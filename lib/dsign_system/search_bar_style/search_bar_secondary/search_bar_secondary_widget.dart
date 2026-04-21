import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_bar_secondary_model.dart';
export 'search_bar_secondary_model.dart';

class SearchBarSecondaryWidget extends StatefulWidget {
  const SearchBarSecondaryWidget({
    super.key,
    Color? cocor,
  }) : this.cocor = cocor ?? Colors.white;

  final Color cocor;

  @override
  State<SearchBarSecondaryWidget> createState() =>
      _SearchBarSecondaryWidgetState();
}

class _SearchBarSecondaryWidgetState extends State<SearchBarSecondaryWidget> {
  late SearchBarSecondaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchBarSecondaryModel());

    _model.textController ??= TextEditingController();
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
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 40.0,
      ),
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.cocor,
          FlutterFlowTheme.of(context).secondaryBackground,
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 3.0, 5.0, 3.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.search_rounded,
              size: 16.0,
            ),
            Expanded(
              child: Container(
                width: 200.0,
                child: TextFormField(
                  controller: _model.textController,
                  focusNode: _model.textFieldFocusNode,
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'ค้นหา',
                    hintStyle: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelLargeFamily,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w200,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelLargeIsCustom,
                        ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                      ),
                  cursorColor: FlutterFlowTheme.of(context).primaryText,
                  validator:
                      _model.textControllerValidator.asValidator(context),
                ),
              ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
