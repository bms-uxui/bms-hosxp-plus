import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_nursingproblems_template_model.dart';
export 'item_nursingproblems_template_model.dart';

class ItemNursingproblemsTemplateWidget extends StatefulWidget {
  const ItemNursingproblemsTemplateWidget({
    super.key,
    this.nursingproblemstemplateitem,
    this.template,
  });

  final int? nursingproblemstemplateitem;
  final String? template;

  @override
  State<ItemNursingproblemsTemplateWidget> createState() =>
      _ItemNursingproblemsTemplateWidgetState();
}

class _ItemNursingproblemsTemplateWidgetState
    extends State<ItemNursingproblemsTemplateWidget> {
  late ItemNursingproblemsTemplateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemNursingproblemsTemplateModel());

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FFAppState().NursingProblemsTemplateitem ==
                    widget!.nursingproblemstemplateitem
                ? FlutterFlowTheme.of(context).accent2
                : FlutterFlowTheme.of(context).primaryBackground,
            FFAppState().NursingProblemsTemplateitem ==
                    widget!.nursingproblemstemplateitem
                ? FlutterFlowTheme.of(context).accent1
                : FlutterFlowTheme.of(context).primaryBackground
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          valueOrDefault<String>(
            widget!.template,
            'Template Name ',
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FFAppState().NursingProblemsTemplateitem ==
                        widget!.nursingproblemstemplateitem
                    ? FlutterFlowTheme.of(context).secondaryBackground
                    : FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ),
    );
  }
}
