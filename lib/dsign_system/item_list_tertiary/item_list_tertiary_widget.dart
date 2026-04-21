import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_list_tertiary_model.dart';
export 'item_list_tertiary_model.dart';

class ItemListTertiaryWidget extends StatefulWidget {
  const ItemListTertiaryWidget({
    super.key,
    this.title,
    this.titlecolor,
    this.showline,
    this.icon,
    Color? iconcolor2,
    Color? iconcolor1,
  })  : this.iconcolor2 = iconcolor2 ?? Colors.white,
        this.iconcolor1 = iconcolor1 ?? Colors.white;

  final String? title;
  final Color? titlecolor;
  final bool? showline;
  final Widget? icon;
  final Color iconcolor2;
  final Color iconcolor1;

  @override
  State<ItemListTertiaryWidget> createState() => _ItemListTertiaryWidgetState();
}

class _ItemListTertiaryWidgetState extends State<ItemListTertiaryWidget> {
  late ItemListTertiaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemListTertiaryModel());

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        valueOrDefault<Color>(
                          widget!.iconcolor1,
                          Color(0xFF7B7B7B),
                        ),
                        valueOrDefault<Color>(
                          widget!.iconcolor2,
                          FlutterFlowTheme.of(context).secondaryText,
                        )
                      ],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: widget!.icon!,
                  ),
                ),
                Text(
                  valueOrDefault<String>(
                    widget!.title,
                    'Title',
                  ),
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                      ),
                ),
              ].divide(SizedBox(width: 8.0)),
            ),
          ),
        ),
        if (widget!.showline ?? true)
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
      ],
    );
  }
}
