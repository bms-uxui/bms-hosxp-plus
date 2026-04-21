import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'test_model.dart';
export 'test_model.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  late TestModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TestModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFlowRadioButton(
      options: ['Option 1', 'Option 2', 'Option 3'].toList(),
      onChanged: (val) => safeSetState(() {}),
      controller: _model.radioButtonValueController ??=
          FormFieldController<String>(null),
      optionHeight: 32.0,
      textStyle: FlutterFlowTheme.of(context).labelMedium.override(
            fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
            color: FlutterFlowTheme.of(context).secondaryBackground,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w300,
            useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
          ),
      selectedTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
            color: FlutterFlowTheme.of(context).secondaryBackground,
            letterSpacing: 0.0,
            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
          ),
      textPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
      buttonPosition: RadioButtonPosition.left,
      direction: Axis.vertical,
      radioButtonColor: FlutterFlowTheme.of(context).secondaryBackground,
      inactiveRadioButtonColor:
          FlutterFlowTheme.of(context).secondaryBackground,
      toggleable: false,
      horizontalAlignment: WrapAlignment.start,
      verticalAlignment: WrapCrossAlignment.start,
    );
  }
}
