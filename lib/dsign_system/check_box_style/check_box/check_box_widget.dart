import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'check_box_model.dart';
export 'check_box_model.dart';

class CheckBoxWidget extends StatefulWidget {
  const CheckBoxWidget({
    super.key,
    this.titlecheckbox,
    this.check,
  });

  final String? titlecheckbox;
  final bool? check;

  @override
  State<CheckBoxWidget> createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  late CheckBoxModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CheckBoxModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        safeSetState(() {
          _model.checkboxValue = true;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              unselectedWidgetColor: FlutterFlowTheme.of(context).secondaryText,
            ),
            child: Checkbox(
              value: _model.checkboxValue ??= widget!.check!,
              onChanged: (newValue) async {
                safeSetState(() => _model.checkboxValue = newValue!);
              },
              side: (FlutterFlowTheme.of(context).secondaryText != null)
                  ? BorderSide(
                      width: 2,
                      color: FlutterFlowTheme.of(context).secondaryText!,
                    )
                  : null,
              activeColor: FlutterFlowTheme.of(context).primary,
              checkColor: FlutterFlowTheme.of(context).secondaryBackground,
            ),
          ),
          Text(
            valueOrDefault<String>(
              widget!.titlecheckbox,
              'Title CheckBox',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: valueOrDefault<Color>(
                    _model.checkboxValue == true
                        ? FlutterFlowTheme.of(context).primaryText
                        : FlutterFlowTheme.of(context).secondaryText,
                    FlutterFlowTheme.of(context).secondaryText,
                  ),
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ].divide(SizedBox(width: 8.0)),
      ),
    );
  }
}
