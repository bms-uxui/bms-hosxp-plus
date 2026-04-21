import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_fillter_model.dart';
export 'button_fillter_model.dart';

class ButtonFillterWidget extends StatefulWidget {
  const ButtonFillterWidget({
    super.key,
    Color? colorbg,
    Color? coloricon,
  })  : this.colorbg = colorbg ?? const Color(0x27FFFFFF),
        this.coloricon = coloricon ?? Colors.white;

  final Color colorbg;
  final Color coloricon;

  @override
  State<ButtonFillterWidget> createState() => _ButtonFillterWidgetState();
}

class _ButtonFillterWidgetState extends State<ButtonFillterWidget> {
  late ButtonFillterModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonFillterModel());

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
          return 24.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 24.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 32.0;
        } else {
          return 32.0;
        }
      }(),
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 24.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 24.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 32.0;
        } else {
          return 32.0;
        }
      }(),
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.colorbg,
          Color(0x27FFFFFF),
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0x06FFFFFF),
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: FaIcon(
              FontAwesomeIcons.slidersH,
              color: valueOrDefault<Color>(
                widget!.coloricon,
                FlutterFlowTheme.of(context).secondaryBackground,
              ),
              size: 10.0,
            ),
          ),
        ),
      ),
    );
  }
}
