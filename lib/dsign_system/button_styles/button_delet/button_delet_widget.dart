import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_delet_model.dart';
export 'button_delet_model.dart';

class ButtonDeletWidget extends StatefulWidget {
  const ButtonDeletWidget({super.key});

  @override
  State<ButtonDeletWidget> createState() => _ButtonDeletWidgetState();
}

class _ButtonDeletWidgetState extends State<ButtonDeletWidget> {
  late ButtonDeletModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonDeletModel());

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
          return 40.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 40.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 48.0;
        } else {
          return 48.0;
        }
      }(),
      constraints: BoxConstraints(
        minWidth: 120.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF44654), FlutterFlowTheme.of(context).error],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            Navigator.pop(context);
          },
          child: Text(
            'ลบ',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      ),
    );
  }
}
