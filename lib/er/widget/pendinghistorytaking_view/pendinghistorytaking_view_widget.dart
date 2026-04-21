import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/er/item_patient_e_r/item_patient_e_r_widget.dart';
import '/er/widget/emergency_e_s_i/emergency_e_s_i_widget.dart';
import '/er/widget/resuscitation_e_s_i/resuscitation_e_s_i_widget.dart';
import '/er/widget/semi_urgent_e_s_i/semi_urgent_e_s_i_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pendinghistorytaking_view_model.dart';
export 'pendinghistorytaking_view_model.dart';

class PendinghistorytakingViewWidget extends StatefulWidget {
  const PendinghistorytakingViewWidget({super.key});

  @override
  State<PendinghistorytakingViewWidget> createState() =>
      _PendinghistorytakingViewWidgetState();
}

class _PendinghistorytakingViewWidgetState
    extends State<PendinghistorytakingViewWidget> {
  late PendinghistorytakingViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PendinghistorytakingViewModel());

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
      decoration: BoxDecoration(),
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
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              height: 24.0,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'รอซักประวัติ 5 คน',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ],
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(PatientInfoERWidget.routeName);

                FFAppState().TabMenuPatientInfoER = 3;
                safeSetState(() {});
              },
              child: wrapWithModel(
                model: _model.itemPatientERModel1,
                updateCallback: () => safeSetState(() {}),
                child: ItemPatientERWidget(
                  image:
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/zwr6ci9pz8d7/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_00_35.png',
                  queue: '1',
                  age: 'อายุ 52 ปี',
                  colorAge: FlutterFlowTheme.of(context).customColor20,
                  screeningData: true,
                  fullname: 'นายทดลอง ทดสอบ',
                  gender: () => IconMaleWidget(),
                  esi: () => ResuscitationESIWidget(),
                ),
              ),
            ),
            wrapWithModel(
              model: _model.itemPatientERModel2,
              updateCallback: () => safeSetState(() {}),
              child: ItemPatientERWidget(
                image:
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/kks5eo2nde9z/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_08_16.png',
                queue: '2',
                age: 'อายุ 68 ปี',
                colorAge: FlutterFlowTheme.of(context).customColor20,
                screeningData: true,
                fullname: 'นางทดลอง ทดสอบ',
                gender: () => IconFemaleWidget(),
                esi: () => SemiUrgentESIWidget(),
              ),
            ),
            wrapWithModel(
              model: _model.itemPatientERModel3,
              updateCallback: () => safeSetState(() {}),
              child: ItemPatientERWidget(
                image:
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/73um5jre73yp/ChatGPT_Image_19_%E0%B8%9E.%E0%B8%84._2568_13_11_36.png',
                queue: '3',
                age: 'อายุ 25 ปี',
                colorAge: FlutterFlowTheme.of(context).primaryText,
                screeningData: true,
                fullname: 'นายทดลอง ทดสอบ',
                gender: () => IconMaleWidget(),
                esi: () => EmergencyESIWidget(),
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
      ),
    );
  }
}
