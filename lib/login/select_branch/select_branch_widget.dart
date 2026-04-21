import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/login/item_branch/item_branch_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'select_branch_model.dart';
export 'select_branch_model.dart';

class SelectBranchWidget extends StatefulWidget {
  const SelectBranchWidget({super.key});

  static String routeName = 'Select_Branch';
  static String routePath = 'selectBranch';

  @override
  State<SelectBranchWidget> createState() => _SelectBranchWidgetState();
}

class _SelectBranchWidgetState extends State<SelectBranchWidget> {
  late SelectBranchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectBranchModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).accent2,
              automaticallyImplyLeading: false,
              title: Text(
                'เลือกสาขา',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ),
              actions: [],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.1,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_4_.._2568_08_58_08.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                        alignment: Alignment(0.0, -1.0),
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: false,
              toolbarHeight: 64.0,
              elevation: 0.0,
            )
          ],
          body: Builder(
            builder: (context) {
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
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: () {
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
                          }()),
                          scrollDirection: Axis.vertical,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  valueOrDefault<double>(
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
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
                                  0.0,
                                  valueOrDefault<double>(
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
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
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'กรุณาเลือกสาขา',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLargeFamily,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyLargeIsCustom,
                                        ),
                                  ),
                                  MasonryGridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                    crossAxisSpacing: () {
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
                                    mainAxisSpacing: () {
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
                                    itemCount: 3,
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      0,
                                    ),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return [
                                        () => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                FFAppState().selectbranch = 1;
                                                safeSetState(() {});

                                                context.pushNamed(
                                                    MainPageWidget.routeName);
                                              },
                                              child: wrapWithModel(
                                                model: _model.itemBranchModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ItemBranchWidget(
                                                  namebranch:
                                                      'โรงพยาพาลบีเอ็มเอส ฮอตเอ็กพาส 1',
                                                  selectbranch: 1,
                                                ),
                                              ),
                                            ),
                                        () => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                FFAppState().selectbranch = 2;
                                                safeSetState(() {});

                                                context.pushNamed(
                                                    MainPageWidget.routeName);
                                              },
                                              child: wrapWithModel(
                                                model: _model.itemBranchModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ItemBranchWidget(
                                                  namebranch:
                                                      'โรงพยาพาลบีเอ็มเอส ฮอตเอ็กพาส 2',
                                                  selectbranch: 2,
                                                ),
                                              ),
                                            ),
                                        () => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                FFAppState().selectbranch = 3;
                                                safeSetState(() {});

                                                context.pushNamed(
                                                    MainPageWidget.routeName);
                                              },
                                              child: wrapWithModel(
                                                model: _model.itemBranchModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ItemBranchWidget(
                                                  namebranch:
                                                      'โรงพยาพาลบีเอ็มเอส ฮอตเอ็กพาส 3',
                                                  selectbranch: 3,
                                                ),
                                              ),
                                            ),
                                      ][index]();
                                    },
                                  ),
                                ].divide(SizedBox(height: () {
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
                                }())),
                              ),
                            ),
                          ].divide(SizedBox(height: () {
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
                          }())),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
