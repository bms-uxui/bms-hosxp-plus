import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'not_durg_model.dart';
export 'not_durg_model.dart';

class NotDurgWidget extends StatefulWidget {
  const NotDurgWidget({
    super.key,
    this.spac,
    this.title,
    this.detail,
    this.fontsize,
    this.textcolor,
    this.imagem,
    this.imaget,
    this.hidedetail,
  });

  final double? spac;
  final String? title;
  final String? detail;
  final double? fontsize;
  final Color? textcolor;
  final double? imagem;
  final double? imaget;
  final bool? hidedetail;

  @override
  State<NotDurgWidget> createState() => _NotDurgWidgetState();
}

class _NotDurgWidgetState extends State<NotDurgWidget> {
  late NotDurgModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotDurgModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/blister.gif',
            width: 56.0,
            height: 56.0,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              valueOrDefault<String>(
                widget!.title,
                'ไม่มีข้อมูล!',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
            if (widget!.hidedetail ?? true)
              Text(
                valueOrDefault<String>(
                  widget!.detail,
                  'ยังไม่มีข้อมูล กรุณาตรวจสอบหรือเพิ่มข้อมูลก่อน',
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                      letterSpacing: 0.0,
                      lineHeight: 1.8,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                    ),
              ),
          ].divide(SizedBox(height: 4.0)),
        ),
      ].divide(SizedBox(
          height: valueOrDefault<double>(
        widget!.spac,
        12.0,
      ))),
    );
  }
}
