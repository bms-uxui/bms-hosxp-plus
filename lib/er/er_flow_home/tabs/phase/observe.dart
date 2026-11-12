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
  _ObsDraft();

  /// แก้ไขบันทึกเดิม: ใส่ค่าเดิมทุกช่อง
  _ObsDraft.edit(_Observe o)
      : editing = o,
        at = o.at,
        place = o.place.isEmpty ? null : o.place,
        room = o.room.isEmpty ? null : o.room,
        bed = o.bed.isEmpty ? null : o.bed,
        orderBy = o.orderBy.isEmpty ? null : o.orderBy,
        status = o.status.isEmpty ? null : o.status,
        out = o.out,
        // บันทึกแล้ว = เริ่มแล้ว · มีผลลัพธ์/เวลาออก = เปิดที่ช่วงจบ
        started = true,
        ending = o.out != null || o.status.isNotEmpty {
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

  /// ช่วงของงาน: เริ่มแล้ว (กด เริ่มสังเกตอาการ) · กลับไปแก้รับเข้า · กำลังบันทึกรอบ · ช่วงจบ
  bool started = false;
  bool editStart = false;

  /// ความถี่ประเมิน (นาที) ที่พยาบาลเลือกเอง เมื่อไม่มีคำสั่ง Observe ของแพทย์
  int? every;

  /// จำนวนรอบที่ต้องประเมิน (เลือกเอง) · null = คำนวณจากคำสั่งแพทย์
  int? rounds;
  bool composing = false;
  bool ending = false;

  /// อยู่ขั้นรอบการสังเกต (แยกจากขั้นเฝ้าดู)
  bool inRounds = false;

  /// รอบที่กำลังบันทึก: เวลา อาการ สิ่งที่ทำ
  TimeOfDay roundAt = TimeOfDay.now();
  final roundNote = TextEditingController();
  final Set<String> roundActs = {};

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
/// ผลการสังเกตอาการ (เลือกตอนจบ)
const List<(IconData, String, bool)> _obsStatus = [
  (Icons.home_rounded, 'กลับบ้าน', false),
  (Icons.local_hospital_rounded, 'Admit', false),
  (Icons.airport_shuttle_rounded, 'Refer', false),
];

/// แท็บบันทึกสังเกตอาการ (เมนู "อื่น ๆ" ของหน้าผู้ป่วย)
const int _obsTab = 16;

/// นาฬิกานับเวลาสังเกตอาการ (ทุก 30 วินาที) · broadcast: หลายวิดเจ็ตฟังพร้อมกันได้ระหว่างเปลี่ยนหน้า
final Stream<void> _obsTick =
    Stream<void>.periodic(const Duration(seconds: 30)).asBroadcastStream();

/// ทิศเปลี่ยนหน้าของฟอร์ม Observe ในแผง workflow (true = ไปข้างหน้า)
bool _obsFwd = true;

/// หน้าของฟอร์ม Observe (ชื่อใน stepper) · ต่อท้ายด้วยหน้าสรุป
const List<String> _obsPages = ['สังเกตอาการ', 'จบ'];

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

  /// แพทย์เวรที่ระบุไว้ในหน้าคัดกรอง ของผู้ป่วยรายนี้ (ชิปแนะนำผู้สั่ง ไม่เติมให้เอง)
  String? _dutyDoctorOf(_P p) {
    if (_caseP().hn != p.hn) return null;
    const key = '${_FeaturesWorkflowFormFieldsPart._erInPrefix}แพทย์เวร';
    for (final f in _filled) {
      final v = f[key];
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  /// ตารางรอบที่พยาบาลต้องเข้าประเมิน: เริ่ม + ทุก N นาที จนครบชั่วโมงที่แพทย์สั่ง
  /// รอบที่บันทึกแล้วจับคู่กับรอบในตารางที่ใกล้ที่สุด (ภายในครึ่งช่วง) · ไม่มีคำสั่ง = ใช้ความถี่ที่พยาบาลเลือก (แสดงถึงรอบถัดไป)
  /// คืน (เวลาในตาราง, เวลาที่ทำจริง หรือ null)
  /// จำนวนรอบ: ที่พยาบาลเลือก > คำนวณจากคำสั่งแพทย์ (ชั่วโมง ÷ ความถี่) · null = ไม่กำหนด
  int? _obsRoundsOf(_P p) {
    final d = _obsDraftOf(p);
    if (d.rounds != null) return d.rounds;
    final ord = _obsOrders[p.hn];
    final every = d.every ?? ord?.everyMin;
    if (ord == null || every == null) return null;
    return ord.hours * 60 ~/ every;
  }

  List<(DateTime, DateTime?)> _obsPlan(_P p) {
    final d = _obsDraftOf(p);
    final start = d.at;
    final ord = _obsOrders[p.hn];
    // ความถี่ที่พยาบาลเลือก > ความถี่ในคำสั่งแพทย์
    final every = d.every ?? ord?.everyMin;
    if (start == null || every == null) return const [];
    final now = DateTime.now();
    DateTime at(TimeOfDay t) =>
        DateTime(start.year, start.month, start.day, t.hour, t.minute);
    final done = {for (final (t, _) in d.acts) at(t)}.toList()..sort();
    // ครบจำนวนรอบที่กำหนด · ไม่กำหนด = แสดงถึงรอบถัดไป
    final n = _obsRoundsOf(p);
    final end = n != null
        ? start.add(Duration(minutes: every * n))
        : now.add(Duration(minutes: every));
    final plan = <(DateTime, DateTime?)>[];
    final used = <DateTime>{};
    for (var t = start.add(Duration(minutes: every));
        !t.isAfter(end);
        t = t.add(Duration(minutes: every))) {
      final half = Duration(minutes: every ~/ 2);
      final hit = done
          .where((x) =>
              !used.contains(x) &&
              !x.isBefore(t.subtract(half)) &&
              x.isBefore(t.add(half)))
          .firstOrNull;
      if (hit != null) used.add(hit);
      plan.add((t, hit));
    }
    return plan;
  }

  /// แถบตารางรอบ (การ์ดซ้อน): สรุปทำแล้ว/เลยเวลา + แถบรอบชุดเดียวกับหน้าคำสั่งแพทย์ · นับใหม่ทุก 30 วินาที
  Widget _obsPlanView(_P p) => StreamBuilder(
      stream: _obsTick,
      builder: (context, _) {
        final d = _obsDraftOf(p);
        final start = d.at;
        if (start == null) return const SizedBox.shrink();
        final ord = _obsOrders[p.hn];
        final plan = _obsPlan(p);
        final now = DateTime.now();
        String mins(int m) => m < 60
            ? '$m นาที'
            : '${m ~/ 60} ชม.${m % 60 == 0 ? '' : ' ${m % 60} นาที'}';
        final late = [
          for (final x in plan)
            if (x.$2 == null && !x.$1.isAfter(now)) x
        ];
        final doneN = plan.where((x) => x.$2 != null).length;
        // แถบรอบชุดเดียวกับคำสั่งทำเป็นรอบในหน้าคำสั่งแพทย์ (_soRoundTrack)
        // Observe แสดงครบทุกรอบในช่วงที่สั่ง (ไม่ตัดเหลือ 4 ช่องแบบคำสั่งยา)
        final who = d.editing?.by ?? ErSession.instance.user?.name ?? 'พยาบาล';
        final done = [
          for (final (_, did) in plan)
            if (did != null) (who, did)
        ];
        final up = [
          for (final (t, did) in plan)
            if (did == null) t
        ];
        return Container(
          padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // สรุปบนแถบ: ทำแล้วกี่รอบจากทั้งหมด · เลยเวลากี่รอบ (แดง)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
              child: Row(children: [
                Expanded(
                  child: Text(
                      plan.isEmpty
                          ? 'สังเกตมาแล้ว ${mins(now.difference(start).inMinutes)}'
                          : ord != null
                              ? 'ทำแล้ว $doneN จาก ${plan.length} รอบ'
                              : 'ทำแล้ว $doneN รอบ',
                      style:
                          _t(13.5, color: _inkTitle, weight: FontWeight.w600)),
                ),
                if (late.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text('เลยเวลา ${late.length} รอบ',
                        style: _t(12.0, color: _red, weight: FontWeight.w600)),
                  ),
              ]),
            ),
            // แถบเลื่อนกินเต็มความกว้างการ์ดซ้อน (ไม่มี padding ข้าง) + ขอบจางสองข้าง
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: plan.isEmpty
                  ? const SizedBox.shrink()
                  : _soRoundTrack(done, up,
                      col: late.isEmpty ? _blue : _red, bleed: 0.0),
            ),
          ]),
        );
      });

  /// ฟอร์มของผู้ป่วยรายนี้: บันทึกแล้ว = ค่าที่บันทึก · ยังไม่บันทึก = ว่าง (สถานที่ตั้งต้น ER)
  _ObsDraft _obsDraftOf(_P p) => _obsDrafts.putIfAbsent(p.hn, () {
        final o = _obsRec[p.hn];
        if (o != null) return _ObsDraft.edit(o);
        // เปิดครั้งแรก = ว่างทุกช่อง ยกเว้นสถานที่ = ห้องฉุกเฉิน (ER) เป็นค่าตั้งต้น
        return _ObsDraft()
          ..place = _masterNames('er_observe_place')
              .where((s) => s.contains('(ER)'))
              .firstOrNull;
      });

  /// ปุ่มบนการ์ดผู้ป่วย (เมนูสังเกตอาการ): เปิดหน้าผู้ป่วยที่แท็บ Observe
  void _openObserve(_P p) => _openDetail(p, tab: _obsTab);

  /// แท็บ Observe (ซ้าย) = แสดงข้อมูลอย่างเดียว 2026-10-20
  /// การคีย์อยู่ที่ขั้น Observe ใน workflow ขวา · ไม่มีปุ่มแก้ไข/ลบ (แบบหน้าข้อมูลอื่นฝั่งซ้าย)
  /// หน้าข้อมูลแบบหน้าอุบัติเหตุ/คัดกรอง (_clyInfoPage): หัวหน้า + การ์ดชื่อช่อง-ค่า + การ์ดข้อความยาว
  Widget _obsTabBody() {
    final p = _caseP();
    final o = _obsRec[p.hn];
    final ndx = _ndxStore[p.hn] ?? const <_Ndx>[];
    final obsStep = _steps.indexWhere((x) => x.$2 == 'สังเกตอาการ');
    final canKey = ErSession.instance.isNurse && obsStep >= 0;
    String val(String s) => s.trim().isEmpty ? '-' : s.trim();

    // การ์ดข้อความยาว: ชุดเดียวกับการ์ดข้อความของหน้าอุบัติเหตุ (เต็มความกว้าง)
    Widget textCard(String name, List<Widget> kids) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 14.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name,
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 8.0),
                  ...kids,
                ]),
          ),
        );
    Widget body(String text, {Color color = _inkTitle}) => Text(text,
        style: _t(14.0, color: color, weight: FontWeight.w500, height: 1.5));

    return _clyInfoPage(
      'สังเกตอาการ',
      'สถานที่ สถานะ อาการ กิจกรรมพยาบาล และวินิจฉัยทางการพยาบาล',
      'nurse_act',
      o == null
          ? const []
          : [
              (
                'ข้อมูลทั่วไป',
                [
                  ('วัน-เวลาเริ่ม', _fmtDateTime(o.at), false),
                  ('สถานที่', val(o.place), false),
                  ('ห้อง', val(o.room), false),
                  ('เตียง', val(o.bed), false),
                  ('ผู้สั่ง', val(o.orderBy), false),
                  (
                    'วัน-เวลาออกจากห้อง',
                    o.out == null ? '-' : _fmtDateTime(o.out!),
                    false
                  ),
                ]
              ),
              ('สถานะ', [('สถานะปัจจุบัน', val(o.status), false)]),
            ],
      // ยังไม่มีบันทึก = ไม่มีบรรทัดผู้บันทึก
      by: o?.by ?? '-',
      at: o == null ? '' : _fmtDateTime(o.at),
      extra: [
        // ตารางรอบตามคำสั่งแพทย์ (ชุดเดียวกับการ์ดรับเข้าในแผงขวา) เมื่อเริ่มสังเกตแล้ว
        if (_obsDrafts[p.hn]?.started ?? false)
          textCard('รอบที่ต้องประเมิน', [_obsPlanView(p)]),
        if (o == null)
          textCard('บันทึกสังเกตอาการ', [
            body(
                canKey
                    ? 'ยังไม่มีบันทึก กรอกได้ที่เมนู Observe ด้านขวา'
                    : 'ยังไม่มีบันทึกสังเกตอาการ',
                color: _ink3),
          ]),
        if (o != null && o.symptom.isNotEmpty)
          textCard('อาการ', [body(o.symptom)]),
        if (o != null && o.acts.isNotEmpty)
          textCard('กิจกรรมพยาบาล', [
            for (final (t, s) in o.acts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72.0,
                        child: Text('${_obsHm(t)} น.',
                            style: _num(13.5,
                                color: _blue, weight: FontWeight.w700)),
                      ),
                      Expanded(child: body(s)),
                    ]),
              ),
          ]),
        if (o != null && o.note.isNotEmpty)
          textCard('หมายเหตุ', [body(o.note)]),
        textCard('วินิจฉัยทางการพยาบาล', [
          if (ndx.isEmpty) body('ยังไม่มีข้อวินิจฉัย', color: _ink3),
          for (final (i, n) in ndx.indexed) ...[
            if (i > 0) const Divider(height: 20.0, color: _line),
            Text('${i + 1}. ${n.dx}',
                style: _t(14.5, color: _inkTitle, weight: FontWeight.w600)),
            if (n.eval.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              body('การประเมินผล: ${n.eval}', color: _ink2),
            ],
            for (final a in n.acts)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: body('${_fmtDateTime(a.at)}  ${a.detail} (${a.by})',
                    color: _ink2),
              ),
          ],
        ]),
      ],
    );
  }

  /// เหรียญ 2.5D หน้าแถว (ชุดเดียวกับฟอร์มอุบัติเหตุ): มีค่า = กรมท่า · ว่าง = เทา · พลิกเมื่อเปลี่ยน
  Widget _obsCoin(IconData icon, bool on) => _CoinFlip(
      value: on ? 'on' : 'off',
      builder: (s, tilt) =>
          _SoStatusCoin.field(icon, on: s == 'on', tilt: tilt));

  /// ป้ายเวลาหน้าแถวกิจกรรม "08.00"
  Widget _obsTimeBadge(TimeOfDay t) => Container(
        width: 56.0,
        height: 32.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE2EAF8),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(_obsHm(t),
            style: _num(13.0, color: _blue, weight: FontWeight.w700)),
      );

  /// ปุ่มลบท้ายแถว: ยืนยันก่อนทุกครั้ง (ชุดเดียวกับฟอร์มอุบัติเหตุ)
  Widget _obsDelBtn(String label, VoidCallback clear) => IconButton(
        onPressed: () async {
          if (!await _wfTextConfirmDelete(label) || !mounted) return;
          HapticFeedback.selectionClick();
          setState(clear);
        },
        tooltip: 'ลบ$label',
        iconSize: 20.0,
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        icon: const Icon(Icons.delete_outline_rounded, color: _ink3),
      );

  /// เลือกเวลา = แผ่นวงล้อเวลาของแอป (_dtSheet timeOnly) ชุดเดียวกับหน้าคัดกรอง/คำสั่งแพทย์
  /// ไม่ใช้ตัวเลือกเวลาของ Material
  Future<TimeOfDay?> _obsPickTime(TimeOfDay init,
      {String title = 'เวลา'}) async {
    final now = DateTime.now();
    final d = await _dtSheet(
      title: title,
      initial: DateTime(now.year, now.month, now.day, init.hour, init.minute),
      // วงล้อเฉพาะเวลาใช้ช่วงชั่วโมง first..last ของวันเดียวกัน = ทั้งวัน 00:00-23:59
      first: DateTime(now.year, now.month, now.day),
      last: DateTime(now.year, now.month, now.day, 23, 59),
      timeOnly: true,
    );
    return d == null ? null : TimeOfDay.fromDateTime(d);
  }

  /// ข้อมูลรับเข้าสังเกตอาการ (ความถี่ เวลาเริ่ม สถานที่ ห้อง เตียง แพทย์ผู้สั่ง): การ์ดซ้อนในขั้นรับเข้าของฟอร์ม Observe
  Widget _obsAdmitCard() {
    final p = _caseP();
    final d = _obsDraftOf(p);
    final doctors = _apptDoctors();
    void ss(VoidCallback f) => setState(() {
          f();
          d.error = null;
        });
    Future<void> pickFlow(int from) async {
      await _listFlow([
        _ListStep('สถานที่', _masterNames('er_observe_place'),
            current: () => d.place, apply: (o) => d.place = o),
        _ListStep('ห้อง', _masterNames('er_room'),
            current: () => d.room, apply: (o) => d.room = o),
        _ListStep('เตียง', _masterNames('er_bed'),
            current: () => d.bed, apply: (o) => d.bed = o),
        _ListStep('ผู้สั่ง', doctors,
            people: true,
            current: () => d.orderBy,
            apply: (o) => d.orderBy = o),
      ].sublist(from, from + 1));
      if (mounted) ss(() {});
    }

    Future<void> pickDt(
        String label, DateTime? cur, void Function(DateTime) set) async {
      final now = DateTime.now();
      final first = now.subtract(const Duration(days: 7));
      // ปุ่มลัด (15/30 นาที/1 ชม.ที่แล้ว) นับย้อนจาก last · เวลาเริ่ม/ออกเป็นอนาคตไม่ได้
      final last = now;
      final init = cur ?? now;
      final v = await _dtSheet(
        title: label,
        initial: init.isBefore(first) || init.isAfter(last) ? now : init,
        first: first,
        last: last,
        pastQuick: true,
      );
      if (v != null && mounted) ss(() => set(v));
    }

    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
    Widget sug(String label, VoidCallback f) => _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              ss(f);
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 132.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.5, color: _blue, weight: FontWeight.w600)),
            ),
          ),
        );

    final obsPlace = _masterNames('er_observe_place')
        .where((s) => s.contains('Observe'))
        .firstOrNull;
    final duty = _dutyDoctorOf(p);
    // คำสั่ง Observe ของแพทย์ (ถ้ามี) = ความถี่ประเมิน · ไม่มี = พยาบาลเลือกเอง
    final obsOrd = _obsOrders[p.hn];
    final pBed = p.bed ?? '';
    String shortDoc(String s) => s.split(' ').take(2).join(' ');

    // ความถี่ = นาที · ค่าเริ่มตามคำสั่งแพทย์ (ถ้ามี) · จำนวนรอบ = ที่เลือก หรือคำนวณจากคำสั่ง
    final every = d.every ?? obsOrd?.everyMin;
    final rounds = _obsRoundsOf(p);
    String everyTh(int m) =>
        m % 60 == 0 ? 'ทุก ${m ~/ 60} ชั่วโมง' : 'ทุก $m นาที';
    const everyOpts = [15, 30, 60, 120, 240];
    Future<void> pickEvery() async {
      String? pick;
      await _listFlow([
        _ListStep(
            'ความถี่', [for (final m in everyOpts) everyTh(m), 'กำหนดเอง'],
            current: () => every == null ? null : everyTh(every),
            apply: (o) => pick = o),
      ]);
      if (pick == null || !mounted) return;
      if (pick == 'กำหนดเอง') {
        await _soNumSheet(
            title: 'ความถี่ (ทุกกี่นาที)',
            unit: 'นาที',
            max: 240.0,
            initial: every == null ? '' : '$every',
            onDone: (v) {
              final n = int.tryParse(v);
              if (n != null && n > 0) ss(() => d.every = n);
            });
        return;
      }
      ss(() => d.every = everyOpts.firstWhere((m) => everyTh(m) == pick));
    }

    Future<void> pickRounds() => _soNumSheet(
        title: 'จำนวนรอบ',
        unit: 'รอบ',
        max: 48.0,
        initial: rounds == null ? '' : '$rounds',
        onDone: (v) {
          final n = int.tryParse(v);
          if (n != null && n > 0) ss(() => d.rounds = n);
        });

    Widget pickRow(String label, IconData icon, String? value, int step,
            {(String, VoidCallback)? hint, bool first = false}) =>
        _gListRow(
          first: first,
          inset: 8.0,
          lead: _obsCoin(icon, value != null),
          title: value ?? label,
          titleLines: 2,
          sub: value == null ? 'ยังไม่ได้เลือก' : label,
          onTap: () => pickFlow(step),
          trail: value == null && hint != null ? sug(hint.$1, hint.$2) : null,
        );
    return // ข้อมูลการ Observe: การ์ดซ้อน (ขาว ขอบ 0.5) ไม่มีหัวข้อ · แตะแถว = เลือกค่า
        Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ความถี่ / เริ่มครั้งแรก / จำนวนรอบ: แถวแบบหน้าสั่งยา (ชื่อซ้าย ค่าขวา › แตะ = แผ่นเลือก)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(children: [
            _procRow('ความถี่', every == null ? null : everyTh(every),
                first: true, placeholder: 'เลือกความถี่', onTap: pickEvery),
            _procRow('เริ่มครั้งแรก', d.at == null ? null : hm(d.at!),
                placeholder: 'ทันที',
                onTap: () => pickDt('เริ่มสังเกตอาการ', d.at, (v) => d.at = v)),
            _procRow('จำนวนรอบ', rounds == null ? null : '$rounds รอบ',
                placeholder: 'เลือกจำนวนรอบ', onTap: pickRounds),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
        ),
        pickRow('สถานที่', Icons.place_rounded, d.place, 0,
            hint: obsPlace == null
                ? null
                : (obsPlace.split(' (').first, () => d.place = obsPlace)),
        pickRow('ห้อง', Icons.meeting_room_rounded, d.room, 1),
        pickRow('เตียง', Icons.bed_rounded, d.bed, 2,
            hint: pBed.isEmpty ? null : (pBed, () => d.bed = pBed)),
        pickRow('แพทย์ผู้สั่ง', Icons.person_rounded, d.orderBy, 3,
            hint: switch (obsOrd?.by ?? duty) {
              final who? => (shortDoc(who), () => d.orderBy = who),
              null => null,
            }),
      ]),
    );
  }

  /// ขั้น Observe ในแผง workflow: หน้าละหมวดแบบฟอร์มอุบัติเหตุ (stepper + การ์ดแบบเมนูแพทย์)
  /// _uiIdx 1 ข้อมูลทั่วไป · 2 สถานะและอาการ · 3 กิจกรรมพยาบาล · 4 วินิจฉัย · 5 สรุป
  /// ข้อมูลและการบันทึกเหมือนเดิม (_ObsDraft · _obsSave · ไม่มีช่องบังคับ)
  Widget _obsFlow() {
    final p = _caseP();
    final d = _obsDraftOf(p);
    // ช่วงของงานจากสถานะฟอร์ม (ไม่ใช่เลขหน้า)
    final phase = d.editStart
        ? 'start'
        : d.composing
            ? 'round'
            : d.ending
                ? 'end'
                : 'rounds';

    void ss(VoidCallback f) => setState(() {
          f();
          d.error = null;
        });

    void save() {
      if (d.missing.isNotEmpty) {
        HapticFeedback.heavyImpact();
        _obsSave(p);
        return;
      }
      _wfSaveBurst('Observe',
          atFull: () {
            _obsSave(p);
            setState(() => _speechDone.add(_speechStep));
          },
          onClose: () {
            // แผงซ้ายเปิดหน้าสังเกตอาการ (แบบบันทึกอุบัติเหตุ)
            setState(() => _detailTab = _obsTab);
            _closeSpeech();
          },
          onView: () => setState(() => _detailTab = _obsTab));
    }

    // วันเวลา = แผ่นปฏิทิน + วงล้อเวลาของแอป (_dtSheet) ชุดเดียวกับวันเวลาเกิดเหตุของอุบัติเหตุ
    Future<void> pickDt(
        String label, DateTime? cur, void Function(DateTime) set) async {
      final now = DateTime.now();
      final first = now.subtract(const Duration(days: 7));
      // ปุ่มลัด (15/30 นาที/1 ชม.ที่แล้ว) นับย้อนจาก last · เวลาเริ่ม/ออกเป็นอนาคตไม่ได้
      final last = now;
      final init = cur ?? now;
      final v = await _dtSheet(
        title: label,
        initial: init.isBefore(first) || init.isAfter(last) ? now : init,
        first: first,
        last: last,
        pastQuick: true,
      );
      if (v != null && mounted) ss(() => set(v));
    }

    // ข้อความยาว: หน้าพิมพ์ในแผง (ชุดเดียวกับเล่าเหตุการณ์ของอุบัติเหตุ) มีไมค์ใน footer
    Future<void> editText(String title, TextEditingController c, String hint,
        {String? crumb}) async {
      final v = await _ftOpen(context,
          title: title,
          crumb: crumb,
          inWorkflow: true,
          initial: c.text,
          hint: hint);
      if (v == null || !mounted) return;
      ss(() => c.text = v.trim());
    }

    // ---- ชิ้นส่วนการ์ด
    // ภาพไอคอนสี่เหลี่ยม: วางพอดีมุมขวา (แบบการ์ดเล่าเหตุการณ์)
    Widget iconArt(String asset) => Padding(
          padding: const EdgeInsets.fromLTRB(56.0, 14.0, 14.0, 22.0),
          child: Image.asset(asset,
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              filterQuality: FilterQuality.medium),
        );
    Widget gap(Widget w) =>
        Padding(padding: const EdgeInsets.only(bottom: 12.0), child: w);

    // การ์ดข้อความยาวแบบการ์ดอาการสำคัญ/หมายเหตุ: เพิ่ม/แก้ไข = หน้าพิมพ์ในแผง
    Widget noteCard(String title, String sub, TextEditingController c,
        String hint, IconData ic) {
      final has = c.text.trim().isNotEmpty;
      Future<void> open() => editText(title, c, hint);
      return gap(_dxCard(
        title,
        sub,
        iconArt('assets/images/er_os_note_add.png'),
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
              lead: _obsCoin(ic, true),
              title: c.text.trim(),
              titleLines: 3,
              sub: '',
              onTap: open,
              trail: _obsDelBtn(title, () => c.clear()),
            ),
        ]),
      ));
    }

    // ---- 3 ช่วงตามงานหน้างานจริง: รับเข้า → เฝ้าดูเป็นรอบ → จบ (ไม่ใช่ฟอร์มกรอกรวดเดียว)
    // รับเข้า = ยืนยันเวลา ที่ ผู้สั่ง (ชิปแนะนำ แตะเพื่อใช้ ไม่เลือกให้ล่วงหน้า)
    // เฝ้าดู = นับเวลา + รอบถัดไป + ไทม์ไลน์รอบ · ปุ่มหลักเดียว "บันทึกรอบนี้"
    // จบ = ผลลัพธ์ + เวลาออก + หมายเหตุ/วินิจฉัย แล้วบันทึก

    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
    String hmT(TimeOfDay t) => '${_obsHm(t).replaceAll('.', ':')} น.';

    const order = ['rounds', 'start', 'round', 'end'];
    void to(String ph, VoidCallback f) {
      HapticFeedback.selectionClick();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _obsFwd = order.indexOf(ph) >= order.indexOf(phase);
        f();
        d.error = null;
      });
    }

    // ชิปแนะนำท้ายแถว: แตะ = ใช้ค่านี้ (ขอบเทา ตัวกรมท่า)
    Widget sug(String label, VoidCallback f) => _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              ss(f);
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 132.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.5, color: _blue, weight: FontWeight.w600)),
            ),
          ),
        );

    // คำสั่ง Observe ของแพทย์ (ถ้ามี) = ความถี่ประเมิน · ไม่มี = พยาบาลเลือกเอง
    final obsOrd = _obsOrders[p.hn];

    // รอบที่บันทึกแล้ว: กิจกรรมเวลาเดียวกัน = 1 รอบ (ใหม่อยู่บน)
    final rounds = <int, List<String>>{};
    for (final (t, s) in d.acts) {
      (rounds[t.hour * 60 + t.minute] ??= []).add(s);
    }
    final roundKeys = rounds.keys.toList()..sort((a, b) => b.compareTo(a));

    // ---- รับเข้า

    // เปิดหน้าบันทึกรอบ (ปุ่มในการ์ดรอบการสังเกต)
    void openRound() => to('round', () {
          d.composing = true;
          d.roundAt = TimeOfDay.now();
          d.roundNote.clear();
          d.roundActs.clear();
        });

    void addRound() {
      final note = d.roundNote.text.trim();
      if (note.isEmpty && d.roundActs.isEmpty) {
        HapticFeedback.heavyImpact();
        setState(
            () => d.error = 'ใส่อาการ หรือเลือกสิ่งที่ทำอย่างน้อย 1 อย่าง');
        return;
      }
      to('rounds', () {
        d.at ??= DateTime.now();
        d.started = true;
        if (note.isNotEmpty) {
          d.acts.add((d.roundAt, 'อาการ: $note'));
          d.symptom.text = note;
        }
        for (final s in d.roundActs) {
          d.acts.add((d.roundAt, s));
        }
        d.composing = false;
      });
      // บันทึกระหว่างทาง (ไม่มี snackbar) ให้แผงซ้าย/ไทม์ไลน์เห็นรอบล่าสุด
      _obsSave(p, quiet: true);
    }

    // ---- เฝ้าดู
    // แถวไทม์ไลน์แนวตั้ง: เหรียญ + เส้นต่อลงแถวถัดไป · ชื่อ เวลา · รายละเอียดทีละบรรทัด
    Widget timelineItem(
            Widget coin, String title, String time, List<String> lines,
            {Widget? trail, bool last = false}) =>
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 44.0,
              child: Column(children: [
                SizedBox(
                    width: 30.0, height: 30.0, child: FittedBox(child: coin)),
                Expanded(
                  child: last
                      ? const SizedBox.shrink()
                      : Container(
                          width: 2.0,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: const Color(0xFFDADCE0)),
                ),
              ]),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: last ? 8.0 : 18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: title,
                            style: _t(14.5,
                                color: _inkTitle, weight: FontWeight.w700)),
                        TextSpan(
                            text: '  $time',
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ])),
                      for (final (j, l) in lines.indexed) ...[
                        const SizedBox(height: 3.0),
                        Text(l,
                            style: _t(13.0,
                                color: j == 0 ? _inkTitle : _ink2,
                                height: 1.35,
                                weight: FontWeight.w500)),
                      ],
                    ]),
              ),
            ),
            if (trail != null)
              Align(alignment: Alignment.topCenter, child: trail),
          ]),
        );

    // ---- รอบการสังเกต (ขั้นแยก): ปุ่มบันทึกกิจกรรม + ไทม์ไลน์รายการรอบ
    Widget roundsPage() {
      final plan = _obsPlan(p);
      final start = d.at ?? DateTime.now();
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // หน้าหลัก: การ์ดสังเกตอาการผู้ป่วย = ปุ่ม 2 อัน (ข้อมูลการรับเข้า · กิจกรรมทางพยาบาล)
        // + ไทม์ไลน์รายการรอบ (ใหม่อยู่บน จบที่รับเข้า) · แต่ละปุ่มเปิดหน้าย่อย ย้อนกลับ = กลับหน้านี้
        gap(_dxCard(
          'สังเกตอาการผู้ป่วย',
          'ข้อมูลการรับเข้า และกิจกรรมทางพยาบาลแต่ละรอบ',
          // ภาพหัวการ์ด (Figma 1036:185 กลับซ้ายขวาตามแบบ)
          // ย่อทั้งภาพลงในช่อง (contain) ไม่ตัดหัว
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 6.0, 12.0, 8.0),
            child: _dxArtFade(Image.asset('assets/images/er_ov_resus_fig.png',
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ปุ่มเมนูปกติของการ์ด (แบบการ์ดอื่น) · footer ใช้เปลี่ยนช่วงเท่านั้น
            _dxTiles([
              (
                Icons.assignment_ind_outlined,
                'ข้อมูลการรับเข้า',
                () => to('start', () => d.editStart = true)
              ),
              (Icons.edit_note_rounded, 'กิจกรรมทางพยาบาล', openRound),
            ]),
            const SizedBox(height: 8.0),
            for (final k in roundKeys)
              timelineItem(
                const _SoStatusCoin.done(),
                // ครั้งที่ตามตารางรอบของแพทย์ (ไม่ตรงตาราง = รอบเพิ่ม)
                switch (plan.indexWhere((x) =>
                    x.$2 != null && x.$2!.hour * 60 + x.$2!.minute == k)) {
                  final n when n >= 0 => 'ครั้งที่ ${n + 1}',
                  _ => 'รอบเพิ่ม',
                },
                hmT(TimeOfDay(hour: k ~/ 60, minute: k % 60)),
                rounds[k]!,
                trail: _obsDelBtn(
                    'รอบ ${hmT(TimeOfDay(hour: k ~/ 60, minute: k % 60))}',
                    () => d.acts
                        .removeWhere((a) => a.$1.hour * 60 + a.$1.minute == k)),
              ),
            timelineItem(
              const _SoStatusCoin.field(Icons.login_rounded),
              'รับเข้า',
              hm(start),
              [
                [
                  if (d.place != null) d.place!,
                  if (d.room != null) d.room!,
                  if (d.bed != null) 'เตียง ${d.bed}',
                ].join(' '),
              ].where((x) => x.isNotEmpty).toList(),
              last: true,
            ),
          ]),
        )),
      ]);
    }

    // ---- บันทึกรอบ: การ์ดเดียว เรียงตามงานข้างเตียง
    // 1 ติ๊กสิ่งที่ทำตามคำสั่งแพทย์ → 2 อาการตอนนี้ → 3 กิจกรรมอื่น · เวลาของรอบ = ชิปหัวการ์ด (ค่าเริ่ม = ตอนนี้)
    Widget roundPage() {
      final note = d.roundNote.text.trim();
      final crumb = 'รอบ ${hmT(d.roundAt)}';
      // ติ๊กได้เฉพาะสิ่งที่แพทย์สั่งใน Observe · ที่เพิ่มเองต่อท้าย (ลบได้)
      final ordered = obsOrd?.acts ?? const <String>[];
      final extra = d.roundActs.where((s) => !ordered.contains(s)).toList();
      final rows = <Widget>[];
      void add(Widget Function(bool first) w) => rows.add(w(rows.isEmpty));
      for (final s in ordered) {
        final on = d.roundActs.contains(s);
        add((first) => _gListRow(
              first: first,
              inset: 8.0,
              lead: _obsCoin(Icons.check_rounded, on),
              title: s,
              sub: on ? 'ทำแล้ว' : 'แตะเมื่อทำแล้ว',
              subColor: on ? _green : _ink3,
              onTap: () {
                HapticFeedback.selectionClick();
                ss(() => on ? d.roundActs.remove(s) : d.roundActs.add(s));
              },
              trail: const SizedBox.shrink(),
            ));
      }
      add((first) => _gListRow(
            first: first,
            inset: 8.0,
            lead: _obsCoin(Icons.monitor_heart_rounded, note.isNotEmpty),
            title: note.isEmpty ? 'อาการตอนนี้' : note,
            titleLines: 3,
            sub: note.isEmpty ? 'แตะเพื่อพิมพ์ หรือพูด' : 'อาการ',
            onTap: () => editText('อาการ', d.roundNote,
                'เช่น ปวดลดลง 3/10 ไม่มีคลื่นไส้ รู้สึกตัวดี',
                crumb: crumb),
          ));
      for (final s in extra) {
        add((first) => _gListRow(
              first: first,
              inset: 8.0,
              lead: _obsCoin(Icons.check_rounded, true),
              title: s,
              sub: 'กิจกรรมอื่น',
              trail: _obsDelBtn(s, () => d.roundActs.remove(s)),
            ));
      }
      add((first) => _gListRow(
            first: first,
            inset: 8.0,
            lead: _obsCoin(Icons.add_rounded, false),
            title: 'เพิ่มกิจกรรมอื่น',
            sub: 'พิมพ์ หรือพูด',
            onTap: () async {
              final v = await _ftOpen(context,
                  title: 'กิจกรรมอื่น',
                  crumb: crumb,
                  inWorkflow: true,
                  initial: '',
                  hint: 'สิ่งที่ทำ เช่น เช็ดตัวลดไข้');
              final t = v?.replaceAll('\n', ' ').trim() ?? '';
              if (t.isNotEmpty && mounted) ss(() => d.roundActs.add(t));
            },
          ));

      return gap(_dxCard(
        'กิจกรรมทางพยาบาล',
        'สิ่งที่ทำตามคำสั่งแพทย์ และอาการตอนนี้',
        const SizedBox.shrink(),
        // เวลาของรอบ: ชิปหัวการ์ด แตะเพื่อเปลี่ยน
        trail: _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final v = await _obsPickTime(d.roundAt, title: 'เวลาของรอบนี้');
              if (v != null && mounted) ss(() => d.roundAt = v);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EAF8),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.schedule_rounded, size: 15.0, color: _blue),
                const SizedBox(width: 4.0),
                Text(hmT(d.roundAt),
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ...rows,
          // บันทึกรอบ = ปุ่มในการ์ด
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
            child: _navBtn('เพิ่มรอบนี้', Icons.check_rounded, addRound),
          ),
          if (d.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(d.error!,
                  textAlign: TextAlign.center,
                  style: _t(12.5, color: _red, weight: FontWeight.w600)),
            ),
        ]),
      ));
    }

    // ---- จบ
    Widget statusTile((IconData, String, bool) s) {
      final (icon, label, alarm) = s;
      final on = d.status == label;
      final c = alarm ? _red : _blue;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            ss(() => d.status = on ? null : label);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 96.0,
            decoration: BoxDecoration(
              color: on ? c.withValues(alpha: 0.06) : _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                  color: on ? c : const Color(0xFFDADCE0),
                  width: on ? 1.5 : 0.5),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _obsCoin(icon, on),
              const SizedBox(height: 8.0),
              Text(label,
                  style: _t(14.0,
                      color: on ? c : _inkTitle, weight: FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    Widget endPage() {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        gap(_dxCard(
          'ผลการสังเกตอาการ',
          'ผลลัพธ์ และเวลาออกจากห้อง',
          const SizedBox.shrink(),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: Row(children: [
                for (var i = 0; i < _obsStatus.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8.0),
                  Expanded(child: statusTile(_obsStatus[i])),
                ],
              ]),
            ),
            _gListRow(
              first: true,
              inset: 8.0,
              lead: _obsCoin(Icons.logout_rounded, d.out != null),
              title: d.out == null ? 'เวลาออกจากห้อง' : hm(d.out!),
              sub: d.out == null ? 'ยังไม่ได้เลือก' : 'เวลาออกจากห้อง',
              onTap: () =>
                  pickDt('วัน-เวลาออกจากห้อง', d.out, (v) => d.out = v),
              trail: d.out == null
                  ? sug('ตอนนี้', () => d.out = DateTime.now())
                  : _obsDelBtn('เวลาออกจากห้อง', () => d.out = null),
            ),
            const SizedBox(height: 4.0),
          ]),
        )),
        noteCard('หมายเหตุ', 'ผลการประเมิน หรือสิ่งที่ส่งต่อ', d.note,
            'ผลการประเมิน / สิ่งที่ต้องส่งต่อ', Icons.sticky_note_2_rounded),
        _ndxSection(p),
        if (d.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(d.error!,
                style: _t(12.5, color: _red, weight: FontWeight.w600)),
          ),
      ]);
    }

    // ---- รับเข้า: ภาพเตียง + การ์ดซ้อนข้อมูลรับเข้า (ใช้ร่วมกับ _obsAdmitCard)
    Widget startPage() => gap(_dxCard(
          'ข้อมูลการรับเข้า',
          'ความถี่ประเมิน เวลาเริ่ม และที่สังเกตอาการ',
          // ภาพหัวการ์ด: เตียงทั้งคัน (Figma 565:55) ตัดเฉพาะพื้นที่โปร่งใส · ขอบล่างจาง
          Padding(
            padding: const EdgeInsets.fromLTRB(34.0, 14.0, 16.0, 22.0),
            child: _dxArtFade(FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              child: ClipRect(
                child: Align(
                  alignment: const Alignment(0.08, 0.53),
                  widthFactor: 0.87,
                  heightFactor: 0.62,
                  child: Image.asset('assets/images/er_obs_bed.png',
                      width: 1024.0,
                      height: 1024.0,
                      filterQuality: FilterQuality.medium),
                ),
              ),
            )),
          ),
          _obsAdmitCard(),
        ));

    final content = switch (phase) {
      'start' => startPage(),
      'round' => roundPage(),
      'end' => endPage(),
      _ => roundsPage(),
    };

    // ปุ่มหลักหนึ่งปุ่มต่อช่วง · ย้อนกลับ = ช่วงก่อนหน้า (รับเข้า = หน้าคำแนะนำ)
    // footer = ตัวควบคุมไปช่วงต่าง ๆ เท่านั้น (ย้อนกลับ | ถัดไป) · ปุ่มบันทึกข้อมูลอยู่ในการ์ด
    // ช่วงจบ = บันทึกทั้งแบบฟอร์ม (ชุดเดียวกับหน้าสุดท้ายของเมนูอื่น)
    final Widget? main = switch (phase) {
      // หน้าย่อย (ข้อมูลการรับเข้า · กิจกรรมทางพยาบาล) = ปุ่มย้อนกลับอย่างเดียว
      'start' => null,
      'round' => null,
      'end' => KeyedSubtree(
          // จุดเริ่มแอนิเมชันบันทึกสำเร็จ
          key: _wfSaveBtnKey,
          child: _navBtn('บันทึก', Icons.check_rounded, save)),
      _ => _navBtn('ถัดไป', Icons.chevron_right_rounded,
          () => to('end', () => d.ending = true),
          trailing: true),
    };
    void back() => switch (phase) {
          'start' => to('rounds', () {
              d.editStart = false;
              // กรอกรับเข้าแล้ว = เริ่มสังเกตอาการ (ไม่ใส่เวลาเริ่ม = ตอนนี้)
              d.at ??= DateTime.now();
              d.started = true;
            }),
          'round' => to('rounds', () => d.composing = false),
          'end' => to('rounds', () => d.ending = false),
          // หน้าหลัก = กลับหน้าคำแนะนำ (กฎทุกเมนู)
          _ => setState(() => _uiIdx = 0),
        };

    // หน้าพิมพ์ข้อความในแผง (_ftOpen inWorkflow): ทับเนื้อหาของขั้นนี้
    _wfTextRebuild = () {
      if (mounted) setState(() {});
    };
    _wfConfirmDelete = (title) => _wfTextConfirmDelete(title);
    final writing = _wfText;

    final body = Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: _hxStepper(
          [
            for (final (i, n) in _obsPages.indexed)
              (n, [d.acts.isNotEmpty, d.status != null && d.out != null][i]),
          ],
          phase == 'end' ? 1 : 0,
          onTap: (i) => to(['rounds', 'end'][i], () {
            d.editStart = false;
            d.composing = false;
            d.ending = i == 1;
          }),
        ),
      ),
      Expanded(
        child: _hxScrollHide(_wfFadePage(
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
                final enter = child.key == ValueKey('obs-page-$phase');
                final dir = _obsFwd ? 1.0 : -1.0;
                if (enter) return _LateSlideIn(dx: 0.22 * dir, child: child);
                return FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position:
                        Tween(begin: Offset(-0.22 * dir, 0), end: Offset.zero)
                            .animate(a),
                    child: child,
                  ),
                );
              },
              // key ตามหน้า: เปลี่ยนหน้า = เริ่มบนสุดเสมอ
              child: ListView(
                key: ValueKey('obs-page-$phase'),
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
                children: [content],
              ),
            ),
          ),
          Padding(
            key: _wfBtnKey,
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(children: [
              _wfFootBack(back),
              if (main != null) Expanded(child: main) else const Spacer(),
            ]),
          ),
        )),
      ),
    ]);
    return Stack(children: [
      Positioned.fill(child: body),
      Positioned.fill(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: writing == null
              ? const SizedBox.shrink(key: ValueKey('obs-no-wft'))
              : ColoredBox(
                  key: ObjectKey(writing),
                  color: _panel,
                  child: _FtPage(req: writing),
                ),
        ),
      ),
    ]);
  }

  /// บันทึก (ครั้งแรก = สร้าง · ครั้งถัดไป = อัปเดตบันทึกเดิม คงผู้บันทึกเดิม)
  /// quiet = บันทึกระหว่างเฝ้าดู (หลังเพิ่มรอบ) ข้อมูลไม่ครบก็ไม่เตือน
  void _obsSave(_P p, {bool quiet = false}) {
    final d = _obsDraftOf(p);
    final miss = d.missing;
    if (miss.isNotEmpty) {
      if (quiet) return;
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
    // ไม่มี snackbar: แอนิเมชันบันทึกสำเร็จของแผงบอกผลแล้ว
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

/// ข้อวินิจฉัยทางการพยาบาลต่อ HN (ตามลำดับที่เพิ่ม)
final Map<String, List<_Ndx>> _ndxStore = {};

/// ข้อวินิจฉัยทางการพยาบาลที่พบบ่อยใน ER
const List<String> _ndxCommon = [
  'ปวดเฉียบพลัน',
  'การแลกเปลี่ยนก๊าซบกพร่อง',
  'เสี่ยงต่อภาวะพร่องสารน้ำ',
  'เสี่ยงต่อการติดเชื้อ',
  'เสี่ยงต่อการพลัดตกหกล้ม',
  'วิตกกังวล',
];

/// การ์ดข้อวินิจฉัยที่กางอยู่ (null = ไม่มี)
String? _ndxOpen;

/// ผลการประเมินบนร่องเหรียญ: ชื่อ · ชนิดเหรียญ (0 ✓ เขียว · 1 ส้ม · 2 เทา)
const List<(String, int)> _ndxEvals = [
  ('ดีขึ้น', 0),
  ('คงเดิม', 2),
  ('แย่ลง', 1),
];

/// ภาพประกอบการ์ดข้อวินิจฉัย (ภาพระบบชุดเดียวกับ ROS/PE) · พิมพ์เอง = ภาพบันทึก
String _ndxArt(String dx) => switch (dx) {
      'ปวดเฉียบพลัน' => 'assets/images/er_ros_sys_msk.png',
      'การแลกเปลี่ยนก๊าซบกพร่อง' => 'assets/images/er_ros_sys_resp.png',
      'เสี่ยงต่อภาวะพร่องสารน้ำ' => 'assets/images/er_ros_sys_cardio.png',
      'เสี่ยงต่อการติดเชื้อ' => 'assets/images/er_ros_sys_hemato.png',
      'เสี่ยงต่อการพลัดตกหกล้ม' => 'assets/images/er_pe_sys_extremities.png',
      'วิตกกังวล' => 'assets/images/er_ros_sys_constitutional.png',
      _ => 'assets/images/er_os_note_add.png',
    };

extension _TabsPhaseObserveNdxPart on _ErFlowHomeWidgetState {
  /// หน้าวินิจฉัยทางการพยาบาล: ภาษาเดียวกับหน้าปัจจัยเสี่ยงของอุบัติเหตุ (ผู้ใช้ 2026-11-11)
  /// กริด 2 คอลัมน์ ข้อละการ์ด (ข้อที่พบบ่อย + ข้อที่พิมพ์เอง) · แตะการ์ด = กางเต็มแถว
  /// ร่องเหรียญ 2.5D = ผลการประเมิน ดีขึ้น ✓ เขียว · คงเดิม เทา · แย่ลง ส้ม (เลือกผล = ได้ข้อนี้ด้วย)
  /// ใต้ร่อง: กิจกรรมของข้อ (เวลา รายละเอียด ผู้ทำ) + ปุ่ม เลือก/ลบข้อ · เพิ่มกิจกรรม · พิมพ์ผล
  /// ข้อมูลชุดเดิม (_ndxStore: ข้อวินิจฉัย · การประเมินผล · กิจกรรม) แก้แล้วมีผลทันที
  Widget _ndxSection(_P p) {
    final list = _ndxStore[p.hn] ?? const <_Ndx>[];
    final me = ErSession.instance.user?.name ?? 'พยาบาล';
    int idx(String dx) => list.indexWhere((n) => n.dx == dx);
    // การ์ดแรกสุด = การ์ดเพิ่มข้อที่ไม่มีในรายการ (พิมพ์เอง)
    const addKey = '__ndx_add__';
    final cards = [
      addKey,
      ..._ndxCommon,
      for (final n in list)
        if (!_ndxCommon.contains(n.dx)) n.dx,
    ];

    // ข้อนี้ (เพิ่มให้ถ้ายังไม่มี) แล้วแทนค่าที่เปลี่ยน · กิจกรรมเรียงตามเวลา
    void put(String dx, {String? eval, List<_NdxAct>? acts}) {
      final l = _ndxStore[p.hn] ??= [];
      var i = l.indexWhere((n) => n.dx == dx);
      if (i < 0) {
        l.add(_Ndx(dx, '', const []));
        i = l.length - 1;
      }
      final o = l[i];
      setState(() => l[i] = _Ndx(dx, eval ?? o.eval,
          [...(acts ?? o.acts)]..sort((a, b) => a.at.compareTo(b.at))));
    }

    Future<String?> typeText(String title, String initial, String hint) async {
      final v = await _ftOpen(context,
          title: title, inWorkflow: true, initial: initial, hint: hint);
      return v?.trim();
    }

    Future<void> addCustom() async {
      final v = await typeText('ข้อวินิจฉัยทางการพยาบาล', '',
          'เช่น ปวดเฉียบพลัน เนื่องจากเนื้อเยื่อได้รับบาดเจ็บ');
      if (v == null || v.isEmpty || !mounted) return;
      HapticFeedback.selectionClick();
      if (idx(v) < 0) put(v);
      setState(() => _ndxOpen = v);
    }

    Future<void> remove(String dx) async {
      final i = idx(dx);
      if (i < 0) return;
      final ok = await _askDelete('ลบข้อวินิจฉัยนี้?',
          'ลำดับ ${i + 1} $dx\nกิจกรรมของข้อนี้จะถูกลบไปด้วย', 'ลบ');
      if (ok != true || !mounted) return;
      setState(() {
        _ndxStore[p.hn]?.removeAt(i);
        if (!_ndxCommon.contains(dx)) _ndxOpen = null;
      });
    }

    // กิจกรรมใหม่ = เวลาตอนนี้ (แตะแถวเพื่อเปลี่ยนเวลา) · ผู้ทำ = ผู้ใช้ที่เข้าระบบ
    Future<void> addAct(String dx) async {
      final v = await typeText(
          'กิจกรรม: $dx', '', 'รายละเอียดกิจกรรม หรือแตะไมค์เพื่อพูด');
      if (v == null || v.isEmpty || !mounted) return;
      final i = idx(dx);
      put(dx, acts: [
        if (i >= 0) ...list[i].acts,
        _NdxAct(me, v.replaceAll('\n', ' '), DateTime.now()),
      ]);
    }

    int? kindOf(String eval) =>
        _ndxEvals.where((e) => e.$1 == eval).map((e) => e.$2).firstOrNull;

    // เลือกผล = ได้ข้อนี้ · แตะผลเดิมซ้ำ = ล้างผล (ข้อยังอยู่) · เลือกแล้วหุบกลับ (แบบปัจจัยเสี่ยง)
    void pick(String dx, String o) {
      HapticFeedback.selectionClick();
      final i = idx(dx);
      put(dx, eval: i >= 0 && list[i].eval == o ? '' : o);
      Future.delayed(const Duration(milliseconds: 720), () {
        if (mounted && _ndxOpen == dx) setState(() => _ndxOpen = null);
      });
    }

    // ร่องเลือก (ชุดเดียวกับปัจจัยเสี่ยง/_peOpts): เหรียญจางทุกจุด · ตัวที่เลือกหมุนโผล่จากใต้ร่อง
    Widget track(String dx, String eval) {
      final sel = _ndxEvals.indexWhere((e) => e.$1 == eval);
      final n = _ndxEvals.length;
      const trackH = 40.0, badge = 46.0, lift = 14.0;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                for (final (k, (o, kind)) in _ndxEvals.indexed)
                  Positioned.fill(
                    top: lift,
                    child: Align(
                      alignment: Alignment(ax(k, trackH), 0.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => pick(dx, o),
                        child: SizedBox.square(
                          dimension: trackH,
                          child: Center(
                            child: Opacity(
                              opacity: k == sel ? 0.0 : 0.45,
                              child: _PeBadge25D(kind: kind, size: 28.0),
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
                        key: ValueKey('ndx-coin-$dx-$sel'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) => Transform.translate(
                          offset: Offset(0.0, (1.0 - t) * (trackH + lift)),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.003)
                              ..rotateY((1.0 - t) * math.pi * 3.0),
                            child: child,
                          ),
                        ),
                        child:
                            _PeBadge25D(kind: _ndxEvals[sel].$2, size: badge),
                      ),
                    ),
                  ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 6.0),
        Row(children: [
          for (final (k, (o, _)) in _ndxEvals.indexed)
            Expanded(
              child: Text(o,
                  textAlign: TextAlign.center,
                  style: _t(13.0,
                      color: k == sel ? _inkTitle : _ink3,
                      weight: k == sel ? FontWeight.w700 : FontWeight.w500)),
            ),
        ]),
      ]);
    }

    // ส่วนใต้ร่องของการ์ดที่กาง: ผลที่พิมพ์เอง · กิจกรรม · ปุ่ม
    const actH = 52.0;
    Widget openBody(String dx) {
      final i = idx(dx);
      final n = i < 0 ? null : list[i];
      final freeEval = n != null && n.eval.isNotEmpty && kindOf(n.eval) == null;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (freeEval)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text('ผลการประเมิน: ${n.eval}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
          ),
        const SizedBox(height: 10.0),
        for (final a in n?.acts ?? const <_NdxAct>[])
          SizedBox(
            height: actH,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              // แตะแถว = เปลี่ยนเวลาของกิจกรรมนี้
              onTap: () async {
                final t = await _obsPickTime(TimeOfDay.fromDateTime(a.at),
                    title: a.detail);
                if (t == null || !mounted) return;
                put(dx, acts: [
                  for (final x in n!.acts)
                    identical(x, a)
                        ? _NdxAct(
                            a.by,
                            a.detail,
                            DateTime(a.at.year, a.at.month, a.at.day, t.hour,
                                t.minute))
                        : x,
                ]);
              },
              child: Row(children: [
                _obsTimeBadge(TimeOfDay.fromDateTime(a.at)),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.5,
                                color: _inkTitle, weight: FontWeight.w600)),
                        Text(a.by,
                            maxLines: 1,
                            style: _t(11.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                ),
                _obsDelBtn(a.detail, () {
                  final j = idx(dx);
                  if (j < 0) return;
                  final o = _ndxStore[p.hn]![j];
                  _ndxStore[p.hn]![j] = _Ndx(o.dx, o.eval, [
                    for (final x in o.acts)
                      if (!identical(x, a)) x
                  ]);
                }),
              ]),
            ),
          ),
        _dxTiles([
          (Icons.add_rounded, 'เพิ่มกิจกรรม', () => addAct(dx)),
          (
            Icons.edit_outlined,
            'พิมพ์ผล',
            () async {
              final v = await typeText(
                  'การประเมินผล: $dx', n?.eval ?? '', 'ผลหลังให้การพยาบาล');
              if (v != null && mounted) put(dx, eval: v);
            }
          ),
          n == null
              ? (Icons.check_rounded, 'เลือกข้อนี้', () => put(dx))
              : (Icons.delete_outline_rounded, 'ลบข้อนี้', () => remove(dx)),
        ]),
      ]);
    }

    // การ์ด (แบบการ์ดปัจจัยเสี่ยง): ภาพบนซ้าย · เหรียญผลขวาบน · ชื่อ + สถานะ · กาง = ร่อง + กิจกรรม
    Widget card(String dx, bool open, double minH) {
      final i = idx(dx);
      final n = i < 0 ? null : list[i];
      final k = n == null ? null : kindOf(n.eval);
      final status = n == null
          ? 'ยังไม่เลือก'
          : [
              n.eval.isEmpty ? 'ยังไม่ประเมิน' : n.eval,
              if (n.acts.isNotEmpty) 'กิจกรรม ${n.acts.length}',
            ].join(' · ');
      return Builder(
        builder: (cardCtx) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _ndxOpen = open ? null : dx);
            if (!open) {
              Future.delayed(const Duration(milliseconds: 420), () {
                if (!cardCtx.mounted || _ndxOpen != dx) return;
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
              // เลือกข้อนี้แล้ว = ขอบกรมท่า
              color: _panel,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                  color: n != null
                      ? _blue.withValues(alpha: 0.55)
                      : const Color(0xFFDADCE0),
                  width: n != null ? 1.2 : 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: 72.0,
                      height: 72.0,
                      child: Image.asset(_ndxArt(dx),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium),
                    ),
                    const Spacer(),
                    if (k != null)
                      KeyedSubtree(
                        key: ValueKey('ndx-st-$dx-${n!.eval}'),
                        child: _PeStatusPop(
                            delay: Duration.zero,
                            child: _PeBadge25D(kind: k, size: 30.0)),
                      )
                    else if (n != null)
                      _obsCoin(Icons.check_rounded, true),
                  ]),
                  const SizedBox(height: 8.0),
                  Text(dx,
                      maxLines: open ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: n == null ? _ink3 : _blue,
                          weight: FontWeight.w500)),
                  const SizedBox(height: 10.0),
                  if (open) ...[
                    track(dx, n?.eval ?? ''),
                    openBody(dx),
                  ],
                ]),
          ),
        ),
      );
    }

    // การ์ดเพิ่มข้อ: ขนาด/โครงเดียวกับการ์ดข้อวินิจฉัย · ช่องภาพ = วงฟ้าอ่อนมี + · ขอบเส้นประบอกว่ากดแล้วได้การ์ดใหม่
    Widget addCard(double minH) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: addCustom,
          child: CustomPaint(
            foregroundPainter: const _NdxDashBorder(),
            child: Container(
              constraints: BoxConstraints(minHeight: minH),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FD),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Container(
                        width: 72.0,
                        height: 72.0,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE2EAF8), shape: BoxShape.circle),
                        child: const Icon(Icons.add_rounded,
                            size: 36.0, color: _blue),
                      ),
                    ]),
                    const SizedBox(height: 8.0),
                    Text('เพิ่มข้อวินิจฉัย',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(15.0, color: _blue, weight: FontWeight.w700)),
                    Text('แตะเพื่อพิมพ์ข้อที่ไม่มีในรายการ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ),
        );

    // ความสูงการ์ด: ปิด 150 · กาง = + ร่อง 82 + ผลที่พิมพ์ + กิจกรรม + แถวปุ่ม
    double hOf(String dx) {
      if (dx == addKey || _ndxOpen != dx) return 150.0;
      final i = idx(dx);
      final n = i < 0 ? null : list[i];
      final free = n != null && n.eval.isNotEmpty && kindOf(n.eval) == null;
      return 150.0 +
          82.0 +
          (free ? 46.0 : 0.0) +
          10.0 +
          (n?.acts.length ?? 0) * actH +
          74.0;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 12.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('วินิจฉัยทางการพยาบาล',
                  style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 2.0),
              Text(
                  list.isEmpty
                      ? 'แตะการ์ดเพื่อเลือกข้อและประเมินผล'
                      : 'เลือกแล้ว ${list.length} ข้อ · แตะการ์ดเพื่อประเมินผลหรือเพิ่มกิจกรรม',
                  style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
      // วางกริดเอง (แบบปัจจัยเสี่ยง/AIS): กางแล้วทุกการ์ดเลื่อนตำแหน่งไปพร้อมกัน
      LayoutBuilder(builder: (context, box) {
        const gap = 10.0;
        final full = box.maxWidth;
        final half = (full - gap) / 2;
        const dur = Duration(milliseconds: 380);
        const crv = Curves.easeInOutCubic;
        final rects = <String, Rect>{};
        var y = 0.0, col = 0;
        var rowH = 0.0;
        for (final dx in cards) {
          final h = hOf(dx);
          if (_ndxOpen == dx) {
            if (col == 1) {
              y += rowH + gap;
              col = 0;
              rowH = 0.0;
            }
            rects[dx] = Rect.fromLTWH(0.0, y, full, h);
            y += h + gap;
          } else {
            rects[dx] = Rect.fromLTWH(col == 0 ? 0.0 : half + gap, y, half, h);
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
            for (final dx in cards)
              AnimatedPositioned(
                key: ValueKey('ndx-card-$dx'),
                duration: dur,
                curve: crv,
                left: rects[dx]!.left,
                top: rects[dx]!.top,
                width: rects[dx]!.width,
                height: rects[dx]!.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minHeight: 0.0,
                    maxHeight: double.infinity,
                    child: dx == addKey
                        ? addCard(rects[dx]!.height)
                        : card(dx, _ndxOpen == dx, rects[dx]!.height),
                  ),
                ),
              ),
          ]),
        );
      }),
    ]);
  }
}

/// ขอบเส้นประของการ์ดเพิ่มข้อวินิจฉัย (มุม 18 เท่าการ์ดอื่น)
class _NdxDashBorder extends CustomPainter {
  const _NdxDashBorder();

  @override
  void paint(Canvas c, Size s) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          (Offset.zero & s).deflate(0.75), const Radius.circular(18.0)));
    final paint = Paint()
      ..color = _blue.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10.0) {
        c.drawPath(m.extractPath(d, math.min(d + 6.0, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_NdxDashBorder old) => false;
}
