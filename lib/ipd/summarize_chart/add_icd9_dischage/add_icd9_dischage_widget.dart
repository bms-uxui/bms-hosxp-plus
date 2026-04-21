import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_icd9_dischage_model.dart';
export 'add_icd9_dischage_model.dart';

class AddIcd9DischageWidget extends StatefulWidget {
  const AddIcd9DischageWidget({
    super.key,
    required this.navigatback,
    required this.saveaction,
  });

  final Future Function()? navigatback;
  final Future Function()? saveaction;

  @override
  State<AddIcd9DischageWidget> createState() => _AddIcd9DischageWidgetState();
}

class _AddIcd9DischageWidgetState extends State<AddIcd9DischageWidget> {
  late AddIcd9DischageModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddIcd9DischageModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await widget.navigatback?.call();
              },
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            Text(
              'บันทึกผลการวินิจฉัยผู้ป่วยใน (ICD9CM)',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                  ),
            ),
          ].divide(SizedBox(width: 12.0)),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 16.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }()),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).customColor5,
                              FlutterFlowTheme.of(context).customColor6
                            ],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: FaIcon(
                            FontAwesomeIcons.userMd,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'แพทย์ผู้วินิจฉัย',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  wrapWithModel(
                    model: _model.dropdownModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: DropdownWidget(),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).customColor7,
                              FlutterFlowTheme.of(context).customColor8
                            ],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            '9',
                            style: GoogleFonts.roboto(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontSize: 8.0,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'ICD9',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  wrapWithModel(
                    model: _model.dropdownModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: DropdownWidget(),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              MasonryGridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                itemCount: 6,
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  0,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return [
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
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
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 10.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'วันที่เริ่ม',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.datePickerModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: DatePickerWidget(
                                textlabel: '',
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
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
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 10.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'เวลาเริ่ม',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.timePickerModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: TimePickerWidget(
                                textlabel: '',
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
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
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 10.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'วันที่สิ้นสุด',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.datePickerModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: DatePickerWidget(
                                textlabel: '',
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
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
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 10.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'เวลาสิ้นสุด',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.timePickerModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: TimePickerWidget(
                                textlabel: '',
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .customColor5,
                                        FlutterFlowTheme.of(context)
                                            .customColor6
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.style_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 10.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Ext type',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.dropdownModel3,
                              updateCallback: () => safeSetState(() {}),
                              child: DropdownWidget(),
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),
                    () => Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context)
                                            .customColor9,
                                        FlutterFlowTheme.of(context)
                                            .customColor10
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'E',
                                      style: GoogleFonts.roboto(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 8.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Extension Code',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode1,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelMediumFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w200,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelMediumIsCustom,
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
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                                maxLines: null,
                                minLines: 1,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                validator: _model.textController1Validator
                                    .asValidator(context),
                              ),
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),
                  ][index]();
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).customColor5,
                              FlutterFlowTheme.of(context).customColor6
                            ],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.star_rounded,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'ลำดับความสำคัญ',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  wrapWithModel(
                    model: _model.countControllerModel,
                    updateCallback: () => safeSetState(() {}),
                    child: CountControllerWidget(
                      textlabel: '1',
                    ),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
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
                          child: FaIcon(
                            FontAwesomeIcons.syringe,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'ชนิดหัตถการ',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  wrapWithModel(
                    model: _model.dropdownModel4,
                    updateCallback: () => safeSetState(() {}),
                    child: DropdownWidget(),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
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
                          child: FaIcon(
                            FontAwesomeIcons.syringe,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'ประเภทหัตถการ',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  wrapWithModel(
                    model: _model.dropdownModel5,
                    updateCallback: () => safeSetState(() {}),
                    child: DropdownWidget(),
                  ),
                ].divide(SizedBox(height: 12.0)),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).customColor17,
                              FlutterFlowTheme.of(context).customColor18
                            ],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.info_rounded,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 12.0,
                          ),
                        ),
                      ),
                      Text(
                        'หมายเหตุ',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).labelSmallFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _model.textController2,
                      focusNode: _model.textFieldFocusNode2,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w200,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelMediumIsCustom,
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
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                      maxLines: null,
                      minLines: 2,
                      cursorColor: FlutterFlowTheme.of(context).primary,
                      validator:
                          _model.textController2Validator.asValidator(context),
                    ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 16.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }())),
          ),
        ),
        if (!valueOrDefault<bool>(
          isWeb
              ? MediaQuery.viewInsetsOf(context).bottom > 0
              : _isKeyboardVisible,
          false,
        ))
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              unawaited(
                () async {
                  await widget.saveaction?.call();
                }(),
              );
            },
            child: wrapWithModel(
              model: _model.bottonPrimaryModel,
              updateCallback: () => safeSetState(() {}),
              child: BottonPrimaryWidget(
                buttonprimary: 'บันทึก',
              ),
            ),
          ),
      ],
    );
  }
}
