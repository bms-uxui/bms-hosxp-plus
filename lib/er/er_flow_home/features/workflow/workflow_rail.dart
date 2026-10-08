// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// กดบันทึกสัญญาณชีพแล้วช่องบังคับยังว่าง: แสดงข้อความเตือนใต้ช่อง
bool _wfVsReqShow = false;

/// ซักประวัติแบบ stepper: หน้าที่เปิดอยู่ (0 อาการสำคัญ 1 สัญญาณชีพ 2 แพ้ยา บุหรี่ สุรา)
int _hxPage = 0;

/// ตัวเลื่อนรายการของฟอร์ม: ListView ใหม่ (เปลี่ยนหน้า) เริ่มที่ 0 เสมอ
final ScrollController _hxScroll = ScrollController(keepScrollOffset: false);

/// เคสที่บันทึกซักประวัติแล้ว (HN) ใช้สรุปช่องที่ขาดใน F9
final Set<String> _hxSaved = {};

/// ซักประวัติที่บันทึกแล้วของแต่ละเคส (HN → รายการ เรียงตามเวลา) บันทึกเพิ่มได้เรื่อย ๆ
/// แต่ละครั้งเก็บเป็น ชื่อช่อง → ค่า (แสดงในแท็บพยาบาลของหน้าคัดกรอง)
final Map<String, List<Map<String, String>>> _hxRecs = {};

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowWorkflowRailState on State<ErFlowHomeWidget> {
  /// แผง workflow ยังแสดงอยู่ (ระหว่างหุบกลับก็ยังต้องมีเนื้อหา)
  bool _wfShown = false;

  /// กางเสร็จแล้ว ใส่เนื้อหาจริงได้
  bool _wfReady = false;

  /// ความสูงของรางขั้นตอน (วัดจริง) ใช้เป็นจุดเริ่มตอนขยาย
  double _wfRailH = 470.0;

  /// ความสูงการ์ดฟอร์มเมื่อวางในแผง workflow ที่กาง (null = ความสูงปกติ)
  double? _flipFill;
}

extension _FeaturesWorkflowWorkflowRailPart on _ErFlowHomeWidgetState {
  Widget _clyRound(IconData icon, VoidCallback onTap) => _Press(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36.0,
            height: 36.0,
            foregroundDecoration: const _InnerGloss(18.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFEEF1F5)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _cyEdge),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10.0,
                    offset: Offset(0.0, 3.0)),
              ],
            ),
            child: Icon(icon, size: 18.0, color: _cySlate),
          ),
        ),
      );

  /// ความคืบหน้าของขั้น i: (กรอกแล้ว, ทั้งหมด) นับเฉพาะเคสที่กำลังพูดบันทึก
  (int, int) _clyStep(int i) {
    final ls = _stepLabels(i);
    if (_speechHn != _caseP().hn) return (0, ls.length);
    return (ls.where((l) => _fieldDone(i, l)).length, ls.length);
  }

  /// รางซ้าย = workflow: ไอคอนขั้น + วงความคืบหน้า · แตะเพื่อเปิดผู้ช่วยที่ขั้นนั้น
  Widget _clyRail() {
    final done = [
      for (final i in _stepOrder)
        if (_clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2) i
    ].length;
    // ขั้นปัจจุบัน = ขั้นแรก (ตามลำดับที่แสดง) ที่ยังไม่ครบ
    var cur = _stepOrder.last;
    for (final i in _stepOrder) {
      if (!(_clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2)) {
        cur = i;
        break;
      }
    }
    // ไม่มีขั้นที่เลือกไว้ก่อน: ไฮไลต์เฉพาะตอนกำลังเปิดขั้นนั้นอยู่
    cur = _speechOpen && _speechHn == _caseP().hn ? _speechStep : -1;
    // แถบขาวชิดขอบขวาจอ มุมโค้งเฉพาะด้านซ้าย · ขั้นที่เลือก = pill ฟ้าอ่อน
    // ขนาด/ระยะเท่ารางในแผงที่กางแล้ว (กว้าง 80 ขั้นแรกชิดบน) ไอคอนจึงไม่ขยับตอนกาง/หุบ
    return Container(
      width: 80.0,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 8.0),
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20.0)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final i in _stepOrder) ...[
            if (i != _firstStep) _railLine(_stepPos(i) <= done),
            _clyRailItem(i, cur),
            if (_tplOn && i == _speechStep) _tplSubmenu(),
            if (_steps[i].$2 == 'วินิจฉัย') ...[
              _railLine(_stepPos(i) < done),
              _accidentRailItem(),
            ],
          ],
        ]),
      ),
    );
  }

  /// ปุ่ม "อุบัติเหตุ": เปิดใน workflow panel (panel ยังไม่กาง = กางก่อน)
  /// บันทึกแล้ว = หน้าดูข้อมูล · ยังไม่บันทึก = ฟอร์ม
  /// เช็ก _accSaved ตอนกด (ไม่ใช่ค่าที่จับไว้ตอน build)
  void _openAccidentPane() {
    final p = _caseP();
    // ฟอร์มของเคสนี้เปิดอยู่ = ไม่สร้างใหม่ ค่าที่กำลังกรอกไม่หาย
    if (_accPaneClose != null && _speechOpen && _speechHn == p.hn) return;
    if (_accSaved(p.hn)) {
      _openAccidentSummaryPane();
    } else {
      _openAccidentEditPane();
    }
  }

  /// กาง workflow panel ของเคสปัจจุบัน + ทิ้ง pane อุบัติเหตุเดิม
  _P _accPaneReset() {
    final p = _caseP();
    if (!_speechOpen || _speechHn != p.hn) {
      _openSpeech(step: _speechHn == p.hn ? _speechStep : null);
    }
    _accPaneDrop();
    return p;
  }

  /// ฟอร์มอุบัติเหตุเดิม (เพิ่มใหม่ / แก้ไข) · โหลดร่างหรือค่าที่บันทึกไว้
  void _openAccidentEditPane() {
    final p = _accPaneReset();
    final (form, close) = _accidentForm(
      p,
      embedded: true,
      done: (save) {
        if (!mounted) return;
        // done ถูกเรียกก่อน _accFinish เก็บลง _accStore จึงห้ามอาศัย _accSaved
        // หลังบันทึก · บันทึก = ไปหน้าดูข้อมูล (อ่าน _accStore ตอน build ซึ่งเก็บแล้ว)
        // ปิดฟอร์ม: เคยบันทึกไว้ = กลับหน้าดูข้อมูล · ยังไม่เคย = ปิด pane
        final back = save || _accSaved(p.hn);
        setState(() {
          _accPaneClose = null;
          _accPane = back && _caseP().hn == p.hn ? _accSummaryPane(p) : null;
        });
      },
    );
    setState(() {
      _accPaneClose = close;
      _accPane = KeyedSubtree(
        // PageStorageKey: ไม่รับตำแหน่งเลื่อนค้างจากฟอร์มขั้นอื่น
        key: PageStorageKey('acc-${p.hn}'),
        child: form,
      );
    });
  }

  /// หน้าดูข้อมูลอุบัติเหตุที่บันทึกแล้ว (read-only)
  void _openAccidentSummaryPane() {
    final p = _accPaneReset();
    setState(() => _accPane = _accSummaryPane(p));
  }

  /// Builder: อ่าน _accStore ตอน build ทุกครั้ง แสดงค่าล่าสุดเสมอ
  Widget _accSummaryPane(_P p) => KeyedSubtree(
        key: PageStorageKey('acc-summary-${p.hn}'),
        child: Builder(builder: (_) => _accidentSavedPane(p)),
      );

  /// ทิ้ง Accident pane
  /// ถ้าเป็นฟอร์มที่ยังไม่บันทึก จะเก็บ draft ตามระบบเดิม
  void _accPaneDrop() {
    _accPaneClose?.call(false, false);
    _accPane = null;
    _accPaneClose = null;
  }

  /// หน้าแสดงข้อมูล Accident หลังบันทึก
  Widget _accidentSavedPane(_P p) {
    final data = _accStore[p.hn] ?? const <String, String>{};

    final narrative = (_accNarratives[p.hn] ?? '').trim();

    String valueOf(String label) => (data[label] ?? '').trim();

    // หมวดตาม schema ของฟอร์ม (_accGroups) ครบทุกหมวด · แสดงเฉพาะช่องที่มีค่า
    // วันที่/เวลาเกิดเหตุเป็นช่องแรกของหมวดแรก (เหตุการณ์) เหมือนในฟอร์ม
    final groups = [
      for (final (i, (title, icon, fields)) in _accGroups.indexed)
        (
          title,
          icon,
          [
            for (final label in [
              if (i == 0) _accWhen,
              for (final (f, _) in fields) f,
              if (title == 'การดูแลก่อนมาถึง') _accPreNote,
            ])
              if (valueOf(label).isNotEmpty) label,
          ],
        ),
    ];
    // แรก = เหตุการณ์ (การ์ดเต็มแถว) · สุดท้าย = หมายเหตุ (ข้อความยาว)
    // ระหว่างกลาง = ปัจจัยเสี่ยง / การดูแลก่อนมาถึง (การ์ดคู่)
    final event = groups.first;
    final notes = groups.last;
    // ช่องเสริม: ข้อมูลการมา (การ์ดคู่) · Trauma (เต็มแถว ต่อจากเหตุการณ์)
    final arrival = (
      _accArrivalTitle,
      Icons.airport_shuttle_rounded,
      [
        for (final (l, _) in _accArrival)
          if (valueOf(l).isNotEmpty) l,
      ],
    );
    final trauma = (
      _accTraumaTitle,
      Icons.monitor_heart_rounded,
      [
        for (final l in _accRegions)
          if (valueOf(l).isNotEmpty) l,
      ],
    );
    // คะแนนแสดงเป็นแถบตัวเลขบนการ์ด Trauma (ไม่ปนกับตาราง AIS)
    // คะแนนหลักขึ้นก่อน (RTS · ISS · PS) ตามด้วยค่าที่ใช้คำนวณ
    final scores = [
      for (final s in ['RTS', 'ISS', 'PS', 'GCS.v', 'BPs', 'RR'])
        if (valueOf(s).isNotEmpty) s,
    ];
    // การ์ดคู่ (ข้อมูลสั้น): ข้อมูลการมา · ปัจจัยเสี่ยง · การดูแลก่อนมาถึง
    // ลำดับเดียวกับฟอร์ม: การมา → เหตุการณ์ → Trauma → (ปัจจัยเสี่ยง | ก่อนมาถึง)
    // → หมายเหตุ / บันทึกข้อมูลอิสระ
    final pairs = [
      for (final g in groups.sublist(1, groups.length - 1))
        if (g.$3.isNotEmpty) g,
    ];

    // จำนวนคอลัมน์ตามความกว้างในการ์ด: กว้าง 3 · ปกติ 2 · แคบมาก 1
    int colsFor(double inner) => inner >= 520 ? 3 : (inner >= 230 ? 2 : 1);

    // ช่องหนึ่งช่อง: ชื่อช่องอยู่บนค่า
    Widget cell(String label) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _t(10, color: _ink3, weight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                valueOf(label),
                style: _t(
                  11.5,
                  color: _inkTitle,
                  weight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );

    // ช่องเรียงเป็นตาราง cols คอลัมน์ตามลำดับ schema · คั่นแถวด้วยเส้นบาง
    Widget grid(List<String> labels, int cols) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < labels.length; r += cols) ...[
              if (r > 0) const Divider(height: 1, color: _line),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = r; c < r + cols; c++) ...[
                    if (c > r) const SizedBox(width: 14),
                    Expanded(
                      child: c < labels.length
                          ? cell(labels[c])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );

    // การ์ดหนึ่งหมวด (สไตล์การ์ดเดิม): หัว = ไอคอน + ชื่อหมวด + จำนวนช่อง
    // การ์ดแคบ: ป้ายจำนวนเหลือแค่ตัวเลข ชื่อหมวดจะได้ไม่ตกบรรทัด
    Widget card(
      String title,
      IconData icon,
      Widget body, {
      int? count,
      bool narrow = false,
    }) =>
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 15, color: _blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: _t(12, color: _blue, weight: FontWeight.w700),
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        narrow ? '$count' : '$count รายการ',
                        style: _t(9, color: _ink3, weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              body,
            ],
          ),
        );

    // การ์ดหมวดแบบตาราง · width = ความกว้างการ์ด ใช้เลือกจำนวนคอลัมน์
    Widget groupCard((String, IconData, List<String>) g, double width) => card(
          g.$1,
          g.$2,
          // ไม่แบ่งคอลัมน์เกินจำนวนช่องที่มีค่า (ช่องเดียว = เต็มความกว้างการ์ด)
          grid(g.$3, math.min(colsFor(width - 28), g.$3.length)),
          count: g.$3.length,
          narrow: width - 28 < 220,
        );

    // Trauma: แถบคะแนน (GCS · BPs · RR · RTS · ISS · PS) + ตาราง AIS ตามตำแหน่ง
    // ISS / RTS = ค่าที่คำนวณ เน้นสีให้เห็นก่อน
    Widget traumaCard(double width) {
      // 28 = padding ซ้ายขวา · +2 = เส้นขอบ 1px ของ _clyCardDeco
      final inner = width - 30;
      final perRow = inner >= 520 ? 6 : 3;
      const gap = 6.0;
      final tileW = ((inner - gap * (perRow - 1)) / perRow).floorToDouble();
      Widget tile(String s) {
        // คะแนนหลัก (RTS / ISS / PS) เน้นสีและตัวใหญ่กว่า ค่าตั้งต้น (GCS/BPs/RR) รองลงมา
        final key = s == 'ISS' || s == 'RTS' || s == 'PS';
        return Container(
          width: tileW,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: key ? _blue.withValues(alpha: 0.07) : _panelSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s,
                style: _t(
                  9,
                  color: key ? _blue : _ink3,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                valueOf(s),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _num(
                  key ? 17 : 14,
                  color: key ? _blue : _inkTitle,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }

      return card(
        trauma.$1,
        trauma.$2,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (scores.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [for (final s in scores) tile(s)],
                ),
              ),
            if (trauma.$3.isNotEmpty)
              grid(trauma.$3, math.min(colsFor(inner), trauma.$3.length)),
          ],
        ),
        count: trauma.$3.length + scores.length,
        narrow: inner < 220,
      );
    }

    // หมายเหตุ: ข้อความยาวเต็มแถว (ช่องชื่อเดียวกับหมวด ไม่ต้องซ้ำชื่อช่อง)
    Widget notesCard() => card(
          notes.$1,
          notes.$2,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final label in notes.$3) ...[
                if (label != notes.$1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
                      style: _t(10, color: _ink3, weight: FontWeight.w600),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 8),
                  child: Text(
                    valueOf(label),
                    style: _t(
                      11.5,
                      color: _inkTitle,
                      weight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );

    // สรุปเหตุการณ์: ประกอบจากค่าที่บันทึกจริงเท่านั้น (ไม่ใช้ AI ไม่เติมคำเดา)
    // บรรทัดละหัวข้อ · หัวข้อที่ไม่มีค่าเลยไม่แสดง
    String join(List<String> labels, {String sep = ' · '}) => [
          for (final l in labels)
            if (valueOf(l).isNotEmpty) valueOf(l),
        ].join(sep);
    String risk() => [
          for (final l in [
            'แอลกอฮอล์',
            'สารเสพติด',
            'หมวกนิรภัย',
            'เข็มขัดนิรภัย'
          ])
            if (valueOf(l).isNotEmpty) '$l ${valueOf(l)}',
        ].join(' · ');
    final digest = [
      ('เหตุการณ์', join(['ประเภทอุบัติเหตุ', 'ยานพาหนะ', _accWhen])),
      ('สถานที่', join(['สถานที่เกิดเหตุ', 'จุดเกิดเหตุ'], sep: ' — ')),
      (
        'ผู้บาดเจ็บ',
        [
          join(['ประเภทผู้บาดเจ็บ']),
          risk()
        ].where((s) => s.isNotEmpty).join(' · ')
      ),
      ('การมา', join([for (final (l, _) in _accArrival) l])),
    ].where((line) => line.$2.isNotEmpty).toList();

    Widget digestBox() => Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.summarize_rounded, size: 15, color: _blue),
                  const SizedBox(width: 6),
                  Text(
                    'สรุปเหตุการณ์',
                    style: _t(11, color: _blue, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (final (label, text) in digest)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$label  ',
                          style:
                              _t(10.5, color: _ink3, weight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: text,
                          style: _t(11.5, color: _inkTitle, height: 1.4),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        );

    // บันทึกข้อมูลอิสระ: ข้อความต้นฉบับที่ผู้ใช้บันทึกไว้ (กระชับ แต่ยังอ่านง่าย)
    Widget freeNote() => Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, size: 16, color: _blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'บันทึกข้อมูลอิสระ',
                      style: _t(11, color: _blue, weight: FontWeight.w700),
                    ),
                  ),
                  Text('ข้อมูลต้นฉบับ', style: _t(9, color: _ink3)),
                ],
              ),
              const SizedBox(height: 5),
              Text(narrative, style: _t(11, color: _ink2, height: 1.45)),
            ],
          ),
        );

    // -----------------------------------------------
    // PAGE
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =============================================
        // HEADER
        // =============================================
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 12),
          decoration: const BoxDecoration(
            color: _panel,
            border: Border(bottom: BorderSide(color: _line)),
          ),
          child: LayoutBuilder(
            builder: (context, header) {
              final compact = header.maxWidth < 420;
              return Row(
                children: [
                  // icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: _glossGrad(_green),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: _glossLift(_green),
                    ),
                    foregroundDecoration: const _InnerGloss(11, dark: true),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.car_crash_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wrap: panel แคบ badge ขึ้นบรรทัดใหม่ ไม่ล้น
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'ข้อมูลอุบัติเหตุ',
                              style: _t(
                                15,
                                color: _inkTitle,
                                weight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: _green,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'บันทึกแล้ว',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(
                                        9.5,
                                        color: _green,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${p.name} · HN ${p.hn}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(10, color: _ink3),
                        ),
                      ],
                    ),
                  ),

                  // Edit · panel แคบ = เหลือแค่ไอคอน (ชื่อปุ่มอยู่ใน tooltip)
                  Tooltip(
                    message: 'แก้ไขข้อมูล',
                    child: _Press(
                      child: Material(
                        color: _panel,
                        shape: const StadiumBorder(
                          side: BorderSide(color: _line),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: _openAccidentEditPane,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 9 : 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_rounded,
                                  size: 15,
                                  color: _blue,
                                ),
                                if (!compact) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    'แก้ไขข้อมูล',
                                    style: _t(
                                      11,
                                      color: _blue,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 3),

                  // ปุ่มหุบอยู่ล่างสุดของรายการขั้นแล้ว (ไม่ซ้ำที่หัวแผง)
                ],
              );
            },
          ),
        ),

        // =============================================
        // CONTENT
        // =============================================
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
            child: LayoutBuilder(
              builder: (context, bounds) {
                final w = bounds.maxWidth;
                const gap = 10.0;
                // การ์ดคู่วางข้างกันเมื่อกว้างพอ · แคบ = ต่อลงมาเต็มแถว
                final twoUp = w >= 420;
                final half = (w - gap) / 2;
                final cards = <Widget>[
                  if (digest.isNotEmpty) digestBox(),
                  if (arrival.$3.isNotEmpty) groupCard(arrival, w),
                  if (event.$3.isNotEmpty) groupCard(event, w),
                  if (trauma.$3.isNotEmpty || scores.isNotEmpty) traumaCard(w),
                  for (var i = 0; i < pairs.length; i += 2)
                    if (twoUp && i + 1 < pairs.length)
                      // การ์ดคู่สูงเท่ากัน
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: groupCard(pairs[i], half)),
                            const SizedBox(width: gap),
                            Expanded(child: groupCard(pairs[i + 1], half)),
                          ],
                        ),
                      )
                    else ...[
                      groupCard(pairs[i], w),
                      if (i + 1 < pairs.length) groupCard(pairs[i + 1], w),
                    ],
                  if (notes.$3.isNotEmpty) notesCard(),
                  if (narrative.isNotEmpty) freeNote(),
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(height: gap),
                      cards[i],
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Additional patient action; does not change the required workflow count.
  /// จำนวนขั้นที่ทำครบ (ใช้ระบายเส้น timeline ในราง)
  int get _railDoneN => [
        for (final i in _stepOrder)
          if (_clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2) i
      ].length;

  /// ช่องว่างระหว่างขั้นในราง (แบบรางแท็บซ้าย ไม่มีเส้น timeline)
  Widget _railLine(bool passed) => const SizedBox(height: 4.0);

  /// ช่องขั้นในราง แบบรางแท็บซ้าย: ไอคอน + ชื่อ · ที่เลือก = pill ฟ้าอ่อน
  /// ครบ = เช็กเขียว · กรอกบางส่วน = วงความคืบหน้าบางรอบไอคอน
  Widget _railCell({
    required IconData icon,
    required String label,
    required bool on,
    bool complete = false,
    double? progress,
    bool joined = false,
    bool first = false,
  }) {
    final ink = complete ? _green : (on ? _blue : _ink3);
    // ที่เลือก = แผ่นขาวบนพื้นเทา แบบรางแท็บซ้าย
    // joined (แผงกาง): ชิดซ้ายต่อกับแผงเนื้อหา มุมเว้าบน/ล่าง
    final cell = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      // กว้างเต็มรางทั้งตอนหุบ/กาง: ชื่อขั้นตัดบรรทัดเหมือนกัน ช่องสูงเท่ากัน ไม่เลื่อน
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        // ต่อกับแผง = ขาว · บนแถบขาว (หุบ) = ฟ้าอ่อนให้เห็นว่าเลือก
        color: on
            ? (joined ? _panel : const Color(0xFFE8F0FE))
            : _panel.withValues(alpha: 0.0),
        borderRadius: joined
            ? const BorderRadius.horizontal(right: Radius.circular(16.0))
            : BorderRadius.circular(16.0),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 34.0,
          height: 34.0,
          child: Stack(alignment: Alignment.center, children: [
            if (progress != null && !complete)
              TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: v,
                    strokeWidth: 2.0,
                    strokeCap: StrokeCap.round,
                    backgroundColor: v > 0 ? _line : Colors.transparent,
                    color: _blue,
                  ),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(complete ? Icons.check_circle_rounded : icon,
                  key: ValueKey(complete), size: 22.0, color: ink),
            ),
          ]),
        ),
        const SizedBox(height: 4.0),
        Text(label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: _t(10.0,
                color: on ? _inkTitle : _ink3,
                weight: on ? FontWeight.w700 : FontWeight.w500,
                height: 1.15)),
      ]),
    );
    if (!joined || !on) return cell;
    // มุมเว้าตรงรอยต่อกับแผง (ขาวเติมมุม เทาเจาะโค้ง) กลับด้านจากรางซ้าย
    Widget fillet({required bool top}) => SizedBox(
          width: 16.0,
          height: 16.0,
          child: ColoredBox(
            color: _panel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: top
                    ? const BorderRadius.only(bottomLeft: Radius.circular(16.0))
                    : const BorderRadius.only(topLeft: Radius.circular(16.0)),
              ),
            ),
          ),
        );
    // มุมเว้าทาสีพื้นเทา: ระหว่างกาง/หุบ ด้านหลังยังเป็นรางขาว จะเห็นเป็นเสี้ยววงเทาโผล่
    // จึงแสดงเฉพาะตอนกางเต็ม (รางขาวถูกถอดแล้ว) ซ่อนทันทีที่เริ่มหุบ
    // ไม่จางช่วงท้าย: ปลาย easeInOutCubic ยาว เสี้ยวจางยังเห็นบนพื้นขาว
    // Builder: context ต้องอยู่ใต้ _WfProgress (context ของ State อยู่นอกแผง)
    return Builder(builder: (context) {
      final o = _WfProgress.of(context) >= 1.0 ? 1.0 : 0.0;
      Widget corner(Widget c) => Opacity(opacity: o, child: c);
      return Stack(clipBehavior: Clip.none, children: [
        cell,
        // ขั้นแรกชิดขอบบน ไม่มีมุมเว้าด้านบน
        if (!first && o > 0.0)
          Positioned(left: 0.0, top: -16.0, child: corner(fillet(top: true))),
        if (o > 0.0)
          Positioned(
              left: 0.0, bottom: -16.0, child: corner(fillet(top: false))),
      ]);
    });
  }

  Widget _accidentRailItem({bool joined = false}) {
    final patient = _caseP();
    final saved = _accSaved(patient.hn);
    final on = _speechOpen && _accPane != null;
    return Semantics(
      button: true,
      label: 'อุบัติเหตุ${saved ? ' บันทึกแล้ว' : ''}',
      child: Tooltip(
        message: saved ? 'ดูข้อมูลอุบัติเหตุ' : 'บันทึกข้อมูลอุบัติเหตุ',
        child: _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAccidentPane,
            child: _railCell(
              icon: Icons.car_crash_outlined,
              label: 'อุบัติเหตุ',
              on: on,
              complete: saved && !on,
              joined: joined,
            ),
          ),
        ),
      ),
    );
  }

  Widget _clyRailItem(int i, int cur, {bool joined = false}) {
    final (ok, n) = _clyStep(i);
    final complete = n > 0 && ok == n;
    // เปิดแผงอุบัติเหตุอยู่ = ขั้นอื่นไม่ถูกเลือก (เลือกได้ทีละช่อง)
    final on = i == cur && _accPane == null;
    final active = _speechOpen && _speechStep == i && _accPane == null;
    final label = _steps[i].$2;
    return _Press(
      child: GestureDetector(
        // กดได้ทั้งช่อง (วง + ป้ายชื่อ) ไม่ต้องเล็งให้โดนวง
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // ไปขั้นอื่น = ออกจาก template (sub menu ผูกกับขั้น Order Set)
          if (i != _speechStep) _tplOpen = null;
          _accPaneDrop();
          _openSpeech(step: i);
        },
        child: _railCell(
          icon: _steps[i].$1,
          label: label,
          on: on || active,
          complete: complete,
          progress: n == 0 ? null : ok / n,
          joined: joined,
          first: i == _firstStep,
        ),
      ),
    );
  }

  /// workflow ที่กางออกทับหุ่น: รายการขั้นซ้าย + ผู้ช่วยของขั้นที่เลือก
  Widget _clyWorkflowOpen() {
    // แบบรางแท็บซ้าย (กลับด้าน): พื้นเทา · เนื้อหาเป็นแผ่นขาวมุม 20
    // รางขั้นตอนขวาบนพื้นเทา ขั้นที่เลือกเป็นแผ่นขาวต่อกับแผงเนื้อหา
    // ไม่มีพื้นราง (ลอยบนพื้นหน้า) · แผงเนื้อหาขาว
    return Container(
      clipBehavior: Clip.none,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // รายการขั้นอยู่ขวา (แผงชิดขวาจอ) · เนื้อหาซ้าย
        // ระหว่างกางออกเป็นแผงว่าง เนื้อหาจริง (ฟอร์ม) ค่อยจางเข้าตอนกางเสร็จ
        // สร้างฟอร์มทั้งก้อนในเฟรมแรกทำจอค้าง animation เลยกระตุก
        // ไม่ใช้ skeleton: skeleton ใช้เฉพาะข้อมูลที่รอโหลดจาก server
        Expanded(
          child: Container(
            // ขั้นแรกเลือกอยู่ = มุมบนขวาเหลี่ยม ต่อกับแท็บขั้นเป็นแผ่นเดียว
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(20.0).copyWith(
                  topRight: _speechStep == _firstStep && _accPane == null
                      ? Radius.zero
                      : const Radius.circular(20.0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: !_wfReady
                  ? const SizedBox.expand(key: ValueKey('wf-empty'))
                  : _accPane != null
                      ? KeyedSubtree(
                          key: const ValueKey('wf-acc'), child: _accPane!)
                      : KeyedSubtree(
                          key: const ValueKey('wf-body'),
                          child: _tplOn ? _tplBody() : _clyGuideBody()),
            ),
          ),
        ),
        Container(
          width: 80.0,
          // ขั้นแรกชิดขอบบนแผง (ต่อกันเป็นแผ่นเดียวแบบรางแท็บซ้าย)
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 8.0),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  for (final i in _stepOrder) ...[
                    if (i != _firstStep) _railLine(_stepPos(i) <= _railDoneN),
                    _clyRailItem(i, _speechStep, joined: true),
                    // เปิด template อยู่: หัวข้อ progress note เป็น sub menu ใต้ขั้นนี้
                    if (_tplOn && i == _speechStep) _tplSubmenu(),
                    if (_steps[i].$2 == 'วินิจฉัย') ...[
                      _railLine(_stepPos(i) < _railDoneN),
                      _accidentRailItem(joined: true),
                    ],
                  ],
                ]),
              ),
            ),
            // ปุ่มหุบแผง: ล่างสุดของรายการขั้น นิ้วเอื้อมถึงง่าย
            const SizedBox(height: 8.0),
            _wfToggleBtn(open: true),
          ]),
        ),
      ]),
    );
  }

  /// ปุ่มหุบ/กางแผง workflow ล่างสุดของรางขั้นตอน
  /// แผงกางอยู่ = หุบ (») · หุบอยู่ = กางขั้นปัจจุบัน («)
  Widget _wfToggleBtn({required bool open}) => Tooltip(
        message: open ? 'หุบแผง' : 'กางแผง',
        child: _Press(
          child: GestureDetector(
            onTap: open ? _closeSpeech : () => _openSpeech(step: _speechStep),
            child: Container(
              width: 44.0,
              height: 36.0,
              decoration: BoxDecoration(
                gradient: _glossWhite,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: _line),
                boxShadow: _glossLift(const Color(0xFF0B1B3F)),
              ),
              foregroundDecoration: const _InnerGloss(100.0),
              child: Icon(
                  open
                      ? Icons.keyboard_double_arrow_right_rounded
                      : Icons.keyboard_double_arrow_left_rounded,
                  size: 20.0,
                  color: _blue),
            ),
          ),
        ),
      );

  /// เนื้อหาผู้ช่วยของขั้นที่เลือก (เดิมอยู่แถบล่าง) วางในแผง workflow ที่กางออก

  static const String _wfVsReqLabel = 'การแพ้ยา / การสูบบุหรี่ / การดื่มสุรา';

  /// ปุ่มปฏิเสธทั้งหมด (ขวามือหัวการ์ด): เลือกตัวแรกของแต่ละกลุ่ม = ไม่แพ้ยา ไม่สูบ ไม่ดื่ม
  Widget _wfNoneAll(Map<String, String> hx) {
    final gs = _localGroups[_wfVsReqLabel]!;
    final none = [for (final g in gs) g.$2.first].join(' · ');
    final on = hx[_wfVsReqLabel] == none;
    void toggle() {
      HapticFeedback.selectionClick();
      setState(() => on ? hx.remove(_wfVsReqLabel) : hx[_wfVsReqLabel] = none);
    }

    // ปุ่ม tonal แบบเดียวกับปุ่มหัวการ์ดขั้นอื่น (ดูการส่งตรวจ สแกนจอ พูด)
    return _triIconBtn(
        on ? Icons.undo_rounded : Icons.do_not_disturb_on_outlined,
        on ? 'ยกเลิกปฏิเสธ' : 'ปฏิเสธทั้งหมด',
        toggle);
  }

  /// ชื่อหัวข้อที่แสดงเป็นคำนาม (คีย์ข้อมูลเดิมไม่เปลี่ยน)
  String _wfNoun(String name) => switch (name) {
        'ตั้งครรภ์' => 'การตั้งครรภ์',
        'ให้นมบุตร' => 'การให้นมบุตร',
        'G6PD' => 'ภาวะพร่อง G6PD',
        'FP' => 'การวางแผนมีครอบครัว',
        _ => name,
      };

  /// แถวตั้งค่าแบบ Google: ไอคอนนำ ชื่อหัวข้อ (+ * บังคับ) ค่าที่เลือกเป็นบรรทัดรอง
  /// ยังไม่เลือก = "ยังไม่เลือก" (กดบันทึกแล้วยังว่าง = แดง)
  Widget _wfSettingRow(String name, String? value,
      {required VoidCallback onTap, bool req = false, bool missing = false}) {
    final label = _wfNoun(name);
    final icon = switch (name) {
      'การแพ้ยา' => Icons.medication_outlined,
      'การสูบบุหรี่' => Icons.smoking_rooms_outlined,
      'การดื่มสุรา' => Icons.wine_bar_outlined,
      'ตั้งครรภ์' => Icons.pregnant_woman_outlined,
      'ให้นมบุตร' => Icons.child_care_outlined,
      'FP' => Icons.family_restroom_outlined,
      _ => Icons.bloodtype_outlined,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(children: [
          // ไอคอนในวงกลมแบบแถว V/S: เลือกแล้ว = เขียวอ่อน · ยังว่าง = ฟ้าอ่อน (บังคับแต่ว่าง = แดงอ่อน)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: missing
                  ? _red.withValues(alpha: 0.12)
                  : value != null
                      ? _green.withValues(alpha: 0.12)
                      : _blue.withValues(alpha: 0.08),
            ),
            child: Icon(icon,
                size: 20.0,
                color: missing
                    ? _red
                    : value != null
                        ? _green
                        : _blue),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: label,
                    style: _t(14.5, color: _inkTitle, weight: FontWeight.w500)),
                if (req) TextSpan(text: ' *', style: _t(14.5, color: _red)),
              ])),
              const SizedBox(height: 2.0),
              Text(value ?? 'ยังไม่เลือก',
                  style: _t(13.0,
                      color: value != null
                          ? _blue
                          : missing
                              ? _red
                              : _ink3,
                      weight: FontWeight.w500)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 22.0, color: _ink3),
        ]),
      ),
    );
  }

  /// เลือกข้อความจากวงล้อ: sheet ลอยแบบเดียวกับตอนเลือกค่า V/S
  /// (การ์ดขาวมุม 20 เว้นขอบ · แถบเลือกกลาง · ปุ่ม ยกเลิก / เลือก มุม 12)
  void _wheelPick(
      String title, List<String> opts, String? cur, ValueChanged<String> on) {
    HapticFeedback.selectionClick();
    var at = cur == null ? 0 : opts.indexOf(cur).clamp(0, opts.length - 1);
    _placedSheet<void>(
      context: context,
      // การ์ดลอย + ghost ย้ายตำแหน่ง มาจาก _placedSheet
      constraints: const BoxConstraints(maxWidth: 520.0),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 220.0,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(initialItem: at),
                    itemExtent: 44.0,
                    diameterRatio: 1.8,
                    perspective: 0.004,
                    useMagnifier: true,
                    magnification: 1.18,
                    overAndUnderCenterOpacity: 0.35,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) {
                      HapticFeedback.selectionClick();
                      at = i;
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: opts.length,
                      builder: (_, i) => Center(
                        child: Text(opts[i],
                            style: _t(17.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12.0),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDADCE0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('ยกเลิก',
                          style:
                              _t(14.0, color: _ink2, weight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48.0,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        on(opts[at]);
                      },
                      child: Text('เลือก',
                          style: _t(15.0,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// ช่องที่ HOSxP ถามคู่กับสัญญาณชีพ: รอบเอว เส้นรอบศีรษะ ตั้งครรภ์/ให้นมบุตร/G6PD
  /// FP และแพ้ยา/สูบบุหรี่/ดื่มสุรา · เก็บลงฟอร์มขั้นซักประวัติ (ค่าเดียวกันทั้งสองที่)
  Widget _wfVsMoreCard() {
    final hx = _filled[7];
    final female = erCaseOf(_caseP().hn).sex.startsWith('ห');
    // รอบเอว เส้นรอบศีรษะ อยู่ในการ์ด V/S (วงล้อ) แล้ว: คัดค่าลงฟอร์มซักประวัติ
    for (final (k, label) in const [
      ('waist', 'รอบเอว'),
      ('head', 'เส้นรอบศีรษะ'),
    ]) {
      final v = _triCtl(k).text.trim();
      if (v.isEmpty) {
        hx.remove(label);
      } else {
        hx[label] = v;
      }
    }

    // หลายช่องย่อยเก็บเป็น "a · b · c" ตามลำดับกลุ่ม (กลุ่มที่ยังไม่เลือก = "-")
    List<Widget> groups(String label,
        {Set<String> skip = const {}, bool req = false}) {
      final gs = _localGroups[label]!;
      final cur = (hx[label] ?? '').split(' · ');
      String? at(int i) =>
          cur.length == gs.length && cur[i] != '-' ? cur[i] : null;
      // แถวแบบหน้าตั้งค่า Google: ไอคอน + ชื่อ + ค่าที่เลือก · แตะเลือกจาก sheet
      return [
        for (final (i, (name, opts)) in gs.indexed)
          if (!skip.contains(name)) ...[
            // คั่นแถวด้วยเส้นบาง ยกเว้นแถวแรกของการ์ด
            if (!(req && i == 0))
              const Divider(
                  height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
            _wfSettingRow(
              name,
              at(i),
              req: req,
              missing: req && _wfVsReqShow && at(i) == null,
              onTap: () => _wheelPick(_wfNoun(name), opts, at(i), (o) {
                final next = [for (var j = 0; j < gs.length; j++) at(j) ?? '-'];
                next[i] = o;
                setState(() => hx[label] = next.join(' · '));
              }),
            ),
          ],
      ];
    }

    return _qCard(
      'แพ้ยา สูบบุหรี่ ดื่มสุรา',
      count: 'ต้องเลือกให้ครบก่อนบันทึก',
      action: _wfNoneAll(hx),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // หลักของขั้นนี้ขึ้นก่อน: แพ้ยา บุหรี่ สุรา
        ...groups(_wfVsReqLabel, req: true),
        // ข้อมูลตามแบบ HOSxP อยู่ท้าย (บันทึกคู่กับสัญญาณชีพ) ระยะเท่าแถวอื่น
        ...groups('ตั้งครรภ์ / ให้นมบุตร / G6PD',
            skip: female ? const {} : const {'ตั้งครรภ์', 'ให้นมบุตร'}),
        // FP: แถวตั้งค่าแบบเดียวกับหัวข้ออื่น แตะแล้วเลือกจากวงล้อ
        if (female) ...[
          const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
          _wfSettingRow(
            'FP',
            hx['FP'],
            onTap: () => _wheelPick(_wfNoun('FP'), _localGroups['FP']!.first.$2,
                hx['FP'], (o) => setState(() => hx['FP'] = o)),
          ),
        ],
      ]),
    );
  }

  /// ขั้นสัญญาณชีพของพยาบาล: ใช้การ์ด V/S ชุดเดียวกับหน้าคัดกรอง (วงล้อเลือกค่า
  /// แดงเมื่อผิดปกติ) แทนช่องกรอกทีละค่า · บันทึก = เพิ่มเป็นรอบวัดใหม่ของเคส
  /// ข้อความสรุปซักประวัติหนึ่งครั้งในไทม์ไลน์กิจกรรมพยาบาล
  String _hxNoteText(int i, Map<String, String> r) {
    String? g(String k) => r[k];
    final vs = [
      if (g('ความดันโลหิต (mmHg)') case final v?) 'BP $v',
      if (g('อัตราการเต้นหัวใจ (bpm)') case final v?) 'HR $v',
      if (g('อัตราการหายใจ (/min)') case final v?) 'RR $v',
      if (g('ออกซิเจนในเลือด (%)') case final v?) 'SpO₂ $v%',
      if (g('อุณหภูมิ (°C)') case final v?) 'T $v',
    ].join('  ');
    return [
      'ซักประวัติ ครั้งที่ ${i + 1}',
      if (g('อาการสำคัญ') case final v?) 'อาการสำคัญ $v',
      if (vs.isNotEmpty) vs,
      [g('การแพ้ยา'), g('การสูบบุหรี่'), g('การดื่มสุรา')]
          .whereType<String>()
          .join(' '),
    ].where((e) => e.isNotEmpty).join('\n');
  }

  /// ค่าซักประวัติตอนกดบันทึก (ก่อนล้างค่า V/S สำหรับรอบถัดไป)
  Map<String, String> _hxSnapshot() {
    String? f(String k) {
      final v = _triVal(k);
      if (v == null) return null;
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }

    final now = DateTime.now();
    final hx = _filled[7];
    final cc = [..._qCc, _regCtl('cc').text.trim()]
        .where((e) => e.isNotEmpty)
        .join(', ');
    return {
      'เวลา':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'ผู้บันทึก': ErSession.instance.user?.name ?? '-',
      if (cc.isNotEmpty) 'อาการสำคัญ': cc,
      if (f('sbp') != null)
        'ความดันโลหิต (mmHg)': '${f('sbp')}/${f('dbp') ?? '-'}',
      if (f('hr') != null) 'อัตราการเต้นหัวใจ (bpm)': f('hr')!,
      if (f('rr') != null) 'อัตราการหายใจ (/min)': f('rr')!,
      if (f('spo2') != null) 'ออกซิเจนในเลือด (%)': f('spo2')!,
      if (f('bt') != null) 'อุณหภูมิ (°C)': f('bt')!,
      if (f('wt') != null) 'น้ำหนัก (kg)': f('wt')!,
      if (f('ht') != null) 'ส่วนสูง (cm)': f('ht')!,
      if (f('waist') != null) 'รอบเอว (cm)': f('waist')!,
      if (f('head') != null) 'เส้นรอบศีรษะ (cm)': f('head')!,
      for (final label in const [
        'ตั้งครรภ์ / ให้นมบุตร / G6PD',
        _wfVsReqLabel,
      ])
        for (final (i, (name, _)) in _localGroups[label]!.indexed)
          if ((hx[label] ?? '').split(' · ') case final v
              when v.length > i && v[i] != '-' && v[i].isNotEmpty)
            name: v[i],
      if (hx['FP'] case final fp?) 'FP': fp,
    };
  }

  /// หน้าสรุปซักประวัติ: หมวดเดียวกับที่แสดงในกิจกรรมพยาบาล · กลับไปแก้ / ยืนยันบันทึก
  Widget _hxReviewPage() {
    final hn = _caseP().hn;
    final r = _hxSnapshot();
    final secs = _hxSections(r);
    Widget card(String name, List<(String, String, bool)> rows) => Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(name,
                style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
            const SizedBox(height: 6.0),
            for (final (k, v, bad) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150.0,
                        child: Text(k,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500)),
                      ),
                      // V/S: สีตามสถานะ + badge ค่าปกติ แบบหน้าการส่งตรวจ
                      Expanded(
                        child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              Text(v,
                                  style: _t(13.5,
                                      color: v == '-'
                                          ? _ink3
                                          : bad
                                              ? _red
                                              : _vsRefOf(k) != null
                                                  ? _green
                                                  : _inkTitle,
                                      weight: FontWeight.w600)),
                              if (_vsRefOf(k) case final ref? when v != '-')
                                Container(
                                  height: 24.0,
                                  padding: const EdgeInsets.fromLTRB(
                                      6.0, 0.0, 8.0, 0.0),
                                  decoration: BoxDecoration(
                                    color: (bad ? _red : _green)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            bad
                                                ? Icons.error_outline_rounded
                                                : Icons
                                                    .check_circle_outline_rounded,
                                            size: 14.0,
                                            color: bad ? _red : _green),
                                        const SizedBox(width: 4.0),
                                        Text('ค่าปกติ $ref',
                                            style: _num(12.0,
                                                color: bad ? _red : _green,
                                                weight: FontWeight.w600)),
                                      ]),
                                ),
                            ]),
                      ),
                    ]),
              ),
          ]),
        );
    return _wfFadePage(
      ListView(
        // เผื่อที่ใต้ปุ่มลอย
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
        children: [
          Text('สรุปก่อนบันทึก',
              style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 2.0),
          Text('ตรวจทานข้อมูลซักประวัติ กดย้อนกลับเพื่อแก้',
              style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(height: 16.0),
          for (final (name, rows) in secs) card(name, rows),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Row(children: [
          Expanded(
            child: _navBtn('ย้อนกลับ', Icons.chevron_left_rounded,
                () => setState(() => _uiIdx = 1),
                primary: false),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: _navBtn('ยืนยันบันทึก', Icons.check_rounded, () {
              _hxSaved.add(hn);
              (_hxRecs[hn] ??= []).add(r);
              _triVsCommit(hn);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('บันทึกซักประวัติแล้ว',
                      style: _t(13.0, color: Colors.white))));
              // บันทึกแล้ว: หุบ workflow แล้วพาไปหน้ากิจกรรมพยาบาล tab ซักประวัติ
              setState(() {
                _wfVsFor = null;
                _uiIdx = 1;
                _detailTab = _nurseTab;
                _actKind = 'ซักประวัติ';
              });
              _closeSpeech();
            }),
          ),
        ]),
      ),
    );
  }

  /// full = ขั้นซักประวัติ: อาการสำคัญ + V/S (รวมรอบเอว เส้นรอบศีรษะ) + ข้อมูลเพิ่มเติม
  /// ไม่ full = ขั้นสัญญาณชีพ: การ์ด V/S อย่างเดียว ไว้วัดรอบถัดไป
  Widget _wfVsBody({bool full = false}) {
    final hn = _caseP().hn;
    if (_wfVsFor != hn) {
      // เปิดขั้นนี้ครั้งแรกของเคส: ล้างค่าที่ค้างจากหน้าคัดกรอง เริ่มรอบวัดใหม่
      _wfVsFor = hn;
      for (final k in const ['sbp', 'dbp', 'hr', 'rr', 'bt', 'spo2', 'dtx']) {
        _triCtl(k).text = '';
      }
      _triVsAt = null;
      // อาการสำคัญ: เริ่มว่าง พยาบาลซักใหม่ โดยดูอาการจากจุดส่งตรวจประกอบ (knowledge ข้อ 52)
      _qCc.clear();
      _regCtl('cc').text = '';
      _hxPage = 0;
    }
    // น้ำหนัก ส่วนสูง: บันทึกไว้แล้วตอนคัดกรองส่งตรวจ ช่องว่าง = เติมจากคัดกรอง (แก้ได้)
    final tri = erTableFor(hn, ErTab.triage).rows;
    for (final (k, label) in const [
      ('wt', 'น้ำหนัก (kg)'),
      ('ht', 'ส่วนสูง (cm)'),
    ]) {
      final v = tri.where((r) => r[1] == label).map((r) => r[2]).firstOrNull;
      if (_triCtl(k).text.trim().isEmpty &&
          v != null &&
          double.tryParse(v) != null) {
        _triCtl(k).text = v;
      }
    }
    _qCardNarrow = true;
    _triVsExtra = full;
    // อาการสำคัญ: การ์ดเดียวกับหน้าคัดกรองส่งตรวจ (ชิปอาการ + พิมพ์เพิ่ม)
    final cc = full ? _qCcCard(fromTriage: erCaseOf(hn).cc.trim()) : null;
    final card = _triAssessCards().first;
    _triVsExtra = false;
    final more = full ? _wfVsMoreCard() : null;
    _qCardNarrow = false;
    // ซักประวัติ: แยกหัวข้อเป็น stepper หน้าละหัวข้อ (ตรงกับหน้าแนะนำ 3 ข้อ)
    final reqV = (_filled[7][_wfVsReqLabel] ?? '').split(' · ');
    final reqOk = reqV.length == 3 && !reqV.contains('-');
    final pages = full
        ? <(String, bool, List<Widget>)>[
            (
              'อาการสำคัญ',
              // ครบเมื่อกรอกอย่างน้อย 1 อย่าง: พิมพ์อาการ หรือเลือกชิป (ไม่บังคับทั้งคู่)
              _qCc.isNotEmpty || _regCtl('cc').text.trim().isNotEmpty,
              [cc!]
            ),
            (
              'สัญญาณชีพ',
              ['sbp', 'hr', 'rr', 'bt', 'spo2']
                  .any((k) => _triCtl(k).text.trim().isNotEmpty),
              [card]
            ),
            ('แพ้ยา บุหรี่ สุรา', reqOk, [more!]),
          ]
        : null;
    final pg = pages == null ? 0 : _hxPage.clamp(0, pages.length - 1);
    final last = pages == null || pg == pages.length - 1;
    void submit() {
      // แพ้ยา สูบบุหรี่ ดื่มสุรา ต้องเลือกครบก่อนบันทึก
      if (full && !reqOk) {
        HapticFeedback.heavyImpact();
        setState(() {
          _wfVsReqShow = true;
          _hxPage = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'เลือกการแพ้ยา การสูบบุหรี่ และการดื่มสุราให้ครบก่อนบันทึก',
                style: _t(13.0, color: Colors.white))));
        return;
      }
      _wfVsReqShow = false;
      // ซักประวัติ: ไปหน้าสรุปก่อน ยืนยันที่หน้าสรุปจึงบันทึก (P4)
      if (full) {
        setState(() => _uiIdx = 2);
        return;
      }
      _triVsCommit(hn);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('บันทึกสัญญาณชีพรอบใหม่แล้ว',
              style: _t(13.0, color: Colors.white))));
      setState(() => _wfVsFor = null);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (pages != null)
        _hxStepper([for (final p in pages) (p.$1, p.$2)], pg)
      else
        const SizedBox(height: 8.0),
      // ปุ่มลอยเหนือเนื้อหา ไม่มีแถบพื้นขาวรอง: เนื้อหาเลื่อนผ่านใต้ปุ่มได้
      Expanded(
        child: Stack(children: [
          Positioned.fill(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              // เนื้อหาเลื่อนผ่านใต้ปุ่ม (ไม่มีพื้นขาวทึบ) จางบาง ๆ ช่วงปุ่ม · ขอบบนไม่จาง
              shaderCallback: (r) {
                final h = r.height;
                double at(double px) => (1.0 - px / h).clamp(0.0, 1.0);
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0.3),
                  ],
                  stops: [
                    0.0,
                    (8.0 / h).clamp(0.0, 1.0),
                    at(110.0),
                    at(70.0),
                    1.0,
                  ],
                ).createShader(r);
              },
              child: ListView(
                // key ตามหน้า (ไม่ใช่ PageStorageKey): เปลี่ยนหน้า = เริ่มบนสุดเสมอ
                // (design rule) · ในหน้าเดียวกัน rebuild แล้วตำแหน่งเลื่อนยังอยู่
                key: ValueKey(full ? 'wf-hx-list-$pg' : 'wf-vs-list'),
                // ไม่เก็บ/คืนตำแหน่งจาก PageStorage (ทุกหน้าใช้ที่เก็บร่วมกัน)
                controller: _hxScroll,
                // เผื่อที่ใต้ปุ่มลอย: เลื่อนเนื้อหาสุดท้ายขึ้นพ้นปุ่มได้
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
                // เปลี่ยนหน้า stepper: เนื้อหาค่อย ๆ ลอยขึ้นปรากฏ (key ตามหน้า = เล่นใหม่ทุกครั้ง)
                children: pages != null
                    ? [
                        for (final (i, w) in pages[pg].$3.indexed)
                          _Appear(
                              key: ValueKey('hx-$pg-$i'), index: i, child: w),
                      ]
                    : [card],
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: pages == null
                  ? SizedBox(
                      height: 52.0,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                        ),
                        onPressed: submit,
                        child: Text('บันทึกสัญญาณชีพ',
                            style: _t(15.0,
                                color: Colors.white, weight: FontWeight.w700)),
                      ),
                    )
                  : Row(children: [
                      Expanded(
                        child: _navBtn(
                            'ย้อนกลับ',
                            Icons.chevron_left_rounded,
                            () => setState(() {
                                  if (pg == 0) {
                                    _uiIdx = 0;
                                  } else {
                                    _hxPage = pg - 1;
                                  }
                                }),
                            primary: false),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _navBtn(
                            last ? 'ตรวจทานก่อนบันทึก' : 'ถัดไป',
                            Icons.chevron_right_rounded,
                            last
                                ? submit
                                : () => setState(() => _hxPage = pg + 1),
                            trailing: true),
                      ),
                    ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  /// หน้าใน workflow: รายการเลื่อนได้ + ปุ่มลอยด้านล่าง (ไม่มีแถบพื้นขาว)
  /// ขอบล่างจางบาง ๆ ช่วงปุ่ม เนื้อหาเลื่อนผ่านใต้ปุ่มได้ · ใช้ทุกหน้าให้เหมือนกัน
  Widget _wfFadePage(Widget list, Widget footer) => Stack(children: [
        Positioned.fill(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) {
              final h = r.height;
              double at(double px) => (1.0 - px / h).clamp(0.0, 1.0);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                ],
                stops: [0.0, at(110.0), at(70.0), 1.0],
              ).createShader(r);
            },
            child: list,
          ),
        ),
        Positioned(left: 0.0, right: 0.0, bottom: 0.0, child: footer),
      ]);

  /// แถบขั้นของซักประวัติ: วงเลข + ชื่อหัวข้อ เส้นเชื่อม · ครบ = เช็กเขียว
  /// แตะหัวข้อเพื่อข้ามไปหน้านั้นได้
  Widget _hxStepper(List<(String, bool)> steps, int at) {
    // เปลี่ยนขั้นแบบมี motion: เส้นเติมสีไหลไปขั้นถัดไป · วงเปลี่ยนสีพร้อมเด้ง
    // ชื่อขั้นคลี่ออก/หุบ (AnimatedSize) ไม่กระโดด
    const dur = Duration(milliseconds: 320);
    const curve = Curves.easeInOutCubic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Row(children: [
        for (final (i, (label, done)) in steps.indexed) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2.0,
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                color: const Color(0xFFE3E8F2),
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: i <= at || steps[i - 1].$2 ? 1.0 : 0.0),
                  duration: dur,
                  curve: curve,
                  // สีเส้นตามขั้นก่อนหน้า: กรอกครบ (เช็กเขียว) = เขียว · ยังไม่ครบ = กรมท่า
                  builder: (context, v, _) => FractionallySizedBox(
                      widthFactor: v,
                      child: AnimatedContainer(
                          duration: dur,
                          color: steps[i - 1].$2 ? _green : _blue)),
                ),
              ),
            ),
          _Press(
            radius: 100.0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _hxPage = i);
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                TweenAnimationBuilder<double>(
                  // วงที่เพิ่งเป็นขั้นปัจจุบันเด้งเบา ๆ
                  key: ValueKey('hxdot-$i-${i == at}'),
                  tween: Tween(begin: i == at ? 0.8 : 1.0, end: 1.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  builder: (context, sc, child) =>
                      Transform.scale(scale: sc, child: child),
                  child: AnimatedContainer(
                    duration: dur,
                    curve: curve,
                    width: 28.0,
                    height: 28.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done && i != at
                          ? _green
                          : i == at
                              ? _blue
                              : const Color(0xFFE8EAED),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: done && i != at
                          ? const Icon(Icons.check_rounded,
                              key: ValueKey('ok'),
                              size: 16.0,
                              color: Colors.white)
                          : Text('${i + 1}',
                              key: ValueKey('n${i == at}'),
                              style: _num(13.0,
                                  color: i == at ? Colors.white : _ink2)),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: dur,
                  curve: curve,
                  child: AnimatedOpacity(
                    duration: dur,
                    opacity: i == at ? 1.0 : 0.0,
                    child: i == at
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(label,
                                style: _t(13.5,
                                    color: _inkTitle, weight: FontWeight.w700)),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  /// ขั้นคัดกรองของพยาบาล: การ์ดชุดเดียวกับแท็บคัดกรองของหน้าส่งตรวจ
  /// (ประเภทผู้ป่วย อาการสำคัญ Red flag สัญญาณชีพ GCS ความปวด ระดับ ESI)
  Widget _wfTriageBody() {
    _qCardNarrow = true;
    final tri = _triAssessCards();
    final cards = <Widget>[
      _triTypeCard(),
      _qCcCard(),
      tri[7],
      tri[0],
      tri[1],
      tri[6],
      tri[3],
      tri[4],
      tri[5],
    ];
    _qCardNarrow = false;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 24.0),
      children: cards,
    );
  }

  /// หน้าคำแนะนำของขั้นที่ใช้หน้ากรอกเฉพาะ (design rule: ทุกเมนูมีหน้าคำแนะนำก่อน)
  /// _uiIdx 0 = หน้าคำแนะนำ · กด "เริ่มกรอก" = 1 (เปลี่ยนขั้นแล้วกลับเป็น 0)
  Widget _wfIntroGate(Widget Function() body) {
    if (_uiIdx > 0) return body();
    return _wfFadePage(
      ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
        children: [_stepIntro()],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Row(children: [
          Expanded(
              child: _navBtn('ย้อนกลับ', Icons.chevron_left_rounded, null,
                  primary: false)),
          const SizedBox(width: 12.0),
          Expanded(
            child: _navBtn('เริ่มกรอก', Icons.chevron_right_rounded,
                () => setState(() => _uiIdx = 1),
                trailing: true),
          ),
        ]),
      ),
    );
  }

  Widget _clyGuideBody() {
    if (ErSession.instance.role == ErRole.nurse &&
        _steps[_speechStep].$2 == 'สัญญาณชีพ') {
      return _wfIntroGate(_wfVsBody);
    }
    // ซักประวัติ: หน้าเดียวรวมอาการสำคัญ สัญญาณชีพ และข้อมูลตามแบบ HOSxP
    if (ErSession.instance.role == ErRole.nurse &&
        _steps[_speechStep].$2 == 'ซักประวัติ') {
      return _wfIntroGate(
          () => _uiIdx >= 2 ? _hxReviewPage() : _wfVsBody(full: true));
    }
    if (ErSession.instance.role == ErRole.nurse &&
        _steps[_speechStep].$2 == 'คัดกรอง') {
      return _wfIntroGate(_wfTriageBody);
    }
    final seq = _uiSeq;
    final n = seq.length;
    final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
    final cur = n == 0 ? null : seq[at];
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    // กำลังพิมพ์ในช่องอยู่: รอพิมพ์เสร็จ (ออกจากช่อง) ค่อยพาไปหน้าตรวจสอบ
    if (complete && _reviewShown != _speechStep && n > 0 && !_inlineTyping) {
      _reviewShown = _speechStep;
      // รอ Dr.Note morph bubble → ปากกาให้จบก่อน (1.6 วิ) ค่อยพาไปหน้าตรวจสอบ
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted && _reviewShown == _speechStep) {
          setState(() => _uiIdx = _uiSeq.length - 1);
        }
      });
    } else if (!complete && _reviewShown == _speechStep) {
      _reviewShown = -1;
    }
    final busy = _agentStatus.isNotEmpty;
    final say = busy
        ? _agentStatus
        : (_agentSay.isEmpty ? 'น้องช่วยพร้อมค่ะ' : _agentSay);
    final total = _pageCount(seq);
    final page = _pageAt(seq);
    final shellMic = cur?.type == ErUiType.form &&
        (_isPeStep(_speechStep) || _isHpiStep(_speechStep));
    return Stack(children: [
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // หัว: ชื่อขั้น (ปุ่มหุบอยู่ล่างสุดของรายการขั้นแล้ว)
            // หน้าคำแนะนำมีชื่อขั้นพร้อมไอคอนอยู่แล้ว หัวแผงไม่ต้องซ้ำ → ไม่มีแถวหัว
            if (page > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                child: Text(_steps[_speechStep].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
            // หน้าคำแนะนำ (หน้าแรก) ยังไม่ต้องมี stepper · เริ่มแสดงเมื่อเข้าหน้ากรอก
            if (total > 1 && page > 0) _pageStepper(seq, page),
            // ไม่แสดงข้อความผู้ช่วยและชิปตัวเลือกคำตอบเหนือหัวข้อหน้า (ผู้ใช้สั่งเอาออก)
            // เนื้อหาของขั้น (ช่องที่ต้องกรอก / การ์ด) ใช้พื้นที่ที่เหลือทั้งหมด
            // มี key: แถวด้านบนโผล่/หาย (สถานะผู้ช่วย · ชิป · stepper) แล้วเนื้อหาไม่ถูกสร้างใหม่
            // (ถ้าสร้างใหม่ รายการที่เลื่อนไว้จะเด้งกลับบนสุด)
            Expanded(
              key: const ValueKey('wf-content'),
              child: Stack(children: [
                Positioned.fill(
                  child: Padding(
                    // หน้าแนะนำ (ไม่มีแถวหัว): ขอบบนเท่าขอบข้าง 16
                    // ฟอร์มสูงเต็มที่เหลือ: เว้นที่ให้ footer · การ์ดอื่นเลื่อนลอดใต้ footer ได้
                    padding: EdgeInsets.fromLTRB(
                        // การ์ดเลื่อนได้: ขอบข้างอยู่ในรายการ แถวเลื่อนแนวนอนล้นถึงขอบแผงได้
                        cur?.type == ErUiType.form ? 16.0 : 0.0,
                        cur?.type == ErUiType.form
                            ? (page > 0 ? 6.0 : 10.0)
                            : 0.0,
                        cur?.type == ErUiType.form ? 16.0 : 0.0,
                        cur?.type == ErUiType.form ? _wfFootH : 0.0),
                    child: cur == null
                        ? Center(
                            child: Text('แตะไมค์แล้วพูดได้เลย',
                                style: _t(12.0, color: _ink3)))
                        : GestureDetector(
                            onHorizontalDragEnd:
                                n < 2 || cur.type == ErUiType.form
                                    ? null
                                    : (d) {
                                        final v = d.primaryVelocity ?? 0;
                                        if (v < -200) _uiGo(1, n);
                                        if (v > 200) _uiGo(-1, n);
                                      },
                            // เปลี่ยนหน้า: เลื่อนซ้าย/ขวาตามทิศ + จาง (ทุกหน้า ทั้งการ์ดและช่องฟอร์ม)
                            // ตัดขอบเลยขวาออกไป 16 (ถึงขอบแผง) ให้แถวชิปที่เลื่อนแนวนอนล้นถึงขอบแผงได้
                            child: ClipRect(
                              clipper: const _ClipPastRight(16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder: (a, b) => Stack(
                                    alignment: Alignment.topLeft,
                                    children: [...b, if (a != null) a]),
                                transitionBuilder: (child, anim) {
                                  final incoming = child.key ==
                                      ValueKey('pg_${_speechStep}_$page');
                                  final dir = _formFwd ? 1.0 : -1.0;
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(
                                            (incoming ? 0.22 : -0.22) * dir,
                                            0.0),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey('pg_${_speechStep}_$page'),
                                  // แผง workflow กาง: ฟอร์มขยายเต็มความสูงที่เหลือ
                                  child: LayoutBuilder(builder: (context, box) {
                                    _flipFill = cur.type == ErUiType.form
                                        ? box.maxHeight - 12.0
                                        : null;
                                    final Widget w = cur.type == ErUiType.form
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: _uiBlock(cur),
                                          )
                                        // การ์ดอื่นยาวได้ เลื่อนภายในแผง ไม่ล้นขอบ
                                        // จำตำแหน่งเลื่อนไว้ ติ๊กรายการแล้วไม่เด้งกลับบนสุด
                                        : SingleChildScrollView(
                                            key: PageStorageKey(
                                                'wfpg_${_speechStep}_$page'),
                                            // เว้นท้ายให้เลื่อนรายการสุดท้ายพ้น footer
                                            // ขอบบนอยู่ในรายการ: เลื่อนขึ้นแล้วเนื้อหาไปจางใต้ stepper ไม่ถูกตัด
                                            padding: EdgeInsets.fromLTRB(
                                                16.0,
                                                page > 0 ? 10.0 : 14.0,
                                                16.0,
                                                _wfFootH + 8.0),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: _uiBlock(cur),
                                            ),
                                          );
                                    _flipFill = null;
                                    return w;
                                  }),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                // บน: ไม่มีแถบจาง (ผู้ใช้ไม่เอาขอบฟุ้ง) เนื้อหาตัดตรงใต้ stepper
                // ล่าง: ปุ่มใหญ่ ย้อนกลับ · ไมค์ · ถัดไป ลอยทับเนื้อหา
                // พื้นกระจกแบบไม่เบลอ (blur กิน raster): ไล่ขาวโปร่ง → ทึบ + เส้นแสงขอบบน
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _panel.withValues(alpha: 0.0),
                          _panel.withValues(alpha: 0.86),
                          _panel.withValues(alpha: 0.97),
                        ],
                        stops: const [0.0, 0.28, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 10.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        Expanded(
                          child: _navBtn('ย้อนกลับ', Icons.chevron_left_rounded,
                              page > 0 ? () => _pageGo(seq, page - 1) : null,
                              primary: false),
                        ),
                        // ไมค์แตะเปิด/ปิด + สถานะใต้ปุ่ม
                        // หน้าการ์ด HPI / ตรวจร่างกาย: ไมค์อยู่บนหัวการ์ดแล้ว ไม่ต้องมีซ้ำด้านล่าง
                        if (!shellMic) ...[
                          const SizedBox(width: 10.0),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(
                              width: 56.0,
                              height: 52.0,
                              child: OverflowBox(
                                maxWidth: 90.0,
                                maxHeight: 90.0,
                                child: _barMic(),
                              ),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: _micFrame,
                              builder: (_, __, ___) => _micLabel(),
                            ),
                          ]),
                        ],
                        const SizedBox(width: 10.0),
                        Expanded(child: _nextBtn(seq, page, total)),
                      ]),
                    ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    ]);
  }
}

/// ความสูง footer ปุ่มนำทาง (ปุ่ม + ป้ายไมค์ + ขอบ) ใช้เว้นท้ายเนื้อหา
const double _wfFootH = 84.0;

/// ตัดขอบตามกล่อง แต่ยื่นเลยขอบขวาออกไป [dx] (เนื้อหาล้นถึงขอบแผงได้)
class _ClipPastRight extends CustomClipper<Rect> {
  const _ClipPastRight(this.dx);
  final double dx;

  @override
  Rect getClip(Size size) =>
      // เผื่อด้านบน 60: มาสคอต Dr.Note ล้นขึ้นเหนือการ์ดได้ (ทับแถบ stepper)
      Rect.fromLTRB(0.0, -60.0, size.width + dx, size.height);

  @override
  bool shouldReclip(_ClipPastRight old) => old.dx != dx;
}

/// ความคืบหน้าการกางแผง workflow (0 = ราง, 1 = กางเต็ม) ให้ส่วนในแผงที่ต้องรู้จังหวะอ่าน
/// ไม่ส่งผ่าน setState เพื่อไม่ให้สร้างแผงทั้งก้อนใหม่ทุกเฟรม
class _WfProgress extends InheritedWidget {
  const _WfProgress({required this.v, required super.child});

  final double v;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WfProgress>()?.v ?? 1.0;

  @override
  bool updateShouldNotify(_WfProgress old) => old.v != v;
}
