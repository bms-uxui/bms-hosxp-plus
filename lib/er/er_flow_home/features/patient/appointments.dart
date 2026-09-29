// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// แท็บ "นัดหมาย" ในหน้าผู้ป่วย: ดูประวัติการนัด (วันนี้ · ที่จะถึง · ผ่านมาแล้ว)
// และบันทึกนัดหมายใหม่ (วันเวลา · สถานที่/ผู้ตรวจ · เหตุที่นัด · คำแนะนำก่อนพบแพทย์)

/// ลำดับของแท็บนัดหมายใน _detailTabs (ต่อท้ายแท็บที่มีอยู่ ไม่ขยับเลขแท็บเดิม)
const int _apptTab = 11;

/// นัดหมายหนึ่งรายการ
class _Appt {
  _Appt({
    required this.clinic,
    required this.date,
    required this.start,
    required this.end,
    required this.dept,
    required this.room,
    required this.doctor,
    required this.reason,
    required this.madeBy,
    required this.madeOn,
    this.note = '',
    this.prep = const [],
  });

  final String clinic;
  final DateTime date;
  final String start;
  final String end;
  final String dept;
  final String room;
  final String doctor;
  final String reason;
  final String madeBy;
  final DateTime madeOn;
  final String note;

  /// สิ่งที่ต้องปฏิบัติตัวก่อนพบแพทย์ (ข้อละบรรทัด)
  final List<String> prep;
}

/// ฟอร์มนัดหมายใหม่ที่กำลังกรอก
class _ApptDraft {
  _ApptDraft(this.hn);

  /// ผู้ป่วยเจ้าของฟอร์ม (เปลี่ยนผู้ป่วยแล้วฟอร์มไม่ตามไป)
  final String hn;
  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;
  String? dept;
  String? clinic;
  String? doctor;
  String? room;
  String? reason;
  final TextEditingController note = TextEditingController();
  final TextEditingController prep = TextEditingController();

  /// ช่องบังคับที่ยังว่าง
  List<String> get missing => [
        if (date == null) 'วันที่นัด',
        if (start == null) 'เวลาเริ่ม',
        if (dept == null) 'แผนก',
        if (reason == null) 'เหตุที่นัด',
      ];
}

/// นัดหมายของแต่ละ HN (ข้อมูลจำลองสำหรับเดโม · บันทึกใหม่เก็บในหน่วยความจำ)
final Map<String, List<_Appt>> _apptStore = {};

/// ฟอร์มที่เปิดอยู่ (null = หน้ารายการนัด)
_ApptDraft? _apptDraft;

// ตัวเลือกของฟอร์ม · ข้อมูลตัวอย่างสำหรับ mockup (ยังไม่มี master แผนก/คลินิกของ OPD)
const List<String> _apptDepts = [
  'อายุรกรรม',
  'ศัลยกรรม',
  'ศัลยกรรมกระดูก',
  'กุมารเวชกรรม',
  'สูติ-นรีเวชกรรม',
  'จักษุ',
  'หู คอ จมูก',
  'เวชศาสตร์ฉุกเฉิน',
];
const List<String> _apptClinics = [
  'คลินิกปอดอุดกั้นเรื้อรัง (COPD)',
  'คลินิกเบาหวาน',
  'คลินิกความดันโลหิตสูง',
  'คลินิกโรคหัวใจ',
  'คลินิกศัลยกรรมทั่วไป',
  'คลินิกกระดูกและข้อ',
  'คลินิกทำแผล',
  'คลินิกอายุรกรรมทั่วไป',
];
const List<String> _apptRooms = [
  'ห้องตรวจอายุรกรรม 1',
  'ห้องตรวจอายุรกรรม 2',
  'ห้องตรวจศัลยกรรม',
  'ห้องตรวจกระดูก',
  'ห้องทำแผล',
  '460 หอพิเศษเดี่ยวอายุรกรรมชั้น 4',
];
const List<String> _apptReasons = [
  'ติดตามอาการหลังออกจากห้องฉุกเฉิน',
  'ฟังผลตรวจทางห้องปฏิบัติการ',
  'ฟังผลเอกซเรย์ / CT',
  'ตัดไหม / ทำแผล',
  'ติดตามการรักษาโรคเรื้อรัง',
  'ตรวจคลื่นสะท้อนหัวใจด้วยการใส่สายตรวจผ่านหลอดอาหาร (TEE)',
];

/// ช่วงเวลาตัวอย่างให้แตะเลือกเร็ว (เริ่ม, สิ้นสุด)
const List<(String, String)> _apptSlots = [
  ('09:00', '09:30'),
  ('10:00', '10:30'),
  ('13:00', '13:30'),
  ('14:00', '14:30'),
];

const List<String> _thMon = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];

/// วันที่แบบไทย พ.ศ. เช่น "1 ต.ค. 2569"
String _apptDate(DateTime d) =>
    '${d.day} ${_thMon[d.month - 1]} ${d.year + 543}';

String _apptHm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ตัวอย่างนัดของผู้ป่วย: นัดที่จะถึง 1 รายการ + นัดที่ผ่านมาแล้ว 1 รายการ
List<_Appt> _apptSeed() {
  final today = _dayOnly(DateTime.now());
  return [
    _Appt(
      clinic: 'คลินิกปอดอุดกั้นเรื้อรัง (COPD)',
      date: today.add(const Duration(days: 3)),
      start: '13:07',
      end: '',
      dept: '460 หอพิเศษเดี่ยวอายุรกรรมชั้น 4',
      room: 'อายุรกรรม',
      doctor: 'น.ส.รัตนาพร สีทน',
      reason: 'ตรวจคลื่นสะท้อนหัวใจด้วยการใส่สายตรวจผ่านหลอดอาหาร (TEE)',
      madeBy: 'น.ส.รัตนาพร สีทน',
      madeOn: today,
      prep: const ['งดน้ำงดอาหารหลังเวลา 20.00 น.'],
    ),
    _Appt(
      clinic: 'คลินิกความดันโลหิตสูง',
      date: today.subtract(const Duration(days: 42)),
      start: '09:00',
      end: '09:30',
      dept: 'อายุรกรรม',
      room: 'ห้องตรวจอายุรกรรม 1',
      doctor: 'นพ. ธีรภัทร อ.',
      reason: 'ติดตามการรักษาโรคเรื้อรัง',
      madeBy: 'นพ. ธีรภัทร อ.',
      madeOn: today.subtract(const Duration(days: 90)),
      note: 'ปรับยาความดันเพิ่ม',
      prep: const ['นำยาเดิมที่ทานอยู่มาด้วย'],
    ),
  ];
}

extension _FeaturesPatientAppointmentsPart on _ErFlowHomeWidgetState {
  List<_Appt> _apptsOf(String hn) => _apptStore.putIfAbsent(hn, _apptSeed);

  /// เนื้อหาการ์ดขวาของแท็บนัดหมาย: ฟอร์มนัดใหม่ หรือ รายการนัด
  Widget _apptTabBody() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
                    begin: Offset(
                        child.key == const ValueKey('form') ? 0.22 : -0.22, 0),
                    end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: _apptDraft?.hn != _caseP().hn
            ? KeyedSubtree(key: const ValueKey('list'), child: _apptList())
            : KeyedSubtree(key: const ValueKey('form'), child: _apptForm()),
      );

  // ------------------------------------------------ รายการนัด

  Widget _apptList() {
    final all = _apptsOf(_caseP().hn);
    final today = _dayOnly(DateTime.now());
    final todays = [
      for (final a in all)
        if (_dayOnly(a.date) == today) a
    ];
    final next = [
      for (final a in all)
        if (_dayOnly(a.date).isAfter(today)) a
    ]..sort((a, b) => a.date.compareTo(b.date));
    final past = [
      for (final a in all)
        if (_dayOnly(a.date).isBefore(today)) a
    ]..sort((a, b) => b.date.compareTo(a.date));
    Widget head(IconData icon, String t, int n) => Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 14.0, 2.0, 8.0),
          child: Row(children: [
            Icon(icon, size: 16.0, color: _blue),
            const SizedBox(width: 6.0),
            Text(t, style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(width: 6.0),
            Text('$n รายการ',
                style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
          ]),
        );
    Widget empty(String t) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Text(t, style: _t(11.0, color: _ink3)),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 16.0),
      children: [
        Row(children: [
          Expanded(
            child: Text('นัดหมาย',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          _apptPrimaryBtn(Icons.add_rounded, 'นัดหมายใหม่',
              () => setState(() => _apptDraft = _ApptDraft(_caseP().hn))),
        ]),
        if (todays.isNotEmpty) ...[
          head(Icons.today_rounded, 'นัดหมายวันนี้', todays.length),
          for (final a in todays) _apptCard(a),
        ],
        head(Icons.event_rounded, 'นัดหมายที่จะถึง', next.length),
        if (next.isEmpty) empty('ยังไม่มีนัดหมายที่จะถึง'),
        for (final a in next) _apptCard(a),
        head(Icons.history_rounded, 'ประวัติการนัด', past.length),
        if (past.isEmpty) empty('ไม่มีประวัติการนัด'),
        for (final a in past) _apptCard(a, past: true),
      ],
    );
  }

  /// ปุ่มหลัก pill navy
  Widget _apptPrimaryBtn(IconData icon, String text, VoidCallback? onTap) =>
      _Press(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100.0),
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: _glossGrad(onTap == null ? _blue4 : _blue),
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: onTap == null ? null : _glossLift(_blue),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 17.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(text,
                  style:
                      _t(12.0, color: Colors.white, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// การ์ดนัดหนึ่งรายการ: คลินิก · แพทย์ · วันนัด (อีกกี่วัน) · รายละเอียด · คำแนะนำ
  Widget _apptCard(_Appt a, {bool past = false}) {
    final days = _dayOnly(a.date).difference(_dayOnly(DateTime.now())).inDays;
    final when = days == 0
        ? 'วันนี้'
        : (days > 0 ? 'อีก $days วันถึงนัด' : 'ผ่านมาแล้ว ${-days} วัน');
    Widget cell(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k, style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
              const SizedBox(height: 2.0),
              Text(v.isEmpty ? '-' : v,
                  style: _t(11.0,
                      color: _inkTitle, height: 1.35, weight: FontWeight.w600)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(a.clinic,
              style: _t(12.5,
                  color: past ? _ink2 : _blue, weight: FontWeight.w700)),
          const SizedBox(height: 8.0),
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            // แพทย์ที่นัดพบ: pill navy
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                gradient: _glossGrad(past ? _ink3 : _blue),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.person_rounded,
                    size: 13.0, color: Colors.white),
                const SizedBox(width: 4.0),
                Text('นัดพบแพทย์ : ${a.doctor.isEmpty ? 'ไม่ระบุ' : a.doctor}',
                    style:
                        _t(10.0, color: Colors.white, weight: FontWeight.w600)),
              ]),
            ),
            // วันนัด + อีกกี่วัน
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    color: (past ? _ink3 : _blue).withValues(alpha: 0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.event_rounded,
                    size: 13.0, color: past ? _ink3 : _blue),
                const SizedBox(width: 4.0),
                Text('${_apptDate(a.date)} · $when',
                    style: _t(10.0,
                        color: past ? _ink2 : _blue, weight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cell(
                          'เวลาที่นัด',
                          a.end.isEmpty
                              ? '${a.start} น.'
                              : '${a.start}–${a.end} น.'),
                      cell('วันที่ทำนัด', _apptDate(a.madeOn)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cell('แผนก', a.dept),
                      cell('ผู้ทำนัด', a.madeBy),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cell('ห้องตรวจ', a.room),
                      cell('เหตุที่นัด', a.reason),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (a.note.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text('หมายเหตุ',
                style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
            const SizedBox(height: 2.0),
            Text(a.note, style: _t(11.0, color: _inkTitle, height: 1.35)),
          ],
          if (a.prep.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text('สิ่งที่ต้องปฏิบัติตัวก่อนพบแพทย์',
                style: _t(10.5,
                    color: past ? _ink2 : _blue, weight: FontWeight.w700)),
            const SizedBox(height: 6.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < a.prep.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 4.0),
                      child: Text('${i + 1} - ${a.prep[i]}',
                          style: _t(11.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------ ฟอร์มบันทึกนัดหมาย

  Widget _apptForm() {
    final d = _apptDraft!;
    final p = _caseP();
    final missing = d.missing;
    Widget section(IconData icon, String title, List<Widget> body) => Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(12.0),
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
                    style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
              ]),
              const SizedBox(height: 10.0),
              ...body,
            ],
          ),
        );
    Widget two(Widget a, Widget b) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 10.0),
            Expanded(child: b),
          ],
        );
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
          children: [
            // หัวฟอร์ม: ย้อนกลับ · ชื่อ · คำอธิบาย
            Row(children: [
              InkWell(
                onTap: () => setState(() => _apptDraft = null),
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: _line),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      size: 22.0, color: _blue),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('บันทึกนัดหมาย',
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('เลือกวัน เวลา และรายละเอียดการนัด',
                        style: _t(10.0, color: _ink3)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 10.0),
            // ผู้ป่วย
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(12.0),
              decoration: _clyCardDeco,
              foregroundDecoration: const _InnerGloss(12.0),
              child: Row(children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 20.0, color: _blue),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: _t(12.5,
                              color: _inkTitle, weight: FontWeight.w700)),
                      Text('HN ${p.hn}', style: _t(10.0, color: _ink3)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text('นัดหมายใหม่',
                      style: _t(9.5, color: _blue, weight: FontWeight.w700)),
                ),
              ]),
            ),
            section(Icons.calendar_month_rounded, 'วันและเวลานัด', [
              _apptLabel('วันที่นัด', must: true),
              _apptBox(
                d.date == null ? 'เลือกวันที่' : _apptDate(d.date!),
                filled: d.date != null,
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  final now = DateTime.now();
                  final v = await showDatePicker(
                    context: context,
                    initialDate: d.date ?? now.add(const Duration(days: 7)),
                    firstDate: _dayOnly(now),
                    lastDate: now.add(const Duration(days: 730)),
                  );
                  if (v != null && mounted) setState(() => d.date = v);
                },
              ),
              const SizedBox(height: 10.0),
              two(
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _apptLabel('เวลาเริ่ม', must: true),
                      _apptBox(
                          d.start == null ? '--:--' : '${_apptHm(d.start!)} น.',
                          filled: d.start != null,
                          icon: Icons.schedule_rounded,
                          onTap: () => _apptPickTime(true)),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _apptLabel('เวลาสิ้นสุด'),
                      _apptBox(
                          d.end == null ? '--:--' : '${_apptHm(d.end!)} น.',
                          filled: d.end != null,
                          icon: Icons.schedule_rounded,
                          onTap: () => _apptPickTime(false)),
                    ]),
              ),
              const SizedBox(height: 8.0),
              Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final (s, e) in _apptSlots)
                  _optChip(
                      '$s–$e',
                      d.start != null &&
                          _apptHm(d.start!) == s &&
                          d.end != null &&
                          _apptHm(d.end!) == e,
                      false, () {
                    TimeOfDay t(String x) => TimeOfDay(
                        hour: int.parse(x.split(':')[0]),
                        minute: int.parse(x.split(':')[1]));
                    setState(() {
                      d.start = t(s);
                      d.end = t(e);
                    });
                  }, size: 10.5),
              ]),
            ]),
            section(Icons.local_hospital_rounded, 'สถานที่และผู้ตรวจ', [
              two(
                _apptSelect('แผนก', d.dept, _apptDepts, (v) => d.dept = v,
                    must: true),
                _apptSelect(
                    'คลินิก', d.clinic, _apptClinics, (v) => d.clinic = v),
              ),
              const SizedBox(height: 10.0),
              two(
                _apptSelect(
                    'นัดพบแพทย์', d.doctor, _apptDoctors(), (v) => d.doctor = v,
                    hint: 'เลือกแพทย์ หรือไม่ระบุ'),
                _apptSelect('ห้องตรวจ', d.room, _apptRooms, (v) => d.room = v,
                    hint: 'เลือกห้องตรวจ หรือไม่ระบุ'),
              ),
            ]),
            section(Icons.notes_rounded, 'รายละเอียดการนัด', [
              _apptSelect(
                  'เหตุที่นัด', d.reason, _apptReasons, (v) => d.reason = v,
                  must: true),
              const SizedBox(height: 10.0),
              _apptLabel('หมายเหตุเพิ่มเติม'),
              _apptTextArea(d.note, 'รายละเอียดที่ทีมรักษาควรทราบ…'),
            ]),
            section(Icons.checklist_rounded, 'คำแนะนำก่อนมาพบแพทย์', [
              _apptLabel('การปฏิบัติตัว (บรรทัดละ 1 ข้อ)'),
              _apptTextArea(d.prep, 'เช่น นำผลตรวจเดิมและรายการยามาด้วย'),
            ]),
          ],
        ),
      ),
      // ปุ่มหลักเต็มกว้างขอบล่าง: ยังไม่ครบ = บอกจำนวนช่องที่ขาด
      Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _apptPrimaryBtn(
                missing.isEmpty
                    ? Icons.check_rounded
                    : Icons.error_outline_rounded,
                missing.isEmpty
                    ? 'บันทึกนัดหมาย'
                    : 'กรอกให้ครบ (${missing.length}) · ${missing.join(', ')}',
                missing.isEmpty ? _apptSave : null),
          ),
        ),
      ),
    ]);
  }

  /// แพทย์จาก master er_doctor (ไม่มี master = รายชื่อแพทย์ในกะ)
  List<String> _apptDoctors() {
    final m = ErMaster.maybe?.table('er_doctor')?.activeItems;
    return [
      if (m != null)
        for (final it in m) it.name
      else
        for (final u in erStaff)
          if (u.role == ErRole.doctor) u.name
    ];
  }

  Future<void> _apptPickTime(bool start) async {
    final d = _apptDraft;
    if (d == null) return;
    final v = await showTimePicker(
      context: context,
      initialTime: (start ? d.start : d.end) ??
          (start
              ? const TimeOfDay(hour: 9, minute: 0)
              : (d.start == null
                  ? const TimeOfDay(hour: 9, minute: 30)
                  : TimeOfDay(
                      hour: (d.start!.hour + (d.start!.minute + 30) ~/ 60) % 24,
                      minute: (d.start!.minute + 30) % 60))),
      builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!),
    );
    if (v == null || !mounted) return;
    setState(() => start ? d.start = v : d.end = v);
  }

  void _apptSave() {
    final d = _apptDraft;
    if (d == null || d.missing.isNotEmpty) return;
    final p = _caseP();
    final a = _Appt(
      clinic: d.clinic ?? d.dept!,
      date: d.date!,
      start: _apptHm(d.start!),
      end: d.end == null ? '' : _apptHm(d.end!),
      dept: d.dept!,
      room: d.room ?? '',
      doctor: d.doctor ?? '',
      reason: d.reason!,
      madeBy: ErSession.instance.user?.name ?? '',
      madeOn: DateTime.now(),
      note: d.note.text.trim(),
      prep: [
        for (final l in d.prep.text.split('\n'))
          if (l.trim().isNotEmpty) l.trim()
      ],
    );
    setState(() {
      _apptsOf(p.hn).add(a);
      _apptDraft = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'บันทึกนัด ${p.name} · ${_apptDate(a.date)} ${a.start} น. แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  // ---- ช่องกรอกตามกติกา "ช่องกรอกในหน้าเต็ม": ป้ายบนช่อง w600 · พื้น _panelSoft · สูง 44

  Widget _apptLabel(String t, {bool must = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text.rich(TextSpan(children: [
          TextSpan(
              text: t, style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
          if (must)
            TextSpan(
                text: ' *',
                style: _t(10.5, color: _red, weight: FontWeight.w700)),
        ])),
      );

  Widget _apptBox(String text,
          {required bool filled,
          required IconData icon,
      required VoidCallback onTap,
      Widget? trailing}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 44.0,
          padding: const EdgeInsets.only(left: 12.0, right: 10.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: filled ? _blue.withValues(alpha: 0.5) : _line),
          ),
          child: Row(children: [
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.5,
                      color: filled ? _inkTitle : _g5,
                      weight: filled ? FontWeight.w600 : FontWeight.w500)),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 4),
            ],
            Icon(icon, size: 17.0, color: _ink3),
          ]),
        ),
      );

  Widget _apptSelect(String label, String? value, List<String> opts,
          void Function(String) set,
          {bool must = false, String? hint}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _apptLabel(label, must: must),
          _apptBox(value ?? (hint ?? 'เลือก$label'),
              filled: value != null,
              icon: Icons.expand_more_rounded, onTap: () async {
            final v = await _listSheet(label, opts, current: value);
            if (v != null && mounted) setState(() => set(v));
          }),
        ],
      );

  Widget _apptTextArea(TextEditingController c, String hint,
          {ValueChanged<String>? onChanged,
          int minLines = 3,
          int maxLines = 6,
          Widget? suffixIcon}) =>
      TextField(
        controller: c,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType:
            maxLines == 1 ? TextInputType.text : TextInputType.multiline,
        style: _t(12.0, height: 1.45),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon,
          hintStyle: _t(12.0, color: _g5),
          filled: true,
          fillColor: _panelSoft,
          contentPadding: const EdgeInsets.all(12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: _blue.withValues(alpha: 0.6)),
          ),
        ),
      );
}
