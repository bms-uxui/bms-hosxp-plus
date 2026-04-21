import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_list_primary_model.dart';
export 'item_list_primary_model.dart';

class ItemListPrimaryWidget extends StatefulWidget {
  const ItemListPrimaryWidget({
    super.key,
    this.title,
    this.titlecolor,
    bool? showline,
  }) : this.showline = showline ?? false;

  final String? title;
  final Color? titlecolor;
  final bool showline;

  @override
  State<ItemListPrimaryWidget> createState() => _ItemListPrimaryWidgetState();
}

class _ItemListPrimaryWidgetState extends State<ItemListPrimaryWidget> {
  late ItemListPrimaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemListPrimaryModel());

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
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
            child: Container(
              width: double.infinity,
              height: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
              child: Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Text(
                  valueOrDefault<String>(
                    widget!.title,
                    'Titel',
                  ),
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        color: valueOrDefault<Color>(
                          widget!.titlecolor,
                          FlutterFlowTheme.of(context).primaryText,
                        ),
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                      ),
                ),
              ),
            ),
          ),
          if (valueOrDefault<bool>(
            widget!.showline,
            true,
          ))
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
        ],
      ),
    );
  }
}
