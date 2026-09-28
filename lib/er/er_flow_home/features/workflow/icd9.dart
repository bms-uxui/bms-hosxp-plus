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

// ------------------------------------------------ หน้าหัตถการ (Figma 227-595)
// หน้าเดียวรวม: เทมเพลต · ชื่อหัตถการ + ICD9 · ผู้ดูแลหัตถการ (ผู้สั่ง ผู้ทำ ผู้ช่วย) · รายละเอียด

/// ชื่อช่องตาม used_by ของ master (er_doctor / er_staff) · ไม่ใช่ช่องบังคับของขั้น
const String _procByLabel = 'ผู้สั่งหัตถการ';
const String _procDoerLabel = 'ผู้ทำหัตถการ';
const String _procAssistLabel = 'ผู้ร่วมทำหัตถการ';
const String _procNoteLabel = 'รายละเอียดหัตถการ';

/// เทมเพลตหัตถการที่ทำบ่อยใน ER: (ชื่อ, หัตถการตาม master er_procedure, รายละเอียด)
const List<(String, String, String)> _procTemplates = [
  (
    'หมากัด',
    'ทำแผล (Dressing)',
    'ล้างแผลสุนัขกัดด้วยน้ำสะอาดและสบู่ 15 นาที เช็ดด้วย Povidone iodine ไม่เย็บแผล ปิดแผลด้วยก๊อซ',
  ),
  (
    'ห้ามเลือดอุบัติเหตุ',
    'เย็บแผล (Suture)',
    'กดห้ามเลือด ล้างแผลด้วย NSS ฉีดยาชา 1% Xylocaine เย็บแผลด้วย Nylon 4-0 ปิดแผลด้วยก๊อซ',
  ),
  (
    'งูกัด',
    'ทำแผล (Dressing)',
    'ล้างแผลด้วยน้ำสะอาด ไม่กรีด ไม่ดูดแผล ดามอวัยวะให้อยู่นิ่ง ถอดเครื่องประดับที่รัด',
  ),
  (
    'ฝีหนอง',
    'ผ่าฝี / ระบายหนอง (I&D)',
    'ฉีดยาชา กรีดระบายหนอง ล้างโพรงหนองด้วย NSS ใส่ก๊อซระบาย ปิดแผล',
  ),
  (
    'ตัดไหม',
    'ตัดไหม (Remove stitches)',
    'แผลแห้งดี ไม่มีการติดเชื้อ ตัดไหมครบทุกเข็ม ปิดแผลด้วยพลาสเตอร์',
  ),
  (
    'ใส่เฝือกอ่อน',
    'ใส่เฝือกอ่อน / Splint',
    'ใส่เฝือกอ่อนดามบริเวณที่บาดเจ็บ ตรวจชีพจรส่วนปลายและการเคลื่อนไหวหลังใส่ปกติ',
  ),
];

extension _FeaturesWorkflowProcPart on _ErFlowHomeWidgetState {
  List<ErMasterItem> _procMaster(String id) =>
      ErMaster.maybe?.table(id)?.activeItems ?? const <ErMasterItem>[];

  /// ชื่อ ICD-9-CM → รหัส
  Map<String, String> get _icd9Codes => {
        for (final it in _procMaster('er_icd9cm')) it.name: it.code,
      };

  /// บทบาทของบุคลากร (แพทย์ พยาบาล ...) จาก master er_staff
  String? _staffRole(String name) {
    for (final it in _procMaster('er_staff')) {
      if (it.name == name) return '${it.extra['role'] ?? ''}';
    }
    return null;
  }

  List<String> get _procAssists => [
        for (final s
            in (_filled[_speechStep][_procAssistLabel] ?? '').split('\n'))
          if (s.trim().isNotEmpty) s.trim()
      ];

  void _procSet(String label, String? v) => setState(() {
        _lastFilled = [(_speechStep, label, _filled[_speechStep][label])];
        if (v == null || v.trim().isEmpty) {
          _filled[_speechStep].remove(label);
        } else {
          _filled[_speechStep][label] = v;
        }
      });

  /// ผู้สั่งเริ่มต้น = แพทย์ที่ login อยู่ (แก้ได้)
  void _procDefaults() {
    final f = _filled[_speechStep];
    final me = ErSession.instance.user;
    if (f.containsKey(_procByLabel) || me == null) return;
    if (ErSession.instance.role != ErRole.doctor) return;
    // ใช้ชื่อตาม master er_doctor (จับคู่ด้วยชื่อต้น) ให้ตรงกับรายการในตัวเลือก
    final p = me.name.split(' ');
    final first = p.length > 1 ? p[1] : me.name;
    f[_procByLabel] = _procMaster('er_doctor')
            .where((it) => it.name.contains(first))
            .map((it) => it.name)
            .firstOrNull ??
        me.name;
  }

  /// แตะเทมเพลต: ลงหัตถการ ICD9 ที่ผูกไว้ และรายละเอียด
  void _procApplyTemplate((String, String, String) t) {
    final f = _filled[_speechStep];
    setState(() {
      _lastFilled = [(_speechStep, _procLabel, f[_procLabel])];
      f[_procLabel] = t.$2;
      f.remove(_icd9Label);
      _autoIcd9();
      f[_procNoteLabel] = t.$3;
      _inlineCtl['$_speechStep|$_procNoteLabel']?.text = t.$3;
    });
  }

  Widget _procPage() {
    _procDefaults();
    final f = _filled[_speechStep];
    final proc = f[_procLabel];
    final icd = f[_icd9Label];
    final code = icd == null ? null : _icd9Codes[icd];
    final assists = _procAssists;
    Widget title(String t) =>
        Text(t, style: _t(12.5, color: _inkTitle, weight: FontWeight.w600));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _procTemplateBar(),
          const SizedBox(height: 12.0),
          _procGroup([
            _procRow('ชื่อหัตถการ', proc,
                placeholder: 'เลือกหัตถการ',
                onTap: () => _pickFromList(_procLabel,
                    [for (final it in _procMaster('er_procedure')) it.name])),
            _procRow('ICD9', icd == null ? null : '$code  $icd',
                placeholder: 'เลือกรหัส',
                onTap: () => _pickFromList(_icd9Label,
                    [for (final it in _procMaster('er_icd9cm')) it.name])),
          ]),
          const SizedBox(height: 16.0),
          Row(children: [
            Expanded(child: title('ผู้ดูแลหัตถการ')),
            _procPill(Icons.person_add_alt_1_rounded, 'เพิ่มผู้ช่วย', () async {
              final taken = {f[_procDoerLabel], ...assists};
              final picked = await _listSheet('เพิ่มผู้ช่วย', [
                for (final it in _procMaster('er_staff'))
                  if (!taken.contains(it.name)) it.name
              ]);
              if (picked == null || !mounted) return;
              _procSet(_procAssistLabel, [...assists, picked].join('\n'));
            }),
          ]),
          const SizedBox(height: 8.0),
          _procGroup([
            _procRow('ผู้สั่ง', f[_procByLabel],
                placeholder: 'เลือกแพทย์',
                onTap: () => _pickFromList(_procByLabel,
                    [for (final it in _procMaster('er_doctor')) it.name])),
          ]),
          const SizedBox(height: 8.0),
          _procGroup([
            _procRow('ผู้ทำ', f[_procDoerLabel],
                placeholder: 'เลือกผู้ทำ',
                sub: f[_procDoerLabel] == null
                    ? null
                    : _staffRole(f[_procDoerLabel]!),
                onTap: () => _pickFromList(_procDoerLabel,
                    [for (final it in _procMaster('er_staff')) it.name])),
            for (var i = 0; i < assists.length; i++)
              _procRow('ผู้ช่วย', assists[i],
                  sub: _staffRole(assists[i]),
                  remove: () => _procSet(_procAssistLabel,
                      ([...assists]..removeAt(i)).join('\n'))),
          ]),
          const SizedBox(height: 16.0),
          title('รายละเอียด'),
          const SizedBox(height: 8.0),
          Container(
            constraints: const BoxConstraints(minHeight: 96.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: _line),
            ),
            child: _inlineInput(_procNoteLabel, f[_procNoteLabel],
                hint: 'เช่น ทำแผลอุบัติเหตุบริเวณหัวเข่า',
                maxLines: 8,
                style: _t(12.5, color: _inkTitle, height: 1.45),
                hintStyle: _t(12.0, color: _ink3)),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  /// แถบเทมเพลตแบบเดียวกับหน้า HPI: ชื่อ + จำนวน ซ้าย ชิปเลื่อนล้นถึงขอบแผง
  Widget _procTemplateBar() => Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('เทมเพลต',
                style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
            Text('${_procTemplates.length} รายการ',
                style: _t(9.0, color: _ink3)),
          ],
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: SizedBox(
            height: 32.0,
            child: LayoutBuilder(
              builder: (context, box) => OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: box.maxWidth + 16.0,
                maxWidth: box.maxWidth + 16.0,
                minHeight: 32.0,
                maxHeight: 32.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16.0),
                  itemCount: _procTemplates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6.0),
                  itemBuilder: (_, i) {
                    final t = _procTemplates[i];
                    final on = _filled[_speechStep][_procNoteLabel] == t.$3;
                    return _Press(
                      child: GestureDetector(
                        onTap: () => _procApplyTemplate(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: on ? _blue : _panel,
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(color: on ? _blue : _line),
                          ),
                          child: Text(t.$1,
                              style: _t(10.5,
                                  color: on ? Colors.white : _inkTitle,
                                  weight: FontWeight.w600)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ]);

  /// การ์ดขอบมนรวมหลายแถว คั่นด้วยเส้นบาง
  Widget _procGroup(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: _line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1.0, color: _line),
            rows[i],
          ],
        ]),
      );

  /// หนึ่งแถว: ชื่อช่องซ้าย ค่าชิดขวา + ลูกศรลง (แตะเพื่อเลือก) หรือปุ่มเอาออก
  Widget _procRow(String label, String? value,
          {String? placeholder,
          String? sub,
          VoidCallback? onTap,
          VoidCallback? remove}) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 10.0, 12.0),
            child: Row(children: [
              Text(label,
                  style: _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value ?? placeholder ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _t(12.5,
                            color: value == null ? _ink3 : _ink2,
                            weight: FontWeight.w500)),
                    if (sub != null && sub.isNotEmpty)
                      Text(sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(10.0, color: _ink3)),
                  ],
                ),
              ),
              const SizedBox(width: 6.0),
              if (remove != null)
                _Press(
                  child: GestureDetector(
                    onTap: remove,
                    child: const Icon(Icons.close_rounded,
                        size: 18.0, color: _ink3),
                  ),
                )
              else
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22.0, color: _blue),
            ]),
          ),
        ),
      );

  Widget _procPill(IconData icon, String label, VoidCallback onTap) => _Press(
        child: Material(
          color: _panel,
          shape: const StadiumBorder(side: BorderSide(color: _line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 15.0, color: _inkTitle),
                const SizedBox(width: 6.0),
                Text(label,
                    style: _t(11.0, color: _inkTitle, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      );
}
