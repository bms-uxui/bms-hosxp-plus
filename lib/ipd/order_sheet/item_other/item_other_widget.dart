import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/order_sheet/buttom_off/buttom_off_widget.dart';
import '/ipd/order_sheet/info_staff/info_staff_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_other_model.dart';
export 'item_other_model.dart';

class ItemOtherWidget extends StatefulWidget {
  const ItemOtherWidget({
    super.key,
    this.showoff,
    this.other,
    this.orderer,
    this.recipient,
    this.showorderrecipient,
    this.dateRecipient,
    this.mouthRecipient,
    this.yearRecipient,
    this.timeRecipient,
    this.showitemspc,
  });

  final bool? showoff;
  final String? other;
  final String? orderer;
  final String? recipient;
  final bool? showorderrecipient;
  final String? dateRecipient;
  final String? mouthRecipient;
  final String? yearRecipient;
  final String? timeRecipient;
  final double? showitemspc;

  @override
  State<ItemOtherWidget> createState() => _ItemOtherWidgetState();
}

class _ItemOtherWidgetState extends State<ItemOtherWidget> {
  late ItemOtherModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemOtherModel());

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
        gradient: LinearGradient(
          colors: [Color(0x0DB078FF), Color(0x0D9040FF)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
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
                ),
                valueOrDefault<double>(
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
                ),
                valueOrDefault<double>(
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
                ),
                0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).customColor13,
                                  FlutterFlowTheme.of(context).customColor14
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.keyboard_control,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                size: 12.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Other',
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .customColor14,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                    if (widget!.showoff ?? true)
                      wrapWithModel(
                        model: _model.buttomOffModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtomOffWidget(),
                      ),
                  ].divide(SizedBox(width: 8.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget!.other,
                        'Other',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
          wrapWithModel(
            model: _model.infoStaffModel,
            updateCallback: () => safeSetState(() {}),
            child: InfoStaffWidget(
              orderer: widget!.orderer,
              recipient: widget!.recipient,
              showorderrecipient: widget!.showorderrecipient,
              dateRecipient: widget!.dateRecipient,
              mouthRecipient: widget!.mouthRecipient,
              yearRecipient: widget!.yearRecipient,
              timeRecipient: widget!.timeRecipient,
              showitemspc: widget!.showitemspc,
            ),
          ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
