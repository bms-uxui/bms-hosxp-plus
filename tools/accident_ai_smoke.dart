// Explicit live smoke check with synthetic text only. No patient records are read.
import 'dart:convert';
import 'dart:io';
import '../lib/er/er_shared/er_smart_fill.dart';

Future<void> main() async {
  final master = jsonDecode(await File('assets/jsons/er_master_data.json').readAsString()) as Map;
  final tables = {for (final table in master['tables'] as List) table['id']: table};
  final mapping = {
    'สถานที่เกิดเหตุ': 'accident_place_type', 'ประเภทอุบัติเหตุ': 'accident_type',
    'ยานพาหนะ': 'accident_vehicle_type', 'ประเภทผู้บาดเจ็บ': 'accident_person_type',
    'หมวกนิรภัย': 'accident_helmet_type', 'เข็มขัดนิรภัย': 'accident_belt_type',
    'แอลกอฮอล์': 'accident_alcohol_type', 'สารเสพติด': 'accident_drug_type',
  };
  final fields = [
    for (final e in mapping.entries) ErFillField(e.key, options: [
      for (final item in tables[e.value]['items'] as List)
        if (item['active'] == true) item['name'] as String,
    ]),
    for (final name in ['วันที่/เวลาเกิดเหตุ', 'ทะเบียนรถ', 'จุดเกิดเหตุ', 'หมายเหตุ'])
      ErFillField(name, custom: true),
  ];
  const source = 'วันที่ 28 กันยายน 2569 เวลา 22:21 เกิดเหตุถนนสุขสวัสดิ์ รถจักรยานยนต์ล้มเอง ผู้ป่วยเป็นผู้ขับขี่ ทะเบียน 1กข 1234 ไม่คาดเข็มขัด สวมหมวกนิรภัย ไม่ดื่มแอลกอฮอล์ ไม่ใช้สารเสพติด';
  final result = await ErSmartFill.extract(source, fields);
  if (result.isEmpty) throw StateError('No suggestions');
  stdout.writeln('Received ${result.length} suggestions; review required before applying.');
  for (final item in result) {
    stdout.writeln('${item.field}: ${item.value} [${item.status.name}, applicable=${item.applicable}]');
    if (item.applicable && !source.contains(item.evidence)) throw StateError('Ungrounded suggestion');
  }
  if (ErSmartFill.apply(result, {}, {}, {}).isNotEmpty) throw StateError('Unconfirmed write');
}
