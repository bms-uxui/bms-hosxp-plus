/// Master data (ตารางรหัส/lookup) ของโมดูล ER — assets/jsons/er_master_data.json
///
/// ครอบคลุมทุก dropdown / chips / radio ในฟอร์ม ER (er_form_kb.json)
/// ชื่อรายการที่มาจากหน้าจอคงข้อความเดิม เพื่อให้ค่าที่เลือกตรงกับ UI
/// ตารางที่ origin = hosxp_knowledge เติมจากตาราง HOSxP / 43 แฟ้ม ตามความรู้ทั่วไป
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// รายการหนึ่งในตาราง master
class ErMasterItem {
  const ErMasterItem({
    required this.code,
    required this.name,
    this.nameEn,
    this.sort = 0,
    this.active = true,
    this.extra = const {},
  });

  factory ErMasterItem.fromJson(Map<String, dynamic> j) {
    const known = {'code', 'name', 'name_en', 'sort', 'active'};
    return ErMasterItem(
      code: '${j['code']}',
      name: j['name'] as String? ?? '',
      nameEn: j['name_en'] as String?,
      sort: (j['sort'] as num?)?.toInt() ?? 0,
      active: j['active'] as bool? ?? true,
      extra: {
        for (final e in j.entries)
          if (!known.contains(e.key)) e.key: e.value
      },
    );
  }

  final String code;
  final String name;
  final String? nameEn;
  final int sort;
  final bool active;

  /// ค่าเสริมเฉพาะตาราง เช่น score, color, group, icd10, typeout
  final Map<String, dynamic> extra;

  @override
  String toString() => '$code:$name';
}

/// ฟอร์ม/ช่องที่ใช้ตารางนี้ (อ้าง id ฟอร์มใน er_form_kb.json)
class ErMasterUse {
  const ErMasterUse(this.form, this.field);
  final String form;
  final String field;
}

/// ตาราง master หนึ่งตาราง
class ErMasterTable {
  const ErMasterTable({
    required this.id,
    required this.nameTh,
    required this.source,
    required this.usedBy,
    required this.items,
    this.origin = '',
  });

  factory ErMasterTable.fromJson(Map<String, dynamic> j) {
    final items = [
      for (final i in (j['items'] as List<dynamic>? ?? const []))
        ErMasterItem.fromJson(i as Map<String, dynamic>)
    ]..sort((a, b) => a.sort.compareTo(b.sort));
    return ErMasterTable(
      id: j['id'] as String,
      nameTh: j['name_th'] as String? ?? '',
      source: j['source'] as String? ?? '',
      origin: j['origin'] as String? ?? '',
      usedBy: [
        for (final u in (j['used_by'] as List<dynamic>? ?? const []))
          ErMasterUse(u['form'] as String, u['field'] as String)
      ],
      items: items,
    );
  }

  final String id;
  final String nameTh;
  final String source;

  /// repo = สกัดจากหน้าจอในโปรเจกต์, hosxp_knowledge = เติมจากความรู้ HOSxP
  final String origin;
  final List<ErMasterUse> usedBy;

  /// เรียงตาม sort แล้ว
  final List<ErMasterItem> items;

  /// เฉพาะรายการที่ active
  List<ErMasterItem> get activeItems => [
        for (final i in items)
          if (i.active) i
      ];

  ErMasterItem? byCode(String code) {
    for (final i in items) {
      if (i.code == code) return i;
    }
    return null;
  }

  ErMasterItem? byName(String name) {
    final n = name.trim();
    for (final i in items) {
      if (i.name == n || i.nameEn == n) return i;
    }
    return null;
  }
}

class ErMaster {
  ErMaster._(this.tables, this._byId, this._byField);

  static ErMaster? _cached;
  static Future<ErMaster>? _loading;

  final List<ErMasterTable> tables;
  final Map<String, ErMasterTable> _byId;

  /// key = 'form|field' → ตาราง
  final Map<String, ErMasterTable> _byField;

  static ErMaster? get maybe => _cached;

  static Future<ErMaster> load() {
    if (_cached != null) return Future.value(_cached);
    return _loading ??= () async {
      final raw =
          await rootBundle.loadString('assets/jsons/er_master_data.json');
      return _cached = parse(raw);
    }();
  }

  /// แปลง json เป็น ErMaster (แยกออกมาเพื่อทดสอบได้โดยไม่ต้องใช้ rootBundle)
  static ErMaster parse(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final tables = [
      for (final t in (data['tables'] as List<dynamic>? ?? const []))
        ErMasterTable.fromJson(t as Map<String, dynamic>)
    ];
    final byId = {for (final t in tables) t.id: t};
    final byField = <String, ErMasterTable>{};
    for (final t in tables) {
      for (final u in t.usedBy) {
        byField.putIfAbsent(_key(u.form, u.field), () => t);
      }
    }
    return ErMaster._(tables, byId, byField);
  }

  static String _key(String form, String field) => '$form|$field';

  ErMasterTable? table(String id) => _byId[id];

  /// ตารางที่ผูกกับช่อง [fieldLabel] ของฟอร์ม [formId] (ตาม used_by)
  ErMasterTable? tableFor(String formId, String fieldLabel) =>
      _byField[_key(formId, fieldLabel)];

  /// ตัวเลือก (active) ของช่องในฟอร์ม — ว่างถ้าไม่มีตารางผูกไว้
  List<ErMasterItem> itemsFor(String formId, String fieldLabel) =>
      tableFor(formId, fieldLabel)?.activeItems ?? const [];

  /// รหัส → ชื่อ (null ถ้าไม่พบ)
  String? nameOf(String tableId, String code) =>
      _byId[tableId]?.byCode(code)?.name;

  /// ชื่อ (ไทยหรืออังกฤษ) → รหัส (null ถ้าไม่พบ)
  String? codeOf(String tableId, String name) =>
      _byId[tableId]?.byName(name)?.code;
}
