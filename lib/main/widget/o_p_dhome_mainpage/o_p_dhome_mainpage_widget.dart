import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/workflow/workflow_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'o_p_dhome_mainpage_model.dart';
export 'o_p_dhome_mainpage_model.dart';

class OPDhomeMainpageWidget extends StatefulWidget {
  const OPDhomeMainpageWidget({super.key});

  @override
  State<OPDhomeMainpageWidget> createState() => _OPDhomeMainpageWidgetState();
}

class _OPDhomeMainpageWidgetState extends State<OPDhomeMainpageWidget> {
  late OPDhomeMainpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPDhomeMainpageModel());

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
                    titletext: 'ข้อมูลผู้ป่วยนอกแยกตามสถานะรอรับบริการ',
                    icon: FaIcon(
                      FontAwesomeIcons.userInjured,
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
                  child: wrapWithModel(
                    model: _model.workflowModel,
                    updateCallback: () => safeSetState(() {}),
                    child: WorkflowWidget(),
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
              }())).addToEnd(SizedBox(height: 100.0)),
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
