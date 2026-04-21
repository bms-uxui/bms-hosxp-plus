import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/fillter_examinationroom_i_p_d/fillter_examinationroom_i_p_d_widget.dart';
import '/organ_donation/approached/approached_widget.dart';
import '/organ_donation/declined/declined_widget.dart';
import '/organ_donation/discussionnotinitiated/discussionnotinitiated_widget.dart';
import '/organ_donation/fillter_organ_donation/fillter_organ_donation_widget.dart';
import '/organ_donation/item_patient_organ_donationpage/item_patient_organ_donationpage_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organ_donationpage_model.dart';
export 'organ_donationpage_model.dart';

class OrganDonationpageWidget extends StatefulWidget {
  const OrganDonationpageWidget({super.key});

  static String routeName = 'OrganDonationpage';
  static String routePath = 'organDonationpage';

  @override
  State<OrganDonationpageWidget> createState() =>
      _OrganDonationpageWidgetState();
}

class _OrganDonationpageWidgetState extends State<OrganDonationpageWidget>
    with TickerProviderStateMixin {
  late OrganDonationpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganDonationpageModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

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
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 54.0,
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
                'บริจาคอวัยวะ',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                    child: InkWell(
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
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: FillterExaminationroomIPDWidget(),
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
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
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: FillterOrganDonationWidget(),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            },
                            child: wrapWithModel(
                              model: _model.buttonFillterModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonFillterWidget(
                                colorbg: Color(0x7FE0E3E7),
                                coloricon: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_21_.._2568_16_08_55.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: Alignment(1.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      valueOrDefault<double>(
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
                      ),
                      0.0,
                      valueOrDefault<double>(
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
                      ),
                      0.0),
                  child: wrapWithModel(
                    model: _model.searchBarPrimaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SearchBarPrimaryWidget(),
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
                  gradient: LinearGradient(
                    colors: [
                      Color(0xCC3E83E6),
                      FlutterFlowTheme.of(context).primaryBackground,
                      FlutterFlowTheme.of(context).primaryBackground
                    ],
                    stops: [0.0, 0.34, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      valueOrDefault<double>(
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
                      ),
                      0.0,
                      0.0),
                  child: Container(
                    width: double.infinity,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-4.25, 0.0),
                          child: Padding(
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
                                4.0,
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
                            child: ListView(
                              padding: EdgeInsets.fromLTRB(
                                0,
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                0,
                                24.0,
                              ),
                              scrollDirection: Axis.vertical,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        PatientInfoOrganDonationWidget
                                            .routeName);
                                  },
                                  child: wrapWithModel(
                                    model: _model
                                        .itemPatientOrganDonationpageModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemPatientOrganDonationpageWidget(
                                      image:
                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/zwr6ci9pz8d7/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_00_35.png',
                                      fullname: 'นายทดลอง ทดสอบ',
                                      age: 'อายุ 52 ปี',
                                      ward: 'หอผู้ป่วยวิกฤตศัลยกรรมหัวใจ',
                                      hn: '0000001',
                                      an: '0000001',
                                      bgimag:
                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/bz1clc9y8cbz/ChatGPT_Image_25_%E0%B8%81.%E0%B8%84._2568_16_31_01.png',
                                      gender: () => IconMaleWidget(),
                                      status: () =>
                                          DiscussionnotinitiatedWidget(),
                                    ),
                                  ),
                                ),
                                wrapWithModel(
                                  model:
                                      _model.itemPatientOrganDonationpageModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemPatientOrganDonationpageWidget(
                                    image:
                                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/5ggmp4wktfto/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_05_37.png',
                                    fullname: 'นางสาวทดลอง ทดสอบ',
                                    age: 'อายุ 35 ปี',
                                    ward: 'หอผู้ป่วยวิกฤตศัลยกรรมหัวใจ',
                                    hn: '0000001',
                                    an: '0000001',
                                    bgimag:
                                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/bz1clc9y8cbz/ChatGPT_Image_25_%E0%B8%81.%E0%B8%84._2568_16_31_01.png',
                                    gender: () => IconFemaleWidget(),
                                    status: () =>
                                        DiscussionnotinitiatedWidget(),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        PatientInfoOrganDonationDetailWidget
                                            .routeName);
                                  },
                                  child: wrapWithModel(
                                    model: _model
                                        .itemPatientOrganDonationpageModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemPatientOrganDonationpageWidget(
                                      image:
                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/kks5eo2nde9z/ChatGPT_Image_20_%E0%B8%9E.%E0%B8%84._2568_16_08_16.png',
                                      fullname: 'นางทดลอง ทดสอบ',
                                      age: 'อายุ 70 ปี',
                                      ward: 'หอผู้ป่วยวิกฤตศัลยกรรมหัวใจ',
                                      hn: '0000001',
                                      an: '0000001',
                                      bgcolor: Color(0x093AAA5F),
                                      bgimag:
                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/rm4oyyzfnd2a/ChatGPT_Image_26_%E0%B8%AA.%E0%B8%84._2568_13_47_10.png',
                                      gender: () => IconFemaleWidget(),
                                      status: () => ApproachedWidget(),
                                    ),
                                  ),
                                ),
                                wrapWithModel(
                                  model:
                                      _model.itemPatientOrganDonationpageModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemPatientOrganDonationpageWidget(
                                    image:
                                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/v7hpd8vn1qab/ChatGPT_Image_19_%E0%B8%9E.%E0%B8%84._2568_10_10_57.png',
                                    fullname: 'เด็กชายทดลอง ทดสอบ',
                                    age: 'อายุ 12 ปี',
                                    ward: 'หอผู้ป่วยวิกฤตศัลยกรรมหัวใจ',
                                    hn: '0000001',
                                    an: '0000001',
                                    bgcolor: Color(0x0BBE1E2D),
                                    bgimag:
                                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/u9q9h13n3vla/ChatGPT_Image_26_%E0%B8%AA.%E0%B8%84._2568_13_49_26.png',
                                    gender: () => IconMaleWidget(),
                                    status: () => DeclinedWidget(),
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
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
