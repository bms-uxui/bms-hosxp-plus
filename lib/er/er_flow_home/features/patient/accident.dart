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

    var extracting = false;
    var applying = false;
    var sourceRevision = 0;

    var showAllCoverage = false;

    // ฟอร์มแบบขั้นตอน: หมวดที่เปิดอยู่ (null = ยังไม่เลือก, -1 = ย่อทุกหมวด)
    // stepWasComplete ใช้จับจังหวะ "เพิ่งครบ" เพื่อไปหมวดถัดไปอัตโนมัติ
    int? openStep;
    final stepWasComplete = <int, bool>{};
    final stepKeys = List.generate(6, (_) => GlobalKey());

    // แถบขั้นตอนตามตำแหน่งเลื่อนจริง: viewStep = หมวดที่อยู่บนสุดของจอ
    // เลื่อนด้วยโปรแกรม (กดหมวด/ถัดไป) พักการจับ scroll ชั่วคราว ไม่ให้ค่ากระโดด
    final formScroll = ScrollController();
    final scrollKey = GlobalKey();
    int? viewStep;
    StateSetter? setForm;
    var autoScrolling = false;
    void syncStepToScroll() {
      if (autoScrolling || !formScroll.hasClients) return;
      final vp = scrollKey.currentContext?.findRenderObject() as RenderBox?;
      if (vp == null || !vp.attached) return;
      final top = vp.localToGlobal(Offset.zero).dy;
      final bottom = top + vp.size.height;
      double? topOf(int i) {
        final b = stepKeys[i].currentContext?.findRenderObject() as RenderBox?;
        return b == null || !b.attached
            ? null
            : b.localToGlobal(Offset.zero).dy;
      }

      var active = 0;
      for (var i = 0; i < stepKeys.length; i++) {
        final y = topOf(i);
        if (y != null && y <= top + 24) active = i;
      }
      // สุดขอบบน/ล่าง: หมวดที่เปิดอยู่ยังเห็นบนจอ = ผู้ใช้ยังทำหมวดนั้น
      // (หมวดย่อที่อยู่ท้าย ๆ ไม่ควรแย่งเป็นขั้นตอนปัจจุบัน)
      final pos = formScroll.position;
      final atTop = pos.pixels <= pos.minScrollExtent + 2;
      final atEnd = pos.pixels >= pos.maxScrollExtent - 2;
      final open = openStep ?? -1;
      final openBox = open >= 0
          ? stepKeys[open].currentContext?.findRenderObject() as RenderBox?
          : null;
      final openVisible = openBox != null &&
          openBox.attached &&
          openBox.localToGlobal(Offset.zero).dy < bottom - 40 &&
          openBox.localToGlobal(Offset.zero).dy + openBox.size.height >
              top + 40;
      if ((atTop || atEnd) && openVisible) {
        active = open;
      } else if (atEnd) {
        // หมวดท้าย ๆ ขึ้นไม่ถึงขอบบน → ใช้หมวดสุดท้ายที่เห็นบนจอ
        for (var i = stepKeys.length - 1; i > active; i--) {
          final y = topOf(i);
          if (y != null && y < bottom - 40) {
            active = i;
            break;
          }
        }
      }
      if (active != viewStep) setForm?.call(() => viewStep = active);
    }

    formScroll.addListener(syncStepToScroll);

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
      if (notify) done(save);
      // รอ animation ปิดจบก่อนคืน controller
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        narrative.dispose();
        formScroll.dispose();
        for (final controller in textControllers.values) {
          controller.dispose();
        }
      });
      _accFinish(p, v, save);
    }

    final form = StatefulBuilder(builder: (ctx, set) {
      setForm = set;

      _accRecalc(v);

      final schema = _accSchema();

      final labels = [
        for (final field in schema) field.id,
        ..._accExtraLabels,
      ];

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

      final done = labels.where((l) => (v[l] ?? '').isNotEmpty).length;

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

      final freeEntry = Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.edit_note_rounded, color: _blue, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'บันทึกข้อมูลอิสระ',
                  style: _t(13, color: _blue, weight: FontWeight.w700),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            _apptTextArea(
              narrative,
              'พูดหรือพิมพ์เหตุการณ์ แล้วตรวจข้อความก่อนให้ AI จัดข้อมูล',
              minLines: 2,
              maxLines: 6,
              onChanged: (value) => set(() {
                sourceRevision++;
                _accNarratives[p.hn] = value;

                // ข้อความเปลี่ยนแล้ว ผลวิเคราะห์เดิมถือว่า stale
                extractionMessage = null;
                analyzedCoverage = null;
                analyzedSuggestions = null;
                analyzedSource = null;
                analyzedSnapshot = null;
                selectedSuggestions.clear();
                showAllCoverage = false;
              }),
              suffixIcon: IconButton(
                tooltip: 'พูดบันทึกข้อมูลอิสระ',
                icon: const Icon(Icons.mic_none_rounded, color: _blue),
                onPressed: extracting
                    ? null
                    : () async {
                        final text = await _voiceTextDialog(
                          title: 'บันทึกข้อมูลอิสระ',
                          initial: narrative.text,
                          hint: 'เล่าเหตุการณ์ · ข้อความจะแสดงหลังหยุดพูด',
                          okText: 'ใช้ข้อความนี้',
                          multiline: true,
                          autoMic: true,
                        );
                        if (text == null || !ctx.mounted) return;
                        set(() {
                          sourceRevision++;
                          narrative.text = text;
                          _accNarratives[p.hn] = text;

                          extractionMessage = null;
                          analyzedCoverage = null;
                          analyzedSuggestions = null;
                          analyzedSource = null;
                          analyzedSnapshot = null;
                          selectedSuggestions.clear();
                          showAllCoverage = false;
                        });
                      },
              ),
            ),

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
                    onPressed: () =>
                        set(() => showAllCoverage = !showAllCoverage),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Text(
                      showAllCoverage
                          ? 'ย่อ'
                          : 'ดูทั้งหมด (${coverage.length})',
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
                          style:
                              _t(10.5, color: _blue, weight: FontWeight.w600)),
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
                              color:
                                  selectedSuggestions.isEmpty ? _ink3 : _blue,
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 6.0),
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
                        style:
                            _t(11.0, color: _inkTitle, weight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestions[i].value,
                            style:
                                _t(10.5, color: _blue, weight: FontWeight.w600),
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

            const SizedBox(height: 8),
            if (extractionMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  extractionMessage!,
                  style: _t(11, color: _ink2),
                ),
              ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  hasAnalysis
                      ? 'เลือกข้อมูลที่จะนำไปกรอกได้ด้านบน'
                      : 'AI จะวิเคราะห์เมื่อกดปุ่มเท่านั้น',
                  style: _t(10.5, color: _ink3),
                ),
                _apptPrimaryBtn(
                  Icons.auto_awesome_rounded,
                  extracting ? 'กำลังวิเคราะห์…' : 'ให้ AI จัดข้อมูล',
                  extracting || narrative.text.trim().isEmpty
                      ? null
                      : analyzeNarrative,
                ),
              ],
            ),
          ],
        ),
      );

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

      // ป้ายเล็กบนหัวการ์ด (จำนวนที่กรอก / ค่าสรุป) ให้สแกนได้เร็ว
      Widget pill(String text, Color color) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(text,
                style: _num(10, color: color, weight: FontWeight.w700)),
          );

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
              const Icon(Icons.info_outline_rounded, size: 14, color: _red),
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

      // ไปหมวด i: แถบขั้นตอนเปลี่ยนทันที แล้วเลื่อนจอตาม (พักจับ scroll ระหว่างเลื่อน)
      void goTo(int i) {
        openStep = i;
        viewStep = i;
        autoScrolling = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final target = stepKeys[i].currentContext;
          if (target != null && target.mounted) {
            await Scrollable.ensureVisible(target,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
          }
          autoScrolling = false;
        });
      }

      // เปิดครั้งแรก: หมวดแรกที่ยังไม่ครบ (ครบทุกหมวดแล้ว = เปิดหมวดแรก)
      if (openStep == null) {
        final first = complete.indexOf(false);
        openStep = first < 0 ? 0 : first;
      } else {
        // หมวดที่เปิดอยู่เพิ่งครบ (จากการเลือกค่า) → ไปหมวดถัดไปอัตโนมัติ
        final cur = openStep!;
        if (cur >= 0 &&
            cur < steps.length - 1 &&
            steps[cur].$5.isNotEmpty &&
            complete[cur] &&
            !(stepWasComplete[cur] ?? true)) {
          goTo(cur + 1);
        }
      }
      for (var i = 0; i < complete.length; i++) {
        stepWasComplete[i] = complete[i];
      }

      String summaryOf(List<String> ls) => [
            for (final l in ls)
              if (hasValue(l))
                // คะแนนเป็นตัวเลขล้วน ใส่ชื่อนำหน้าให้อ่านรู้เรื่อง
                '${_accScores.contains(l) ? '$l ' : ''}'
                    '${v[l]!.trim().replaceAll('\n', ' ')}',
          ].join(' · ');

      // การ์ดขั้นตอน: หัวแตะเพื่อเปิด/ย่อ · ย่อแล้วแสดงสรุปสั้น + สถานะ ✓
      Widget step(int i) {
        final (title, icon, body, ls, _) = steps[i];
        final open = openStep == i;
        final ok = complete[i];
        final count = filled(ls);
        final summary = summaryOf(ls);
        final badges = [
          if (title == _accTraumaTitle)
            for (final s in ['ISS', 'RTS'])
              if (hasValue(s)) pill('$s ${v[s]}', _blue),
        ];
        return Container(
          key: stepKeys[i],
          margin: const EdgeInsets.only(bottom: 6.0),
          decoration: open
              ? _clyCardDeco
              : BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
          foregroundDecoration: open ? const _InnerGloss(12.0) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => set(() {
                  if (open) {
                    openStep = -1;
                  } else {
                    goTo(i);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(children: [
                    // วงสถานะ: ✓ ครบ · เลขขั้นตอน (ฟ้าเข้ม = กำลังทำ)
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ok
                            ? _green
                            : open
                                ? _blue
                                : _blue.withValues(alpha: 0.08),
                      ),
                      child: ok
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : Text('${i + 1}',
                              style: _num(11.5,
                                  color: open ? Colors.white : _blue,
                                  weight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(icon, size: 14, color: _blue),
                              Text(title,
                                  style: _t(12.5,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              ...badges,
                            ],
                          ),
                          if (!open)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                summary.isEmpty ? 'ยังไม่ได้กรอก' : summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(10.5,
                                    color: summary.isEmpty ? _ink3 : _ink2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    pill(
                        '$count/${ls.length}',
                        // เขียว = ช่องจำเป็นของหมวดครบ (ตรงกับ ✓) แม้ช่องเสริมยังว่าง
                        ok ? _green : _ink3),
                    Icon(
                        open
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: _ink3),
                  ]),
                ),
              ),
              if (open) ...[
                const Divider(height: 1, color: _line),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: body,
                  ),
                ),
                // ไปหมวดถัดไปเองได้เสมอ (หมวดสุดท้ายไม่มีปุ่ม)
                if (i < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => set(() => goTo(i + 1)),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded,
                            size: 16, color: _blue),
                        label: Text('ถัดไป: ${steps[i + 1].$1}',
                            style:
                                _t(11, color: _blue, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      }

      // ขั้นตอนปัจจุบัน = หมวดที่อยู่บนจอ (ตามการเลื่อน/กด) · ยังไม่เลื่อน = หมวดที่เปิด
      final activeStep = viewStep ?? (openStep! >= 0 ? openStep! : 0);
      final stepNow = activeStep + 1;

      final size = MediaQuery.sizeOf(ctx);

      final body = Column(children: [
        // หัว: ไอคอน · ชื่อ · ผู้ป่วย · ปิด

        Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 14.0, 8.0, 6.0),
          child: Row(children: [
            Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                gradient: _glossGrad(_blue),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.car_crash_rounded,
                  size: 18.0, color: Colors.white),
            ),

            const SizedBox(width: 10.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('บันทึกข้อมูลอุบัติเหตุ',
                      style:
                          _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text('${p.name} · HN ${p.hn}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.0, color: _ink3)),
                ],
              ),
            ),

            // ความคืบหน้า: ขั้นตอนปัจจุบัน + จำนวนช่องที่กรอกแล้ว
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ขั้นตอน $stepNow/${steps.length}',
                    style: _t(11.5, color: _blue, weight: FontWeight.w700)),
                Text('$done/${labels.length} ช่อง',
                    style: _num(10, color: _ink3)),
              ],
            ),

            // ในแผง workflow มีปุ่มหุบด้านล่างแล้ว: ปุ่มปิดเฉพาะตอนเปิดเป็น dialog
            if (!embedded)
              IconButton(
                onPressed: () => close(false),
                tooltip: 'ปิด',
                icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                    color: _ink2),
              ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),

          // แถบขั้นตอน: เขียว = ครบ · ฟ้า = กำลังทำ · แตะเพื่อไปหมวดนั้น
          child: Row(children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Tooltip(
                  message: steps[i].$1,
                  child: InkWell(
                    onTap: () => set(() => goTo(i)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        // หมวดที่อยู่ตอนนี้หนากว่า (เห็นได้แม้หมวดนั้นครบแล้ว = สีเขียว)
                        height: activeStep == i ? 7 : 4,
                        decoration: BoxDecoration(
                          color: complete[i]
                              ? _green
                              : activeStep == i
                                  ? _blue
                                  : _line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        ),

        // ข้อมูลจากคัดกรองให้ตรวจทาน (อาการสำคัญ)

        if (c.cc.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 10.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 15.0, color: _blue),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text('อาการสำคัญ: ${c.cc}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _ink2, height: 1.35)),
              ),
            ]),
          ),

        Expanded(
          child: SingleChildScrollView(
            key: scrollKey,
            controller: formScroll,
            padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 6.0),
            child: Column(children: [
              freeEntry,
              for (var i = 0; i < steps.length; i++) step(i),
            ]),
          ),
        ),

        // ขอบล่าง: ล้าง · บันทึก (ยังไม่ครบ = บอกช่องที่ขาด)

        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          decoration: const BoxDecoration(
              color: _panel, border: Border(top: BorderSide(color: _line))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(
                missing.isEmpty
                    ? 'ข้อมูลจำเป็นครบแล้ว · ตรวจทานก่อนบันทึก'
                    : 'ยังขาด: ${missing.join(' · ')}',
                style: _t(10.5, color: _ink2)),
            const SizedBox(height: 8),
            Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (v.isNotEmpty)
                    TextButton(
                      onPressed: () => set(() {
                        v.clear();

                        for (final controller in textControllers.values) {
                          controller.clear();
                        }
                      }),
                      child: Text('ล้างทั้งหมด', style: _t(11.0, color: _ink3)),
                    ),
                  _apptPrimaryBtn(Icons.check_rounded, 'บันทึกข้อมูลอุบัติเหตุ',
                      missing.isEmpty ? () => close(true) : null),
                ]),
          ]),
        ),
      ]);
      if (embedded) return body;
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
