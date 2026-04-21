import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_sheet_datepicker_model.dart';
export 'button_sheet_datepicker_model.dart';

class ButtonSheetDatepickerWidget extends StatefulWidget {
  const ButtonSheetDatepickerWidget({super.key});

  @override
  State<ButtonSheetDatepickerWidget> createState() =>
      _ButtonSheetDatepickerWidgetState();
}

class _ButtonSheetDatepickerWidgetState
    extends State<ButtonSheetDatepickerWidget> {
  late ButtonSheetDatepickerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonSheetDatepickerModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: () {
          if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
            return 480.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 480.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 550.0;
          } else {
            return 550.0;
          }
        }(),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Text(
                    dateTimeFormat(
                        "d MMMM y", _model.calendarSelectedDay!.start),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                  Container(
                    width: 50.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.rectangle,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ตกลง',
                          style: GoogleFonts.roboto(
                            color: FlutterFlowTheme.of(context).info,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FlutterFlowCalendar(
              color: FlutterFlowTheme.of(context).primary,
              iconColor: FlutterFlowTheme.of(context).secondaryText,
              weekFormat: false,
              weekStartsMonday: false,
              initialDate: getCurrentTimestamp,
              rowHeight: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 56.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 56.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 64.0;
                } else {
                  return 64.0;
                }
              }(),
              onChange: (DateTimeRange? newSelectedDate) {
                safeSetState(
                    () => _model.calendarSelectedDay = newSelectedDate);
              },
              titleStyle: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleLargeIsCustom,
                  ),
              dayOfWeekStyle: FlutterFlowTheme.of(context).labelSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                    color: Color(0xFF57636C),
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelSmallIsCustom,
                  ),
              dateStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
              selectedDateStyle: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
              inactiveDateStyle: FlutterFlowTheme.of(context)
                  .labelMedium
                  .override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                    color: Color(0xFF989898),
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelMediumIsCustom,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
