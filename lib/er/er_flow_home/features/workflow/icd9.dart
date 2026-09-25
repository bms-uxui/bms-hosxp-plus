// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

const String _icd9Label = 'รหัสหัตถการ ICD-9-CM';
const String _procLabel = 'หัตถการที่ทำ';

extension _FeaturesWorkflowIcd9Part on _ErFlowHomeWidgetState {
  /// ICD-9-CM ที่แนะนำจากหัตถการที่เลือก (ผูกรหัสไว้ใน master er_procedure.icd9cm)
  /// คืน (รหัส, ชื่อตาม master er_icd9cm) ไม่เดารหัสเอง
  List<(String, String)> _icd9Suggest() {
    final m = ErMaster.maybe;
    final proc = _filled[_speechStep][_procLabel];
    if (m == null || proc == null || proc.isEmpty) return const [];
    final icd = {
      for (final it
          in m.table('er_icd9cm')?.activeItems ?? const <ErMasterItem>[])
        it.code: it.name
    };
    return [
      for (final it
          in m.table('er_procedure')?.activeItems ?? const <ErMasterItem>[])
        if (proc.contains(it.name) && icd[it.extra['icd9cm']] != null)
          ('${it.extra['icd9cm']}', icd[it.extra['icd9cm']]!),
    ];
  }

  Widget _icd9Bar(List<(String, String)> sug) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 12.0, color: _blue),
            const SizedBox(width: 4.0),
            Text('แนะนำจากหัตถการที่ทำ',
                style: _t(9.5, color: _blueHue, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4.0),
          Wrap(spacing: 5.0, runSpacing: 5.0, children: [
            for (final (code, name) in sug)
              _optChip('$code · $name',
                  _filled[_speechStep][_icd9Label] == name, false, () {
                setState(() {
                  _lastFilled = [
                    (_speechStep, _icd9Label, _filled[_speechStep][_icd9Label])
                  ];
                  _filled[_speechStep][_icd9Label] = name;
                });
              }, size: 10.5),
          ]),
        ],
      );

  /// เลือกหัตถการแล้ว ICD-9-CM ยังว่าง: เติมรหัสที่ผูกไว้ให้เลย (แก้ได้)
  void _autoIcd9() {
    if (_filled[_speechStep].containsKey(_icd9Label)) return;
    final sug = _icd9Suggest();
    if (sug.isNotEmpty) _filled[_speechStep][_icd9Label] = sug.first.$2;
  }

  /// ให้ผู้ช่วยเสนอ ICD-9-CM จากหัตถการ โดยใช้คู่รหัสใน master เท่านั้น
  String _icd9Prompt() {
    final m = ErMaster.maybe;
    if (m == null) return '';
    final icd = {
      for (final it
          in m.table('er_icd9cm')?.activeItems ?? const <ErMasterItem>[])
        it.code: it.name
    };
    final pairs = [
      for (final it
          in m.table('er_procedure')?.activeItems ?? const <ErMasterItem>[])
        if (icd[it.extra['icd9cm']] != null)
          '- ${it.name} → ${icd[it.extra['icd9cm']]}'
    ].join('\n');
    return '''
เมื่อรู้หัตถการที่ทำ ให้เสนอ "$_icd9Label" ทันทีโดยใส่ชื่อรหัสตามคู่นี้เท่านั้น (ห้ามแต่งรหัสเอง) แล้วถามแพทย์ยืนยัน:
$pairs''';
  }
}
