// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// เตรียมบันทึกข้อมูลอุบัติเหตุ (ปุ่ม "อุบัติเหตุ" บนการ์ดผู้ป่วย ช่วงหลังการตรวจ)
// ช่องและตัวเลือกมาจาก master accident_* ทั้งหมด · ช่องยานพาหนะ/ผู้บาดเจ็บ/หมวก/เข็มขัด
// แสดงเฉพาะเมื่อประเภทเป็นอุบัติเหตุการขนส่ง

/// กลุ่มช่องของฟอร์ม: (หัวข้อ, ไอคอน, [(ชื่อช่อง, id ตาราง master)], เฉพาะอุบัติเหตุการขนส่ง)
const List<(String, IconData, List<(String, String)>, bool)> _accGroups = [
  (
    'เหตุการณ์',
    Icons.place_rounded,
    [
      ('สถานที่เกิดเหตุ', 'accident_place_type'),
      ('ประเภทอุบัติเหตุ', 'accident_type'),
    ],
    false
  ),
  (
    'การขนส่ง',
    Icons.two_wheeler_rounded,
    [
      ('ยานพาหนะ', 'accident_vehicle_type'),
      ('ประเภทผู้บาดเจ็บ', 'accident_person_type'),
      ('หมวกนิรภัย', 'accident_helmet_type'),
      ('เข็มขัดนิรภัย', 'accident_belt_type'),
    ],
    true
  ),
  (
    'ปัจจัยเสี่ยง',
    Icons.local_bar_rounded,
    [
      ('แอลกอฮอล์', 'accident_alcohol_type'),
      ('สารเสพติด', 'accident_drug_type'),
    ],
    false
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
    false
  ),
  (
    'ความรุนแรง',
    Icons.monitor_heart_rounded,
    [('ระดับความรุนแรง (AIS สูงสุด)', 'accident_ais_severity')],
    false
  ),
];

const String _accWhen = 'วันที่/เวลาเกิดเหตุ';
const String _accTypeLabel = 'ประเภทอุบัติเหตุ';

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

extension _FeaturesPatientAccidentPart on _ErFlowHomeWidgetState {
  bool _accSaved(String hn) => _accStore[hn]?.isNotEmpty ?? false;

  /// เป็นอุบัติเหตุการขนส่งหรือไม่ (เปิดกลุ่มยานพาหนะ/หมวก/เข็มขัด)
  bool _accTransport(Map<String, String> v) =>
      (v[_accTypeLabel] ?? '').contains('การขนส่ง');

  /// ช่องที่ต้องแสดงตามประเภท
  List<String> _accLabels(Map<String, String> v) => [
        _accWhen,
        for (final (_, _, fields, transport) in _accGroups)
          if (!transport || _accTransport(v))
            for (final (l, _) in fields) l,
      ];

  List<String> _accOptions(String table) => [
        for (final it in ErMaster.maybe?.table(table)?.activeItems ??
            const <ErMasterItem>[])
          it.name
      ];

  String _accNow(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/'
      '${t.year + 543} ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')} น.';

  /// ฟอร์มบันทึกอุบัติเหตุของผู้ป่วย p
  Future<void> _openAccident(_P p) async {
    final c = erCaseOf(p.hn);
    final v = {...?(_accDrafts[p.hn] ?? _accStore[p.hn])};
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final labels = _accLabels(v);
        final done = labels.where((l) => (v[l] ?? '').isNotEmpty).length;
        final missing = [
          for (final l in _accRequired)
            if ((v[l] ?? '').isEmpty) l
        ];

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

        // ช่องหนึ่งช่อง: ตัวเลือก ≤ 6 = ชิป · มากกว่านั้น = ช่องเลือกจากรายการ (ค้นหาได้)
        Widget field(String label, String table) {
          final opts = _accOptions(table);
          final cur = v[label];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _apptLabel(label, must: _accRequired.contains(label)),
                if (opts.length <= 6)
                  Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                    for (final o in opts)
                      _optChip(o, o == cur, false, () {
                        set(() => o == cur ? v.remove(label) : v[label] = o);
                      }, size: 11.0),
                  ])
                else
                  _apptBox(cur ?? 'เลือก$label',
                      filled: cur != null,
                      icon: Icons.expand_more_rounded, onTap: () async {
                    final o = await _listSheet(label, opts, current: cur);
                    if (o != null) set(() => v[label] = o);
                  }),
              ],
            ),
          );
        }

        Widget group(String title, IconData icon, List<Widget> body) =>
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 2.0),
              decoration: _clyCardDeco,
              foregroundDecoration: const _InnerGloss(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Container(
                      width: 26.0,
                      height: 26.0,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(icon, size: 15.0, color: _blue),
                    ),
                    const SizedBox(width: 8.0),
                    Text(title,
                        style: _t(12.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10.0),
                  ...body,
                ],
              ),
            );

        // วันเวลาเกิดเหตุ: ช่องแตะเลือก + ปุ่มนาฬิกา (เวลาปัจจุบัน)
        final when = Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _apptLabel(_accWhen, must: true),
              Row(children: [
                Expanded(
                  child: _apptBox(v[_accWhen] ?? 'เลือกวันที่และเวลา',
                      filled: v[_accWhen] != null,
                      icon: Icons.edit_calendar_rounded,
                      onTap: pickWhen),
                ),
                const SizedBox(width: 8.0),
                Tooltip(
                  message: 'ใช้เวลาปัจจุบัน',
                  child: _Press(
                    child: GestureDetector(
                      onTap: () =>
                          set(() => v[_accWhen] = _accNow(DateTime.now())),
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          gradient: _glossGrad(_blue),
                          shape: BoxShape.circle,
                          boxShadow: _glossLift(_blue),
                        ),
                        child: const Icon(Icons.schedule_rounded,
                            size: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );

        final groups = [
          for (final (title, icon, fields, transport) in _accGroups)
            if (!transport || _accTransport(v))
              group(title, icon, [
                if (title == 'เหตุการณ์') when,
                for (final (l, table) in fields) field(l, table),
              ]),
        ];

        final size = MediaQuery.sizeOf(ctx);
        final twoCol = size.width >= 900.0;
        final half = (groups.length / 2).ceil();
        return Dialog(
          backgroundColor: _bg,
          insetPadding: const EdgeInsets.all(24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          child: SizedBox(
            width: math.min(960.0, size.width - 48.0),
            height: math.min(680.0, size.height - 48.0),
            child: Column(children: [
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
                            style: _t(14.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        Text('${p.name} · HN ${p.hn}',
                            style: _t(10.0, color: _ink3)),
                      ],
                    ),
                  ),
                  Text('กรอกแล้ว $done/${labels.length}',
                      style: _t(10.5, color: _blue, weight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    tooltip: 'ปิด',
                    icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                        color: _ink2),
                  ),
                ]),
              ),
              // ข้อมูลจากคัดกรองให้ตรวจทาน (อาการสำคัญ)
              if (c.cc.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15.0, color: _blue),
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
                  padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 6.0),
                  child: twoCol
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child:
                                    Column(children: groups.sublist(0, half))),
                            const SizedBox(width: 12.0),
                            Expanded(
                                child: Column(children: groups.sublist(half))),
                          ],
                        )
                      : Column(children: groups),
                ),
              ),
              // ขอบล่าง: ล้าง · บันทึก (ยังไม่ครบ = บอกช่องที่ขาด)
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 10.0, 14.0, 14.0),
                child: Row(children: [
                  if (v.isNotEmpty)
                    TextButton(
                      onPressed: () => set(v.clear),
                      child: Text('ล้างทั้งหมด', style: _t(11.0, color: _ink3)),
                    ),
                  const Spacer(),
                  _apptPrimaryBtn(
                      missing.isEmpty
                          ? Icons.check_rounded
                          : Icons.error_outline_rounded,
                      missing.isEmpty
                          ? 'บันทึกข้อมูลอุบัติเหตุ'
                          : 'กรอกให้ครบ (${missing.length}) · ${missing.join(', ')}',
                      missing.isEmpty ? () => Navigator.pop(ctx, true) : null),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
    if (saved != true || !mounted) {
      // ปิดโดยไม่บันทึก: เก็บเป็นร่างไว้ เปิดใหม่ค่าไม่หาย
      _accDrafts[p.hn] = v;
      return;
    }
    // ตัดค่าของกลุ่มที่ไม่แสดงแล้ว (เช่น เปลี่ยนจากขนส่งเป็นพลัดตก)
    final keep = _accLabels(v).toSet();
    v.removeWhere((k, _) => !keep.contains(k));
    _accDrafts.remove(p.hn);
    setState(() => _accStore[p.hn] = v);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('บันทึกข้อมูลอุบัติเหตุ ${p.name} แล้ว',
            style: _t(12.0, color: Colors.white))));
  }
}
