import '/dsign_system/button_styles/botton_primary1/botton_primary1_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/item_drug/item_drug_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drunglist_view_model.dart';
export 'drunglist_view_model.dart';

class DrunglistViewWidget extends StatefulWidget {
  const DrunglistViewWidget({
    super.key,
    bool? buttonMedOder,
  }) : this.buttonMedOder = buttonMedOder ?? false;

  final bool buttonMedOder;

  @override
  State<DrunglistViewWidget> createState() => _DrunglistViewWidgetState();
}

class _DrunglistViewWidgetState extends State<DrunglistViewWidget> {
  late DrunglistViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrunglistViewModel());

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: true)
          ..addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
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
        0,
        24.0,
      ),
      scrollDirection: Axis.vertical,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              valueOrDefault<double>(
                () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 12.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 16.0;
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
                    return 16.0;
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Container(
              width: double.infinity,
              color: Color(0x00000000),
              child: ExpandableNotifier(
                controller: _model.expandableExpandableController,
                child: ExpandablePanel(
                  header: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB31927), Color(0xFF910E1B)],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/ChatGPT_Image_18_.._2568_15_26_25.png',
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 40.0;
                                    } else {
                                      return 40.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 40.0;
                                    } else {
                                      return 40.0;
                                    }
                                  }(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                'รายการแพ้ยา',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          Text(
                            '2 รายการ',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  collapsed: Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          wrapWithModel(
                            model: _model.iconButtonTertiaryModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: IconButtonTertiaryWidget(
                              iconbuttontertiary: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 14.0,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                          ),
                          Text(
                            'ดูเพิ่มเติม',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelSmallFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelSmallIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                  expanded: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: _model.itemDrugallergyModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemDrugallergyWidget(
                          num: '1',
                          drug: 'Penicillin',
                          reaction:
                              'ผื่นลมพิษ (Urticaria), คัน, หายใจลำบาก, หน้าและคอบวม (Angioedema), ช็อก (Anaphylaxis)',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.itemDrugallergyModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemDrugallergyWidget(
                          num: '2',
                          drug: 'Sulfonamides',
                          reaction:
                              'ผื่นแดง, มีไข้, ผิวหนังลอกเป็นแผ่น (Stevens-Johnson Syndrome), คัน',
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          wrapWithModel(
                            model: _model.iconButtonTertiaryModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: IconButtonTertiaryWidget(
                              iconbuttontertiary: Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 14.0,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                          ),
                          Text(
                            'ซ่อน',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelSmallFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelSmallIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ].divide(SizedBox(height: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                    }())).addToStart(SizedBox(height: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                  theme: ExpandableThemeData(
                    tapHeaderToExpand: true,
                    tapBodyToExpand: true,
                    tapBodyToCollapse: true,
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    hasIcon: false,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
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
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 10.0,
                      ),
                    ),
                  ),
                  Text(
                    'รายการสั่งยา',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).customColor8,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
              if (_model.buttonMedOder == widget!.buttonMedOder)
                wrapWithModel(
                  model: _model.bottonPrimary1Model,
                  updateCallback: () => safeSetState(() {}),
                  child: BottonPrimary1Widget(
                    buttonprimary: 'Med Order',
                  ),
                ),
            ],
          ),
        ),
        Padding(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
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
                        FontAwesomeIcons.calendarPlus,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 10.0,
                      ),
                    ),
                  ),
                  Text(
                    'STAT',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).customColor8,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
              wrapWithModel(
                model: _model.itemDrugModel1,
                updateCallback: () => safeSetState(() {}),
                child: ItemDrugWidget(
                  num: '1',
                  drug: 'PARACETAMOL',
                  quantity: '10',
                  howusemedicine:
                      'รับประทานครั้งละ 5.0 tab วันละ 1 ครั้ง ก่อนอาหารเช้า ครึ่ง เม็ดหลังอาหารเย็น',
                  pharmacist: 'นายแพทย์ทดลอง ทดสอบ',
                ),
              ),
              wrapWithModel(
                model: _model.itemDrugModel2,
                updateCallback: () => safeSetState(() {}),
                child: ItemDrugWidget(
                  num: '1',
                  drug: 'PARACETAMOL',
                  quantity: '10',
                  howusemedicine:
                      'รับประทานครั้งละ 5.0 tab วันละ 1 ครั้ง ก่อนอาหารเช้า ครึ่ง เม็ดหลังอาหารเย็น',
                  pharmacist: 'นายแพทย์ทดลอง ทดสอบ',
                ),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
        ),
        Padding(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
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
                        FontAwesomeIcons.calendarCheck,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 10.0,
                      ),
                    ),
                  ),
                  Text(
                    'One Day',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).customColor8,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
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
                    child: wrapWithModel(
                      model: _model.notDataModel,
                      updateCallback: () => safeSetState(() {}),
                      child: NotDataWidget(
                        spac: 0.0,
                        title: 'ไม่พบข้อมูล',
                        detail: '',
                        fontsize: 12.0,
                        textcolor: FlutterFlowTheme.of(context).secondaryText,
                        imagem: 48.0,
                        imaget: 48.0,
                        hidedetail: false,
                      ),
                    ),
                  ),
                ),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
        ),
        Padding(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
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
                        FontAwesomeIcons.calendarAlt,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 10.0,
                      ),
                    ),
                  ),
                  Text(
                    'Continue',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).customColor8,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
              wrapWithModel(
                model: _model.itemDrugModel3,
                updateCallback: () => safeSetState(() {}),
                child: ItemDrugWidget(
                  num: '1',
                  drug: 'PARACETAMOL',
                  quantity: '10',
                  howusemedicine:
                      'รับประทานครั้งละ 5.0 tab วันละ 1 ครั้ง ก่อนอาหารเช้า ครึ่ง เม็ดหลังอาหารเย็น',
                  pharmacist: 'นายแพทย์ทดลอง ทดสอบ',
                ),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
        ),
      ].divide(SizedBox(height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 12.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 12.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 16.0;
        } else {
          return 16.0;
        }
      }())),
    );
  }
}
