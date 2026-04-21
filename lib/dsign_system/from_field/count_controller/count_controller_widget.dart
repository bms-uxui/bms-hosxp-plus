import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'count_controller_model.dart';
export 'count_controller_model.dart';

class CountControllerWidget extends StatefulWidget {
  const CountControllerWidget({
    super.key,
    this.icon,
    this.textlabel,
  });

  final Widget? icon;
  final String? textlabel;

  @override
  State<CountControllerWidget> createState() => _CountControllerWidgetState();
}

class _CountControllerWidgetState extends State<CountControllerWidget> {
  late CountControllerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CountControllerModel());

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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: TextFormField(
            controller: _model.textController,
            focusNode: _model.textFieldFocusNode,
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
              isDense: true,
              hintText: valueOrDefault<String>(
                widget!.textlabel,
                'Ex.0',
              ),
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: FlutterFlowTheme.of(context).primary,
            validator: _model.textControllerValidator.asValidator(context),
          ),
        ),
        Align(
          alignment: AlignmentDirectional(1.0, -1.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                0.0,
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 16.0;
                    } else {
                      return 16.0;
                    }
                  }(),
                  0.0,
                ),
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 12.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 16.0;
                    } else {
                      return 16.0;
                    }
                  }(),
                  0.0,
                ),
                0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                wrapWithModel(
                  model: _model.iconButtonTertiaryModel1,
                  updateCallback: () => safeSetState(() {}),
                  child: IconButtonTertiaryWidget(
                    iconbuttontertiary: FaIcon(
                      FontAwesomeIcons.minus,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 14.0,
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.iconButtonTertiaryModel2,
                  updateCallback: () => safeSetState(() {}),
                  child: IconButtonTertiaryWidget(
                    iconbuttontertiary: FaIcon(
                      FontAwesomeIcons.plus,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 14.0,
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ),
        ),
      ],
    );
  }
}
