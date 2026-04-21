import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'icon_female_model.dart';
export 'icon_female_model.dart';

class IconFemaleWidget extends StatefulWidget {
  const IconFemaleWidget({super.key});

  @override
  State<IconFemaleWidget> createState() => _IconFemaleWidgetState();
}

class _IconFemaleWidgetState extends State<IconFemaleWidget> {
  late IconFemaleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconFemaleModel());

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
          colors: [Color(0xFFFF8AE1), Color(0xFFEE4FC5)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: FaIcon(
          FontAwesomeIcons.venus,
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
