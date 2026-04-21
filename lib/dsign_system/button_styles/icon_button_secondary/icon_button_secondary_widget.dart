import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_button_secondary_model.dart';
export 'icon_button_secondary_model.dart';

class IconButtonSecondaryWidget extends StatefulWidget {
  const IconButtonSecondaryWidget({
    super.key,
    this.iconbuttonsecondary,
    Color? color1,
    Color? color2,
  })  : this.color1 = color1 ?? const Color(0xFFF1F4FF),
        this.color2 = color2 ?? const Color(0xFFD4E8FF);

  final Widget? iconbuttonsecondary;
  final Color color1;
  final Color color2;

  @override
  State<IconButtonSecondaryWidget> createState() =>
      _IconButtonSecondaryWidgetState();
}

class _IconButtonSecondaryWidgetState extends State<IconButtonSecondaryWidget> {
  late IconButtonSecondaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconButtonSecondaryModel());

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
            valueOrDefault<Color>(
              widget!.color1,
              Color(0xFFF1F4FF),
            ),
            valueOrDefault<Color>(
              widget!.color2,
              Color(0xFFD4E8FF),
            )
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
                color: FlutterFlowTheme.of(context).primary,
                letterSpacing: 0.0,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }
}
