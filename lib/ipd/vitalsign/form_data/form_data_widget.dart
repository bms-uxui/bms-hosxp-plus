import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/buttonsheet_levelof_consciousness/buttonsheet_levelof_consciousness_widget.dart';
import '/ipd/vitalsign/buttonsheet_typeofsymptoms/buttonsheet_typeofsymptoms_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'form_data_model.dart';
export 'form_data_model.dart';

class FormDataWidget extends StatefulWidget {
  const FormDataWidget({super.key});

  @override
  State<FormDataWidget> createState() => _FormDataWidgetState();
}

class _FormDataWidgetState extends State<FormDataWidget> {
  late FormDataModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormDataModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

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
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFB078FF), Color(0xFF9040FF)],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'การประเมิน',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ],
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
                    hintText: 'ข้อความ...',
                    hintStyle: FlutterFlowTheme.of(context)
                        .labelMedium
                        .override(
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
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                  maxLines: null,
                  minLines: 2,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  validator:
                      _model.textController1Validator.asValidator(context),
                ),
              ),
            ].divide(SizedBox(height: 8.0)),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFB078FF), Color(0xFF9040FF)],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.pie_chart_rounded,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 10.0,
                          ),
                        ),
                      ),
                      Text(
                        'Temp Chart Bottom Note',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ],
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
                    hintText: 'ข้อความ...',
                    hintStyle: FlutterFlowTheme.of(context)
                        .labelMedium
                        .override(
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
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
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
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          child: FaIcon(
                            FontAwesomeIcons.capsules,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 8.0,
                          ),
                        ),
                      ),
                      Text(
                        'Medication',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                child: TextFormField(
                  controller: _model.textController3,
                  focusNode: _model.textFieldFocusNode3,
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'ข้อความ...',
                    hintStyle: FlutterFlowTheme.of(context)
                        .labelMedium
                        .override(
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
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                  maxLines: null,
                  minLines: 1,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  validator:
                      _model.textController3Validator.asValidator(context),
                ),
              ),
            ].divide(SizedBox(height: 8.0)),
          ),
          MasonryGridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 1;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 1;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 2;
                } else {
                  return 2;
                }
              }(),
            ),
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            itemCount: 2,
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
                                    FlutterFlowTheme.of(context).info,
                                    Color(0xFF3E83E6)
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
                                  Icons.pin,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 10.0,
                                ),
                              ),
                            ),
                            Text(
                              'ประเภท',
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
                                  child: ButtonsheetTypeofsymptomsWidget(),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          },
                          child: wrapWithModel(
                            model: _model.dropdownModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: DropdownWidget(),
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
                                  Icons.pin,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 10.0,
                                ),
                              ),
                            ),
                            Text(
                              'ระดับความรู้สึกตัว',
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
                                  child:
                                      ButtonsheetLevelofConsciousnessWidget(),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          },
                          child: wrapWithModel(
                            model: _model.dropdownModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: DropdownWidget(),
                          ),
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
              ][index]();
            },
          ),
          MasonryGridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 1;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 1;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 2;
                } else {
                  return 2;
                }
              }(),
            ),
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            itemCount: 2,
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
                                  FontAwesomeIcons.burn,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 10.0,
                                ),
                              ),
                            ),
                            Text(
                              'Urine (ครั้ง)',
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
                        MasonryGridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 1;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 1;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 2;
                              } else {
                                return 2;
                              }
                            }(),
                          ),
                          crossAxisSpacing: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 12.0;
                            } else {
                              return 12.0;
                            }
                          }(),
                          mainAxisSpacing: 8.0,
                          itemCount: 2,
                          padding: EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            0,
                          ),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return [
                              () => wrapWithModel(
                                    model: _model.countControllerModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CountControllerWidget(),
                                  ),
                              () => Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: _model.textController4,
                                      focusNode: _model.textFieldFocusNode4,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'ลักษณะ...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
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
                                      validator: _model.textController4Validator
                                          .asValidator(context),
                                    ),
                                  ),
                            ][index]();
                          },
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
                                  FontAwesomeIcons.poop,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 8.0,
                                ),
                              ),
                            ),
                            Text(
                              'Stool (ครั้ง)',
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
                        MasonryGridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 1;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 1;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 2;
                              } else {
                                return 2;
                              }
                            }(),
                          ),
                          crossAxisSpacing: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 12.0;
                            } else {
                              return 12.0;
                            }
                          }(),
                          mainAxisSpacing: 8.0,
                          itemCount: 2,
                          padding: EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            0,
                          ),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return [
                              () => wrapWithModel(
                                    model: _model.countControllerModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: CountControllerWidget(),
                                  ),
                              () => Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: _model.textController5,
                                      focusNode: _model.textFieldFocusNode5,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'ลักษณะ...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
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
                                      validator: _model.textController5Validator
                                          .asValidator(context),
                                    ),
                                  ),
                            ][index]();
                          },
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
              ][index]();
            },
          ),
        ].divide(SizedBox(height: 12.0)),
      ),
    );
  }
}
