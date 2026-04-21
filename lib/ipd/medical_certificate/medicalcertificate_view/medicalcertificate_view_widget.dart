import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/medical_certificate/item_medicalcertificate/item_medicalcertificate_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'medicalcertificate_view_model.dart';
export 'medicalcertificate_view_model.dart';

class MedicalcertificateViewWidget extends StatefulWidget {
  const MedicalcertificateViewWidget({
    super.key,
    bool? buttonadd,
    this.crossAxisCount,
  }) : this.buttonadd = buttonadd ?? false;

  final bool buttonadd;
  final int? crossAxisCount;

  @override
  State<MedicalcertificateViewWidget> createState() =>
      _MedicalcertificateViewWidgetState();
}

class _MedicalcertificateViewWidgetState
    extends State<MedicalcertificateViewWidget> {
  late MedicalcertificateViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MedicalcertificateViewModel());

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
      child: Padding(
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
            2.0,
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
                        child: FaIcon(
                          FontAwesomeIcons.fileMedical,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          size: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
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
                        ),
                      ),
                    ),
                    Text(
                      'ออกใบรับรองแพทย์',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: FlutterFlowTheme.of(context).customColor12,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
                if (_model.buttonadd == widget!.buttonadd)
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(AddMedicalcertificateWidget.routeName);
                    },
                    child: wrapWithModel(
                      model: _model.iconButtonPrimaryModel,
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
                  ),
              ],
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(MedicalcertificateDetailWidget.routeName);
              },
              child: wrapWithModel(
                model: _model.itemMedicalcertificateModel1,
                updateCallback: () => safeSetState(() {}),
                child: ItemMedicalcertificateWidget(
                  crossAxisCount: widget!.crossAxisCount,
                ),
              ),
            ),
            wrapWithModel(
              model: _model.itemMedicalcertificateModel2,
              updateCallback: () => safeSetState(() {}),
              child: ItemMedicalcertificateWidget(
                crossAxisCount: widget!.crossAxisCount,
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
