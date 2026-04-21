import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dropdown_model.dart';
export 'dropdown_model.dart';

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({
    super.key,
    this.textlabel,
    this.icon,
    this.text,
    this.update,
    this.width,
  });

  final String? textlabel;
  final Widget? icon;
  final String? text;
  final String? update;
  final double? width;

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  late DropdownModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DropdownModel());

    _model.textController ??= TextEditingController(text: widget!.text);
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: widget!.width,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            child: TextFormField(
              controller: _model.textController,
              focusNode: _model.textFieldFocusNode,
              autofocus: false,
              readOnly: true,
              obscureText: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: valueOrDefault<String>(
                  widget!.textlabel,
                  'กรุณาเลือก',
                ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).labelMediumFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w200,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelMediumIsCustom,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0x00000000),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0x00000000),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).primaryBackground,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 20.0,
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
              maxLines: null,
              minLines: 1,
              cursorColor: FlutterFlowTheme.of(context).primary,
              validator: _model.textControllerValidator.asValidator(context),
            ),
          ),
          Container(
            width: double.infinity,
            height: 48.0,
            decoration: BoxDecoration(),
          ),
        ],
      ),
    );
  }
}
