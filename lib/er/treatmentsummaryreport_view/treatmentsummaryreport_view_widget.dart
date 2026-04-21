import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'treatmentsummaryreport_view_model.dart';
export 'treatmentsummaryreport_view_model.dart';

class TreatmentsummaryreportViewWidget extends StatefulWidget {
  const TreatmentsummaryreportViewWidget({super.key});

  @override
  State<TreatmentsummaryreportViewWidget> createState() =>
      _TreatmentsummaryreportViewWidgetState();
}

class _TreatmentsummaryreportViewWidgetState
    extends State<TreatmentsummaryreportViewWidget>
    with TickerProviderStateMixin {
  late TreatmentsummaryreportViewModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TreatmentsummaryreportViewModel());

    animationsMap.addAll({
      'iconOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 730.0.ms,
            duration: 2500.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'iconOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 730.0.ms,
            duration: 2500.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HPI',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้บันทึก : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'รายละเอียด',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                            Text(
                              'มีไข้สูง ปวดท้อง',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ตรวจร่างกาย',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้ตรวจ : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
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
                                    FlutterFlowTheme.of(context).customColor11,
                                    FlutterFlowTheme.of(context).customColor12
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.boy_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 12.0,
                                ),
                              ),
                            ),
                            Text(
                              'บันทึกการตรวจร่างกาย',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
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
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'รายละเอียด',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                            Text(
                              'ผู้ป่วยชายอายุ 52 ปี มาด้วยอาการปวดท้องด้านขวาล่างมา ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'หัตถการ',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCE7FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  'ลำดับ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.5,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'รายการ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'ผู้ทำหัตถการ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  '1.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.5,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'ADL (Feeding)',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'อรพินท์ จันทา',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  '2.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.5,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'ADL (Feeding)',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'อรพินท์ จันทา',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผล LAB',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้สั่ง : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCE7FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                height: double.infinity,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'ลำดับ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'รายการ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    'รายงานผล',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                height: double.infinity,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    '1.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'HbA1C',
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily,
                                              letterSpacing: 0.5,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodySmallIsCustom,
                                            ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 100.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x1A5FD187),
                                            Color(0x273AAA5F)
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 4.0, 12.0, 4.0),
                                        child: Text(
                                          '79',
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .success,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      '2',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'HbA1C',
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily,
                                              letterSpacing: 0.5,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodySmallIsCustom,
                                            ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 100.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x19F47A86),
                                            Color(0x25BE1E2D)
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 4.0, 12.0, 4.0),
                                        child: Text(
                                          '79',
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      '3',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'HbA1C',
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily,
                                              letterSpacing: 0.5,
                                              lineHeight: 1.5,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodySmallIsCustom,
                                            ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 100.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFB960),
                                            Color(0xFFFFA02A)
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
                                        child: Icon(
                                          Icons.hourglass_top_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 12.0,
                                        ).animateOnPageLoad(animationsMap[
                                            'iconOnPageLoadAnimation1']!),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผล X-ray',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้สั่ง : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCE7FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  'ลำดับ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.5,
                                        lineHeight: 1.5,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'รายการ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    'รายงานผล',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    '1.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Skull AP-Lat (Digital)',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 100.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFB960),
                                            Color(0xFFFFA02A)
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
                                        child: Icon(
                                          Icons.hourglass_top_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 12.0,
                                        ).animateOnPageLoad(animationsMap[
                                            'iconOnPageLoadAnimation2']!),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'วินิจฉัย',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้วินิจฉัย : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCE7FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                height: double.infinity,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'ลำดับ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'รหัส',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'รายการ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'ประเภท',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    '1.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 80.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'J00',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Acute nasopharyngitis [common cold]',
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 100.0,
                                  height: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Principal Dianosis',
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis Text',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Color(0xFF2397FF),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ' ผู้วินิจฉัย : ',
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
                          TextSpan(
                            text: 'นายแพทย์ทดลอง ทดสอบ',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 48.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0x0D2397FF),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCE7FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                height: double.infinity,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'ลำดับ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'ผลวินิจฉัย',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 60.0,
                                decoration: BoxDecoration(),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    '1.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          letterSpacing: 0.5,
                                          lineHeight: 1.5,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'ปวดหัว ตัวร้อน มีไข้สูง',
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.5,
                                            lineHeight: 1.5,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
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
      ),
    );
  }
}
