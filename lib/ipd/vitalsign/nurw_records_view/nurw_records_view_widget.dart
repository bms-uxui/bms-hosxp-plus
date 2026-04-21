import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_nurw_records/item_nurw_records_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nurw_records_view_model.dart';
export 'nurw_records_view_model.dart';

class NurwRecordsViewWidget extends StatefulWidget {
  const NurwRecordsViewWidget({
    super.key,
    this.crossAxisCount,
    bool? bottonAddNursRecod,
  }) : this.bottonAddNursRecod = bottonAddNursRecod ?? false;

  final int? crossAxisCount;
  final bool bottonAddNursRecod;

  @override
  State<NurwRecordsViewWidget> createState() => _NurwRecordsViewWidgetState();
}

class _NurwRecordsViewWidgetState extends State<NurwRecordsViewWidget> {
  late NurwRecordsViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NurwRecordsViewModel());

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    'บันทึกพยาบาล',
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
                  if (_model.bottonAddNursRecod == widget!.bottonAddNursRecod)
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(AddNursingrecordsWidget.routeName);
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
            ].divide(SizedBox(width: 8.0)),
          ),
        ),
        wrapWithModel(
          model: _model.itemNurwRecordsModel1,
          updateCallback: () => safeSetState(() {}),
          child: ItemNurwRecordsWidget(
            icon: FaIcon(
              FontAwesomeIcons.solidSun,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 12.0,
            ),
            duty: 'เวรเช้า',
            day: '12',
            month: 'มิ.ย',
            year: '2568',
            time: '12:00',
            color: FlutterFlowTheme.of(context).secondaryText,
            crossAxisCount: widget!.crossAxisCount,
          ),
        ),
        wrapWithModel(
          model: _model.itemNurwRecordsModel2,
          updateCallback: () => safeSetState(() {}),
          child: ItemNurwRecordsWidget(
            icon: FaIcon(
              FontAwesomeIcons.solidMoon,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 12.0,
            ),
            duty: 'เวนดึก',
            day: '2',
            month: 'มิ.ย',
            year: '2568',
            time: '10:00',
            color: FlutterFlowTheme.of(context).secondaryText,
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
    );
  }
}
