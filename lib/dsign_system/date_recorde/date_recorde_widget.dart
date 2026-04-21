import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'date_recorde_model.dart';
export 'date_recorde_model.dart';

class DateRecordeWidget extends StatefulWidget {
  const DateRecordeWidget({
    super.key,
    this.day,
    this.month,
    this.year,
    Color? color,
  }) : this.color = color ?? const Color(0xFF465054);

  final String? day;
  final String? month;
  final String? year;
  final Color color;

  @override
  State<DateRecordeWidget> createState() => _DateRecordeWidgetState();
}

class _DateRecordeWidgetState extends State<DateRecordeWidget> {
  late DateRecordeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DateRecordeModel());

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
