/// Template การตรวจร่างกายของแพทย์: ชุดระบบที่ตรวจบ่อยพร้อมผลตั้งต้น
///
/// แพทย์บันทึกผลตรวจครั้งปัจจุบันเป็น template ของตัวเองได้ แล้วเรียกใช้ซ้ำ
/// ทั้งแตะเองและสั่งผู้ช่วยด้วยเสียง เก็บในเครื่องแยกตามผู้ใช้ (shared_preferences)
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ErPeTemplate {
  const ErPeTemplate(this.name, this.values, {this.builtIn = false});

  factory ErPeTemplate.fromJson(Map<String, dynamic> j) => ErPeTemplate(
        j['name'] as String? ?? '',
        {
          for (final e in (j['values'] as Map? ?? const {}).entries)
            '${e.key}': '${e.value}'
        },
      );

  final String name;

  /// ชื่อช่อง (รวม "<ระบบ> - รายละเอียด") → ค่า
  final Map<String, String> values;

  /// template ตั้งต้นของระบบ ลบไม่ได้
  final bool builtIn;

  /// จำนวนระบบที่ template นี้ครอบคลุม (ไม่นับช่องรายละเอียด)
  int get systems => values.keys.where((k) => !k.contains(' - ')).length;

  Map<String, dynamic> toJson() => {'name': name, 'values': values};
}

/// template ตั้งต้นตามสาขาของแพทย์ที่มาตรวจผู้ป่วยใน ER
/// แพทย์เฉพาะทางตรวจเฉพาะระบบของสาขา ระบบนอก template บันทึกเป็น "ไม่ได้ตรวจ"
const List<ErPeTemplate> erPeBuiltIns = [
  ErPeTemplate(
      'เวชศาสตร์ฉุกเฉิน (ครบทุกระบบ)',
      {
        'GA': 'ปกติ',
        'HEENT': 'ปกติ',
        'Heart': 'ปกติ',
        'Chest': 'ปกติ',
        'Abdomen': 'ปกติ',
        'PR': 'ไม่ได้ตรวจ',
        'PV': 'ไม่ได้ตรวจ',
        'Genitalia': 'ไม่ได้ตรวจ',
        'Neurological': 'ปกติ',
        'Extremities': 'ปกติ',
      },
      builtIn: true),
  ErPeTemplate(
      'อายุรกรรม',
      {
        'GA': 'ปกติ',
        'HEENT': 'ปกติ',
        'Heart': 'ปกติ',
        'Chest': 'ปกติ',
        'Abdomen': 'ปกติ',
        'Neurological': 'ปกติ',
        'Extremities': 'ปกติ',
      },
      builtIn: true),
  ErPeTemplate(
      'ศัลยกรรมทั่วไป',
      {
        'GA': 'ปกติ',
        'Chest': 'ปกติ',
        'Abdomen': 'ปกติ',
        'PR': 'ปกติ',
        'Extremities': 'ปกติ',
      },
      builtIn: true),
  ErPeTemplate(
      'ศัลยกรรมกระดูกและข้อ',
      {
        'GA': 'ปกติ',
        'Extremities': 'ปกติ',
        'Neurological': 'ปกติ',
      },
      builtIn: true),
  ErPeTemplate(
      'สูติ-นรีเวช',
      {
        'GA': 'ปกติ',
        'Abdomen': 'ปกติ',
        'PV': 'ปกติ',
        'Genitalia': 'ปกติ',
      },
      builtIn: true),
  ErPeTemplate(
      'กุมารเวช',
      {
        'GA': 'ปกติ',
        'HEENT': 'ปกติ',
        'Heart': 'ปกติ',
        'Chest': 'ปกติ',
        'Abdomen': 'ปกติ',
      },
      builtIn: true),
];

class ErPeTemplates {
  ErPeTemplates._();

  static String _key(String userId) => 'er_pe_templates_$userId';

  /// template ของผู้ใช้ (ของตัวเองก่อน ตามด้วยของระบบ)
  static Future<List<ErPeTemplate>> load(String userId) async {
    final mine = <ErPeTemplate>[];
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key(userId));
      if (raw != null) {
        for (final j in jsonDecode(raw) as List<dynamic>) {
          mine.add(ErPeTemplate.fromJson(j as Map<String, dynamic>));
        }
      }
    } catch (_) {}
    return [...mine, ...erPeBuiltIns];
  }

  static Future<void> _save(String userId, List<ErPeTemplate> mine) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _key(userId), jsonEncode([for (final t in mine) t.toJson()]));
  }

  /// บันทึก (ชื่อซ้ำ = แทนที่ของเดิม)
  static Future<List<ErPeTemplate>> add(String userId, ErPeTemplate t) async {
    final all = await load(userId);
    final mine = [
      t,
      for (final x in all)
        if (!x.builtIn && x.name != t.name) x
    ];
    await _save(userId, mine);
    return [...mine, ...erPeBuiltIns];
  }

  static Future<List<ErPeTemplate>> remove(String userId, String name) async {
    final all = await load(userId);
    final mine = [
      for (final x in all)
        if (!x.builtIn && x.name != name) x
    ];
    await _save(userId, mine);
    return [...mine, ...erPeBuiltIns];
  }
}
