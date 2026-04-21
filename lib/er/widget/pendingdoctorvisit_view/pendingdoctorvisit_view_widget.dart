import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/er/item_patient_e_r/item_patient_e_r_widget.dart';
import '/er/widget/non_urgent_e_s_i/non_urgent_e_s_i_widget.dart';
import '/er/widget/semi_urgent_e_s_i/semi_urgent_e_s_i_widget.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pendingdoctorvisit_view_model.dart';
export 'pendingdoctorvisit_view_model.dart';

class PendingdoctorvisitViewWidget extends StatefulWidget {
  const PendingdoctorvisitViewWidget({super.key});

  @override
  State<PendingdoctorvisitViewWidget> createState() =>
      _PendingdoctorvisitViewWidgetState();
}

class _PendingdoctorvisitViewWidgetState
    extends State<PendingdoctorvisitViewWidget> {
  late PendingdoctorvisitViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PendingdoctorvisitViewModel());

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowRadioButton(
                      options: [
                        'ทั้งหมด 2 คน',
                        'รอตรวจ 2 คน',
                        'รอผลตรวจ Lab/Xray 0 คน'
                      ].toList(),
                      onChanged: (val) => safeSetState(() {}),
                      controller: _model.radioButtonValueController ??=
                          FormFieldController<String>(null),
                      optionHeight: 24.0,
                      textStyle: FlutterFlowTheme.of(context)
                          .labelMedium
                          .override(
                            fontFamily:
                                FlutterFlowTheme.of(context).labelMediumFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .labelMediumIsCustom,
                          ),
                      selectedTextStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                      textPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      buttonPosition: RadioButtonPosition.left,
                      direction: Axis.vertical,
                      radioButtonColor: FlutterFlowTheme.of(context).primary,
                      inactiveRadioButtonColor:
                          FlutterFlowTheme.of(context).secondaryText,
                      toggleable: false,
                      horizontalAlignment: WrapAlignment.start,
                      verticalAlignment: WrapCrossAlignment.start,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(PatientInfoERWidget.routeName);

                FFAppState().TabMenuPatientInfoER = 4;
                safeSetState(() {});
              },
              child: wrapWithModel(
                model: _model.itemPatientERModel1,
                updateCallback: () => safeSetState(() {}),
                child: ItemPatientERWidget(
                  image:
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/zwr6ci9pz8d7/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_00_35.png',
                  queue: '4',
                  age: 'อายุ 33 ปี',
                  colorAge: FlutterFlowTheme.of(context).primaryText,
                  screeningData: false,
                  fullname: 'นายทดลอง ทดสอบ',
                  gender: () => IconMaleWidget(),
                  esi: () => NonUrgentESIWidget(),
                ),
              ),
            ),
            wrapWithModel(
              model: _model.itemPatientERModel2,
              updateCallback: () => safeSetState(() {}),
              child: ItemPatientERWidget(
                image:
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/kks5eo2nde9z/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_08_16.png',
                queue: '5',
                age: 'อายุ 70 ปี',
                colorAge: FlutterFlowTheme.of(context).customColor20,
                screeningData: false,
                fullname: 'นางทดลอง ทดสอบ',
                gender: () => IconFemaleWidget(),
                esi: () => SemiUrgentESIWidget(),
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
