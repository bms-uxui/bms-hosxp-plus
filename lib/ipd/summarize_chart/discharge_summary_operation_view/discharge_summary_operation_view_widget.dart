import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/summarize_chart/item_i_m_p_o_r_t_a_n_t_n_o_n_o_p_e_r_a_t_i_n_g_r_o_o_m_p_r_o_c_e_d_u_r_e_s/item_i_m_p_o_r_t_a_n_t_n_o_n_o_p_e_r_a_t_i_n_g_r_o_o_m_p_r_o_c_e_d_u_r_e_s_widget.dart';
import '/ipd/summarize_chart/item_o_p_e_r_a_t_i_o_n_r_o_o_m_p_r_o_c_e_d_u_r_e/item_o_p_e_r_a_t_i_o_n_r_o_o_m_p_r_o_c_e_d_u_r_e_widget.dart';
import '/ipd/summarize_chart/item_s_p_e_c_i_a_l_i_n_v_e_s_t_i_g_a_t_i_o_n_s/item_s_p_e_c_i_a_l_i_n_v_e_s_t_i_g_a_t_i_o_n_s_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'discharge_summary_operation_view_model.dart';
export 'discharge_summary_operation_view_model.dart';

class DischargeSummaryOperationViewWidget extends StatefulWidget {
  const DischargeSummaryOperationViewWidget({super.key});

  @override
  State<DischargeSummaryOperationViewWidget> createState() =>
      _DischargeSummaryOperationViewWidgetState();
}

class _DischargeSummaryOperationViewWidgetState
    extends State<DischargeSummaryOperationViewWidget> {
  late DischargeSummaryOperationViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DischargeSummaryOperationViewModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
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
          0,
          24.0,
        ),
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FlutterFlowTheme.of(context).accent2,
                                FlutterFlowTheme.of(context).accent1
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
                              Icons.person_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                        Text(
                          'OPERATION ROOM PROCEDURE',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyLargeFamily,
                                color: FlutterFlowTheme.of(context).accent1,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyLargeIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                    wrapWithModel(
                      model: _model.iconButtonPrimaryModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: IconButtonPrimaryWidget(
                        iconbuttonprimary: Icon(
                          Icons.add_rounded,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                wrapWithModel(
                  model: _model.itemOPERATIONROOMPROCEDUREModel1,
                  updateCallback: () => safeSetState(() {}),
                  child: ItemOPERATIONROOMPROCEDUREWidget(
                    icd9: '000',
                    operation: 'Fasciotomy (83.14)',
                    day: '24',
                    month: 'ม.ค.',
                    year: '2568',
                    time: '00:00',
                    operatingDoctor: 'ทดลอง ทดสอบ',
                    extsCode: 'ซ้าย',
                    operationStartDate: '24 ม.ค. 2568',
                    operationStartTime: '00:00',
                    operationEndDate: '24 ม.ค. 2568',
                    operationEndTime: '00:00',
                    incisionDate: '25 ม.ค. 2568',
                    incisionTime: '00:00',
                    closureDate: '24 ม.ค. 2568',
                    closureTime: '00:00',
                    recordedBy: 'ทดลอง ทดสอบ',
                  ),
                ),
                wrapWithModel(
                  model: _model.itemOPERATIONROOMPROCEDUREModel2,
                  updateCallback: () => safeSetState(() {}),
                  child: ItemOPERATIONROOMPROCEDUREWidget(
                    icd9: '000',
                    operation: 'Fasciotomy (83.14)',
                    day: '24',
                    month: 'ม.ค.',
                    year: '2568',
                    time: '00:00',
                    operatingDoctor: 'ทดลอง ทดสอบ',
                    extsCode: 'ซ้าย',
                    operationStartDate: '24 ม.ค. 2568',
                    operationStartTime: '00:00',
                    operationEndDate: '24 ม.ค. 2568',
                    operationEndTime: '00:00',
                    incisionDate: '25 ม.ค. 2568',
                    incisionTime: '00:00',
                    closureDate: '24 ม.ค. 2568',
                    closureTime: '00:00',
                    recordedBy: 'ทดลอง ทดสอบ',
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).customColor5,
                                  FlutterFlowTheme.of(context).customColor6
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
                                Icons.image_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                size: 10.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'IMPORTANT NON OPERATING ROOM PROCEDURES',
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyLargeFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .customColor6,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyLargeIsCustom,
                                  ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.iconButtonPrimaryModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: IconButtonPrimaryWidget(
                        iconbuttonprimary: Icon(
                          Icons.add_rounded,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                wrapWithModel(
                  model: _model.itemIMPORTANTNONOPERATINGROOMPROCEDURESModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ItemIMPORTANTNONOPERATINGROOMPROCEDURESWidget(
                    nonORprocedures: 'Paracentesis',
                    day: '01',
                    month: 'ม.ค.',
                    year: '2568',
                    time: '00:00',
                    diagnosingDoctor: 'ทดลอง ทดสอบ',
                    recordedBy: 'ทดลอง ทดสอบ',
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 16.0;
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FlutterFlowTheme.of(context).customColor7,
                                FlutterFlowTheme.of(context).customColor8
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
                              Icons.featured_play_list,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                        Text(
                          'SPECIAL INVESTIGATIONS',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyLargeFamily,
                                color:
                                    FlutterFlowTheme.of(context).customColor8,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyLargeIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                    wrapWithModel(
                      model: _model.iconButtonPrimaryModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: IconButtonPrimaryWidget(
                        iconbuttonprimary: Icon(
                          Icons.add_rounded,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                wrapWithModel(
                  model: _model.itemSPECIALINVESTIGATIONSModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ItemSPECIALINVESTIGATIONSWidget(),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
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
