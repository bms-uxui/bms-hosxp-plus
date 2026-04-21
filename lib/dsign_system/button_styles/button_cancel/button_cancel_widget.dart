import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_cancel_model.dart';
export 'button_cancel_model.dart';

class ButtonCancelWidget extends StatefulWidget {
  const ButtonCancelWidget({super.key});

  @override
  State<ButtonCancelWidget> createState() => _ButtonCancelWidgetState();
}

class _ButtonCancelWidgetState extends State<ButtonCancelWidget> {
  late ButtonCancelModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonCancelModel());

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
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
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
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            'ยกเลิก',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                  color: FlutterFlowTheme.of(context).error,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                ),
          ),
        ),
      ),
    );
  }
}
