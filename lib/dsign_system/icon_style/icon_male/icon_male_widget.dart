import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_male_model.dart';
export 'icon_male_model.dart';

class IconMaleWidget extends StatefulWidget {
  const IconMaleWidget({super.key});

  @override
  State<IconMaleWidget> createState() => _IconMaleWidgetState();
}

class _IconMaleWidgetState extends State<IconMaleWidget> {
  late IconMaleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconMaleModel());

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
      width: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 20.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 20.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 24.0;
        } else {
          return 24.0;
        }
      }(),
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 20.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 20.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 24.0;
        } else {
          return 24.0;
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
          colors: [Color(0xFF62B3FF), Color(0xFF2397FF)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: FaIcon(
          FontAwesomeIcons.mars,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          size: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 14.0;
            } else {
              return 14.0;
            }
          }(),
        ),
      ),
    );
  }
}
