/// หน้าแรกของโมดูล ER — ภาพรวมกระแสงานทั้งห้องเป็นแท่น isometric สี่ขั้น
///
/// อ่านได้ในแวบเดียวว่าตอนนี้คนค้างอยู่ขั้นไหนกี่คน และขั้นไหนเป็นคอขวด
/// แตะที่แท่นเพื่อกางรายชื่อของขั้นนั้นโดยไม่ต้องออกจากหน้า
///
/// ข้อมูลในไฟล์นี้ยังเป็นข้อมูลจำลองทั้งหมด รอต่อกับฐานข้อมูลจริงของ HOSxP
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../er_bed_view/er_room_3d.dart';
import '../er_shared/er_ai.dart';
import '../er_login/er_login_widget.dart';
import '../er_shared/er_aura.dart';
import '../er_shared/er_body_map.dart';
import 'er_detail_tables.dart';
import '../er_shared/er_case_tables.dart';
import '../er_shared/er_cases.dart';
import '../er_shared/er_session.dart';
import '../er_shared/er_form_kb.dart';
import '../er_shared/er_genui.dart';
import '../er_shared/er_master.dart';
import '../er_shared/er_notify.dart';
import '../er_shared/er_pe_templates.dart';
import '../er_shared/er_vitals.dart';

part 'core/theme.dart';
part 'core/models.dart';
part 'features/alerts/alerts.dart';
part 'tabs/left_panel.dart';
part 'tabs/phase/phase_tab.dart';
part 'sidebar/pinned.dart';
part 'tabs/phase/recent.dart';
part 'tabs/overview/overview_scene.dart';
part 'features/patient/timeline.dart';
part 'features/assistant/chat.dart';
part 'features/workflow/workflow_panel.dart';
part 'features/workflow/workflow_state.dart';
part 'features/workflow/workflow_blocks.dart';
part 'features/patient/side_board.dart';
part 'features/patient/exam_tab.dart';
part 'features/patient/orders_tab.dart';
part 'features/speech/speech.dart';
part 'features/speech/agent.dart';
part 'features/workflow/form_fields.dart';
part 'features/patient/ai_summary.dart';
part 'features/patient/patient_page.dart';
part 'features/patient/body_scene.dart';
part 'tabs/overview/urgent_strip.dart';
part 'sidebar/sidebar.dart';
part 'tabs/overview/overview_tab.dart';
part 'features/patient/form_kb_tab.dart';
part 'features/patient/patient_header.dart';
part 'features/patient/table_view.dart';
part 'features/patient/overview_panel.dart';
part 'features/workflow/workflow_rail.dart';
part 'features/alerts/reminders.dart';
part 'features/patient/follow_tasks.dart';
part 'features/workflow/disposition.dart';
part 'features/workflow/hpi.dart';
part 'features/workflow/pe_templates.dart';
part 'features/workflow/icd9.dart';
part 'features/workflow/esi_assist.dart';
part 'features/workflow/step_intro.dart';
part 'core/skeleton.dart';
part 'tabs/phase/observe.dart';
part 'tabs/phase/patient_list.dart';
part 'core/widgets.dart';
part 'core/mock_data.dart';

class ErFlowHomeWidget extends StatefulWidget {
  const ErFlowHomeWidget({super.key});

  static const String routeName = 'Er_Flow_Home';
  static const String routePath = 'erFlowHome';

  @override
  State<ErFlowHomeWidget> createState() => _ErFlowHomeWidgetState();
}

class _ErFlowHomeWidgetState extends State<ErFlowHomeWidget>
    with
        _FeaturesAlertsAlertsState,
        _TabsLeftPanelState,
        _TabsPhasePhaseTabState,
        _SidebarPinnedState,
        _TabsPhaseRecentState,
        _TabsOverviewOverviewSceneState,
        _FeaturesPatientTimelineState,
        _FeaturesAssistantChatState,
        _FeaturesWorkflowWorkflowPanelState,
        _FeaturesWorkflowWorkflowStateState,
        _FeaturesWorkflowWorkflowBlocksState,
        _FeaturesPatientSideBoardState,
        _FeaturesPatientExamTabState,
        _FeaturesPatientOrdersTabState,
        _FeaturesSpeechSpeechState,
        _FeaturesSpeechAgentState,
        _FeaturesPatientAiSummaryState,
        _FeaturesPatientPatientPageState,
        _FeaturesPatientBodySceneState,
        _TabsOverviewUrgentStripState,
        _FeaturesPatientFormKbTabState,
        _FeaturesPatientOverviewPanelState,
        _FeaturesWorkflowWorkflowRailState,
        _FeaturesAlertsRemindersState,
        _FeaturesPatientFollowTasksState,
        _FeaturesWorkflowPeTemplatesState {
  /// ช่วงงานที่กางรายชื่ออยู่ ถ้าเป็น null คือดูภาพรวมทั้งห้อง
  _Phase? _open;

  /// HN ของผู้ป่วยที่เลือกอยู่ในฉากสามมิติ null = ใช้คนแรกของช่วงงาน
  String? _sceneHn;

  /// โหมดข้อมูลผู้ป่วย: กล้องเลื่อนไปมองเตียงจากบน แผงซ้ายเป็นกราฟ
  /// ฝั่งขวามีรายการข้อมูลกับเส้นเวลา (Figma node 58-697)
  bool _detail = false;

  /// แท็บที่เลือกในแถบบนของหน้ารายละเอียด (ยังเป็นภาพนิ่ง ยกเว้น "ภาพรวม")
  int _detailTab = 0;

  /// แท็บภาพรวม/ตรวจร่างกาย/คำสั่งแพทย์: true = ดูเป็นตาราง
  bool _tableView = false;

  /// จุดอาการที่กำลังเพ่ง แตะที่จุดเพื่อสลับ null = ยังไม่ได้เลือก
  String? _focusSpot;

  /// กำลังโหลดข้อมูลของหน้า/ช่วงงานที่เลือกอยู่ → โชว์ skeleton แทนเนื้อหา
  /// ยังไม่มี API จริง จึงจำลองหน่วงเวลา: เปิดหน้าครั้งแรก 900ms สลับช่วงงาน 500ms
  bool _loading = true;
  int _loadSeq = 0;

  void _simulateLoad(Duration d) {
    final seq = ++_loadSeq;
    setState(() => _loading = true);
    Future.delayed(d, () {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _loading = false);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _simulateLoad(const Duration(milliseconds: 900));
    ErFormKb.load();
    _loadPeTemplates();
    _remTimer = Timer.periodic(const Duration(seconds: 1), (_) => _remCheck());
    // แจ้งเตือนระดับระบบ: แตะแล้วเปิดผู้ป่วย (หรือรายการแจ้งเตือนถ้าไม่ผูก HN)
    ErNotify.onOpen = _notifyOpen;
    ErNotify.init().then((_) {
      final hn = ErNotify.launchHn;
      ErNotify.launchHn = null;
      if (hn != null && mounted) _notifyOpen(hn);
    });
    // ตัวอย่าง: งานประเมินซ้ำหลังให้ยาที่เหลือ 4 นาที ตั้งเตือนไว้ให้แล้ว
    _reminders.add(_Reminder('670123469', 'ประเมินซ้ำหลังให้ยา 15 นาที',
        DateTime.now().add(const Duration(minutes: 4))));
    _loadPins();
    _loadBoard();
    ErMaster.load().then((_) {
      if (mounted) setState(() {});
    });
    ErSession.instance.addListener(_onSession);
    // ยังไม่ได้เลือกบทบาท → ไปหน้า login จำลองก่อน
    if (!ErSession.instance.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.goNamed(ErLoginWidget.routeName);
      });
    }
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (ErNotify.onOpen == _notifyOpen) ErNotify.onOpen = null;
    _remTimer?.cancel();
    _remTick.dispose();
    _micFrame.dispose();
    _peekHide();
    _footScroll.dispose();
    _chatScroll.dispose();
    _recTimer?.cancel();
    _rec.dispose();
    ErSession.instance.removeListener(_onSession);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // คีย์บอร์ดไม่ดันหน้า (dialog/bottom sheet จัดการพื้นที่เอง) กันแผงผู้ช่วยล้น
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      // หน้ารายละเอียดผู้ป่วยเป็นโครงใหม่ทั้งหน้า ไม่มีแถบซ้าย/แผงเดิม
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(
            child: _detail && _open != null
                ? _detailPage()
                : Row(
                    children: [
                      _sideBar(),
                      _leftPanel(),
                      // ฝั่งขวาเป็นฉากสามมิติเต็มพื้นที่ ชิปด้านบนเปลี่ยนทั้งฉากและแผงซ้าย
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(child: _stairScene()),
                                  // กดที่ว่างรอบ ๆ เพื่อปิดการ์ดแจ้งเตือน
                                  if (_alertsOpen)
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            setState(() => _alertsOpen = false),
                                      ),
                                    ),
                                  Positioned(
                                      right: 16.0,
                                      top: 12.0,
                                      child: _alertBell()),
                                  Positioned(
                                    right: 16.0,
                                    top: 62.0,
                                    child: _alertToasts(),
                                  ),
                                  // การ์ดแจ้งเตือนลอยทับฉาก ไม่กินความกว้างของหน้า
                                  Positioned(
                                    right: 16.0,
                                    top: 62.0,
                                    bottom: 16.0,
                                    child: IgnorePointer(
                                      ignoring: !_alertsOpen,
                                      child: AnimatedSlide(
                                        offset: _alertsOpen
                                            ? Offset.zero
                                            : const Offset(0.06, -0.04),
                                        duration:
                                            const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                        child: AnimatedOpacity(
                                          opacity: _alertsOpen ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 220),
                                          child: _alertCardOverlay(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // คำอธิบายสีมีเฉพาะโหมดภาพรวม เลือกช่วงงานแล้ว
                                  // การ์ดผู้ป่วยกินพื้นที่ตรงนั้นแทน
                                  // ตอนซูมก็ซ่อน แผงสรุปมีคำอธิบายสีของตัวเองแล้ว
                                  if (_open == null)
                                    Positioned(
                                      left: 20.0,
                                      bottom: 12.0,
                                      child: IgnorePointer(
                                        ignoring: _zoom != null,
                                        child: AnimatedOpacity(
                                          opacity: _zoom == null ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 420),
                                          curve: Curves.easeInOutCubic,
                                          child: _legend(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // แถบผู้ป่วยเร่งด่วนมีเฉพาะโหมดภาพรวม
                            // เลือกช่วงงานแล้วรายชื่ออยู่ในแผงซ้ายกับการ์ดในฉากอยู่แล้ว
                            if (_open == null) _urgentStrip(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          // หน้ารายละเอียดผู้ป่วย: ป้ายผู้ใช้บังการ์ดคอลัมน์ซ้าย ซ่อนไว้
          if (!(_detail && _open != null))
            Positioned(left: 12.0, bottom: 10.0, child: _userChip()),
          // หน้าผู้ป่วย: การแจ้งเตือนระดับแอปชุดเดียวกับหน้าภาพรวม (toast + รายการ)
          if (_detail && _open != null) ...[
            if (_alertsOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _alertsOpen = false),
                ),
              ),
            Positioned(right: 16.0, top: 64.0, child: _alertToasts()),
            Positioned(
              right: 16.0,
              top: 64.0,
              bottom: 16.0,
              child: IgnorePointer(
                ignoring: !_alertsOpen,
                child: AnimatedOpacity(
                  opacity: _alertsOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: _alertCardOverlay(),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
