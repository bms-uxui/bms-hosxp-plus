import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttonsheet_address_model.dart';
export 'buttonsheet_address_model.dart';

class ButtonsheetAddressWidget extends StatefulWidget {
  const ButtonsheetAddressWidget({super.key});

  @override
  State<ButtonsheetAddressWidget> createState() =>
      _ButtonsheetAddressWidgetState();
}

class _ButtonsheetAddressWidgetState extends State<ButtonsheetAddressWidget> {
  late ButtonsheetAddressModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonsheetAddressModel());

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
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.all(valueOrDefault<double>(
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
            )),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'เพิ่มที่อยู่',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                    _model.address = 1;
                    _model.province = null;
                    _model.district = null;
                    _model.subdistrict = null;
                    _model.postalCode = null;
                    safeSetState(() {});
                  },
                  child: wrapWithModel(
                    model: _model.iconButtonTertiaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: IconButtonTertiaryWidget(
                      iconbuttontertiary: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 16.0,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
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
                  0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 12.0, 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/53accc2b-5818-4fec-9e9a-25a313da95a5.png',
                                  width: 70.0,
                                  height: 70.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(valueOrDefault<double>(
                            () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
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
                          )),
                          child: Builder(
                            builder: (context) {
                              if (_model.address == 1) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'จังหวัด',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 1;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.province,
                                                  '12',
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                );
                              } else if (_model.address == 2) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'จังหวัด',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 1;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.province,
                                                  ' 12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'อำเภอ/เขต',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 2;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.district,
                                                  ' 12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                );
                              } else if (_model.address == 3) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'จังหวัด',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 1;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.province,
                                                  ' 12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'อำเภอ/เขต',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 2;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.district,
                                                  '12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'ตำบล/แขวง',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 3;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.subdistrict,
                                                  ' 12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                );
                              } else if (_model.address == 4) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'จังหวัด',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 1;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.province,
                                                  '12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'อำเภอ/เขต',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 2;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.district,
                                                  '12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'ตำบล/แขวง',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 3;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.subdistrict,
                                                  '12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.map_sharp,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'รหัสไปรษณีย์',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
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
                                            _model.address = 4;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.postalCode,
                                                  '12',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                );
                              } else {
                                return Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(valueOrDefault<double>(
                          () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
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
                        )),
                        child: Builder(
                          builder: (context) {
                            if (_model.address == 1) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'จังหวัด',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  wrapWithModel(
                                    model: _model.searchBarSecondaryModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SearchBarSecondaryWidget(
                                      cocor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                  ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.province =
                                              'จังหวัดกรุงเทพมหานคร';
                                          _model.address = 2;
                                          safeSetState(() {});
                                        },
                                        child: wrapWithModel(
                                          model: _model.itemListPrimaryModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'กรุงเทพมหานคร',
                                            titlecolor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            showline: true,
                                          ),
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'กาญจนบุรี',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'กาฬสินธุ์',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel4,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'กำแพงเพชร',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel5,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'ขอนแก่น',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'จันทบุรี',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel7,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'ฉะเชิงเทรา',
                                          showline: true,
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.itemListPrimaryModel8,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ItemListPrimaryWidget(
                                          title: 'ชลบุรี',
                                          showline: false,
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              );
                            } else if (_model.address == 2) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'อำเภอ/เขต',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  wrapWithModel(
                                    model: _model.searchBarSecondaryModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SearchBarSecondaryWidget(
                                      cocor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.district = 'คลองสาน';
                                            _model.address = 3;
                                            safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.itemListPrimaryModel9,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListPrimaryWidget(
                                              title: 'คลองสาน',
                                              showline: true,
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel10,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'คลองสามวา',
                                            showline: true,
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel11,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'คันนายาว',
                                            showline: true,
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel12,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'จตุจักร',
                                            showline: true,
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel13,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'จอมทอง',
                                            showline: true,
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              );
                            } else if (_model.address == 3) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ตำบล/แขวง',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  wrapWithModel(
                                    model: _model.searchBarSecondaryModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SearchBarSecondaryWidget(
                                      cocor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.subdistrict = 'แขวงคลองสาน';
                                            _model.address = 4;
                                            safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model:
                                                _model.itemListPrimaryModel14,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListPrimaryWidget(
                                              title: 'แขวงคลองสาน',
                                              showline: true,
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel15,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'แขวงคลองต้นไทร',
                                            showline: true,
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel16,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'แขวงบางลำภูล่าง',
                                            showline: true,
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemListPrimaryModel17,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemListPrimaryWidget(
                                            title: 'แขวงสมเด็จเจ้าพระยา',
                                            showline: false,
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              );
                            } else if (_model.address == 4) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'รหัสไปรษณีย์',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  wrapWithModel(
                                    model: _model.searchBarSecondaryModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SearchBarSecondaryWidget(
                                      cocor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.postalCode = '10600';
                                            safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model:
                                                _model.itemListPrimaryModel18,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListPrimaryWidget(
                                              title: '10600',
                                              showline: true,
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              );
                            } else {
                              return Align(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: () {
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
                }())),
              ),
            ),
          ),
          if (_model.postalCode == _model.postalCode)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  FFAppState().address = true;
                  safeSetState(() {});
                  Navigator.pop(context);
                },
                child: wrapWithModel(
                  model: _model.bottonPrimaryModel,
                  updateCallback: () => safeSetState(() {}),
                  child: BottonPrimaryWidget(
                    buttonprimary: 'ยืนยัน',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
