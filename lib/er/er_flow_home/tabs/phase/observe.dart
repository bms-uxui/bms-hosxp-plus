// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// บันทึกสังเกตอาการของเคส (1 เคส = 1 บันทึก)
class _Observe {
  const _Observe({
    required this.at,
    required this.place,
    required this.room,
    required this.bed,
    required this.orderBy,
    required this.status,
    required this.out,
    required this.symptom,
    required this.acts,
    required this.note,
    required this.by,
  });

  final DateTime at;
  final String place;
  final String room;
  final String bed;
  final String orderBy;

  /// สถานะปัจจุบัน (สังเกตอาการ · กลับบ้าน · Admit) ว่าง = ไม่ระบุ
  final String status;
  final DateTime? out;
  final String symptom;

  /// กิจกรรมพยาบาล เรียงตามเวลา: เวลาที่ทำ · สิ่งที่ทำ
  final List<(TimeOfDay, String)> acts;
  final String note;
  final String by;

  /// บรรทัดละกิจกรรม: "08.00 น. - วัดสัญญาณชีพ"
  String get activity =>
      [for (final (t, s) in acts) '${_obsHm(t)} น. - $s'].join('\n');

  /// ข้อความสั้นในไทม์ไลน์: อาการ · กิจกรรมพยาบาล
  String get summary => [
        // สถานะอื่นที่ไม่ใช่สังเกตอาการต่อ แสดงต่อท้าย เช่น "สังเกตอาการ → กลับบ้าน"
        'สังเกตอาการ${status.isEmpty || status == 'สังเกตอาการ' ? '' : ' → $status'}'
            '${symptom.isEmpty ? '' : ': $symptom'}',
        // ย่อ "08.00 น. - งาน" เป็น "08.00 งาน" ให้อ่านง่ายในไทม์ไลน์
        if (activity.isNotEmpty)
          activity.replaceAll(' น. - ', ' ').replaceAll('\n', ' · '),
      ].join(' — ');
}

/// ฟอร์มที่กำลังกรอก (ไม่มีช่องบังคับ)
class _ObsDraft {
  _ObsDraft({this.at, this.place, this.bed, this.orderBy});

  /// แก้ไขบันทึกเดิม: ใส่ค่าเดิมทุกช่อง
  _ObsDraft.edit(_Observe o)
      : editing = o,
        at = o.at,
        place = o.place.isEmpty ? null : o.place,
        room = o.room.isEmpty ? null : o.room,
        bed = o.bed.isEmpty ? null : o.bed,
        orderBy = o.orderBy.isEmpty ? null : o.orderBy,
        status = o.status.isEmpty ? null : o.status,
        out = o.out {
    symptom.text = o.symptom;
    note.text = o.note;
    acts.addAll(o.acts);
  }

  /// บันทึกที่บันทึกไว้แล้ว (null = ยังไม่เคยบันทึก)
  _Observe? editing;

  /// ข้อความเตือนตอนกดบันทึก (null = ไม่มี)
  String? error;

  DateTime? at;
  String? place;
  String? room;
  String? bed;
  String? orderBy;
  String? status;
  DateTime? out;
  final symptom = TextEditingController();
  final note = TextEditingController();

  /// กิจกรรมพยาบาล: เวลาที่ทำ · สิ่งที่ทำ
  final List<(TimeOfDay, String)> acts = [];

  /// เวลาของกิจกรรมถัดไปที่จะเพิ่ม (ตั้งต้น = ตอนเปิดฟอร์ม)
  TimeOfDay actAt = TimeOfDay.now();
  final actInput = TextEditingController();

  /// เรียงตามเวลา (เช้า → สาย)
  List<(TimeOfDay, String)> get actsSorted => [...acts]..sort((a, b) =>
      (a.$1.hour * 60 + a.$1.minute).compareTo(b.$1.hour * 60 + b.$1.minute));

  bool hasAct(String s) => acts.any((a) => a.$2 == s);

  List<String> get missing => [
        // ไม่บังคับช่องใด · กันแค่บันทึกเปล่า (ไม่มีสถานะ อาการ กิจกรรม หรือหมายเหตุเลย)
        if (status == null &&
            symptom.text.trim().isEmpty &&
            acts.isEmpty &&
            note.text.trim().isEmpty)
          'ข้อมูลอย่างน้อย 1 ช่อง (สถานะ อาการ กิจกรรมพยาบาล หรือหมายเหตุ)',
      ];

  _Observe toObserve(String by) => _Observe(
        at: at ?? DateTime.now(),
        place: place ?? '',
        room: room ?? '',
        bed: bed ?? '',
        orderBy: orderBy ?? '',
        status: status ?? '',
        out: out,
        symptom: symptom.text.trim(),
        acts: actsSorted,
        note: note.text.trim(),
        by: by,
      );

  void dispose() {
    symptom.dispose();
    actInput.dispose();
    note.dispose();
  }
}

/// เวลาแบบไทย 08.00
String _obsHm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

/// บันทึกสังเกตอาการต่อ HN (1 เคส = 1 บันทึก)
final Map<String, _Observe> _obsRec = {};

/// ฟอร์มที่กำลังกรอกบนหน้าต่อ HN (ค้างไว้ระหว่างสลับแท็บ)
final Map<String, _ObsDraft> _obsDrafts = {};

/// สถานะปัจจุบันของผู้ป่วย: ไอคอน · ชื่อ · ต้องเฝ้าระวัง (แดง)
const List<(IconData, String, bool)> _obsStatus = [
  (Icons.visibility_rounded, 'สังเกตอาการ', false),
  (Icons.home_rounded, 'กลับบ้าน', false),
  (Icons.local_hospital_rounded, 'Admit', false),
];

/// กิจกรรมพยาบาลที่ใช้บ่อยระหว่างสังเกตอาการ
const List<String> _obsActivities = [
  'วัดสัญญาณชีพทุก 15 นาที',
  'ประเมินระดับความปวด',
  'ประเมินระดับความรู้สึกตัว (GCS)',
  'จัดท่านอนศีรษะสูง 30 องศา',
  'ให้ออกซิเจนตามแผนการรักษา',
  'ดูแลให้สารน้ำทางหลอดเลือดดำ',
  'เฝ้าระวังอาการแพ้ยา',
];

/// แท็บบันทึกสังเกตอาการ (เมนู "อื่น ๆ" ของหน้าผู้ป่วย)
const int _obsTab = 16;

extension _TabsPhaseObservePart on _ErFlowHomeWidgetState {
  /// บันทึกกิจกรรมพยาบาลของผู้ป่วย (ใหม่ → เก่า) ถ้าไม่มีบันทึกใช้เหตุการณ์ของพยาบาล
  /// บันทึกสังเกตอาการของเคส (ถ้ามี) ขึ้นก่อน
  List<ErNote> _nurseNotesOf(_P p) {
    final c = erCaseOf(p.hn);
    final o = _obsRec[p.hn];
    // ซักประวัติที่บันทึกจาก workflow (ล่าสุดก่อน)
    final hx = _hxRecs[p.hn] ?? const <Map<String, String>>[];
    final obs = [
      for (final (i, r) in hx.indexed.toList().reversed)
        ErNote(r['เวลา'] ?? '', r['ผู้บันทึก'] ?? 'พยาบาล', _hxNoteText(i, r),
            kind: 'ซักประวัติ'),
      if (o != null)
        ErNote(_apptHm(TimeOfDay.fromDateTime(o.at)), o.by, o.summary,
            kind: 'สังเกตอาการ'),
    ];
    if (c.nurseNotes.isNotEmpty) return [...obs, ...c.nurseNotes];
    return [
      ...obs,
      if (c.lastNote != null) c.lastNote!,
      for (final e in c.events)
        if (!e.byDoctor && e.time != c.lastNote?.time)
          ErNote(e.time, 'พยาบาล', e.text, kind: e.kind),
    ];
  }

  // ------------------------------------------------ บันทึกข้อมูลสังเกตอาการ

  /// แพทย์เวรที่ระบุไว้ในหน้าคัดกรอง (ข้อมูลรับเข้าห้องฉุกเฉิน) ของผู้ป่วยรายนี้
  /// ฟอร์ม workflow เป็นของผู้ป่วยที่กำลังดูอยู่ รายอื่นจึงยังไม่มีค่า
  String? _dutyDoctorOf(_P p) {
    if (_caseP().hn != p.hn) return null;
    const key = '${_FeaturesWorkflowFormFieldsPart._erInPrefix}แพทย์เวร';
    for (final f in _filled) {
      final v = f[key];
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  /// ฟอร์มของผู้ป่วยรายนี้: บันทึกแล้ว = ค่าที่บันทึก · ยังไม่บันทึก = ค่าตั้งต้น
  _ObsDraft _obsDraftOf(_P p) => _obsDrafts.putIfAbsent(p.hn, () {
        final o = _obsRec[p.hn];
        if (o != null) return _ObsDraft.edit(o);
        return _ObsDraft(
          at: DateTime.now(),
          place: _masterNames('er_observe_place')
              .where((s) => s.contains('Observe'))
              .firstOrNull,
          bed: p.bed,
          // ผู้สั่ง: ค่ารอ = แพทย์เวรที่ระบุไว้ในหน้าคัดกรอง (ถ้ามี) · แก้ได้
          orderBy: _dutyDoctorOf(p),
        );
      });

  /// ปุ่มบนการ์ดผู้ป่วย (เมนูสังเกตอาการ): เปิดหน้าผู้ป่วยที่แท็บ Observe
  void _openObserve(_P p) => _openDetail(p, tab: _obsTab);

  /// หน้าบันทึกสังเกตอาการ: 1 เคส = 1 บันทึก กรอกบนหน้าได้เลย
  /// ล่างสุดมีปุ่มบันทึก และปุ่มลบ (เมื่อบันทึกแล้ว) ไว้ลบกรณีบันทึกผิด
  Widget _obsTabBody() {
    final p = _caseP();
    final d = _obsDraftOf(p);
    final saved = _obsRec[p.hn];
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
          children: [
            Row(children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  gradient: _glossGrad(_blue),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: const Icon(Icons.visibility_rounded,
                    size: 16.0, color: Colors.white),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('บันทึกข้อมูลสังเกตอาการ',
                        style: _t(13.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('${p.name} · HN ${p.hn}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(9.5, color: _ink3)),
                  ],
                ),
              ),
              // สถานะการบันทึก
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: saved == null
                      ? _panelSoft
                      : _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      saved == null
                          ? Icons.edit_note_rounded
                          : Icons.check_circle_rounded,
                      size: 13.0,
                      color: saved == null ? _ink3 : _blue),
                  const SizedBox(width: 4.0),
                  Text(
                      saved == null
                          ? 'ยังไม่บันทึก'
                          : 'บันทึกแล้ว · ${saved.by}',
                      style: _t(9.5,
                          color: saved == null ? _ink3 : _blue,
                          weight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
              decoration: _clyCardDeco,
              foregroundDecoration: const _InnerGloss(12.0),
              child: _obsForm(d),
            ),
            const SizedBox(height: 10.0),
            // วินิจฉัยทางการพยาบาล: เพิ่มได้หลายข้อ (บันทึกแยกจากฟอร์มด้านบน)
            _ndxSection(p),
          ],
        ),
      ),
      // แถบล่าง: ข้อความสถานะ/ข้อผิดพลาด · ลบ (เมื่อบันทึกแล้ว) · บันทึก
      Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 10.0),
        child: Row(children: [
          Expanded(
            child: Text(
                d.error ??
                    (saved == null
                        ? 'ผู้บันทึก ${ErSession.instance.user?.name ?? '-'}'
                        : 'แก้ไขแล้วกดบันทึกเพื่ออัปเดต · ลบได้หากบันทึกผิด'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _t(9.5,
                    color: d.error == null ? _ink3 : _red,
                    weight:
                        d.error == null ? FontWeight.w500 : FontWeight.w700)),
          ),
          if (saved != null) ...[
            _miniBtn(
                Icons.delete_outline_rounded, 'ลบข้อมูล', () => _obsDelete(p),
                tooltip: 'ลบบันทึกสังเกตอาการ (บันทึกผิด)'),
            const SizedBox(width: 8.0),
          ],
          _apptPrimaryBtn(Icons.check_rounded, 'บันทึก', () => _obsSave(p)),
        ]),
      ),
    ]);
  }

  /// ช่องกรอกทั้งหมดของบันทึกสังเกตอาการ (ไม่มีช่องบังคับ)
  Widget _obsForm(_ObsDraft d) {
    final doctors = _apptDoctors();
    void ss(VoidCallback f) => setState(() {
          f();
          d.error = null;
        });

    Future<void> pick(String label, List<String> opts, String? cur,
        void Function(String) set) async {
      final v = await _listSheet(label, opts, current: cur);
      if (v != null && mounted) ss(() => set(v));
    }

    Widget sel(String label, String? v, List<String> opts,
            void Function(String) set) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(label),
            _apptBox(v ?? '- เลือก -',
                filled: v != null,
                icon: Icons.expand_more_rounded,
                onTap: () => pick(label, opts, v, set)),
          ],
        );

    Widget dt(String label, DateTime? v, void Function(DateTime?) set) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(label),
            _apptBox(v == null ? 'เลือกวัน-เวลา' : _fmtDateTime(v),
                filled: v != null,
                icon: Icons.schedule_rounded, onTap: () async {
              final now = DateTime.now();
              final day = await showDatePicker(
                context: context,
                initialDate: v ?? now,
                firstDate: now.subtract(const Duration(days: 7)),
                lastDate: now.add(const Duration(days: 1)),
              );
              if (day == null || !mounted) return;
              final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(v ?? now));
              if (t == null || !mounted) return;
              ss(() => set(
                  DateTime(day.year, day.month, day.day, t.hour, t.minute)));
            }),
          ],
        );

    Widget two(Widget a, Widget b) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 8.0),
            Expanded(child: b),
          ],
        );

    // ช่องข้อความ + ไมค์ (พูดแล้วแปลงเป็นข้อความ)
    Widget text(String label, TextEditingController c, String hint) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(label),
            _apptTextArea(c, hint, onChanged: (_) {
              if (d.error != null) ss(() {});
            },
                suffixIcon: IconButton(
                  tooltip: 'พูดแล้วแปลงเป็นข้อความ',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 34.0, minHeight: 34.0),
                  icon: const Icon(Icons.mic_none_rounded,
                      size: 16.0, color: _blue),
                  onPressed: () async {
                    final v = await _voiceTextDialog(
                      title: label,
                      initial: c.text,
                      hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
                      okText: 'ใช้ข้อความนี้',
                      multiline: true,
                      autoMic: true,
                    );
                    if (v != null && mounted) ss(() => c.text = v.trim());
                  },
                )),
          ],
        );

    // ---- กิจกรรมพยาบาล: [เวลา] - สิ่งที่ทำ ทีละบรรทัด
    Future<TimeOfDay?> pickTime(TimeOfDay init) => showTimePicker(
          context: context,
          initialTime: init,
          builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
              child: child!),
        );

    // ป้ายเวลา แตะเพื่อเปลี่ยนเวลา
    Widget timePill(TimeOfDay t, void Function(TimeOfDay) set) => InkWell(
          onTap: () async {
            final v = await pickTime(t);
            if (v != null && mounted) ss(() => set(v));
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: 26.0,
            padding: const EdgeInsets.symmetric(horizontal: 7.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _blue.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.schedule_rounded, size: 12.0, color: _blue),
              const SizedBox(width: 4.0),
              Text('${_obsHm(t)} น.',
                  style: _num(10.5, color: _blue, weight: FontWeight.w700)),
            ]),
          ),
        );

    void addAct(String s) {
      final t = s.trim();
      if (t.isEmpty) return;
      ss(() {
        d.acts.add((d.actAt, t));
        d.actInput.clear();
      });
    }

    Widget actEditor() {
      final rows = d.actsSorted;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _apptLabel('กิจกรรมพยาบาล'),
          Container(
            padding: const EdgeInsets.fromLTRB(8.0, 6.0, 4.0, 6.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                  color: rows.isEmpty ? _line : _blue.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // รายการที่ใส่แล้ว: เวลา - กิจกรรม · ✕ ลบ
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(children: [
                      timePill(r.$1, (v) {
                        final i = d.acts.indexOf(r);
                        if (i >= 0) d.acts[i] = (v, r.$2);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text('-', style: _t(11.0, color: _ink3)),
                      ),
                      Expanded(
                        child: Text(r.$2,
                            style: _t(11.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                      ),
                      IconButton(
                        tooltip: 'ลบกิจกรรมนี้',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 28.0, minHeight: 28.0),
                        onPressed: () => ss(() => d.acts.remove(r)),
                        icon: const Icon(Icons.close_rounded,
                            size: 14.0, color: _ink3),
                      ),
                    ]),
                  ),
                if (rows.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0, right: 4.0),
                    child: Divider(height: 1.0, color: _line),
                  ),
                // แถวเพิ่มใหม่: เวลา · พิมพ์กิจกรรม · ไมค์ · เพิ่ม
                Row(children: [
                  timePill(d.actAt, (v) => d.actAt = v),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: TextField(
                      controller: d.actInput,
                      onSubmitted: addAct,
                      style: _t(11.0),
                      decoration: InputDecoration(
                        hintText: 'พิมพ์กิจกรรมที่ทำ แล้วกด +',
                        hintStyle: _t(11.0, color: _g5),
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'พูดกิจกรรมที่ทำ',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                    icon: const Icon(Icons.mic_none_rounded,
                        size: 16.0, color: _blue),
                    onPressed: () async {
                      final v = await _voiceTextDialog(
                        title: 'กิจกรรมพยาบาล เวลา ${_obsHm(d.actAt)} น.',
                        initial: d.actInput.text,
                        hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
                        okText: 'เพิ่ม',
                        autoMic: true,
                      );
                      if (v != null && mounted) {
                        addAct(v.replaceAll('\n', ' '));
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'เพิ่มกิจกรรม',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                    onPressed: () => addAct(d.actInput.text),
                    icon: const Icon(Icons.add_circle_rounded,
                        size: 20.0, color: _blue),
                  ),
                ]),
              ],
            ),
          ),
          // ชิปกิจกรรมที่ใช้บ่อย: แตะ = เพิ่มที่เวลาในแถวเพิ่มใหม่ · แตะซ้ำ = เอาออก
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final s in _obsActivities)
                _optChip((d.hasAct(s) ? '✓ ' : '+ ') + s, d.hasAct(s), false,
                    () {
                  ss(() => d.hasAct(s)
                      ? d.acts.removeWhere((a) => a.$2 == s)
                      : d.acts.add((d.actAt, s)));
                }, size: 10.0),
            ]),
          ),
        ],
      );
    }

    // ช่องสถานะ: แตะเลือก 1 ค่า · แตะซ้ำ = ไม่ระบุ
    Widget statusChip((IconData, String, bool) s) {
      final (icon, label, alarm) = s;
      final on = d.status == label;
      final c = alarm ? _red : _blue;
      return InkWell(
        onTap: () => ss(() => d.status = on ? null : label),
        borderRadius: BorderRadius.circular(10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 34.0,
          decoration: BoxDecoration(
            color: on ? c : _panelSoft,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: on ? c : _line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.0, color: on ? Colors.white : c),
              const SizedBox(width: 5.0),
              Text(label,
                  style: _t(10.5,
                      color: on ? Colors.white : _ink,
                      weight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        two(
          dt('วัน-เวลาเริ่มสังเกตอาการ', d.at, (v) => d.at = v),
          sel('สถานที่', d.place, _masterNames('er_observe_place'),
              (v) => d.place = v),
        ),
        const SizedBox(height: 6.0),
        two(
          sel('ห้อง', d.room, _masterNames('er_room'), (v) => d.room = v),
          sel('เตียง', d.bed, _masterNames('er_bed'), (v) => d.bed = v),
        ),
        const SizedBox(height: 6.0),
        two(
          sel('ผู้สั่ง', d.orderBy, doctors, (v) => d.orderBy = v),
          dt('วัน-เวลาออกจากห้อง', d.out, (v) => d.out = v),
        ),
        const SizedBox(height: 8.0),
        _apptLabel('สถานะปัจจุบัน'),
        Row(children: [
          for (var i = 0; i < _obsStatus.length; i++) ...[
            if (i > 0) const SizedBox(width: 6.0),
            Expanded(child: statusChip(_obsStatus[i])),
          ],
        ]),
        const SizedBox(height: 8.0),
        text('อาการ', d.symptom,
            'อาการที่สังเกตได้ เช่น ปวดลดลง 3/10 ไม่มีคลื่นไส้'),
        const SizedBox(height: 8.0),
        actEditor(),
        const SizedBox(height: 8.0),
        text('หมายเหตุ', d.note, 'ผลการประเมิน / สิ่งที่ต้องติดตาม'),
      ],
    );
  }

  /// บันทึก (ครั้งแรก = สร้าง · ครั้งถัดไป = อัปเดตบันทึกเดิม คงผู้บันทึกเดิม)
  void _obsSave(_P p) {
    final d = _obsDraftOf(p);
    final miss = d.missing;
    if (miss.isNotEmpty) {
      setState(() => d.error = 'ยังขาด: ${miss.join(', ')}');
      return;
    }
    final old = _obsRec[p.hn];
    final o = d.toObserve(old?.by ?? ErSession.instance.user?.name ?? 'พยาบาล');
    setState(() {
      _obsRec[p.hn] = o;
      d.editing = o;
      d.error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            '${old == null ? 'บันทึก' : 'อัปเดต'}ข้อมูลสังเกตอาการ ${p.name} แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// ลบบันทึกหลังยืนยัน (บันทึกผิด) · ฟอร์มกลับเป็นค่าตั้งต้น
  Future<void> _obsDelete(_P p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ลบข้อมูลสังเกตอาการ?',
            style: _t(13.0, weight: FontWeight.w700)),
        content: Text(
            'ลบแล้วข้อมูลสังเกตอาการของ ${p.name} จะหายทั้งหมด\n'
            'รวมถึงในไทม์ไลน์กิจกรรมพยาบาล',
            style: _t(11.5, color: _ink2, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('ลบข้อมูล', style: _t(11.0, color: Colors.white))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _obsRec.remove(p.hn);
      _obsDrafts.remove(p.hn)?.dispose();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ลบข้อมูลสังเกตอาการของ ${p.name} แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// ไทม์ไลน์กิจกรรมพยาบาล: เวลา · ผู้บันทึก · ข้อความอิสระ เลื่อนดูย้อนหลังได้
  Widget _nurseActivity(_P p) {
    final notes = _nurseNotesOf(p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, size: 15.0, color: _blue),
          const SizedBox(width: 5.0),
          Text('กิจกรรมพยาบาล',
              style: _t(11.0, color: _blueHue, weight: FontWeight.w700)),
          const SizedBox(width: 6.0),
          Text('${notes.length} บันทึก', style: _t(9.5, color: _ink3)),
          const Spacer(),
          if (notes.isNotEmpty)
            Text('ล่าสุด ${notes.first.time} น.', style: _t(9.5, color: _ink3)),
        ]),
        const SizedBox(height: 6.0),
        if (notes.isEmpty)
          Text('ยังไม่มีบันทึกทางการพยาบาล', style: _t(11.0, color: _ink3))
        else
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final n = notes[i];
                final last = i == notes.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 56.0,
                        child: Text(_clock(n.time),
                            style: _num(10.5,
                                color: i == 0 ? _inkTitle : _ink3,
                                weight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 14.0,
                        child: Column(children: [
                          const SizedBox(height: 4.0),
                          Container(
                            width: 7.0,
                            height: 7.0,
                            decoration: BoxDecoration(
                              color: i == 0 ? _blue : _g5,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!last)
                            Expanded(
                                child: Container(width: 1.0, color: _line)),
                        ]),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.text,
                                  style: _t(11.5,
                                      color: i == 0 ? _inkTitle : _ink,
                                      height: 1.4)),
                              Text(n.by, style: _t(9.5, color: _ink3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------ วินิจฉัยทางการพยาบาล

/// กิจกรรมของข้อวินิจฉัย: เจ้าหน้าที่ · รายละเอียด · เวลา
class _NdxAct {
  const _NdxAct(this.by, this.detail, this.at);
  final String by;
  final String detail;
  final DateTime at;
}

/// ข้อวินิจฉัยทางการพยาบาลหนึ่งข้อ: ข้อวินิจฉัย · การประเมินผล · กิจกรรม
class _Ndx {
  const _Ndx(this.dx, this.eval, this.acts);
  final String dx;
  final String eval;
  final List<_NdxAct> acts;
}

/// ฟอร์มข้อวินิจฉัยที่กำลังกรอกบนหน้า (index = แก้ข้อเดิม · null = ข้อใหม่)
class _NdxDraft {
  _NdxDraft([this.index, _Ndx? from]) {
    if (from != null) {
      dx.text = from.dx;
      eval.text = from.eval;
      acts.addAll(from.acts);
    }
  }

  final int? index;
  final dx = TextEditingController();
  final eval = TextEditingController();
  final List<_NdxAct> acts = [];
  final actInput = TextEditingController();
  TimeOfDay actAt = TimeOfDay.now();
  String? error;

  void dispose() {
    dx.dispose();
    eval.dispose();
    actInput.dispose();
  }
}

/// ข้อวินิจฉัยทางการพยาบาลต่อ HN (ตามลำดับที่เพิ่ม)
final Map<String, List<_Ndx>> _ndxStore = {};

/// ฟอร์มที่เปิดค้างอยู่ต่อ HN
final Map<String, _NdxDraft> _ndxDrafts = {};

/// ข้อวินิจฉัยทางการพยาบาลที่พบบ่อยใน ER
const List<String> _ndxCommon = [
  'ปวดเฉียบพลัน',
  'การแลกเปลี่ยนก๊าซบกพร่อง',
  'เสี่ยงต่อภาวะพร่องสารน้ำ',
  'เสี่ยงต่อการติดเชื้อ',
  'เสี่ยงต่อการพลัดตกหกล้ม',
  'วิตกกังวล',
];

extension _TabsPhaseObserveNdxPart on _ErFlowHomeWidgetState {
  /// ส่วนวินิจฉัยทางการพยาบาล: ตารางข้อวินิจฉัย (แตะแถว = แก้ไข) · + เพิ่ม
  /// ฟอร์มเพิ่ม/แก้กางอยู่ใต้ตาราง ไม่เปิดหน้าต่างใหม่
  Widget _ndxSection(_P p) {
    final list = _ndxStore[p.hn] ?? const <_Ndx>[];
    final d = _ndxDrafts[p.hn];
    Widget th(String t, {int flex = 1, TextAlign align = TextAlign.left}) =>
        Expanded(
          flex: flex,
          child: Text(t,
              textAlign: align,
              style: _t(9.5, color: _ink3, weight: FontWeight.w700)),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.assignment_turned_in_rounded,
                size: 16.0, color: _blue),
            const SizedBox(width: 6.0),
            Text('วินิจฉัยทางการพยาบาล',
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(width: 6.0),
            Text('${list.length} ข้อ', style: _t(9.5, color: _ink3)),
            const Spacer(),
            if (d == null)
              _miniBtn(Icons.add_rounded, 'เพิ่ม',
                  () => setState(() => _ndxDrafts[p.hn] = _NdxDraft()),
                  tooltip: 'เพิ่มข้อวินิจฉัยทางการพยาบาล'),
          ]),
          const SizedBox(height: 8.0),
          if (list.isEmpty && d == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text('ยังไม่มีข้อวินิจฉัย · กด "เพิ่ม" เพื่อบันทึกข้อแรก',
                  style: _t(10.5, color: _ink3)),
            ),
          if (list.isNotEmpty) ...[
            // หัวตาราง
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10.0)),
                border: Border.all(color: _line),
              ),
              child: Row(children: [
                SizedBox(
                  width: 34.0,
                  child: Text('ลำดับ',
                      style: _t(9.5, color: _ink3, weight: FontWeight.w700)),
                ),
                th('ข้อวินิจฉัยทางการพยาบาล', flex: 4),
                th('กิจกรรม', flex: 2, align: TextAlign.center),
                th('การประเมินผล', flex: 4),
              ]),
            ),
            for (var i = 0; i < list.length; i++)
              InkWell(
                onTap: () => setState(() {
                  _ndxDrafts.remove(p.hn)?.dispose();
                  _ndxDrafts[p.hn] = _NdxDraft(i, list[i]);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color:
                        d?.index == i ? _blue.withValues(alpha: 0.08) : _panel,
                    border: const Border(
                      left: BorderSide(color: _line),
                      right: BorderSide(color: _line),
                      bottom: BorderSide(color: _line),
                    ),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 34.0,
                          child: Text('${i + 1}',
                              style: _num(10.5,
                                  color: _blue, weight: FontWeight.w700)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(list[i].dx,
                              style: _t(11.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${list[i].acts.length}',
                              textAlign: TextAlign.center,
                              style: _num(11.0, color: _ink)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(list[i].eval.isEmpty ? '-' : list[i].eval,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0, color: _ink)),
                        ),
                      ]),
                ),
              ),
            if (d == null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('แตะแถวเพื่อแก้ไข · เพิ่มกิจกรรม · หรือลบ',
                    style: _t(9.0, color: _ink3)),
              ),
          ],
          if (d != null) ...[
            const SizedBox(height: 10.0),
            _ndxEditor(p, d),
          ],
        ],
      ),
    );
  }

  /// ฟอร์มข้อวินิจฉัย: ข้อวินิจฉัย · การประเมินผล · กิจกรรม (ลำดับ เจ้าหน้าที่ รายละเอียด เวลา)
  /// ปุ่ม: ลบ (เฉพาะข้อเดิม) · บันทึก · ปิด
  Widget _ndxEditor(_P p, _NdxDraft d) {
    final me = ErSession.instance.user?.name ?? 'พยาบาล';
    void ss(VoidCallback f) => setState(() {
          f();
          d.error = null;
        });

    void addAct(String s) {
      final t = s.trim();
      if (t.isEmpty) return;
      final now = DateTime.now();
      ss(() {
        d.acts.add(_NdxAct(
            me,
            t,
            DateTime(
                now.year, now.month, now.day, d.actAt.hour, d.actAt.minute)));
        d.actInput.clear();
      });
    }

    void close() => setState(() => _ndxDrafts.remove(p.hn)?.dispose());

    void save() {
      if (d.dx.text.trim().isEmpty) {
        setState(() => d.error = 'กรอกข้อวินิจฉัยทางการพยาบาลก่อนบันทึก');
        return;
      }
      final v = _Ndx(d.dx.text.trim(), d.eval.text.trim(),
          [...d.acts]..sort((a, b) => a.at.compareTo(b.at)));
      final list = _ndxStore[p.hn] ??= [];
      setState(() {
        if (d.index != null && d.index! < list.length) {
          list[d.index!] = v;
        } else {
          list.add(v);
        }
        _ndxDrafts.remove(p.hn)?.dispose();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('บันทึกข้อวินิจฉัย "${v.dx}" แล้ว',
              style: _t(12.0, color: Colors.white))));
    }

    Future<void> delete() async {
      final i = d.index;
      if (i == null) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('ลบข้อวินิจฉัยนี้?',
              style: _t(13.0, weight: FontWeight.w700)),
          content: Text(
              'ลำดับ ${i + 1} · ${d.dx.text}\nกิจกรรมของข้อนี้จะถูกลบไปด้วย',
              style: _t(11.5, color: _ink2, height: 1.5)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('ลบ', style: _t(11.0, color: Colors.white))),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      setState(() {
        _ndxStore[p.hn]?.removeAt(i);
        _ndxDrafts.remove(p.hn)?.dispose();
      });
    }

    Widget field(String label, TextEditingController c, String hint,
            {int lines = 1}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(label),
            _apptTextArea(c, hint,
                minLines: lines, maxLines: lines == 1 ? 1 : 5, onChanged: (_) {
              if (d.error != null) ss(() {});
            },
                suffixIcon: IconButton(
                  tooltip: 'พูดแล้วแปลงเป็นข้อความ',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 34.0, minHeight: 34.0),
                  icon: const Icon(Icons.mic_none_rounded,
                      size: 16.0, color: _blue),
                  onPressed: () async {
                    final v = await _voiceTextDialog(
                      title: label,
                      initial: c.text,
                      hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
                      okText: 'ใช้ข้อความนี้',
                      multiline: lines > 1,
                      autoMic: true,
                    );
                    if (v != null && mounted) ss(() => c.text = v.trim());
                  },
                )),
          ],
        );

    // หัวคอลัมน์ตารางกิจกรรม
    Widget th(String t, {int flex = 1}) => Expanded(
          flex: flex,
          child: Text(t, style: _t(9.5, color: _ink3, weight: FontWeight.w700)),
        );

    final acts = [...d.acts]..sort((a, b) => a.at.compareTo(b.at));
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              d.index == null
                  ? 'เพิ่มข้อวินิจฉัยทางการพยาบาล'
                  : 'แก้ไขข้อวินิจฉัย ลำดับ ${d.index! + 1}',
              style: _t(11.5, color: _blue, weight: FontWeight.w700)),
          const SizedBox(height: 8.0),
          field('ข้อวินิจฉัยทางการพยาบาล', d.dx,
              'เช่น ปวดเฉียบพลัน เนื่องจากเนื้อเยื่อได้รับบาดเจ็บ'),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final s in _ndxCommon)
                _optChip(s, d.dx.text.trim() == s, false,
                    () => ss(() => d.dx.text = s),
                    size: 10.0),
            ]),
          ),
          const SizedBox(height: 8.0),
          field('การประเมินผล', d.eval, 'ผลหลังให้การพยาบาล', lines: 2),
          const SizedBox(height: 10.0),
          _apptLabel('กิจกรรม'),
          Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 6.0, 4.0, 6.0),
                  child: Row(children: [
                    SizedBox(
                      width: 34.0,
                      child: Text('ลำดับ',
                          style:
                              _t(9.5, color: _ink3, weight: FontWeight.w700)),
                    ),
                    th('เจ้าหน้าที่', flex: 3),
                    th('รายละเอียด', flex: 5),
                    th('เวลา', flex: 3),
                    const SizedBox(width: 28.0),
                  ]),
                ),
                const Divider(height: 1.0, color: _line),
                for (var i = 0; i < acts.length; i++)
                  Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 6.0, 4.0, 6.0),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _line)),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 34.0,
                            child: Text('${i + 1}',
                                style: _num(10.5,
                                    color: _blue, weight: FontWeight.w700)),
                          ),
                          Expanded(
                            flex: 3,
                            child:
                                Text(acts[i].by, style: _t(10.5, color: _ink)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(acts[i].detail,
                                style: _t(11.0,
                                    color: _inkTitle, weight: FontWeight.w600)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(_fmtDateTime(acts[i].at),
                                style: _num(10.0, color: _ink2)),
                          ),
                          IconButton(
                            tooltip: 'ลบกิจกรรมนี้',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28.0, minHeight: 28.0),
                            onPressed: () => ss(() => d.acts.remove(acts[i])),
                            icon: const Icon(Icons.close_rounded,
                                size: 14.0, color: _ink3),
                          ),
                        ]),
                  ),
                // แถวเพิ่มกิจกรรม: เวลา · รายละเอียด · ไมค์ · เพิ่ม
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 4.0),
                  child: Row(children: [
                    InkWell(
                      onTap: () async {
                        final v = await showTimePicker(
                          context: context,
                          initialTime: d.actAt,
                          builder: (c, child) => MediaQuery(
                              data: MediaQuery.of(c)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!),
                        );
                        if (v != null && mounted) ss(() => d.actAt = v);
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        height: 26.0,
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        decoration: BoxDecoration(
                          color: _panelSoft,
                          borderRadius: BorderRadius.circular(8.0),
                          border:
                              Border.all(color: _blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.schedule_rounded,
                              size: 12.0, color: _blue),
                          const SizedBox(width: 4.0),
                          Text('${_obsHm(d.actAt)} น.',
                              style: _num(10.5,
                                  color: _blue, weight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: TextField(
                        controller: d.actInput,
                        onSubmitted: addAct,
                        style: _t(11.0),
                        decoration: InputDecoration(
                          hintText: 'รายละเอียดกิจกรรม แล้วกด +',
                          hintStyle: _t(11.0, color: _g5),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'พูดกิจกรรม',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                      icon: const Icon(Icons.mic_none_rounded,
                          size: 16.0, color: _blue),
                      onPressed: () async {
                        final v = await _voiceTextDialog(
                          title: 'กิจกรรม เวลา ${_obsHm(d.actAt)} น.',
                          initial: d.actInput.text,
                          hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
                          okText: 'เพิ่ม',
                          autoMic: true,
                        );
                        if (v != null && mounted) {
                          addAct(v.replaceAll('\n', ' '));
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'เพิ่มกิจกรรม',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                      onPressed: () => addAct(d.actInput.text),
                      icon: const Icon(Icons.add_circle_rounded,
                          size: 20.0, color: _blue),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          // ปุ่ม: ลบ (ข้อเดิม) ซ้าย · บันทึก / ปิด ขวา
          Row(children: [
            if (d.index != null)
              _miniBtn(Icons.delete_outline_rounded, 'ลบ', delete,
                  tooltip: 'ลบข้อวินิจฉัยนี้'),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(d.error ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5, color: _red, weight: FontWeight.w700)),
            ),
            _miniBtn(Icons.close_rounded, 'ปิด', close,
                tooltip: 'ปิดโดยไม่บันทึก'),
            const SizedBox(width: 8.0),
            _apptPrimaryBtn(Icons.check_rounded, 'บันทึกข้อวินิจฉัย', save),
          ]),
        ],
      ),
    );
  }
}
