import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'more_physical_examination_model.dart';
export 'more_physical_examination_model.dart';

class MorePhysicalExaminationWidget extends StatefulWidget {
  const MorePhysicalExaminationWidget({super.key});

  @override
  State<MorePhysicalExaminationWidget> createState() =>
      _MorePhysicalExaminationWidgetState();
}

class _MorePhysicalExaminationWidgetState
    extends State<MorePhysicalExaminationWidget> {
  late MorePhysicalExaminationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MorePhysicalExaminationModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: () {
          if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
            return 450.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 450.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 550.0;
          } else {
            return 550.0;
          }
        }(),
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
                    'รูปภาพ',
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
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
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
                  ),
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      width: 100.0,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final selectedMedia = await selectMedia(
                                  mediaSource: MediaSource.photoGallery,
                                  multiImage: false,
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) =>
                                        validateFileFormat(
                                            m.storagePath, context))) {
                                  safeSetState(() => _model
                                      .isDataUploading_uploadDataLu0 = true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];

                                  try {
                                    showUploadMessage(
                                      context,
                                      'Uploading file...',
                                      showLoading: true,
                                    );
                                    selectedUploadedFiles = selectedMedia
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              height: m.dimensions?.height,
                                              width: m.dimensions?.width,
                                              blurHash: m.blurHash,
                                              originalFilename:
                                                  m.originalFilename,
                                            ))
                                        .toList();
                                  } finally {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    _model.isDataUploading_uploadDataLu0 =
                                        false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedMedia.length) {
                                    safeSetState(() {
                                      _model.uploadedLocalFile_uploadDataLu0 =
                                          selectedUploadedFiles.first;
                                    });
                                    showUploadMessage(context, 'Success!');
                                  } else {
                                    safeSetState(() {});
                                    showUploadMessage(
                                        context, 'Failed to upload data');
                                    return;
                                  }
                                }

                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .accent2,
                                            FlutterFlowTheme.of(context).accent1
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.image_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 10.0,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'เลือกจากคลัง',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLargeFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyLargeIsCustom,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1.0,
                              thickness: 1.0,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final selectedMedia = await selectMedia(
                                  multiImage: false,
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) =>
                                        validateFileFormat(
                                            m.storagePath, context))) {
                                  safeSetState(() => _model
                                      .isDataUploading_uploadDataLu1 = true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];

                                  try {
                                    selectedUploadedFiles = selectedMedia
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              height: m.dimensions?.height,
                                              width: m.dimensions?.width,
                                              blurHash: m.blurHash,
                                              originalFilename:
                                                  m.originalFilename,
                                            ))
                                        .toList();
                                  } finally {
                                    _model.isDataUploading_uploadDataLu1 =
                                        false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedMedia.length) {
                                    safeSetState(() {
                                      _model.uploadedLocalFile_uploadDataLu1 =
                                          selectedUploadedFiles.first;
                                    });
                                  } else {
                                    safeSetState(() {});
                                    return;
                                  }
                                }

                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .accent2,
                                            FlutterFlowTheme.of(context).accent1
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'ถ่ายภาพ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLargeFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyLargeIsCustom,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1.0,
                              thickness: 1.0,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                            Container(
                              width: double.infinity,
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 48.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 48.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24.0,
                                    height: 24.0,
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
                                        FontAwesomeIcons.solidFileImage,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        size: 10.0,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'เลือกจาก template',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyLargeIsCustom,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
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
          ],
        ),
      ),
    );
  }
}
