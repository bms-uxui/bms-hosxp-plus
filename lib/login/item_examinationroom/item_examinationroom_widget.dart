import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_examinationroom_model.dart';
export 'item_examinationroom_model.dart';

class ItemExaminationroomWidget extends StatefulWidget {
  const ItemExaminationroomWidget({
    super.key,
    this.examinationroom,
  });

  final String? examinationroom;

  @override
  State<ItemExaminationroomWidget> createState() =>
      _ItemExaminationroomWidgetState();
}

class _ItemExaminationroomWidgetState extends State<ItemExaminationroomWidget> {
  late ItemExaminationroomModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemExaminationroomModel());

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
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 80.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 80.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 100.0;
        } else {
          return 100.0;
        }
      }(),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.9,
            child: Align(
              alignment: AlignmentDirectional(1.0, 1.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/ChatGPT_Image_4_.._2568_09_05_12.png',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Padding(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  wrapWithModel(
                    model: _model.iconButtonTertiaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: IconButtonTertiaryWidget(
                      iconbuttontertiary: Icon(
                        Icons.double_arrow_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 14.0,
                      ),
                      color: Color(0x98F1F4F8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      valueOrDefault<String>(
                        widget!.examinationroom,
                        'Examination room',
                      ),
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                  ),
                ].divide(SizedBox(width: 12.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
