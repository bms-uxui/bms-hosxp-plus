import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_antibiotices/item_antibiotices_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'antibiotices_view_model.dart';
export 'antibiotices_view_model.dart';

class AntibioticesViewWidget extends StatefulWidget {
  const AntibioticesViewWidget({super.key});

  @override
  State<AntibioticesViewWidget> createState() => _AntibioticesViewWidgetState();
}

class _AntibioticesViewWidgetState extends State<AntibioticesViewWidget> {
  late AntibioticesViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AntibioticesViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
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
              ),
              0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB078FF), Color(0xFF9040FF)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    Icons.grid_4x4,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    size: 12.0,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'ยาปฏิชีวนะ',
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        color: Color(0xFF9040FF),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                      ),
                ),
              ),
            ].divide(SizedBox(width: 8.0)),
          ),
        ),
        wrapWithModel(
          model: _model.itemAntibioticesModel1,
          updateCallback: () => safeSetState(() {}),
          child: ItemAntibioticesWidget(
            number: '1. ',
            nameantibiotices: '[C] CHLORPHENIRAMINE SYR 2 mg/5ml van (60 ml.)',
            howtouse:
                'รับประทานครั้งละ 5.0 tab วันละ 1 ครั้ง ก่อนอาหารเช้า ครึ่ง เม็ดหลังอาหารเย็น',
            helplabel:
                'หลังผสมเก็บที่อุณหภูมิห้องได้ 24 ชม. เก็บ 2-8 องศา นาน 7 วัน',
            commander: 'ทดลอง ทดสอบ',
            orderdate: '5 มิ.ย. 2568',
            discontinuancedate: '20 มิ.ย. 2568',
            numday: '5',
          ),
        ),
        wrapWithModel(
          model: _model.itemAntibioticesModel2,
          updateCallback: () => safeSetState(() {}),
          child: ItemAntibioticesWidget(
            number: '2. ',
            nameantibiotices: '[C] CHLORPHENIRAMINE SYR 2 mg/5ml van (60 ml.)',
            howtouse:
                'รับประทานครั้งละ 5.0 tab วันละ 1 ครั้ง ก่อนอาหารเช้า ครึ่ง เม็ดหลังอาหารเย็น',
            helplabel:
                'หลังผสมเก็บที่อุณหภูมิห้องได้ 24 ชม. เก็บ 2-8 องศา นาน 7 วัน',
            commander: 'ทดลอง ทดสอบ',
            orderdate: '5 มิ.ย. 2568',
            discontinuancedate: '20 มิ.ย. 2568',
            numday: '5',
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
    );
  }
}
