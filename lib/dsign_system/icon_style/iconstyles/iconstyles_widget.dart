import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'iconstyles_model.dart';
export 'iconstyles_model.dart';

class IconstylesWidget extends StatefulWidget {
  const IconstylesWidget({
    super.key,
    this.iconstyles,
    Color? color2,
    Color? color,
  })  : this.color2 = color2 ?? const Color(0xFF245EBD),
        this.color = color ?? const Color(0xFF3675D4);

  final Widget? iconstyles;
  final Color color2;
  final Color color;

  @override
  State<IconstylesWidget> createState() => _IconstylesWidgetState();
}

class _IconstylesWidgetState extends State<IconstylesWidget> {
  late IconstylesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconstylesModel());

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
      width: 32.0,
      height: 32.0,
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
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: widget!.iconstyles!,
      ),
    );
  }
}
