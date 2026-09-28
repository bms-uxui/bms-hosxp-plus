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
      thaiName || dxCode == null || dx.isEmpty ? dx : 'ICD-10 $dxCode · $dx';
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
        symptoms: symptoms.text.trim(),
        from: from,
        to: to,
        dx: dx.text.trim(),
        dxCode: dxCode,
        advice: advice.text.trim(),
        note: note.text.trim(),
        draft: true,
      );
}

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

  Widget _mcTabBody() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
                    begin: Offset(
                        child.key == const ValueKey('mc-form') ? 0.22 : -0.22,
                        0),
                    end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: _mcDraft?.hn != _caseP().hn
            ? KeyedSubtree(key: const ValueKey('mc-list'), child: _mcList())
            : KeyedSubtree(key: const ValueKey('mc-form'), child: _mcForm()),
      );

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
    } else {
      // ใบใหม่: อาการที่ตรวจพบ = CC ที่บันทึกไว้ในเคส (แก้ต่อได้)
      d.symptoms.text = erCaseOf(d.hn).cc.trim();
    }
    setState(() => _mcDraft = d);
  }

  /// แก้ไขใบที่ออกแล้ว: ได้เฉพาะแพทย์ที่ login ตอนออกใบนั้น · คนอื่น = แจ้งเตือน
  Future<void> _mcEdit(_MedCert c) async {
    final me = ErSession.instance.user?.name;
    final owner = c.issuedBy.isEmpty ? c.doctor : c.issuedBy;
    if (me == null || me != owner) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.lock_person_rounded, size: 32.0, color: _red),
          title: Text('ท่านไม่ใช่ผู้ออกใบรับรองแพทย์',
              textAlign: TextAlign.center,
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          content: Text(
              'ใบรับรองแพทย์ฉบับนี้แก้ไขได้เฉพาะแพทย์ผู้ออกใบรับรองเท่านั้น\n'
              'หากต้องการเปลี่ยนแปลง กรุณาติดต่อแพทย์ผู้ออกใบรับรอง',
              textAlign: TextAlign.center,
              style: _t(11.5, color: _ink2, height: 1.5)),
          actions: [
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _blue),
                onPressed: () => Navigator.pop(ctx),
                child: Text('รับทราบ', style: _t(11.0, color: Colors.white))),
          ],
        ),
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

  Widget _mcList() {
    final certs = [..._certsOf(_caseP().hn)]
      ..sort((a, b) => b.issued.compareTo(a.issued));
    return ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 16.0),
      children: [
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ใบรับรองแพทย์',
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                Text('ประวัติการออกใบรับรอง ${certs.length} ฉบับ',
                    style: _t(10.0, color: _ink3)),
              ],
            ),
          ),
          _apptPrimaryBtn(
              Icons.note_add_rounded, 'ออกใบรับรองแพทย์', () => _mcNew()),
        ]),
        const SizedBox(height: 12.0),
        if (certs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('ยังไม่เคยออกใบรับรองแพทย์ให้ผู้ป่วยรายนี้',
                  style: _t(11.0, color: _ink3)),
            ),
          ),
        for (final c in certs) _mcCard(c),
      ],
    );
  }

  Widget _mcCard(_MedCert c) {
    Widget cell(String k, String v) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
            const SizedBox(height: 2.0),
            Text(v,
                style: _t(11.0,
                    color: _inkTitle, height: 1.35, weight: FontWeight.w600)),
          ],
        );
    final owner = c.issuedBy.isEmpty ? c.doctor : c.issuedBy;
    final mine = ErSession.instance.user?.name == owner;
    // แตะการ์ด = แก้ไขใบนี้ (เช็คสิทธิ์ผู้ออกใน _mcEdit)
    return InkWell(
      onTap: () => _mcEdit(c),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.description_rounded,
                    size: 18.0, color: _blue),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.type,
                        style: _t(12.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('เลขที่ ${c.no}',
                        style:
                            _num(9.5, color: _ink3, weight: FontWeight.w600)),
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
                child: Text('พัก ${c.days} วัน',
                    style: _t(10.0, color: _blue, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: _line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cell('วันที่ออก', _apptDate(c.issued))),
                      Expanded(child: cell('แพทย์ผู้ตรวจ', c.doctor)),
                      Expanded(
                          child: cell('ช่วงวันพัก',
                              '${_apptDate(c.from)} – ${_apptDate(c.to)}')),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  cell('การวินิจฉัย', c.dxShown),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            Row(children: [
              _miniBtn(Icons.visibility_rounded, 'ดูเอกสาร', () => _mcView(c)),
              const SizedBox(width: 6.0),
              _miniBtn(
                  Icons.content_copy_rounded, 'ออกซ้ำ', () => _mcNew(from: c),
                  tooltip: 'ออกใบรับรองใหม่โดยใช้ข้อมูลจากฉบับนี้'),
              const SizedBox(width: 6.0),
              _miniBtn(mine ? Icons.edit_rounded : Icons.lock_outline_rounded,
                  'แก้ไข', () => _mcEdit(c),
                  tooltip: mine
                      ? 'แก้ไขใบรับรองนี้'
                      : 'แก้ไขได้เฉพาะผู้ออกใบรับรอง ($owner)'),
              const Spacer(),
              Text('ออกโดย $owner',
                  style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
            ]),
          ],
        ),
      ),
    );
  }

  /// ดูเอกสารเต็ม
  Future<void> _mcView(_MedCert c) => showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: _bg,
          insetPadding: const EdgeInsets.all(24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                  child: Text('${c.type} · ${c.no}',
                      style:
                          _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  tooltip: 'ปิด',
                  icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                      color: _ink2),
                ),
              ]),
              const SizedBox(height: 8.0),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520.0),
                  child: FittedBox(child: _mcPaper(c)),
                ),
              ),
            ]),
          ),
        ),
      );

  // ------------------------------------------------ ฟอร์มออกใบรับรอง

  Widget _mcForm() {
    final d = _mcDraft!;
    final p = _caseP();
    final c = erCaseOf(p.hn);
    final missing = d.missing;
    final preview = d.toCert(_mcPreviewNo());
    return LayoutBuilder(builder: (ctx, box) {
      final wide = box.maxWidth >= 760.0;
      final form = ListView(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
        children: [
          // จอแคบ: ตัวอย่างเอกสารเปิดเต็มจอจากปุ่มบนหัวฟอร์ม (ไม่ย่อจนอ่านไม่ออก)
          _mcHeader(p, c, preview: wide ? null : preview),
          const SizedBox(height: 10.0),
          _mcFormCard(d, c),
        ],
      );
      return Column(children: [
        Expanded(
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 11, child: form),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 12.0, 12.0),
                      child: _mcPreviewCard(preview),
                    ),
                  ),
                ])
              : form,
        ),
        // ปุ่มหลักขอบล่าง "บันทึก" · ยังไม่ครบ = กดไม่ได้ (กดค้างดูช่องที่ขาด)
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
          child: Center(
            child: Tooltip(
              message: missing.isEmpty
                  ? (d.editing == null ? 'ออกใบรับรองแพทย์' : 'บันทึกการแก้ไข')
                  : 'ยังขาด: ${missing.join(', ')}',
              child: _apptPrimaryBtn(Icons.check_rounded, 'บันทึก',
                  missing.isEmpty ? _mcIssue : null),
            ),
          ),
        ),
      ]);
    });
  }

  /// เลขที่ที่จะได้ (แสดงในตัวอย่าง ยังไม่นับจนกว่าจะออกจริง)
  String _mcPreviewNo() =>
      'MC${DateTime.now().year + 543}-${_mcSeq.toString().padLeft(4, '0')}';

  Widget _mcHeader(_P p, ErCase c, {_MedCert? preview}) => Row(children: [
        InkWell(
          onTap: () => setState(() => _mcDraft = null),
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
              Text(
                  _mcDraft?.editing == null
                      ? 'ออกใบรับรองแพทย์'
                      : 'แก้ไขใบรับรอง ${_mcDraft!.editing!.no}',
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
              Text('${p.name} · HN ${p.hn} · อายุ ${c.ageText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(10.0, color: _ink3)),
            ],
          ),
        ),
        if (preview != null) ...[
          _miniBtn(Icons.description_outlined, 'ตัวอย่างเอกสาร',
              () => _mcView(preview),
              tooltip: 'ดูตัวอย่างใบรับรองตามที่กรอกอยู่'),
          const SizedBox(width: 6.0),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text('แบบร่าง',
              style: _t(9.5, color: _blue, weight: FontWeight.w700)),
        ),
      ]);

  Widget _mcFormCard(_McDraft d, ErCase c) {
    Widget step(int n, String t) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(children: [
            Container(
              width: 22.0,
              height: 22.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text('$n',
                  style: _num(11.0, color: _blue, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 8.0),
            Text(t, style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
          ]),
        );
    Widget gap([double h = 10.0]) => SizedBox(height: h);
    Widget div() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Divider(height: 1.0, color: _line),
        );
    Widget two(Widget a, Widget b) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 10.0),
            Expanded(child: b),
          ],
        );
    final me = ErSession.instance.user;
    final doctors = [
      if (me?.role == ErRole.doctor) me!.name,
      for (final x in _apptDoctors())
        if (x != me?.name) x,
    ];
    // ชิปการวินิจฉัย: จากเวชระเบียนของเคส + ที่ลงไว้ในขั้น "วินิจฉัย/สั่ง"
    final dxChips = <(String, String?)>[
      for (final x in c.dx) (x.text, x.icd10),
      for (var st = 0; st < _forms.length; st++)
        for (final t in _multiItems(_filled[st][_dxTextLabel])) (t, null),
    ];
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // แถบพูด: บอกวิธีใช้ไมค์ในช่อง
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _blue.withValues(alpha: 0.18)),
            ),
            child: Row(children: [
              const Icon(Icons.mic_rounded, size: 18.0, color: _blue),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('พูดเพื่อกรอกข้อมูล',
                        style: _t(11.0, color: _blue, weight: FontWeight.w700)),
                    Text('แตะไมค์ในช่องที่ต้องการ แล้วพูดภาษาไทย',
                        style: _t(9.5, color: _ink3)),
                  ],
                ),
              ),
            ]),
          ),
          div(),
          step(1, 'ประเภทเอกสาร'),
          // แถวเดียว: รูปแบบใบรับรอง · แพทย์ผู้ตรวจ (วันที่ออก = วันที่บันทึก ไม่ต้องเลือก)
          two(
            _apptSelect(
                'รูปแบบใบรับรองแพทย์', d.type, _mcTypes, (v) => d.type = v,
                must: true),
            _apptSelect('แพทย์ผู้ตรวจ', d.doctor, doctors, (v) => d.doctor = v,
                must: true, hint: 'เลือกแพทย์'),
          ),
          gap(),
          Container(
            // ตัวเลือกรอง: ตัวอักษรขนาด label (9.5) · สวิตช์ย่อลง
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 2.0, 0.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(children: [
              Expanded(
                child: Text('ใช้ชื่อโรคภาษาไทยแทนรหัส ICD-10 บนใบรับรอง',
                    style: _t(9.5, color: _ink2, weight: FontWeight.w600)),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: d.thaiName,
                  activeTrackColor: _blue,
                  onChanged: (v) => setState(() => d.thaiName = v),
                ),
              ),
            ]),
          ),
          div(),
          step(2, 'ข้อมูลการตรวจและระยะพักรักษา'),
          _apptLabel('อาการที่ตรวจพบ', must: true),
          _mcText(d.symptoms, 'เช่น ไอ มีไข้ อ่อนเพลีย', 'อาการที่ตรวจพบ',
              lines: 2),
          // ชิป CC แสดงเฉพาะเมื่อข้อความในช่องยังไม่มี CC (ถูกลบ/แก้ไปแล้ว)
          if (c.cc.trim().isNotEmpty &&
              !d.symptoms.text.contains(c.cc.trim())) ...[
            gap(6.0),
            Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              _optChip('+ อาการสำคัญจากเวชระเบียน', false, false,
                  () => _mcAppend(d.symptoms, c.cc),
                  size: 10.0),
            ]),
          ],
          gap(),
          // ช่วงวันพัก: [เริ่ม] – [ถึง] · ชิปจำนวนวัน + ระบุเอง · สรุปจำนวนวันใต้ชิป
          _mcRestRow(d),
          div(),
          step(3, 'การวินิจฉัยและคำแนะนำ'),
          _apptLabel('การวินิจฉัย', must: true),
          _mcText(d.dx, 'เลือกจากรายการวินิจฉัยของผู้ป่วย หรือพิมพ์เอง',
              'การวินิจฉัย',
              onEdit: () => d.dxCode = null),
          if (dxChips.isNotEmpty) ...[
            gap(6.0),
            Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final (t, code) in dxChips)
                _optChip(code == null ? t : '$code · $t', d.dx.text == t, false,
                    () {
                  setState(() {
                    d.dx.text = t;
                    d.dxCode = code;
                  });
                }, size: 10.0),
            ]),
          ],
          gap(),
          _apptLabel('ความเห็นและข้อแนะนำของแพทย์'),
          _mcText(d.advice, 'เช่น ควรพักรักษาตัว และมาตรวจตามนัด',
              'ความเห็นและข้อแนะนำ',
              lines: 2),
          gap(6.0),
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            // เฉพาะข้อแนะนำสำหรับผู้ป่วย (ไม่ใช้ c.advice ซึ่งเป็นงานภายในของทีม ER)
            for (final a in _mcAdviceChips)
              _optChip('+ $a', d.advice.text.contains(a), false,
                  () => _mcAppend(d.advice, a),
                  size: 10.0),
          ]),
          gap(),
          _apptLabel('หมายเหตุเพิ่มเติม (ถ้ามี)'),
          _mcText(d.note, 'รายละเอียดที่ต้องการแสดงในใบรับรอง', 'หมายเหตุ'),
          div(),
          InkWell(
            onTap: () => setState(() => d.certify = !d.certify),
            borderRadius: BorderRadius.circular(8.0),
            child: Row(children: [
              Checkbox(
                value: d.certify,
                activeColor: _blue,
                onChanged: (v) => setState(() => d.certify = v ?? false),
              ),
              Expanded(
                child: Text(
                    'ขอรับรองว่าผู้ป่วยมารับการตรวจและรักษาที่โรงพยาบาลแห่งนี้จริง',
                    style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// แถวช่วงวันพัก (ตามแบบ): พักตั้งแต่วันที่ – ถึงวันที่ · ชิป 1/2/3/5/7 วัน + ระบุเอง
  Widget _mcRestRow(_McDraft d) {
    final bad = d.to.isBefore(d.from);
    final days = d.toCert('').days;
    const quick = [1, 2, 3, 5, 7];
    Future<DateTime?> pick(DateTime init, DateTime first) => showDatePicker(
          context: context,
          initialDate: init.isBefore(first) ? first : init,
          firstDate: first,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
    Future<void> pickFrom() async {
      final v = await pick(d.from, DateTime(d.from.year - 1));
      if (v == null || !mounted) return;
      setState(() {
        final len = d.to.difference(d.from);
        d.from = _dayOnly(v);
        d.to = d.from.add(len.isNegative ? Duration.zero : len);
      });
    }

    Future<void> pickTo() async {
      final v = await pick(d.to, d.from);
      if (v != null && mounted) setState(() => d.to = _dayOnly(v));
    }

    // ช่องวันที่: ไอคอนปฏิทินซ้าย · วันที่ · ✕ คืนค่าตั้งต้น
    Widget box(
            String label, DateTime v, VoidCallback onTap, VoidCallback onClear,
            {bool error = false}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(label, must: true),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                height: 44.0,
                padding: const EdgeInsets.only(left: 12.0),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: error ? _red : _line, width: error ? 1.5 : 1.0),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16.0, color: _ink2),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(_apptDate(v),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: onClear,
                    tooltip: 'คืนค่าตั้งต้น',
                    iconSize: 16.0,
                    constraints:
                        const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                    icon: const Icon(Icons.close_rounded, color: _ink3),
                  ),
                ]),
              ),
            ),
          ],
        );

    final dates = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: box('พักตั้งแต่วันที่', d.from, pickFrom, () {
          // ✕ วันเริ่ม = วันนี้ (คงจำนวนวันเดิม)
          setState(() {
            final len = d.to.difference(d.from);
            d.from = _dayOnly(DateTime.now());
            d.to = d.from.add(len.isNegative ? Duration.zero : len);
          });
        }),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
        child:
            Text('–', style: _t(14.0, color: _ink2, weight: FontWeight.w700)),
      ),
      Expanded(
        child: box(
            'ถึงวันที่',
            d.to,
            pickTo,
            // ✕ วันสิ้นสุด = วันเริ่ม (พัก 1 วัน)
            () => setState(() => d.to = d.from),
            error: bad),
      ),
    ]);

    final chips = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(spacing: 6.0, runSpacing: 6.0, children: [
          for (final n in quick)
            _optChip('$n วัน', !bad && days == n, false, () {
              setState(() => d.to = d.from.add(Duration(days: n - 1)));
            }, size: 10.5),
          _optChip('ระบุเอง', !bad && !quick.contains(days), false, pickTo,
              size: 10.5),
        ]),
        const SizedBox(height: 6.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: bad
                ? _red.withValues(alpha: 0.06)
                : _blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: bad ? 'วันสิ้นสุดก่อนวันเริ่ม' : '$days วัน ',
                style: _t(10.5,
                    color: bad ? _red : _blue, weight: FontWeight.w700)),
            if (!bad)
              TextSpan(
                  text: '(รวมวันเริ่มต้นและวันสิ้นสุด)',
                  style: _t(9.5, color: _ink3)),
          ])),
        ),
      ],
    );

    return LayoutBuilder(builder: (_, box) {
      // จอกว้าง: วันที่กับชิปอยู่แถวเดียว · แคบ: ชิปลงบรรทัดใหม่
      if (box.maxWidth < 600.0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [dates, const SizedBox(height: 10.0), chips],
        );
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(flex: 11, child: dates),
        const SizedBox(width: 14.0),
        Expanded(flex: 10, child: chips),
      ]);
    });
  }

  /// ต่อท้ายข้อความในช่อง (ไม่ซ้ำ)
  void _mcAppend(TextEditingController c, String t) {
    final cur = c.text.trim();
    if (cur.contains(t)) return;
    setState(() => c.text = cur.isEmpty ? t : '$cur $t');
  }

  /// ช่องข้อความ + ไมค์มุมขวา (แตะไมค์ = เปิดหน้าต่างพูดแล้วเริ่มฟังทันที)
  Widget _mcText(TextEditingController c, String hint, String title,
          {int lines = 1, VoidCallback? onEdit}) =>
      TextField(
        controller: c,
        minLines: lines,
        maxLines: lines == 1 ? 1 : 5,
        onChanged: (_) => setState(() => onEdit?.call()),
        style: _t(12.0, height: 1.45),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _t(12.0, color: _g5),
          filled: true,
          fillColor: _panelSoft,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(12.0, 12.0, 4.0, 12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: c.text.isEmpty ? _line : _blue.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: _blue.withValues(alpha: 0.7)),
          ),
          suffixIcon: IconButton(
            tooltip: 'พูดแล้วแปลงเป็นข้อความ',
            icon: const Icon(Icons.mic_none_rounded, size: 18.0, color: _blue),
            onPressed: () async {
              final v = await _voiceTextDialog(
                title: title,
                initial: c.text,
                hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
                okText: 'ใช้ข้อความนี้',
                multiline: lines > 1,
                autoMic: true,
              );
              if (v != null && mounted) {
                setState(() {
                  c.text = v.trim();
                  onEdit?.call();
                });
              }
            },
          ),
        ),
      );

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
    setState(() {
      if (at >= 0) {
        list[at] = cert;
      } else {
        list.add(cert);
      }
      _mcDraft = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'ดูเอกสาร',
            textColor: Colors.white,
            onPressed: () => _mcView(cert)),
        content: Text(
            at >= 0
                ? 'แก้ไขใบรับรองเลขที่ ${cert.no} แล้ว'
                : 'ออก${cert.type} เลขที่ ${cert.no} แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  // ------------------------------------------------ ตัวอย่างเอกสาร

  Widget _mcPreviewCard(_MedCert c) => Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: _line),
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
  Widget _mcPaper(_MedCert c) {
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
    return Container(
      width: 420.0,
      height: 594.0,
      padding: const EdgeInsets.fromLTRB(30.0, 26.0, 30.0, 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
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
            Center(
              child: Text(
                  c.type == _mcTypes.first ? 'Medical Certificate' : c.type,
                  style: _t(9.0, color: _ink3)),
            ),
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
            ]),
            para([k('อาการที่ตรวจพบ : '), v(c.symptoms)]),
            para([k('การวินิจฉัย : '), v(c.dxShown)]),
            para([k('ความเห็นของแพทย์ : '), v(c.advice)]),
            para([
              k('สมควรพักรักษาตัวเป็นเวลา '),
              v(bad ? '' : '${c.days}'),
              k(' วัน ตั้งแต่วันที่ '),
              v(_apptDate(c.from)),
              k(' ถึงวันที่ '),
              v(_apptDate(c.to)),
            ]),
            if (c.note.isNotEmpty) para([k('หมายเหตุ : '), v(c.note)]),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 190.0,
                child: Column(children: [
                  Text('ลงชื่อ …………………………………', style: _t(9.0, color: _ink2)),
                  const SizedBox(height: 4.0),
                  Text('( ${c.doctor.isEmpty ? dots : c.doctor} )',
                      textAlign: TextAlign.center,
                      style:
                          _t(9.0, color: _inkTitle, weight: FontWeight.w600)),
                  Text('แพทย์ผู้ตรวจ', style: _t(8.5, color: _ink3)),
                  Text('เลขที่ใบอนุญาตประกอบวิชาชีพ ว. …………',
                      style: _t(8.0, color: _ink3)),
                ]),
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
