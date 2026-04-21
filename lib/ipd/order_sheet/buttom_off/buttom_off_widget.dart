import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttom_off_model.dart';
export 'buttom_off_model.dart';

class ButtomOffWidget extends StatefulWidget {
  const ButtomOffWidget({super.key});

  @override
  State<ButtomOffWidget> createState() => _ButtomOffWidgetState();
}

class _ButtomOffWidgetState extends State<ButtomOffWidget> {
  late ButtomOffModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtomOffModel());

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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        gradient: LinearGradient(
          colors: [Color(0xFFEC2E41), FlutterFlowTheme.of(context).error],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
        child: Text(
          'Off',
          style: GoogleFonts.roboto(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            fontSize: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 10.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 10.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }(),
          ),
        ),
      ),
    );
  }
}
