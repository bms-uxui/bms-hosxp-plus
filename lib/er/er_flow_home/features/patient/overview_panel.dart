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
    'กิจกรรมพยาบาล': (
      Icons.volunteer_activism_outlined,
      Icons.volunteer_activism_rounded
    ),
  };

  /// เมนูย่อยของแท็บบนราง (ลำดับ = ค่า _clyTriPage)
  static const Map<int, List<String>> _railSubs = {
    1: ['ประวัติ', 'คัดกรอง'],
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
    final onIdx = moreOn ? bar.length : bar.indexOf(_detailTab);

    // แบบรางแท็บหน้าคัดกรอง: ไอคอน + ชื่อ · เลือก = ไอคอนฟ้า ชื่อเข้มตัวหนา
    Widget head(IconData icon, String label, bool on, [IconData? fill]) =>
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
    Widget subItem(int k, String t) {
      final on = _clyTriPage == k;
      return _Press(
        scale: 0.98,
        radius: 8.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _clyTriPage = k);
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
      final on = i == _detailTab;
      final dot =
          (i == 6 && _labNewOf(hn).isNotEmpty) || (i == 3 && _orderNewOf(hn));
      final headBtn = _Press(
        radius: 16.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            go(i);
          },
          child: SizedBox(
            height: tabH,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                  child: head(
                      _railIcons[_detailTabs[i]]?.$1 ?? Icons.circle_outlined,
                      _detailTabs[i],
                      on,
                      _railIcons[_detailTabs[i]]?.$2)),
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
                      top: _clyTriPage * subH,
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
                        for (final (k, label) in subs.indexed)
                          subItem(k, label),
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
              ((_railSubs[_detailTab]?.length ?? 0) > 0
                  ? _railSubs[_detailTab]!.length * subH + 10.0
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
            child: head(Icons.more_horiz_rounded,
                moreOn ? _detailTabs[_detailTab] : 'อื่น ๆ', moreOn),
          ),
        );

    return SizedBox(
      width: 100.0,
      child: LayoutBuilder(builder: (context, box) {
        // +1 = ปุ่ม "อื่น ๆ"
        tabH = ((box.maxHeight / (bar.length + 1)) - tabGap).clamp(58.0, 72.0);
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
                  ),
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
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
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
    return ListView(
      // ระยะบนน้อยลง หัวหน้าชิดขึ้น (เดิม 24)
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
      children: _appearAll([
        // หัวหน้าแบบหน้าส่งตรวจ: ชื่อ + คำอธิบายซ้าย · รูปประกอบชิดขวา
        if (below != null)
          // มีแถบ tab: รูปใหญ่ชิดขอบขวาการ์ด ปลายรูปยืนบนเส้นใต้ tab
          Stack(clipBehavior: Clip.none, children: [
            Positioned(
              right: -20.0,
              bottom: 1.0,
              child: heroArt ??
                  Image.asset('assets/images/er_hero_$hero.png',
                      height: 110.0, fit: BoxFit.contain),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.only(right: 160.0),
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
                const SizedBox(width: 16.0),
                // รูปยืนบนการ์ดแรก: ชิดล่างแถวหัว แล้วเลื่อนลงจนปลายรูปจมใต้การ์ด (แบบหน้าส่งตรวจ)
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
        for (final (name, rows) in cards)
          if (rows.isNotEmpty) ...[
            card(name, rows),
            const SizedBox(height: 12.0),
          ],
        ...extra,
      ]),
    );
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

  /// ประวัติ: ผู้ป่วย การมาถึง การรับบริการ (แบบแท็บประวัติของหน้าส่งตรวจ)
  Widget _clyHistBody() {
    final p = _caseP();
    final c = erCaseOf(p.hn);
    final info = {
      for (final r in erTablesFor(p.hn, ErTab.overview).first.rows) r[0]: r[1]
    };
    String v(String k) => info[k] ?? '-';
    return _clyInfoPage(
        'ประวัติ', 'ข้อมูลผู้ป่วยจากบัตรประชาชนและ HOSxP', 'personal', [
      (
        'ผู้ป่วย',
        [
          ('ชื่อ', p.name, false),
          ('HN', c.hn, false),
          ('เพศ อายุ', '${c.sex} ${c.ageText}', false),
          ('หมู่เลือด', c.bloodGroup, false),
          ('สิทธิการรักษา', c.right, false),
          (
            'แพ้ยา / อาหาร',
            c.allergies.isEmpty ? 'ไม่มีประวัติแพ้' : c.allergies.join(', '),
            c.allergies.isNotEmpty
          ),
          (
            'โรคประจำตัว',
            c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', '),
            false
          ),
        ]
      ),
      ('การมาถึง', _clyTriRows({'ข้อมูลรับเข้า', 'ข้อมูลการมา'})),
      (
        'การรับบริการ',
        [
          ('เตียง', v('เตียง'), false),
          ('แพทย์เจ้าของไข้', v('แพทย์เจ้าของไข้'), false),
          ('พยาบาล', v('พยาบาล'), false),
        ]
      ),
    ]);
  }

  /// แท็บการส่งตรวจ: เมนูย่อยบนราง ประวัติ | คัดกรอง (แบบหน้าส่งตรวจ)
  Widget _clyTriageBody() =>
      _clyTriPage == 0 ? _clyHistBody() : _clyTriageInfo();

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

    final timeline = Container(
      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('บันทึกทางการพยาบาล',
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text('${notes.length} บันทึก',
              style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12.0),
        if (notes.isEmpty)
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
        extra: [timeline]);
  }

  /// แท็บการส่งตรวจ: ข้อมูลจากจุดคัดกรอง
  Widget _clyTriageSent() => _clyInfoPage(
          'คัดกรอง', 'ข้อมูลที่บันทึกจากหน้าคัดกรองและส่งตรวจ', 'triage', [
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
      2 => ListView(
          padding: const EdgeInsets.all(12.0),
          children: _appearAll(_examPanelItems()),
        ),
      // สั่งการรักษาใน workflow: สำรับการ์ดเต็มความสูงแผง (ไม่อยู่ในรายการเลื่อน)
      3 when _soDeckOn => _soDeck(),
      3 => ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 12.0),
          // เลือก Order Set / ติ๊กสั่ง ย้ายไปอยู่ใน workflow ขั้น "วินิจฉัย/สั่ง"
          // แท็บนี้เหลือดูสถานะคำสั่ง + งานที่ต้องติดตาม
          children: _appearAll([_orderRecord()]),
        ),
      8 => _kbPanel(),
      _apptTab => _apptTabBody(),
      _mcTab => _mcTabBody(),
      _obsTab => _obsTabBody(),
      _accTab => _accTabBody(),
      _xrayTab => _xrayTabBody(),
      _nurseTab => _clyNurseActPage(),
      _ftTab => _ftTabBody(),
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

  /// พื้นการ์ด (clean flat): ขาวเรียบ + เส้นขอบบาง ไม่มีเงา
  /// การ์ดหลักแบบ Google (Ads/AdSense) เดียวกับหน้าคัดกรอง: ขาว ขอบเทา #DADCE0 มุม 12 ไม่มีเงา
  BoxDecoration get _clyCardDeco => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      );

  /// พื้นการ์ดย่อย (ค่าแต่ละตัว): ขาวเรียบ ขอบบอกสถานะ (แดง = ผิดปกติ)
  /// การ์ดย่อยแบบหน้าคัดกรอง: ขาว ขอบเทามุม 12 · ขอบสีเมื่อบอกสถานะ
  BoxDecoration _clyTileDeco({Color edge = _line}) => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: edge == _line ? const Color(0xFFDADCE0) : edge,
            width: edge == _line ? 1.0 : 1.5),
      );

  /// การ์ดสัญญาณชีพ: ค่าล่าสุด + แท่งย้อนหลังเล็ก ๆ ต่อค่า
  /// อาการสำคัญ (CC) ตัวเต็ม ย้ายจากแถบบนมาไว้บนสุดของภาพรวม
  /// อาการสำคัญ (บันทึกได้หลายคน เลือกดูของแต่ละคน) + HPI
  Widget _clyCc() {
    final c = _case;
    final recs = erCcRecords(c);
    // -1 = สรุปโดย AI (เปรียบเทียบทุกผู้บันทึก)
    // ค่าเริ่ม = สรุป AI (-1) เมื่อมีผู้บันทึกหลายคน
    final ai = recs.length > 1 && (_ccPick[c.hn] ?? -1) == -1;
    final at = recs.isEmpty
        ? 0
        : (_ccPick[c.hn] ?? recs.length - 1).clamp(0, recs.length - 1);
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
    // ตัวเลือกผู้บันทึกเป็น avatar · วงกรมท่า = กำลังดู
    Widget sel(bool on, Widget child, VoidCallback onTap) => _Press(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: on ? _blue : _line, width: 2.0),
              ),
              child: child,
            ),
          ),
        );
    Widget aiChip() => sel(
        ai,
        Container(
          width: 26.0,
          height: 26.0,
          // tonal แบบ Google (ไม่ใช่กรมท่าทึบ)
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.auto_awesome_rounded, size: 14.0, color: _blue),
        ),
        // แตะซ้ำตอนดูสรุป AI อยู่ = วิเคราะห์ใหม่ (เห็น skeleton ระหว่างรอ)
        () => setState(() {
              if (ai) {
                _ccAi.remove(c.hn);
                _ccAiErr.remove(c.hn);
              }
              _ccPick[c.hn] = -1;
            }));
    Widget pick(int i) => sel(!ai && i == at, _ccAvatar(recs[i], 26.0),
        () => setState(() => _ccPick[c.hn] = i));

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 18.0),
      decoration: _clyCardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
              child: Text('อาการสำคัญ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(17.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
            const SizedBox(width: 2.0),
            _copyBtn('CC + HPI',
                () => 'CC: ${recs.isEmpty ? c.cc : recs[at].text}\nHPI: $hpi',
                iconOnly: true),
            const Spacer(),
            // ผู้บันทึกหลายคน: แตะ avatar เพื่อดูของแต่ละคน · ✦ = สรุป AI
            if (recs.length > 1) ...[
              aiChip(),
              const SizedBox(width: 4.0),
              // avatar ซ้อนกัน · คนที่กำลังดูอยู่บนสุด
              SizedBox(
                width: 34.0 + (recs.length - 1) * 20.0,
                height: 34.0,
                child: Stack(children: [
                  for (final i in [
                    for (var k = 0; k < recs.length; k++)
                      if (ai || k != at) k,
                    if (!ai) at,
                  ])
                    Positioned(left: i * 20.0, top: 0.0, child: pick(i)),
                ]),
              ),
            ],
          ]),
          const SizedBox(height: 6.0),
          if (ai)
            _ccAiView(c.hn, recs)
          else ...[
            if (recs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(children: [
                  _ccAvatar(recs[at], 18.0),
                  const SizedBox(width: 6.0),
                  Text(
                      '${recs[at].who} · ${recs[at].role} · ${recs[at].time} น.',
                      style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
                ]),
              ),
            _copyable(
                'CC',
                recs.isEmpty ? c.cc : recs[at].text,
                Text(recs.isEmpty ? '—' : recs[at].text,
                    style: _t(12.5,
                        color: _inkTitle,
                        weight: FontWeight.w500,
                        height: 1.4))),
          ],
          const SizedBox(height: 8.0),
          const Divider(height: 10.0, color: _line),
          // HPI แยกตาม visit: วันนี้ + visit ก่อนหน้า (แสดง CC ของ visit นั้นด้วย)
          Builder(builder: (context) {
            final hv = erHpiVisits(c);
            final hi = (_hpiVisit[c.hn] ?? 0).clamp(0, hv.length - 1);
            String short(String d) {
              const m = [
                'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
                'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
              ];
              final p = d.split('/');
              if (p.length != 3) return d;
              return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
            }

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
                      _copyBtn('HPI', () => text),
                    ]),
                    if (hv.length > 1) ...[
                      const SizedBox(height: 8.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          for (var i = 0; i < hv.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6.0),
                            _hpiVisitPill(
                                i == 0 ? 'วันนี้' : short(hv[i].date),
                                i == hi,
                                () => setState(() => _hpiVisit[c.hn] = i)),
                          ],
                        ]),
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hi > 0) ...[
                            Row(children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 13.0, color: _ink3),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                    '${hv[hi].place} วันที่ ${hv[hi].date}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(10.0,
                                        color: _ink3, weight: FontWeight.w600)),
                              ),
                            ]),
                            const SizedBox(height: 8.0),
                            _hpiRow(
                                'CC',
                                Text(hv[hi].cc,
                                    style: _t(11.5,
                                        color: _inkTitle,
                                        weight: FontWeight.w600,
                                        height: 1.4))),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1.0, color: _line),
                            ),
                          ],
                          _hpiRow(
                              'HPI',
                              _copyable(
                                  'HPI',
                                  text,
                                  Text(
                                      text.isEmpty
                                          ? 'ยังไม่ได้บันทึก'
                                          : _prettyHpi(text),
                                      style: _t(11.5,
                                          color: text.isEmpty ? _ink3 : _ink,
                                          height: 1.5)))),
                        ],
                      ),
                    ),
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
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
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
      // อุณหภูมิล่าสุด ต่อจากส่วนสูง
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
    final vi = (_labVisit[_case.hn] ?? 0).clamp(0, visits.length - 1);
    // toggle eGFR: แสดงเฉพาะ lab ใน profile ไต (eGFR คำนวณจาก Cr + BUN Cr Na K Cl HCO₃)
    final labs =
        _sortLabs(_egfrOn ? _egfrProfile(visits[vi].labs) : visits[vi].labs);
    const per = 5;
    // วันที่ 23/09/2569 → 23 ก.ย. 69
    String short(String d) {
      const m = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ];
      final p = d.split('/');
      if (p.length != 3) return d;
      return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
    }

    Widget visitChip(int i) {
      final on = i == vi;
      return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: _Press(
          child: Material(
            color: on ? _blue.withValues(alpha: 0.1) : _panelSoft,
            borderRadius: BorderRadius.circular(100.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _labVisit[_case.hn] = i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
                child: Text(i == 0 ? 'วันนี้' : short(visits[i].date),
                    style: _t(11.0,
                        color: on ? _blue : _ink2, weight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

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
            const SizedBox(width: 10.0),
            // เลือกดูตามวันที่มา visit (วันนี้ = visit นี้)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var i = 0; i < visits.length; i++) visitChip(i),
                ]),
              ),
            ),
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
                    border: Border.all(color: _line),
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
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: latest
                ? (bad ? _red : const Color(0xFFDADCE0))
                : (bad ? Colors.white : _blue),
            width: latest ? 1.0 : 2.0),
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
              child: Row(
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
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: v.label == 'Pulse' ? 'PR' : v.label,
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
                            const SizedBox(height: 6.0),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                        latest
                                            ? (v.display ??
                                                _vsValue(v, pick, of))
                                            : _vsValue(v, pick, of),
                                        style: _num(compact ? 22.0 : 26.0,
                                            color: bad ? w1 : _inkTitle,
                                            weight: FontWeight.w700)),
                                    const SizedBox(width: 4.0),
                                    Text(v.unit,
                                        style:
                                            _t(12.0, color: bad ? dim : _ink3)),
                                    // เปลี่ยนจากรอบแรก (แรกรับ) ถึงรอบที่ดู: ไอคอนลูกศร + ค่าที่เปลี่ยน
                                    if (pick > 0) ...[
                                      const SizedBox(width: 8.0),
                                      _vsDeltaChip(v.series[0], v.series[pick],
                                          bad ? w1 : _ink2),
                                    ],
                                  ]),
                            ),
                          ]),
                    ),
                    // การ์ดผังเตียง: มุมขวาบนเป็นปุ่ม ‹ › จึงไม่วางไอคอน
                    if (!bedCard) ...[
                      const SizedBox(width: 8.0),
                      // ชิดมุมขวาบน ไม่ยืดตามความสูงการ์ด (แถวยืดเพื่อให้ค่าชิดล่าง)
                      Align(
                          alignment: Alignment.topRight,
                          child: _vsBadge(v.label, bad,
                              size: compact ? 28.0 : 40.0)),
                    ],
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
  Widget _vsBadge(String label, bool bad, {double size = 28.0}) {
    final img = switch (label) {
      'BP' => 'assets/images/er_vs_bp.png',
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
            fontFamily: 'GoogleSans',
            fontFamilyFallback: const ['NotoSansThai'],
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
                  fontFamily: 'GoogleSans',
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
                    fontFamily: 'GoogleSans',
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
              style: const TextStyle(
                  fontFamily: 'GoogleSans',
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
