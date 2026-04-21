import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chronic_disease_model.dart';
export 'chronic_disease_model.dart';

class ChronicDiseaseWidget extends StatefulWidget {
  const ChronicDiseaseWidget({
    super.key,
    this.chronicdisease,
  });

  /// ChronicDisease
  final String? chronicdisease;

  @override
  State<ChronicDiseaseWidget> createState() => _ChronicDiseaseWidgetState();
}

class _ChronicDiseaseWidgetState extends State<ChronicDiseaseWidget> {
  late ChronicDiseaseModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChronicDiseaseModel());

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFBD6EF2), Color(0xFFAF1EBE)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 12.0, 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 32.0,
                height: 32.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/virus-removebg-preview.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            RichText(
              textScaler: MediaQuery.of(context).textScaler,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'โรคเรื้อรัง : ',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w300,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                  TextSpan(
                    text: valueOrDefault<String>(
                      widget!.chronicdisease,
                      'Name',
                    ),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  )
                ],
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
