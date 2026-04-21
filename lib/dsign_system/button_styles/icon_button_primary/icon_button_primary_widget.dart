import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_button_primary_model.dart';
export 'icon_button_primary_model.dart';

class IconButtonPrimaryWidget extends StatefulWidget {
  const IconButtonPrimaryWidget({
    super.key,
    this.iconbuttonprimary,
  });

  final Widget? iconbuttonprimary;

  @override
  State<IconButtonPrimaryWidget> createState() =>
      _IconButtonPrimaryWidgetState();
}

class _IconButtonPrimaryWidgetState extends State<IconButtonPrimaryWidget> {
  late IconButtonPrimaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconButtonPrimaryModel());

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
      width: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 48.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 48.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 56.0;
        } else {
          return 56.0;
        }
      }(),
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
        shape: BoxShape.rectangle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Text(
          'เพิ่ม',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }
}
