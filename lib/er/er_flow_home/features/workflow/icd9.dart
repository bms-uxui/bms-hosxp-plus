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
const String _procAtLabel = 'วันที่ทำหัตถการ';

/// วันเวลาที่ทำหัตถการ (null = ยังไม่ระบุ ใช้เวลาตอนเปิดหน้า)
DateTime? _procAt;

/// หลายหัตถการ (d18 2026-10-20): รายการที่บันทึกแล้วเก็บเป็น JSON ในช่องนี้
/// ช่องเดี่ยว (ชื่อ ICD9 วันที่ ผู้สั่ง ผู้ทำ ผู้ช่วย รายละเอียด) = ร่างของรายการที่กำลังแก้
/// ไม่ได้แก้อยู่: ชื่อ/ICD9 = สรุปทุกรายการ (บรรทัดละรายการ) ให้ขั้นวินิจฉัยดึงรหัสได้
const String _procListKey = 'หัตถการ - รายการ';

/// หน้าย่อยแก้หัตถการ: null = หน้ารายการ · -1 = เพิ่มใหม่ · n = แก้รายการที่ n
int? _procEdit;

/// Order set หัตถการ: แตะแล้วลงทุกหัตถการในชุดพร้อมกัน (หัตถการตาม master er_procedure, รายละเอียด)
const List<(String, List<(String, String)>)> _procOrderSets = [
  (
    'หมากัด',
    [
      (
        'ทำแผล (Dressing)',
        'ล้างแผลสุนัขกัดด้วยน้ำสะอาดและสบู่ 15 นาที เช็ดด้วย Povidone iodine ไม่เย็บแผล ปิดแผลด้วยก๊อซ'
      ),
      ('ฉีดยา (Injection)', 'ฉีดวัคซีนป้องกันพิษสุนัขบ้า และ Tetanus toxoid'),
    ]
  ),
  (
    'แผลฉีกขาด',
    [
      (
        'ล้างแผล / ตัดเนื้อตาย (Debridement)',
        'ล้างแผลด้วย NSS ตัดเนื้อตายขอบแผล'
      ),
      (
        'เย็บแผล (Suture)',
        'ฉีดยาชา 1% Xylocaine เย็บแผลด้วย Nylon 4-0 ปิดแผลด้วยก๊อซ'
      ),
    ]
  ),
  (
    'งูกัด',
    [
      ('ทำแผล (Dressing)', 'ล้างแผลด้วยน้ำสะอาด ไม่กรีด ไม่ดูดแผล'),
      ('ใส่เฝือกอ่อน / Splint', 'ดามอวัยวะให้อยู่นิ่ง ถอดเครื่องประดับที่รัด'),
      ('เจาะเลือด (Venipuncture)', 'เจาะเลือดส่ง CBC, PT/INR, 20 min WBCT'),
    ]
  ),
  (
    'ฝีหนอง',
    [
      (
        'ผ่าฝี / ระบายหนอง (I&D)',
        'ฉีดยาชา กรีดระบายหนอง ล้างโพรงหนองด้วย NSS ใส่ก๊อซระบาย ปิดแผล'
      ),
    ]
  ),
  (
    'กระดูกหัก',
    [
      (
        'ใส่เฝือกอ่อน / Splint',
        'ใส่เฝือกอ่อนดามบริเวณที่บาดเจ็บ ตรวจชีพจรส่วนปลายและการเคลื่อนไหวหลังใส่ปกติ'
      ),
      ('ฉีดยา (Injection)', 'ให้ยาแก้ปวด'),
    ]
  ),
  (
    'หอบหืด',
    [
      ('พ่นยา (Nebulization)', 'Berodual NB 1 unit'),
      ('ให้ออกซิเจน (Oxygen therapy)', 'O2 cannula 3 LPM'),
    ]
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

  /// รูปหน้าซ้อนกัน (สูงสุด 3 + วง +n) วงซ้ายอยู่บน ขอบขาวคั่นแต่ละวง
  Widget _procFaces(List<String> names) {
    const d = 30.0, step = 16.0;
    // วงที่ถูกทับเห็นแค่ฝั่งขวา: อักษร/ตัวเลขขยับไปทางขวา
    const peek = Alignment(0.42, 0.0);
    final shown = names.take(3).toList();
    final more = names.length - shown.length;
    final n = shown.length + (more > 0 ? 1 : 0);
    Widget ring(Widget child) => Container(
          width: d,
          height: d,
          padding: const EdgeInsets.all(2.0),
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: _panel),
          child: child,
        );
    return SizedBox(
      width: d + step * (n - 1),
      height: d,
      // วาดจากขวาไปซ้าย: วงซ้ายสุด (คนแรก) อยู่บนสุด ทับวงถัดไป
      child: Stack(children: [
        if (more > 0)
          Positioned(
            left: shown.length * step,
            child: ring(Container(
              alignment: peek,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: _panelSoft),
              child: Text('+$more',
                  style: _num(11.0, color: _ink2, weight: FontWeight.w700)),
            )),
          ),
        for (final (i, nm) in shown.indexed.toList().reversed)
          Positioned(
              left: i * step,
              child: ring(_docAvatar(nm, d - 4.0,
                  align: i == 0 ? Alignment.center : peek))),
      ]),
    );
  }

  /// ชื่อบุคลากรไม่รวมวงเล็บท้าย "นพ. ก (รังสีแพทย์)" → "นพ. ก"
  String _procPersonName(String n) =>
      n.replaceFirst(RegExp(r'\s*\([^()]*\)\s*$'), '');

  /// บทบาท: วงเล็บท้ายชื่อก่อน แล้วค่อย master er_staff
  String? _procPersonRole(String n) =>
      RegExp(r'\(([^()]*)\)\s*$').firstMatch(n)?.group(1) ?? _staffRole(n);

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
  String _procAtText(DateTime d) =>
      '${_thDate(d)} ${_clock('${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}')}';

  /// แตะวันที่ทำ: เลือกวัน แล้วเลือกเวลาต่อ (แบบวันเวลาเข้าห้องฉุกเฉินในหน้าคัดกรอง)
  Future<void> _procPickAt() async {
    final cur = _procAt ?? DateTime.now();
    final d = await showDatePicker(
        context: context,
        initialDate: cur,
        firstDate: DateTime.now().subtract(const Duration(days: 7)),
        lastDate: DateTime.now());
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(cur));
    if (!mounted) return;
    final at = DateTime(
        d.year, d.month, d.day, t?.hour ?? cur.hour, t?.minute ?? cur.minute);
    _procAt = at;
    _procSet(_procAtLabel, _procAtText(at));
  }

  void _procDefaults() {
    final f = _filled[_speechStep];
    // วันที่ทำ: ค่าเริ่มต้น = ตอนนี้
    if (!f.containsKey(_procAtLabel)) {
      _procAt = DateTime.now();
      f[_procAtLabel] = _procAtText(_procAt!);
    }
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

  /// ช่องร่างของหัตถการหนึ่งรายการ (map key → ช่องในฟอร์ม)
  static const _procKeys = {
    'proc': _procLabel,
    'icd': _icd9Label,
    'at': _procAtLabel,
    'by': _procByLabel,
    'doer': _procDoerLabel,
    'assist': _procAssistLabel,
    'note': _procNoteLabel,
  };

  /// รายการหัตถการที่บันทึกแล้ว · ข้อมูลเดิมแบบรายการเดียว (ยังไม่มีรายการ) = แปลงเป็นรายการแรก
  List<Map<String, String>> _procItems() {
    final f = _filled[_speechStep];
    final raw = f[_procListKey];
    if (raw != null && raw.isNotEmpty) {
      try {
        return [
          for (final m in (jsonDecode(raw) as List))
            {for (final e in (m as Map).entries) '${e.key}': '${e.value}'}
        ];
      } catch (_) {}
    }
    final one = f[_procLabel];
    if (_procEdit == null && one != null && one.trim().isNotEmpty) {
      return [
        {
          for (final e in _procKeys.entries)
            if (f[e.value] case final v? when v.isNotEmpty) e.key: v
        }
      ];
    }
    return [];
  }

  /// เขียนรายการกลับ + ตั้งช่องสรุป (ชื่อ/ICD9 บรรทัดละรายการ) · ล้างช่องร่าง
  void _procStore(List<Map<String, String>> items) {
    final f = _filled[_speechStep];
    if (items.isEmpty) {
      f.remove(_procListKey);
    } else {
      f[_procListKey] = jsonEncode(items);
    }
    for (final k in _procKeys.values) {
      f.remove(k);
    }
    final names = [
      for (final m in items)
        if ((m['proc'] ?? '').isNotEmpty) m['proc']!
    ];
    final icds = [
      for (final m in items)
        if ((m['icd'] ?? '').isNotEmpty) m['icd']!
    ];
    if (names.isNotEmpty) f[_procLabel] = names.join('\n');
    if (icds.isNotEmpty) f[_icd9Label] = icds.join('\n');
    _inlineCtl['$_speechStep|$_procNoteLabel']?.text = '';
  }

  /// เปิดหน้าย่อยแก้ (i = null = เพิ่มใหม่): ใส่ค่ารายการนั้นลงช่องร่าง
  void _procOpen(int? i) {
    final items = _procItems();
    final f = _filled[_speechStep];
    setState(() {
      _procStore(items);
      for (final k in _procKeys.values) {
        f.remove(k);
      }
      if (i != null && i < items.length) {
        for (final e in _procKeys.entries) {
          if (items[i][e.key] case final v? when v.isNotEmpty) f[e.value] = v;
        }
      }
      _procAt = null;
      _inlineCtl['$_speechStep|$_procNoteLabel']?.text =
          f[_procNoteLabel] ?? '';
      _procEdit = i ?? -1;
    });
  }

  /// บันทึกหน้าย่อย: ต้องมีชื่อหัตถการ · แทนที่รายการเดิมหรือต่อท้าย
  void _procSaveEdit() {
    final f = _filled[_speechStep];
    if ((f[_procLabel] ?? '').trim().isEmpty) {
      HapticFeedback.heavyImpact();
      _wfToast('เลือกชื่อหัตถการก่อนบันทึก', error: true);
      return;
    }
    final item = {
      for (final e in _procKeys.entries)
        if (f[e.value] case final v? when v.trim().isNotEmpty) e.key: v.trim()
    };
    final raw = f[_procListKey];
    final items = raw == null || raw.isEmpty
        ? <Map<String, String>>[]
        : _procItemsRaw(raw);
    final i = _procEdit ?? -1;
    setState(() {
      if (i >= 0 && i < items.length) {
        items[i] = item;
      } else {
        items.add(item);
      }
      _procStore(items);
      _procEdit = null;
    });
  }

  List<Map<String, String>> _procItemsRaw(String raw) {
    try {
      return [
        for (final m in (jsonDecode(raw) as List))
          {for (final e in (m as Map).entries) '${e.key}': '${e.value}'}
      ];
    } catch (_) {
      return [];
    }
  }

  /// ยกเลิกหน้าย่อย: คืนช่องสรุปของรายการเดิม
  void _procCancelEdit() {
    final raw = _filled[_speechStep][_procListKey];
    setState(() {
      _procStore(raw == null || raw.isEmpty ? [] : _procItemsRaw(raw));
      _procEdit = null;
    });
  }

  /// ลบรายการที่ i (ยืนยันจากหน้าย่อย)
  /// ลบหัตถการ: ถามยืนยันก่อนเสมอ (กันลบพลาด) · ยกเลิก + ปุ่มแดง แบบ studio PE
  Future<void> _procDelete(int i) async {
    final name = _filled[_speechStep][_procLabel] ?? 'หัตถการนี้';
    final ok = await _askDelete(
        'ลบหัตถการนี้?', '$name จะถูกลบออกจากรายการหัตถการที่ทำ', 'ลบหัตถการ');
    if (!ok || !mounted) return;
    final raw = _filled[_speechStep][_procListKey];
    final items = raw == null || raw.isEmpty
        ? <Map<String, String>>[]
        : _procItemsRaw(raw);
    setState(() {
      if (i >= 0 && i < items.length) items.removeAt(i);
      _procStore(items);
      _procEdit = null;
    });
  }

  /// Order set: ลงทุกหัตถการในชุดต่อท้ายรายการ (ICD9 ตาม master · ผู้สั่ง = แพทย์ที่ login · เวลา = ตอนนี้)
  void _procApplyOrderSet((String, List<(String, String)>) set) {
    final items = _procItems();
    final codes = {
      for (final it in _procMaster('er_procedure'))
        it.name: '${it.extra['icd9cm'] ?? ''}'
    };
    final icdName = {
      for (final it in _procMaster('er_icd9cm')) it.code: it.name
    };
    final me = ErSession.instance.user;
    String? by;
    if (me != null && ErSession.instance.role == ErRole.doctor) {
      final p = me.name.split(' ');
      final first = p.length > 1 ? p[1] : me.name;
      by = _procMaster('er_doctor')
              .where((it) => it.name.contains(first))
              .map((it) => it.name)
              .firstOrNull ??
          me.name;
    }
    final at = _procAtText(DateTime.now());
    HapticFeedback.selectionClick();
    setState(() {
      for (final (proc, note) in set.$2) {
        items.add({
          'proc': proc,
          if (icdName[codes[proc]] case final n?) 'icd': n,
          'at': at,
          if (by != null) 'by': by,
          if (note.isNotEmpty) 'note': note,
        });
      }
      _procStore(items);
    });
    _wfToast('เพิ่ม ${set.$2.length} หัตถการจากเทมเพลต "${set.$1}"');
  }

  /// หน้าย่อยหัตถการอยู่ (หัวแผง = breadcrumb · footer = ย้อนกลับ | บันทึก) แบบหน้าย่อยวินิจฉัย
  bool get _procNested =>
      _procEdit != null &&
      _speechStep < _steps.length &&
      _steps[_speechStep].$2 == 'หัตถการ' &&
      _formAt == 0;

  Widget _procCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: _procCancelEdit,
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('หัตถการที่ทำ',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text((_procEdit ?? -1) < 0 ? 'เพิ่มหัตถการ' : 'แก้หัตถการ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// เลือก Order set จากรายการ แล้วลงทั้งชุด
  Future<void> _procPickOrderSet() async {
    final names = {
      for (final t in _procOrderSets)
        '${t.$1} · ${t.$2.length} หัตถการ  (${t.$2.map((x) => x.$1.split(' (').first).join(', ')})':
            t
    };
    final picked = await _listSheet('เทมเพลตหัตถการ', names.keys.toList());
    if (picked == null || !mounted) return;
    _procApplyOrderSet(names[picked]!);
  }

  /// หน้ารายการหัตถการ (design language เดียวกับการ์ด Diagnosis Text):
  /// การ์ดหัว + คำอธิบาย · แผ่นปุ่มลัด เพิ่ม | Order set · แถวรายการ (ชื่อ · ผู้ทำ เวลา · รหัส ICD9 ไม่มีเลขลำดับ)
  Widget _procListPage() {
    final items = _procItems();
    final codes = _icd9Codes;
    return ListView(
      key: const ValueKey('proc-list'),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 96.0),
      children: [
        _dxCard(
          'หัตถการที่ทำ',
          'ลงได้หลายรายการ หรือเลือกจากเทมเพลต',
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 0.0, 0.0),
            // hero เดียวกับหน้ากิจกรรมพยาบาล (มือสวมถุงมือ)
            child: _dxArtFade(Image.asset('assets/images/er_hero_nurse_act.png',
                fit: BoxFit.contain, alignment: Alignment.bottomRight)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _dxTiles([
              (Icons.add_rounded, 'เพิ่ม', () => _procOpen(null)),
              (Icons.post_add_rounded, 'เทมเพลต', _procPickOrderSet),
            ]),
            for (final (i, m) in items.indexed)
              _gListRow(
                first: i == 0,
                inset: 8.0,
                titleLines: 2,
                title: m['proc'] ?? '-',
                // บรรทัดรอง = รหัส ICD-9 + เวลา · ขวาสุด = รูปหน้าผู้ทำ/ผู้ช่วยซ้อนกัน
                sub: [
                  if (codes[m['icd']] case final c?) c,
                  if (m['at'] case final a?) a,
                ].join('  '),
                onTap: () => _procOpen(i),
                trail: () {
                  final ppl = [
                    for (final k in const ['doer', 'assist'])
                      for (final x in (m[k] ?? '').split('\n'))
                        if (x.trim().isNotEmpty) x.trim()
                  ];
                  return ppl.isEmpty ? null : _procFaces(ppl);
                }(),
              ),
          ]),
        ),
      ],
    );
  }

  /// หน้าย่อยแก้หัตถการ (design language เดียวกับหน้าแก้รหัส ICD-10):
  /// การ์ดขาวขอบเทา มุม 16 · หัวการ์ด 16 หนา · แถวแบบรายการ (ชื่อซ้าย ค่าขวา ลูกศร)
  /// รายละเอียด = ช่องพิมพ์พื้นเทาอ่อนแบบหน้าแก้ Diagnosis Text · ลบ = ปุ่ม tonal แดงจาง
  Widget _procPage() {
    if (_procEdit == null) return _procListPage();
    _procDefaults();
    final f = _filled[_speechStep];
    final proc = f[_procLabel];
    final icd = f[_icd9Label];
    final code = icd == null ? null : _icd9Codes[icd];
    final assists = _procAssists;
    final doers = [
      for (final d in (f[_procDoerLabel] ?? '').split('\n'))
        if (d.trim().isNotEmpty) d.trim()
    ];
    Widget card(String title, List<Widget> kids, {Widget? action}) => Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 6.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                ),
                if (action != null) action,
              ]),
            ),
            ...kids,
          ]),
        );
    return ListView(
      key: ValueKey('proc-edit-$_procEdit'),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 96.0),
      children: [
        card('หัตถการ', [
          _procRow('ชื่อหัตถการ', proc,
              first: true,
              placeholder: 'เลือกหัตถการ',
              onTap: () => _procFlow(0)),
          _procRow('ICD-9-CM', icd,
              lead: code, placeholder: 'เลือกรหัส', onTap: () => _procFlow(1)),
          _procRow('วันที่ทำ', f[_procAtLabel],
              placeholder: 'เลือกวันเวลา', onTap: _procPickAt),
        ]),
        card('ผู้ดูแลหัตถการ', [
          _procRow('ผู้สั่ง', f[_procByLabel],
              first: true,
              faces: f[_procByLabel] == null
                  ? null
                  : _procFaces([f[_procByLabel]!]),
              placeholder: 'เลือกแพทย์',
              onTap: () => _procFlow(2)),
          // ผู้ทำหลายคน (เก็บบรรทัดละคน): แถวเดียว รูปหน้าซ้อนกัน + ชื่อคนแรก และอีก n คน
          // แตะ = เปิด sheet เลือก/เอาออก
          _procRow('ผู้ทำ', doers.isEmpty ? null : _procPersonName(doers.first),
              placeholder: 'เลือกผู้ทำ',
              // คนเดียว = บทบาท · หลายคน = และอีก n คน
              sub: doers.length > 1
                  ? 'และอีก ${doers.length - 1} คน'
                  : doers.isEmpty
                      ? null
                      : _procPersonRole(doers.first),
              faces: doers.isEmpty ? null : _procFaces(doers),
              onTap: () => _procFlow(3)),
          // ผู้ช่วย: แถวเดียวแบบผู้ทำ (เลือก/สลับบทบาทใน sheet ผู้ทำ)
          if (assists.isNotEmpty)
            _procRow('ผู้ช่วย', _procPersonName(assists.first),
                sub: assists.length > 1
                    ? 'และอีก ${assists.length - 1} คน'
                    : _procPersonRole(assists.first),
                faces: _procFaces(assists),
                onTap: () => _procFlow(3)),
        ]),
        // รายละเอียด: ไม่มีการ์ดครอบ · หัวข้อ + ช่องพิมพ์ตรง ๆ (แบบหน้าแก้ Diagnosis Text)
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 8.0),
          child: Text('รายละเอียด',
              style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 16.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96.0),
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _line, width: 0.5),
            ),
            child: _inlineInput(_procNoteLabel, f[_procNoteLabel],
                hint: 'เช่น ทำแผลอุบัติเหตุบริเวณหัวเข่า',
                maxLines: 8,
                style: _t(15.0,
                    color: _inkTitle, weight: FontWeight.w500, height: 1.45),
                hintStyle: _t(14.0, color: _ink3)),
          ),
        ),
        // แก้รายการเดิม: ปุ่มลบ (tonal แดงจาง เต็มกว้าง แบบหน้าย่อยวินิจฉัย)
        if (_procEdit! >= 0)
          TextButton.icon(
            onPressed: () => _procDelete(_procEdit!),
            style: TextButton.styleFrom(
              foregroundColor: _red,
              backgroundColor: _red.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              minimumSize: const Size(0.0, 48.0),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
            label: Text('ลบหัตถการนี้',
                style: _t(14.0, color: _red, weight: FontWeight.w600)),
          ),
      ],
    );
  }

  /// เลือกต่อเนื่องใน sheet เดียว (แบบ sheet วัด V/S): ชื่อหัตถการ → ICD-9-CM → ผู้สั่ง → ผู้ทำ
  /// เริ่มจากแถวที่แตะ · ถัดไป = ช่องที่ยังว่าง
  Future<void> _procFlow(int from) {
    final f = _filled[_speechStep];
    List<String> lines(String k) => [
          for (final x in (f[k] ?? '').split('\n'))
            if (x.trim().isNotEmpty) x.trim()
        ];
    _ListStep st(String label, String table, String short,
            {Map<String, String>? codes,
            List<String>? opts,
            bool people = false,
            bool many = false,
            bool confirm = false}) =>
        _ListStep(label, opts ?? [for (final it in _procMaster(table)) it.name],
            codes: codes,
            short: short,
            people: people,
            many: many,
            confirm: confirm,
            current: () => f[label],
            apply: (o) => _applyPick(label, o));
    final steps = [
      st(_procLabel, 'er_procedure', 'หัตถการ'),
      // รหัสเติมตามหัตถการ (pre-select) · ถัดไปหยุดให้ยืนยันทุกครั้ง
      st(_icd9Label, 'er_icd9cm', 'ICD-9-CM', codes: _icd9Codes, confirm: true),
      st(_procByLabel, 'er_doctor', 'ผู้สั่ง', opts: _dxDoctors, people: true),
      // ผู้ทำ + ผู้ช่วย ใน sheet เดียว: เลือกแล้วสลับบทบาทได้ท้ายแถว
      _ListStep('ผู้ทำและผู้ช่วย',
          [for (final it in _procMaster('er_staff')) it.name],
          short: 'ผู้ทำ',
          people: true,
          many: true,
          tags: const ['ผู้ทำ', 'ผู้ช่วย'],
          tagOf: (o) => lines(_procDoerLabel).contains(o)
              ? 'ผู้ทำ'
              : lines(_procAssistLabel).contains(o)
                  ? 'ผู้ช่วย'
                  : null,
          setTag: (o, t) => setState(() {
                final d = lines(_procDoerLabel)..remove(o);
                final a = lines(_procAssistLabel)..remove(o);
                if (t == 'ผู้ทำ') d.add(o);
                if (t == 'ผู้ช่วย') a.add(o);
                f[_procDoerLabel] = d.join('\n');
                f[_procAssistLabel] = a.join('\n');
              }),
          current: () => f[_procDoerLabel],
          apply: (_) {}),
    ];
    return _listFlow(steps.sublist(from));
  }

  /// หนึ่งแถวในการ์ด (แบบแถวรายการหน้าแก้ ICD-10): ชื่อช่องซ้าย · ค่าชิดขวา (+ บรรทัดรอง)
  /// เส้นคั่นบางระหว่างแถว · ลูกศรเทา (แตะเลือก) หรือ ✕ (เอาออก) · add = แถวเพิ่มสีกรมท่า
  Widget _procRow(String label, String? value,
          {String? placeholder,
          String? sub,
          String? lead,
          Widget? faces,
          bool first = false,
          bool add = false,
          VoidCallback? onTap,
          VoidCallback? remove}) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        if (!first)
          const Divider(height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 10.0, 4.0, 10.0),
                child: Row(children: [
                  if (add) ...[
                    const Icon(Icons.add_rounded, size: 20.0, color: _blue),
                    const SizedBox(width: 8.0),
                    Text(label,
                        style: _t(14.0, color: _blue, weight: FontWeight.w600)),
                    const Spacer(),
                  ] else ...[
                    Text(label,
                        style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                    const SizedBox(width: 12.0),
                    // รูปหน้า (ถ้ามี) ซ้ายของชื่อ ชิดขวาไปด้วยกัน
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (faces != null) ...[
                              faces,
                              const SizedBox(width: 10.0),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text.rich(
                                      TextSpan(children: [
                                        if (lead != null && value != null)
                                          TextSpan(
                                              text: '$lead  ',
                                              style: _num(14.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w700)),
                                        TextSpan(
                                            text: value ?? placeholder ?? ''),
                                      ]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: _t(14.0,
                                          color:
                                              value == null ? _ink3 : _inkTitle,
                                          weight: value == null
                                              ? FontWeight.w500
                                              : FontWeight.w600)),
                                  if (sub != null && sub.isNotEmpty)
                                    Text(sub,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _t(12.0,
                                            color: _ink3,
                                            weight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  if (remove != null)
                    IconButton(
                      onPressed: remove,
                      iconSize: 18.0,
                      constraints:
                          const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                      icon: const Icon(Icons.close_rounded, color: _ink3),
                    )
                  else if (!add)
                    const Icon(Icons.chevron_right_rounded,
                        size: 22.0, color: _ink3),
                ]),
              ),
            ),
          ),
        ),
      ]);
}
