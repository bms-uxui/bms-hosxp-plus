import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/drunglist_view/drunglist_view_widget.dart';
import '/ipd/drugand_service/item_service/item_service_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drug_srevice_view_model.dart';
export 'drug_srevice_view_model.dart';

class DrugSreviceViewWidget extends StatefulWidget {
  const DrugSreviceViewWidget({super.key});

  @override
  State<DrugSreviceViewWidget> createState() => _DrugSreviceViewWidgetState();
}

class _DrugSreviceViewWidgetState extends State<DrugSreviceViewWidget>
    with TickerProviderStateMixin {
  late DrugSreviceViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrugSreviceViewModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

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
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment(0.0, 0),
            child: TabBar(
              labelColor: FlutterFlowTheme.of(context).primaryText,
              unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
              labelPadding: EdgeInsets.all(2.0),
              labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).labelLargeFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelLargeIsCustom,
                  ),
              unselectedLabelStyle: FlutterFlowTheme.of(context)
                  .bodyLarge
                  .override(
                    fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                  ),
              indicatorColor: FlutterFlowTheme.of(context).primary,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              tabs: [
                Tab(
                  text: 'ยา',
                ),
                Tab(
                  text: 'ค่าบริการ',
                ),
              ],
              controller: _model.tabBarController,
              onTap: (i) async {
                [() async {}, () async {}][i]();
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _model.tabBarController,
              children: [
                wrapWithModel(
                  model: _model.drunglistViewModel,
                  updateCallback: () => safeSetState(() {}),
                  child: DrunglistViewWidget(
                    buttonMedOder: true,
                  ),
                ),
                ListView(
                  padding: EdgeInsets.fromLTRB(
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
                    0,
                    24.0,
                  ),
                  scrollDirection: Axis.vertical,
                  children: [
                    Padding(
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
                      child: Row(
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
                                  child: FaIcon(
                                    FontAwesomeIcons.handHoldingUsd,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: 10.0,
                                  ),
                                ),
                              ),
                              Text(
                                'ค่ารักษาพยาบาลอื่นๆ',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
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
                      child: wrapWithModel(
                        model: _model.itemServiceModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemServiceWidget(
                          num: '1',
                          title: 'Lactate, Blood',
                          amount: '200',
                          type: 'ค่าตรวจวินิจฉัยทางเทคนิคการแพทย์และพยาธิวิทยา',
                          paymentmethod: 'ลูกหนี้สิทธิ',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
