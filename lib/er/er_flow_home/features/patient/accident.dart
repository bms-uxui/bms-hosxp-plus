// ignore_for_file: invalid_use_of_protected_member

part of '../../er_flow_home_widget.dart';

// เตรียมบันทึกข้อมูลอุบัติเหตุ (ปุ่ม "อุบัติเหตุ" บนการ์ดผู้ป่วย ช่วงหลังการตรวจ)

// ตัวเลือกใช้ master accident_* เดิม ช่องดูแลก่อนมาถึงรองรับข้อความเพิ่มเติม

// แสดงข้อมูลเหตุการณ์และปัจจัยเสี่ยงครบ โดยไม่ซ่อนตามประเภทอุบัติเหตุ

/// กลุ่มช่องของฟอร์ม: (หัวข้อ, ไอคอน, [(ชื่อช่อง, id ตาราง master)])

const List<(String, IconData, List<(String, String)>)> _accGroups = [
  (
    'เหตุการณ์',
    Icons.place_rounded,
    [
      ('ประเภทอุบัติเหตุ', 'accident_type'),
      ('ยานพาหนะ', 'accident_vehicle_type'),
      ('สถานที่เกิดเหตุ', 'accident_place_type'),
      ('จุดเกิดเหตุ', ''),
      ('ประเภทผู้บาดเจ็บ', 'accident_person_type'),
      ('ทะเบียนรถ', ''),
    ],
  ),
  (
    'ปัจจัยเสี่ยง',
    Icons.shield_outlined,
    [
      ('แอลกอฮอล์', 'accident_alcohol_type'),
      ('สารเสพติด', 'accident_drug_type'),
      ('เข็มขัดนิรภัย', 'accident_belt_type'),
      ('หมวกนิรภัย', 'accident_helmet_type'),
    ],
  ),
  (
    'การดูแลก่อนมาถึง',
    Icons.health_and_safety_rounded,
    [
      ('การดูแลการหายใจ', 'accident_airway_type'),
      ('การห้ามเลือด', 'accident_bleed_type'),
      ('การให้ IV fluid', 'accident_fluid_type'),
      ('การใส่ Splint/Slab', 'accident_splint_type'),
      ('การ Immobilize C-spine', 'accident_cspine_type'),
    ],
  ),
  ('หมายเหตุ', Icons.notes_rounded, [('หมายเหตุ', '')]),
];

const String _accWhen = 'วันที่/เวลาเกิดเหตุ';

/// การ์ดบนสุดของหน้าเหตุการณ์: เล่าเหตุการณ์ให้ AI จัดข้อมูล (ไม่บังคับ)
const String _accNarrTitle = 'เล่าเหตุการณ์';

// ช่องเสริม (ข้อมูลการมา · Trauma · หมายเหตุการดูแลก่อนมาถึง) แยกจาก _accGroups
// เพื่อไม่เปลี่ยน schema ที่ส่งให้ AI จัดข้อมูล · ยังไม่คำนวณ Trauma Score อัตโนมัติ
const String _accArrivalTitle = 'ข้อมูลการมา';
const List<(String, String)> _accArrival = [
  ('ประเภทการมา', 'er_arrival_type'),
  ('มาจากหน่วยบริการ', 'er_refer_from_hospital_type'),
  ('ผู้นำส่ง', 'er_bringer'),
];
const String _accTraumaTitle = 'สัญญาณชีพ / Trauma';
const String _accAisTable = 'accident_ais_severity';
const List<String> _accRegions = [
  'HEAD/NECK',
  'FACE',
  'THORAX',
  'ABDOMEN/PELVIC CONTENTS',
  'EXTREMITIES/PELVIC GIRDLE',
  'EXTERNAL',
];

/// ส่วนของร่างกาย (AIS) → (ชื่อไทย, ภาพประกอบชุดเดียวกับการ์ดระบบของตรวจร่างกาย)
const Map<String, (String, String)> _accRegionArt = {
  'HEAD/NECK': ('ศีรษะและคอ', 'assets/images/er_pe_sys_heent.png'),
  'FACE': ('ใบหน้า', 'assets/images/er_ros_sys_ent.png'),
  'THORAX': ('ทรวงอก', 'assets/images/er_pe_sys_chest.png'),
  'ABDOMEN/PELVIC CONTENTS': (
    'ช่องท้องและอุ้งเชิงกราน',
    'assets/images/er_pe_sys_abdomen.png'
  ),
  'EXTREMITIES/PELVIC GIRDLE': (
    'แขนขาและกระดูกเชิงกราน',
    'assets/images/er_pe_sys_extremities.png'
  ),
  'EXTERNAL': ('ผิวหนังภายนอก', 'assets/images/er_pe_sys_ga.png'),
};

/// ชื่อสั้นใต้เหรียญ AIS 1–6
const Map<int, String> _accAisShort = {
  1: 'เล็กน้อย',
  2: 'ปานกลาง',
  3: 'รุนแรง',
  4: 'รุนแรงมาก',
  5: 'วิกฤต',
  6: 'สูงสุด',
};

const List<String> _accScores = ['GCS.v', 'BPs', 'RR', 'RTS', 'ISS', 'PS'];

/// ช่องที่คำนวณอัตโนมัติ (แสดงอย่างเดียว)
const Set<String> _accComputed = {'RTS', 'ISS'};

// ---------------------------------------------------------------------------
// Trauma Scoring (Prototype) · ยังไม่มี logic เดิมในโปรเจกต์ จึงแยกฟังก์ชันไว้ตรงนี้
// ---------------------------------------------------------------------------

/// เลข AIS จากค่าที่เลือก เช่น "AIS 3 · รุนแรง (ไม่คุกคามชีวิต)" → 3
int? _accAisOf(String? value) {
  final m = RegExp(r'^AIS (\d)').firstMatch(value ?? '');
  return m == null ? null : int.parse(m.group(1)!);
}

/// ISS = ผลรวมกำลังสองของ AIS 3 ค่าสูงสุด (a² + b² + c²)
/// ตามนิยาม ISS: มี AIS 6 ตำแหน่งใดก็ตาม = 75 · ยังไม่เลือก AIS เลย = null
int? _accIss(Iterable<int?> ais) {
  final scores = ais.whereType<int>().toList()..sort((a, b) => b - a);
  if (scores.isEmpty) return null;
  if (scores.first == 6) return 75;
  return scores.take(3).fold<int>(0, (sum, a) => sum + a * a);
}

/// Revised Trauma Score (Champion 1989)
/// RTS = 0.9368·GCS(code) + 0.7326·SBP(code) + 0.2908·RR(code)
/// ต้องมีครบทั้ง GCS รวม (3–15), SBP และ RR มิฉะนั้น = null
double? _accRts(int? gcs, double? sbp, double? rr) {
  if (gcs == null || sbp == null || rr == null) return null;
  if (gcs < 3 || gcs > 15 || sbp < 0 || rr < 0) return null;
  final gcsCode = gcs >= 13
      ? 4
      : gcs >= 9
          ? 3
          : gcs >= 6
              ? 2
              : gcs >= 4
                  ? 1
                  : 0;
  final sbpCode = sbp > 89
      ? 4
      : sbp >= 76
          ? 3
          : sbp >= 50
              ? 2
              : sbp >= 1
                  ? 1
                  : 0;
  final rrCode = rr > 29
      ? 3
      : rr >= 10
          ? 4
          : rr >= 6
              ? 2
              : rr >= 1
                  ? 1
                  : 0;
  return 0.9368 * gcsCode + 0.7326 * sbpCode + 0.2908 * rrCode;
}

/// ระดับความรุนแรงของคะแนน Trauma (knowledge ข้อ 71) → (โทนเหรียญ 1–6, คำอธิบาย)
/// โทน 1–2 = กรมท่า (ไม่รุนแรง) · 4–6 = แดง (สีโผล่เมื่อผิดปกติเท่านั้น)
/// ISS: 1–8 เล็กน้อย · 9–15 ปานกลาง · 16–24 รุนแรง (major trauma) · ≥ 25 วิกฤต
(int, String)? _accIssTone(String? v) {
  final n = int.tryParse((v ?? '').trim());
  if (n == null) return null;
  if (n >= 25) return (6, 'วิกฤต · Major trauma');
  if (n >= 16) return (4, 'รุนแรง · Major trauma');
  if (n >= 9) return (2, 'ปานกลาง');
  return (1, 'เล็กน้อย');
}

/// RTS (0–7.84 ยิ่งต่ำยิ่งรุนแรง): 7.84 ปกติ · 4–7.83 ผิดปกติ · < 4 วิกฤต (ส่ง Trauma center)
(int, String)? _accRtsTone(String? v) {
  final x = double.tryParse((v ?? '').trim());
  if (x == null) return null;
  if (x < 4.0) return (6, 'วิกฤต · ส่ง Trauma center');
  if (x < 7.84) return (4, 'ผิดปกติ');
  return (1, 'ปกติ');
}

/// คำนวณ ISS / RTS ใหม่จากค่าในฟอร์ม (เรียกทุกครั้งที่ฟอร์ม rebuild = real-time)
void _accRecalc(Map<String, String> v) {
  void put(String key, String? value) =>
      value == null ? v.remove(key) : v[key] = value;
  put('ISS',
      _accIss([for (final r in _accRegions) _accAisOf(v[r])])?.toString());
  put(
      'RTS',
      _accRts(
              int.tryParse((v['GCS.v'] ?? '').trim()),
              double.tryParse((v['BPs'] ?? '').trim()),
              double.tryParse((v['RR'] ?? '').trim()))
          ?.toStringAsFixed(2));
}

const String _accPreNote = 'หมายเหตุการดูแลก่อนมาถึง';
const List<String> _accExtraLabels = [
  'ประเภทการมา',
  'มาจากหน่วยบริการ',
  'ผู้นำส่ง',
  ..._accRegions,
  ..._accScores,
  _accPreNote,
];

const String _accTypeLabel = 'ประเภทอุบัติเหตุ';

const Set<String> _accEditableSelects = {
  'การดูแลการหายใจ',
  'การห้ามเลือด',
  'การให้ IV fluid',
  'การใส่ Splint/Slab',
  'การ Immobilize C-spine',
};

/// ช่องบังคับก่อนบันทึก

const List<String> _accRequired = [
  _accWhen,
  'สถานที่เกิดเหตุ',
  _accTypeLabel,
];

/// ข้อมูลอุบัติเหตุที่บันทึกแล้วของแต่ละ HN (เก็บในหน่วยความจำ)

final Map<String, Map<String, String>> _accStore = {};

/// ร่างที่ยังไม่กดบันทึก (ปิดหน้าต่างแล้วเปิดใหม่ ค่าที่กรอกไว้ยังอยู่)

final Map<String, Map<String, String>> _accDrafts = {};

final Map<String, String> _accNarratives = {};

/// ค่าในฟอร์มที่กำลังกรอกอยู่ (map ตัวเดียวกับในฟอร์ม) · แผงซ้ายอ่านค่านี้แสดงแบบ real-time
final Map<String, Map<String, String>> _accLive = {};

/// เพิ่มทุกครั้งที่ฟอร์มอุบัติเหตุ rebuild = แผงซ้ายวาดใหม่ตามค่าล่าสุด
final ValueNotifier<int> _accLiveTick = ValueNotifier(0);

extension _FeaturesPatientAccidentPart on _ErFlowHomeWidgetState {
  Widget _accLabel(String label, {bool must = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text.rich(TextSpan(children: [
          TextSpan(
              text: label,
              style: _t(11.5, color: _ink2, weight: FontWeight.w700)),
          if (must)
            TextSpan(
                text: ' *',
                style: _t(11.5, color: _red, weight: FontWeight.w700)),
        ])),
      );

  bool _accSaved(String hn) => _accStore[hn]?.isNotEmpty ?? false;

  /// ตัวเลือกแบบ popover เกาะใต้ช่อง (เฉพาะ Accident) · กว้างเท่าช่อง สูงจำกัด
  /// เลื่อนในรายการ · รายการยาว (> 8) มีช่องค้นหา · คืนค่าที่เลือก (null = ปิด)
  Future<String?> _accPicker(
      BuildContext anchor, String label, List<String> opts,
      {String? current}) {
    final box = anchor.findRenderObject() as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final screen = MediaQuery.sizeOf(context);
    final width =
        rect.width.clamp(240.0, math.min(420.0, screen.width - 24)).toDouble();
    final search = opts.length > 8;
    // วางใต้ช่อง ถ้าที่ไม่พอ → วางเหนือช่อง
    final below = screen.height - rect.bottom - 16;
    final above = rect.top - 16;
    final down = below >= 240 || below >= above;
    final maxH = math.min(340.0, (down ? below : above) - 6);
    final left = rect.left.clamp(12.0, screen.width - width - 12).toDouble();
    var query = '';
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ปิด',
      barrierColor: Colors.black.withValues(alpha: 0.04),
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, _, __) => Stack(children: [
        Positioned(
          left: left,
          width: width,
          top: down ? rect.bottom + 4 : null,
          bottom: down ? null : screen.height - rect.top + 4,
          child: Material(
            color: _panel,
            elevation: 8,
            shadowColor: const Color(0x330B1B3F),
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: StatefulBuilder(builder: (ctx, set) {
                final q = query.trim().toLowerCase();
                final shown = [
                  for (final o in opts)
                    if (q.isEmpty || o.toLowerCase().contains(q)) o,
                ];
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  if (search)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: TextField(
                        autofocus: true,
                        onChanged: (s) => set(() => query = s),
                        style: _t(12),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'ค้นหา',
                          prefixIcon: const Icon(Icons.search_rounded,
                              size: 18, color: _ink3),
                          filled: true,
                          fillColor: _panelSoft,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  Flexible(
                    child: shown.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text('ไม่พบรายการ',
                                style: _t(11, color: _ink3)),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            children: [
                              for (final o in shown)
                                Semantics(
                                  button: true,
                                  selected: o == current,
                                  label: o,
                                  child: InkWell(
                                    onTap: () => Navigator.of(ctx).pop(o),
                                    child: Container(
                                      // สูง ≥ 44 กดบน Tablet สะดวก
                                      constraints:
                                          const BoxConstraints(minHeight: 44),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: o == current
                                            ? _blue.withValues(alpha: 0.09)
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(children: [
                                        Expanded(
                                          child: Text(o,
                                              style: _t(12,
                                                  color: o == current
                                                      ? _blue
                                                      : _inkTitle,
                                                  weight: o == current
                                                      ? FontWeight.w700
                                                      : FontWeight.w500)),
                                        ),
                                        if (o == current)
                                          const Icon(Icons.check_rounded,
                                              size: 17, color: _blue),
                                      ]),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ]);
              }),
            ),
          ),
        ),
      ]),
    );
  }

  List<ErFillField> _accSchema() => [
        const ErFillField(_accWhen, custom: true),
        for (final (_, _, fields) in _accGroups)
          for (final (label, table) in fields)
            ErFillField(label,
                options: _accOptions(table),
                custom: table.isEmpty || _accEditableSelects.contains(label)),
      ];

  List<String> _accLabels() => [for (final field in _accSchema()) field.id];

  List<String> _accOptions(String table) => [
        for (final it in ErMaster.maybe?.table(table)?.activeItems ??
            const <ErMasterItem>[])

          // AIS: เลือกได้ 1–6 · เลขคะแนนนำหน้า อ่านระดับได้ทันที
          if (table != _accAisTable || it.code != '0')
            table == _accAisTable ? 'AIS ${it.code} · ${it.name}' : it.name
      ];

  String _accNow(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/'
      '${t.year + 543} ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')} น.';

  /// ฟอร์มบันทึกอุบัติเหตุของผู้ป่วย p แบบ dialog
  Future<void> _openAccident(_P p) async {
    final (form, close) = _accidentForm(p,
        done: (_) => Navigator.of(context, rootNavigator: true).pop());
    await showDialog<void>(context: context, builder: (_) => form);
    // ปิดด้วยการแตะนอก dialog = ปิดโดยไม่บันทึก (ปิดจากปุ่มแล้วจะไม่ทำซ้ำ)
    close(false, false);
  }

  /// เนื้อหาฟอร์มอุบัติเหตุ ใช้ได้ทั้งใน dialog และใน workflow panel (embedded)
  /// คืนตัวฟอร์ม + ฟังก์ชันปิด (save, notify) · done ถูกเรียกเมื่อกดปิด/บันทึกจากในฟอร์ม
  /// เก็บ widget ตัวเดิมไว้ใช้ซ้ำ สถานะในฟอร์มจึงไม่หายตอน rebuild
  (Widget, void Function(bool save, [bool notify])) _accidentForm(_P p,
      {required void Function(bool save) done, bool embedded = false}) {
    final c = erCaseOf(p.hn);

    final v = {...?(_accDrafts[p.hn] ?? _accStore[p.hn])};

    // ค่าตั้งต้น Trauma จากข้อมูลผู้ป่วยที่มีอยู่ (แก้ได้ในฟอร์ม)
    if (c.gcsScore != '-') v.putIfAbsent('GCS.v', () => c.gcsScore);
    if (c.sbp.isNotEmpty) v.putIfAbsent('BPs', () => '${c.sbp.last.round()}');
    if (c.rr.isNotEmpty) v.putIfAbsent('RR', () => '${c.rr.last.round()}');

    final narrative = TextEditingController(text: _accNarratives[p.hn] ?? '');

    // แผงซ้ายแสดงข้อมูลที่กำลังบันทึก (แบบขั้นอื่นที่ซ้ายเปิดหน้าข้อมูลของขั้นนั้น)
    _accLive[p.hn] = v;
    if (embedded) _detailTab = _accTab;

    var extracting = false;
    var applying = false;
    var sourceRevision = 0;

    var showAllCoverage = false;

    // ฟอร์มแบบหน้า (แบบเดียวกับขั้นใน workflow panel):
    // 0 = หน้าแนะนำ · 1 = เล่าเหตุการณ์ · 2.. = หมวด · หน้าสุดท้าย = สรุปก่อนบันทึก
    // fwd = ทิศเปลี่ยนหน้า (ไปข้างหน้าเลื่อนซ้าย ย้อนกลับเลื่อนขวา)
    var page = 0;
    var fwd = true;

    // หน้า AIS: ส่วนของร่างกายที่กางเลือกระดับอยู่ (แบบการ์ดระบบของตรวจร่างกาย)
    String? aisOpen;

    String? extractionMessage;

    // ผลวิเคราะห์ล่าสุดจากปุ่ม "ให้ AI จัดข้อมูล"
    // แยกจาก Form State จนกว่าผู้ใช้จะเลือกและกดนำข้อมูลไปกรอก
    List<ErCoverage>? analyzedCoverage;
    List<ErFillSuggestion>? analyzedSuggestions;
    final selectedSuggestions = <int>{};
    String? analyzedSource;
    Map<String, String>? analyzedSnapshot;

    // จุดเกาะ popover ของช่องที่พิมพ์เองหรือเลือกจากรายการได้
    final fieldKeys = <String, GlobalKey>{};

    final textControllers = {
      for (final label in [
        'จุดเกิดเหตุ',
        'ทะเบียนรถ',
        'หมายเหตุ',
        ..._accEditableSelects,
        ..._accScores,
        _accPreNote,
      ])
        label: TextEditingController(text: v[label] ?? ''),
    };

    var closed = false;
    void close(bool save, [bool notify = true]) {
      if (closed) return;
      closed = true;
      _accLive.remove(p.hn);
      _accLiveTick.value++;
      if (notify) done(save);
      // รอ animation ปิดจบก่อนคืน controller
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        narrative.dispose();
        for (final controller in textControllers.values) {
          controller.dispose();
        }
      });
      _accFinish(p, v, save);
    }

    final form = StatefulBuilder(builder: (ctx, set) {
      _accRecalc(v);
      WidgetsBinding.instance.addPostFrameCallback((_) => _accLiveTick.value++);

      final schema = _accSchema();

      final coverage = analyzedCoverage ?? const <ErCoverage>[];
      final suggestions = analyzedSuggestions ?? const <ErFillSuggestion>[];

      final foundCoverage = coverage
          .where((item) => item.status == ErCoverageStatus.found)
          .length;
      final reviewCoverage = coverage
          .where((item) => item.status == ErCoverageStatus.needsReview)
          .length;
      final visibleCoverage =
          showAllCoverage ? coverage : coverage.take(8).toList(growable: false);

      final applicableSuggestionIndexes = <int>[
        for (var i = 0; i < suggestions.length; i++)
          if (suggestions[i].applicable) i,
      ];

      final hasAnalysis = analyzedSource != null &&
          analyzedSource == narrative.text.trim() &&
          analyzedCoverage != null &&
          analyzedSuggestions != null;

      final missing = [
        for (final l in _accRequired)
          if ((v[l] ?? '').isEmpty) l
      ];

      Future<void> analyzeNarrative() async {
        if (extracting || narrative.text.trim().isEmpty) return;

        final source = narrative.text.trim();
        final revision = sourceRevision;
        final snapshot = Map<String, String>.of(v);

        set(() {
          extracting = true;
          extractionMessage = null;
          analyzedCoverage = null;
          analyzedSuggestions = null;
          analyzedSource = null;
          analyzedSnapshot = null;
          selectedSuggestions.clear();
          showAllCoverage = false;
        });

        try {
          final extracted = await ErSmartFill.extract(source, schema);
          if (!ctx.mounted) return;
          final mergedCoverage =
              ErSmartFill.analyzedCoverage(source, schema, extracted);

          if (revision != sourceRevision || source != narrative.text.trim()) {
            set(() {
              extractionMessage =
                  'ข้อความมีการเปลี่ยนแปลงระหว่างวิเคราะห์ · กรุณากดให้ AI จัดข้อมูลใหม่';
            });
            return;
          }

          set(() {
            analyzedSource = source;
            analyzedSnapshot = snapshot;
            analyzedCoverage = mergedCoverage;
            analyzedSuggestions = extracted;
            selectedSuggestions.clear();

            final fillable = extracted.where((item) => item.applicable).length;
            extractionMessage = fillable > 0
                ? 'AI วิเคราะห์แล้ว · พบข้อมูลที่สามารถนำไปกรอกได้ $fillable รายการ'
                : 'AI วิเคราะห์แล้ว · ยังไม่พบข้อมูลที่สามารถนำไปกรอกอัตโนมัติได้';
          });
        } catch (_) {
          if (ctx.mounted) {
            set(() {
              extractionMessage =
                  'วิเคราะห์ไม่สำเร็จ · ตรวจการเชื่อมต่อบริการ AI แล้วลองใหม่';
            });
          }
        } finally {
          if (ctx.mounted) set(() => extracting = false);
        }
      }

      // ตั้งข้อความเล่าเหตุการณ์ใหม่ (คัดลอกจากคัดกรอง / หน้าพิมพ์) · ผลวิเคราะห์เดิม stale
      void setNarrative(String text) => set(() {
            sourceRevision++;
            if (narrative.text != text) narrative.text = text;
            _accNarratives[p.hn] = text;
            extractionMessage = null;
            analyzedCoverage = null;
            analyzedSuggestions = null;
            analyzedSource = null;
            analyzedSnapshot = null;
            selectedSuggestions.clear();
            showAllCoverage = false;
          });

      // ผลวิเคราะห์ของ AI (แสดงใต้ข้อความในการ์ดเล่าเหตุการณ์)
      final aiResults =
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ก่อนกด "ให้ AI จัดข้อมูล" จะไม่แสดง Coverage หรือ Checkbox
        if (hasAnalysis) ...[
          const SizedBox(height: 10),
          Text(
            'พบข้อมูลแล้ว $foundCoverage · ยังขาดข้อมูล ${coverage.length - foundCoverage - reviewCoverage} · ต้องตรวจสอบ $reviewCoverage',
            style: _t(10.5, color: _ink2, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'แสดงหลักฐานจากข้อความเท่านั้น · กรอกเฉพาะเมื่อกดนำข้อมูลที่เลือกไปกรอก',
            style: _t(9.5, color: _ink3),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in visibleCoverage)
                Builder(builder: (context) {
                  final (icon, status, color, background) =
                      switch (item.status) {
                    ErCoverageStatus.found => (
                        Icons.check_circle_rounded,
                        'พบข้อมูลแล้ว',
                        _green,
                        _green.withValues(alpha: 0.08),
                      ),
                    ErCoverageStatus.needsReview => (
                        Icons.help_outline_rounded,
                        'ต้องตรวจสอบ',
                        _blue2,
                        _blue2.withValues(alpha: 0.08),
                      ),
                    ErCoverageStatus.missing => (
                        Icons.remove_circle_outline_rounded,
                        'ยังขาดข้อมูล',
                        _ink3,
                        _panelSoft,
                      ),
                  };
                  return Tooltip(
                    message: '${item.field} · $status',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        border: Border.all(
                          color: color.withValues(alpha: 0.22),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 13, color: color),
                          const SizedBox(width: 4),
                          Text(
                            item.field,
                            style: _t(
                              9.5,
                              color: color,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
          if (coverage.length > 8)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => set(() => showAllCoverage = !showAllCoverage),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  showAllCoverage ? 'ย่อ' : 'ดูทั้งหมด (${coverage.length})',
                  style: _t(10, color: _blue),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Text(
                'ข้อมูลที่สามารถนำไปกรอกได้',
                style: _t(
                  11.5,
                  color: _inkTitle,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${selectedSuggestions.length}/${applicableSuggestionIndexes.length} รายการ',
              style: _t(10, color: _ink3),
            ),
          ]),
          const SizedBox(height: 6),
          if (applicableSuggestionIndexes.isEmpty)
            Text(
              'ยังไม่มีข้อมูลที่สามารถนำไปกรอกอัตโนมัติได้',
              style: _t(10.5, color: _ink3),
            )
          else ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                TextButton(
                  style: _accLinkBtn,
                  onPressed: () => set(() {
                    selectedSuggestions
                      ..clear()
                      ..addAll(applicableSuggestionIndexes);
                  }),
                  child: Text('เลือกทั้งหมด',
                      style: _t(10.5, color: _blue, weight: FontWeight.w600)),
                ),
                TextButton(
                  style: _accLinkBtn,
                  onPressed: selectedSuggestions.isEmpty
                      ? null
                      : () => set(() {
                            selectedSuggestions.clear();
                          }),
                  child: Text('ล้างทั้งหมด',
                      style: _t(10.5,
                          color: selectedSuggestions.isEmpty ? _ink3 : _blue,
                          weight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final i in applicableSuggestionIndexes)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: _clyTileDeco(),
                child: CheckboxListTile(
                  // แถวกระทัดรัด: ช่องติ๊กเล็ก ระยะขอบแคบ
                  dense: true,
                  visualDensity:
                      const VisualDensity(horizontal: -4.0, vertical: -4.0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: selectedSuggestions.contains(i),
                  activeColor: _blue,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) => set(() {
                    if (checked == true) {
                      selectedSuggestions.add(i);
                    } else {
                      selectedSuggestions.remove(i);
                    }
                  }),
                  title: Text(
                    suggestions[i].field,
                    style: _t(11.0, color: _inkTitle, weight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestions[i].value,
                        style: _t(10.5, color: _blue, weight: FontWeight.w600),
                      ),
                      if (suggestions[i].status == ErFillStatus.needsReview)
                        Text(
                          'ต้องตรวจสอบ${suggestions[i].reason.isEmpty ? '' : ' · ${suggestions[i].reason}'}',
                          style: _t(9.5, color: _ink2),
                        ),
                      if (suggestions[i].evidence.isNotEmpty)
                        Text(
                          'จากข้อความ: “${suggestions[i].evidence}”',
                          style: _t(9.0, color: _ink3),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _apptPrimaryBtn(
                Icons.playlist_add_check_rounded,
                'นำข้อมูลที่เลือกไปกรอก (${selectedSuggestions.length})',
                selectedSuggestions.isEmpty || applying
                    ? null
                    : () async {
                        final snapshot = analyzedSnapshot;
                        final revision = sourceRevision;
                        if (snapshot == null || !hasAnalysis || applying) {
                          return;
                        }
                        set(() => applying = true);
                        Map<String, String>? reviewed;
                        try {
                          reviewed = await _accReviewFill(
                            suggestions,
                            Set<int>.of(selectedSuggestions),
                            snapshot,
                            v,
                          );
                        } finally {
                          if (ctx.mounted) set(() => applying = false);
                        }
                        if (reviewed == null ||
                            !ctx.mounted ||
                            revision != sourceRevision) {
                          return;
                        }
                        final applied = reviewed;

                        set(() {
                          v
                            ..clear()
                            ..addAll(applied);
                          for (final entry in textControllers.entries) {
                            entry.value.text = v[entry.key] ?? '';
                          }

                          // ค่าที่เพิ่งนำไปกรอกถือเป็น baseline ใหม่
                          // เพื่อไม่ให้การกดรอบถัดไปมองค่าที่เพิ่งใส่เป็น conflict ซ้ำ
                          analyzedSnapshot = Map<String, String>.of(v);
                          selectedSuggestions.clear();

                          extractionMessage =
                              'นำข้อมูลที่เลือกไปกรอกแล้ว · กรุณาตรวจทานก่อนบันทึก';
                        });
                      },
              ),
            ),
          ],
          for (final item in suggestions.where((item) => !item.applicable))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${item.field}: ${item.value} · ${item.reason} · กรุณาตรวจสอบและกรอกเอง',
                style: _t(10.5, color: _ink2),
              ),
            ),
        ],

        if (extractionMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Text(
              extractionMessage!,
              style: _t(12, color: _ink2),
            ),
          ),
      ]);

      // เปลี่ยนเฉพาะเวลา: คงวันที่เดิม (ยังไม่มีวันที่ = วันนี้) · เวลาเริ่ม = ปัจจุบัน
      Future<void> pickTime() async {
        final now = DateTime.now();
        final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})')
            .firstMatch(v[_accWhen] ?? '');
        final day = m == null
            ? now
            : DateTime(int.parse(m.group(3)!) - 543, int.parse(m.group(2)!),
                int.parse(m.group(1)!));
        final t = await showTimePicker(
            context: ctx,
            initialTime: m == null
                ? TimeOfDay.fromDateTime(now)
                : TimeOfDay(
                    hour: int.parse(m.group(4)!),
                    minute: int.parse(m.group(5)!)));
        if (t == null || !ctx.mounted) return;
        set(() => v[_accWhen] =
            _accNow(DateTime(day.year, day.month, day.day, t.hour, t.minute)));
      }

      Future<void> pickWhen() async {
        final now = DateTime.now();

        final d = await showDatePicker(
          context: ctx,
          initialDate: now,
          firstDate: now.subtract(const Duration(days: 30)),
          lastDate: now,
        );

        if (d == null || !ctx.mounted) return;

        final t = await showTimePicker(
            context: ctx, initialTime: TimeOfDay.fromDateTime(now));

        if (t == null) return;

        set(() => v[_accWhen] =
            _accNow(DateTime(d.year, d.month, d.day, t.hour, t.minute)));
      }

      bool hasValue(String label) => (v[label] ?? '').trim().isNotEmpty;

      Widget? clearAction(String label) => hasValue(label)
          ? IconButton(
              tooltip: 'ล้างค่า$label',
              onPressed: () => set(() {
                v.remove(label);

                textControllers[label]?.clear();
              }),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                foregroundColor: _ink3,
                hoverColor: _blue.withValues(alpha: 0.08),
                highlightColor: _blue.withValues(alpha: 0.12),
              ),
              icon: const Icon(Icons.clear_rounded, size: 15),
            )
          : null;

      Widget fieldHeading(String label) =>
          _accLabel(label, must: _accRequired.contains(label));

      // ไมค์เฉพาะข้อความยาว (หมายเหตุ) · ข้อมูลสั้น เช่น จุดเกิดเหตุ ทะเบียนรถ
      // หรือช่องเลือก พิมพ์/เลือกเองเร็วกว่า ไม่ต้องมี voice input
      // (เล่าเหตุการณ์ด้วยเสียงยังทำได้ที่ "บันทึกข้อมูลอิสระ")
      bool voiceUseful(String label) => label == 'หมายเหตุ';

      Widget field(String label, String table) {
        final opts = _accOptions(table);

        final cur = v[label];

        // ISS / RTS: คำนวณอัตโนมัติ แสดงอย่างเดียว
        if (_accComputed.contains(label)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                fieldHeading(label),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _blue.withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(cur ?? '—',
                          style:
                              _num(13, color: cur == null ? _ink3 : _inkTitle)),
                    ),
                    const Icon(Icons.calculate_rounded, size: 16, color: _blue),
                    const SizedBox(width: 4),
                    Text('คำนวณอัตโนมัติ', style: _t(9.5, color: _ink3)),
                  ]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldHeading(label),
              if (textControllers.containsKey(label))
                KeyedSubtree(
                    key: fieldKeys.putIfAbsent(label, GlobalKey.new),
                    child: _apptTextArea(
                        textControllers[label]!,
                        label == 'หมายเหตุ'
                            ? 'ระบุหมายเหตุเพิ่มเติม'
                            : label == _accPreNote
                                ? 'ระบุการดูแลอื่นก่อนมาถึง'
                                : _accScores.contains(label)
                                    ? (label == 'GCS.v'
                                        ? 'GCS รวม 3–15'
                                        : 'ระบุค่า $label')
                                    : _accEditableSelects.contains(label)
                                        ? 'เลือกจากรายการ หรือพิมพ์รายละเอียด'
                                        : label == 'จุดเกิดเหตุ'
                                            ? 'ระบุถนน / บริเวณที่เกิดเหตุ'
                                            : 'ระบุทะเบียนรถ',
                        minLines: label == 'หมายเหตุ'
                            ? 3
                            : (label == _accPreNote ? 2 : 1),
                        maxLines: label == 'หมายเหตุ'
                            ? 6
                            : (label == _accPreNote ? 4 : 1),
                        suffixIcon: voiceUseful(label) ||
                                _accEditableSelects.contains(label) ||
                                hasValue(label)
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                if (_accEditableSelects.contains(label))
                                  IconButton(
                                    tooltip: 'เลือกค่ามาตรฐาน$label',
                                    constraints: const BoxConstraints(
                                        minWidth: 44, minHeight: 44),
                                    icon: const Icon(Icons.expand_more_rounded,
                                        color: _ink3, size: 20),
                                    onPressed: opts.isEmpty
                                        ? null
                                        : () async {
                                            // เกาะกับช่องพิมพ์ทั้งช่อง (ไม่ใช่แค่ไอคอน)
                                            final field = fieldKeys[label]
                                                    ?.currentContext ??
                                                ctx;
                                            final picked = await _accPicker(
                                                field, label, opts,
                                                current: v[label]);

                                            if (picked == null ||
                                                !ctx.mounted) {
                                              return;
                                            }

                                            set(() {
                                              v[label] = picked;

                                              textControllers[label]!.value =
                                                  TextEditingValue(
                                                text: picked,
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: picked.length),
                                              );
                                            });
                                          },
                                  ),
                                if (voiceUseful(label))
                                  IconButton(
                                    tooltip: 'พูดเพื่อกรอก$label',
                                    constraints: const BoxConstraints(
                                        minWidth: 44, minHeight: 44),
                                    icon: const Icon(Icons.mic_none_rounded,
                                        color: _blue, size: 20),
                                    onPressed: () async {
                                      final result = await _voiceTextDialog(
                                        title: label,
                                        initial: textControllers[label]!.text,
                                        hint:
                                            'แตะไมค์เพื่อพูด หรือพิมพ์แก้ข้อความ',
                                        okText: 'ใช้ข้อความนี้',
                                        multiline: label == 'หมายเหตุ',
                                        autoMic: true,
                                      );

                                      if (result == null || !ctx.mounted)
                                        return;

                                      set(() {
                                        textControllers[label]!.text = result;

                                        if (result.isEmpty) {
                                          v.remove(label);
                                        } else {
                                          v[label] = result;
                                        }
                                      });
                                    },
                                  ),
                                if (hasValue(label)) ...[
                                  const SizedBox(width: 4),
                                  clearAction(label)!,
                                ],
                              ])
                            : null,
                        onChanged: (text) => set(() {
                              if (text.isEmpty) {
                                v.remove(label);
                              } else {
                                v[label] = text;
                              }
                            })))
              else if (opts.isEmpty)
                Text('ยังไม่มีรายการให้เลือก', style: _t(11, color: _ink3))
              else

                // Builder: ใช้ตำแหน่งช่องเป็นจุดเกาะของ popover
                Builder(
                  builder: (anchor) => _apptBox(cur ?? 'เลือก$label',
                      filled: cur != null,
                      icon: Icons.expand_more_rounded,
                      trailing: clearAction(label), onTap: () async {
                    final o =
                        await _accPicker(anchor, label, opts, current: cur);
                    if (o != null && ctx.mounted) set(() => v[label] = o);
                  }),
                ),
            ],
          ),
        );
      }

      // แถบคะแนน Trauma: กล่องใหญ่ 2 ใบเต็มกว้าง (ISS · RTS) ป้ายย่อซ้าย ชื่อเต็มใต้ ค่าตัวใหญ่ขวา
      // คำนวณได้ = พื้นฟ้าอ่อน ค่ากรมท่า · ยังคำนวณไม่ได้ = พื้นเทา ขีด + บอกว่าต้องกรอกอะไร
      Widget scoreBar() {
        // กล่องคะแนน: ชื่อย่อ + ระดับความรุนแรง ซ้าย · เหรียญคะแนนขวา (หมุนโผล่เมื่อค่าเปลี่ยน)
        // ไม่รุนแรง = พื้นฟ้าอ่อน · รุนแรง = พื้นแดงอ่อน (error container) ขอบแดงจาง
        Widget one(String k, (int, String)? tone, String need) {
          final val = v[k];
          final ok = tone != null;
          final bad = ok && tone.$1 >= 4;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 72.0,
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              decoration: BoxDecoration(
                color: !ok
                    ? _panelSoft
                    : bad
                        ? const Color(0xFFFCE8E6)
                        : _blue.withValues(alpha: 0.08),
                // มุม 16 เท่าการ์ดและแผ่นปุ่มในแผง workflow (_dxCard / _dxTiles)
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                    color: bad
                        ? _red.withValues(alpha: 0.25)
                        : Colors.transparent),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k,
                            style: _t(14.0,
                                color: !ok ? _ink2 : (bad ? _red : _blue),
                                weight: FontWeight.w700)),
                        Text(ok ? tone.$2 : need,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(11.5,
                                color: bad ? _red : _ink3,
                                weight: FontWeight.w600)),
                      ]),
                ),
                if (ok)
                  KeyedSubtree(
                    key: ValueKey('score-$k-$val'),
                    child: _PeStatusPop(
                        delay: Duration.zero,
                        child: _AisCoin(
                            level: tone.$1, size: 50.0, text: val!.trim())),
                  )
                else
                  Text('—',
                      style: _num(24.0, color: _ink3, weight: FontWeight.w700)),
              ]),
            ),
          );
        }

        return Row(children: [
          one('ISS', _accIssTone(v['ISS']), 'เลือก AIS เพื่อคำนวณ'),
          const SizedBox(width: 10.0),
          one('RTS', _accRtsTone(v['RTS']), 'กรอก GCS BP RR'),
        ]);
      }

      // วันเวลาเกิดเหตุ: ช่องแตะเลือก + ปุ่มนาฬิกา (เวลาปัจจุบัน)

      final when = Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            fieldHeading(_accWhen),

            // แตะช่อง = เลือกวัน+เวลา · ไอคอนนาฬิกาในช่อง = เลือกเฉพาะเวลา
            _apptBox(v[_accWhen] ?? 'เลือกวันที่และเวลา',
                filled: v[_accWhen] != null,
                icon: Icons.edit_calendar_rounded,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (clearAction(_accWhen) != null) clearAction(_accWhen)!,
                  IconButton(
                    tooltip: 'เลือกเวลา',
                    onPressed: pickTime,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.schedule_rounded,
                        size: 18, color: _blue),
                  ),
                ]),
                onTap: pickWhen),
          ],
        ),
      );

      // ตารางช่อง 1–3 คอลัมน์ตามพื้นที่จริง · minCol = ความกว้างต่ำสุดต่อช่อง
      // ช่องสั้น (ตัวเลข) ใช้ minCol แคบ → ได้ 3 คอลัมน์เร็วกว่า
      Widget fieldGrid(List<Widget> items, {double minCol = 240}) =>
          LayoutBuilder(builder: (context, bounds) {
            const gap = 14.0;
            final cols =
                ((bounds.maxWidth + gap) / (minCol + gap)).floor().clamp(1, 3);
            // ปัดลง กันผลรวมทศนิยมเกินความกว้างจนคอลัมน์สุดท้ายตกบรรทัด
            final w =
                ((bounds.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
            return Wrap(
              spacing: gap,
              children: [
                for (final item in items) SizedBox(width: w, child: item),
              ],
            );
          });

      int filled(Iterable<String> ls) => ls.where(hasValue).length;

      Widget subHeading(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(text.toUpperCase(),
                style: _t(10, color: _blue, weight: FontWeight.w700)),
          );

      // เนื้อหาแต่ละหมวดตาม schema เดิม (_accGroups) · ช่องเดิมครบทุกช่อง
      final groupBodies = <String, List<Widget>>{
        for (final (title, _, fields) in _accGroups)
          title: [
            fieldGrid([
              if (title == 'เหตุการณ์') when,
              for (final (l, table) in fields) field(l, table),
            ],
                // หมายเหตุ = ข้อความยาว เต็มแถวเสมอ
                minCol: title == 'หมายเหตุ' ? double.infinity : 240),
            if (title == 'การดูแลก่อนมาถึง') field(_accPreNote, ''),
          ],
      };
      List<String> groupLabels(String title) => [
            if (title == 'เหตุการณ์') _accWhen,
            for (final (t, _, fields) in _accGroups)
              if (t == title)
                for (final (l, _) in fields) l,
            if (title == 'การดูแลก่อนมาถึง') _accPreNote,
          ];
      IconData groupIcon(String title) =>
          _accGroups.firstWhere((g) => g.$1 == title).$2;

      // BPs / RR ที่ใช้คำนวณ RTS = ค่าในช่องด้านล่าง (ตั้งต้นจากสัญญาณชีพล่าสุด)
      final vitalsMissing = [
        if (!hasValue('BPs')) 'BPs',
        if (!hasValue('RR')) 'RR',
      ];

      final traumaBody = <Widget>[
        if (vitalsMissing.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    'ค่า ${vitalsMissing.join(' และ ')} ยังไม่มีการบันทึก · กรุณากรอกก่อนคำนวณ RTS',
                    style: _t(10.5, color: _red)),
              ),
            ]),
          ),
        subHeading('Body Region (AIS Score)'),
        fieldGrid([for (final r in _accRegions) field(r, _accAisTable)]),
        subHeading('Trauma Score'),
        fieldGrid([for (final s in _accScores) field(s, '')], minCol: 150),
      ];

      // ขั้นตอนของฟอร์ม: (ชื่อ, ไอคอน, เนื้อหา, ช่องทั้งหมด, ช่องที่ต้องครบก่อนไปต่อ)
      // "ต้องครบ" ใช้เฉพาะช่องเลือก (ไม่ใช่ช่องพิมพ์) จะได้ไม่ย่อหมวดระหว่างพิมพ์
      // หมวดที่ไม่มีช่องต้องครบ = ผู้ใช้กด "ถัดไป" เอง
      final steps =
          <(String, IconData, List<Widget>, List<String>, List<String>)>[
        (
          _accArrivalTitle,
          Icons.airport_shuttle_rounded,
          [
            fieldGrid([for (final (l, table) in _accArrival) field(l, table)],
                minCol: 180),
          ],
          [for (final (l, _) in _accArrival) l],
          [for (final (l, _) in _accArrival) l],
        ),
        (
          'เหตุการณ์',
          groupIcon('เหตุการณ์'),
          groupBodies['เหตุการณ์']!,
          groupLabels('เหตุการณ์'),
          _accRequired,
        ),
        (
          _accTraumaTitle,
          Icons.monitor_heart_rounded,
          traumaBody,
          [..._accRegions, ..._accScores],
          _accRegions,
        ),
        (
          'ปัจจัยเสี่ยง',
          groupIcon('ปัจจัยเสี่ยง'),
          groupBodies['ปัจจัยเสี่ยง']!,
          groupLabels('ปัจจัยเสี่ยง'),
          groupLabels('ปัจจัยเสี่ยง'),
        ),
        (
          'การดูแลก่อนมาถึง',
          groupIcon('การดูแลก่อนมาถึง'),
          groupBodies['การดูแลก่อนมาถึง']!,
          groupLabels('การดูแลก่อนมาถึง'),
          const <String>[],
        ),
        (
          'หมายเหตุ',
          groupIcon('หมายเหตุ'),
          groupBodies['หมายเหตุ']!,
          groupLabels('หมายเหตุ'),
          const <String>[],
        ),
      ];

      // ✓ = ช่องต้องครบกรอกครบแล้ว (หมวดที่ไม่มีช่องต้องครบ = มีข้อมูลอย่างน้อย 1 ช่อง)
      final complete = [
        for (final s in steps)
          s.$5.isNotEmpty ? s.$5.every(hasValue) : filled(s.$4) > 0,
      ];

      // หน้าแบบเมนูแพทย์ (หน้าละหลายการ์ด): (ชื่อใน stepper, หมวดใน steps)
      // steps: 0 การมา · 1 เหตุการณ์ · 2 Trauma · 3 ปัจจัยเสี่ยง · 4 การดูแลก่อนมาถึง · 5 หมายเหตุ
      // หน้าละหมวด (แยกประเภทชัดเจน แบบ stepper ของเมนูแพทย์): (ชื่อใน stepper, หมวดใน steps)
      // steps: 0 การมา · 1 เหตุการณ์ · 2 Trauma · 3 ปัจจัยเสี่ยง · 4 การดูแลก่อนมาถึง · 5 หมายเหตุ
      // หมวด Trauma แยกเป็น 2 หน้า: AIS (ช่องบังคับของหมวด) · Trauma Score (ตัวเลข/คำนวณ)
      const pageSteps = <(String, List<int>)>[
        ('เหตุการณ์', [1]),
        ('การมา', [0]),
        ('ความเสี่ยง', [3]),
        ('AIS', [2]),
        ('Trauma Score', []),
        ('การดูแล', [4, 5]),
      ];
      const scorePage = 5;
      const firstStepPage = 1;
      final lastPage = firstStepPage + pageSteps.length;
      final pageNames = [for (final p in pageSteps) p.$1, 'สรุป'];
      final pageDone = [
        for (final (i, (_, ix)) in pageSteps.indexed)
          firstStepPage + i == scorePage
              ? hasValue('RTS')
              : ix.every((k) => complete[k]),
        missing.isEmpty,
      ];

      void go(int to) {
        if (to == page) return;
        HapticFeedback.selectionClick();
        FocusManager.instance.primaryFocus?.unfocus();
        set(() {
          fwd = to > page;
          page = to.clamp(0, lastPage);
        });
      }

      // หน้าของช่อง (ไว้พาไปช่องที่ขาด / แตะแถวในหน้าสรุป)
      int pageOf(String label) {
        if (_accScores.contains(label)) return scorePage;
        final i = steps.indexWhere((s) => s.$4.contains(label));
        final p = pageSteps.indexWhere((x) => x.$2.contains(i));
        return firstStepPage + (p < 0 ? 0 : p);
      }

      // ---- ชิ้นส่วนแบบหน้าย่อยหัตถการ (การ์ดขาวมุม 16 · แถวรายการ ชื่อซ้าย ค่าขวา ลูกศร)
      Widget card(String title, List<Widget> kids,
              {String sub = '', Widget? action}) =>
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 6.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: _t(16.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              if (sub.isNotEmpty)
                                Text(sub,
                                    style: _t(12.0,
                                        color: _ink3, weight: FontWeight.w500)),
                            ]),
                      ),
                      if (action != null) action,
                    ]),
                  ),
                  ...kids,
                ]),
          );

      // เลือกต่อเนื่องใน sheet เดียว (แบบเพิ่มหัตถการ): เริ่มจากแถวที่แตะ แล้วต่อช่องถัดไปในการ์ด
      Future<void> pickFlow(List<(String, String)> fields, int from) async {
        await _listFlow([
          for (final (l, table) in fields.sublist(from))
            _ListStep(l, _accOptions(table),
                current: () => v[l],
                apply: (o) {
                  v[l] = o;
                  textControllers[l]?.text = o;
                }),
        ]);
        if (ctx.mounted) set(() {});
      }

      // ป้าย * ของช่องบังคับ ต่อท้ายชื่อแถว
      String rowLabel(String l) => _accRequired.contains(l) ? '$l *' : l;

      // แถวพิมพ์ (ข้อความสั้น/ตัวเลข): ชื่อซ้าย · ช่องพิมพ์ชิดขวาในแถว
      Widget inputRow(String l, String hint,
              {bool first = false, bool number = false}) =>
          Column(mainAxisSize: MainAxisSize.min, children: [
            if (!first)
              const Divider(
                  height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                child: Row(children: [
                  Text(l,
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      controller: textControllers[l],
                      textAlign: TextAlign.right,
                      keyboardType: number
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.text,
                      style:
                          _t(14.0, color: _inkTitle, weight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: _t(14.0, color: _ink3),
                      ),
                      onChanged: (text) => set(() {
                        if (text.isEmpty) {
                          v.remove(l);
                        } else {
                          v[l] = text;
                        }
                      }),
                    ),
                  ),
                ]),
              ),
            ),
          ]);

      // ค่าคำนวณอัตโนมัติ (ISS / RTS): แสดงอย่างเดียว ไม่มีลูกศร
      Widget computedRow(String l) => Column(children: [
            const Divider(
                height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
                child: Row(children: [
                  Text(l,
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(v[l] ?? '—',
                        style: _num(14.0,
                            color: hasValue(l) ? _inkTitle : _ink3,
                            weight: FontWeight.w700)),
                    Text('คำนวณอัตโนมัติ',
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
                ]),
              ),
            ),
          ]);

      // ---- หน้า
      // หน้าแนะนำ: โครงเดียวกับหน้าแนะนำของขั้นใน workflow panel
      Widget introPage() => _stepIntroView(
            sign: _waySignHero(
              name: 'อุบัติเหตุ',
              names: const ['อุบัติเหตุ'],
              icons: const [Icons.car_crash_rounded],
              iconPaths: const [null],
              done: [_accSaved(p.hn)],
              at: 0,
            ),
            mark: Icon(Icons.car_crash_rounded,
                size: 112.0, color: _blue.withValues(alpha: 0.1)),
            items: const [
              (
                'เหตุการณ์',
                'เล่าเหตุการณ์ให้ AI ช่วยกรอก · วันเวลา สถานที่ ประเภท'
              ),
              ('ข้อมูลการมา', 'ประเภทการมา หน่วยบริการที่ส่งมา ผู้นำส่ง'),
              ('ปัจจัยเสี่ยง', 'แอลกอฮอล์ สารเสพติด เข็มขัดและหมวกนิรภัย'),
              ('AIS', 'ระดับความรุนแรงรายส่วนของร่างกาย'),
              ('Trauma Score', 'GCS BP RR · RTS และ ISS คำนวณอัตโนมัติ'),
              (
                'การดูแลก่อนมาถึง',
                'การดูแลระหว่างนำส่ง และหมายเหตุ (ไม่บังคับ)'
              ),
            ],
            // ข้อมูลจากคัดกรองให้ตรวจทาน (อาการสำคัญ)
            extra: c.cc.isEmpty
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16.0, color: _blue),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text('อาการสำคัญ: ${c.cc}',
                                style: _t(12.0, color: _ink2, height: 1.4)),
                          ),
                        ]),
                  ),
          );

      // ---- การ์ดหมวดแบบการ์ด "ประวัติอาการปัจจุบัน" (HPI): ชื่อ · คำอธิบาย · ภาพมุมขวา
      // แผ่นปุ่มลัด (_dxTiles) · ค่าที่ลงแล้วเป็นแถวรายการ (ค่า = หัวแถว · ชื่อช่อง = บรรทัดรอง)
      Widget art(String? asset) => asset == null
          ? const SizedBox.shrink()
          : _dxArtFade(Image.asset(asset,
              fit: BoxFit.cover, filterQuality: FilterQuality.medium));

      // แถวค่าที่ลงแล้ว แตะ = แก้ช่องนั้น
      Widget valueRow(String l, String value, VoidCallback onTap,
              {bool first = false}) =>
          _gListRow(
            first: first,
            inset: 8.0,
            title: value.trim().replaceAll('\n', ' '),
            titleLines: 2,
            sub: rowLabel(l),
            onTap: onTap,
            trail: IconButton(
              onPressed: onTap,
              tooltip: 'แก้$l',
              iconSize: 20.0,
              constraints:
                  const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
              icon: const Icon(Icons.edit_outlined, color: _ink3),
            ),
          );

      // การ์ดหมวดที่เลือกจาก master: เพิ่ม = sheet เลือกต่อเนื่องจากช่องแรกที่ยังว่าง
      Widget catCard(String title, String sub, String? asset,
          List<(String, String)> fields,
          {List<(IconData, String, VoidCallback?)> tiles = const [],
          List<Widget> after = const []}) {
        final filledIx = [
          for (var i = 0; i < fields.length; i++)
            if (hasValue(fields[i].$1)) i
        ];
        final empty = fields.indexWhere((f) => !hasValue(f.$1));
        final all = empty < 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _dxCard(
            title,
            sub,
            art(asset),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _dxTiles([
                all
                    ? (Icons.edit_outlined, 'แก้ไข', () => pickFlow(fields, 0))
                    : (
                        Icons.add_rounded,
                        'เพิ่ม',
                        () => pickFlow(fields, empty)
                      ),
                ...tiles,
              ]),
              for (final (k, i) in filledIx.indexed)
                valueRow(
                    fields[i].$1, v[fields[i].$1]!, () => pickFlow(fields, i),
                    first: k == 0),
              ...after,
            ]),
          ),
        );
      }

      // ข้อความยาว (หมายเหตุ ฯลฯ) แบบการ์ด HPI: เพิ่ม/แก้ไข = หน้าต่างพิมพ์/พูด
      Future<void> editText(String l, String title) async {
        final text = await _voiceTextDialog(
          title: title,
          initial: textControllers[l]?.text ?? v[l] ?? '',
          hint: 'แตะไมค์เพื่อพูด หรือพิมพ์',
          okText: 'ใช้ข้อความนี้',
          multiline: true,
          autoMic: false,
        );
        if (text == null || !ctx.mounted) return;
        set(() {
          textControllers[l]?.text = text;
          if (text.trim().isEmpty) {
            v.remove(l);
          } else {
            v[l] = text.trim();
          }
        });
      }

      // หน้าเหตุการณ์: เล่าเหตุการณ์ (AI) · เหตุการณ์
      Widget eventPage() {
        final ev = [
          for (final (_, _, fs) in _accGroups.where((g) => g.$1 == 'เหตุการณ์'))
            ...fs
        ];
        final evSelect = [
          for (final f in ev)
            if (f.$2.isNotEmpty) f
        ];
        final story = narrative.text.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // แบบการ์ด "อาการสำคัญ" ของซักประวัติ: หัวข้อ + คำอธิบาย · ข้อความจากจุดคัดกรอง
            // (พื้นเทา) · เส้นคั่นมีปุ่ม "คัดลอกมาแก้ไข" · ช่อง floating label แตะแล้วเปิดหน้าพิมพ์
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_accNarrTitle,
                                  style: _t(16.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              const SizedBox(height: 2.0),
                              Text(
                                  c.cc.isEmpty
                                      ? 'พูดหรือพิมพ์เหตุการณ์ ให้ AI ช่วยกรอก · ไม่บังคับ'
                                      : 'ทบทวนเหตุการณ์จากจุดคัดกรอง',
                                  style: _t(12.5,
                                      color: _ink3, weight: FontWeight.w500)),
                            ]),
                      ),
                      // ปุ่มรองแบบ tonal ขวามือหัวข้อ (แบบปุ่ม "ดูการส่งตรวจ")
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _blue,
                          backgroundColor: const Color(0xFFE2EAF8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0.0, 40.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        ),
                        onPressed: extracting || story.isEmpty
                            ? null
                            : analyzeNarrative,
                        icon:
                            const Icon(Icons.auto_awesome_rounded, size: 16.0),
                        label: Text(
                            extracting ? 'กำลังวิเคราะห์…' : 'ให้ AI จัดข้อมูล',
                            style: _t(12.5,
                                color:
                                    extracting || story.isEmpty ? _ink3 : _blue,
                                weight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 12.0),
                    if (c.cc.isNotEmpty) ...[
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
                        decoration: BoxDecoration(
                          color: _panelSoft,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('จากจุดคัดกรอง',
                                  style: _t(12.0,
                                      color: _ink2, weight: FontWeight.w600)),
                              const SizedBox(height: 4.0),
                              Text(c.cc,
                                  style: _t(13.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w500,
                                      height: 1.45)),
                            ]),
                      ),
                      SizedBox(
                        height: 56.0,
                        child: Stack(alignment: Alignment.center, children: [
                          Container(
                              height: 1.0, color: const Color(0xFFE3E8F2)),
                          Container(
                            color: _panel,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _blue,
                                backgroundColor: _panel,
                                side: const BorderSide(
                                    color: Color(0xFFDADCE0), width: 0.5),
                                shape: const StadiumBorder(),
                                minimumSize: const Size(0.0, 36.0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setNarrative(c.cc);
                              },
                              icon: const Icon(Icons.arrow_downward_rounded,
                                  size: 16.0),
                              label: Text('คัดลอกมาแก้ไข',
                                  style: _t(12.5,
                                      color: _blue, weight: FontWeight.w600)),
                            ),
                          ),
                        ]),
                      ),
                    ],
                    // ช่องเล่าเหตุการณ์: แตะแล้วเปิดหน้าพิมพ์ (แบบ "อาการเพิ่มเติม")
                    TextField(
                      // พิมพ์ในช่องได้เลย ไม่เปิดหน้าต่างพิมพ์แยก
                      controller: narrative,
                      onChanged: (_) => setNarrative(narrative.text),
                      minLines: 1,
                      maxLines: 5,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w500),
                      decoration:
                          _qFloat('เหตุการณ์เพิ่มเติม (ถ้ามี)').copyWith(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 14.0, right: 8.0),
                          child: Icon(Icons.edit_outlined,
                              size: 16.0, color: _ink3),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                        contentPadding:
                            const EdgeInsets.fromLTRB(0.0, 18.0, 16.0, 18.0),
                      ),
                    ),
                    aiResults,
                  ]),
            ),
            catCard(
              'เหตุการณ์',
              'วันเวลา สถานที่ ประเภทอุบัติเหตุ ยานพาหนะ',
              null,
              evSelect,
              tiles: [
                (Icons.schedule_rounded, 'วันเวลาเกิดเหตุ', pickWhen),
              ],
              after: [
                if (hasValue(_accWhen))
                  valueRow(_accWhen, v[_accWhen]!, pickWhen),
                for (final f in ev)
                  if (f.$2.isEmpty)
                    inputRow(
                        f.$1,
                        f.$1 == 'ทะเบียนรถ'
                            ? 'ระบุทะเบียนรถ'
                            : 'ระบุถนน / บริเวณ'),
              ],
            ),
          ],
        );
      }

      // หน้าการมา
      Widget arrivalPage() => catCard(
          'ข้อมูลการมา',
          'ประเภทการมา หน่วยบริการที่ส่งมา ผู้นำส่ง',
          'assets/images/er_ov_emergent_fig.png',
          _accArrival);

      // หน้าปัจจัยเสี่ยง
      Widget riskPage() => catCard('ปัจจัยเสี่ยง',
              'แอลกอฮอล์ สารเสพติด เข็มขัดและหมวกนิรภัย', null, [
            for (final (_, _, fs)
                in _accGroups.where((g) => g.$1 == 'ปัจจัยเสี่ยง'))
              ...fs
          ]);

      // หน้า AIS ราย body region
      // หน้า AIS: ภาษาเดียวกับหน้าเลือกผลแต่ละระบบของตรวจร่างกาย (PE)
      // กริด 2 คอลัมน์วางเอง (AnimatedPositioned) · การ์ดที่กาง = เต็มแถว ทุกใบเลื่อนนุ่มพร้อมกัน
      // ระดับ AIS 1–6 = เหรียญ 3D ตัวเลข: ร่อง 6 ช่อง · ตัวที่เลือกหมุนโผล่จากใต้ร่อง · ลากบนร่องได้
      Widget aisPage() {
        final opts = _accOptions(_accAisTable);
        String? optOf(int k) =>
            opts.where((o) => _accAisOf(o) == k).firstOrNull;
        void pick(String r, int k) {
          HapticFeedback.selectionClick();
          final o = optOf(k);
          final cur = _accAisOf(v[r]);
          set(() {
            // แตะเหรียญที่เลือกอยู่ซ้ำ = เอาค่าออก
            if (o == null || cur == k) {
              v.remove(r);
            } else {
              v[r] = o;
            }
          });
          // เลือกเสร็จ = หุบกลับครึ่งแถว (แบบเลือกผลตรวจร่างกาย)
          Future.delayed(const Duration(milliseconds: 720), () {
            if (ctx.mounted && aisOpen == r) set(() => aisOpen = null);
          });
        }

        // ร่องเลือกระดับ (แบบ _peOpts): ร่องเทา · เหรียญจาง 6 จุด · ตัวที่เลือกเหรียญใหญ่ลอย
        Widget track(String r) {
          final sel = _accAisOf(v[r]);
          const n = 6, trackH = 40.0, badge = 46.0, lift = 14.0;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(builder: (context, box) {
                  final wAll = box.maxWidth;
                  double ax(int k, double c) =>
                      2.0 *
                          (wAll * (2 * k + 1) / (2 * n) - c / 2) /
                          (wAll - c) -
                      1.0;
                  return SizedBox(
                    height: trackH + lift,
                    child: ClipRect(
                      clipper: const _SoClipBelow(0.0),
                      child: Stack(alignment: Alignment.center, children: [
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          top: lift,
                          height: trackH,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0F3),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                        for (var k = 0; k < n; k++)
                          Positioned.fill(
                            top: lift,
                            child: Align(
                              alignment: Alignment(ax(k, trackH), 0.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => pick(r, k + 1),
                                child: SizedBox.square(
                                  dimension: trackH,
                                  child: Center(
                                    child: Opacity(
                                      opacity: sel == k + 1 ? 0.0 : 0.45,
                                      child: _AisCoin(level: k + 1, size: 28.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // เหรียญที่เลือก: หมุนรอบแกน Y โผล่ขึ้นจากใต้ร่อง (แบบเหรียญผลตรวจร่างกาย)
                        if (sel != null)
                          Align(
                            alignment: Alignment(ax(sel - 1, badge), -1.0),
                            child: IgnorePointer(
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey('ais-coin-$r-$sel'),
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, t, child) =>
                                    Transform.translate(
                                  offset:
                                      Offset(0.0, (1.0 - t) * (trackH + lift)),
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.003)
                                      ..rotateY((1.0 - t) * math.pi * 3.0),
                                    child: child,
                                  ),
                                ),
                                child: _AisCoin(level: sel, size: badge),
                              ),
                            ),
                          ),
                        // ลากบนร่อง = เลือกระดับใต้นิ้ว
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, b) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (d) {
                                final k =
                                    ((d.localPosition.dx / b.maxWidth) * n)
                                            .floor()
                                            .clamp(0, n - 1) +
                                        1;
                                if (_accAisOf(v[r]) != k) {
                                  final o = optOf(k);
                                  if (o != null) set(() => v[r] = o);
                                }
                              },
                              onHorizontalDragEnd: (_) => Future.delayed(
                                  const Duration(milliseconds: 720), () {
                                if (ctx.mounted && aisOpen == r) {
                                  set(() => aisOpen = null);
                                }
                              }),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 6.0),
                // ชื่อระดับใต้ร่อง
                Row(children: [
                  for (var k = 1; k <= n; k++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => pick(r, k),
                        child: Column(children: [
                          Text('$k',
                              style: _num(12.5,
                                  color: k == sel ? _inkTitle : _ink2,
                                  weight: k == sel
                                      ? FontWeight.w700
                                      : FontWeight.w600)),
                          Text(_accAisShort[k] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10.5,
                                  color: k == sel ? _inkTitle : _ink3,
                                  weight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                ]),
              ]);
        }

        // การ์ดส่วนของร่างกาย (แบบ _peSysCard): ภาพซ้ายบน · เหรียญสถานะมุมขวาบน · ชื่อ + ระดับ
        Widget aisCard(String r, bool open, double minH) {
          final cur = v[r];
          final n = _accAisOf(cur);
          final (th, img) =
              _accRegionArt[r] ?? (r, 'assets/images/er_pe_sys_ga.png');
          return Builder(
            builder: (cardCtx) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                set(() => aisOpen = open ? null : r);
                // กางแล้ว = เลื่อนให้เห็นการ์ดทั้งใบ (รอกริดขยายเสร็จก่อน)
                if (!open) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (!cardCtx.mounted || aisOpen != r) return;
                    Scrollable.ensureVisible(cardCtx,
                        alignment: 0.1,
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeInOutCubic);
                  });
                }
              },
              child: Container(
                constraints: BoxConstraints(minHeight: minH),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(18.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 72.0,
                              height: 72.0,
                              child: Image.asset(img,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium),
                            ),
                            const Spacer(),
                            // เปลี่ยนระดับ = เหรียญใหม่หมุนโผล่ (key ตามค่า)
                            if (n != null)
                              KeyedSubtree(
                                key: ValueKey('ais-st-$r-$n'),
                                child: _PeStatusPop(
                                    delay: Duration.zero,
                                    child: _AisCoin(level: n, size: 30.0)),
                              ),
                          ]),
                      const SizedBox(height: 8.0),
                      Text(th,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(15.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      Text(
                          n == null
                              ? r
                              : cur!.replaceFirst(RegExp(r'^AIS \d · '), ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w500)),
                      const SizedBox(height: 10.0),
                      if (open) track(r),
                    ]),
              ),
            ),
          );
        }

        final rest = [
          for (final r in _accRegions)
            if (!hasValue(r)) r
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // หัวหน้าแบบหน้าเลือกผลแต่ละระบบ: ชื่อ + คำอธิบาย · ปุ่มรอง/ป้าย ISS ขวามือ
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 12.0),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Body Region (AIS)',
                            style: _t(17.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text('แตะส่วนของร่างกายเพื่อเลือกระดับ AIS 1–6',
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                ),
              ]),
            ),
            // คะแนนรวม: ISS (จาก AIS) + RTS (จาก GCS BP RR)
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: scoreBar(),
            ),
            // วางกริดเอง (แบบหน้าตรวจร่างกาย): กาง/หุบแล้วทุกการ์ดเลื่อนตำแหน่ง/ขนาดไปพร้อมกัน
            LayoutBuilder(builder: (context, box) {
              const gap = 10.0;
              final full = box.maxWidth;
              final half = (full - gap) / 2;
              const dur = Duration(milliseconds: 380);
              const crv = Curves.easeInOutCubic;
              double hOf(String r) => aisOpen == r ? 150.0 + 96.0 : 150.0;
              final rects = <String, Rect>{};
              var y = 0.0, col = 0;
              var rowH = 0.0;
              for (final r in _accRegions) {
                final h = hOf(r);
                if (aisOpen == r) {
                  if (col == 1) {
                    y += rowH + gap;
                    col = 0;
                    rowH = 0.0;
                  }
                  rects[r] = Rect.fromLTWH(0.0, y, full, h);
                  y += h + gap;
                } else {
                  rects[r] =
                      Rect.fromLTWH(col == 0 ? 0.0 : half + gap, y, half, h);
                  rowH = math.max(rowH, h);
                  if (col == 1) {
                    y += rowH + gap;
                    col = 0;
                    rowH = 0.0;
                  } else {
                    col = 1;
                  }
                }
              }
              final total = col == 1 ? y + rowH : math.max(0.0, y - gap);
              return AnimatedContainer(
                duration: dur,
                curve: crv,
                height: total,
                child: Stack(clipBehavior: Clip.none, children: [
                  for (final r in _accRegions)
                    AnimatedPositioned(
                      key: ValueKey('ais-card-$r'),
                      duration: dur,
                      curve: crv,
                      left: rects[r]!.left,
                      top: rects[r]!.top,
                      width: rects[r]!.width,
                      height: rects[r]!.height,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minHeight: 0.0,
                          maxHeight: double.infinity,
                          child: aisCard(r, aisOpen == r, rects[r]!.height),
                        ),
                      ),
                    ),
                ]),
              );
            }),
            if (rest.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text('ยังไม่ได้เลือก ${rest.length} ส่วน',
                    style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
              ),
          ],
        );
      }

      // หน้า Trauma Score: ตัวเลข = แถวพิมพ์ · RTS / ISS คำนวณเอง
      Widget scorePageView() {
        final vitalsMissing = [
          if (!hasValue('BPs')) 'BPs',
          if (!hasValue('RR')) 'RR',
        ];
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: scoreBar(),
              ),
              card(
                'Trauma Score',
                [
                  inputRow('GCS.v', 'GCS รวม 3–15', first: true, number: true),
                  inputRow('BPs', 'mmHg', number: true),
                  inputRow('RR', '/min', number: true),
                  computedRow('RTS'),
                  computedRow('ISS'),
                  inputRow('PS', 'ระบุค่า PS', number: true),
                ],
                sub: vitalsMissing.isEmpty
                    ? 'ค่าตั้งต้นจากสัญญาณชีพล่าสุด แก้ได้'
                    : 'ยังไม่มีค่า ${vitalsMissing.join(' และ ')} · กรอกก่อนคำนวณ RTS',
              ),
            ]);
      }

      // หน้า 3: การดูแลก่อนมาถึง · หมายเหตุ (การ์ดหมวดแบบ HPI)
      Widget carePage() {
        final care = [
          for (final (_, _, fs)
              in _accGroups.where((g) => g.$1 == 'การดูแลก่อนมาถึง'))
            ...fs
        ];
        Widget noteCard(String l, String title, String sub, String? asset) {
          final has = hasValue(l);
          Future<void> open() => editText(l, title);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _dxCard(
              title,
              sub,
              art(asset),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _dxTiles([
                  has
                      ? (Icons.edit_outlined, 'แก้ไข', open)
                      : (Icons.add_rounded, 'เพิ่ม', open),
                ]),
                if (has)
                  _gListRow(
                    first: true,
                    inset: 8.0,
                    title: v[l]!,
                    titleLines: 3,
                    sub: 'แตะเพื่อแก้',
                    onTap: open,
                  ),
              ]),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            catCard(
              'การดูแลก่อนมาถึง',
              'การดูแลระหว่างนำส่ง · ไม่บังคับ',
              'assets/images/er_hero_nurse_act.png',
              care,
              tiles: [
                (
                  Icons.notes_rounded,
                  'การดูแลอื่น',
                  () => editText(_accPreNote, 'การดูแลอื่นก่อนมาถึง')
                ),
              ],
              after: [
                if (hasValue(_accPreNote))
                  valueRow(_accPreNote, v[_accPreNote]!,
                      () => editText(_accPreNote, 'การดูแลอื่นก่อนมาถึง')),
              ],
            ),
            noteCard('หมายเหตุ', 'หมายเหตุ', 'ข้อมูลอื่นที่ต้องบันทึกเพิ่ม',
                'assets/images/er_os_note_add.png'),
          ],
        );
      }

      // หน้าสรุปก่อนบันทึก: การ์ดละหมวด แตะแถวเพื่อกลับไปแก้ · ว่าง = pill เทา (แบบสรุปเมนูแพทย์)
      Widget reviewPage() {
        Widget row(String k, String? val, int to) {
          final ok = (val ?? '').trim().isNotEmpty;
          return InkWell(
            onTap: () => go(to),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (k.isNotEmpty) ...[
                  SizedBox(
                    width: 160.0,
                    child: Text(rowLabel(k),
                        style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 12.0),
                ],
                Expanded(
                  child: Align(
                    alignment: k.isEmpty
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: ok
                        ? Text(val!.trim(),
                            textAlign:
                                k.isEmpty ? TextAlign.start : TextAlign.right,
                            style: _t(13.5,
                                color: _inkTitle,
                                height: 1.4,
                                weight: FontWeight.w600))
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text('ยังไม่ได้กรอก',
                                style: _t(12.5,
                                    color: _ink2, weight: FontWeight.w600)),
                          ),
                  ),
                ),
              ]),
            ),
          );
        }

        Widget sumCard(String name, List<Widget> rows) => Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 8.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(name,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 4.0),
                    ...rows,
                  ]),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('สรุปก่อนบันทึก',
                style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text(
                missing.isEmpty
                    ? 'ตรวจทานข้อมูลอุบัติเหตุ แตะรายการเพื่อแก้'
                    : 'ยังขาด ${missing.length} ช่อง แตะรายการเพื่อกรอก',
                style: _t(12.5,
                    color: missing.isEmpty ? _ink3 : _blue,
                    weight: FontWeight.w500)),
            const SizedBox(height: 16.0),
            if (narrative.text.trim().isNotEmpty)
              sumCard(_accNarrTitle, [row('', narrative.text, firstStepPage)]),
            for (final s in steps)
              sumCard(s.$1, [
                for (final l in s.$4) row(l, v[l], pageOf(l)),
              ]),
            // ล้างค่าที่กรอกทั้งหมด (action รอง อยู่ท้ายหน้าสรุป)
            if (v.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => set(() {
                    v.clear();
                    for (final controller in textControllers.values) {
                      controller.clear();
                    }
                  }),
                  child: Text('ล้างทั้งหมด',
                      style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
                ),
              ),
          ],
        );
      }

      final content = switch (page) {
        0 => introPage(),
        1 => eventPage(),
        2 => arrivalPage(),
        3 => riskPage(),
        4 => aisPage(),
        5 => scorePageView(),
        6 => carePage(),
        _ => reviewPage(),
      };

      // ปุ่มหลัก: เริ่มกรอก → ถัดไป → ตรวจทาน → บันทึก (ยังขาด = ไปช่องที่ขาด)
      final Widget main;
      if (page == 0) {
        main = _navBtn('เริ่มกรอก', Icons.chevron_right_rounded, () => go(1),
            trailing: true);
      } else if (page < lastPage) {
        main = _navBtn(page == lastPage - 1 ? 'ตรวจทาน' : 'ถัดไป',
            Icons.chevron_right_rounded, () => go(page + 1),
            trailing: true);
      } else if (missing.isEmpty) {
        main = _navBtn(
            'บันทึกข้อมูลอุบัติเหตุ', Icons.check_rounded, () => close(true));
      } else {
        main = _navBtn('ไปช่องที่ขาด (${missing.length})',
            Icons.chevron_right_rounded, () => go(pageOf(missing.first)),
            trailing: true);
      }

      final body = Column(children: [
        // dialog: ปุ่มหุบชิดมุม (ในแผง workflow ใช้ปุ่มหุบของแผง)
        if (!embedded)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => close(false),
              tooltip: 'ปิด',
              icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                  color: _ink2),
            ),
          ),
        // stepper แบบเดียวกับขั้นอื่น (ไม่แสดงบนหน้าแนะนำ)
        if (page > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _hxStepper(
              [
                for (var i = 0; i < pageNames.length; i++)
                  (pageNames[i], pageDone[i])
              ],
              page - 1,
              onTap: (i) => go(i + 1),
            ),
          )
        else
          const SizedBox(height: 16.0),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder: (child, a) {
              final enter = child.key == ValueKey('acc-page-$page');
              final dx = (enter ? 0.22 : -0.22) * (fwd ? 1 : -1);
              return FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position:
                      Tween(begin: Offset(dx, 0), end: Offset.zero).animate(a),
                  child: child,
                ),
              );
            },
            // key ตามหน้า: เปลี่ยนหน้า = เริ่มบนสุดเสมอ (design rule)
            child: ListView(
              key: ValueKey('acc-page-$page'),
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              children: [content],
            ),
          ),
        ),
        // footer: ย้อนกลับ (กลม) · ปุ่มหลัก · ไปหน้าสรุป (กลม) แบบเดียวกับขั้นอื่น
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 10.0),
          child: Row(children: [
            _wfFootBack(page > 0 ? () => go(page - 1) : null),
            Expanded(child: main),
            _wfFootSide(
                show: page >= 1 && page < lastPage,
                left: false,
                child: _wfIconBtn(Icons.fact_check_outlined, 'ไปหน้าสรุป',
                    () => go(lastPage))),
          ]),
        ),
      ]);
      if (embedded) return body;
      final size = MediaQuery.sizeOf(ctx);
      return Dialog(
        backgroundColor: _bg,
        insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 24),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        child: SizedBox(
          width: math.min(960.0, size.width - 48.0),
          height: math.min(680.0, size.height - 48.0),
          child: body,
        ),
      );
    });
    return (form, close);
  }

  /// ปิดฟอร์มอุบัติเหตุ: บันทึกลง store หรือเก็บเป็นร่าง
  void _accFinish(_P p, Map<String, String> v, bool save) {
    if (!save || !mounted) {
      // ปิดโดยไม่บันทึก: เก็บเป็นร่างไว้ เปิดใหม่ค่าไม่หาย

      _accDrafts[p.hn] = v;

      return;
    }

    // เก็บเฉพาะช่องในฟอร์มปัจจุบัน รวมค่ามาตรฐานและข้อความที่ผู้ใช้กรอกเอง

    final keep = {..._accLabels(), ..._accExtraLabels};

    v.removeWhere((k, _) => !keep.contains(k));

    _accDrafts.remove(p.hn);

    setState(() => _accStore[p.hn] = v);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('บันทึกข้อมูลอุบัติเหตุ ${p.name} แล้ว',
            style: _t(12.0, color: Colors.white))));
  }
}

/// ปุ่มลิงก์เล็กในแผงอุบัติเหตุ (เลือกทั้งหมด / ล้างทั้งหมด): ไม่มีพื้น ระยะแคบ
final ButtonStyle _accLinkBtn = TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
);

/// เหรียญระดับ AIS (ตัวเลข 1–6) แบบเหรียญสถานะผลตรวจร่างกาย (_PeBadge25D):
/// แผ่นวงกลมซ้อนหลายชั้นตามแกน Z = ขอบหนา · หน้าเหรียญไล่แสงจากซ้ายบน + ตัวเลขขาว
/// สี: 1–2 = กรมท่า (ไม่รุนแรง) · 3–6 = แดง (รุนแรง ตามกฎสีผิดปกติ) เข้มขึ้นตามระดับ
class _AisCoin extends StatelessWidget {
  const _AisCoin({required this.level, this.size = 24.0, this.text});
  final int level;
  final double size;

  /// ข้อความบนหน้าเหรียญ (เช่น คะแนน ISS 75 / RTS 7.11) · null = เลขระดับ
  final String? text;

  static (Color, Color, Color) _cols(int k) => switch (k) {
        1 => (const Color(0xFF8A96D0), _blue3, _blue2),
        2 => (const Color(0xFF5A69B4), _blue2, _blue),
        3 => (const Color(0xFFF07C72), const Color(0xFFE5554A), _red),
        4 => (const Color(0xFFEA6257), _red, const Color(0xFFB3261E)),
        5 => (
            const Color(0xFFDD4136),
            const Color(0xFFC5221F),
            const Color(0xFF8C1D18)
          ),
        _ => (
            const Color(0xFFC5221F),
            const Color(0xFF9F1C17),
            const Color(0xFF6E140F)
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (hi, base, deep) = _cols(level);
    const n = 6;
    return SizedBox.square(
      dimension: size,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.003)
          ..rotateY(0.55)
          ..rotateX(0.18),
        child: Stack(children: [
          for (var k = n; k >= 1; k--)
            Positioned.fill(
              child: Transform(
                transform:
                    Matrix4.translationValues(0.0, 0.0, -k * 0.9 * size / 36.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(base, deep, 0.4 + 0.6 * k / n),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [hi, base],
                ),
              ),
              child: Center(
                child: Text(text ?? '$level',
                    style: TextStyle(
                        fontFamily: _fontFam,
                        fontFamilyFallback: _fontFb,
                        fontSize: size *
                            ((text ?? '$level').length <= 2 ? 0.48 : 0.32),
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.0)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
