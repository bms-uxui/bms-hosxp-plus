import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/accident/accident_view/accident_view_widget.dart';
import '/er/diagnosis/diag_e_r_view/diag_e_r_view_widget.dart';
import '/er/drugand_service/drug_srevice_e_r_view/drug_srevice_e_r_view_widget.dart';
import '/er/emr/e_m_r_er_view/e_m_r_er_view_widget.dart';
import '/er/fillter_menu_e_r/fillter_menu_e_r_widget.dart';
import '/er/info_patient_e_r/info_patient_e_r_view/info_patient_e_r_view_widget.dart';
import '/er/menu_patient_info_e_r/menu_patient_info_e_r_widget.dart';
import '/er/nursing_activities/nursing_activities_view/nursing_activities_view_widget.dart';
import '/er/observe/observe_view/observe_view_widget.dart';
import '/er/patient_screening/patient_screening_view/patient_screening_view_widget.dart';
import '/er/physical_examination/physical_examination_view/physical_examination_view_widget.dart';
import '/er/treatment/treatment_e_r_view/treatment_e_r_view_widget.dart';
import '/er/waitingfor_screening/waitingfor_screening_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/appiontment_view/appiontment_view_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_info_e_r_model.dart';
export 'patient_info_e_r_model.dart';

class PatientInfoERWidget extends StatefulWidget {
  const PatientInfoERWidget({super.key});

  static String routeName = 'Patient_Info_ER';
  static String routePath = 'patientInfoER';

  @override
  State<PatientInfoERWidget> createState() => _PatientInfoERWidgetState();
}

class _PatientInfoERWidgetState extends State<PatientInfoERWidget>
    with TickerProviderStateMixin {
  late PatientInfoERModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasMenuPatientInfoERTriggered1 = false;
  var hasMenuPatientInfoERTriggered2 = false;
  var hasMenuPatientInfoERTriggered3 = false;
  var hasMenuPatientInfoERTriggered4 = false;
  var hasMenuPatientInfoERTriggered5 = false;
  var hasMenuPatientInfoERTriggered6 = false;
  var hasMenuPatientInfoERTriggered7 = false;
  var hasMenuPatientInfoERTriggered8 = false;
  var hasMenuPatientInfoERTriggered9 = false;
  var hasMenuPatientInfoERTriggered10 = false;
  var hasMenuPatientInfoERTriggered11 = false;
  var hasMenuPatientInfoERTriggered12 = false;
  var hasMenuPatientInfoERTriggered13 = false;
  var hasMenuPatientInfoERTriggered14 = false;
  var hasMenuPatientInfoERTriggered15 = false;
  var hasMenuPatientInfoERTriggered16 = false;
  var hasMenuPatientInfoERTriggered17 = false;
  var hasMenuPatientInfoERTriggered18 = false;
  var hasMenuPatientInfoERTriggered19 = false;
  var hasMenuPatientInfoERTriggered20 = false;
  var hasMenuPatientInfoERTriggered21 = false;
  var hasMenuPatientInfoERTriggered22 = false;
  var hasMenuPatientInfoERTriggered23 = false;
  var hasMenuPatientInfoERTriggered24 = false;
  var hasMenuPatientInfoERTriggered25 = false;
  var hasMenuPatientInfoERTriggered26 = false;
  var hasMenuPatientInfoERTriggered27 = false;
  var hasMenuPatientInfoERTriggered28 = false;
  var hasMenuPatientInfoERTriggered29 = false;
  var hasMenuPatientInfoERTriggered30 = false;
  var hasMenuPatientInfoERTriggered31 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientInfoERModel());

    // จอนี้ออกแบบมาให้อ่านแนวนอน (แผงประวัติ + สองฝั่งเทียบกัน) จึงล็อกแนวไว้
    // ตอนเข้า แล้วคืนค่าเดิมตอนออก — ไม่มีผลบนเว็บและเดสก์ท็อป
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: true)
          ..addListener(() => safeSetState(() {}));
    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.5, 1.5),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 100.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 100.0.ms,
            duration: 600.0.ms,
            begin: Offset(-23.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'rowOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: Offset(-23.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation11': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation12': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation13': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation14': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation15': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation16': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation17': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation18': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation19': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation20': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation21': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation22': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation23': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation24': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation25': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation26': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation27': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation28': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation29': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation30': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation31': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _erRailScroll.dispose();
    _erLeftScroll.dispose();
    _erRightScroll.dispose();
    _erTimelineScroll.dispose();
    _model.dispose();

    super.dispose();
  }

  // แต่ละแผงในโหมดแบ่งจอถือ controller ของตัวเอง ไม่งั้นทุกแผงไปผูกกับ
  // PrimaryScrollController ตัวเดียวของ NestedScrollView แล้วเลื่อนพร้อมกันหมด
  final ScrollController _erRailScroll = ScrollController();
  final ScrollController _erLeftScroll = ScrollController();
  final ScrollController _erRightScroll = ScrollController();
  final ScrollController _erTimelineScroll = ScrollController();

  /// แคบกว่านี้แบ่งสองฝั่งแล้วอ่านไม่ออก
  static const double _erSplitMinWidth = 1000.0;
  static const double _erRailWidth = 288.0;

  /// แคบกว่านี้ไทม์ไลน์ยังอยู่ในแผงซ้าย เพราะแบ่งแผงแล้วเนื้อหาตรงกลางจะเหลือน้อยเกิน
  static const double _erTimelineMinWidth = 1000.0;

  /// ตอนกางเทียบสองฝั่ง ต้องกว้างกว่านี้ถึงจะมีที่พอให้ไทม์ไลน์อยู่ด้วย
  static const double _erTimelineWithCompareMinWidth = 1400.0;

  // ---------------------------------------------------------------------------
  // ข้อมูลตัวอย่างของแผงประวัติ — จอนี้ยังไม่ผูก API เหมือนส่วนอื่นของหน้า
  // TODO: ผูกกับผลลัพธ์ API เคส ER (แพ้ยา / สัญญาณชีพ / ผลแล็บ / รอบตรวจซ้ำ)
  // ---------------------------------------------------------------------------
  static const List<List<String>> _erAllergyDemo = [
    ['Penicillin', 'ผื่นลมพิษ (Urticaria), หายใจลำบาก'],
  ];

  /// [ชื่อค่า, ค่าที่วัดได้, ช่วงปกติ, ทิศทาง] — ทิศทาง high = สูงกว่าเกณฑ์, low = ต่ำกว่า
  static const List<List<String>> _erAbnormalVitalDemo = [
    ['อุณหภูมิ', '38.9 °C', '36.5–37.5', 'high'],
    ['ความดัน', '156/90 mmHg', '90/60–140/90', 'high'],
    ['ชีพจร', '101 ครั้ง/นาที', '60–100', 'high'],
  ];

  static const List<List<String>> _erAbnormalLabDemo = [
    ['Lactate', '2.8 mmol/L', '0.5–2.2', 'high'],
    ['WBC', '14,200 /µL', '4,000–11,000', 'high'],
  ];

  /// [เวลา, หัวข้อ, สถานะ] — done = ทำแล้ว, due = ถึงรอบแล้ว, next = รอบถัดไป
  static const List<List<String>> _erRecheckDemo = [
    ['08:55', 'คัดกรองแรกรับ', 'done'],
    ['09:10', 'ตรวจซ้ำรอบที่ 1', 'done'],
    ['09:25', 'ตรวจซ้ำรอบที่ 2', 'done'],
    ['09:40', 'ตรวจซ้ำรอบที่ 3', 'due'],
    ['09:55', 'ตรวจซ้ำรอบที่ 4', 'next'],
  ];

  /// หัวข้อหมวดแบบเดียวกับที่ใช้ทั้งโมดูล: วงกลมไล่สี + ไอคอนขาว + ชื่อหมวดสีเดียวกับวงกลม
  Widget _erRailHeading(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradient,
    Color titleColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 12.0,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                  color: titleColor,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                ),
          ),
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }

  /// การ์ดขาวมุมมน 24 แบบเดียวกับการ์ดอื่นในหน้า
  Widget _erRailCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }

  /// คู่ป้ายกำกับกับค่า ตามแบบที่ใช้ในการ์ดข้อมูลผู้ป่วย
  Widget _erRailField(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: valueColor ?? FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ],
    );
  }

  /// แถวค่าที่ผิดปกติ — บอกด้วยลูกศรและคำกำกับด้วย ไม่ใช่สีอย่างเดียว
  /// (WCAG: ห้ามสื่อความหมายด้วยสีเพียงอย่างเดียว)
  Widget _erRailAbnormal(BuildContext context, String name, String value,
      String normal, String direction) {
    final theme = FlutterFlowTheme.of(context);
    final isHigh = direction == 'high';
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _erRailField(context, 'ปกติ $normal', name),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHigh
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: theme.error,
                  size: 14.0,
                ),
                Text(
                  value,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.error,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ].divide(SizedBox(width: 2.0)),
            ),
            Text(
              isHigh ? 'สูงกว่าเกณฑ์' : 'ต่ำกว่าเกณฑ์',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.error,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ),
      ].divide(SizedBox(width: 8.0)),
    );
  }

  Widget _erRailDivider(BuildContext context) => StyledDivider(
        height: 1.0,
        thickness: 1.0,
        color: FlutterFlowTheme.of(context).alternate,
        lineStyle: DividerLineStyle.dashed,
      );

  Widget _erRailEmpty(BuildContext context, String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      );

  /// ชิปกลมแบบเดียวกับชิปบนหัวจอ
  Widget _erRailChip(BuildContext context, String text) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ),
      );

  /// แผงประวัติผู้ป่วยแบบตั้ง อยู่ซ้ายสุดเมื่อจอกว้างพอ
  Widget _erProfileRail(BuildContext context, {required bool withTimeline}) {
    final theme = FlutterFlowTheme.of(context);

    Color recheckColor(String status) {
      if (status == 'due') return theme.error;
      if (status == 'next') return theme.secondaryText;
      return Color(0xFF2BA755);
    }

    String recheckLabel(String status) {
      if (status == 'due') return 'ถึงรอบแล้ว';
      if (status == 'next') return 'รอบถัดไป';
      return 'บันทึกแล้ว';
    }

    return Container(
      width: _erRailWidth,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(right: BorderSide(color: theme.alternate, width: 1.0)),
      ),
      child: ListView(
        controller: _erRailScroll,
        primary: false,
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ข้อมูลผู้ป่วย ----------
              _erRailHeading(context, 'ข้อมูลผู้ป่วย', Icons.person_rounded,
                  [Color(0xFF62B3FF), Color(0xFF2397FF)], Color(0xFF2397FF)),
              _erRailCard(context, [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.secondary, theme.accent2],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Icon(Icons.person_rounded,
                            color: theme.secondaryBackground, size: 22.0),
                      ),
                    ),
                    Expanded(
                      child: _erRailField(
                          context, 'อายุ 52 ปี · ชาย', 'นายทดสอบ ทดสอบ'),
                    ),
                  ].divide(SizedBox(width: 12.0)),
                ),
                _erRailDivider(context),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _erRailChip(context, 'Q 1'),
                    _erRailChip(context, 'HN 0000001'),
                    _erRailChip(context, 'ประเภท : Trauma'),
                  ],
                ),
              ]),

              // ---------- แพ้ยา ----------
              _erRailHeading(context, 'แพ้ยา', Icons.warning_rounded,
                  [Color(0xFFFF7C87), theme.error], theme.error),
              _erRailCard(
                context,
                _erAllergyDemo.isEmpty
                    ? [_erRailEmpty(context, 'ปฏิเสธการแพ้ยา')]
                    : [
                        for (int i = 0; i < _erAllergyDemo.length; i++) ...[
                          if (i > 0) _erRailDivider(context),
                          _erRailField(
                            context,
                            _erAllergyDemo[i][1],
                            _erAllergyDemo[i][0],
                            valueColor: theme.error,
                          ),
                        ],
                      ],
              ),

              // ---------- สัญญาณชีพที่ผิดปกติ ----------
              _erRailHeading(
                  context,
                  'สัญญาณชีพที่ผิดปกติ',
                  Icons.monitor_heart_rounded,
                  [Color(0xFFFFB960), Color(0xFFFFA02A)],
                  Color(0xFFFFA02A)),
              _erRailCard(
                context,
                _erAbnormalVitalDemo.isEmpty
                    ? [_erRailEmpty(context, 'สัญญาณชีพอยู่ในเกณฑ์ปกติ')]
                    : [
                        for (int i = 0;
                            i < _erAbnormalVitalDemo.length;
                            i++) ...[
                          if (i > 0) _erRailDivider(context),
                          _erRailAbnormal(
                              context,
                              _erAbnormalVitalDemo[i][0],
                              _erAbnormalVitalDemo[i][1],
                              _erAbnormalVitalDemo[i][2],
                              _erAbnormalVitalDemo[i][3]),
                        ],
                      ],
              ),

              // ---------- ผลแล็บที่ผิดปกติ ----------
              _erRailHeading(context, 'ผลแล็บที่ผิดปกติ', Icons.science_rounded,
                  [Color(0xFFB078FF), Color(0xFF9040FF)], Color(0xFF9040FF)),
              _erRailCard(
                context,
                _erAbnormalLabDemo.isEmpty
                    ? [_erRailEmpty(context, 'ยังไม่มีผลแล็บที่ผิดปกติ')]
                    : [
                        for (int i = 0; i < _erAbnormalLabDemo.length; i++) ...[
                          if (i > 0) _erRailDivider(context),
                          _erRailAbnormal(
                              context,
                              _erAbnormalLabDemo[i][0],
                              _erAbnormalLabDemo[i][1],
                              _erAbnormalLabDemo[i][2],
                              _erAbnormalLabDemo[i][3]),
                        ],
                      ],
              ),

              if (withTimeline) ...[
                // ---------- ไทม์ไลน์การตรวจซ้ำ ----------
                _erRailHeading(
                    context,
                    'ไทม์ไลน์การตรวจซ้ำ',
                    Icons.schedule_rounded,
                    [Color(0xFF37E974), Color(0xFF2BA755)],
                    Color(0xFF2BA755)),
                _erRailCard(context, [
                  for (int i = 0; i < _erRecheckDemo.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsetsDirectional.fromSTEB(
                              0.0, 5.0, 0.0, 0.0),
                          decoration: BoxDecoration(
                            color: _erRecheckDemo[i][2] == 'next'
                                ? theme.secondaryBackground
                                : recheckColor(_erRecheckDemo[i][2]),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: recheckColor(_erRecheckDemo[i][2]),
                                width: 1.5),
                          ),
                        ),
                        Expanded(
                          child: _erRailField(
                            context,
                            '${_erRecheckDemo[i][0]} น.',
                            _erRecheckDemo[i][1],
                          ),
                        ),
                        Icon(
                          _erRecheckDemo[i][2] == 'due'
                              ? Icons.notifications_active_rounded
                              : _erRecheckDemo[i][2] == 'next'
                                  ? Icons.schedule_rounded
                                  : Icons.check_circle_rounded,
                          color: recheckColor(_erRecheckDemo[i][2]),
                          size: 14.0,
                        ),
                        Text(
                          recheckLabel(_erRecheckDemo[i][2]),
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: recheckColor(_erRecheckDemo[i][2]),
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                ]),
              ],
            ].divide(SizedBox(height: 12.0)),
          ),
        ],
      ),
    );
  }

  /// แผงไทม์ไลน์การตรวจซ้ำ อยู่ขวาสุดเมื่อจอกว้างพอ
  Widget _erTimelineRail(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    Color recheckColor(String status) {
      if (status == 'due') return theme.error;
      if (status == 'next') return theme.secondaryText;
      return Color(0xFF2BA755);
    }

    String recheckLabel(String status) {
      if (status == 'due') return 'ถึงรอบแล้ว';
      if (status == 'next') return 'รอบถัดไป';
      return 'บันทึกแล้ว';
    }

    return Container(
      width: _erRailWidth,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(left: BorderSide(color: theme.alternate, width: 1.0)),
      ),
      child: ListView(
        controller: _erTimelineScroll,
        primary: false,
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ไทม์ไลน์การตรวจซ้ำ ----------
              _erRailHeading(
                  context,
                  'ไทม์ไลน์การตรวจซ้ำ',
                  Icons.schedule_rounded,
                  [Color(0xFF37E974), Color(0xFF2BA755)],
                  Color(0xFF2BA755)),
              _erRailCard(context, [
                for (int i = 0; i < _erRecheckDemo.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10.0,
                        height: 10.0,
                        margin:
                            EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                        decoration: BoxDecoration(
                          color: _erRecheckDemo[i][2] == 'next'
                              ? theme.secondaryBackground
                              : recheckColor(_erRecheckDemo[i][2]),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: recheckColor(_erRecheckDemo[i][2]),
                              width: 1.5),
                        ),
                      ),
                      Expanded(
                        child: _erRailField(
                          context,
                          '${_erRecheckDemo[i][0]} น.',
                          _erRecheckDemo[i][1],
                        ),
                      ),
                      Icon(
                        _erRecheckDemo[i][2] == 'due'
                            ? Icons.notifications_active_rounded
                            : _erRecheckDemo[i][2] == 'next'
                                ? Icons.schedule_rounded
                                : Icons.check_circle_rounded,
                        color: recheckColor(_erRecheckDemo[i][2]),
                        size: 14.0,
                      ),
                      Text(
                        recheckLabel(_erRecheckDemo[i][2]),
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: recheckColor(_erRecheckDemo[i][2]),
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
              ]),
            ].divide(SizedBox(height: 12.0)),
          ),
        ],
      ),
    );
  }

  /// ชื่อแท็บตามลำดับของ TabMenuPatientInfoER (1–14)
  static const List<String> _erTabNames = [
    'ข้อมูลผู้ป่วย',
    'EMR',
    'คัดกรอง',
    'ตรวจร่างกาย',
    'กิจกรรมพยาบาล',
    'อุบัติเหตุ',
    'สังเกตอาการ',
    'หัตถการ',
    'Lab/X-Ray',
    'การวินิจฉัย',
    'ยา/ค่าบริการ',
    'นัดหมาย',
    'ใบรับรองแพทย์',
    'สรุปการรักษา',
  ];

  String _erTabName(int tab) => (tab >= 1 && tab <= _erTabNames.length)
      ? _erTabNames[tab - 1]
      : 'หน้าจอ $tab';

  /// เนื้อหาของแท็บที่ระบุ — แยกออกมาจาก build เพื่อให้เรียกได้สองครั้งตอนเทียบสองจอ
  Widget _erTabBody(BuildContext context, int tab) {
    if (tab == 1) {
      return Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: wrapWithModel(
          model: _model.infoPatientERViewModel,
          updateCallback: () => safeSetState(() {}),
          child: InfoPatientERViewWidget(),
        ),
      );
    } else if (tab == 2) {
      return wrapWithModel(
        model: _model.eMRErViewModel,
        updateCallback: () => safeSetState(() {}),
        child: EMRErViewWidget(),
      );
    } else if (tab == 3) {
      return wrapWithModel(
        model: _model.patientScreeningViewModel,
        updateCallback: () => safeSetState(() {}),
        child: PatientScreeningViewWidget(),
      );
    } else if (tab == 4) {
      return wrapWithModel(
        model: _model.physicalExaminationViewModel,
        updateCallback: () => safeSetState(() {}),
        child: PhysicalExaminationViewWidget(),
      );
    } else if (tab == 5) {
      return wrapWithModel(
        model: _model.nursingActivitiesViewModel,
        updateCallback: () => safeSetState(() {}),
        child: NursingActivitiesViewWidget(),
      );
    } else if (tab == 6) {
      return wrapWithModel(
        model: _model.accidentViewModel,
        updateCallback: () => safeSetState(() {}),
        child: AccidentViewWidget(),
      );
    } else if (tab == 7) {
      return wrapWithModel(
        model: _model.observeViewModel,
        updateCallback: () => safeSetState(() {}),
        child: ObserveViewWidget(),
      );
    } else if (tab == 8) {
      return wrapWithModel(
        model: _model.treatmentERViewModel,
        updateCallback: () => safeSetState(() {}),
        child: TreatmentERViewWidget(),
      );
    } else if (tab == 9) {
      return wrapWithModel(
        model: _model.labXrayViewModel,
        updateCallback: () => safeSetState(() {}),
        child: LabXrayViewWidget(),
      );
    } else if (tab == 10) {
      return wrapWithModel(
        model: _model.diagERViewModel,
        updateCallback: () => safeSetState(() {}),
        child: DiagERViewWidget(),
      );
    } else if (tab == 11) {
      return wrapWithModel(
        model: _model.drugSreviceERViewModel,
        updateCallback: () => safeSetState(() {}),
        child: DrugSreviceERViewWidget(),
      );
    } else if (tab == 12) {
      return wrapWithModel(
        model: _model.appiontmentViewModel,
        updateCallback: () => safeSetState(() {}),
        child: AppiontmentViewWidget(),
      );
    } else if (tab == 13) {
      return wrapWithModel(
        model: _model.medicalcertificateViewModel,
        updateCallback: () => safeSetState(() {}),
        child: MedicalcertificateViewWidget(),
      );
    } else if (tab == 14) {
      return Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              valueOrDefault<double>(
                () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 12.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 16.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 16.0;
                  } else {
                    return 16.0;
                  }
                }(),
                0.0,
              ),
              0.0,
              valueOrDefault<double>(
                () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 12.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 16.0;
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
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              0,
              () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 12.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 16.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 16.0;
                } else {
                  return 16.0;
                }
              }(),
              0,
              0,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5997F4),
                      FlutterFlowTheme.of(context).primary
                    ],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(valueOrDefault<double>(
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
                  )),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/ChatGPT_Image_11_.._2568_12_02_02.png',
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 40.0;
                                    } else {
                                      return 40.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 40.0;
                                    } else {
                                      return 40.0;
                                    }
                                  }(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                'สรุปการรักษา Fast Track',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                      Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: Color(0x33FFFFFF),
                      ),
                      Text(
                        'โรงพยาบาลทดสอบ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 2.0, 12.0, 2.0),
                              child: Text(
                                'HN : 12345678',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
                                    ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 2.0, 12.0, 2.0),
                              child: Text(
                                'ประเภท : Trauma',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_28_.._2568_08_44_08.png',
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              valueOrDefault<double>(
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                          child: Text(
                            'ข้อมูลผู้ป่วย',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyLargeFamily,
                                  color: Color(0xFF245EBD),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyLargeIsCustom,
                                ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0x0B2397FF),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }(),
                                  0.0,
                                )),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 3;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 3;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 4;
                                          } else {
                                            return 4;
                                          }
                                        }(),
                                      ),
                                      crossAxisSpacing: 12.0,
                                      mainAxisSpacing: 12.0,
                                      itemCount: 3,
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return [
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'เพศ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                  Text(
                                                    'ชาย',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'อายุ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                  Text(
                                                    '52 ปี',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'รหัสผู้ป่วย',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                  Text(
                                                    '12345678',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                        ][index]();
                                      },
                                    ),
                                    StyledDivider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      lineStyle: DividerLineStyle.dashed,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'โรคประจำตัว',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                        Text(
                                          'ไม่มี',
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(valueOrDefault<double>(
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
                  )),
                  child: Container(
                    width: double.infinity,
                    color: Color(0x00000000),
                    child: ExpandableNotifier(
                      controller: _model.expandableExpandableController,
                      child: ExpandablePanel(
                        header: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 16.0,
                                ),
                                Text(
                                  'แพ้ยา',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                            wrapWithModel(
                              model: _model.iconButtonTertiaryModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonTertiaryWidget(
                                iconbuttontertiary: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 14.0,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                            ),
                          ],
                        ),
                        collapsed: Container(),
                        expanded: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            wrapWithModel(
                              model: _model.itemDrugallergyModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemDrugallergyWidget(
                                num: '1',
                                drug: 'Penicillin',
                                reaction:
                                    'ผื่นลมพิษ (Urticaria), คัน, หายใจลำบาก, หน้าและคอบวม (Angioedema), ช็อก (Anaphylaxis)',
                                colorbg1: Color(0x0BBE1E2D),
                                colorbg2: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                colorborder: Color(0x0BBE1E2D),
                              ),
                            ),
                          ]
                              .divide(SizedBox(height: 8.0))
                              .addToStart(SizedBox(height: 8.0)),
                        ),
                        theme: ExpandableThemeData(
                          tapHeaderToExpand: true,
                          tapBodyToExpand: false,
                          tapBodyToCollapse: false,
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                          hasIcon: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_27_.._2568_13_36_56.png',
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              valueOrDefault<double>(
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                          child: Text(
                            'สัญญาณชีพ',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyLargeFamily,
                                  color: Color(0xFF245EBD),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyLargeIsCustom,
                                ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0x0B2397FF),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }(),
                                  0.0,
                                )),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MasonryGridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 2;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 2;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 4;
                                          } else {
                                            return 4;
                                          }
                                        }(),
                                      ),
                                      crossAxisSpacing: 12.0,
                                      mainAxisSpacing: 12.0,
                                      itemCount: 4,
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return [
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF8BBAFF),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/thermometer.png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'อุณหภูมิ',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  RichText(
                                                    textScaler:
                                                        MediaQuery.of(context)
                                                            .textScaler,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '37.2',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text: '   ํC',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 10.0,
                                                          ),
                                                        )
                                                      ],
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF8BBAFF),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/blood-pressure_(1).png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'ความดัน',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  RichText(
                                                    textScaler:
                                                        MediaQuery.of(context)
                                                            .textScaler,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '120/78',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text: '  kg.',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 10.0,
                                                          ),
                                                        )
                                                      ],
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF8BBAFF),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/pulse-rate.png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'อัตราการเต้นชีพจร',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  RichText(
                                                    textScaler:
                                                        MediaQuery.of(context)
                                                            .textScaler,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '82',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text: '  rpm',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 10.0,
                                                          ),
                                                        )
                                                      ],
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF8BBAFF),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/lungs_(1).png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'อัตราการหายใจ',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  RichText(
                                                    textScaler:
                                                        MediaQuery.of(context)
                                                            .textScaler,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '\t18',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text: '  bpm',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 10.0,
                                                          ),
                                                        )
                                                      ],
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                        ][index]();
                                      },
                                    ),
                                    StyledDivider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      lineStyle: DividerLineStyle.dashed,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 20.0,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FlutterFlowTheme.of(context)
                                                        .customColor7,
                                                    FlutterFlowTheme.of(context)
                                                        .customColor8
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.waveSquare,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 8.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'GCS',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                        RichText(
                                          textScaler:
                                              MediaQuery.of(context).textScaler,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'E3 ',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                              TextSpan(
                                                text: 'V2 ',
                                                style: TextStyle(),
                                              ),
                                              TextSpan(
                                                text: 'M6 ',
                                                style: TextStyle(),
                                              )
                                            ],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_2_.._2568_10_54_59.png',
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              valueOrDefault<double>(
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                          child: Text(
                            'การวินิจฉัย',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyLargeFamily,
                                  color: Color(0xFF245EBD),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyLargeIsCustom,
                                ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0x0B2397FF),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0,
                                sigmaY: 5.0,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }(),
                                  0.0,
                                )),
                                child: Text(
                                  'Penetrating abdomen',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_2_.._2568_11_05_00.png',
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(valueOrDefault<double>(
                        () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 12.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 16.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 16.0;
                          } else {
                            return 16.0;
                          }
                        }(),
                        0.0,
                      )),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ไทม์ไลน์การรักษา',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: Color(0xFF245EBD),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          Stack(
                            children: [
                              Container(
                                width: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 590.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 590.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 670.0;
                                        } else {
                                          return 670.0;
                                        }
                                      }(),
                                      child: StyledVerticalDivider(
                                        width: 1.0,
                                        thickness: 1.0,
                                        indent: 24.0,
                                        endIndent: 24.0,
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        lineStyle: DividerLineStyle.dashed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons
                                                              .medical_services_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Triage',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFF75AFFF),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons.flash_on,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Activate Trauma Fast Track',
                                                          maxLines: 1,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                    Wrap(
                                                      spacing: 12.0,
                                                      runSpacing: 8.0,
                                                      alignment:
                                                          WrapAlignment.start,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .start,
                                                      direction:
                                                          Axis.horizontal,
                                                      runAlignment:
                                                          WrapAlignment.start,
                                                      verticalDirection:
                                                          VerticalDirection
                                                              .down,
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_month_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 14.0,
                                                            ),
                                                            Text(
                                                              '2 ก.ย. 2568',
                                                              maxLines: 1,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelSmallFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .labelSmallIsCustom,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.access_time,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 14.0,
                                                            ),
                                                            Text(
                                                              '20 นาที',
                                                              maxLines: 1,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelSmallFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .labelSmallIsCustom,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.groups_sharp,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Trauma Team Arrival',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons
                                                              .water_drop_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'MTP',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.output_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'ER Out',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons
                                                              .content_cut_sharp,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'OR',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.timer_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Door ER to Door OR',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons
                                                              .water_drop_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '1st Blood Transfusion',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0x0B2397FF),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            border: Border.all(
                                              color: Color(0x0B2397FF),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5.0,
                                                sigmaY: 5.0,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 16.0;
                                                    } else {
                                                      return 16.0;
                                                    }
                                                  }(),
                                                  0.0,
                                                )),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF75AFFF),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.chat_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Trauma Team Consult',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ],
                          ),
                        ].divide(SizedBox(height: 12.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 16.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }())),
          ),
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [],
      );
    }
  }

  /// หัวแถบของแต่ละฝั่งในโหมดเทียบ บอกว่าฝั่งนี้คือหน้าจออะไร
  Widget _erPaneHeader(BuildContext context, int tab,
      {required bool closable}) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(bottom: BorderSide(color: theme.alternate, width: 1.0)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(14.0, 6.0, 6.0, 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              _erTabName(tab),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.labelMedium,
            ),
          ),
          if (!closable && _model.compareTabER == null)
            PopupMenuButton<int>(
              tooltip: 'เปิดอีกหน้าจอมาเทียบข้าง ๆ',
              position: PopupMenuPosition.under,
              onSelected: (value) =>
                  safeSetState(() => _model.compareTabER = value),
              itemBuilder: (context) => [
                for (int t = 1; t <= _erTabNames.length; t++)
                  if (t != FFAppState().TabMenuPatientInfoER)
                    PopupMenuItem<int>(value: t, child: Text(_erTabName(t))),
              ],
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.vertical_split_rounded,
                        size: 16.0, color: theme.primary),
                    Text(
                      'เทียบ',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.primary,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ].divide(SizedBox(width: 4.0)),
                ),
              ),
            ),
          if (closable) ...[
            PopupMenuButton<int>(
              tooltip: 'เปลี่ยนหน้าจอที่เทียบ',
              icon: Icon(Icons.swap_horiz_rounded,
                  size: 18.0, color: theme.secondaryText),
              onSelected: (value) =>
                  safeSetState(() => _model.compareTabER = value),
              itemBuilder: (context) => [
                for (int t = 1; t <= _erTabNames.length; t++)
                  if (t != FFAppState().TabMenuPatientInfoER)
                    PopupMenuItem<int>(value: t, child: Text(_erTabName(t))),
              ],
            ),
            IconButton(
              tooltip: 'ปิดการเทียบ',
              iconSize: 18.0,
              icon: Icon(Icons.close_rounded, color: theme.secondaryText),
              onPressed: () => safeSetState(() => _model.compareTabER = null),
            ),
          ],
        ],
      ),
    );
  }

  /// หนึ่งฝั่งของจอเทียบ = หัวแถบ + เนื้อหาแท็บ
  Widget _erPane(
    BuildContext context,
    int tab, {
    required bool closable,
    required ScrollController controller,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _erPaneHeader(context, tab, closable: closable),
        Expanded(
          // ลูกที่เลื่อนได้ข้างในจะไปเกาะ controller ตัวนี้แทนตัวกลางของทั้งหน้า
          // ทำให้สองฝั่งเลื่อนแยกกัน และหัวจอไม่ขยับตามตอนอ่านฝั่งใดฝั่งหนึ่ง
          child: PrimaryScrollController(
            controller: controller,
            child: Scrollbar(
              controller: controller,
              thumbVisibility: false,
              child: _erTabBody(context, tab),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).accent2,
              automaticallyImplyLeading: false,
              // จอกว้างย้ายประวัติผู้ป่วยไปไว้เป็นแผงตั้งด้านซ้าย หัวจอจึงเหลือแค่ชื่อ
              title: MediaQuery.sizeOf(context).width >= _erSplitMinWidth
                  ? Text(
                      'นายทดสอบ ทดสอบ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleSmallFamily,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 56.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 56.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 60.0;
                                } else {
                                  return 60.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 56.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 56.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 60.0;
                                } else {
                                  return 60.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).secondary,
                                    FlutterFlowTheme.of(context).accent2
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0x33FFFFFF),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: 'er',
                                    transitionOnUserGestures: true,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: Image.asset(
                                        'assets/images/ChatGPT_Image_20_.._2568_16_00_35.png',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(1.0, 1.0),
                                    child: Container(
                                      width: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 20.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 20.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 24.0;
                                        } else {
                                          return 24.0;
                                        }
                                      }(),
                                      height: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 20.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 20.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
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
                                          colors: [
                                            Color(0xFF62B3FF),
                                            Color(0xFF2397FF)
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.mars,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 14.0;
                                            } else {
                                              return 14.0;
                                            }
                                          }(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animateOnPageLoad(
                                animationsMap['containerOnPageLoadAnimation']!),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'นายทดสอบ ทดสอบ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 14.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 14.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 18.0;
                                              } else {
                                                return 18.0;
                                              }
                                            }(),
                                            letterSpacing: 0.2,
                                            fontWeight: FontWeight.w500,
                                            shadows: [
                                              Shadow(
                                                color: Color(0x6757636C),
                                                offset: Offset(0.0, 0.0),
                                                blurRadius: 4.0,
                                              )
                                            ],
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ).animateOnPageLoad(animationsMap[
                                        'textOnPageLoadAnimation']!),
                                  ].divide(SizedBox(width: 12.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.56, -1.0),
                                          end: AlignmentDirectional(-0.56, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 2.0, 12.0, 2.0),
                                        child: Text(
                                          'Q 1',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 14.0;
                                                  } else {
                                                    return 14.0;
                                                  }
                                                }(),
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.waitingforScreeningModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: WaitingforScreeningWidget(),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0x1914181B),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 2.0, 12.0, 2.0),
                                        child: Text(
                                          'HN 0000001',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontSize: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 14.0;
                                                  } else {
                                                    return 14.0;
                                                  }
                                                }(),
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .customColor19,
                                            FlutterFlowTheme.of(context)
                                                .customColor20
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.56, -1.0),
                                          end: AlignmentDirectional(-0.56, 1.0),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 2.0, 12.0, 2.0),
                                        child: Text(
                                          'อายุ 52 ปี',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontSize: () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 10.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointLarge) {
                                                    return 14.0;
                                                  } else {
                                                    return 14.0;
                                                  }
                                                }(),
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ).animateOnPageLoad(
                                    animationsMap['rowOnPageLoadAnimation']!),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ].divide(SizedBox(width: 12.0)),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
              actions: [
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.safePop();
                      },
                      child: wrapWithModel(
                        model: _model.iconButtonTertiaryModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: IconButtonTertiaryWidget(
                          iconbuttontertiary: Icon(
                            Icons.close_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 16.0,
                          ),
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, -1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_30_.._2568_11_49_46.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: Alignment(1.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(56.0),
                child: Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Stack(
                    children: [
                      if (FFAppState().filtermenuER == 'All')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation1'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered1 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation1']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation1']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered1),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation2'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered2 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation2']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation2']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered2),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 3;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation3'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered3 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation3']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'คัดกรอง',
                                      icon: Icon(
                                        Icons.person_search,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 3
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 16.0,
                                      ),
                                      tabMenuPatientInfoER: 3,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation3']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered3),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 4;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation4'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered4 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation4']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ตรวจร่างกาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userMd,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 4
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 4,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation4']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered4),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 5;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation5'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered5 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation5']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'กิจกรรมพยาบาล',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userNurse,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 5
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 5,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation5']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered5),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 6;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation6'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered6 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation6']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel6,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'อุบัติเหตุ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userInjured,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 6
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 6,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation6']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered6),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 7;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation7'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered7 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation7']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel7,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สังเกตอาการ',
                                      icon: Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 7
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 7,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation7']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered7),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 8;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation8'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered8 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation8']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel8,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'หัตถการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.syringe,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 8
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 8,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation8']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered8),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation9'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered9 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation9']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel9,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation9']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered9),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 10;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation10'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered10 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation10']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel10,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'การวินิจฉัย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileContract,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  10
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 10,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation10']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered10),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation11'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered11 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation11']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel11,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation11']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered11),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 12;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation12'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered12 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation12']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel12,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'นัดหมาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.calendarDay,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  12
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 12,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation12']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered12),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 13;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation13'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered13 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation13']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel13,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ใบรับรองแพทย์',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedical,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  13
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 13,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation13']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered13),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 14;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation14'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered14 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation14']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel14,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สรุปการรักษา',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  14
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 14,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation14']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered14),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())),
                            ),
                          ),
                        ),
                      if (FFAppState().filtermenuER == 'Doctor')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation15'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered15 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation15']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel15,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation15']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered15),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation16'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered16 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation16']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel16,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation16']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered16),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 4;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation17'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered17 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation17']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel17,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ตรวจร่างกาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userMd,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 4
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 4,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation17']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered17),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation18'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered18 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation18']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel18,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation18']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered18),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 10;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation19'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered19 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation19']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel19,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'การวินิจฉัย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileContract,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  10
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 10,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation19']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered19),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation20'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered20 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation20']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel20,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation20']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered20),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 13;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation21'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered21 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation21']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel21,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ใบรับรองแพทย์',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedical,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  13
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 13,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation21']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered21),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())),
                            ),
                          ),
                        ),
                      if (FFAppState().filtermenuER == 'Nurse')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation22'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered22 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation22']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel22,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation22']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered22),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation23'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered23 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation23']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel23,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation23']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered23),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 3;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation24'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered24 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation24']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel24,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'คัดกรอง',
                                      icon: Icon(
                                        Icons.person_search,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 3
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 16.0,
                                      ),
                                      tabMenuPatientInfoER: 3,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation24']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered24),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 5;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation25'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered25 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation25']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel25,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'กิจกรรมพยาบาล',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userNurse,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 5
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 5,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation25']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered25),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 6;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation26'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered26 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation26']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel26,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'อุบัติเหตุ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userInjured,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 6
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 6,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation26']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered26),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 7;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation27'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered27 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation27']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel27,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สังเกตอาการ',
                                      icon: Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 7
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 7,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation27']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered27),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 8;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation28'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered28 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation28']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel28,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'หัตถการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.syringe,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 8
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 8,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation28']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered28),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation29'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered29 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation29']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel29,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation29']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered29),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation30'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered30 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation30']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel30,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation30']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered30),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 12;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation31'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered31 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation31']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel31,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'นัดหมาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.calendarDay,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  12
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 12,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation31']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered31),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              }())),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              toolbarHeight: 74.0,
              elevation: 0.0,
            )
          ],
          body: Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    0.0,
                    valueOrDefault<double>(
                      () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
                          return 0.0;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointMedium) {
                          return 0.0;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointLarge) {
                          return 8.0;
                        } else {
                          return 8.0;
                        }
                      }(),
                      0.0,
                    ),
                    0.0,
                    0.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xCC3E83E6),
                        FlutterFlowTheme.of(context).primaryBackground,
                        FlutterFlowTheme.of(context).primaryBackground
                      ],
                      stops: [0.0, 0.34, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final int leftTab = FFAppState().TabMenuPatientInfoER;
                        final int? rightTab = _model.compareTabER;
                        // ไทม์ไลน์แยกออกมาเป็นแผงขวาได้ต่อเมื่อเหลือที่ให้เนื้อหาตรงกลางพอ
                        final bool showTimeline = box.maxWidth >=
                            (rightTab == null || rightTab == leftTab
                                ? _erTimelineMinWidth
                                : _erTimelineWithCompareMinWidth);
                        // แคบกว่านี้แบ่งสองฝั่งแล้วอ่านไม่ออก ให้กลับไปจอเดียว
                        if (box.maxWidth < _erSplitMinWidth) {
                          return _erTabBody(context, leftTab);
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _erProfileRail(context,
                                withTimeline: !showTimeline),
                            Expanded(
                              child: _erPane(context, leftTab,
                                  closable: false, controller: _erLeftScroll),
                            ),
                            if (rightTab != null && rightTab != leftTab) ...[
                              VerticalDivider(
                                width: 1.0,
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              Expanded(
                                child: _erPane(context, rightTab,
                                    closable: true, controller: _erRightScroll),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
