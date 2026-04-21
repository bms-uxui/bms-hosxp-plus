import '/dsign_system/alertdialog/alert_dialog_delete/alert_dialog_delete_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_error/alert_dialog_error_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_generate/alert_dialog_generate_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_information/alert_dialog_information_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_loading/alert_dialog_loading_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_success/alert_dialog_success_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_warning/alert_dialog_warning_widget.dart';
import '/dsign_system/alertdialog/loading/loading_widget.dart';
import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/botton_provider_i_d/botton_provider_i_d_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/check_box_style/check_box/check_box_widget.dart';
import '/dsign_system/from_field/button_sheet_datepicker/button_sheet_datepicker_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'preview_widget_model.dart';
export 'preview_widget_model.dart';

class PreviewWidgetWidget extends StatefulWidget {
  const PreviewWidgetWidget({super.key});

  static String routeName = 'PreviewWidget';
  static String routePath = 'previewWidget';

  @override
  State<PreviewWidgetWidget> createState() => _PreviewWidgetWidgetState();
}

class _PreviewWidgetWidgetState extends State<PreviewWidgetWidget> {
  late PreviewWidgetModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PreviewWidgetModel());

    _model.switchValue1 = false;
    _model.switchValue2 = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 50.0,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Page Title',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).titleMediumIsCustom,
              ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
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
              child: MasonryGridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 1;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 2;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 2;
                    } else {
                      return 2;
                    }
                  }(),
                ),
                crossAxisSpacing: () {
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
                mainAxisSpacing: () {
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
                itemCount: 9,
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  0,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return [
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Button',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 4,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Report',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.bottonPrimaryModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: BottonPrimaryWidget(
                                                  buttonprimary: 'Text',
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'View detail',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.bottonPrimaryModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: BottonPrimaryWidget(
                                                  buttonprimary: 'ดูรายละเอียด',
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Save',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.bottonPrimaryModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: BottonPrimaryWidget(
                                                  buttonprimary: 'บันทึก',
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Add',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.bottonPrimaryModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: BottonPrimaryWidget(
                                                  buttonprimary: 'เพิ่ม',
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                wrapWithModel(
                                  model: _model.bottonProviderIDModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: BottonProviderIDWidget(),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 2,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Button Properties',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model:
                                                    _model.bottonSecondaryModel,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: BottonSecondaryWidget(
                                                  buttonsecondary:
                                                      'button secondary',
                                                  icon: Icon(
                                                    Icons.arrow_back,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'AI',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .buttonAIgenerateModel,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ButtonAIgenerateWidget(
                                                  aiGenerate: 'ai',
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 1,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              height: () {
                                                if (MediaQuery.sizeOf(context)
                                                        .width <
                                                    kBreakpointSmall) {
                                                  return 40.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointMedium) {
                                                  return 40.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointLarge) {
                                                  return 48.0;
                                                } else {
                                                  return 48.0;
                                                }
                                              }(),
                                              constraints: BoxConstraints(
                                                minWidth: 120.0,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'ยกเลิก',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Icon Button',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 3,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Report',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonPrimaryModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonPrimaryWidget(
                                                  iconbuttonprimary: Icon(
                                                    Icons.arrow_back,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'add',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonPrimaryModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonPrimaryWidget(
                                                  iconbuttonprimary: Icon(
                                                    Icons.add_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Save',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonPrimaryModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonPrimaryWidget(
                                                  iconbuttonprimary: Icon(
                                                    Icons.save_alt_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Edit',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonSecondaryModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child:
                                                    IconButtonSecondaryWidget(
                                                  iconbuttonsecondary: Icon(
                                                    Icons.mode_edit,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Delete',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonSecondaryModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child:
                                                    IconButtonSecondaryWidget(
                                                  iconbuttonsecondary: Icon(
                                                    Icons.delete_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'View detail',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonSecondaryModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child:
                                                    IconButtonSecondaryWidget(
                                                  iconbuttonsecondary: Icon(
                                                    Icons
                                                        .keyboard_arrow_right_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'View detail',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonSecondaryModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child:
                                                    IconButtonSecondaryWidget(
                                                  iconbuttonsecondary: Icon(
                                                    Icons
                                                        .keyboard_arrow_right_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'date picker',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
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
                                                            ButtonSheetDatepickerWidget(),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: wrapWithModel(
                                                  model: _model
                                                      .iconButtonSecondaryModel5,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child:
                                                      IconButtonSecondaryWidget(
                                                    iconbuttonsecondary: Icon(
                                                      Icons.calendar_month,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      size: 18.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 6,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Photo',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: Icon(
                                                    Icons.image,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 12.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Camera',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: Icon(
                                                    Icons.camera_alt,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 12.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Nexpage',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: Icon(
                                                    Icons
                                                        .keyboard_arrow_right_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 14.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'minus sign',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: FaIcon(
                                                    FontAwesomeIcons.minus,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 12.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'plus sign',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: FaIcon(
                                                    FontAwesomeIcons.plus,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 12.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Mic',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              wrapWithModel(
                                                model: _model
                                                    .iconButtonTertiaryModel6,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonTertiaryWidget(
                                                  iconbuttontertiary: FaIcon(
                                                    FontAwesomeIcons.microphone,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 12.0,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'alert',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 8,
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
                                            children: [
                                              Text(
                                                'warring',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogWarningWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .warning,
                                                          Color(0xFFC57108)
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
                                                        Icons.warning_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Error',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogErrorWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFF5968),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error
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
                                                        Icons.error_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Success',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogSuccessWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF74ED9C),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .success
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
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Information',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogInformationWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF7DADF8),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
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
                                                        Icons.info,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Loading',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              LoadingWidget(),
                                                        );
                                                      },
                                                    );

                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 3000,
                                                      ),
                                                    );
                                                    unawaited(
                                                      () async {
                                                        Navigator.pop(context);
                                                      }(),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF7DADF8),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
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
                                                        Icons
                                                            .downloading_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Loading2',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogLoadingWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF7DADF8),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
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
                                                        Icons
                                                            .downloading_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Loading AI',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogGenerateWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFFA466),
                                                          Color(0xFF9E53FF)
                                                        ],
                                                        stops: [0.0, 1.0],
                                                        begin:
                                                            AlignmentDirectional(
                                                                0.56, -1.0),
                                                        end:
                                                            AlignmentDirectional(
                                                                -0.56, 1.0),
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: Icon(
                                                        Icons.auto_awesome,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Delete',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Builder(
                                                builder: (context) => InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              AlertDialogDeleteWidget(),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFF5968),
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error
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
                                                        Icons.delete_rounded,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.search_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 14.0,
                                        ),
                                        Text(
                                          'Search Primary',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    wrapWithModel(
                                      model: _model.searchBarPrimaryModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: SearchBarPrimaryWidget(),
                                    ),
                                  ].divide(SizedBox(height: 4.0)),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Check Box',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 1;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 1;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 2;
                                      } else {
                                        return 2;
                                      }
                                    }(),
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 4,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => wrapWithModel(
                                            model: _model.checkBoxModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: CheckBoxWidget(
                                              titlecheckbox: '1',
                                            ),
                                          ),
                                      () => wrapWithModel(
                                            model: _model.checkBoxModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: CheckBoxWidget(
                                              titlecheckbox: '2',
                                            ),
                                          ),
                                      () => wrapWithModel(
                                            model: _model.checkBoxModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: CheckBoxWidget(
                                              titlecheckbox: '3',
                                            ),
                                          ),
                                      () => wrapWithModel(
                                            model: _model.checkBoxModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: CheckBoxWidget(
                                              titlecheckbox: '4',
                                            ),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Switch',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 1;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 1;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 2;
                                      } else {
                                        return 2;
                                      }
                                    }(),
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 2,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'non active',
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
                                              Switch.adaptive(
                                                value: _model.switchValue1!,
                                                onChanged: (newValue) async {
                                                  safeSetState(() =>
                                                      _model.switchValue1 =
                                                          newValue!);
                                                },
                                                activeColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                activeTrackColor:
                                                    FlutterFlowTheme.of(context)
                                                        .success,
                                                inactiveTrackColor:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                inactiveThumbColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'active',
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
                                              Switch.adaptive(
                                                value: _model.switchValue2!,
                                                onChanged: (newValue) async {
                                                  safeSetState(() =>
                                                      _model.switchValue2 =
                                                          newValue!);
                                                },
                                                activeColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                activeTrackColor:
                                                    FlutterFlowTheme.of(context)
                                                        .success,
                                                inactiveTrackColor:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                inactiveThumbColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'User Profile',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 4,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Doctor M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: Image.asset(
                                                    'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Doctor W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: Image.asset(
                                                    'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Nurse M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: Image.asset(
                                                    'assets/images/ChatGPT_Image_19_.._2568_09_12_05.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Nurse W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: Image.asset(
                                                    'assets/images/ChatGPT_Image_19_.._2568_09_14_08.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 10,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Infant M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_19_.._2568_10_01_14.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF62B3FF),
                                                              Color(0xFF2397FF)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .mars,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Infant W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_19_.._2568_10_03_09.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF8AE1),
                                                              Color(0xFFEE4FC5)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .venus,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Child M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_19_.._2568_10_10_57.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF62B3FF),
                                                              Color(0xFF2397FF)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .mars,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Child W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_19_.._2568_10_16_09.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF8AE1),
                                                              Color(0xFFEE4FC5)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .venus,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Adolescence M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF62B3FF),
                                                              Color(0xFF2397FF)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .mars,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Adolescence W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_20_.._2568_15_52_58.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF8AE1),
                                                              Color(0xFFEE4FC5)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .venus,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Adulthood M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_20_.._2568_16_00_35.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF62B3FF),
                                                              Color(0xFF2397FF)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .mars,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Adulthood W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_20_.._2568_16_05_37.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF8AE1),
                                                              Color(0xFFEE4FC5)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .venus,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Older Adults M',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_20_.._2568_16_06_55.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF62B3FF),
                                                              Color(0xFF2397FF)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .mars,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Older Adults W',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              Container(
                                                width: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                height: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 48.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 56.0;
                                                  } else {
                                                    return 56.0;
                                                  }
                                                }(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      child: Image.asset(
                                                        'assets/images/ChatGPT_Image_20_.._2568_16_08_16.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Container(
                                                        width: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        height: () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 20.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 24.0;
                                                          } else {
                                                            return 24.0;
                                                          }
                                                        }(),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4.0,
                                                              color: Color(
                                                                  0x1A000000),
                                                              offset: Offset(
                                                                0.0,
                                                                2.0,
                                                              ),
                                                            )
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF8AE1),
                                                              Color(0xFFEE4FC5)
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .venus,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 12.0;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 14.0;
                                                              } else {
                                                                return 14.0;
                                                              }
                                                            }(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Radio Button',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: FlutterFlowRadioButton(
                                    options: [
                                      'Option 1',
                                      'Option 2',
                                      'Option 3'
                                    ].toList(),
                                    onChanged: (val) => safeSetState(() {}),
                                    controller:
                                        _model.radioButtonValueController ??=
                                            FormFieldController<String>(null),
                                    optionHeight: 32.0,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .labelMediumFamily,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .labelMediumIsCustom,
                                        ),
                                    selectedTextStyle:
                                        FlutterFlowTheme.of(context)
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
                                    textPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 16.0, 0.0),
                                    buttonPosition: RadioButtonPosition.left,
                                    direction: Axis.horizontal,
                                    radioButtonColor:
                                        FlutterFlowTheme.of(context).success,
                                    inactiveRadioButtonColor:
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    toggleable: false,
                                    horizontalAlignment: WrapAlignment.start,
                                    verticalAlignment: WrapCrossAlignment.start,
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                    () => Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Icon style',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'icon background color',
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
                                  ),
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 5;
                                      } else {
                                        return 5;
                                      }
                                    }(),
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 8,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF5FDD89),
                                                    FlutterFlowTheme.of(context)
                                                        .success
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFC776F2),
                                                    Color(0xFFB139F0)
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFEC6370),
                                                    FlutterFlowTheme.of(context)
                                                        .error
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFE5976E),
                                                    Color(0xFFE0570F)
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF62B3FF),
                                                    Color(0xFF2397FF)
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF8AE1),
                                                    Color(0xFFEE4FC5)
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      () => Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFEC6370),
                                                    FlutterFlowTheme.of(context)
                                                        .error
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
                                                  Icons.arrow_back,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Medical',
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
                                  ),
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 5;
                                      } else {
                                        return 5;
                                      }
                                    }(),
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 27,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'medical',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .briefcaseMedical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Lab',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.vial,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Drug',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.capsules,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.userInjured,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Doctor',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.userMd,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Nurse',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.userNurse,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Emergency',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.ambulance,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Docmedical',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.fileMedical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.bandAid,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Home Care',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .clinicMedical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .handHoldingMedical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .handHoldingHeart,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .handHoldingWater,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.syringe,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.brain,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.stethoscope,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'bandaid',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .prescriptionBottleAlt,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'CC',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.heartBroken,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'CC',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.crutch,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'CC',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.virus,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.carCrash,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.shieldAlt,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.skull,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.toilet,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'IPD',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.procedures,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'OPD',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.hospitalUser,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.skull,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Vital Sign',
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
                                  ),
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 3;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 5;
                                      } else {
                                        return 5;
                                      }
                                    }(),
                                  ),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  itemCount: 14,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'medical',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .thermometerFull,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Service',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.weight,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Lab',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.heartbeat,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Drug',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.lungs,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .rulerVertical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.solidEye,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.tape,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.solidTired,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.tint,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.venus,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.mars,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.procedures,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .rulerVertical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                      () => Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'Patient',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 10.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .rulerVertical,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                  ][index]();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
