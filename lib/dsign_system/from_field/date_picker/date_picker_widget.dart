import '/dsign_system/from_field/button_sheet_datepicker/button_sheet_datepicker_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'date_picker_model.dart';
export 'date_picker_model.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({
    super.key,
    this.textlabel,
  });

  final String? textlabel;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DatePickerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DatePickerModel());

    _model.textController ??= TextEditingController(
        text: dateTimeFormat("d MMM y", getCurrentTimestamp));
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
            readOnly: true,
            obscureText: false,
            decoration: InputDecoration(
              isDense: true,
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
                Icons.calendar_month,
                color: FlutterFlowTheme.of(context).alternate,
                size: 16.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
            cursorColor: FlutterFlowTheme.of(context).primary,
            validator: _model.textControllerValidator.asValidator(context),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              isDismissible: false,
              useSafeArea: true,
              context: context,
              builder: (context) {
                return Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: ButtonSheetDatepickerWidget(),
                );
              },
            ).then((value) => safeSetState(() {}));
          },
          child: Container(
            width: double.infinity,
            height: 48.0,
            decoration: BoxDecoration(),
          ),
        ),
      ],
    );
  }
}
