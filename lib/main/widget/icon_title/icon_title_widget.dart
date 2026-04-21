import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_title_model.dart';
export 'icon_title_model.dart';

class IconTitleWidget extends StatefulWidget {
  const IconTitleWidget({
    super.key,
    this.titletext,
    this.icon,
    this.color1,
    this.color2,
  });

  final String? titletext;
  final Widget? icon;
  final Color? color1;
  final Color? color2;

  @override
  State<IconTitleWidget> createState() => _IconTitleWidgetState();
}

class _IconTitleWidgetState extends State<IconTitleWidget> {
  late IconTitleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconTitleModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                valueOrDefault<Color>(
                  widget!.color1,
                  Color(0xFFA0A0A0),
                ),
                valueOrDefault<Color>(
                  widget!.color2,
                  FlutterFlowTheme.of(context).secondaryText,
                )
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: widget!.icon!,
          ),
        ),
        AnimatedDefaultTextStyle(
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodyLargeIsCustom,
              ),
          duration: Duration(milliseconds: 600),
          curve: Curves.easeIn,
          child: Text(
            valueOrDefault<String>(
              widget!.titletext,
              'Title Text',
            ),
          ),
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }
}
