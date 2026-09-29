import 'package:flutter_test/flutter_test.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_smart_fill.dart';

void main() {
  const fields = [
    ErFillField('แอลกอฮอล์', options: ['ดื่ม', 'ไม่ดื่ม', 'ไม่ทราบ']),
    ErFillField('หมายเหตุ', custom: true),
    ErFillField('วันที่/เวลาเกิดเหตุ', custom: true),
  ];
  const coverageFields = [
    ErFillField('วันที่/เวลาเกิดเหตุ', custom: true),
    ErFillField('สถานที่เกิดเหตุ', options: ['ถนน', 'ชุมชน']),
    ErFillField('ประเภทอุบัติเหตุ', options: ['อุบัติเหตุการขนส่ง (V01-V89)']),
    ErFillField('ยานพาหนะ',
        options: ['รถจักรยานยนต์', 'รถจักรยาน', 'รถปิคอัพ']),
    ErFillField('จุดเกิดเหตุ', custom: true),
    ErFillField('หมวกนิรภัย', options: ['ใช้', 'ไม่ใช้', 'ไม่ทราบ']),
    ErFillField('การดูแลการหายใจ', options: [
      'มีการดูแลการหายใจก่อนมาถึง',
      'ไม่มีการดูแลการหายใจก่อนมาถึง',
      'ไม่จำเป็น',
      'มีการดูแลการหายใจก่อนมาถึงไม่เหมาะสม',
    ]),
  ];
  Map<String, String> row(String field, String value, String evidence,
          {String status = 'matched'}) =>
      {
        'field': field,
        'value': value,
        'evidence': evidence,
        'status': status,
      };
  test('requires a source quote and existing dropdown option', () {
    final result = ErSmartFill.map(
        'ไม่ดื่ม',
        [
          row('แอลกอฮอล์', 'ไม่มี', 'ไม่ดื่ม'),
          row('หมายเหตุ', 'แต่งข้อมูล', 'ข้อความที่ไม่มี'),
          row('ไม่มีช่อง', 'ไม่ดื่ม', 'ไม่ดื่ม'),
        ],
        fields);
    expect(result.every((s) => !s.applicable), isTrue);
  });
  test('negated evidence cannot be reported as a confident positive match', () {
    final result = ErSmartFill.map(
        'ไม่ดื่ม', [row('แอลกอฮอล์', 'ดื่ม', 'ไม่ดื่ม')], fields);
    expect(result.single.status, ErFillStatus.unmatched);
  });
  test('model unmatched output is not promoted to applicable', () {
    final result = ErSmartFill.map('ไม่ทราบ',
        [row('หมายเหตุ', 'ไม่ทราบ', 'ไม่ทราบ', status: 'unmatched')], fields);
    expect(result.single.applicable, isFalse);
  });
  test('duplicate target proposals cannot silently win over one another', () {
    final result = ErSmartFill.map(
        'ดื่ม ไม่ดื่ม',
        [
          row('แอลกอฮอล์', 'ดื่ม', 'ดื่ม'),
          row('แอลกอฮอล์', 'ไม่ดื่ม', 'ไม่ดื่ม'),
        ],
        fields);
    expect(result.every((s) => !s.applicable), isTrue);
  });
  test('apply requires selection and preserves existing values by default', () {
    final result = ErSmartFill.map(
        'ไม่ดื่ม', [row('แอลกอฮอล์', 'ไม่ดื่ม', 'ไม่ดื่ม')], fields);
    final old = {'แอลกอฮอล์': 'ดื่ม'};
    expect(ErSmartFill.apply(result, {}, old, old), old);
    expect(ErSmartFill.apply(result, {0}, old, old)['แอลกอฮอล์'], 'ไม่ดื่ม');
    expect(old['แอลกอฮอล์'], 'ดื่ม');
    expect(
        ErSmartFill.apply(
            result, {0}, old, {'แอลกอฮอล์': 'ไม่ทราบ'})['แอลกอฮอล์'],
        'ไม่ทราบ');
  });
  test('date without explicit time cannot acquire invented time', () {
    final result = ErSmartFill.map(
        '28 กันยายน 2569',
        [
          row('วันที่/เวลาเกิดเหตุ', '28/09/2569 22:21 น.', '28 กันยายน 2569'),
        ],
        fields);
    expect(result.single.applicable, isFalse);
  });
  test('invalid calendar date cannot be applied', () {
    final result = ErSmartFill.map(
        '31/02/2569 22:21',
        [
          row('วันที่/เวลาเกิดเหตุ', '31/02/2569 22:21 น.', '31/02/2569 22:21'),
        ],
        fields);
    expect(result.single.applicable, isFalse);
  });
  test('date conversion is reviewed, custom multiline content is preserved',
      () {
    const source = '28 กันยายน 2569 เวลา 22:21\nบรรทัดหนึ่ง\nบรรทัดสอง';
    final result = ErSmartFill.map(
        source,
        [
          row('วันที่/เวลาเกิดเหตุ', '28/09/2569 22:21 น.',
              '28 กันยายน 2569 เวลา 22:21'),
          row('หมายเหตุ', 'บรรทัดหนึ่ง\nบรรทัดสอง', 'บรรทัดหนึ่ง\nบรรทัดสอง'),
        ],
        fields);
    expect(result.first.status, ErFillStatus.needsReview);
    expect(ErSmartFill.apply(result, {1}, {}, {})['หมายเหตุ'],
        'บรรทัดหนึ่ง\nบรรทัดสอง');
  });

  test('coverage uses exact form options and complete date-time evidence', () {
    const source =
        'ผู้ป่วยประสบอุบัติเหตุรถจักรยานยนต์ วันที่ 29/09/2569 เวลา 10:30 น.';
    final coverage = {
      for (final item in ErSmartFill.coverage(source, coverageFields))
        item.field: item.status,
    };
    expect(coverage['วันที่/เวลาเกิดเหตุ'], ErCoverageStatus.found);
    expect(coverage['ยานพาหนะ'], ErCoverageStatus.found);
    expect(coverage['ประเภทอุบัติเหตุ'], ErCoverageStatus.needsReview);
    expect(coverage['สถานที่เกิดเหตุ'], ErCoverageStatus.missing);
    expect(coverage['จุดเกิดเหตุ'], ErCoverageStatus.missing);
    expect(coverage['หมวกนิรภัย'], ErCoverageStatus.missing);
    expect(
        ErSmartFill.coverage('วันที่ 31/02/2569 เวลา 25:70 น.', coverageFields)
            .first
            .status,
        ErCoverageStatus.needsReview);
  });

  test('coverage updates for a named place and explicit helmet use', () {
    const source = 'เกิดเหตุบริเวณถนนสุขสวัสดิ์ ผู้ป่วยสวมหมวกนิรภัย';
    final coverage = {
      for (final item in ErSmartFill.coverage(source, coverageFields))
        item.field: item.status,
    };
    expect(coverage['จุดเกิดเหตุ'], ErCoverageStatus.found);
    expect(coverage['สถานที่เกิดเหตุ'], ErCoverageStatus.needsReview);
    expect(coverage['หมวกนิรภัย'], ErCoverageStatus.found);
    expect(coverage['วันที่/เวลาเกิดเหตุ'], ErCoverageStatus.missing);
  });

  test('ambiguous topic cues need review and generic options need context', () {
    final ambiguous = {
      for (final item in ErSmartFill.coverage(
          'ตรวจหมวกนิรภัยและการดูแลการหายใจ', coverageFields))
        item.field: item.status,
    };
    final generic = {
      for (final item in ErSmartFill.coverage('ไม่จำเป็น', coverageFields))
        item.field: item.status,
    };
    expect(ambiguous['หมวกนิรภัย'], ErCoverageStatus.needsReview);
    expect(ambiguous['การดูแลการหายใจ'], ErCoverageStatus.needsReview);
    expect(generic['หมวกนิรภัย'], ErCoverageStatus.missing);
    expect(generic['การดูแลการหายใจ'], ErCoverageStatus.missing);
  });

  test('coverage only checks source evidence and handles pre-arrival phrases',
      () {
    final exact = {
      for (final item
          in ErSmartFill.coverage('มีการดูแลการหายใจก่อนมาถึง', coverageFields))
        item.field: item.status,
    };
    final ambiguous = {
      for (final item in ErSmartFill.coverage('ดูแลการหายใจ', coverageFields))
        item.field: item.status,
    };
    expect(exact['การดูแลการหายใจ'], ErCoverageStatus.found);
    expect(ambiguous['การดูแลการหายใจ'], ErCoverageStatus.needsReview);
  });

  test('analyzed coverage follows validated mappings, including custom fields',
      () {
    const source = 'ข้อความอิสระ ไม่ดื่ม';
    final extracted = ErSmartFill.map(
        source,
        [
          row('หมายเหตุ', 'ข้อความอิสระ', 'ข้อความอิสระ'),
          row('แอลกอฮอล์', 'ไม่ดื่ม', 'ไม่ดื่ม', status: 'needs_review'),
        ],
        fields);
    final result = {
      for (final item
          in ErSmartFill.analyzedCoverage(source, fields, extracted))
        item.field: item.status,
    };
    expect(result['หมายเหตุ'], ErCoverageStatus.found);
    expect(result['แอลกอฮอล์'], ErCoverageStatus.needsReview);
    expect(result['วันที่/เวลาเกิดเหตุ'], ErCoverageStatus.missing);
  });

  test('rejected or unsupported extraction cannot promote coverage', () {
    const source = 'หมายเหตุ ทดสอบ';
    final extracted = ErSmartFill.map(
        source,
        [
          row('หมายเหตุ', 'ทดสอบ', 'ทดสอบ', status: 'unmatched'),
          row('แอลกอฮอล์', 'ดื่ม', 'หลักฐานที่ไม่มี'),
        ],
        fields);
    final result = {
      for (final item
          in ErSmartFill.analyzedCoverage(source, fields, extracted))
        item.field: item.status,
    };
    expect(result['หมายเหตุ'], ErCoverageStatus.needsReview);
    expect(result['แอลกอฮอล์'], ErCoverageStatus.missing);
  });

  test('multiple rejected values show review rather than found', () {
    const source = 'ดื่ม ไม่ดื่ม';
    final extracted = ErSmartFill.map(
        source,
        [
          row('แอลกอฮอล์', 'ดื่ม', 'ดื่ม'),
          row('แอลกอฮอล์', 'ไม่ดื่ม', 'ไม่ดื่ม'),
        ],
        fields);
    expect(ErSmartFill.analyzedCoverage(source, fields, extracted).first.status,
        ErCoverageStatus.needsReview);
  });

  test('conflicts require a different nonempty current value', () {
    final suggestion = ErSmartFill.map(
            'ไม่ดื่ม', [row('แอลกอฮอล์', 'ไม่ดื่ม', 'ไม่ดื่ม')], fields)
        .single;
    expect(ErSmartFill.conflicts(suggestion, ''), isFalse);
    expect(ErSmartFill.conflicts(suggestion, '   '), isFalse);
    expect(ErSmartFill.conflicts(suggestion, 'ไม่ดื่ม'), isFalse);
    expect(ErSmartFill.conflicts(suggestion, 'ดื่ม'), isTrue);
  });
}
