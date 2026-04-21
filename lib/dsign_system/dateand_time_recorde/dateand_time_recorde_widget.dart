import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dateand_time_recorde_model.dart';
export 'dateand_time_recorde_model.dart';

class DateandTimeRecordeWidget extends StatefulWidget {
  const DateandTimeRecordeWidget({
    super.key,
    this.day,
    this.month,
    this.year,
    this.time,
    Color? color,
  }) : this.color = color ?? const Color(0xFF465054);

  final String? day;
  final String? month;
  final String? year;
  final String? time;
  final Color color;

  @override
  State<DateandTimeRecordeWidget> createState() =>
      _DateandTimeRecordeWidgetState();
}

class _DateandTimeRecordeWidgetState extends State<DateandTimeRecordeWidget> {
  late DateandTimeRecordeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DateandTimeRecordeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: valueOrDefault<String>(
              widget!.day,
              '00',
            ),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: '-',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: Color(0x00465054),
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: valueOrDefault<String>(
              widget!.month,
              'M.M',
            ),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: '-',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: Color(0x00465054),
                  letterSpacing: 0.0,
                  fontStyle: FontStyle.italic,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: valueOrDefault<String>(
              widget!.year,
              'YYYY',
            ),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: ' - ',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: valueOrDefault<String>(
              widget!.time,
              '00:00',
            ),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          TextSpan(
            text: ' น.',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: widget!.color,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          )
        ],
        style: FlutterFlowTheme.of(context).labelSmall.override(
              fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
            ),
      ),
    );
  }
}
