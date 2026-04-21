import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/order_sheet/buttom_off/buttom_off_widget.dart';
import '/ipd/order_sheet/info_staff/info_staff_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_examination_model.dart';
export 'item_examination_model.dart';

class ItemExaminationWidget extends StatefulWidget {
  const ItemExaminationWidget({
    super.key,
    this.showoff,
    this.examination,
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
  final String? examination;
  final String? orderer;
  final String? recipient;
  final bool? showorderrecipient;
  final String? dateRecipient;
  final String? mouthRecipient;
  final String? yearRecipient;
  final String? timeRecipient;
  final double? showitemspc;

  @override
  State<ItemExaminationWidget> createState() => _ItemExaminationWidgetState();
}

class _ItemExaminationWidgetState extends State<ItemExaminationWidget> {
  late ItemExaminationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemExaminationModel());

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
          colors: [Color(0x0EFFB960), Color(0x0DFFA02A)],
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
                                  FlutterFlowTheme.of(context).customColor17,
                                  FlutterFlowTheme.of(context).customColor18
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
                                FontAwesomeIcons.vial,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                size: 10.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Examination',
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .customColor18,
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
                        widget!.examination,
                        'Examination',
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
