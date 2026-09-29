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

        padding: const EdgeInsets.only(bottom: 8),

        child: Text.rich(TextSpan(children: [

          TextSpan(

              text: label,

              style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),

          if (must)

            TextSpan(

                text: ' *',

                style: _t(12.5, color: _red, weight: FontWeight.w700)),

        ])),

      );



  bool _accSaved(String hn) => _accStore[hn]?.isNotEmpty ?? false;



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

    final narrative = TextEditingController(text: _accNarratives[p.hn] ?? '');

    var extracting = false;
    var applying = false;
    var sourceRevision = 0;

    var showAllCoverage = false;

    String? extractionMessage;

    // ผลวิเคราะห์ล่าสุดจากปุ่ม "ให้ AI จัดข้อมูล"
    // แยกจาก Form State จนกว่าผู้ใช้จะเลือกและกดนำข้อมูลไปกรอก
    List<ErCoverage>? analyzedCoverage;
    List<ErFillSuggestion>? analyzedSuggestions;
    final selectedSuggestions = <int>{};
    String? analyzedSource;
    Map<String, String>? analyzedSnapshot;

    final textControllers = {

      for (final label in [

        'จุดเกิดเหตุ',

        'ทะเบียนรถ',

        'หมายเหตุ',

        ..._accEditableSelects

      ])

        label: TextEditingController(text: v[label] ?? ''),

    };

    final saved = await showDialog<bool>(

      context: context,

      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {

        final schema = _accSchema();

        final labels = [for (final field in schema) field.id];

        final coverage = analyzedCoverage ?? const <ErCoverage>[];
        final suggestions =
            analyzedSuggestions ?? const <ErFillSuggestion>[];

        final foundCoverage = coverage
            .where((item) => item.status == ErCoverageStatus.found)
            .length;
        final reviewCoverage = coverage
            .where((item) => item.status == ErCoverageStatus.needsReview)
            .length;
        final visibleCoverage = showAllCoverage
            ? coverage
            : coverage.take(8).toList(growable: false);

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
                        onPressed: () => set(() {
                          selectedSuggestions
                            ..clear()
                            ..addAll(applicableSuggestionIndexes);
                        }),
                        child: const Text('เลือกทั้งหมด'),
                      ),
                      TextButton(
                        onPressed: selectedSuggestions.isEmpty
                            ? null
                            : () => set(() {
                                  selectedSuggestions.clear();
                                }),
                        child: const Text('ล้างทั้งหมด'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (final i in applicableSuggestionIndexes)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: _clyTileDeco(),
                      child: CheckboxListTile(
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
                          style: _t(11.5, weight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestions[i].value,
                              style: _t(11.5, color: _blue),
                            ),
                            if (suggestions[i].status == ErFillStatus.needsReview)
                              Text(
                                'ต้องตรวจสอบ${suggestions[i].reason.isEmpty ? '' : ' · ${suggestions[i].reason}'}',
                                style: _t(10, color: _blue2),
                              ),
                            if (suggestions[i].evidence.isNotEmpty)
                              Text(
                                'จากข้อความ: “${suggestions[i].evidence}”',
                                style: _t(9.5, color: _ink3),
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
                                for (final entry
                                    in textControllers.entries) {
                                  entry.value.text = v[entry.key] ?? '';
                                }

                                // ค่าที่เพิ่งนำไปกรอกถือเป็น baseline ใหม่
                                // เพื่อไม่ให้การกดรอบถัดไปมองค่าที่เพิ่งใส่เป็น conflict ซ้ำ
                                analyzedSnapshot =
                                    Map<String, String>.of(v);
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



        // Master-backed fields use the existing searchable select. Only the

        // free-text fields keep the voice dialog; the pre-arrival care options

        // remain selectable without an attached mic action.

        bool voiceUseful(String label) =>

            label == 'หมายเหตุ' ||

            label == 'จุดเกิดเหตุ' ||

            label == 'ทะเบียนรถ';



        Widget field(String label, String table) {

          final opts = _accOptions(table);

          final cur = v[label];

          return Padding(

            padding: const EdgeInsets.only(bottom: 12.0),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                fieldHeading(label),

                if (textControllers.containsKey(label))

                  _apptTextArea(

                      textControllers[label]!,

                      label == 'หมายเหตุ'

                          ? 'ระบุหมายเหตุเพิ่มเติม'

                          : _accEditableSelects.contains(label)

                              ? 'เลือกจากรายการ หรือพิมพ์รายละเอียด'

                              : label == 'จุดเกิดเหตุ'

                                  ? 'ระบุถนน / บริเวณที่เกิดเหตุ'

                                  : 'ระบุทะเบียนรถ',

                      minLines: label == 'หมายเหตุ' ? 3 : 1,

                      maxLines: label == 'หมายเหตุ' ? 6 : 1,

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

                                          final picked = await _listSheet(

                                              label, opts,

                                              current: v[label]);

                                          if (picked == null || !ctx.mounted) {

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

                              if (label == 'หมายเหตุ' ||

                                  label == 'จุดเกิดเหตุ' ||

                                  label == 'ทะเบียนรถ')

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

                                    if (result == null || !ctx.mounted) return;

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

                          }))

                else if (opts.isEmpty)

                  Text('ยังไม่มีรายการให้เลือก', style: _t(11, color: _ink3))

                else

                  _apptBox(cur ?? 'เลือก$label',

                      filled: cur != null,

                      icon: Icons.expand_more_rounded,

                      trailing: clearAction(label), onTap: () async {

                    final o = await _listSheet(label, opts, current: cur);

                    if (o != null && ctx.mounted) set(() => v[label] = o);

                  }),

              ],

            ),

          );

        }



        Widget group(String title, IconData icon, List<Widget> body,

            int completed, int total) {

          return Container(

            margin: const EdgeInsets.only(bottom: 12.0),

            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 2.0),

            decoration: _clyCardDeco,

            foregroundDecoration: const _InnerGloss(12.0),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                Container(

                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(

                      color: _blue.withValues(alpha: 0.06),

                      borderRadius: BorderRadius.circular(10),

                    ),

                    child: Row(children: [

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

                      Expanded(

                          child: Text(title,

                              style: _t(13,

                                  color: _blue, weight: FontWeight.w700))),

                      Text('$completed/$total',

                          style: _num(10,

                              color: completed == total ? _green : _ink3)),

                    ])),

                const SizedBox(height: 10.0),

                const SizedBox(height: 4),

                ...body,

              ],

            ),

          );

        }



        // วันเวลาเกิดเหตุ: ช่องแตะเลือก + ปุ่มนาฬิกา (เวลาปัจจุบัน)

        final when = Padding(

          padding: const EdgeInsets.only(bottom: 12.0),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              fieldHeading(_accWhen),

              Row(children: [

                Expanded(

                  child: _apptBox(v[_accWhen] ?? 'เลือกวันที่และเวลา',

                      filled: v[_accWhen] != null,

                      icon: Icons.edit_calendar_rounded,

                      trailing: clearAction(_accWhen),

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



        Widget fieldGrid(List<Widget> items,

                {bool event = false, bool compact = false}) =>

            LayoutBuilder(

              builder: (context, bounds) => Wrap(

                spacing: 16,

                children: [

                  for (final item in items)

                    SizedBox(

                      width: event && bounds.maxWidth >= 840

                          ? (bounds.maxWidth - 32) / 3

                          : bounds.maxWidth >=

                                  (compact

                                      ? 380

                                      : event

                                          ? 560

                                          : 620)

                              ? (bounds.maxWidth - 16) / 2

                              : bounds.maxWidth,

                      child: item,

                    ),

                ],

              ),

            );



        final groups = <String, Widget>{

          for (final (title, icon, fields) in _accGroups)

            title: group(

                title,

                icon,

                [

                  fieldGrid([

                    if (title == 'เหตุการณ์') when,

                    for (final (l, table) in fields) field(l, table),

                  ],

                      event: title == 'เหตุการณ์',

                      compact: title == 'ปัจจัยเสี่ยง'),

                ],

                fields.where((f) => (v[f.$1] ?? '').isNotEmpty).length +

                    (title == 'เหตุการณ์' && (v[_accWhen] ?? '').isNotEmpty

                        ? 1

                        : 0),

                fields.length + (title == 'เหตุการณ์' ? 1 : 0)),

        };



        final size = MediaQuery.sizeOf(ctx);

        final twoCol = size.width >= 900.0;

        return Dialog(

          backgroundColor: _bg,

          insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 24),

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

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                            style: _t(10.0, color: _ink3)),

                      ],

                    ),

                  ),

                  Text('$done/${labels.length} ช่อง',

                      style: _num(10.5, color: _blue)),

                  IconButton(

                    onPressed: () => Navigator.pop(ctx, false),

                    tooltip: 'ปิด',

                    icon: const Icon(Icons.keyboard_double_arrow_left_rounded,

                        color: _ink2),

                  ),

                ]),

              ),

              Padding(

                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),

                child: ClipRRect(

                  borderRadius: BorderRadius.circular(4),

                  child: LinearProgressIndicator(

                    value: labels.isEmpty ? 0 : done / labels.length,

                    minHeight: 4,

                    color: _blue,

                    backgroundColor: _line,

                  ),

                ),

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

                  child: Column(children: [

                    freeEntry,

                    groups['เหตุการณ์']!,

                    if (twoCol)

                      Row(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Expanded(

                              child: Column(children: [

                            groups['ปัจจัยเสี่ยง']!,

                          ])),

                          const SizedBox(width: 12.0),

                          Expanded(

                              child: Column(children: [

                            groups['การดูแลก่อนมาถึง']!,

                            groups['หมายเหตุ']!,

                          ])),

                        ],

                      )

                    else ...[

                      for (final entry in groups.entries)

                        if (entry.key != 'เหตุการณ์') entry.value,

                    ],

                  ]),

                ),

              ),

              // ขอบล่าง: ล้าง · บันทึก (ยังไม่ครบ = บอกช่องที่ขาด)

              Container(

                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),

                decoration: const BoxDecoration(

                    color: _panel,

                    border: Border(top: BorderSide(color: _line))),

                child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

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

                                  for (final controller

                                      in textControllers.values) {

                                    controller.clear();

                                  }

                                }),

                                child: Text('ล้างทั้งหมด',

                                    style: _t(11.0, color: _ink3)),

                              ),

                            _apptPrimaryBtn(

                                Icons.check_rounded,

                                'บันทึกข้อมูลอุบัติเหตุ',

                                missing.isEmpty

                                    ? () => Navigator.pop(ctx, true)

                                    : null),

                          ]),

                    ]),

              ),

            ]),

          ),

        );

      }),

    );

    // Let the dialog's closing animation finish before releasing its controller.

    Future<void>.delayed(const Duration(milliseconds: 350), () {

      narrative.dispose();

      for (final controller in textControllers.values) {

        controller.dispose();

      }

    });

    if (saved != true || !mounted) {

      // ปิดโดยไม่บันทึก: เก็บเป็นร่างไว้ เปิดใหม่ค่าไม่หาย

      _accDrafts[p.hn] = v;

      return;

    }

    // เก็บเฉพาะช่องในฟอร์มปัจจุบัน รวมค่ามาตรฐานและข้อความที่ผู้ใช้กรอกเอง

    final keep = _accLabels().toSet();

    v.removeWhere((k, _) => !keep.contains(k));

    _accDrafts.remove(p.hn);

    setState(() => _accStore[p.hn] = v);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(

        behavior: SnackBarBehavior.floating,

        content: Text('บันทึกข้อมูลอุบัติเหตุ ${p.name} แล้ว',

            style: _t(12.0, color: Colors.white))));

  }

}
