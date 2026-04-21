import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_branch_model.dart';
export 'item_branch_model.dart';

class ItemBranchWidget extends StatefulWidget {
  const ItemBranchWidget({
    super.key,
    this.namebranch,
    this.selectbranch,
  });

  final String? namebranch;

  /// colortext
  final int? selectbranch;

  @override
  State<ItemBranchWidget> createState() => _ItemBranchWidgetState();
}

class _ItemBranchWidgetState extends State<ItemBranchWidget>
    with TickerProviderStateMixin {
  late ItemBranchModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemBranchModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).accent2,
            FlutterFlowTheme.of(context).accent1
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional(1.0, 1.0),
            child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x04F1F4F8), Color(0x0CFFFFFF)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.56, -1.0),
                  end: AlignmentDirectional(-0.56, 1.0),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.0),
                  topRight: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Align(
              alignment: AlignmentDirectional(1.0, 1.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/ChatGPT_Image_4_.._2568_08_58_08.png',
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
                children: [
                  if (FFAppState().selectbranch == widget!.selectbranch)
                    Container(
                      width: 6.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: FFAppState().selectbranch == widget!.selectbranch
                            ? FlutterFlowTheme.of(context).secondaryBackground
                            : Color(0x003E83E6),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      valueOrDefault<String>(
                        widget!.namebranch,
                        'Branch',
                      ),
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
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
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
  }
}
