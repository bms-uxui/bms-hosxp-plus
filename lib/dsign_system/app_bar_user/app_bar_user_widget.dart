import '/dsign_system/user_profile/user_profile_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_bar_user_model.dart';
export 'app_bar_user_model.dart';

class AppBarUserWidget extends StatefulWidget {
  const AppBarUserWidget({super.key});

  @override
  State<AppBarUserWidget> createState() => _AppBarUserWidgetState();
}

class _AppBarUserWidgetState extends State<AppBarUserWidget> {
  late AppBarUserModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppBarUserModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: wrapWithModel(
            model: _model.userProfileModel,
            updateCallback: () => safeSetState(() {}),
            child: UserProfileWidget(
              name: 'นายแพทย์ทดสอบ ทดสอบ',
              jobposition: 'แพทย์',
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 32.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 32.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 40.0;
                } else {
                  return 40.0;
                }
              }(),
              height: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 32.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 32.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 40.0;
                } else {
                  return 40.0;
                }
              }(),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10.0,
                        sigmaY: 10.0,
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(SettingWidget.routeName);
                        },
                        child: Container(
                          width: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 32.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 32.0;
                            } else if (MediaQuery.sizeOf(context).width <
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
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 32.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 40.0;
                            } else {
                              return 40.0;
                            }
                          }(),
                          decoration: BoxDecoration(
                            color: Color(0x19FFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0x19FFFFFF),
                            ),
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Icon(
                              Icons.notifications_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              size: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1.0, -1.0),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed(SettingWidget.routeName);
                  },
                  child: Container(
                    width: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                        return 32.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointMedium) {
                        return 32.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointLarge) {
                        return 40.0;
                      } else {
                        return 40.0;
                      }
                    }(),
                    height: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                        return 32.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointMedium) {
                        return 32.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointLarge) {
                        return 40.0;
                      } else {
                        return 40.0;
                      }
                    }(),
                    decoration: BoxDecoration(
                      color: Color(0x19FFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0x19FFFFFF),
                      ),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.settings_sharp,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }
}
