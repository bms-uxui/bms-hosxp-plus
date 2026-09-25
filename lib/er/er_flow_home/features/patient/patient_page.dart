// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

const List<String> _detailTabs = [
  'ภาพรวม',
  'คัดกรอง',
  'ตรวจร่างกาย',
  'คำสั่งแพทย์',
  'สัญญาณชีพ',
  'ยา',
  'แล็บ',
  'ภาพถ่าย',
  'ฟอร์ม HOSxP',
  'EMR',
  'Progress note',
];

/// จำนวนแท็บที่แสดงบนแถบ (ภาพรวม…ภาพถ่าย) · ฟอร์ม HOSxP / EMR / Progress note
/// ไม่อยู่บนแถบ เปิดจากช่องทางลัดใน bento หรือปุ่ม "ใส่ progress note" แทน
const int _barTabs = 8;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientPatientPageState on State<ErFlowHomeWidget> {
  bool _chatOpen = false;
}

extension _FeaturesPatientPatientPagePart on _ErFlowHomeWidgetState {
  // ------------------------------------------------- โหมดข้อมูลผู้ป่วย
  /// หน้ารายละเอียดผู้ป่วย (Figma node 58-697) โครงใหม่ทั้งหน้า
  ///
  /// บน: แถบแท็บ + ป้ายชื่อผู้ป่วย (แตะเพื่อกลับ)
  /// ล่าง: กราฟ | ฉากมองจากบน + จุดอาการ | ข้อมูลผู้ป่วย | เส้นเวลา + ปุ่มลัด
  Widget _detailPage() => Column(
        children: [
          RepaintBoundary(child: _detailTopBar()),
          Expanded(
            child: Stack(
              children: [
                // ฉากสามมิติเป็นพื้นหลังเต็มพื้นที่ ทุกแผงลอยทับอยู่ข้างบน
                Positioned.fill(
                  child: Stack(
                    children: [
                      // ฉาก 3D แยกชั้นวาด: แผงลอยข้างบนอัปเดตไม่ทำให้ฉากวาดใหม่
                      // ภาพรวมแบบ ClyHealth: พื้นไล่สีเทาฟ้า หุ่นอยู่ครึ่งซ้าย
                      if (_clyOn)
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_cyBgTop, _cyBgBottom],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0.0,
                        top: 0.0,
                        bottom: 0.0,
                        right: _clyOn
                            ? MediaQuery.sizeOf(context).width - _clySceneW
                            : 0.0,
                        // แผง workflow กางเต็มทับหุ่นแล้ว: ซ่อนฉาก 3D (WebView ยังอยู่ ไม่โหลดใหม่)
                        // WebView ที่ต้อง composite ทุกเฟรมกิน raster ~9 ms/เฟรม ซ่อนได้ = ลื่นขึ้นมาก
                        child: Offstage(
                          offstage: _clyOn && _speechOpen && _wfReady,
                          child: RepaintBoundary(child: _sceneFor(_open)),
                        ),
                      ),
                      // แท็บภาพรวม: พื้นขาว ฉากจางหายไปทางซ้ายใต้คอลัมน์กราฟ/ปัญหา
                      if (_detailTab == 0 &&
                          !_tableView &&
                          !_summaryOpen &&
                          !_clyOn)
                        Positioned(
                          left: 0.0,
                          top: 0.0,
                          bottom: 0.0,
                          width: 560.0,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.92),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // วงกลมเพ่งบริเวณอาการ วาดไว้ใต้จุดทั้งหมด
                      if (!_loading)
                        for (final h in _hotspots)
                          if (h.visible && h.code == _focusSpot)
                            Positioned(
                              left: h.dx - 132.0,
                              top: h.dy - 132.0,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  size: const Size(264.0, 264.0),
                                  painter: _FocusRing(color: _blue),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                ..._detailOverlays(),

                // ลิ้นชักวัดสัญญาณชีพซ้ำ: แตะพื้นที่ว่างเพื่อปิด
                if (_vsDrawer)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeVsDrawer,
                      child: Container(color: const Color(0x14000000)),
                    ),
                  ),
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: IgnorePointer(
                    ignoring: !_vsDrawer,
                    child: AnimatedSlide(
                      offset: _vsDrawer ? Offset.zero : const Offset(1.0, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: _vsDrawerPanel(),
                    ),
                  ),
                ),
                // ลิ้นชักส่งต่อผู้ป่วย (F9): แตะพื้นที่ว่างเพื่อปิด
                if (_f9Open)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _f9Close,
                      child: Container(color: const Color(0x14000000)),
                    ),
                  ),
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: IgnorePointer(
                    ignoring: !_f9Open,
                    child: AnimatedSlide(
                      offset: _f9Open ? Offset.zero : const Offset(1.0, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: _f9DrawerPanel(),
                    ),
                  ),
                ),
                // แตะพื้นที่ว่างเพื่อปิดลิ้นชักเส้นเวลา
                if (_timelineOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _timelineOpen = false),
                    ),
                  ),
                // เส้นเวลาเป็นลิ้นชักเลื่อนเข้ามาจากขอบขวา
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: IgnorePointer(
                    ignoring: !_timelineOpen,
                    child: AnimatedSlide(
                      offset:
                          _timelineOpen ? Offset.zero : const Offset(1.0, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: _loading
                          ? _detailTimelineSkeleton()
                          : _detailTimeline(),
                    ),
                  ),
                ),
                // aura (WebView เล่นเสียง) เตรียมไว้ตั้งแต่เปิดหน้าคนไข้
                // ซ่อนด้วย opacity ให้ WebView โหลดค้างไว้ ตอนเปิดโหมดพูดจะได้พูดทันที
                // WebView เสียงผู้ช่วยค้างไว้ตลอด (ซ่อนด้วย opacity) แถบพูดไม่ต้องย้ายมัน
                _auraWarm(),
                // โหมดพูดเพื่อบันทึก ทับทุกอย่างรวมถึงปุ่มลัด
                // แผงผู้ช่วยข้างวงล้อ: เฉพาะสิ่งที่ต้องลงมือทำ (ข้อมูลที่หน้าแสดงอยู่แล้วไม่ซ้ำ)
                // พยาบาล: งานที่ต้องติดตามเป็นแถบการ์ดแนวนอนลอยด้านล่างทุกแท็บ
                if (ErSession.instance.isNurse && !_speechOpen && !_loading)
                  _nurseFooter(),
                if (_speechOpen && !_loading && !_clyOn) _agentBar(),
                // แจ้งเตือน + ประวัติการบันทึก มุมซ้ายล่าง (ย้ายจากแถบบน)
                if (!_loading)
                  Positioned(left: 12.0, bottom: 16.0, child: _detailDock()),
                // ลิ้นชักประวัติการคุยกับผู้ช่วย เลื่อนจากซ้าย ทับแถบพูดได้
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  width: 400.0,
                  child: IgnorePointer(
                    ignoring: !_chatOpen,
                    child: AnimatedSlide(
                      offset: _chatOpen ? Offset.zero : const Offset(-1.0, 0.0),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      child: _chatPanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  /// แตะค่าใน checklist เพื่อแก้ด้วยมือ (ASR ฟังผิด) ไม่ต้องพูดใหม่
  Future<void> _editField(String label, {String? title}) async {
    final ctrl = TextEditingController(text: _filled[_speechStep][label] ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? label, style: _t(13.0, weight: FontWeight.w700)),
        content: SizedBox(
          width: 560.0,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 4,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
            style: _t(12.5, height: 1.45),
            decoration: const InputDecoration(
                hintText: 'พิมพ์ข้อความ (ยาวได้หลายประโยค)',
                border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: Text('ล้างค่า', style: _t(11.0, color: _red))),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text('บันทึก', style: _t(11.0, color: Colors.white))),
        ],
      ),
    );
    if (v == null || !mounted) return;
    setState(() {
      if (v.isEmpty) {
        _filled[_speechStep].remove(label);
      } else {
        // HPI จัดรูปแบบอัตโนมัติทุกครั้งที่บันทึก (แบบ prettier)
        _filled[_speechStep][label] = _fmtField(label, v);
      }
      _allergyWarn = _allergyConflict();
    });
  }

  /// แถบบนของหน้ารายละเอียด
  ///
  /// ตามผัง 58:697 — ซ้ายสุดคือย้อนกลับ ตามด้วยแท็บ ขวาสุดคือบันทึก
  /// ชื่อผู้ป่วยอยู่กับแท็บ ไม่ต้องทำเป็นปุ่มย้อนกลับซ้อนอีกอันเหมือนเดิม
  /// แท็บแบบขีดเส้นใต้ ตามแบบที่ผู้ใช้ส่งมา — ไม่มีพื้นหลัง มีแค่เส้นใต้ตัวที่เลือก
  Widget _detailTabItem(int i) {
    final on = i == _detailTab;
    final hn = _caseP().hn;
    final dot =
        (i == 6 && _labNewOf(hn).isNotEmpty) || (i == 3 && _orderNewOf(hn));
    final item = _tabItemBody(i, on);
    if (!dot) return item;
    return Stack(clipBehavior: Clip.none, children: [
      item,
      Positioned(right: 3.0, top: 3.0, child: _newDot(8.0)),
    ]);
  }

  Widget _tabItemBody(int i, bool on) {
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          _detailTab = i;
          _markSeen(_caseP().hn, i);
          _orderEditing = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: on ? _glossGrad(_blue) : null,
            borderRadius: BorderRadius.circular(9.0),
            boxShadow: on ? _glossLift(_blue) : null,
          ),
          foregroundDecoration: on ? const _InnerGloss(9.0, dark: true) : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _detailTabs[i],
              maxLines: 1,
              style: _t(11.0,
                  color: on ? Colors.white : _ink2,
                  weight: on ? FontWeight.w600 : FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  /// ภาพรวมแบบ ClyHealth ใช้เมื่ออยู่แท็บภาพรวมในมุมมองภาพ
  bool get _clyOn => _detail && !_summaryOpen;

  List<Widget> _clyOverlays() {
    final bottom = ErSession.instance.isNurse ? 96.0 : 16.0;
    final sceneW = _clySceneW;
    final open = _speechOpen;
    final wfW = MediaQuery.sizeOf(context).width * _wfSplit - 28.0;
    return [
      if (!open) ..._clyLabels(),
      // แตะป้ายอาการ: drill-down เห็นรูปของตำแหน่งนั้น (ทับหุ่น เว้นราง)
      if (!open && _symOpen != null)
        Positioned(
          key: const ValueKey('sym-drill'),
          left: 88.0,
          top: 16.0,
          bottom: bottom,
          width: sceneW - 102.0,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_symOpen!.code),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.94 + 0.06 * v, child: child),
            ),
            child: _symDrill(),
          ),
        ),
      // ปุ่มซูมหุ่น มุมขวาล่างของพื้นที่หุ่น
      if (!open)
        Positioned(
          left: sceneW - 58.0,
          bottom: bottom,
          child: Column(children: [
            _clyRound(Icons.add_rounded, () => _clySetZoom(_clyZoom * 0.85)),
            const SizedBox(height: 10.0),
            _clyRound(Icons.remove_rounded, () => _clySetZoom(_clyZoom / 0.85)),
            const SizedBox(height: 10.0),
            _clyRound(Icons.open_in_full_rounded, () => _clySetZoom(1.15)),
          ]),
        ),
      // แผงกระจกด้านขวา
      Positioned(
        left: sceneW,
        right: 16.0,
        // ขอบบนแถบแท็บตรงกับขอบบนแผง workflow / รางขั้นตอน (16)
        top: 16.0,
        bottom: bottom,
        // แยกชั้นวาด: ฉาก 3D อัปเดตเฟรม แผงขวาไม่ต้องวาดใหม่ตาม
        child: RepaintBoundary(child: _clyPanel()),
      ),
      // ที่จับขอบซ้ายแผงขวา: ลากปรับความกว้าง · แตะสองครั้งกลับค่าเริ่ม
      Positioned(
        // เปิด workflow: ที่จับอยู่ขอบขวาของแผง workflow (ปรับความกว้าง workflow)
        left: open ? 14.0 + wfW - 2.0 : sceneW - 12.0,
        width: 16.0,
        top: 16.0,
        bottom: bottom,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // ลากปรับได้ทั้งตอนดูหุ่น และตอนกาง workflow (จำแยกกัน)
          onHorizontalDragUpdate: (d) => setState(() {
            final dx = d.delta.dx / MediaQuery.sizeOf(context).width;
            if (_speechOpen) {
              _wfSplit = (_wfSplit + dx).clamp(0.40, 0.66);
            } else {
              _clySplit = (_clySplit + dx).clamp(0.30, 0.55);
            }
          }),
          onDoubleTap: () =>
              setState(() => _speechOpen ? _wfSplit = 0.54 : _clySplit = 0.40),
          child: Center(
            child: Container(
              width: 5.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: _g5,
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          ),
        ),
      ),
      // ราง workflow: กดขั้นแล้วขยายต่อเนื่องจากรางเดิม (กว้าง + สูง) ทับหุ่น
      // วางท้ายสุดให้อยู่ชั้นบนแผงขวา
      // ปิดแล้วหุบกลับเป็นราง · เนื้อหาจัดวางเต็มขนาดตั้งแต่แรก ตัดขอบเอา
      // key คงที่: ป้ายบนหุ่นก่อนหน้านี้หาย/โผล่ตอนเปิดปิด ถ้าไม่มี key
      // Flutter จะจับคู่ element ผิดตัว animation เริ่มใหม่ที่ปลายทาง (ไม่ยืด)
      Positioned(
        key: const ValueKey('cly-workflow'),
        left: 14.0,
        top: 16.0,
        bottom: bottom,
        // กางแล้วลอยทับแผงขวาได้ (แผงขวาไม่ถูกบีบ)
        width: wfW,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: open ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeInOutCubic,
          onEnd: () {
            if (!_speechOpen && _wfShown) {
              setState(() {
                _wfShown = false;
                _wfReady = false;
              });
            } else {
              _wfMakeReady();
            }
          },
          child: _wfShown || open
              ? RepaintBoundary(child: _clyWorkflowOpen())
              : null,
          builder: (context, v, panel) => LayoutBuilder(
            builder: (context, box) {
              final railH = math.min(_wfRailH, box.maxHeight);
              final w = 64.0 + (box.maxWidth - 64.0) * v;
              final h = railH + (box.maxHeight - railH) * v;
              // กันค้างที่โครง: กางเต็มแล้วแต่ยังไม่ใส่เนื้อหา (เช่นเปิดค้างมาก่อน)
              if (v >= 1.0 && _speechOpen && !_wfReady) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _wfMakeReady());
              }
              final fadeIn = const Interval(0.45, 1.0).transform(v);
              final fadeOut = 1.0 - const Interval(0.0, 0.25).transform(v);
              return Stack(clipBehavior: Clip.none, children: [
                // กรอบการ์ดขาวทึบตั้งแต่เริ่ม ยืดจากขนาดรางไปเต็มแผง
                // เนื้อหาข้างในค่อยจางเข้าตามหลัง จึงเห็นการ์ดยืดออกชัด
                if (v > 0.0 && panel != null)
                  Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(14.0 + 8.0 * v),
                      border: Border.all(color: _line),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1B3F)
                              .withValues(alpha: 0.06 + 0.06 * v),
                          blurRadius: 12.0 + 16.0 * v,
                          offset: Offset(0, 4.0 + 4.0 * v),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.0 + 8.0 * v),
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: box.maxWidth,
                        maxWidth: box.maxWidth,
                        minHeight: box.maxHeight,
                        maxHeight: box.maxHeight,
                        child: Opacity(opacity: fadeIn, child: panel),
                      ),
                    ),
                  ),
                if (v < 1.0)
                  IgnorePointer(
                    ignoring: v > 0.0,
                    child: Opacity(
                      opacity: fadeOut,
                      child: _MeasureSize(
                        onChange: (sz) {
                          if ((sz.height - _wfRailH).abs() > 1.0) {
                            setState(() => _wfRailH = sz.height);
                          }
                        },
                        child: RepaintBoundary(child: _clyRail()),
                      ),
                    ),
                  ),
              ]);
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _detailOverlays() {
    final list = _detailOverlaysInner();
    // ปุ่มสลับวางกลางบนของพื้นที่ฉาก เฉพาะแท็บที่มีทั้งภาพและตาราง
    if (!_summaryOpen && !_speechOpen && _hasToggle && !_clyOn) {
      return [
        ...list,
        Positioned(
          top: 12.0,
          left: 0.0,
          right: 0.0,
          child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            _viewToggle(),
            if (_detailTab == 0 && !_tableView) ...[
              const SizedBox(width: 8.0),
              _boardEditButton(),
              if (_boardEdit) _boardResetButton(),
            ],
          ])),
        ),
      ];
    }
    return list;
  }

  List<Widget> _detailOverlaysInner() {
    if (_summaryOpen) return _summaryOverlays();
    if (_clyOn && !_loading) return _clyOverlays();
    // โหมดพูดคงหน้าจอของแท็บเดิมไว้ (ไม่สลับเป็นแผงบริบท) orbit ลอยทับด้านล่าง
    if (_tableOnly || (_hasToggle && _tableView)) return _tableOverlays();
    if (_detailTab == 2) return _examOverlays();
    if (_detailTab == 8) return _kbOverlays();
    if (_detailTab == 3) {
      return [
        Positioned(left: 0.0, top: 0.0, bottom: 0.0, child: _orderLeft()),
        Positioned(right: 0.0, top: 0.0, bottom: 0.0, child: _orderRight()),
      ];
    }
    return [
      Positioned(
        left: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: _loading ? _detailChartsSkeleton() : _boardColumn(0),
      ),
      if (!_loading)
        Positioned(
            left: _boardW[0], top: 0.0, bottom: 0.0, child: _boardColumn(1)),
      if (!_loading)
        Positioned(
            right: _boardW[3], top: 0.0, bottom: 0.0, child: _boardColumn(2)),
      Positioned(
        right: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: _loading ? _detailFieldsSkeleton() : _boardColumn(3),
      ),
    ];
  }

  /// ปุ่มลัดในการ์ดผู้ป่วย
  /// เปิดหน้ารายละเอียดผู้ป่วย (เลือกแท็บได้)
  void _openDetail(_P p, {int tab = 0}) {
    setState(() {
      _detail = true;
      _detailTab = tab;
      _touchRecent(p.hn);
      _markSeen(p.hn, tab);
    });
    _prefetchReview();
    _simulateLoad(const Duration(milliseconds: 600));
  }

  // ---------------------------------------------------------------- รายชื่อ
  /// เข้าหน้ารายละเอียดของผู้ป่วยคนนี้ทันที (จากหมุดข้างแถบหรือรายชื่อในแผง)
  /// ล้างข้อมูลการพูดของคนไข้คนก่อน (ฟอร์ม ข้อความ ประวัติคุย การ์ดผู้ช่วย)
  void _resetSpeechCase() {
    _hpiManual = false;
    _peTplUsed = null;
    _peScope = null;
    for (final m in _filled) {
      m.clear();
    }
    for (var i = 0; i < _transcripts.length; i++) {
      _transcripts[i] = '';
      _utter[i].clear();
    }
    _glow = const {};
    _speechDone.clear();
    _speechStep = 0;
    _chatLog.clear();
    _reviewJson = null;
    _reviewClips = null;
    _reviewJob = null;
    _uiIdx = 0;
    _formAt = 0;
    _orderPick.clear();
    _uiTicks.clear();
    _lastFilled = const [];
    _allergyWarn = null;
    _agentChoices = null;
  }

  void _openPatient(_P p) {
    if (_speechOpen) _closeSpeech();
    _vsPick.clear();
    _touchRecent(p.hn);
    setState(() {
      _open = _Phase.of(p.stage);
      _sceneHn = p.hn;
      _zoom = null;
      _summaryOpen = false;
      _timelineOpen = false;
      _detail = true;
    });
    _prefetchReview();
    _simulateLoad(const Duration(milliseconds: 600));
  }
}
