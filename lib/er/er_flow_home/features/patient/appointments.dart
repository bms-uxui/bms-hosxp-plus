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
    this.contact = '',
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

  /// จุดที่ผู้ป่วยต้องไปติดต่อเมื่อมาตามนัด
  final String contact;

  /// สิ่งที่ต้องปฏิบัติตัวก่อนพบแพทย์ (ข้อละบรรทัด)
  final List<String> prep;
}

/// ฟอร์มนัดหมายใหม่ที่กำลังกรอก
class _ApptDraft {
  _ApptDraft(this.hn, {this.editing});

  /// เปิดจากนัดเดิมเพื่อแก้ไข: เติมค่าเดิมทุกช่อง บันทึกแล้วแทนที่นัดเดิม
  factory _ApptDraft.edit(String hn, _Appt a) {
    TimeOfDay? tm(String s) {
      final p = s.split(':');
      if (p.length != 2) return null;
      final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
      return h == null || m == null ? null : TimeOfDay(hour: h, minute: m);
    }

    return _ApptDraft(hn, editing: a)
      ..date = a.date
      ..start = tm(a.start)
      ..end = tm(a.end)
      ..dept = a.dept
      ..clinic = a.clinic == a.dept ? null : a.clinic
      ..doctor = a.doctor.isEmpty ? null : a.doctor
      ..room = a.room.isEmpty ? null : a.room
      ..reason = a.reason
      ..contact = a.contact.isEmpty ? null : a.contact
      ..note.text = a.note
      ..prep.text = a.prep.join('\n');
  }

  /// ผู้ป่วยเจ้าของฟอร์ม (เปลี่ยนผู้ป่วยแล้วฟอร์มไม่ตามไป)
  final String hn;

  /// นัดเดิมที่กำลังแก้ (null = นัดใหม่)
  final _Appt? editing;
  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;
  String? dept;
  String? clinic;
  String? doctor;
  String? room;
  String? reason;
  String? contact;
  final TextEditingController note = TextEditingController();
  final TextEditingController prep = TextEditingController();

  /// คำค้นข้อความหมายเหตุสำเร็จรูป
  String noteQuery = '';

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

/// แท็บนัดหมาย: วันที่เลือก / เดือนที่ดูในปฏิทิน (ต่อ HN)
final Map<String, DateTime> _apptDay = {};
final Map<String, DateTime> _apptMonth = {};

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

/// การปฏิบัติตัวก่อนมาพบแพทย์ที่ตั้งค่าไว้กับห้องตรวจ (ข้อมูลตัวอย่าง)
const Map<String, List<String>> _apptRoomPrep = {
  'ห้องตรวจอายุรกรรม 1': [
    'งดน้ำงดอาหารหลังเวลา 20.00 น.',
    'นำยาเดิมที่ทานอยู่มาด้วย',
    'มาเจาะเลือดก่อนพบแพทย์ 1 ชั่วโมง',
  ],
  'ห้องตรวจอายุรกรรม 2': [
    'นำยาเดิมที่ทานอยู่มาด้วย',
    'วัดความดันโลหิตที่บ้านและจดบันทึกมาด้วย',
  ],
  'ห้องตรวจศัลยกรรม': [
    'ห้ามแผลโดนน้ำ',
    'นำฟิล์มเอกซเรย์เดิมมาด้วย',
  ],
  'ห้องตรวจกระดูก': [
    'นำฟิล์มเอกซเรย์เดิมมาด้วย',
    'ใส่เฝือก/อุปกรณ์พยุงมาตามเดิม',
    'หากปวดบวมมากขึ้นให้มาก่อนนัด',
  ],
  'ห้องทำแผล': [
    'ห้ามแผลโดนน้ำ',
    'มาตัดไหมตามวันนัด',
  ],
  '460 หอพิเศษเดี่ยวอายุรกรรมชั้น 4': [
    'งดน้ำงดอาหารหลังเวลา 20.00 น.',
    'มาก่อนเวลานัด 30 นาที',
  ],
};

/// ข้อความหมายเหตุสำเร็จรูปให้ค้นหาและเลือกใช้ (ข้อมูลตัวอย่าง)
const List<String> _apptNotePhrases = [
  'ติดตามผลเลือดที่ส่งจากห้องฉุกเฉิน',
  'ติดตามผลเอกซเรย์ / CT',
  'ติดตามผลเพาะเชื้อ',
  'ประเมินอาการหลังให้ยา',
  'ทบทวนยาและปรับขนาดยา',
  'ยาเดิมเพียงพอถึงวันนัด',
  'ให้ญาติมาด้วยในวันนัด',
  'ผู้ป่วยติดต่อยาก โทรยืนยันนัดก่อน 1 วัน',
  'หากอาการแย่ลงให้มาห้องฉุกเฉินได้ทันที',
  'นัดพร้อมผลตรวจจากโรงพยาบาลอื่น',
];

/// จุดติดต่อเมื่อมาตามนัด (ข้อมูลตัวอย่าง)
const List<String> _apptContacts = [
  'ห้องบัตร (เวชระเบียน)',
  'จุดคัดกรอง OPD',
  'จุดซักประวัติหน้าห้องตรวจ',
  'เคาน์เตอร์คลินิกพิเศษ',
  'ห้องเจาะเลือด / Lab',
  'ห้องเอกซเรย์',
  'ห้องฉุกเฉิน (ER)',
];

/// ข้อมูลพื้นฐานห้องตรวจ → แผนกที่ผูกไว้ (ห้องที่ไม่อยู่ในนี้ = ไม่ได้ผูกแผนก)
/// เลือกห้องแล้วเติมแผนกให้อัตโนมัติ แก้แผนกเองได้ถ้าไม่ถูก
const Map<String, String> _apptRoomDept = {
  'ห้องตรวจอายุรกรรม 1': 'อายุรกรรม',
  'ห้องตรวจอายุรกรรม 2': 'อายุรกรรม',
  'ห้องตรวจศัลยกรรม': 'ศัลยกรรม',
  'ห้องตรวจกระดูก': 'ศัลยกรรมกระดูก',
  '460 หอพิเศษเดี่ยวอายุรกรรมชั้น 4': 'อายุรกรรม',
};
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

  /// แท็บนัดหมาย (แผงซ้าย แสดงผลอย่างเดียว): หน้าข้อมูลแบบ EMR
  /// หัวหน้า + รูปประกอบ · ปฏิทินเดือน (จุด = มีนัด) · การ์ดนัดของวันที่เลือก
  /// ลง/แก้นัดที่แผง workflow ขั้นจำหน่าย
  Widget _apptTabBody() {
    final hn = _caseP().hn;
    final all = _apptsOf(hn);
    final today = _dayOnly(DateTime.now());
    // วันที่เลือกเริ่มต้น: นัดถัดไป (ไม่มี = วันนี้)
    final upcoming = [
      for (final a in all)
        if (!_dayOnly(a.date).isBefore(today)) _dayOnly(a.date)
    ]..sort();
    final day = _apptDay[hn] ?? (upcoming.isNotEmpty ? upcoming.first : today);
    final month = _apptMonth[hn] ?? DateTime(day.year, day.month);
    final onDay = [
      for (final a in all)
        if (_dayOnly(a.date) == day) a
    ]..sort((a, b) => a.start.compareTo(b.start));

    String or(String v) => v.trim().isEmpty ? '-' : v;
    final cards = <(String, List<(String, String, bool)>)>[
      for (final a in onDay)
        (
          a.clinic,
          [
            (
              'เวลา',
              a.end.isEmpty ? '${a.start} น.' : '${a.start} - ${a.end} น.',
              false
            ),
            ('แพทย์', or(a.doctor), false),
            ('แผนก', or(a.dept), false),
            ('ห้องตรวจ', or(a.room), false),
            ('เหตุที่นัด', or(a.reason), false),
            if (a.contact.isNotEmpty) ('ติดต่อที่', a.contact, false),
            if (a.note.isNotEmpty) ('หมายเหตุ', a.note, false),
            if (a.prep.isNotEmpty)
              (
                'ปฏิบัติตัวก่อนพบแพทย์',
                [for (final (i, x) in a.prep.indexed) '${i + 1}. $x']
                    .join('\n'),
                false
              ),
            ('ผู้ทำนัด', '${or(a.madeBy)} เมื่อ ${_apptDate(a.madeOn)}', false),
          ]
        ),
    ];
    final last = all.isEmpty
        ? null
        : (all.toList()..sort((a, b) => b.madeOn.compareTo(a.madeOn))).first;
    final days = day.difference(today).inDays;
    return _clyInfoPage(
      'นัดหมาย',
      'ลงหรือแก้นัดหมายได้ที่แผงขวา ขั้นจำหน่าย',
      'personal',
      cards,
      by: last == null ? '-' : or(last.madeBy),
      at: last == null ? '' : _apptDate(last.madeOn),
      lead: [
        _apptCalendar(hn, all, month, day, today),
        const SizedBox(height: 16.0),
        // หัววันที่เลือก
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: _apptDate(day),
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
            TextSpan(
                text: days == 0
                    ? '  วันนี้'
                    : (days > 0
                        ? '  อีก $days วัน'
                        : '  ผ่านมาแล้ว ${-days} วัน'),
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          ])),
        ),
      ],
      extra: [
        if (onDay.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text('ไม่มีนัดในวันนี้',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }

  /// ปฏิทินเดือน (แบบ Google Calendar): เลื่อนเดือน · วันนี้ = วงขอบ · วันที่เลือก = วงทึบ
  /// วันที่มีนัด = จุดใต้เลข (ที่จะถึง น้ำเงิน · ผ่านแล้ว เทา)
  Widget _apptCalendar(String hn, List<_Appt> all, DateTime month, DateTime day,
      DateTime today) {
    const months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    const wd = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    final has = <DateTime, int>{};
    for (final a in all) {
      final d = _dayOnly(a.date);
      has[d] = (has[d] ?? 0) + 1;
    }
    final first = DateTime(month.year, month.month);
    final lead = first.weekday % 7; // อาทิตย์ = 0
    final n = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((lead + n) / 7).ceil();
    void goMonth(int k) {
      HapticFeedback.selectionClick();
      setState(() => _apptMonth[hn] = DateTime(month.year, month.month + k));
    }

    Widget navBtn(IconData icon, VoidCallback onTap, String tip) => IconButton(
          onPressed: onTap,
          tooltip: tip,
          icon: Icon(icon, size: 22.0, color: _ink2),
        );

    Widget cell(int i) {
      final dn = i - lead + 1;
      if (dn < 1 || dn > n) return const SizedBox(height: 48.0);
      final d = DateTime(month.year, month.month, dn);
      final isSel = d == day;
      final isToday = d == today;
      final cnt = has[d] ?? 0;
      final pastDay = d.isBefore(today);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _apptDay[hn] = d);
        },
        child: SizedBox(
          height: 48.0,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34.0,
              height: 34.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSel
                    ? _blue
                    : (cnt > 0 ? _blue.withValues(alpha: 0.08) : null),
                shape: BoxShape.circle,
                border: isToday && !isSel
                    ? Border.all(color: _blue, width: 1.5)
                    : null,
              ),
              child: Text('$dn',
                  style: _num(14.0,
                      color: isSel
                          ? Colors.white
                          : (cnt > 0 ? _blue : (pastDay ? _ink3 : _inkTitle)),
                      weight: cnt > 0 || isSel || isToday
                          ? FontWeight.w700
                          : FontWeight.w500)),
            ),
            const SizedBox(height: 3.0),
            // จุดนัด (สูงสุด 3)
            SizedBox(
              height: 5.0,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (var k = 0; k < cnt.clamp(0, 3); k++)
                  Container(
                    width: 5.0,
                    height: 5.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                        color: pastDay ? _ink3 : _blue, shape: BoxShape.circle),
                  ),
              ]),
            ),
          ]),
        ),
      );
    }

    final thisMonth = month.year == today.year && month.month == today.month;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text('${months[month.month - 1]} ${month.year + 543}',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          if (!thisMonth)
            TextButton(
              onPressed: () => setState(() {
                _apptMonth[hn] = DateTime(today.year, today.month);
                _apptDay[hn] = today;
              }),
              child: Text('วันนี้',
                  style: _t(14.0, color: _blue, weight: FontWeight.w600)),
            ),
          navBtn(Icons.chevron_left_rounded, () => goMonth(-1), 'เดือนก่อน'),
          navBtn(Icons.chevron_right_rounded, () => goMonth(1), 'เดือนถัดไป'),
        ]),
        const SizedBox(height: 4.0),
        Row(children: [
          for (final (i, w) in wd.indexed)
            Expanded(
              child: Center(
                child: Text(w,
                    style: _t(12.5,
                        color: i == 0 ? _red.withValues(alpha: 0.8) : _ink3,
                        weight: FontWeight.w600)),
              ),
            ),
        ]),
        const SizedBox(height: 4.0),
        for (var r = 0; r < rows; r++)
          Row(children: [
            for (var c = 0; c < 7; c++) Expanded(child: cell(r * 7 + c)),
          ]),
      ]),
    );
  }

  // ------------------------------------------------ หน้านัดหมายในแผง workflow (ขั้นจำหน่าย)

  /// อยู่ในฟอร์มนัดของผู้ป่วยนี้ (หัวแผงเป็น breadcrumb · footer = ยกเลิก | บันทึก)
  bool get _apptEditing => _apptDraft?.hn == _caseP().hn;

  /// หน้าลงนัด: รายการนัดที่ยังไม่ถึง (แตะ = แก้) + แถวเพิ่มนัด · หรือฟอร์มนัด
  Widget _apptWfPage() {
    if (_apptEditing) {
      final d = _apptDraft!;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptForm(embedded: true),
            // แก้นัดเดิม: ลบได้ (ยืนยันก่อน)
            if (d.editing case final a?)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: TextButton.icon(
                  onPressed: () async {
                    await _apptDelete(a);
                    if (mounted && !_apptsOf(_caseP().hn).contains(a)) {
                      setState(() => _apptDraft = null);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _red,
                    backgroundColor: _red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    minimumSize: const Size(double.infinity, 48.0),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
                  label: Text('ลบนัดหมายนี้',
                      style: _t(14.0, color: _red, weight: FontWeight.w600)),
                ),
              ),
          ]);
    }
    final today = _dayOnly(DateTime.now());
    final next = [
      for (final a in _apptsOf(_caseP().hn))
        if (!_dayOnly(a.date).isBefore(today)) a
    ]..sort((a, b) => a.date.compareTo(b.date));
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, a) in next.indexed)
              _gListRow(
                first: i == 0,
                inset: 8.0,
                title: a.clinic,
                sub: [
                  '${_apptDate(a.date)} ${a.start} น.',
                  if (a.doctor.isNotEmpty) a.doctor,
                ].join('  '),
                onTap: () => setState(
                    () => _apptDraft = _ApptDraft.edit(_caseP().hn, a)),
                trail: IconButton(
                  onPressed: () => setState(
                      () => _apptDraft = _ApptDraft.edit(_caseP().hn, a)),
                  tooltip: 'แก้นัดหมายนี้',
                  iconSize: 20.0,
                  constraints:
                      const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                  icon: const Icon(Icons.edit_outlined, color: _ink3),
                ),
              ),
            _gListRow(
              first: next.isEmpty,
              inset: 8.0,
              lead: _gLead(Icons.add_rounded, size: 40.0),
              title: 'เพิ่มนัดหมาย',
              sub: next.isEmpty
                  ? 'ยังไม่มีนัดติดตาม เลือกวัน เวลา และคลินิก'
                  : 'เลือกวัน เวลา และคลินิก',
              onTap: () => setState(() => _apptDraft = _ApptDraft(_caseP().hn)),
              trail: const SizedBox.shrink(),
            ),
          ]),
    );
  }

  /// breadcrumb ของฟอร์มนัด: จำหน่าย › นัดหมายใหม่/แก้นัดหมาย · แตะส่วนแรก = กลับรายการ
  Widget _apptCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: () => setState(() => _apptDraft = null),
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('นัดหมาย',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
                _apptDraft?.editing == null ? 'นัดหมายใหม่' : 'แก้นัดหมาย',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// ปุ่มหลัก pill navy
  Widget _apptPrimaryBtn(IconData icon, String text, VoidCallback? onTap) =>
      _Press(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100.0),
          child: Container(
            height: 36.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              gradient: _glossGrad(onTap == null ? _blue4 : _blue),
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: onTap == null ? null : _glossLift(_blue),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 15.0, color: Colors.white),
              const SizedBox(width: 5.0),
              Text(text,
                  style:
                      _t(11.5, color: Colors.white, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// ลบนัดหลังยืนยัน (กันลบพลาด)
  Future<void> _apptDelete(_Appt a) async {
    final p = _caseP();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text('ลบการนัดหมายนี้?', style: _t(13.0, weight: FontWeight.w700)),
        content: Text(
            '${a.clinic}\n${_apptDate(a.date)} · ${a.start} น.\n'
            'ลบแล้วนัดนี้จะหายจากรายการของ ${p.name}',
            style: _t(11.5, color: _ink2, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _red),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  Text('ลบการนัดหมาย', style: _t(11.0, color: Colors.white))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _apptsOf(p.hn).remove(a));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ลบนัด ${_apptDate(a.date)} ${a.start} น. แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  // ------------------------------------------------ ฟอร์มบันทึกนัดหมาย

  /// [embedded] = อยู่ในแผง workflow: ไม่มีหัวฟอร์ม/การ์ดผู้ป่วย/ปุ่มบันทึก (footer แผงทำแทน)
  Widget _apptForm({bool embedded = false}) {
    final d = _apptDraft!;
    final p = _caseP();
    final missing = d.missing;
    Widget section(IconData icon, String title, List<Widget> body) => Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(icon, size: 13.0, color: _blue),
                ),
                const SizedBox(width: 8.0),
                Text(title,
                    style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8.0),
              ...body,
            ],
          ),
        );
    Widget two(Widget a, Widget b) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 8.0),
            Expanded(child: b),
          ],
        );
    final items = <Widget>[
      // หัวฟอร์ม: ย้อนกลับ · ชื่อ · คำอธิบาย
      Row(children: [
        InkWell(
          onTap: () => setState(() => _apptDraft = null),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _line, width: 0.5),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                size: 17.0, color: _blue),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.editing == null ? 'บันทึกนัดหมาย' : 'แก้ไขการนัดหมาย',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              Text(
                  d.editing == null
                      ? 'เลือกวัน เวลา และรายละเอียดการนัด'
                      : 'แก้ไขแล้วกดบันทึก นัดเดิมจะถูกแทนที่',
                  style: _t(9.5, color: _ink3)),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 8.0),
      // ผู้ป่วย
      Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12.0),
        child: Row(children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(Icons.person_rounded, size: 17.0, color: _blue),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
                Text('HN ${p.hn}', style: _t(9.5, color: _ink3)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text(d.editing == null ? 'นัดหมายใหม่' : 'แก้ไขนัด',
                style: _t(9.5, color: _blue, weight: FontWeight.w700)),
          ),
        ]),
      ),
      section(Icons.calendar_month_rounded, 'วันและเวลานัด', [
        // แถวเดียว: วันที่นัด · เวลาเริ่ม · เวลาสิ้นสุด
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _apptLabel('วันที่นัด', must: true),
                  _apptBox(
                    d.date == null ? 'เลือกวันที่' : _apptDate(d.date!),
                    filled: d.date != null,
                    must: true,
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final now = DateTime.now();
                      final v = await showDatePicker(
                        context: context,
                        initialDate: d.date ?? now.add(const Duration(days: 7)),
                        firstDate: _dayOnly(now),
                        lastDate: now.add(const Duration(days: 730)),
                      );
                      if (v != null && mounted) {
                        setState(() => d.date = v);
                      }
                    },
                  ),
                ]),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _apptLabel('เวลาเริ่ม', must: true),
                  _apptBox(
                      d.start == null ? '--:--' : '${_apptHm(d.start!)} น.',
                      filled: d.start != null,
                      must: true,
                      icon: Icons.schedule_rounded,
                      onTap: () => _apptPickTime(true)),
                ]),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _apptLabel('เวลาสิ้นสุด'),
                  _apptBox(d.end == null ? '--:--' : '${_apptHm(d.end!)} น.',
                      filled: d.end != null,
                      icon: Icons.schedule_rounded,
                      onTap: () => _apptPickTime(false)),
                ]),
          ),
        ]),
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
            }, size: 10.0),
        ]),
      ]),
      section(Icons.local_hospital_rounded, 'สถานที่และผู้ตรวจ', [
        two(
          _apptSelect('แผนก', d.dept, _apptDepts, (v) => d.dept = v,
              must: true),
          _apptSelect('คลินิก', d.clinic, _apptClinics, (v) => d.clinic = v),
        ),
        const SizedBox(height: 8.0),
        two(
          _apptSelect(
              'นัดพบแพทย์', d.doctor, _apptDoctors(), (v) => d.doctor = v,
              hint: 'เลือกแพทย์ หรือไม่ระบุ'),
          _apptSelect('ห้องตรวจ', d.room, _apptRooms, (v) {
            d.room = v;
            // ห้องที่ผูกแผนกไว้: เติมแผนกให้เลย (แก้ทีหลังได้)
            final dept = _apptRoomDept[v];
            if (dept != null && dept != d.dept) {
              d.dept = dept;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    content: Text(
                        'ตั้งแผนกเป็น "$dept" ตามห้องตรวจ · แก้ได้ที่ช่องแผนก',
                        style: _t(12.0, color: Colors.white))));
              });
            }
          }, hint: 'เลือกห้องตรวจ หรือไม่ระบุ'),
        ),
      ]),
      section(Icons.notes_rounded, 'รายละเอียดการนัด', [
        // แถวเดียว: เหตุที่นัด · ติดต่อที่
        two(
          _apptSelect('เหตุที่นัด', d.reason, _apptReasons, (v) => d.reason = v,
              must: true),
          _apptSelect(
              'ติดต่อที่', d.contact, _apptContacts, (v) => d.contact = v,
              hint: 'เลือกจุดติดต่อ หรือไม่ระบุ'),
        ),
        const SizedBox(height: 8.0),
        _apptLabel('หมายเหตุเพิ่มเติม'),
        // ค้นหาข้อความสำเร็จรูป แตะผลลัพธ์เพื่อเติมต่อท้ายหมายเหตุ
        TextField(
          onChanged: (v) => setState(() => d.noteQuery = v.trim()),
          style: _t(11.0),
          decoration: InputDecoration(
            hintText: 'ค้นหาข้อความหมายเหตุ เช่น "ผล", "ยา", "ญาติ"',
            hintStyle: _t(11.0, color: _g5),
            prefixIcon:
                const Icon(Icons.search_rounded, size: 16.0, color: _ink3),
            isDense: true,
            filled: true,
            fillColor: _panel,
            contentPadding: const EdgeInsets.symmetric(vertical: 9.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _blue.withValues(alpha: 0.6)),
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Builder(builder: (_) {
          final q = d.noteQuery.toLowerCase();
          final hits = [
            for (final s in _apptNotePhrases)
              if (q.isEmpty || s.toLowerCase().contains(q)) s
          ];
          if (hits.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                  'ไม่พบข้อความ "${d.noteQuery}" · พิมพ์ในช่องด้านล่างได้เลย',
                  style: _t(9.5, color: _ink3)),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final s in q.isEmpty ? hits.take(4) : hits)
                _optChip((d.note.text.contains(s) ? '✓ ' : '+ ') + s,
                    d.note.text.contains(s), false, () {
                  setState(() {
                    final cur = d.note.text.trim();
                    if (cur.contains(s)) return;
                    d.note.text = cur.isEmpty ? s : '$cur\n$s';
                  });
                }, size: 10.0),
            ]),
          );
        }),
        _apptTextArea(d.note, 'รายละเอียดที่ทีมรักษาควรทราบ…'),
      ]),
      section(Icons.checklist_rounded, 'คำแนะนำก่อนมาพบแพทย์', [
        // ตัวเลือกที่ตั้งค่าไว้กับห้องตรวจ: แตะเพื่อเพิ่ม/เอาออก
        if (_apptRoomPrep[d.room] case final presets?) ...[
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 13.0, color: _blue),
            const SizedBox(width: 4.0),
            Text('ตั้งค่าไว้ที่ ${d.room} · แตะเพื่อเพิ่ม',
                style: _t(10.0, color: _blue, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6.0),
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final s in presets)
              _optChip(
                  (_apptPrepLines(d).contains(s) ? '✓ ' : '+ ') + s,
                  _apptPrepLines(d).contains(s),
                  false,
                  () => setState(() => _apptTogglePrep(d, s)),
                  size: 10.0),
          ]),
          const SizedBox(height: 8.0),
        ],
        _apptLabel('การปฏิบัติตัว (บรรทัดละ 1 ข้อ · พิมพ์เพิ่มเองได้)'),
        _apptTextArea(d.prep, 'เช่น นำผลตรวจเดิมและรายการยามาด้วย'),
        const SizedBox(height: 8.0),
        // เพิ่มข้อความเองทีละข้อ
        Align(
          alignment: Alignment.centerLeft,
          child: _miniBtn(Icons.add_rounded, 'เพิ่มข้อ', () async {
            final v = await _voiceTextDialog(
              title: 'เพิ่มคำแนะนำก่อนมาพบแพทย์',
              initial: '',
              hint: 'พิมพ์ 1 ข้อ หรือแตะไมค์เพื่อพูด',
              okText: 'เพิ่ม',
            );
            final t = (v ?? '').replaceAll('\n', ' ').trim();
            if (t.isNotEmpty && mounted) {
              setState(() {
                if (!_apptPrepLines(d).contains(t)) {
                  _apptTogglePrep(d, t);
                }
              });
            }
          }, tooltip: 'เพิ่มคำแนะนำเป็นข้อความเอง'),
        ),
      ]),
    ];
    // 3 ชิ้นแรก = หัวฟอร์ม · ระยะ · การ์ดผู้ป่วย
    if (embedded) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: items.sublist(3));
    }
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 10.0),
          children: items,
        ),
      ),
      // ปุ่มหลักเต็มกว้างขอบล่าง: ยังไม่ครบ = บอกจำนวนช่องที่ขาด
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            // ปุ่มสั้น "บันทึก" · ยังไม่ครบ = กดไม่ได้ (ช่องที่ขาดขึ้นแดงในฟอร์มแล้ว)
            child: Tooltip(
              message: missing.isEmpty
                  ? (d.editing == null ? 'บันทึกนัดหมาย' : 'บันทึกการแก้ไข')
                  : 'ยังขาด: ${missing.join(', ')}',
              child: _apptPrimaryBtn(Icons.check_rounded, 'บันทึก',
                  missing.isEmpty ? _apptSave : null),
            ),
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

  /// การปฏิบัติตัวในช่อง (บรรทัดละข้อ)
  List<String> _apptPrepLines(_ApptDraft d) => [
        for (final l in d.prep.text.split('\n'))
          if (l.trim().isNotEmpty) l.trim()
      ];

  /// เพิ่มข้อ (ต่อท้าย) หรือเอาออกถ้ามีอยู่แล้ว (เรียกใน setState)
  void _apptTogglePrep(_ApptDraft d, String s) {
    final lines = _apptPrepLines(d);
    lines.contains(s) ? lines.remove(s) : lines.add(s);
    d.prep.text = lines.join('\n');
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
      contact: d.contact ?? '',
      // แก้ไข: คงผู้ทำนัด/วันที่ทำนัดเดิม
      madeBy: d.editing?.madeBy ?? ErSession.instance.user?.name ?? '',
      madeOn: d.editing?.madeOn ?? DateTime.now(),
      note: d.note.text.trim(),
      prep: [
        for (final l in d.prep.text.split('\n'))
          if (l.trim().isNotEmpty) l.trim()
      ],
    );
    final list = _apptsOf(p.hn);
    final at = d.editing == null ? -1 : list.indexOf(d.editing!);
    setState(() {
      if (at >= 0) {
        list[at] = a;
      } else {
        list.add(a);
      }
      _apptDraft = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            '${at >= 0 ? 'แก้ไขนัด' : 'บันทึกนัด'} ${p.name} · '
            '${_apptDate(a.date)} ${a.start} น. แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  // ---- ช่องกรอกแบบกระชับ (นัดหมาย · ใบรับรองแพทย์ · อุบัติเหตุ · คัดกรอง):
  // ป้ายบนช่อง w600 · พื้น _panelSoft · สูง 36 (ผู้ใช้ขอให้เล็กกว่าหน้าเต็มที่สูง 44)

  Widget _apptLabel(String t, {bool must = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Text.rich(TextSpan(children: [
          TextSpan(
              text: t, style: _t(9.5, color: _ink2, weight: FontWeight.w600)),
          if (must)
            TextSpan(
                text: ' *',
                style: _t(9.5, color: _red, weight: FontWeight.w700)),
        ])),
      );

  /// ช่องแตะเลือก · must = ช่องบังคับ: ยังว่างอยู่ = ขอบแดง + พื้นแดงจาง + ไอคอนเตือน
  Widget _apptBox(String text,
      {required bool filled,
      required IconData icon,
      required VoidCallback onTap,
      bool must = false,
      Widget? trailing}) {
    final missing = must && !filled;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 36.0,
        padding: const EdgeInsets.only(left: 10.0, right: 8.0),
        decoration: BoxDecoration(
          color: missing ? _red.withValues(alpha: 0.05) : _panelSoft,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: missing
                  ? _red.withValues(alpha: 0.7)
                  : (filled ? _blue.withValues(alpha: 0.5) : _line),
              width: missing ? 1.5 : 1.0),
        ),
        child: Row(children: [
          if (missing) ...[
            const Icon(Icons.error_outline_rounded, size: 16.0, color: _red),
            const SizedBox(width: 6.0),
          ],
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.5,
                    color: filled ? _inkTitle : (missing ? _red : _g5),
                    weight: filled ? FontWeight.w600 : FontWeight.w500)),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 4),
          ],
          Icon(icon, size: 15.0, color: missing ? _red : _ink3),
        ]),
      ),
    );
  }

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
              must: must,
              icon: Icons.expand_more_rounded, onTap: () async {
            final v = await _listSheet(label, opts, current: value);
            if (v != null && mounted) setState(() => set(v));
          }),
        ],
      );

  Widget _apptTextArea(TextEditingController c, String hint,
          {ValueChanged<String>? onChanged,
          int minLines = 2,
          int maxLines = 6,
          Widget? suffixIcon}) =>
      TextField(
        controller: c,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType:
            maxLines == 1 ? TextInputType.text : TextInputType.multiline,
        style: _t(11.0, height: 1.4),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon,
          hintStyle: _t(11.0, color: _g5),
          isDense: true,
          filled: true,
          fillColor: _panelSoft,
          contentPadding: const EdgeInsets.all(10.0),
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
