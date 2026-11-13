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

/// กิจกรรมทางพยาบาลที่ติดตามเป็นรอบ: ตั้งค่าของตัวเอง (จำนวนรอบ ระยะห่าง หมายเหตุ) + บันทึกแต่ละครั้ง
class _ObsAct {
  _ObsAct(this.name, {required this.rounds, required this.every})
      : start = DateTime.now();

  String name;
  int rounds;

  /// ระยะห่างแต่ละรอบ (นาที)
  int every;
  String note = '';

  /// แบบฟอร์มบันทึกผล = ชุดสำเร็จรูปของ Form Builder (_soFormPresets) · ว่าง = พิมพ์ผลอย่างเดียว
  String formName = '';
  List<_MField> form = [];

  /// เวลาของรอบแรก = บันทึกครั้งแรก (ยังไม่บันทึก = ตอนเพิ่มกิจกรรม)
  DateTime start;

  /// บันทึกแต่ละครั้ง (เก่า → ใหม่): เวลาที่ทำ · ผลการสังเกตอาการ
  final List<(TimeOfDay, String)> recs = [];

  /// เพิ่งบันทึกครบทุกรอบ: การ์ดแผนทางซ้ายเล่นแสงสำเร็จครั้งเดียว แล้วล้างค่า
  bool cheer = false;

  int get left => (rounds - recs.length).clamp(0, rounds);
  double get progress =>
      rounds <= 0 ? 0.0 : (recs.length / rounds).clamp(0.0, 1.0);
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
    // บันทึกเดิมไม่มีตั้งค่ากิจกรรม: รวมตามชื่อกิจกรรม (จำนวนรอบ = เท่าที่บันทึก)
    for (final (t, x) in o.acts) {
      final i = x.indexOf(': ');
      final name = i < 0 ? x : x.substring(0, i);
      var a = plan.where((a) => a.name == name).firstOrNull;
      if (a == null) {
        plan.add(a = _ObsAct(name, rounds: 0, every: 60));
        a.start = DateTime(o.at.year, o.at.month, o.at.day, t.hour, t.minute);
      }
      a.recs.add((t, i < 0 ? '' : x.substring(i + 2)));
      a.rounds = a.recs.length;
    }
    syncActs();
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

  /// กิจกรรมพยาบาล: เวลาที่ทำ · สิ่งที่ทำ (สร้างจาก [log] ตอนบันทึก)
  final List<(TimeOfDay, String)> acts = [];

  /// กิจกรรมที่ติดตาม (ลำดับที่เพิ่ม)
  final List<_ObsAct> plan = [];

  /// เขียน [acts] ใหม่จากบันทึกของทุกกิจกรรม · มีผล = "กิจกรรม: ผล"
  void syncActs() {
    acts
      ..clear()
      ..addAll([
        for (final a in plan)
          for (final (t, x) in a.recs) (t, x.isEmpty ? a.name : '${a.name}: $x')
      ]);
  }

  /// ช่วงของงาน: เริ่มแล้ว (กด เริ่มสังเกตอาการ) · กลับไปแก้รับเข้า · กำลังบันทึกรอบ · ช่วงจบ
  bool started = false;

  bool composing = false;
  bool ending = false;

  /// หน้าในเมนูย่อยสรุปผล: 0 ผลการสังเกตอาการ · 1 หมายเหตุ · 2 วินิจฉัยทางการพยาบาล
  int endPg = 0;

  /// หน้าสรุปก่อนบันทึกของเมนูย่อยปัจจุบัน (ท้าย stepper)
  bool reviewing = false;

  /// อยู่ขั้นรอบการสังเกต (แยกจากขั้นเฝ้าดู)
  bool inRounds = false;

  /// หน้ากิจกรรมที่เปิดอยู่ (null = หน้ารายการกิจกรรม)
  int? actIdx;

  /// บันทึกครั้งนี้ของกิจกรรมที่เปิด: เวลาที่ทำ · ผลการสังเกตอาการ
  TimeOfDay? recAt;

  /// หน้ากิจกรรม: การ์ดตั้งค่าเปิดดูแล้ว (เปิดหน้า = หุบ เห็นจาง ๆ + ปุ่มแสดง)
  bool showSet = false;

  /// แตะการ์ดกิจกรรมในแท็บซ้าย = ขอเปิดหน้ากิจกรรมนี้ในแผงขวา (ทำตอน build ของ _obsFlow)
  int? openReq;
  final recNote = TextEditingController();

  /// ค่าที่กรอกในแบบฟอร์ม (ชื่อช่อง → ค่า) · V/S ใช้ช่องชุดเดียวกับคัดกรอง (_triCtl)
  final Map<String, String> recVals = {};

  /// คืนค่าของหน้าคัดกรอง (V/S Pain GCS รูม่านตา) ที่ค้างไว้ก่อนเปิดฟอร์มกิจกรรม · null = ไม่ได้ยืม
  VoidCallback? triUndo;

  /// เวลาของกิจกรรมถัดไปที่จะเพิ่ม (ตั้งต้น = ตอนเปิดฟอร์ม)
  TimeOfDay actAt = TimeOfDay.now();
  final actInput = TextEditingController();

  /// เรียงตามเวลา (เช้า → สาย)
  List<(TimeOfDay, String)> get actsSorted => [...acts]..sort((a, b) =>
      (a.$1.hour * 60 + a.$1.minute).compareTo(b.$1.hour * 60 + b.$1.minute));

  bool hasAct(String s) => acts.any((a) => a.$2 == s);

  List<String> get missing => [
        // กันแค่บันทึกเปล่า: ยังไม่มีกิจกรรมเลย · สร้างกิจกรรมไว้ยังไม่ประเมิน = บันทึกได้
        if (plan.isEmpty && acts.isEmpty) 'กิจกรรมพยาบาล',
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
    recNote.dispose();
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

/// กิจกรรมพยาบาลที่ใช้บ่อยระหว่างสังเกตอาการ (แผ่นเลือกกิจกรรม แบ่งหมวด)
const List<(String, List<String>)> _obsActCats = [
  (
    'ประเมิน',
    [
      'วัดสัญญาณชีพทุก 15 นาที',
      'ประเมินระดับความปวด',
      'ประเมินระดับความรู้สึกตัว (GCS)',
    ]
  ),
  (
    'ดูแล',
    [
      'จัดท่านอนศีรษะสูง 30 องศา',
      'ให้ออกซิเจนตามแผนการรักษา',
      'ดูแลให้สารน้ำทางหลอดเลือดดำ',
    ]
  ),
  ('เฝ้าระวัง', ['เฝ้าระวังอาการแพ้ยา']),
];

/// แท็บบันทึกสังเกตอาการ (เมนู "อื่น ๆ" ของหน้าผู้ป่วย)
const int _obsTab = 16;

/// นาฬิกานับเวลาสังเกตอาการ (ทุก 30 วินาที) · broadcast: หลายวิดเจ็ตฟังพร้อมกันได้ระหว่างเปลี่ยนหน้า
final Stream<void> _obsTick =
    Stream<void>.periodic(const Duration(seconds: 30)).asBroadcastStream();

/// ทิศเปลี่ยนหน้าของฟอร์ม Observe ในแผง workflow (true = ไปข้างหน้า)
bool _obsFwd = true;

/// แท็บ Observe ซ้าย: กิจกรรมที่กางบันทึกทุกรอบอยู่ (ชื่อกิจกรรม)
final Set<String> _obsRecOpen = {};

/// แท็บแฟ้มในแท็บ Observe ซ้าย: 0 สังเกตอาการ · 1 วินิจฉัยทางการพยาบาล
int _obsFolderTab = 0;

/// การ์ดแผนของกิจกรรม (ชื่อ) ไว้เลื่อนมาให้เห็นตอนเปิดบันทึกกิจกรรมนั้นในแผงขวา
final Map<String, GlobalKey> _obsCardKeys = {};

/// หน้าของฟอร์ม Observe (ชื่อใน stepper) · ต่อท้ายด้วยหน้าสรุป
const List<String> _obsPages = ['ข้อมูลการรับเข้า', 'กิจกรรมพยาบาล'];

/// เมนูย่อยของ Observe ในรางขวา (แบบอุบัติเหตุ): 0 สังเกตอาการ (stepper รับเข้า → กิจกรรม) · 1 สรุปผล
const List<String> _obsRailSubs = ['สังเกตอาการ', 'พยาบาลวินิจฉัย'];

/// stepper ของเมนูย่อยสรุปผล (หนึ่งหน้าหนึ่งเรื่อง ตามหัวข้อในหน้าแนะนำ)
const List<String> _obsEndPages = ['วินิจฉัย'];

/// เมนูย่อยที่เลือกอยู่ในราง (0 สังเกตอาการ · 1 สรุปผล) · หน้าแนะนำของขั้นแสดงหัวข้อของเมนูย่อยนี้
final ValueNotifier<int> _obsRailSub = ValueNotifier(0);

/// หัวข้อในหน้าแนะนำของแต่ละเมนูย่อย (ลำดับเดียวกับ _obsRailSubs) · design rule P4: ทุกขั้นย่อยมีหน้าแนะนำ
const _obsSubIntro = <List<(String, String)>>[
  [
    ('ข้อมูลการรับเข้า', 'เวลาเริ่ม ที่สังเกตอาการ และแพทย์ผู้สั่ง'),
    (
      'กิจกรรมทางพยาบาล',
      'เพิ่มกิจกรรมที่ต้องติดตาม ตั้งรอบ แล้วบันทึกผลแต่ละครั้ง'
    ),
  ],
  [
    (
      'วินิจฉัยทางการพยาบาล',
      'ข้อวินิจฉัย ข้อมูลสนับสนุน เป้าหมาย กิจกรรม และการประเมินผล'
    ),
  ],
];

/// แตะเมนูย่อยในราง: ขอให้ฟอร์มไปเมนูย่อยนี้ · รับแล้วล้างเป็น null
final ValueNotifier<int?> _obsRailGo = ValueNotifier(null);

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

  /// ตารางรอบของกิจกรรม: รอบแรก = เริ่ม แล้วทุก [_ObsAct.every] นาที ครบ [_ObsAct.rounds] รอบ
  /// บันทึกลงช่องตามลำดับ (ครั้งที่ 1 = ช่องแรก) · คืน (เวลาในตาราง, เวลาที่ทำจริง หรือ null)
  List<(DateTime, DateTime?)> _obsActPlan(_ObsAct a) {
    final s = a.start;
    final done = [
      for (final (t, _) in a.recs)
        DateTime(s.year, s.month, s.day, t.hour, t.minute)
    ]..sort();
    return [
      for (var k = 0; k < a.rounds || k < done.length; k++)
        (
          s.add(Duration(minutes: a.every * k)),
          k < done.length ? done[k] : null
        )
    ];
  }

  /// ค่าตั้งต้นของกิจกรรมใหม่: ตามคำสั่ง Observe ของแพทย์ (ความถี่ · ชั่วโมง ÷ ความถี่) ไม่มีคำสั่ง = ทุก 1 ชม. 4 รอบ
  _ObsAct _obsNewAct(_P p, String name) {
    final ord = _obsOrders[p.hn];
    final every = ord?.everyMin ?? 60;
    final a = _ObsAct(name,
        rounds: ord == null ? 4 : (ord.hours * 60 ~/ every).clamp(1, 48),
        every: every);
    // แบบฟอร์มตั้งต้นเดาจากชื่อกิจกรรม เช่น ปวด = Pain score
    final g = _obsGuessForm(name);
    final hit = _obsFormPresets.where((x) => x.$1 == g).firstOrNull;
    if (hit != null) {
      a
        ..formName = hit.$1
        ..form = hit.$3();
    }
    return a;
  }

  /// แบบฟอร์มที่เลือกได้สำหรับกิจกรรมพยาบาล (ไม่รวมฟอร์มการให้ยา/หัตถการของคำสั่งแพทย์)
  List<(String, String, List<_MField> Function())> get _obsFormPresets => [
        for (final x in _soFormPresets)
          if (x.$1 != 'การให้ยา' && x.$1 != 'หัตถการ') x
      ];

  /// พรีวิวหน้าบันทึกของแบบฟอร์ม (แตะไม่ได้): เวลาที่ทำ + ช่องของฟอร์ม + ช่องพิมพ์ผล แบบเดียวกับหน้ากิจกรรม
  /// V/S Pain Neuro วาดแถวนิ่งแทนการ์ดคัดกรองจริง (การ์ดจริงมี GlobalKey ซ้ำกับหน้ากิจกรรมที่เปิดอยู่)
  Widget _obsFormPreview(String name) {
    final preset = _obsFormPresets.where((x) => x.$1 == name).firstOrNull;
    Widget row(String l, String ph) =>
        _procRow(l, null, placeholder: ph, onTap: () {});
    final form = <Widget>[
      if (name == 'สัญญาณชีพ')
        for (final l in const [
          'ความดันโลหิต',
          'อัตราการเต้นหัวใจ',
          'การหายใจ',
          'อุณหภูมิ',
          'ออกซิเจนในเลือด',
        ])
          row(l, 'ยังไม่วัด')
      else if (name == 'Neuro sign')
        for (final l in const [
          'ความรู้สึกตัว',
          'การลืมตา (E)',
          'การพูด (V)',
          'การเคลื่อนไหว (M)',
          'รูม่านตา',
        ])
          row(l, 'ยังไม่ประเมิน')
      else if (name == 'Pain score') ...[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(height: 1.0, color: _line),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text('Pain score',
                    style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
              ),
              Text('ยังไม่ระบุ',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12.0),
            _PainFaceSlider(value: null, quiet: true, onChanged: (_) {}),
          ]),
        ),
      ] else if (preset != null)
        for (final (i, f) in preset.$3().indexed) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
            child: Divider(height: 1.0, color: _line),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
            child: _mFieldView(f, <String, String>{}, (_) {},
                preview: true, key: 'obspv$i'),
          ),
        ],
    ];
    return IgnorePointer(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _procRow('เวลาที่ทำ', null,
            first: true, placeholder: 'เลือกเวลา', onTap: () {}),
        ...form,
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          constraints: const BoxConstraints(minHeight: 96.0),
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(preset == null ? 'ผลการสังเกตอาการ' : 'รายละเอียดเพิ่มเติม',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
            const SizedBox(height: 6.0),
            Text('หากมีโปรดระบุ',
                style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  /// แบบฟอร์มที่เดาจากชื่อกิจกรรม (ชุดเดียวกับการเดาฟอร์มของคำสั่งแพทย์) เช่น ปวด = Pain score · ไม่เข้า = ''
  String _obsGuessForm(String name) =>
      _obsFormPresets
          .where((x) => RegExp(x.$2).hasMatch(name.toLowerCase()))
          .firstOrNull
          ?.$1 ??
      '';

  /// แผ่นเลือกพร้อมพรีวิวหน้าบันทึก: ซ้าย = รายการเป็นกลุ่ม (แตะ = ดูพรีวิว) · ขวา = พรีวิวแบบฟอร์มของรายการนั้น
  /// items = (ค่า, ชื่อที่แสดง, แบบฟอร์ม) · taken = เลือกไปแล้ว (จาง แตะไม่ได้) · [onCustom] = ปุ่มข้อความล่างซ้าย
  Future<void> _obsPickSheet({
    required String title,
    required String sub,
    required List<(String?, List<(String, String, String)>)> groups,
    required String? initial,
    required String cta,
    required void Function(String) onPick,
    String? current,
    Set<String> taken = const {},
    String? customLabel,
    VoidCallback? onCustom,
  }) {
    final all = [for (final g in groups) ...g.$2];
    var sel = initial ??
        all.where((x) => !taken.contains(x.$1)).firstOrNull?.$1 ??
        '';
    return _placedSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 760.0),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final cur = all.where((x) => x.$1 == sel).firstOrNull;
        Widget item((String, String, String) x) {
          final (v, l, f) = x;
          final on = v == sel;
          final used = taken.contains(v);
          return Opacity(
            opacity: used ? 0.45 : 1.0,
            // ripple: วาดบน Material ของแถวเอง (พื้นเลือกอยู่ = Ink ใต้ ripple ไม่ทับ)
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: used
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        set(() => sel = v);
                      },
                borderRadius: BorderRadius.circular(12.0),
                splashColor: _blue.withValues(alpha: 0.12),
                highlightColor: _blue.withValues(alpha: 0.06),
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 10.0, 12.0),
                  decoration: BoxDecoration(
                    color: on ? _blue.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l,
                                style: _t(15.0,
                                    color: on ? _blue : _inkTitle,
                                    weight: on
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                            // บรรทัดรอง = ชื่อแบบฟอร์ม (เฉพาะรายการกิจกรรม ที่ชื่อต่างจากฟอร์ม)
                            if (f.isNotEmpty && f != l)
                              Text(f,
                                  style: _t(12.5,
                                      color: _ink3, weight: FontWeight.w500)),
                          ]),
                    ),
                    if (used)
                      Text('เลือกแล้ว',
                          style:
                              _t(12.5, color: _ink2, weight: FontWeight.w600))
                    else if (v == current)
                      Text('ใช้อยู่',
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          );
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: SizedBox(
            height: math.min(600.0, MediaQuery.of(ctx).size.height * 0.75),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 22.0, 12.0, 12.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: _t(22.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              Text(sub,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(13.0,
                                      color: _ink3, weight: FontWeight.w500)),
                            ]),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: _ink2)),
                    ]),
                  ),
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 260.0,
                            child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                    12.0, 0.0, 4.0, 12.0),
                                children: [
                                  for (final (gi, (g, xs))
                                      in groups.indexed) ...[
                                    if (g != null)
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(12.0,
                                            gi == 0 ? 0.0 : 12.0, 0.0, 4.0),
                                        child: Text(g,
                                            style: _t(13.0,
                                                color: _ink3,
                                                weight: FontWeight.w600)),
                                      ),
                                    for (final x in xs) item(x),
                                  ],
                                ]),
                          ),
                          // พรีวิว: เล่าเรื่องแบบตัวสร้างฟอร์ม Standing order (_SoIntro + _soCameraIn)
                          // จอจำลอง → พยาบาลแตะ → แผงเปิด → กล้องซูมเข้าหน้าบันทึก · แตะ = ข้ามไปท้าย · เปลี่ยนรายการ = เล่าใหม่
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(
                                  4.0, 0.0, 16.0, 0.0),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: _cyBgTop,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: KeyedSubtree(
                                key: ValueKey('obspv-$sel'),
                                child: _SoIntro(builder: (anim) {
                                  final nm = cur?.$2 ?? 'กิจกรรม';
                                  return Stack(children: [
                                    Positioned.fill(
                                      top: 28.0,
                                      child: _soCameraIn(
                                        anim,
                                        nm,
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: _panel,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 14.0, 8.0, 8.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        8.0, 0.0, 8.0, 4.0),
                                                    child: Text(
                                                        cur == null ||
                                                                cur.$3.isEmpty
                                                            ? 'พิมพ์ผลอย่างเดียว'
                                                            : cur.$3,
                                                        style: _t(13.0,
                                                            color: _ink3,
                                                            weight: FontWeight
                                                                .w600)),
                                                  ),
                                                  _obsFormPreview(
                                                      cur?.$3 ?? ''),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8.0,
                                      left: 12.0,
                                      right: 12.0,
                                      child: _soCamCaption(anim, nm),
                                    ),
                                  ]);
                                }),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                    child: Row(children: [
                      if (onCustom != null) ...[
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onCustom();
                          },
                          icon: const Icon(Icons.edit_rounded,
                              size: 18.0, color: _blue),
                          label: Text(customLabel ?? 'เพิ่มเอง',
                              style: _t(15.0,
                                  color: _blue, weight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12.0),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: cur == null
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  onPick(sel);
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            minimumSize: const Size.fromHeight(52.0),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(cta,
                              style: _t(16.0,
                                  color: Colors.white,
                                  weight: FontWeight.w600)),
                        ),
                      ),
                    ]),
                  ),
                ]),
          ),
        );
      }),
    );
  }

  /// สถานะของกิจกรรม: บันทึกล่าสุด • ต้องติดตามอีก N ครั้ง
  String _obsActStatus(_ObsAct a) => [
        a.recs.isEmpty
            ? 'ยังไม่ได้บันทึก'
            : 'บันทึกล่าสุด ${_obsHm(a.recs.last.$1).replaceAll('.', ':')} น.',
        a.left == 0 ? 'ครบแล้ว' : 'ต้องติดตามอีก ${a.left} ครั้ง',
      ].join(' • ');

  /// แผนรอบของกิจกรรมพยาบาล (แท็บ Observe ซ้าย) แบบการ์ดประวัติคำสั่งแพทย์:
  /// เหรียญสถานะหน้าสุด (รอ · ถัดไป · ครบ) · ชื่อ + ระยะห่าง จำนวนรอบ แบบฟอร์ม · แถบรอบเต็มกว้าง
  /// ใต้แถบ = ผลที่บันทึกแต่ละครั้ง (ใหม่อยู่บน) พับแบบดูรายการ
  /// กิจกรรมที่กำลังบันทึกอยู่ในแผงขวา = ชื่อกรมท่า + shimmer + badge ดินสอ (ชุดเดียวกับหน้าคำสั่งแพทย์)
  Widget _obsPlanView(_P p) => StreamBuilder(
      stream: _obsTick,
      builder: (context, _) {
        final d = _obsDraftOf(p);
        if (d.plan.isEmpty) {
          return Text('ยังไม่มีกิจกรรมที่ติดตาม',
              style: _t(14.0, color: _ink3, weight: FontWeight.w500));
        }
        final now = DateTime.now();
        final who = d.editing?.by ?? ErSession.instance.user?.name ?? 'พยาบาล';
        String every(int m) =>
            m % 60 == 0 ? 'ทุก ${m ~/ 60} ชั่วโมง' : 'ทุก $m นาที';
        String hm(TimeOfDay t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // เรียงแบบหน้าคำสั่งแพทย์: ที่ต้องทำก่อนอยู่บน (เลยเวลา/ถึงรอบถัดไปเร็วสุด) · ครบแล้วลงล่าง
              // ai = ลำดับจริงใน d.plan (ใช้กับโฟกัส/เปิดหน้ากิจกรรม)
              for (final (ai, a) in [...d.plan.indexed]..sort((x, y) {
                  DateTime? next(_ObsAct a) =>
                      _obsActPlan(a).where((r) => r.$2 == null).firstOrNull?.$1;
                  final nx = next(x.$2), ny = next(y.$2);
                  if ((nx == null) != (ny == null)) return nx == null ? 1 : -1;
                  if (nx == null || ny == null) return x.$1.compareTo(y.$1);
                  final c = nx.compareTo(ny);
                  return c != 0 ? c : x.$1.compareTo(y.$1);
                }))
                Builder(builder: (context) {
                  final plan = _obsActPlan(a);
                  final late = [
                    for (final x in plan)
                      if (x.$2 == null && !x.$1.isAfter(now)) x
                  ];
                  final done = [
                    for (final (_, did) in plan)
                      if (did != null) (who, did)
                  ];
                  final up = [
                    for (final (t, did) in plan)
                      if (did == null) t
                  ];
                  final complete = plan.isNotEmpty && up.isEmpty;
                  final focus = d.actIdx == ai;
                  final open = _obsRecOpen.contains(a.name);
                  // ผลแต่ละครั้ง: ครั้งที่ 1 อยู่บน (ตามแถบรอบซ้ายไปขวา) · หัว = ครั้งที่ (ซ้าย) เวลา ผู้บันทึก (ขวา)
                  // ค่าทีละแถว ชื่อซ้าย ค่าขวา: "Pain score 3" → Pain score | 3 (ตัดที่คำแรกที่ขึ้นต้นด้วยตัวเลข)
                  // ระดับความรู้สึกตัว → ความรู้สึกตัว | ตื่นดี · ข้อความอิสระ → รายละเอียด | ข้อความ
                  (String, String) kv(String x) {
                    final w = x.split(' ');
                    final i =
                        w.indexWhere((t) => RegExp(r'^[0-9]').hasMatch(t));
                    if (i > 0) {
                      return (w.take(i).join(' '), w.skip(i).join(' '));
                    }
                    if (_triLocOpts.contains(x)) return ('ความรู้สึกตัว', x);
                    return ('รายละเอียด', x);
                  }

                  Widget line(String l, String v, {bool head = false}) =>
                      Padding(
                        padding: EdgeInsets.only(top: head ? 0.0 : 4.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l,
                                  style: head
                                      ? _t(13.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w600)
                                      : _t(13.0,
                                          color: _ink2,
                                          weight: FontWeight.w500)),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(v,
                                    textAlign: TextAlign.right,
                                    style: head
                                        ? _t(12.0,
                                            color: _ink3,
                                            weight: FontWeight.w500)
                                        : _t(13.0,
                                            color: _inkTitle,
                                            height: 1.35,
                                            weight: FontWeight.w600)),
                              ),
                            ]),
                      );

                  Widget rec(int k) {
                    final (t, x) = a.recs[k];
                    final parts = [
                      for (final s in x.split(', '))
                        if (s.trim().isNotEmpty) kv(s.trim())
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // หัว = ครั้งที่ · ทุกค่ามีป้ายกำกับ ชื่อซ้าย ค่าขวา (เวลาที่ทำ ผู้ทำ แล้วผล)
                            Text('ครั้งที่ ${k + 1}',
                                style: _t(13.0,
                                    color: _inkTitle, weight: FontWeight.w600)),
                            line('เวลาที่ทำ', hm(t)),
                            line('ผู้ทำ', who),
                            if (parts.isEmpty)
                              line('รายละเอียด', '-')
                            else
                              for (final (l, v) in parts) line(l, v),
                          ]),
                    );
                  }

                  // แตะการ์ด = เปิดหน้ากิจกรรมนี้ในแผงขวา (ขั้น Observe) เพื่อบันทึก/แก้ไข · ripple ตอนกด
                  final obsStep =
                      _steps.indexWhere((x) => x.$2 == 'สังเกตอาการ');
                  final canKey = ErSession.instance.isNurse && obsStep >= 0;
                  void openRec() {
                    HapticFeedback.selectionClick();
                    _openSpeech(step: obsStep);
                    setState(() {
                      _uiIdx = 1;
                      d.openReq = ai;
                    });
                  }

                  return Container(
                    // key เฉพาะการ์ดที่โฟกัส (แบบหน้าคำสั่งแพทย์) · หน้าซ้ายมีสองชุดระหว่างเปลี่ยนหน้า = key ซ้ำ
                    key: focus
                        ? _obsCardKeys.putIfAbsent(a.name, GlobalKey.new)
                        : null,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: _panel,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(
                            color: Color(0xFFDADCE0), width: 0.5),
                      ),
                      child: InkWell(
                        onTap: !canKey || focus ? null : openRec,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
                          child: Stack(children: [
                            // แสงสำเร็จกวาดซ้ายไปขวาครั้งเดียว ตอนเพิ่งบันทึกครบ (ใต้เนื้อหา)
                            if (a.cheer)
                              Positioned.fill(
                                child: _SoSuccessSweep(
                                    key: ValueKey('obs-cheer-${a.name}'),
                                    fresh: true,
                                    fromLeft: true),
                              ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 0.0, 12.0, 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // เหรียญสถานะ: ครบ = เขียว ✓ · เริ่มแล้ว = ฟ้า นาฬิกา · ยังไม่เริ่ม = เทา
                                          SizedBox.square(
                                            dimension: 36.0,
                                            child: FittedBox(
                                              child: complete
                                                  ? const _SoStatusCoin.done()
                                                  : a.recs.isNotEmpty
                                                      ? const _SoStatusCoin
                                                          .next()
                                                      : const _SoStatusCoin
                                                          .wait(),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AnimatedDefaultTextStyle(
                                                    duration: const Duration(
                                                        milliseconds: 240),
                                                    style: _t(14.0,
                                                        color: focus
                                                            ? _blue
                                                            : _inkTitle,
                                                        weight:
                                                            FontWeight.w600),
                                                    child: focus
                                                        ? _SoFocusShimmer(
                                                            key: ValueKey(
                                                                'obs-fs-${a.name}'),
                                                            child: Text(a.name))
                                                        : Text(a.name),
                                                  ),
                                                  Text(
                                                      [
                                                        every(a.every),
                                                        '${a.rounds} รอบ',
                                                        a.formName.isEmpty
                                                            ? 'พิมพ์ผล'
                                                            : a.formName,
                                                      ].join(' • '),
                                                      style: _t(12.5,
                                                          color: _ink3,
                                                          weight:
                                                              FontWeight.w500)),
                                                ]),
                                          ),
                                          const SizedBox(width: 8.0),
                                          // มุมขวาบนแบบการ์ดหน้าคำสั่งแพทย์: กำลังบันทึกในแผงขวา = badge ดินสอ
                                          // ไม่ใช่ = ⋮ (เปิดบันทึกในแผงขวา เหมือนแตะการ์ด) · สถานะดูจากเหรียญและแถบรอบ
                                          if (focus)
                                            const _SoEditBadge(editing: true)
                                          else if (canKey)
                                            SizedBox(
                                              width: 32.0,
                                              height: 32.0,
                                              child: IconButton(
                                                onPressed: openRec,
                                                padding: EdgeInsets.zero,
                                                tooltip: 'ตัวเลือก',
                                                icon: const Icon(
                                                    Icons.more_vert_rounded,
                                                    size: 20.0,
                                                    color: _ink2),
                                              ),
                                            ),
                                        ]),
                                  ),
                                  if (plan.isNotEmpty)
                                    // ไม่เกิน 5 รอบ = ไม่เลื่อน: เว้นซ้ายขวา 16 เท่าตอนเลื่อน (แถบไม่ชนขอบการ์ด)
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          plan.length <= 5 ? 16.0 : 0.0,
                                          0.0,
                                          plan.length <= 5 ? 16.0 : 0.0,
                                          8.0),
                                      child: _soRoundTrack(done, up,
                                          col: late.isEmpty ? _blue : _red,
                                          bleed: 0.0),
                                    ),
                                  // ผลที่บันทึกแต่ละรอบ (ครั้งที่ 1 อยู่บน) · ยาวเกิน = พับแบบดูรายการ
                                  if (a.recs.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 0.0, 16.0, 8.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Divider(
                                                height: 1.0, color: _line),
                                            const SizedBox(height: 4.0),
                                            _soFoldBox(
                                              open: open,
                                              peek: 132.0,
                                              more: 'ดูบันทึกทั้งหมด',
                                              less: 'ซ่อนบันทึก',
                                              onToggle: () => setState(() =>
                                                  open
                                                      ? _obsRecOpen
                                                          .remove(a.name)
                                                      : _obsRecOpen
                                                          .add(a.name)),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    for (var k = 0;
                                                        k < a.recs.length;
                                                        k++) ...[
                                                      rec(k),
                                                      if (k < a.recs.length - 1)
                                                        const Divider(
                                                            height: 1.0,
                                                            color: _line),
                                                    ],
                                                  ]),
                                            ),
                                          ]),
                                    ),
                                ]),
                          ]),
                        ),
                      ),
                    ),
                  );
                }),
            ]);
      });

  /// การ์ดข้อวินิจฉัยในแท็บ Observe ซ้าย (แบบการ์ดกิจกรรมพยาบาล / การ์ดคำสั่งแพทย์):
  /// เหรียญสถานะ · ชื่อข้อ + เนื่องจาก · ⋮ = เปิดข้อนี้ในแผงขวา · กำลังแก้ในแผงขวา = ชื่อกรมท่า + badge ดินสอ
  /// แถวชื่อซ้าย ค่าขวา: ข้อมูลสนับสนุน เป้าหมาย การประเมินผล · กิจกรรมการพยาบาล (เวลา ผู้ทำ)
  Widget _ndxLeftCard(_P p, _Ndx n) {
    final d = _obsDraftOf(p);
    final obsStep = _steps.indexWhere((x) => x.$2 == 'สังเกตอาการ');
    final canKey = ErSession.instance.isNurse && obsStep >= 0;
    final focus = d.ending && _ndxOpen == n.dx && _speechOpen;
    void open() {
      HapticFeedback.selectionClick();
      _openSpeech(step: obsStep);
      _obsRailSub.value = 1;
      _obsRailGo.value = 11;
      setState(() {
        _uiIdx = 1;
        _ndxOpen = n.dx;
      });
    }

    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
    Widget line(String l, String v, {bool empty = false}) => Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: _t(13.0,
                      color: empty ? _ink3 : _inkTitle,
                      height: 1.35,
                      weight: empty ? FontWeight.w500 : FontWeight.w600)),
            ),
          ]),
        );
    final evalText = [
      if (n.eval.isNotEmpty) n.eval,
      if (n.evalNote.isNotEmpty) n.evalNote,
    ].join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: _panel,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
        child: InkWell(
          onTap: !canKey || focus ? null : open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ประเมินผลแล้ว = เขียว ✓ · มีกิจกรรม = ฟ้า นาฬิกา · ยังไม่เริ่ม = เทา
                    SizedBox.square(
                      dimension: 36.0,
                      child: FittedBox(
                        child: n.evalNote.isNotEmpty || n.eval.isNotEmpty
                            ? const _SoStatusCoin.done()
                            : n.acts.isNotEmpty
                                ? const _SoStatusCoin.next()
                                : const _SoStatusCoin.wait(),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 240),
                              style: _t(14.0,
                                  color: focus ? _blue : _inkTitle,
                                  weight: FontWeight.w600),
                              child: focus
                                  ? _SoFocusShimmer(
                                      key: ValueKey('ndx-fs-${n.dx}'),
                                      child: Text(n.dx))
                                  : Text(n.dx),
                            ),
                            Text(
                                n.cause.isEmpty
                                    ? 'ยังไม่ระบุสาเหตุ'
                                    : 'เนื่องจาก${n.cause}',
                                style: _t(12.5,
                                    color: _ink3, weight: FontWeight.w500)),
                          ]),
                    ),
                    const SizedBox(width: 8.0),
                    if (focus)
                      const _SoEditBadge(editing: true)
                    else if (canKey)
                      SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: IconButton(
                          onPressed: open,
                          padding: EdgeInsets.zero,
                          tooltip: 'ตัวเลือก',
                          icon: const Icon(Icons.more_vert_rounded,
                              size: 20.0, color: _ink2),
                        ),
                      ),
                  ]),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 4.0),
                    child: Divider(height: 1.0, color: _line),
                  ),
                  line('ข้อมูลสนับสนุน',
                      n.support.isEmpty ? 'ยังไม่ได้กรอก' : n.support,
                      empty: n.support.isEmpty),
                  line('เป้าหมาย', n.goal.isEmpty ? 'ยังไม่ได้กรอก' : n.goal,
                      empty: n.goal.isEmpty),
                  line('การประเมินผล',
                      evalText.isEmpty ? 'ยังไม่ประเมิน' : evalText,
                      empty: evalText.isEmpty),
                  // กิจกรรมการพยาบาล: แถวละครั้ง เวลา (ซ้าย) รายละเอียด + ผู้ทำ (ขวา)
                  if (n.acts.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text('กิจกรรมการพยาบาล',
                        style: _t(13.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    for (final a in n.acts)
                      line(hm(a.at), '${a.detail}\n${a.by}'),
                  ],
                ]),
          ),
        ),
      ),
    );
  }

  /// ฟอร์มของผู้ป่วยรายนี้: บันทึกแล้ว = ค่าที่บันทึก · ยังไม่บันทึก = ว่าง (สถานที่ตั้งต้น ER · เตียงตามผู้ป่วย)
  _ObsDraft _obsDraftOf(_P p) => _obsDrafts.putIfAbsent(p.hn, () {
        final o = _obsRec[p.hn];
        if (o != null) return _ObsDraft.edit(o);
        // เปิดครั้งแรก = ว่างทุกช่อง ยกเว้นสถานที่ = ห้องฉุกเฉิน (ER) เป็นค่าตั้งต้น
        // เตียง = เตียงปัจจุบันของผู้ป่วย (มีอยู่แล้วไม่ต้องเลือกซ้ำ)
        return _ObsDraft()
          ..place = _masterNames('er_observe_place')
              .where((s) => s.contains('(ER)'))
              .firstOrNull
          ..bed = (p.bed ?? '').isEmpty ? null : p.bed;
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
      'รอบประเมินและกิจกรรมทางพยาบาล',
      'nurse_act',
      o == null
          ? const []
          : [
              // ชื่อช่องชุดเดียวกับหน้ารับเข้าในแผงขวา · สถานะ/เวลาออกจากห้อง อยู่ที่ขั้นจำหน่าย (ไม่ซ้ำ)
              (
                'ข้อมูลการรับเข้า',
                [
                  ('เริ่มสังเกตอาการ', _fmtDateTime(o.at), false),
                  ('สถานที่', val(o.place), false),
                  ('ห้อง', val(o.room), false),
                  ('เตียง', val(o.bed), false),
                  ('แพทย์ผู้สั่ง', val(o.orderBy), false),
                ]
              ),
            ],
      // ภาพหัวหน้า = ภาพพยาบาลดูแลผู้ป่วย ชุดเดียวกับการ์ดกิจกรรมทางพยาบาลในแผงขวา
      heroArt: Image.asset('assets/images/er_ov_resus_fig.png',
          filterQuality: FilterQuality.medium),
      // ยังไม่มีบันทึก = ไม่มีบรรทัดผู้บันทึก
      by: o?.by ?? '-',
      at: o == null ? '' : _fmtDateTime(o.at),
      extra: [
        // แฟ้มแท็บแบบประวัติคำสั่งแพทย์ (One Day | Continuation): สังเกตอาการ | วินิจฉัย (ตามเมนูย่อยในรางขวา)
        _soDeckFolder([
          (
            'สังเกตอาการ',
            _obsDrafts[p.hn]?.plan.length,
            () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // การ์ดกิจกรรมวางตรงในแฟ้มเลย (แบบการ์ดคำสั่งในแฟ้มคำสั่งแพทย์) ไม่มีการ์ดหุ้ม
                      if (_obsDrafts[p.hn]?.started ?? false) _obsPlanView(p),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 72.0,
                                      child: Text('${_obsHm(t)} น.',
                                          style: _num(13.5,
                                              color: _blue,
                                              weight: FontWeight.w700)),
                                    ),
                                    Expanded(child: body(s)),
                                  ]),
                            ),
                        ]),
                      if (o != null && o.note.isNotEmpty)
                        textCard('หมายเหตุ', [body(o.note)]),
                    ]),
          ),
          (
            'วินิจฉัย',
            ndx.length,
            () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final n in ndx) _ndxLeftCard(p, n),
                    ]),
          ),
        ],
            // วงบนแท็บ = ความคืบหน้า: รอบที่บันทึกแล้ว / รอบทั้งหมด · ข้อที่ประเมินผลแล้ว / ข้อทั้งหมด
            prog: {
              'สังเกตอาการ': () {
                final pl = _obsDrafts[p.hn]?.plan ?? const <_ObsAct>[];
                final all = pl.fold<int>(0, (s, a) => s + a.rounds);
                final done = pl.fold<int>(
                    0, (s, a) => s + a.recs.length.clamp(0, a.rounds));
                return all == 0 ? 0.0 : done / all;
              }(),
              'วินิจฉัย': ndx.isEmpty
                  ? 0.0
                  : ndx
                          .where(
                              (n) => n.evalNote.isNotEmpty || n.eval.isNotEmpty)
                          .length /
                      ndx.length,
            },
            tab: (
              () => _obsFolderTab,
              (i) => _obsFolderTab = i
            )),
      ],
    );
  }

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

  /// แถวระยะห่างการสังเกตอาการ (ตั้งค่าของกิจกรรม) · แผ่นชุดเดียวกับหน้าสั่งยา (_soFilterSheet)
  /// กำหนดเอง = แผ่นตัวเลขนาที
  Widget _obsEveryRow(int every, void Function(int) onSet,
      {String label = 'ระยะห่างการสังเกตอาการ', bool first = false}) {
    void ss(VoidCallback f) => setState(f);
    String everyTh(int m) =>
        m % 60 == 0 ? 'ทุก ${m ~/ 60} ชั่วโมง' : 'ทุก $m นาที';
    // แผ่นความถี่ชุดเดียวกับหน้าสั่งยา (_soFilterSheet): หมวดซ้าย ค้นหา กำหนดเองท้ายแผ่น
    const everyOpts = [15, 30, 60, 120, 240, 360, 480, 720];
    Future<void> customEvery() => _soNumSheet(
        title: '$label (ทุกกี่นาที)',
        unit: 'นาที',
        max: 240.0,
        initial: '$every',
        onDone: (v) {
          final n = int.tryParse(v);
          if (n != null && n > 0) ss(() => onSet(n));
        });
    Future<void> pickEvery() => _soFilterSheet(
          title: label,
          sub: 'การสังเกตอาการ',
          cats: [
            (
              'ทุกกี่นาที',
              [
                for (final m in everyOpts)
                  if (m < 60) everyTh(m)
              ]
            ),
            (
              'ทุกกี่ชั่วโมง',
              [
                for (final m in everyOpts)
                  if (m >= 60) everyTh(m)
              ]
            ),
          ],
          current: everyTh(every),
          onPick: (o) =>
              ss(() => onSet(everyOpts.firstWhere((m) => everyTh(m) == o))),
          customLabel: 'กำหนดเอง',
          onCustom: customEvery,
        );

    return _procRow(label, everyTh(every), first: first, onTap: pickEvery);
  }

  Widget _obsAdmitCard() {
    final p = _caseP();
    final d = _obsDraftOf(p);
    // ฟอร์มที่เปิดไว้ก่อนมีค่าตั้งต้นเตียง: เติมเตียงปัจจุบันของผู้ป่วย
    if (d.bed == null && (p.bed ?? '').isNotEmpty) d.bed = p.bed;
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

    // แถวเลือกค่าแบบหน้าสั่งยา: ชื่อช่องซ้าย ค่าขวา › (ไม่มีเหรียญ) · แตะ = รายการของช่องนั้น
    Widget pickRow(String label, String? value, int step) =>
        _procRow(label, value,
            placeholder: 'เลือก$label', onTap: () => pickFlow(step));
    return // ข้อมูลการ Observe: การ์ดซ้อน (ขาว ขอบ 0.5) ไม่มีหัวข้อ · แตะแถว = เลือกค่า
        Container(
      // ล่างเท่าระยะข้าง 8 (การ์ดซ้อนในการ์ด)
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ทุกแถวแบบหน้าสั่งยา (ชื่อซ้าย ค่าขวา › แตะ = แผ่นเลือก): ความถี่ เริ่มครั้งแรก จำนวนรอบ ที่ ผู้สั่ง
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(children: [
            _procRow('เริ่มสังเกตอาการ', d.at == null ? null : hm(d.at!),
                first: true,
                placeholder: 'ทันที',
                onTap: () => pickDt('เริ่มสังเกตอาการ', d.at, (v) => d.at = v)),
            pickRow('สถานที่', d.place, 0),
            pickRow('ห้อง', d.room, 1),
            pickRow('เตียง', d.bed, 2),
            pickRow('แพทย์ผู้สั่ง', d.orderBy, 3),
          ]),
        ),
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
    // stepper 3 ขั้น: start = ข้อมูลการรับเข้า · round = กิจกรรมพยาบาล (รายการ) · end = จบ
    // act = หน้ากิจกรรม (หน้าย่อยของกิจกรรมพยาบาล มี breadcrumb แทน stepper)
    // ≥ 10 = กดเริ่มกรอกที่หน้าแนะนำ: ไปหน้าแรกของเมนูย่อย (k - 10) ทันที
    if (_obsRailGo.value case final k? when k >= 10) {
      _obsRailGo.value = null;
      d.actIdx = null;
      d.reviewing = false;
      d.ending = k == 11;
      d.composing = false;
      d.endPg = 0;
      if (k == 11) {
        d.at ??= DateTime.now();
        d.started = true;
      }
    }
    final phase = d.actIdx != null
        ? 'act'
        : d.reviewing
            ? 'review'
            : d.ending
                ? 'end'
                : d.composing
                    ? 'round'
                    : 'start';

    void ss(VoidCallback f) => setState(() {
          f();
          d.error = null;
        });

    void save() {
      _wfSaveBurst(_obsRailSubs[d.ending ? 1 : 0],
          atFull: () {
            _obsSave(p, quiet: true);
            setState(() => _speechDone.add(_speechStep));
          },
          onClose: () {
            // แผงซ้ายเปิดหน้าสังเกตอาการ (แบบบันทึกอุบัติเหตุ)
            setState(() => _detailTab = _obsTab);
            _closeSpeech();
          },
          onView: () => setState(() => _detailTab = _obsTab));
    }

    // ---- ชิ้นส่วนการ์ด
    Widget gap(Widget w) =>
        Padding(padding: const EdgeInsets.only(bottom: 12.0), child: w);

    // ---- 3 ช่วงตามงานหน้างานจริง: รับเข้า → เฝ้าดูเป็นรอบ → จบ (ไม่ใช่ฟอร์มกรอกรวดเดียว)
    // รับเข้า = ยืนยันเวลา ที่ ผู้สั่ง (ชิปแนะนำ แตะเพื่อใช้ ไม่เลือกให้ล่วงหน้า)
    // เฝ้าดู = นับเวลา + รอบถัดไป + ไทม์ไลน์รอบ · ปุ่มหลักเดียว "บันทึกรอบนี้"
    // ผลลัพธ์/เวลาออกจากห้อง = ขั้นจำหน่าย · วินิจฉัยเป็นเมนูย่อยแยก

    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
    String hmT(TimeOfDay t) => '${_obsHm(t).replaceAll('.', ':')} น.';

    const order = ['start', 'round', 'act', 'end', 'review'];
    // ฟอร์ม V/S Pain score Neuro sign = การ์ดชุดเดียวกับหน้าคัดกรอง (ใช้ค่าชุดเดียวกัน)
    // เปิดหน้ากิจกรรม = เก็บค่าคัดกรองไว้แล้วล้าง · ออกจากหน้ากิจกรรม = คืนค่า
    const triForms = {'สัญญาณชีพ', 'Pain score', 'Neuro sign'};
    const vsKeys = ['sbp', 'dbp', 'hr', 'rr', 'bt', 'spo2', 'gcs'];
    void vsTake() {
      if (d.triUndo != null) return;
      final vs = {for (final k in vsKeys) k: _triCtl(k).text};
      final pain = _triPain, e = _triE, v = _triV, m = _triM, loc = _triLoc;
      final pupil = {..._triPupil};
      final link = _triPupilLink;
      d.triUndo = () {
        for (final k in vsKeys) {
          _triCtl(k).text = vs[k] ?? '';
        }
        _triPain = pain;
        _triE = e;
        _triV = v;
        _triM = m;
        _triLoc = loc;
        _triPupil
          ..clear()
          ..addAll(pupil);
        _triPupilLink = link;
      };
      for (final k in vsKeys) {
        _triCtl(k).text = '';
      }
      _triPain = null;
      _triE = _triV = _triM = _triLoc = null;
      _triPupil.clear();
      _triPupilLink = true;
    }

    void vsRestore() {
      d.triUndo?.call();
      d.triUndo = null;
    }

    void to(String ph, VoidCallback f) {
      HapticFeedback.selectionClick();
      if (phase == 'act' && ph != 'act') vsRestore();
      FocusManager.instance.primaryFocus?.unfocus();
      // เปลี่ยนหน้า = เริ่มบนสุด: stepper ที่หุบตอนเลื่อนหน้าก่อนกลับมาแสดง
      _hxStepAcc = 0.0;
      _hxStepHidden.value = false;
      setState(() {
        _obsFwd = order.indexOf(ph) >= order.indexOf(phase);
        f();
        d.error = null;
      });
    }

    // ---- กิจกรรมทางพยาบาล: รายการกิจกรรม → หน้ากิจกรรม (บันทึกครั้งนี้ + ตั้งค่า)

    void openAct(int i) => to('act', () {
          d.composing = true;
          // เปิดจากการ์ดซ้ายระหว่างอยู่หน้าสรุป/สรุปผล = กลับเข้าเมนูย่อยสังเกตอาการ
          d.reviewing = false;
          d.ending = false;
          d.actIdx = i;
          d.recAt = null;
          d.showSet = false;
          d.recNote.clear();
          d.recVals.clear();
          if (triForms.contains(d.plan[i].formName)) vsTake();
          // แท็บซ้าย: เลื่อนการ์ดของกิจกรรมนี้ขึ้นชิดบน (แบบโฟกัสคำสั่งแพทย์)
          final name = d.plan[i].name;
          Future<void>.delayed(const Duration(milliseconds: 360), () {
            final c = _obsCardKeys[name]?.currentContext;
            if (c != null && c.mounted) _soScrollCardTop(c);
          });
        });

    // รางขวา: เมนูย่อยที่เลือกตามหน้าปัจจุบัน · แตะเมนูย่อย = สลับหน้า (หลังเฟรมนี้)
    if (_obsRailSub.value != (d.ending ? 1 : 0)) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _obsRailSub.value = d.ending ? 1 : 0);
    }
    if (_obsRailGo.value case final k?) {
      _obsRailGo.value = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (k == 1 && !d.ending) {
          to('end', () {
            d.reviewing = false;
            d.actIdx = null;
            d.composing = false;
            d.at ??= DateTime.now();
            d.started = true;
            d.ending = true;
            d.endPg = 0;
          });
        } else if (k == 0 && d.ending) {
          to('start', () {
            d.ending = false;
            d.reviewing = false;
          });
        }
      });
    }

    // แตะการ์ดกิจกรรมในแท็บซ้าย: เปิดหน้ากิจกรรมนั้นหลังเฟรมนี้ (ไม่ setState ระหว่าง build)
    if (d.openReq case final i?) {
      d.openReq = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && i < d.plan.length && d.actIdx != i) {
          vsRestore();
          openAct(i);
        }
      });
    }

    // เพิ่มกิจกรรมใหม่: แผ่นเลือก (กิจกรรมที่ใช้บ่อย + เพิ่มเอง) แล้วเปิดหน้ากิจกรรมนั้น
    void addNew(String name) {
      d.plan.add(_obsNewAct(p, name));
      openAct(d.plan.length - 1);
    }

    // แต่ละกิจกรรมแสดงแบบฟอร์มที่จะใช้ + พรีวิวหน้าบันทึก ก่อนเพิ่ม
    Future<void> pickNew() => _obsPickSheet(
          title: 'เพิ่มกิจกรรมใหม่',
          sub: 'กิจกรรมทางพยาบาล',
          groups: [
            for (final (g, xs) in _obsActCats)
              (g, [for (final x in xs) (x, x, _obsGuessForm(x))])
          ],
          initial: null,
          cta: 'เพิ่มกิจกรรมนี้',
          taken: {for (final a in d.plan) a.name},
          onPick: addNew,
          customLabel: 'เพิ่มเอง',
          onCustom: () async {
            final v = await _ftOpen(context,
                title: 'กิจกรรม',
                crumb: 'กิจกรรมทางพยาบาล',
                inWorkflow: true,
                initial: '',
                hint: 'สิ่งที่ทำ เช่น ติดตามอาการแพ้ยา Amoxil');
            final t = v?.replaceAll('\n', ' ').trim() ?? '';
            if (t.isNotEmpty && mounted) addNew(t);
          },
        );

    // บันทึกหน้ากิจกรรม: มีเวลาหรือผล = เพิ่มบันทึกครั้งนี้ (ไม่เลือกเวลา = ตอนนี้) · ตั้งค่าเก็บทันทีที่แก้
    void saveAct() {
      final a = d.plan[d.actIdx!];
      // ผลที่บันทึก = ค่าจากแบบฟอร์ม (ชื่อ ค่า หน่วย) ตามด้วยข้อความที่พิมพ์
      String vs(String k) => _triCtl(k).text.trim();
      final vsMap = {
        'BP': vs('sbp').isEmpty || vs('dbp').isEmpty
            ? ''
            : '${vs('sbp')}/${vs('dbp')}',
        'HR': vs('hr'),
        'RR': vs('rr'),
        'BT': vs('bt'),
        'SpO₂': vs('spo2'),
      };
      const vsUnit = {
        'BP': ' mmHg',
        'HR': '/min',
        'RR': '/min',
        'BT': ' °C',
        'SpO₂': '%'
      };
      final hasVs = a.formName == 'สัญญาณชีพ';
      int? sc(String? x) => x == null || x.startsWith('C')
          ? null
          : int.tryParse(x.substring(1, 2));
      final ge = sc(_triE), gv = sc(_triV), gm = sc(_triM);
      String pupil(String side) => [
            if (_triPupil[side] != null) '${_triPupil[side]} mm',
            if (_triPupil['${side}r'] != null) _triPupil['${side}r']!,
          ].join(' ');
      final parts = <String>[
        if (hasVs)
          for (final e in vsMap.entries)
            if (e.value.isNotEmpty) '${e.key} ${e.value}${vsUnit[e.key]}',
        if (a.formName == 'Pain score' && _triPain != null)
          'Pain score $_triPain',
        if (a.formName == 'Neuro sign') ...[
          if (_triLoc != null) _triLoc!,
          if (ge != null && gv != null && gm != null)
            'GCS ${ge + gv + gm} (E$ge V$gv M$gm)',
          if (pupil('R').isNotEmpty) 'รูม่านตาขวา ${pupil('R')}',
          if (pupil('L').isNotEmpty) 'รูม่านตาซ้าย ${pupil('L')}',
        ],
        for (final f in a.form)
          if (triForms.contains(a.formName))
            ...[]
          else if ((d.recVals[f.label] ?? '').trim().isNotEmpty)
            '${f.label} ${d.recVals[f.label]!.trim()}'
                '${f.unit.isEmpty ? '' : ' ${f.unit}'}',
        if (d.recNote.text.trim().isNotEmpty) d.recNote.text.trim(),
      ];
      final note = parts.join(', ');
      to('round', () {
        if (d.recAt != null || note.isNotEmpty) {
          final t = d.recAt ?? TimeOfDay.now();
          // V/S จากกิจกรรมลงกราฟสัญญาณชีพของเคสด้วย (แบบรับคำสั่งวัด V/S)
          if (hasVs && vsMap.values.any((v) => v.isNotEmpty)) {
            final n = DateTime.now();
            _taskVsToCase(
                vsMap, DateTime(n.year, n.month, n.day, t.hour, t.minute));
          }
          if (a.recs.isEmpty) {
            final n = DateTime.now();
            a.start = DateTime(n.year, n.month, n.day, t.hour, t.minute);
          }
          a.recs.add((t, note));
          // ครบทุกรอบด้วยบันทึกนี้ = success feedback (เสียงยืนยัน + สั่น + แสงบนการ์ดแผน)
          if (a.left == 0) {
            a.cheer = true;
            // แสงเล่นจบ (1.4 วิ) แล้วไม่เล่นซ้ำเมื่อกลับมาหน้านี้
            Future.delayed(const Duration(seconds: 2), () => a.cheer = false);
            ErFeedback.confirm();
            HapticFeedback.mediumImpact();
          }
          d.syncActs();
          d.at ??= DateTime.now();
          d.started = true;
        }
        d.actIdx = null;
      });
      _obsSave(p, quiet: true);
    }

    // ---- กิจกรรมทางพยาบาล (บันทึกรอบ): checklist ต่อจากรอบก่อน · แตะ = ทำแล้ว (ลงเวลาให้)
    // ไม่มีช่องเวลาที่ดูผู้ป่วย/อาการแยก: เวลารอบ = กิจกรรมแรก · อาการ = ผลของแต่ละกิจกรรม
    // วงแหวนความคืบหน้าของกิจกรรม (ทำแล้ว/จำนวนรอบ) · ครบ = เขียว (ขั้นที่ทำครบ) · ยังไม่ครบ = กรมท่า
    Widget ring(_ObsAct a) => SizedBox(
          width: 48.0,
          height: 48.0,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: a.progress,
                strokeWidth: 6.0,
                backgroundColor: const Color(0xFFE2EAF8),
                color: a.left == 0 ? _green : _blue,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${(a.progress * 100).round()}%',
                style: _num(11.5,
                    color: a.left == 0 ? _green : _blue,
                    weight: FontWeight.w700)),
          ]),
        );

    // ---- รายการกิจกรรม: ปุ่มเพิ่มกิจกรรมใหม่ + แถวกิจกรรม (วงแหวน ชื่อ สถานะ ›)
    Widget roundPage() => gap(_dxCard(
          'กิจกรรมทางพยาบาล',
          'กิจกรรมที่ติดตามเป็นรอบ และผลการสังเกตแต่ละครั้ง',
          // ภาพหัวการ์ด: พยาบาลดูแลผู้ป่วย (ไม่มีพื้นหลัง) ขอบล่างจาง
          Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 8.0, 12.0, 10.0),
            child: _dxArtFade(Image.asset('assets/images/er_ov_resus_fig.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                filterQuality: FilterQuality.medium)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _dxTiles([(Icons.edit_note_rounded, 'เพิ่มกิจกรรมใหม่', pickNew)]),
            for (final (i, a) in d.plan.indexed)
              _gListRow(
                first: i == 0,
                inset: 8.0,
                lead: ring(a),
                title: a.name,
                sub: _obsActStatus(a),
                onTap: () => openAct(i),
                trail: const Icon(Icons.chevron_right_rounded,
                    size: 22.0, color: _ink3),
              ),
          ]),
        ));

    // ---- หน้ากิจกรรม: บันทึกครั้งนี้ (เวลาที่ทำ + ผล) · ตั้งค่าการสังเกตอาการ
    Widget actPage() {
      final a = d.plan[d.actIdx!];
      Future<void> editName() async {
        final v = await _ftOpen(context,
            title: 'ชื่อกิจกรรมทางพยาบาล',
            crumb: a.name,
            inWorkflow: true,
            initial: a.name,
            hint: 'เช่น ติดตามอาการแพ้ยา Amoxil');
        final t = v?.replaceAll('\n', ' ').trim() ?? '';
        if (t.isNotEmpty && mounted) ss(() => a.name = t);
      }

      Future<void> editNote() async {
        final v = await _ftOpen(context,
            title: 'หมายเหตุการสังเกตอาการ',
            crumb: a.name,
            inWorkflow: true,
            initial: a.note,
            hint: 'เช่น หากพบการแพ้ให้หยุดการให้ยาและแจ้งแพทย์');
        if (v != null && mounted) ss(() => a.note = v.trim());
      }

      Future<void> remove() async {
        if (!await _wfTextConfirmDelete(a.name,
                heading: 'ลบกิจกรรม ${a.name}?',
                sub: a.recs.isEmpty
                    ? 'กิจกรรมนี้จะหายจากรายการ'
                    : 'บันทึก ${a.recs.length} ครั้งของกิจกรรมนี้จะหายไปด้วย',
                action: 'ลบ') ||
            !mounted) {
          return;
        }
        to('round', () {
          d.plan.remove(a);
          d.syncActs();
          d.actIdx = null;
        });
      }

      // แถวตั้งค่าของกิจกรรม (ใช้ทั้งตอนกาง และเป็นภาพเบลอตอนหุบ)
      final settings =
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _procRow('ชื่อกิจกรรม', a.name, first: true, onTap: editName),
        // แบบฟอร์มบันทึกผล: ชุดสำเร็จรูปของ Form Builder · ไม่ใช้ = พิมพ์ผลอย่างเดียว
        _procRow('แบบฟอร์ม', a.formName.isEmpty ? null : a.formName,
            placeholder: 'พิมพ์ผลอย่างเดียว',
            onTap: () => _obsPickSheet(
                  title: 'แบบฟอร์มบันทึกผล',
                  sub: a.name,
                  groups: [
                    (
                      null,
                      [
                        ('', 'ไม่ใช้แบบฟอร์ม', ''),
                        for (final x in _obsFormPresets) (x.$1, x.$1, x.$1),
                      ]
                    )
                  ],
                  initial: a.formName,
                  current: a.formName,
                  cta: 'ใช้แบบฟอร์มนี้',
                  // เปลี่ยนแบบฟอร์ม = ช่องกรอกเปลี่ยนทั้งชุด ค่าที่กรอกครั้งนี้หาย → ถามก่อน
                  onPick: (o) async {
                    if (o == a.formName) return;
                    String nm(String f) => f.isEmpty ? 'พิมพ์ผลอย่างเดียว' : f;
                    if (!await _wfTextConfirmDelete(nm(o),
                            heading: 'เปลี่ยนแบบฟอร์มเป็น ${nm(o)}?',
                            sub: 'ช่องกรอกจะเปลี่ยนจาก ${nm(a.formName)} '
                                'และค่าที่กรอกไว้ในครั้งนี้จะหายไป '
                                'บันทึกครั้งก่อน ๆ ยังอยู่ครบ',
                            action: 'เปลี่ยน',
                            icon: Icons.swap_horiz_rounded) ||
                        !mounted) {
                      return;
                    }
                    ss(() {
                      final x =
                          _obsFormPresets.where((x) => x.$1 == o).firstOrNull;
                      a
                        ..formName = x?.$1 ?? ''
                        ..form = x?.$3() ?? [];
                      d.recVals.clear();
                      d.recNote.clear();
                      // ค่าที่ยืมจากหน้าคัดกรอง: คืนก่อน แล้วยืมใหม่แบบว่าง (ไม่ค้างค่าของฟอร์มเดิม)
                      vsRestore();
                      if (triForms.contains(a.formName)) vsTake();
                    });
                  },
                )),
        _obsEveryRow(a.every, (m) => a.every = m, label: 'ระยะห่าง'),
        _procRow('จำนวนรอบ', '${a.rounds} รอบ',
            onTap: () => _soNumSheet(
                title: 'จำนวนรอบการสังเกตอาการ',
                unit: 'รอบ',
                max: 48.0,
                initial: '${a.rounds}',
                onDone: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0) ss(() => a.rounds = n);
                })),
        _procRow('หมายเหตุ', a.note.isEmpty ? null : a.note,
            placeholder: 'เพิ่มหมายเหตุ', valueLines: 1, onTap: editNote),
        const SizedBox(height: 8.0),
        // ลบกิจกรรม: ปุ่ม tonal แดงจาง เต็มกว้าง (แบบหน้าแก้หัตถการ)
        TextButton.icon(
          onPressed: remove,
          style: TextButton.styleFrom(
            foregroundColor: _red,
            backgroundColor: _red.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            minimumSize: const Size(0.0, 48.0),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
          label: Text('ลบกิจกรรมนี้',
              style: _t(14.0, color: _red, weight: FontWeight.w600)),
        ),
        const SizedBox(height: 8.0),
      ]);

      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        gap(_dxCard(
          a.name,
          // subtitle = คำอธิบายคงที่ของการ์ด (สถานะอยู่ที่แถวในหน้ารายการ)
          'เวลาที่ทำ และผลการสังเกตอาการครั้งนี้',
          const SizedBox.shrink(),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _procRow('เวลาที่ทำ', d.recAt == null ? null : hmT(d.recAt!),
                first: true, placeholder: 'เลือกเวลา', onTap: () async {
              final v = await _obsPickTime(d.recAt ?? TimeOfDay.now(),
                  title: 'เวลาที่ทำ');
              if (v != null && mounted) ss(() => d.recAt = v);
            }),
            // V/S Pain score Neuro sign = การ์ดเดียวกับหน้าคัดกรอง (ไม่มีหัว วางในแผงแคบ)
            if (triForms.contains(a.formName)) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 0.0, 8.0, a.formName == 'Pain score' ? 12.0 : 0.0),
                child: const Divider(height: 1.0, color: _line),
              ),
              Padding(
                // V/S Neuro = แถวเรียบ (_procRow มีระยะ 8 ในตัว) · Pain = เว้น 8 เอง
                padding: a.formName == 'Pain score'
                    ? const EdgeInsets.symmetric(horizontal: 8.0)
                    : EdgeInsets.zero,
                child: Builder(builder: (_) {
                  final flat = _qFlat;
                  _qCardNarrow = true;
                  _qFlat = true;
                  _qVsPlain = true;
                  final card = switch (a.formName) {
                    'Pain score' =>
                      _triPainCard((_, __) => const SizedBox.shrink()),
                    'Neuro sign' => _triNeuroCard(),
                    _ => _triAssessCards().first,
                  };
                  _qVsPlain = false;
                  _qFlat = flat;
                  _qCardNarrow = false;
                  // บันทึกใหม่ = วิดเจ็ตใหม่ (แถบ Pain ไม่ค้างตำแหน่งของครั้งก่อน)
                  return KeyedSubtree(
                      key: ValueKey('obs-rec-${d.actIdx}-${a.recs.length}'),
                      child: card);
                }),
              ),
            ] else
              // ฟอร์มอื่นของ Form Builder: ช่องเดียวกับหน้ารับคำสั่งแพทย์ คั่นด้วยเส้น
              for (final (i, f) in a.form.indexed) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
                  child: Divider(height: 1.0, color: _line),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
                  child: _mFieldView(f, d.recVals, (g) => setState(g),
                      key: 'obs${d.actIdx}|$i'),
                ),
              ],
            // ผลการสังเกตอาการ: ช่องพิมพ์พื้นเทาอ่อนในการ์ด (แบบหน้าแก้หัตถการ)
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 8.0),
              constraints: const BoxConstraints(minHeight: 140.0),
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        a.form.isEmpty
                            ? 'ผลการสังเกตอาการ'
                            : 'รายละเอียดเพิ่มเติม',
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: d.recNote,
                      minLines: 4,
                      maxLines: 10,
                      style: _t(14.5,
                          color: _inkTitle,
                          weight: FontWeight.w500,
                          height: 1.45),
                      decoration: InputDecoration.collapsed(
                          hintText: 'หากมีโปรดระบุ',
                          hintStyle:
                              _t(14.0, color: _ink3, weight: FontWeight.w500)),
                    ),
                  ]),
            ),
          ]),
        )),
        // ตั้งค่าครั้งเดียวตอนสร้าง บันทึกทุกรอบไม่ต้องเห็น: หุบ = การ์ดขาวล้วน
        // ไอคอน หัว คำอธิบาย และปุ่ม "แก้ไขข้อมูลการสังเกตอาการ" กลางการ์ด · กดแล้วเป็นการ์ดตั้งค่าเต็ม
        gap(AnimatedSize(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: d.showSet
              ? _dxCard(
                  'ตั้งค่าการสังเกตอาการ',
                  'แบบฟอร์ม ระยะห่าง จำนวนรอบ และหมายเหตุของกิจกรรมนี้',
                  const SizedBox.shrink(),
                  settings,
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  // ขอบวาดทับบนสุด: หมอกขาวไม่กลบเส้นขอบ มุมโค้งต่อเนื่อง
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border:
                        Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                  ),
                  child: Stack(children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3E5E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined,
                                size: 24.0, color: _inkTitle),
                          ),
                          const SizedBox(height: 12.0),
                          Text('ตั้งค่าการสังเกตอาการ',
                              textAlign: TextAlign.center,
                              style: _t(17.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          const SizedBox(height: 4.0),
                          Text(
                              'ข้อมูลการสังเกตอาการถูกกำหนดไว้เมื่อพยาบาลคนแรกเริ่มสร้างกิจกรรมพยาบาลนี้',
                              textAlign: TextAlign.center,
                              style: _t(13.0,
                                  color: _ink2,
                                  height: 1.35,
                                  weight: FontWeight.w500)),
                          const SizedBox(height: 14.0),
                          _Press(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ss(() => d.showSet = true);
                              },
                              child: Container(
                                height: 44.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F4),
                                  borderRadius: BorderRadius.circular(100.0),
                                  border: Border.all(
                                      color: const Color(0xFFDADCE0)),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('แก้ไขข้อมูลการสังเกตอาการ',
                                          style: _t(14.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w600))
                                    ]),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
        )),
      ]);
    }

    // ช่องที่ขาดของเมนูย่อยปัจจุบัน: (ชื่อ, ไปหน้านั้น) · สังเกตอาการ = มีกิจกรรมอย่างน้อย 1 กิจกรรม
    // (สร้างไว้ยังไม่ได้ประเมินก็บันทึกได้ เช่น ตั้งแผนรอบไว้ให้เวรถัดไป)
    // พยาบาลวินิจฉัย = ข้อวินิจฉัยอย่างน้อย 1 ข้อ
    final reviewMiss = <(String, VoidCallback)>[
      if (!d.ending && d.plan.isEmpty)
        (
          'กิจกรรมพยาบาล',
          () => to('round', () {
                d.reviewing = false;
                d.composing = true;
              })
        ),
      if (d.ending && (_ndxStore[p.hn] ?? const <_Ndx>[]).isEmpty)
        ('ข้อวินิจฉัย', () => to('end', () => d.reviewing = false)),
    ];

    // ---- สรุปก่อนบันทึก (ท้าย stepper ของทุกเมนูย่อย · design rule P4) แบบหน้าสรุปขั้นย่อยของอุบัติเหตุ
    // แถว = ชื่อซ้าย ค่าขวา · แตะแถว = กลับไปแก้หน้านั้น · ว่าง = ป้ายเทา "ยังไม่ได้กรอก"
    Widget reviewPage() {
      Widget row(String k, String? val, VoidCallback go) {
        final ok = (val ?? '').trim().isNotEmpty;
        return InkWell(
          onTap: go,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 130.0,
                child: Text(k,
                    style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ok
                      ? Text(val!.trim(),
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
                  const SizedBox(height: 4.0),
                  ...rows,
                ]),
          );

      void back(String ph, VoidCallback f) => to(ph, () {
            d.reviewing = false;
            f();
          });
      void goStart() => back('start', () => d.composing = false);
      void goRound() => back('round', () => d.composing = true);
      final ndx = _ndxStore[p.hn] ?? const <_Ndx>[];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('สรุปก่อนบันทึก',
            style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
        const SizedBox(height: 2.0),
        // ขาด = บอกจำนวนสีกรมท่า (ไม่ใช้แดง) แบบหน้าสรุปของอุบัติเหตุ · ปุ่มหลัก = ไปช่องที่ขาด
        Text(
            reviewMiss.isEmpty
                ? 'ตรวจทานข้อมูล${_obsRailSubs[d.ending ? 1 : 0]} กดย้อนกลับหรือแตะรายการเพื่อแก้'
                : 'ยังขาด ${reviewMiss.length} ช่อง แตะรายการเพื่อกรอก',
            style: _t(12.5,
                color: reviewMiss.isEmpty ? _ink3 : _blue,
                weight: FontWeight.w500)),
        const SizedBox(height: 16.0),
        if (!d.ending) ...[
          sumCard('ข้อมูลการรับเข้า', [
            row('เริ่มสังเกตอาการ', d.at == null ? null : hm(d.at!), goStart),
            row('สถานที่', d.place, goStart),
            row('ห้อง', d.room, goStart),
            row('เตียง', d.bed, goStart),
            row('แพทย์ผู้สั่ง', d.orderBy, goStart),
          ]),
          sumCard('กิจกรรมทางพยาบาล', [
            if (d.plan.isEmpty) row('กิจกรรม', null, goRound),
            for (final a in d.plan)
              row(
                  a.name,
                  a.recs.isEmpty
                      ? 'ยังไม่ได้บันทึก'
                      : 'ทำแล้ว ${a.recs.length} จาก ${a.rounds} รอบ',
                  goRound),
          ]),
        ] else ...[
          sumCard('วินิจฉัยทางการพยาบาล', [
            if (ndx.isEmpty)
              row('ข้อวินิจฉัย', null, () => back('end', () => d.endPg = 0)),
            for (final x in ndx)
              row(
                  x.cause.isEmpty ? x.dx : '${x.dx} เนื่องจาก${x.cause}',
                  [
                    x.evalNote.isNotEmpty
                        ? x.evalNote
                        : x.eval.isEmpty
                            ? 'ยังไม่ประเมิน'
                            : x.eval,
                    if (x.goal.isEmpty) 'ยังไม่ตั้งเป้าหมาย',
                  ].join(' • '),
                  () => back('end', () => d.endPg = 0)),
          ]),
        ],
      ]);
    }

    // พยาบาลวินิจฉัย: หน้าเดียว (รายการข้อวินิจฉัย → หน้าข้อ)
    Widget endPage() => _ndxSection(p);

    // ---- รับเข้า: ภาพเตียง + การ์ดซ้อนข้อมูลรับเข้า (ใช้ร่วมกับ _obsAdmitCard)
    Widget startPage() => gap(_dxCard(
          'ข้อมูลการรับเข้า',
          'เวลาเริ่ม ที่สังเกตอาการ และแพทย์ผู้สั่ง',
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
      'act' => actPage(),
      'end' => endPage(),
      'review' => reviewPage(),
      _ => startPage(),
    };

    // ปุ่มหลักหนึ่งปุ่มต่อช่วง · ย้อนกลับ = ช่วงก่อนหน้า (รับเข้า = หน้าคำแนะนำ)
    // footer = ตัวควบคุมไปช่วงต่าง ๆ เท่านั้น (ย้อนกลับ | ถัดไป) · ปุ่มบันทึกข้อมูลอยู่ในการ์ด
    // ช่วงจบ = บันทึกทั้งแบบฟอร์ม (ชุดเดียวกับหน้าสุดท้ายของเมนูอื่น)
    // หน้าข้อวินิจฉัย (หน้าย่อยของวินิจฉัย แบบหน้ากิจกรรม): breadcrumb แทน stepper
    final ndxOn = phase == 'end' &&
        _ndxOpen != null &&
        (_ndxStore[p.hn] ?? const <_Ndx>[]).any((n) => n.dx == _ndxOpen);
    void ndxBack() {
      HapticFeedback.selectionClick();
      _hxStepAcc = 0.0;
      _hxStepHidden.value = false;
      setState(() {
        _obsFwd = false;
        _ndxOpen = null;
      });
    }

    // เปลี่ยนหน้าในสรุปผล (stepper ของเมนูย่อย) · เลื่อนหน้าไปทางเดียวกับลำดับ
    void endTo(int i) {
      HapticFeedback.selectionClick();
      FocusManager.instance.primaryFocus?.unfocus();
      _hxStepAcc = 0.0;
      _hxStepHidden.value = false;
      setState(() {
        _obsFwd = i >= d.endPg;
        d.endPg = i;
        d.error = null;
        _ndxOpen = null;
      });
    }

    // แสดงผลวิเคราะห์ AI อยู่ (แบบ AI ช่วยวินิจฉัย): footer = บันทึกลงข้อวินิจฉัย (เลือกผลก่อนจึงกดได้)
    // ย้อนกลับ = ปิดผลวิเคราะห์ กลับเป็นแบบฟอร์ม
    final aiOn = ndxOn && _ndxAiClose != null;
    final aiPicked = aiOn && _ndxAiPicked.contains('${p.hn}|$_ndxOpen');
    final Widget? main = aiOn
        ? _navBtn('บันทึกลงข้อวินิจฉัย', Icons.check_rounded,
            aiPicked ? _ndxAiCommit : null)
        : ndxOn
            // หน้าข้อวินิจฉัย: บันทึก = กลับหน้ารายการ (ค่าเก็บทันทีที่แก้)
            ? _navBtn('บันทึก', Icons.check_rounded, ndxBack)
            : switch (phase) {
                // ข้อมูลการรับเข้า: ถัดไป = เริ่มสังเกตอาการ (ไม่ใส่เวลาเริ่ม = ตอนนี้) แล้วไปกิจกรรมพยาบาล
                'start' => _navBtn('ถัดไป', Icons.chevron_right_rounded, () {
                    to('round', () {
                      d.composing = true;
                      d.at ??= DateTime.now();
                      d.started = true;
                    });
                    _obsSave(p, quiet: true);
                  }, trailing: true),
                // หน้าสุดท้ายของเมนูย่อย = ตรวจทาน (หน้าสรุปก่อนบันทึก) แบบอุบัติเหตุ
                // ผลลัพธ์/เวลาออกจากห้อง ตัดสินที่ขั้นจำหน่าย (ไม่ซ้ำใน Observe)
                'round' => _navBtn('ตรวจทาน', Icons.chevron_right_rounded, () {
                    _obsSave(p, quiet: true);
                    to('review', () => d.reviewing = true);
                  }, trailing: true),
                // สรุป: ครบ = บันทึก · ยังขาด = พาไปช่องที่ขาด (design rule ปุ่มหลัก)
                'review' => reviewMiss.isEmpty
                    ? KeyedSubtree(
                        key: _wfSaveBtnKey,
                        child: _navBtn('บันทึก', Icons.check_rounded, save))
                    : _navBtn('ไปช่องที่ขาด (${reviewMiss.length})',
                        Icons.chevron_right_rounded, reviewMiss.first.$2,
                        trailing: true),
                // หน้ากิจกรรม: บันทึกครั้งนี้ แล้วกลับรายการ
                'act' => _navBtn('บันทึก', Icons.check_rounded, saveAct),
                // สรุปผล: ถัดไปทีละหน้า · หน้าสุดท้าย = บันทึกทั้งแบบฟอร์ม
                _ when d.endPg < _obsEndPages.length - 1 => _navBtn('ถัดไป',
                    Icons.chevron_right_rounded, () => endTo(d.endPg + 1),
                    trailing: true),
                _ => _navBtn('ตรวจทาน', Icons.chevron_right_rounded,
                    () => to('review', () => d.reviewing = true),
                    trailing: true),
              };
    void back() => aiOn
        ? _ndxAiClose!()
        : ndxOn
            ? ndxBack()
            : switch (phase) {
                'round' => to('start', () => d.composing = false),
                // สรุป = กลับหน้าสุดท้ายของเมนูย่อย
                'review' =>
                  to(d.ending ? 'end' : 'round', () => d.reviewing = false),
                'act' => to('round', () => d.actIdx = null),
                'end' when d.endPg > 0 => endTo(d.endPg - 1),
                // หน้าแรกของเมนูย่อยสรุปผล = กลับหน้าแนะนำของสรุปผล (กฎทุกเมนู)
                'end' => setState(() {
                    _obsRailSub.value = 1;
                    _uiIdx = 0;
                  }),
                // ขั้นแรก = กลับหน้าคำแนะนำ (กฎทุกเมนู)
                _ => setState(() => _uiIdx = 0),
              };

    // หน้าพิมพ์ข้อความในแผง (_ftOpen inWorkflow): ทับเนื้อหาของขั้นนี้
    _wfTextRebuild = () {
      if (mounted) setState(() {});
    };
    _wfConfirmDelete = (title) => _wfTextConfirmDelete(title);
    final writing = _wfText;

    // หน้ากิจกรรม = breadcrumb แทน stepper (กิจกรรมพยาบาล / ชื่อกิจกรรม) แตะชื่อแม่ = กลับรายการ
    final body = Column(children: [
      if (phase == 'act')
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
          child: Row(children: [
            _CrumbPrev('กิจกรรมพยาบาล', onTap: back),
            const _CrumbSep(),
            Expanded(
              child: Text(d.plan[d.actIdx!].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        )
      // หน้าข้อวินิจฉัย: วินิจฉัย / ชื่อข้อ (แตะชื่อแม่ = กลับรายการ)
      else if (ndxOn)
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
          child: Row(children: [
            _CrumbPrev('วินิจฉัย', onTap: ndxBack),
            const _CrumbSep(),
            Expanded(
              child: Text(_ndxOpen!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        )
      // สรุปผล = เมนูย่อยแยกในราง มี stepper ของตัวเอง (ผล · หมายเหตุ · วินิจฉัย)
      else if (d.ending)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _hxStepper(
            [
              for (final (i, n) in _obsEndPages.indexed)
                (n, [(_ndxStore[p.hn] ?? const <_Ndx>[]).isNotEmpty][i]),
              // ท้าย stepper = สรุป · เมนูย่อยนี้มีหน้าเดียว: แสดงสรุปเป็นจุดจริง
              // (ชื่อ 'สรุป' = stepper ซ่อนเป็นปลายเส้น เหลือจุดเดียวโดด ๆ)
              (
                'สรุปก่อนบันทึก',
                (_ndxStore[p.hn] ?? const <_Ndx>[]).isNotEmpty
              ),
            ],
            phase == 'review' ? _obsEndPages.length : d.endPg,
            onTap: (i) => i == _obsEndPages.length
                ? to('review', () => d.reviewing = true)
                : phase == 'review'
                    ? to('end', () {
                        d.reviewing = false;
                        d.endPg = i;
                      })
                    : endTo(i),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _hxStepper(
            [
              for (final (i, n) in _obsPages.indexed)
                (n, [d.started, d.plan.isNotEmpty][i]),
              ('สรุป', d.started && d.plan.isNotEmpty),
            ],
            switch (phase) { 'round' => 1, 'review' => 2, _ => 0 },
            onTap: (i) => to(['start', 'round', 'review'][i], () {
              if (i > 0) {
                d.at ??= DateTime.now();
                d.started = true;
              }
              d.composing = i == 1;
              d.reviewing = i == 2;
              d.actIdx = null;
              d.ending = false;
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
                final enter =
                    child.key == ValueKey('obs-page-$phase${d.endPg}$ndxOn');
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
                key: ValueKey('obs-page-$phase${d.endPg}$ndxOn'),
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
  const _Ndx(this.dx, this.eval, this.acts,
      {this.cause = '', this.support = '', this.goal = '', this.evalNote = ''});
  final String dx;
  final String eval;
  final List<_NdxAct> acts;

  /// โครงตามกระบวนการพยาบาล: เนื่องจาก (สาเหตุ) · ข้อมูลสนับสนุน (S/O) · เป้าหมาย/เกณฑ์ · รายละเอียดผล
  final String cause;
  final String support;
  final String goal;
  final String evalNote;

  _Ndx copy(
          {String? eval,
          List<_NdxAct>? acts,
          String? cause,
          String? support,
          String? goal,
          String? evalNote}) =>
      _Ndx(dx, eval ?? this.eval, acts ?? this.acts,
          cause: cause ?? this.cause,
          support: support ?? this.support,
          goal: goal ?? this.goal,
          evalNote: evalNote ?? this.evalNote);
}

/// ค่าตั้งต้นของข้อที่พบบ่อย: (เนื่องจาก, เป้าหมาย/เกณฑ์การประเมินผล) · แก้ได้ทุกช่อง
/// ตัวอย่างตามตำราการพยาบาลฉุกเฉิน ให้ทีมพยาบาล ER ยืนยันก่อนใช้จริง
const Map<String, (String, String)> _ndxDefaults = {
  'ปวดเฉียบพลัน': (
    'เนื้อเยื่อได้รับบาดเจ็บ',
    'ปวดลดลง Pain score ไม่เกิน 3 ภายใน 1 ชั่วโมง'
  ),
  'การแลกเปลี่ยนก๊าซบกพร่อง': (
    'การระบายอากาศและการไหลเวียนเลือดในปอดไม่สมดุล',
    'SpO₂ ตั้งแต่ 95% หายใจ 12–20 ครั้ง/นาที ไม่เหนื่อยหอบ'
  ),
  'เสี่ยงต่อภาวะพร่องสารน้ำ': (
    'สูญเสียสารน้ำจากการอาเจียน ถ่ายเหลว หรือเสียเลือด',
    'ชีพจรไม่เกิน 100 ครั้ง/นาที BP systolic ตั้งแต่ 90 mmHg ปัสสาวะตั้งแต่ 0.5 mL/kg/ชม.'
  ),
  'เสี่ยงต่อการติดเชื้อ': (
    'มีบาดแผลหรือได้รับการทำหัตถการ',
    'ไม่มีไข้ (BT ต่ำกว่า 38 °C) แผลไม่บวมแดง'
  ),
  'เสี่ยงต่อการพลัดตกหกล้ม': (
    'ระดับความรู้สึกตัวลดลง หรือได้รับยาที่มีผลต่อการทรงตัว',
    'ไม่เกิดการพลัดตกหกล้มขณะอยู่ใน ER'
  ),
  'วิตกกังวล': (
    'ไม่คุ้นเคยกับสถานที่และไม่ทราบผลการรักษา',
    'ผู้ป่วยบอกว่าคลายกังวล สีหน้าผ่อนคลาย'
  ),
};

/// ข้อวินิจฉัยทางการพยาบาลต่อ HN (ตามลำดับที่เพิ่ม)
final Map<String, List<_Ndx>> _ndxStore = {};

/// ผล AI วิเคราะห์ข้อวินิจฉัย (HN|ข้อ) ขอครั้งเดียวใช้ทุกช่อง (เนื่องจาก ข้อมูลสนับสนุน เป้าหมาย ประเมินผล)
final Map<String, Future<Map<String, dynamic>?>> _ndxAiCache = {};

/// ปุ่ม AI ในหน้าข้อวินิจฉัย: กำลังวิเคราะห์ (HN|ข้อ)
final Set<String> _ndxAiBusy = {};

/// ผลวิเคราะห์ที่กำลังแสดงเป็นการ์ดข้อเสนอ (HN|ข้อ) · กดใช้ = เติมช่อง · ปิด = ซ่อน
final Map<String, Map<String, dynamic>> _ndxAiShow = {};

/// เลือกผลวิเคราะห์แล้ว (HN|ข้อ) = ปุ่ม footer "บันทึกลงข้อวินิจฉัย" กดได้ (แบบ AI ช่วยวินิจฉัย)
final Set<String> _ndxAiPicked = {};

/// footer ของหน้าข้อวินิจฉัย: บันทึกผลวิเคราะห์ที่เลือกลงช่อง · ปิดการ์ดกลับเป็นแบบฟอร์ม
VoidCallback? _ndxAiCommit;
VoidCallback? _ndxAiClose;

/// ข้อวินิจฉัยทางการพยาบาลที่พบบ่อยใน ER
/// ข้อวินิจฉัยมาจาก master er_nursing_diagnosis (HOSxP er_nursing_diag) · ไม่มี master = ชุดนี้แทน
const List<String> _ndxCommon = [
  'ปวดเฉียบพลัน',
  'การแลกเปลี่ยนก๊าซบกพร่อง',
  'เสี่ยงต่อการพลัดตกหกล้ม',
  'วิตกกังวล',
];

/// หมวดของแผ่นเลือกกิจกรรมการพยาบาล (master er_nursing_activity ไม่มีหมวด จัดตามบทบาท) · ไม่อยู่ในหมวดใด = อื่น ๆ
const List<(String, List<String>)> _ndxActGroups = [
  (
    'ประเมิน / ติดตาม',
    [
      'ติดตามสัญญาณชีพ (Vital signs)',
      'สอบถามระดับความปวด',
      'ประเมินการลดลงของอาการปวด',
      'ประเมินระดับความปวดโดยใช้ Numeric Rating Scale',
      'ประเมิน GCS และ pupil',
      'ติดตาม O2 saturation',
      'ติดตาม ECG monitor',
      'เจาะ DTX / ติดตามระดับน้ำตาลในเลือด',
      'บันทึกสารน้ำเข้า-ออก (I/O)',
    ]
  ),
  (
    'ดูแล / บำบัด',
    [
      'ให้ยาตามแผนการรักษา',
      'ให้ออกซิเจนตามแผนการรักษา',
      'ดูแลให้สารน้ำทางหลอดเลือดดำ',
      'จัดท่านอนศีรษะสูง 30 องศา',
      'ประคบอุ่น / ประคบเย็น',
      'เช็ดตัวลดไข้',
      'ทำความสะอาดบาดแผล',
    ]
  ),
  (
    'ความปลอดภัย / จิตใจ',
    [
      'ยกราวกั้นเตียง ช่วยพยุงเวลาลุก',
      'ให้ข้อมูลและคลายความวิตกกังวลแก่ผู้ป่วยและญาติ',
    ]
  ),
];

/// หมวดของแผ่นเลือกข้อวินิจฉัย (master ไม่มีหมวด จัดตามระบบ/ปัญหา) · ข้อที่ไม่อยู่ในหมวดใด = อื่น ๆ
const List<(String, List<String>)> _ndxGroups = [
  (
    'หายใจและออกซิเจน',
    [
      'เสี่ยงต่อภาวะพร่องออกซิเจน',
      'การแลกเปลี่ยนก๊าซบกพร่อง',
      'เสี่ยงต่อภาวะเนื้อเยื่อสมองได้รับออกซิเจนไม่เพียงพอ',
      'เนื้อเยื่อหัวใจได้รับออกซิเจนไม่เพียงพอ',
    ]
  ),
  (
    'ไหลเวียนและสารน้ำ',
    [
      'เสี่ยงต่อภาวะช็อกจากการเสียเลือด',
      'มีภาวะไม่สมดุลของสารน้ำและอิเล็กโทรไลต์',
    ]
  ),
  (
    'ติดเชื้อและไข้',
    [
      'เสี่ยงต่อการติดเชื้อในกระแสเลือด / ภาวะช็อกจากการติดเชื้อ',
      'มีภาวะไข้สูง',
    ]
  ),
  (
    'ความปลอดภัยและผิวหนัง',
    ['เสี่ยงต่อการพลัดตกหกล้ม', 'ผิวหนังไม่สมบูรณ์ / มีบาดแผล']
  ),
  ('ความปวดและจิตใจ', ['ปวดเฉียบพลัน', 'วิตกกังวล']),
];

/// การ์ดข้อวินิจฉัยที่กางอยู่ (null = ไม่มี)
String? _ndxOpen;

/// ภาพประกอบการ์ดข้อวินิจฉัย (ภาพระบบชุดเดียวกับ ROS/PE) · พิมพ์เอง = ภาพบันทึก
String _ndxArt(String dx) => switch (dx) {
      'ปวดเฉียบพลัน' => 'assets/images/er_ros_sys_msk.png',
      'การแลกเปลี่ยนก๊าซบกพร่อง' => 'assets/images/er_ros_sys_resp.png',
      'เสี่ยงต่อภาวะพร่องออกซิเจน' => 'assets/images/er_ros_sys_resp.png',
      'เสี่ยงต่อภาวะเนื้อเยื่อสมองได้รับออกซิเจนไม่เพียงพอ' =>
        'assets/images/er_pe_sys_neuro.png',
      'เนื้อเยื่อหัวใจได้รับออกซิเจนไม่เพียงพอ' =>
        'assets/images/er_pe_sys_heart.png',
      'เสี่ยงต่อภาวะช็อกจากการเสียเลือด' =>
        'assets/images/er_ros_sys_hemato.png',
      'มีภาวะไม่สมดุลของสารน้ำและอิเล็กโทรไลต์' =>
        'assets/images/er_ros_sys_cardio.png',
      'เสี่ยงต่อการติดเชื้อในกระแสเลือด / ภาวะช็อกจากการติดเชื้อ' =>
        'assets/images/er_ros_sys_hemato.png',
      'มีภาวะไข้สูง' => 'assets/images/er_ros_sys_constitutional.png',
      'ผิวหนังไม่สมบูรณ์ / มีบาดแผล' =>
        'assets/images/er_pe_sys_extremities.png',
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

    // ข้อนี้ (เพิ่มให้ถ้ายังไม่มี) แล้วแทนค่าที่เปลี่ยน · กิจกรรมเรียงตามเวลา
    // ข้อใหม่ = เนื่องจาก/เป้าหมาย ตั้งต้นของข้อที่พบบ่อย (_ndxDefaults)
    void put(String dx,
        {String? eval,
        List<_NdxAct>? acts,
        String? cause,
        String? support,
        String? goal,
        String? evalNote}) {
      final l = _ndxStore[p.hn] ??= [];
      var i = l.indexWhere((n) => n.dx == dx);
      if (i < 0) {
        final df = _ndxDefaults[dx];
        l.add(_Ndx(dx, '', const [], cause: df?.$1 ?? '', goal: df?.$2 ?? ''));
        i = l.length - 1;
      }
      final o = l[i];
      setState(() => l[i] = o.copy(
          eval: eval,
          acts: acts == null
              ? null
              : ([...acts]..sort((a, b) => a.at.compareTo(b.at))),
          cause: cause,
          support: support,
          goal: goal,
          evalNote: evalNote));
    }

    // หน้าพิมพ์ในแผงมี breadcrumb เสมอ (แม่ = ข้อวินิจฉัย หรือหน้ารายการวินิจฉัย)
    // ---- AI ช่วยวิเคราะห์ (ปุ่มในหน้าพิมพ์ แบบ AI ช่วยวินิจฉัยของ Diagnosis Text)
    // อิงข้อมูลเคส: อาการสำคัญ/สัญญาณชีพ/ตรวจร่างกาย · ผลการสังเกตอาการแต่ละรอบ · คำสั่งแพทย์ที่รับแล้ว
    // ข้อมูลไม่พอ = ช่องว่าง ห้ามเดา · ผลเป็นข้อเสนอ พยาบาลแก้/ยืนยันก่อนบันทึก (P8)
    const aiSrc = {
      'CC': 'อาการสำคัญ',
      'HPI': 'ประวัติ',
      'VS': 'สัญญาณชีพ',
      'NEURO': 'ระบบประสาท',
      'PE': 'ตรวจร่างกาย',
      'ROS': 'ตรวจร่างกาย',
      'LAB': 'Lab',
      'OBS': 'สังเกตอาการ',
      'ORDER': 'คำสั่งแพทย์',
      'PMH': 'โรคประจำตัว',
    };
    Future<Map<String, dynamic>?> aiAll(String dx) =>
        _ndxAiCache.putIfAbsent('${p.hn}|$dx|v2', () async {
          final obs = [
            for (final a in _obsDraftOf(p).plan)
              for (final (k, (t, x)) in a.recs.indexed)
                if (x.isNotEmpty)
                  '[OBS] ${a.name} ครั้งที่ ${k + 1} ${_obsHm(t)} น.: $x',
          ];
          final orders = [
            for (final t in _allTasks)
              '[ORDER] ${t.title}${t.detail.isEmpty ? '' : ' (${t.detail})'}'
                  '${_isDone(t.title) ? ' รับแล้ว' : ' รอรับ'}',
          ];
          final out = await ErAi.chat([
            {
              'role': 'system',
              'content': '''
คุณช่วยพยาบาลห้องฉุกเฉินเขียนแผนการพยาบาลของข้อวินิจฉัยที่ให้ จากข้อมูลในเคส แต่ละบรรทัดมีป้ายแหล่ง [CC] [HPI] [VS] [NEURO] [PE] [ROS] [LAB] [OBS] [ORDER] [PMH]
- cause: สาเหตุ/ปัจจัยที่เกี่ยวข้องของข้อนี้ สั้น ๆ ไม่ต้องขึ้นต้นด้วย "เนื่องจาก"
- support: ข้อมูลสนับสนุน รูปแบบ "S: ... O: ..." ใช้เฉพาะข้อมูลจริงในเคส ส่วนที่ไม่มีให้ละไว้
- goal: เป้าหมายและเกณฑ์การประเมินผลที่วัดได้ มีเวลากำกับ
- eval: ผลการประเมินเทียบกับเป้าหมาย จาก [OBS] ล่าสุด ถ้ายังไม่มีผลสังเกตให้ว่าง
- ห้ามเดาข้อมูลที่ไม่มี ช่องที่ข้อมูลไม่พอให้เป็น "" ภาษาไทยแบบบันทึกการพยาบาล
- ห้ามใส่ป้ายแหล่ง เช่น [CC] [VS] ในข้อความ ให้ใส่ใน refs เท่านั้น
- refs: ทุกวลีที่อ้างข้อมูลในเคส ระบุช่อง ข้อความ (ตรงตัวอักษร) และป้ายแหล่ง
- reasons: ข้อมูลในเคสที่ใช้วิเคราะห์ 2-4 ข้อ ข้อละ 1 ประโยค เช่น "BT 37.6 °C และ WBC 15,800 บ่งถึงการติดเชื้อ"
ตอบ JSON: {"cause":"","support":"","goal":"","eval":"","reasons":[""],"refs":[{"field":"support","text":"SpO2 94%","src":"VS"}]}'''
            },
            {
              'role': 'user',
              'content':
                  'ข้อวินิจฉัยทางการพยาบาล: $dx\n\nข้อมูลเคส:\n${_dxCaseText()}'
                      '${obs.isEmpty ? '' : '\n${obs.join('\n')}'}'
                      '${orders.isEmpty ? '' : '\n${orders.join('\n')}'}'
            },
          ], fast: true, json: true, temperature: 0.1, maxTokens: 900);
          final j = ErAi.extractJson(out);
          // ขอไม่สำเร็จ = ไม่เก็บไว้ (กดใหม่ขอใหม่)
          if (j == null) _ndxAiCache.remove('${p.hn}|$dx|v2');
          return j;
        });

    // โมเดลบางครั้งแนบป้ายแหล่ง [CC] [VS] มาในข้อความ = ตัดออก (ที่มาแสดงเป็นชิปแทน)
    String clean(Object? raw) => '${raw ?? ''}'
        .replaceAll(RegExp(r'\s*\[[A-Z]{2,6}\]'), '')
        // ส่วน S/O ที่ว่าง ("S: O: …") = ตัดป้ายที่ไม่มีข้อมูล
        .replaceAll(RegExp(r'\b[SO]:\s*(?=[SO]:|$)'), '')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();

    // ปุ่ม AI ในหน้าข้อวินิจฉัย: วิเคราะห์แล้วแสดงผลเป็นการ์ดข้อเสนอ (ไม่มีโหมดย้อนกลับ)
    Future<void> aiFillAll(String dx) async {
      final k = '${p.hn}|$dx';
      if (_ndxAiBusy.contains(k)) return;
      HapticFeedback.selectionClick();
      setState(() => _ndxAiBusy.add(k));
      final j = await aiAll(dx);
      if (!mounted) return;
      setState(() {
        _ndxAiBusy.remove(k);
        // ผลวิเคราะห์แสดงเป็นการ์ดข้อเสนอก่อน (แบบ AI ช่วยวินิจฉัย) · พยาบาลกดใช้เอง
        if (j != null) _ndxAiShow[k] = j;
      });
    }

    // ใช้ผลวิเคราะห์: เติมทุกช่องที่ AI ตอบ (ช่องที่ AI เว้นว่าง = คงค่าเดิม) · เก็บค่าเดิมไว้ย้อนกลับ
    void aiApply(String dx) {
      final k = '${p.hn}|$dx';
      final j = _ndxAiShow[k];
      if (j == null) return;
      final l = _ndxStore[p.hn];
      final i = l?.indexWhere((n) => n.dx == dx) ?? -1;
      if (l == null || i < 0) return;
      final o = l[i];
      String keep(String cur, String f) =>
          clean(j[f]).isNotEmpty ? clean(j[f]) : cur;
      final n = o.copy(
          cause: keep(o.cause, 'cause'),
          support: keep(o.support, 'support'),
          goal: keep(o.goal, 'goal'),
          evalNote: keep(o.evalNote, 'eval'));
      HapticFeedback.mediumImpact();
      setState(() {
        l[i] = n;
        _ndxAiShow.remove(k);
        _ndxAiPicked.remove(k);
      });
    }

    // การ์ดข้อเสนอ (ชุดเดียวกับ Most likely ของ AI ช่วยวินิจฉัย): พื้นไล่ฟ้าอ่อน · ป้ายคร่อมขอบ
    // ค่าที่ AI เสนอแต่ละช่อง (ชื่อซ้าย ค่าขวา) · ข้อมูลที่ AI ใช้วิเคราะห์ · ปุ่มใช้ผลวิเคราะห์นี้
    Widget aiCard(String dx) {
      final k = '${p.hn}|$dx';
      final j = _ndxAiShow[k]!;
      final rows = [
        for (final (f, l) in const [
          ('cause', 'เนื่องจาก'),
          ('support', 'ข้อมูลสนับสนุน'),
          ('goal', 'เป้าหมาย'),
          ('eval', 'การประเมินผล'),
        ])
          if (clean(j[f]).isNotEmpty) (l, clean(j[f])),
      ];
      final why = [
        for (final x
            in (j['reasons'] is List ? j['reasons'] as List : const []))
          if (clean(x).isNotEmpty) clean(x),
      ];
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 12.0),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              key: ValueKey('ndx-ai-bg-$k'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Color(0xFFEAF0FB),
                      Color(0xFFEAF0FB),
                      Color(0xFFFFFFFF)
                    ],
                    stops: [0.0, 0.0, 0.02 + 0.98 * v],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 14.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ข้อความยาวหลายบรรทัด: หัวข้อบน ค่าล่างชิดซ้ายเต็มกว้าง (อ่านง่ายกว่าค่าชิดขวาแคบ ๆ)
                  for (final (i, (l, v)) in rows.indexed)
                    _Appear(
                      key: ValueKey('ndx-ai-row-$k-$i'),
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l,
                                  style: _t(12.5,
                                      color: _ink2, weight: FontWeight.w600)),
                              const SizedBox(height: 2.0),
                              Text(v,
                                  style: _t(14.5,
                                      color: _inkTitle,
                                      height: 1.45,
                                      weight: FontWeight.w600)),
                            ]),
                      ),
                    ),
                  if (why.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Divider(height: 1.0, color: Color(0xFFDDE5F3)),
                    ),
                  if (why.isNotEmpty) ...[
                    Text('ข้อมูลที่ AI ใช้วิเคราะห์',
                        style: _t(12.5, color: _ink2, weight: FontWeight.w700)),
                    const SizedBox(height: 6.0),
                  ],
                  for (final (wi, w) in why.take(4).indexed)
                    _Appear(
                      key: ValueKey('ndx-ai-why-$k-$wi'),
                      index: rows.length + wi,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 5.0,
                                  height: 5.0,
                                  margin: const EdgeInsets.only(
                                      top: 9.0, left: 4.0, right: 10.0),
                                  decoration: const BoxDecoration(
                                      color: _ink2, shape: BoxShape.circle)),
                              Expanded(
                                child: Text(w,
                                    style: _t(13.5,
                                        color: _ink,
                                        height: 1.45,
                                        weight: FontWeight.w500)),
                              ),
                            ]),
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  // เลือกผลนี้ (ปุ่มเดียวกับ AI ช่วยวินิจฉัย) · บันทึกจริงที่ปุ่ม footer
                  _DxPickBtn(
                      on: _ndxAiPicked.contains(k),
                      label: 'ใช้ผลวิเคราะห์นี้',
                      onTap: () => setState(() => _ndxAiPicked.contains(k)
                          ? _ndxAiPicked.remove(k)
                          : _ndxAiPicked.add(k)),
                      base: _t(14.0, weight: FontWeight.w700)),
                ]),
          ),
          // ป้ายคร่อมขอบบน (แบบ Most likely) · ปุ่มปิดมุมขวา
          Positioned(
            left: 16.0,
            top: -13.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFC9D6EE), width: 1.0),
              ),
              child: Text('ข้อเสนอจาก AI',
                  style: _t(12.0, color: _blue, weight: FontWeight.w700)),
            ),
          ),
        ]),
      );
    }

    // ปุ่ม AI ชุดเดียวกับในหน้าพิมพ์: ขอบไล่สี AI · ✦ + ชื่อ · กำลังวิเคราะห์ = ไอคอนแหล่งข้อมูลวนเด้ง
    Widget aiBtn(String dx) {
      final k = '${p.hn}|$dx';
      final busy = _ndxAiBusy.contains(k);
      // มีผลวิเคราะห์แสดงอยู่ = ปิดปุ่ม (ออกด้วย ← ใน footer แบบ AI ช่วยวินิจฉัย)
      final shown = _ndxAiShow.containsKey(k);
      const aiGrad = [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)];
      return Opacity(
        opacity: shown ? 0.4 : 1.0,
        child: _Press(
          child: Container(
            padding: const EdgeInsets.all(1.2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              gradient: const LinearGradient(colors: aiGrad),
            ),
            child: Material(
              color: _panel,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: busy || shown ? null : () => aiFillAll(dx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (busy)
                      const _AovSources(icons: [
                        Icons.chat_bubble_outline_rounded,
                        Icons.monitor_heart_outlined,
                        Icons.assignment_outlined,
                      ], loading: true, ink: _blue, wave: true)
                    else ...[
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: aiGrad,
                        ).createShader(r),
                        child:
                            const Icon(Icons.auto_awesome_rounded, size: 19.0),
                      ),
                      const SizedBox(width: 8.0),
                      Text('AI ช่วยวิเคราะห์',
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ผลของช่องเดียว + ชิปที่มา (ชื่อหน้าที่เอามา)
    Future<_FtAiOut?> aiField(String dx, String field) async {
      final j = await aiAll(dx);
      final v = clean(j?[field]);
      if (v.isEmpty) return null;
      String src(Object? raw) {
        final code = '${raw ?? ''}'.toUpperCase();
        for (final e in aiSrc.entries) {
          if (code.contains(e.key)) return e.value;
        }
        return 'ข้อมูลเคส';
      }

      return (
        text: v,
        refs: [
          for (final x in (j?['refs'] is List ? j!['refs'] as List : const []))
            if (x is Map &&
                x['field'] == field &&
                '${x['text'] ?? ''}'.trim().isNotEmpty &&
                v.contains('${x['text']}'.trim()))
              ('${x['text']}'.trim(), src(x['src'])),
        ]
      );
    }

    // [ai] = ช่องที่ให้ AI ช่วยวิเคราะห์ของข้อ [crumb] (ไม่ส่ง = ไม่มีปุ่ม AI)
    Future<String?> typeText(String title, String initial, String hint,
        {String crumb = 'วินิจฉัย', String? ai}) async {
      final v = await _ftOpen(context,
          title: title,
          crumb: crumb,
          inWorkflow: true,
          initial: initial,
          hint: hint,
          aiFill: ai == null ? null : (_) => aiField(crumb, ai),
          aiLabel: ai == null ? null : 'AI ช่วยวิเคราะห์');
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
        // ลบแล้วกลับหน้ารายการ
        _ndxOpen = null;
      });
    }

    // กิจกรรมใหม่ = เวลาตอนนี้ (แตะแถวเพื่อเปลี่ยนเวลา) · ผู้ทำ = ผู้ใช้ที่เข้าระบบ
    // เพิ่มกิจกรรม = แผ่นเลือกแบบ filter จาก master er_nursing_activity (HOSxP er_nursing_detail)
    // หมวดตามบทบาท + ค้นหา + เพิ่มเอง · ลงเวลาตอนนี้ ผู้ทำ = ผู้ใช้ที่เข้าระบบ (แตะแถวแก้เวลาได้)
    Future<void> addAct(String dx) async {
      void add(String v) {
        final t = v.replaceAll('\n', ' ').trim();
        if (t.isEmpty) return;
        final i = idx(dx);
        put(dx, acts: [
          if (i >= 0) ...list[i].acts,
          _NdxAct(me, t, DateTime.now()),
        ]);
      }

      final m = _masterNames('er_nursing_activity');
      final names = m.isEmpty ? [for (final g in _ndxActGroups) ...g.$2] : m;
      final grouped = {for (final g in _ndxActGroups) ...g.$2};
      await _soFilterSheet(
        title: 'เพิ่มกิจกรรมการพยาบาล',
        sub: dx,
        cats: [
          ('ทั้งหมด', names),
          for (final (g, xs) in _ndxActGroups)
            if (xs.where(names.contains).isNotEmpty)
              (
                g,
                [
                  for (final x in xs)
                    if (names.contains(x)) x
                ]
              ),
          if (names.where((x) => !grouped.contains(x)).isNotEmpty)
            (
              'อื่น ๆ',
              [
                for (final x in names)
                  if (!grouped.contains(x)) x
              ]
            ),
        ],
        current: null,
        onPick: add,
        customLabel: 'เพิ่มเอง',
        onCustom: () async {
          final v = await typeText(
              'กิจกรรมการพยาบาล', '', 'รายละเอียดกิจกรรม หรือแตะไมค์เพื่อพูด',
              crumb: dx);
          if (v != null && mounted) add(v);
        },
      );
    }

    // ---- โครงเดียวกับกิจกรรมทางพยาบาล (ผู้ใช้ 2026-11-13):
    // หน้ารายการ = การ์ด + ปุ่มเพิ่มข้อวินิจฉัยใหม่ + แถวข้อที่เลือก (›) · แตะแถว = หน้าข้อวินิจฉัย (breadcrumb)

    // แผ่นเลือกข้อ: ข้อที่พบบ่อย (เลือกแล้ว = จาง) + เพิ่มเอง
    // แผ่นเลือกแบบ filter: ซ้าย = หมวด (ทั้งหมด + ตามระบบ) · ขวา = ค้นหา + รายการ จาก master
    void pickNew() {
      final all = _masterNames('er_nursing_diagnosis');
      final names = all.isEmpty ? _ndxCommon : all;
      final grouped = {for (final g in _ndxGroups) ...g.$2};
      final cats = [
        ('ทั้งหมด', names),
        for (final (g, xs) in _ndxGroups)
          if (xs.where(names.contains).isNotEmpty)
            (
              g,
              [
                for (final x in xs)
                  if (names.contains(x)) x
              ]
            ),
        if (names.where((x) => !grouped.contains(x)).isNotEmpty)
          (
            'อื่น ๆ',
            [
              for (final x in names)
                if (!grouped.contains(x)) x
            ]
          ),
      ];
      _soFilterSheet(
        title: 'เพิ่มข้อวินิจฉัยใหม่',
        sub: 'วินิจฉัยทางการพยาบาล',
        cats: cats,
        current: null,
        taken: {for (final n in list) n.dx},
        onPick: (o) {
          put(o);
          setState(() => _ndxOpen = o);
        },
        customLabel: 'เพิ่มเอง',
        onCustom: addCustom,
      );
    }

    // ภาพนำแถว = ภาพของข้อ
    Widget lead(_Ndx n) => SizedBox.square(
          dimension: 48.0,
          child: Image.asset(_ndxArt(n.dx),
              fit: BoxFit.contain, filterQuality: FilterQuality.medium),
        );

    String status(_Ndx n) => [
          n.evalNote.isEmpty && n.eval.isEmpty
              ? 'ยังไม่ประเมินผล'
              : 'ประเมินผลแล้ว',
          n.acts.isEmpty
              ? 'ยังไม่มีกิจกรรม'
              : 'กิจกรรม ${n.acts.length} รายการ',
        ].join(' • ');

    Widget listPage() => _dxCard(
          'วินิจฉัยทางการพยาบาล',
          'ข้อวินิจฉัย การประเมินผล และกิจกรรมของแต่ละข้อ',
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 10.0, 16.0, 10.0),
            child: _dxArtFade(Image.asset('assets/images/er_os_note_add.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                filterQuality: FilterQuality.medium)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _dxTiles([(Icons.add_rounded, 'เพิ่มข้อวินิจฉัยใหม่', pickNew)]),
            for (final (i, n) in list.indexed)
              _gListRow(
                first: i == 0,
                inset: 8.0,
                lead: lead(n),
                title: n.dx,
                sub: status(n),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _ndxOpen = n.dx);
                },
                trail: const Icon(Icons.chevron_right_rounded,
                    size: 22.0, color: _ink3),
              ),
          ]),
        );

    // หน้าข้อวินิจฉัย: การประเมินผล (ร่องเหรียญ) · กิจกรรม (เวลา ผู้ทำ) · เพิ่มกิจกรรม พิมพ์ผล · ลบข้อนี้
    Widget detailPage(String dx) {
      final i = idx(dx);
      final n = i < 0 ? null : list[i];
      final body =
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // แบบ AI ช่วยวินิจฉัยของ Diagnosis Text: กำลังวิเคราะห์/มีผล = แสดงผลอย่างเดียว ซ่อนแบบฟอร์ม
        // ใช้ผล หรือปิด (×) = กลับมาเป็นแบบฟอร์ม
        if (_ndxAiShow.containsKey('${p.hn}|$dx'))
          aiCard(dx)
        else if (_ndxAiBusy.contains('${p.hn}|$dx'))
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 32.0),
            child: Text(
                'กำลังวิเคราะห์จากการสังเกตอาการ อาการสำคัญ และคำสั่งแพทย์',
                textAlign: TextAlign.center,
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          )
        else ...[
          // ตามกระบวนการพยาบาล: ข้อวินิจฉัย (เนื่องจาก) → ข้อมูลสนับสนุน → เป้าหมาย → กิจกรรม → ประเมินผล
          _procRow('เนื่องจาก', n?.cause.isEmpty ?? true ? null : n!.cause,
              first: true,
              placeholder: 'ระบุสาเหตุ',
              valueLines: 3, onTap: () async {
            final v = await typeText(
                'เนื่องจาก', n?.cause ?? '', 'สาเหตุหรือปัจจัยที่เกี่ยวข้อง',
                crumb: dx);
            if (v != null && mounted) put(dx, cause: v);
          }),
          _procRow(
              'ข้อมูลสนับสนุน', n?.support.isEmpty ?? true ? null : n!.support,
              placeholder: 'S ผู้ป่วยบอก • O ที่สังเกตได้',
              valueLines: 4, onTap: () async {
            // ว่าง = เติมผลล่าสุดของกิจกรรมพยาบาลให้เป็นข้อมูล O (แก้ต่อได้)
            final auto = [
              for (final a in _obsDraftOf(p).plan)
                if (a.recs.isNotEmpty && a.recs.last.$2.isNotEmpty)
                  '${a.name}: ${a.recs.last.$2}'
            ];
            final v = await typeText(
              'ข้อมูลสนับสนุน',
              (n?.support.isEmpty ?? true) && auto.isNotEmpty
                  ? 'O: ${auto.join('\n')}'
                  : n?.support ?? '',
              'S: สิ่งที่ผู้ป่วยบอก  O: สิ่งที่สังเกตหรือวัดได้',
              crumb: dx,
            );
            if (v != null && mounted) put(dx, support: v);
          }),
          _procRow('เป้าหมาย', n?.goal.isEmpty ?? true ? null : n!.goal,
              placeholder: 'เป้าหมายและเกณฑ์การประเมินผล',
              valueLines: 3, onTap: () async {
            final v = await typeText('เป้าหมาย', n?.goal ?? '',
                'เช่น ปวดลดลง Pain score ไม่เกิน 3 ภายใน 1 ชั่วโมง',
                crumb: dx);
            if (v != null && mounted) put(dx, goal: v);
          }),
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: Divider(height: 1.0, color: _line),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 4.0),
            child: Text('กิจกรรมการพยาบาล',
                style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
          ),
          for (final a in n?.acts ?? const <_NdxAct>[])
            InkWell(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                child: Row(children: [
                  _obsTimeBadge(TimeOfDay.fromDateTime(a.at)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.detail,
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
                    _ndxStore[p.hn]![j] = o.copy(acts: [
                      for (final x in o.acts)
                        if (!identical(x, a)) x
                    ]);
                  }),
                ]),
              ),
            ),
          const SizedBox(height: 4.0),
          _dxTiles([(Icons.add_rounded, 'เพิ่มกิจกรรม', () => addAct(dx))]),
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0.0),
            child: Divider(height: 1.0, color: _line),
          ),
          // การประเมินผล = ข้อความเทียบกับเป้าหมาย (ไม่มีตัวเลือก ดีขึ้น/คงเดิม/แย่ลง)
          _procRow(
              'การประเมินผล',
              n?.evalNote.isNotEmpty ?? false
                  ? n!.evalNote
                  : n?.eval.isNotEmpty ?? false
                      ? n!.eval
                      : null,
              placeholder: 'ผลหลังให้การพยาบาล เทียบกับเป้าหมาย',
              valueLines: 3, onTap: () async {
            final v = await typeText('การประเมินผล', n?.evalNote ?? '',
                'ผลหลังให้การพยาบาล เทียบกับเป้าหมาย',
                crumb: dx);
            if (v != null && mounted) put(dx, evalNote: v);
          }),
          const SizedBox(height: 8.0),
          // ลบข้อ: ปุ่ม tonal แดงจาง เต็มกว้าง (แบบหน้ากิจกรรมทางพยาบาล) · ยืนยันก่อนลบ
          TextButton.icon(
            onPressed: () => remove(dx),
            style: TextButton.styleFrom(
              foregroundColor: _red,
              backgroundColor: _red.withValues(alpha: 0.08),
              minimumSize: const Size.fromHeight(48.0),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
            label: Text('ลบข้อวินิจฉัยนี้',
                style: _t(14.0, color: _red, weight: FontWeight.w600)),
          ),
          const SizedBox(height: 8.0),
        ],
      ]);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 12.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dx,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('แผนการพยาบาลของข้อนี้',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
            const SizedBox(width: 8.0),
            // AI ช่วยวิเคราะห์จากการสังเกตอาการ อาการสำคัญ คำสั่งแพทย์
            aiBtn(dx),
          ]),
        ),
        // มีผลวิเคราะห์ = การ์ดข้อเสนอวางตรงในหน้า (ไม่มีการ์ดขอบหุ้ม แบบ AI ช่วยวินิจฉัย)
        if (_ndxAiShow.containsKey('${p.hn}|$dx'))
          body
        else
          Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: body,
          ),
      ]);
    }

    final cur = _ndxOpen;
    // ให้ footer ของแผงเรียกได้ (บันทึกผลที่เลือก / ปิดผลวิเคราะห์)
    final aiK = '${p.hn}|$cur';
    _ndxAiCommit =
        cur != null && _ndxAiShow.containsKey(aiK) ? () => aiApply(cur) : null;
    _ndxAiClose = cur != null && _ndxAiShow.containsKey(aiK)
        ? () => setState(() {
              _ndxAiShow.remove(aiK);
              _ndxAiPicked.remove(aiK);
            })
        : null;
    return cur != null && idx(cur) >= 0 ? detailPage(cur) : listPage();
  }
}
