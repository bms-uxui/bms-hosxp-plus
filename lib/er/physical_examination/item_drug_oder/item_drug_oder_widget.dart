import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/er/drugand_service/buttonsheet_frequency/buttonsheet_frequency_widget.dart';
import '/er/drugand_service/buttonsheet_route_medication/buttonsheet_route_medication_widget.dart';
import '/er/drugand_service/buttonsheet_time_coe/buttonsheet_time_coe_widget.dart';
import '/er/drugand_service/buttonsheet_unit/buttonsheet_unit_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_drug_oder_model.dart';
export 'item_drug_oder_model.dart';

class ItemDrugOderWidget extends StatefulWidget {
  const ItemDrugOderWidget({
    super.key,
    this.name,
  });

  final String? name;

  @override
  State<ItemDrugOderWidget> createState() => _ItemDrugOderWidgetState();
}

class _ItemDrugOderWidgetState extends State<ItemDrugOderWidget> {
  late ItemDrugOderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemDrugOderModel());

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
    context.watch<FFAppState>();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (_model.checkboxValue!) {
          safeSetState(() {
            _model.checkboxValue = false;
          });
        } else {
          safeSetState(() {
            _model.checkboxValue = true;
          });
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(valueOrDefault<double>(
            () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }(),
            0.0,
          )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
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
                      unselectedWidgetColor:
                          FlutterFlowTheme.of(context).secondaryText,
                    ),
                    child: Checkbox(
                      value: _model.checkboxValue ??= false,
                      onChanged: (newValue) async {
                        safeSetState(() => _model.checkboxValue = newValue!);
                      },
                      side: (FlutterFlowTheme.of(context).secondaryText != null)
                          ? BorderSide(
                              width: 2,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText!,
                            )
                          : null,
                      activeColor: FlutterFlowTheme.of(context).primary,
                      checkColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                  ),
                  Text(
                    valueOrDefault<String>(
                      widget!.name,
                      'medical name',
                    ),
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: _model.checkboxValue == true
                              ? FlutterFlowTheme.of(context).primaryText
                              : FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 4.0)),
              ),
              if (_model.checkboxValue == true)
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (_model.checkboxValue == true)
                      Stack(
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
                                hintText: 'จำนวน',
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
                                    .secondaryBackground,
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              cursorColor: FlutterFlowTheme.of(context).primary,
                              validator: _model.textControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0,
                                  valueOrDefault<double>(
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 14.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 14.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
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
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0.0,
                                  ),
                                  0.0),
                              child: Text(
                                'เม็ด',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelSmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelSmallIsCustom,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (FFAppState().medecationOrder == 'ยา')
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.mode = 2;
                                  safeSetState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 6.0, 16.0, 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18.0,
                                          height: 18.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: valueOrDefault<Color>(
                                                _model.mode == 2
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                              ),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: valueOrDefault<Color>(
                                                  _model.mode == 2
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Mode 2',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.mode = 3;
                                  safeSetState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 6.0, 16.0, 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18.0,
                                          height: 18.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: valueOrDefault<Color>(
                                                _model.mode == 3
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                              ),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: valueOrDefault<Color>(
                                                  _model.mode == 3
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Mode 3',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                          Builder(
                            builder: (context) {
                              if (_model.mode == 3) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 16.0;
                                            } else {
                                              return 16.0;
                                            }
                                          }(),
                                          0.0,
                                        )),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor5,
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor6
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.info_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 10.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'วิธีใช้',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isDismissible: false,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          ButtonsheetRouteMedicationWidget(),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: wrapWithModel(
                                                model: _model.dropdownModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: DropdownWidget(),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 16.0;
                                            } else {
                                              return 16.0;
                                            }
                                          }(),
                                          0.0,
                                        )),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 2;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 2;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 4;
                                                  } else {
                                                    return 4;
                                                  }
                                                }(),
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 4,
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
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 20.0,
                                                                height: 20.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                    ],
                                                                    stops: [
                                                                      0.0,
                                                                      1.0
                                                                    ],
                                                                    begin:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                    end: AlignmentDirectional(
                                                                        0, 1.0),
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .medication_sharp,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    size: 10.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'Dose',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8.0)),
                                                          ),
                                                          wrapWithModel(
                                                            model: _model
                                                                .countControllerModel,
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            child:
                                                                CountControllerWidget(),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                  () => Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          LinearGradient(
                                                                        colors: [
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor5,
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor10
                                                                        ],
                                                                        stops: [
                                                                          0.0,
                                                                          1.0
                                                                        ],
                                                                        begin: AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                        end: AlignmentDirectional(
                                                                            0,
                                                                            1.0),
                                                                      ),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          FaIcon(
                                                                        FontAwesomeIcons
                                                                            .uniregistry,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        size:
                                                                            8.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'หน่วย',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ],
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              await showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                enableDrag:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        ButtonsheetUnitWidget(),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .dropdownModel2,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  DropdownWidget(),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                  () => Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 20.0,
                                                                height: 20.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: [
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                    ],
                                                                    stops: [
                                                                      0.0,
                                                                      1.0
                                                                    ],
                                                                    begin:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                    end: AlignmentDirectional(
                                                                        0, 1.0),
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .bar_chart_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    size: 10.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'ความถี่',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8.0)),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isDismissible:
                                                                    false,
                                                                useSafeArea:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        ButtonsheetFrequencyWidget(),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .dropdownModel3,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  DropdownWidget(),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                  () => Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          LinearGradient(
                                                                        colors: [
                                                                          FlutterFlowTheme.of(context)
                                                                              .accent2,
                                                                          FlutterFlowTheme.of(context)
                                                                              .accent1
                                                                        ],
                                                                        stops: [
                                                                          0.0,
                                                                          1.0
                                                                        ],
                                                                        begin: AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                        end: AlignmentDirectional(
                                                                            0,
                                                                            1.0),
                                                                      ),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .access_time_filled_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        size:
                                                                            10.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'เวลา',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ],
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isDismissible:
                                                                    false,
                                                                useSafeArea:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        ButtonsheetTimeCoeWidget(),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .dropdownModel4,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  DropdownWidget(),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                ][index]();
                                              },
                                            ),
                                          ].divide(SizedBox(height: 12.0)),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                );
                              } else if (_model.mode == 2) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 16.0;
                                            } else {
                                              return 16.0;
                                            }
                                          }(),
                                          0.0,
                                        )),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor5,
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor6
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.info_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 10.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'วิธีใช้ Mode2',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isDismissible: false,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          ButtonsheetRouteMedicationWidget(),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: wrapWithModel(
                                                model: _model.dropdownModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: DropdownWidget(),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }())),
                                );
                              } else {
                                return Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(),
                                );
                              }
                            },
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                  ].divide(SizedBox(height: 8.0)),
                ),
            ].divide(SizedBox(
                height: valueOrDefault<double>(
              _model.checkboxValue == true ? 8.0 : 0.0,
              0.0,
            ))),
          ),
        ),
      ),
    );
  }
}
