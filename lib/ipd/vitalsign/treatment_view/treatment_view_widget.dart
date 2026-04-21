import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/fillter_treatment_i_p_d/fillter_treatment_i_p_d_widget.dart';
import '/ipd/vitalsign/item_treatment/item_treatment_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'treatment_view_model.dart';
export 'treatment_view_model.dart';

class TreatmentViewWidget extends StatefulWidget {
  const TreatmentViewWidget({
    super.key,
    bool? buttonaddTreatment,
  }) : this.buttonaddTreatment = buttonaddTreatment ?? false;

  final bool buttonaddTreatment;

  @override
  State<TreatmentViewWidget> createState() => _TreatmentViewWidgetState();
}

class _TreatmentViewWidgetState extends State<TreatmentViewWidget> {
  late TreatmentViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TreatmentViewModel());

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
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
                      child: FaIcon(
                        FontAwesomeIcons.syringe,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 12.0,
                      ),
                    ),
                  ),
                  Text(
                    'หัตถการผู้ป่วยใน',
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
                ].divide(SizedBox(width: 8.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        isDismissible: false,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: FillterTreatmentIPDWidget(),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    child: wrapWithModel(
                      model: _model.buttonFillterModel,
                      updateCallback: () => safeSetState(() {}),
                      child: ButtonFillterWidget(
                        colorbg: FlutterFlowTheme.of(context).alternate,
                        coloricon: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ),
                  if (_model.buttonaddTreatment == widget!.buttonaddTreatment)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(AddTreatmentIPDWidget.routeName);
                      },
                      child: wrapWithModel(
                        model: _model.iconButtonPrimaryModel,
                        updateCallback: () => safeSetState(() {}),
                        child: IconButtonPrimaryWidget(
                          iconbuttonprimary: Icon(
                            Icons.add_rounded,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                ].divide(SizedBox(width: 8.0)),
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
            context.pushNamed(TreatmentIPDDetailWidget.routeName);
          },
          child: wrapWithModel(
            model: _model.itemTreatmentModel1,
            updateCallback: () => safeSetState(() {}),
            child: ItemTreatmentWidget(),
          ),
        ),
        wrapWithModel(
          model: _model.itemTreatmentModel2,
          updateCallback: () => safeSetState(() {}),
          child: ItemTreatmentWidget(),
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
