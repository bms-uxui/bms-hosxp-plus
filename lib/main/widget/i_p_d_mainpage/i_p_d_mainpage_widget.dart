import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/menutab/menutab_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/tab_a_d/tab_a_d_widget.dart';
import '/main/widget/tab_u_t/tab_u_t_widget.dart';
import '/main/widget/tab_v_b/tab_v_b_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'i_p_d_mainpage_model.dart';
export 'i_p_d_mainpage_model.dart';

class IPDMainpageWidget extends StatefulWidget {
  const IPDMainpageWidget({super.key});

  @override
  State<IPDMainpageWidget> createState() => _IPDMainpageWidgetState();
}

class _IPDMainpageWidgetState extends State<IPDMainpageWidget> {
  late IPDMainpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IPDMainpageModel());

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
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wrapWithModel(
                  model: _model.iconTitleModel,
                  updateCallback: () => safeSetState(() {}),
                  child: IconTitleWidget(
                    titletext: 'ข้อมูลผู้ป่วยใน',
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
                        fontFamily:
                            FlutterFlowTheme.of(context).labelSmallFamily,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                wrapWithModel(
                                  model: _model.menutabModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: MenutabWidget(
                                    tab: 'กำลังรักษา',
                                    stage: _model.page,
                                    action: () async {
                                      _model.page = 'กำลังรักษา';
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.menutabModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: MenutabWidget(
                                    tab: 'รับใหม่และจำหน่าย',
                                    stage: _model.page,
                                    action: () async {
                                      _model.page = 'รับใหม่และจำหน่าย';
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.menutabModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: MenutabWidget(
                                    tab: 'เตียงว่าง',
                                    stage: _model.page,
                                    action: () async {
                                      _model.page = 'เตียงว่าง';
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (_model.page == 'กำลังรักษา') {
                              return wrapWithModel(
                                model: _model.tabUTModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TabUTWidget(),
                              );
                            } else if (_model.page == 'รับใหม่และจำหน่าย') {
                              return wrapWithModel(
                                model: _model.tabADModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TabADWidget(),
                              );
                            } else if (_model.page == 'เตียงว่าง') {
                              return wrapWithModel(
                                model: _model.tabVBModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TabVBWidget(),
                              );
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [],
                              );
                            }
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
                  ),
                ),
              ].divide(SizedBox(height: () {
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
          }())).addToEnd(SizedBox(height: 100.0)),
        ),
      ),
    );
  }
}
