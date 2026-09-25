/// ฐานความรู้ฟอร์ม ER ของ HOSxP Plus (assets/jsons/er_form_kb.json)
///
/// สกัดจากหน้า FlutterFlow ใน lib/er/** — ชื่อช่องและตัวเลือกจริงในระบบ
/// ผู้ช่วยเสียงใช้เพื่อรู้ว่าแต่ละขั้นต้องกรอกอะไร และให้ตัวเลือกตรงกับหน้าจอ
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ErFormKb {
  ErFormKb._(this.forms);

  static ErFormKb? _cached;
  static Future<ErFormKb>? _loading;

  final List<Map<String, dynamic>> forms;

  static ErFormKb? get maybe => _cached;

  static Future<ErFormKb> load() {
    if (_cached != null) return Future.value(_cached);
    return _loading ??= () async {
      final raw = await rootBundle.loadString('assets/jsons/er_form_kb.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final forms = [
        for (final f in (data['forms'] as List<dynamic>? ?? const []))
          f as Map<String, dynamic>
      ];
      return _cached = ErFormKb._(forms);
    }();
  }

  Map<String, dynamic>? form(String id) {
    for (final f in forms) {
      if (f['id'] == id) return f;
    }
    return null;
  }

  /// ข้อความสรุปฟอร์มสำหรับใส่ใน prompt: ชื่อช่อง + ตัวเลือก
  /// [sections] ว่าง = เอาทุก section, [maxOptions] กันรายการยาว
  String describe(String id,
      {List<String> sections = const [], int maxOptions = 16}) {
    final f = form(id);
    if (f == null) return '';
    final buf = StringBuffer('ฟอร์ม "${f['title']}" (${f['role']})\n');
    for (final s in (f['sections'] as List<dynamic>? ?? const [])) {
      final title = s['title'] as String? ?? '';
      if (sections.isNotEmpty && !sections.contains(title)) continue;
      buf.writeln('  [$title]');
      for (final fd in (s['fields'] as List<dynamic>? ?? const [])) {
        final label = fd['label'];
        final type = fd['type'];
        final opts = (fd['options'] as List<dynamic>?)?.cast<String>();
        final hint = fd['hint'];
        buf.write('   - $label ($type');
        if (fd['required'] == true) buf.write(', จำเป็น');
        buf.write(')');
        if (hint != null && (hint as String).isNotEmpty)
          buf.write(' หน่วย/ตัวอย่าง: $hint');
        if (opts != null && opts.isNotEmpty) {
          final show = opts.take(maxOptions).join(' | ');
          buf.write(' ตัวเลือก: $show');
          if (opts.length > maxOptions) buf.write(' | …');
        }
        buf.writeln();
      }
    }
    return buf.toString();
  }

  /// ตัวเลือกของช่องหนึ่งในฟอร์ม (หาแบบตรงชื่อ)
  List<String> options(String formId, String label) {
    final f = form(formId);
    if (f == null) return const [];
    for (final s in (f['sections'] as List<dynamic>? ?? const [])) {
      for (final fd in (s['fields'] as List<dynamic>? ?? const [])) {
        if (fd['label'] == label) {
          return (fd['options'] as List<dynamic>?)?.cast<String>() ?? const [];
        }
      }
    }
    return const [];
  }
}
