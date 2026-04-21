import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_list_secondary_model.dart';
export 'item_list_secondary_model.dart';

class ItemListSecondaryWidget extends StatefulWidget {
  const ItemListSecondaryWidget({
    super.key,
    this.title,
    this.titlecolor,
    this.subtitle,
    this.subtitelcolor,
    this.hideline,
  });

  final String? title;
  final Color? titlecolor;
  final String? subtitle;
  final Color? subtitelcolor;
  final bool? hideline;

  @override
  State<ItemListSecondaryWidget> createState() =>
      _ItemListSecondaryWidgetState();
}

class _ItemListSecondaryWidgetState extends State<ItemListSecondaryWidget> {
  late ItemListSecondaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemListSecondaryModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
          child: Container(
            width: double.infinity,
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 48.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 48.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 56.0;
              } else {
                return 56.0;
              }
            }(),
            decoration: BoxDecoration(),
            child: Align(
              alignment: AlignmentDirectional(-1.0, 0.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: valueOrDefault<String>(
                        widget!.title,
                        'Title',
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: valueOrDefault<Color>(
                              widget!.titlecolor,
                              FlutterFlowTheme.of(context).accent1,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    TextSpan(
                      text: ' : ',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).labelLargeFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .labelLargeIsCustom,
                          ),
                    ),
                    TextSpan(
                      text: valueOrDefault<String>(
                        widget!.subtitle,
                        'Sub Title',
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: valueOrDefault<Color>(
                              widget!.subtitelcolor,
                              FlutterFlowTheme.of(context).primaryText,
                            ),
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ),
            ),
          ),
        ),
        if (widget!.hideline ?? true)
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
      ],
    );
  }
}
