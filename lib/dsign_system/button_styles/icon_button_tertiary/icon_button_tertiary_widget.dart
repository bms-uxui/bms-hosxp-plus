import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_button_tertiary_model.dart';
export 'icon_button_tertiary_model.dart';

class IconButtonTertiaryWidget extends StatefulWidget {
  const IconButtonTertiaryWidget({
    super.key,
    this.iconbuttontertiary,
    this.color,
  });

  final Widget? iconbuttontertiary;
  final Color? color;

  @override
  State<IconButtonTertiaryWidget> createState() =>
      _IconButtonTertiaryWidgetState();
}

class _IconButtonTertiaryWidgetState extends State<IconButtonTertiaryWidget> {
  late IconButtonTertiaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconButtonTertiaryModel());

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
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.color,
          FlutterFlowTheme.of(context).primaryBackground,
        ),
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: widget!.iconbuttontertiary!,
      ),
    );
  }
}
