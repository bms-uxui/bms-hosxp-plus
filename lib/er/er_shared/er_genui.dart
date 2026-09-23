/// Generative UI ของผู้ช่วย ER: ผู้ช่วยตอบเป็น "บล็อก UI" (JSON) แทนข้อความล้วน
///
/// แนวเดียวกับโปรโตคอล A2UI — agent ส่งคำอธิบาย UI แบบ declarative
/// แอปวาดด้วย widget ในแค็ตตาล็อกที่เตรียมไว้เท่านั้น (ชนิดที่ไม่รู้จักถูกข้าม)
///
/// หลักสำคัญ: บล็อกที่แสดงตัวเลขของผู้ป่วย (vitals, labs, imaging) รับแค่ "ชื่อ"
/// ค่าจริงแอปดึงจากแฟ้มเคสเอง ผู้ช่วยจึงแต่งตัวเลขขึ้นมาไม่ได้
library;

/// ชนิดบล็อกในแค็ตตาล็อก
enum ErUiType {
  brief,
  vitals,
  labs,
  imaging,
  alert,
  form,
  orderSet,
  checklist,
  timer,
  nextStep,
}

const Map<String, ErUiType> _byName = {
  'brief': ErUiType.brief,
  'vitals': ErUiType.vitals,
  'labs': ErUiType.labs,
  'imaging': ErUiType.imaging,
  'alert': ErUiType.alert,
  'form': ErUiType.form,
  'order_set': ErUiType.orderSet,
  'checklist': ErUiType.checklist,
  'timer': ErUiType.timer,
  'next_step': ErUiType.nextStep,
};

/// บล็อก UI หนึ่งชิ้น: ชนิด + ข้อมูลดิบจาก JSON (แต่ละชนิดอ่านคีย์ของตัวเอง)
class ErUiBlock {
  const ErUiBlock(this.type, this.data, {this.source = 'agent'});

  final ErUiType type;
  final Map<String, dynamic> data;

  /// 'agent' = ผู้ช่วยสร้าง · 'guide' = บล็อกตั้งต้นของขั้น (แอปสร้างเอง)
  final String source;

  String str(String k, [String d = '']) {
    final v = data[k];
    return v is String ? v.trim() : d;
  }

  List<String> strs(String k) => [
        for (final v in (data[k] is List ? data[k] as List : const []))
          if (v is String && v.trim().isNotEmpty) v.trim(),
      ];

  List<Map<String, dynamic>> maps(String k) => [
        for (final v in (data[k] is List ? data[k] as List : const []))
          if (v is Map) v.cast<String, dynamic>(),
      ];

  /// คีย์ไว้กันบล็อกซ้ำ (ชนิดเดียวกัน หัวข้อเดียวกัน)
  String get key => '${type.name}|${str('title')}';
}

/// อ่านรายการบล็อกจากคำตอบผู้ช่วย ข้ามชนิดที่ไม่อยู่ในแค็ตตาล็อก
List<ErUiBlock> erParseUi(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final b in raw)
      if (b is Map && _byName[b['type']] != null)
        ErUiBlock(_byName[b['type']]!, b.cast<String, dynamic>()),
  ].take(5).toList();
}

/// รวมบล็อกของผู้ช่วยกับบล็อกตั้งต้นของขั้น: ของผู้ช่วยขึ้นก่อน
/// บล็อกตั้งต้นชนิดเดียวกันที่ผู้ช่วยส่งมาแล้วถูกตัดออก (ไม่ซ้ำซ้อน)
List<ErUiBlock> erMergeUi(List<ErUiBlock> agent, List<ErUiBlock> guide) {
  final have = {for (final b in agent) b.type};
  return [
    ...agent,
    for (final b in guide)
      if (!have.contains(b.type)) b,
  ];
}

/// คำอธิบายแค็ตตาล็อกสำหรับ system prompt
const String erUiCatalogPrompt = '''
UI ที่แสดงให้แพทย์เห็น (generative UI) ใส่ในคีย์ "ui" เป็นอาร์เรย์ 0-3 บล็อก
เลือกเฉพาะที่ช่วยให้ตัดสินใจขั้นนี้ได้ทันทีโดยไม่ต้องสลับหน้าจอ ชนิดที่ใช้ได้:
- {"type":"brief","title":"...","points":["...", "..."]}  สรุปสั้น 2-4 ข้อ
- {"type":"vitals","keys":["hr","bp","spo2","rr","bt","gcs"],"note":"..."}  ระบบดึงค่าจริงเอง ห้ามใส่ตัวเลข
- {"type":"labs","names":["Lactate","Cr"],"note":"..."}  ชื่อแล็บตามข้อมูลเคส ระบบดึงค่าเอง
- {"type":"imaging","names":["CT brain"]}  ชื่อภาพถ่ายตามข้อมูลเคส
- {"type":"alert","level":"critical|warn|info","title":"...","text":"..."}  เตือนสิ่งอันตราย เช่น แพ้ยา ค่าวิกฤต
- {"type":"form","title":"...","fields":["<ชื่อช่องในฟอร์มขั้นนี้>", ...]}  การ์ดช่องที่ควรกรอกต่อ
- {"type":"order_set","title":"...","groups":[{"field":"ยา/เวชภัณฑ์|Lab|X-ray|หัตถการ","items":["...", "..."]}]}
    ชุดคำสั่งแนะนำ ชื่อรายการต้องมาจาก template ในฟอร์ม HOSxP ด้านบน แพทย์ติ๊กแล้วกดยืนยัน
- {"type":"checklist","title":"...","items":["...", "..."]}  bundle/ขั้นตอนมาตรฐานที่ต้องทำ
- {"type":"timer","label":"...","since":"HH:MM","target_min":60}  นับเวลาเป้าหมาย เช่น door-to-needle
- {"type":"next_step","title":"...","detail":"...","action":"confirm_step|summary"}  ปุ่มพาไปขั้นต่อไป
ข้อความใน ui เขียนแบบย่อทางการแพทย์ได้ (ไม่ถูกอ่านออกเสียง) ห้ามแต่งตัวเลขของผู้ป่วย
''';
