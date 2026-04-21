import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'more_physical_examination_widget.dart'
    show MorePhysicalExaminationWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MorePhysicalExaminationModel
    extends FlutterFlowModel<MorePhysicalExaminationWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  bool isDataUploading_uploadDataLu0 = false;
  FFUploadedFile uploadedLocalFile_uploadDataLu0 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  bool isDataUploading_uploadDataLu1 = false;
  FFUploadedFile uploadedLocalFile_uploadDataLu1 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
  }
}
