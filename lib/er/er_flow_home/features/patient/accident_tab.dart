// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ แท็บอุบัติเหตุ (แพทย์)
// ข้อมูลเหตุการณ์ที่พยาบาลคัดกรองบันทึกตอนรับเข้า ไว้ประกอบการดูแลเคสบาดเจ็บ
// ค่าที่แพทย์บันทึกเองในขั้น "อุบัติเหตุ" ของ workflow แทนที่ค่าจากจุดคัดกรอง

/// ลำดับของแท็บใน _detailTabs (ต่อท้าย ไม่ขยับเลขแท็บเดิม)
const int _accTab = 13;

/// ช่องของฟอร์มอุบัติเหตุ (ชื่อเดียวกับฟอร์ม accident ของจุดคัดกรอง)
const String _accHas = 'มีอุบัติเหตุหรือไม่';
const String _accPlace = 'สถานที่เกิดเหตุ';
const String _accType = 'ประเภทอุบัติเหตุ';
const String _accVehicle = 'ยานพาหนะ / ประเภทผู้บาดเจ็บ';
const String _accSafety = 'หมวกนิรภัย / เข็มขัดนิรภัย';
const String _accSubst = 'แอลกอฮอล์ / สารเสพติด';
const String _accPre = 'การดูแลก่อนมาถึง';

/// ข้อมูลจำลองจากจุดคัดกรอง: HN → (เวลาเกิดเหตุ, ช่องฟอร์ม)
const Map<String, (String, Map<String, String>)> _accSeed = {
  '670123469': (
    '09:10',
    {
      _accHas: 'มี',
      _accPlace: 'บนถนนสายหลัก ถ.มิตรภาพ หน้าตลาดเทศบาล',
      _accType: 'การขนส่ง V20-V29 ผู้ขับขี่รถจักรยานยนต์',
      _accVehicle: 'รถจักรยานยนต์ / ผู้ขับขี่',
      _accSafety: 'สวมหมวกนิรภัย / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ดามขาขวา ใส่ Collar ห้ามเลือดแผลศีรษะ',
    }
  ),
  '670123460': (
    '09:52',
    {
      _accHas: 'มี',
      _accPlace: 'บนถนนสายรอง ซอยวัดกลาง',
      _accType: 'การขนส่ง V20-V29 ผู้ขับขี่รถจักรยานยนต์',
      _accVehicle: 'รถจักรยานยนต์ / ผู้ขับขี่',
      _accSafety: 'ไม่สวมหมวกนิรภัย / -',
      _accSubst: 'ดื่มแอลกอฮอล์ (ได้กลิ่น) / ไม่ใช้',
      _accPre: 'ใส่ Collar ดามแขนซ้าย',
    }
  ),
  '670123458': (
    '09:30',
    {
      _accHas: 'มี',
      _accPlace: 'ที่บ้าน',
      _accType: 'พลัดตกหกล้ม W10 ตกบันได',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ไม่ได้รับการดูแล',
    }
  ),
  '670123466': (
    '08:40',
    {
      _accHas: 'มี',
      _accPlace: 'ที่ทำงาน (ร้านอาหาร)',
      _accType: 'ของมีคม W26 มีด',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'กดห้ามเลือดด้วยผ้าสะอาด',
    }
  ),
  '670123468': (
    '09:15',
    {
      _accHas: 'มี',
      _accPlace: 'ที่บ้าน (ห้องน้ำ)',
      _accType: 'พลัดตกหกล้ม W01 ลื่นล้มบนพื้นระดับเดียวกัน',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ประคบเย็น',
    }
  ),
  '670123474': (
    '08:20',
    {
      _accHas: 'มี',
      _accPlace: 'สนามฟุตบอลโรงเรียน',
      _accType: 'การบาดเจ็บจากกีฬา W03 ปะทะกับผู้อื่น',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ประคบเย็น ยกขาสูง',
    }
  ),
};

extension _FeaturesPatientAccidentTabPart on _ErFlowHomeWidgetState {
  /// แผงซ้ายของอุบัติเหตุ: มีข้อมูลจากฟอร์ม (กำลังกรอก/บันทึกแล้ว/ร่าง) = หน้าข้อมูลแบบหน้าอื่น
  /// (_clyInfoPage) อัปเดตตามฟอร์มทันที · ยังไม่มี = empty state
  Widget _accTabBody() => ValueListenableBuilder<int>(
      valueListenable: _accLiveTick,
      builder: (context, _, __) {
        final hn = _caseP().hn;
        final vals = _accLive[hn] ?? _accStore[hn] ?? _accDrafts[hn];
        // ยังไม่ได้บันทึกในฟอร์มอุบัติเหตุ = empty state (ไม่แสดงข้อมูลจากจุดคัดกรองแทน)
        if (vals == null || vals.isEmpty) {
          return _accEmpty('ยังไม่มีข้อมูลอุบัติเหตุ');
        }
        // ยังไม่ได้กรอกอะไรเอง (มีแต่คะแนนที่คำนวณจากสัญญาณชีพ) = empty state ไม่ใช่การ์ดขีดว่างทั้งหน้า
        final entered = vals.entries.any(
            (e) => !_accScores.contains(e.key) && e.value.trim().isNotEmpty);
        return entered
            ? _accRecordPage(vals, live: _accLive.containsKey(hn))
            : _accEmpty('ยังไม่มีข้อมูลอุบัติเหตุ');
      });

  Widget _accRecordPage(Map<String, String> v, {required bool live}) {
    final hn = _caseP().hn;
    String val(String k) => (v[k] ?? '').trim().isEmpty ? '-' : v[k]!.trim();
    List<(String, String, bool)> rows(Iterable<String> ks) => [
          for (final k in ks) (k, val(k), false),
        ];
    List<String> group(String t) => [
          for (final (g, _, fs) in _accGroups)
            if (g == t)
              for (final (l, _) in fs) l
        ];
    final story = (_accNarratives[hn] ?? '').trim();
    final iss = _accIssTone(v['ISS']);
    final rts = _accRtsTone(v['RTS']);
    // ข้อความยาว: การ์ดแบบเดียวกับการ์ดใน _clyInfoPage แต่เต็มความกว้าง (ไม่มีคอลัมน์ชื่อช่อง)
    Widget textCard(String name, String text) => Container(
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(name,
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 8.0),
            Text(text,
                style: _t(14.0,
                    color: _inkTitle, weight: FontWeight.w500, height: 1.5)),
          ]),
        );
    return _clyInfoPage(
      'อุบัติเหตุ',
      // คำอธิบายหน้า = หน้านี้มีอะไร (แบบหน้า Lab / X-ray / ค่าบริการ) ไม่ใช่สถานะการกรอก
      // ยังไม่บันทึก = บอกท้ายประโยคสั้น ๆ ให้รู้ว่ายังเป็นร่าง
      'เหตุการณ์ การมา และความรุนแรงของการบาดเจ็บครั้งนี้',
      'triage',
      [
        ('เหตุการณ์', rows([_accWhen, ...group('เหตุการณ์')])),
        ('ข้อมูลการมา', rows([for (final (l, _) in _accArrival) l])),
        (
          'ปัจจัยเสี่ยง',
          [
            for (final k in group('ปัจจัยเสี่ยง'))
              // ดื่ม/ใช้สาร/ไม่สวม/ไม่คาด = ความเสี่ยง (แดง)
              (
                k,
                val(k),
                RegExp(r'ดื่ม|ใช้|ไม่สวม|ไม่คาด').hasMatch(v[k] ?? '') &&
                    !RegExp(r'ไม่ดื่ม|ไม่ใช้').hasMatch(v[k] ?? '')
              ),
          ]
        ),
        (
          'Body Region (AIS)',
          [
            for (final r in _accRegions)
              (_accRegionArt[r]?.$1 ?? r, val(r), (_accAisOf(v[r]) ?? 0) >= 3),
          ]
        ),
        (
          'Trauma Score',
          [
            (
              'ISS',
              iss == null ? '-' : '${v['ISS']} · ${iss.$2}',
              (iss?.$1 ?? 0) >= 4
            ),
            (
              'RTS',
              rts == null ? '-' : '${v['RTS']} · ${rts.$2}',
              (rts?.$1 ?? 0) >= 4
            ),
            for (final k in ['GCS.v', 'BPs', 'RR', 'PS']) (k, val(k), false),
          ]
        ),
        (
          'การดูแลก่อนมาถึง',
          [
            ...rows(group('การดูแลก่อนมาถึง')),
            if (val(_accPreNote) != '-') (_accPreNote, val(_accPreNote), false),
          ]
        ),
        if (val('หมายเหตุ') != '-')
          ('หมายเหตุ', [('', val('หมายเหตุ'), false)]),
      ],
      heroArt: Image.asset('assets/images/er_ov_emergent_fig.png',
          filterQuality: FilterQuality.medium),
      // ไม่ใช่ข้อมูลของผู้บันทึกคัดกรอง: ไม่แสดงบรรทัด "บันทึกโดย" (ยังไม่มีผู้บันทึกจริง)
      by: '-',
      lead: [
        if (story.isNotEmpty) ...[
          textCard('เล่าเหตุการณ์', story),
          const SizedBox(height: 12.0)
        ],
      ],
      extra: [
        if (val('หมายเหตุ') != '-') textCard('หมายเหตุ', val('หมายเหตุ')),
      ],
    );
  }

  /// empty state ชุดเดียวกับหน้าคำสั่งแพทย์ (ภาพคลิปบอร์ดโทนเทา + หัวข้อ + บอกว่าเริ่มที่ไหน)
  Widget _accEmpty(String text) => _soEmpty(
      text,
      'เริ่มบันทึกได้ที่เมนู "อุบัติเหตุ" ทางขวา\n'
      'เล่าเหตุการณ์ให้ AI ช่วยกรอก หรือกรอกเองทีละหัวข้อ',
      heading: 'อุบัติเหตุ');
}

// ------------------------------------------------ แท็บ X-ray
// ประวัติการสั่ง X-ray ทุกครั้งที่มา (ER-6102) แบบหน้าการสั่ง X-ray ของ HOSxP:
// รายการใบสั่งตามช่วงเวลา → แตะใบ → ภาพฟิล์ม + ผลอ่าน + เปิดดูใน PACS
// โครงหน้าเดียวกับหน้าผล Lab (breadcrumb · หัววัน · เหรียญสถานะ · timeline sheet)

/// ลำดับของแท็บใน _detailTabs (ต่อท้าย ไม่ขยับเลขแท็บเดิม)
const int _xrayTab = 14;

/// ใบสั่ง X-ray 1 ใบ · stage 0 สั่งแล้ว · 1 รับตัว · 2 ฉายรังสี · 3 อ่านฟิล์ม · 4 ยืนยันผล
/// นาที (recv/shot/read/confirm) นับจากเวลาสั่ง
typedef _XrOrder = ({
  String no,
  String date,
  String time,
  String place,
  String by,
  int visit,
  String item,
  String side,
  String pose,
  int stage,
  String finding,
  String impression,
  String reader,
  List<ErImage> films,
  int recv,
  int shot,
  int read,
  int confirm,
});

/// ใบที่เปิดดูอยู่ ('hn|เลขที่สั่ง') · null = หน้ารายการ
final ValueNotifier<String?> _xrOpen = ValueNotifier(null);

/// ช่วงเวลาที่เลือก (index ของ _xrRanges)
var _xrRange = 0;

/// ช่วงเวลาแบบตัวกรองประวัติ X-ray ของ HOSxP (วัน · -1 = เฉพาะครั้งนี้)
const _xrRanges = [
  ('ครั้งนี้', -1),
  ('2 เดือน', 60),
  ('1 ปี', 365),
  ('3 ปี', 1095),
];

const _xrSteps = ['ส่งคำสั่ง', 'รับตัว', 'ฉายรังสี', 'อ่านฟิล์ม', 'ยืนยันผล'];

/// ไอคอนบนเหรียญตามขั้น: ส่ง (เครื่องบินกระดาษ) · คนไข้ · ชัตเตอร์ถ่ายภาพ · ตา · ตรายืนยัน
const _xrStepIcons = [
  'ph-paper-plane-tilt',
  'ph-user',
  'ph-aperture',
  'ph-eye',
  'ph-seal-check',
];

// ค่าจำลองประวัติครั้งก่อน (รอดึงจาก HOSxP xray_report / PACS)
const _xrCxr = 'assets/images/xray/cxr.jpg';
const _xrCxrLat = 'assets/images/xray/cxr_lat.jpg';
const _xrCt = 'assets/images/xray/ct_brain.png';
const _xrReaders = ['พญ. ณัฐธิดา ศรีสุข', 'นพ. ปกรณ์ วงศ์ไทย'];

/// คำบรรยายผลอ่านตามชนิดภาพ (findings) · ผลสรุปมาจาก impression
String _xrFindingOf(String item, String impression) {
  final normal = _xrNormal(impression);
  if (item.startsWith('CT')) {
    return normal
        ? 'No intracranial hemorrhage. No mass effect or midline shift. '
            'Ventricles and sulci are normal for age.'
        : 'Hypodensity at left MCA territory. No hemorrhagic transformation. '
            'No midline shift.';
  }
  return normal
      ? 'No active pulmonary infiltration. Heart size is within normal limit. '
          'Both costophrenic angles are sharp.'
      : 'Increased opacity at the affected area. '
          'Clinical correlation is recommended.';
}

bool _xrNormal(String impression) =>
    RegExp(r'^ปกติ|normal|ไม่พบ', caseSensitive: false).hasMatch(impression);

extension _FeaturesPatientXrayTabPart on _ErFlowHomeWidgetState {
  /// วันที่ dd/mm/yyyy (พ.ศ.) → DateTime
  DateTime? _xrDay(String d) {
    final p = d.split('/');
    if (p.length != 3) return null;
    final y = int.tryParse(p[2]);
    final m = int.tryParse(p[1]);
    final dd = int.tryParse(p[0]);
    if (y == null || m == null || dd == null) return null;
    return DateTime(y > 2400 ? y - 543 : y, m, dd);
  }

  String _xrDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year + 543}';

  /// ใบสั่ง X-ray ทุกครั้งที่มา ใหม่ → เก่า
  /// ครั้งนี้ = ภาพรังสีของเคส (รวมท่าของภาพชนิดเดียวกันเป็นใบเดียว) + คำสั่ง X-ray ที่ยังไม่ทำ
  /// ครั้งก่อน = ค่าจำลองต่อ HN (วันที่ย้อนจากวันนี้)
  List<_XrOrder> _xrOrders() {
    final c = erCaseOf(_caseP().hn);
    final out = <_XrOrder>[];
    final visits = erLabVisits(c);
    final today = visits.first.date;
    final todayD = _xrDay(today) ?? DateTime(2026, 9, 23);
    int hash(String s) =>
        s.codeUnits.fold<int>(7, (a, x) => (a * 31 + x) % 9973);
    final me = ErSession.instance.user?.name ?? 'แพทย์เวร';
    final rounds = _soRoundsOf(c.hn);

    // คำสั่ง X-ray ในคำสั่งแพทย์ครั้งนี้ที่ยังไม่ทำ = ใบรอรับตัว
    for (final r in rounds) {
      for (final (name, _, st, _) in r.items) {
        if (_soRoundCatOf(r, name) != 'X-ray' || _soOk(r, name, st)) continue;
        out.add((
          no: '${680000 + hash('${r.time}|$name') % 9000}',
          date: today,
          time: r.time,
          place: 'ER',
          by: r.by,
          visit: 0,
          item: name,
          side: '-',
          pose: name.contains('PA') || name.contains('Chest') ? 'PA' : 'AP',
          stage: 0,
          finding: '',
          impression: '',
          reader: '',
          films: const [],
          recv: 0,
          shot: 0,
          read: 0,
          confirm: 0,
        ));
      }
    }

    // ภาพของเคส: ชุดเดียวกับค่าบริการ (erXrayStudies) รวมท่าเป็นใบเดียว
    final by = rounds.isNotEmpty ? rounds.last.by : me;
    for (final st in erXrayStudies(c)) {
      final base = st.base;
      final imgs = st.films;
      final poses = [
        for (final i in imgs)
          if (i.name.contains('(')) i.name.split('(').last.replaceAll(')', '')
      ];
      final wait = imgs.any((i) => i.result.contains('รอ'));
      final imp = wait ? '' : {for (final i in imgs) i.result}.join(', ');
      final h = hash('${c.hn}|$base');
      final item = st.item;
      out.add((
        no: '${680000 + h % 9000}',
        date: today,
        time: st.time,
        place: 'ER',
        by: by,
        visit: 0,
        item: item,
        side: base.contains('ankle') ? 'ขวา' : '-',
        pose: poses.isEmpty
            ? (base.startsWith('CT') ? 'Axial' : 'AP')
            : poses.join(', '),
        stage: wait ? 2 : 4,
        finding: wait ? '' : _xrFindingOf(item, imp),
        impression: imp,
        reader: wait ? '' : _xrReaders[h % 2],
        films: imgs,
        recv: 6 + h % 8,
        shot: 14 + h % 10,
        read: 40 + h % 30,
        confirm: 52 + h % 30,
      ));
    }

    // ครั้งก่อน (ค่าจำลอง): 2 ครั้ง ย้อน 1-2 เดือน และ 1-2 ปี
    final hh = hash(c.hn);
    final past = [
      (
        35 + hh % 20,
        'OPD อายุรกรรม',
        [
          ('Chest X-ray', 'PA', [_xrCxr], 'ปกติ')
        ]
      ),
      (
        420 + hh % 300,
        'OPD ศัลยกรรม',
        [
          ('Chest X-ray', 'PA, Lat', [_xrCxr, _xrCxrLat], 'ปกติ'),
          if (hh % 2 == 0)
            ('CT brain', 'Axial', [_xrCt], 'No acute intracranial abnormality'),
        ]
      ),
    ];
    for (final (vi, (ago, place, items)) in past.indexed) {
      final d = _xrDate(todayD.subtract(Duration(days: ago)));
      for (final (si, (item, pose, assets, imp)) in items.indexed) {
        final h = hash('${c.hn}|$d|$item');
        final films = [
          for (final (k, a) in assets.indexed)
            ErImage(
                '$item (${pose.split(', ')[k.clamp(0, pose.split(', ').length - 1)]})',
                imp,
                a)
        ];
        out.add((
          no: '${670000 + h % 9000}',
          date: d,
          time:
              '${(9 + h % 3).toString().padLeft(2, '0')}:${(10 + h % 45).toString().padLeft(2, '0')}',
          place: place,
          by: const ['นพ. ธีรภัทร อ.', 'พญ. ศิริพร กิตติวงศ์'][(h + si) % 2],
          visit: vi + 1,
          item: item,
          side: '-',
          pose: pose,
          stage: 4,
          finding: _xrFindingOf(item, imp),
          impression: imp,
          reader: _xrReaders[h % 2],
          films: films,
          recv: 10 + h % 10,
          shot: 18 + h % 12,
          read: 90 + h % 60,
          confirm: 120 + h % 60,
        ));
      }
    }
    return out;
  }

  /// ใบในช่วงเวลาที่เลือก
  List<_XrOrder> _xrInRange(List<_XrOrder> all) {
    final days = _xrRanges[_xrRange].$2;
    if (days < 0) {
      return [
        for (final o in all)
          if (o.visit == 0) o
      ];
    }
    final today = _xrDay(all.isEmpty ? '' : all.first.date);
    return [
      for (final o in all)
        if (today == null ||
            today.difference(_xrDay(o.date) ?? today).inDays <= days)
          o
    ];
  }

  String _xrDept(_XrOrder o) => o.place == 'ER' ? 'ห้องฉุกเฉิน (ER)' : o.place;

  String _xrStageText(int s) => switch (s) {
        0 => 'รอรับตัว',
        1 => 'รอฉายรังสี',
        2 => 'รออ่านฟิล์ม',
        3 => 'รอยืนยันผล',
        _ => 'ยืนยันผลแล้ว',
      };

  /// ใต้ชื่อใบที่ยังไม่ยืนยันผล: บอกขั้นที่ทำเสร็จล่าสุดพร้อมเวลา แล้วสิ่งที่รอ
  /// (มีภาพแต่ยังไม่มีผลอ่าน = ฉายแล้ว รอรังสีแพทย์อ่าน)
  String _xrWaitText(_XrOrder o) {
    String at(int m) => _clock(_labHm(o.time, m));
    return switch (o.stage) {
      0 => 'รอรับตัว สั่งเมื่อ ${_labThDate(o.date)} ${_clock(o.time)}',
      1 => 'รับตัวแล้ว ${at(o.recv)} รอฉายรังสี',
      2 => 'ฉายรังสีแล้ว ${at(o.shot)} รอรังสีแพทย์อ่านผล',
      _ => 'อ่านผลแล้ว ${at(o.read)} รอยืนยันผล',
    };
  }

  /// ค่าบริการ + สถานะชำระ (ราคาชุดเดียวกับหน้าค่าบริการ erXrayPrice) · ยังไม่ฉาย = ยังไม่คิดเงิน
  /// ครั้งก่อน = ชำระแล้ว · ครั้งนี้ = เบิกตามสิทธิ หรือรอชำระถ้าจ่ายเอง (ค่าจำลอง)
  (String, String)? _xrPay(_XrOrder o) {
    if (o.stage < 2 || o.films.isEmpty) return null;
    final ct = o.item.startsWith('CT');
    final q = ct ? 1 : o.films.length;
    final p = erXrayPrice[o.item] ?? (ct ? 2500.0 : 200.0);
    final right = erCaseOf(_caseP().hn).right.trim();
    return (
      '${(p * q).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')} บาท'
          '${q > 1 ? ' ($q ท่า)' : ''}',
      o.visit > 0
          ? 'ชำระแล้ว'
          : right == 'จ่ายเอง'
              ? 'รอชำระ ผู้ป่วยชำระเอง'
              : 'เบิกตามสิทธิ${right.isEmpty ? '' : right}',
    );
  }

  /// เวลาของแต่ละขั้น (ขั้นที่ยังไม่ถึง = null)
  List<String?> _xrTimes(_XrOrder o) => [
        o.time,
        for (final (k, m) in [o.recv, o.shot, o.read, o.confirm].indexed)
          k + 1 <= o.stage ? _labHm(o.time, m) : null,
      ];

  Widget _xrayTabBody() {
    return ValueListenableBuilder<String?>(
      valueListenable: _xrOpen,
      builder: (context, open, _) {
        final hn = _caseP().hn;
        final all = _xrOrders();
        final o = all.where((x) => '$hn|${x.no}' == open).firstOrNull;
        if (o != null) return _xrDetail(o);
        final shown = _xrInRange(all);
        return _clyInfoPage(
            'X-ray', 'ภาพรังสีและผลอ่านทุกครั้งที่มา', 'xray', const [],
            by: '-',
            heroArt: SizedBox.square(
              dimension: 200.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48.0, 32.0, 24.0, 6.0),
                child: Image.asset('assets/images/er_os_xray.png',
                    fit: BoxFit.contain, alignment: Alignment.bottomRight),
              ),
            ),
            below: Transform.translate(
              offset: const Offset(-12.0, 0.0),
              child: _xrRangeTabs(),
            ),
            extra: [
              KeyedSubtree(
                key: ValueKey('xr-orders$_xrRange'),
                child: shown.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(children: [
                          Text(
                              _xrRange == 0
                                  ? 'ครั้งนี้ยังไม่ได้สั่ง X-ray'
                                  : 'ไม่มีการสั่ง X-ray ในช่วงนี้',
                              style: _t(14.0,
                                  color: _ink2, weight: FontWeight.w600)),
                          if (_xrRange == 0 && all.isNotEmpty) ...[
                            const SizedBox(height: 4.0),
                            Text('เลือกช่วงเวลาด้านบนเพื่อดูภาพครั้งก่อน',
                                style: _t(13.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ],
                        ]),
                      )
                    : _xrOrderList(shown),
              ),
            ]);
      },
    );
  }

  /// แท็บช่วงเวลา: ขีดใต้แบบแถบวันของหน้าผล Lab
  Widget _xrRangeTabs() {
    Widget tab(int i, String label) {
      final on = i == _xrRange;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _xrRange = i);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: _num(14.0,
                            color: on ? _blue : _ink2,
                            weight: on ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: on ? _blue : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3.0)),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final (i, (label, _)) in _xrRanges.indexed) tab(i, label),
      ]),
    );
  }

  /// รายการใบสั่งจัดตามวันที่มา: แถวละใบ (เหรียญสถานะ · ชื่อ · ท่า เวลา แผนก · ภาพย่อ)
  Widget _xrOrderList(List<_XrOrder> orders) {
    final hn = _caseP().hn;
    final visits = <int, List<_XrOrder>>{};
    for (final o in orders) {
      (visits[o.visit] ??= []).add(o);
    }

    Widget row(_XrOrder o, int i, bool first) {
      final bad = o.stage == 4 && !_xrNormal(o.impression);
      return Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        shape: first
            ? const RoundedRectangleBorder()
            : const Border(top: BorderSide(color: _line)),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _xrOpen.value = '$hn|${o.no}';
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 12.0),
            child: Row(children: [
              SizedBox.square(
                dimension: 40.0,
                child: Center(
                  child: _CoinPop(
                    index: i,
                    child: bad
                        ? const _SoStatusCoin.abnormal()
                        : o.stage == 0
                            ? const _SoStatusCoin.wait()
                            : o.stage < 4
                                ? const _SoStatusCoin.lab()
                                : const _SoStatusCoin.result(),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.side == '-' ? o.item : '${o.item} ${o.side}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(15.0, color: _ink, weight: FontWeight.w600)),
                      const SizedBox(height: 2.0),
                      Text('ท่า ${o.pose} • ${_clock(o.time)} • ${_xrDept(o)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(13.0, color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
              if (o.stage < 4 || bad) ...[
                const SizedBox(width: 12.0),
                Text(bad ? 'ผิดปกติ' : _xrStageText(o.stage),
                    style: _t(13.0,
                        color: bad ? _labWarn : _ink3,
                        weight: FontWeight.w600)),
              ],
              // ภาพย่อฟิล์มแรก (พื้นดำ) ให้จำใบได้จากภาพ
              if (o.films.isNotEmpty) ...[
                const SizedBox(width: 12.0),
                Container(
                  width: 44.0,
                  height: 44.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Image.asset(o.films.first.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ],
              const SizedBox(width: 4.0),
              const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
            ]),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (vi, xs) in visits.values.indexed) ...[
        Padding(
          padding: EdgeInsets.fromLTRB(4.0, vi == 0 ? 2.0 : 18.0, 4.0, 8.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Text(
                  xs.first.visit == 0
                      ? 'ภาพรังสีครั้งนี้ ${_labThDate(xs.first.date)}'
                      : 'ภาพรังสีวันที่ ${_labThDate(xs.first.date)}',
                  style: _t(13.5, color: _ink2, weight: FontWeight.w700)),
            ),
            if ({for (final o in xs) o.by}.length == 1)
              Text('สั่งโดย ${xs.first.by}',
                  style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ]),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, o) in xs.indexed)
              _Appear(index: i, child: row(o, i, i == 0)),
          ]),
        ),
      ],
    ]);
  }

  /// สถานะใบมุมขวาบน (เหรียญ + คำ ไม่มีพื้น) · แตะ = ลำดับงานรังสี 5 ขั้น
  Widget _xrStatusBadge(_XrOrder o) => Builder(
        builder: (bctx) => Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              showModalBottomSheet<void>(
                context: bctx,
                useRootNavigator: true,
                backgroundColor: _panel,
                constraints: const BoxConstraints(maxWidth: 560.0),
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0))),
                builder: (sctx) => SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 12.0, 16.0, 20.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text('ลำดับงานรังสี',
                                  style: _t(17.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                            ),
                            IconButton(
                              tooltip: 'ปิด',
                              onPressed: () => Navigator.pop(sctx),
                              icon: const Icon(Icons.close_rounded,
                                  size: 22.0, color: _ink2),
                            ),
                          ]),
                          const SizedBox(height: 8.0),
                          _soLabTrack(_xrSteps, o.stage, _xrTimes(o),
                              icons: _xrStepIcons),
                          const SizedBox(height: 8.0),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
              height: 32.0,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox.square(
                  dimension: 20.0,
                  child: FittedBox(
                      child: o.stage == 4
                          ? const _SoStatusCoin.done()
                          : const _SoStatusCoin.lab()),
                ),
                const SizedBox(width: 6.0),
                Text(_xrStageText(o.stage),
                    style: _t(13.0, color: _ink, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      );

  /// หน้าใบสั่ง 1 ใบ: ภาพฟิล์ม + ปุ่มดูใน PACS → ผลอ่าน → รายละเอียดใบสั่ง
  Widget _xrDetail(_XrOrder o) {
    final done = o.stage == 4;
    final bad = done && !_xrNormal(o.impression);
    final conf = o.confirm;
    String after(int m) =>
        '${m >= 60 ? '${m ~/ 60} ชม. ' : ''}${m % 60} นาทีหลังสั่ง';

    // ฟิล์ม: แถวละ 2 ภาพ พื้นดำ แตะ = เต็มจอ ซูมได้
    Widget film(int i) => _Press(
          child: GestureDetector(
            onTap: () => _xrayView(o.films, i),
            child: Container(
              height: 220.0,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.0)),
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(o.films[i].asset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: _g4))),
                Positioned(
                  left: 8.0,
                  bottom: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(100.0)),
                    child: Text(
                        o.films[i].name.contains('(')
                            ? o.films[i].name
                                .split('(')
                                .last
                                .replaceAll(')', '')
                            : o.pose,
                        style: _t(12.0,
                            color: Colors.white, weight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        );

    final films = o.films.isEmpty
        ? Container(
            height: 120.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(12.0)),
            child: Text(
                o.stage < 2 ? 'ยังไม่มีภาพ รอฉายรังสี' : 'ภาพยังไม่เข้า PACS',
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          )
        : LayoutBuilder(builder: (context, box) {
            const gap = 8.0;
            final per = box.maxWidth >= 2 * 220.0 + gap ? 2 : 1;
            return Column(children: [
              for (var r = 0; r < o.films.length; r += per)
                Padding(
                  padding: EdgeInsets.only(top: r == 0 ? 0.0 : gap),
                  child: Row(children: [
                    for (var k = 0; k < per; k++) ...[
                      if (k > 0) const SizedBox(width: gap),
                      Expanded(
                          child: r + k < o.films.length
                              ? film(r + k)
                              : const SizedBox.shrink()),
                    ],
                  ]),
                ),
            ]);
          });

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
        child: Row(children: [
          _CrumbPrev('X-ray', onTap: () {
            HapticFeedback.selectionClick();
            _xrOpen.value = null;
          }),
          const _CrumbSep(),
          Expanded(
            child: Text('${o.item}  #${o.no}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 8.0),
          _xrStatusBadge(o),
        ]),
      ),
      Expanded(
        child: ListView(
          key: ValueKey('xr-${o.no}'),
          padding: const EdgeInsets.all(12.0),
          children: [
            // การ์ดภาพ: ชื่อ + เวลายืนยันผล · ฟิล์ม · เปิดใน PACS (ปุ่มหลักของหน้า)
            _Appear(
              index: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(o.side == '-' ? o.item : '${o.item} ${o.side}',
                          style: _t(17.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      const SizedBox(height: 2.0),
                      Text(
                          done
                              ? 'ยืนยันผล ${_labThDate(o.date)} ${_clock(_labHm(o.time, conf))} (${after(conf)})'
                              : _xrWaitText(o),
                          style:
                              _t(13.0, color: _ink3, weight: FontWeight.w500)),
                      const SizedBox(height: 12.0),
                      films,
                      if (o.films.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        SizedBox(
                          height: 44.0,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                          'ยังไม่ได้เชื่อมต่อ PACS ของโรงพยาบาล')));
                            },
                            icon: const Icon(Icons.open_in_new_rounded,
                                size: 18.0, color: _ink),
                            label: Text('ดูภาพใน PACS',
                                style: _t(14.0,
                                    color: _ink, weight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFC4C7CC)),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ]),
              ),
            ),
            const SizedBox(height: 12.0),
            // ผลอ่าน: คำบรรยาย + สรุป (ผิดปกติ = สีเตือน) + รังสีแพทย์
            _Appear(
              index: 1,
              child: _labCard('ผลอ่าน', [
                if (o.stage < 3)
                  Text('ยังไม่มีผลอ่าน รอรังสีแพทย์อ่านฟิล์ม',
                      style: _t(14.0, color: _ink3, weight: FontWeight.w500))
                else ...[
                  Text(o.finding,
                      style: _t(14.0,
                          color: _ink, weight: FontWeight.w500, height: 1.5)),
                  const SizedBox(height: 12.0),
                  Text('สรุปผล',
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(height: 2.0),
                  Text(o.impression,
                      style: _t(15.0,
                          color: bad ? _labWarn : _inkTitle,
                          weight: FontWeight.w700)),
                  const SizedBox(height: 12.0),
                  Text(
                      'อ่านโดย ${o.reader} รังสีแพทย์ ${_clock(_labHm(o.time, o.read))}',
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                ],
              ]),
            ),
            const SizedBox(height: 12.0),
            _Appear(
              index: 2,
              child: _labCard('รายละเอียดใบสั่ง', [
                _soKvGrid([
                  _soKv('เลขที่สั่ง', o.no),
                  _soKv('สั่งเมื่อ', '${_labThDate(o.date)} ${_clock(o.time)}'),
                  _soKv('ผู้สั่ง', o.by),
                  _soKv('แผนกที่สั่ง', _xrDept(o)),
                  if (o.side != '-') _soKv('ด้าน', o.side),
                  _soKv('ท่า', o.pose),
                  if (o.stage >= 2)
                    _soKv('ฉายรังสี', _clock(_labHm(o.time, o.shot))),
                  if (done)
                    _soKv('ยืนยันผล',
                        '${_clock(_labHm(o.time, conf))} (${after(conf)})'),
                  if (_xrPay(o) case (final fee, final st)) ...[
                    _soKv('ค่าบริการ', fee),
                    _soKv('การชำระเงิน', st),
                  ],
                ]),
              ]),
            ),
          ],
        ),
      ),
    ]);
  }

  /// ดูภาพเต็มจอ ปัดเลื่อนภาพ · หนีบซูมได้
  void _xrayView(List<ErImage> imgs, int start) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      // Material โปร่ง: IconButton ใน dialog ต้องมี Material ancestor (ไม่งั้นจอแดง)
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          PageView.builder(
            controller: PageController(initialPage: start),
            itemCount: imgs.length,
            itemBuilder: (_, i) => Column(children: [
              Expanded(
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: Center(child: Image.asset(imgs[i].asset)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 28.0),
                child: Text('${imgs[i].name}  ${imgs[i].result}',
                    textAlign: TextAlign.center,
                    style:
                        _t(13.0, color: Colors.white, weight: FontWeight.w600)),
              ),
            ]),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
