import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'discussionnotinitiated_model.dart';
export 'discussionnotinitiated_model.dart';

class DiscussionnotinitiatedWidget extends StatefulWidget {
  const DiscussionnotinitiatedWidget({super.key});

  @override
  State<DiscussionnotinitiatedWidget> createState() =>
      _DiscussionnotinitiatedWidgetState();
}

class _DiscussionnotinitiatedWidgetState
    extends State<DiscussionnotinitiatedWidget> {
  late DiscussionnotinitiatedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiscussionnotinitiatedModel());

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
          colors: [Color(0x27838689), Color(0x25465054)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 2.0,
            sigmaY: 2.0,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(6.0, 2.0, 12.0, 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF838689),
                        FlutterFlowTheme.of(context).secondaryText
                      ],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'ยังไม่ได้เจรจา',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ].divide(SizedBox(width: 4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
