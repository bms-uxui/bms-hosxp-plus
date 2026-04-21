import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_practices_model.dart';
export 'item_practices_model.dart';

class ItemPracticesWidget extends StatefulWidget {
  const ItemPracticesWidget({
    super.key,
    this.numpractices,
    this.practices,
    this.bgcolor,
  });

  final String? numpractices;
  final String? practices;
  final Color? bgcolor;

  @override
  State<ItemPracticesWidget> createState() => _ItemPracticesWidgetState();
}

class _ItemPracticesWidgetState extends State<ItemPracticesWidget> {
  late ItemPracticesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemPracticesModel());

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
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.bgcolor,
          FlutterFlowTheme.of(context).secondaryBackground,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(valueOrDefault<double>(
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
          0.0,
        )),
        child: RichText(
          textScaler: MediaQuery.of(context).textScaler,
          text: TextSpan(
            children: [
              TextSpan(
                text: valueOrDefault<String>(
                  widget!.numpractices,
                  '0',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
              TextSpan(
                text: '. ',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
              TextSpan(
                text: valueOrDefault<String>(
                  widget!.practices,
                  'Practices',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              )
            ],
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
