import '/dsign_system/date_recorde/date_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_lab_history_model.dart';
export 'item_lab_history_model.dart';

class ItemLabHistoryWidget extends StatefulWidget {
  const ItemLabHistoryWidget({
    super.key,
    this.day,
    this.month,
    this.year,
    this.resultlab,
    this.color,
  });

  final String? day;
  final String? month;
  final String? year;
  final String? resultlab;
  final Color? color;

  @override
  State<ItemLabHistoryWidget> createState() => _ItemLabHistoryWidgetState();
}

class _ItemLabHistoryWidgetState extends State<ItemLabHistoryWidget> {
  late ItemLabHistoryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemLabHistoryModel());

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
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wrapWithModel(
              model: _model.dateRecordeModel,
              updateCallback: () => safeSetState(() {}),
              child: DateRecordeWidget(
                day: widget!.day,
                month: widget!.month,
                year: widget!.year,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            Text(
              valueOrDefault<String>(
                widget!.resultlab,
                '0',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: widget!.color,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ],
        ),
        Divider(
          height: 1.0,
          thickness: 1.0,
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
      ].divide(SizedBox(height: 8.0)),
    );
  }
}
