import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'botton_primary1_model.dart';
export 'botton_primary1_model.dart';

class BottonPrimary1Widget extends StatefulWidget {
  const BottonPrimary1Widget({
    super.key,
    this.buttonprimary,
  });

  /// ButtonPrimary
  final String? buttonprimary;

  @override
  State<BottonPrimary1Widget> createState() => _BottonPrimary1WidgetState();
}

class _BottonPrimary1WidgetState extends State<BottonPrimary1Widget> {
  late BottonPrimary1Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottonPrimary1Model());

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
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 32.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 32.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 40.0;
        } else {
          return 40.0;
        }
      }(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).accent2,
            FlutterFlowTheme.of(context).accent1
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              valueOrDefault<String>(
                widget!.buttonprimary,
                'Button Primary',
              ),
              textAlign: TextAlign.start,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
