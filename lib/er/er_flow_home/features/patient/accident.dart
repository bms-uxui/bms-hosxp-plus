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

/// ไอคอนหัวข้อ (เหรียญในการ์ด "เพิ่มอัตโนมัติ")
IconData _accFieldIcon(String l) => switch (l) {
      'ประเภทอุบัติเหตุ' => Icons.warning_amber_rounded,
      'ยานพาหนะ' => Icons.two_wheeler_rounded,
      'สถานที่เกิดเหตุ' => Icons.location_city_rounded,
      'จุดเกิดเหตุ' => Icons.place_rounded,
      'ประเภทผู้บาดเจ็บ' => Icons.personal_injury_rounded,
      'ทะเบียนรถ' => Icons.pin_rounded,
      _accWhen => Icons.schedule_rounded,
      'ประเภทการมา' => Icons.directions_walk_rounded,
      'มาจากหน่วยบริการ' => Icons.local_hospital_rounded,
      'ผู้นำส่ง' => Icons.person_rounded,
      'แอลกอฮอล์' => Icons.local_bar_rounded,
      'สารเสพติด' => Icons.medication_rounded,
      'เข็มขัดนิรภัย' => Icons.airline_seat_recline_normal_rounded,
      'หมวกนิรภัย' => Icons.sports_motorsports_rounded,
      _ => Icons.auto_awesome_rounded,
    };

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

/// ส่วนของร่างกาย (AIS) → (ชื่อไทย, ภาพประกอบ) · ภาพจาก Figma 976:29 (ชุดภาพ AIS 6 ส่วน)
const Map<String, (String, String)> _accRegionArt = {
  'HEAD/NECK': ('ศีรษะและคอ', 'assets/images/er_ais_head.png'),
  'FACE': ('ใบหน้า', 'assets/images/er_ais_face.png'),
  'THORAX': ('ทรวงอก', 'assets/images/er_ais_thorax.png'),
  'ABDOMEN/PELVIC CONTENTS': (
    'ช่องท้องและอุ้งเชิงกราน',
    'assets/images/er_ais_abdomen.png'
  ),
  'EXTREMITIES/PELVIC GIRDLE': (
    'แขนขาและกระดูกเชิงกราน',
    'assets/images/er_ais_extremities.png'
  ),
  'EXTERNAL': ('ผิวหนังภายนอก', 'assets/images/er_ais_external.png'),
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
const Set<String> _accComputed = {'RTS', 'ISS', 'PS'};

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

/// Probability of Survival แบบ TRISS (Boyd 1987, ค่าสัมประสิทธิ์ MTOS)
/// b = b0 + b1·RTS + b2·ISS + b3·AgeIndex · Ps = 1 / (1 + e^-b)
/// AgeIndex = 0 (อายุ < 55) · 1 (≥ 55) · ทะลุ (ถูกแทง/ยิง) ใช้ชุดค่า penetrating · อื่น = blunt
/// ต้องมี RTS และ ISS ครบ มิฉะนั้น = null
double? _accPs(double? rts, int? iss, int? age, {bool penetrating = false}) {
  if (rts == null || iss == null || age == null) return null;
  final (b0, b1, b2, b3) = penetrating
      ? (-2.5355, 0.9934, -0.0651, -1.1360)
      : (-0.4499, 0.8085, -0.0835, -1.7430);
  final b = b0 + b1 * rts + b2 * iss + b3 * (age >= 55 ? 1 : 0);
  return 1 / (1 + math.exp(-b));
}

/// บาดแผลทะลุ (penetrating) จากเรื่องเล่า: ถูกแทง/ยิง/มีด/ปืน/ของมีคม
bool _accPenetrating(String text) =>
    RegExp(r'แทง|ยิง|มีด|ปืน|กระสุน|ของมีคม|เสียบ|ทะลุ').hasMatch(text);

/// คำนวณ ISS / RTS / PS ใหม่จากค่าในฟอร์ม (เรียกทุกครั้งที่ฟอร์ม rebuild = real-time)
void _accRecalc(Map<String, String> v, {int? age, String story = ''}) {
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
  put(
      'PS',
      _accPs(double.tryParse(v['RTS'] ?? ''), int.tryParse(v['ISS'] ?? ''), age,
              penetrating: _accPenetrating(story))
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

/// ผู้บันทึกเรื่องเล่าอุบัติเหตุ + เวลา (HN → (ชื่อ, hh:mm)) · จากคัดกรอง = พยาบาลคัดกรองและเวลาคัดกรอง
final Map<String, (String, String)> _accNarrBy = {};

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
    var sourceRevision = 0;

    // ฟอร์มแบบหน้า (แบบเดียวกับขั้นใน workflow panel):
    // 0 = หน้าแนะนำ · 1 = เล่าเหตุการณ์ · 2.. = หมวด · หน้าสุดท้าย = สรุปก่อนบันทึก
    // fwd = ทิศเปลี่ยนหน้า (ไปข้างหน้าเลื่อนซ้าย ย้อนกลับเลื่อนขวา)
    var page = 0;
    var fwd = true;
    // หน้าแนะนำ (page 0) ของขั้นย่อยไหน (index ของ _accRailSubs) · ทุกขั้นย่อยเริ่มที่หน้าแนะนำของตัวเอง
    var introGroup = 0;

    // หน้า AIS: ส่วนของร่างกายที่กางเลือกระดับอยู่ (แบบการ์ดระบบของตรวจร่างกาย)
    String? aisOpen;
    // หน้า AIS: false = การ์ดสรุปแบบผลตรวจร่างกาย (ปุ่มเพิ่ม + ส่วนที่เลือกแล้ว) · true = กริดเลือกส่วน
    var aisPicking = false;
    // หน้าสรุปของขั้นย่อยปัจจุบัน (ท้าย stepper ของขั้นย่อย ก่อนบันทึกแยกทีละหัวข้อ)
    var reviewing = false;
    // หน้าปัจจัยเสี่ยง: การ์ดที่กางเลือกค่าอยู่ (แบบการ์ดระบบของตรวจร่างกาย)
    String? riskOpen;
    // การ์ดส่วนของร่างกายในกริด AIS (เลื่อนการ์ดที่เปิดถัดไปให้อยู่ในจอ)
    final aisKeys = <String, GlobalKey>{};

    String? extractionMessage;

    // ผลวิเคราะห์ล่าสุดจากปุ่ม "ให้ AI จัดข้อมูล"
    // แยกจาก Form State จนกว่าผู้ใช้จะเลือกและกดนำข้อมูลไปกรอก
    List<ErCoverage>? analyzedCoverage;
    List<ErFillSuggestion>? analyzedSuggestions;
    // ข้อเสนอ AI ที่ผู้ใช้กดปิดแล้ว (ช่อง|ค่า) · วิเคราะห์ใหม่ = ล้าง
    final dismissedSug = <String>{};
    // เพิ่มอัตโนมัติ (story): flying = เหรียญที่กำลังลอยจากแถว AI ไปลงแถวของหัวข้อ
    // landAt = ลำดับที่แถวได้ค่า (ไฮไลต์จางครั้งเดียวต่อการลง) · coinKeys/rowKeys = ตำแหน่งต้นทาง/ปลายทาง
    var flying = <String>[];
    // ไปช่องที่ขาด (จากหน้าสรุป): แถวช่องบังคับที่ยังว่างมีแสงแดงกวาดซ้าย→ขวาครั้งเดียว
    // (ชุดเดียวกับตอนลบคำสั่งแพทย์ _SoSuccessSweep) · nudgeTick = รอบของแสง
    var nudge = <String>{};
    var nudgeTick = 0;
    final landAt = <String, int>{};
    var landSeq = 0;
    final coinKeys = <String, GlobalKey>{};
    final rowKeys = <String, GlobalKey>{};
    String? analyzedSource;

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
      _accRecalc(v, age: erCaseOf(p.hn).age, story: narrative.text);
      WidgetsBinding.instance.addPostFrameCallback((_) => _accLiveTick.value++);

      final schema = _accSchema();

      final suggestions = analyzedSuggestions ?? const <ErFillSuggestion>[];

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

        set(() {
          extracting = true;
          extractionMessage = null;
          analyzedCoverage = null;
          analyzedSuggestions = null;
          analyzedSource = null;
        });

        try {
          final ai = await ErSmartFill.extract(source, schema);
          if (!ctx.mounted) return;
          // เรื่องเล่ามักบอกเวลาแบบสัมพัทธ์ ("30 นาทีก่อนมา รพ.") ซึ่ง AI ไม่เดาวันเวลาให้
          // จุดคัดกรองบันทึกเวลาเกิดเหตุไว้แล้ว (วันนี้ hh:mm) = ใช้เป็นข้อเสนอของวันที่/เวลาเกิดเหตุ
          final triTime = _accSeed[p.hn]?.$1;
          final hasWhen = ai.any((x) =>
              x.field == _accWhen && x.applicable && x.value.trim().isNotEmpty);
          final tm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(triTime ?? '');
          final extracted = [
            ...ai
                .where((x) => !(x.field == _accWhen && !hasWhen && tm != null)),
            if (!hasWhen && tm != null)
              ErFillSuggestion(
                field: _accWhen,
                value: _accNow(() {
                  final n = DateTime.now();
                  return DateTime(n.year, n.month, n.day,
                      int.parse(tm.group(1)!), int.parse(tm.group(2)!));
                }()),
                evidence: 'เวลาเกิดเหตุที่จุดคัดกรองบันทึกไว้',
                status: ErFillStatus.matched,
                reason: 'จากจุดคัดกรอง',
                applicable: true,
              ),
          ];
          final mergedCoverage =
              ErSmartFill.analyzedCoverage(source, schema, extracted);

          if (revision != sourceRevision || source != narrative.text.trim()) {
            set(() {
              extractionMessage = null;
            });
            return;
          }

          set(() {
            analyzedSource = source;
            analyzedCoverage = mergedCoverage;
            analyzedSuggestions = extracted;
            dismissedSug.clear();

            // ผลปกติไม่ต้องมีข้อความสถานะ (รายการที่กรอกได้บอกเองแล้ว) · ข้อความเหลือแค่ตอนผิดพลาด
            extractionMessage = null;
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
          });

      // ผลวิเคราะห์ของ AI: ข้อเสนอไปอยู่ที่การ์ดของหัวข้อนั้น ๆ (sugRow) ไม่รวมเป็นรายการติ๊กที่นี่
      // เหลือแค่ข้อความตอนวิเคราะห์ไม่สำเร็จ
      final aiResults =
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (extractionMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Text(
              extractionMessage!,
              style: _t(12, color: _ink2),
            ),
          ),
      ]);

      // ข้อเสนอ AI ของช่อง l (จากเรื่องเล่า): ใช้ได้ · ยังไม่ปิด · ค่าต่างจากที่กรอกอยู่
      ErFillSuggestion? sugOf(String l) {
        if (!hasAnalysis) return null;
        for (final x in suggestions) {
          if (x.field == l &&
              x.applicable &&
              x.value.trim().isNotEmpty &&
              (v[l] ?? '').trim() != x.value.trim() &&
              !dismissedSug.contains('$l|${x.value}')) {
            return x;
          }
        }
        return null;
      }

      // ข้อเสนอ AI ของการ์ด: แถว "ข้อมูลที่กรอกได้อัตโนมัติ" ใต้การ์ดเมนู
      // เหรียญซ้อน 1 เหรียญต่อ 1 หัวข้อที่ยังเพิ่มได้: กรมท่า = AI พบค่า (เพิ่มอัตโนมัติได้) · เทา = ยังไม่พบ
      // ปุ่มขวา = ใส่ทุกหัวข้อที่ AI พบ (ไม่พบเลย = ปุ่มปิด) · ไม่มีหัวข้อให้เพิ่มแล้ว = ไม่แสดงการ์ด
      Widget autoCard(List<String> labels) {
        final found = [
          for (final l in labels)
            if (sugOf(l) case final x?) (l, x.value)
        ];
        final rest = [
          for (final l in labels)
            if ((v[l] ?? '').trim().isEmpty && !found.any((f) => f.$1 == l)) l
        ];
        // ไม่แสดงแถว: ยังไม่มีเรื่องเล่า (ยังวิเคราะห์ไม่ได้) · หรือการ์ดนี้กรอกครบแล้ว
        // วิเคราะห์แล้วไม่พบค่าใหม่ = แถวยังอยู่ บอกผลว่า AI ไม่พบ (ไม่หายไปเฉย ๆ)
        final noStory = !hasAnalysis && narrative.text.trim().isEmpty;
        final hidden = flying.isEmpty &&
            !extracting &&
            (noStory || (found.isEmpty && rest.isEmpty));
        final noneFound = hasAnalysis && !extracting && found.isEmpty;
        // โผล่/หายแบบยืดหดนุ่ม (ไม่กระตุกทั้งการ์ด)
        Widget anim(Widget child) => AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: child,
            );
        if (hidden) return anim(const SizedBox(width: double.infinity));
        final coins = [
          for (final (l, _) in found) (l, true),
          for (final l in rest) (l, false),
        ];
        // story: เหรียญกรมท่าลอยโค้งจากแถว AI ไปจอดที่เหรียญหน้าแถวของหัวข้อนั้นทีละเหรียญ
        // ลื่น: เหรียญทั้งหมดบินใน Overlay ชั้นเดียว ตัวจับเวลาเดียว ระหว่างบินไม่ rebuild ฟอร์ม
        // ลงครบ = ใส่ค่าทุกช่องใน set ครั้งเดียว แล้วค่อยเอาชั้นบินออกเฟรมถัดไป (เหรียญปลายทางเป็นกรมท่าแล้ว ไม่กะพริบ)
        void useAll() {
          if (flying.isNotEmpty) return;
          HapticFeedback.mediumImpact();
          final overlay = Overlay.of(ctx);
          final obox = overlay.context.findRenderObject() as RenderBox?;
          Offset? at(GlobalKey? k) {
            final b = k?.currentContext?.findRenderObject() as RenderBox?;
            if (b == null || obox == null || !b.attached) return null;
            return obox.globalToLocal(b.localToGlobal(Offset.zero));
          }

          void applyAll() {
            if (!ctx.mounted) return;
            set(() {
              for (final (l, val) in found) {
                v[l] = val;
                textControllers[l]?.text = val;
                landAt[l] = ++landSeq;
              }
              flying = [];
            });
          }

          final trips = [
            for (final (l, _) in found)
              if ((at(coinKeys[l]), at(rowKeys[l])) case (final f?, final t?))
                (l, f, t)
          ];
          if (trips.isEmpty) return applyAll();
          const fly = 620, gap = 90;
          final total = fly + gap * (trips.length - 1);
          // เสียงสั่นเบา ๆ ตอนแต่ละเหรียญลงจอด (ตัวจับเวลา ไม่แตะ state)
          for (var i = 0; i < trips.length; i++) {
            Future.delayed(Duration(milliseconds: gap * i + fly),
                HapticFeedback.selectionClick);
          }
          late final OverlayEntry e;
          e = OverlayEntry(
            builder: (_) => IgnorePointer(
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: total.toDouble()),
                  duration: Duration(milliseconds: total),
                  onEnd: () {
                    applyAll();
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => e.remove());
                  },
                  builder: (context, ms, _) => Stack(children: [
                    for (final (i, (l, from, to)) in trips.indexed)
                      Builder(builder: (context) {
                        final raw = ((ms - gap * i) / fly).clamp(0.0, 1.0);
                        final t = Curves.easeInOutCubic.transform(raw);
                        // โค้ง bezier: ยอดสูงตามระยะ เอนขวาเล็กน้อยเหมือนโยน
                        final lift = 24.0 + 0.16 * (to - from).distance;
                        final c = Offset((from.dx + to.dx) / 2 + 24.0,
                            math.min(from.dy, to.dy) - lift);
                        final p = from * ((1 - t) * (1 - t)) +
                            c * (2 * (1 - t) * t) +
                            to * (t * t);
                        return Positioned(
                          left: p.dx,
                          top: p.dy,
                          child: Transform.scale(
                            scale: 1.0 + 0.14 * math.sin(raw * math.pi),
                            // หมุน 1 รอบช่วงยกขึ้น แล้วร่อนหน้าตรง จบที่มุมพัก 0.55 เท่าเหรียญปลายทาง
                            child: _SoStatusCoin.field(_accFieldIcon(l),
                                tilt: 0.55 +
                                    2 *
                                        math.pi *
                                        Curves.easeOutCubic.transform(
                                            (raw / 0.6).clamp(0.0, 1.0))),
                          ),
                        );
                      }),
                  ]),
                ),
              ),
            ),
          );
          // ซ่อนเหรียญต้นทางกับวางชั้นบินในเฟรมเดียวกัน (เหรียญไม่หายวูบ) · rebuild ครั้งนี้ตกที่ t=0 ซึ่งยังไม่ขยับ
          set(() => flying = [for (final (l, _, _) in trips) l]);
          overlay.insert(e);
        }

        // ปุ่มขวา: ยังไม่วิเคราะห์ = "วิเคราะห์" (ต้องมีเรื่องเล่า)
        // วิเคราะห์แล้ว = "เพิ่ม" (ไม่พบค่าใหม่ = ปิด)
        final ready = hasAnalysis && !extracting;
        // กำลังวิเคราะห์ = หมุนหน้าคำเดิม (ปุ่มไม่ขยายจนหัวข้อตกบรรทัด)
        final label = extracting
            ? 'วิเคราะห์'
            : ready
                ? 'เพิ่ม'
                : 'วิเคราะห์';
        final VoidCallback? tap = extracting || flying.isNotEmpty
            ? null
            : ready
                ? (found.isEmpty ? null : useAll)
                : (narrative.text.trim().isEmpty ? null : analyzeNarrative);

        // เหรียญ 2.5D ขนาด 36 (_SoStatusCoin) ซ้อนกันทีละ 26
        const d = 36.0, step = 26.0;
        // ไม่มีกรอบการ์ดซ้อน: วางตรงในการ์ด (ระยะซ้ายเท่าแถวรายการ)
        return anim(Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 12.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวการ์ดคงที่ · จำนวนที่เพิ่มได้ดูจากเหรียญกรมท่า
                    Text(
                        // เพิ่งกดเพิ่มไปแล้ว = บอกว่าเพิ่มแล้ว · วิเคราะห์แล้วไม่พบเลย = AI ไม่พบ
                        noneFound
                            ? (labels.any(landAt.containsKey)
                                ? 'เพิ่มข้อมูลจาก AI แล้ว'
                                : 'AI ไม่พบข้อมูลเพิ่มจากเรื่องเล่า')
                            // บอกที่มา: AI อ่านเรื่องเล่าเหตุการณ์แล้วเติมช่องให้
                            : 'AI ช่วยกรอกจากเรื่องเล่า',
                        style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
                    // ที่มาของข้อมูล: เรื่องเล่าเหตุการณ์ที่บันทึกตอนคัดกรอง
                    if (!noneFound)
                      Text('ดึงข้อมูลจากการคัดกรอง',
                          style:
                              _t(11.0, color: _ink3, weight: FontWeight.w500)),
                    const SizedBox(height: 8.0),
                    // เหรียญเกินความกว้าง = เหรียญสุดท้ายเป็น "+n" (ไม่ตัดขอบ)
                    LayoutBuilder(builder: (context, box) {
                      final fit =
                          ((box.maxWidth - d) / step).floor().clamp(0, 99) + 1;
                      final more = coins.length > fit;
                      final shown = more ? coins.take(fit - 1).toList() : coins;
                      // เหรียญเปลี่ยนลำดับ/ออกไป = เลื่อนเข้าที่แบบนุ่ม (ไม่กระโดด)
                      Widget coin(int i, Widget child, {String? tip}) =>
                          AnimatedPositioned(
                            key: ValueKey('coin${tip ?? '+'}'),
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            left: step * i,
                            top: 0.0,
                            child: Tooltip(message: tip ?? '', child: child),
                          );
                      final n = shown.length + (more ? 1 : 0);
                      return SizedBox(
                        height: d,
                        width: d + step * (n - 1),
                        child: Stack(children: [
                          // เหรียญที่กำลังลอยไปแถวของมัน = ช่องว่างไว้ (ตัวที่บินอยู่ใน Overlay)
                          for (final (i, (l, on)) in shown.indexed)
                            coin(
                                i,
                                KeyedSubtree(
                                  key: coinKeys.putIfAbsent(l, GlobalKey.new),
                                  child: flying.contains(l)
                                      ? const SizedBox(width: d, height: d)
                                      // กำลังวิเคราะห์ = เหรียญเด้งไล่เป็นคลื่น · เสร็จ = เหรียญที่พบพลิกเป็นกรมท่าทีละเหรียญ
                                      : _AccScanBob(
                                          on: extracting,
                                          index: i,
                                          child: _AccCoinFlip(
                                            on: on,
                                            delay: Duration(
                                                milliseconds: 380 + 120 * i),
                                            builder: (on, tilt) =>
                                                _SoStatusCoin.field(
                                                    _accFieldIcon(l),
                                                    on: on,
                                                    tilt: tilt),
                                          ),
                                        ),
                                ),
                                tip: l),
                          if (more)
                            coin(
                              shown.length,
                              _SoStatusCoin.label(
                                  '+${coins.length - shown.length}',
                                  face: const [
                                    Color(0xFFF4F6FA),
                                    Color(0xFFD6DCE6)
                                  ],
                                  side: const [
                                    Color(0xFFBCC4D0),
                                    Color(0xFF9EA8B7)
                                  ],
                                  ink: const Color(0xFF5F6B7D)),
                            ),
                        ]),
                      );
                    }),
                  ]),
            ),
            const SizedBox(width: 12.0),
            _Press(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: tap,
                child: Container(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tap == null
                        ? const Color(0xFFF1F3F4)
                        : _blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (extracting) ...[
                      const SizedBox(
                        width: 14.0,
                        height: 14.0,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0, color: _ink3),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                    Text(label,
                        style: _t(14.0,
                            color: tap == null ? _g5 : _blue,
                            weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ]),
        ));
      }

      // เปลี่ยนเฉพาะเวลา: คงวันที่เดิม (ยังไม่มีวันที่ = วันนี้) · เวลาเริ่ม = ปัจจุบัน
      // วันเวลาเกิดเหตุ: แผ่นเลือกวัน + วงล้อเวลาของ ER (_dtSheet) ชุดเดียวกับ "สั่งเมื่อ"
      // ปุ่มลัดย้อนหลัง (ตอนนี้ / 15 / 30 นาที / 1 ชม.ที่แล้ว) · เลือกอนาคตไม่ได้ · ย้อนได้ 30 วัน
      Future<void> pickWhen() async {
        final now = DateTime.now();
        final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})')
            .firstMatch(v[_accWhen] ?? '');
        final cur = m == null
            ? now
            : DateTime(
                int.parse(m.group(3)!) - 543,
                int.parse(m.group(2)!),
                int.parse(m.group(1)!),
                int.parse(m.group(4)!),
                int.parse(m.group(5)!));
        final d = await _dtSheet(
          title: _accWhen,
          initial: cur.isAfter(now) ? now : cur,
          first: now.subtract(const Duration(days: 30)),
          last: now,
          pastQuick: true,
        );
        if (d == null || !ctx.mounted) return;
        set(() => v[_accWhen] = _accNow(d));
      }

      // เลือกเวลา = แผ่นวันเวลาเดียวกัน (ไม่ใช้ตัวเลือกเวลาของ Android)
      Future<void> pickTime() => pickWhen();

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
        // การ์ดคะแนนใบเดียว แบ่งครึ่ง ISS | RTS: ชื่อ · ตัวเลขใหญ่ + ป้ายระดับ
        // ใต้ตัวเลข = แถบช่วงความรุนแรง (แบบแถบ GCS หน้าภาพรวม) จุดเลื่อนไปที่ค่าจริง
        // ISS 0–75 ยิ่งสูงยิ่งรุนแรง · RTS 0–7.84 ยิ่งต่ำยิ่งรุนแรง (แถบเรียงร้าย → ดี จากซ้าย)
        const amber = Color(0xFFDC8610);
        Widget one(String k, (int, String)? tone, String need, double max,
            List<(double, double, Color)> bands,
            {bool lowBad = false}) {
          final raw = v[k]?.trim();
          final x = double.tryParse(raw ?? '');
          final ok = tone != null && x != null;
          final lvl = ok ? tone.$1 : 0;
          final col = !ok
              ? _ink3
              : lvl >= 4
                  ? _red
                  : lvl >= 2
                      ? amber
                      : _green;
          // ตำแหน่ง 0..1 บนแถบ (RTS กลับด้าน: ค่าต่ำ = ซ้าย)
          final pos = !ok ? null : (x / max).clamp(0.0, 1.0);
          // กะทัดรัด 2 แถว: ชื่อ ตัวเลข ป้ายระดับ (บรรทัดเดียว) · แถบช่วง + จุดค่า
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(k,
                              style: _t(12.5,
                                  color: _ink2, weight: FontWeight.w600)),
                          const SizedBox(width: 8.0),
                          KeyedSubtree(
                            key: ValueKey('score-$k-$raw'),
                            child: _PeStatusPop(
                              delay: Duration.zero,
                              child: Text(ok ? raw! : '—',
                                  style: _num(20.0,
                                      color: !ok
                                          ? _ink3
                                          : lvl >= 4
                                              ? _red
                                              : _inkTitle,
                                      weight: FontWeight.w700)),
                            ),
                          ),
                          const Spacer(),
                          if (ok)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 1.0),
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Text(tone.$2.split(' · ').first,
                                  style: _t(11.0,
                                      color: col, weight: FontWeight.w700)),
                            )
                          else
                            Flexible(
                              child: Text(need,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(11.0,
                                      color: _ink3, weight: FontWeight.w500)),
                            ),
                        ]),
                    const SizedBox(height: 6.0),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: pos ?? -1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (_, t, __) => SizedBox(
                        height: 12.0,
                        width: double.infinity,
                        child: CustomPaint(
                            painter: _AccBandPainter(bands: [
                          for (final (a, b, c) in bands) (a / max, b / max, c)
                        ], at: t < 0 ? null : t, dot: col)),
                      ),
                    ),
                  ]),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              one('ISS', _accIssTone(v['ISS']), 'รอ AIS', 75.0, [
                (0.0, 8.0, const Color(0xFFB0B5BB)),
                (9.0, 15.0, amber.withValues(alpha: 0.45)),
                (16.0, 24.0, _red.withValues(alpha: 0.45)),
                (25.0, 75.0, _red.withValues(alpha: 0.75)),
              ]),
              const VerticalDivider(
                  width: 1.0,
                  thickness: 1.0,
                  indent: 12.0,
                  endIndent: 12.0,
                  color: _line),
              one(
                  'RTS',
                  _accRtsTone(v['RTS']),
                  'รอ GCS BP RR',
                  7.84,
                  [
                    (0.0, 3.99, _red.withValues(alpha: 0.75)),
                    (4.0, 7.83, amber.withValues(alpha: 0.45)),
                    (7.84, 7.84, const Color(0xFFB0B5BB)),
                  ],
                  lowBad: true),
            ]),
          ),
        );
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
        // ชื่อเดียวกับหน้าแนะนำของขั้นย่อย (_accSubIntro)
        ('เหตุการณ์', [1]),
        ('ข้อมูลการมา', [0]),
        ('ปัจจัยเสี่ยง', [3]),
        ('AIS', [2]),
        ('Trauma Score', []),
        // หมายเหตุแยกเป็นขั้นที่ 2 ของขั้นย่อยการดูแล (ผู้ใช้ 2026-11-10)
        ('การดูแลก่อนมาถึง', [4]),
        ('หมายเหตุ', [5]),
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
          aisPicking = false;
          reviewing = false;
        });
      }

      // ไปหน้าแนะนำของขั้นย่อย g (forward = เลื่อนไปข้างหน้า)
      void toIntro(int g, {required bool forward}) {
        if (page == 0 && introGroup == g) return;
        HapticFeedback.selectionClick();
        FocusManager.instance.primaryFocus?.unfocus();
        set(() {
          fwd = forward;
          introGroup = g;
          page = 0;
          aisPicking = false;
          reviewing = false;
        });
      }

      // หน้าแรกของขั้นย่อย (ไม่ใช่ขั้นแรก) = ก่อนเข้าต้องผ่านหน้าแนะนำของขั้นย่อยนั้น
      int groupStarting(int pg) => _accRailSubs.indexWhere((x) => x.$2 == pg);

      // หน้าของช่อง (ไว้พาไปช่องที่ขาด / แตะแถวในหน้าสรุป)
      int pageOf(String label) {
        if (_accScores.contains(label)) return scorePage;
        final i = steps.indexWhere((s) => s.$4.contains(label));
        final p = pageSteps.indexWhere((x) => x.$2.contains(i));
        return firstStepPage + (p < 0 ? 0 : p);
      }

      // เลือกต่อเนื่องใน sheet เดียว (แบบเพิ่มหัตถการ): เริ่มจากแถวที่แตะ แล้วต่อช่องถัดไปในการ์ด
      // withWhen = ขั้นสุดท้ายเป็นวันเวลาเกิดเหตุ (หน้าปฏิทิน + วงล้อเวลาใน sheet เดียวกัน)
      Future<void> pickFlow(List<(String, String)> fields, int from,
          {bool withWhen = false}) async {
        final now = DateTime.now();
        final whenSt = _DtState(now);
        await _listFlow([
          for (final (l, table) in fields.sublist(from))
            _ListStep(l, _accOptions(table),
                current: () => v[l],
                apply: (o) {
                  v[l] = o;
                  textControllers[l]?.text = o;
                }),
          if (withWhen)
            _ListStep(_accWhen, const [],
                short: 'วันเวลาเกิดเหตุ',
                current: () => v[_accWhen],
                apply: (o) => v[_accWhen] = o,
                page: (done) => StatefulBuilder(
                      builder: (_, ss) => Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                        child: _dtPanel(whenSt, ss,
                            first: now.subtract(const Duration(days: 30)),
                            last: now,
                            pastQuick: true, onUse: (d) {
                          v[_accWhen] = _accNow(d);
                          done();
                        }),
                      ),
                    )),
        ]);
        if (ctx.mounted) set(() {});
      }

      // ป้าย * ของช่องบังคับ ต่อท้ายชื่อแถว
      String rowLabel(String l) => _accRequired.contains(l) ? '$l *' : l;

      // ---- หน้า
      // หน้าแนะนำ: โครงเดียวกับหน้าแนะนำของขั้นใน workflow panel
      // หน้าแนะนำของขั้นย่อย (แบบเมนูซักประวัติ: ป้ายชื่อขั้นย่อย + หัวข้อในขั้นย่อยนั้น)
      Widget introPage() => _stepIntroView(
            sign: _waySignHero(
              name: _accRailSubs[introGroup].$1,
              names: [_accRailSubs[introGroup].$1],
              icons: const [Icons.car_crash_rounded],
              iconPaths: const [null],
              done: [_accSaved(p.hn)],
              at: 0,
            ),
            mark: Icon(Icons.car_crash_rounded,
                size: 112.0, color: _blue.withValues(alpha: 0.1)),
            items: _accSubIntro[introGroup],
            // กล่องอาการสำคัญเอาออก 2026-11-10 (หน้าแนะนำบอกแค่หัวข้อในขั้นย่อย)
          );

      // ---- การ์ดหมวดแบบการ์ด "ประวัติอาการปัจจุบัน" (HPI): ชื่อ · คำอธิบาย · ภาพมุมขวา
      // แผ่นปุ่มลัด (_dxTiles) · ค่าที่ลงแล้วเป็นแถวรายการ (ค่า = หัวแถว · ชื่อช่อง = บรรทัดรอง)
      Widget art(String? asset) => asset == null
          ? const SizedBox.shrink()
          : _dxArtFade(Image.asset(asset,
              fit: BoxFit.cover, filterQuality: FilterQuality.medium));

      // แถวค่าที่ลงแล้ว แตะ = แก้ช่องนั้น
      // แถวที่เพิ่งได้ค่าจาก "เพิ่มอัตโนมัติ": พื้นกรมท่าอ่อนจางหายใน 1.4 วิ (ครั้งเดียวต่อการลง)
      Widget landFx(String l, Widget row) {
        final n = landAt[l];
        if (n == null) return row;
        return TweenAnimationBuilder<double>(
          key: ValueKey('land$l$n'),
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 1400),
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          builder: (context, a, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.07 * a),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: child,
          ),
          child: row,
        );
      }

      // ไอคอนประจำหัวข้อหน้าแถว = เหรียญ 2.5D (ชุดเดียวกับเหรียญในแถวกรอกอัตโนมัติ): กรอกแล้ว = กรมท่า · ยังว่าง = เทา
      // ได้ค่า = เหรียญพลิกจากเทาเป็นกรมท่า (ชุดเดียวกับเหรียญประเภท ICD-10) · key = ปลายทางเหรียญที่บินมาลง
      Widget rowIcon(String l) {
        final n = landAt[l];
        final coin = n != null && hasValue(l)
            // เหรียญที่บินมาลง: ยุบรับแรงกระแทกเบา ๆ แล้วคืนตัว ไม่พลิกซ้ำ
            ? TweenAnimationBuilder<double>(
                key: ValueKey('pop$l$n'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 420),
                builder: (context, t, child) => Transform.scale(
                  scale: 1.0 - 0.14 * math.sin(t * math.pi) * (1.0 - t),
                  child: child,
                ),
                child: _SoStatusCoin.field(_accFieldIcon(l)),
              )
            : _CoinFlip(
                value: hasValue(l) ? 'on' : 'off',
                builder: (s, tilt) => _SoStatusCoin.field(_accFieldIcon(l),
                    on: s == 'on', tilt: tilt));
        return KeyedSubtree(
            key: rowKeys.putIfAbsent(l, GlobalKey.new), child: coin);
      }

      Widget valueRow(String l, String value, VoidCallback onTap,
              {bool first = false}) =>
          landFx(
            l,
            _gListRow(
              first: first,
              inset: 8.0,
              lead: rowIcon(l),
              title: value.trim().replaceAll('\n', ' '),
              titleLines: 2,
              sub: rowLabel(l),
              onTap: onTap,
              // แตะแถว = แก้ · ปุ่มขวา = ลบค่านี้ (ยืนยันก่อนทุกครั้ง ยกเลิก + ลบสีแดง)
              trail: IconButton(
                onPressed: () async {
                  if (!await _wfTextConfirmDelete(l) || !ctx.mounted) return;
                  HapticFeedback.selectionClick();
                  set(() {
                    v.remove(l);
                    textControllers[l]?.clear();
                  });
                },
                tooltip: 'ลบ$l',
                iconSize: 20.0,
                constraints:
                    const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                icon: const Icon(Icons.delete_outline_rounded, color: _ink3),
              ),
            ),
          );

      // หัวข้อที่ยังไม่กรอก: แสดงในรายการด้วย (เห็นครบว่าต้องกรอกอะไร) · แตะ = เลือกค่า
      // บังคับ = ดอกจัน · ไม่บังคับ = ป้าย "ถ้ามี" (ชุดเดียวกับแถวจุดเกิดเหตุ/ทะเบียนรถ)
      Widget emptyRow(String l, VoidCallback onTap, {bool first = false}) {
        final row = _gListRow(
          first: first,
          inset: 8.0,
          lead: rowIcon(l),
          title: rowLabel(l),
          badge: _accRequired.contains(l) ? null : 'ถ้ามี',
          sub: 'ยังไม่ได้เลือก',
          onTap: onTap,
        );
        if (!nudge.contains(l)) return row;
        return Stack(children: [
          Positioned.fill(
            top: first ? 0.0 : 1.0,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: _SoSuccessSweep(
                    key: ValueKey('nudge$l$nudgeTick'),
                    fromLeft: true,
                    color: _red,
                    fresh: true),
              ),
            ),
          ),
          row,
        ]);
      }

      // การ์ดหมวดที่เลือกจาก master: เพิ่ม = sheet เลือกต่อเนื่องจากช่องแรกที่ยังว่าง
      Widget catCard(String title, String sub, String? asset,
          List<(String, String)> fields,
          {List<(IconData, String, VoidCallback?)> tiles = const [],
          List<Widget> after = const [],
          bool withWhen = false,
          List<String> sugExtra = const []}) {
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
                    ? (
                        Icons.edit_outlined,
                        'แก้ไข',
                        () => pickFlow(fields, 0, withWhen: withWhen)
                      )
                    : (
                        Icons.add_rounded,
                        'เพิ่ม',
                        () => pickFlow(fields, empty, withWhen: withWhen)
                      ),
                ...tiles,
              ]),
              autoCard([
                for (final (l, _) in fields) l,
                if (withWhen) _accWhen,
                ...sugExtra,
              ]),
              // รายการครบทุกหัวข้อของการ์ด: กรอกแล้ว = ค่า + ลบ · ยังว่าง = ยังไม่ได้เลือก
              for (final (i, (l, _)) in fields.indexed)
                hasValue(l)
                    ? valueRow(l, v[l]!, () => pickFlow(fields, i),
                        first: i == 0)
                    : emptyRow(l, () => pickFlow(fields, i), first: i == 0),
              ...after,
            ]),
          ),
        );
      }

      // ข้อความยาว (หมายเหตุ ฯลฯ) แบบการ์ด HPI: เพิ่ม/แก้ไข = หน้าต่างพิมพ์/พูด
      // หน้าพิมพ์ในแผงชุดเดียวกับเล่าเหตุการณ์ / Doctor Note (_ftOpen) ไม่ใช่ dialog ลอย
      Future<void> editText(String l, String title) async {
        final text = await _ftOpen(ctx,
            title: title,
            inWorkflow: true,
            initial: textControllers[l]?.text ?? v[l] ?? '',
            hint: 'พิมพ์ หรือแตะไมค์เพื่อพูด');
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

      // ช่องข้อความสั้น (จุดเกิดเหตุ ทะเบียนรถ): หน้าพิมพ์ในแผงชุดเดียวกับเล่าเหตุการณ์
      Future<void> editField(String l) async {
        final text = await _ftOpen(ctx,
            title: l,
            inWorkflow: true,
            initial: v[l] ?? '',
            hint: l == 'ทะเบียนรถ'
                ? 'เช่น 1กข 1234 กรุงเทพฯ'
                : 'เช่น ถนนพหลโยธิน หน้าตลาด');
        if (text == null || !ctx.mounted) return;
        set(() {
          textControllers[l]?.text = text.trim();
          if (text.trim().isEmpty) {
            v.remove(l);
          } else {
            v[l] = text.trim();
          }
        });
      }

      // เล่าเหตุการณ์: หน้าพิมพ์/พูดชุดเดียวกับช่องข้อความอื่น (editText)
      Future<void> editStory() async {
        // แผ่นพิมพ์ลอยชุดเดียวกับ Doctor Note ในขั้นการวินิจฉัย (_ftOpen)
        final text = await _ftOpen(ctx,
            title: _accNarrTitle,
            sub: 'เกิดอะไรขึ้น ที่ไหน เมื่อไร',
            inWorkflow: true,
            initial: narrative.text,
            hint: 'เช่น ขับจักรยานยนต์ชนรถเก๋งที่ทางแยก ไม่สวมหมวกนิรภัย');
        if (text == null || !ctx.mounted) return;
        narrative.text = text.trim();
        // ลบเรื่องเล่า = ไม่มีผู้บันทึก
        if (narrative.text.isEmpty) {
          _accNarrBy.remove(p.hn);
          setNarrative('');
          return;
        }
        final now = DateTime.now();
        _accNarrBy[p.hn] = (
          ErSession.instance.user?.name ?? 'ผู้ใช้',
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
        );
        // ไม่วิเคราะห์เอง: ผู้ใช้กด "วิเคราะห์" ในการ์ดข้อมูลที่กรอกได้อัตโนมัติ
        setNarrative(narrative.text);
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
            // โครงแบบหน้าการวินิจฉัย (Diagnosis Text): การ์ดเดียวต่อหัวข้อ ชื่อ คำอธิบาย ภาพ
            // ปุ่มทำงานเป็นแถว (เล่า / จากจุดคัดกรอง / ให้ AI จัดข้อมูล) · ข้อความที่เล่าแล้ว = แถวใต้ปุ่ม แตะแก้
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _dxCard(
                _accNarrTitle,
                // บอกว่าการ์ดนี้คืออะไร สั้นแบบการ์ด Diagnosis Text / Doctor Note
                'สิ่งที่เกิดขึ้นตามคำบอกเล่าของผู้ป่วยหรือผู้นำส่ง',
                // ภาพไอคอนสี่เหลี่ยม: วางพอดีมุมขวา (contain + เว้นขอบ) ไม่ขยายเต็มช่อง 150×110
                Padding(
                  padding: const EdgeInsets.fromLTRB(56.0, 14.0, 14.0, 22.0),
                  child: Image.asset('assets/images/er_os_note_add.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                      filterQuality: FilterQuality.medium),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dxTiles([
                        (
                          story.isEmpty
                              ? Icons.add_rounded
                              : Icons.edit_outlined,
                          story.isEmpty ? 'เล่าเหตุการณ์' : 'แก้ไข',
                          () => editStory(),
                        ),
                        if (c.cc.isNotEmpty)
                          (
                            Icons.content_paste_rounded,
                            // สั้นพอให้ช่องกว้าง ~100 ไม่ตัดบรรทัด (ปุ่มช่องปรับตามความกว้างแผง)
                            'จากคัดกรอง',
                            () {
                              HapticFeedback.selectionClick();
                              // ผู้บันทึก = พยาบาลคัดกรอง เวลาคัดกรอง (แถว "พยาบาลคัดกรอง / เวลา")
                              final tri = erTableFor(p.hn, ErTab.triage)
                                  .rows
                                  .where((r) => r[1] == 'พยาบาลคัดกรอง / เวลา')
                                  .map((r) => r[2].split(' · '))
                                  .firstOrNull;
                              _accNarrBy[p.hn] = (
                                tri?.first.trim() ?? 'พยาบาลคัดกรอง',
                                // เวลาในตารางมี "น." อยู่แล้ว · เก็บแค่ hh:mm แล้วให้ _clock เติม
                                tri != null && tri.length > 1
                                    ? tri[1].replaceAll('น.', '').trim()
                                    : ''
                              );
                              setNarrative(c.cc);
                            },
                          ),
                      ]),
                      if (story.isNotEmpty)
                        _gListRow(
                          first: true,
                          inset: 8.0,
                          title: story,
                          // ยาวเกิน 2 บรรทัด = ตัด … (แตะดูเต็มในหน้าแก้ไข)
                          titleLines: 2,
                          // บอกที่มา: บันทึกโดยใคร เมื่อไร (ไม่รู้ = ไม่มีบรรทัดรอง)
                          sub: switch (_accNarrBy[p.hn]) {
                            (final who, final at) when at.isNotEmpty =>
                              'บันทึกโดย $who เมื่อ ${_clock(at)}',
                            (final who, _) => 'บันทึกโดย $who',
                            null => '',
                          },
                          onTap: () => editStory(),
                        ),
                      aiResults,
                    ]),
              ),
            ),
            catCard(
              'เหตุการณ์',
              'วันเวลา สถานที่ ประเภทอุบัติเหตุ ยานพาหนะ',
              // ไม่มีภาพอุบัติเหตุในชุด: ใช้ภาพเจ้าหน้าที่เข็นเปลรับผู้บาดเจ็บ
              'assets/images/er_ov_emergent_fig.png',
              evSelect,
              // ขั้นสุดท้ายของ เพิ่ม/แก้ไข = วันเวลาเกิดเหตุ ใน sheet เดียวกัน (เลื่อนต่อจากช่องก่อนหน้า)
              withWhen: true,
              // ช่องข้อความ (จุดเกิดเหตุ ทะเบียนรถ) รวมในแถวสรุป AI ของการ์ดนี้
              sugExtra: [
                for (final f in ev)
                  if (f.$2.isEmpty) f.$1
              ],
              tiles: [
                (Icons.schedule_rounded, 'วันเวลาเกิดเหตุ', pickWhen),
              ],
              after: [
                // วันเวลาเกิดเหตุ: แสดงเสมอ (ยังว่าง = ยังไม่ได้เลือก)
                hasValue(_accWhen)
                    ? valueRow(_accWhen, v[_accWhen]!, pickWhen)
                    : emptyRow(_accWhen, pickWhen),
                // ช่องข้อความ: แถวรายการ แตะ = หน้าพิมพ์ในแผง (ไม่มีช่องพิมพ์ลอยในการ์ด แบบหน้าการวินิจฉัย)
                for (final f in ev)
                  if (f.$2.isEmpty) ...[
                    landFx(
                      f.$1,
                      _gListRow(
                        inset: 8.0,
                        lead: rowIcon(f.$1),
                        title: f.$1,
                        // ช่องข้อความในการ์ดนี้ไม่บังคับ (ไม่ใช่ทุกเหตุจะมีทะเบียนรถ หรือรู้จุดเกิดเหตุ)
                        badge: 'ถ้ามี',
                        sub: hasValue(f.$1)
                            ? v[f.$1]!.trim()
                            // ยังไม่กรอก = บอกว่าช่องนี้ใส่อะไร (ไม่ใช่ตัวอย่างค่า)
                            : f.$1 == 'ทะเบียนรถ'
                                ? 'ทะเบียนรถที่เกิดเหตุ'
                                : 'ถนน ซอย หรือจุดสังเกตที่เกิดเหตุ',
                        subColor: hasValue(f.$1) ? _inkTitle : _ink3,
                        subLines: 2,
                        onTap: () => editField(f.$1),
                      ),
                    ),
                  ],
              ],
            ),
          ],
        );
      }

      // หน้าการมา
      Widget arrivalPage() => catCard(
          'ข้อมูลการมา',
          'ประเภทการมา หน่วยบริการที่ส่งมา ผู้นำส่ง',
          // ภาพเข็นเปลย้ายไปการ์ดเหตุการณ์ · การมา = พยาบาลเข็นรถเข็นผู้ป่วยเข้ามา
          'assets/images/er_ov_urgent_fig.png',
          _accArrival);

      // หน้าปัจจัยเสี่ยง: ชุดเดียวกับหน้าเลือกผลแต่ละระบบของตรวจร่างกาย (PE) และหน้า AIS
      // กริด 2 คอลัมน์ · แตะการ์ด = กางเต็มแถว · ร่อง 3 ช่อง เหรียญ 2.5D (_PeBadge25D)
      // ไม่เสี่ยง = ✓ เขียว · เสี่ยง = สามเหลี่ยมส้ม · ไม่ทราบ = เทา (ความหมายเดียวกับ ปกติ/ผิดปกติ/ไม่ได้ตรวจ)
      // กริดการ์ดเลือกค่า (แบบหน้าตรวจร่างกาย/AIS): ใช้ทั้งหน้าปัจจัยเสี่ยงและการดูแลก่อนมาถึง
      // artOf = ภาพ/ไอคอนบนการ์ด · kindOf = เหรียญ 2.5D (0 ✓ เขียว · 1 ส้ม · 2 เทา)
      // short = ชื่อสั้นของตัวเลือก (ใต้ร่อง + บนการ์ด) เมื่อชื่อเต็มยาวเกินช่อง
      Widget choiceGrid(String title, String sub, List<(String, String)> fs,
          Widget Function(String) artOf, int Function(String) kindOf,
          {String Function(String)? short,
          Widget? trail,
          List<String>? order}) {
        String sh(String o) => short == null ? o : short(o);
        void pick(String l, String o) {
          HapticFeedback.selectionClick();
          final again = v[l] == o;
          set(() {
            if (again) {
              v.remove(l);
              textControllers[l]?.clear();
            } else {
              v[l] = o;
              textControllers[l]?.text = o;
            }
          });
          // เลือกเสร็จ = หุบกลับครึ่งแถว (แบบเลือกผลตรวจร่างกาย)
          Future.delayed(const Duration(milliseconds: 720), () {
            if (ctx.mounted && riskOpen == l) set(() => riskOpen = null);
          });
        }

        // ร่องเลือก (แบบ _peOpts): ร่องเทา · เหรียญจางทุกจุด · ตัวที่เลือกเหรียญใหญ่โผล่จากใต้ร่อง
        Widget track(String l, List<String> opts) {
          final sel = opts.indexOf(v[l] ?? '');
          final n = opts.length;
          const trackH = 40.0, badge = 46.0, lift = 14.0;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(builder: (context, box) {
                  final w = box.maxWidth;
                  double ax(int k, double c) =>
                      2.0 * (w * (2 * k + 1) / (2 * n) - c / 2) / (w - c) - 1.0;
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
                        for (final (k, o) in opts.indexed)
                          Positioned.fill(
                            top: lift,
                            child: Align(
                              alignment: Alignment(ax(k, trackH), 0.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => pick(l, o),
                                child: SizedBox.square(
                                  dimension: trackH,
                                  child: Center(
                                    child: Opacity(
                                      opacity: k == sel ? 0.0 : 0.45,
                                      child: _PeBadge25D(
                                          kind: kindOf(o), size: 28.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (sel >= 0)
                          Align(
                            alignment: Alignment(ax(sel, badge), -1.0),
                            child: IgnorePointer(
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey('risk-coin-$l-$sel'),
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
                                child: _PeBadge25D(
                                    kind: kindOf(opts[sel]), size: badge),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 6.0),
                Row(children: [
                  for (final (k, o) in opts.indexed)
                    Expanded(
                      child: Text(sh(o),
                          textAlign: TextAlign.center,
                          style: _t(13.0,
                              color: k == sel ? _inkTitle : _ink3,
                              weight: k == sel
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                ]),
              ]);
        }

        // การ์ด (แบบ aisCard): ภาพ/ไอคอนบนซ้าย · เหรียญค่าที่เลือกขวาบน · ชื่อ + ค่า · กาง = ร่องเลือก
        Widget card(String l, String table, bool open, double minH) {
          // เรียงตัวเลือกตาม order (ชื่อสั้น) ให้ทุกการ์ดในกริดเรียงเหมือนกัน (master บางตารางสลับลำดับ)
          final opts = _accOptions(table);
          if (order != null) {
            int at(String o) {
              final i = order.indexOf(sh(o));
              return i < 0 ? order.length : i;
            }

            opts.sort((a, b) => at(a).compareTo(at(b)));
          }
          final cur = v[l];
          final has = cur != null && cur.trim().isNotEmpty;
          return Builder(
              builder: (cardCtx) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      set(() => riskOpen = open ? null : l);
                      // กางแล้ว = เลื่อนให้การ์ดขึ้นชิดบน เห็นทั้งใบ (รอกริดขยาย/ย้ายที่เสร็จ 380)
                      if (!open) {
                        Future.delayed(const Duration(milliseconds: 420), () {
                          if (!cardCtx.mounted || riskOpen != l) return;
                          Scrollable.ensureVisible(cardCtx,
                              alignment: 0.0,
                              duration: const Duration(milliseconds: 360),
                              curve: Curves.easeOutCubic);
                        });
                      }
                    },
                    child: Container(
                      constraints: BoxConstraints(minHeight: minH),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                            color: const Color(0xFFDADCE0), width: 0.5),
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
                                    child: artOf(l),
                                  ),
                                  const Spacer(),
                                  if (has)
                                    KeyedSubtree(
                                      key: ValueKey('risk-st-$l-$cur'),
                                      child: _PeStatusPop(
                                          delay: Duration.zero,
                                          child: _PeBadge25D(
                                              kind: kindOf(cur), size: 30.0)),
                                    ),
                                ]),
                            const SizedBox(height: 8.0),
                            Text(l,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(15.0,
                                    color: _inkTitle, weight: FontWeight.w700)),
                            Text(has ? sh(cur) : 'ยังไม่เลือก',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                            const SizedBox(height: 10.0),
                            if (open) track(l, opts),
                          ]),
                    ),
                  ));
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 12.0),
                // หัวกริด + ปุ่มรองชิดขวา (เช่น เลือกทั้งหมด)
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: _t(17.0,
                                    color: _inkTitle, weight: FontWeight.w700)),
                            const SizedBox(height: 2.0),
                            Text(sub,
                                style: _t(12.5,
                                    color: _ink3, weight: FontWeight.w500)),
                          ])),
                      if (trail != null) trail,
                    ]),
              ),
              // ข้อเสนอ AI ของทั้งกริด: การ์ดซ้อน "เพิ่มอัตโนมัติ" เหนือกริด
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: autoCard([for (final (l, _) in fs) l]),
              ),
              // วางกริดเอง (แบบหน้าตรวจร่างกาย/AIS): กางแล้วทุกการ์ดเลื่อนตำแหน่งไปพร้อมกัน
              LayoutBuilder(builder: (context, box) {
                const gap = 10.0;
                final full = box.maxWidth;
                final half = (full - gap) / 2;
                const dur = Duration(milliseconds: 380);
                const crv = Curves.easeInOutCubic;
                double hOf(String l) => riskOpen == l ? 150.0 + 82.0 : 150.0;
                final rects = <String, Rect>{};
                var y = 0.0, col = 0;
                var rowH = 0.0;
                for (final (l, _) in fs) {
                  final h = hOf(l);
                  if (riskOpen == l) {
                    if (col == 1) {
                      y += rowH + gap;
                      col = 0;
                      rowH = 0.0;
                    }
                    rects[l] = Rect.fromLTWH(0.0, y, full, h);
                    y += h + gap;
                  } else {
                    rects[l] =
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
                    for (final (l, table) in fs)
                      AnimatedPositioned(
                        key: ValueKey('risk-card-$l'),
                        duration: dur,
                        curve: crv,
                        left: rects[l]!.left,
                        top: rects[l]!.top,
                        width: rects[l]!.width,
                        height: rects[l]!.height,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minHeight: 0.0,
                            maxHeight: double.infinity,
                            child:
                                card(l, table, riskOpen == l, rects[l]!.height),
                          ),
                        ),
                      ),
                  ]),
                );
              }),
            ]);
      }

      // หน้าปัจจัยเสี่ยง: ภาพจาก Figma 987:1072 · เสี่ยง (ดื่ม ใช้ ไม่คาด ไม่สวม) = ส้ม · ไม่ทราบ = เทา
      Widget riskPage() => choiceGrid(
            'ปัจจัยเสี่ยง',
            'แตะการ์ดเพื่อเลือกในแต่ละหัวข้อ',
            [
              for (final (_, _, f)
                  in _accGroups.where((g) => g.$1 == 'ปัจจัยเสี่ยง'))
                ...f
            ],
            (l) => Image.asset(
                switch (l) {
                  'แอลกอฮอล์' => 'assets/images/er_risk_alcohol.png',
                  'สารเสพติด' => 'assets/images/er_risk_drug.png',
                  'เข็มขัดนิรภัย' => 'assets/images/er_risk_belt.png',
                  _ => 'assets/images/er_risk_helmet.png',
                },
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium),
            (o) => const {'ดื่ม', 'ใช้', 'ไม่คาด', 'ไม่สวม'}.contains(o)
                ? 1
                : o == 'ไม่ทราบ'
                    ? 2
                    : 0,
          );

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
          // เลือกเสร็จ = เปิดการ์ดส่วนถัดไปที่ยังไม่ได้เลือก (ไล่ต่อจากส่วนนี้ วนกลับต้นถ้าสุดแล้ว)
          // เอาค่าออก หรือเลือกครบทุกส่วนแล้ว = หุบกลับครึ่งแถว
          final picked = v.containsKey(r);
          Future.delayed(const Duration(milliseconds: 720), () {
            if (!ctx.mounted || aisOpen != r) return;
            final at = _accRegions.indexOf(r);
            final next = picked
                ? [
                    ..._accRegions.skip(at + 1),
                    ..._accRegions.take(at),
                  ].where((x) => !hasValue(x)).firstOrNull
                : null;
            set(() => aisOpen = next);
            // เลื่อนการ์ดที่เปิดขึ้นชิดบนของรายการ (รอการ์ดขยาย/ย้ายที่เสร็จ 380 มิลลิวินาที)
            if (next != null) {
              Future.delayed(const Duration(milliseconds: 420), () {
                final c = aisKeys[next]?.currentContext;
                if (c == null || !c.mounted) return;
                // alignment 0 = ขอบบนการ์ดชิดบนรายการ
                Scrollable.ensureVisible(c,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic);
              });
            }
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
        // ก่อนเลือกส่วน: การ์ดแบบผลตรวจร่างกาย (ชื่อ คำอธิบาย ภาพ · ปุ่มเพิ่ม) + ส่วนที่เลือกแล้ว
        // แตะเพิ่ม / แถวส่วน = เปิดกริดเลือกส่วนของร่างกาย
        if (!aisPicking) {
          void openPick([String? r]) {
            HapticFeedback.selectionClick();
            set(() {
              aisPicking = true;
              aisOpen = r;
            });
          }

          return _dxCard(
            'AIS Score',
            'เลือกระดับความรุนแรง AIS ของแต่ละส่วนของร่างกาย',
            art('assets/images/er_ais_thorax.png'),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // คะแนน ISS / RTS ในการ์ดเดียวกัน (เห็นผลของ AIS ที่เลือกทันที)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: scoreBar(),
              ),
              // ทุกส่วนของร่างกายเป็นแถวเสมอ (ไม่มีปุ่มเพิ่ม/แก้ไขแยก) · แตะแถว = กริดเลือก กางส่วนนั้น
              // ยังไม่เลือก = เทา "ยังไม่เลือก" · AIS ≥ 3 = แดง
              for (final (i, r) in _accRegions.indexed)
                Builder(builder: (_) {
                  final k = _accAisOf(v[r]);
                  return _gListRow(
                    first: i == 0,
                    inset: 8.0,
                    lead: SizedBox.square(
                      dimension: 40.0,
                      child: Opacity(
                        opacity: k == null ? 0.55 : 1.0,
                        child: Image.asset(_accRegionArt[r]?.$2 ?? '',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                      ),
                    ),
                    title: _accRegionArt[r]?.$1 ?? r,
                    sub: k == null
                        ? 'ยังไม่เลือก'
                        : 'AIS $k ${_accAisShort[k] ?? ''}',
                    subColor: k == null
                        ? _ink3
                        : k >= 3
                            ? _red
                            : _ink2,
                    onTap: () => openPick(r),
                  );
                }),
            ]),
          );
        }
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
                          child: KeyedSubtree(
                            key: aisKeys.putIfAbsent(r, GlobalKey.new),
                            child: aisCard(r, aisOpen == r, rects[r]!.height),
                          ),
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
        // แถวแบบรายการ V/S ในซักประวัติ (vsCard แผงแคบ): ภาพ/ไอคอน · ชื่อ + ค่าปกติ · ค่า (แดง = ผิดปกติ)
        // แตะ = วงล้อเลือกค่า · RTS / ISS คำนวณเอง แสดงในการ์ดคะแนนด้านบน (ไม่ซ้ำเป็นแถว)
        bool badOf(String k, double x) => switch (k) {
              'GCS.v' => x < 13,
              'BPs' => x < 90,
              'RR' => x < 10 || x > 29,
              _ => false,
            };
        Widget vsRow(
            String k, String th, String? normal, String unit, List<String> opts,
            {Widget? fig,
            IconData icon = Icons.analytics_outlined,
            bool first = false}) {
          final raw = v[k]?.trim();
          final x = double.tryParse(raw ?? '');
          final has = x != null;
          final red = has && badOf(k, x);
          return Column(mainAxisSize: MainAxisSize.min, children: [
            if (!first)
              const Divider(
                  height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
            InkWell(
              onTap: () => _wheelPick(
                  th,
                  opts,
                  raw,
                  (o) => set(() {
                        v[k] = o;
                        textControllers[k]?.text = o;
                      })),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(children: [
                  fig ??
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: red
                              ? _red.withValues(alpha: 0.12)
                              : has
                                  ? _green.withValues(alpha: 0.12)
                                  : _blue.withValues(alpha: 0.08),
                        ),
                        child: Icon(icon,
                            size: 20.0,
                            color: red
                                ? _red
                                : has
                                    ? _green
                                    : _blue),
                      ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: th,
                                style: _t(14.5,
                                    color: _inkTitle, weight: FontWeight.w500)),
                            // ค่าปกติ / ถ้ามี = ป้ายเล็กพื้นเทา (ชุดเดียวกับป้าย "ถ้ามี" ของ _gListRow)
                            if (normal != null)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 1.0),
                                  decoration: BoxDecoration(
                                    color: _panelSoft,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(normal,
                                      style: _t(11.5,
                                          color: _ink2,
                                          weight: FontWeight.w600)),
                                ),
                              ),
                          ])),
                          const SizedBox(height: 2.0),
                          Text(has ? '$raw $unit'.trim() : 'ยังไม่ระบุ',
                              style: _t(13.0,
                                  color: red
                                      ? _red
                                      : has
                                          ? _blue
                                          : _ink3,
                                  weight: FontWeight.w500)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22.0, color: _ink3),
                ]),
              ),
            ),
          ]);
        }

        // PS (TRISS): คำนวณเองจาก RTS ISS อายุ ไม่ต้องเลือก · แสดงเป็นร้อยละ
        // < 0.5 = แดง (โอกาสรอดต่ำ เกณฑ์ unexpected outcome ของ TRISS)
        Widget psRow() {
          final ps = double.tryParse(v['PS'] ?? '');
          final low = ps != null && ps < 0.5;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Divider(
                height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(children: [
                // เหรียญ 2.5D "%" แทนภาพประกอบ (ช่องไอคอนซ้าย 40) · คำนวณเอง ไม่ต้องเลือก
                // สีตามผล: ยังคำนวณไม่ได้ = เทา · รอดสูง = เขียว · ต่ำกว่า 50% = แดง
                SizedBox.square(
                  dimension: 40.0,
                  child: FittedBox(
                    child: KeyedSubtree(
                      key: ValueKey('ps-coin-${ps == null ? 0 : low ? 1 : 2}'),
                      child: _PeStatusPop(
                        delay: Duration.zero,
                        child: ps == null
                            ? const _SoStatusCoin.label('%',
                                face: [Color(0xFFF4F6FA), Color(0xFFD6DCE6)],
                                side: [Color(0xFFBCC4D0), Color(0xFF9EA8B7)])
                            : low
                                ? const _SoStatusCoin.label('%', face: [
                                    Color(0xFFFF7B72),
                                    Color(0xFFD93025)
                                  ], side: [
                                    Color(0xFFB3261E),
                                    Color(0xFF8C1D18)
                                  ])
                                : const _SoStatusCoin.label('%', face: [
                                    Color(0xFF5BE08F),
                                    Color(0xFF22B45E)
                                  ], side: [
                                    Color(0xFF1B8F4C),
                                    Color(0xFF0F6B37)
                                  ]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('โอกาสรอดชีวิต (PS)',
                            style: _t(14.5,
                                color: _inkTitle, weight: FontWeight.w500)),
                        const SizedBox(height: 2.0),
                        Text(
                            ps == null
                                ? 'คำนวณเมื่อมี RTS และ ISS'
                                : '${(ps * 100).round()}%  (${ps.toStringAsFixed(2)})',
                            style: _t(13.0,
                                color: low
                                    ? _red
                                    : ps != null
                                        ? _blue
                                        : _ink3,
                                weight: FontWeight.w500)),
                      ]),
                ),
              ]),
            ),
          ]);
        }

        // ที่มาและวิธีคำนวณคะแนน: dialog ชุดเดียวกับ "แนวโน้มในภาพรวมคำนวณอย่างไร" (_ovTrendInfo)
        // หัวข้อละแถว ไอคอนวงสีจาง + ชื่อ + บรรทัดอธิบาย · ปุ่ม "เข้าใจแล้ว"
        // เนื้อหาตรงกับสูตรในโค้ด: _accRts _accIss _accPs (knowledge ข้อ 71 73)
        void learnMore() {
          HapticFeedback.selectionClick();
          Widget sec(IconData ic, Color c, String title, List<String> lines) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.12),
                            shape: BoxShape.circle),
                        child: Icon(ic, size: 18.0, color: c),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: _t(15.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              const SizedBox(height: 4.0),
                              for (final l in lines)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: Text(l,
                                      style: _t(13.0,
                                          color: _ink2,
                                          weight: FontWeight.w500)),
                                ),
                            ]),
                      ),
                    ]),
              );
          showDialog<void>(
            context: ctx,
            builder: (dctx) => Dialog(
              backgroundColor: _panel,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('คะแนน Trauma คำนวณอย่างไร',
                            style: _t(18.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 4.0),
                        Text(
                            'ระบบคำนวณจากค่าที่บันทึก เพื่อช่วยประเมินความรุนแรง ไม่ใช่การวินิจฉัย',
                            style: _t(13.0,
                                color: _ink3, weight: FontWeight.w500)),
                        const SizedBox(height: 18.0),
                        sec(Icons.psychology_outlined, _blue,
                            'GCS (Teasdale & Jennett 1974)', [
                          'ผลรวมของการลืมตา (E 1–4) การพูด (V 1–5) และการเคลื่อนไหว (M 1–6) ได้ 3–15',
                          '13–15 เล็กน้อย, 9–12 ปานกลาง, 3–8 รุนแรง',
                        ]),
                        sec(Icons.monitor_heart_outlined, _red,
                            'RTS (Champion 1989)', [
                          'แปลง GCS ความดันซิสโตลิก และอัตราการหายใจ เป็นรหัส 0–4 แล้วถ่วงน้ำหนัก',
                          'RTS = 0.9368 × GCS + 0.7326 × SBP + 0.2908 × RR (ใช้รหัส)',
                          'GCS 13–15 = 4, 9–12 = 3, 6–8 = 2, 4–5 = 1, 3 = 0',
                          'SBP มากกว่า 89 = 4, 76–89 = 3, 50–75 = 2, 1–49 = 1, 0 = 0',
                          'RR 10–29 = 4, มากกว่า 29 = 3, 6–9 = 2, 1–5 = 1, 0 = 0',
                          'ช่วง 0–7.84 ยิ่งต่ำยิ่งรุนแรง ต่ำกว่า 4 พิจารณาส่ง Trauma center',
                        ]),
                        sec(Icons.personal_injury_outlined,
                            const Color(0xFFDC8610), 'ISS (Baker 1974)', [
                          'จากระดับ AIS ของแต่ละส่วนของร่างกาย เลือก 3 ส่วนที่ระดับสูงสุด แล้วรวมกำลังสอง',
                          'ISS = a² + b² + c² ได้ 0–75 มีส่วนใดเป็น AIS 6 = 75 ทันที',
                          '1–8 เล็กน้อย, 9–15 ปานกลาง, 16–24 รุนแรง, 25 ขึ้นไป วิกฤต',
                          'ISS 16 ขึ้นไป ถือเป็น Major trauma',
                        ]),
                        sec(Icons.percent_rounded, _green,
                            'PS โอกาสรอดชีวิต (TRISS, Boyd 1987)', [
                          'ใช้ RTS ISS และอายุ คำนวณโอกาสรอดชีวิต 0–1 แสดงเป็นร้อยละ',
                          'b = b0 + b1 × RTS + b2 × ISS + b3 × อายุ แล้ว PS = 1 ÷ (1 + e^−b)',
                          'บาดเจ็บแบบกระแทก: b0 −0.4499, b1 0.8085, b2 −0.0835, b3 −1.7430',
                          'บาดแผลทะลุ (ถูกแทง ยิง): b0 −2.5355, b1 0.9934, b2 −0.0651, b3 −1.1360',
                          'อายุ 55 ปีขึ้นไป = 1 ต่ำกว่า = 0 · ต่ำกว่า 50% ถือว่าโอกาสรอดต่ำ',
                        ]),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(dctx).pop(),
                            child: Text('เข้าใจแล้ว',
                                style: _t(14.0,
                                    color: _blue, weight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          );
        }

        // GCS: การ์ดเดียวกับช่อง GCS หน้าภาพรวม (_neuroRow) · คะแนนใหญ่ /15 · E V M · ระดับ + แถบ 3–15
        // E V M จากการประเมินของเคส (ตรงกับคะแนนรวมเท่านั้น) · แตะ = วงล้อเลือกคะแนนรวม
        Widget gcsTile() {
          final total = int.tryParse(v['GCS.v']?.trim() ?? '');
          final m = RegExp(r'E(\d)\D*V(\d)\D*M(\d)')
              .firstMatch(erCaseOf(p.hn).gcs ?? '');
          final evm = m == null
              ? null
              : [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
          final sub = total == null
              ? 'ยังไม่ประเมิน'
              : evm != null && evm.reduce((a, b) => a + b) == total
                  ? 'E${evm[0]} V${evm[1]} M${evm[2]}'
                  : 'คะแนนรวม';
          final bad = (total ?? 15) <= 8;
          final level = total == null
              ? ''
              : total <= 8
                  ? 'Severe'
                  : total <= 12
                      ? 'Moderate'
                      : 'Mild';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Material(
              color: bad ? _vsHot : _panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                    color: bad ? _vsHot : const Color(0xFFDADCE0), width: 0.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _wheelPick(
                    'GCS รวม',
                    [for (var i = 15; i >= 3; i--) '$i'],
                    total?.toString(),
                    (o) => set(() {
                          v['GCS.v'] = o;
                          textControllers['GCS.v']?.text = o;
                        })),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 14.0, 12.0),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GCS',
                                style: _t(13.0,
                                    color: bad ? Colors.white : _inkTitle,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 2.0),
                            Text.rich(
                                TextSpan(
                                    text: total?.toString() ?? '-',
                                    children: [
                                      TextSpan(
                                          text: ' /15',
                                          style: _t(13.0,
                                              color: bad
                                                  ? const Color(0xE6FFFFFF)
                                                  : _ink3,
                                              weight: FontWeight.w500)),
                                    ]),
                                style: _num(20.0,
                                    color: bad ? Colors.white : _inkTitle,
                                    weight: FontWeight.w700)),
                            Text(sub,
                                style: _t(12.0,
                                    color:
                                        bad ? const Color(0xE6FFFFFF) : _ink3,
                                    weight: FontWeight.w500)),
                          ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(level,
                              style: _t(17.0,
                                  color: bad
                                      ? Colors.white
                                      : (total ?? 15) <= 12
                                          ? const Color(0xFFDC8610)
                                          : _inkTitle,
                                  weight: FontWeight.w700)),
                          const SizedBox(height: 8.0),
                          SizedBox(
                              width: 128.0,
                              height: 18.0,
                              child:
                                  CustomPaint(painter: _GcsBarPainter(total))),
                        ]),
                  ]),
                ),
              ),
            ),
          );
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // คะแนน ISS / RTS แสดงที่การ์ด Body Region (AIS) ที่เดียว (ไม่ซ้ำบนหน้านี้)
              _dxCard(
                'Trauma Score',
                'ค่าตั้งต้นจากสัญญาณชีพล่าสุด แตะเพื่อแก้',
                art(null),
                // การ์ดซ้อน (หลัก nested card): ขาว ขอบ 0.5 · ระยะใน 8 จากขอบการ์ดนอก (_dxCard) < หัวข้อ 16
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gcsTile(),
                      const SizedBox(height: 4.0),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                              color: const Color(0xFFDADCE0), width: 0.5),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              vsRow(
                                  'BPs',
                                  'ความดันซิสโตลิก',
                                  'ปกติ ≥ 90',
                                  'mmHg',
                                  [for (var i = 250; i >= 0; i -= 2) '$i'],
                                  fig: _vsFigmaIcon('sbp', size: 40.0),
                                  first: true),
                              vsRow('RR', 'อัตราการหายใจ', 'ปกติ 10–29', '/min',
                                  [for (var i = 60; i >= 0; i--) '$i'],
                                  fig: _vsFigmaIcon('rr', size: 40.0)),
                              psRow(),
                            ]),
                      ),
                    ]),
                // ปุ่ม FYI วงกลม ⓘ ชุดเดียวกับหน้าภาพรวม (แนวโน้มคำนวณอย่างไร)
                trail: Tooltip(
                  message: 'คะแนนคำนวณอย่างไร',
                  child: Material(
                    color: _panelSoft,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: learnMore,
                      child: const SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Icon(Icons.info_outline_rounded,
                            size: 18.0, color: _ink2),
                      ),
                    ),
                  ),
                ),
              ),
            ]);
      }

      // หน้า 3: การดูแลก่อนมาถึง · หมายเหตุ (การ์ดหมวดแบบ HPI)
      // note = หน้าหมายเหตุ (ขั้นที่ 2 ของขั้นย่อยการดูแล) ใช้การ์ดชุดเดียวกัน
      Widget carePage({bool note = false}) {
        // ชื่อสั้นของตัวเลือกการดูแล (master เป็นประโยคยาว เช่น "มีการห้ามเลือดก่อนมาถึงไม่เหมาะสม")
        String careShort(String o) => o.contains('ไม่เหมาะสม')
            ? 'ไม่เหมาะสม'
            : o == 'ไม่จำเป็น'
                ? 'ไม่จำเป็น'
                : o.startsWith('ไม่มี')
                    ? 'ไม่มี'
                    : 'มี';
        final care = [
          for (final (_, _, fs)
              in _accGroups.where((g) => g.$1 == 'การดูแลก่อนมาถึง'))
            ...fs
        ];
        Widget noteCard(String l, String title, String sub, String? asset,
            {Widget? artW}) {
          final has = hasValue(l);
          Future<void> open() => editText(l, title);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _dxCard(
              title,
              sub,
              artW ?? art(asset),
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
                    titleLines: 2,
                    sub: '',
                    onTap: open,
                  ),
              ]),
            ),
          );
        }

        if (note) {
          return noteCard(
              'หมายเหตุ', 'หมายเหตุ', 'ข้อมูลอื่นที่ต้องบันทึกเพิ่ม', null,
              // ภาพไอคอนสี่เหลี่ยม: วางพอดีมุมขวา (แบบการ์ดเล่าเหตุการณ์) ไม่ขยายเต็มช่อง
              artW: Padding(
                padding: const EdgeInsets.fromLTRB(56.0, 14.0, 14.0, 22.0),
                child: Image.asset('assets/images/er_os_note_add.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                    filterQuality: FilterQuality.medium),
              ));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ทุกหัวข้อเป็นการ์ดเลือก (แบบปัจจัยเสี่ยง/AIS) · ตัวเลือกยาว = ชื่อสั้น มี/ไม่มี/ไม่จำเป็น/ไม่เหมาะสม
            // มี = ✓ เขียว · ไม่เหมาะสม = ส้ม · ไม่มี/ไม่จำเป็น = เทา
            choiceGrid(
              'การดูแลก่อนมาถึง',
              'สิ่งที่ผู้ป่วยได้รับระหว่างนำส่ง ไม่บังคับกรอก',
              care,
              // ภาพชุดเดียวกับการ์ดระบบ ROS/PE (ภาพประกอบแบน) · ยังไม่มีภาพเฉพาะใน Figma
              (l) => Image.asset(
                  switch (l) {
                    'การดูแลการหายใจ' => 'assets/images/er_ros_sys_resp.png',
                    'การห้ามเลือด' => 'assets/images/er_ros_sys_hemato.png',
                    'การให้ IV fluid' => 'assets/images/er_os_proc.png',
                    'การใส่ Splint/Slab' => 'assets/images/er_ros_sys_msk.png',
                    _ => 'assets/images/er_xr_bone_side.png',
                  },
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium),
              (o) => careShort(o) == 'มี'
                  ? 0
                  : careShort(o) == 'ไม่เหมาะสม'
                      ? 1
                      : 2,
              short: careShort,
              order: const ['มี', 'ไม่มี', 'ไม่จำเป็น', 'ไม่เหมาะสม'],
              // เลือกค่าเดียวให้ทุกหัวข้อ (เช่น ไม่จำเป็นทั้งหมด) แล้วแก้รายข้อต่อได้
              trail: TextButton.icon(
                onPressed: () => _wheelPick(
                    'เลือกทั้งหมดเป็น',
                    const ['มี', 'ไม่มี', 'ไม่จำเป็น', 'ไม่เหมาะสม'],
                    null,
                    (sel) => set(() {
                          for (final (l, table) in care) {
                            final o = _accOptions(table)
                                .where((x) => careShort(x) == sel)
                                .firstOrNull;
                            if (o == null) continue;
                            v[l] = o;
                            textControllers[l]?.text = o;
                          }
                        })),
                style: TextButton.styleFrom(
                  foregroundColor: _blue,
                  backgroundColor: const Color(0xFFE2EAF8),
                  shape: const StadiumBorder(),
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0.0, 36.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 16.0),
                label: Text('เลือกทั้งหมด',
                    style: _t(12.5, color: _blue, weight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12.0),
            // การดูแลอื่น: แถวเดียวในการ์ดซ้อน (แบบแถวจุดเกิดเหตุ/ทะเบียนรถ) ไม่ใช่การ์ดที่มีแต่ปุ่มเพิ่ม
            // แตะ = หน้าพิมพ์ในแผง (ลบได้ในหน้านั้น)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: _gListRow(
                first: true,
                inset: 8.0,
                title: 'การดูแลอื่น',
                badge: 'ถ้ามี',
                sub: hasValue(_accPreNote)
                    ? v[_accPreNote]!.trim()
                    : 'การดูแลระหว่างนำส่งที่ไม่มีในรายการด้านบน',
                subColor: hasValue(_accPreNote) ? _inkTitle : _ink3,
                subLines: 2,
                onTap: () => editText(_accPreNote, 'การดูแลอื่น'),
              ),
            ),
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
                        // ช่องบังคับที่ยังว่าง = ป้ายแดง (ชุดเดียวกับดอกจันแดง) · ไม่บังคับ = ป้ายเทา
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: _accRequired.contains(k)
                                  ? _red.withValues(alpha: 0.1)
                                  : const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text('ยังไม่ได้กรอก',
                                style: _t(12.5,
                                    color:
                                        _accRequired.contains(k) ? _red : _ink2,
                                    weight: FontWeight.w600)),
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

      // ขั้นย่อยของหน้าปัจจุบัน (หน้าแนะนำ = introGroup)
      final grp = page == 0
          ? introGroup
          : math.max(
              0, _accRailSubs.indexWhere((x) => page >= x.$2 && page <= x.$3));
      final (grpName, grpA, grpB) = _accRailSubs[grp];
      // หมวด (steps) ที่อยู่ในขั้นย่อยนี้ · ช่องบังคับที่ยังว่างของขั้นย่อยนี้
      final grpSteps = <int>{
        for (var pg = grpA; pg <= grpB; pg++) ...pageSteps[pg - 1].$2
      };
      final grpMissing = [
        for (final k in grpSteps)
          for (final l in steps[k].$4)
            if (_accRequired.contains(l) && !hasValue(l)) l,
      ];

      // หน้าสรุปของขั้นย่อย: เฉพาะหัวข้อในขั้นย่อยนี้ แตะแถว = กลับไปแก้ · ว่าง = pill เทา
      Widget groupReview() {
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
                    width: 150.0,
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
                            maxLines: k.isEmpty ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.5,
                                color: _inkTitle,
                                height: 1.4,
                                weight: FontWeight.w600))
                        // ช่องบังคับที่ยังว่าง = ป้ายแดง (ชุดเดียวกับดอกจันแดง) · ไม่บังคับ = ป้ายเทา
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: _accRequired.contains(k)
                                  ? _red.withValues(alpha: 0.1)
                                  : const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text('ยังไม่ได้กรอก',
                                style: _t(12.5,
                                    color:
                                        _accRequired.contains(k) ? _red : _ink2,
                                    weight: FontWeight.w600)),
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
                borderRadius: BorderRadius.circular(16.0),
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
                grpMissing.isEmpty
                    ? 'ตรวจทานข้อมูล$grpName กดย้อนกลับหรือแตะรายการเพื่อแก้'
                    : 'ยังขาด ${grpMissing.length} ช่อง แตะรายการเพื่อกรอก',
                style: _t(12.5,
                    color: grpMissing.isEmpty ? _ink3 : _blue,
                    weight: FontWeight.w500)),
            const SizedBox(height: 16.0),
            if (grp == 0 && narrative.text.trim().isNotEmpty)
              sumCard(_accNarrTitle, [row('', narrative.text, grpA)]),
            for (final k in grpSteps.toList()..sort())
              sumCard(steps[k].$1, [
                for (final l in steps[k].$4) row(l, v[l], pageOf(l)),
              ]),
            if (grp == 1)
              sumCard('คะแนน', [
                for (final l in const ['RTS', 'ISS', 'PS'])
                  row(l, v[l], scorePage),
              ]),
          ],
        );
      }

      // บันทึกขั้นย่อยนี้: เก็บค่าทั้งหมดที่กรอกแล้ว (แบบ _accFinish แต่ไม่ปิดฟอร์มก่อนแอนิเมชัน)
      // แอนิเมชันบันทึกเดียวกับทุกขั้น แล้วหุบแผง แผงซ้ายเปิดหน้าอุบัติเหตุ (แบบบันทึกซักประวัติ)
      void saveGroup() {
        _wfSaveBurst(grpName,
            atFull: () {
              final keep = {..._accLabels(), ..._accExtraLabels};
              final out = {
                for (final e in v.entries)
                  if (keep.contains(e.key)) e.key: e.value
              };
              _accDrafts.remove(p.hn);
              setState(() => _accStore[p.hn] = out);
            },
            onClose: () {
              setState(() => _detailTab = _accTab);
              _accPaneDrop();
              _closeSpeech();
            },
            // หน้าสำเร็จ "ดูที่บันทึก" = หน้าอุบัติเหตุแผงซ้าย
            onView: () => setState(() => _detailTab = _accTab));
      }

      final content = reviewing
          ? groupReview()
          : switch (page) {
              0 => introPage(),
              1 => eventPage(),
              2 => arrivalPage(),
              3 => riskPage(),
              4 => aisPage(),
              5 => scorePageView(),
              6 => carePage(),
              7 => carePage(note: true),
              _ => reviewPage(),
            };

      // ไปช่องที่ขาด: รอหน้าเลื่อนเข้าที่ก่อน แล้วค่อยกวาดแสงแดงที่แถวที่ยังว่าง · จบแล้วล้าง
      void flashMissing(List<String> ls) {
        Future.delayed(const Duration(milliseconds: 380), () async {
          if (!ctx.mounted) return;
          // แถวแรกที่ขาดอยู่นอกจอ = เลื่อนมากลางจอก่อน แล้วจึงกวาดแสง
          final c = rowKeys[ls.first]?.currentContext;
          if (c != null && c.mounted) {
            await Scrollable.ensureVisible(c,
                alignment: 0.45,
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic);
          }
          if (!ctx.mounted) return;
          set(() {
            nudge = {...ls};
            nudgeTick++;
          });
          final tick = nudgeTick;
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (ctx.mounted && nudgeTick == tick) set(() => nudge = {});
          });
        });
      }

      // ปุ่มหลัก: เริ่มกรอก → ถัดไป → ตรวจทาน → บันทึก (ยังขาด = ไปช่องที่ขาด)
      final Widget main;
      if (page == 0) {
        main = _navBtn('เริ่มกรอก', Icons.chevron_right_rounded,
            () => go(_accRailSubs[introGroup].$2),
            trailing: true);
      } else if (reviewing) {
        // หน้าสรุปของขั้นย่อย: ครบ = บันทึกหัวข้อนี้ · ยังขาด = พาไปช่องที่ขาด
        main = grpMissing.isEmpty
            ? KeyedSubtree(
                key: _wfSaveBtnKey,
                child: _navBtn('บันทึก', Icons.check_rounded, saveGroup))
            : _navBtn('ไปช่องที่ขาด (${grpMissing.length})',
                Icons.chevron_right_rounded, () {
                final l = grpMissing.first;
                go(l == _accWhen ? grpA : pageOf(l));
                flashMissing(grpMissing);
              }, trailing: true);
      } else if (page < lastPage) {
        // หน้าสุดท้ายของขั้นย่อย = ตรวจทาน (หน้าสรุปของขั้นย่อย) ไม่ข้ามไปขั้นย่อยถัดไป
        main = _navBtn(
            page == grpB ? 'ตรวจทาน' : 'ถัดไป', Icons.chevron_right_rounded,
            () {
          if (page == grpB) {
            HapticFeedback.selectionClick();
            set(() {
              fwd = true;
              reviewing = true;
            });
          } else {
            go(page + 1);
          }
        }, trailing: true);
      } else if (missing.isEmpty) {
        main = _navBtn(
            'บันทึกข้อมูลอุบัติเหตุ', Icons.check_rounded, () => close(true));
      } else {
        main = _navBtn(
            'ไปช่องที่ขาด (${missing.length})', Icons.chevron_right_rounded,
            () {
          go(pageOf(missing.first));
          flashMissing(missing);
        }, trailing: true);
      }

      // ในแผง workflow: ฟอร์มนี้เป็นที่วางหน้าพิมพ์ข้อความ (_ftOpen inWorkflow) แทนแผ่นลอย
      // = หน้าย่อยในแผงชุดเดียวกับ Doctor Note (breadcrumb + กล่องพิมพ์ + footer ยกเลิก ไมค์ บันทึก)
      if (embedded) {
        _wfTextRebuild = () {
          if (ctx.mounted) set(() {});
        };
        // ลบข้อความในหน้าพิมพ์ = ยืนยันก่อน (dialog กลางของ ER ยกเลิก + ลบ)
        _wfConfirmDelete = (title) => _wfTextConfirmDelete(title);
      }
      final writing = embedded ? _wfText : null;

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
            // แถบขั้นเฉพาะหน้าในขั้นย่อยปัจจุบัน (แบบเมนูซักประวัติ: แต่ละขั้นย่อยมีแถบของตัวเอง)
            child: Builder(builder: (_) {
              final (_, a, b) = _accRailSubs.firstWhere(
                  (x) => page >= x.$2 && page <= x.$3,
                  orElse: () => _accRailSubs.first);
              // ท้าย stepper ของทุกขั้นย่อย = สรุป (ตรวจทานก่อนบันทึกหัวข้อนี้)
              return _hxStepper(
                [
                  for (var pg = a; pg <= b; pg++)
                    (pageNames[pg - 1], pageDone[pg - 1]),
                  ('สรุป', grpMissing.isEmpty),
                ],
                reviewing ? b - a + 1 : page - a,
                onTap: (i) {
                  if (i == b - a + 1) {
                    if (reviewing) return;
                    HapticFeedback.selectionClick();
                    set(() {
                      fwd = true;
                      reviewing = true;
                    });
                  } else {
                    go(a + i);
                  }
                },
              );
            }),
          )
        else
          const SizedBox(height: 16.0),
        // หลักการ footer แผงขวา: ปุ่มลอยเหนือเนื้อหาที่จางลง ไม่มีแถบแยก (_wfFadePage ชุดเดียวกับขั้นอื่น)
        Expanded(
          // เลื่อนเนื้อหาลง = หุบ stepper · เลื่อนขึ้น/บนสุด = กางกลับ (ชุดเดียวกับซักประวัติ _hxScrollHide)
          child: _hxScrollHide(_wfFadePage(
            // เปลี่ยนหน้า: ชุดเดียวกับหน้าในขั้นอื่นของ workflow (workflow_rail)
            // หน้าใหม่เลื่อนเข้าหลังเฟรมแรก (_LateSlideIn) · หน้าเก่าจาง+เลื่อนออก easeIn · ชิดบนซ้าย
            ClipRect(
                clipper: const _ClipPastRight(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (a, b) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...b, if (a != null) a]),
                  transitionBuilder: (child, a) {
                    final enter = child.key ==
                        ValueKey('acc-page-$page-$introGroup-$reviewing');
                    final dir = fwd ? 1.0 : -1.0;
                    if (enter)
                      return _LateSlideIn(dx: 0.22 * dir, child: child);
                    return FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                                begin: Offset(-0.22 * dir, 0), end: Offset.zero)
                            .animate(a),
                        child: child,
                      ),
                    );
                  },
                  // key ตามหน้า: เปลี่ยนหน้า = เริ่มบนสุดเสมอ (design rule)
                  child: ListView(
                    key: ValueKey('acc-page-$page-$introGroup-$reviewing'),
                    // ล่างเว้น 96 ให้แถวสุดท้ายพ้นปุ่มลอย
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
                    children: [content],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Row(children: [
                // ย้อน: หน้าแรกของขั้นย่อย → หน้าแนะนำของขั้นย่อยนั้น
                // · หน้าแนะนำ → หน้าสุดท้ายของขั้นย่อยก่อนหน้า
                _wfFootBack(page > 0
                    ? () {
                        // หน้าสรุปขั้นย่อย = กลับหน้าสุดท้ายของขั้นย่อย
                        if (reviewing) {
                          HapticFeedback.selectionClick();
                          set(() {
                            fwd = false;
                            reviewing = false;
                          });
                          return;
                        }
                        // กริดเลือกส่วน AIS = ย้อนกลับไปการ์ดสรุปก่อน
                        if (aisPicking) {
                          HapticFeedback.selectionClick();
                          set(() {
                            aisPicking = false;
                            aisOpen = null;
                          });
                          return;
                        }
                        final g = groupStarting(page);
                        if (g >= 0) {
                          toIntro(g, forward: false);
                        } else {
                          go(page - 1);
                        }
                      }
                    : introGroup > 0
                        ? () => go(_accRailSubs[introGroup - 1].$3)
                        : null),
                Expanded(child: main),
                _wfFootSide(
                    show: page >= 1 && !reviewing,
                    left: false,
                    child: _wfIconBtn(
                        Icons.fact_check_outlined,
                        'ไปหน้าสรุป',
                        () => set(() {
                              fwd = true;
                              reviewing = true;
                            }))),
              ]),
            ),
          )),
        ),
      ]);
      if (embedded) {
        // รางขวา: ขั้นย่อยของอุบัติเหตุไฮไลต์ตามหน้าปัจจุบัน · แตะขั้นย่อย = ขอไปหน้านั้น
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // หน้าแนะนำ = ค่าติดลบบอกขั้นย่อย (-1 = ขั้นย่อยแรก)
          final at = page == 0 ? -(introGroup + 1) : page;
          if (_accRailPage.value != at) _accRailPage.value = at;
        });
        return ValueListenableBuilder<int?>(
          valueListenable: _accRailGo,
          builder: (_, to, __) {
            if (to != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_accRailGo.value != to) return;
                _accRailGo.value = null;
                if (!ctx.mounted) return;
                // ขั้นย่อยที่อยู่ตอนนี้ (หน้าแนะนำ = introGroup)
                final cur = page == 0
                    ? introGroup
                    : _accRailSubs
                        .indexWhere((x) => page >= x.$2 && page <= x.$3);
                toIntro(to, forward: to > cur);
              });
            }
            if (writing == null) return body;
            return ColoredBox(
              key: ObjectKey(writing),
              color: _panel,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
                      child: Row(children: [
                        _CrumbPrev('อุบัติเหตุ',
                            onTap: () => _wfTextClose(null)),
                        const _CrumbSep(),
                        Expanded(
                          child: Text(writing.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(14.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    Expanded(child: _FtPage(req: writing)),
                  ]),
            );
          },
        );
      }
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

/// เหรียญระดับ AIS (ตัวเลข 1–6) แบบเหรียญสถานะผลตรวจร่างกาย (_PeBadge25D):
/// แผ่นวงกลมซ้อนหลายชั้นตามแกน Z = ขอบหนา · หน้าเหรียญไล่แสงจากซ้ายบน + ตัวเลขขาว
/// สี: 1–2 = กรมท่า (ไม่รุนแรง) · 3–6 = แดง (รุนแรง ตามกฎสีผิดปกติ) เข้มขึ้นตามระดับ
class _AisCoin extends StatelessWidget {
  const _AisCoin({required this.level, this.size = 24.0});
  final int level;
  final double size;

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
                child: Text('$level',
                    style: TextStyle(
                        fontFamily: _fontFam,
                        fontFamilyFallback: _fontFb,
                        fontSize: size * 0.48,
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

/// หน้าปัจจุบันของฟอร์มอุบัติเหตุในแผง workflow (ให้รางขวาไฮไลต์ขั้นย่อย)
final ValueNotifier<int> _accRailPage = ValueNotifier(0);

/// ขอให้ฟอร์มอุบัติเหตุไปหน้าแนะนำของขั้นย่อยนี้ (แตะขั้นย่อยในรางขวา) · รับแล้วล้างเป็น null
final ValueNotifier<int?> _accRailGo = ValueNotifier(null);

/// ขั้นย่อยของอุบัติเหตุในรางขวา (card sorting 2026-11-10: 6 หน้าฟอร์มรวมเป็น 3 กลุ่ม)
/// (ชื่อ, หน้าแรก, หน้าสุดท้าย) · หน้า 0 แนะนำ · 1 เหตุการณ์ 2 การมา 3 ความเสี่ยง
/// · 4 AIS 5 Trauma Score · 6 การดูแล 7 หมายเหตุ · 8 สรุปทั้งฟอร์ม
const _accRailSubs = [
  ('เหตุการณ์', 1, 3),
  ('ความรุนแรง', 4, 5),
  ('การดูแล', 6, 7),
];

/// หัวข้อในหน้าแนะนำของแต่ละขั้นย่อย (ลำดับเดียวกับ _accRailSubs)
const _accSubIntro = <List<(String, String)>>[
  [
    ('เหตุการณ์', 'เล่าให้ AI ช่วยกรอก วันเวลา สถานที่ ประเภท'),
    ('ข้อมูลการมา', 'ประเภทการมา หน่วยที่ส่งมา ผู้นำส่ง'),
    ('ปัจจัยเสี่ยง', 'แอลกอฮอล์ สารเสพติด เข็มขัดและหมวกนิรภัย'),
  ],
  [
    ('AIS', 'ระดับความรุนแรงของแต่ละส่วนของร่างกาย'),
    ('Trauma Score', 'RTS และ ISS คำนวณให้อัตโนมัติ'),
  ],
  [
    ('การดูแลก่อนมาถึง', 'การดูแลที่ผู้ป่วยได้รับระหว่างนำส่ง ไม่บังคับ'),
    ('หมายเหตุ', 'ข้อมูลอื่นที่ต้องบันทึกเพิ่ม ไม่บังคับ'),
  ],
];

/// แถบช่วงความรุนแรง (แบบ _GcsBarPainter): ช่วงสีต่อกันเป็นเส้นหนาปลายมน · จุดค่า = วงขาว + สีระดับ
/// bands = (เริ่ม, จบ, สี) เป็นสัดส่วน 0..1 · ช่วงที่กว้างเป็นศูนย์ (เช่น RTS ปกติ 7.84) = จุดปลายเส้น
class _AccBandPainter extends CustomPainter {
  _AccBandPainter({required this.bands, required this.at, required this.dot});
  final List<(double, double, Color)> bands;
  final double? at;
  final Color dot;

  @override
  void paint(Canvas c, Size s) {
    const r = 3.0;
    final y = s.height / 2;
    final w = s.width - 2 * r;
    double x(double f) => r + f * w;
    final p = Paint()
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    for (final (a, b, col) in bands) {
      p.color = col;
      final x1 = x(a) + (a > 0 ? 2.0 : 0.0);
      final x2 = x(b) - (b < 1 ? 2.0 : 0.0);
      c.drawLine(Offset(x1, y), Offset(math.max(x1, x2), y), p);
    }
    if (at case final f?) {
      c.drawCircle(Offset(x(f), y), 6.0, Paint()..color = Colors.white);
      c.drawCircle(Offset(x(f), y), 4.5, Paint()..color = dot);
    }
  }

  @override
  bool shouldRepaint(_AccBandPainter o) => o.at != at || o.dot != dot;
}

/// กำลังวิเคราะห์: เหรียญเด้งขึ้นทีละเหรียญไล่เป็นคลื่นวนจนกว่าจะเสร็จ (index = ลำดับในแถว)
class _AccScanBob extends StatefulWidget {
  const _AccScanBob(
      {required this.on, required this.index, required this.child});
  final bool on;
  final int index;
  final Widget child;

  @override
  State<_AccScanBob> createState() => _AccScanBobState();
}

class _AccScanBobState extends State<_AccScanBob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  bool _settling = false;
  double _settleFrom = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.on) _c.repeat();
  }

  @override
  void didUpdateWidget(_AccScanBob w) {
    super.didUpdateWidget(w);
    if (w.on == widget.on) return;
    if (widget.on) {
      _settling = false;
      _c.duration = const Duration(milliseconds: 1300);
      _c.repeat();
      return;
    }

    // หยุดการวน แล้วนุ่ม ๆ คืนเหรียญที่กำลังลอยให้ลงตำแหน่งพัก
    // การเลื่อนไปถึง 1.0 อาจจบรอบขณะเหรียญบางใบยังเด้งอยู่ โดยเฉพาะแถวที่มีหลายเหรียญ
    final u = (_c.value * 1.4 - widget.index * 0.14) % 1.4;
    _settleFrom = u < 0.5 ? math.sin(u / 0.5 * math.pi) : 0.0;
    _settling = true;
    _c.stop();
    _c.duration = const Duration(milliseconds: 180);
    _c.forward(from: 0.0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          // แต่ละเหรียญเด้งในช่วงของตัวเอง (เลื่อนเฟสตามลำดับ)
          final u = (_c.value * 1.4 - widget.index * 0.14) % 1.4;
          final k = _settling
              ? _settleFrom * (1.0 - Curves.easeOutCubic.transform(_c.value))
              : u < 0.5
                  ? math.sin(u / 0.5 * math.pi)
                  : 0.0;
          return Transform.translate(
            offset: Offset(0.0, -9.0 * k),
            child: Transform.scale(
              scale: 1.0 + 0.08 * k,
              child: RepaintBoundary(child: child),
            ),
          );
        },
        child: widget.child,
      );
}

/// เหรียญพลิกเมื่อสถานะเปลี่ยน (เทา ↔ กรมท่า) หลังหน่วง [delay] · ใช้ไล่พลิกทีละเหรียญตอนวิเคราะห์เสร็จ
class _AccCoinFlip extends StatefulWidget {
  const _AccCoinFlip(
      {required this.on, required this.delay, required this.builder});
  final bool on;
  final Duration delay;
  final Widget Function(bool on, double tilt) builder;

  @override
  State<_AccCoinFlip> createState() => _AccCoinFlipState();
}

class _AccCoinFlipState extends State<_AccCoinFlip>
    with SingleTickerProviderStateMixin {
  static const double _rest = 0.55;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560), value: 1.0);
  late bool _old = widget.on;
  late bool _shown = widget.on;

  @override
  void didUpdateWidget(_AccCoinFlip w) {
    super.didUpdateWidget(w);
    if (w.on != widget.on) {
      final target = widget.on;
      Future.delayed(widget.on ? widget.delay : Duration.zero, () {
        if (!mounted || widget.on != target) return;
        _old = _shown;
        _shown = target;
        if (target) HapticFeedback.selectionClick();
        _c.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final v = _c.value;
          if (v >= 1.0) return widget.builder(_shown, _rest);
          final tilt = _rest + Curves.easeInOutSine.transform(v) * math.pi;
          final front = tilt < math.pi / 2;
          return Transform.scale(
            scale: 1.0 + 0.12 * math.sin(v * math.pi),
            child: widget.builder(
                front ? _old : _shown, front ? tilt : tilt - math.pi),
          );
        },
      );
}
