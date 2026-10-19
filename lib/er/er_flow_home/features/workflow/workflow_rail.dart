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

/// แถบปุ่มล่างของแผง workflow: toast ลอยเหนือแถบนี้ในแผงขวา ไม่ทับปุ่ม
final GlobalKey _wfBtnKey = GlobalKey();

/// สถานะกาง/หุบที่แอนิเมชันใช้ (ตาม _speechOpen ช้าไป 1 เฟรม ดู patient_page)
final ValueNotifier<bool> _wfGo = ValueNotifier(false);

/// ช่องที่เลือกในรางหุบ: วัดตำแหน่งให้พื้นรางขาว morph ไปเป็นแท็บของเมนูนั้นตอนกาง
final GlobalKey _wfSelKey = GlobalKey();

/// รางขั้นตอนขวา: กว้างเท่ารางแท็บซ้าย (100) · สูงช่องคำนวณตามจอ (ตั้งใน LayoutBuilder)
const double _wfRailW = 100.0;
double _wfCellH = 72.0;

extension _FeaturesWorkflowWorkflowRailPart on _ErFlowHomeWidgetState {
  /// snackbar แบบ Google มุม 8 ตัวขาว ไม่มีปุ่มปิด หายเอง
  /// error = พื้นเทาเข้ม + ไอคอนแดงอ่อน F28B82 · สำเร็จ = พื้นเขียวทึบ + ติ๊กขาว
  void _wfToast(String msg, {bool error = false, bool anchored = true}) {
    final m = ScaffoldMessenger.of(context);
    // วางในแผงขวา เหนือแถบปุ่ม (กว้างเท่าปุ่ม) · หาแถบไม่เจอ / แผงกำลังปิด = กลางล่าง
    EdgeInsets? margin;
    final box = anchored ? _wfBtnKey.currentContext?.findRenderObject() : null;
    if (box is RenderBox && box.attached) {
      final o = box.localToGlobal(Offset.zero);
      final screen = MediaQuery.sizeOf(context);
      margin = EdgeInsets.fromLTRB(
          o.dx + 16.0,
          0.0,
          screen.width - o.dx - box.size.width + 16.0,
          screen.height - o.dy - MediaQuery.paddingOf(context).bottom);
    }
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      width: margin == null ? 400.0 : null,
      margin: margin,
      elevation: 0.0,
      duration: Duration(milliseconds: error ? 4000 : 2500),
      backgroundColor:
          error ? const Color(0xFF3C4043) : const Color(0xFF188038),
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Row(children: [
        Icon(error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            size: 20.0, color: error ? const Color(0xFFF28B82) : Colors.white),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(msg,
              style: _t(14.0, color: Colors.white, weight: FontWeight.w500)),
        ),
      ]),
    ));
  }

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
  /// bg: false = ไม่วาดพื้นขาว (ตอนกาง/หุบ พื้นขาวเป็นชั้น morph แยก ดู patient_page)
  Widget _clyRail({bool bg = true}) {
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
      width: _wfRailW,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 8.0),
      decoration: bg
          ? const BoxDecoration(
              color: _panel,
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(20.0)),
            )
          : null,
      // สูงช่องตามที่มี แบบรางซ้าย (46–72) ให้ครบทุกขั้นในจอเดียว
      child: LayoutBuilder(builder: (context, box) {
        _wfRailFit(box.maxHeight, reserve: 56.0);
        return SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final i in _stepOrder) ...[
              if (i != _firstStep) _railLine(_stepPos(i) <= done),
              _clyRailItem(i, cur),
              if (_tplOn && i == _speechStep) _tplSubmenu(),
              if (_accAfter(i)) ...[
                _railLine(_stepPos(i) < done),
                _accidentRailItem(),
              ],
            ],
          ]),
        );
      }),
    );
  }

  /// สูงช่องในรางขวา = แบบรางซ้าย: แบ่งความสูงตามจำนวนขั้น (+ อุบัติเหตุ) 46–72
  /// reserve = ที่ของปุ่มหุบ/กางใต้ราง · หุบ/กางใช้ความสูงเท่ากัน ไอคอนไม่ขยับ
  void _wfRailFit(double h, {double reserve = 0.0}) {
    if (!h.isFinite) return;
    // ขั้นของบทบาท + ช่องวาดภาพใต้ตรวจร่างกาย
    // (ช่องอุบัติเหตุเอาออกจากรางแพทย์ 2026-10-19: พยาบาลคัดกรองบันทึกอุบัติเหตุ)
    final n = _stepOrder.length +
        (_stepOrder.any(_accAfter) ? 1 : 0) +
        (_stepOrder.any((i) => _steps[i].$2 == 'ตรวจร่างกาย') ? 1 : 0);
    // ต่ำสุด 56 = ไอคอน 34 + ชื่อ 1 บรรทัด ไม่ล้นช่อง (46 เดิมไอคอนล้นขึ้นบน)
    _wfCellH = ((h - reserve - 8.0) / n - 4.0).clamp(56.0, 72.0);
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
    _drawPaneOn = false;
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
    Widget? below,
    double belowH = 0.0,
  }) {
    final ink = complete ? _green : (on ? _blue : _ink3);
    return _railCellBody(
        below: below,
        belowH: below == null ? 0.0 : belowH,
        icon: icon,
        label: label,
        on: on,
        complete: complete,
        progress: progress,
        joined: joined,
        first: first,
        ink: ink);
  }

  Widget _railCellBody({
    required IconData icon,
    required String label,
    required bool on,
    required bool complete,
    required double? progress,
    required bool joined,
    required bool first,
    required Color ink,
    Color? fill,
    Widget? below,
    double belowH = 0.0,
  }) {
    // ที่เลือก = แผ่นขาวบนพื้นเทา แบบรางแท็บซ้าย
    // joined (แผงกาง): ชิดซ้ายต่อกับแผงเนื้อหา มุมเว้าบน/ล่าง
    final cell = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      // กว้างเต็มรางทั้งตอนหุบ/กาง: ชื่อขั้นตัดบรรทัดเหมือนกัน ช่องสูงเท่ากัน ไม่เลื่อน
      width: double.infinity,
      // ขนาดเท่ารางซ้าย: สูงตามที่มี ไอคอน 24 ชื่อ 10.5 บรรทัดเดียว
      // มีเมนูย่อย = แผ่นขาวยืดลงครอบเมนูย่อยด้วย (แบบรางซ้าย ข้อมูลผู้ป่วย → EMR)
      // สูงตายตัวเสมอ (AnimatedContainer เทียบ null ↔ ค่าไม่ได้) · เมนูย่อยละ 48 + ท้าย 4
      height: _wfCellH + belowH,
      decoration: BoxDecoration(
        // ต่อกับแผง = ขาว · บนแถบขาว (หุบ) = ฟ้าอ่อนให้เห็นว่าเลือก
        color: on
            // รางหุบ: ไม่มี pill ฟ้า (เคยโผล่ 1–2 เฟรมก่อนกางแล้วหาย = กะพริบ) · แท็บขาวมาจาก morph
            ? (fill ?? (joined ? _panel : _panel.withValues(alpha: 0.0)))
            : _panel.withValues(alpha: 0.0),
        borderRadius: joined
            ? const BorderRadius.horizontal(right: Radius.circular(16.0))
            : BorderRadius.circular(16.0),
      ),
      // ตอนหุบ morph บีบช่องเหลือสูงเดียว: ตัดส่วนเมนูย่อยทิ้ง ไม่ล้น
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0.0,
          maxHeight: double.infinity,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: _wfCellH,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      // ไอคอนขั้นที่เลือกบนรางกาง: เป้าของแอนิเมชันบันทึกสำเร็จ
                      key: on && joined ? _wfSelIconKey : null,
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
                                backgroundColor:
                                    v > 0 ? _line : Colors.transparent,
                                color: _blue,
                              ),
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          // ไอคอน Phosphor: ไม่เลือก = Regular · เลือก = Fill · ครบ = เช็กวง (Fill)
                          child: switch ((complete, _solarSteps[label])) {
                            (true, _) => _SolarIcon('ถูกต้อง',
                                key: const ValueKey(true),
                                size: 24.0,
                                stroke: 1.5,
                                color: ink,
                                paths: _solarSteps['ถูกต้อง']!.$2),
                            (false, final sol?) => _SolarIcon(label,
                                // คีย์คงที่: เปลี่ยนเส้น↔ทึบตอนเลือกทันที ไม่เล่น scale (เล่นเฉพาะตอนครบ)
                                key: const ValueKey(false),
                                size: 24.0,
                                stroke: 1.5,
                                color: ink,
                                grow: on ? 0.0 : 0.5,
                                paths: on ? sol.$2 : sol.$1),
                            _ => Icon(
                                complete ? Icons.check_circle_rounded : icon,
                                key: ValueKey(complete),
                                size: 24.0,
                                color: ink),
                          },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(_stepShown(label),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: _t(10.5,
                              color: on ? _inkTitle : _ink3,
                              weight: on ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ]),
            ),
            if (below != null) below,
          ]),
        ),
      ),
    );
    if (!joined && on) return KeyedSubtree(key: _wfSelKey, child: cell);
    if (!joined || !on) return cell;
    // มุมเว้าตรงรอยต่อกับแผง: วาดเฉพาะเนื้อขาว (ไม่มีแผ่นเทาทับ = ไม่เห็นเสี้ยวเทาบนฉาก/พื้น)
    // แสดงตลอด: ระหว่างกาง แท็บอยู่ในพื้นขาวที่ morph อยู่แล้ว มุมจึงกลืนไป ไม่กะพริบตอนจบ
    Widget fillet({required bool top}) => SizedBox(
          width: 16.0,
          height: 16.0,
          child: CustomPaint(painter: _ConcaveCorner(top: top)),
        );
    return Stack(clipBehavior: Clip.none, children: [
      // แท็บที่ต่อกับแผง: แอนิเมชันบันทึกสำเร็จเติมเขียวตรงนี้ด้วย
      KeyedSubtree(key: _wfSelCellKey, child: cell),
      // ขั้นแรกชิดขอบบน ไม่มีมุมเว้าด้านบน
      if (!first) Positioned(left: 0.0, top: -16.0, child: fillet(top: true)),
      Positioned(left: 0.0, bottom: -16.0, child: fillet(top: false)),
    ]);
  }

  /// เปิดหน้าแนะนำ "วาดภาพ" ในแผง workflow (hero + ขั้นตอน + เริ่ม)
  void _openDrawPane() {
    _accPaneReset();
    setState(() {
      _drawPaneOn = true;
      _accPane = KeyedSubtree(
        key: const PageStorageKey('draw-intro'),
        child: Builder(builder: (_) => _drawIntroPane()),
      );
    });
  }

  /// เมนูย่อยในแผ่นขาวของขั้น แบบรางซ้าย (EMR/การส่งตรวจ): ข้อความล้วน
  /// เลือกอยู่ = pill ฟ้าอ่อน ตัวกรมท่าหนา
  Widget _railSub(String text, bool on, VoidCallback onTap) => _Press(
        scale: 0.98,
        radius: 8.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            ErFeedback.tap();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 44.0,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 6.0, 4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE8F0FE) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: _t(13.0,
                  color: on ? _blue : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w500),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
        ),
      );

  /// ชื่อขั้นที่แสดง (key ขั้นคงเดิม): พยาบาล "ออกจาก ER" แสดงเป็น "จำหน่าย"
  String _stepShown(String label) => label == 'ออกจาก ER' ? 'จำหน่าย' : label;

  /// พยาบาล: ช่องอุบัติเหตุต่อจากขั้นคัดกรอง (แพทย์ไม่มี 2026-10-19)
  bool _accAfter(int i) =>
      ErSession.instance.isNurse && _steps[i].$2 == 'คัดกรอง';

  Widget _accidentRailItem({bool joined = false}) {
    final patient = _caseP();
    final saved = _accSaved(patient.hn);
    final on = _speechOpen && _accPane != null && !_drawPaneOn;
    return Semantics(
      button: true,
      label: 'อุบัติเหตุ${saved ? ' บันทึกแล้ว' : ''}',
      child: Tooltip(
        message: saved ? 'ดูข้อมูลอุบัติเหตุ' : 'บันทึกข้อมูลอุบัติเหตุ',
        // ไม่มี ripple/ย่อเด้ง (เหตุผลเดียวกับ _clyRailItem)
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ErFeedback.tap();
            _openAccidentPane();
          },
          child: _railCell(
            icon: Icons.car_crash_outlined,
            label: 'อุบัติเหตุ',
            on: on,
            complete: saved && !on,
            joined: joined,
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
    // ตรวจร่างกาย: เลือกอยู่ = เมนูย่อย ผลตรวจ / วาดภาพ ในแผ่นขาวเดียวกัน
    final drawOn = _speechOpen && _accPane != null && _drawPaneOn;
    final subs = joined &&
        label == 'ตรวจร่างกาย' &&
        _speechOpen &&
        _speechStep == i &&
        (_accPane == null || _drawPaneOn);
    // ไม่มี ripple/ย่อเด้ง (_Press): รางหุบถูกซ่อนทันทีที่เริ่มกาง ripple จะขาดกลางคัน (กะพริบ)
    // และช่องที่ย่ออยู่ทำให้ปลายทาง morph ส่าย · การกาง + morph เป็น feedback ของการแตะแล้ว
    return GestureDetector(
      // กดได้ทั้งช่อง (วง + ป้ายชื่อ) ไม่ต้องเล็งให้โดนวง
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ErFeedback.tap();
        // ไปขั้นอื่น = ออกจาก template (sub menu ผูกกับขั้น Order Set)
        if (i != _speechStep) _tplOpen = null;
        _accPaneDrop();
        _openSpeech(step: i);
      },
      child: _railCell(
        below: subs
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                _railSub('PE/ROS', !drawOn, () {
                  _accPaneDrop();
                  _openSpeech(step: i);
                }),
                _railSub('วาดภาพ', drawOn, _openDrawPane),
                const SizedBox(height: 4.0),
              ])
            : null,
        belowH: 100.0,
        icon: _steps[i].$1,
        label: label,
        on: on || active || subs,
        complete: complete,
        progress: n == 0 ? null : ok / n,
        joined: joined,
        first: i == _firstStep,
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
          // มุมขวาของแผงโค้งตามจังหวะกาง (เริ่มเหลี่ยม ต่อกับพื้นรางเป็นแผ่นเดียว)
          child: Builder(builder: (context) {
            final pr = 20.0 * _WfProgress.of(context);
            return Container(
              // ขั้นแรกเลือกอยู่ = มุมบนขวาเหลี่ยม ต่อกับแท็บขั้นเป็นแผ่นเดียว
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(20.0),
                        right: Radius.circular(pr))
                    .copyWith(
                        topRight: _speechStep == _firstStep && _accPane == null
                            ? Radius.zero
                            : Radius.circular(pr)),
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
                            // กรอบแผงสำหรับแอนิเมชันบันทึกสำเร็จ (ทุกบทบาท/ทุกขั้น รวมหน้าพยาบาล)
                            child: Stack(children: [
                              Positioned.fill(
                                child: IgnorePointer(
                                    child: SizedBox(key: _wfPanelKey)),
                              ),
                              Positioned.fill(
                                  child: _tplOn ? _tplBody() : _clyGuideBody()),
                            ])),
              ),
            );
          }),
        ),
        Container(
          width: _wfRailW,
          // ขั้นแรกชิดขอบบนแผง (แท็บที่เลือกต่อกับแผงเป็นแผ่นเดียว) · ช่องสูงพอ ไอคอนไม่ล้น
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 8.0),
          // คิดความสูงช่องจากความสูงรางทั้งหมด (เท่ารางหุบ) ไม่ใช่ที่เหลือหลังปุ่มหุบ
          // ไม่งั้นตอนกาง/หุบ สองรางสูงช่องไม่เท่ากัน ไอคอนซ้อนเหลื่อม (crossfade)
          child: LayoutBuilder(builder: (context, outer) {
            _wfRailFit(outer.maxHeight, reserve: 56.0);
            return Column(children: [
              Expanded(
                child: LayoutBuilder(builder: (context, box) {
                  return SingleChildScrollView(
                    child: Column(children: [
                      for (final i in _stepOrder) ...[
                        if (i != _firstStep)
                          _railLine(_stepPos(i) <= _railDoneN),
                        _clyRailItem(i, _speechStep, joined: true),
                        // เปิด template อยู่: หัวข้อ progress note เป็น sub menu ใต้ขั้นนี้
                        if (_tplOn && i == _speechStep) _tplSubmenu(),
                        if (_accAfter(i)) ...[
                          _railLine(_stepPos(i) < _railDoneN),
                          _accidentRailItem(joined: true),
                        ],
                      ],
                    ]),
                  );
                }),
              ),
              // ปุ่มหุบแผง: ล่างสุดของรายการขั้น นิ้วเอื้อมถึงง่าย
              const SizedBox(height: 8.0),
              _wfToggleBtn(open: true),
            ]);
          }),
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
  void _wheelPick(String title, List<String> opts, String? cur,
          ValueChanged<String> on) =>
      _wheelPickSeq([(title, opts, cur, on)]);

  /// วงล้อหลายข้อต่อกันแบบ sheet V/S: กด "ถัดไป" = บันทึกข้อนี้ ปิด sheet
  /// แล้วเปิด sheet ข้อถัดไปต่อทันที · ข้อสุดท้ายของชุด = "เสร็จ" · ข้อเดียว = "เลือก"
  void _wheelPickSeq(
      List<(String, List<String>, String?, ValueChanged<String>)> steps,
      {bool chained = false}) {
    if (steps.isEmpty) return;
    HapticFeedback.selectionClick();
    final (title, opts, cur, on) = steps.first;
    final nextTitle = steps.length > 1 ? steps[1].$1 : null;
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
                        // แบบ sheet V/S: ปิดแล้วเปิดข้อถัดไปต่อเลย
                        if (nextTitle != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) =>
                              _wheelPickSeq(steps.sublist(1), chained: true));
                        }
                      },
                      child: Text(
                          nextTitle != null
                              ? 'ถัดไป  $nextTitle'
                              : chained
                                  ? 'เสร็จ'
                                  : 'เลือก',
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
      // อ่านค่าล่าสุดทุกครั้ง: sheet หลายข้อบันทึกต่อกันโดยไม่ทับข้อก่อนหน้า
      void put(int i, String o) {
        final now = (hx[label] ?? '').split(' · ');
        final next = [
          for (var j = 0; j < gs.length; j++)
            now.length == gs.length ? now[j] : '-'
        ];
        next[i] = o;
        setState(() => hx[label] = next.join(' · '));
      }

      // แถวแบบหน้าตั้งค่า Google: ไอคอน + ชื่อ + ค่าที่เลือก · แตะเลือกจาก sheet
      return [
        for (final (i, (name, _)) in gs.indexed)
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
              // กลุ่มบังคับ (แพ้ยา บุหรี่ สุรา): เลือกเสร็จไปข้อถัดไปที่ยังว่างใน sheet เดิม
              onTap: () => _wheelPickSeq([
                for (final j in [
                  i,
                  if (req)
                    for (var n = i + 1; n < gs.length; n++)
                      if (at(n) == null && !skip.contains(gs[n].$1)) n,
                ])
                  (_wfNoun(gs[j].$1), gs[j].$2, at(j), (o) => put(j, o)),
              ]),
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
            child: KeyedSubtree(
              key: _wfSaveBtnKey,
              child: _navBtn('บันทึก', Icons.check_rounded, () {
                // แอนิเมชันบันทึกสำเร็จแบบเดียวกับทุกขั้น แล้วหุบ workflow
                // พาไปหน้ากิจกรรมพยาบาล tab ซักประวัติ
                _wfSaveBurst('ซักประวัติ', atFull: () {
                  _hxSaved.add(hn);
                  (_hxRecs[hn] ??= []).add(r);
                  _triVsCommit(hn);
                  setState(() => _speechDone.add(_speechStep));
                }, onClose: () {
                  setState(() {
                    _wfVsFor = null;
                    _uiIdx = 1;
                    _detailTab = _nurseTab;
                    _actKind = 'ซักประวัติ';
                  });
                  _closeSpeech();
                });
              }),
            ),
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
        _wfToast('เลือกแพ้ยา บุหรี่ สุรา ให้ครบก่อนบันทึก', error: true);
        return;
      }
      _wfVsReqShow = false;
      // ซักประวัติ: ไปหน้าสรุปก่อน ยืนยันที่หน้าสรุปจึงบันทึก (P4)
      if (full) {
        setState(() => _uiIdx = 2);
        return;
      }
      // สัญญาณชีพรอบใหม่: แอนิเมชันบันทึกสำเร็จแบบเดียวกับทุกขั้น แล้วหุบแผง
      _wfSaveBurst('สัญญาณชีพ', atFull: () {
        _triVsCommit(hn);
        setState(() => _speechDone.add(_speechStep));
      }, onClose: () {
        setState(() => _wfVsFor = null);
        _closeSpeech();
      });
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
              key: _wfBtnKey,
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: pages == null
                  ? SizedBox(
                      // จุดเริ่มแอนิเมชันบันทึกสำเร็จ
                      key: _wfSaveBtnKey,
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
                            last ? 'ตรวจทาน' : 'ถัดไป',
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
  Widget _hxStepper(List<(String, bool)> steps, int at,
      {void Function(int)? onTap}) {
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
                if (onTap != null) {
                  onTap(i);
                } else {
                  setState(() => _hxPage = i);
                }
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
  /// ขั้นรับคำสั่งแพทย์ (พยาบาล): คำสั่งจริงจากแพทย์ (_allTasks) แยกหน้าตามหมวด
  /// แต่ละแถว: ชื่อ + ด่วน · สั่งเมื่อ/โดย · ปุ่ม "รับคำสั่ง" (รับแล้ว = เช็กเขียว แตะซ้ำ = ยกเลิกการรับ)
  /// คำสั่งหลายรอบ: แตะแถว = sheet บันทึกรอบ (เดิม) · หน้าสุดท้าย = สรุป + บันทึก (แอนิเมชันสำเร็จ)
  Widget _wfOrderRecvBody() {
    final all = [
      for (final t in _allTasks)
        if (t.time.isNotEmpty) t
    ]..sort((a, b) => a.time.compareTo(b.time));
    final groups = <String, List<_Task>>{};
    for (final t in all) {
      (groups[_orderCat(t)] ??= []).add(t);
    }
    final cats = [
      for (final c in _orderCats)
        if (groups.containsKey(c)) c
    ];
    bool got(_Task t) => _taskDone.contains(t.title);
    final pages = [
      for (final c in cats) (c.split(' /').first, groups[c]!.every(got)),
      ('สรุป', all.every(got)),
    ];
    final pg = _ordPage.clamp(0, pages.length - 1);
    final review = pg == pages.length - 1;

    Widget row(_Task t, bool first) {
      final done = got(t);
      final at = _taskDoneAt[t.title];
      final rec = _taskRounds[_roundKey(t)];
      final n =
          int.tryParse(RegExp(r'×(\d+)').firstMatch(t.title)?.group(1) ?? '') ??
              0;
      return _gListRow(
        first: first,
        inset: 8.0,
        title: t.title,
        note: t.urgent ? 'ด่วน' : null,
        noteColor: _red,
        sub: done
            ? 'รับแล้ว${at == null ? '' : ' ${_taskClock(at)}'} ${_taskDoneBy[t.title] ?? ''}'
                .trim()
            : rec != null && rec.isNotEmpty
                ? 'ทำแล้ว ${rec.length}${n > 0 ? '/$n' : ''} รอบ  สั่ง ${_clock(t.time)} ${t.by}'
                : 'สั่ง ${_clock(t.time)} ${t.by}',
        subColor: done ? _green : _ink3,
        // แตะแถว = รายละเอียด/บันทึกรอบ (sheet เดิมของคำสั่ง)
        onTap: () => _taskAcceptSheet(t),
        trail: done
            ? IconButton(
                onPressed: () => _taskToggle(t),
                tooltip: 'ยกเลิกการรับคำสั่ง',
                icon: const Icon(Icons.check_circle_rounded,
                    size: 26.0, color: _green),
              )
            : FilledButton.tonal(
                onPressed: () => _taskToggle(t),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F0FE),
                  foregroundColor: _blue,
                  minimumSize: const Size(0.0, 36.0),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  shape: const StadiumBorder(),
                ),
                child: Text('รับคำสั่ง',
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ),
      );
    }

    Widget card(String title, List<Widget> rows, {Widget? action}) => Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 6.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 6.0),
              child: Row(children: [
                Expanded(
                  child: Text(title,
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                ),
                if (action != null) action,
              ]),
            ),
            ...rows,
          ]),
        );

    List<Widget> body;
    if (review) {
      final pending = [
        for (final t in all)
          if (!got(t)) t
      ];
      body = [
        Text('สรุปก่อนบันทึก',
            style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
        const SizedBox(height: 2.0),
        Text(
            pending.isEmpty
                ? 'รับคำสั่งครบทุกรายการแล้ว'
                : 'ยังไม่ได้รับ ${pending.length} รายการ บันทึกได้ รายการที่เหลือยังรออยู่',
            style: _t(12.5,
                color: pending.isEmpty ? _green : _ink3,
                weight: FontWeight.w500)),
        const SizedBox(height: 16.0),
        for (final c in cats)
          card(c, [
            for (final (i, t) in groups[c]!.indexed) row(t, i == 0),
          ]),
      ];
    } else {
      final c = cats[pg];
      final list = groups[c]!;
      final left = list.where((t) => !got(t)).length;
      body = [
        card(
            c,
            [
              for (final (i, t) in list.indexed) row(t, i == 0),
            ],
            // รับทั้งหมวดในครั้งเดียว (ไม่แตะรายการที่รับแล้ว)
            action: left < 2
                ? null
                : TextButton(
                    onPressed: () {
                      for (final t in list) {
                        if (!got(t)) _taskToggle(t);
                      }
                    },
                    child: Text('รับทั้งหมด ($left)',
                        style: _t(13.0, color: _blue, weight: FontWeight.w600)),
                  )),
      ];
    }

    void save() => _wfSaveBurst('รับคำสั่งแพทย์',
        atFull: () => setState(() => _speechDone.add(_speechStep)),
        onClose: () {
          setState(() {
            _ordPage = 0;
            _uiIdx = 0;
            _detailTab = _nurseTab;
            _actKind = null;
          });
          _closeSpeech();
        });

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _hxStepper(pages, pg, onTap: (i) => setState(() => _ordPage = i)),
      Expanded(
        child: _wfFadePage(
          ListView(
            key: ValueKey('ord-$pg'),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 96.0),
            children: all.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text('ยังไม่มีคำสั่งแพทย์',
                            style: _t(14.0,
                                color: _ink3, weight: FontWeight.w500)),
                      ),
                    ),
                  ]
                : body,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(children: [
              Expanded(
                child: _navBtn(
                    'ย้อนกลับ',
                    Icons.chevron_left_rounded,
                    () => setState(() {
                          if (pg == 0) {
                            _uiIdx = 0;
                          } else {
                            _ordPage = pg - 1;
                          }
                        }),
                    primary: false),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: review
                    ? KeyedSubtree(
                        key: _wfSaveBtnKey,
                        child: _navBtn('บันทึก', Icons.check_rounded, save))
                    : _navBtn(
                        pg == pages.length - 2 ? 'ตรวจทาน' : 'ถัดไป',
                        Icons.chevron_right_rounded,
                        () => setState(() => _ordPage = pg + 1),
                        trailing: true),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }

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
    // รับคำสั่งแพทย์: รายการคำสั่งจริงของเคส แยกหน้าตามหมวด → สรุป → บันทึก
    if (ErSession.instance.role == ErRole.nurse &&
        _steps[_speechStep].$2 == 'รับคำสั่งแพทย์') {
      return _wfIntroGate(_wfOrderRecvBody);
    }
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
    // หน้าย่อยฟอร์มนัด (ขั้นจำหน่าย): breadcrumb + footer ยกเลิก | บันทึก แบบหน้าย่อยวินิจฉัย
    final apptNested = cur?.data['appt'] == true && _apptEditing;
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    // กำลังพิมพ์ในช่องอยู่: รอพิมพ์เสร็จ (ออกจากช่อง) ค่อยพาไปหน้าตรวจสอบ
    // วินิจฉัย: ลงได้หลายโรค ไม่เด้งไปหน้าสรุปเองหลังลงโรคแรก (แพทย์กด "ถัดไป" เอง)
    if (complete &&
        _reviewShown != _speechStep &&
        n > 0 &&
        !_inlineTyping &&
        !_isDxStep(_speechStep)) {
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
    // HPI: ไมค์อยู่ footer แบบหน้าวินิจฉัย (การ์ดไม่มีไมค์แล้ว)
    final shellMic = cur?.type == ErUiType.form && _isPeStep(_speechStep);
    return Stack(children: [
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // หัว: ชื่อขั้น (ปุ่มหุบอยู่ล่างสุดของรายการขั้นแล้ว)
            // หน้าคำแนะนำมีชื่อขั้นพร้อมไอคอนอยู่แล้ว หัวแผงไม่ต้องซ้ำ → ไม่มีแถวหัว
            // หน้าย่อยที่มี stepper: ไม่แสดงชื่อขั้นซ้ำ (stepper + ไฮไลต์ในรางขวาบอกอยู่แล้ว)
            if (page > 0 && total <= 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                child: Text(_steps[_speechStep].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
            // หน้าคำแนะนำ (หน้าแรก) ยังไม่ต้องมี stepper · เริ่มแสดงเมื่อเข้าหน้ากรอก
            // หน้าย่อย (nested): แทน stepper ด้วย breadcrumb เส้นทาง (แตะส่วนแรก = กลับ)
            if (total > 1 && page > 0)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _dxNested ||
                        apptNested ||
                        _hpiNested ||
                        _peDrawNested ||
                        _peNoteNested
                    ? KeyedSubtree(
                        key: const ValueKey('crumb'),
                        child: _peDrawNested
                            ? _peDrawCrumb()
                            : _peNoteNested
                                ? _peNoteCrumb()
                                : _dxNested
                                    ? _dxCrumb()
                                    : _hpiNested
                                        ? _hpiCrumb()
                                        : _apptCrumb())
                    : KeyedSubtree(
                        key: const ValueKey('stepper'),
                        child: _pageStepper(seq, page)),
              ),
            // ไม่แสดงข้อความผู้ช่วยและชิปตัวเลือกคำตอบเหนือหัวข้อหน้า (ผู้ใช้สั่งเอาออก)
            // เนื้อหาของขั้น (ช่องที่ต้องกรอก / การ์ด) ใช้พื้นที่ที่เหลือทั้งหมด
            // มี key: แถวด้านบนโผล่/หาย (สถานะผู้ช่วย · ชิป · stepper) แล้วเนื้อหาไม่ถูกสร้างใหม่
            // (ถ้าสร้างใหม่ รายการที่เลื่อนไว้จะเด้งกลับบนสุด)
            Expanded(
              key: const ValueKey('wf-content'),
              child: Stack(children: [
                // แบบซักประวัติพยาบาล: เนื้อหาเลื่อนลอดใต้ปุ่ม จางบาง ๆ ช่วงปุ่ม (ไม่มีพื้นขาวรอง)
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
                          // หน้ารายการเลื่อนได้ (วินิจฉัย / ตรวจร่างกาย): ลอดใต้ปุ่มได้ เว้นท้ายในรายการเอง
                          cur?.type == ErUiType.form &&
                                  !_isDxStep(_speechStep) &&
                                  !_isPeStep(_speechStep)
                              ? _wfFootH
                              : 0.0),
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
                                    child:
                                        LayoutBuilder(builder: (context, box) {
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
                ),
                // บน: ไม่มีแถบจาง (ผู้ใช้ไม่เอาขอบฟุ้ง) เนื้อหาตัดตรงใต้ stepper
                // ล่าง: ปุ่มใหญ่ ย้อนกลับ · ไมค์ · ถัดไป ลอยทับเนื้อหา
                // พื้นกระจกแบบไม่เบลอ (blur กิน raster): ไล่ขาวโปร่ง → ทึบ + เส้นแสงขอบบน
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  // ปุ่มลอยไม่มีพื้นรอง (แบบซักประวัติพยาบาล) · ความจางมาจาก ShaderMask ของเนื้อหา
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 10.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        // หน้าย่อย: footer เป็น ย้อนกลับ | ไมค์ของช่อง | บันทึก
                        Expanded(
                          child: _dxNested ||
                                  apptNested ||
                                  _hpiNested ||
                                  _peDrawNested ||
                                  _peNoteNested
                              ? _navBtn(
                                  'ย้อนกลับ',
                                  Icons.chevron_left_rounded,
                                  () => _peNoteNested
                                      ? _peNoteCancel()
                                      : _peDrawNested
                                          ? _peDrawClose()
                                          : setState(() => _dxNested
                                              ? (() {
                                                  _dxEdit = _icdEdit = null;
                                                  _reDiagOpen = false;
                                                  _noteEdit = false;
                                                })()
                                              : _hpiNested
                                                  ? _hpiEdit = false
                                                  : _apptDraft = null),
                                  primary: false)
                              : _navBtn(
                                  'ย้อนกลับ',
                                  Icons.chevron_left_rounded,
                                  page > 0
                                      ? () => _pageGo(seq, page - 1)
                                      : null,
                                  primary: false),
                        ),
                        // ไมค์แตะเปิด/ปิด + สถานะใต้ปุ่ม
                        // หน้าการ์ด HPI / ตรวจร่างกาย: ไมค์อยู่บนหัวการ์ดแล้ว ไม่ต้องมีซ้ำด้านล่าง
                        // หน้าย่อย Diagnosis Text: ไมค์ของช่องแก้ข้อความ (แทนไมค์ผู้ช่วย)
                        // แก้รหัส ICD-10: ไม่มีช่องพิมพ์ = ไม่มีไมค์
                        if ((_dxNested && _icdEdit == null && !_reDiagOpen) ||
                            _hpiNested) ...[
                          const SizedBox(width: 10.0),
                          _dxMic(),
                        ],
                        if (!shellMic &&
                            !_dxNested &&
                            !apptNested &&
                            !_hpiNested &&
                            !_peDrawNested &&
                            !_peNoteNested) ...[
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
                        Expanded(
                            child: _peDrawNested
                                ? _navBtn('บันทึกภาพ', Icons.check_rounded,
                                    _peDraft == null ? null : _peDrawSave)
                                : _peNoteNested
                                    ? _navBtn('บันทึก', Icons.check_rounded,
                                        _peNoteSave)
                                    : apptNested
                                        ? _navBtn(
                                            'บันทึก',
                                            Icons.check_rounded,
                                            (_apptDraft?.missing.isEmpty ??
                                                    false)
                                                ? _apptSave
                                                : null)
                                        : _hpiNested
                                            ? _navBtn(
                                                'บันทึก',
                                                Icons.check_rounded,
                                                _hpiEditSave)
                                            : _dxNested && _noteEdit
                                                ? _navBtn(
                                                    'บันทึก',
                                                    Icons.check_rounded,
                                                    _noteEditSave)
                                                : _dxNested
                                                    ? _reDiagOpen
                                                        ? _navBtn(
                                                            _reDiagPicked
                                                                    .isEmpty
                                                                ? 'เพิ่ม'
                                                                : 'เพิ่ม ${_reDiagPicked.length} รายการ',
                                                            Icons.check_rounded,
                                                            _reDiagPicked
                                                                    .isEmpty
                                                                ? null
                                                                : _reDiagSave)
                                                        : _navBtn(
                                                            _icdEdit == null &&
                                                                    (_dxEdit ??
                                                                            -1) <
                                                                        0
                                                                ? 'เพิ่มรายการ'
                                                                : 'บันทึก',
                                                            Icons.check_rounded,
                                                            _icdEdit != null
                                                                ? _icdEditSave
                                                                : _dxEditSave)
                                                    : _nextBtn(
                                                        seq, page, total)),
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

/// หน้าในขั้นรับคำสั่งแพทย์ (หมวด … สรุป)
int _ordPage = 0;

/// แผง workflow แสดงหน้าแนะนำ "วาดภาพ" อยู่ (ใช้ช่อง _accPane ร่วมกับอุบัติเหตุ)
bool _drawPaneOn = false;

/// กันกดบันทึกซ้ำระหว่างเล่นแอนิเมชัน (ไม่ข้ามไปสองขั้น)
bool _wfSaving = false;

/// กรอบแผง workflow · ปุ่มบันทึก · ไอคอนขั้นที่เลือกบนรางขวา (ตำแหน่งเริ่ม/จบของแอนิเมชันบันทึก)
final GlobalKey _wfPanelKey = GlobalKey();
final GlobalKey _wfSaveBtnKey = GlobalKey();
final GlobalKey _wfSelIconKey = GlobalKey();
final GlobalKey _wfSelCellKey = GlobalKey();

Rect? _wfRectOf(GlobalKey k) {
  final b = k.currentContext?.findRenderObject() as RenderBox?;
  if (b == null || !b.hasSize) return null;
  return b.localToGlobal(Offset.zero) & b.size;
}

/// แอนิเมชันบันทึกสำเร็จ (3.4 วิ · ค้างข้อความ "บันทึกแล้ว" ~1.1 วิให้อ่าน) วาดใน Overlay:
/// 1) สีเขียวแผ่ออกจากปุ่มบันทึกจนเต็มแผง (ตัดตามมุมแผง)
/// 2) วงขาวลากเส้นรอบ → ติ๊กลากเส้น · "บันทึกแล้ว" + ชื่อขั้น (เรียบ ไม่มีประกาย)
/// 3) เขียวหดเป็นวงเล็กลอยเข้าไอคอนขั้นบนรางขวา (ที่ขึ้นเช็กแล้ว) แล้วจางหาย
class _SaveBurst extends StatefulWidget {
  const _SaveBurst(
      {required this.panel,
      this.tab,
      required this.from,
      required this.to,
      required this.base,
      required this.step,
      required this.onClose,
      required this.onEnd});

  final Rect panel;

  /// แท็บขั้นบนรางที่ต่อกับแผง (เติมเขียวพร้อมแผง)
  final Rect? tab;
  final Offset from;
  final Offset? to;
  final TextStyle base;
  final String step;

  /// เรียกครั้งเดียวตอนเขียวเริ่มหดเข้าราง (t 0.8) = หุบแผง workflow
  final VoidCallback onClose;
  final VoidCallback onEnd;

  @override
  State<_SaveBurst> createState() => _SaveBurstState();
}

class _SaveBurstState extends State<_SaveBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3400))
    ..addListener(() {
      if (!_closed && _c.value >= 0.8) {
        _closed = true;
        widget.onClose();
      }
    })
    ..forward().whenComplete(() => widget.onEnd());
  bool _closed = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _seg(double v, double a, double b,
          [Curve c = Curves.easeOutCubic]) =>
      c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final p = widget.panel;
            final label = _seg(t, 0.324, 0.438) * (1 - _seg(t, 0.765, 0.824));
            return Stack(children: [
              Positioned.fill(
                child: CustomPaint(
                    painter: _SaveTickArt(
                        t: t,
                        panel: p,
                        tab: widget.tab,
                        from: widget.from,
                        to: widget.to)),
              ),
              Positioned(
                left: p.left,
                width: p.width,
                top: p.top + p.height * 0.42 + 52.0,
                child: Opacity(
                  opacity: label,
                  child: Transform.translate(
                    offset: Offset(0.0, 8.0 * (1 - label)),
                    child: Column(children: [
                      Text('บันทึกแล้ว',
                          style: widget.base.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              decoration: TextDecoration.none)),
                      const SizedBox(height: 2.0),
                      Text(widget.step,
                          style: widget.base.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                              decoration: TextDecoration.none)),
                    ]),
                  ),
                ),
              ),
            ]);
          },
        ),
      );
}

class _SaveTickArt extends CustomPainter {
  const _SaveTickArt(
      {required this.t,
      required this.panel,
      this.tab,
      required this.from,
      this.to});

  final double t;
  final Rect panel;
  final Rect? tab;
  final Offset from;
  final Offset? to;

  static double _seg(double v, double a, double b,
          [Curve c = Curves.easeOutCubic]) =>
      c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  static const _g1 = Color(0xFF2FA352), _g2 = Color(0xFF1E8E3E);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(panel.center.dx, panel.top + panel.height * 0.42);
    final target = to ?? Offset(panel.right + 40.0, panel.top + 40.0);
    // รัศมีที่ครอบทั้งแผงเมื่อวัดจากจุด o
    final all = tab == null ? panel : panel.expandToInclude(tab!);
    double cover(Offset o) => [
          all.topLeft,
          all.topRight,
          all.bottomLeft,
          all.bottomRight
        ].map((c) => (c - o).distance).reduce(math.max);
    // พื้นที่เติมเขียว = แผง + แท็บขั้นที่ต่ออยู่ (มุมขวาโค้ง 16 แบบแท็บ)
    // รวมรูปด้วย Path.combine(union) ทั้งหมด (addPath ทิศ winding ต่างกัน = รอยต่อหักล้างเป็นเส้นขาว)
    var area = Path()
      ..addRRect(RRect.fromRectAndRadius(panel, const Radius.circular(20.0)));
    void join(Path p) => area = Path.combine(PathOperation.union, area, p);
    if (tab != null) {
      final tb = tab!;
      join(Path()
        ..addRRect(RRect.fromRectAndCorners(
            tb.inflate(0.5).translate(-1.0, 0.0),
            topRight: const Radius.circular(16.0),
            bottomRight: const Radius.circular(16.0))));
      // มุมเว้า 16 ตรงรอยต่อแผง-แท็บ (บน/ล่าง) แบบแท็บจริง ไม่เห็นเสี้ยวขาว
      const f = 16.0;
      for (final top in [true, false]) {
        // ซ้อนเข้าแท็บ 1.5 px กันเส้นขาวบางตรงรอยต่อ
        final y = top ? tb.top - f : tb.bottom - 1.5;
        final sq = Path()
          ..addRect(Rect.fromLTWH(tb.left - 1.0, y, f + 1.0, f + 1.5));
        final hole = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(tb.left + f, top ? tb.top - f : tb.bottom + f),
              radius: f));
        join(Path.combine(PathOperation.difference, sq, hole));
      }
      // มุมขวาของแผงข้างแท็บ: เติมให้ขอบแผงตรง (แผงจริงต่อกับรางขาว ไม่โค้งตรงนี้)
      join(Path()
        ..addRect(Rect.fromLTRB(
            panel.right - 20.0, panel.top, panel.right, panel.bottom)));
    }

    final spread = _seg(t, 0.0, 0.268, Curves.easeInOutCubic);
    final leave = _seg(t, 0.81, 0.956, Curves.easeInOutCubic);
    final fade = 1 - _seg(t, 0.956, 1.0);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_g1, _g2],
      ).createShader(panel.inflate(200.0));

    canvas.save();
    if (leave <= 0) {
      // 1) แผ่จากปุ่ม: วงโตจนครอบแผง ตัดตามมุมแผง
      canvas.clipPath(area);
      canvas.drawCircle(from, cover(from) * spread, paint);
    } else {
      // 3) หดเข้าไอคอนขั้นบนราง: วงเลื่อนจากกลางแผงไปเป้า + เล็กลงเหลือขนาดไอคอน
      // กรอบตัดขยายจากแผงให้ครอบเป้า (วงออกนอกแผงได้ตอนท้าย)
      final reach =
          panel.expandToInclude(Rect.fromCircle(center: target, radius: 24.0));
      canvas.clipPath(Path.combine(
          PathOperation.union,
          area,
          Path()
            ..addRRect(RRect.fromRectAndRadius(Rect.lerp(panel, reach, leave)!,
                const Radius.circular(20.0)))));
      final pos = Offset.lerp(center, target, leave)!;
      final r = cover(center) + (17.0 - cover(center)) * _seg(leave, 0.0, 0.7);
      canvas.drawCircle(pos, r, paint..color = _g1.withValues(alpha: fade));
      if (leave > 0.7) {
        // วงเล็กที่ไอคอน: ติ๊กขาวเล็ก (ต่อกับเช็กของราง) แล้วจาง
        final s = 0.45;
        final tk = Path()
          ..moveTo(pos.dx - 16.0 * s, pos.dy + 1.0 * s)
          ..lineTo(pos.dx - 4.0 * s, pos.dy + 13.0 * s)
          ..lineTo(pos.dx + 17.0 * s, pos.dy - 12.0 * s);
        canvas.drawPath(
            tk,
            Paint()
              ..color = Colors.white.withValues(alpha: fade)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
      }
    }
    canvas.restore();

    // 2) วงขาวลากเส้นรอบ + ติ๊ก (กลางแผง) · จางก่อนหด
    final mark = 1 - _seg(t, 0.75, 0.81);
    if (mark <= 0) return;
    final ring = _seg(t, 0.212, 0.394, Curves.easeInOutCubic);
    final tick = _seg(t, 0.324, 0.453, Curves.easeInOutCubic);
    const r = 34.0;
    final white = Paint()
      ..color = Colors.white.withValues(alpha: mark)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (ring > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2,
          math.pi * 2 * ring, false, white..strokeWidth = 3.5);
    }
    if (tick > 0) {
      final p = Path()
        ..moveTo(center.dx - 15.0, center.dy + 1.0)
        ..lineTo(center.dx - 4.0, center.dy + 12.0)
        ..lineTo(center.dx + 16.0, center.dy - 11.0);
      final m = p.computeMetrics().first;
      canvas.drawPath(
          m.extractPath(0.0, m.length * tick), white..strokeWidth = 5.0);
    }
  }

  @override
  bool shouldRepaint(_SaveTickArt old) => old.t != t;
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

/// แท็บขาวที่ morph จากพื้นรางหุบไปเป็นช่องที่เลือก (ต่อกับแผงที่กาง)
/// left = มุมซ้ายโค้ง (ตอนแผงยังไม่แตะ) · right = มุมขวาโค้งของแท็บ
/// fillet = มุมเว้าบน/ล่างระหว่างแท็บกับขอบแผง (วาดเป็นสีขาวล้วน ไม่มีพื้นเทาทับฉาก)
class _WfTabMorph extends CustomPainter {
  const _WfTabMorph(
      {required this.rect,
      required this.left,
      required this.right,
      required this.fillet,
      required this.maxY});
  final Rect rect;
  final double left, right, fillet, maxY;

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = _panel;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: Radius.circular(left),
            bottomLeft: Radius.circular(left),
            topRight: Radius.circular(right),
            bottomRight: Radius.circular(right)),
        white);
    final f = fillet;
    if (f < 0.5) return;
    // มุมเว้าบน: สี่เหลี่ยม f×f เหนือแท็บชิดขอบซ้าย ลบวงกลมรัศมี f ที่มุมขวาบน
    Path concave(Offset corner, Offset circle) {
      final sq = Path()
        ..addRect(Rect.fromPoints(corner,
            corner + Offset(f, 0) + Offset(0, circle.dy > corner.dy ? f : -f)));
      final c = Path()..addOval(Rect.fromCircle(center: circle, radius: f));
      return Path.combine(PathOperation.difference, sq, c);
    }

    if (rect.top - f >= 0) {
      canvas.drawPath(
          concave(rect.topLeft, Offset(rect.left + f, rect.top - f)), white);
    }
    if (rect.bottom + f <= maxY) {
      canvas.drawPath(
          concave(rect.bottomLeft, Offset(rect.left + f, rect.bottom + f)),
          white);
    }
  }

  @override
  bool shouldRepaint(_WfTabMorph o) =>
      o.rect != rect ||
      o.left != left ||
      o.right != right ||
      o.fillet != fillet;
}

/// มุมเว้าขาวระหว่างแท็บที่เลือกกับขอบแผง (top = มุมเหนือแท็บ · false = ใต้แท็บ)
class _ConcaveCorner extends CustomPainter {
  const _ConcaveCorner({required this.top});
  final bool top;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width;
    final sq = Path()..addRect(Offset.zero & size);
    final c = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(r, top ? 0.0 : size.height), radius: r));
    canvas.drawPath(
        Path.combine(PathOperation.difference, sq, c), Paint()..color = _panel);
  }

  @override
  bool shouldRepaint(_ConcaveCorner o) => o.top != top;
}

/// รางขั้น workflow ขวา: ไอคอน Phosphor (MIT) แปลงจาก SVG เป็น path 24×24 (M L C Z) · (d, ทึบ?, evenOdd?) · (Regular, Fill)
/// ไม่เลือก = Regular · เลือก = Fill · ครบ = check-circle Fill
const Map<String, (List<(String, bool, bool)>, List<(String, bool, bool)>)>
    _solarSteps = {
  'คัดกรอง': (
    [
      (
        'M23.185 11.696C23.152 11.622 22.358 9.861 20.593 8.095C18.241 5.743 15.27 4.5 12 4.5C8.73 4.5 5.759 5.743 3.407 8.095C1.642 9.861 0.844 11.625 0.815 11.696C0.772 11.792 0.75 11.896 0.75 12.001C0.75 12.106 0.772 12.21 0.815 12.306C0.847 12.38 1.642 14.14 3.407 15.906C5.759 18.257 8.73 19.5 12 19.5C15.27 19.5 18.241 18.257 20.593 15.906C22.358 14.14 23.152 12.38 23.185 12.306C23.228 12.21 23.25 12.106 23.25 12.001C23.25 11.896 23.228 11.792 23.185 11.696M12 18C9.114 18 6.593 16.951 4.507 14.883C3.65 14.031 2.922 13.06 2.344 12C2.922 10.94 3.65 9.969 4.507 9.117C6.593 7.049 9.114 6 12 6C14.886 6 17.407 7.049 19.493 9.117C20.351 9.968 21.081 10.939 21.661 12C20.985 13.262 18.04 18 12 18M12 7.5C11.11 7.5 10.24 7.764 9.5 8.258C8.76 8.753 8.183 9.456 7.843 10.278C7.502 11.1 7.413 12.005 7.586 12.878C7.76 13.751 8.189 14.553 8.818 15.182C9.447 15.811 10.249 16.24 11.122 16.414C11.995 16.587 12.9 16.498 13.722 16.157C14.544 15.817 15.247 15.24 15.742 14.5C16.236 13.76 16.5 12.89 16.5 12C16.499 11.21 16.291 10.435 15.896 9.751C15.501 9.067 14.933 8.499 14.249 8.104C13.565 7.709 12.79 7.501 12 7.5M12 15C11.407 15 10.827 14.824 10.333 14.494C9.84 14.165 9.455 13.696 9.228 13.148C9.001 12.6 8.942 11.997 9.058 11.415C9.173 10.833 9.459 10.298 9.879 9.879C10.298 9.459 10.833 9.173 11.415 9.058C11.997 8.942 12.6 9.001 13.148 9.228C13.696 9.455 14.165 9.84 14.494 10.333C14.824 10.827 15 11.407 15 12C15 12.527 14.861 13.044 14.598 13.5C14.335 13.956 13.956 14.335 13.5 14.598C13.044 14.861 12.527 15 12 15',
        true,
        false
      )
    ],
    [
      (
        'M23.185 11.696C23.152 11.622 22.358 9.861 20.593 8.095C18.241 5.743 15.27 4.5 12 4.5C8.73 4.5 5.759 5.743 3.407 8.095C1.642 9.861 0.844 11.625 0.815 11.696C0.772 11.792 0.75 11.896 0.75 12.001C0.75 12.106 0.772 12.21 0.815 12.306C0.847 12.38 1.642 14.14 3.407 15.906C5.759 18.257 8.73 19.5 12 19.5C15.27 19.5 18.241 18.257 20.593 15.906C22.358 14.14 23.152 12.38 23.185 12.306C23.228 12.21 23.25 12.106 23.25 12.001C23.25 11.896 23.228 11.792 23.185 11.696M12 15.75C11.258 15.75 10.533 15.53 9.917 15.118C9.3 14.706 8.819 14.12 8.535 13.435C8.252 12.75 8.177 11.996 8.322 11.268C8.467 10.541 8.824 9.873 9.348 9.348C9.873 8.824 10.541 8.467 11.268 8.322C11.996 8.177 12.75 8.252 13.435 8.535C14.12 8.819 14.706 9.3 15.118 9.917C15.53 10.533 15.75 11.258 15.75 12C15.75 12.658 15.577 13.305 15.248 13.875C14.918 14.445 14.445 14.918 13.875 15.248C13.305 15.577 12.658 15.75 12 15.75',
        true,
        false
      )
    ]
  ),
  'ประวัติ HPI': (
    [
      (
        'M17.25 10.5C17.25 10.632 17.215 10.761 17.15 10.875C17.084 10.989 16.989 11.084 16.875 11.15C16.761 11.215 16.632 11.25 16.5 11.25L10.5 11.25C10.342 11.25 10.187 11.2 10.059 11.107C9.931 11.014 9.836 10.882 9.787 10.732C9.738 10.581 9.738 10.419 9.787 10.268C9.836 10.118 9.931 9.986 10.059 9.893C10.187 9.8 10.342 9.75 10.5 9.75L16.5 9.75C16.632 9.75 16.761 9.785 16.875 9.85C16.989 9.916 17.084 10.011 17.15 10.125C17.215 10.239 17.25 10.368 17.25 10.5M16.5 12.75L10.5 12.75C10.342 12.75 10.187 12.8 10.059 12.893C9.931 12.986 9.836 13.118 9.787 13.268C9.738 13.419 9.738 13.581 9.787 13.732C9.836 13.882 9.931 14.014 10.059 14.107C10.187 14.2 10.342 14.25 10.5 14.25L16.5 14.25C16.658 14.25 16.813 14.2 16.941 14.107C17.069 14.014 17.164 13.882 17.213 13.732C17.262 13.581 17.262 13.419 17.213 13.268C17.164 13.118 17.069 12.986 16.941 12.893C16.813 12.8 16.658 12.75 16.5 12.75M21 4.5L21 19.5C21 19.763 20.931 20.022 20.799 20.25C20.667 20.478 20.478 20.667 20.25 20.799C20.022 20.931 19.763 21 19.5 21L4.5 21C4.237 21 3.978 20.931 3.75 20.799C3.522 20.667 3.333 20.478 3.201 20.25C3.069 20.022 3 19.763 3 19.5L3 4.5C3 4.237 3.069 3.978 3.201 3.75C3.333 3.522 3.522 3.333 3.75 3.201C3.978 3.069 4.237 3 4.5 3L19.5 3C19.763 3 20.022 3.069 20.25 3.201C20.478 3.333 20.667 3.522 20.799 3.75C20.931 3.978 21 4.237 21 4.5M4.5 19.5L6.75 19.5L6.75 4.5L4.5 4.5ZM19.5 19.5L19.5 4.5L8.25 4.5L8.25 19.5Z',
        true,
        false
      )
    ],
    [
      (
        'M19.5 3L4.5 3C4.237 3 3.978 3.069 3.75 3.201C3.522 3.333 3.333 3.522 3.201 3.75C3.069 3.978 3 4.237 3 4.5L3 19.5C3 19.763 3.069 20.022 3.201 20.25C3.333 20.478 3.522 20.667 3.75 20.799C3.978 20.931 4.237 21 4.5 21L19.5 21C19.763 21 20.022 20.931 20.25 20.799C20.478 20.667 20.667 20.478 20.799 20.25C20.931 20.022 21 19.763 21 19.5L21 4.5C21 4.237 20.931 3.978 20.799 3.75C20.667 3.522 20.478 3.333 20.25 3.201C20.022 3.069 19.763 3 19.5 3M7.5 19.5L4.5 19.5L4.5 4.5L7.5 4.5ZM16.5 14.25L10.5 14.25C10.342 14.25 10.187 14.2 10.059 14.107C9.931 14.014 9.836 13.882 9.787 13.732C9.738 13.581 9.738 13.419 9.787 13.268C9.836 13.118 9.931 12.986 10.059 12.893C10.187 12.8 10.342 12.75 10.5 12.75L16.5 12.75C16.658 12.75 16.813 12.8 16.941 12.893C17.069 12.986 17.164 13.118 17.213 13.268C17.262 13.419 17.262 13.581 17.213 13.732C17.164 13.882 17.069 14.014 16.941 14.107C16.813 14.2 16.658 14.25 16.5 14.25M16.5 11.25L10.5 11.25C10.342 11.25 10.187 11.2 10.059 11.107C9.931 11.014 9.836 10.882 9.787 10.732C9.738 10.581 9.738 10.419 9.787 10.268C9.836 10.118 9.931 9.986 10.059 9.893C10.187 9.8 10.342 9.75 10.5 9.75L16.5 9.75C16.658 9.75 16.813 9.8 16.941 9.893C17.069 9.986 17.164 10.118 17.213 10.268C17.262 10.419 17.262 10.581 17.213 10.732C17.164 10.882 17.069 11.014 16.941 11.107C16.813 11.2 16.658 11.25 16.5 11.25',
        true,
        false
      )
    ]
  ),
  'ตรวจร่างกาย': (
    [
      (
        'M15 3.75C15 3.157 14.824 2.577 14.494 2.083C14.165 1.59 13.696 1.205 13.148 0.978C12.6 0.751 11.997 0.692 11.415 0.808C10.833 0.923 10.298 1.209 9.879 1.629C9.459 2.048 9.173 2.583 9.058 3.165C8.942 3.747 9.001 4.35 9.228 4.898C9.455 5.446 9.84 5.915 10.333 6.244C10.827 6.574 11.407 6.75 12 6.75C12.527 6.75 13.044 6.611 13.5 6.348C13.956 6.085 14.335 5.706 14.598 5.25C14.861 4.794 15 4.277 15 3.75M12 5.25C11.703 5.25 11.413 5.162 11.167 4.997C10.92 4.832 10.728 4.598 10.614 4.324C10.501 4.05 10.471 3.748 10.529 3.457C10.587 3.166 10.73 2.899 10.939 2.689C11.149 2.48 11.416 2.337 11.707 2.279C11.998 2.221 12.3 2.251 12.574 2.364C12.848 2.478 13.082 2.67 13.247 2.917C13.412 3.163 13.5 3.453 13.5 3.75C13.5 4.013 13.431 4.272 13.299 4.5C13.167 4.728 12.978 4.917 12.75 5.049C12.522 5.181 12.263 5.25 12 5.25M21.703 8.223C21.647 7.944 21.526 7.683 21.352 7.459C21.177 7.235 20.953 7.054 20.696 6.931C20.44 6.808 20.159 6.746 19.875 6.75L4.125 6.75C3.784 6.75 3.45 6.843 3.158 7.019C2.866 7.194 2.627 7.446 2.468 7.747C2.309 8.048 2.234 8.387 2.253 8.728C2.271 9.068 2.382 9.397 2.574 9.678C2.765 9.96 3.03 10.185 3.339 10.328L3.352 10.328L8.109 12.423L6.141 19.897C5.977 20.258 5.931 20.662 6.011 21.051C6.091 21.439 6.291 21.793 6.584 22.06C6.877 22.328 7.247 22.496 7.642 22.54C8.036 22.585 8.434 22.503 8.779 22.307C9.124 22.111 9.398 21.811 9.562 21.45L12 17.243L14.438 21.45C14.61 21.796 14.885 22.08 15.226 22.264C15.566 22.447 15.955 22.521 16.338 22.475C16.722 22.429 17.083 22.266 17.37 22.007C17.657 21.748 17.858 21.407 17.944 21.03C18.029 20.653 17.997 20.259 17.85 19.901L15.881 12.428L20.639 10.332L20.651 10.332C20.913 10.217 21.144 10.043 21.326 9.824C21.509 9.605 21.638 9.346 21.704 9.068C21.769 8.79 21.769 8.501 21.703 8.223M20.034 8.963L14.697 11.313C14.589 11.361 14.493 11.433 14.419 11.525C14.344 11.617 14.292 11.725 14.267 11.84C14.242 11.956 14.244 12.076 14.274 12.19L16.418 20.344C16.429 20.387 16.445 20.43 16.464 20.47C16.496 20.538 16.507 20.613 16.495 20.686C16.484 20.76 16.451 20.828 16.401 20.883C16.351 20.937 16.285 20.976 16.213 20.994C16.141 21.011 16.065 21.007 15.996 20.981C15.949 20.964 15.907 20.938 15.871 20.905C15.835 20.872 15.805 20.832 15.785 20.787C15.775 20.767 15.765 20.747 15.753 20.728L12.649 15.375C12.583 15.261 12.488 15.167 12.374 15.101C12.26 15.036 12.131 15.001 12 15.001C11.869 15.001 11.74 15.036 11.626 15.101C11.512 15.167 11.417 15.261 11.351 15.375L8.25 20.723C8.238 20.742 8.228 20.762 8.218 20.782C8.197 20.827 8.168 20.867 8.132 20.9C8.096 20.934 8.053 20.96 8.007 20.977C7.937 21.002 7.862 21.006 7.79 20.989C7.717 20.971 7.652 20.933 7.602 20.878C7.552 20.823 7.519 20.755 7.507 20.681C7.496 20.608 7.507 20.533 7.538 20.466C7.558 20.425 7.573 20.383 7.584 20.339L9.726 12.188C9.756 12.073 9.758 11.953 9.733 11.837C9.708 11.722 9.656 11.614 9.581 11.522C9.507 11.43 9.411 11.358 9.303 11.31L3.966 8.963C3.905 8.934 3.852 8.889 3.815 8.833C3.777 8.777 3.756 8.711 3.753 8.643C3.749 8.576 3.764 8.509 3.796 8.449C3.828 8.389 3.875 8.339 3.933 8.304C3.991 8.269 4.057 8.25 4.125 8.25L19.875 8.25C19.943 8.25 20.009 8.268 20.068 8.303C20.126 8.338 20.174 8.388 20.206 8.447C20.238 8.507 20.253 8.575 20.25 8.642C20.247 8.71 20.226 8.776 20.188 8.832C20.151 8.889 20.098 8.934 20.037 8.963Z',
        true,
        false
      )
    ],
    [
      (
        'M9.375 3.375C9.375 2.856 9.529 2.348 9.817 1.917C10.106 1.485 10.516 1.148 10.995 0.95C11.475 0.751 12.003 0.699 12.512 0.8C13.021 0.902 13.489 1.152 13.856 1.519C14.223 1.886 14.473 2.354 14.575 2.863C14.676 3.372 14.624 3.9 14.425 4.38C14.227 4.859 13.89 5.269 13.458 5.558C13.027 5.846 12.519 6 12 6C11.539 6 11.087 5.879 10.688 5.648C10.288 5.418 9.957 5.087 9.727 4.688C9.496 4.288 9.375 3.836 9.375 3.375M21.337 8.678C21.292 8.456 21.196 8.246 21.056 8.067C20.916 7.888 20.737 7.743 20.532 7.645C20.327 7.546 20.102 7.497 19.875 7.5L4.125 7.5C3.852 7.5 3.585 7.574 3.351 7.715C3.118 7.855 2.927 8.057 2.799 8.298C2.672 8.539 2.612 8.81 2.627 9.082C2.642 9.355 2.731 9.618 2.884 9.843C3.037 10.069 3.249 10.248 3.497 10.362L3.502 10.362L8.555 12.587L6.5 20.396C6.396 20.634 6.355 20.894 6.382 21.152C6.409 21.41 6.502 21.656 6.652 21.867C6.803 22.078 7.005 22.247 7.24 22.357C7.439 22.451 7.655 22.5 7.875 22.5C8.158 22.5 8.435 22.421 8.674 22.271C8.914 22.12 9.106 21.905 9.229 21.651L12 16.875L14.773 21.656C14.91 21.936 15.131 22.165 15.405 22.314C15.679 22.462 15.992 22.521 16.301 22.483C16.61 22.446 16.9 22.313 17.13 22.103C17.36 21.893 17.519 21.617 17.585 21.313C17.651 21.008 17.621 20.691 17.498 20.405L15.443 12.595L20.506 10.368C20.714 10.275 20.898 10.135 21.043 9.959C21.188 9.783 21.29 9.576 21.341 9.353C21.392 9.131 21.391 8.9 21.337 8.678',
        true,
        false
      )
    ]
  ),
  // Figma 479:135 พลาสเตอร์ปิดแผล (รูปเดียวกันทั้งปกติ/เลือก)
  'หัตถการ': (
    [
      (
        'M17.235 2.004C17.248 2.003 17.262 2.003 17.276 2.002C18.515 1.962 19.693 2.452 20.585 3.318C21.78 4.479 22.232 6.181 21.848 7.794C21.662 8.57 21.25 9.383 20.682 9.953C19.89 10.747 19.087 11.536 18.292 12.329L13.114 17.478L10.793 19.792C10.351 20.231 9.767 20.861 9.273 21.198C8.532 21.697 7.664 21.975 6.772 22C6.597 22.002 6.448 21.99 6.276 21.975C2.523 21.627 0.647 17.073 3.177 14.223C3.446 13.921 3.765 13.628 4.052 13.342L5.667 11.734L10.407 7.007L13.104 4.315C13.906 3.514 14.578 2.691 15.68 2.298C16.254 2.094 16.639 2.028 17.235 2.004ZM6.954 21.222C7.666 21.184 8.351 20.94 8.927 20.521C9.369 20.198 9.936 19.576 10.34 19.182L13.481 16.068L18.055 11.503L19.477 10.088C19.726 9.842 20.039 9.557 20.269 9.295C21.49 7.906 21.548 5.621 20.351 4.197C19.491 3.175 18.383 2.664 17.042 2.765L17.021 2.766C16.345 2.83 15.713 3.02 15.151 3.417C14.811 3.656 14.517 3.977 14.222 4.271L13.115 5.376L9.277 9.205C8.116 10.373 6.948 11.535 5.775 12.692L4.441 14.011C4.309 14.141 4.162 14.297 4.026 14.423C1.524 16.746 3.012 20.946 6.379 21.223C6.578 21.239 6.754 21.243 6.954 21.222Z',
        true,
        false
      ),
      (
        'M12.163 7.789C12.481 7.737 12.908 7.861 13.171 8.04C13.329 8.148 13.559 8.403 13.698 8.545L14.412 9.257L15.322 10.164C15.746 10.584 16.154 10.886 16.261 11.503C16.328 11.89 16.237 12.287 16.009 12.606C15.909 12.746 15.537 13.1 15.4 13.238L14.057 14.567L13.151 15.466C12.744 15.869 12.521 16.166 11.932 16.265C11.07 16.341 10.726 15.864 10.174 15.307L9.151 14.275L8.472 13.587C8.154 13.263 7.925 13.065 7.837 12.602C7.771 12.257 7.815 11.766 8.028 11.478C8.209 11.231 8.498 10.972 8.716 10.755L9.83 9.646L10.847 8.629C11.313 8.163 11.484 7.903 12.163 7.789ZM11.799 15.563C11.893 15.55 12.02 15.539 12.09 15.475C12.264 15.316 12.437 15.139 12.603 14.973L13.642 13.939L14.85 12.749C15.046 12.556 15.273 12.346 15.452 12.14C15.557 12.02 15.585 11.813 15.56 11.655C15.541 11.534 15.492 11.419 15.417 11.322C15.312 11.186 15.131 11.02 15.004 10.893L14.291 10.179L13.313 9.199C13.061 8.947 12.688 8.46 12.304 8.499C11.841 8.556 11.617 8.889 11.304 9.204L10.317 10.187L9.186 11.312C9.005 11.491 8.813 11.669 8.64 11.861C8.475 12.044 8.467 12.476 8.612 12.676C8.745 12.835 8.935 13.013 9.086 13.164L9.995 14.074L10.907 14.996C11.21 15.302 11.34 15.544 11.799 15.563Z',
        true,
        false
      ),
      (
        'M16.679 4.44C16.972 4.396 17.245 4.598 17.289 4.891C17.332 5.184 17.129 5.457 16.836 5.499C16.544 5.541 16.273 5.34 16.229 5.048C16.186 4.756 16.387 4.484 16.679 4.44Z',
        true,
        false
      ),
      (
        'M7.117 18.227C7.306 18.191 7.5 18.26 7.624 18.407C7.749 18.554 7.785 18.756 7.719 18.937C7.652 19.118 7.494 19.249 7.304 19.281C7.015 19.33 6.74 19.136 6.689 18.847C6.637 18.558 6.828 18.281 7.117 18.227Z',
        true,
        false
      ),
      (
        'M16.968 8.288C17.254 8.223 17.539 8.401 17.605 8.686C17.671 8.972 17.494 9.257 17.208 9.324C16.922 9.391 16.636 9.213 16.569 8.926C16.503 8.64 16.682 8.354 16.968 8.288Z',
        true,
        false
      ),
      (
        'M6.773 14.419C6.959 14.375 7.155 14.435 7.285 14.576C7.415 14.717 7.459 14.916 7.4 15.099C7.342 15.281 7.189 15.418 7.002 15.457C6.717 15.515 6.438 15.334 6.375 15.05C6.313 14.766 6.49 14.485 6.773 14.419Z',
        true,
        false
      ),
      (
        'M5.107 16.133C5.296 16.096 5.491 16.164 5.616 16.312C5.741 16.46 5.775 16.664 5.706 16.845C5.636 17.025 5.474 17.154 5.283 17.18C4.998 17.22 4.733 17.026 4.686 16.743C4.638 16.459 4.824 16.189 5.107 16.133Z',
        true,
        false
      ),
      (
        'M8.79 16.508C9.078 16.449 9.359 16.633 9.418 16.921C9.478 17.209 9.293 17.49 9.005 17.549C8.718 17.608 8.437 17.423 8.378 17.136C8.319 16.849 8.503 16.568 8.79 16.508Z',
        true,
        false
      ),
      (
        'M14.97 6.19C15.258 6.134 15.538 6.323 15.593 6.612C15.648 6.901 15.457 7.18 15.167 7.234C14.88 7.287 14.603 7.098 14.549 6.81C14.494 6.523 14.682 6.246 14.97 6.19Z',
        true,
        false
      ),
      (
        'M18.681 6.563C18.971 6.516 19.245 6.715 19.29 7.006C19.334 7.297 19.133 7.569 18.841 7.611C18.553 7.653 18.285 7.455 18.241 7.167C18.197 6.879 18.393 6.61 18.681 6.563Z',
        true,
        false
      )
    ],
    [
      (
        'M17.235 2.004C17.248 2.003 17.262 2.003 17.276 2.002C18.515 1.962 19.693 2.452 20.585 3.318C21.78 4.479 22.232 6.181 21.848 7.794C21.662 8.57 21.25 9.383 20.682 9.953C19.89 10.747 19.087 11.536 18.292 12.329L13.114 17.478L10.793 19.792C10.351 20.231 9.767 20.861 9.273 21.198C8.532 21.697 7.664 21.975 6.772 22C6.597 22.002 6.448 21.99 6.276 21.975C2.523 21.627 0.647 17.073 3.177 14.223C3.446 13.921 3.765 13.628 4.052 13.342L5.667 11.734L10.407 7.007L13.104 4.315C13.906 3.514 14.578 2.691 15.68 2.298C16.254 2.094 16.639 2.028 17.235 2.004ZM6.954 21.222C7.666 21.184 8.351 20.94 8.927 20.521C9.369 20.198 9.936 19.576 10.34 19.182L13.481 16.068L18.055 11.503L19.477 10.088C19.726 9.842 20.039 9.557 20.269 9.295C21.49 7.906 21.548 5.621 20.351 4.197C19.491 3.175 18.383 2.664 17.042 2.765L17.021 2.766C16.345 2.83 15.713 3.02 15.151 3.417C14.811 3.656 14.517 3.977 14.222 4.271L13.115 5.376L9.277 9.205C8.116 10.373 6.948 11.535 5.775 12.692L4.441 14.011C4.309 14.141 4.162 14.297 4.026 14.423C1.524 16.746 3.012 20.946 6.379 21.223C6.578 21.239 6.754 21.243 6.954 21.222Z',
        true,
        false
      ),
      (
        'M12.163 7.789C12.481 7.737 12.908 7.861 13.171 8.04C13.329 8.148 13.559 8.403 13.698 8.545L14.412 9.257L15.322 10.164C15.746 10.584 16.154 10.886 16.261 11.503C16.328 11.89 16.237 12.287 16.009 12.606C15.909 12.746 15.537 13.1 15.4 13.238L14.057 14.567L13.151 15.466C12.744 15.869 12.521 16.166 11.932 16.265C11.07 16.341 10.726 15.864 10.174 15.307L9.151 14.275L8.472 13.587C8.154 13.263 7.925 13.065 7.837 12.602C7.771 12.257 7.815 11.766 8.028 11.478C8.209 11.231 8.498 10.972 8.716 10.755L9.83 9.646L10.847 8.629C11.313 8.163 11.484 7.903 12.163 7.789ZM11.799 15.563C11.893 15.55 12.02 15.539 12.09 15.475C12.264 15.316 12.437 15.139 12.603 14.973L13.642 13.939L14.85 12.749C15.046 12.556 15.273 12.346 15.452 12.14C15.557 12.02 15.585 11.813 15.56 11.655C15.541 11.534 15.492 11.419 15.417 11.322C15.312 11.186 15.131 11.02 15.004 10.893L14.291 10.179L13.313 9.199C13.061 8.947 12.688 8.46 12.304 8.499C11.841 8.556 11.617 8.889 11.304 9.204L10.317 10.187L9.186 11.312C9.005 11.491 8.813 11.669 8.64 11.861C8.475 12.044 8.467 12.476 8.612 12.676C8.745 12.835 8.935 13.013 9.086 13.164L9.995 14.074L10.907 14.996C11.21 15.302 11.34 15.544 11.799 15.563Z',
        true,
        false
      ),
      (
        'M16.679 4.44C16.972 4.396 17.245 4.598 17.289 4.891C17.332 5.184 17.129 5.457 16.836 5.499C16.544 5.541 16.273 5.34 16.229 5.048C16.186 4.756 16.387 4.484 16.679 4.44Z',
        true,
        false
      ),
      (
        'M7.117 18.227C7.306 18.191 7.5 18.26 7.624 18.407C7.749 18.554 7.785 18.756 7.719 18.937C7.652 19.118 7.494 19.249 7.304 19.281C7.015 19.33 6.74 19.136 6.689 18.847C6.637 18.558 6.828 18.281 7.117 18.227Z',
        true,
        false
      ),
      (
        'M16.968 8.288C17.254 8.223 17.539 8.401 17.605 8.686C17.671 8.972 17.494 9.257 17.208 9.324C16.922 9.391 16.636 9.213 16.569 8.926C16.503 8.64 16.682 8.354 16.968 8.288Z',
        true,
        false
      ),
      (
        'M6.773 14.419C6.959 14.375 7.155 14.435 7.285 14.576C7.415 14.717 7.459 14.916 7.4 15.099C7.342 15.281 7.189 15.418 7.002 15.457C6.717 15.515 6.438 15.334 6.375 15.05C6.313 14.766 6.49 14.485 6.773 14.419Z',
        true,
        false
      ),
      (
        'M5.107 16.133C5.296 16.096 5.491 16.164 5.616 16.312C5.741 16.46 5.775 16.664 5.706 16.845C5.636 17.025 5.474 17.154 5.283 17.18C4.998 17.22 4.733 17.026 4.686 16.743C4.638 16.459 4.824 16.189 5.107 16.133Z',
        true,
        false
      ),
      (
        'M8.79 16.508C9.078 16.449 9.359 16.633 9.418 16.921C9.478 17.209 9.293 17.49 9.005 17.549C8.718 17.608 8.437 17.423 8.378 17.136C8.319 16.849 8.503 16.568 8.79 16.508Z',
        true,
        false
      ),
      (
        'M14.97 6.19C15.258 6.134 15.538 6.323 15.593 6.612C15.648 6.901 15.457 7.18 15.167 7.234C14.88 7.287 14.603 7.098 14.549 6.81C14.494 6.523 14.682 6.246 14.97 6.19Z',
        true,
        false
      ),
      (
        'M18.681 6.563C18.971 6.516 19.245 6.715 19.29 7.006C19.334 7.297 19.133 7.569 18.841 7.611C18.553 7.653 18.285 7.455 18.241 7.167C18.197 6.879 18.393 6.61 18.681 6.563Z',
        true,
        false
      )
    ]
  ),
  // Phosphor stethoscope (เลือก = Bold)
  'วินิจฉัย': (
    [
      (
        'M20.625 15C20.625 15.222 20.559 15.44 20.435 15.625C20.312 15.81 20.136 15.954 19.931 16.039C19.725 16.125 19.499 16.147 19.281 16.103C19.062 16.06 18.862 15.953 18.705 15.795C18.547 15.638 18.44 15.438 18.397 15.219C18.353 15.001 18.375 14.775 18.461 14.569C18.546 14.364 18.69 14.188 18.875 14.065C19.06 13.941 19.278 13.875 19.5 13.875C19.697 13.875 19.891 13.927 20.062 14.026C20.234 14.124 20.376 14.266 20.474 14.438C20.573 14.609 20.625 14.803 20.625 15M20.198 18.683C20.089 19.387 19.815 20.055 19.398 20.633C18.98 21.21 18.432 21.68 17.798 22.005C17.164 22.329 16.462 22.499 15.75 22.5L13.5 22.5C12.71 22.499 11.935 22.291 11.251 21.896C10.567 21.501 9.999 20.933 9.604 20.249C9.209 19.565 9.001 18.79 9 18L9 14.202C8.039 14.081 7.122 13.729 6.327 13.177C5.532 12.625 4.882 11.888 4.433 11.03C3.985 10.172 3.75 9.218 3.75 8.25L3.75 3.75C3.75 3.618 3.785 3.489 3.85 3.375C3.916 3.261 4.011 3.166 4.125 3.1C4.239 3.035 4.368 3 4.5 3L6.75 3C6.908 3 7.063 3.05 7.191 3.143C7.319 3.236 7.414 3.368 7.463 3.518C7.512 3.669 7.512 3.831 7.463 3.982C7.414 4.132 7.319 4.264 7.191 4.357C7.063 4.45 6.908 4.5 6.75 4.5L5.25 4.5L5.25 8.25C5.25 9.047 5.461 9.829 5.863 10.517C6.264 11.206 6.841 11.775 7.535 12.167C8.228 12.56 9.013 12.761 9.81 12.75C12.258 12.718 14.25 10.664 14.25 8.172L14.25 4.5L12.75 4.5C12.592 4.5 12.437 4.45 12.309 4.357C12.181 4.264 12.086 4.132 12.037 3.982C11.988 3.831 11.988 3.669 12.037 3.518C12.086 3.368 12.181 3.236 12.309 3.143C12.437 3.05 12.592 3 12.75 3L15 3C15.132 3 15.261 3.035 15.375 3.1C15.489 3.166 15.584 3.261 15.65 3.375C15.715 3.489 15.75 3.618 15.75 3.75L15.75 8.172C15.75 11.251 13.45 13.824 10.5 14.201L10.5 18C10.5 18.527 10.639 19.044 10.902 19.5C11.165 19.956 11.544 20.335 12 20.598C12.456 20.861 12.973 21 13.5 21L15.75 21C16.202 20.999 16.648 20.897 17.054 20.7C17.461 20.503 17.818 20.217 18.099 19.863C18.38 19.51 18.577 19.097 18.677 18.656C17.955 18.494 17.298 18.122 16.787 17.587C16.276 17.053 15.935 16.378 15.806 15.65C15.677 14.922 15.767 14.171 16.063 13.494C16.36 12.816 16.85 12.242 17.473 11.842C18.095 11.442 18.822 11.236 19.561 11.248C20.301 11.26 21.02 11.491 21.629 11.911C22.237 12.331 22.708 12.922 22.982 13.609C23.256 14.296 23.321 15.049 23.168 15.773C23.015 16.496 22.651 17.159 22.123 17.676C21.595 18.194 20.925 18.544 20.198 18.682ZM21.75 15C21.75 14.555 21.618 14.12 21.371 13.75C21.124 13.38 20.772 13.092 20.361 12.921C19.95 12.751 19.497 12.706 19.061 12.793C18.625 12.88 18.224 13.094 17.909 13.409C17.594 13.724 17.38 14.125 17.293 14.561C17.206 14.997 17.251 15.45 17.421 15.861C17.592 16.272 17.88 16.624 18.25 16.871C18.62 17.118 19.055 17.25 19.5 17.25C19.895 17.25 20.283 17.146 20.625 16.949C20.967 16.751 21.251 16.467 21.449 16.125C21.646 15.783 21.75 15.395 21.75 15',
        true,
        false
      )
    ],
    [
      (
        'M23.25 15C23.25 14.209 23 13.439 22.537 12.799C22.073 12.159 21.418 11.681 20.667 11.435C19.916 11.189 19.106 11.187 18.353 11.429C17.6 11.671 16.943 12.144 16.476 12.782C16.008 13.419 15.754 14.189 15.75 14.979C15.746 15.77 15.992 16.541 16.452 17.184C16.913 17.826 17.565 18.307 18.315 18.557C18.231 18.945 18.059 19.31 17.814 19.622C17.568 19.935 17.255 20.187 16.897 20.361C16.54 20.535 16.147 20.625 15.75 20.625L13.5 20.625C13.039 20.625 12.587 20.504 12.188 20.273C11.788 20.043 11.457 19.712 11.227 19.312C10.996 18.913 10.875 18.461 10.875 18L10.875 14.522C13.85 13.98 16.125 11.326 16.125 8.172L16.125 3.75C16.125 3.553 16.073 3.359 15.974 3.188C15.876 3.016 15.734 2.874 15.562 2.776C15.391 2.677 15.197 2.625 15 2.625L12.75 2.625C12.512 2.625 12.281 2.7 12.089 2.84C11.897 2.979 11.753 3.176 11.68 3.402C11.607 3.628 11.607 3.872 11.68 4.098C11.753 4.324 11.897 4.521 12.089 4.66C12.281 4.8 12.512 4.875 12.75 4.875L13.875 4.875L13.875 8.172C13.875 10.46 12.05 12.346 9.805 12.375C9.075 12.385 8.355 12.2 7.719 11.841C7.084 11.481 6.555 10.959 6.187 10.329C5.819 9.698 5.625 8.98 5.625 8.25L5.625 4.875L6.75 4.875C6.988 4.875 7.219 4.8 7.411 4.66C7.603 4.521 7.747 4.324 7.82 4.098C7.893 3.872 7.893 3.628 7.82 3.402C7.747 3.176 7.603 2.979 7.411 2.84C7.219 2.7 6.988 2.625 6.75 2.625L4.5 2.625C4.303 2.625 4.109 2.677 3.938 2.776C3.766 2.874 3.624 3.016 3.526 3.187C3.427 3.359 3.375 3.553 3.375 3.75L3.375 8.25C3.375 9.241 3.606 10.219 4.05 11.106C4.495 11.992 5.139 12.763 5.933 13.356C6.727 13.95 7.649 14.35 8.625 14.525L8.625 18C8.626 18.855 8.852 19.696 9.28 20.436C9.708 21.177 10.323 21.792 11.064 22.22C11.804 22.648 12.645 22.874 13.5 22.875L15.75 22.875C16.539 22.874 17.316 22.682 18.014 22.315C18.712 21.948 19.311 21.418 19.76 20.769C20.208 20.12 20.492 19.372 20.588 18.589C21.099 18.433 21.57 18.171 21.971 17.818C22.372 17.466 22.694 17.033 22.914 16.547C23.135 16.061 23.249 15.534 23.25 15M19.5 16.5C19.203 16.5 18.913 16.412 18.667 16.247C18.42 16.082 18.228 15.848 18.114 15.574C18.001 15.3 17.971 14.998 18.029 14.707C18.087 14.416 18.23 14.149 18.439 13.939C18.649 13.73 18.916 13.587 19.207 13.529C19.498 13.471 19.8 13.501 20.074 13.614C20.348 13.728 20.582 13.92 20.747 14.167C20.912 14.413 21 14.703 21 15C21 15.263 20.931 15.522 20.799 15.75C20.667 15.978 20.478 16.167 20.25 16.299C20.022 16.431 19.763 16.5 19.5 16.5',
        true,
        false
      )
    ]
  ),
  // Phosphor list-plus (เลือก = Bold เส้นหนา ไม่ใช่ Fill กล่องทึบ)
  'สั่งการรักษา': (
    [
      (
        'M3 6C3 5.868 3.035 5.739 3.1 5.625C3.166 5.511 3.261 5.416 3.375 5.35C3.489 5.285 3.618 5.25 3.75 5.25L20.25 5.25C20.408 5.25 20.563 5.3 20.691 5.393C20.819 5.486 20.914 5.618 20.963 5.768C21.012 5.919 21.012 6.081 20.963 6.232C20.914 6.382 20.819 6.514 20.691 6.607C20.563 6.7 20.408 6.75 20.25 6.75L3.75 6.75C3.618 6.75 3.489 6.715 3.375 6.65C3.261 6.584 3.166 6.489 3.1 6.375C3.035 6.261 3 6.132 3 6M3.75 12.75L20.25 12.75C20.408 12.75 20.563 12.7 20.691 12.607C20.819 12.514 20.914 12.382 20.963 12.232C21.012 12.081 21.012 11.919 20.963 11.768C20.914 11.618 20.819 11.486 20.691 11.393C20.563 11.3 20.408 11.25 20.25 11.25L3.75 11.25C3.592 11.25 3.437 11.3 3.309 11.393C3.181 11.486 3.086 11.618 3.037 11.768C2.988 11.919 2.988 12.081 3.037 12.232C3.086 12.382 3.181 12.514 3.309 12.607C3.437 12.7 3.592 12.75 3.75 12.75M13.5 17.25L3.75 17.25C3.592 17.25 3.437 17.3 3.309 17.393C3.181 17.486 3.086 17.618 3.037 17.768C2.988 17.919 2.988 18.081 3.037 18.232C3.086 18.382 3.181 18.514 3.309 18.607C3.437 18.7 3.592 18.75 3.75 18.75L13.5 18.75C13.658 18.75 13.813 18.7 13.941 18.607C14.069 18.514 14.164 18.382 14.213 18.232C14.262 18.081 14.262 17.919 14.213 17.768C14.164 17.618 14.069 17.486 13.941 17.393C13.813 17.3 13.658 17.25 13.5 17.25M21.75 17.25L20.25 17.25L20.25 15.75C20.25 15.592 20.2 15.437 20.107 15.309C20.014 15.181 19.882 15.086 19.732 15.037C19.581 14.988 19.419 14.988 19.268 15.037C19.118 15.086 18.986 15.181 18.893 15.309C18.8 15.437 18.75 15.592 18.75 15.75L18.75 17.25L17.25 17.25C17.092 17.25 16.937 17.3 16.809 17.393C16.681 17.486 16.586 17.618 16.537 17.768C16.488 17.919 16.488 18.081 16.537 18.232C16.586 18.382 16.681 18.514 16.809 18.607C16.937 18.7 17.092 18.75 17.25 18.75L18.75 18.75L18.75 20.25C18.75 20.408 18.8 20.563 18.893 20.691C18.986 20.819 19.118 20.914 19.268 20.963C19.419 21.012 19.581 21.012 19.732 20.963C19.882 20.914 20.014 20.819 20.107 20.691C20.2 20.563 20.25 20.408 20.25 20.25L20.25 18.75L21.75 18.75C21.908 18.75 22.063 18.7 22.191 18.607C22.319 18.514 22.414 18.382 22.463 18.232C22.512 18.081 22.512 17.919 22.463 17.768C22.414 17.618 22.319 17.486 22.191 17.393C22.063 17.3 21.908 17.25 21.75 17.25',
        true,
        false
      )
    ],
    [
      (
        'M2.625 6C2.625 5.803 2.677 5.609 2.776 5.438C2.874 5.266 3.016 5.124 3.187 5.026C3.359 4.927 3.553 4.875 3.75 4.875L20.25 4.875C20.488 4.875 20.719 4.95 20.911 5.09C21.103 5.229 21.247 5.426 21.32 5.652C21.393 5.878 21.393 6.122 21.32 6.348C21.247 6.574 21.103 6.771 20.911 6.91C20.719 7.05 20.488 7.125 20.25 7.125L3.75 7.125C3.553 7.125 3.359 7.073 3.188 6.974C3.016 6.876 2.874 6.734 2.776 6.562C2.677 6.391 2.625 6.197 2.625 6M3.75 13.125L20.25 13.125C20.488 13.125 20.719 13.05 20.911 12.91C21.103 12.771 21.247 12.574 21.32 12.348C21.393 12.122 21.393 11.878 21.32 11.652C21.247 11.426 21.103 11.229 20.911 11.09C20.719 10.95 20.488 10.875 20.25 10.875L3.75 10.875C3.512 10.875 3.281 10.95 3.089 11.09C2.897 11.229 2.753 11.426 2.68 11.652C2.607 11.878 2.607 12.122 2.68 12.348C2.753 12.574 2.897 12.771 3.089 12.91C3.281 13.05 3.512 13.125 3.75 13.125M13.5 16.875L3.75 16.875C3.512 16.875 3.281 16.95 3.089 17.09C2.897 17.229 2.753 17.426 2.68 17.652C2.607 17.878 2.607 18.122 2.68 18.348C2.753 18.574 2.897 18.771 3.089 18.91C3.281 19.05 3.512 19.125 3.75 19.125L13.5 19.125C13.738 19.125 13.969 19.05 14.161 18.91C14.353 18.771 14.497 18.574 14.57 18.348C14.643 18.122 14.643 17.878 14.57 17.652C14.497 17.426 14.353 17.229 14.161 17.09C13.969 16.95 13.738 16.875 13.5 16.875M21.75 16.875L20.625 16.875L20.625 15.75C20.625 15.512 20.55 15.281 20.41 15.089C20.271 14.897 20.074 14.753 19.848 14.68C19.622 14.607 19.378 14.607 19.152 14.68C18.926 14.753 18.729 14.897 18.59 15.089C18.45 15.281 18.375 15.512 18.375 15.75L18.375 16.875L17.25 16.875C17.012 16.875 16.781 16.95 16.589 17.09C16.397 17.229 16.253 17.426 16.18 17.652C16.107 17.878 16.107 18.122 16.18 18.348C16.253 18.574 16.397 18.771 16.589 18.91C16.781 19.05 17.012 19.125 17.25 19.125L18.375 19.125L18.375 20.25C18.375 20.488 18.45 20.719 18.59 20.911C18.729 21.103 18.926 21.247 19.152 21.32C19.378 21.393 19.622 21.393 19.848 21.32C20.074 21.247 20.271 21.103 20.41 20.911C20.55 20.719 20.625 20.488 20.625 20.25L20.625 19.125L21.75 19.125C21.988 19.125 22.219 19.05 22.411 18.91C22.603 18.771 22.747 18.574 22.82 18.348C22.893 18.122 22.893 17.878 22.82 17.652C22.747 17.426 22.603 17.229 22.411 17.09C22.219 16.95 21.988 16.875 21.75 16.875',
        true,
        false
      )
    ]
  ),
  'จำหน่าย': (
    [
      (
        'M11.25 20.25C11.25 20.382 11.215 20.511 11.15 20.625C11.084 20.739 10.989 20.834 10.875 20.9C10.761 20.965 10.632 21 10.5 21L4.5 21C4.368 21 4.239 20.965 4.125 20.9C4.011 20.834 3.916 20.739 3.85 20.625C3.785 20.511 3.75 20.382 3.75 20.25L3.75 3.75C3.75 3.618 3.785 3.489 3.85 3.375C3.916 3.261 4.011 3.166 4.125 3.1C4.239 3.035 4.368 3 4.5 3L10.5 3C10.658 3 10.813 3.05 10.941 3.143C11.069 3.236 11.164 3.368 11.213 3.518C11.262 3.669 11.262 3.831 11.213 3.982C11.164 4.132 11.069 4.264 10.941 4.357C10.813 4.45 10.658 4.5 10.5 4.5L5.25 4.5L5.25 19.5L10.5 19.5C10.632 19.5 10.761 19.535 10.875 19.6C10.989 19.666 11.084 19.761 11.15 19.875C11.215 19.989 11.25 20.118 11.25 20.25M21.531 11.469L17.781 7.719C17.669 7.607 17.524 7.534 17.367 7.509C17.211 7.484 17.05 7.509 16.909 7.581C16.768 7.653 16.653 7.768 16.581 7.909C16.509 8.05 16.484 8.211 16.509 8.367C16.534 8.524 16.607 8.669 16.719 8.781L19.19 11.25L10.5 11.25C10.342 11.25 10.187 11.3 10.059 11.393C9.931 11.486 9.836 11.618 9.787 11.768C9.738 11.919 9.738 12.081 9.787 12.232C9.836 12.382 9.931 12.514 10.059 12.607C10.187 12.7 10.342 12.75 10.5 12.75L19.19 12.75L16.719 15.219C16.607 15.331 16.534 15.476 16.509 15.633C16.484 15.789 16.509 15.95 16.581 16.091C16.653 16.232 16.768 16.347 16.909 16.419C17.05 16.491 17.211 16.516 17.367 16.491C17.524 16.466 17.669 16.393 17.781 16.281L21.531 12.531C21.624 12.438 21.691 12.321 21.725 12.194C21.759 12.067 21.759 11.933 21.725 11.806C21.691 11.679 21.624 11.562 21.531 11.469',
        true,
        false
      )
    ],
    [
      (
        'M11.25 20.25C11.25 20.382 11.215 20.511 11.15 20.625C11.084 20.739 10.989 20.834 10.875 20.9C10.761 20.965 10.632 21 10.5 21L4.5 21C4.368 21 4.239 20.965 4.125 20.9C4.011 20.834 3.916 20.739 3.85 20.625C3.785 20.511 3.75 20.382 3.75 20.25L3.75 3.75C3.75 3.618 3.785 3.489 3.85 3.375C3.916 3.261 4.011 3.166 4.125 3.1C4.239 3.035 4.368 3 4.5 3L10.5 3C10.658 3 10.813 3.05 10.941 3.143C11.069 3.236 11.164 3.368 11.213 3.518C11.262 3.669 11.262 3.831 11.213 3.982C11.164 4.132 11.069 4.264 10.941 4.357C10.813 4.45 10.658 4.5 10.5 4.5L5.25 4.5L5.25 19.5L10.5 19.5C10.632 19.5 10.761 19.535 10.875 19.6C10.989 19.666 11.084 19.761 11.15 19.875C11.215 19.989 11.25 20.118 11.25 20.25M21.531 11.469L17.781 7.719C17.676 7.614 17.542 7.543 17.396 7.514C17.251 7.485 17.1 7.5 16.963 7.557C16.826 7.613 16.709 7.71 16.626 7.833C16.544 7.956 16.5 8.102 16.5 8.25L16.5 11.25L10.5 11.25C10.342 11.25 10.187 11.3 10.059 11.393C9.931 11.486 9.836 11.618 9.787 11.768C9.738 11.919 9.738 12.081 9.787 12.232C9.836 12.382 9.931 12.514 10.059 12.607C10.187 12.7 10.342 12.75 10.5 12.75L16.5 12.75L16.5 15.75C16.5 15.898 16.544 16.044 16.626 16.167C16.709 16.29 16.826 16.387 16.963 16.443C17.1 16.5 17.251 16.515 17.396 16.486C17.542 16.457 17.676 16.386 17.781 16.281L21.531 12.531C21.624 12.438 21.691 12.321 21.725 12.194C21.759 12.067 21.759 11.933 21.725 11.806C21.691 11.679 21.624 11.562 21.531 11.469',
        true,
        false
      )
    ]
  ),
  'สัญญาณชีพ': (
    [
      (
        'M6.75 13.5L3 13.5C2.842 13.5 2.687 13.45 2.559 13.357C2.431 13.264 2.336 13.132 2.287 12.982C2.238 12.831 2.238 12.669 2.287 12.518C2.336 12.368 2.431 12.236 2.559 12.143C2.687 12.05 2.842 12 3 12L6.349 12L7.626 10.084C7.694 9.981 7.787 9.897 7.896 9.838C8.005 9.78 8.126 9.749 8.25 9.749C8.374 9.749 8.495 9.78 8.604 9.838C8.713 9.897 8.806 9.981 8.874 10.084L11.25 13.646L12.126 12.334C12.194 12.231 12.287 12.147 12.396 12.089C12.505 12.03 12.626 12 12.75 12L15 12C15.158 12 15.313 12.05 15.441 12.143C15.569 12.236 15.664 12.368 15.713 12.518C15.762 12.669 15.762 12.831 15.713 12.982C15.664 13.132 15.569 13.264 15.441 13.357C15.313 13.45 15.158 13.5 15 13.5L13.151 13.5L11.874 15.416C11.806 15.519 11.713 15.603 11.604 15.662C11.495 15.72 11.374 15.751 11.25 15.751C11.126 15.751 11.005 15.72 10.896 15.662C10.787 15.603 10.694 15.519 10.626 15.416L8.25 11.852L7.374 13.164C7.306 13.267 7.213 13.352 7.104 13.411C6.995 13.469 6.874 13.5 6.75 13.5M16.688 3.75C14.752 3.75 13.057 4.583 12 5.99C10.943 4.583 9.248 3.75 7.312 3.75C6.293 3.751 5.291 4.02 4.408 4.531C3.525 5.041 2.791 5.775 2.281 6.658C1.77 7.541 1.501 8.543 1.5 9.562L1.5 9.773C1.505 9.932 1.56 10.085 1.657 10.21C1.754 10.335 1.888 10.426 2.041 10.471C2.193 10.515 2.355 10.51 2.504 10.456C2.653 10.402 2.781 10.303 2.871 10.172C2.96 10.041 3.005 9.885 3 9.727L3 9.562C3.001 8.806 3.201 8.063 3.579 7.407C3.958 6.752 4.502 6.208 5.157 5.829C5.813 5.451 6.556 5.251 7.312 5.25C9.136 5.25 10.667 6.221 11.306 7.781C11.363 7.919 11.459 8.036 11.582 8.119C11.706 8.202 11.851 8.246 12 8.246C12.149 8.246 12.294 8.202 12.418 8.119C12.541 8.036 12.637 7.919 12.694 7.781C13.333 6.218 14.864 5.25 16.688 5.25C17.444 5.251 18.187 5.451 18.843 5.829C19.498 6.208 20.042 6.752 20.421 7.407C20.799 8.063 20.999 8.806 21 9.562C21 14.588 13.71 19.139 12 20.138C10.985 19.546 8.003 17.7 5.749 15.243C5.66 15.146 5.547 15.074 5.421 15.034C5.295 14.995 5.162 14.989 5.033 15.017C4.904 15.046 4.786 15.108 4.688 15.197C4.591 15.286 4.519 15.399 4.48 15.525C4.44 15.65 4.434 15.784 4.463 15.913C4.492 16.041 4.553 16.16 4.643 16.257C7.565 19.445 11.48 21.571 11.645 21.66C11.754 21.719 11.876 21.75 12 21.75C12.124 21.75 12.246 21.719 12.355 21.66C12.77 21.437 22.5 16.125 22.5 9.562C22.499 8.543 22.23 7.541 21.719 6.658C21.209 5.775 20.475 5.041 19.592 4.531C18.709 4.02 17.707 3.751 16.688 3.75',
        true,
        false
      )
    ],
    [
      (
        'M22.5 9.562C22.5 16.125 12.77 21.437 12.355 21.656C12.246 21.715 12.124 21.746 12 21.746C11.876 21.746 11.754 21.715 11.645 21.656C11.331 21.487 5.687 18.404 2.956 14.073C2.921 14.016 2.901 13.951 2.9 13.884C2.898 13.817 2.914 13.751 2.947 13.693C2.979 13.635 3.026 13.586 3.084 13.552C3.141 13.518 3.207 13.5 3.274 13.5L6.75 13.5C6.874 13.5 6.995 13.47 7.104 13.411C7.213 13.353 7.306 13.269 7.374 13.166L8.25 11.854L10.626 15.416C10.686 15.507 10.765 15.583 10.858 15.64C10.951 15.697 11.055 15.733 11.163 15.745C11.271 15.758 11.381 15.747 11.484 15.712C11.566 15.685 11.643 15.643 11.712 15.59C11.78 15.537 11.839 15.472 11.886 15.399L13.151 13.5L15 13.5C15.137 13.5 15.272 13.463 15.39 13.392C15.508 13.32 15.603 13.218 15.667 13.096C15.73 12.975 15.759 12.837 15.75 12.7C15.739 12.573 15.696 12.45 15.625 12.343C15.554 12.236 15.458 12.149 15.345 12.089C15.231 12.029 15.105 11.998 14.977 12L12.75 12C12.626 12 12.505 12.03 12.396 12.089C12.287 12.147 12.194 12.231 12.126 12.334L11.25 13.646L8.874 10.084C8.814 9.993 8.734 9.917 8.642 9.86C8.549 9.803 8.444 9.767 8.336 9.754C8.228 9.742 8.118 9.753 8.015 9.788C7.933 9.815 7.856 9.857 7.788 9.91C7.72 9.964 7.661 10.028 7.614 10.101L6.349 12L2.206 12C2.153 12 2.1 11.989 2.052 11.967C2.003 11.946 1.96 11.914 1.924 11.874C1.889 11.834 1.863 11.787 1.847 11.737C1.621 11.034 1.504 10.301 1.5 9.562C1.501 8.543 1.77 7.541 2.281 6.658C2.791 5.775 3.525 5.041 4.408 4.531C5.291 4.02 6.293 3.751 7.312 3.75C9.248 3.75 10.943 4.583 12 5.99C13.057 4.583 14.752 3.75 16.688 3.75C17.707 3.751 18.709 4.02 19.592 4.531C20.475 5.041 21.209 5.775 21.719 6.658C22.23 7.541 22.499 8.543 22.5 9.562',
        true,
        false
      )
    ]
  ),
  'ความรุนแรง AIS': (
    [
      (
        'M11.25 12.75L11.25 7.5C11.25 7.342 11.3 7.187 11.393 7.059C11.486 6.931 11.618 6.836 11.768 6.787C11.919 6.738 12.081 6.738 12.232 6.787C12.382 6.836 12.514 6.931 12.607 7.059C12.7 7.187 12.75 7.342 12.75 7.5L12.75 12.75C12.75 12.908 12.7 13.063 12.607 13.191C12.514 13.319 12.382 13.414 12.232 13.463C12.081 13.512 11.919 13.512 11.768 13.463C11.618 13.414 11.486 13.319 11.393 13.191C11.3 13.063 11.25 12.908 11.25 12.75M21.75 8.583L21.75 15.417C21.751 15.614 21.712 15.809 21.637 15.991C21.561 16.174 21.45 16.339 21.31 16.477L16.477 21.31C16.339 21.45 16.174 21.561 15.991 21.637C15.809 21.712 15.614 21.751 15.417 21.75L8.583 21.75C8.386 21.751 8.191 21.712 8.009 21.637C7.826 21.561 7.661 21.45 7.522 21.31L2.69 16.477C2.55 16.339 2.439 16.174 2.363 15.991C2.288 15.809 2.249 15.614 2.25 15.417L2.25 8.583C2.249 8.386 2.288 8.191 2.363 8.009C2.439 7.826 2.55 7.661 2.69 7.522L7.522 2.69C7.661 2.55 7.826 2.439 8.009 2.363C8.191 2.288 8.386 2.249 8.583 2.25L15.417 2.25C15.614 2.249 15.809 2.288 15.991 2.363C16.174 2.439 16.339 2.55 16.477 2.69L21.31 7.522C21.45 7.661 21.561 7.826 21.637 8.009C21.712 8.191 21.751 8.386 21.75 8.583M20.25 8.583L15.417 3.75L8.583 3.75L3.75 8.583L3.75 15.417L8.583 20.25L15.417 20.25L20.25 15.417ZM12 15C11.778 15 11.56 15.066 11.375 15.19C11.19 15.313 11.046 15.489 10.961 15.694C10.875 15.9 10.853 16.126 10.897 16.344C10.94 16.563 11.047 16.763 11.205 16.92C11.362 17.078 11.562 17.185 11.781 17.228C11.999 17.272 12.225 17.25 12.431 17.164C12.636 17.079 12.812 16.935 12.935 16.75C13.059 16.565 13.125 16.347 13.125 16.125C13.125 15.928 13.073 15.734 12.974 15.562C12.876 15.391 12.734 15.249 12.562 15.151C12.391 15.052 12.197 15 12 15',
        true,
        false
      )
    ],
    [
      (
        'M21.31 7.522L16.478 2.69C16.339 2.551 16.173 2.441 15.991 2.365C15.809 2.29 15.614 2.251 15.417 2.25L8.583 2.25C8.386 2.251 8.191 2.29 8.009 2.365C7.827 2.441 7.661 2.551 7.522 2.69L2.69 7.522C2.551 7.661 2.441 7.827 2.365 8.009C2.29 8.191 2.251 8.386 2.25 8.583L2.25 15.417C2.251 15.614 2.29 15.809 2.365 15.991C2.441 16.173 2.551 16.339 2.69 16.478L7.522 21.31C7.661 21.449 7.827 21.559 8.009 21.635C8.191 21.71 8.386 21.749 8.583 21.75L15.417 21.75C15.614 21.749 15.809 21.71 15.991 21.635C16.173 21.559 16.339 21.449 16.478 21.31L21.31 16.478C21.449 16.339 21.559 16.173 21.635 15.991C21.71 15.809 21.749 15.614 21.75 15.417L21.75 8.583C21.749 8.386 21.71 8.191 21.635 8.009C21.559 7.827 21.449 7.661 21.31 7.522M11.25 7.5C11.25 7.342 11.3 7.187 11.393 7.059C11.486 6.931 11.618 6.836 11.768 6.787C11.919 6.738 12.081 6.738 12.232 6.787C12.382 6.836 12.514 6.931 12.607 7.059C12.7 7.187 12.75 7.342 12.75 7.5L12.75 12.75C12.75 12.908 12.7 13.063 12.607 13.191C12.514 13.319 12.382 13.414 12.232 13.463C12.081 13.512 11.919 13.512 11.768 13.463C11.618 13.414 11.486 13.319 11.393 13.191C11.3 13.063 11.25 12.908 11.25 12.75ZM12 17.25C11.778 17.25 11.56 17.184 11.375 17.06C11.19 16.937 11.046 16.761 10.961 16.556C10.875 16.35 10.853 16.124 10.897 15.906C10.94 15.687 11.047 15.487 11.205 15.33C11.362 15.172 11.562 15.065 11.781 15.022C11.999 14.978 12.225 15 12.431 15.086C12.636 15.171 12.812 15.315 12.935 15.5C13.059 15.685 13.125 15.903 13.125 16.125C13.125 16.322 13.073 16.516 12.974 16.688C12.876 16.859 12.734 17.001 12.562 17.099C12.391 17.198 12.197 17.25 12 17.25',
        true,
        false
      )
    ]
  ),
  'รับคำสั่งแพทย์': (
    [
      (
        'M21 12C21 12.132 20.965 12.261 20.9 12.375C20.834 12.489 20.739 12.584 20.625 12.65C20.511 12.715 20.382 12.75 20.25 12.75L12 12.75C11.842 12.75 11.687 12.7 11.559 12.607C11.431 12.514 11.336 12.382 11.287 12.232C11.238 12.081 11.238 11.919 11.287 11.768C11.336 11.618 11.431 11.486 11.559 11.393C11.687 11.3 11.842 11.25 12 11.25L20.25 11.25C20.382 11.25 20.511 11.285 20.625 11.35C20.739 11.416 20.834 11.511 20.9 11.625C20.965 11.739 21 11.868 21 12M12 6.75L20.25 6.75C20.408 6.75 20.563 6.7 20.691 6.607C20.819 6.514 20.914 6.382 20.963 6.232C21.012 6.081 21.012 5.919 20.963 5.768C20.914 5.618 20.819 5.486 20.691 5.393C20.563 5.3 20.408 5.25 20.25 5.25L12 5.25C11.842 5.25 11.687 5.3 11.559 5.393C11.431 5.486 11.336 5.618 11.287 5.768C11.238 5.919 11.238 6.081 11.287 6.232C11.336 6.382 11.431 6.514 11.559 6.607C11.687 6.7 11.842 6.75 12 6.75M20.25 17.25L12 17.25C11.842 17.25 11.687 17.3 11.559 17.393C11.431 17.486 11.336 17.618 11.287 17.768C11.238 17.919 11.238 18.081 11.287 18.232C11.336 18.382 11.431 18.514 11.559 18.607C11.687 18.7 11.842 18.75 12 18.75L20.25 18.75C20.408 18.75 20.563 18.7 20.691 18.607C20.819 18.514 20.914 18.382 20.963 18.232C21.012 18.081 21.012 17.919 20.963 17.768C20.914 17.618 20.819 17.486 20.691 17.393C20.563 17.3 20.408 17.25 20.25 17.25M7.719 3.969L5.25 6.44L4.281 5.469C4.169 5.357 4.024 5.284 3.867 5.259C3.711 5.234 3.55 5.259 3.409 5.331C3.268 5.403 3.153 5.518 3.081 5.659C3.009 5.8 2.984 5.961 3.009 6.117C3.034 6.274 3.107 6.419 3.219 6.531L4.719 8.031C4.812 8.124 4.929 8.191 5.056 8.225C5.183 8.259 5.317 8.259 5.444 8.225C5.571 8.191 5.688 8.124 5.781 8.031L8.781 5.031C8.893 4.919 8.966 4.774 8.991 4.617C9.016 4.461 8.991 4.3 8.919 4.159C8.847 4.018 8.732 3.903 8.591 3.831C8.45 3.759 8.289 3.734 8.133 3.759C7.976 3.784 7.831 3.857 7.719 3.969M7.719 9.969L5.25 12.44L4.281 11.469C4.169 11.357 4.024 11.284 3.867 11.259C3.711 11.234 3.55 11.259 3.409 11.331C3.268 11.403 3.153 11.518 3.081 11.659C3.009 11.8 2.984 11.961 3.009 12.117C3.034 12.274 3.107 12.419 3.219 12.531L4.719 14.031C4.812 14.124 4.929 14.191 5.056 14.225C5.183 14.259 5.317 14.259 5.444 14.225C5.571 14.191 5.688 14.124 5.781 14.031L8.781 11.031C8.893 10.919 8.966 10.774 8.991 10.617C9.016 10.461 8.991 10.3 8.919 10.159C8.847 10.018 8.732 9.903 8.591 9.831C8.45 9.759 8.289 9.734 8.133 9.759C7.976 9.784 7.831 9.857 7.719 9.969M7.719 15.969L5.25 18.44L4.281 17.469C4.169 17.357 4.024 17.284 3.867 17.259C3.711 17.234 3.55 17.259 3.409 17.331C3.268 17.403 3.153 17.518 3.081 17.659C3.009 17.8 2.984 17.961 3.009 18.117C3.034 18.274 3.107 18.419 3.219 18.531L4.719 20.031C4.812 20.124 4.929 20.191 5.056 20.225C5.183 20.259 5.317 20.259 5.444 20.225C5.571 20.191 5.688 20.124 5.781 20.031L8.781 17.031C8.893 16.919 8.966 16.774 8.991 16.617C9.016 16.461 8.991 16.3 8.919 16.159C8.847 16.018 8.732 15.903 8.591 15.831C8.45 15.759 8.289 15.734 8.133 15.759C7.976 15.784 7.831 15.857 7.719 15.969',
        true,
        false
      )
    ],
    [
      (
        'M19.5 3L4.5 3C4.237 3 3.978 3.069 3.75 3.201C3.522 3.333 3.333 3.522 3.201 3.75C3.069 3.978 3 4.237 3 4.5L3 19.5C3 19.763 3.069 20.022 3.201 20.25C3.333 20.478 3.522 20.667 3.75 20.799C3.978 20.931 4.237 21 4.5 21L19.5 21C19.763 21 20.022 20.931 20.25 20.799C20.478 20.667 20.667 20.478 20.799 20.25C20.931 20.022 21 19.763 21 19.5L21 4.5C21 4.237 20.931 3.978 20.799 3.75C20.667 3.522 20.478 3.333 20.25 3.201C20.022 3.069 19.763 3 19.5 3M11.031 14.031L8.031 17.031C7.938 17.124 7.821 17.191 7.694 17.225C7.567 17.259 7.433 17.259 7.306 17.225C7.179 17.191 7.062 17.124 6.969 17.031L5.469 15.531C5.357 15.419 5.284 15.274 5.259 15.117C5.234 14.961 5.259 14.8 5.331 14.659C5.403 14.518 5.518 14.403 5.659 14.331C5.8 14.259 5.961 14.234 6.117 14.259C6.274 14.284 6.419 14.357 6.531 14.469L7.5 15.44L9.969 12.969C10.081 12.857 10.226 12.784 10.383 12.759C10.539 12.734 10.7 12.759 10.841 12.831C10.982 12.903 11.097 13.018 11.169 13.159C11.241 13.3 11.266 13.461 11.241 13.617C11.216 13.774 11.143 13.919 11.031 14.031M11.031 8.031L8.031 11.031C7.938 11.124 7.821 11.191 7.694 11.225C7.567 11.259 7.433 11.259 7.306 11.225C7.179 11.191 7.062 11.124 6.969 11.031L5.469 9.531C5.357 9.419 5.284 9.274 5.259 9.117C5.234 8.961 5.259 8.8 5.331 8.659C5.403 8.518 5.518 8.403 5.659 8.331C5.8 8.259 5.961 8.234 6.117 8.259C6.274 8.284 6.419 8.357 6.531 8.469L7.5 9.44L9.969 6.969C10.081 6.857 10.226 6.784 10.383 6.759C10.539 6.734 10.7 6.759 10.841 6.831C10.982 6.903 11.097 7.018 11.169 7.159C11.241 7.3 11.266 7.461 11.241 7.617C11.216 7.774 11.143 7.919 11.031 8.031M18 15.75L13.5 15.75C13.342 15.75 13.187 15.7 13.059 15.607C12.931 15.514 12.836 15.382 12.787 15.232C12.738 15.081 12.738 14.919 12.787 14.768C12.836 14.618 12.931 14.486 13.059 14.393C13.187 14.3 13.342 14.25 13.5 14.25L18 14.25C18.158 14.25 18.313 14.3 18.441 14.393C18.569 14.486 18.664 14.618 18.713 14.768C18.762 14.919 18.762 15.081 18.713 15.232C18.664 15.382 18.569 15.514 18.441 15.607C18.313 15.7 18.158 15.75 18 15.75M18 9.75L13.5 9.75C13.342 9.75 13.187 9.7 13.059 9.607C12.931 9.514 12.836 9.382 12.787 9.232C12.738 9.081 12.738 8.919 12.787 8.768C12.836 8.618 12.931 8.486 13.059 8.393C13.187 8.3 13.342 8.25 13.5 8.25L18 8.25C18.158 8.25 18.313 8.3 18.441 8.393C18.569 8.486 18.664 8.618 18.713 8.768C18.762 8.919 18.762 9.081 18.713 9.232C18.664 9.382 18.569 9.514 18.441 9.607C18.313 9.7 18.158 9.75 18 9.75',
        true,
        false
      )
    ]
  ),
  'สังเกตอาการ': (
    [
      (
        'M23.185 11.696C23.152 11.622 22.358 9.861 20.593 8.095C18.241 5.743 15.27 4.5 12 4.5C8.73 4.5 5.759 5.743 3.407 8.095C1.642 9.861 0.844 11.625 0.815 11.696C0.772 11.792 0.75 11.896 0.75 12.001C0.75 12.106 0.772 12.21 0.815 12.306C0.847 12.38 1.642 14.14 3.407 15.906C5.759 18.257 8.73 19.5 12 19.5C15.27 19.5 18.241 18.257 20.593 15.906C22.358 14.14 23.152 12.38 23.185 12.306C23.228 12.21 23.25 12.106 23.25 12.001C23.25 11.896 23.228 11.792 23.185 11.696M12 18C9.114 18 6.593 16.951 4.507 14.883C3.65 14.031 2.922 13.06 2.344 12C2.922 10.94 3.65 9.969 4.507 9.117C6.593 7.049 9.114 6 12 6C14.886 6 17.407 7.049 19.493 9.117C20.351 9.968 21.081 10.939 21.661 12C20.985 13.262 18.04 18 12 18M12 7.5C11.11 7.5 10.24 7.764 9.5 8.258C8.76 8.753 8.183 9.456 7.843 10.278C7.502 11.1 7.413 12.005 7.586 12.878C7.76 13.751 8.189 14.553 8.818 15.182C9.447 15.811 10.249 16.24 11.122 16.414C11.995 16.587 12.9 16.498 13.722 16.157C14.544 15.817 15.247 15.24 15.742 14.5C16.236 13.76 16.5 12.89 16.5 12C16.499 11.21 16.291 10.435 15.896 9.751C15.501 9.067 14.933 8.499 14.249 8.104C13.565 7.709 12.79 7.501 12 7.5M12 15C11.407 15 10.827 14.824 10.333 14.494C9.84 14.165 9.455 13.696 9.228 13.148C9.001 12.6 8.942 11.997 9.058 11.415C9.173 10.833 9.459 10.298 9.879 9.879C10.298 9.459 10.833 9.173 11.415 9.058C11.997 8.942 12.6 9.001 13.148 9.228C13.696 9.455 14.165 9.84 14.494 10.333C14.824 10.827 15 11.407 15 12C15 12.527 14.861 13.044 14.598 13.5C14.335 13.956 13.956 14.335 13.5 14.598C13.044 14.861 12.527 15 12 15',
        true,
        false
      )
    ],
    [
      (
        'M23.185 11.696C23.152 11.622 22.358 9.861 20.593 8.095C18.241 5.743 15.27 4.5 12 4.5C8.73 4.5 5.759 5.743 3.407 8.095C1.642 9.861 0.844 11.625 0.815 11.696C0.772 11.792 0.75 11.896 0.75 12.001C0.75 12.106 0.772 12.21 0.815 12.306C0.847 12.38 1.642 14.14 3.407 15.906C5.759 18.257 8.73 19.5 12 19.5C15.27 19.5 18.241 18.257 20.593 15.906C22.358 14.14 23.152 12.38 23.185 12.306C23.228 12.21 23.25 12.106 23.25 12.001C23.25 11.896 23.228 11.792 23.185 11.696M12 15.75C11.258 15.75 10.533 15.53 9.917 15.118C9.3 14.706 8.819 14.12 8.535 13.435C8.252 12.75 8.177 11.996 8.322 11.268C8.467 10.541 8.824 9.873 9.348 9.348C9.873 8.824 10.541 8.467 11.268 8.322C11.996 8.177 12.75 8.252 13.435 8.535C14.12 8.819 14.706 9.3 15.118 9.917C15.53 10.533 15.75 11.258 15.75 12C15.75 12.658 15.577 13.305 15.248 13.875C14.918 14.445 14.445 14.918 13.875 15.248C13.305 15.577 12.658 15.75 12 15.75',
        true,
        false
      )
    ]
  ),
  'การพยาบาล': (
    [
      (
        'M21.593 13.224C21.348 13.035 21.067 12.898 20.767 12.821C20.467 12.744 20.155 12.729 19.849 12.777C21.609 11 22.5 9.232 22.5 7.5C22.5 5.018 20.504 3 18.051 3C17.4 2.996 16.756 3.134 16.164 3.406C15.572 3.677 15.047 4.074 14.625 4.57C14.203 4.074 13.678 3.677 13.086 3.406C12.494 3.134 11.85 2.996 11.199 3C8.746 3 6.75 5.018 6.75 7.5C6.75 8.531 7.054 9.533 7.693 10.594C7.17 10.726 6.692 10.999 6.31 11.381L4.19 13.5L1.5 13.5C1.237 13.5 0.978 13.569 0.75 13.701C0.522 13.833 0.333 14.022 0.201 14.25C0.069 14.478 0 14.737 0 15L0 18.75C0 19.013 0.069 19.272 0.201 19.5C0.333 19.728 0.522 19.917 0.75 20.049C0.978 20.181 1.237 20.25 1.5 20.25L11.25 20.25C11.311 20.25 11.372 20.242 11.432 20.227L17.432 18.727C17.47 18.718 17.507 18.706 17.543 18.69L21.188 17.139L21.229 17.121C21.579 16.946 21.879 16.684 22.1 16.361C22.322 16.038 22.457 15.664 22.494 15.275C22.531 14.885 22.468 14.492 22.311 14.133C22.154 13.775 21.908 13.462 21.597 13.224ZM11.199 4.5C11.78 4.491 12.351 4.656 12.837 4.974C13.324 5.291 13.705 5.746 13.931 6.281C13.988 6.419 14.084 6.536 14.207 6.619C14.331 6.702 14.476 6.746 14.625 6.746C14.774 6.746 14.919 6.702 15.043 6.619C15.166 6.536 15.262 6.419 15.319 6.281C15.545 5.746 15.926 5.291 16.413 4.974C16.899 4.656 17.47 4.491 18.051 4.5C19.649 4.5 21 5.873 21 7.5C21 9.329 19.52 11.398 16.719 13.491L15.68 13.73C15.802 13.214 15.765 12.673 15.574 12.179C15.383 11.685 15.047 11.26 14.61 10.96C14.173 10.66 13.655 10.5 13.125 10.5L9.439 10.5C8.63 9.409 8.25 8.449 8.25 7.5C8.25 5.873 9.601 4.5 11.199 4.5M1.5 15L3.75 15L3.75 18.75L1.5 18.75ZM20.572 15.77L17.009 17.287L11.156 18.75L5.25 18.75L5.25 14.56L7.372 12.44C7.51 12.3 7.676 12.189 7.858 12.113C8.04 12.038 8.235 11.999 8.432 12L13.125 12C13.363 12 13.594 12.075 13.786 12.215C13.978 12.354 14.122 12.551 14.195 12.777C14.268 13.003 14.268 13.247 14.195 13.473C14.122 13.699 13.978 13.896 13.786 14.035C13.594 14.175 13.363 14.25 13.125 14.25L10.5 14.25C10.342 14.25 10.187 14.3 10.059 14.393C9.931 14.486 9.836 14.618 9.787 14.768C9.738 14.919 9.738 15.081 9.787 15.232C9.836 15.382 9.931 15.514 10.059 15.607C10.187 15.7 10.342 15.75 10.5 15.75L13.5 15.75C13.556 15.75 13.613 15.744 13.668 15.731L19.949 14.287L19.978 14.279C20.131 14.237 20.293 14.24 20.444 14.289C20.594 14.338 20.727 14.431 20.826 14.555C20.924 14.679 20.984 14.83 20.997 14.988C21.011 15.146 20.977 15.304 20.901 15.443C20.825 15.582 20.709 15.696 20.569 15.77Z',
        true,
        false
      )
    ],
    [
      (
        'M21.593 13.224C21.348 13.035 21.067 12.898 20.767 12.821C20.467 12.744 20.155 12.729 19.849 12.777C21.609 11 22.5 9.232 22.5 7.5C22.5 5.018 20.504 3 18.051 3C17.4 2.996 16.756 3.134 16.164 3.406C15.572 3.677 15.047 4.074 14.625 4.57C14.203 4.074 13.678 3.677 13.086 3.406C12.494 3.134 11.85 2.996 11.199 3C8.746 3 6.75 5.018 6.75 7.5C6.75 8.531 7.054 9.533 7.693 10.594C7.17 10.726 6.692 10.999 6.31 11.381L4.19 13.5L1.5 13.5C1.237 13.5 0.978 13.569 0.75 13.701C0.522 13.833 0.333 14.022 0.201 14.25C0.069 14.478 0 14.737 0 15L0 18.75C0 19.013 0.069 19.272 0.201 19.5C0.333 19.728 0.522 19.917 0.75 20.049C0.978 20.181 1.237 20.25 1.5 20.25L11.25 20.25C11.311 20.25 11.372 20.242 11.432 20.227L17.432 18.727C17.47 18.718 17.507 18.706 17.543 18.69L21.188 17.139L21.229 17.121C21.579 16.946 21.879 16.684 22.1 16.361C22.322 16.038 22.457 15.664 22.494 15.275C22.531 14.885 22.468 14.492 22.311 14.133C22.154 13.775 21.908 13.462 21.597 13.224ZM20.572 15.77L17.009 17.287L11.156 18.75L5.25 18.75L5.25 14.56L7.372 12.44C7.51 12.3 7.676 12.189 7.858 12.113C8.04 12.038 8.235 11.999 8.432 12L13.125 12C13.363 12 13.594 12.075 13.786 12.215C13.978 12.354 14.122 12.551 14.195 12.777C14.268 13.003 14.268 13.247 14.195 13.473C14.122 13.699 13.978 13.896 13.786 14.035C13.594 14.175 13.363 14.25 13.125 14.25L10.5 14.25C10.342 14.25 10.187 14.3 10.059 14.393C9.931 14.486 9.836 14.618 9.787 14.768C9.738 14.919 9.738 15.081 9.787 15.232C9.836 15.382 9.931 15.514 10.059 15.607C10.187 15.7 10.342 15.75 10.5 15.75L13.5 15.75C13.556 15.75 13.613 15.744 13.668 15.731L19.949 14.287L19.978 14.279C20.131 14.237 20.293 14.24 20.444 14.289C20.594 14.338 20.727 14.431 20.826 14.555C20.924 14.679 20.984 14.83 20.997 14.988C21.011 15.146 20.977 15.304 20.901 15.443C20.825 15.582 20.709 15.696 20.569 15.77Z',
        true,
        false
      )
    ]
  ),
  'ออกจาก ER': (
    [
      (
        'M11.25 20.25C11.25 20.382 11.215 20.511 11.15 20.625C11.084 20.739 10.989 20.834 10.875 20.9C10.761 20.965 10.632 21 10.5 21L4.5 21C4.368 21 4.239 20.965 4.125 20.9C4.011 20.834 3.916 20.739 3.85 20.625C3.785 20.511 3.75 20.382 3.75 20.25L3.75 3.75C3.75 3.618 3.785 3.489 3.85 3.375C3.916 3.261 4.011 3.166 4.125 3.1C4.239 3.035 4.368 3 4.5 3L10.5 3C10.658 3 10.813 3.05 10.941 3.143C11.069 3.236 11.164 3.368 11.213 3.518C11.262 3.669 11.262 3.831 11.213 3.982C11.164 4.132 11.069 4.264 10.941 4.357C10.813 4.45 10.658 4.5 10.5 4.5L5.25 4.5L5.25 19.5L10.5 19.5C10.632 19.5 10.761 19.535 10.875 19.6C10.989 19.666 11.084 19.761 11.15 19.875C11.215 19.989 11.25 20.118 11.25 20.25M21.531 11.469L17.781 7.719C17.669 7.607 17.524 7.534 17.367 7.509C17.211 7.484 17.05 7.509 16.909 7.581C16.768 7.653 16.653 7.768 16.581 7.909C16.509 8.05 16.484 8.211 16.509 8.367C16.534 8.524 16.607 8.669 16.719 8.781L19.19 11.25L10.5 11.25C10.342 11.25 10.187 11.3 10.059 11.393C9.931 11.486 9.836 11.618 9.787 11.768C9.738 11.919 9.738 12.081 9.787 12.232C9.836 12.382 9.931 12.514 10.059 12.607C10.187 12.7 10.342 12.75 10.5 12.75L19.19 12.75L16.719 15.219C16.607 15.331 16.534 15.476 16.509 15.633C16.484 15.789 16.509 15.95 16.581 16.091C16.653 16.232 16.768 16.347 16.909 16.419C17.05 16.491 17.211 16.516 17.367 16.491C17.524 16.466 17.669 16.393 17.781 16.281L21.531 12.531C21.624 12.438 21.691 12.321 21.725 12.194C21.759 12.067 21.759 11.933 21.725 11.806C21.691 11.679 21.624 11.562 21.531 11.469',
        true,
        false
      )
    ],
    [
      (
        'M11.25 20.25C11.25 20.382 11.215 20.511 11.15 20.625C11.084 20.739 10.989 20.834 10.875 20.9C10.761 20.965 10.632 21 10.5 21L4.5 21C4.368 21 4.239 20.965 4.125 20.9C4.011 20.834 3.916 20.739 3.85 20.625C3.785 20.511 3.75 20.382 3.75 20.25L3.75 3.75C3.75 3.618 3.785 3.489 3.85 3.375C3.916 3.261 4.011 3.166 4.125 3.1C4.239 3.035 4.368 3 4.5 3L10.5 3C10.658 3 10.813 3.05 10.941 3.143C11.069 3.236 11.164 3.368 11.213 3.518C11.262 3.669 11.262 3.831 11.213 3.982C11.164 4.132 11.069 4.264 10.941 4.357C10.813 4.45 10.658 4.5 10.5 4.5L5.25 4.5L5.25 19.5L10.5 19.5C10.632 19.5 10.761 19.535 10.875 19.6C10.989 19.666 11.084 19.761 11.15 19.875C11.215 19.989 11.25 20.118 11.25 20.25M21.531 11.469L17.781 7.719C17.676 7.614 17.542 7.543 17.396 7.514C17.251 7.485 17.1 7.5 16.963 7.557C16.826 7.613 16.709 7.71 16.626 7.833C16.544 7.956 16.5 8.102 16.5 8.25L16.5 11.25L10.5 11.25C10.342 11.25 10.187 11.3 10.059 11.393C9.931 11.486 9.836 11.618 9.787 11.768C9.738 11.919 9.738 12.081 9.787 12.232C9.836 12.382 9.931 12.514 10.059 12.607C10.187 12.7 10.342 12.75 10.5 12.75L16.5 12.75L16.5 15.75C16.5 15.898 16.544 16.044 16.626 16.167C16.709 16.29 16.826 16.387 16.963 16.443C17.1 16.5 17.251 16.515 17.396 16.486C17.542 16.457 17.676 16.386 17.781 16.281L21.531 12.531C21.624 12.438 21.691 12.321 21.725 12.194C21.759 12.067 21.759 11.933 21.725 11.806C21.691 11.679 21.624 11.562 21.531 11.469',
        true,
        false
      )
    ]
  ),
  'ซักประวัติ': (
    [
      (
        'M21.757 17.509C22.275 16.434 22.529 15.251 22.498 14.058C22.467 12.865 22.152 11.697 21.58 10.65C21.007 9.604 20.192 8.709 19.204 8.04C18.216 7.371 17.082 6.948 15.897 6.805C15.37 5.58 14.526 4.518 13.452 3.727C12.378 2.937 11.112 2.447 9.785 2.309C8.459 2.171 7.119 2.389 5.905 2.94C4.691 3.492 3.646 4.358 2.877 5.448C2.109 6.538 1.645 7.813 1.534 9.142C1.422 10.471 1.667 11.806 2.243 13.009L1.562 15.325C1.486 15.584 1.481 15.858 1.547 16.12C1.614 16.381 1.749 16.619 1.94 16.81C2.131 17.001 2.369 17.136 2.63 17.203C2.892 17.269 3.166 17.264 3.425 17.188L5.741 16.507C6.485 16.864 7.283 17.097 8.102 17.196C8.634 18.442 9.494 19.522 10.591 20.319C11.687 21.116 12.98 21.6 14.33 21.722C15.68 21.843 17.038 21.596 18.259 21.007L20.575 21.688C20.834 21.764 21.108 21.769 21.369 21.703C21.63 21.636 21.869 21.501 22.059 21.31C22.25 21.12 22.386 20.881 22.452 20.62C22.519 20.359 22.514 20.085 22.438 19.826ZM5.812 14.953C5.741 14.953 5.67 14.963 5.601 14.983L3 15.75L3.766 13.148C3.793 13.054 3.802 12.957 3.791 12.86C3.781 12.764 3.753 12.67 3.707 12.585C3.166 11.574 2.927 10.429 3.016 9.286C3.106 8.143 3.522 7.049 4.214 6.135C4.906 5.221 5.845 4.524 6.921 4.127C7.997 3.73 9.164 3.649 10.284 3.895C11.404 4.141 12.43 4.702 13.241 5.513C14.051 6.324 14.613 7.35 14.859 8.47C15.104 9.59 15.024 10.757 14.627 11.833C14.23 12.908 13.533 13.848 12.619 14.54C11.705 15.232 10.611 15.648 9.468 15.737C8.325 15.827 7.18 15.588 6.169 15.047C6.06 14.986 5.937 14.954 5.812 14.953M20.23 17.647L21 20.25L18.398 19.484C18.304 19.457 18.207 19.448 18.11 19.459C18.014 19.469 17.92 19.497 17.835 19.543C16.921 20.031 15.895 20.275 14.859 20.249C13.823 20.224 12.811 19.93 11.922 19.398C11.033 18.866 10.296 18.112 9.785 17.211C11.158 17.067 12.465 16.547 13.561 15.709C14.657 14.87 15.5 13.744 15.997 12.456C16.495 11.169 16.626 9.768 16.378 8.41C17.575 8.692 18.657 9.336 19.476 10.253C20.295 11.17 20.813 12.317 20.959 13.538C21.105 14.759 20.872 15.996 20.292 17.08C20.246 17.166 20.217 17.261 20.207 17.358C20.197 17.455 20.206 17.553 20.233 17.647Z',
        true,
        false
      )
    ],
    [
      (
        'M21.757 17.509C22.275 16.434 22.529 15.251 22.498 14.058C22.467 12.865 22.152 11.697 21.58 10.65C21.007 9.604 20.192 8.709 19.204 8.04C18.216 7.371 17.082 6.948 15.897 6.805C15.37 5.58 14.526 4.518 13.452 3.727C12.378 2.937 11.112 2.447 9.785 2.309C8.459 2.171 7.119 2.389 5.905 2.94C4.691 3.492 3.646 4.358 2.877 5.448C2.109 6.538 1.645 7.813 1.534 9.142C1.422 10.471 1.667 11.806 2.243 13.009L1.562 15.325C1.486 15.584 1.481 15.858 1.547 16.12C1.614 16.381 1.749 16.619 1.94 16.81C2.131 17.001 2.369 17.136 2.63 17.203C2.892 17.269 3.166 17.264 3.425 17.188L5.741 16.507C6.485 16.864 7.283 17.097 8.102 17.196C8.634 18.442 9.494 19.522 10.591 20.319C11.687 21.116 12.98 21.6 14.33 21.722C15.68 21.843 17.038 21.596 18.259 21.007L20.575 21.688C20.834 21.764 21.108 21.769 21.369 21.703C21.63 21.636 21.869 21.501 22.059 21.31C22.25 21.12 22.386 20.881 22.452 20.62C22.519 20.359 22.514 20.085 22.438 19.826ZM20.233 17.647L21 20.25L18.398 19.484C18.304 19.457 18.207 19.448 18.11 19.459C18.014 19.469 17.92 19.497 17.835 19.543C16.921 20.031 15.895 20.275 14.859 20.249C13.823 20.224 12.811 19.93 11.922 19.398C11.033 18.866 10.296 18.112 9.785 17.211C11.158 17.067 12.465 16.547 13.561 15.709C14.657 14.87 15.5 13.744 15.997 12.456C16.495 11.169 16.626 9.768 16.378 8.41C17.575 8.692 18.657 9.336 19.476 10.253C20.295 11.17 20.813 12.317 20.959 13.538C21.105 14.759 20.872 15.996 20.292 17.08C20.246 17.166 20.217 17.261 20.207 17.358C20.197 17.455 20.206 17.553 20.233 17.647',
        true,
        false
      )
    ]
  ),
  'อุบัติเหตุ': (
    [
      (
        'M22.2 17.633L14.002 3.396C13.797 3.047 13.504 2.758 13.153 2.557C12.802 2.356 12.405 2.25 12 2.25C11.595 2.25 11.198 2.356 10.847 2.557C10.496 2.758 10.203 3.047 9.998 3.396L1.8 17.633C1.603 17.971 1.499 18.355 1.499 18.745C1.499 19.136 1.603 19.52 1.8 19.857C2.002 20.208 2.294 20.499 2.646 20.7C2.998 20.901 3.397 21.004 3.802 21L20.198 21C20.603 21.004 21.002 20.9 21.353 20.699C21.704 20.498 21.996 20.208 22.198 19.857C22.396 19.52 22.5 19.136 22.5 18.746C22.5 18.355 22.397 17.971 22.2 17.633M20.9 19.106C20.828 19.228 20.726 19.329 20.602 19.398C20.479 19.467 20.34 19.502 20.198 19.5L3.802 19.5C3.66 19.502 3.521 19.467 3.398 19.398C3.274 19.329 3.172 19.228 3.1 19.106C3.036 18.997 3.001 18.872 3.001 18.744C3.001 18.617 3.036 18.492 3.1 18.383L11.299 4.145C11.372 4.023 11.475 3.923 11.598 3.853C11.721 3.784 11.86 3.747 12.002 3.747C12.143 3.747 12.283 3.784 12.406 3.853C12.529 3.923 12.632 4.023 12.705 4.145L20.903 18.383C20.968 18.492 21.001 18.618 21 18.745C21 18.872 20.965 18.997 20.9 19.106M11.25 13.5L11.25 9.75C11.25 9.592 11.3 9.437 11.393 9.309C11.486 9.181 11.618 9.086 11.768 9.037C11.919 8.988 12.081 8.988 12.232 9.037C12.382 9.086 12.514 9.181 12.607 9.309C12.7 9.437 12.75 9.592 12.75 9.75L12.75 13.5C12.75 13.658 12.7 13.813 12.607 13.941C12.514 14.069 12.382 14.164 12.232 14.213C12.081 14.262 11.919 14.262 11.768 14.213C11.618 14.164 11.486 14.069 11.393 13.941C11.3 13.813 11.25 13.658 11.25 13.5M13.125 16.875C13.125 17.097 13.059 17.315 12.935 17.5C12.812 17.685 12.636 17.829 12.431 17.914C12.225 18 11.999 18.022 11.781 17.978C11.562 17.935 11.362 17.828 11.205 17.67C11.047 17.513 10.94 17.313 10.897 17.094C10.853 16.876 10.875 16.65 10.961 16.444C11.046 16.239 11.19 16.063 11.375 15.94C11.56 15.816 11.778 15.75 12 15.75C12.197 15.75 12.391 15.802 12.562 15.901C12.734 15.999 12.876 16.141 12.974 16.312C13.073 16.484 13.125 16.678 13.125 16.875',
        true,
        false
      )
    ],
    [
      (
        'M22.2 17.633L14.002 3.396C13.797 3.047 13.504 2.758 13.153 2.557C12.802 2.356 12.405 2.25 12 2.25C11.595 2.25 11.198 2.356 10.847 2.557C10.496 2.758 10.203 3.047 9.998 3.396L1.8 17.633C1.603 17.971 1.499 18.355 1.499 18.745C1.499 19.136 1.603 19.52 1.8 19.857C2.002 20.208 2.294 20.499 2.646 20.7C2.998 20.901 3.397 21.004 3.802 21L20.198 21C20.603 21.004 21.002 20.9 21.353 20.699C21.704 20.498 21.996 20.208 22.198 19.857C22.396 19.52 22.5 19.136 22.5 18.746C22.5 18.355 22.397 17.971 22.2 17.633M11.25 9.75C11.25 9.592 11.3 9.437 11.393 9.309C11.486 9.181 11.618 9.086 11.768 9.037C11.919 8.988 12.081 8.988 12.232 9.037C12.382 9.086 12.514 9.181 12.607 9.309C12.7 9.437 12.75 9.592 12.75 9.75L12.75 13.5C12.75 13.658 12.7 13.813 12.607 13.941C12.514 14.069 12.382 14.164 12.232 14.213C12.081 14.262 11.919 14.262 11.768 14.213C11.618 14.164 11.486 14.069 11.393 13.941C11.3 13.813 11.25 13.658 11.25 13.5ZM12 18C11.778 18 11.56 17.934 11.375 17.81C11.19 17.687 11.046 17.511 10.961 17.306C10.875 17.1 10.853 16.874 10.897 16.656C10.94 16.437 11.047 16.237 11.205 16.08C11.362 15.922 11.562 15.815 11.781 15.772C11.999 15.728 12.225 15.75 12.431 15.836C12.636 15.921 12.812 16.065 12.935 16.25C13.059 16.435 13.125 16.653 13.125 16.875C13.125 17.072 13.073 17.266 12.974 17.438C12.876 17.609 12.734 17.751 12.562 17.849C12.391 17.948 12.197 18 12 18',
        true,
        false
      )
    ]
  ),
  'ถูกต้อง': (
    [
      (
        'M16.281 9.219C16.374 9.312 16.441 9.429 16.475 9.556C16.509 9.683 16.509 9.817 16.475 9.944C16.441 10.071 16.374 10.188 16.281 10.281L11.031 15.531C10.938 15.624 10.821 15.691 10.694 15.725C10.567 15.759 10.433 15.759 10.306 15.725C10.179 15.691 10.062 15.624 9.969 15.531L7.719 13.281C7.607 13.169 7.534 13.024 7.509 12.867C7.484 12.711 7.509 12.55 7.581 12.409C7.653 12.268 7.768 12.153 7.909 12.081C8.05 12.009 8.211 11.984 8.367 12.009C8.524 12.034 8.669 12.107 8.781 12.219L10.5 13.94L15.219 9.219C15.312 9.126 15.429 9.059 15.556 9.025C15.683 8.991 15.817 8.991 15.944 9.025C16.071 9.059 16.188 9.126 16.281 9.219M21.75 12C21.75 13.928 21.178 15.814 20.107 17.417C19.036 19.02 17.513 20.27 15.731 21.008C13.95 21.746 11.989 21.939 10.098 21.563C8.207 21.186 6.469 20.258 5.106 18.894C3.742 17.531 2.814 15.793 2.437 13.902C2.061 12.011 2.254 10.05 2.992 8.269C3.73 6.487 4.98 4.964 6.583 3.893C8.186 2.822 10.072 2.25 12 2.25C13.711 2.252 15.391 2.703 16.873 3.559C18.354 4.415 19.585 5.646 20.441 7.127C21.297 8.609 21.748 10.289 21.75 12M20.25 12C20.25 10.368 19.766 8.773 18.86 7.417C17.953 6.06 16.664 5.002 15.157 4.378C13.65 3.754 11.991 3.59 10.391 3.909C8.79 4.227 7.32 5.013 6.166 6.166C5.013 7.32 4.227 8.79 3.909 10.391C3.59 11.991 3.754 13.65 4.378 15.157C5.002 16.664 6.06 17.953 7.417 18.86C8.773 19.766 10.368 20.25 12 20.25C13.448 20.248 14.87 19.866 16.123 19.142C17.376 18.418 18.418 17.376 19.142 16.123C19.866 14.87 20.248 13.448 20.25 12',
        true,
        false
      )
    ],
    [
      (
        'M12 2.25C10.072 2.25 8.186 2.822 6.583 3.893C4.98 4.964 3.73 6.487 2.992 8.269C2.254 10.05 2.061 12.011 2.437 13.902C2.814 15.793 3.742 17.531 5.106 18.894C6.469 20.258 8.207 21.186 10.098 21.563C11.989 21.939 13.95 21.746 15.731 21.008C17.513 20.27 19.036 19.02 20.107 17.417C21.178 15.814 21.75 13.928 21.75 12C21.748 10.289 21.297 8.609 20.441 7.127C19.585 5.646 18.354 4.415 16.873 3.559C15.391 2.703 13.711 2.252 12 2.25M16.281 10.281L11.031 15.531C10.938 15.624 10.821 15.691 10.694 15.725C10.567 15.759 10.433 15.759 10.306 15.725C10.179 15.691 10.062 15.624 9.969 15.531L7.719 13.281C7.607 13.169 7.534 13.024 7.509 12.867C7.484 12.711 7.509 12.55 7.581 12.409C7.653 12.268 7.768 12.153 7.909 12.081C8.05 12.009 8.211 11.984 8.367 12.009C8.524 12.034 8.669 12.107 8.781 12.219L10.5 13.94L15.219 9.219C15.331 9.107 15.476 9.034 15.633 9.009C15.789 8.984 15.95 9.009 16.091 9.081C16.232 9.153 16.347 9.268 16.419 9.409C16.491 9.55 16.516 9.711 16.491 9.867C16.466 10.024 16.393 10.169 16.281 10.281',
        true,
        false
      )
    ]
  ),
};
