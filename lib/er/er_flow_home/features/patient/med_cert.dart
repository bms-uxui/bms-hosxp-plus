// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// แท็บ "ใบรับรองแพทย์" ในหน้าผู้ป่วย: ประวัติการออกใบรับรอง + ออกใบรับรองใหม่
// ฟอร์ม 3 ส่วน (ประเภทเอกสาร · การตรวจและระยะพัก · วินิจฉัยและคำแนะนำ) คู่กับตัวอย่างเอกสาร
// ที่อัปเดตขณะกรอก · ทุกช่องข้อความพูดได้ (ไมค์ในช่อง) · ชิปเติมเร็วจากเวชระเบียนของเคส

/// ลำดับของแท็บใน _detailTabs
const int _mcTab = 12;

/// รูปแบบใบรับรองแพทย์
const List<String> _mcTypes = [
  'ใบรับรองแพทย์ลาป่วย',
  'ใบรับรองแพทย์ลาป่วย IPD',
  'ใบรับรองแพทย์ทั่วไป (สมัครงาน / ศึกษาต่อ)',
  'ใบรับรองแพทย์ 5 โรค',
  'ใบรับรองการเจ็บป่วย (ประกัน)',
];

/// ข้อแนะนำที่ใช้บ่อย (แตะเพื่อต่อท้าย)
const List<String> _mcAdviceChips = [
  'ควรพักรักษาตัว',
  'รับประทานยาตามแพทย์สั่ง',
  'มาตรวจตามนัด',
  'งดทำงานหนัก',
  'หากอาการไม่ดีขึ้นให้มาพบแพทย์',
];

/// ใบรับรองแพทย์ที่ออกแล้ว (หรือกำลังร่าง ใช้แสดงตัวอย่าง)
class _MedCert {
  const _MedCert({
    required this.no,
    required this.type,
    required this.doctor,
    required this.issued,
    required this.thaiName,
    required this.symptoms,
    required this.from,
    required this.to,
    required this.dx,
    required this.dxCode,
    required this.advice,
    required this.note,
    required this.draft,
    this.issuedBy = '',
  });

  /// แพทย์ที่ login ตอนออกใบรับรอง (มีสิทธิ์แก้ไขใบนี้คนเดียว)
  final String issuedBy;

  final String no;
  final String type;
  final String doctor;
  final DateTime issued;

  /// true = แสดงชื่อโรคภาษาไทย/ข้อความ แทนรหัส ICD-10
  final bool thaiName;
  final String symptoms;
  final DateTime from;
  final DateTime to;
  final String dx;
  final String? dxCode;
  final String advice;
  final String note;
  final bool draft;

  /// จำนวนวันพัก (รวมวันเริ่มและวันสิ้นสุด)
  int get days => _dayOnly(to).difference(_dayOnly(from)).inDays + 1;

  /// การวินิจฉัยตามที่จะพิมพ์ลงเอกสาร
  String get dxShown =>
      thaiName || dxCode == null || dx.isEmpty ? dx : 'ICD-10 $dxCode $dx';
}

/// ฟอร์มใบรับรองที่กำลังกรอก
class _McDraft {
  _McDraft(this.hn, {required this.doctor}) {
    final t = _dayOnly(DateTime.now());
    issued = t;
    from = t;
    to = t.add(const Duration(days: 1));
  }

  final String hn;

  /// ใบเดิมที่กำลังแก้ไข (null = ออกใบใหม่)
  _MedCert? editing;
  String type = _mcTypes.first;
  String? doctor;
  late DateTime issued;
  late DateTime from;
  late DateTime to;
  bool thaiName = true;
  bool certify = false;

  /// หน้าที่เปิดอยู่ในฟอร์ม (0–2 หัวข้อ · 3 = สรุป)
  int page = 0;
  String? dxCode;
  final TextEditingController symptoms = TextEditingController();
  final TextEditingController dx = TextEditingController();
  final TextEditingController advice = TextEditingController();
  final TextEditingController note = TextEditingController();

  /// ช่องที่ยังขาดก่อนออกใบรับรองได้
  List<String> get missing => [
        if (doctor == null) 'แพทย์ผู้ตรวจ',
        if (symptoms.text.trim().isEmpty) 'อาการที่ตรวจพบ',
        if (dx.text.trim().isEmpty) 'การวินิจฉัย',
        if (to.isBefore(from)) 'ช่วงวันพัก',
        if (!certify) 'ยืนยันการรับรอง',
      ];

  _MedCert toCert(String no) => _MedCert(
        no: no,
        type: type,
        doctor: doctor ?? '',
        issued: issued,
        thaiName: thaiName,
        symptoms: _mcNoEmoji(symptoms.text),
        from: from,
        to: to,
        dx: _mcNoEmoji(dx.text),
        dxCode: dxCode,
        advice: _mcNoEmoji(advice.text),
        note: _mcNoEmoji(note.text),
        draft: true,
      );
}

/// ปิดโหมดตัวอย่างกระดาษในแผงซ้าย (กลับไปรายการ) · เปิดเมนูใบรับรองใหม่ = แสดงอีก
bool _mcLiveOff = false;

/// key ของแต่ละส่วนบนกระดาษแผงซ้าย (กล้องซูมหาส่วนที่กำลังกรอก)
final Map<String, GlobalKey> _mcMarkKeys = {
  for (final k in [
    'type',
    'intro',
    'sym',
    'rest',
    'dx',
    'advice',
    'note',
    'sign'
  ])
    k: GlobalKey(),
};

/// ผู้วินิจฉัย + เวลา และประเภทของแต่ละการวินิจฉัย (จากขั้นวินิจฉัย) ไว้แสดงแถวการวินิจฉัย
final Map<String, (String, String)> _mcDxMeta = {};

/// ตัดอีโมจิออก (ใบรับรองแพทย์เป็นเอกสารทางการ) · ช่องว่างซ้อนรวมเป็นช่องเดียว
final RegExp _mcEmojiRe = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}'
    r'\u{FE00}-\u{FE0F}\u{200D}\u{20E3}\u{E0020}-\u{E007F}]',
    unicode: true);
String _mcNoEmoji(String s) =>
    s.replaceAll(_mcEmojiRe, '').replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();

/// ลายเซ็นของผู้ใช้ (ชื่อ → ลายเซ็น) ในหน่วยความจำ (ข้อมูลจำลอง)
final Map<String, _ESig> _esigStore = {};

/// ลายเซ็นหนึ่งชุด: รูปที่อัปโหลด หรือ ลายเส้นที่เซ็นบนจอ (พิกัดในแผ่นขนาด pad)
class _ESig {
  _ESig({this.image, this.strokes = const [], this.pad = Size.zero});

  final Uint8List? image;
  final List<List<Offset>> strokes;
  final Size pad;

  bool get has => image != null || strokes.isNotEmpty;
}

/// ทิศเปลี่ยนหน้าฟอร์มล่าสุด (true = ไปข้างหน้า)
bool _mcFwd = true;

/// ใบรับรองของแต่ละ HN (ข้อมูลจำลอง · ออกใหม่เก็บในหน่วยความจำ)
final Map<String, List<_MedCert>> _mcStore = {};
_McDraft? _mcDraft;

/// เลขที่เอกสารถัดไป (ต่อปี พ.ศ.)
int _mcSeq = 1;
String _mcNextNo() =>
    'MC${DateTime.now().year + 543}-${(_mcSeq++).toString().padLeft(4, '0')}';

/// ตัวอย่างใบรับรองเดิมของผู้ป่วย 1 ใบ (เพื่อให้เห็นหน้าประวัติ)
List<_MedCert> _mcSeed() {
  final t = _dayOnly(DateTime.now()).subtract(const Duration(days: 42));
  return [
    _MedCert(
      no: 'MC${t.year + 543}-0098',
      type: 'ใบรับรองแพทย์ลาป่วย',
      doctor: 'นพ. ธีรภัทร อมรเลิศ',
      issued: t,
      thaiName: true,
      symptoms: 'ไอ มีไข้ และอ่อนเพลีย',
      from: t,
      to: t.add(const Duration(days: 1)),
      dx: 'การติดเชื้อทางเดินหายใจส่วนบน',
      dxCode: 'J06.9',
      advice: 'ควรพักรักษาตัว รับประทานยาตามแพทย์สั่ง และมาตรวจตามนัด',
      note: '',
      draft: false,
      issuedBy: 'นพ. ธีรภัทร อมรเลิศ',
    ),
  ];
}

extension _FeaturesPatientMedCertPart on _ErFlowHomeWidgetState {
  List<_MedCert> _certsOf(String hn) => _mcStore.putIfAbsent(hn, _mcSeed);

  /// edit = false (แท็บแผงซ้าย): ดูอย่างเดียว · ออก/แก้ไขที่ workflow panel ขวา (แบบอุบัติเหตุ นัดหมาย)
  /// แผงซ้าย: กำลังกรอกฟอร์ม (แผงขวา) = กระดาษ A4 ตามที่กรอก + ไฮไลต์ส่วนที่กำลังกรอก
  /// ไม่มีร่าง = รายการใบที่ออกแล้ว
  Widget _mcTabBody({bool edit = false}) => edit
      ? _mcForm()
      : (_mcDraft?.hn == _caseP().hn && !_mcLiveOff
          ? _mcLivePaper(_mcDraft!)
          : _mcList());

  /// ส่วนบนกระดาษของแต่ละหน้าฟอร์ม (หน้าสรุป = ไม่ไฮไลต์)
  static const _mcPageMarks = [
    {'type', 'intro', 'sign'},
    {'sym', 'dx', 'advice', 'note'},
    {'rest'},
    <String>{},
  ];

  Widget _mcLivePaper(_McDraft d) {
    final pg = d.page.clamp(0, _mcPageNames.length);
    final last = pg == _mcPageNames.length;
    final cert = d.toCert(d.editing?.no ?? _mcPreviewNo());
    final marks = _mcPageMarks[pg];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // breadcrumb: แตะ "ใบรับรองแพทย์" = ออกจากตัวอย่าง กลับไปรายการ (ฟอร์มขวากรอกต่อได้)
        Row(children: [
          _CrumbPrev('ใบรับรองแพทย์',
              onTap: () => setState(() => _mcLiveOff = true)),
          const _CrumbSep(),
          Text('ตัวอย่าง',
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
        ]),
        // ไม่มีหัวหน้า: กระดาษใช้พื้นที่เต็ม (ขั้นที่กรอกดูจาก stepper แผงขวา)
        const SizedBox(height: 8.0),
        // กล้องตามส่วนที่กรอก (แผงขวา): ซูมเข้า + กระดาษตั้งตรง · สรุป = ทั้งแผ่นวางเอียง
        Expanded(
          // ขั้นกรอก = ซูมไปส่วนที่กรอก · ขั้นสรุป = เต็มแผ่นตั้งตรง
          child: _McPaperCam(
            straight: last,
            // หน้าแรก: กล้องดูหัวกระดาษ + ย่อหน้าแรก (ลายเซ็นท้ายแผ่นจาง/ชัดอย่างเดียว)
            focus: [
              for (final k in marks)
                if (k != 'sign') _mcMarkKeys[k]!
            ],
            child: _mcIllusPaper(cert, marks,
                keys: _mcMarkKeys, stamped: d.certify),
          ),
        ),
      ]),
    );
  }

  /// เปิดฟอร์มใหม่ (from = ใบเดิมที่ต้องการออกซ้ำ)
  void _mcNew({_MedCert? from}) {
    // แจ้งเตือนที่มีปุ่ม (ดูเอกสาร) ไม่หายเอง จะบังปุ่มบันทึกของฟอร์ม
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final me = ErSession.instance.user;
    final d = _McDraft(_caseP().hn,
        doctor: me?.role == ErRole.doctor ? me!.name : null);
    if (from != null) {
      d.type = from.type;
      d.thaiName = from.thaiName;
      d.symptoms.text = from.symptoms;
      d.dx.text = from.dx;
      d.dxCode = from.dxCode;
      d.advice.text = from.advice;
      final len = from.days - 1;
      d.to = d.from.add(Duration(days: len < 0 ? 0 : len));
    }
    // ใบใหม่: ฟอร์มว่าง ให้ผู้ใช้กรอกเอง (อาการจากเวชระเบียนเติมได้จาก tile "จากเวชระเบียน")
    setState(() => _mcDraft = d);
  }

  /// แก้ไขใบที่ออกแล้ว: ได้เฉพาะแพทย์ที่ login ตอนออกใบนั้น · คนอื่น = แจ้งเตือน
  Future<void> _mcEdit(_MedCert c) async {
    final me = ErSession.instance.user?.name;
    final owner = c.issuedBy.isEmpty ? c.doctor : c.issuedBy;
    if (me == null || me != owner) {
      await _paperAsk<void>(
        heading: 'ท่านไม่ใช่ผู้ออกใบรับรองแพทย์',
        sub: 'ใบรับรองแพทย์ฉบับนี้แก้ไขได้เฉพาะแพทย์ผู้ออกใบรับรองเท่านั้น\n'
            'หากต้องการเปลี่ยนแปลง กรุณาติดต่อแพทย์ผู้ออกใบรับรอง',
        icon: Icons.lock_person_rounded,
        actions: [('รับทราบ', null, true)],
      );
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final d = _McDraft(_caseP().hn, doctor: c.doctor)
      ..editing = c
      ..type = c.type
      ..issued = c.issued
      ..from = c.from
      ..to = c.to
      ..thaiName = c.thaiName
      ..dxCode = c.dxCode
      ..certify = true;
    d.symptoms.text = c.symptoms;
    d.dx.text = c.dx;
    d.advice.text = c.advice;
    d.note.text = c.note;
    setState(() => _mcDraft = d);
  }

  // ------------------------------------------------ ประวัติการออกใบรับรอง

  /// แท็บแผงซ้าย: ดูใบที่ออกแล้วอย่างเดียว (ออก/แก้ไขที่เมนูใบรับรองแพทย์ แผงขวา)
  Widget _mcList() {
    final certs = [..._certsOf(_caseP().hn)]
      ..sort((a, b) => b.issued.compareTo(a.issued));
    // ยังไม่มีใบ = หน้าว่างแบบแท็บอุบัติเหตุ (บอกว่าบันทึกได้ที่เมนูทางขวา)
    if (certs.isEmpty) {
      return _clyInfoPage('ใบรับรองแพทย์',
          'ใบรับรองแพทย์ที่ออกให้ผู้ป่วยรายนี้', 'med_cert', const [],
          heroArt: Image.asset('assets/images/er_hero_med_cert.png',
              filterQuality: FilterQuality.medium),
          empty: true,
          emptyTitle: 'ยังไม่มีใบรับรองแพทย์',
          emptySub: 'เริ่มออกใบได้ที่เมนู "ใบรับรองแพทย์" ทางขวา\n'
              'เลือกรูปแบบเอกสาร แล้วกรอกทีละหัวข้อ');
    }
    final last = certs.first;
    return _clyInfoPage(
      'ใบรับรองแพทย์',
      'ใบรับรองแพทย์ที่ออกให้ผู้ป่วยรายนี้',
      'med_cert',
      const [],
      by: last.issuedBy.isEmpty ? last.doctor : last.issuedBy,
      at: _apptDate(last.issued),
      // ภาพทั้งแผ่น (contain) ไม่ตัดหัวเอกสาร
      heroArt: Image.asset('assets/images/er_hero_med_cert.png',
          filterQuality: FilterQuality.medium),
      lead: [
        for (final c in certs) ...[
          _mcCard(c),
          const SizedBox(height: 12.0),
        ],
      ],
    );
  }

  /// การ์ดใบรับรองหนึ่งฉบับ: หัว (ชนิด เลขที่ วันพัก) แถวข้อมูลแบบหน้าอื่น
  /// action เดียว = ดูเอกสาร (ออกซ้ำ/แก้ไขอยู่ในหน้าดูเอกสาร)
  Widget _mcCard(_MedCert c) {
    final owner = c.issuedBy.isEmpty ? c.doctor : c.issuedBy;
    // แผงแคบ = หัวข้ออยู่บนค่า ไม่ตัดค่าหลายบรรทัด
    var narrow = false;
    Widget kv(String k, String v) {
      final label =
          Text(k, style: _t(13.0, color: _ink2, weight: FontWeight.w500));
      final value = Text(v,
          style:
              _t(14.0, color: _inkTitle, height: 1.4, weight: FontWeight.w600));
      return Padding(
        padding: EdgeInsets.symmetric(vertical: narrow ? 4.0 : 5.0),
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [label, const SizedBox(height: 1.0), value])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 130.0, child: label),
                Expanded(child: value),
              ]),
      );
    }

    return LayoutBuilder(builder: (context, box) {
      narrow = box.maxWidth < 440.0;
      return Container(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 12.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.type,
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 2.0),
                  Text('เลขที่ ${c.no}',
                      style: _num(13.0, color: _ink3, weight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            // จำนวนวันพัก = ข้อมูลที่คนถามบ่อยที่สุด เด่นที่มุมขวา
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text('พัก ${c.days} วัน',
                  style: _t(13.0, color: _blue, weight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 10.0),
          kv('วันที่ออก', _apptDate(c.issued)),
          kv('ช่วงวันพัก', '${_apptDate(c.from)} ถึง ${_apptDate(c.to)}'),
          kv('การวินิจฉัย', c.dxShown),
          kv('แพทย์ผู้ตรวจ', c.doctor),
          if (owner != c.doctor) kv('ผู้ออกใบ', owner),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerLeft,
            child: _miniBtn(
                Icons.visibility_rounded, 'ดูเอกสาร', () => _mcView(c)),
          ),
        ]),
      );
    });
  }

  /// หน้าแนะนำในแผง workflow ขวา (แบบหน้าแนะนำของอุบัติเหตุ): ป้าย + หัวข้อของฟอร์ม + เริ่มกรอก
  Widget _mcIntro() => _stepIntroView(
        sign: _waySignHero(
          name: 'ใบรับรองแพทย์',
          names: const ['ใบรับรองแพทย์'],
          icons: const [Icons.description_rounded],
          iconPaths: const [null],
          done: const [false],
          at: 0,
        ),
        mark: Icon(Icons.description_rounded,
            size: 112.0, color: _blue.withValues(alpha: 0.1)),
        items: const [
          ('ประเภทเอกสาร', 'ลาป่วย สมัครงาน 5 โรค หรือประกัน'),
          ('การตรวจและวินิจฉัย', 'อาการที่ตรวจพบ การวินิจฉัย ความเห็นของแพทย์'),
          ('ระยะพักรักษา', 'วันเริ่มและวันสิ้นสุดการพัก'),
        ],
      );

  /// ดูใบรับรองที่ออกแล้ว: แผ่นล่างแบบตัวดูใบรายงานผล Lab PDF (_labPdfView)
  /// หัว = ชื่อเอกสาร + ปิด · กระดาษแบบฟอร์ม (หนีบซูมได้) บนพื้นเทา · footer ลอย:
  /// ปุ่มหลัก "แก้ไข" (ไม่ใช่ผู้ออก = กุญแจ แจ้งเตือน) · ปุ่มกลมรอง "ออกซ้ำ"
  /// เลือกแล้วปิดแผ่นก่อน แล้วเปิดฟอร์มที่แผงขวา (ห้าม dialog ซ้อนบน sheet)
  Future<void> _mcView(_MedCert c) async {
    final owner = c.issuedBy.isEmpty ? c.doctor : c.issuedBy;
    final mine = ErSession.instance.user?.name == owner;
    // กรอบกระดาษ: จับภาพเป็นไฟล์ตอนกดดาวน์โหลด (ก่อนปิดแผ่น)
    final paperKey = GlobalKey();
    Uint8List? png;
    final what = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: _panel,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.88,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 8.0, 8.0),
            child: Row(children: [
              Expanded(
                child: Text('${c.type} เลขที่ ${c.no}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(18.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: 'ปิด',
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded, color: _ink2, size: 22.0),
              ),
            ]),
          ),
          const Divider(height: 1.0, thickness: 1.0, color: _line),
          Expanded(
            child: Stack(children: [
              // กระดาษบนพื้นเทา หนีบซูมได้ (แบบตัวดู PDF)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF1F3F4),
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 96.0),
                      child: FittedBox(
                          // ใบที่ออกแล้ว: กระดาษแบบฟอร์ม + ตราประทับ (ลายน้ำผู้เปิดดู ไม่มีคำว่าตัวอย่าง)
                          child: RepaintBoundary(
                        key: paperKey,
                        child: _mcIllusPaper(c, const {},
                            stamped: true, sample: false),
                      )),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: IgnorePointer(
                  child: Container(
                    height: 110.0,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00F1F3F4), Color(0xFFF1F3F4)],
                        stops: [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                    child: Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, 'edit'),
                          icon: Icon(
                              mine
                                  ? Icons.edit_rounded
                                  : Icons.lock_outline_rounded,
                              size: 20.0),
                          label: const Text('แก้ไข'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48.0),
                            shape: const StadiumBorder(),
                            textStyle: _t(15.0, weight: FontWeight.w600),
                          ),
                        ),
                      ),
                      // ปุ่มรอง: ขาวขอบเทา มีชื่อ (แตะง่าย รู้ว่าทำอะไร) สูงเท่าปุ่มหลัก
                      for (final (ic, label, key) in const [
                        (Icons.download_rounded, 'ดาวน์โหลด', 'download'),
                        (Icons.content_copy_rounded, 'ออกซ้ำ', 'copy'),
                      ]) ...[
                        const SizedBox(width: 8.0),
                        OutlinedButton.icon(
                          onPressed: () async {
                            if (key == 'download') {
                              // จับภาพกระดาษก่อนปิดแผ่น (ปิดแล้วจับไม่ได้)
                              final ro =
                                  paperKey.currentContext?.findRenderObject()
                                      as RenderRepaintBoundary?;
                              final img = await ro?.toImage(pixelRatio: 3.0);
                              final bd = await img?.toByteData(
                                  format: ui.ImageByteFormat.png);
                              png = bd?.buffer.asUint8List();
                            }
                            if (ctx.mounted) Navigator.pop(ctx, key);
                          },
                          icon: Icon(ic, size: 18.0),
                          label: Text(label),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _blue,
                            backgroundColor: _panel,
                            minimumSize: const Size(0.0, 48.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            side: const BorderSide(color: Color(0xFFC4C7CC)),
                            shape: const StadiumBorder(),
                            textStyle: _t(14.0, weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
    if (!mounted || what == null) return;
    if (what == 'download') {
      // เตือน PDPA ก่อน (ชุดเดียวกับดาวน์โหลดใบผล Lab) · ยกเลิก = แผ่นเดิมกลับมา
      final ok = await _paperAsk<bool>(
            heading: 'ข้อควรระวังก่อนดาวน์โหลด',
            sub:
                'เอกสารนี้มีข้อมูลสุขภาพของผู้ป่วย เป็นข้อมูลส่วนบุคคลที่อ่อนไหว '
                'ใช้เพื่อการรักษาผู้ป่วยรายนี้เท่านั้น ห้ามส่งต่อให้ผู้ไม่เกี่ยวข้อง '
                'หรือเผยแพร่ในช่องทางสาธารณะ และลบไฟล์เมื่อไม่ใช้แล้ว '
                'ผู้ดาวน์โหลดต้องรับผิดชอบตาม พ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล',
            icon: Icons.privacy_tip_outlined,
            tone: _blue,
            actions: const [
              ('ยกเลิก', false, false),
              ('รับทราบ', true, false),
            ],
          ) ==
          true;
      if (!mounted) return;
      if (!ok || png == null) {
        if (!ok) await _mcView(c);
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final name = 'ใบรับรองแพทย์_${c.no}.png';
      await File('${dir.path}/$name').writeAsBytes(png!, flush: true);
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('บันทึก $name ในเครื่องแล้ว')));
      }
      return;
    }
    if (what == 'edit') {
      await _mcEdit(c);
    } else {
      _mcNew(from: c);
    }
    if (_mcDraft?.hn == _caseP().hn) _openMedCertPane();
  }

  // ------------------------------------------------ ฟอร์มออกใบรับรอง
  // แบบฟอร์มอุบัติเหตุในแผงขวา: stepper บน · หน้าละหัวข้อ (การ์ด + แถวค่า) · หน้าสรุปท้าย
  // footer ลอย ย้อนกลับ | ถัดไป (หน้าสรุป = ออกใบรับรอง)

  // ลำดับหน้า/การ์ด = ลำดับบนเอกสาร: ผู้ตรวจ → อาการ → วินิจฉัย → ความเห็น → วันพัก
  static const _mcPageNames = [
    'ประเภทเอกสาร',
    'การตรวจและวินิจฉัย',
    'ระยะพักรักษา',
  ];

  /// แผงขวา: หน้าแนะนำ (ยังไม่มีร่าง) + หน้าฟอร์มทุกหน้า ใช้ footer ตัวเดียวกัน
  /// (ปุ่มข้าง ← / ไปหน้าสรุป งอก-หดออกจากปุ่มหลักแบบ liquid เหมือนอุบัติเหตุ)
  Widget _mcForm() {
    final d = _mcDraft?.hn == _caseP().hn ? _mcDraft : null;
    final intro = d == null;
    final c = erCaseOf(_caseP().hn);
    final missing = d?.missing ?? const <String>[];
    final done = d == null
        ? const [false, false, false]
        : [
            d.doctor != null,
            d.symptoms.text.trim().isNotEmpty && d.dx.text.trim().isNotEmpty,
            !d.to.isBefore(d.from),
          ];
    final pg = (d?.page ?? 0).clamp(0, _mcPageNames.length);
    final last = !intro && pg == _mcPageNames.length;
    void go(int i) {
      if (d == null || i == pg) return;
      HapticFeedback.selectionClick();
      setState(() {
        _mcFwd = i > pg;
        d.page = i;
      });
    }

    void start() {
      _mcFwd = true;
      _mcNew();
    }

    // หน้าพิมพ์ข้อความ (_ftOpen inWorkflow) = หน้าย่อยในแผงนี้ แทนแผ่นลอย (แบบอุบัติเหตุ)
    _wfTextRebuild = () {
      if (mounted) setState(() {});
    };
    _wfConfirmDelete = (title) => _wfTextConfirmDelete(title);
    final writing = _wfText;
    if (writing != null) {
      // หัว (breadcrumb + ชื่อ) อยู่ใน _FtPage แล้ว · ล่างเติม 6 ให้ footer ระดับเดียวกับขั้นอื่น
      return ColoredBox(
        key: ObjectKey(writing),
        color: _panel,
        child: Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
            child: _FtPage(req: writing)),
      );
    }
    final key = intro ? 'mc-intro' : 'mc-pg-$pg';
    final children = d == null
        ? [_mcIntro()]
        : switch (pg) {
            0 => _mcPageType(d),
            // หน้า 2: อาการ + วินิจฉัย + ความเห็น · หน้า 3: วันพัก (ตามลำดับบนเอกสาร)
            1 => [_mcPageExam(d, c).first, ..._mcPageDx(d, c)],
            2 => [_mcPageExam(d, c).last],
            _ => _mcPageSummary(d),
          };
    return Column(children: [
      // stepper ไม่แสดงบนหน้าแนะนำ (design rules)
      if (intro)
        const SizedBox(height: 8.0)
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _hxStepper([
            for (final (i, n) in _mcPageNames.indexed) (n, done[i]),
            ('สรุป', missing.isEmpty),
          ], pg, onTap: go),
        ),
      Expanded(
          // เลื่อนเนื้อหาลง = หุบ stepper · เลื่อนขึ้น/บนสุด = กางกลับ (ชุดเดียวกับอุบัติเหตุ)
          child: _hxScrollHide(
        _wfFadePage(
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (a, b) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...b, if (a != null) a]),
              transitionBuilder: (child, a) {
                final dir = _mcFwd ? 1.0 : -1.0;
                final enter = child.key == ValueKey(key);
                return FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                            begin: Offset((enter ? 0.22 : -0.22) * dir, 0),
                            end: Offset.zero)
                        .animate(a),
                    child: child,
                  ),
                );
              },
              child: ListView(
                key: ValueKey(key),
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
                children: children,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(children: [
              // หน้าแนะนำ = ไม่มีปุ่มย้อน · หน้าแรกของฟอร์ม: ย้อนกลับ = หน้าแนะนำ
              _wfFootBack(intro
                  ? null
                  : () => pg == 0
                      ? setState(() {
                          _mcFwd = false;
                          _mcDraft = null;
                        })
                      : go(pg - 1)),
              Expanded(
                child: intro
                    ? _navBtn('เริ่มกรอก', Icons.chevron_right_rounded, start,
                        trailing: true)
                    : !last
                        ? _navBtn('ถัดไป', Icons.chevron_right_rounded,
                            () => go(pg + 1),
                            trailing: true)
                        : Tooltip(
                            message: missing.isEmpty
                                ? ''
                                : 'ยังขาด: ${missing.join(', ')}',
                            // key ปุ่มบันทึก: จุดเริ่มแอนิเมชันบันทึกสำเร็จ (ชุดเดียวกับทุกขั้น)
                            child: KeyedSubtree(
                              key: _wfSaveBtnKey,
                              child: _navBtn(
                                  d!.editing == null
                                      ? 'ออกใบรับรอง'
                                      : 'บันทึกการแก้ไข',
                                  Icons.check_rounded,
                                  missing.isEmpty ? _mcIssue : null),
                            ),
                          ),
              ),
              // ไปหน้าสรุป (แบบอุบัติเหตุ): หน้าฟอร์มที่ยังไม่ใช่สรุป
              _wfFootSide(
                  show: !intro && !last,
                  left: false,
                  child: _wfIconBtn(Icons.fact_check_outlined, 'ไปหน้าสรุป',
                      () => go(_mcPageNames.length))),
            ]),
          ),
        ),
      )),
    ]);
  }

  /// แถวค่าแบบฟอร์มอุบัติเหตุ: เหรียญไอคอน · มีค่า = ค่า (ชื่อช่องใต้) · ว่าง = ชื่อช่อง + ยังไม่ได้เลือก
  Widget _mcRow(IconData icon, String label, String? value, VoidCallback onTap,
      {bool must = false, bool first = false, Widget? trail, String? empty}) {
    final has = value != null && value.trim().isNotEmpty;
    return _gListRow(
      first: first,
      inset: 8.0,
      lead: _McGIcon(icon, on: has),
      title: has ? value.trim() : (must ? '$label *' : label),
      titleLines: 4,
      badge: !has && !must ? 'ถ้ามี' : null,
      sub: has ? label : (empty ?? 'ยังไม่ได้เลือก'),
      onTap: onTap,
      trail: trail,
    );
  }

  /// ภาพมุมขวาของการ์ดหัวข้อ (ชุดเดียวกับการ์ดอุบัติเหตุ)
  /// whole = ภาพทั้งชิ้น (contain) ไม่ตัดขอบ (design rules 11: ล้นขอบได้ ไม่ crop)
  /// dx/dy = เลื่อนภาพ (พร้อมเงาจาง) ไปขวา/ลง · scale = ขยายจากมุมขวาบน
  Widget _mcArt(String asset,
          {bool whole = false,
          double dx = 0.0,
          double dy = 0.0,
          double scale = 1.0}) =>
      Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
              scale: scale,
              alignment: Alignment.topRight,
              child: _mcArtBody(asset, whole)));

  Widget _mcArtBody(String asset, bool whole) => _dxArtFade(whole
      ? Padding(
          padding: const EdgeInsets.fromLTRB(28.0, 6.0, 12.0, 0.0),
          child: Image.asset(asset,
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              filterQuality: FilterQuality.medium),
        )
      : Image.asset(asset,
          fit: BoxFit.cover, filterQuality: FilterQuality.medium));

  /// notch = ปุ่มในรอยเว้ามุมขวาล่าง (ไอคอน, ข้อความ, แตะ) · null = การ์ดปกติ (_dxCard)
  Widget _mcCardOf(String title, String sub, Widget art, List<Widget> body,
      {(IconData, String, VoidCallback)? notch}) {
    final col =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: body);
    if (notch == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _dxCard(title, sub, art, col),
      );
    }
    const pillW = 168.0, g = _NotchCardBorder.gap;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: const ShapeDecoration(
              color: _panel, shape: _NotchCardBorder(w: pillW + g)),
          child: Stack(children: [
            Positioned(
                right: -8.0, top: 0.0, width: 150.0, height: 110.0, child: art),
            Padding(
              // ล่างเว้นเท่าความสูงขั้นเว้า (เนื้อหาไม่ทับปุ่ม)
              padding: const EdgeInsets.fromLTRB(
                  8.0, 16.0, 8.0, _NotchCardBorder.stepH),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(title,
                          style: _t(17.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 130.0),
                      child: Text(sub,
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 16.0),
                    col,
                  ]),
            ),
          ]),
        ),
        // ปุ่มในรอยเว้า (ชุดเดียวกับ "ดูทั้งหมด" การ์ดคำสั่งแพทย์)
        Positioned(
          right: 0.0,
          bottom: 0.0,
          width: pillW + g,
          height: _NotchCardBorder.stepH,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(g, g, 0.0, 0.0),
            child: _Press(
              radius: 100.0,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notch.$3();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EAF8),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(notch.$1, size: 18.0, color: _blue),
                    const SizedBox(width: 4.0),
                    Text(notch.$2,
                        maxLines: 1,
                        style: _t(13.5, color: _blue, weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// เลือกค่าจากรายการ (sheet เดียวกับฟอร์มอื่นในแผงขวา)
  Future<void> _mcPick(String label, List<String> opts, String? Function() cur,
      void Function(String) apply,
      {bool people = false, bool custom = false}) async {
    await _listFlow([
      _ListStep(label, opts,
          current: cur, apply: apply, people: people, custom: custom),
    ]);
    if (mounted) setState(() {});
  }

  /// แก้ข้อความ = หน้าพิมพ์ในแผง (ชุดเดียวกับอุบัติเหตุ / Doctor Note) มีไมค์ให้พูดในหน้านั้น
  /// chips = ข้อความที่ใช้บ่อย แตะเพื่อต่อท้าย
  /// fromRecord = ข้อความจากเวชระเบียน: ปุ่ม "จากเวชระเบียน" ขวาหัวข้อ (ที่เดียวกับปุ่ม AI) กด = เติมต่อท้าย
  /// recordLabel/recordIcon = ชื่อ/ไอคอนปุ่ม · replace = แทนทั้งช่อง (เช่น การวินิจฉัย) แทนการต่อท้าย
  Future<void> _mcEditText(TextEditingController c, String title, String hint,
      {VoidCallback? onEdit,
      List<String> chips = const [],
      String fromRecord = '',
      String recordLabel = 'จากเวชระเบียน',
      IconData recordIcon = Icons.assignment_ind_rounded,
      bool replace = false}) async {
    final text = await _ftOpen(context,
        title: title,
        inWorkflow: true,
        // breadcrumb อยู่ในหัวหน้าพิมพ์ (ใบรับรองแพทย์ / ชื่อช่อง) ไม่ซ้ำชื่อสองบรรทัด
        crumb: 'ใบรับรองแพทย์',
        initial: c.text,
        hint: hint,
        chips: chips,
        aiLabel: fromRecord.isEmpty ? null : recordLabel,
        // ไม่ใช่ AI: ไอคอนแหล่งข้อมูล + ขอบเทา
        aiIcon: recordIcon,
        aiFill: fromRecord.isEmpty
            ? null
            : (cur) async {
                final t = cur.trim();
                return (
                  text: replace
                      ? fromRecord
                      : t.contains(fromRecord)
                          ? t
                          : (t.isEmpty ? fromRecord : '$t $fromRecord'),
                  refs: const <(String, String)>[]
                );
              });
    if (text == null || !mounted) return;
    setState(() {
      // เอกสารราชการ: ไม่รับอีโมจิ
      c.text = _mcNoEmoji(text);
      onEdit?.call();
    });
  }

  // ------------------------------------------------ ลายเซ็นอิเล็กทรอนิกส์ (ตั้งค่า > ลายเซ็น)

  /// ลายเซ็นของแพทย์ชื่อนี้ (เทียบคำนำหน้า + ชื่อต้น: ชื่อเต็ม/ย่อเป็นคนเดียวกัน)
  _ESig? _esigOf(String name) {
    String who(String n) => n.split(RegExp(r'\s+')).take(2).join(' ');
    for (final e in _esigStore.entries) {
      if (e.value.has && who(e.key) == who(name)) return e.value;
    }
    return null;
  }

  /// บรรทัดลายน้ำ: ชื่อผู้ใช้ที่ login + วันที่ เวลา ตอนสร้างภาพ
  String _mcWatermarkWho() {
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final who = ErSession.instance.user?.name ?? '';
    return [if (who.isNotEmpty) who, _apptDate(now), _clock(hm)].join('  ');
  }

  /// แสดงลายเซ็นในกรอบ size: รูปที่อัปโหลด / ลายเส้นที่เซ็นบนจอ · ไม่มี = ลายเซ็นจำลอง
  Widget _esigView(String name, Size size, {bool mock = true}) {
    final e = name.isEmpty ? null : _esigOf(name);
    if (e?.image != null) {
      return SizedBox.fromSize(
          size: size, child: Image.memory(e!.image!, fit: BoxFit.contain));
    }
    if (e != null && e.strokes.isNotEmpty) {
      return CustomPaint(size: size, painter: _ESigPainter(e.strokes, e.pad));
    }
    if (!mock || name.isEmpty) return SizedBox.fromSize(size: size);
    return CustomPaint(size: size, painter: const _McSignature());
  }

  /// หมวดลายเซ็นในหน้าตั้งค่า: ตัวอย่างลายเซ็น · อัปโหลดรูป / เซ็นบนจอ · ลบ (ยืนยันก่อน)
  Widget _esigSettings(StateSetter set) {
    final me = ErSession.instance.user;
    final e = me == null ? null : _esigStore[me.name];
    final has = e?.has ?? false;
    void save(_ESig v) {
      if (me == null) return;
      _esigStore[me.name] = v;
      set(() {});
      setState(() {});
    }

    Future<void> upload() async {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (x == null) return;
      final b = await x.readAsBytes();
      save(_ESig(image: b));
    }

    Future<void> draw() async {
      final r = await _esigDrawPad();
      if (r != null) save(r);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
      child: SizedBox(
        width: 460.0,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ลายเซ็นอิเล็กทรอนิกส์',
                  style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 4.0),
              Text('ใช้ลงนามในเอกสาร เช่น ใบรับรองแพทย์',
                  style: _t(12.0, color: _ink3)),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ตัวอย่างลายเซ็นบนพื้นกระดาษ + เส้นลงชื่อ
                      Container(
                        height: 150.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _panelSoft,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: has
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    _esigView(me!.name, const Size(220.0, 90.0),
                                        mock: false),
                                    Container(
                                        width: 240.0,
                                        height: 1.0,
                                        color: const Color(0xFFBDC1C6)),
                                    const SizedBox(height: 6.0),
                                    Text(me.name,
                                        style: _t(12.5,
                                            color: _ink2,
                                            weight: FontWeight.w600)),
                                  ])
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.draw_outlined,
                                        size: 32.0, color: _ink3),
                                    const SizedBox(height: 8.0),
                                    Text('ยังไม่มีลายเซ็น',
                                        style: _t(14.0,
                                            color: _inkTitle,
                                            weight: FontWeight.w600)),
                                    Text('อัปโหลดรูปลายเซ็น หรือเซ็นบนจอ',
                                        style: _t(12.5,
                                            color: _ink2,
                                            weight: FontWeight.w500)),
                                  ]),
                      ),
                      const SizedBox(height: 12.0),
                      _dxTiles([
                        (Icons.upload_file_rounded, 'อัปโหลดรูป', upload),
                        (Icons.draw_rounded, 'เซ็นบนจอ', draw),
                      ]),
                      Text('ไฟล์ PNG หรือ JPG พื้นขาวหรือโปร่งใส',
                          style: _t(12.0, color: _ink3)),
                      if (has) ...[
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async {
                              if (!await _askDelete(
                                  'ลบลายเซ็น?',
                                  'เอกสารที่ออกใหม่จะไม่มีลายเซ็นของท่าน',
                                  'ลบลายเซ็น')) {
                                return;
                              }
                              _esigStore.remove(me!.name);
                              set(() {});
                              setState(() {});
                            },
                            // _red เป็น getter (เปลี่ยนตามธีม) ใช้ const ไม่ได้
                            icon: Icon(Icons.delete_outline_rounded,
                                size: 18.0, color: _red),
                            label: Text('ลบลายเซ็น',
                                style: _t(13.0,
                                    color: _red, weight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ]),
              ),
            ]),
      ),
    );
  }

  /// แผ่นเซ็นบนจอ: ลากนิ้วเซ็น · ล้าง · ยกเลิก | ใช้ลายเซ็นนี้
  /// แผ่นเซ็นบนจอ: bottom sheet กลางจอ (แบบแผ่นดูเอกสาร) · ลากนิ้วเซ็นในกรอบ
  /// ปิดการลากแผ่นลง (ไม่แย่งท่าทางกับการเซ็น) · ล้าง | ใช้ลายเซ็นนี้
  Future<_ESig?> _esigDrawPad() {
    final strokes = <List<Offset>>[];
    var pad = Size.zero;
    return showModalBottomSheet<_ESig>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: _panel,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => SafeArea(
          top: false,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 8.0, 8.0),
                  child: Row(children: [
                    Expanded(
                      child: Text('เซ็นชื่อในกรอบ',
                          style: _t(18.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    IconButton(
                      tooltip: 'ปิด',
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded,
                          color: _ink2, size: 22.0),
                    ),
                  ]),
                ),
                const Divider(height: 1.0, thickness: 1.0, color: _line),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                  child: LayoutBuilder(builder: (context, box) {
                    pad = Size(box.maxWidth, box.maxWidth * 0.45);
                    return Container(
                      width: pad.width,
                      height: pad.height,
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      // Listener: เส้นเริ่มทันทีที่แตะ (ไม่มีระยะ slop) · ตัดเส้นที่ลากออกนอกกรอบ
                      // วาดตามตำแหน่งนิ้วจริง (fit: false) ไม่ย่อ/เลื่อนตามขอบเขตลายเส้น
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(children: [
                          // เส้นลงชื่อจาง ๆ ใต้กลางกรอบ (บอกตำแหน่งเซ็น)
                          Positioned(
                            left: 24.0,
                            right: 24.0,
                            bottom: pad.height * 0.28,
                            child: const CustomPaint(
                                size: Size(double.infinity, 1.0),
                                painter: _McDotLine()),
                          ),
                          if (strokes.isEmpty)
                            Positioned.fill(
                              child: Center(
                                child: Text('เซ็นชื่อที่นี่',
                                    style: _t(14.0,
                                        color: _g5, weight: FontWeight.w500)),
                              ),
                            ),
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (e) =>
                                  ss(() => strokes.add([e.localPosition])),
                              onPointerMove: (e) =>
                                  ss(() => strokes.last.add(e.localPosition)),
                              child: CustomPaint(
                                  painter:
                                      _ESigPainter(strokes, pad, fit: false)),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }),
                ),
                // footer แบบแผ่นดูเอกสาร: ปุ่มหลักเต็มกว้าง + ปุ่มรองขาวขอบเทา
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                  child: Row(children: [
                    OutlinedButton.icon(
                      onPressed: strokes.isEmpty
                          ? null
                          : () => ss(() => strokes.clear()),
                      icon: const Icon(Icons.refresh_rounded, size: 18.0),
                      label: const Text('ล้าง'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        disabledForegroundColor: _g5,
                        backgroundColor: _panel,
                        minimumSize: const Size(0.0, 48.0),
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        side: const BorderSide(color: Color(0xFFC4C7CC)),
                        shape: const StadiumBorder(),
                        textStyle: _t(14.0, weight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: FilledButton(
                        onPressed: strokes.isEmpty
                            ? null
                            : () => Navigator.pop(
                                ctx,
                                _ESig(strokes: [
                                  for (final s in strokes) List.of(s),
                                ], pad: pad)),
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE8EAED),
                          minimumSize: const Size.fromHeight(48.0),
                          shape: const StadiumBorder(),
                          textStyle: _t(15.0, weight: FontWeight.w600),
                        ),
                        child: const Text('ใช้ลายเซ็นนี้'),
                      ),
                    ),
                  ]),
                ),
              ]),
        ),
      ),
    );
  }

  // ---- หน้า 1: ประเภทเอกสาร
  List<Widget> _mcPageType(_McDraft d) {
    final me = ErSession.instance.user;
    // คนเดียวกันชื่อคนละแบบ (เต็ม "พญ. ศิริพร กิตติวงศ์" / ย่อ "พญ. ศิริพร ก.")
    // = เทียบคำนำหน้า + ชื่อต้น ไม่ให้ขึ้นซ้ำ
    String who(String n) => n.split(RegExp(r'\s+')).take(2).join(' ');
    final doctors = [
      if (me?.role == ErRole.doctor) me!.name,
      for (final x in _apptDoctors())
        if (me == null || who(x) != who(me.name)) x,
    ];
    return [
      _mcCardOf('ประเภทเอกสาร', 'รูปแบบใบรับรอง\nและแพทย์ผู้ตรวจ',
          _mcArt('assets/images/er_hero_med_cert.png', whole: true), [
        _mcRow(
            Icons.description_rounded,
            'รูปแบบใบรับรองแพทย์',
            d.type,
            () => _mcPick('รูปแบบใบรับรองแพทย์', _mcTypes, () => d.type,
                (v) => d.type = v),
            must: true,
            first: true),
        _mcRow(
            Icons.person_rounded,
            'แพทย์ผู้ตรวจ',
            d.doctor,
            () => _mcPick(
                'แพทย์ผู้ตรวจ', doctors, () => d.doctor, (v) => d.doctor = v,
                people: true),
            must: true),
      ]),
    ];
  }

  /// เลือกการแสดงชื่อโรค: sheet เดียวกับตัวเลือกอื่น แต่เป็นหน้าเฉพาะ
  /// การ์ดตัวเลือก 2 ใบ · กระดาษใบรับรองย่อส่วนของแบบที่เลือก (เลื่อนเข้าใหม่ทุกครั้งที่เลือก) · ใช้แบบนี้
  Future<void> _mcPickDxStyle(_McDraft d) async {
    var thai = d.thaiName;
    final focus = GlobalKey();
    await _listFlow([
      _ListStep('การแสดงชื่อโรค', const [],
          current: () => null,
          apply: (_) {},
          page: (done) => StatefulBuilder(
                builder: (ctx, ss) => Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ตัวอย่างกระดาษอยู่บน · ตัวเลือก 2 ใบอยู่ใต้
                        _mcPaperDemo(d, thai, focus),
                        const SizedBox(height: 16.0),
                        Row(children: [
                          for (final (i, o) in const [
                            'ชื่อโรคภาษาไทย',
                            'รหัส ICD-10 และชื่อโรค'
                          ].indexed) ...[
                            if (i > 0) const SizedBox(width: 12.0),
                            Expanded(
                              child: _mcOptCard(o, thai == (i == 0), () {
                                HapticFeedback.selectionClick();
                                ss(() => thai = i == 0);
                              }),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 14.0),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              setState(() => d.thaiName = thai);
                              done();
                            },
                            child: Text('ใช้แบบนี้',
                                style: _t(15.0,
                                    color: Colors.white,
                                    weight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                ),
              )),
    ]);
    if (mounted) setState(() {});
  }

  /// การ์ดตัวเลือกแบบ sheet ตัวเลือก: เลือกอยู่ = พื้นฟ้าจาง ขอบกรมท่า + ✓
  Widget _mcOptCard(String text, bool on, VoidCallback onTap) => _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 64.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFF3F6FC) : _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                  color: on ? _blue : const Color(0xFFDADCE0),
                  width: on ? 1.2 : 0.5),
            ),
            child: Row(children: [
              Expanded(
                child: Text(text,
                    style: _t(14.0,
                        color: on ? _blue : _inkTitle,
                        weight: on ? FontWeight.w700 : FontWeight.w600)),
              ),
              if (on) const Icon(Icons.check_rounded, size: 20.0, color: _blue),
            ]),
          ),
        ),
      );

  /// ตัวอย่างบนเอกสารจริง (_mcPaper ทั้งแผ่น) ตามแบบที่เลือก: เห็นทั้งหน้าก่อน แล้วค่อยซูมเข้าบรรทัดการวินิจฉัย
  /// วินิจฉัยยังไม่มีรหัส = โรคตัวอย่าง
  Widget _mcPaperDemo(_McDraft d, bool thai, GlobalKey focus) {
    final real = d.dx.text.trim().isNotEmpty && d.dxCode != null;
    final c0 = d.toCert(d.editing?.no ?? _mcPreviewNo());
    final cert = _MedCert(
      no: c0.no,
      type: c0.type,
      doctor: c0.doctor,
      issued: c0.issued,
      thaiName: thai,
      symptoms: c0.symptoms,
      from: c0.from,
      to: c0.to,
      dx: real ? c0.dx : 'การติดเชื้อทางเดินหายใจส่วนบน',
      dxCode: real ? c0.dxCode : 'J06.9',
      advice: c0.advice,
      note: c0.note,
      draft: false,
    );
    // ไม่มีกรอบนอก: กระดาษอย่างเดียว
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _McPaperFocus(
        paper: _mcStylePaper(cert.dxShown, focus),
        focus: focus,
        replay: thai,
      ),
    ]);
  }

  /// กระดาษเนื้อหาจริงในหน้าตาภาพประกอบใบรับรอง (Figma 1203-241) 420×594:
  /// แผ่นซ้อนหลัง · กระดาษครีม · กากบาทแดง + แถบหัวกระดาษ · หัวเรื่อง · ย่อหน้าจริง (ไฮไลต์ส่วน hi)
  /// · ลายเซ็น + ชื่อแพทย์ + ตรา
  /// keys = key ของแต่ละส่วน (ให้กล้องหาตำแหน่งส่วนที่กำลังกรอก)
  /// stamped = ยืนยันการรับรองแล้ว (ติ๊กในหน้าสรุป) → ตราประทับปั๊มลง
  /// ฟอนต์บนกระดาษ = Sarabun (ฟอนต์เอกสารราชการ) ไม่ตามฟอนต์ที่ตั้งในแอป
  /// sample = ลายน้ำ "ตัวอย่าง" (ใบที่ออกแล้ว = false)
  Widget _mcIllusPaper(_MedCert c, Set<String> hi,
      {Map<String, GlobalKey> keys = const {},
      bool stamped = false,
      bool sample = true}) {
    // _t อ่านฟอนต์จาก _fontFam ตอนสร้าง style: สลับชั่วคราวระหว่างสร้างกระดาษแล้วคืนค่า
    final keepFont = _fontFam;
    _fontFam = 'Sarabun';
    try {
      return _mcIllusPaperBody(c, hi,
          keys: keys, stamped: stamped, sample: sample);
    } finally {
      _fontFam = keepFont;
    }
  }

  Widget _mcIllusPaperBody(_MedCert c, Set<String> hi,
      {Map<String, GlobalKey> keys = const {},
      bool stamped = false,
      bool sample = true}) {
    const paper = Color(0xFFF6F5F4), line = Color(0xFFCED1D8);
    const ink = Color(0xFF33383E);
    final p = _caseP();
    final ec = erCaseOf(p.hn);
    const dots = '……………';
    final bad = c.to.isBefore(c.from);
    // ส่วนของย่อหน้า: (ข้อความ, เป็นค่าที่กรอกไหม) · ค่าเปลี่ยน = พิมพ์ทีละตัว + กรอบเขียว (_McWritePara)
    (String, bool) v(String s) => (s, true);
    (String, bool) k(String s) => (s, false);
    final kStyle = _t(11.5, color: _ink2, height: 1.6);
    final vStyle = _t(11.5, color: ink, weight: FontWeight.w700, height: 1.6);
    final eStyle = _t(11.5, color: _g5, weight: FontWeight.w700, height: 1.6);
    Widget bar(double w, {double h = 7.0}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
              color: line, borderRadius: BorderRadius.circular(h / 2)),
        );
    // focus = ส่วนที่กำลังกรอกชัดเต็มที่ · ส่วนอื่นจางลง (ไม่มีพื้นไฮไลต์) · hi ว่าง = ชัดทั้งแผ่น
    double op(String? key) =>
        hi.isEmpty || (key != null && hi.contains(key)) ? 1.0 : 0.28;
    Widget fade(Widget child, [String? key]) => AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          opacity: op(key),
          child: child,
        );
    Widget mark(String key, Widget child) =>
        KeyedSubtree(key: keys[key], child: fade(child, key));
    Widget para(String key, List<(String, bool)> parts) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: mark(
              key,
              _McWritePara(
                  parts: parts,
                  label: kStyle,
                  value: vStyle,
                  empty: eStyle,
                  dots: dots)),
        );
    // บรรทัดแบบฟอร์ม: ชื่อช่อง + เส้นจุดยาวถึงขอบ · ค่าเขียนทับบนเส้น (พิมพ์ทีละตัวตอนเปลี่ยน)
    // บนกระดาษ: ขึ้นบรรทัดใหม่/บรรทัดว่าง = ช่องว่างเดียว · จำกัดบรรทัด (กระดาษขนาดคงที่ ไม่ล้น)
    Widget field(String label, String raw,
        {double indent = 0.0, int lines = 1}) {
      final value = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
      return Padding(
        padding: EdgeInsets.only(left: indent, top: 3.0),
        // ค่ายาวหลายบรรทัด: ชื่อช่องอยู่บรรทัดแรก (ไม่จมลงล่าง)
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(label,
                  style: _t(10.0, color: ink, weight: FontWeight.w600)),
            ),
          Expanded(
            child: Stack(children: [
              const Positioned(
                  left: 2.0,
                  right: 0.0,
                  bottom: 3.0,
                  child: CustomPaint(
                      size: Size(double.infinity, 1.0), painter: _McDotLine())),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, bottom: 1.0),
                child: _McWritePara(
                    parts: [(value, true)],
                    label: kStyle,
                    value: vStyle.copyWith(fontSize: 10.5, height: 1.5),
                    empty: eStyle.copyWith(fontSize: 10.5, height: 1.5),
                    dots: ' ',
                    maxLines: lines),
              ),
            ]),
          ),
        ]),
      );
    }

    return SizedBox(
      width: 420.0,
      height: 594.0,
      child: Stack(clipBehavior: Clip.none, children: [
        // กระดาษแผ่นเดียว: เงาตามรูปทรงกระดาษ (มุมที่พับไม่มีเงาโผล่)
        const Positioned.fill(
          child: CustomPaint(painter: _McPaperShadow()),
        ),
        // เนื้อกระดาษ: แสงจากซ้ายบน + เม็ดเนื้อละเอียด + ขอบสว่างบาง
        // ขอบกระดาษโค้งพลิ้ว + มุมขวาล่างพับ (ตัดด้วย _McPaperShape)
        Positioned.fill(
          child: ClipPath(
            clipper: const _McPaperShape(),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDFCFA), paper, Color(0xFFEDEBE7)],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
              child: const CustomPaint(painter: _McPaperGrain()),
            ),
          ),
        ),
        // เนื้อหาแบบฟอร์มใบรับรองแพทย์ (โครงแบบฟอร์มทั่วไปของโรงพยาบาล):
        // หัว (ตรา รพ. + ชื่อเอกสาร) · บรรทัดจุดมีค่าเขียนทับ · ความเห็น · ช่องติ๊กรับรอง
        // · วันพัก · วันที่ออก · ลงชื่อแพทย์ + ตรา · หมายเหตุ · รหัสแบบฟอร์ม
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 22.0, 30.0, 14.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  fade(Center(
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _ink3, width: 1.2),
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          size: 20.0, color: _ink2),
                    ),
                  )),
                  const SizedBox(height: 6.0),
                  fade(Center(
                    child: Text('ใบรับรองแพทย์',
                        style: _t(15.0, color: ink, weight: FontWeight.w800)),
                  )),
                  Center(
                    child: mark(
                        'type',
                        Text(c.type,
                            style: _t(9.0,
                                color: _ink2, weight: FontWeight.w500))),
                  ),
                  fade(Align(
                    alignment: Alignment.centerRight,
                    child: Text('โรงพยาบาล ห้องฉุกเฉิน',
                        style: _t(9.5, color: ink, weight: FontWeight.w700)),
                  )),
                  const SizedBox(height: 6.0),
                  mark(
                      'intro',
                      Column(children: [
                        field('ข้าพเจ้า', c.doctor, indent: 40.0),
                        field('ใบอนุญาตประกอบวิชาชีพเวชกรรมเลขที่', ''),
                        field('ได้ตรวจร่างกาย', p.name),
                        field('HN', '${p.hn}   อายุ ${ec.ageText}'),
                      ])),
                  mark('sym', field('อาการที่ตรวจพบ', c.symptoms, lines: 3)),
                  mark('dx', field('การวินิจฉัยของแพทย์', c.dxShown, lines: 2)),
                  mark(
                      'advice',
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            field('ความเห็นและข้อแนะนำของแพทย์', ''),
                            field('', c.advice, lines: 3),
                          ])),
                  mark('note', field('', c.note, lines: 2)),
                  const SizedBox(height: 6.0),
                  // ช่องติ๊กรับรอง (ติ๊กในขั้นสรุป)
                  mark(
                      'rest',
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(children: [
                              Icon(
                                  stamped
                                      ? Icons.check_box_outlined
                                      : Icons.check_box_outline_blank_rounded,
                                  size: 14.0,
                                  color: ink),
                              const SizedBox(width: 4.0),
                              Text('ขอรับรองว่ามารักษาที่โรงพยาบาลนี้จริง',
                                  style: _t(10.0,
                                      color: ink, weight: FontWeight.w600)),
                            ]),
                            field('สมควรให้หยุดพักรักษาตัวมีกำหนด',
                                bad ? '' : '${c.days} วัน'),
                            Row(children: [
                              Expanded(
                                  child: field('วันที่', _apptDate(c.from))),
                              const SizedBox(width: 10.0),
                              Expanded(
                                  child: field('ถึงวันที่', _apptDate(c.to))),
                            ]),
                          ])),
                  fade(Padding(
                    padding: const EdgeInsets.only(left: 120.0),
                    child: field('ใบรับรองแพทย์นี้ออกให้เมื่อวันที่',
                        _apptDate(c.issued)),
                  )),
                  const Spacer(),
                  // ลงชื่อผู้ตรวจ + ชื่อแพทย์ · ตราประทับทับมุมขวา
                  SizedBox(
                    height: 74.0,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        left: 130.0,
                        right: 40.0,
                        top: 0.0,
                        child: mark(
                            'sign',
                            Column(children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ลงชื่อ',
                                        style: _t(10.0,
                                            color: ink,
                                            weight: FontWeight.w600)),
                                    Expanded(
                                      child: SizedBox(
                                        height: 30.0,
                                        // ลายเซ็นล้นกรอบได้ (เขียนเลยเส้นแบบลายเซ็นจริง ไม่ถูกตัด)
                                        child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              const Positioned(
                                                  left: 0.0,
                                                  right: 0.0,
                                                  bottom: 2.0,
                                                  child: CustomPaint(
                                                      size: Size(
                                                          double.infinity, 1.0),
                                                      painter: _McDotLine())),
                                              if (c.doctor.isNotEmpty)
                                                // ลายเซ็นแพทย์ (ตั้งค่า > ลายเซ็น) · ยังไม่มี = ลายเซ็นจำลอง
                                                // กึ่งกลางเส้นลงชื่อ (ตรงกับชื่อแพทย์ใต้เส้น) ฐานลายเซ็นทับเส้นนิด
                                                Positioned(
                                                  left: -20.0,
                                                  right: -20.0,
                                                  bottom: -8.0,
                                                  child: Center(
                                                    child: _esigView(
                                                        c.doctor,
                                                        const Size(
                                                            140.0, 56.0)),
                                                  ),
                                                ),
                                            ]),
                                      ),
                                    ),
                                    Text('ผู้ตรวจ',
                                        style: _t(10.0,
                                            color: ink,
                                            weight: FontWeight.w600)),
                                  ]),
                              const SizedBox(height: 4.0),
                              Text(
                                  '( ${c.doctor.isEmpty ? '                    ' : c.doctor} )',
                                  style: _t(10.0,
                                      color: ink, weight: FontWeight.w600)),
                            ])),
                      ),
                      Positioned(
                          right: -8.0,
                          top: -6.0,
                          child: fade(_McStamp(on: stamped))),
                    ]),
                  ),
                  const SizedBox(height: 6.0),
                  fade(Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('หมายเหตุ  ',
                            style:
                                _t(8.5, color: ink, weight: FontWeight.w700)),
                        Expanded(
                          child: Text(
                              'ใบรับรองแพทย์ที่ถูกต้องและสมบูรณ์ต้องมีตราประทับของโรงพยาบาล '
                              'ถ้ามีรอยแก้ไขต้องมีการลงลายมือชื่อกำกับ โดยแพทย์ผู้ทำการตรวจ',
                              style: _t(8.0, color: _ink2, height: 1.4)),
                        ),
                      ])),
                  fade(Align(
                    alignment: Alignment.centerRight,
                    child: Text('FR-MED-001', style: _num(7.5, color: _ink3)),
                  )),
                ]),
          ),
        ),
        // ลายน้ำ: (ตัวอย่าง) + ชื่อระบบ + ผู้เปิดดูและวันเวลา เอียงทแยงกลางแผ่น
        // ใบที่ออกแล้ว = ไม่มีคำว่า "ตัวอย่าง" แต่ยังระบุผู้เปิดดู (รวมไฟล์ที่ดาวน์โหลด)
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.rotate(
                angle: -0.55,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (sample)
                    Text('ตัวอย่าง',
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 76.0,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1967D3)
                                .withValues(alpha: 0.09))),
                  Text('BMS HOSxP+ ER',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 24.0,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w800,
                          color:
                              const Color(0xFF1967D3).withValues(alpha: 0.09))),
                  // ผู้เปิดดู + วันเวลา (ระบุที่มาเมื่อภาพตัวอย่างถูกแคปออกไป)
                  Text(_mcWatermarkWho(),
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 15.0,
                          height: 1.6,
                          fontWeight: FontWeight.w700,
                          color:
                              const Color(0xFF1967D3).withValues(alpha: 0.10))),
                ]),
              ),
            ),
          ),
        ),
        // ผิวโค้งอ่อน (แถบแสง/เงา) + เส้นขอบตามรูปทรง + มุมพับ
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _McPaperBend())),
        ),
      ]),
    );
  }

  /// กระดาษแบบภาพประกอบใบรับรอง (Figma 1203-241) ขนาดเต็ม 420×594:
  /// แผ่นซ้อนหลัง · กระดาษครีม · กากบาทแดง + หัวเรื่อง · เส้น skeleton · บรรทัดการวินิจฉัยจริง · ลายเซ็น + ตรา
  Widget _mcStylePaper(String dx, GlobalKey focus) {
    const paper = Color(0xFFF6F5F4), line = Color(0xFFCED1D8);
    Widget bar(double w, {double h = 9.0}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
              color: line, borderRadius: BorderRadius.circular(h / 2)),
        );
    Widget row(List<double> ws) => Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Row(children: [
            for (final (i, w) in ws.indexed) ...[
              if (i > 0) const SizedBox(width: 14.0),
              bar(w),
            ],
          ]),
        );
    return SizedBox(
      width: 420.0,
      height: 594.0,
      child: Stack(clipBehavior: Clip.none, children: [
        // แผ่นซ้อนด้านหลัง (เหลื่อมขวาล่าง)
        Positioned(
          left: 14.0,
          top: 12.0,
          right: -10.0,
          bottom: -10.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFDADDE3),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.fromLTRB(36.0, 34.0, 36.0, 30.0),
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                // กากบาทแดง
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Stack(children: [
                    Center(
                        child: Container(
                            width: 40.0,
                            height: 13.0,
                            color: const Color(0xFFDA5948))),
                    Center(
                        child: Container(
                            width: 13.0,
                            height: 40.0,
                            color: const Color(0xFFDA5948))),
                  ]),
                ),
                const SizedBox(width: 16.0),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  bar(110.0, h: 7.0),
                  const SizedBox(height: 7.0),
                  bar(80.0, h: 7.0),
                ]),
              ]),
              const SizedBox(height: 26.0),
              Center(
                child: Text('ใบรับรองแพทย์',
                    style: _t(30.0,
                        color: const Color(0xFF33383E),
                        weight: FontWeight.w700)),
              ),
              const SizedBox(height: 26.0),
              row([60.0, 150.0]),
              row([50.0, 210.0]),
              row([70.0, 130.0, 40.0]),
              const SizedBox(height: 6.0),
              // บรรทัดที่เปลี่ยนตามตัวเลือก (ข้อความจริง)
              // เปลี่ยนแบบ = ต่อเนื่อง: ข้อความเก่าจางออก/ใหม่จางเข้า + ความสูงบรรทัดยืดหดนุ่ม ๆ
              AnimatedSize(
                key: focus,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (cur, prev) =>
                      Stack(alignment: Alignment.topLeft, children: [
                    ...prev,
                    if (cur != null) cur,
                  ]),
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position:
                          Tween(begin: const Offset(0, 0.25), end: Offset.zero)
                              .animate(a),
                      child: child,
                    ),
                  ),
                  child: SizedBox(
                    key: ValueKey(dx),
                    width: double.infinity,
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'การวินิจฉัย : ',
                          style:
                              _t(17.0, color: _ink2, weight: FontWeight.w500)),
                      TextSpan(
                          text: dx,
                          style: _t(17.0,
                              color: const Color(0xFF33383E),
                              weight: FontWeight.w700)),
                    ])),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              row([300.0]),
              row([280.0]),
              row([170.0]),
              const Spacer(),
              // ลายเซ็น + ตราประทับ
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  bar(50.0, h: 7.0),
                  const SizedBox(height: 8.0),
                  bar(80.0, h: 7.0),
                ]),
                const Spacer(),
                Column(children: [
                  const Icon(Icons.gesture_rounded,
                      size: 44.0, color: Color(0xFF437EC5)),
                  bar(110.0, h: 2.0),
                  const SizedBox(height: 8.0),
                  bar(80.0, h: 7.0),
                ]),
                const SizedBox(width: 12.0),
                Container(
                  width: 78.0,
                  height: 78.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFA6CCEF), width: 3.0),
                  ),
                  child: Container(
                    width: 62.0,
                    height: 62.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFA6CCEF), width: 1.5),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        size: 28.0, color: Color(0xFFA6CCEF)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  // ---- หน้า 2: การตรวจและวันพัก
  List<Widget> _mcPageExam(_McDraft d, ErCase c) {
    final bad = d.to.isBefore(d.from);
    final days = d.toCert('').days;
    // 0 = 1 เดือน
    const quick = [1, 2, 3, 5, 7, 0];
    final cc = c.cc.trim();
    // แผ่นเลือกวันของแอป (ปฏิทินไทย พ.ศ.) แบบวันที่อย่างเดียว
    // แตะวันไหนก็เปิดแผ่นช่วงวันเดียวกัน (ปฏิทินไทย พ.ศ.) · end = เริ่มที่การเลือกวันสิ้นสุด
    Future<void> pickRange(bool end) async {
      final r = await _mcRangeSheet(d.from, d.to, end: end);
      if (r != null && mounted) {
        setState(() {
          d.from = r.$1;
          d.to = r.$2;
        });
      }
    }

    return [
      _mcCardOf('อาการที่ตรวจพบ', 'อาการและสิ่งที่ตรวจพบ\nที่จะพิมพ์บนใบ',
          _mcArt('assets/images/er_dx_text.png', whole: true), [
        // ปุ่มเดียว: ใช้ข้อมูลจากเวชระเบียน (อาการสำคัญ) · ไม่มีข้อมูล/ใส่แล้ว = กดไม่ได้
        _mcTile(
            Icons.assignment_ind_rounded,
            'ใช้ข้อมูลจากเวชระเบียน',
            cc.isEmpty || d.symptoms.text.contains(cc)
                ? null
                : () => _mcAppend(d.symptoms, cc)),
        _mcRow(
            Icons.sick_rounded,
            'อาการที่ตรวจพบ',
            d.symptoms.text,
            // หน้าพิมพ์มีปุ่ม "จากเวชระเบียน" ขวาหัวข้อ กด = เติมอาการสำคัญ
            () => _mcEditText(
                d.symptoms, 'อาการที่ตรวจพบ', 'เช่น ไอ มีไข้ อ่อนเพลีย',
                fromRecord: cc),
            must: true,
            first: true,
            empty: 'ยังไม่ได้กรอก'),
      ]),
      _mcCardOf(
          'ระยะพักรักษา',
          'วันเริ่มและวันสิ้นสุดการพัก',
          // ภาพประกอบผู้ป่วยพักฟื้นบนเตียง (Figma 1224-31 ตัดพื้นหลัง/ผนังออก)
          _mcArt('assets/images/er_mc_rest.png',
              whole: true, dx: 16.0, dy: 6.0, scale: 1.6),
          [
            // สรุปช่วงวันพัก แบบเส้นทางของลิ้นชักส่งต่อ (พื้นเรียบ): วันเริ่ม - - → วันสิ้นสุด · จำนวนวันกลางเส้น
            // แตะวันไหน = เปิดแผ่นเลือกวันนั้น
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 8.0),
              // การ์ดขอบ (outline) พื้นขาว แบบการ์ดซ้อนในฟอร์ม
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Column(children: [
                Row(children: [
                  _mcDateNode(Icons.event_rounded, 'พักตั้งแต่',
                      _apptDate(d.from), false, () => pickRange(false)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      // จำนวนวัน (รวมวันเริ่มและวันสิ้นสุด) · ผิดช่วง = แดง
                      Text(bad ? 'วันผิด' : '$days วัน',
                          style: _t(15.0,
                              color: bad ? _red : _blue,
                              weight: FontWeight.w700)),
                      const SizedBox(height: 4.0),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        for (var k = 0; k < 3; k++)
                          Container(
                            width: 6.0,
                            height: 3.0,
                            margin: const EdgeInsets.only(right: 4.0),
                            decoration: BoxDecoration(
                              color: bad ? _red : _blue,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        Icon(Icons.arrow_forward_rounded,
                            size: 20.0, color: bad ? _red : _blue),
                      ]),
                    ]),
                  ),
                  _mcDateNode(Icons.event_available_rounded, 'ถึงวันที่',
                      _apptDate(d.to), bad, () => pickRange(true)),
                ]),
                const SizedBox(height: 12.0),
                // จำนวนวันที่ใช้บ่อย: ปุ่มกว้างเท่ากันแถวเดียว (ชุดเดียวกับแผ่นเลือกช่วงวัน)
                _mcQuickGrid(
                    quick,
                    (n) => !bad && d.to == _mcQuickEnd(d.from, n),
                    (n) => setState(() => d.to = _mcQuickEnd(d.from, n))),
              ]),
            ),
          ]),
    ];
  }

  /// วันสิ้นสุดตามตัวเลือกด่วน: n วัน (รวมวันเริ่ม) · 0 = 1 เดือน (วันเดียวกันเดือนหน้า ลบ 1 วัน)
  DateTime _mcQuickEnd(DateTime from, int n) => n == 0
      ? DateTime(from.year, from.month + 1, from.day)
          .subtract(const Duration(days: 1))
      : from.add(Duration(days: n - 1));

  String _mcQuickLabel(int n) => n == 0 ? '1 เดือน' : '$n วัน';

  /// ตัวเลือกจำนวนวัน: ปุ่มกว้างเท่ากันแถวเดียว (เลขบน หน่วยล่าง) · แคบ = 3 × 2
  /// เลือกอยู่ = กรมท่าทึบ ตัวขาว · อื่น = ขาวขอบเทา (ชุดเดียวกับ _optChip)
  Widget _mcQuickGrid(
      List<int> opts, bool Function(int) on, void Function(int) pick) {
    Widget cell(int n) {
      final sel = on(n);
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (sel) return;
            HapticFeedback.selectionClick();
            pick(n);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 52.0,
            decoration: BoxDecoration(
              color: sel ? _blue : _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: sel ? _blue : const Color(0xFFDADCE0)),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(n == 0 ? '1' : '$n',
                  maxLines: 1,
                  style: _t(17.0,
                      color: sel ? Colors.white : _inkTitle,
                      weight: FontWeight.w700)),
              Text(n == 0 ? 'เดือน' : 'วัน',
                  maxLines: 1,
                  style: _t(11.5,
                      color: sel ? Colors.white : _ink3,
                      weight: FontWeight.w500)),
            ]),
          ),
        ),
      );
    }

    Widget row(Iterable<int> ns) => Row(children: [
          for (final (i, n) in ns.indexed) ...[
            if (i > 0) const SizedBox(width: 6.0),
            Expanded(child: cell(n)),
          ],
        ]);

    // ช่องละ ≥ 44 ได้ = แถวเดียว · ไม่พอ = สองแถว แถวละครึ่ง
    return LayoutBuilder(builder: (context, box) {
      final one =
          (box.maxWidth - 6.0 * (opts.length - 1)) / opts.length >= 44.0;
      if (one) return row(opts);
      final h = (opts.length + 1) ~/ 2;
      return Column(children: [
        row(opts.take(h)),
        const SizedBox(height: 6.0),
        row(opts.skip(h)),
      ]);
    });
  }

  /// ปุ่มเดียวในการ์ดซ้อน (ชุดเดียวกับการ์ด action tile) · ไอคอนสองโทนแบบ Google
  /// onTap null = กดไม่ได้ (ไอคอนเทา ตัวอักษรจาง)
  Widget _mcTile(IconData icon, String text, VoidCallback? onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _Press(
          child: Material(
            color: _panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                // ไอคอนอยู่บนชื่อ (แบบการ์ด action tile)
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _McGIcon(icon, on: onTap != null),
                  const SizedBox(height: 6.0),
                  Text(text,
                      style: _t(14.0,
                          color: onTap == null ? _g5 : _inkTitle,
                          weight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      );

  /// แผ่นเลือกช่วงวันพัก: ปฏิทินไทย พ.ศ. แตะวันเริ่ม → แตะวันสิ้นสุด (ช่วงระหว่างไฮไลต์)
  /// แตะก่อนวันเริ่ม = เริ่มใหม่ · สรุปช่วง + จำนวนวันด้านล่าง · "ใช้ช่วงนี้"
  Future<(DateTime, DateTime)?> _mcRangeSheet(DateTime from0, DateTime to0,
      {bool end = false}) {
    final t0 = _dayOnly(DateTime.now());
    var a = _dayOnly(from0), b = _dayOnly(to0);
    if (a.isBefore(t0)) a = t0;
    if (b.isBefore(a)) b = a;
    var pickEnd = end;
    var month = DateTime((end ? b : a).year, (end ? b : a).month);
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
      'ธันวาคม'
    ];
    const wd = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    final today = _dayOnly(DateTime.now());
    return _placedSheet<(DateTime, DateTime)>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 460.0),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final firstWd = DateTime(month.year, month.month, 1).weekday % 7;
        final nDays = DateTime(month.year, month.month + 1, 0).day;
        final days = b.difference(a).inDays + 1;
        // ตัวเลขวัน + แตะ (แถบช่วงและวงวันเริ่ม/สิ้นสุดวาดเป็นชั้นล่างที่เลื่อนต่อเนื่อง)
        Widget day(int n) {
          final dd = DateTime(month.year, month.month, n);
          final edge = dd == a || dd == b;
          final inside = dd.isAfter(a) && dd.isBefore(b);
          // ห้ามย้อนหลัง: ก่อนวันนี้ = จาง กดไม่ได้
          final past = dd.isBefore(today);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: past
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    set(() {
                      if (!pickEnd || dd.isBefore(a)) {
                        a = dd;
                        if (b.isBefore(a)) b = a;
                        pickEnd = true;
                      } else {
                        b = dd;
                        pickEnd = false;
                      }
                    });
                  },
            child: SizedBox(
              height: 40.0,
              child: Center(
                child: Container(
                  width: 34.0,
                  height: 34.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: dd == today && !edge && !inside
                        ? Border.all(color: _blue, width: 1.0)
                        : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: _num(14.0,
                        color: edge ? Colors.white : (past ? _g5 : _inkTitle),
                        weight: edge ? FontWeight.w700 : FontWeight.w500),
                    child: Text('$n'),
                  ),
                ),
              ),
            ),
          );
        }

        // เดือนก่อนเดือนนี้ = ย้อนหลังทั้งเดือน กดไม่ได้
        Widget nav(IconData ic, int dm) {
          final ok = dm > 0 ||
              DateTime(month.year, month.month)
                  .isAfter(DateTime(today.year, today.month));
          return IconButton(
            onPressed: ok
                ? () =>
                    set(() => month = DateTime(month.year, month.month + dm))
                : null,
            icon: Icon(ic, size: 22.0, color: ok ? _ink2 : _g5),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 16.0),
          decoration: const BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ช่วงวันพักรักษา',
                              style: _t(22.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                        ]),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: _ink2)),
                ]),
                const SizedBox(height: 10.0),
                // ช่องวันเริ่ม | วันสิ้นสุด: ช่องที่กำลังเลือกขอบกรมท่า · แตะ = สลับไปเลือกช่องนั้น
                Row(children: [
                  for (final (i, (cap, v))
                      in [('พักตั้งแต่', a), ('ถึงวันที่', b)].indexed) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 18.0, color: _ink3),
                      ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => set(() {
                          pickEnd = i == 1;
                          month = DateTime(v.year, v.month);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                                color: pickEnd == (i == 1)
                                    ? _blue
                                    : const Color(0xFFDADCE0),
                                width: pickEnd == (i == 1) ? 1.5 : 0.5),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cap,
                                    style: _t(12.0,
                                        color: _ink2, weight: FontWeight.w500)),
                                // micro: วันที่เปลี่ยน = เลื่อนขึ้นแทนที่
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (c, an) => FadeTransition(
                                    opacity: an,
                                    child: SlideTransition(
                                        position: Tween(
                                                begin: const Offset(0, 0.4),
                                                end: Offset.zero)
                                            .animate(an),
                                        child: c),
                                  ),
                                  child: Text(_apptDate(v),
                                      key: ValueKey(v),
                                      style: _t(15.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w700)),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 48.0,
                  child: Row(children: [
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                          '${months[month.month - 1]} ${month.year + 543}',
                          style: _t(16.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    nav(Icons.chevron_left_rounded, -1),
                    nav(Icons.chevron_right_rounded, 1),
                  ]),
                ),
                Row(children: [
                  for (final w in wd)
                    Expanded(
                      child: Center(
                        child: Text(w,
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w600)),
                      ),
                    ),
                ]),
                const SizedBox(height: 4.0),
                // ชั้นล่าง: แถบช่วง + วงวันเริ่ม/สิ้นสุด เลื่อน/ยืดต่อเนื่อง (ตำแหน่งในตารางแบบทศนิยม)
                Stack(children: [
                  Positioned.fill(
                    child: TweenAnimationBuilder<Offset>(
                      key: ValueKey(month),
                      tween: Tween(
                          end: Offset(
                              (firstWd +
                                      a
                                          .difference(
                                              DateTime(month.year, month.month))
                                          .inDays)
                                  .toDouble(),
                              (firstWd +
                                      b
                                          .difference(
                                              DateTime(month.year, month.month))
                                          .inDays)
                                  .toDouble())),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => CustomPaint(
                          painter: _McRangePainter(
                              v.dx, v.dy, ((firstWd + nDays) / 7).ceil() * 7)),
                    ),
                  ),
                  Column(children: [
                    for (var r = 0; r < ((firstWd + nDays) / 7).ceil(); r++)
                      Row(children: [
                        for (var c = 0; c < 7; c++)
                          Expanded(
                            child: Builder(builder: (_) {
                              final n = r * 7 + c - firstWd + 1;
                              return n < 1 || n > nDays
                                  ? const SizedBox(height: 40.0)
                                  : day(n);
                            }),
                          ),
                      ]),
                  ]),
                ]),
                const SizedBox(height: 8.0),
                // จำนวนวันที่ใช้บ่อย: ตั้งวันสิ้นสุดจากวันเริ่ม
                _mcQuickGrid(
                    const [1, 2, 3, 5, 7, 0],
                    (k) => b == _mcQuickEnd(a, k),
                    (k) => set(() {
                          b = _mcQuickEnd(a, k);
                          pickEnd = false;
                        })),
                const SizedBox(height: 12.0),
                const Divider(height: 1.0, color: _line),
                const SizedBox(height: 12.0),
                Row(children: [
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'รวม',
                          style: _t(15.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      TextSpan(
                          text: ' $days วัน',
                          style:
                              _t(14.0, color: _blue, weight: FontWeight.w700)),
                    ])),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 14.0),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.pop(ctx, (a, b)),
                    child: Text('ใช้ช่วงนี้',
                        style: _t(15.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ]),
              ]),
        );
      }),
    );
  }

  /// จุดวันบนเส้นทางสรุปวันพัก: เหรียญ + ป้ายเล็ก + วันที่ (bad = แดง) · แตะ = แก้วันนั้น
  Widget _mcDateNode(IconData icon, String cap, String date, bool bad,
          VoidCallback onTap) =>
      Expanded(
        child: _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Column(children: [
              _McGIcon(icon, on: !bad),
              const SizedBox(height: 6.0),
              Text(cap, style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
              Text(date,
                  maxLines: 1,
                  style: _t(15.0,
                      color: bad ? _red : _inkTitle, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// การวินิจฉัยของการมาครั้งนี้ (ข้อความ → รหัส ICD-10) ที่แพทย์บันทึกในขั้นวินิจฉัย
  /// (Diagnosis Text + รหัสที่ผูกไว้ แบบการ์ดวินิจฉัยหน้าภาพรวม)
  /// ขั้นวินิจฉัยยังว่าง = ใช้รายการในเวชระเบียนของเคสแทน (ไม่รวมสองแหล่ง กันรายการเกิน)
  Map<String, String?> _mcDxOptions(ErCase c) {
    final out = <String, String?>{};
    final st = [for (var i = 0; i < _steps.length; i++) i]
            .where(_isDxStep)
            .firstOrNull ??
        -1;
    if (st >= 0 && _speechHn == _caseP().hn && st < _filled.length) {
      final keep = _speechStep;
      _speechStep = st; // helper ของเมนูวินิจฉัยอ่านจากขั้นปัจจุบัน
      try {
        final items = _multiItems(_filled[st][_dxTextLabel]);
        final icd = _multiItems(_filled[st][_icd10Label], icd: true);
        final icdCodes = _icd10Codes();
        final src = _icdSrcMap();
        final by = _byMap(_dxTextLabel), at = _atMap(_dxTextLabel);
        for (final t in items) {
          String? code;
          var type = '1';
          for (final (i, e) in icd.indexed) {
            if (src[e] == t) {
              code = _icdRowSplit(e, icdCodes).$1;
              type = _diagTypeOf(icd, i);
              break;
            }
          }
          out[t] = code;
          // ผู้วินิจฉัย เวลา ประเภท (แสดงแถวแบบรายการ Diagnosis Text)
          _mcDxMeta[t] = (
            [by[t] ?? '', if (at[t] case final x?) _clock(x)]
                .where((e) => e.isNotEmpty)
                .join('  '),
            type
          );
        }
      } finally {
        _speechStep = keep;
      }
    }
    if (out.isEmpty) {
      for (final x in c.dx) {
        out[x.text] = x.icd10;
      }
    }
    return out;
  }

  /// แถวการวินิจฉัยแบบรายการ Diagnosis Text ของขั้นวินิจฉัย:
  /// ชื่อโรค (2 บรรทัด) · ผู้วินิจฉัย + เวลา · ดินสอขวา · ใต้แถว = ป้ายรหัส ICD-10 + ประเภท
  /// ยังว่าง = แถวว่างแบบแถวอื่นในฟอร์ม
  Widget _mcDxRow(_McDraft d, VoidCallback edit) {
    final dx = d.dx.text.trim();
    if (dx.isEmpty) {
      return _mcRow(Icons.assignment_rounded, 'การวินิจฉัย', null, edit,
          must: true, first: true);
    }
    final meta = _mcDxMeta[dx];
    final row = _gListRow(
      first: true,
      inset: 8.0,
      titleLines: 2,
      title: dx,
      sub: meta == null || meta.$1.isEmpty ? 'การวินิจฉัย' : meta.$1,
      onTap: edit,
      trail: IconButton(
        onPressed: edit,
        tooltip: 'แก้รายการนี้',
        iconSize: 20.0,
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        icon: const Icon(Icons.edit_outlined, color: _ink3),
      ),
    );
    final code = d.dxCode;
    if (code == null) return row;
    // ป้ายรหัส: พื้นเทาจาง · เหรียญประเภท + รหัส + ชื่อประเภท (ชุดเดียวกับขั้นวินิจฉัย)
    final t = meta?.$2 ?? '1';
    final tName = _diagTypes
        .firstWhere((x) => x.$1 == t, orElse: () => _diagTypes.first)
        .$2;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      row,
      Transform.translate(
        offset: const Offset(0.0, -6.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 6.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
              decoration: const ShapeDecoration(
                  color: Color(0xFFF1F3F4), shape: StadiumBorder()),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _typeDot(t, 20.0),
                const SizedBox(width: 6.0),
                Text(code,
                    style: _num(13.0, color: _blue, weight: FontWeight.w700)),
                const SizedBox(width: 6.0),
                Text(tName,
                    style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  // ---- หน้า 3: วินิจฉัยและคำแนะนำ
  List<Widget> _mcPageDx(_McDraft d, ErCase c) {
    final codes = _mcDxOptions(c);
    // ใช้ข้อมูลจากการวินิจฉัย: รายการเดียว = เติมเลย · หลายรายการ = เลือกจาก sheet
    void useDx(String v) {
      d.dx.text = v;
      d.dxCode = codes[v];
    }

    return [
      // มุมขวาล่างเว้า = ปุ่มใส่/เอารหัส ICD-10 ออกจากใบ (มีรหัสเท่านั้น · แบบการ์ดอาการสำคัญ)
      _mcCardOf(
          'การวินิจฉัย',
          'เลือกจากรายการของผู้ป่วย\nหรือพิมพ์เอง',
          notch: d.dxCode == null
              ? null
              : (
                  d.thaiName ? Icons.add_rounded : Icons.remove_rounded,
                  d.thaiName ? 'ใส่รหัส ICD-10' : 'เอารหัสออก',
                  () => setState(() => d.thaiName = !d.thaiName)
                ),
          _mcArt('assets/images/er_dx_doctor_t.png'),
          [
            // ปุ่มเดียว (แบบการ์ดอาการ): ดึงข้อความวินิจฉัย + ICD-10 จากขั้นวินิจฉัย/เวชระเบียน
            _mcTile(
                Icons.assignment_rounded,
                'ใช้ข้อมูลจากการวินิจฉัย',
                codes.isEmpty
                    ? null
                    : codes.length == 1
                        ? () => setState(() => useDx(codes.keys.first))
                        : () => _mcPick('การวินิจฉัย', codes.keys.toList(),
                            () => d.dx.text.isEmpty ? null : d.dx.text, useDx)),
            _mcDxRow(
                d,
                // หน้าพิมพ์มีปุ่ม "จากการวินิจฉัย" ขวาหัวข้อ (แทนทั้งช่อง) · รหัสผูกตามข้อความที่ตรงกัน
                () => _mcEditText(d.dx, 'การวินิจฉัย',
                    'เลือกจากรายการวินิจฉัยของผู้ป่วย หรือพิมพ์เอง',
                    fromRecord: codes.isEmpty ? '' : codes.keys.first,
                    recordLabel: 'จากการวินิจฉัย',
                    recordIcon: Icons.assignment_rounded,
                    replace: true,
                    onEdit: () => d.dxCode = codes[d.dx.text])),
          ]),
      _mcCardOf('ความเห็นของแพทย์', 'คำแนะนำและหมายเหตุที่จะพิมพ์บนใบ',
          const SizedBox.shrink(), [
        // ปุ่มเดียว: เปิดหน้าพิมพ์ (มีไมค์ + คำที่ใช้บ่อยใต้ช่องพิมพ์)
        _mcTile(
            Icons.add_comment_rounded,
            'เพิ่มความเห็นแพทย์',
            () => _mcEditText(d.advice, 'ความเห็นและข้อแนะนำ',
                'เช่น ควรพักรักษาตัว และมาตรวจตามนัด',
                chips: _mcAdviceChips)),
        // แถวแสดงเฉพาะเมื่อกรอกแล้ว (แตะ = แก้) · ยังว่าง = มีแค่ปุ่มเพิ่มความเห็น
        if (d.advice.text.trim().isNotEmpty)
          _mcRow(
              Icons.chat_bubble_rounded,
              'ความเห็นและข้อแนะนำ',
              d.advice.text,
              () => _mcEditText(d.advice, 'ความเห็นและข้อแนะนำ',
                  'เช่น ควรพักรักษาตัว และมาตรวจตามนัด',
                  chips: _mcAdviceChips),
              first: true,
              empty: 'ยังไม่ได้กรอก'),
        if (d.note.text.trim().isNotEmpty)
          _mcRow(
              Icons.sticky_note_2_rounded,
              'หมายเหตุ',
              d.note.text,
              () => _mcEditText(
                  d.note, 'หมายเหตุ', 'รายละเอียดที่ต้องการแสดงในใบรับรอง'),
              empty: 'ยังไม่ได้กรอก'),
      ]),
    ];
  }

  // ---- หน้าสรุป: ตัวอย่างเอกสารตามที่กรอก + ยืนยันการรับรอง
  List<Widget> _mcPageSummary(_McDraft d) => [
        _mcCardOf('ยืนยันการรับรอง', 'ตรวจทานเอกสารด้านล่างก่อนออกใบ',
            const SizedBox.shrink(), [
          _gListRow(
            first: true,
            inset: 8.0,
            lead: _McGIcon(Icons.verified_rounded, on: d.certify),
            title: 'ขอรับรองว่าผู้ป่วยมารับการตรวจที่นี่จริง *',
            titleLines: 3,
            sub: d.editing == null
                ? 'จำเป็นก่อนออกใบรับรอง'
                : 'แก้ไขใบเลขที่ ${d.editing!.no}',
            onTap: () => setState(() => d.certify = !d.certify),
            trail: Checkbox(
              value: d.certify,
              activeColor: _blue,
              onChanged: (v) => setState(() => d.certify = v ?? false),
            ),
          ),
        ]),
        // ตัวอย่างเอกสารดูที่กระดาษแผงซ้าย (ไม่ซ้ำในแผงขวา)
      ];

  /// เลขที่ที่จะได้ (แสดงในตัวอย่าง ยังไม่นับจนกว่าจะออกจริง)
  String _mcPreviewNo() =>
      'MC${DateTime.now().year + 543}-${_mcSeq.toString().padLeft(4, '0')}';

  /// ต่อท้ายข้อความในช่อง (ไม่ซ้ำ)
  void _mcAppend(TextEditingController c, String t) {
    final cur = c.text.trim();
    if (cur.contains(t)) return;
    setState(() => c.text = cur.isEmpty ? t : '$cur $t');
  }

  void _mcIssue() {
    final d = _mcDraft;
    if (d == null || d.missing.isNotEmpty) return;
    final old = d.editing;
    // แก้ไข: คงเลขที่และผู้ออกเดิม · ออกใหม่: เลขที่ถัดไป + ผู้ออก = คนที่ login
    final c = d.toCert(old?.no ?? _mcNextNo());
    final cert = _MedCert(
      issuedBy: old?.issuedBy ?? ErSession.instance.user?.name ?? c.doctor,
      no: c.no,
      type: c.type,
      doctor: c.doctor,
      issued: c.issued,
      thaiName: c.thaiName,
      symptoms: c.symptoms,
      from: c.from,
      to: c.to,
      dx: c.dx,
      dxCode: c.dxCode,
      advice: c.advice,
      note: c.note,
      draft: false,
    );
    final list = _certsOf(d.hn);
    final at = old == null ? -1 : list.indexOf(old);
    // บันทึกสำเร็จแบบเดียวกับทุกขั้น (พื้นเขียวแผ่จากปุ่ม + หน้าสำเร็จ) ไม่ใช่ snackbar
    // ปิด = หุบแผง แผงซ้ายเปิดรายการใบรับรอง · "ดูที่บันทึก" = แผงซ้ายรายการใบรับรอง
    _wfSaveBurst(at >= 0 ? 'แก้ไขใบรับรองแพทย์' : 'ออกใบรับรองแพทย์',
        atFull: () => setState(() {
              if (at >= 0) {
                list[at] = cert;
              } else {
                list.add(cert);
              }
              _mcDraft = null;
            }),
        onClose: () {
          setState(() {
            _detailTab = _mcTab;
            _mcLiveOff = false;
          });
          _accPaneDrop();
          _closeSpeech();
        },
        onView: () => setState(() => _detailTab = _mcTab));
  }

  // ------------------------------------------------ ตัวอย่างเอกสาร

  Widget _mcPreviewCard(_MedCert c) => Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: _line, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Text('ตัวอย่างเอกสาร',
                  style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 6.0),
              Text('อัปเดตขณะกรอก', style: _t(9.5, color: _ink3)),
              const Spacer(),
              _miniBtn(Icons.open_in_full_rounded, 'ขยาย', () => _mcView(c)),
            ]),
            const SizedBox(height: 8.0),
            Flexible(child: FittedBox(child: _mcPaper(c))),
          ],
        ),
      );

  /// หน้าเอกสาร A4 (420 × 594) · ช่องที่ยังไม่กรอกเป็นเส้นจุด
  /// focus = key ของบรรทัดการวินิจฉัย (ให้ภาพตัวอย่างซูมเข้าหาบรรทัดนี้)
  /// hi = ส่วนที่กำลังกรอก (ไฮไลต์พื้นฟ้าอ่อน): type intro sym rest dx advice note sign
  Widget _mcPaper(_MedCert c, {GlobalKey? focus, Set<String> hi = const {}}) {
    final p = _caseP();
    final ec = erCaseOf(p.hn);
    const dots = '……………………';
    TextSpan v(String s) => TextSpan(
        text: s.isEmpty ? dots : s,
        style: _t(9.5,
            color: s.isEmpty ? _g5 : _inkTitle, weight: FontWeight.w700));
    TextSpan k(String s) =>
        TextSpan(text: s, style: _t(9.5, color: _ink2, height: 1.9));
    Widget para(List<TextSpan> s) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text.rich(TextSpan(children: s)),
        );
    final bad = c.to.isBefore(c.from);
    Widget mark(String key, Widget child) =>
        Stack(clipBehavior: Clip.none, children: [
          // แถบไฮไลต์ด้านหลัง ล้นขอบข้อความเล็กน้อย (ไม่กินที่ เนื้อหาไม่ขยับ)
          Positioned(
            left: -6.0,
            right: -6.0,
            top: -1.0,
            bottom: 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: hi.contains(key)
                    ? const Color(0xFFE2EAF8)
                    : const Color(0x00E2EAF8),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
          child,
        ]);
    return Container(
      width: 420.0,
      height: 594.0,
      padding: const EdgeInsets.fromLTRB(30.0, 26.0, 30.0, 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0B1B3F).withValues(alpha: 0.10),
              blurRadius: 14.0,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(children: [
        if (c.draft)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.5,
                  child: Text('แบบร่าง',
                      style: _t(64.0,
                          color: _blue.withValues(alpha: 0.05),
                          weight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    size: 18.0, color: _blue),
              ),
            ),
            const SizedBox(height: 6.0),
            Center(
              child: Text('ใบรับรองแพทย์',
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
            mark(
                'type',
                Center(
                  child: Text(
                      c.type == _mcTypes.first ? 'Medical Certificate' : c.type,
                      style: _t(9.0, color: _ink3)),
                )),
            const SizedBox(height: 10.0),
            Container(height: 2.0, color: _blue.withValues(alpha: 0.6)),
            const SizedBox(height: 8.0),
            Row(children: [
              Text('เลขที่ ${c.no}',
                  style: _num(8.5, color: _ink3, weight: FontWeight.w600)),
              const Spacer(),
              Text('วันที่ ${_apptDate(c.issued)}',
                  style: _t(8.5, color: _ink3, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12.0),
            mark(
                'intro',
                para([
                  k('ข้าพเจ้า '),
                  v(c.doctor),
                  k(' แพทย์ผู้ประกอบวิชาชีพเวชกรรม ได้ทำการตรวจร่างกาย '),
                  v(p.name),
                  k(' อายุ '),
                  v(ec.ageText),
                  k(' HN '),
                  v(p.hn),
                  k(' เมื่อวันที่ '),
                  v(_apptDate(c.issued)),
                ])),
            mark('sym', para([k('อาการที่ตรวจพบ : '), v(c.symptoms)])),
            mark(
                'dx',
                KeyedSubtree(
                    key: focus,
                    child: para([k('การวินิจฉัย : '), v(c.dxShown)]))),
            mark('advice', para([k('ความเห็นของแพทย์ : '), v(c.advice)])),
            mark(
                'rest',
                para([
                  k('สมควรพักรักษาตัวเป็นเวลา '),
                  v(bad ? '' : '${c.days}'),
                  k(' วัน ตั้งแต่วันที่ '),
                  v(_apptDate(c.from)),
                  k(' ถึงวันที่ '),
                  v(_apptDate(c.to)),
                ])),
            if (c.note.isNotEmpty || hi.contains('note'))
              mark('note', para([k('หมายเหตุ : '), v(c.note)])),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 190.0,
                child: mark(
                    'sign',
                    Column(children: [
                      Text('ลงชื่อ …………………………………',
                          style: _t(9.0, color: _ink2)),
                      const SizedBox(height: 4.0),
                      Text('( ${c.doctor.isEmpty ? dots : c.doctor} )',
                          textAlign: TextAlign.center,
                          style: _t(9.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                      Text('แพทย์ผู้ตรวจ', style: _t(8.5, color: _ink3)),
                      Text('เลขที่ใบอนุญาตประกอบวิชาชีพ ว. …………',
                          style: _t(8.0, color: _ink3)),
                    ])),
              ),
            ),
            const SizedBox(height: 14.0),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 4.0),
            Text('ออกโดยระบบ HOSxP Plus · ห้องฉุกเฉิน',
                style: _t(7.5, color: _ink3)),
          ],
        ),
      ]),
    );
  }
}

/// ไอคอนนำแถวของฟอร์มใบรับรอง: Material filled สองโทนแบบ Google (ref Figma 1205-336)
/// ครึ่งบนซ้ายสว่าง ครึ่งล่างขวาเข้ม แบ่งตามแนวทแยง (แสงจากซ้ายบน) บนพื้นวงกลมสีอ่อน
/// มีค่าแล้ว = โทนน้ำเงิน Google · ยังว่าง = โทนเทา · [alert] = โทนแดง (ค่าผิดปกติ)
/// [size] = เส้นผ่านศูนย์กลางวง (ไอคอนกับแผ่นรองขาวย่อ/ขยายตามสัดส่วน)
class _McGIcon extends StatelessWidget {
  const _McGIcon(this.icon,
      {this.on = false,
      this.alert = false,
      this.size = 40.0,
      this.navy = false});

  final IconData icon;
  final bool on, alert;
  final double size;

  /// ชุดสีกรอบไอคอนกลางของแอป (กฎกรอบไอคอน): กรอบ #DBE5FC · สัญลักษณ์กรมท่าสองโทน
  final bool navy;

  /// ไอคอนที่ไม่มีเส้นข้างใน (ไม่ต้องรองพื้นขาว กันขาวโผล่ตามช่องว่างรอบรูป)
  /// (List ไม่ใช่ Set: IconData ไม่มี primitive equality ใช้ใน const Set ไม่ได้)
  static const _solid = [
    Icons.person_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_add_alt_1_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    // สีจาก Figma (Selection colors): สว่าง 4385F3 · เข้ม 1967D3 · พื้น D2E3FD
    // ผิดปกติ: แดงชุดเดียวกัน (สว่าง EA4335 · เข้ม C5221F · พื้น FCE8E6)
    final light = navy
        ? const Color(0xFF5A69B4)
        : alert
            ? const Color(0xFFEA4335)
            : on
                ? const Color(0xFF4385F3)
                : _g5;
    final dark = navy
        ? const Color(0xFF2B3F96)
        : alert
            ? const Color(0xFFC5221F)
            : on
                ? const Color(0xFF1967D3)
                : const Color(0xFF80868B);
    final k = size / 40.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: navy
            ? const Color(0xFFDBE5FC)
            : alert
                ? const Color(0xFFFCE8E6)
                : on
                    ? const Color(0xFFD2E3FD)
                    : const Color(0xFFF1F3F4),
      ),
      // เส้นข้างในไอคอน (ช่องโปร่งของ filled icon) = ขาว: แผ่นขาวรองใต้กลางไอคอน
      child: Stack(alignment: Alignment.center, children: [
        if (!_solid.contains(icon))
          Container(
            width: 12.0 * k,
            height: 12.0 * k,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0 * k),
            ),
          ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [light, light, dark, dark],
            stops: const [0.0, 0.5, 0.5, 1.0],
          ).createShader(r),
          child: Icon(icon, size: 24.0 * k, color: Colors.white),
        ),
      ]),
    );
  }
}

/// ไอคอน "ชื่อโรค" (Figma 1205-390): เอกสารขาวมุมพับ หัวเข้ม + 2 บรรทัด (skeleton) · เหรียญเชื้อโรคมุมขวาล่าง
/// วาดด้วยโค้ด (ไม่ใช้ไฟล์ภาพ hot reload ได้) · off = โทนเทา
class _McDiseaseIcon extends StatelessWidget {
  const _McDiseaseIcon({this.on = true});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final ink = on ? const Color(0xFF165CD1) : const Color(0xFF80868B);
    final soft = on ? const Color(0xFF90B9F3) : const Color(0xFFC4C7C5);
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? const Color(0xFFD2E3FD) : const Color(0xFFF1F3F4),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        // ขนาด/ตำแหน่งเท่าเอกสารของ Icons.description_rounded 24 ในวง 40 (16×20 กลางวง)
        Positioned(
          left: 12.0,
          top: 10.0,
          width: 16.0,
          height: 20.0,
          child: CustomPaint(painter: _McDocPainter(soft)),
        ),
        // หัวเอกสาร = แถบหนาสีเข้ม (skeleton แทนคำว่า "ชื่อโรค") · ตามด้วย 2 บรรทัดสีอ่อน
        Positioned(
          left: 14.0,
          top: 14.0,
          child: Container(
            width: 8.0,
            height: 2.5,
            decoration: BoxDecoration(
                color: ink, borderRadius: BorderRadius.circular(1.25)),
          ),
        ),
        for (final (y, w) in const [(19.0, 7.0), (22.0, 5.0)])
          Positioned(
            left: 14.0,
            top: y,
            child: Container(
              width: w,
              height: 1.5,
              decoration: BoxDecoration(
                  color: soft, borderRadius: BorderRadius.circular(0.75)),
            ),
          ),
        Positioned(
          right: 6.0,
          bottom: 7.0,
          child: Container(
            width: 14.0,
            height: 14.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? const Color(0xFF0B52D0) : const Color(0xFF80868B),
            ),
            child: const Icon(Icons.coronavirus_rounded,
                size: 10.5, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

/// แผ่นเอกสารขาวมุมขวาบนพับ (พับ = สีอ่อนของไอคอน)
class _McDocPainter extends CustomPainter {
  const _McDocPainter(this.fold);

  final Color fold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, f = w * 0.34, r = 2.0;
    final body = Path()
      ..moveTo(r, 0)
      ..lineTo(w - f, 0)
      ..lineTo(w, f)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFFAFBFD));
    final ear = Path()
      ..moveTo(w - f, 0)
      ..lineTo(w, f)
      ..lineTo(w - f, f)
      ..close();
    canvas.drawPath(ear, Paint()..color = fold);
  }

  @override
  bool shouldRepaint(_McDocPainter old) => old.fold != fold;
}

/// ตัวอย่างเอกสาร: เปิดครั้งแรก = กระดาษเต็มแผ่นจางเข้า → ค้าง → ซูมนุ่ม ๆ ไปบรรทัด focus → ไฮไลต์
/// replay เปลี่ยน (เลือกแบบใหม่) = ไฮไลต์จางเข้าใหม่อย่างเดียว · กระดาษ 420×594
class _McPaperFocus extends StatefulWidget {
  const _McPaperFocus(
      {required this.paper, required this.focus, required this.replay});

  final Widget paper;
  final GlobalKey focus;
  final Object replay;

  @override
  State<_McPaperFocus> createState() => _McPaperFocusState();
}

class _McPaperFocusState extends State<_McPaperFocus>
    with TickerProviderStateMixin {
  static const _pw = 420.0, _ph = 594.0, _vh = 280.0;
  // ช่วงบรรทัดยืดหดหลังเปลี่ยนแบบ: วัดตำแหน่งทุกเฟรม กล้องเลื่อนตามต่อเนื่อง
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 360))
    ..addListener(_measure);
  // story ตอนเปิด เริ่มหลัง sheet เลื่อนขึ้นเสร็จ (ไม่งั้นเล่นระหว่าง sheet กำลังเข้า มองไม่เห็น)
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1900));
  final _paperKey = GlobalKey();
  Rect _line = const Rect.fromLTWH(36.0, 300.0, 348.0, 24.0);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _in.forward();
    });
    _play();
  }

  @override
  void didUpdateWidget(_McPaperFocus old) {
    super.didUpdateWidget(old);
    if (old.replay != widget.replay) _play();
  }

  /// ตำแหน่งบรรทัด focus ในพิกัดกระดาษ
  void _measure() {
    final rb = widget.focus.currentContext?.findRenderObject() as RenderBox?;
    final pb = _paperKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || pb == null || !rb.attached || !pb.attached) return;
    if (!rb.hasSize) return;
    final r = rb.localToGlobal(Offset.zero, ancestor: pb) & rb.size;
    if (r != _line && mounted) setState(() => _line = r);
  }

  void _play() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measure();
      _c.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        // ทั้งแผ่นพอดีกรอบ (เผื่อแผ่นซ้อนด้านหลัง) → กระดาษกว้างพอดีกรอบ บรรทัด focus กลางกรอบ
        final fit = math.min(w / _pw, _vh / _ph) * 0.9;
        final zoom = (w - 40.0) / _pw;
        // กระดาษล้นเกินกรอบได้ แล้วจางหายที่ขอบ: บนน้อย (ไม่ทับหัว sheet) ล่างมาก (ใต้ปุ่มตัวเลือก)
        const eT = 20.0, eB = 64.0, h = _vh + eT + eB;
        return SizedBox(
          width: w,
          height: _vh,
          child: OverflowBox(
            maxHeight: h,
            minHeight: h,
            // วางให้ขอบบนของพื้นที่ล้นอยู่ที่ -eT
            alignment: const Alignment(0.0, 2 * eT / (eT + eB) - 1),
            // ขอบบน/ล่างที่กระดาษเลยกรอบ = จางหาย (ไม่ใช่เส้นตัดแข็ง)
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FFFFFF),
                  Colors.white,
                  Colors.white,
                  Color(0x00FFFFFF)
                ],
                stops: [0.0, 0.12, 0.7, 1.0],
              ).createShader(r),
              child: AnimatedBuilder(
                animation: Listenable.merge([_c, _in]),
                builder: (context, child) {
                  // 0–0.2 จางเข้าทั้งแผ่น · 0.2–0.45 ค้าง · 0.45–0.85 ซูมเข้าบรรทัด focus
                  final t = _in.value;
                  final up =
                      Curves.easeOut.transform((t / 0.2).clamp(0.0, 1.0));
                  final k = Curves.easeInOutCubic
                      .transform(((t - 0.45) / 0.4).clamp(0.0, 1.0));
                  final s = fit + (zoom - fit) * k;
                  final cy = _ph / 2 + (_line.center.dy - _ph / 2) * k;
                  final dx = w / 2 - _pw / 2 * s;
                  final dy = eT + _vh / 2 - cy * s + 16.0 * (1 - up);
                  return Opacity(
                    opacity: up,
                    child: Stack(clipBehavior: Clip.hardEdge, children: [
                      Positioned(
                        left: dx,
                        top: dy,
                        width: _pw,
                        height: _ph,
                        child: Transform.scale(
                            scale: s,
                            alignment: Alignment.topLeft,
                            child: child),
                      ),
                    ]),
                  );
                },
                child: KeyedSubtree(key: _paperKey, child: widget.paper),
              ),
            ),
          ),
        );
      });
}

/// เนื้อกระดาษ: เม็ดละเอียดจาง ๆ (สุ่มแบบตายตัว) + ขอบบน/ซ้ายสว่างบาง (สันกระดาษรับแสง)
class _McPaperGrain extends CustomPainter {
  const _McPaperGrain();

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(7);
    final dark = Paint()..color = const Color(0x0F5A4A30);
    final lite = Paint()..color = const Color(0x22FFFFFF);
    for (var i = 0; i < 1400; i++) {
      final o =
          Offset(r.nextDouble() * size.width, r.nextDouble() * size.height);
      canvas.drawCircle(o, 0.35 + r.nextDouble() * 0.5, i.isEven ? dark : lite);
    }
    // เส้นใยสั้น ๆ ประปราย
    final fiber = Paint()
      ..color = const Color(0x0A5A4A30)
      ..strokeWidth = 0.6;
    for (var i = 0; i < 90; i++) {
      final o =
          Offset(r.nextDouble() * size.width, r.nextDouble() * size.height);
      final a = r.nextDouble() * math.pi;
      final l = 3.0 + r.nextDouble() * 6.0;
      canvas.drawLine(o, o + Offset(math.cos(a), math.sin(a)) * l, fiber);
    }
    // สันกระดาษรับแสง (บน + ซ้าย)
    final edge = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(2, 0.8), Offset(size.width - 2, 0.8), edge);
    canvas.drawLine(const Offset(0.8, 2), Offset(0.8, size.height - 2), edge);
  }

  @override
  bool shouldRepaint(_McPaperGrain old) => false;
}

/// รูปทรงกระดาษอ่อน: ขอบบนโก่งขึ้นนิด · ขอบข้าง/ล่างโค้งเบา · มุมขวาบนตัดเฉียง (ส่วนที่พับ)
class _McPaperShape extends CustomClipper<Path> {
  const _McPaperShape();

  static Path outline(Size s) {
    final w = s.width, h = s.height;
    return Path()
      ..moveTo(0, 2)
      // ไม่มีรอยพับ/ม้วนมุม (ผู้ใช้ไม่เอา) · ขอบบนโก่งนิด
      ..quadraticBezierTo(w * 0.5, -4, w, 3)
      ..quadraticBezierTo(w + 3, h * 0.55, w - 1, h - 3)
      ..quadraticBezierTo(w * 0.45, h + 4, 2, h - 3)
      ..quadraticBezierTo(-3, h * 0.5, 0, 2)
      ..close();
  }

  @override
  Path getClip(Size size) => outline(size);

  @override
  bool shouldReclip(_McPaperShape old) => false;
}

/// ความอ่อนของกระดาษ: ขอบล่างหม่นนิด · เส้นขอบตามรูปทรง
/// · มุมขวาบนพับลง เห็นด้านหลังกระดาษ + เงาใต้รอยพับ
class _McPaperBend extends CustomPainter {
  const _McPaperBend();

  @override
  void paint(Canvas canvas, Size size) {
    final shape = _McPaperShape.outline(size);
    canvas.save();
    canvas.clipPath(shape);
    // ขอบล่างหม่นลงนิด (กระดาษโค้งลง)
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0x00000000), Color(0x0F3A2A10)],
            stops: [0.0, 0.75, 1.0],
          ).createShader(Offset.zero & size));
    canvas.restore();
    canvas.drawPath(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = const Color(0x22000000));
  }

  @override
  bool shouldRepaint(_McPaperBend old) => false;
}

/// กล้องของกระดาษแผงซ้าย: focus ว่าง = เห็นทั้งแผ่นวางเอียง (มิติแบบภาพประกอบ)
/// มี focus = ซูมให้ส่วนนั้นพอดีกรอบ + กระดาษค่อย ๆ ตั้งตรง (อ่านง่าย) · เปลี่ยน focus = เลื่อนนุ่ม ๆ
/// ขอบบน/ล่างที่กระดาษเลยกรอบ = จางหาย
class _McPaperCam extends StatefulWidget {
  const _McPaperCam(
      {required this.focus, required this.child, this.straight = false});

  final List<GlobalKey> focus;

  /// ไม่มี focus แต่ให้กระดาษตั้งตรงทั้งแผ่น (ขั้นสรุป: ตรวจทานก่อนออกใบ)
  final bool straight;
  final Widget child;

  @override
  State<_McPaperCam> createState() => _McPaperCamState();
}

class _McPaperCamState extends State<_McPaperCam> {
  static const _pw = 420.0, _ph = 594.0;
  final _paperKey = GlobalKey();
  Rect? _target;

  // story ตอนปรากฏ: ทั้งแผ่นวางเอียงจางเข้า + เลื่อนขึ้น → ค้างให้เห็นทั้งแผ่น → กล้องซูมไปส่วนที่กรอก
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // วัดส่วน focus หลังวาด (พิกัดกระดาษ) · เปลี่ยน = เลื่อนกล้อง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pb = _paperKey.currentContext?.findRenderObject() as RenderBox?;
      Rect? u;
      for (final k in widget.focus) {
        final rb = k.currentContext?.findRenderObject() as RenderBox?;
        if (pb == null || rb == null || !rb.attached || !rb.hasSize) continue;
        final r = rb.localToGlobal(Offset.zero, ancestor: pb) & rb.size;
        u = u == null ? r : u.expandToInclude(r);
      }
      // เผื่อที่รอบส่วนที่โฟกัส (ไม่อัดชิดขอบกรอบ)
      final t = u?.inflate(40.0);
      if (t != _target) setState(() => _target = t);
    });
    final target = _ready ? _target : null;
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth, h = box.maxHeight;
      // ทั้งแผ่น (เผื่อแผ่นซ้อน + มุมเอียง)
      // ทั้งแผ่นพอดีกรอบ (เผื่อเงา + มุมเอียงตอนเปิด)
      final fit = math.min(w / _pw, h / _ph) * 0.9;
      const full = Rect.fromLTWH(0, 0, _pw, _ph);
      return TweenAnimationBuilder<double>(
        // ปรากฏครั้งเดียวตอนเปิดแผง: จางเข้า + เลื่อนขึ้นนิด
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, a, child) => Opacity(
          opacity: a,
          child: Transform.translate(
              offset: Offset(0.0, 28.0 * (1 - a)), child: child),
        ),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // เห็นทั้งแผ่นแล้ว ไม่จางขอบ
            colors: [Colors.white, Colors.white],
          ).createShader(r),
          child: ClipRect(
            // ตั้งตรงแยกจากระดับซูม: มี focus = ตรงเต็มที่ · ไม่มี = เอียงแบบภาพประกอบ
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                  end: target != null || (widget.straight && _ready)
                      ? 1.0
                      : 0.0),
              duration: const Duration(milliseconds: 720),
              curve: Curves.easeInOutCubic,
              builder: (context, k, child) => TweenAnimationBuilder<Rect?>(
                tween: RectTween(end: target ?? full),
                duration: const Duration(milliseconds: 720),
                curve: Curves.easeInOutCubic,
                child: child,
                builder: (context, r, child) {
                  final rect = r ?? full;
                  // ซูมสุด = กระดาษกว้างพอดีกรอบ เว้นขอบ (ขอบซ้ายขวาไม่หลุด ไม่อัดแน่น)
                  final maxS = math.max(fit, (w - 56.0) / _pw);
                  final s = math
                      .min(w / rect.width, h / rect.height)
                      .clamp(fit, maxS);
                  final dx = w / 2 - rect.center.dx * s;
                  // วางสูงกว่ากลางกรอบเล็กน้อย (กระดาษขยับขึ้น ชิดหัวหน้า)
                  // ซูมเข้า = สูงกว่ากลางกรอบ (ชิดหัวหน้า) · ทั้งแผ่น = กึ่งกลาง (ไม่ตัดหัวกระดาษ)
                  // ระดับซูมจากขนาดกรอบที่ดูอยู่ (ทั้งแผ่น = 0) ไม่ใช่จากช่วงซูม (กรอบแคบ maxS ≈ fit หารแล้วเพี้ยน)
                  final zoomed =
                      ((full.height / rect.height - 1.0) / 1.5).clamp(0.0, 1.0);
                  final dy = h * (0.5 - 0.14 * zoomed) - rect.center.dy * s;
                  return Stack(clipBehavior: Clip.none, children: [
                    Positioned(
                      left: dx,
                      top: dy,
                      width: _pw,
                      height: _ph,
                      child: Transform.scale(
                        scale: s,
                        alignment: Alignment.topLeft,
                        child: Transform(
                          alignment: Alignment((rect.center.dx / _pw) * 2 - 1,
                              (rect.center.dy / _ph) * 2 - 1),
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateX(-0.45 * (1 - k))
                            ..rotateZ(0.16 * (1 - k)),
                          child: child,
                        ),
                      ),
                    ),
                  ]);
                },
              ),
              child: KeyedSubtree(key: _paperKey, child: widget.child),
            ),
          ),
        ),
      );
    });
  }
}

/// เงาใต้กระดาษตามรูปทรง _McPaperShape (drawShadow ไม่ใช้ blur filter)
class _McPaperShadow extends CustomPainter {
  const _McPaperShadow();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(_McPaperShape.outline(size).shift(const Offset(2, 5)),
        const Color(0x660B1B3F), 6.0, true);
  }

  @override
  bool shouldRepaint(_McPaperShadow old) => false;
}

/// ย่อหน้าบนกระดาษตัวอย่าง: ค่าที่กรอกเปลี่ยน = พิมพ์ค่าใหม่ทีละตัว (writing) + ไฮไลต์เขียวอ่อนหลังค่า
/// แล้วค่อย ๆ จางหาย ไม่มีกรอบ (กติกา diff: เพิ่ม/แก้ = เขียว + พิมพ์) · เปิดครั้งแรกไม่เล่น
class _McWritePara extends StatefulWidget {
  const _McWritePara(
      {required this.parts,
      required this.label,
      required this.value,
      required this.empty,
      required this.dots,
      this.maxLines});

  final List<(String, bool)> parts;
  final TextStyle label, value, empty;
  final String dots;

  /// จำกัดบรรทัดบนกระดาษ (เกิน = …) · null = ไม่จำกัด
  final int? maxLines;

  @override
  State<_McWritePara> createState() => _McWriteParaState();
}

class _McWriteParaState extends State<_McWritePara>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..value = 1.0;

  String _vals(_McWritePara w) => [
        for (final (t, isV) in w.parts)
          if (isV) t
      ].join('\u0001');

  @override
  void didUpdateWidget(_McWritePara old) {
    super.didUpdateWidget(old);
    if (_vals(old) != _vals(widget)) _c.forward(from: 0.0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // พิมพ์ (0–0.45, easeOut ไหลนุ่ม) · ไฮไลต์เขียวอ่อนหลังค่าที่เปลี่ยน ค่อย ๆ จาง (0.55–1)
          final typed =
              Curves.easeOutCubic.transform((t / 0.45).clamp(0.0, 1.0));
          final glow = t >= 1.0
              ? 0.0
              : 1.0 -
                  Curves.easeInOut
                      .transform(((t - 0.55) / 0.45).clamp(0.0, 1.0));
          final total = [
            for (final (s, isV) in widget.parts)
              if (isV) s.length
          ].fold(0, (a, b) => a + b);
          var left = (total * typed).round();
          final hl = Paint()
            ..color = const Color(0xFF34A853).withValues(alpha: 0.16 * glow);
          final spans = <TextSpan>[];
          for (final (s, isV) in widget.parts) {
            if (!isV) {
              spans.add(TextSpan(text: s, style: widget.label));
            } else if (s.isEmpty) {
              spans.add(TextSpan(text: widget.dots, style: widget.empty));
            } else {
              final n = left.clamp(0, s.length);
              left -= n;
              // ตัวที่ยังไม่พิมพ์ = จองที่ไว้ (โปร่งใส) ย่อหน้าไม่กระตุกตอนพิมพ์
              spans.add(TextSpan(
                  text: s.substring(0, n),
                  style: glow > 0.0
                      ? widget.value.copyWith(background: hl)
                      : widget.value));
              if (n < s.length) {
                spans.add(TextSpan(
                    text: s.substring(n),
                    style:
                        widget.value.copyWith(color: const Color(0x00000000))));
              }
            }
          }
          return Text.rich(TextSpan(children: spans),
              maxLines: widget.maxLines,
              overflow: widget.maxLines == null
                  ? TextOverflow.clip
                  : TextOverflow.ellipsis);
        },
      );
}

/// ตราประทับโรงพยาบาลบนกระดาษตัวอย่าง: ยังไม่ยืนยัน = วงประจาง (ที่ประทับ)
/// ยืนยัน = หมึกค่อย ๆ ซึม: รอยหมึกปรากฏจากกลางออกไปขอบ (วงเปิดขอบนุ่ม) ตราไม่ขยับ
/// สีหมึกจางเข้าเต็มที่ตามการซึม · ยกเลิกติ๊ก = จางออก
class _McStamp extends StatelessWidget {
  const _McStamp({required this.on});

  final bool on;

  static const ink = Color(0xFF1967D3);

  Widget _impression() {
    final c = ink.withValues(alpha: 0.85);
    return Container(
      width: 72.0,
      height: 72.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c, width: 3.0),
      ),
      child: Container(
        width: 58.0,
        height: 58.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c, width: 1.2),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_hospital_rounded, size: 18.0, color: c),
          Text('รับรองแล้ว',
              style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontFamilyFallback: _fontFb,
                  fontSize: 8.5,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: c)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 76.0,
        height: 76.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: on ? 1.0 : 0.0),
          duration: Duration(milliseconds: on ? 1400 : 220),
          curve: on ? Curves.easeOutCubic : Curves.easeIn,
          builder: (context, t, child) =>
              Stack(alignment: Alignment.center, children: [
            // ที่ประทับ (ประ) · จางเมื่อหมึกซึม
            Opacity(
              opacity: (1.0 - t * 2.0).clamp(0.0, 1.0),
              child: const CustomPaint(
                  size: Size(70.0, 70.0), painter: _McDashRing()),
            ),
            if (t > 0.0)
              // หมึกซึม: มาสก์วงกลมขยายจากกลาง ขอบนุ่ม (ไม่ใช่ blur) + ความเข้มตามการซึม
              Opacity(
                opacity: (0.35 + 0.65 * t).clamp(0.0, 1.0),
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => RadialGradient(
                    colors: const [
                      Colors.white,
                      Colors.white,
                      Color(0x00FFFFFF)
                    ],
                    stops: [
                      0.0,
                      (t * 0.85).clamp(0.0, 1.0),
                      (t * 1.15).clamp(0.01, 1.0)
                    ],
                  ).createShader(r),
                  child: child,
                ),
              ),
          ]),
          child: Transform.rotate(angle: -0.21, child: _impression()),
        ),
      );
}

/// วงประบอกที่ประทับตรา
class _McDashRing extends CustomPainter {
  const _McDashRing();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1.5;
    final p = Paint()
      ..color = const Color(0xFFB8C7DE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const n = 24;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r), a, math.pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(_McDashRing old) => false;
}

/// เส้นจุดของบรรทัดแบบฟอร์ม
class _McDotLine extends CustomPainter {
  const _McDotLine();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF9AA0A6);
    for (var x = 0.0; x < size.width; x += 3.0) {
      canvas.drawCircle(Offset(x, 0.5), 0.45, p);
    }
  }

  @override
  bool shouldRepaint(_McDotLine old) => false;
}

/// ลายเซ็นจำลองแบบเขียนด้วยปากกาหมึกน้ำเงิน: เส้นตวัดต่อเนื่อง (ตัวแรกสูงมีห่วง + ตัวเล็กหยัก + ตวัดขีดใต้)
/// น้ำหนักเส้นไม่เท่ากันตามแรงกด (หนากลางเส้น บางที่ปลาย)
class _McSignature extends CustomPainter {
  const _McSignature();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final pts = <List<double>>[
      [0.10, 0.30, 0.20, 0.02, 0.22, 0.20],
      [0.24, 0.40, 0.12, 0.62, 0.16, 0.66],
      [0.22, 0.70, 0.28, 0.40, 0.33, 0.48],
      [0.37, 0.56, 0.36, 0.70, 0.41, 0.62],
      [0.46, 0.52, 0.47, 0.42, 0.51, 0.50],
      [0.55, 0.60, 0.56, 0.72, 0.61, 0.56],
      [0.65, 0.40, 0.70, 0.30, 0.72, 0.46],
      [0.74, 0.62, 0.80, 0.66, 0.86, 0.50],
      [0.92, 0.36, 0.98, 0.70, 0.80, 0.84],
      [0.60, 0.96, 0.30, 0.92, 0.14, 0.86],
    ];
    final path = Path()..moveTo(0.04 * w, 0.78 * h);
    for (final q in pts) {
      path.cubicTo(q[0] * w, q[1] * h, q[2] * w, q[3] * h, q[4] * w, q[5] * h);
    }
    const ink = Color(0xFF1F4FA8);
    for (final m in path.computeMetrics()) {
      const n = 120;
      for (var i = 0; i < n; i++) {
        final a = m.length * i / n, b = m.length * (i + 1) / n;
        // แรงกด: เริ่มบาง หนาขึ้นช่วงกลาง บางลงตอนตวัดท้าย
        final pr = math.sin(math.pi * (0.15 + 0.8 * i / n));
        canvas.drawPath(
            m.extractPath(a, b + 0.6),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 0.7 + 1.5 * pr
              ..color = ink.withValues(alpha: 0.78 + 0.18 * pr));
      }
    }
    // จุดท้ายลายเซ็น
    canvas.drawCircle(Offset(0.93 * w, 0.22 * h), 1.3, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_McSignature old) => false;
}

/// วาดลายเส้นลายเซ็น (ปากกาหมึกน้ำเงิน) ย่อ/ขยายจากแผ่นเซ็น pad ให้พอดีกรอบ
class _ESigPainter extends CustomPainter {
  _ESigPainter(this.strokes, this.pad, {this.fit = true});

  final List<List<Offset>> strokes;
  final Size pad;

  /// true = ย่อขยายตามขอบเขตลายเส้น (แสดงบนเอกสาร) · false = พิกัดแผ่นเซ็นตรง ๆ (ขณะเซ็น)
  final bool fit;

  @override
  void paint(Canvas canvas, Size size) {
    if (pad.isEmpty || strokes.isEmpty) return;
    // ย่อขยายตามขอบเขตลายเส้นจริง (ไม่ใช่ทั้งแผ่นเซ็น) แล้ววางกึ่งกลางกรอบ
    // = ลายเซ็นเต็มกรอบเท่ากันทุกครั้ง ไม่เล็ก/เยื้องตามตำแหน่งที่เซ็นบนแผ่น
    var box = Offset.zero & pad;
    if (fit) {
      box = Rect.fromPoints(strokes.first.first, strokes.first.first);
      for (final st in strokes) {
        for (final o in st) {
          box = box.expandToInclude(Rect.fromPoints(o, o));
        }
      }
      box = box.inflate(3.0);
    }
    final k = math.min(size.width / box.width, size.height / box.height);
    canvas.save();
    canvas.translate((size.width - box.width * k) / 2 - box.left * k,
        (size.height - box.height * k) / 2 - box.top * k);
    canvas.scale(k);
    final p = Paint()
      ..color = const Color(0xFF1F4FA8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.6 / k; // หนาเท่ากันบนกระดาษไม่ว่าย่อขยายเท่าไร
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 0.8 / k, p..style = PaintingStyle.fill);
        p.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length; i++) {
        final m = Offset.lerp(s[i - 1], s[i], 0.5)!;
        path.quadraticBezierTo(s[i - 1].dx, s[i - 1].dy, m.dx, m.dy);
      }
      path.lineTo(s.last.dx, s.last.dy);
      canvas.drawPath(path, p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ESigPainter old) => true;
}

/// แถบช่วงวัน + วงวันเริ่ม/สิ้นสุดบนตารางปฏิทิน 7 คอลัมน์ (แถวสูง 40)
/// s, e = ตำแหน่งในตาราง (ทศนิยม = ระหว่างเลื่อน) · นอกตาราง = ไม่วาดวง (แถบยังต่อถึงขอบ)
class _McRangePainter extends CustomPainter {
  const _McRangePainter(this.s, this.e, this.cells);

  final double s, e;
  final int cells;

  static const rowH = 40.0, band = 34.0;

  Offset _at(double idx, double cw) {
    // ระหว่างสองช่อง (ข้ามแถว) = เลื่อนตรงระหว่างจุดกลางสองช่อง
    final i0 = idx.floorToDouble(), t = idx - i0;
    Offset c(double i) =>
        Offset((i % 7) * cw + cw / 2, (i ~/ 7) * rowH + rowH / 2);
    return Offset.lerp(c(i0), c(i0 + 1), t)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / 7;
    final fill = Paint()..color = const Color(0xFFE2EAF8);
    final lo = math.max(s, 0.0), hi = math.min(e, cells - 1.0);
    if (e - s > 0.01 && hi >= lo) {
      final rows = (cells / 7).ceil();
      for (var r = 0; r < rows; r++) {
        final r0 = r * 7.0, r1 = r * 7.0 + 6.0;
        final a = math.max(lo, r0), b = math.min(hi, r1);
        if (a > b) continue;
        // ปลายช่วงเริ่มที่กลางวง · ต่อข้ามแถว = ชิดขอบตาราง
        final left = (a - r0) * cw + (a == s ? cw / 2 : 0.0);
        final right = (b - r0) * cw + (b == e ? cw / 2 : cw);
        final top = r * rowH + (rowH - band) / 2;
        final roundL = a == r0 && a != s, roundR = b == r1 && b != e;
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(left, top, right, top + band,
                topLeft: Radius.circular(roundL ? band / 2 : 0),
                bottomLeft: Radius.circular(roundL ? band / 2 : 0),
                topRight: Radius.circular(roundR ? band / 2 : 0),
                bottomRight: Radius.circular(roundR ? band / 2 : 0)),
            fill);
      }
    }
    final dot = Paint()..color = _blue;
    for (final i in [s, e]) {
      if (i < 0 || i > cells - 1) continue;
      canvas.drawCircle(_at(i, cw), band / 2, dot);
    }
  }

  @override
  bool shouldRepaint(_McRangePainter o) =>
      o.s != s || o.e != e || o.cells != cells;
}
