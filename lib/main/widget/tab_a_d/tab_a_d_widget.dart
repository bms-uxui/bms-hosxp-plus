import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'tab_a_d_model.dart';
export 'tab_a_d_model.dart';

/// Infomation Chart Admission And Discharge
class TabADWidget extends StatefulWidget {
  const TabADWidget({super.key});

  @override
  State<TabADWidget> createState() => _TabADWidgetState();
}

class _TabADWidgetState extends State<TabADWidget> {
  late TabADModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TabADModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      crossAxisSpacing: () {
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
      mainAxisSpacing: () {
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
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                ),
              ),
          () => Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              8.0,
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
                              8.0),
                          child: Text(
                            'รวม 520 คน',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleSmallIsCustom,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16.0,
                              height: 16.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFA0A0A0),
                                    FlutterFlowTheme.of(context).secondaryText
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              'จำหน่าย',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ].divide(SizedBox(width: 12.0)),
                        ),
                      ),
                    ],
                  ),
                  MasonryGridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
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
                    crossAxisSpacing: 8.0,
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
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7DDCEB),
                                        Color(0xFF55AFBD)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'อายุรกรรม',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7AC1ED),
                                        Color(0xFF4396D0)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'ศัลยกรรม',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4A97DE),
                                        Color(0xFF2C6CB1)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'สูติกรรม',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7A8DE5),
                                        Color(0xFF2E408D)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'กุมารเวชกรรม',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF806EB3),
                                        Color(0xFF4F3C8B)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'โสต ศอ นาสิก',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFC876BA),
                                        Color(0xFF8D328F)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'จิตเวช',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE58CAC),
                                        Color(0xFFD64162)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'แพทย์แผนไทย',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF5A95F),
                                        Color(0xFFE06637)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'ศัลยกรรมประสาท',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF4BA1F),
                                        Color(0xFFC39006)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'เวชกรรมสังคม',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                        () => Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFA9CB58),
                                        Color(0xFF67972B)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'กายอุปกรณ์ (นักกายอุปกรณ์)',
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
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                      ][index]();
                    },
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
        ][index]();
      },
    );
  }
}
