// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// key ของการ์ด V/S ใน section สัญญาณชีพ (ชิปใน AI Overview เลื่อนมาหา)
final Map<String, GlobalKey> _vsTileKeys = {};

/// การ์ด V/S ที่กำลังไฮไลต์หลังแตะชิปใน AI Overview
String? _vsFlash;

/// เมนูย่อยของแท็บการส่งตรวจในหน้าผู้ป่วย: 0 ประวัติ · 1 คัดกรอง
int _clyTriPage = 1;

/// ค่าอ้างอิงของแถวที่มีเกณฑ์ (ผู้ใหญ่ · ตามการ์ด V/S ของหน้าคัดกรอง) แสดงใน badge หลังค่า
String? _vsRefOf(String label) => switch (label) {
      final l when l.startsWith('อุณหภูมิ') => '36.5–37.5',
      final l when l.startsWith('ความดัน') => '90–139/60–89',
      final l when l.startsWith('อัตราการเต้น') => '60–100',
      final l when l.startsWith('อัตราการหายใจ') => '12–20',
      final l when l.startsWith('ออกซิเจน') => '≥ 92',
      final l when l.startsWith('ระดับความเจ็บปวด') => '0–3',
      _ => null,
    };

/// ค่าสัญญาณชีพนอกช่วงปกติ (ช่วงเดียวกับ [_vsRefOf]) · ไม่ใช่ V/S หรืออ่านไม่ได้ = false
bool _vsBad(String label, String value) {
  final n = [
    for (final x in RegExp(r'\d+(\.\d+)?').allMatches(value))
      double.parse(x.group(0)!)
  ];
  if (n.isEmpty) return false;
  final v = n.first;
  return switch (label) {
    final l when l.startsWith('อุณหภูมิ') => v < 36.5 || v > 37.5,
    final l when l.startsWith('ความดัน') =>
      v < 90 || v > 139 || (n.length > 1 && (n[1] < 60 || n[1] > 89)),
    final l when l.startsWith('อัตราการเต้น') => v < 60 || v > 100,
    final l when l.startsWith('อัตราการหายใจ') => v < 12 || v > 20,
    final l when l.startsWith('ออกซิเจน') => v < 92,
    _ => false,
  };
}

/// ประเภทกิจกรรมที่เลือกดูในหน้ากิจกรรมพยาบาล (ชื่อขั้นในเมนูขวา · null = ทั้งหมด)
String? _actKind;

/// แท็บซักประวัติในหน้ากิจกรรมพยาบาล: true = เทียบทุกครั้งเป็นกราฟ · false = ไทม์ไลน์
bool _actChart = false;

const Color _cyBgTop = Color(0xFFF1F3F4);
const Color _cyBgBottom = Color(0xFFF1F3F4);
const Color _cyGlass = _panel;
const Color _cyEdge = _line;
const Color _cySlate = _blue;

/// ระบบร่างกายบนราง: ไอคอน · ชื่อ · อวัยวะที่ไฮไลต์ · ค่าที่เกี่ยวข้อง
const List<(IconData, String, List<String>, List<String>)> _clySystems = [
  (Icons.person_search_outlined, 'ภาพรวม', [], []),
  (
    Icons.favorite_border_rounded,
    'หัวใจและหลอดเลือด',
    ['heart'],
    ['HR', 'BP', 'Lactate', 'Trop', 'K']
  ),
  (
    Icons.air_rounded,
    'ระบบหายใจ',
    ['lungs', 'trachea'],
    ['SpO₂', 'RR', 'pCO2', 'pO2']
  ),
  (
    Icons.psychology_outlined,
    'สมองและระบบประสาท',
    ['brain'],
    ['DTX', 'Glucose', 'Na', 'BT']
  ),
  (
    Icons.lunch_dining_outlined,
    'ทางเดินอาหาร',
    ['stomach', 'liver', 'intestine', 'pancreas', 'esophagus'],
    ['AST', 'ALT', 'Lipase', 'Amylase', 'Bili', 'Hb']
  ),
  (
    Icons.water_drop_outlined,
    'ไตและทางเดินปัสสาวะ',
    ['kidneys', 'bladder'],
    ['Cr', 'BUN', 'Na', 'K']
  ),
  (
    Icons.accessibility_new_rounded,
    'กระดูกและกล้ามเนื้อ',
    [],
    ['Hb', 'CK', 'Pain']
  ),
  (
    Icons.bloodtype_outlined,
    'เลือดและการติดเชื้อ',
    [],
    ['Hb', 'WBC', 'Plt', 'Lactate', 'BT']
  ),
];

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientOverviewPanelState on State<ErFlowHomeWidget> {
  /// ทิศที่เปลี่ยนแท็บล่าสุด (1 = ไปขวา · -1 = ไปซ้าย) ใช้เลื่อนหน้าใหม่เข้า
  int _tabDir = 1;

  /// อาการสำคัญของผู้บันทึกที่เลือกดู: HN → ลำดับ (ไม่มี = ล่าสุด)
  final Map<String, int> _ccPick = {};

  /// visit ที่เลือกดูผล Lab: HN → ลำดับ (0 = วันนี้)
  final Map<String, int> _labVisit = {};

  /// visit ที่เลือกดู HPI ในการ์ด CC: HN → ลำดับ (0 = วันนี้)
  final Map<String, int> _hpiVisit = {};

  /// ส่วน HPI ในการ์ด CC: เลื่อนมาให้เห็น + ไฮไลต์ชั่วครู่ (ปุ่ม "ดูประวัติ HPI")
  final GlobalKey _hpiSecKey = GlobalKey();
  bool _hpiFlash = false;
  Timer? _hpiFlashT;

  /// ผล Lab ที่เลือกไว้เปรียบเทียบข้าม visit (ชื่อรายการ)
  final Set<String> _labSel = {};
}

/// หมวดของคำสั่งแพทย์ ตามลำดับแสดง (หน้ากิจกรรมพยาบาล + ขั้นรับคำสั่งแพทย์)
const List<String> _orderCats = [
  'ยา / เวชภัณฑ์',
  'Lab',
  'X-ray / ตรวจพิเศษ',
  'หัตถการ / การพยาบาล',
];

extension _FeaturesPatientOverviewPanelPart on _ErFlowHomeWidgetState {
  /// ไปแท็บภาพรวม เลื่อนถึงส่วน HPI ในการ์ด CC แล้วไฮไลต์ค้าง 2.5s ค่อยจาง
  void _showHpiHistory() {
    _hpiFlashT?.cancel();
    setState(() {
      _detailTab = 0;
      _hpiFlash = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _hpiSecKey.currentContext;
      if (!mounted || ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          alignment: 0.1);
    });
    _hpiFlashT = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _hpiFlash = false);
    });
  }

  // ---- แผงขวา

  /// ไอคอน duotone ของแต่ละแท็บบนรางซ้าย (เทียบชื่อแท็บ): (เส้น, ทึบ)
  /// วาดทึบสีจางไว้ใต้เส้นสีเต็ม = สองโทน
  static const Map<String, (IconData, IconData)> _railIcons = {
    'ภาพรวม': (Icons.dashboard_outlined, Icons.dashboard_rounded),
    'การส่งตรวจ': (
      Icons.content_paste_search_outlined,
      Icons.content_paste_search_rounded
    ),
    'Lab': (Icons.science_outlined, Icons.science_rounded),
    'X-ray': (Icons.image_outlined, Icons.image_rounded),
    'ยา': (Icons.medication_outlined, Icons.medication_rounded),
    'ตรวจร่างกาย': (
      Icons.personal_injury_outlined,
      Icons.personal_injury_rounded
    ),
    'คำสั่งแพทย์': (Icons.assignment_outlined, Icons.assignment_rounded),
    'Fast track': (Icons.bolt_outlined, Icons.bolt_rounded),
    'EMR': (Icons.folder_shared_outlined, Icons.folder_shared_rounded),
    'ข้อมูลผู้ป่วย': (Icons.badge_outlined, Icons.badge_rounded),
    'Lab/X-Ray': (Icons.biotech_outlined, Icons.biotech_rounded),
    'กิจกรรมพยาบาล': (
      Icons.volunteer_activism_outlined,
      Icons.volunteer_activism_rounded
    ),
    'การวินิจฉัย': (Icons.history_outlined, Icons.history_rounded),
  };

  /// รางแท็บแนวตั้งแบบหน้าคัดกรอง (register_page _qTabsBody): ไอคอน + ชื่อ
  /// แท็บที่เลือก = แผ่นขาวเลื่อนไปหา ต่อกับแผงเนื้อหา มีมุมเว้าบน/ล่าง
  Widget _clyTabRail() {
    void go(int i) => setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          _tabDir = _tabOrder(i) >= _tabOrder(_detailTab) ? 1 : -1;
          _detailTab = i;
          _markSeen(_caseP().hn, i);
          _orderEditing = null;
        });
    final hn = _caseP().hn;
    // เคสที่เปิด fast track = มีเมนู Fast track ต่อท้ายราง
    _ftRailOn = _ftOf(hn).isNotEmpty;
    // เปลี่ยนไปเคสที่ไม่มี fast track ขณะอยู่แท็บนี้ = กลับภาพรวม
    if (!_ftRailOn && _detailTab == _ftTab) _detailTab = 0;
    // สูงเมนูย่อลงเมื่อเมนูเยอะ (เช่นมี Fast track) ให้ครบทุกเมนูในจอเดียว
    var tabH = 72.0;
    const tabGap = 4.0, slide = Duration(milliseconds: 260);
    final more = _moreTabIdx;
    final moreOn = more.contains(_detailTab);
    final bar = _barTabIdx;
    final onIdx = moreOn ? bar.length : bar.indexOf(_railLead(_detailTab));
    // เมนูย่อยที่เลือกในกลุ่ม: แท็บตรง + หน้าย่อยตรง (ประวัติ/คัดกรองเป็นแท็บเดียวกัน)
    int subSel(int lead) {
      final subs = _railSubs[lead] ?? const [];
      for (final (k, x) in subs.indexed) {
        if (x.$2 == _detailTab && (x.$3 == null || x.$3 == _clyTriPage)) {
          return k;
        }
      }
      return 0;
    }

    // แบบรางแท็บหน้าคัดกรอง: ไอคอน + ชื่อ · เลือก = ไอคอนฟ้า ชื่อเข้มตัวหนา
    // ไอคอน Phosphor: ไม่เลือก = Regular สีเทา · เลือก = Fill กรมท่า · ไม่มีในชุด = Material เดิม
    Widget head(IconData icon, String label, bool on,
            [IconData? fill, String? solar]) =>
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_solarRail[solar ?? label] case final sol?)
            _SolarIcon(solar ?? label,
                size: 24.0,
                stroke: 1.5,
                color: on ? _blue : _ink3,
                // Regular บางไป: หนาขึ้นเล็กน้อย (Fill ไม่ต้อง)
                // ไอคอนเส้นจาก Figma (ไม่มีแบบทึบ) เส้นบางกว่า = หนาเพิ่มทั้งสองสถานะ
                grow: (on ? 0.0 : 0.5) +
                    (_figmaRailIcons.contains(solar ?? label) ? 0.45 : 0.0),
                paths: on ? sol.$2 : sol.$1)
          else
            Icon(icon, size: 24.0, color: on ? _blue : _ink3),
          const SizedBox(height: 4.0),
          AnimatedDefaultTextStyle(
            duration: slide,
            style: _t(10.5,
                color: on ? _inkTitle : _ink3,
                weight: on ? FontWeight.w700 : FontWeight.w500),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ),
        ]);

    // เมนูย่อย: สูง 56 กดง่ายบนแท็บเล็ต · ที่เลือก = pill ฟ้าอ่อน ตัวฟ้า
    const subH = 56.0;
    Widget subItem(int lead, int k, (String, int, int?) x) {
      final on = subSel(lead) == k;
      final t = x.$1;
      return _Press(
        scale: 0.98,
        radius: 8.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            if (x.$2 != _detailTab) go(x.$2);
            if (x.$3 case final page?) setState(() => _clyTriPage = page);
          },
          // พื้น pill วาดแยก (เลื่อนตามแท็บที่เลือก) ที่นี่เหลือแค่ชื่อ
          child: Container(
            height: subH - 4.0,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 6.0, 4.0),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: slide,
              curve: Curves.easeOutCubic,
              style: _t(13.0,
                  color: on ? _blue : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w500),
              child: Text(t,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      );
    }

    Widget item(int i) {
      // กลุ่มที่มีเมนูย่อย: เลือกอยู่เมื่อแท็บปัจจุบันอยู่ในกลุ่ม
      final on = i == _railLead(_detailTab);
      final name = _railGroupName[i] ?? _detailTabs[i];
      final dot =
          (i == 6 && _labNewOf(hn).isNotEmpty) || (i == 3 && _orderNewOf(hn));
      final headBtn = _Press(
        radius: 16.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            // หัวกลุ่ม = เปิดเมนูย่อยแรก (ข้อมูลผู้ป่วย → EMR · Lab/X-Ray → Lab)
            go(_railSubs[i]?.first.$2 ?? i);
          },
          child: SizedBox(
            height: tabH,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                  child: head(_railIcons[name]?.$1 ?? Icons.circle_outlined,
                      name, on, _railIcons[name]?.$2)),
              if (dot) Positioned(right: 14.0, top: 10.0, child: _newDot(8.0)),
            ]),
          ),
        ),
      );
      final subs = _railSubs[i];
      if (subs == null) return headBtn;
      // เมนูย่อยกางใต้แท็บที่เลือก พร้อมแผ่นขาวที่ยืดตาม (แบบหน้าส่งตรวจ)
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        headBtn,
        AnimatedSize(
          duration: slide,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: on
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Stack(children: [
                    // pill ฟ้าอ่อนอันเดียว เลื่อนไปหาเมนูย่อยที่เลือก (ไม่จาง-ขึ้นใหม่)
                    AnimatedPositioned(
                      duration: slide,
                      curve: Curves.easeOutCubic,
                      left: 8.0,
                      right: 6.0,
                      top: subSel(i) * subH,
                      height: subH - 4.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (k, x) in subs.indexed) subItem(i, k, x),
                      ],
                    ),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]);
    }

    // มุมเว้าตรงรอยต่อแท็บกับแผง (ขาวเติมมุม เทาเจาะโค้ง)
    Widget fillet({required bool top}) => SizedBox(
          width: 16.0,
          height: 16.0,
          child: ColoredBox(
            color: _panel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: top
                    ? const BorderRadius.only(
                        bottomRight: Radius.circular(16.0))
                    : const BorderRadius.only(topRight: Radius.circular(16.0)),
              ),
            ),
          ),
        );

    // แผ่นขาวของแท็บที่เลือก + มุมเว้า เลื่อนไปพร้อมกัน
    Widget blob() => AnimatedPositioned(
          duration: slide,
          curve: Curves.easeOutCubic,
          top: onIdx * (tabH + tabGap),
          left: 0.0,
          right: 0.0,
          height: tabH +
              ((_railSubs[_railLead(_detailTab)]?.length ?? 0) > 0
                  ? _railSubs[_railLead(_detailTab)]!.length * subH + 10.0
                  : 0.0),
          child: IgnorePointer(
            child: Stack(clipBehavior: Clip.none, children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(16.0)),
                  ),
                ),
              ),
              // แท็บแรกชิดขอบบนแผง ไม่ต้องมีมุมเว้าด้านบน
              Positioned(
                right: 0.0,
                top: -16.0,
                child: AnimatedOpacity(
                    opacity: onIdx == 0 ? 0.0 : 1.0,
                    duration: slide,
                    child: fillet(top: true)),
              ),
              Positioned(right: 0.0, bottom: -16.0, child: fillet(top: false)),
            ]),
          ),
        );

    // แท็บรอง: เมนู "อื่น ๆ" (ที่เลือกอยู่แสดงชื่อแท็บนั้น)
    Widget moreTab() => PopupMenuButton<int>(
          tooltip: 'แท็บอื่น ๆ',
          position: PopupMenuPosition.under,
          color: _panel,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onSelected: go,
          itemBuilder: (_) => [
            for (final i in more)
              PopupMenuItem<int>(
                value: i,
                height: 40.0,
                child: Text(_detailTabs[i],
                    style: _t(12.0,
                        color: i == _detailTab ? _blue : _inkTitle,
                        weight: i == _detailTab
                            ? FontWeight.w700
                            : FontWeight.w500)),
              ),
          ],
          child: SizedBox(
            height: tabH,
            child: head(
                Icons.more_horiz_rounded,
                moreOn ? _detailTabs[_detailTab] : 'อื่น ๆ',
                moreOn,
                null,
                'อื่น ๆ'),
          ),
        );

    return SizedBox(
      width: 100.0,
      child: LayoutBuilder(builder: (context, box) {
        // +1 = ปุ่ม "อื่น ๆ"
        tabH = ((box.maxHeight / (bar.length + 1)) - tabGap).clamp(46.0, 72.0);
        return SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Stack(clipBehavior: Clip.none, children: [
            if (onIdx >= 0) blob(),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final i in bar) ...[item(i), const SizedBox(height: tabGap)],
              moreTab(),
            ]),
          ]),
        );
      }),
    );
  }

  Widget _clyPanel() {
    return ClipRect(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _clyTabRail(),
        ),
        // แผงเนื้อหาขาวแผ่นเดียว (แบบหน้าคัดกรอง) · แท็บแรกเลือก = มุมบนซ้ายเหลี่ยมต่อกับแท็บ
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(20.0).copyWith(
                  topLeft: _barTabIdx.first == _detailTab
                      ? Radius.zero
                      : const Radius.circular(20.0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // เปลี่ยนแท็บ: หน้าใหม่เลื่อนเข้าจากทิศของแท็บ (ขวา/ซ้ายตามลำดับบนแถบ)
                // พร้อมจาง ส่วนหน้าเดิมจางออกอยู่กับที่ · ไม่ซ้อนกันจนรก
                Expanded(
                  // ไปดูแหล่งอ้างอิงจากผลวิเคราะห์ AI: กรอบฟ้าเรืองรอบแผงชั่วครู่ (ไม่รับแตะ)
                  child: Stack(children: [
                    Positioned.fill(
                        child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (cur, prev) => Stack(
                          alignment: Alignment.topCenter,
                          children: [...prev, if (cur != null) cur]),
                      transitionBuilder: (child, a) {
                        final incoming = child.key == _clyBodyKey;
                        if (!incoming) {
                          // หน้าเดิม: จางเร็ว (ครึ่งแรกของเวลา) ไม่เลื่อน
                          return FadeTransition(
                            opacity: CurvedAnimation(
                                parent: a, curve: const Interval(0.5, 1.0)),
                            child: child,
                          );
                        }
                        return FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                                    begin: Offset(0.04 * _tabDir, 0.0),
                                    end: Offset.zero)
                                .animate(a),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: _clyBodyKey,
                        // เลือกรายการใน Order Set แล้ว: แผงขวาเป็นฟอร์มกรอกรายละเอียดของรายการนั้น
                        child: (_tplOn ? _tplOrders() : null) ??
                            (_orderEditing != null && _speechOpen
                                ? ListView(
                                    padding: const EdgeInsets.all(12.0),
                                    children: [_orderEditorCard()],
                                  )
                                : null) ??
                            (_loading ? _clyBodySkeleton() : null) ??
                            _clyTabAppear() ??
                            _clyBento(),
                      ),
                    )),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: _refFlash,
                          builder: (_, src, __) => AnimatedOpacity(
                            opacity: src == null ? 0.0 : 1.0,
                            duration:
                                Duration(milliseconds: src == null ? 700 : 180),
                            // ไม่ไฮไลต์ทั้งแผง: ไฮไลต์เฉพาะแถวที่อ้าง · ที่นี่เหลือแค่ป้ายบอกแหล่ง
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: src == null
                                  ? null
                                  : Container(
                                      margin: const EdgeInsets.only(top: 10.0),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: _blue,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Text('อ้างอิง: $src',
                                          style: _t(12.0,
                                              color: Colors.white,
                                              weight: FontWeight.w600)),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  /// เนื้อหาการ์ดขวาของแท็บอื่นนอกจากภาพรวม (null = ภาพรวม)
  /// หน้าแท็บที่ไม่ได้ห่อทีละชิ้น (X-ray, อุบัติเหตุ, นัดหมาย …) ปรากฏทั้งหน้าแบบเดียวกัน
  Widget? _clyTabAppear() {
    final b = _clyTabBody();
    if (b == null) return null;
    final perItem = _detailTab == 2 ||
        _detailTab == 3 ||
        _detailTab == 6 ||
        b is SingleChildScrollView;
    return perItem ? b : _Appear(index: 0, child: b);
  }

  /// หน้าข้อมูลแบบหน้าส่งตรวจ (register): หัว + รูปประกอบขวา แล้วการ์ดตามหัวข้อ
  /// การ์ด = (ชื่อ, แถว (หัวข้อ, ค่า, ผิดปกติ)) · ค่าผิดปกติสีแดง
  Widget _clyInfoPage(String title, String sub, String hero,
      List<(String, List<(String, String, bool)>)> cards,
      {Widget? tabs,
      Widget? below,
      String? by,
      String? at,
      Widget? heroArt,
      List<Widget> lead = const [],
      List<Widget> extra = const []}) {
    // ผู้บันทึกและวันเวลา: จากแถว "พยาบาลคัดกรอง / เวลา" + วันที่เข้าห้องฉุกเฉิน
    final tri = erTableFor(_caseP().hn, ErTab.triage).rows;
    String? cell(String k) =>
        tri.where((r) => r[1] == k).map((r) => r[2]).firstOrNull;
    final byRaw = cell('พยาบาลคัดกรอง / เวลา') ?? '-';
    final byParts = byRaw.split(' · ');
    final recBy = by ?? byParts.first;
    final recAt = at ??
        [
          if (cell('วันที่เข้าห้องฉุกเฉิน') case final d? when d != '-') d,
          if (byParts.length > 1) byParts[1],
        ].join(' ');
    Widget kv((String, String, bool) r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 170.0,
              child: Text(r.$1,
                  style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
            ),
            Expanded(
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    // ค่าที่มีเกณฑ์: ตัวเลขสีตามสถานะ (ปกติ เขียว · ผิดปกติ แดง)
                    Text(r.$2,
                        style: _t(14.0,
                            color: r.$3
                                ? _red
                                : (_vsRefOf(r.$1) != null && r.$2 != '-'
                                    ? _green
                                    : _inkTitle),
                            weight: FontWeight.w600)),
                    if (_vsRefOf(r.$1) case final ref? when r.$2 != '-')
                      // badge ค่าอ้างอิง แบบ chip ของ Google: สีบอกสถานะ
                      // ปกติ = เขียว (ติ๊ก) · ผิดปกติ = แดง (error)
                      Container(
                        height: 24.0,
                        padding: const EdgeInsets.fromLTRB(6.0, 0.0, 8.0, 0.0),
                        decoration: BoxDecoration(
                          color: (r.$3 ? _red : _green).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              r.$3
                                  ? Icons.error_outline_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14.0,
                              color: r.$3 ? _red : _green),
                          const SizedBox(width: 4.0),
                          Text('ค่าปกติ $ref',
                              style: _num(12.0,
                                  color: r.$3 ? _red : _green,
                                  weight: FontWeight.w600)),
                        ]),
                      ),
                  ]),
            ),
          ]),
        );
    Widget card(String name, List<(String, String, bool)> rows) => Container(
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
            const SizedBox(height: 6.0),
            for (final r in rows) kv(r),
          ]),
        );
    Widget head() =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: _t(28.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 4.0),
          Text(sub, style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
          if (recBy != '-') ...[
            const SizedBox(height: 8.0),
            // ข้อความบรรทัดเดียว ไม่มีไอคอน (น้ำหนักต่ำสุด w500)
            Text('บันทึกโดย $recBy${recAt.isEmpty ? '' : ' เมื่อ $recAt'}',
                style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ],
          if (tabs != null) ...[
            const SizedBox(height: 14.0),
            tabs,
          ],
        ]);
    // แผงแคบ (< 460) = ซ่อนรูปประกอบ ให้หัวข้อและ tab ใช้ความกว้างเต็ม ไม่ทับกัน
    return LayoutBuilder(builder: (context, box) {
      final art = box.maxWidth >= 460.0;
      // รูปหัวหน้า: สูง 84–110 ตามความกว้าง · กว้างไม่เกิน 1.45 เท่าของสูง (กันทับหัวข้อ)
      final artH = (box.maxWidth * 0.16).clamp(72.0, 110.0);
      return ListView(
        // ระยะบนน้อยลง หัวหน้าชิดขึ้น (เดิม 24)
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
        children: _appearAll([
          // หัวหน้าแบบหน้าส่งตรวจ: ชื่อ + คำอธิบายซ้าย · รูปประกอบชิดขวา
          if (below != null)
            // มีแถบ tab: รูปใหญ่ชิดขอบขวาการ์ด ปลายรูปยืนบนเส้นใต้ tab
            // ปลายรูปจางลง (bottom fade) ไม่ทับชื่อ tab
            Stack(clipBehavior: Clip.none, children: [
              if (art)
                // อยู่ในขอบการ์ดเสมอ (ไม่ล้นขวาจนรูปขาด) · สูงตามความกว้างแผง
                Positioned(
                  right: 0.0,
                  bottom: 1.0,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.55, 0.95],
                    ).createShader(r),
                    child: heroArt ??
                        Image.asset('assets/images/er_hero_$hero.png',
                            height: artH,
                            width: artH * 1.45,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight),
                  ),
                ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: EdgeInsets.only(right: art ? artH * 1.45 : 0.0),
                  child: head(),
                ),
                const SizedBox(height: 14.0),
                below,
                Container(height: 1.0, color: _line),
              ]),
            ])
          else
            IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(child: head()),
                  if (art) const SizedBox(width: 16.0),
                  // รูปยืนบนการ์ดแรก: ชิดล่างแถวหัว แล้วเลื่อนลงจนปลายรูปจมใต้การ์ด (แบบหน้าส่งตรวจ)
                  if (art)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.translate(
                        offset: const Offset(0.0, 24.0),
                        child: heroArt ??
                            Image.asset('assets/images/er_hero_$hero.png',
                                height: 96.0, fit: BoxFit.contain),
                      ),
                    ),
                ])),
          SizedBox(height: below != null ? 16.0 : 14.0),
          // ส่วนก่อนการ์ด (เช่น ปฏิทินนัด)
          ...lead,
          for (final (name, rows) in cards)
            if (rows.isNotEmpty) ...[
              card(name, rows),
              const SizedBox(height: 12.0),
            ],
          ...extra,
        ]),
      );
    });
  }

  /// แถวของตารางคัดกรองตามหมวด (ด้านซ้าย/ขวา ไม่มีบริบท = ใส่ชื่อหมวดนำหน้า)
  List<(String, String, bool)> _clyTriRows(Set<String> cats) {
    final t = erTableFor(_caseP().hn, ErTab.triage);
    return [
      for (final (i, r) in t.rows.indexed)
        if (cats.contains(r[0]))
          (
            r[0].startsWith('รูม่านตา') ? 'รูม่านตา ${r[1]}' : r[1],
            r[2],
            t.alerts.contains((i, 2)),
          ),
    ];
  }

  /// แท็บการส่งตรวจ = คัดกรอง (เมนูย่อยของ "ข้อมูลผู้ป่วย" บนราง คู่กับ EMR)
  Widget _clyTriageBody() =>
      // ประวัติย้ายไปรวมกับ EMR (แท็บ 9) · แท็บนี้เหลือคัดกรอง
      _clyTriageInfo();

  /// คัดกรอง: อาการ สัญญาณชีพ ระดับ ESI (แบบแท็บคัดกรองของหน้าส่งตรวจ)
  /// ข้อมูลจากจุดคัดกรองอย่างเดียว (ซักประวัติพยาบาลย้ายไปหน้ากิจกรรมพยาบาล)
  Widget _clyTriageInfo() => _clyTriageSent();

  /// หมวดของซักประวัติหนึ่งครั้ง ตามโครงหน้าซักประวัติ: แสดงทุกแถว ไม่ได้กรอก = "-"
  /// ใช้ทั้งแท็บพยาบาล (หน้าคัดกรอง) และไทม์ไลน์กิจกรรมพยาบาล
  List<(String, List<(String, String, bool)>)> _hxSections(
      Map<String, String> r) {
    final female = erCaseOf(_caseP().hn).sex.startsWith('ห');
    List<(String, String, bool)> rows(List<String> keys,
            [Map<String, String> names = const {}]) =>
        [
          for (final k in keys)
            (
              names[k] ?? k,
              (r[k] ?? '').isEmpty ? '-' : r[k]!,
              _vsBad(k, r[k] ?? '')
            ),
        ];
    return [
      ('อาการ', rows(const ['อาการสำคัญ'])),
      (
        'สัญญาณชีพ',
        rows(const [
          'ความดันโลหิต (mmHg)',
          'อัตราการเต้นหัวใจ (bpm)',
          'อัตราการหายใจ (/min)',
          'ออกซิเจนในเลือด (%)',
          'อุณหภูมิ (°C)',
        ])
      ),
      (
        'ข้อมูลร่างกาย',
        rows([
          'รอบเอว (cm)',
          'เส้นรอบศีรษะ (cm)',
          if (female) ...['ตั้งครรภ์', 'ให้นมบุตร', 'FP'],
          'G6PD',
        ], const {
          'FP': 'วางแผนครอบครัว'
        })
      ),
      ('ประวัติ', rows(const ['การแพ้ยา', 'การสูบบุหรี่', 'การดื่มสุรา'])),
    ];
  }

  /// หน้ากิจกรรมพยาบาล: หัวหน้าแบบหน้าคัดกรอง + ไทม์ไลน์ในการ์ด (ล่าสุดบนสุด)
  /// หมวดของคำสั่ง (ข้อมูลคำสั่งไม่มีหมวด: จัดจากไอคอน + คำในชื่อ)
  /// ใช้ร่วมกันระหว่างหน้ากิจกรรมพยาบาล (ซ้าย) และขั้นรับคำสั่งแพทย์ (แผง workflow)
  String _orderCat(_Task t) {
    final x = t.title;
    // ตัวย่อเป็นคำเต็ม (case-sensitive) ไม่ให้ "ct" ใน Lactate/Tazobactam หลุดเข้าหมวดนี้
    if (RegExp(r'\b(X-?ray|CT|CXR|MRI|EKG|ECG)\b').hasMatch(x) ||
        x.contains('อัลตราซาวด์')) {
      return 'X-ray / ตรวจพิเศษ';
    }
    if (t.icon == Icons.science_rounded ||
        t.icon == Icons.water_drop_rounded ||
        RegExp(r'เจาะ|เก็บ|CBC|Lactate|Troponin|DTX|culture|Lab',
                caseSensitive: false)
            .hasMatch(x)) {
      return 'Lab';
    }
    if (t.icon == Icons.medication_rounded || x.startsWith('ให้')) {
      return 'ยา / เวชภัณฑ์';
    }
    return 'หัตถการ / การพยาบาล';
  }

  /// คำสั่งแพทย์จัดตามหมวด (ยา/เวชภัณฑ์ · Lab · X-ray · หัตถการ/การพยาบาล)
  /// แต่ละรายการ: ชื่อ · ป้ายสถานะ (รอรับคำสั่ง / รอบ k/N / รับแล้ว) · ชิปเวลาที่สั่ง ผู้สั่ง จำนวนรอบ
  Widget _nurseOrderGroups() {
    final tasks = [
      for (final t in _allTasks)
        if (t.time.isNotEmpty) t
    ]..sort((a, b) => a.time.compareTo(b.time));
    String cat(_Task t) => _orderCat(t);

    const order = [
      'ยา / เวชภัณฑ์',
      'Lab',
      'X-ray / ตรวจพิเศษ',
      'หัตถการ / การพยาบาล'
    ];
    Widget status(_Task t) {
      final done = _taskDone.contains(t.title);
      final rec = _taskRounds[_roundKey(t)];
      final n =
          int.tryParse(RegExp(r'×(\d+)').firstMatch(t.title)?.group(1) ?? '') ??
              0;
      final (Color c, String txt) = done
          ? (_green, 'รับแล้ว')
          : rec != null && rec.isNotEmpty
              ? (_blue, 'รอบ ${rec.length}${n > 0 ? '/$n' : ''}')
              : (_ink3, 'รอรับคำสั่ง');
      return Text(txt, style: _t(12.5, color: c, weight: FontWeight.w600));
    }

    // บรรทัดสถานะแบบแถวคำสั่งในภาพรวม: สั่งเมื่อ/โดย · รับหรือรอบล่าสุด
    String sub(_Task t) {
      final at = _taskDoneAt[t.title];
      final by = _taskDoneBy[t.title];
      final rec = _taskRounds[_roundKey(t)];
      return [
        'สั่ง ${_clock(t.time)} ${t.by}',
        if (at != null) 'รับ ${_taskClock(at)}${by == null ? '' : ' $by'}',
        if (at == null && rec != null && rec.isNotEmpty)
          'รอบล่าสุด ${_taskClock(rec.last.$2)} ${rec.last.$1}',
      ].join('  ');
    }

    // แถวไทม์ไลน์แบบบันทึกการพยาบาล: เวลาสั่ง | จุด + เส้น | ชื่อ + ผู้สั่ง/ผู้รับ · สถานะขวา
    // จุด: รับแล้ว = เขียว · กำลังทำรอบ = น้ำเงิน · รอรับ = เทา
    Widget tlRow(_Task t, bool end) {
      final done = _taskDone.contains(t.title);
      final rec = _taskRounds[_roundKey(t)];
      final dot = done ? _green : (rec != null && rec.isNotEmpty ? _blue : _g5);
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 64.0,
            child: Text(_clock(t.time),
                style: _num(13.0, color: _ink2, weight: FontWeight.w600)),
          ),
          SizedBox(
            width: 16.0,
            child: Column(children: [
              const SizedBox(height: 5.0),
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              if (!end) Expanded(child: Container(width: 1.0, color: _line)),
            ]),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: end ? 4.0 : 14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: t.title,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                      if (t.urgent)
                        TextSpan(
                            text: '  ด่วน',
                            style:
                                _t(12.0, color: _red, weight: FontWeight.w700)),
                    ])),
                    const SizedBox(height: 2.0),
                    Text(
                        sub(t).replaceFirst(
                            RegExp(r'^สั่ง \S+ น\. '), 'สั่งโดย '),
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ),
          const SizedBox(width: 8.0),
          status(t),
        ]),
      );
    }

    final groups = <String, List<_Task>>{};
    for (final t in tasks) {
      (groups[cat(t)] ??= []).add(t);
    }
    // การ์ดละหมวด แบบการ์ดข้อมูลในหน้า (หัวข้อ + จำนวน) · แถวรายการภาษาเดียวกับ V/S
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final g in order)
        if (groups[g] case final list?)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 10.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(g,
                          style: _t(16.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    Text('${list.length} รายการ',
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 4.0),
                  const SizedBox(height: 8.0),
                  for (final (i, t) in list.indexed)
                    tlRow(t, i == list.length - 1),
                ]),
          ),
    ]);
  }

  Widget _clyNurseActPage() {
    final p = _caseP();
    // ล่าสุดบนสุด เรียงตามเวลาจริง (ข้อมูลเดิมบางเคสเรียงไม่ตรงเวลา)
    final all = [..._nurseNotesOf(p)]..sort((a, b) => b.time.compareTo(a.time));
    // หมวดของบันทึก = ขั้นในเมนูขวาของพยาบาล (ติดมากับบันทึก ไม่เดาจากข้อความ)
    String kindOf(ErNote n) => n.kind ?? 'การพยาบาล';

    // tab ตามลำดับเมนูขวา เฉพาะประเภทที่มีบันทึก
    final kinds = {for (final n in all) kindOf(n)};
    final tabs = [
      for (final st in _stepOrder)
        if (kinds.contains(_steps[st].$2)) _steps[st].$2
    ];
    if (_actKind != null && !tabs.contains(_actKind)) _actKind = null;
    final notes = [
      for (final n in all)
        if (_actKind == null || kindOf(n) == _actKind) n
    ];
    final last = notes.firstOrNull;
    // tab แบบ Google: ตัวหนังสือ + เส้นใต้น้ำเงินใต้ tab ที่เลือก เลื่อนแนวนอนได้
    Widget tab(String? k, String label) {
      final on = _actKind == k;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _actKind = k);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: _t(14.0,
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

    final tabBar = tabs.isEmpty
        ? null
        : Transform.translate(
            offset: const Offset(-12.0, 0.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                tab(null, 'ทั้งหมด'),
                for (final k in tabs) tab(k, k),
              ]),
            ),
          );
    // รายการซักประวัติ: หาบันทึกต้นทางจาก "ครั้งที่ n" แล้วแสดงเป็นหมวดแบบหน้าซักประวัติ
    final recs = _hxRecs[p.hn] ?? const <Map<String, String>>[];
    Map<String, String>? recOf(ErNote n) {
      final m = RegExp(r'^ซักประวัติ ครั้งที่ (\d+)').firstMatch(n.text);
      final k = m == null ? null : int.parse(m.group(1)!) - 1;
      return k != null && k < recs.length ? recs[k] : null;
    }

    Widget hxBody(Map<String, String> r) => Container(
          margin: const EdgeInsets.only(top: 6.0),
          padding: const EdgeInsets.fromLTRB(14.0, 10.0, 12.0, 10.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (gi, (name, rows)) in _hxSections(r).indexed) ...[
              if (gi > 0) const SizedBox(height: 8.0),
              Text(name,
                  style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
              for (final (k, v, _) in rows)
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150.0,
                          child: Text(k,
                              style: _t(12.0,
                                  color: _ink2, weight: FontWeight.w500)),
                        ),
                        Expanded(
                          child: Text(v,
                              style: _t(12.5,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                      ]),
                ),
            ],
          ]),
        );

    Widget row(int i, ErNote n) {
      final end = i == notes.length - 1;
      final rec = recOf(n);
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 64.0,
            child: Text(_clock(n.time),
                style: _num(13.0,
                    color: i == 0 ? _inkTitle : _ink3,
                    weight: FontWeight.w600)),
          ),
          SizedBox(
            width: 16.0,
            child: Column(children: [
              const SizedBox(height: 5.0),
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                    color: i == 0 ? _blue : _g5, shape: BoxShape.circle),
              ),
              if (!end) Expanded(child: Container(width: 1.0, color: _line)),
            ]),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: end ? 0.0 : 14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec == null ? n.text : n.text.split('\n').first,
                        style: _t(14.0,
                            color: _inkTitle,
                            weight: i == 0 ? FontWeight.w600 : FontWeight.w500,
                            height: 1.45)),
                    if (rec != null) hxBody(rec),
                    const SizedBox(height: 2.0),
                    Text(n.by,
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ),
        ]),
      );
    }

    // แท็บซักประวัติ: สลับไทม์ไลน์ / เทียบเป็นกราฟ (segmented แบบ Google)
    final hxTab = _actKind == 'ซักประวัติ' && recs.isNotEmpty;
    final chart = hxTab && _actChart;
    Widget modeBtn(bool c, IconData ic, String label) {
      final on = _actChart == c;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _actChart = c);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(10.0, 6.0, 12.0, 6.0),
            decoration: BoxDecoration(
              color: on ? _blue.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ic, size: 16.0, color: on ? _blue : _ink2),
              const SizedBox(width: 6.0),
              Text(label,
                  style: _t(13.0,
                      color: on ? _blue : _ink2,
                      weight: on ? FontWeight.w600 : FontWeight.w500)),
            ]),
          ),
        ),
      );
    }

    final modeBar = Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        modeBtn(false, Icons.view_agenda_outlined, 'ไทม์ไลน์'),
        modeBtn(true, Icons.show_chart_rounded, 'กราฟเปรียบเทียบ'),
      ]),
    );

    final timeline = Container(
      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('บันทึกทางการพยาบาล',
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text(chart ? 'เทียบ ${recs.length} ครั้ง' : '${notes.length} บันทึก',
              style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          if (hxTab) ...[const SizedBox(width: 12.0), modeBar],
        ]),
        const SizedBox(height: 12.0),
        if (chart)
          _hxCompare(recs)
        else if (notes.isEmpty)
          Text('ยังไม่มีบันทึกทางการพยาบาล',
              style: _t(13.0, color: _ink3, weight: FontWeight.w500))
        else
          for (final (i, n) in notes.indexed) row(i, n),
      ]),
    );
    return _clyInfoPage(
        'กิจกรรมพยาบาล', 'บันทึกการพยาบาลตามเวลา', 'nurse_act', const [],
        by: last?.by ?? '-',
        at: last == null ? '' : _clock(last.time),
        // แถบ tab เต็มความกว้างใต้หัวหน้า (ในคอลัมน์ข้างรูปแคบไป)
        below: tabBar,
        // คำสั่งแพทย์ตามหมวด + สถานะ (ต้นแบบหน้ากิจกรรมพยาบาล HOSxP) เหนือไทม์ไลน์
        // แสดงผลอย่างเดียว · รับคำสั่งที่แผงขวา
        extra: [
          if (_actKind == null || _actKind == 'รับคำสั่งแพทย์') ...[
            _nurseOrderGroups(),
            const SizedBox(height: 12.0),
          ],
          timeline,
        ]);
  }

  /// เทียบซักประวัติทุกครั้ง: กราฟต่อค่า (เส้นโค้ง ค่ากำกับทุกจุด เวลาใต้จุด ครั้งล่าสุดจุดใหญ่)
  /// แล้วตารางข้อมูลอื่นเทียบทีละครั้ง (เปลี่ยนจากครั้งก่อน = ตัวหนาน้ำเงิน)
  Widget _hxCompare(List<Map<String, String>> recs) {
    List<double> nums(String? v) => [
          for (final m in RegExp(r'\d+(\.\d+)?').allMatches(v ?? ''))
            double.parse(m.group(0)!)
        ];
    String timeOf(Map<String, String> r) =>
        r['เวลา'] == null ? '' : '${r['เวลา']} น.';
    String fmt(String key, double v) => key.startsWith('อุณหภูมิ')
        ? v.toStringAsFixed(1)
        : v == v.roundToDouble()
            ? v.toInt().toString()
            : v.toStringAsFixed(1);
    // ลำดับเดียวกับการ์ด V/S ในหน้าซักประวัติ: น้ำหนัก ส่วนสูง รอบเอว เส้นรอบศีรษะ
    // แล้ว BP HR RR BT SpO₂
    const metrics = [
      ('น้ำหนัก (kg)', 'น้ำหนัก', 'kg'),
      ('ส่วนสูง (cm)', 'ส่วนสูง', 'cm'),
      ('รอบเอว (cm)', 'รอบเอว', 'cm'),
      ('เส้นรอบศีรษะ (cm)', 'เส้นรอบศีรษะ', 'cm'),
      ('ความดันโลหิต (mmHg)', 'ความดันโลหิต', 'mmHg'),
      ('อัตราการเต้นหัวใจ (bpm)', 'อัตราการเต้นหัวใจ', 'bpm'),
      ('อัตราการหายใจ (/min)', 'อัตราการหายใจ', '/min'),
      ('อุณหภูมิ (°C)', 'อุณหภูมิ', '°C'),
      ('ออกซิเจนในเลือด (%)', 'ออกซิเจนในเลือด', '%'),
    ];
    final charted = [
      for (final m in metrics)
        if (recs.any((r) => nums(r[m.$1]).isNotEmpty)) m
    ];

    // ช่วงค่าปกติ (ตัวบนของ BP) ใช้วาดแถบในกราฟ · เกณฑ์เดียวกับ _vsBad
    (double, double)? refOf(String key) => switch (key) {
          final k when k.startsWith('อุณหภูมิ') => (36.5, 37.5),
          final k when k.startsWith('ความดัน') => (90.0, 139.0),
          final k when k.startsWith('อัตราการเต้น') => (60.0, 100.0),
          final k when k.startsWith('อัตราการหายใจ') => (12.0, 20.0),
          final k when k.startsWith('ออกซิเจน') => (92.0, 100.0),
          _ => null,
        };

    Widget tile((String, String, String) m) {
      final (key, name, unit) = m;
      // แกน x เดียวกันทุกการ์ด = ซักประวัติทุกครั้ง · ครั้งที่ไม่ได้วัด = ช่องว่าง
      final vals = [for (final r in recs) nums(r[key])];
      final idx = [
        for (var i = 0; i < vals.length; i++)
          if (vals[i].isNotEmpty) i
      ];
      final last = idx.last;
      final lastV = vals[last];
      final bp = key.startsWith('ความดัน');
      final bad = _vsBad(key, recs[last][key]!);
      final ref = _vsRefOf(key);
      return Container(
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5, color: _inkTitle, weight: FontWeight.w600)),
            ),
            if (ref != null)
              Text('ปกติ $ref',
                  style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
          ]),
          const SizedBox(height: 2.0),
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                    bp && lastV.length > 1
                        ? '${fmt(key, lastV[0])}/${fmt(key, lastV[1])}'
                        : fmt(key, lastV[0]),
                    style: _num(22.0,
                        color: bad ? _red : _inkTitle,
                        weight: FontWeight.w700)),
                const SizedBox(width: 4.0),
                Text(unit,
                    style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                if (idx.length > 1) ...[
                  const SizedBox(width: 8.0),
                  _vsDeltaChip(
                      vals[idx.first][0], lastV[0], bad ? _red : _ink2),
                ] else ...[
                  const SizedBox(width: 8.0),
                  Text('วัดครั้งเดียว',
                      style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                ],
              ]),
          const SizedBox(height: 6.0),
          SizedBox(
            // สูงเท่ากันทุกใบ: การ์ดแถวเดียวกันขอบล่างตรงกัน (BP ต้องมีที่ให้ค่าตัวล่าง)
            height: 96.0,
            child: CustomPaint(
              size: Size.infinite,
              painter: _HxCmpChart(
                values: [for (final v in vals) v.isEmpty ? null : v[0]],
                values2: bp
                    ? [for (final v in vals) v.length > 1 ? v[1] : null]
                    : null,
                labels: [for (final v in vals) v.isEmpty ? '' : fmt(key, v[0])],
                ref: refOf(key),
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          // เวลาใต้แต่ละช่อง (ช่องกว้างเท่ากัน = ตรงกับจุดในกราฟ) เฉพาะครั้งที่วัด
          // ช่องแคบ (หลายครั้ง) = แสดงแค่ครั้งแรกกับครั้งล่าสุดที่วัด ไม่ให้เวลาชนกัน
          LayoutBuilder(builder: (context, box) {
            final roomy = box.maxWidth / recs.length >= 60.0;
            return Row(children: [
              for (var i = 0; i < recs.length; i++)
                Expanded(
                  child: Text(
                      vals[i].isNotEmpty &&
                              (roomy || i == idx.first || i == last)
                          ? timeOf(recs[i])
                          : '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: _num(11.0,
                          color: i == last ? _inkTitle : _ink3,
                          weight: FontWeight.w500)),
                ),
            ]);
          }),
        ]),
      );
    }

    // ตารางข้อมูลอื่น (ไม่ใช่ค่าที่มีกราฟแล้ว) แถวที่ว่างทุกครั้งไม่แสดง
    final keys = <String>[];
    final cells = <Map<String, String>>[];
    final skip = {for (final m in charted) m.$1, 'อาการสำคัญ'};
    for (final r in recs) {
      final m = <String, String>{};
      for (final (sec, rows) in _hxSections(r)) {
        if (sec == 'สัญญาณชีพ') continue;
        for (final (k, v, _) in rows) {
          if (skip.contains(k)) continue;
          m[k] = v;
          if (!keys.contains(k)) keys.add(k);
        }
      }
      cells.add(m);
    }
    keys.removeWhere((k) => cells.every((m) => (m[k] ?? '-') == '-'));

    final table = Table(
      columnWidths: const {0: FixedColumnWidth(150.0)},
      defaultColumnWidth: const FixedColumnWidth(140.0),
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        TableRow(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAED)))),
          children: [
            const SizedBox.shrink(),
            for (final (i, r) in recs.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ครั้งที่ ${i + 1}',
                          style: _t(12.5,
                              color: _inkTitle, weight: FontWeight.w600)),
                      Text(timeOf(r),
                          style: _num(11.5,
                              color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
          ],
        ),
        for (final k in keys)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 12.0),
              child: Text(k,
                  style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
            ),
            for (final (i, m) in cells.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                child: Builder(builder: (_) {
                  final v = m[k] ?? '-';
                  final changed = i > 0 && v != (cells[i - 1][k] ?? '-');
                  return Text(v,
                      style: _t(12.5,
                          color: changed ? _blue : _inkTitle,
                          weight: changed ? FontWeight.w700 : FontWeight.w500));
                }),
              ),
          ]),
      ],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (charted.isEmpty)
        Text('ยังไม่มีค่าสัญญาณชีพให้เทียบ',
            style: _t(13.0, color: _ink3, weight: FontWeight.w500))
      else
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 520.0 ? 2 : 1;
          final w = (box.maxWidth - 12.0 * (cols - 1)) / cols;
          // จำนวนคี่: ใบท้ายเต็มแถว ไม่ให้อยู่เดี่ยวครึ่งแถว
          final wide = cols == 2 && charted.length.isOdd;
          return Wrap(spacing: 12.0, runSpacing: 12.0, children: [
            for (final (i, m) in charted.indexed)
              SizedBox(
                  width: wide && i == charted.length - 1 ? box.maxWidth : w,
                  child: _Appear(index: i, child: tile(m))),
          ]);
        }),
      if (keys.isNotEmpty) ...[
        const SizedBox(height: 20.0),
        Text('ข้อมูลอื่น',
            style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
        const SizedBox(height: 2.0),
        Text('ตัวหนาสีน้ำเงิน คือค่าที่เปลี่ยนจากครั้งก่อน',
            style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
        const SizedBox(height: 10.0),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: table),
      ],
    ]);
  }

  /// แท็บการส่งตรวจ: ข้อมูลจากจุดคัดกรอง
  Widget _clyTriageSent() => _clyInfoPage(
          'การส่งตรวจ', 'ข้อมูลที่บันทึกจากหน้าคัดกรองและส่งตรวจ', 'triage', [
        ('อาการ', _clyTriRows({'ประเภทผู้ป่วย', 'อาการสำคัญ'})),
        (
          'สัญญาณชีพ',
          _clyTriRows({
            'Vital Sign',
            'การประเมินระดับความรู้สึกตัว (GCS)',
            'ระดับความเจ็บปวด',
            'รูม่านตา (Pupils)'
          })
        ),
        ('ระดับ ESI', _clyTriRows({'ระดับความเร่งด่วน (ESI)', 'ผู้คัดกรอง'})),
      ]);

  Widget? _clyTabBody() {
    if (_detailTab == _ftTab && _ftOf(_caseP().hn).isEmpty) _detailTab = 0;
    if (_detailTab == 1) return _clyTriageBody();
    // แท็บแล็บ: เลือกรายการเปรียบเทียบข้าม visit ก่อน แล้วตามด้วยตารางผลเต็ม
    if (_detailTab == 6) {
      return ListView(
        padding: const EdgeInsets.all(12.0),
        children: _appearAll([
          _labTabCompare(),
          const SizedBox(height: 10.0),
          ErDetailTable(hn: _caseP().hn, tab: ErTab.labs),
        ]),
      );
    }
    final table =
        _detailTab < _tabTables.length ? _tabTables[_detailTab] : null;
    if (table != null && (_tableOnly || (_hasToggle && _tableView))) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: _Appear(
            index: 0, child: ErDetailTable(hn: _caseP().hn, tab: table)),
      );
    }
    return switch (_detailTab) {
      2 => _examPage(),
      // สั่งการรักษาใน workflow: สำรับการ์ดเต็มความสูงแผง (ไม่อยู่ในรายการเลื่อน)
      3 when _soDeckOn => _soDeck(),
      // แท็บคำสั่งแพทย์: หน้าข้อมูลแบบ EMR (tab ครั้งที่บันทึก + การ์ด One Day / Continuation)
      3 => _orderRecord(),
      8 => _kbPanel(),
      _apptTab => _apptTabBody(),
      _mcTab => _mcTabBody(),
      _obsTab => _obsTabBody(),
      _accTab => _accTabBody(),
      _xrayTab => _xrayTabBody(),
      _nurseTab => _clyNurseActPage(),
      _ftTab => _ftTabBody(),
      _reDiagTab => _reDiagPage(),
      9 => _emrTab(),
      10 => _progressTab(),
      _ => null,
    };
  }

  /// ห่อแต่ละชิ้นในหน้าให้ปรากฏไล่กัน (ช่องว่าง SizedBox ไม่นับลำดับ)
  List<Widget> _appearAll(List<Widget> items) {
    var n = 0;
    return [
      for (final w in items)
        w is SizedBox && w.child == null ? w : _Appear(index: n++, child: w)
    ];
  }

  ValueKey<String> get _clyBodyKey => ValueKey(
      'cly$_detailTab$_tableView${_orderEditing ?? ''}${_tplOn ? 'tpl' : ''}');

  /// แท็บของหน้าผู้ป่วย ย้ายจากแถบบนมาอยู่หัวการ์ดขวา
  /// แท็บแบบ Google: pill tonal บนพื้นหน้า ไม่มีการ์ดครอบ
  Widget _clyTabs() => Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        // แท็บที่เลือกกว้าง (ชื่อ) ที่เหลือแบ่งเท่ากันเป็นปุ่มไอคอน
        // ความกว้างเปลี่ยนแบบมี animation ตอนสลับแท็บ · แท็บรองอยู่ในเมนู "อื่น ๆ"
        child: LayoutBuilder(builder: (context, box) {
          final tabs = [..._barTabIdx, -1];
          final moreOn = _moreTabIdx.contains(_detailTab);
          bool isOn(int i) => i == -1 ? moreOn : i == _detailTab;
          const activeW = 120.0;
          final anyOn = tabs.any(isOn);
          final restW = (box.maxWidth - (anyOn ? activeW : 0.0)) /
              (tabs.length - (anyOn ? 1 : 0));
          return Row(children: [
            for (final i in tabs)
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: isOn(i) ? activeW : restW,
                child: i == -1 ? _moreTabItem() : _detailTabItem(i),
              ),
          ]);
        }),
      );

  /// พื้นการ์ด (clean flat): ขาวเรียบ + เส้นขอบ 0.5 ไม่มีเงา
  /// การ์ดหลักแบบ Google (Ads/AdSense) เดียวกับหน้าคัดกรอง: ขาว ขอบเทา #DADCE0 มุม 16 ไม่มีเงา
  BoxDecoration get _clyCardDeco => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      );

  /// พื้นการ์ดย่อย (ค่าแต่ละตัว): ขาวเรียบ ขอบบอกสถานะ (แดง = ผิดปกติ)
  /// การ์ดย่อยแบบหน้าคัดกรอง: ขาว ขอบเทามุม 16 · ขอบสีเมื่อบอกสถานะ
  BoxDecoration _clyTileDeco({Color edge = _line}) => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
            color: edge == _line ? const Color(0xFFDADCE0) : edge,
            width: edge == _line ? 0.5 : 1.5),
      );

  /// การ์ดสัญญาณชีพ: ค่าล่าสุด + แท่งย้อนหลังเล็ก ๆ ต่อค่า
  /// อาการสำคัญ (CC) ตัวเต็ม ย้ายจากแถบบนมาไว้บนสุดของภาพรวม
  /// อาการสำคัญ (บันทึกได้หลายคน เลือกดูของแต่ละคน) + HPI
  Widget _clyCc() {
    final c = _case;
    final recs = erCcRecords(c);
    // HPI ที่แพทย์บันทึกใน workflow ก่อน · ไม่มีใช้ของเดิมในแฟ้ม
    String hpi = c.hpi;
    if (_speechHn == c.hn) {
      for (final m in _filled) {
        final v = (m['HPI'] ?? '').trim();
        // ยังเป็น template ที่มีช่อง [ ] ค้าง = ยังเขียนไม่เสร็จ ใช้ของในแฟ้มก่อน
        if (v.isNotEmpty && (!v.contains('[') || c.hpi.isEmpty)) {
          // เอาเครื่องหมาย rich text (# **) ออกก่อนแสดง/คัดลอกในการ์ด
          hpi = _richPlain(v);
          break;
        }
      }
    }
    // หัวแบบการ์ดคำสั่งแพทย์: ชื่อใหญ่ + บรรทัดรอง · ไม่มี avatar ซ้อนบนหัว (ชื่อไม่ถูกตัด)
    // เนื้อหา: อาการล่าสุด (หลายคนบันทึก = สรุป AI) แล้วไทม์ไลน์คอลัมน์เวลาแบบกิจกรรมพยาบาล
    final multi = recs.length > 1;
    final aiRes = multi ? _ccAi[c.hn] : null;
    if (multi &&
        aiRes == null &&
        !_ccAiBusy.contains(c.hn) &&
        !_ccAiErr.containsKey(c.hn)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ccAiRun(c.hn, recs));
    }
    final latest = recs.isEmpty ? null : recs.last;
    final lead = aiRes != null
        ? aiRes.sum
            .map((sg) => sg.text.trim())
            .where((t) => t.isNotEmpty)
            .join(' ')
        : (latest?.text ?? c.cc);
    final ccCopy = recs.isEmpty ? c.cc : lead;

    // แถวไทม์ไลน์: เวลา | จุด + เส้น | อาการ ณ เวลานั้น + ผู้บันทึก
    Widget tlRow(int i) {
      final r = recs[i];
      final last = i == recs.length - 1;
      // AI บอกสิ่งที่เปลี่ยนในช่วงนั้น (ตัดเวลาที่ AI ใส่ซ้ำหน้าข้อความ) · ไม่มี = ข้อความที่บันทึกจริง
      final note = aiRes != null && i < aiRes.time.length
          ? aiRes.time[i].text
              .replaceFirst(
                  RegExp(r'^\s*\d{1,2}[:.]\d{2}\s*(น\.)?\s*[:\-–·]?\s*'), '')
              .trim()
          : r.text;
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 52.0,
            child: Text(_clock(r.time),
                style: _num(12.0,
                    color: last ? _inkTitle : _ink3, weight: FontWeight.w600)),
          ),
          SizedBox(
            width: 14.0,
            child: Column(children: [
              const SizedBox(height: 5.0),
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                    color: last ? _blue : _g5, shape: BoxShape.circle),
              ),
              if (!last) Expanded(child: Container(width: 1.0, color: _line)),
            ]),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0.0 : 12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note,
                        style: _t(12.5,
                            color: _inkTitle,
                            weight: last ? FontWeight.w600 : FontWeight.w500,
                            height: 1.4)),
                    const SizedBox(height: 2.0),
                    Text('${r.role}  ${r.who}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
      decoration: _clyCardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('อาการสำคัญ',
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 2.0),
                    Text(
                        latest == null
                            ? 'จากจุดคัดกรอง'
                            : multi
                                ? 'บันทึก ${recs.length} ครั้ง ล่าสุด ${_clock(latest.time)}'
                                : '${latest.role}  ${_clock(latest.time)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
                  ]),
            ),
            _copyBtn('CC + HPI', () => 'CC: $ccCopy\nHPI: $hpi',
                iconOnly: true),
          ]),
          const SizedBox(height: 12.0),
          // อาการปัจจุบัน: ตัวใหญ่สุดของการ์ด
          _copyable(
              'CC',
              ccCopy,
              Text(lead.isEmpty ? '—' : lead,
                  style: _t(14.0,
                      color: _inkTitle, weight: FontWeight.w500, height: 1.5))),
          if (multi) ...[
            const SizedBox(height: 4.0),
            Row(children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 13.0, color: aiRes == null ? _ink3 : _blue),
              const SizedBox(width: 4.0),
              Flexible(
                child: Text(
                    aiRes != null
                        ? 'สรุปโดย AI จากบันทึก ${recs.length} ครั้ง ตรวจทานก่อนใช้'
                        : _ccAiBusy.contains(c.hn)
                            ? 'AI กำลังสรุปจากบันทึก ${recs.length} ครั้ง'
                            : 'บันทึกล่าสุด',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 14.0),
            Text('อาการตามช่วงเวลา',
                style: _t(12.5, color: _ink2, weight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            for (var i = 0; i < recs.length; i++) tlRow(i),
          ],
          const SizedBox(height: 12.0),
          const Divider(height: 1.0, color: _line),
          const SizedBox(height: 8.0),
          // HPI แยกตาม visit: วันนี้ + visit ก่อนหน้า (แสดง CC ของ visit นั้นด้วย)
          Builder(builder: (context) {
            final hv = erHpiVisits(c);
            // visit ก่อนหน้าดูในหน้า EMR (ไม่มีแถบเลือก visit ซ้ำในภาพรวม)
            const hi = 0;
            final text = hi == 0 ? hpi : hv[hi].hpi;
            return AnimatedContainer(
              key: _hpiSecKey,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: _hpiFlash
                    ? _blue.withValues(alpha: 0.06)
                    : _blue.withValues(alpha: 0.0),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    color: _hpiFlash ? _blue : _blue.withValues(alpha: 0.0),
                    width: 1.5),
              ),
              // หัว (ชื่อ · คัดลอก) → แถวเลือก visit → กล่องเนื้อหา (ที่มา · CC · HPI)
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('ประวัติปัจจุบัน (HPI)',
                            style: _t(15.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                      ),
                      _copyBtn('HPI', () => text, iconOnly: true),
                    ]),
                    const SizedBox(height: 8.0),
                    // timeline การบันทึก HPI: เวลา | จุด + เส้น | ข้อความ + แพทย์ผู้บันทึก
                    // ครั้งแรก = HPI ในแฟ้ม (แพทย์เจ้าของไข้ เวลาเข้า ER) · ต่อด้วยที่แก้ใน workflow
                    Builder(builder: (context) {
                      final tri = erTableFor(c.hn, ErTab.triage).rows;
                      String cell(String k) =>
                          tri
                              .where((r) => r[1] == k)
                              .map((r) => r[2])
                              .firstOrNull ??
                          '-';
                      final info = {
                        for (final r
                            in erTablesFor(c.hn, ErTab.overview).first.rows)
                          r[0]: r[1]
                      };
                      final log = <(String, String, String)>[
                        if (c.hpi.trim().isNotEmpty)
                          (
                            cell('เวลาที่เข้าห้องฉุกเฉิน'),
                            info['แพทย์เจ้าของไข้'] ?? '-',
                            c.hpi
                          ),
                        ...?_hpiLog[c.hn],
                      ];
                      if (log.isEmpty) {
                        return Text('ยังไม่ได้บันทึก',
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500));
                      }
                      Widget row(int i) {
                        final (time, who, t) = log[i];
                        final last = i == log.length - 1;
                        final hm = RegExp(r'^\d{1,2}:\d{2}').firstMatch(time);
                        return IntrinsicHeight(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 52.0,
                                  child: Text(
                                      hm == null ? time : _clock(hm.group(0)!),
                                      style: _num(12.0,
                                          color: last ? _inkTitle : _ink3,
                                          weight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 14.0,
                                  child: Column(children: [
                                    const SizedBox(height: 5.0),
                                    Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                          color: last ? _blue : _g5,
                                          shape: BoxShape.circle),
                                    ),
                                    if (!last)
                                      Expanded(
                                          child: Container(
                                              width: 1.0, color: _line)),
                                  ]),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: last ? 0.0 : 14.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _copyable(
                                              'HPI',
                                              _richPlain(t),
                                              Text(_prettyHpi(_richPlain(t)),
                                                  // ครั้งก่อนย่อ · ล่าสุดเต็ม
                                                  maxLines: last ? null : 3,
                                                  overflow: last
                                                      ? null
                                                      : TextOverflow.ellipsis,
                                                  style: _t(12.5,
                                                      color: last
                                                          ? _inkTitle
                                                          : _ink2,
                                                      weight: last
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      height: 1.45))),
                                          const SizedBox(height: 2.0),
                                          Text(
                                              i == 0 && c.hpi.trim().isNotEmpty
                                                  ? 'บันทึกโดย $who'
                                                  : 'แก้โดย $who',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: _t(11.0,
                                                  color: _ink3,
                                                  weight: FontWeight.w500)),
                                        ]),
                                  ),
                                ),
                              ]),
                        );
                      }

                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < log.length; i++) row(i),
                          ]);
                    }),
                  ]),
            );
          }),
        ],
      ),
    );
  }

  /// pill เลือก visit ของ HPI: ขาวขอบเทา · ที่เลือก = กรมท่า
  Widget _hpiVisitPill(String label, bool on, VoidCallback onTap) => _Press(
        child: Material(
          // Google filter chip: เลือก = พื้นฟ้าอ่อน ตัวกรมท่า · ไม่เลือก = ขอบเทา
          color: on ? _blue.withValues(alpha: 0.1) : _panel,
          shape: StadiumBorder(
              side: BorderSide(
                  color: on ? Colors.transparent : const Color(0xFFDADCE0))),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(label,
                  style: _t(10.5,
                      color: on ? _blue : _ink2, weight: FontWeight.w600)),
            ),
          ),
        ),
      );

  /// แถวในกล่อง HPI: ป้ายหัวแถวกว้างเท่ากัน (CC / HPI) + เนื้อหา
  Widget _hpiRow(String label, Widget child) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38.0,
          margin: const EdgeInsets.only(top: 1.0, right: 10.0),
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(label,
              style: _t(9.5, color: _blueHue, weight: FontWeight.w700)),
        ),
        Expanded(child: child),
      ]);

  Widget _clyVitals() {
    // ใช้ HR ชื่อเดียวทั้งระบบ (เลิกแยก PR/Pulse ที่ใช้ค่าชุดเดียวกัน)
    final vs = _caseVitals();
    return Container(
      // ส่วนหนึ่งของแผงขาว ไม่ครอบเป็นการ์ดซ้อน (ลดกล่องในกล่อง)
      // ไม่มี padding ข้าง: ขอบการ์ด V/S ตรงกับการ์ดอื่นใน bento (ListView เว้น 12 แล้ว)
      // ล่าง 0: ระยะถึงการ์ดถัดไปมาจาก bento (10) เท่าช่องว่างอื่นในหน้า
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // หัวการ์ด: ชื่อซ้าย · เวลาวัดล่าสุดชิดขวาสุด
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('สัญญาณชีพ',
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ]),
            ),
            Text('วัดล่าสุด ${_clock(_case.times.last)}',
                style: _t(12.0, color: _ink3)),
          ]),
          const SizedBox(height: 12.0),
          // ค่าร่างกาย (น้ำหนัก ส่วนสูง BMI BSA) อยู่บน stat card
          _bodyRow(),
          const SizedBox(height: 14.0),
          // แผงแคบ: ขึ้นแถวใหม่แทนการบีบ (ช่องไม่แคบกว่า 112 กราฟอ่านออก)
          _vsBento(vs),
        ],
      ),
    );
  }

  /// สัดส่วนร่างกายใต้สัญญาณชีพ: น้ำหนัก · ส่วนสูง · BMI · BSA (มีหน่วยทุกค่า)
  /// ปุ่มขอวัดสัญญาณชีพซ้ำ · ขอแล้ว = ป้ายสถานะ "ขอวัดซ้ำแล้ว hh:mm" (รอพยาบาล)
  Widget _vsRecheckBtn() {
    final req = _vsRecheck;
    return _Press(
      child: GestureDetector(
        // เปิดลิ้นชักกรอกค่า (ขอให้พยาบาลวัดได้จากในลิ้นชัก)
        onTap: _openVsDrawer,
        child: Container(
          height: 32.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.center,
          // ปุ่ม pill แบบ Google (เหมือนปุ่มบนหน้าคัดกรอง)
          decoration: BoxDecoration(
            color: req == null ? _blue : _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(req == null ? Icons.replay_rounded : Icons.schedule_rounded,
                size: 13.0, color: req == null ? Colors.white : _blue),
            const SizedBox(width: 4.0),
            Text(req == null ? 'วัดซ้ำ' : 'ขอวัดซ้ำแล้ว ${req.time} น.',
                style: _t(10.0,
                    color: req == null ? Colors.white : _blue,
                    weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  /// icon ของ HOSxP+ (glyph ขาวพื้นโปร่ง ย้อมสีได้) ตามชื่อค่าสัญญาณชีพ/ร่างกาย
  static const Map<String, String> _vsGlyph = {
    'HR': 'assets/images/heart-rate_(1).png',
    'Pulse': 'assets/images/pulse-rate.png',
    'BP': 'assets/images/blood-pressure_(1).png',
    'SpO₂': 'assets/images/o2.png',
    'RR': 'assets/images/lungs_(1).png',
    'BT': 'assets/images/thermometer.png',
    'น้ำหนัก': 'assets/images/weight-scale_(1).png',
    'ส่วนสูง': 'assets/images/height_(1).png',
    'BMI': 'assets/images/bmi.png',
  };

  Widget _vsIcon(String label, IconData fallback, double size, Color color) {
    final a = _vsGlyph[label];
    if (a == null) return Icon(fallback, size: size, color: color);
    return Image.asset(a,
        width: size,
        height: size,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (_, __, ___) => Icon(fallback, size: size, color: color));
  }

  Widget _bodyRow() {
    final b = erBody(_case);
    String n1(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    final bt = _case.bt.last;
    // ค่าผิดปกติเป็นแดง: BT นอก 36.0–37.5 °C · BMI นอก 18.5–24.9 (WHO)
    // น้ำหนัก / ส่วนสูง / BSA ไม่มีช่วงปกติตายตัว
    final items = [
      ('น้ำหนัก', n1(b.kg), 'kg', false),
      ('ส่วนสูง', '${b.cm}', 'cm', false),
      // อุณหภูมิล่าสุด ต่อจากส่วนสูง (แถวนี้ต้องคงเดิม ผู้ใช้ยืนยัน 2026-10-14)
      ('BT', n1(bt), '°C', bt < 36.0 || bt > 37.5),
      ('BMI', b.bmi.toStringAsFixed(1), 'kg/m²', b.bmi < 18.5 || b.bmi >= 25.0),
      ('BSA', b.bsa.toStringAsFixed(2), 'm²', false),
    ];
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      // แผงแคบ: ค่าเรียงต่อกันขึ้นบรรทัดใหม่ (ไม่มีเส้นคั่น) แทนการบีบจนล้น
      child: LayoutBuilder(builder: (context, box) {
        // ไอคอนกึ่งกลางแนวตั้งของแถว · ข้อความ (ชื่อ ค่า หน่วย) ยังเรียงตาม baseline
        Widget item(int i) => Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(items[i].$1,
                      style: _t(12.0, color: items[i].$4 ? _red : _ink3)),
                  const SizedBox(width: 6.0),
                  Text(items[i].$2,
                      style: _num(16.0,
                          color: items[i].$4 ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  const SizedBox(width: 2.0),
                  Text(items[i].$3, style: _t(11.0, color: _ink3)),
                ],
              )),
            ]);
        if (box.maxWidth < items.length * 118.0) {
          return Wrap(spacing: 16.0, runSpacing: 6.0, children: [
            for (var i = 0; i < items.length; i++) item(i),
          ]);
        }
        return Row(children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                  width: 1.0,
                  height: 18.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  color: _line),
            Expanded(child: item(i)),
          ],
        ]);
      }),
    );
  }

  /// การ์ดผลแล็บล่าสุด: ค่า · H/L · ช่วงอ้างอิง · ตำแหน่งเทียบช่วงปกติ
  Widget _clyLabs() {
    final visits = erLabVisits(_case);
    // ภาพรวม = visit นี้เท่านั้น (visit ก่อนหน้าดูใน EMR / แท็บ Lab)
    const vi = 0;
    // toggle eGFR: แสดงเฉพาะ lab ใน profile ไต (eGFR คำนวณจาก Cr + BUN Cr Na K Cl HCO₃)
    // หมู่เลือดอยู่บนหัวผู้ป่วยแล้ว ไม่ซ้ำในการ์ดนี้
    final labs = _sortLabs([
      for (final l in _egfrOn ? _egfrProfile(visits[vi].labs) : visits[vi].labs)
        if (l.name != 'Blood group') l
    ]);
    const per = 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Text('ผลแล็บ',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            const SizedBox(width: 8.0),
            // eGFR เป็น profile ที่ดูประจำ: เปิด/ปิดแถวได้
            _egfrToggle(),
            const Spacer(),
            if (labs.isNotEmpty) ...[
              _copyBtn(_egfrOn ? 'Lab (eGFR)' : 'Lab',
                  () => labs.map(_labCopy).join(', ')),
              const SizedBox(width: 6.0),
              Text(
                  'ผิดปกติ ${labs.where((l) => l.abnormal).length}/${labs.length}',
                  style: _t(9.5, color: _ink3)),
              const SizedBox(width: 6.0),
            ],
            _Press(
              child: GestureDetector(
                onTap: () => setState(() => _detailTab = 6),
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    gradient: _glossWhite,
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(color: _line, width: 0.5),
                    boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                  ),
                  foregroundDecoration: const _InnerGloss(7.0),
                  child: const Icon(Icons.north_east_rounded,
                      size: 14.0, color: _inkTitle),
                ),
              ),
            ),
          ]),
          if (vi > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('${visits[vi].place} · ${visits[vi].date}',
                  style: _t(9.5, color: _ink3)),
            ),
          const SizedBox(height: 8.0),
          if (labs.isEmpty)
            Text('ยังไม่มีผลแล็บ', style: _t(11.0, color: _ink3))
          else
            // แผงแคบ: ลดคอลัมน์ (ช่องไม่แคบกว่า 110) สูงสุด 5
            _clyCardGrid([
              for (final l in labs) _flashWrap('lab:${l.name}', _clyLabTile(l))
            ], per: per, gap: 6.0, minW: 110.0),
        ],
      ),
    );
  }

  /// การ์ดผล Lab หนึ่งรายการ ตามชนิด: ตัวเลข (H/L + แถบจุด) · ข้อความ · ภาพ
  /// แตะ = เลือก/เอาออกจากการเปรียบเทียบ (วงกรมท่า = เลือกอยู่)
  Widget _clyLabTile(ErLab l, {bool pick = false}) {
    // pick = โหมดเลือกเปรียบเทียบ (แท็บแล็บ) · ภาพรวม: แตะแล้วไปเทียบที่แท็บแล็บ
    final on = pick && _labSel.contains(l.name);
    final hi = l.isNumeric && l.value > l.hi,
        lo = l.isNumeric && l.value < l.lo;
    final bad = l.abnormal;
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    Widget flag(String t) => Container(
          constraints: const BoxConstraints(minWidth: 15.0),
          height: 15.0,
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _glossGrad(_red),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: _glossLift(_red),
          ),
          foregroundDecoration: const _InnerGloss(4.0, dark: true),
          child: Text(t,
              style: _t(8.5, color: Colors.white, weight: FontWeight.w800)),
        );
    final body = switch (l.type) {
      ErLabType.numeric => [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(f(l.value),
                      style: _num(15.0,
                          color: bad ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  Text(' | ', style: _t(9.0, color: _ink3)),
                  // eGFR เกณฑ์ปกติเป็นขั้นต่ำ (≥ 60) ไม่ใช่เพดาน
                  Text(l.name == 'eGFR' ? '≥${f(l.lo)}' : f(l.hi),
                      style: _num(9.5, color: _ink3)),
                ]),
          ),
          const SizedBox(height: 6.0),
          _labDots(l.value, l.hi, bad, dots: 10),
        ],
      ErLabType.text => [
          Text(l.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _t(12.5,
                  color: bad ? _red : _inkTitle, weight: FontWeight.w600)),
        ],
      ErLabType.image => [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Image.asset(l.image,
                height: 34.0, width: double.infinity, fit: BoxFit.cover),
          ),
          if (l.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(l.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5,
                      color: bad ? _red : _ink2, weight: FontWeight.w600)),
            ),
        ],
    };
    return _Press(
      child: GestureDetector(
        onLongPress: () => _copyText(l.name, _labCopy(l)),
        onTap: () => setState(() {
          if (!pick) {
            _labSel
              ..clear()
              ..add(l.name);
            _detailTab = 6;
          } else if (on) {
            _labSel.remove(l.name);
          } else {
            _labSel.add(l.name);
          }
        }),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 8.0),
          decoration: _clyTileDeco(edge: on ? _blue : _line).copyWith(
              border:
                  Border.all(color: on ? _blue : _line, width: on ? 1.6 : 1.0)),
          foregroundDecoration: const _InnerGloss(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (l.type != ErLabType.numeric) ...[
                  Icon(
                      l.type == ErLabType.image
                          ? Icons.image_rounded
                          : Icons.notes_rounded,
                      size: 11.0,
                      color: _ink3),
                  const SizedBox(width: 3.0),
                ],
                Expanded(
                  child: Text(l.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(9.5, color: _ink2)),
                ),
                // ป้าย H/L แบบรายงานแล็บ · ข้อความ/ภาพที่ผิดปกติ = !
                if (hi || lo) flag(hi ? 'H' : 'L') else if (bad) flag('!'),
                // ผลใหม่ที่ยังไม่เปิดดู
                if (_labNewOf(_case.hn).contains(l.name)) ...[
                  const SizedBox(width: 4.0),
                  _newDot(8.0),
                ],
              ]),
              const SizedBox(height: 2.0),
              ...body,
            ],
          ),
        ),
      ),
    );
  }

  /// การ์ดเปรียบเทียบในแท็บแล็บ: กริดผลล่าสุด (แตะเลือกได้หลายรายการ) + ตารางข้าม visit
  Widget _labTabCompare() {
    final visits = erLabVisits(_case);
    final names = <String>{};
    final latest = <ErLab>[
      for (final v in visits)
        for (final l in v.labs)
          if (names.add(l.name)) l
    ];
    const per = 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('เปรียบเทียบผล Lab',
            style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        for (var i = 0; i < latest.length; i += per)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0.0 : 6.0),
            child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + per; j++) ...[
                      if (j > i) const SizedBox(width: 6.0),
                      Expanded(
                          child: j < latest.length
                              ? _clyLabTile(latest[j], pick: true)
                              : const SizedBox.shrink()),
                    ],
                  ]),
            ),
          ),
        if (_labSel.isNotEmpty) _labCompare(visits),
      ]),
    );
  }

  /// ตารางเปรียบเทียบผล Lab ที่เลือก ข้าม visit (เก่า → ใหม่) + การเปลี่ยนแปลงล่าสุด
  Widget _labCompare(
      List<({String date, String place, List<ErLab> labs})> visits) {
    final cols = visits.reversed.toList(); // เก่า → ใหม่
    String short(String d) {
      const m = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ];
      final p = d.split('/');
      if (p.length != 3) return d;
      return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
    }

    ErLab? at(int c, String name) {
      for (final l in cols[c].labs) {
        if (l.name == name) return l;
      }
      return null;
    }

    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);

    Widget cell(ErLab? l) {
      if (l == null) return Text('—', style: _t(11.0, color: _ink3));
      if (l.type == ErLabType.image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Image.asset(l.image, height: 56.0, fit: BoxFit.cover),
        );
      }
      return Text(l.resultText,
          style: _num(12.0,
              color: l.abnormal ? _red : _inkTitle, weight: FontWeight.w600));
    }

    // การเปลี่ยนแปลง: ครั้งล่าสุดเทียบครั้งก่อนหน้าที่มีผล
    Widget change(String name) {
      final seq = [
        for (var c = 0; c < cols.length; c++)
          if (at(c, name) case final l?) l
      ];
      if (seq.length < 2) {
        return Text('ครั้งแรก', style: _t(10.0, color: _ink3));
      }
      final a = seq[seq.length - 2], b = seq.last;
      if (b.isNumeric && a.isNumeric) {
        final d = b.value - a.value;
        if (d == 0) return Text('คงเดิม', style: _t(10.0, color: _ink3));
        final pct = a.value == 0 ? 0 : (d / a.value * 100).round();
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              d > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 12.0,
              color: b.abnormal ? _red : _ink2),
          Text('${f(d.abs())} (${pct.abs()}%)',
              style: _num(10.5,
                  color: b.abnormal ? _red : _ink2, weight: FontWeight.w600)),
        ]);
      }
      final same = a.resultText == b.resultText;
      return Text(same ? 'คงเดิม' : 'เปลี่ยน',
          style: _t(10.0,
              color: same ? _ink3 : (b.abnormal ? _red : _ink2),
              weight: FontWeight.w600));
    }

    final names = [
      for (final v in visits)
        for (final l in v.labs)
          if (_labSel.contains(l.name)) l.name
    ].toSet().toList();

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.compare_arrows_rounded, size: 14.0, color: _ink2),
          const SizedBox(width: 5.0),
          Expanded(
            child: Text('เปรียบเทียบการเปลี่ยนแปลง',
                style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
          ),
          InkWell(
            onTap: () => setState(_labSel.clear),
            child: Text('ล้าง',
                style: _t(10.0, color: _blue, weight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6.0),
        Table(
          columnWidths: {
            0: const FlexColumnWidth(1.6),
            for (var c = 0; c < cols.length; c++)
              c + 1: const FlexColumnWidth(),
            cols.length + 1: const FlexColumnWidth(1.3),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Text('รายการ', style: _t(9.5, color: _ink3)),
              for (var c = 0; c < cols.length; c++)
                Text(c == cols.length - 1 ? 'วันนี้' : short(cols[c].date),
                    style: _t(9.5,
                        color: c == cols.length - 1 ? _blue : _ink3,
                        weight: FontWeight.w600)),
              Text('เปลี่ยนแปลง', style: _t(9.5, color: _ink3)),
            ]),
            for (final n in names)
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _line))),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(n,
                        style: _t(10.5,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  for (var c = 0; c < cols.length; c++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: cell(at(c, n)),
                    ),
                  change(n),
                ],
              ),
          ],
        ),
      ]),
    );
  }

  /// แถบจุดของค่าแล็บ (แบบเดิมจากการ์ดแล็บ ผัง 181:3803)
  /// จุดถี่ ๆ บอกระดับ ขีดคั่นคือเพดานปกติ จุดที่เลยขีดคือส่วนที่ผิดปกติ
  Widget _labDots(double value, double hi, bool bad, {int dots = 16}) {
    final tone = bad ? _red : _blue;
    final scale = hi * 1.45;
    final filled = ((value / scale) * dots).round().clamp(0, dots);
    final markAt = ((hi / scale) * dots).round().clamp(1, dots - 1);
    return Container(
      height: 12.0,
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(children: [
        for (var i = 0; i < dots; i++) ...[
          if (i == markAt)
            Container(
              width: 1.2,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              color: _ink3,
            ),
          Expanded(
            child: Center(
              child: Container(
                width: 3.0,
                height: 3.0,
                decoration: BoxDecoration(
                  color: i < filled ? tone : _ink3.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  /// แตะการ์ด V/S = preview กราฟลอยเหนือการ์ด (แตะที่อื่น = ปิด)
  Widget _vsPeek(ErVital v, Widget tile) => _VsPeek(
      preview: () => _clyVitalTile(v, fill: true, big: true, reveal: true),
      child: tile);

  /// การ์ด V/S ใน bento: มี key ให้ชิป AI เลื่อนมาหา + กรอบฟ้าไฮไลต์ชั่วครู่
  Widget _vsFlashWrap(ErVital v, Widget tile) => _flashWrap(v.label, tile);

  /// การ์ดที่ชิปใน AI Overview ชี้มาได้ (V/S = ชื่อค่า · แล็บ = 'lab:ชื่อ')
  Widget _flashWrap(String id, Widget tile) => KeyedSubtree(
        key: _vsTileKeys.putIfAbsent(id, GlobalKey.new),
        // passthrough: การ์ดได้ขนาดจากแม่เหมือนไม่มี wrapper (แถวแล็บไม่มีความสูงตายตัว)
        child: Stack(fit: StackFit.passthrough, children: [
          tile,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _vsFlash == id ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: _blue, width: 3.0),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );

  /// แตะชิปใน AI Overview: เลื่อนไปการ์ดค่านั้นใน section สัญญาณชีพ แล้วไฮไลต์
  void _vsJump(String label, [int tries = 0]) {
    final c = _vsTileKeys[label]?.currentContext;
    if (c == null) {
      // การ์ดยังไม่ถูกสร้าง (รายการเลื่อนสร้างทีละส่วน) = เลื่อนลงทีละหน้าจอแล้วหาใหม่
      if (tries >= 6) return;
      final anchor = _vsTileKeys.values
          .map((k) => k.currentContext)
          .whereType<BuildContext>()
          .firstOrNull;
      final pos = anchor == null ? null : Scrollable.maybeOf(anchor)?.position;
      if (pos == null || pos.pixels >= pos.maxScrollExtent) return;
      pos
          .animateTo(
              math.min(pos.pixels + pos.viewportDimension * 0.8,
                  pos.maxScrollExtent),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut)
          .then((_) {
        if (mounted) _vsJump(label, tries + 1);
      });
      return;
    }
    if (tries == 0) HapticFeedback.selectionClick();
    Scrollable.ensureVisible(c,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.3);
    setState(() => _vsFlash = label);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _vsFlash == label) setState(() => _vsFlash = null);
    });
  }

  /// stat card สัญญาณชีพ: แตะ/ลากบนแท่งเพื่อเลือกรอบการวัด · แตะสองครั้ง = กลับล่าสุด
  /// หัวการ์ดแสดงค่าและเวลาของรอบที่เลือก · ใต้แท่งมีเวลาวัดทุกรอบ
  /// การ์ดค่าสัญญาณชีพหนึ่งค่า · of = เคสอื่น (การ์ดรายเตียง) ไม่ใส่ = เคสที่เปิดอยู่
  /// [bedCard] = การ์ดในผังเตียง: บอกเวลาที่ตรวจต่อท้ายชื่อค่า · มุมขวาเว้นให้ปุ่ม ‹ ›
  /// bento เรียงตามใบคัดกรอง: BP → PR → RR → BT → SpO₂ (→ HR จาก monitor)
  /// แถวบน BP ใหญ่ (2 ส่วน กราฟสูง) + PR · แถวล่างที่เหลือการ์ดเล็กเรียงกัน
  Widget _vsBento(List<ErVital> vs) {
    // HR ใหญ่ซ้าย (สูงสองแถว มีกราฟ) · ขวา 2x2: BP RR / BT SpO₂ (ค่าอย่างเดียว แตะดูกราฟ)
    ErVital? by(String l) => vs.where((v) => v.label == l).firstOrNull;
    const gap = 10.0, cellH = 96.0;
    final hr = by('HR');
    final rest = [
      for (final l in const ['BP', 'RR', 'BT', 'SpO₂'])
        if (by(l) case final v?) v,
    ];
    Widget cell(ErVital v) => SizedBox(
        height: cellH,
        child: _vsPeek(
            v,
            _vsFlashWrap(
                v, _clyVitalTile(v, compact: true, chart: false, fill: true))));
    final grid = Column(children: [
      for (var r = 0; r < rest.length; r += 2) ...[
        if (r > 0) const SizedBox(height: gap),
        Row(children: [
          Expanded(child: cell(rest[r])),
          const SizedBox(width: gap),
          Expanded(
              child: r + 1 < rest.length
                  ? cell(rest[r + 1])
                  : const SizedBox.shrink()),
        ]),
      ],
    ]);
    if (hr == null) return grid;
    final rows = (rest.length + 1) ~/ 2;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 4,
        child: SizedBox(
          height: rows * cellH + (rows - 1) * gap,
          child: _vsPeek(
              hr, _vsFlashWrap(hr, _clyVitalTile(hr, big: true, fill: true))),
        ),
      ),
      const SizedBox(width: gap),
      // ช่อง 2x2 กว้างกว่า HR เล็กน้อย ค่าคู่ (BP) ไม่ถูกย่อจนอ่านยาก
      Expanded(flex: 6, child: grid),
    ]);
  }

  Widget _clyVitalTile(ErVital v,
      {ErCase? of,
      bool big = false,
      bool bedCard = false,
      bool compact = false,
      bool fill = false,
      bool chart = true,
      bool reveal = false}) {
    final n = v.series.length;
    final ts = (of ?? _case).times;
    final pick = (_vsPick[v.label] ?? n - 1).clamp(0, n - 1);
    final latest = pick == n - 1;
    final bad = v.color == _red;
    String timeAt(int i) => i < ts.length ? ts[i] : '';
    void choose(double dx, double w) {
      final i = (dx / w * n).floor().clamp(0, n - 1);
      if (i != _vsPick[v.label]) setState(() => _vsPick[v.label] = i);
    }

    // Material 3: ค่าผิดปกติ = error container (แดงอ่อน) ตัวเลข/กราฟสีแดง
    // ค่าปกติ = surface container (เทาอ่อน) ไม่มีเส้นขอบ
    // ป้ายชื่อ/เวลาไม่แดง (แดงเฉพาะตัวเลขกับกราฟ) ลดพื้นที่สีแดง
    const w1 = Colors.white;
    final dim = Colors.white.withValues(alpha: 0.8);
    final fillC = bad
        ? Colors.white.withValues(alpha: 0.3)
        : _blue.withValues(alpha: 0.14);
    // กราฟเต็มการ์ด: หัว/ค่ามี padding · กราฟ + เวลาชิดขอบซ้ายขวาล่าง
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // แบบการ์ดหน้าคัดกรอง: ขาว ขอบเทา มุม 12 · ย้อนดูรอบเก่า = ขอบสี
        // ค่าผิดปกติ = แดงทึบ ตัวอักษร/กราฟขาว (แบบการ์ดหน้าคัดกรอง)
        color: bad ? _red : _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
            color: latest
                ? (bad ? _red : const Color(0xFFDADCE0))
                : (bad ? Colors.white : _blue),
            width: latest ? 0.5 : 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวการ์ดแบบหน้าคัดกรอง: ชื่อ + ค่าปกติจาง · ค่าใหญ่ · ชื่อไทย + เวลา | ไอคอนวงกลมขวาบน
          _vsHead(
            !chart && fill,
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16.0, 14.0, 12.0, !chart && fill ? 14.0 : 0.0),
              child: Stack(fit: StackFit.passthrough, children: [
                Row(
                    crossAxisAlignment: !chart && fill
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            mainAxisAlignment: !chart && fill
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right: bedCard
                                        ? 0.0
                                        : (compact ? 36.0 : 48.0)),
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                        text:
                                            v.label == 'Pulse' ? 'PR' : v.label,
                                        style: _t(15.0,
                                            color: bad ? w1 : _inkTitle,
                                            weight: FontWeight.w600)),
                                    // เวลาที่วัด (ของรอบที่ดู) ต่อท้ายชื่อ
                                    TextSpan(
                                        text: '   ${_ago(timeAt(pick))}',
                                        style: _t(11.0,
                                            color: bad
                                                ? dim
                                                : (latest ? _ink3 : _blue),
                                            weight: FontWeight.w500)),
                                  ]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              // ค่าตัวเลขขนาดเท่ากันทุกการ์ด: ที่ไม่พอ = ตัดหน่วยก่อน แล้วตัดตัวเปลี่ยนแปลง
                              // (BP "88/56 mmHg ↓24" ยาวกว่าเพื่อน เดิมย่อทั้งแถวจนตัวเล็ก)
                              LayoutBuilder(builder: (context, box) {
                                final val = latest
                                    ? (v.display ?? _vsValue(v, pick, of))
                                    : _vsValue(v, pick, of);
                                final valSt = _num(compact ? 22.0 : 26.0,
                                    color: bad ? w1 : _inkTitle,
                                    weight: FontWeight.w700);
                                final unitSt =
                                    _t(12.0, color: bad ? dim : _ink3);
                                final sc = MediaQuery.textScalerOf(context);
                                double tw(String t, TextStyle st) =>
                                    (TextPainter(
                                            text: TextSpan(text: t, style: st),
                                            textDirection: TextDirection.ltr,
                                            textScaler: sc)
                                          ..layout())
                                        .width;
                                final d = pick > 0
                                    ? (v.series[pick] - v.series[0]).abs()
                                    : 0.0;
                                final vw = tw(val, valSt);
                                final uw = 4.0 + tw(v.unit, unitSt);
                                // ความกว้างจริงของชิปเปลี่ยนแปลง (ข้อความเดียวกับ _vsDeltaChip)
                                final dTxt = d < 0.05
                                    ? 'คงที่'
                                    : d < 10 && d != d.roundToDouble()
                                        ? d.toStringAsFixed(1)
                                        : d.round().toString();
                                final dw = pick > 0
                                    ? 8.0 +
                                        (d < 0.05 ? 0.0 : 15.0) +
                                        tw(
                                            dTxt,
                                            d < 0.05
                                                ? _t(12.0,
                                                    weight: FontWeight.w700)
                                                : _num(12.0,
                                                    weight: FontWeight.w700))
                                    : 0.0;
                                final room = box.maxWidth;
                                final showDelta = pick > 0 &&
                                    (vw + dw <= room || vw + uw + dw <= room);
                                final showUnit =
                                    vw + uw + (showDelta ? dw : 0.0) <= room;
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(val, style: valSt),
                                        if (showUnit) ...[
                                          const SizedBox(width: 4.0),
                                          Text(v.unit, style: unitSt),
                                        ],
                                        // เปลี่ยนจากรอบแรก (แรกรับ) ถึงรอบที่ดู: ไอคอนลูกศร + ค่าที่เปลี่ยน
                                        if (showDelta) ...[
                                          const SizedBox(width: 8.0),
                                          _vsDeltaChip(v.series[0],
                                              v.series[pick], bad ? w1 : _ink2),
                                        ],
                                      ]),
                                );
                              }),
                            ]),
                      ),
                    ]),
                // ไอคอนลอยมุมขวาบน (กินที่แค่แถวชื่อ): แถวค่ากว้างเต็มการ์ด ตัวเลขไม่ต้องย่อ
                // การ์ดผังเตียง: มุมขวาบนเป็นปุ่ม ‹ › จึงไม่วางไอคอน
                if (!bedCard)
                  Positioned(
                      top: 0.0,
                      right: 0.0,
                      child:
                          _vsBadge(v.label, bad, size: compact ? 28.0 : 40.0)),
              ]),
            ),
          ),
          // chart: false = การ์ดแค่ค่า (bento) · แตะเพื่อดูกราฟ
          if (!chart && !fill) const SizedBox(height: 14.0),
          if (chart) const SizedBox(height: 2.0),
          if (chart)
            _vsFlex(fill, LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => choose(d.localPosition.dx, w),
                onHorizontalDragUpdate: (d) => choose(d.localPosition.dx, w),
                onDoubleTap: () => setState(() => _vsPick.remove(v.label)),
                child: Column(children: [
                  // กราฟเส้น: จุดทุกรอบ + ค่ากำกับ · รอบที่เลือก = จุดใหญ่
                  _vsGraphBox(
                    fill: fill,
                    // สูงพอให้ค่ากำกับบน/ล่างเส้น (BP สองเส้น) ไม่เบียดกัน
                    height: big ? 80.0 : 52.0,
                    child: TweenAnimationBuilder<double>(
                      // reveal: เส้นกราฟค่อย ๆ วาดจากซ้ายไปขวาตอนเปิด preview
                      tween: Tween(begin: reveal ? 0.0 : 1.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, k, child) =>
                          ClipRect(clipper: _RevealClip(k), child: child),
                      child: CustomPaint(
                        painter: _VsSpark(
                          values: v.series,
                          // BP: เส้นตัวล่าง (diastolic) คู่กับตัวบน
                          values2: v.unit == 'mmHg' ? (of ?? _case).dbp : null,
                          labels: [
                            for (var i = 0; i < n; i++)
                              v.unit == 'mmHg'
                                  ? v.series[i].round().toString()
                                  : _vsValue(v, i, of),
                          ],
                          pick: pick,
                          ink: bad ? w1 : _blue,
                          faint:
                              bad ? Colors.white.withValues(alpha: 0.6) : _ink3,
                          fill: fillC,
                          // trend แบบเรียบ: เส้นโค้ง + พื้นไล่จาง จุดเดียวที่รอบที่เลือก
                          clean: true,
                          // preview (แตะการ์ด): ป้ายค่าทุกจุด + เวลาวัด
                          allLabels: reveal,
                          times: [for (var i = 0; i < n; i++) timeAt(i)],
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            })),
        ],
      ),
    );
  }

  /// การเปลี่ยนแปลง: ไอคอนลูกศรขึ้น/ลง + ค่า · ไม่เปลี่ยน = "คงที่"
  Widget _vsDeltaChip(double from, double to, Color c) {
    final d = to - from;
    if (d.abs() < 0.05) {
      return Text('คงที่', style: _t(12.0, color: c, weight: FontWeight.w700));
    }
    final v = d.abs() < 10 && d != d.roundToDouble()
        ? d.abs().toStringAsFixed(1)
        : d.abs().round().toString();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(d > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14.0, color: c),
      const SizedBox(width: 1.0),
      Text(v, style: _num(12.0, color: c, weight: FontWeight.w700)),
    ]);
  }

  /// หัวการ์ด: การ์ดค่าอย่างเดียวที่สูงตายตัว = ยืดเต็มการ์ด (ค่าชิดล่าง)
  Widget _vsHead(bool expand, Widget child) =>
      expand ? Expanded(child: child) : child;

  /// fill = การ์ดสูงตายตัว (bento): ส่วนกราฟยืดเต็มที่เหลือ
  Widget _vsFlex(bool fill, Widget child) =>
      fill ? Expanded(child: child) : child;
  Widget _vsGraphBox(
          {required bool fill,
          required double height,
          required Widget child}) =>
      fill
          ? Expanded(child: SizedBox(width: double.infinity, child: child))
          : SizedBox(height: height, width: double.infinity, child: child);

  /// ช่วงค่าปกติ (ผู้ใหญ่) ใช้วาดแถบ ref บนกราฟ · BP = ตัวบน
  static const Map<String, (double, double)> _vsRef = {
    'HR': (60.0, 100.0),
    'Pulse': (60.0, 100.0),
    'BP': (90.0, 139.0),
    'SpO₂': (92.0, 100.0),
    'RR': (12.0, 20.0),
    'BT': (36.5, 37.5),
  };

  /// ค่าปกติ (ผู้ใหญ่) และชื่อไทย แสดงบนการ์ด V/S แบบหน้าคัดกรอง
  static const Map<String, String> _vsNormal = {
    'HR': '≤ 100',
    'Pulse': '≤ 100',
    'BP': '90–139/60–89',
    'SpO₂': '≥ 92',
    'RR': '≤ 20',
    'BT': '36.5–37.5',
  };
  static const Map<String, String> _vsThai = {
    'HR': 'อัตราการเต้นหัวใจ',
    'Pulse': 'ชีพจร',
    'BP': 'ความดันโลหิต',
    'SpO₂': 'ออกซิเจนในเลือด',
    'RR': 'การหายใจ',
    'BT': 'อุณหภูมิ',
  };

  /// ไอคอนค่า V/S ชุดเดียวกับการ์ดหน้าคัดกรอง: BP/PR = ภาพประกอบ Figma
  /// ค่าอื่น = ไอคอนในวงกลมพื้นอ่อน (ผิดปกติ = แดงอ่อน)
  /// แถวรายการที่แตะได้ (ภาษาเดียวกับแถว V/S ในซักประวัติ = หน้าตั้งค่า Google):
  /// เส้นคั่นบน (ยกเว้นแถวแรก) · ไอคอนวง · ชื่อ + ป้ายเล็ก · บรรทัดสถานะ · ลูกศรขวา
  /// ใช้กับทุก list ที่แตะได้ ให้หน้าตาเหมือนกันทั้งแอป
  Widget _gListRow({
    Widget? lead,
    required String title,
    String? note,
    Color noteColor = _ink3,
    required String sub,
    Color subColor = _ink3,
    VoidCallback? onTap,
    bool first = false,
    bool compact = false,
    bool dim = false,
    Widget? trail,
    double inset = 0.0,
    int? titleLines,
    Widget? top,
  }) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        if (!first)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: const Divider(
                height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
          ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                inset, compact ? 8.0 : 12.0, inset, compact ? 8.0 : 12.0),
            child: Row(children: [
              if (lead != null) ...[
                lead,
                SizedBox(width: compact ? 10.0 : 14.0),
              ],
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ป้ายเหนือชื่อ (เช่น รหัส ICD-10)
                      // ป้ายเหนือชื่อ หรือแทนบรรทัดชื่อทั้งบรรทัด (title ว่าง)
                      if (top != null) top,
                      if (top != null && title.isNotEmpty)
                        const SizedBox(height: 4.0),
                      if (title.isNotEmpty)
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: title,
                                style: _t(compact ? 13.0 : 14.5,
                                    color: dim ? _ink3 : _inkTitle,
                                    weight: FontWeight.w500)),
                            if (note != null)
                              TextSpan(
                                  text: '  $note',
                                  style: _t(compact ? 11.0 : 12.0,
                                      color: noteColor,
                                      weight: noteColor == _ink3
                                          ? FontWeight.w500
                                          : FontWeight.w700)),
                          ]),
                          maxLines: titleLines ?? (compact ? 1 : 3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (sub.isNotEmpty) ...[
                        SizedBox(height: compact ? 1.0 : 2.0),
                        Text(sub,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(compact ? 11.5 : 13.0,
                                color: subColor, weight: FontWeight.w500)),
                      ],
                    ]),
              ),
              const SizedBox(width: 8.0),
              trail ??
                  (onTap == null
                      ? const SizedBox.shrink()
                      : Icon(Icons.chevron_right_rounded,
                          size: compact ? 20.0 : 22.0, color: _ink3)),
            ]),
          ),
        ),
      ]);

  /// ไอคอนวงหน้าแถว (โทนตามสถานะ: กรมท่า = รอ · เขียว = เสร็จ · แดง = ผิดปกติ/ด่วน)
  Widget _gLead(IconData icon, {Color tone = _blue, double size = 40.0}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: tone.withValues(alpha: tone == _blue ? 0.08 : 0.12),
            shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.5, color: tone),
      );

  Widget _vsBadge(String label, bool bad, {double size = 28.0}) {
    final img = switch (label) {
      'BP' => 'assets/images/er_vs_bp.png',
      // BT: ภาพชุดเดียวกับ BP/HR (Figma 414:55)
      'BT' => 'assets/images/er_vs_bt3d.png',
      'HR' || 'Pulse' || 'PR' => 'assets/images/er_vs_pr.png',
      _ => null,
    };
    if (img != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0.0,
            bottom: 0.0,
            width: label == 'BP' ? size : size * 0.895,
            height: label == 'BP' ? size : size * 0.895,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  // บนการ์ดแดงทึบ: วงสีแดงเข้มกว่าการ์ด (เหมือนหน้าคัดกรอง)
                  color: bad
                      ? Color.lerp(_red, Colors.black, 0.22)!
                      : const Color(0xFFEDEDF0),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned.fill(child: Image.asset(img)),
        ]),
      );
    }
    const icons = {
      'HR': Icons.monitor_heart_rounded,
      'RR': Icons.air_rounded,
      'BT': Icons.thermostat_rounded,
      'SpO₂': Icons.water_drop_rounded,
      'SpO2': Icons.water_drop_rounded,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bad
            ? Color.lerp(_red, Colors.black, 0.22)!
            : _blue.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icons[label] ?? Icons.favorite_rounded,
          size: size * 0.55, color: bad ? Colors.white : _blue),
    );
  }

  Widget _clyEmpty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(text, style: _t(11.0, color: _ink3)),
      );

  /// กริด 3 คอลัมน์ การ์ดในแถวเดียวกันสูงเท่ากัน
  /// grid คอลัมน์เท่ากัน ช่องสูงเท่ากันในแถว · minW > 0 = responsive:
  /// จำนวนคอลัมน์ลดตามความกว้างแผง (ช่องไม่แคบกว่า minW) สูงสุด per คอลัมน์
  /// equal = false: ไม่ยืดช่องให้สูงเท่ากัน (ช่องที่มี LayoutBuilder ข้างใน
  /// วัด intrinsic height ไม่ได้ เช่น tile สัญญาณชีพที่มีกราฟ)
  Widget _clyCardGrid(List<Widget> items,
      {int per = 3, double gap = 8.0, double minW = 0.0, bool equal = true}) {
    Widget row(int i, int n) => Row(
          crossAxisAlignment:
              equal ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            for (var j = i; j < i + n; j++) ...[
              if (j > i) SizedBox(width: gap),
              Expanded(
                  child: j < items.length ? items[j] : const SizedBox.shrink()),
            ],
          ],
        );
    Widget rows(int n) => Column(children: [
          for (var i = 0; i < items.length; i += n)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0.0 : gap),
              child: equal ? IntrinsicHeight(child: row(i, n)) : row(i, n),
            ),
        ]);
    if (minW <= 0.0) return rows(per);
    return LayoutBuilder(
        builder: (context, box) =>
            rows(((box.maxWidth + gap) / (minW + gap)).floor().clamp(1, per)));
  }
}

/// กราฟเส้นสัญญาณชีพในการ์ด: แบ่งช่องเท่ากันตามจำนวนรอบ (ตรงกับแถวเวลาใต้กราฟ)
/// พื้นใต้เส้นไล่จาง · จุดทุกรอบ + ค่ากำกับเหนือจุด · รอบที่เลือกจุดใหญ่ตัวหนา
/// values2 = เส้นที่สอง (BP ตัวล่าง) ค่ากำกับอยู่ใต้จุด
class _VsSpark extends CustomPainter {
  _VsSpark({
    required this.values,
    required this.labels,
    required this.pick,
    required this.ink,
    required this.faint,
    required this.fill,
    this.values2,
    this.clean = false,
    this.ref,
    this.allLabels = false,
    this.times = const [],
  });

  /// ป้ายค่าทุกจุด + เวลาที่วัดใต้แต่ละจุด (preview กราฟ)
  final bool allLabels;
  final List<String> times;

  /// ช่วงค่าปกติ (ref) ของเส้นหลัก: วาดเป็นแถบขอบเส้นประ (โหมดเรียบ)
  final (double, double)? ref;

  /// โหมดเรียบแบบ Google: ไม่มีป้ายค่า ไม่มีจุดทุกรอบ (จุดเฉพาะรอบที่เลือก)
  final bool clean;
  final List<double> values;
  final List<String> labels;
  final int pick;
  final Color ink;
  final Color faint;
  final Color fill;
  final List<double>? values2;

  /// เส้นโค้ง monotone (Fritsch–Carlson) ผ่านทุกจุด ต่อปลายถึงขอบตามความชัน
  static (Path, List<Offset>) _curve(List<Offset> pts, Size size, double top) {
    final n = pts.length;
    double edgeY(Offset a, Offset b, double x) {
      if ((b.dx - a.dx).abs() < 0.01) return a.dy;
      final y = a.dy + (b.dy - a.dy) * (x - a.dx) / (b.dx - a.dx);
      return y.clamp(top, size.height - 1.0);
    }

    final left = Offset(0.0, n > 1 ? edgeY(pts[0], pts[1], 0.0) : pts[0].dy);
    final right = Offset(size.width,
        n > 1 ? edgeY(pts[n - 2], pts[n - 1], size.width) : pts[0].dy);
    final c = [left, ...pts, right];
    final m = c.length;
    final d = [
      for (var i = 0; i < m - 1; i++)
        (c[i + 1].dy - c[i].dy) / (c[i + 1].dx - c[i].dx)
    ];
    final t = List<double>.filled(m, 0.0);
    t[0] = d[0];
    t[m - 1] = d[m - 2];
    for (var i = 1; i < m - 1; i++) {
      t[i] = d[i - 1] * d[i] <= 0 ? 0.0 : (d[i - 1] + d[i]) / 2;
    }
    for (var i = 0; i < m - 1; i++) {
      if (d[i] == 0) {
        t[i] = 0.0;
        t[i + 1] = 0.0;
        continue;
      }
      final a0 = t[i] / d[i], b0 = t[i + 1] / d[i];
      final h = a0 * a0 + b0 * b0;
      if (h > 9.0) {
        final k = 3.0 / math.sqrt(h);
        t[i] = k * a0 * d[i];
        t[i + 1] = k * b0 * d[i];
      }
    }
    final line = Path()..moveTo(c[0].dx, c[0].dy);
    for (var i = 0; i < m - 1; i++) {
      final dx = (c[i + 1].dx - c[i].dx) / 3;
      line.cubicTo(c[i].dx + dx, c[i].dy + t[i] * dx, c[i + 1].dx - dx,
          c[i + 1].dy - t[i + 1] * dx, c[i + 1].dx, c[i + 1].dy);
    }
    return (line, c);
  }

  TextPainter _labelTp(String s, bool on, double cw) => TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontFamily: _fontFam,
            fontFamilyFallback: _fontFb,
            fontSize: on ? 9.0 : 8.0,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            color: on ? ink : faint,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: math.max(cw + 6.0, 40.0));

  /// ค่ากำกับจุด: จุดเว้นจุด (ล่าสุดเสมอ) + จุดที่เลือก · ไม่ให้เบียดกัน
  /// ป้ายที่จะทับป้ายที่วาดแล้ว (ห่างไม่ถึง 4) ข้ามไป · ป้ายไม่ล้นขอบการ์ด
  void _labels(
      Canvas canvas, Size size, List<String> text, List<Offset> pts, double cw,
      {bool below = false}) {
    final n = pts.length;
    // จุดเว้นจุด นับจากล่าสุดย้อนหลัง (ล่าสุดมีป้ายเสมอ) + จุดที่เลือก
    final order = <int>[
      if (pick >= 0 && pick < n) pick,
      for (var i = n - 1; i >= 0; i -= 2) i,
    ];
    final used = <Rect>[];
    for (final i in {...order}) {
      final on = i == pick;
      final tp = _labelTp(text[i], on, cw);
      final x = (pts[i].dx - tp.width / 2)
          .clamp(0.0, math.max(0.0, size.width - tp.width))
          .toDouble();
      final y =
          below ? pts[i].dy + 7.0 : math.max(0.0, pts[i].dy - 8.0 - tp.height);
      final r = Rect.fromLTWH(x, y, tp.width, tp.height);
      if (used.any((u) => u.inflate(4.0).overlaps(r))) continue;
      used.add(r);
      tp.paint(canvas, r.topLeft);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final two = values2 != null && values2!.length == n;
    // สองเส้น: เว้นล่างให้ค่ากำกับใต้เส้นล่าง
    // เว้นบน/ล่างให้ป้ายที่ห่างจากจุด 8
    final top = clean ? 22.0 : 17.0,
        bottom = clean ? (two ? 20.0 : 8.0) : (two ? 18.0 : 4.0);
    final all = [...values, if (two) ...values2!];
    final hi = all.reduce(math.max), lo = all.reduce(math.min);
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    final cw = size.width / n;
    Offset at(double v, int i) => Offset(
        cw * (i + 0.5),
        hi == lo
            ? (top + size.height - bottom) / 2
            : top + (size.height - top - bottom) * (1 - (v - lo) / span));
    // มีช่วงค่าปกติ = กราฟแถบ ref · ไม่มี = เส้นโค้งเรียบ (ด้านล่าง)
    if (clean && ref != null) {
      _refChart(canvas, size, n, two);
      return;
    }
    final pts = [for (var i = 0; i < n; i++) at(values[i], i)];
    final (line, chain) = _curve(pts, size, top);
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    // ไล่จากสีเต็มที่จุดสูงสุดของเส้น ลงไปโปร่งใสที่ขอบล่าง
    final topY = chain.map((p) => p.dy).reduce(math.min);
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill, fill.withValues(alpha: 0.0)],
          ).createShader(Rect.fromLTRB(0.0, topY, size.width, size.height)));
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = clean ? 2.2 : 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, stroke);
    List<Offset> pts2 = const [];
    if (two) {
      pts2 = [for (var i = 0; i < n; i++) at(values2![i], i)];
      final (line2, _) = _curve(pts2, size, top);
      canvas.drawPath(
          line2,
          stroke
            ..color = ink.withValues(alpha: 0.6)
            ..strokeWidth = 1.4);
    }
    void dot(Offset p, bool on) {
      canvas.drawCircle(p, on ? 3.6 : 2.2, Paint()..color = ink);
      if (on) {
        canvas.drawCircle(
            p,
            3.6,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      }
    }

    if (clean) {
      // จุดรอบแรก (เล็ก) + รอบที่เลือก (ใหญ่) พร้อมค่ากำกับ ให้เห็นว่าเปลี่ยนจากเท่าไรเป็นเท่าไร
      final k = (pick >= 0 && pick < n) ? pick : n - 1;
      final keep = allLabels ? {for (var i = 0; i < n; i++) i} : {0, k};
      for (final i in keep) {
        dot(pts[i], i == k);
        if (two) dot(pts2[i], i == k);
      }
      void tag(String t, Offset p, {bool below = false, bool strong = false}) {
        final tp = TextPainter(
          text: TextSpan(
              text: t,
              style: TextStyle(
                  fontFamily: _fontFam,
                  fontSize: strong ? 10.5 : 9.5,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                  color: strong ? ink : faint)),
          textDirection: TextDirection.ltr,
        )..layout();
        final x = (p.dx - tp.width / 2).clamp(2.0, size.width - tp.width - 2.0);
        final y = below
            ? math.min(size.height - tp.height, p.dy + 5.0)
            : math.max(0.0, p.dy - tp.height - 5.0);
        tp.paint(canvas, Offset(x, y));
      }

      for (final i in keep) {
        tag(labels[i], pts[i], strong: i == k);
        if (two) {
          tag(values2![i].round().toString(), pts2[i],
              below: true, strong: i == k);
        }
      }
      // เวลาที่วัดชิดขอบล่างใต้แต่ละจุด (preview)
      if (allLabels && times.isNotEmpty) {
        for (var i = 0; i < n && i < times.length; i++) {
          if (times[i].isEmpty) continue;
          final tp = TextPainter(
            text: TextSpan(
                text: times[i],
                style: TextStyle(
                    fontFamily: _fontFam,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: faint)),
            textDirection: TextDirection.ltr,
          )..layout();
          final x = (pts[i].dx - tp.width / 2)
              .clamp(2.0, size.width - tp.width - 2.0);
          tp.paint(canvas, Offset(x, size.height - tp.height - 2.0));
        }
      }
      return;
    }
    for (var i = 0; i < n; i++) {
      dot(pts[i], i == pick);
      if (two) dot(pts2[i], i == pick);
    }
    _labels(canvas, size, labels, pts, cw);
    if (two) {
      _labels(canvas, size, [for (final v in values2!) v.round().toString()],
          pts2, cw,
          below: true);
    }
  }

  /// กราฟแบบเรียบ: แถบช่วงค่าปกติ (ref) ขอบเส้นประ + ค่าขอบช่วงกำกับขวา
  /// เส้นข้อมูลทึบ จุดทุกรอบ · จุดที่หลุดช่วงปกติเป็นแดง · จุดที่เลือกใหญ่
  /// BP: เส้นตัวบนเทียบช่วงปกติตัวบน + เส้นตัวล่างจาง
  void _refChart(Canvas canvas, Size size, int n, bool two) {
    const labelW = 26.0, top = 8.0, bottom = 8.0;
    final w = size.width - labelW;
    final all = [
      ...values,
      if (two) ...values2!,
      if (ref != null) ...[ref!.$1, ref!.$2],
    ];
    final hi = all.reduce(math.max), lo = all.reduce(math.min);
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    double y(double v) =>
        top + (size.height - top - bottom) * (1 - (v - lo) / span);
    final cw = w / n;
    Offset at(double v, int i) => Offset(cw * (i + 0.5), y(v));
    const okC = Color(0xFF001B7C), badC = Color(0xFFD93025);
    // แถบค่าปกติ
    if (ref != null) {
      final r = Rect.fromLTRB(0.0, y(ref!.$2), w, y(ref!.$1));
      canvas.drawRect(r, Paint()..color = okC.withValues(alpha: 0.06));
      final dash = Paint()
        ..color = const Color(0xFF9AA0A6)
        ..strokeWidth = 1.0;
      for (final yy in [r.top, r.bottom]) {
        for (var x = 0.0; x < w; x += 6.0) {
          canvas.drawLine(
              Offset(x, yy), Offset(math.min(x + 3.0, w), yy), dash);
        }
      }
      void tag(double v, double yy) {
        final tp = TextPainter(
          text: TextSpan(
              text: v == v.roundToDouble() ? '${v.toInt()}' : '$v',
              style: TextStyle(
                  fontFamily: _fontFam,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF80868B))),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas,
            Offset(w + 4.0,
                (yy - tp.height / 2).clamp(0.0, size.height - tp.height)));
      }

      tag(ref!.$2, r.top);
      tag(ref!.$1, r.bottom);
    }
    bool out(double v) => ref != null && (v < ref!.$1 || v > ref!.$2);
    void series(List<double> vs, {bool faint = false, bool judge = true}) {
      final pts = [for (var i = 0; i < n; i++) at(vs[i], i)];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = okC.withValues(alpha: faint ? 0.35 : 0.85)
            ..strokeWidth = faint ? 1.4 : 2.0
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round);
      for (var i = 0; i < n; i++) {
        final on = i == pick;
        final c = judge && out(vs[i]) ? badC : okC;
        final r = on ? 4.0 : (faint ? 2.0 : 2.6);
        canvas.drawCircle(
            pts[i], r, Paint()..color = c.withValues(alpha: faint ? 0.5 : 1.0));
        if (on && !faint) {
          canvas.drawCircle(
              pts[i],
              r,
              Paint()
                ..color = Colors.white
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4);
        }
      }
    }

    if (two) series(values2!, faint: true, judge: false);
    series(values);
  }

  @override
  bool shouldRepaint(_VsSpark o) =>
      o.pick != pick ||
      o.ink != ink ||
      o.values.join(',') != values.join(',') ||
      o.labels.join(',') != labels.join(',') ||
      (o.values2 ?? const []).join(',') != (values2 ?? const []).join(',');
}

/// ปรากฏทีละชิ้นตอนเปลี่ยนหน้า: จาง + ลอยขึ้น 12px · ชิ้นถัดไปช้ากว่ากัน 45ms
/// สร้างใหม่ทุกครั้งที่เปลี่ยนแท็บ (หน้าอยู่ใต้ KeyedSubtree ของแท็บ)
class _Appear extends StatefulWidget {
  const _Appear({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 360));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    // ไม่เกิน 8 ลำดับ: รายการยาว ๆ ไม่ต้องรอนาน
    final delay = 60 + 45 * widget.index.clamp(0, 8);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: AnimatedBuilder(
          animation: _a,
          builder: (context, child) => Transform.translate(
              offset: Offset(0.0, 12.0 * (1.0 - _a.value)), child: child),
          child: widget.child,
        ),
      );
}

/// แตะ = แสดง preview ลอยเหนือ child · แตะที่ไหนก็ได้/ออกจากหน้า = ปิด (ไม่ค้าง)
class _VsPeek extends StatefulWidget {
  const _VsPeek({required this.preview, required this.child});

  final Widget Function() preview;
  final Widget child;

  @override
  State<_VsPeek> createState() => _VsPeekState();
}

class _VsPeekState extends State<_VsPeek> {
  OverlayEntry? _entry;

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _open() {
    _close();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    HapticFeedback.mediumImpact();
    final o = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);
    const w = 420.0, h = 220.0;
    final left = (o.dx + box.size.width / 2 - w / 2)
        .clamp(12.0, screen.width - w - 12.0);
    final top = (o.dy - h - 8.0).clamp(12.0, screen.height - h - 12.0);
    final preview = widget.preview();
    _entry = OverlayEntry(
      builder: (_) => Stack(children: [
        // แตะที่ไหนก็ได้ = ปิด preview
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const ColoredBox(color: Color(0x14000000)),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, k, child) => Opacity(
                  opacity: ((k - 0.9) * 10).clamp(0.0, 1.0),
                  child: Transform.scale(scale: k, child: child)),
              child: Material(
                color: Colors.transparent,
                elevation: 12.0,
                shadowColor: const Color(0x330B1B3F),
                borderRadius: BorderRadius.circular(12.0),
                child: preview,
              ),
            ),
          ),
        ),
      ]),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void deactivate() {
    _close();
    super.deactivate();
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _open,
        child: widget.child,
      );
}

/// ตัดให้เห็นแค่ส่วนซ้าย k (0..1) ของความกว้าง: เส้นกราฟค่อย ๆ วาดจากซ้ายไปขวา
class _RevealClip extends CustomClipper<Rect> {
  const _RevealClip(this.k);
  final double k;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, -20, size.width * k, size.height + 40);

  @override
  bool shouldReclip(_RevealClip old) => old.k != k;
}

/// กราฟเทียบซักประวัติ: ช่องเท่ากันต่อครั้ง · ครั้งที่ไม่ได้วัดเว้นว่าง (เส้นต่อข้ามไป)
/// แถบช่วงค่าปกติขอบเส้นประ · จุดนอกช่วง = แดง · ครั้งล่าสุดที่วัด = จุดใหญ่ขอบขาว
/// values2 = ตัวล่างของ BP (เส้นจาง ค่ากำกับใต้จุด)
class _HxCmpChart extends CustomPainter {
  _HxCmpChart({
    required this.values,
    required this.labels,
    this.values2,
    this.ref,
  });

  final List<double?> values;
  final List<double?>? values2;
  final List<String> labels;
  final (double, double)? ref;

  static const _ok = Color(0xFF001B7C), _bad = Color(0xFFD93025);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final two = values2 != null;
    const top = 20.0;
    final bottom = two ? 18.0 : 6.0;
    final all = [
      ...values.whereType<double>(),
      if (two) ...values2!.whereType<double>(),
      if (ref != null) ...[ref!.$1, ref!.$2],
    ];
    if (all.isEmpty) return;
    var lo = all.reduce(math.min), hi = all.reduce(math.max);
    final pad = (hi - lo).abs() < 0.01 ? 1.0 : (hi - lo) * 0.08;
    lo -= pad;
    hi += pad;
    final cw = size.width / n;
    double y(double v) =>
        top + (size.height - top - bottom) * (1 - (v - lo) / (hi - lo));
    if (ref != null) {
      final r = Rect.fromLTRB(0.0, y(ref!.$2), size.width, y(ref!.$1));
      canvas.drawRect(r, Paint()..color = _ok.withValues(alpha: 0.05));
      final dash = Paint()
        ..color = const Color(0xFFBDC1C6)
        ..strokeWidth = 1.0;
      for (final yy in [r.top, r.bottom]) {
        for (var x = 0.0; x < size.width; x += 6.0) {
          canvas.drawLine(
              Offset(x, yy), Offset(math.min(x + 3.0, size.width), yy), dash);
        }
      }
    }
    bool out(double v) => ref != null && (v < ref!.$1 || v > ref!.$2);
    final lastI = values.lastIndexWhere((v) => v != null);

    void tag(String t, Offset p, Color c,
        {bool below = false, bool strong = false}) {
      final tp = TextPainter(
        text: TextSpan(
            text: t,
            style: TextStyle(
                fontFamily: _fontFam,
                fontSize: strong ? 11.0 : 10.0,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                color: c)),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (p.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      final yy = below
          ? math.min(size.height - tp.height, p.dy + 5.0)
          : math.max(0.0, p.dy - tp.height - 5.0);
      tp.paint(canvas, Offset(x, yy));
    }

    void series(List<double?> vs, {required bool faint}) {
      final pts = <(int, Offset)>[
        for (var i = 0; i < n; i++)
          if (vs[i] case final v?) (i, Offset(cw * (i + 0.5), y(v)))
      ];
      if (pts.isEmpty) return;
      if (pts.length > 1) {
        final path = Path()..moveTo(pts.first.$2.dx, pts.first.$2.dy);
        for (final (_, q) in pts.skip(1)) {
          path.lineTo(q.dx, q.dy);
        }
        canvas.drawPath(
            path,
            Paint()
              ..color = _ok.withValues(alpha: faint ? 0.35 : 0.85)
              ..strokeWidth = faint ? 1.4 : 2.0
              ..style = PaintingStyle.stroke
              ..strokeJoin = StrokeJoin.round
              ..strokeCap = StrokeCap.round);
      }
      for (final (i, p) in pts) {
        final v = vs[i]!;
        final isLast = i == lastI;
        final c = !faint && out(v) ? _bad : _ok;
        final r = faint ? 2.4 : (isLast ? 4.6 : 3.4);
        canvas.drawCircle(
            p, r, Paint()..color = c.withValues(alpha: faint ? 0.5 : 1.0));
        if (isLast && !faint) {
          canvas.drawCircle(
              p,
              r,
              Paint()
                ..color = Colors.white
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4);
        }
        if (faint) {
          tag(v.round().toString(), p, const Color(0xFF80868B), below: true);
        } else {
          tag(labels[i], p,
              out(v) ? _bad : (isLast ? _ok : const Color(0xFF5F6368)),
              strong: isLast);
        }
      }
    }

    if (two) series(values2!, faint: true);
    series(values, faint: false);
  }

  @override
  bool shouldRepaint(_HxCmpChart o) =>
      o.values.join(',') != values.join(',') ||
      (o.values2 ?? const []).join(',') != (values2 ?? const []).join(',') ||
      o.ref != ref;
}

/// เมนูที่ใช้ไอคอนเส้นจาก Figma (เส้นบางกว่าชุด Phosphor ต้องเพิ่มความหนา)
const Set<String> _figmaRailIcons = {'กิจกรรมพยาบาล'};

/// เมนูรางซ้าย: ไอคอน Phosphor (MIT) แปลงจาก SVG เป็น path 24×24 (M L C Z) · (d, ทึบ?, evenOdd?) · (Regular, Fill)
/// ไม่เลือก = Regular · เลือก = Fill
const Map<String, (List<(String, bool, bool)>, List<(String, bool, bool)>)>
    _solarRail = {
  'ภาพรวม': (
    [
      (
        'M9.75 3.75L5.25 3.75C4.987 3.75 4.728 3.819 4.5 3.951C4.272 4.083 4.083 4.272 3.951 4.5C3.819 4.728 3.75 4.987 3.75 5.25L3.75 9.75C3.75 10.013 3.819 10.272 3.951 10.5C4.083 10.728 4.272 10.917 4.5 11.049C4.728 11.181 4.987 11.25 5.25 11.25L9.75 11.25C10.013 11.25 10.272 11.181 10.5 11.049C10.728 10.917 10.917 10.728 11.049 10.5C11.181 10.272 11.25 10.013 11.25 9.75L11.25 5.25C11.25 4.987 11.181 4.728 11.049 4.5C10.917 4.272 10.728 4.083 10.5 3.951C10.272 3.819 10.013 3.75 9.75 3.75M9.75 9.75L5.25 9.75L5.25 5.25L9.75 5.25ZM18.75 3.75L14.25 3.75C13.987 3.75 13.728 3.819 13.5 3.951C13.272 4.083 13.083 4.272 12.951 4.5C12.819 4.728 12.75 4.987 12.75 5.25L12.75 9.75C12.75 10.013 12.819 10.272 12.951 10.5C13.083 10.728 13.272 10.917 13.5 11.049C13.728 11.181 13.987 11.25 14.25 11.25L18.75 11.25C19.013 11.25 19.272 11.181 19.5 11.049C19.728 10.917 19.917 10.728 20.049 10.5C20.181 10.272 20.25 10.013 20.25 9.75L20.25 5.25C20.25 4.987 20.181 4.728 20.049 4.5C19.917 4.272 19.728 4.083 19.5 3.951C19.272 3.819 19.013 3.75 18.75 3.75M18.75 9.75L14.25 9.75L14.25 5.25L18.75 5.25ZM9.75 12.75L5.25 12.75C4.987 12.75 4.728 12.819 4.5 12.951C4.272 13.083 4.083 13.272 3.951 13.5C3.819 13.728 3.75 13.987 3.75 14.25L3.75 18.75C3.75 19.013 3.819 19.272 3.951 19.5C4.083 19.728 4.272 19.917 4.5 20.049C4.728 20.181 4.987 20.25 5.25 20.25L9.75 20.25C10.013 20.25 10.272 20.181 10.5 20.049C10.728 19.917 10.917 19.728 11.049 19.5C11.181 19.272 11.25 19.013 11.25 18.75L11.25 14.25C11.25 13.987 11.181 13.728 11.049 13.5C10.917 13.272 10.728 13.083 10.5 12.951C10.272 12.819 10.013 12.75 9.75 12.75M9.75 18.75L5.25 18.75L5.25 14.25L9.75 14.25ZM18.75 12.75L14.25 12.75C13.987 12.75 13.728 12.819 13.5 12.951C13.272 13.083 13.083 13.272 12.951 13.5C12.819 13.728 12.75 13.987 12.75 14.25L12.75 18.75C12.75 19.013 12.819 19.272 12.951 19.5C13.083 19.728 13.272 19.917 13.5 20.049C13.728 20.181 13.987 20.25 14.25 20.25L18.75 20.25C19.013 20.25 19.272 20.181 19.5 20.049C19.728 19.917 19.917 19.728 20.049 19.5C20.181 19.272 20.25 19.013 20.25 18.75L20.25 14.25C20.25 13.987 20.181 13.728 20.049 13.5C19.917 13.272 19.728 13.083 19.5 12.951C19.272 12.819 19.013 12.75 18.75 12.75M18.75 18.75L14.25 18.75L14.25 14.25L18.75 14.25Z',
        true,
        false
      )
    ],
    [
      (
        'M11.25 5.25L11.25 9.75C11.25 10.013 11.181 10.272 11.049 10.5C10.917 10.728 10.728 10.917 10.5 11.049C10.272 11.181 10.013 11.25 9.75 11.25L5.25 11.25C4.987 11.25 4.728 11.181 4.5 11.049C4.272 10.917 4.083 10.728 3.951 10.5C3.819 10.272 3.75 10.013 3.75 9.75L3.75 5.25C3.75 4.987 3.819 4.728 3.951 4.5C4.083 4.272 4.272 4.083 4.5 3.951C4.728 3.819 4.987 3.75 5.25 3.75L9.75 3.75C10.013 3.75 10.272 3.819 10.5 3.951C10.728 4.083 10.917 4.272 11.049 4.5C11.181 4.728 11.25 4.987 11.25 5.25M18.75 3.75L14.25 3.75C13.987 3.75 13.728 3.819 13.5 3.951C13.272 4.083 13.083 4.272 12.951 4.5C12.819 4.728 12.75 4.987 12.75 5.25L12.75 9.75C12.75 10.013 12.819 10.272 12.951 10.5C13.083 10.728 13.272 10.917 13.5 11.049C13.728 11.181 13.987 11.25 14.25 11.25L18.75 11.25C19.013 11.25 19.272 11.181 19.5 11.049C19.728 10.917 19.917 10.728 20.049 10.5C20.181 10.272 20.25 10.013 20.25 9.75L20.25 5.25C20.25 4.987 20.181 4.728 20.049 4.5C19.917 4.272 19.728 4.083 19.5 3.951C19.272 3.819 19.013 3.75 18.75 3.75M9.75 12.75L5.25 12.75C4.987 12.75 4.728 12.819 4.5 12.951C4.272 13.083 4.083 13.272 3.951 13.5C3.819 13.728 3.75 13.987 3.75 14.25L3.75 18.75C3.75 19.013 3.819 19.272 3.951 19.5C4.083 19.728 4.272 19.917 4.5 20.049C4.728 20.181 4.987 20.25 5.25 20.25L9.75 20.25C10.013 20.25 10.272 20.181 10.5 20.049C10.728 19.917 10.917 19.728 11.049 19.5C11.181 19.272 11.25 19.013 11.25 18.75L11.25 14.25C11.25 13.987 11.181 13.728 11.049 13.5C10.917 13.272 10.728 13.083 10.5 12.951C10.272 12.819 10.013 12.75 9.75 12.75M18.75 12.75L14.25 12.75C13.987 12.75 13.728 12.819 13.5 12.951C13.272 13.083 13.083 13.272 12.951 13.5C12.819 13.728 12.75 13.987 12.75 14.25L12.75 18.75C12.75 19.013 12.819 19.272 12.951 19.5C13.083 19.728 13.272 19.917 13.5 20.049C13.728 20.181 13.987 20.25 14.25 20.25L18.75 20.25C19.013 20.25 19.272 20.181 19.5 20.049C19.728 19.917 19.917 19.728 20.049 19.5C20.181 19.272 20.25 19.013 20.25 18.75L20.25 14.25C20.25 13.987 20.181 13.728 20.049 13.5C19.917 13.272 19.728 13.083 19.5 12.951C19.272 12.819 19.013 12.75 18.75 12.75',
        true,
        false
      )
    ]
  ),
  'Fast track': (
    [
      (
        'M20.23 11.078C20.202 10.958 20.144 10.847 20.062 10.754C19.981 10.662 19.877 10.591 19.762 10.548L14.361 8.522L15.735 1.647C15.76 1.52 15.751 1.388 15.71 1.265C15.669 1.142 15.596 1.032 15.499 0.945C15.403 0.859 15.285 0.799 15.159 0.771C15.032 0.743 14.9 0.749 14.776 0.788C14.652 0.826 14.54 0.896 14.452 0.991L3.952 12.241C3.866 12.331 3.805 12.44 3.772 12.56C3.739 12.679 3.737 12.805 3.765 12.926C3.793 13.047 3.85 13.159 3.932 13.252C4.013 13.345 4.117 13.416 4.233 13.46L9.636 15.486L8.265 22.353C8.24 22.48 8.249 22.612 8.29 22.735C8.331 22.858 8.404 22.968 8.501 23.055C8.597 23.141 8.715 23.201 8.841 23.229C8.968 23.257 9.1 23.251 9.224 23.212C9.348 23.174 9.46 23.104 9.548 23.009L20.048 11.759C20.132 11.669 20.193 11.56 20.224 11.441C20.256 11.323 20.258 11.198 20.23 11.078M10.253 20.062L11.235 15.152C11.258 15.036 11.254 14.917 11.223 14.804C11.191 14.69 11.134 14.586 11.054 14.499C10.975 14.412 10.876 14.344 10.766 14.303L5.812 12.442L13.746 3.942L12.765 8.853C12.742 8.968 12.746 9.088 12.777 9.201C12.809 9.315 12.866 9.419 12.946 9.506C13.025 9.593 13.124 9.66 13.234 9.702L18.184 11.558Z',
        true,
        false
      )
    ],
    [
      (
        'M20.048 11.762L9.548 23.012C9.46 23.107 9.348 23.177 9.224 23.215C9.1 23.254 8.968 23.259 8.841 23.232C8.715 23.204 8.597 23.144 8.501 23.058C8.404 22.971 8.331 22.861 8.29 22.738C8.249 22.615 8.24 22.483 8.265 22.356L9.639 15.481L4.237 13.452C4.121 13.409 4.017 13.337 3.935 13.244C3.854 13.151 3.796 13.039 3.769 12.918C3.741 12.798 3.743 12.672 3.776 12.552C3.808 12.433 3.87 12.323 3.955 12.233L14.455 0.983C14.544 0.889 14.656 0.819 14.78 0.78C14.904 0.742 15.035 0.736 15.162 0.763C15.289 0.791 15.407 0.851 15.503 0.938C15.6 1.024 15.672 1.135 15.714 1.258C15.755 1.381 15.764 1.512 15.739 1.64L14.361 8.522L19.763 10.548C19.879 10.592 19.981 10.663 20.062 10.756C20.143 10.848 20.2 10.96 20.228 11.08C20.256 11.2 20.254 11.325 20.222 11.444C20.19 11.563 20.129 11.672 20.045 11.762Z',
        true,
        false
      )
    ]
  ),
  'ข้อมูลผู้ป่วย': (
    [
      (
        'M18.75 10.5C18.75 10.632 18.715 10.761 18.65 10.875C18.584 10.989 18.489 11.084 18.375 11.15C18.261 11.215 18.132 11.25 18 11.25L14.25 11.25C14.092 11.25 13.937 11.2 13.809 11.107C13.681 11.014 13.586 10.882 13.537 10.732C13.488 10.581 13.488 10.419 13.537 10.268C13.586 10.118 13.681 9.986 13.809 9.893C13.937 9.8 14.092 9.75 14.25 9.75L18 9.75C18.132 9.75 18.261 9.785 18.375 9.85C18.489 9.916 18.584 10.011 18.65 10.125C18.715 10.239 18.75 10.368 18.75 10.5M18 12.75L14.25 12.75C14.092 12.75 13.937 12.8 13.809 12.893C13.681 12.986 13.586 13.118 13.537 13.268C13.488 13.419 13.488 13.581 13.537 13.732C13.586 13.882 13.681 14.014 13.809 14.107C13.937 14.2 14.092 14.25 14.25 14.25L18 14.25C18.158 14.25 18.313 14.2 18.441 14.107C18.569 14.014 18.664 13.882 18.713 13.732C18.762 13.581 18.762 13.419 18.713 13.268C18.664 13.118 18.569 12.986 18.441 12.893C18.313 12.8 18.158 12.75 18 12.75M21.75 5.25L21.75 18.75C21.75 19.013 21.681 19.272 21.549 19.5C21.417 19.728 21.228 19.917 21 20.049C20.772 20.181 20.513 20.25 20.25 20.25L3.75 20.25C3.487 20.25 3.228 20.181 3 20.049C2.772 19.917 2.583 19.728 2.451 19.5C2.319 19.272 2.25 19.013 2.25 18.75L2.25 5.25C2.25 4.987 2.319 4.728 2.451 4.5C2.583 4.272 2.772 4.083 3 3.951C3.228 3.819 3.487 3.75 3.75 3.75L20.25 3.75C20.513 3.75 20.772 3.819 21 3.951C21.228 4.083 21.417 4.272 21.549 4.5C21.681 4.728 21.75 4.987 21.75 5.25M20.25 18.75L20.25 5.25L3.75 5.25L3.75 18.75ZM12.726 15.562C12.765 15.716 12.755 15.878 12.697 16.025C12.639 16.173 12.536 16.298 12.402 16.383C12.268 16.468 12.111 16.509 11.953 16.499C11.795 16.489 11.644 16.43 11.521 16.329C11.399 16.228 11.312 16.091 11.273 15.938C11.026 14.976 10.048 14.25 8.999 14.25C7.95 14.25 6.973 14.976 6.726 15.938C6.686 16.091 6.599 16.228 6.477 16.329C6.354 16.43 6.203 16.489 6.045 16.499C5.887 16.509 5.73 16.468 5.596 16.383C5.463 16.298 5.359 16.173 5.301 16.025C5.243 15.878 5.233 15.716 5.273 15.562C5.393 15.114 5.597 14.691 5.872 14.317C6.148 13.942 6.491 13.623 6.884 13.374C6.463 12.956 6.175 12.421 6.058 11.839C5.941 11.256 5.999 10.652 6.226 10.103C6.452 9.554 6.837 9.084 7.33 8.754C7.824 8.423 8.405 8.247 8.999 8.247C9.593 8.247 10.174 8.423 10.668 8.754C11.161 9.084 11.546 9.554 11.772 10.103C11.999 10.652 12.057 11.256 11.94 11.839C11.823 12.421 11.535 12.956 11.114 13.374C11.507 13.622 11.851 13.942 12.127 14.316C12.403 14.691 12.606 15.113 12.727 15.562ZM9 12.75C9.297 12.75 9.587 12.662 9.833 12.497C10.08 12.332 10.272 12.098 10.386 11.824C10.499 11.55 10.529 11.248 10.471 10.957C10.413 10.666 10.27 10.399 10.061 10.189C9.851 9.98 9.584 9.837 9.293 9.779C9.002 9.721 8.7 9.751 8.426 9.864C8.152 9.978 7.918 10.17 7.753 10.417C7.588 10.663 7.5 10.953 7.5 11.25C7.5 11.513 7.569 11.772 7.701 12C7.833 12.228 8.022 12.417 8.25 12.549C8.478 12.681 8.737 12.75 9 12.75',
        true,
        false
      )
    ],
    [
      (
        'M10.5 11.25C10.5 11.547 10.412 11.837 10.247 12.083C10.082 12.33 9.848 12.522 9.574 12.636C9.3 12.749 8.998 12.779 8.707 12.721C8.416 12.663 8.149 12.52 7.939 12.311C7.73 12.101 7.587 11.834 7.529 11.543C7.471 11.252 7.501 10.95 7.614 10.676C7.728 10.402 7.92 10.168 8.167 10.003C8.413 9.838 8.703 9.75 9 9.75C9.263 9.75 9.522 9.819 9.75 9.951C9.978 10.083 10.167 10.272 10.299 10.5C10.431 10.728 10.5 10.987 10.5 11.25M21.75 5.25L21.75 18.75C21.75 19.013 21.681 19.272 21.549 19.5C21.417 19.728 21.228 19.917 21 20.049C20.772 20.181 20.513 20.25 20.25 20.25L3.75 20.25C3.487 20.25 3.228 20.181 3 20.049C2.772 19.917 2.583 19.728 2.451 19.5C2.319 19.272 2.25 19.013 2.25 18.75L2.25 5.25C2.25 4.987 2.319 4.728 2.451 4.5C2.583 4.272 2.772 4.083 3 3.951C3.228 3.819 3.487 3.75 3.75 3.75L20.25 3.75C20.513 3.75 20.772 3.819 21 3.951C21.228 4.083 21.417 4.272 21.549 4.5C21.681 4.728 21.75 4.987 21.75 5.25M12.727 15.562C12.606 15.113 12.403 14.691 12.127 14.316C11.852 13.942 11.508 13.622 11.115 13.374C11.536 12.956 11.824 12.421 11.941 11.839C12.058 11.256 12 10.652 11.773 10.103C11.547 9.554 11.162 9.084 10.669 8.754C10.175 8.423 9.594 8.247 9 8.247C8.406 8.247 7.825 8.423 7.331 8.754C6.838 9.084 6.453 9.554 6.227 10.103C6 10.652 5.942 11.256 6.059 11.839C6.176 12.421 6.464 12.956 6.885 13.374C6.492 13.623 6.149 13.942 5.873 14.317C5.597 14.691 5.394 15.114 5.273 15.562C5.234 15.716 5.244 15.878 5.302 16.025C5.36 16.173 5.463 16.298 5.597 16.383C5.731 16.468 5.888 16.509 6.046 16.499C6.204 16.489 6.355 16.43 6.478 16.329C6.6 16.228 6.687 16.091 6.727 15.938C6.974 14.977 7.951 14.25 9 14.25C10.049 14.25 11.027 14.975 11.273 15.938C11.313 16.091 11.4 16.228 11.522 16.329C11.645 16.43 11.796 16.489 11.954 16.499C12.112 16.509 12.269 16.468 12.403 16.383C12.537 16.298 12.64 16.173 12.698 16.025C12.756 15.878 12.766 15.716 12.727 15.562M18.75 13.5C18.75 13.368 18.715 13.239 18.65 13.125C18.584 13.011 18.489 12.916 18.375 12.85C18.261 12.785 18.132 12.75 18 12.75L14.25 12.75C14.092 12.75 13.937 12.8 13.809 12.893C13.681 12.986 13.586 13.118 13.537 13.268C13.488 13.419 13.488 13.581 13.537 13.732C13.586 13.882 13.681 14.014 13.809 14.107C13.937 14.2 14.092 14.25 14.25 14.25L18 14.25C18.132 14.25 18.261 14.215 18.375 14.15C18.489 14.084 18.584 13.989 18.65 13.875C18.715 13.761 18.75 13.632 18.75 13.5M18.75 10.5C18.75 10.368 18.715 10.239 18.65 10.125C18.584 10.011 18.489 9.916 18.375 9.85C18.261 9.785 18.132 9.75 18 9.75L14.25 9.75C14.092 9.75 13.937 9.8 13.809 9.893C13.681 9.986 13.586 10.118 13.537 10.268C13.488 10.419 13.488 10.581 13.537 10.732C13.586 10.882 13.681 11.014 13.809 11.107C13.937 11.2 14.092 11.25 14.25 11.25L18 11.25C18.132 11.25 18.261 11.215 18.375 11.15C18.489 11.084 18.584 10.989 18.65 10.875C18.715 10.761 18.75 10.632 18.75 10.5',
        true,
        false
      )
    ]
  ),
  'การส่งตรวจ': (
    [
      (
        'M18.75 3L15.351 3C14.787 2.369 14.057 1.91 13.244 1.676C12.431 1.442 11.569 1.442 10.756 1.676C9.943 1.91 9.213 2.369 8.649 3L5.25 3C4.987 3 4.728 3.069 4.5 3.201C4.272 3.333 4.083 3.522 3.951 3.75C3.819 3.978 3.75 4.237 3.75 4.5L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L18.75 21.75C19.013 21.75 19.272 21.681 19.5 21.549C19.728 21.417 19.917 21.228 20.049 21C20.181 20.772 20.25 20.513 20.25 20.25L20.25 4.5C20.25 4.237 20.181 3.978 20.049 3.75C19.917 3.522 19.728 3.333 19.5 3.201C19.272 3.069 19.013 3 18.75 3M12 3C12.527 3 13.044 3.139 13.5 3.402C13.956 3.665 14.335 4.044 14.598 4.5C14.861 4.956 15 5.473 15 6L9 6C9 5.473 9.139 4.956 9.402 4.5C9.665 4.044 10.044 3.665 10.5 3.402C10.956 3.139 11.473 3 12 3M18.75 20.25L5.25 20.25L5.25 4.5L7.758 4.5C7.587 4.982 7.5 5.489 7.5 6L7.5 6.75C7.5 6.882 7.535 7.011 7.6 7.125C7.666 7.239 7.761 7.334 7.875 7.4C7.989 7.465 8.118 7.5 8.25 7.5L15.75 7.5C15.882 7.5 16.011 7.465 16.125 7.4C16.239 7.334 16.334 7.239 16.4 7.125C16.465 7.011 16.5 6.882 16.5 6.75L16.5 6C16.5 5.489 16.413 4.982 16.242 4.5L18.75 4.5Z',
        true,
        false
      )
    ],
    [
      (
        'M18.75 3L15.351 3C14.787 2.369 14.057 1.91 13.244 1.676C12.431 1.442 11.569 1.442 10.756 1.676C9.943 1.91 9.213 2.369 8.649 3L5.25 3C4.987 3 4.728 3.069 4.5 3.201C4.272 3.333 4.083 3.522 3.951 3.75C3.819 3.978 3.75 4.237 3.75 4.5L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L18.75 21.75C19.013 21.75 19.272 21.681 19.5 21.549C19.728 21.417 19.917 21.228 20.049 21C20.181 20.772 20.25 20.513 20.25 20.25L20.25 4.5C20.25 4.237 20.181 3.978 20.049 3.75C19.917 3.522 19.728 3.333 19.5 3.201C19.272 3.069 19.013 3 18.75 3M12 3C12.527 3 13.044 3.139 13.5 3.402C13.956 3.665 14.335 4.044 14.598 4.5C14.861 4.956 15 5.473 15 6L9 6C9 5.473 9.139 4.956 9.402 4.5C9.665 4.044 10.044 3.665 10.5 3.402C10.956 3.139 11.473 3 12 3',
        true,
        false
      )
    ]
  ),
  // Figma 479:132 หมวกพยาบาลมีกากบาท · เลือก = หมวกทึบ เจาะกากบาท + เส้นแบ่งแถบ
  'กิจกรรมพยาบาล': (
    [
      (
        'M11.714 4.465C12.017 4.447 12.328 4.462 12.632 4.47C14.414 4.512 17.401 4.841 18.933 5.72C19.194 5.87 19.482 6.116 19.646 6.37C19.947 6.834 20.164 7.668 20.354 8.21C20.507 8.651 20.696 9.094 20.817 9.545C21.388 9.745 23.111 10.346 23.489 10.719C23.64 10.868 23.746 11.113 23.75 11.324C23.752 11.452 23.732 11.574 23.691 11.695C23.562 12.074 23.393 12.446 23.245 12.818L22.296 15.212L21.385 17.519C21.213 17.961 21.043 18.403 20.865 18.843C20.674 19.313 20.229 19.603 19.718 19.533C19.439 19.495 19.166 19.437 18.891 19.386C18.453 19.303 18.014 19.231 17.573 19.17C15.892 18.931 14.058 18.752 12.358 18.757C10.526 18.745 8.696 18.865 6.882 19.117C6.342 19.19 5.803 19.273 5.266 19.366C4.537 19.495 3.652 19.817 3.19 18.973C3.037 18.694 2.929 18.358 2.813 18.059L2.215 16.53L1.053 13.569C0.82 12.979 0.592 12.385 0.354 11.797C0.237 11.512 0.203 11.267 0.336 10.979C0.525 10.569 0.942 10.444 1.325 10.276C1.922 10.016 2.534 9.802 3.147 9.584C3.237 9.384 3.352 9.028 3.429 8.812L3.933 7.399C4.042 7.091 4.137 6.76 4.301 6.478C4.625 5.918 5.159 5.646 5.743 5.439C6.989 5 8.32 4.743 9.632 4.599C10.323 4.526 11.018 4.481 11.714 4.465ZM12.721 18.037C14.47 18.078 16.216 18.229 17.947 18.49C18.366 18.554 18.784 18.624 19.202 18.7C19.67 18.785 19.998 18.999 20.193 18.482C21.092 16.095 22.083 13.74 22.989 11.358C23.009 11.305 22.867 11.172 22.797 11.139C19.364 9.504 15.487 8.972 11.716 9.011C11.59 9.012 11.46 9.011 11.335 9.018C8.093 9.103 4.832 9.594 1.829 10.875C0.77 11.326 0.911 11.157 1.327 12.214L1.984 13.881L3.262 17.139C3.438 17.584 3.601 18.035 3.782 18.478C3.847 18.635 3.908 18.822 4.11 18.816C4.335 18.811 4.554 18.76 4.774 18.72C5.025 18.676 5.276 18.634 5.528 18.594C7.244 18.308 8.977 18.128 10.715 18.056C11.257 18.033 12.194 18.002 12.721 18.037ZM4.07 9.303C6.74 8.59 9.494 8.238 12.258 8.258C14.3 8.262 16.336 8.471 18.335 8.883C18.788 8.98 19.497 9.143 19.932 9.288C19.744 8.807 19.584 8.317 19.405 7.833C19.298 7.54 19.171 7.088 19 6.84C18.845 6.616 18.509 6.381 18.257 6.277C16.674 5.622 14.869 5.364 13.166 5.289C12.784 5.272 12.149 5.24 11.781 5.266C10.006 5.336 8.281 5.485 6.572 6.021C5.981 6.206 5.192 6.411 4.909 7.03C4.822 7.221 4.753 7.441 4.682 7.64L4.276 8.776C4.222 8.929 4.145 9.17 4.07 9.303Z',
        true,
        false
      ),
      (
        'M11.314 10.846L12.244 10.844C13.026 10.842 13.419 10.813 13.356 11.776C13.341 12.016 13.387 12.307 13.336 12.551C13.684 12.528 14.062 12.554 14.406 12.55C15.204 12.537 15.136 13.132 15.122 13.672C15.096 14.703 15.362 15.337 14.008 15.233C13.838 15.22 13.535 15.241 13.341 15.226C13.36 15.606 13.38 16.095 13.337 16.475C13.307 16.735 13.051 16.909 12.788 16.919L11.385 16.924C10.867 16.923 10.674 16.738 10.675 16.21C10.676 15.887 10.678 15.558 10.681 15.235C10.119 15.221 8.773 15.458 8.91 14.546C8.978 14.091 8.661 12.682 9.309 12.579C9.687 12.518 10.28 12.554 10.689 12.541C10.687 12.519 10.685 12.497 10.684 12.475C10.66 12.138 10.664 11.614 10.692 11.273C10.716 10.965 11.028 10.855 11.314 10.846ZM11.348 11.524C11.362 11.796 11.359 12.076 11.36 12.343C11.36 12.862 11.431 13.285 10.743 13.244C10.38 13.223 9.96 13.273 9.597 13.238C9.606 13.421 9.607 14.411 9.579 14.545C9.962 14.545 10.347 14.544 10.729 14.549C10.973 14.551 11.229 14.558 11.33 14.812C11.4 14.986 11.327 16.188 11.362 16.241L11.382 16.244L12.689 16.247C12.625 15.898 12.688 15.304 12.672 14.935C12.654 14.495 13.264 14.545 13.572 14.544L14.448 14.542C14.429 14.375 14.424 13.414 14.438 13.235C14.024 13.266 13.573 13.233 13.153 13.241C12.456 13.255 12.721 12.489 12.669 12.052C12.656 11.943 12.694 11.58 12.654 11.521L12.643 11.523C12.236 11.525 11.751 11.536 11.348 11.524Z',
        true,
        false
      )
    ],
    [
      (
        'M11.714 4.465C12.017 4.447 12.328 4.462 12.632 4.47C14.414 4.512 17.401 4.841 18.933 5.72C19.194 5.87 19.482 6.116 19.646 6.37C19.947 6.834 20.164 7.668 20.354 8.21C20.507 8.651 20.696 9.094 20.817 9.545C21.388 9.745 23.111 10.346 23.489 10.719C23.64 10.868 23.746 11.113 23.75 11.324C23.752 11.452 23.732 11.574 23.691 11.695C23.562 12.074 23.393 12.446 23.245 12.818L22.296 15.212L21.385 17.519C21.213 17.961 21.043 18.403 20.865 18.843C20.674 19.313 20.229 19.603 19.718 19.533C19.439 19.495 19.166 19.437 18.891 19.386C18.453 19.303 18.014 19.231 17.573 19.17C15.892 18.931 14.058 18.752 12.358 18.757C10.526 18.745 8.696 18.865 6.882 19.117C6.342 19.19 5.803 19.273 5.266 19.366C4.537 19.495 3.652 19.817 3.19 18.973C3.037 18.694 2.929 18.358 2.813 18.059L2.215 16.53L1.053 13.569C0.82 12.979 0.592 12.385 0.354 11.797C0.237 11.512 0.203 11.267 0.336 10.979C0.525 10.569 0.942 10.444 1.325 10.276C1.922 10.016 2.534 9.802 3.147 9.584C3.237 9.384 3.352 9.028 3.429 8.812L3.933 7.399C4.042 7.091 4.137 6.76 4.301 6.478C4.625 5.918 5.159 5.646 5.743 5.439C6.989 5 8.32 4.743 9.632 4.599C10.323 4.526 11.018 4.481 11.714 4.465Z',
        true,
        false
      ),
      (
        '~M12.721 18.037C14.47 18.078 16.216 18.229 17.947 18.49C18.366 18.554 18.784 18.624 19.202 18.7C19.67 18.785 19.998 18.999 20.193 18.482C21.092 16.095 22.083 13.74 22.989 11.358C23.009 11.305 22.867 11.172 22.797 11.139C19.364 9.504 15.487 8.972 11.716 9.011C11.59 9.012 11.46 9.011 11.335 9.018C8.093 9.103 4.832 9.594 1.829 10.875C0.77 11.326 0.911 11.157 1.327 12.214L1.984 13.881L3.262 17.139C3.438 17.584 3.601 18.035 3.782 18.478C3.847 18.635 3.908 18.822 4.11 18.816C4.335 18.811 4.554 18.76 4.774 18.72C5.025 18.676 5.276 18.634 5.528 18.594C7.244 18.308 8.977 18.128 10.715 18.056C11.257 18.033 12.194 18.002 12.721 18.037Z',
        true,
        false
      ),
      (
        '!M11.177 11.689L12.588 11.689L12.588 13.164L14.064 13.164L14.064 14.575L12.588 14.575L12.588 16.05L11.177 16.05L11.177 14.575L9.702 14.575L9.702 13.164L11.177 13.164Z',
        true,
        false
      )
    ]
  ),
  'Lab/X-Ray': (
    [
      (
        'M22.281 8.094L16.656 2.469C16.563 2.376 16.446 2.309 16.319 2.275C16.192 2.241 16.058 2.241 15.931 2.275C15.804 2.309 15.687 2.376 15.594 2.469L3.479 14.585C2.852 15.211 2.44 16.021 2.301 16.896C2.163 17.772 2.305 18.669 2.707 19.458C3.11 20.248 3.752 20.89 4.542 21.293C5.331 21.695 6.228 21.837 7.104 21.699C7.979 21.56 8.789 21.148 9.415 20.521L19.905 10.031L21.987 9.337C22.109 9.297 22.218 9.226 22.304 9.132C22.39 9.038 22.451 8.923 22.48 8.798C22.51 8.674 22.507 8.544 22.472 8.421C22.437 8.298 22.371 8.186 22.281 8.095ZM8.354 19.46C7.949 19.85 7.432 20.104 6.875 20.186C6.318 20.268 5.749 20.174 5.249 19.916C4.749 19.659 4.341 19.251 4.084 18.751C3.826 18.251 3.732 17.682 3.814 17.125C3.896 16.568 4.15 16.051 4.54 15.646L7.24 12.946C8.034 12.674 9.279 12.571 10.903 13.415C11.897 13.934 12.795 14.165 13.581 14.233ZM19.263 8.663C19.152 8.7 19.052 8.762 18.969 8.844L15.26 12.554C14.466 12.826 13.221 12.929 11.597 12.085C10.603 11.566 9.705 11.335 8.919 11.267L16.125 4.06L20.362 8.297Z',
        true,
        false
      )
    ],
    [
      (
        'M22.281 8.094L16.656 2.469C16.563 2.376 16.446 2.309 16.319 2.275C16.192 2.241 16.058 2.241 15.931 2.275C15.804 2.309 15.687 2.376 15.594 2.469L3.479 14.585C2.852 15.211 2.44 16.021 2.301 16.896C2.163 17.772 2.305 18.669 2.707 19.458C3.11 20.248 3.752 20.89 4.542 21.293C5.331 21.695 6.228 21.837 7.104 21.699C7.979 21.56 8.789 21.148 9.415 20.521L19.905 10.031L21.987 9.337C22.109 9.297 22.218 9.226 22.304 9.132C22.39 9.038 22.451 8.923 22.48 8.798C22.51 8.674 22.507 8.544 22.472 8.421C22.437 8.298 22.371 8.186 22.281 8.095ZM19.263 8.663C19.152 8.7 19.052 8.762 18.969 8.844L15.26 12.554C14.466 12.826 13.221 12.929 11.597 12.085C10.603 11.566 9.705 11.335 8.919 11.267L16.125 4.06L20.362 8.297Z',
        true,
        false
      )
    ]
  ),
  'Lab': (
    [
      (
        'M22.281 8.094L16.656 2.469C16.563 2.376 16.446 2.309 16.319 2.275C16.192 2.241 16.058 2.241 15.931 2.275C15.804 2.309 15.687 2.376 15.594 2.469L3.479 14.585C2.852 15.211 2.44 16.021 2.301 16.896C2.163 17.772 2.305 18.669 2.707 19.458C3.11 20.248 3.752 20.89 4.542 21.293C5.331 21.695 6.228 21.837 7.104 21.699C7.979 21.56 8.789 21.148 9.415 20.521L19.905 10.031L21.987 9.337C22.109 9.297 22.218 9.226 22.304 9.132C22.39 9.038 22.451 8.923 22.48 8.798C22.51 8.674 22.507 8.544 22.472 8.421C22.437 8.298 22.371 8.186 22.281 8.095ZM8.354 19.46C7.949 19.85 7.432 20.104 6.875 20.186C6.318 20.268 5.749 20.174 5.249 19.916C4.749 19.659 4.341 19.251 4.084 18.751C3.826 18.251 3.732 17.682 3.814 17.125C3.896 16.568 4.15 16.051 4.54 15.646L7.24 12.946C8.034 12.674 9.279 12.571 10.903 13.415C11.897 13.934 12.795 14.165 13.581 14.233ZM19.263 8.663C19.152 8.7 19.052 8.762 18.969 8.844L15.26 12.554C14.466 12.826 13.221 12.929 11.597 12.085C10.603 11.566 9.705 11.335 8.919 11.267L16.125 4.06L20.362 8.297Z',
        true,
        false
      )
    ],
    [
      (
        'M22.281 8.094L16.656 2.469C16.563 2.376 16.446 2.309 16.319 2.275C16.192 2.241 16.058 2.241 15.931 2.275C15.804 2.309 15.687 2.376 15.594 2.469L3.479 14.585C2.852 15.211 2.44 16.021 2.301 16.896C2.163 17.772 2.305 18.669 2.707 19.458C3.11 20.248 3.752 20.89 4.542 21.293C5.331 21.695 6.228 21.837 7.104 21.699C7.979 21.56 8.789 21.148 9.415 20.521L19.905 10.031L21.987 9.337C22.109 9.297 22.218 9.226 22.304 9.132C22.39 9.038 22.451 8.923 22.48 8.798C22.51 8.674 22.507 8.544 22.472 8.421C22.437 8.298 22.371 8.186 22.281 8.095ZM19.263 8.663C19.152 8.7 19.052 8.762 18.969 8.844L15.26 12.554C14.466 12.826 13.221 12.929 11.597 12.085C10.603 11.566 9.705 11.335 8.919 11.267L16.125 4.06L20.362 8.297Z',
        true,
        false
      )
    ]
  ),
  'ยา': (
    [
      (
        'M20.289 3.713C19.67 3.093 18.898 2.647 18.051 2.42C17.205 2.193 16.313 2.193 15.466 2.42C14.62 2.647 13.848 3.093 13.228 3.713L3.713 13.227C2.983 13.976 2.506 14.935 2.35 15.969C2.195 17.003 2.368 18.061 2.845 18.991C3.322 19.922 4.079 20.679 5.01 21.156C5.94 21.633 6.998 21.806 8.032 21.65C9.066 21.494 10.025 21.018 10.774 20.288L20.29 10.773C20.909 10.153 21.354 9.381 21.58 8.534C21.806 7.688 21.806 6.797 21.58 5.951C21.353 5.104 20.908 4.333 20.289 3.713M9.713 19.227C9.192 19.749 8.518 20.092 7.79 20.208C7.061 20.323 6.315 20.205 5.658 19.87C5 19.535 4.466 19.001 4.131 18.344C3.796 17.686 3.678 16.94 3.793 16.211C3.908 15.483 4.251 14.809 4.773 14.288L9 10.06L13.941 15ZM19.229 9.713L15 13.94L10.061 9L14.289 4.773C14.813 4.261 15.484 3.927 16.208 3.818C16.932 3.708 17.672 3.829 18.323 4.163C18.975 4.497 19.505 5.027 19.839 5.678C20.173 6.33 20.294 7.07 20.184 7.794C20.075 8.518 19.741 9.189 19.229 9.712M17.782 7.719C17.876 7.812 17.943 7.929 17.977 8.056C18.011 8.183 18.011 8.317 17.977 8.444C17.943 8.571 17.876 8.688 17.782 8.781L15.532 11.031C15.439 11.124 15.323 11.191 15.196 11.225C15.069 11.259 14.935 11.259 14.808 11.224C14.681 11.19 14.565 11.123 14.472 11.03C14.379 10.937 14.312 10.821 14.278 10.694C14.244 10.567 14.244 10.433 14.278 10.306C14.312 10.178 14.379 10.062 14.472 9.969L16.722 7.719C16.815 7.626 16.931 7.559 17.058 7.525C17.185 7.491 17.319 7.491 17.446 7.525C17.573 7.559 17.689 7.626 17.782 7.719',
        true,
        false
      )
    ],
    [
      (
        'M20.29 3.713C19.67 3.093 18.898 2.647 18.052 2.42C17.205 2.193 16.313 2.193 15.467 2.42C14.62 2.647 13.848 3.093 13.228 3.713L3.713 13.227C2.983 13.976 2.506 14.935 2.35 15.969C2.195 17.003 2.368 18.061 2.845 18.991C3.322 19.922 4.079 20.679 5.01 21.156C5.94 21.633 6.998 21.806 8.032 21.65C9.066 21.494 10.025 21.018 10.774 20.288L20.29 10.773C20.909 10.153 21.354 9.381 21.58 8.534C21.807 7.688 21.807 6.797 21.58 5.951C21.354 5.105 20.909 4.333 20.29 3.713M19.229 9.713L14.471 14.469L9.532 9.531L14.289 4.773C14.813 4.261 15.484 3.927 16.208 3.818C16.932 3.708 17.672 3.829 18.323 4.163C18.975 4.497 19.505 5.027 19.839 5.678C20.173 6.33 20.294 7.07 20.184 7.794C20.075 8.518 19.741 9.189 19.229 9.712M17.782 7.719C17.876 7.812 17.943 7.929 17.977 8.056C18.011 8.183 18.011 8.317 17.977 8.444C17.943 8.571 17.876 8.688 17.782 8.781L15.533 11.031C15.439 11.124 15.323 11.191 15.196 11.225C15.069 11.259 14.935 11.259 14.808 11.224C14.681 11.19 14.565 11.123 14.472 11.03C14.379 10.937 14.312 10.821 14.278 10.694C14.244 10.567 14.244 10.433 14.278 10.306C14.312 10.178 14.379 10.062 14.472 9.969L16.722 7.719C16.815 7.626 16.931 7.559 17.058 7.525C17.185 7.491 17.319 7.491 17.446 7.525C17.573 7.559 17.689 7.626 17.782 7.719',
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
  'คำสั่งแพทย์': (
    [
      (
        'M15.75 14.25C15.75 14.382 15.715 14.511 15.65 14.625C15.584 14.739 15.489 14.834 15.375 14.9C15.261 14.965 15.132 15 15 15L9 15C8.842 15 8.687 14.95 8.559 14.857C8.431 14.764 8.336 14.632 8.287 14.482C8.238 14.331 8.238 14.169 8.287 14.018C8.336 13.868 8.431 13.736 8.559 13.643C8.687 13.55 8.842 13.5 9 13.5L15 13.5C15.132 13.5 15.261 13.535 15.375 13.6C15.489 13.666 15.584 13.761 15.65 13.875C15.715 13.989 15.75 14.118 15.75 14.25M15 10.5L9 10.5C8.842 10.5 8.687 10.55 8.559 10.643C8.431 10.736 8.336 10.868 8.287 11.018C8.238 11.169 8.238 11.331 8.287 11.482C8.336 11.632 8.431 11.764 8.559 11.857C8.687 11.95 8.842 12 9 12L15 12C15.158 12 15.313 11.95 15.441 11.857C15.569 11.764 15.664 11.632 15.713 11.482C15.762 11.331 15.762 11.169 15.713 11.018C15.664 10.868 15.569 10.736 15.441 10.643C15.313 10.55 15.158 10.5 15 10.5M20.25 4.5L20.25 20.25C20.25 20.513 20.181 20.772 20.049 21C19.917 21.228 19.728 21.417 19.5 21.549C19.272 21.681 19.013 21.75 18.75 21.75L5.25 21.75C4.987 21.75 4.728 21.681 4.5 21.549C4.272 21.417 4.083 21.228 3.951 21C3.819 20.772 3.75 20.513 3.75 20.25L3.75 4.5C3.75 4.237 3.819 3.978 3.951 3.75C4.083 3.522 4.272 3.333 4.5 3.201C4.728 3.069 4.987 3 5.25 3L8.649 3C9.213 2.369 9.943 1.91 10.756 1.676C11.569 1.442 12.431 1.442 13.244 1.676C14.057 1.91 14.787 2.369 15.351 3L18.75 3C19.013 3 19.272 3.069 19.5 3.201C19.728 3.333 19.917 3.522 20.049 3.75C20.181 3.978 20.25 4.237 20.25 4.5M9 6L15 6C15 5.367 14.799 4.749 14.427 4.237C14.055 3.724 13.529 3.343 12.927 3.147C12.325 2.951 11.675 2.951 11.073 3.147C10.471 3.343 9.945 3.724 9.573 4.237C9.201 4.749 9 5.367 9 6M18.75 4.5L16.242 4.5C16.413 4.982 16.5 5.489 16.5 6L16.5 6.75C16.5 6.882 16.465 7.011 16.4 7.125C16.334 7.239 16.239 7.334 16.125 7.4C16.011 7.465 15.882 7.5 15.75 7.5L8.25 7.5C8.118 7.5 7.989 7.465 7.875 7.4C7.761 7.334 7.666 7.239 7.6 7.125C7.535 7.011 7.5 6.882 7.5 6.75L7.5 6C7.5 5.489 7.587 4.982 7.758 4.5L5.25 4.5L5.25 20.25L18.75 20.25Z',
        true,
        false
      )
    ],
    [
      (
        'M18.75 3L15.351 3C14.787 2.369 14.057 1.91 13.244 1.676C12.431 1.442 11.569 1.442 10.756 1.676C9.943 1.91 9.213 2.369 8.649 3L5.25 3C4.987 3 4.728 3.069 4.5 3.201C4.272 3.333 4.083 3.522 3.951 3.75C3.819 3.978 3.75 4.237 3.75 4.5L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L18.75 21.75C19.013 21.75 19.272 21.681 19.5 21.549C19.728 21.417 19.917 21.228 20.049 21C20.181 20.772 20.25 20.513 20.25 20.25L20.25 4.5C20.25 4.237 20.181 3.978 20.049 3.75C19.917 3.522 19.728 3.333 19.5 3.201C19.272 3.069 19.013 3 18.75 3M12 3C12.527 3 13.044 3.139 13.5 3.402C13.956 3.665 14.335 4.044 14.598 4.5C14.861 4.956 15 5.473 15 6L9 6C9 5.473 9.139 4.956 9.402 4.5C9.665 4.044 10.044 3.665 10.5 3.402C10.956 3.139 11.473 3 12 3M15 15L9 15C8.842 15 8.687 14.95 8.559 14.857C8.431 14.764 8.336 14.632 8.287 14.482C8.238 14.331 8.238 14.169 8.287 14.018C8.336 13.868 8.431 13.736 8.559 13.643C8.687 13.55 8.842 13.5 9 13.5L15 13.5C15.158 13.5 15.313 13.55 15.441 13.643C15.569 13.736 15.664 13.868 15.713 14.018C15.762 14.169 15.762 14.331 15.713 14.482C15.664 14.632 15.569 14.764 15.441 14.857C15.313 14.95 15.158 15 15 15M15 12L9 12C8.842 12 8.687 11.95 8.559 11.857C8.431 11.764 8.336 11.632 8.287 11.482C8.238 11.331 8.238 11.169 8.287 11.018C8.336 10.868 8.431 10.736 8.559 10.643C8.687 10.55 8.842 10.5 9 10.5L15 10.5C15.158 10.5 15.313 10.55 15.441 10.643C15.569 10.736 15.664 10.868 15.713 11.018C15.762 11.169 15.762 11.331 15.713 11.482C15.664 11.632 15.569 11.764 15.441 11.857C15.313 11.95 15.158 12 15 12',
        true,
        false
      )
    ]
  ),
  'อื่น ๆ': (
    [
      (
        'M13.125 12C13.125 12.222 13.059 12.44 12.935 12.625C12.812 12.81 12.636 12.954 12.431 13.039C12.225 13.125 11.999 13.147 11.781 13.103C11.562 13.06 11.362 12.953 11.205 12.795C11.047 12.638 10.94 12.438 10.897 12.219C10.853 12.001 10.875 11.775 10.961 11.569C11.046 11.364 11.19 11.188 11.375 11.065C11.56 10.941 11.778 10.875 12 10.875C12.197 10.875 12.391 10.927 12.562 11.026C12.734 11.124 12.876 11.266 12.974 11.438C13.073 11.609 13.125 11.803 13.125 12M18.375 10.875C18.153 10.875 17.935 10.941 17.75 11.065C17.565 11.188 17.421 11.364 17.336 11.569C17.25 11.775 17.228 12.001 17.272 12.219C17.315 12.438 17.422 12.638 17.58 12.795C17.737 12.953 17.937 13.06 18.156 13.103C18.374 13.147 18.6 13.125 18.806 13.039C19.011 12.954 19.187 12.81 19.31 12.625C19.434 12.44 19.5 12.222 19.5 12C19.5 11.803 19.448 11.609 19.349 11.438C19.251 11.266 19.109 11.124 18.938 11.026C18.766 10.927 18.572 10.875 18.375 10.875M5.625 10.875C5.403 10.875 5.185 10.941 5 11.065C4.815 11.188 4.671 11.364 4.586 11.569C4.5 11.775 4.478 12.001 4.522 12.219C4.565 12.438 4.672 12.638 4.83 12.795C4.987 12.953 5.187 13.06 5.406 13.103C5.624 13.147 5.85 13.125 6.056 13.039C6.261 12.954 6.437 12.81 6.56 12.625C6.684 12.44 6.75 12.222 6.75 12C6.75 11.803 6.698 11.609 6.599 11.438C6.501 11.266 6.359 11.124 6.188 11.026C6.016 10.927 5.822 10.875 5.625 10.875',
        true,
        false
      )
    ],
    [
      (
        'M21 7.5L3 7.5C2.737 7.5 2.478 7.569 2.25 7.701C2.022 7.833 1.833 8.022 1.701 8.25C1.569 8.478 1.5 8.737 1.5 9L1.5 15C1.5 15.263 1.569 15.522 1.701 15.75C1.833 15.978 2.022 16.167 2.25 16.299C2.478 16.431 2.737 16.5 3 16.5L21 16.5C21.263 16.5 21.522 16.431 21.75 16.299C21.978 16.167 22.167 15.978 22.299 15.75C22.431 15.522 22.5 15.263 22.5 15L22.5 9C22.5 8.737 22.431 8.478 22.299 8.25C22.167 8.022 21.978 7.833 21.75 7.701C21.522 7.569 21.263 7.5 21 7.5M5.625 13.125C5.403 13.125 5.185 13.059 5 12.935C4.815 12.812 4.671 12.636 4.586 12.431C4.5 12.225 4.478 11.999 4.522 11.781C4.565 11.562 4.672 11.362 4.83 11.205C4.987 11.047 5.187 10.94 5.406 10.897C5.624 10.853 5.85 10.875 6.056 10.961C6.261 11.046 6.437 11.19 6.56 11.375C6.684 11.56 6.75 11.778 6.75 12C6.75 12.197 6.698 12.391 6.599 12.562C6.501 12.734 6.359 12.876 6.188 12.974C6.016 13.073 5.822 13.125 5.625 13.125M12 13.125C11.778 13.125 11.56 13.059 11.375 12.935C11.19 12.812 11.046 12.636 10.961 12.431C10.875 12.225 10.853 11.999 10.897 11.781C10.94 11.562 11.047 11.362 11.205 11.205C11.362 11.047 11.562 10.94 11.781 10.897C11.999 10.853 12.225 10.875 12.431 10.961C12.636 11.046 12.812 11.19 12.935 11.375C13.059 11.56 13.125 11.778 13.125 12C13.125 12.197 13.073 12.391 12.974 12.562C12.876 12.734 12.734 12.876 12.562 12.974C12.391 13.073 12.197 13.125 12 13.125M18.375 13.125C18.153 13.125 17.935 13.059 17.75 12.935C17.565 12.812 17.421 12.636 17.336 12.431C17.25 12.225 17.228 11.999 17.272 11.781C17.315 11.562 17.422 11.362 17.58 11.205C17.737 11.047 17.937 10.94 18.156 10.897C18.374 10.853 18.6 10.875 18.806 10.961C19.011 11.046 19.187 11.19 19.31 11.375C19.434 11.56 19.5 11.778 19.5 12C19.5 12.197 19.448 12.391 19.349 12.562C19.251 12.734 19.109 12.876 18.938 12.974C18.766 13.073 18.572 13.125 18.375 13.125',
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
  'ภาพถ่าย': (
    [
      (
        'M20.25 3.75L3.75 3.75C3.487 3.75 3.228 3.819 3 3.951C2.772 4.083 2.583 4.272 2.451 4.5C2.319 4.728 2.25 4.987 2.25 5.25L2.25 18.75C2.25 19.013 2.319 19.272 2.451 19.5C2.583 19.728 2.772 19.917 3 20.049C3.228 20.181 3.487 20.25 3.75 20.25L20.25 20.25C20.513 20.25 20.772 20.181 21 20.049C21.228 19.917 21.417 19.728 21.549 19.5C21.681 19.272 21.75 19.013 21.75 18.75L21.75 5.25C21.75 4.987 21.681 4.728 21.549 4.5C21.417 4.272 21.228 4.083 21 3.951C20.772 3.819 20.513 3.75 20.25 3.75M20.25 5.25L20.25 14.883L17.806 12.44C17.62 12.253 17.388 12.12 17.133 12.051C16.879 11.983 16.611 11.983 16.357 12.051C16.103 12.12 15.871 12.253 15.684 12.44L13.809 14.315L9.684 10.19C9.498 10.004 9.266 9.87 9.012 9.802C8.758 9.734 8.49 9.734 8.236 9.802C7.982 9.87 7.75 10.004 7.564 10.19L3.75 14.003L3.75 5.25ZM3.75 16.125L8.625 11.25L16.125 18.75L3.75 18.75ZM20.25 18.75L18.247 18.75L14.872 15.375L16.747 13.5L20.25 17.004ZM13.5 9.375C13.5 9.153 13.566 8.935 13.69 8.75C13.813 8.565 13.989 8.421 14.194 8.336C14.4 8.25 14.626 8.228 14.844 8.272C15.063 8.315 15.263 8.422 15.42 8.58C15.578 8.737 15.685 8.937 15.728 9.156C15.772 9.374 15.75 9.6 15.664 9.806C15.579 10.011 15.435 10.187 15.25 10.31C15.065 10.434 14.847 10.5 14.625 10.5C14.428 10.5 14.234 10.448 14.062 10.349C13.891 10.251 13.749 10.109 13.651 9.938C13.552 9.766 13.5 9.572 13.5 9.375',
        true,
        false
      )
    ],
    [
      (
        'M20.25 3.75L3.75 3.75C3.487 3.75 3.228 3.819 3 3.951C2.772 4.083 2.583 4.272 2.451 4.5C2.319 4.728 2.25 4.987 2.25 5.25L2.25 18.75C2.25 19.013 2.319 19.272 2.451 19.5C2.583 19.728 2.772 19.917 3 20.049C3.228 20.181 3.487 20.25 3.75 20.25L20.25 20.25C20.513 20.25 20.772 20.181 21 20.049C21.228 19.917 21.417 19.728 21.549 19.5C21.681 19.272 21.75 19.013 21.75 18.75L21.75 5.25C21.75 4.987 21.681 4.728 21.549 4.5C21.417 4.272 21.228 4.083 21 3.951C20.772 3.819 20.513 3.75 20.25 3.75M14.625 8.25C14.847 8.25 15.065 8.316 15.25 8.44C15.435 8.563 15.579 8.739 15.664 8.944C15.75 9.15 15.772 9.376 15.728 9.594C15.685 9.813 15.578 10.013 15.42 10.17C15.263 10.328 15.063 10.435 14.844 10.478C14.626 10.522 14.4 10.5 14.194 10.414C13.989 10.329 13.813 10.185 13.69 10C13.566 9.815 13.5 9.597 13.5 9.375C13.5 9.178 13.552 8.984 13.651 8.812C13.749 8.641 13.891 8.499 14.062 8.401C14.234 8.302 14.428 8.25 14.625 8.25M20.25 18.75L3.75 18.75L3.75 15.065L8.094 10.719C8.187 10.626 8.304 10.559 8.431 10.525C8.558 10.491 8.692 10.491 8.819 10.525C8.946 10.559 9.063 10.626 9.156 10.719L15.469 17.031C15.581 17.143 15.725 17.216 15.882 17.241C16.038 17.266 16.199 17.241 16.34 17.169C16.481 17.097 16.596 16.982 16.668 16.841C16.74 16.7 16.765 16.539 16.741 16.383C16.716 16.226 16.642 16.081 16.53 15.969L14.874 14.315L16.219 12.969C16.312 12.876 16.428 12.809 16.555 12.775C16.682 12.741 16.816 12.741 16.943 12.775C17.07 12.809 17.186 12.876 17.279 12.969L20.25 15.944Z',
        true,
        false
      )
    ]
  ),
  'ฟอร์ม HOSxP': (
    [
      (
        'M20.031 7.719L14.781 2.469C14.711 2.4 14.628 2.345 14.537 2.307C14.446 2.269 14.349 2.25 14.25 2.25L5.25 2.25C4.987 2.25 4.728 2.319 4.5 2.451C4.272 2.583 4.083 2.772 3.951 3C3.819 3.228 3.75 3.487 3.75 3.75L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L18.75 21.75C19.013 21.75 19.272 21.681 19.5 21.549C19.728 21.417 19.917 21.228 20.049 21C20.181 20.772 20.25 20.513 20.25 20.25L20.25 8.25C20.25 8.151 20.231 8.054 20.193 7.963C20.155 7.872 20.1 7.789 20.031 7.719M15 4.81L17.69 7.5L15 7.5ZM18.75 20.25L5.25 20.25L5.25 3.75L13.5 3.75L13.5 8.25C13.5 8.382 13.535 8.511 13.6 8.625C13.666 8.739 13.761 8.834 13.875 8.9C13.989 8.965 14.118 9 14.25 9L18.75 9ZM15.75 12.75C15.75 12.882 15.715 13.011 15.65 13.125C15.584 13.239 15.489 13.334 15.375 13.4C15.261 13.465 15.132 13.5 15 13.5L9 13.5C8.842 13.5 8.687 13.45 8.559 13.357C8.431 13.264 8.336 13.132 8.287 12.982C8.238 12.831 8.238 12.669 8.287 12.518C8.336 12.368 8.431 12.236 8.559 12.143C8.687 12.05 8.842 12 9 12L15 12C15.132 12 15.261 12.035 15.375 12.1C15.489 12.166 15.584 12.261 15.65 12.375C15.715 12.489 15.75 12.618 15.75 12.75M15.75 15.75C15.75 15.882 15.715 16.011 15.65 16.125C15.584 16.239 15.489 16.334 15.375 16.4C15.261 16.465 15.132 16.5 15 16.5L9 16.5C8.842 16.5 8.687 16.45 8.559 16.357C8.431 16.264 8.336 16.132 8.287 15.982C8.238 15.831 8.238 15.669 8.287 15.518C8.336 15.368 8.431 15.236 8.559 15.143C8.687 15.05 8.842 15 9 15L15 15C15.132 15 15.261 15.035 15.375 15.1C15.489 15.166 15.584 15.261 15.65 15.375C15.715 15.489 15.75 15.618 15.75 15.75',
        true,
        false
      )
    ],
    [
      (
        'M20.031 7.719L14.781 2.469C14.711 2.4 14.628 2.345 14.537 2.307C14.446 2.269 14.349 2.25 14.25 2.25L5.25 2.25C4.987 2.25 4.728 2.319 4.5 2.451C4.272 2.583 4.083 2.772 3.951 3C3.819 3.228 3.75 3.487 3.75 3.75L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L18.75 21.75C19.013 21.75 19.272 21.681 19.5 21.549C19.728 21.417 19.917 21.228 20.049 21C20.181 20.772 20.25 20.513 20.25 20.25L20.25 8.25C20.25 8.151 20.231 8.054 20.193 7.963C20.155 7.872 20.1 7.789 20.031 7.719M15 16.5L9 16.5C8.842 16.5 8.687 16.45 8.559 16.357C8.431 16.264 8.336 16.132 8.287 15.982C8.238 15.831 8.238 15.669 8.287 15.518C8.336 15.368 8.431 15.236 8.559 15.143C8.687 15.05 8.842 15 9 15L15 15C15.158 15 15.313 15.05 15.441 15.143C15.569 15.236 15.664 15.368 15.713 15.518C15.762 15.669 15.762 15.831 15.713 15.982C15.664 16.132 15.569 16.264 15.441 16.357C15.313 16.45 15.158 16.5 15 16.5M15 13.5L9 13.5C8.842 13.5 8.687 13.45 8.559 13.357C8.431 13.264 8.336 13.132 8.287 12.982C8.238 12.831 8.238 12.669 8.287 12.518C8.336 12.368 8.431 12.236 8.559 12.143C8.687 12.05 8.842 12 9 12L15 12C15.158 12 15.313 12.05 15.441 12.143C15.569 12.236 15.664 12.368 15.713 12.518C15.762 12.669 15.762 12.831 15.713 12.982C15.664 13.132 15.569 13.264 15.441 13.357C15.313 13.45 15.158 13.5 15 13.5M14.25 8.25L14.25 4.125L18.375 8.25Z',
        true,
        false
      )
    ]
  ),
  'EMR': (
    [
      (
        'M20.12 18.621C20.54 18.201 20.826 17.667 20.942 17.085C21.058 16.503 20.998 15.899 20.771 15.351C20.545 14.803 20.16 14.334 19.667 14.004C19.173 13.674 18.593 13.498 18 13.498C17.406 13.498 16.826 13.674 16.332 14.004C15.839 14.334 15.455 14.803 15.228 15.351C15.001 15.899 14.941 16.503 15.057 17.085C15.173 17.667 15.46 18.201 15.879 18.621C15.488 18.87 15.147 19.19 14.873 19.564C14.599 19.938 14.396 20.359 14.275 20.807C14.241 20.934 14.242 21.068 14.276 21.195C14.31 21.322 14.377 21.438 14.47 21.531C14.564 21.624 14.68 21.691 14.807 21.725C14.87 21.741 14.935 21.75 15 21.75C15.11 21.75 15.218 21.726 15.317 21.679C15.417 21.633 15.505 21.565 15.575 21.481C15.646 21.397 15.697 21.298 15.725 21.192C15.99 20.196 16.926 19.5 18 19.5C19.074 19.5 20.01 20.196 20.275 21.192C20.307 21.322 20.373 21.44 20.466 21.536C20.558 21.632 20.675 21.701 20.804 21.736C20.932 21.772 21.068 21.773 21.196 21.738C21.325 21.704 21.443 21.636 21.536 21.542C21.63 21.447 21.697 21.329 21.73 21.2C21.763 21.071 21.761 20.935 21.725 20.807C21.604 20.359 21.401 19.937 21.127 19.564C20.852 19.19 20.511 18.87 20.12 18.621M18 15C18.297 15 18.587 15.088 18.833 15.253C19.08 15.418 19.272 15.652 19.386 15.926C19.499 16.2 19.529 16.502 19.471 16.793C19.413 17.084 19.27 17.351 19.061 17.561C18.851 17.77 18.584 17.913 18.293 17.971C18.002 18.029 17.7 17.999 17.426 17.886C17.152 17.772 16.918 17.58 16.753 17.333C16.588 17.087 16.5 16.797 16.5 16.5C16.5 16.237 16.569 15.978 16.701 15.75C16.833 15.522 17.022 15.333 17.25 15.201C17.478 15.069 17.737 15 18 15M20.25 6.75L12.31 6.75L9.75 4.19C9.611 4.05 9.446 3.939 9.264 3.863C9.082 3.788 8.887 3.749 8.69 3.75L3.75 3.75C3.487 3.75 3.228 3.819 3 3.951C2.772 4.083 2.583 4.272 2.451 4.5C2.319 4.728 2.25 4.987 2.25 5.25L2.25 18.807C2.25 19.06 2.317 19.309 2.443 19.528C2.57 19.747 2.752 19.929 2.971 20.056C3.19 20.183 3.439 20.25 3.692 20.25L11.303 20.25C11.461 20.25 11.615 20.2 11.743 20.107C11.871 20.014 11.967 19.882 12.016 19.732C12.065 19.581 12.065 19.419 12.016 19.268C11.967 19.118 11.871 18.986 11.743 18.893C11.615 18.8 11.461 18.75 11.303 18.75L3.75 18.75L3.75 8.25L20.25 8.25L20.25 11.25C20.25 11.408 20.3 11.563 20.393 11.691C20.486 11.819 20.618 11.914 20.768 11.963C20.919 12.012 21.081 12.012 21.232 11.963C21.382 11.914 21.514 11.819 21.607 11.691C21.7 11.563 21.75 11.408 21.75 11.25L21.75 8.25C21.75 7.987 21.681 7.728 21.549 7.5C21.417 7.272 21.228 7.083 21 6.951C20.772 6.819 20.513 6.75 20.25 6.75M8.69 5.25L10.19 6.75L3.75 6.75L3.75 5.25Z',
        true,
        false
      )
    ],
    [
      (
        'M21.725 20.807C21.764 20.955 21.757 21.113 21.705 21.257C21.652 21.402 21.556 21.526 21.43 21.615C21.304 21.703 21.154 21.75 21 21.75L15 21.75C14.847 21.75 14.698 21.703 14.572 21.615C14.447 21.528 14.351 21.404 14.298 21.26C14.245 21.117 14.237 20.961 14.275 20.812C14.396 20.365 14.598 19.943 14.873 19.569C15.147 19.195 15.488 18.875 15.879 18.625C15.46 18.206 15.174 17.671 15.058 17.089C14.942 16.507 15.001 15.904 15.228 15.356C15.455 14.807 15.84 14.339 16.333 14.009C16.826 13.679 17.407 13.503 18 13.503C18.593 13.503 19.174 13.679 19.667 14.009C20.16 14.339 20.545 14.807 20.772 15.356C20.999 15.904 21.058 16.507 20.942 17.089C20.826 17.671 20.54 18.206 20.121 18.625C20.511 18.874 20.852 19.193 21.126 19.566C21.401 19.939 21.604 20.36 21.725 20.807M21.75 8.25L21.75 11.25C21.75 11.408 21.7 11.563 21.607 11.691C21.514 11.819 21.382 11.914 21.232 11.963C21.081 12.012 20.919 12.012 20.768 11.963C20.618 11.914 20.486 11.819 20.393 11.691C20.3 11.563 20.25 11.408 20.25 11.25L20.25 8.25L3.75 8.25L3.75 18.75L11.303 18.75C11.461 18.75 11.615 18.8 11.743 18.893C11.871 18.986 11.967 19.118 12.016 19.268C12.065 19.419 12.065 19.581 12.016 19.732C11.967 19.882 11.871 20.014 11.743 20.107C11.615 20.2 11.461 20.25 11.303 20.25L3.692 20.25C3.439 20.25 3.19 20.183 2.971 20.056C2.752 19.93 2.57 19.748 2.444 19.529C2.317 19.31 2.25 19.061 2.25 18.808L2.25 5.25C2.25 4.987 2.319 4.728 2.451 4.5C2.583 4.272 2.772 4.083 3 3.951C3.228 3.819 3.487 3.75 3.75 3.75L8.69 3.75C8.887 3.749 9.082 3.788 9.264 3.863C9.446 3.939 9.611 4.05 9.75 4.19L12.31 6.75L20.25 6.75C20.513 6.75 20.772 6.819 21 6.951C21.228 7.083 21.417 7.272 21.549 7.5C21.681 7.728 21.75 7.987 21.75 8.25M10.19 6.75L8.69 5.25L3.75 5.25L3.75 6.75Z',
        true,
        false
      )
    ]
  ),
  'Progress note': (
    [
      (
        'M8.25 9C8.25 8.868 8.285 8.739 8.35 8.625C8.416 8.511 8.511 8.416 8.625 8.35C8.739 8.285 8.868 8.25 9 8.25L15 8.25C15.158 8.25 15.313 8.3 15.441 8.393C15.569 8.486 15.664 8.618 15.713 8.768C15.762 8.919 15.762 9.081 15.713 9.232C15.664 9.382 15.569 9.514 15.441 9.607C15.313 9.7 15.158 9.75 15 9.75L9 9.75C8.868 9.75 8.739 9.715 8.625 9.65C8.511 9.584 8.416 9.489 8.35 9.375C8.285 9.261 8.25 9.132 8.25 9M9 12.75L15 12.75C15.158 12.75 15.313 12.7 15.441 12.607C15.569 12.514 15.664 12.382 15.713 12.232C15.762 12.081 15.762 11.919 15.713 11.768C15.664 11.618 15.569 11.486 15.441 11.393C15.313 11.3 15.158 11.25 15 11.25L9 11.25C8.842 11.25 8.687 11.3 8.559 11.393C8.431 11.486 8.336 11.618 8.287 11.768C8.238 11.919 8.238 12.081 8.287 12.232C8.336 12.382 8.431 12.514 8.559 12.607C8.687 12.7 8.842 12.75 9 12.75M12 14.25L9 14.25C8.842 14.25 8.687 14.3 8.559 14.393C8.431 14.486 8.336 14.618 8.287 14.768C8.238 14.919 8.238 15.081 8.287 15.232C8.336 15.382 8.431 15.514 8.559 15.607C8.687 15.7 8.842 15.75 9 15.75L12 15.75C12.158 15.75 12.313 15.7 12.441 15.607C12.569 15.514 12.664 15.382 12.713 15.232C12.762 15.081 12.762 14.919 12.713 14.768C12.664 14.618 12.569 14.486 12.441 14.393C12.313 14.3 12.158 14.25 12 14.25M21 4.5L21 14.69C21.001 14.887 20.962 15.082 20.887 15.264C20.811 15.446 20.7 15.611 20.56 15.75L15.75 20.56C15.611 20.7 15.446 20.811 15.264 20.887C15.082 20.962 14.887 21.001 14.69 21L4.5 21C4.237 21 3.978 20.931 3.75 20.799C3.522 20.667 3.333 20.478 3.201 20.25C3.069 20.022 3 19.763 3 19.5L3 4.5C3 4.237 3.069 3.978 3.201 3.75C3.333 3.522 3.522 3.333 3.75 3.201C3.978 3.069 4.237 3 4.5 3L19.5 3C19.763 3 20.022 3.069 20.25 3.201C20.478 3.333 20.667 3.522 20.799 3.75C20.931 3.978 21 4.237 21 4.5M4.5 19.5L14.25 19.5L14.25 15C14.25 14.868 14.285 14.739 14.35 14.625C14.416 14.511 14.511 14.416 14.625 14.35C14.739 14.285 14.868 14.25 15 14.25L19.5 14.25L19.5 4.5L4.5 4.5ZM15.75 15.75L15.75 18.441L18.44 15.75Z',
        true,
        false
      )
    ],
    [
      (
        'M19.5 3L4.5 3C4.237 3 3.978 3.069 3.75 3.201C3.522 3.333 3.333 3.522 3.201 3.75C3.069 3.978 3 4.237 3 4.5L3 19.5C3 19.763 3.069 20.022 3.201 20.25C3.333 20.478 3.522 20.667 3.75 20.799C3.978 20.931 4.237 21 4.5 21L14.69 21C14.887 21 15.082 20.962 15.264 20.886C15.446 20.811 15.611 20.7 15.75 20.56L20.56 15.75C20.7 15.611 20.811 15.446 20.886 15.264C20.962 15.082 21 14.887 21 14.69L21 4.5C21 4.237 20.931 3.978 20.799 3.75C20.667 3.522 20.478 3.333 20.25 3.201C20.022 3.069 19.763 3 19.5 3M9 8.25L15 8.25C15.158 8.25 15.313 8.3 15.441 8.393C15.569 8.486 15.664 8.618 15.713 8.768C15.762 8.919 15.762 9.081 15.713 9.232C15.664 9.382 15.569 9.514 15.441 9.607C15.313 9.7 15.158 9.75 15 9.75L9 9.75C8.842 9.75 8.687 9.7 8.559 9.607C8.431 9.514 8.336 9.382 8.287 9.232C8.238 9.081 8.238 8.919 8.287 8.768C8.336 8.618 8.431 8.486 8.559 8.393C8.687 8.3 8.842 8.25 9 8.25M12 15.75L9 15.75C8.842 15.75 8.687 15.7 8.559 15.607C8.431 15.514 8.336 15.382 8.287 15.232C8.238 15.081 8.238 14.919 8.287 14.768C8.336 14.618 8.431 14.486 8.559 14.393C8.687 14.3 8.842 14.25 9 14.25L12 14.25C12.158 14.25 12.313 14.3 12.441 14.393C12.569 14.486 12.664 14.618 12.713 14.768C12.762 14.919 12.762 15.081 12.713 15.232C12.664 15.382 12.569 15.514 12.441 15.607C12.313 15.7 12.158 15.75 12 15.75M9 12.75C8.842 12.75 8.687 12.7 8.559 12.607C8.431 12.514 8.336 12.382 8.287 12.232C8.238 12.081 8.238 11.919 8.287 11.768C8.336 11.618 8.431 11.486 8.559 11.393C8.687 11.3 8.842 11.25 9 11.25L15 11.25C15.158 11.25 15.313 11.3 15.441 11.393C15.569 11.486 15.664 11.618 15.713 11.768C15.762 11.919 15.762 12.081 15.713 12.232C15.664 12.382 15.569 12.514 15.441 12.607C15.313 12.7 15.158 12.75 15 12.75ZM15 19.19L15 15L19.191 15Z',
        true,
        false
      )
    ]
  ),
  'นัดหมาย': (
    [
      (
        'M19.5 3L17.25 3L17.25 2.25C17.25 2.092 17.2 1.937 17.107 1.809C17.014 1.681 16.882 1.586 16.732 1.537C16.581 1.488 16.419 1.488 16.268 1.537C16.118 1.586 15.986 1.681 15.893 1.809C15.8 1.937 15.75 2.092 15.75 2.25L15.75 3L8.25 3L8.25 2.25C8.25 2.092 8.2 1.937 8.107 1.809C8.014 1.681 7.882 1.586 7.732 1.537C7.581 1.488 7.419 1.488 7.268 1.537C7.118 1.586 6.986 1.681 6.893 1.809C6.8 1.937 6.75 2.092 6.75 2.25L6.75 3L4.5 3C4.237 3 3.978 3.069 3.75 3.201C3.522 3.333 3.333 3.522 3.201 3.75C3.069 3.978 3 4.237 3 4.5L3 19.5C3 19.763 3.069 20.022 3.201 20.25C3.333 20.478 3.522 20.667 3.75 20.799C3.978 20.931 4.237 21 4.5 21L19.5 21C19.763 21 20.022 20.931 20.25 20.799C20.478 20.667 20.667 20.478 20.799 20.25C20.931 20.022 21 19.763 21 19.5L21 4.5C21 4.237 20.931 3.978 20.799 3.75C20.667 3.522 20.478 3.333 20.25 3.201C20.022 3.069 19.763 3 19.5 3M6.75 4.5L6.75 5.25C6.75 5.408 6.8 5.563 6.893 5.691C6.986 5.819 7.118 5.914 7.268 5.963C7.419 6.012 7.581 6.012 7.732 5.963C7.882 5.914 8.014 5.819 8.107 5.691C8.2 5.563 8.25 5.408 8.25 5.25L8.25 4.5L15.75 4.5L15.75 5.25C15.75 5.408 15.8 5.563 15.893 5.691C15.986 5.819 16.118 5.914 16.268 5.963C16.419 6.012 16.581 6.012 16.732 5.963C16.882 5.914 17.014 5.819 17.107 5.691C17.2 5.563 17.25 5.408 17.25 5.25L17.25 4.5L19.5 4.5L19.5 7.5L4.5 7.5L4.5 4.5ZM19.5 19.5L4.5 19.5L4.5 9L19.5 9ZM13.125 12.375C13.125 12.597 13.059 12.815 12.935 13C12.812 13.185 12.636 13.329 12.431 13.414C12.225 13.5 11.999 13.522 11.781 13.478C11.562 13.435 11.362 13.328 11.205 13.17C11.047 13.013 10.94 12.813 10.897 12.594C10.853 12.376 10.875 12.15 10.961 11.944C11.046 11.739 11.19 11.563 11.375 11.44C11.56 11.316 11.778 11.25 12 11.25C12.197 11.25 12.391 11.302 12.562 11.401C12.734 11.499 12.876 11.641 12.974 11.812C13.073 11.984 13.125 12.178 13.125 12.375M17.25 12.375C17.25 12.597 17.184 12.815 17.06 13C16.937 13.185 16.761 13.329 16.556 13.414C16.35 13.5 16.124 13.522 15.906 13.478C15.687 13.435 15.487 13.328 15.33 13.17C15.172 13.013 15.065 12.813 15.022 12.594C14.978 12.376 15 12.15 15.086 11.944C15.171 11.739 15.315 11.563 15.5 11.44C15.685 11.316 15.903 11.25 16.125 11.25C16.322 11.25 16.516 11.302 16.688 11.401C16.859 11.499 17.001 11.641 17.099 11.812C17.198 11.984 17.25 12.178 17.25 12.375M9 16.125C9 16.347 8.934 16.565 8.81 16.75C8.687 16.935 8.511 17.079 8.306 17.164C8.1 17.25 7.874 17.272 7.656 17.228C7.437 17.185 7.237 17.078 7.08 16.92C6.922 16.763 6.815 16.563 6.772 16.344C6.728 16.126 6.75 15.9 6.836 15.694C6.921 15.489 7.065 15.313 7.25 15.19C7.435 15.066 7.653 15 7.875 15C8.072 15 8.266 15.052 8.438 15.151C8.609 15.249 8.751 15.391 8.849 15.562C8.948 15.734 9 15.928 9 16.125M13.125 16.125C13.125 16.347 13.059 16.565 12.935 16.75C12.812 16.935 12.636 17.079 12.431 17.164C12.225 17.25 11.999 17.272 11.781 17.228C11.562 17.185 11.362 17.078 11.205 16.92C11.047 16.763 10.94 16.563 10.897 16.344C10.853 16.126 10.875 15.9 10.961 15.694C11.046 15.489 11.19 15.313 11.375 15.19C11.56 15.066 11.778 15 12 15C12.197 15 12.391 15.052 12.562 15.151C12.734 15.249 12.876 15.391 12.974 15.562C13.073 15.734 13.125 15.928 13.125 16.125M17.25 16.125C17.25 16.347 17.184 16.565 17.06 16.75C16.937 16.935 16.761 17.079 16.556 17.164C16.35 17.25 16.124 17.272 15.906 17.228C15.687 17.185 15.487 17.078 15.33 16.92C15.172 16.763 15.065 16.563 15.022 16.344C14.978 16.126 15 15.9 15.086 15.694C15.171 15.489 15.315 15.313 15.5 15.19C15.685 15.066 15.903 15 16.125 15C16.322 15 16.516 15.052 16.688 15.151C16.859 15.249 17.001 15.391 17.099 15.562C17.198 15.734 17.25 15.928 17.25 16.125',
        true,
        false
      )
    ],
    [
      (
        'M19.5 3L17.25 3L17.25 2.25C17.25 2.092 17.2 1.937 17.107 1.809C17.014 1.681 16.882 1.586 16.732 1.537C16.581 1.488 16.419 1.488 16.268 1.537C16.118 1.586 15.986 1.681 15.893 1.809C15.8 1.937 15.75 2.092 15.75 2.25L15.75 3L8.25 3L8.25 2.25C8.25 2.092 8.2 1.937 8.107 1.809C8.014 1.681 7.882 1.586 7.732 1.537C7.581 1.488 7.419 1.488 7.268 1.537C7.118 1.586 6.986 1.681 6.893 1.809C6.8 1.937 6.75 2.092 6.75 2.25L6.75 3L4.5 3C4.237 3 3.978 3.069 3.75 3.201C3.522 3.333 3.333 3.522 3.201 3.75C3.069 3.978 3 4.237 3 4.5L3 19.5C3 19.763 3.069 20.022 3.201 20.25C3.333 20.478 3.522 20.667 3.75 20.799C3.978 20.931 4.237 21 4.5 21L19.5 21C19.763 21 20.022 20.931 20.25 20.799C20.478 20.667 20.667 20.478 20.799 20.25C20.931 20.022 21 19.763 21 19.5L21 4.5C21 4.237 20.931 3.978 20.799 3.75C20.667 3.522 20.478 3.333 20.25 3.201C20.022 3.069 19.763 3 19.5 3M7.875 17.25C7.653 17.25 7.435 17.184 7.25 17.06C7.065 16.937 6.921 16.761 6.836 16.556C6.75 16.35 6.728 16.124 6.772 15.906C6.815 15.687 6.922 15.487 7.08 15.33C7.237 15.172 7.437 15.065 7.656 15.022C7.874 14.978 8.1 15 8.306 15.086C8.511 15.171 8.687 15.315 8.81 15.5C8.934 15.685 9 15.903 9 16.125C9 16.322 8.948 16.516 8.849 16.688C8.751 16.859 8.609 17.001 8.438 17.099C8.266 17.198 8.072 17.25 7.875 17.25M12 17.25C11.778 17.25 11.56 17.184 11.375 17.06C11.19 16.937 11.046 16.761 10.961 16.556C10.875 16.35 10.853 16.124 10.897 15.906C10.94 15.687 11.047 15.487 11.205 15.33C11.362 15.172 11.562 15.065 11.781 15.022C11.999 14.978 12.225 15 12.431 15.086C12.636 15.171 12.812 15.315 12.935 15.5C13.059 15.685 13.125 15.903 13.125 16.125C13.125 16.322 13.073 16.516 12.974 16.688C12.876 16.859 12.734 17.001 12.562 17.099C12.391 17.198 12.197 17.25 12 17.25M12 13.5C11.778 13.5 11.56 13.434 11.375 13.31C11.19 13.187 11.046 13.011 10.961 12.806C10.875 12.6 10.853 12.374 10.897 12.156C10.94 11.937 11.047 11.737 11.205 11.58C11.362 11.422 11.562 11.315 11.781 11.272C11.999 11.228 12.225 11.25 12.431 11.336C12.636 11.421 12.812 11.565 12.935 11.75C13.059 11.935 13.125 12.153 13.125 12.375C13.125 12.572 13.073 12.766 12.974 12.938C12.876 13.109 12.734 13.251 12.562 13.349C12.391 13.448 12.197 13.5 12 13.5M16.125 17.25C15.903 17.25 15.685 17.184 15.5 17.06C15.315 16.937 15.171 16.761 15.086 16.556C15 16.35 14.978 16.124 15.022 15.906C15.065 15.687 15.172 15.487 15.33 15.33C15.487 15.172 15.687 15.065 15.906 15.022C16.124 14.978 16.35 15 16.556 15.086C16.761 15.171 16.937 15.315 17.06 15.5C17.184 15.685 17.25 15.903 17.25 16.125C17.25 16.322 17.198 16.516 17.099 16.688C17.001 16.859 16.859 17.001 16.688 17.099C16.516 17.198 16.322 17.25 16.125 17.25M16.125 13.5C15.903 13.5 15.685 13.434 15.5 13.31C15.315 13.187 15.171 13.011 15.086 12.806C15 12.6 14.978 12.374 15.022 12.156C15.065 11.937 15.172 11.737 15.33 11.58C15.487 11.422 15.687 11.315 15.906 11.272C16.124 11.228 16.35 11.25 16.556 11.336C16.761 11.421 16.937 11.565 17.06 11.75C17.184 11.935 17.25 12.153 17.25 12.375C17.25 12.572 17.198 12.766 17.099 12.938C17.001 13.109 16.859 13.251 16.688 13.349C16.516 13.448 16.322 13.5 16.125 13.5M19.5 7.5L4.5 7.5L4.5 4.5L6.75 4.5L6.75 5.25C6.75 5.408 6.8 5.563 6.893 5.691C6.986 5.819 7.118 5.914 7.268 5.963C7.419 6.012 7.581 6.012 7.732 5.963C7.882 5.914 8.014 5.819 8.107 5.691C8.2 5.563 8.25 5.408 8.25 5.25L8.25 4.5L15.75 4.5L15.75 5.25C15.75 5.408 15.8 5.563 15.893 5.691C15.986 5.819 16.118 5.914 16.268 5.963C16.419 6.012 16.581 6.012 16.732 5.963C16.882 5.914 17.014 5.819 17.107 5.691C17.2 5.563 17.25 5.408 17.25 5.25L17.25 4.5L19.5 4.5Z',
        true,
        false
      )
    ]
  ),
  'ใบรับรองแพทย์': (
    [
      (
        'M12 12.75C12 12.882 11.965 13.011 11.9 13.125C11.834 13.239 11.739 13.334 11.625 13.4C11.511 13.465 11.382 13.5 11.25 13.5L6.75 13.5C6.592 13.5 6.437 13.45 6.309 13.357C6.181 13.264 6.086 13.132 6.037 12.982C5.988 12.831 5.988 12.669 6.037 12.518C6.086 12.368 6.181 12.236 6.309 12.143C6.437 12.05 6.592 12 6.75 12L11.25 12C11.382 12 11.511 12.035 11.625 12.1C11.739 12.166 11.834 12.261 11.9 12.375C11.965 12.489 12 12.618 12 12.75M11.25 9L6.75 9C6.592 9 6.437 9.05 6.309 9.143C6.181 9.236 6.086 9.368 6.037 9.518C5.988 9.669 5.988 9.831 6.037 9.982C6.086 10.132 6.181 10.264 6.309 10.357C6.437 10.45 6.592 10.5 6.75 10.5L11.25 10.5C11.408 10.5 11.563 10.45 11.691 10.357C11.819 10.264 11.914 10.132 11.963 9.982C12.012 9.831 12.012 9.669 11.963 9.518C11.914 9.368 11.819 9.236 11.691 9.143C11.563 9.05 11.408 9 11.25 9M21.75 15.138L21.75 21C21.751 21.132 21.717 21.262 21.652 21.377C21.587 21.492 21.492 21.588 21.378 21.655C21.264 21.721 21.134 21.756 21.002 21.757C20.869 21.757 20.74 21.722 20.625 21.656L18.375 20.368L16.125 21.656C16.01 21.722 15.881 21.757 15.748 21.757C15.616 21.756 15.486 21.721 15.372 21.655C15.258 21.588 15.163 21.492 15.098 21.377C15.033 21.262 14.999 21.132 15 21L15 18.75L3.75 18.75C3.487 18.75 3.228 18.681 3 18.549C2.772 18.417 2.583 18.228 2.451 18C2.319 17.772 2.25 17.513 2.25 17.25L2.25 5.25C2.25 4.987 2.319 4.728 2.451 4.5C2.583 4.272 2.772 4.083 3 3.951C3.228 3.819 3.487 3.75 3.75 3.75L20.25 3.75C20.513 3.75 20.772 3.819 21 3.951C21.228 4.083 21.417 4.272 21.549 4.5C21.681 4.728 21.75 4.987 21.75 5.25L21.75 8.112C22.384 8.719 22.842 9.486 23.075 10.332C23.308 11.178 23.308 12.072 23.075 12.918C22.842 13.764 22.384 14.531 21.75 15.138M15 17.25L15 15.138C14.349 14.51 13.885 13.712 13.661 12.835C13.437 11.959 13.461 11.036 13.732 10.173C14.002 9.309 14.508 8.537 15.191 7.945C15.875 7.352 16.711 6.961 17.604 6.817C18.498 6.672 19.414 6.779 20.25 7.125L20.25 5.25L3.75 5.25L3.75 17.25ZM20.25 16.125C19.656 16.373 19.019 16.501 18.375 16.501C17.731 16.501 17.094 16.373 16.5 16.125L16.5 19.708L18 18.849C18.113 18.785 18.242 18.751 18.372 18.751C18.503 18.751 18.631 18.785 18.744 18.849L20.244 19.708ZM21.75 11.625C21.75 10.958 21.552 10.305 21.181 9.75C20.81 9.195 20.283 8.762 19.667 8.507C19.05 8.251 18.371 8.185 17.717 8.315C17.062 8.445 16.46 8.767 15.989 9.239C15.517 9.71 15.195 10.312 15.065 10.967C14.935 11.621 15.001 12.3 15.257 12.917C15.512 13.533 15.945 14.06 16.5 14.431C17.055 14.802 17.708 15 18.375 15C18.967 15 19.549 14.844 20.062 14.548C20.576 14.252 21.002 13.826 21.298 13.312C21.594 12.799 21.75 12.217 21.75 11.625',
        true,
        false
      )
    ],
    [
      (
        'M21.75 8.112L21.75 5.25C21.75 4.987 21.681 4.728 21.549 4.5C21.417 4.272 21.228 4.083 21 3.951C20.772 3.819 20.513 3.75 20.25 3.75L3.75 3.75C3.487 3.75 3.228 3.819 3 3.951C2.772 4.083 2.583 4.272 2.451 4.5C2.319 4.728 2.25 4.987 2.25 5.25L2.25 17.25C2.25 17.513 2.319 17.772 2.451 18C2.583 18.228 2.772 18.417 3 18.549C3.228 18.681 3.487 18.75 3.75 18.75L15 18.75L15 21C14.999 21.132 15.033 21.262 15.098 21.377C15.163 21.492 15.258 21.588 15.372 21.655C15.486 21.721 15.616 21.756 15.748 21.757C15.881 21.757 16.01 21.722 16.125 21.656L18.375 20.368L20.625 21.656C20.74 21.722 20.869 21.757 21.002 21.757C21.134 21.756 21.264 21.721 21.378 21.655C21.492 21.588 21.587 21.492 21.652 21.377C21.717 21.262 21.751 21.132 21.75 21L21.75 15.138C22.384 14.531 22.842 13.764 23.075 12.918C23.308 12.072 23.308 11.178 23.075 10.332C22.842 9.486 22.384 8.719 21.75 8.112M12 13.5L6.75 13.5C6.592 13.5 6.437 13.45 6.309 13.357C6.181 13.264 6.086 13.132 6.037 12.982C5.988 12.831 5.988 12.669 6.037 12.518C6.086 12.368 6.181 12.236 6.309 12.143C6.437 12.05 6.592 12 6.75 12L12 12C12.158 12 12.313 12.05 12.441 12.143C12.569 12.236 12.664 12.368 12.713 12.518C12.762 12.669 12.762 12.831 12.713 12.982C12.664 13.132 12.569 13.264 12.441 13.357C12.313 13.45 12.158 13.5 12 13.5M12 10.5L6.75 10.5C6.592 10.5 6.437 10.45 6.309 10.357C6.181 10.264 6.086 10.132 6.037 9.982C5.988 9.831 5.988 9.669 6.037 9.518C6.086 9.368 6.181 9.236 6.309 9.143C6.437 9.05 6.592 9 6.75 9L12 9C12.158 9 12.313 9.05 12.441 9.143C12.569 9.236 12.664 9.368 12.713 9.518C12.762 9.669 12.762 9.831 12.713 9.982C12.664 10.132 12.569 10.264 12.441 10.357C12.313 10.45 12.158 10.5 12 10.5M20.25 19.707L18.75 18.848C18.637 18.784 18.508 18.75 18.378 18.75C18.247 18.75 18.119 18.784 18.006 18.848L16.506 19.707L16.506 16.125C17.1 16.373 17.737 16.501 18.381 16.501C19.024 16.501 19.662 16.373 20.256 16.125ZM18.375 15C17.708 15 17.055 14.802 16.5 14.431C15.945 14.06 15.512 13.533 15.257 12.917C15.001 12.3 14.935 11.621 15.065 10.967C15.195 10.312 15.517 9.71 15.989 9.239C16.46 8.767 17.062 8.445 17.717 8.315C18.371 8.185 19.05 8.251 19.667 8.507C20.283 8.762 20.81 9.195 21.181 9.75C21.552 10.305 21.75 10.958 21.75 11.625C21.75 12.217 21.594 12.799 21.298 13.312C21.002 13.826 20.576 14.252 20.062 14.548C19.549 14.844 18.967 15 18.375 15',
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
  'X-ray': (
    [
      (
        'M21 3.75L21 7.5C21 7.658 20.95 7.813 20.857 7.941C20.764 8.069 20.632 8.164 20.482 8.213C20.331 8.262 20.169 8.262 20.018 8.213C19.868 8.164 19.736 8.069 19.643 7.941C19.55 7.813 19.5 7.658 19.5 7.5L19.5 4.5L16.5 4.5C16.342 4.5 16.187 4.45 16.059 4.357C15.931 4.264 15.836 4.132 15.787 3.982C15.738 3.831 15.738 3.669 15.787 3.518C15.836 3.368 15.931 3.236 16.059 3.143C16.187 3.05 16.342 3 16.5 3L20.25 3C20.382 3 20.511 3.035 20.625 3.1C20.739 3.166 20.834 3.261 20.9 3.375C20.965 3.489 21 3.618 21 3.75M7.5 19.5L4.5 19.5L4.5 16.5C4.5 16.342 4.45 16.187 4.357 16.059C4.264 15.931 4.132 15.836 3.982 15.787C3.831 15.738 3.669 15.738 3.518 15.787C3.368 15.836 3.236 15.931 3.143 16.059C3.05 16.187 3 16.342 3 16.5L3 20.25C3 20.382 3.035 20.511 3.1 20.625C3.166 20.739 3.261 20.834 3.375 20.9C3.489 20.965 3.618 21 3.75 21L7.5 21C7.658 21 7.813 20.95 7.941 20.857C8.069 20.764 8.164 20.632 8.213 20.482C8.262 20.331 8.262 20.169 8.213 20.018C8.164 19.868 8.069 19.736 7.941 19.643C7.813 19.55 7.658 19.5 7.5 19.5M20.25 15.75C20.118 15.75 19.989 15.785 19.875 15.85C19.761 15.916 19.666 16.011 19.6 16.125C19.535 16.239 19.5 16.368 19.5 16.5L19.5 19.5L16.5 19.5C16.342 19.5 16.187 19.55 16.059 19.643C15.931 19.736 15.836 19.868 15.787 20.018C15.738 20.169 15.738 20.331 15.787 20.482C15.836 20.632 15.931 20.764 16.059 20.857C16.187 20.95 16.342 21 16.5 21L20.25 21C20.382 21 20.511 20.965 20.625 20.9C20.739 20.834 20.834 20.739 20.9 20.625C20.965 20.511 21 20.382 21 20.25L21 16.5C21 16.368 20.965 16.239 20.9 16.125C20.834 16.011 20.739 15.916 20.625 15.85C20.511 15.785 20.382 15.75 20.25 15.75M3.75 8.25C3.882 8.25 4.011 8.215 4.125 8.15C4.239 8.084 4.334 7.989 4.4 7.875C4.465 7.761 4.5 7.632 4.5 7.5L4.5 4.5L7.5 4.5C7.658 4.5 7.813 4.45 7.941 4.357C8.069 4.264 8.164 4.132 8.213 3.982C8.262 3.831 8.262 3.669 8.213 3.518C8.164 3.368 8.069 3.236 7.941 3.143C7.813 3.05 7.658 3 7.5 3L3.75 3C3.618 3 3.489 3.035 3.375 3.1C3.261 3.166 3.166 3.261 3.1 3.375C3.035 3.489 3 3.618 3 3.75L3 7.5C3 7.632 3.035 7.761 3.1 7.875C3.166 7.989 3.261 8.084 3.375 8.15C3.489 8.215 3.618 8.25 3.75 8.25M7.5 6.75L16.5 6.75C16.632 6.75 16.761 6.785 16.875 6.85C16.989 6.916 17.084 7.011 17.15 7.125C17.215 7.239 17.25 7.368 17.25 7.5L17.25 16.5C17.25 16.632 17.215 16.761 17.15 16.875C17.084 16.989 16.989 17.084 16.875 17.15C16.761 17.215 16.632 17.25 16.5 17.25L7.5 17.25C7.368 17.25 7.239 17.215 7.125 17.15C7.011 17.084 6.916 16.989 6.85 16.875C6.785 16.761 6.75 16.632 6.75 16.5L6.75 7.5C6.75 7.368 6.785 7.239 6.85 7.125C6.916 7.011 7.011 6.916 7.125 6.85C7.239 6.785 7.368 6.75 7.5 6.75M8.25 15.75L15.75 15.75L15.75 8.25L8.25 8.25Z',
        true,
        false
      )
    ],
    [
      (
        'M21 3.75L21 7.5C21 7.658 20.95 7.813 20.857 7.941C20.764 8.069 20.632 8.164 20.482 8.213C20.331 8.262 20.169 8.262 20.018 8.213C19.868 8.164 19.736 8.069 19.643 7.941C19.55 7.813 19.5 7.658 19.5 7.5L19.5 4.5L16.5 4.5C16.342 4.5 16.187 4.45 16.059 4.357C15.931 4.264 15.836 4.132 15.787 3.982C15.738 3.831 15.738 3.669 15.787 3.518C15.836 3.368 15.931 3.236 16.059 3.143C16.187 3.05 16.342 3 16.5 3L20.25 3C20.382 3 20.511 3.035 20.625 3.1C20.739 3.166 20.834 3.261 20.9 3.375C20.965 3.489 21 3.618 21 3.75M7.5 19.5L4.5 19.5L4.5 16.5C4.5 16.342 4.45 16.187 4.357 16.059C4.264 15.931 4.132 15.836 3.982 15.787C3.831 15.738 3.669 15.738 3.518 15.787C3.368 15.836 3.236 15.931 3.143 16.059C3.05 16.187 3 16.342 3 16.5L3 20.25C3 20.382 3.035 20.511 3.1 20.625C3.166 20.739 3.261 20.834 3.375 20.9C3.489 20.965 3.618 21 3.75 21L7.5 21C7.658 21 7.813 20.95 7.941 20.857C8.069 20.764 8.164 20.632 8.213 20.482C8.262 20.331 8.262 20.169 8.213 20.018C8.164 19.868 8.069 19.736 7.941 19.643C7.813 19.55 7.658 19.5 7.5 19.5M20.25 15.75C20.118 15.75 19.989 15.785 19.875 15.85C19.761 15.916 19.666 16.011 19.6 16.125C19.535 16.239 19.5 16.368 19.5 16.5L19.5 19.5L16.5 19.5C16.342 19.5 16.187 19.55 16.059 19.643C15.931 19.736 15.836 19.868 15.787 20.018C15.738 20.169 15.738 20.331 15.787 20.482C15.836 20.632 15.931 20.764 16.059 20.857C16.187 20.95 16.342 21 16.5 21L20.25 21C20.382 21 20.511 20.965 20.625 20.9C20.739 20.834 20.834 20.739 20.9 20.625C20.965 20.511 21 20.382 21 20.25L21 16.5C21 16.368 20.965 16.239 20.9 16.125C20.834 16.011 20.739 15.916 20.625 15.85C20.511 15.785 20.382 15.75 20.25 15.75M3.75 8.25C3.882 8.25 4.011 8.215 4.125 8.15C4.239 8.084 4.334 7.989 4.4 7.875C4.465 7.761 4.5 7.632 4.5 7.5L4.5 4.5L7.5 4.5C7.658 4.5 7.813 4.45 7.941 4.357C8.069 4.264 8.164 4.132 8.213 3.982C8.262 3.831 8.262 3.669 8.213 3.518C8.164 3.368 8.069 3.236 7.941 3.143C7.813 3.05 7.658 3 7.5 3L3.75 3C3.618 3 3.489 3.035 3.375 3.1C3.261 3.166 3.166 3.261 3.1 3.375C3.035 3.489 3 3.618 3 3.75L3 7.5C3 7.632 3.035 7.761 3.1 7.875C3.166 7.989 3.261 8.084 3.375 8.15C3.489 8.215 3.618 8.25 3.75 8.25M6.75 7.5L6.75 16.5C6.75 16.632 6.785 16.761 6.85 16.875C6.916 16.989 7.011 17.084 7.125 17.15C7.239 17.215 7.368 17.25 7.5 17.25L16.5 17.25C16.632 17.25 16.761 17.215 16.875 17.15C16.989 17.084 17.084 16.989 17.15 16.875C17.215 16.761 17.25 16.632 17.25 16.5L17.25 7.5C17.25 7.368 17.215 7.239 17.15 7.125C17.084 7.011 16.989 6.916 16.875 6.85C16.761 6.785 16.632 6.75 16.5 6.75L7.5 6.75C7.368 6.75 7.239 6.785 7.125 6.85C7.011 6.916 6.916 7.011 6.85 7.125C6.785 7.239 6.75 7.368 6.75 7.5',
        true,
        false
      )
    ]
  ),
  'Observe': (
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
  'การวินิจฉัย': (
    [
      (
        'M12.75 7.5L12.75 11.575L16.136 13.607C16.272 13.688 16.379 13.811 16.441 13.957C16.502 14.103 16.517 14.264 16.481 14.419C16.445 14.573 16.362 14.712 16.242 14.816C16.123 14.92 15.973 14.983 15.816 14.997C15.658 15.011 15.5 14.975 15.364 14.893L11.614 12.643C11.503 12.576 11.411 12.482 11.347 12.369C11.283 12.257 11.25 12.129 11.25 12L11.25 7.5C11.25 7.342 11.3 7.187 11.393 7.059C11.486 6.931 11.618 6.836 11.768 6.787C11.919 6.738 12.081 6.738 12.232 6.787C12.382 6.836 12.514 6.931 12.607 7.059C12.7 7.187 12.75 7.342 12.75 7.5M12 3C10.817 2.997 9.645 3.229 8.552 3.682C7.459 4.135 6.467 4.8 5.633 5.639C4.951 6.329 4.345 6.993 3.75 7.688L3.75 6C3.75 5.842 3.7 5.687 3.607 5.559C3.514 5.431 3.382 5.336 3.232 5.287C3.081 5.238 2.919 5.238 2.768 5.287C2.618 5.336 2.486 5.431 2.393 5.559C2.3 5.687 2.25 5.842 2.25 6L2.25 9.75C2.25 9.882 2.285 10.011 2.35 10.125C2.416 10.239 2.511 10.334 2.625 10.4C2.739 10.465 2.868 10.5 3 10.5L6.75 10.5C6.908 10.5 7.063 10.45 7.191 10.357C7.319 10.264 7.414 10.132 7.463 9.982C7.512 9.831 7.512 9.669 7.463 9.518C7.414 9.368 7.319 9.236 7.191 9.143C7.063 9.05 6.908 9 6.75 9L4.594 9C5.264 8.211 5.932 7.467 6.693 6.697C7.735 5.654 9.062 4.942 10.506 4.649C11.951 4.357 13.45 4.496 14.816 5.05C16.182 5.604 17.354 6.549 18.187 7.766C19.019 8.982 19.474 10.418 19.495 11.891C19.517 13.365 19.103 14.813 18.306 16.053C17.51 17.293 16.365 18.272 15.016 18.865C13.667 19.459 12.172 19.641 10.72 19.39C9.267 19.14 7.92 18.466 6.848 17.454C6.733 17.346 6.586 17.276 6.429 17.256C6.272 17.235 6.112 17.265 5.973 17.341C5.834 17.417 5.722 17.535 5.655 17.678C5.587 17.821 5.566 17.983 5.595 18.138C5.624 18.294 5.702 18.437 5.817 18.546C7.04 19.699 8.561 20.488 10.209 20.821C11.857 21.155 13.565 21.02 15.14 20.432C16.715 19.845 18.094 18.827 19.121 17.496C20.148 16.165 20.781 14.572 20.949 12.9C21.117 11.227 20.813 9.541 20.072 8.032C19.331 6.523 18.182 5.252 16.755 4.362C15.329 3.473 13.681 3.001 12 3',
        true,
        false
      )
    ],
    [
      (
        'M21 12C21 13.758 20.485 15.477 19.519 16.946C18.553 18.414 17.178 19.568 15.564 20.264C13.95 20.96 12.167 21.169 10.436 20.863C8.705 20.558 7.101 19.752 5.823 18.546C5.708 18.437 5.63 18.294 5.601 18.138C5.571 17.983 5.592 17.821 5.66 17.678C5.728 17.535 5.84 17.417 5.979 17.341C6.118 17.265 6.278 17.235 6.435 17.256C6.592 17.276 6.739 17.346 6.854 17.454C7.926 18.466 9.273 19.139 10.726 19.39C12.178 19.64 13.673 19.457 15.022 18.864C16.371 18.27 17.515 17.291 18.312 16.051C19.108 14.811 19.522 13.363 19.5 11.889C19.478 10.415 19.023 8.98 18.19 7.764C17.358 6.547 16.185 5.603 14.82 5.049C13.454 4.495 11.954 4.356 10.51 4.649C9.065 4.942 7.739 5.654 6.697 6.697C6.376 7.022 6.061 7.352 5.752 7.688L7.281 9.219C7.386 9.324 7.457 9.458 7.486 9.604C7.515 9.749 7.5 9.9 7.443 10.037C7.387 10.174 7.29 10.291 7.167 10.374C7.044 10.456 6.898 10.5 6.75 10.5L3 10.5C2.868 10.5 2.739 10.465 2.625 10.4C2.511 10.334 2.416 10.239 2.35 10.125C2.285 10.011 2.25 9.882 2.25 9.75L2.25 6C2.25 5.852 2.294 5.706 2.376 5.583C2.459 5.46 2.576 5.363 2.713 5.307C2.85 5.25 3.001 5.235 3.146 5.264C3.292 5.293 3.426 5.364 3.531 5.469L4.688 6.628C4.989 6.301 5.301 5.972 5.631 5.639C6.889 4.379 8.493 3.52 10.239 3.172C11.985 2.823 13.796 3.001 15.442 3.682C17.087 4.363 18.494 5.517 19.483 6.997C20.472 8.478 21 10.219 21 12M12 6.75C11.868 6.75 11.739 6.785 11.625 6.85C11.511 6.916 11.416 7.011 11.35 7.125C11.285 7.239 11.25 7.368 11.25 7.5L11.25 12C11.25 12.129 11.283 12.257 11.347 12.369C11.411 12.482 11.503 12.576 11.614 12.643L15.364 14.893C15.5 14.975 15.658 15.011 15.816 14.997C15.973 14.983 16.123 14.92 16.242 14.816C16.362 14.712 16.445 14.573 16.481 14.419C16.517 14.264 16.502 14.103 16.441 13.957C16.379 13.811 16.272 13.688 16.136 13.607L12.75 11.575L12.75 7.5C12.75 7.368 12.715 7.239 12.65 7.125C12.584 7.011 12.489 6.916 12.375 6.85C12.261 6.785 12.132 6.75 12 6.75',
        true,
        false
      )
    ]
  ),
};
