import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_nurs_probltm/item_nurs_probltm_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nurs_probltm_view_model.dart';
export 'nurs_probltm_view_model.dart';

class NursProbltmViewWidget extends StatefulWidget {
  const NursProbltmViewWidget({
    super.key,
    bool? buttonaddNursPromple,
  }) : this.buttonaddNursPromple = buttonaddNursPromple ?? false;

  final bool buttonaddNursPromple;

  @override
  State<NursProbltmViewWidget> createState() => _NursProbltmViewWidgetState();
}

class _NursProbltmViewWidgetState extends State<NursProbltmViewWidget> {
  late NursProbltmViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NursProbltmViewModel());

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
                        FontAwesomeIcons.userNurse,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 12.0,
                      ),
                    ),
                  ),
                  Text(
                    'ปัญหาทางพยาบาล',
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
              if (_model.buttonaddNursPromple == widget!.buttonaddNursPromple)
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed(AddNursingproblemsWidget.routeName);
                  },
                  child: wrapWithModel(
                    model: _model.iconButtonPrimaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: IconButtonPrimaryWidget(
                      iconbuttonprimary: Icon(
                        Icons.add_rounded,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 20.0,
                      ),
                    ),
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
            context.pushNamed(NursingProblemsDetailWidget.routeName);
          },
          child: wrapWithModel(
            model: _model.itemNursProbltmModel,
            updateCallback: () => safeSetState(() {}),
            child: ItemNursProbltmWidget(
              userrecorder: 'ทดลอง ทดสอบ',
              day: '12',
              month: 'มิ.ย',
              year: '2568',
              time: '11:00',
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
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
