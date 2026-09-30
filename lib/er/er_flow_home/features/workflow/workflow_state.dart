// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowWorkflowStateState on State<ErFlowHomeWidget> {
  /// ท่า Dr.Note จาก debugger (null = ค่าตั้งต้น) · เปิด debugger อยู่ไหม
  (double, double, double, double)? _drPose;
  bool _drPoseOpen = false;

  /// การ์ดที่กำลังนำเสนอในสำรับเหนือวงล้อ
  int _uiIdx = 0;

  /// หน้าที่เปิดอยู่ของ flipbook ฟอร์ม (ทีละช่อง)
  int _formAt = 0;

  /// ขั้นที่เด้งไปหน้าสรุปยืนยันแล้ว (ครบทุกช่อง) กันเด้งซ้ำ
  int _reviewShown = -1;

  /// ขั้นที่ผู้ใช้สั่งข้าม (เสียง "ข้าม"/"ขั้นต่อไป") → หน้าตรวจสอบยอมให้ไปต่อแม้ยังไม่ครบ
  int _skipAsked = -1;
  bool _formFwd = true;

  /// HPI แบบเล่าเอง (ค่าเริ่ม: เปิดมาเป็นฟอร์มเปล่า) · แตะชิป template แล้วเป็นโหมด template
  bool _hpiManual = true;
  bool _hpiApplying = false;

  /// ช่องพิมพ์ในฟอร์ม (พิมพ์ในช่องได้เลย ไม่เปิด dialog): 'ขั้น|ชื่อช่อง' → controller / focus
  final Map<String, TextEditingController> _inlineCtl = {};
  final Map<String, FocusNode> _inlineFocus = {};

  // ---- โหมดพูดเพื่อบันทึก (Figma 186:68)
  bool _speechOpen = false;
  int _speechStep = 0;

  /// ฟอร์มอุบัติเหตุที่เปิดอยู่ใน workflow panel (null = แสดงขั้นตามปกติ)
  /// เก็บ widget ตัวเดิมไว้ สถานะในฟอร์มจึงอยู่ครบระหว่าง rebuild
  Widget? _accPane;
  void Function(bool save, [bool notify])? _accPaneClose;

  /// ค่าที่ AI จับได้ของแต่ละขั้น ชื่อช่อง → ข้อความ
  final List<Map<String, String>> _filled =
      List.generate(8, (_) => <String, String>{});

  /// ข้อความที่ถอดเสียงได้ของแต่ละขั้น (สะสม)
  final List<String> _transcripts = List.filled(8, '');

  /// ประโยคที่พูดของแต่ละขั้น แยกเป็นรายประโยค (แก้/ลบย้อนหลังได้)
  /// ทุกครั้งที่พูดเพิ่มหรือแก้ประโยคเก่า ผู้ช่วยตีความ "ทั้งหมด" ใหม่
  /// ประโยคหลังที่แก้ประโยคก่อน ("ไม่ใช่ 2 วัน เป็น 3 วัน") จะไปแก้ค่าในช่องเดิม
  final List<List<String>> _utter = List.generate(8, (_) => <String>[]);

  /// ช่องที่ผู้ช่วยเพิ่งลง/แก้ในรอบล่าสุด ไว้ไฮไลต์ให้เห็นว่าเปลี่ยนตรงไหน
  Set<String> _glow = const {};

  /// ประโยคล่าสุดที่หุ่นพูด
  String _agentSay = '';

  /// สถานะงานเบื้องหลัง เช่น กำลังถอดเสียง / กำลังคิด (ว่าง = ไม่มี)
  String _agentStatus = '';
  bool _agentBusy = false;

  /// ตัวเลือกที่ผู้ช่วยสร้างให้กด (generative UI): ช่อง + รายการตัวเลือก
  (String, List<String>)? _agentChoices;

  /// ช่องที่เพิ่งลงในรอบล่าสุด ไว้ "ยกเลิกอันล่าสุด"
  List<(int, String, String?)> _lastFilled = const [];
}
