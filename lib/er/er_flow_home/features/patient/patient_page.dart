// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// getter: เพิ่มแท็บแล้ว hot reload เห็นทันที (ค่าเริ่มต้นของตัวแปร global ไม่รันใหม่)
List<String> get _detailTabs => const [
  'ภาพรวม',
  'การส่งตรวจ',
  'ตรวจร่างกาย',
  'คำสั่งแพทย์',
  'สัญญาณชีพ',
  'ยา',
  'Lab',
  'ภาพถ่าย',
  'ฟอร์ม HOSxP',
  'EMR',
  'Progress note',
  'นัดหมาย',
  'ใบรับรองแพทย์',
  'อุบัติเหตุ',
  'X-ray',
  'กิจกรรมพยาบาล',
  'Observe',
  'Fast track',
];

/// แท็บกิจกรรมพยาบาล (ต่อท้าย ไม่ขยับเลขแท็บเดิม)
const int _nurseTab = 15;

/// แท็บที่แสดงบนแถบ (ภาพรวม…ภาพถ่าย + นัดหมาย) · ฟอร์ม HOSxP / EMR / Progress note
/// ไม่อยู่บนแถบ เปิดจากช่องทางลัดใน bento หรือปุ่ม "ใส่ progress note" แทน
/// ลำดับบนแถบ: แล็บ (6) ต่อจากคัดกรอง · เลขแท็บเดิมไม่เปลี่ยน
/// แล็บ X-ray ยา เรียงติดกัน · แพทย์: แท็บอุบัติเหตุต่อจากยา ไว้ประกอบการดูแลเคสบาดเจ็บ
/// กิจกรรมพยาบาลต่อจากการส่งตรวจ (ซักประวัติที่บันทึกขึ้นในไทม์ไลน์นี้)
List<int> get _barTabIdx =>
    [0, if (_ftRailOn) _ftTab, 1, _nurseTab, 6, _xrayTab, 5, 2, 3];

/// แท็บ Fast track (เลขต่อท้าย) · บนรางอยู่ถัดจากภาพรวม เฉพาะเคสที่เปิดแฟ้มแล้ว
const int _ftTab = 17;
bool _ftRailOn = false;

/// แท็บที่เหลืออยู่ในเมนู "อื่น ๆ" (แพทย์มีแท็บอุบัติเหตุด้วย)
List<int> get _moreTabIdx => [
      if (ErSession.instance.role == ErRole.doctor) _accTab,
      4,
      7,
      _apptTab,
      _mcTab,
      _obsTab,
    ];

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
            // กาง/หุบ workflow: สัดส่วนแผงซ้าย/ขวาค่อย ๆ เปลี่ยนพร้อมแผงกาง
            // (เปลี่ยนทันทีทำให้แผงซ้ายกระตุก) · ลากที่จับ = ทันที
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _clySplitTarget),
              // ไม่ animate ระดับทั้งหน้า (rebuild ทั้งหน้าทุกเฟรม = กระตุก)
              // แผงซ้ายเลื่อนตามแผง workflow เองใน _clyOverlays
              duration: Duration.zero,
              curve: Curves.easeInOutCubic,
              builder: (context, split, _) {
                _clySplitNow = split;
                return Stack(
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
                          // หุ่นอยู่ฝั่งขวา (แผงข้อมูลซ้าย)
                          // เว้นขวาเท่ารางขั้นตอน (ขอบ 14 + กว้าง 76) หุ่นอยู่กึ่งกลาง
                          // พื้นที่ระหว่างแผงซ้ายกับรางพอดี
                          Positioned(
                            // ฉากอยู่ที่ตำแหน่งตอนหุบเสมอ: กาง workflow แล้วหุ่นไม่ขยับ/ไม่ resize
                            // (แผง workflow กางทับอยู่แล้ว)
                            left: _clyOn
                                ? MediaQuery.sizeOf(context).width *
                                    (1.0 - _clySplit)
                                : 0.0,
                            top: 0.0,
                            bottom: 0.0,
                            right: _clyOn ? 76.0 : 0.0,
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
                          offset:
                              _vsDrawer ? Offset.zero : const Offset(1.0, 0.0),
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
                          offset:
                              _f9Open ? Offset.zero : const Offset(1.0, 0.0),
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
                          offset: _timelineOpen
                              ? Offset.zero
                              : const Offset(1.0, 0.0),
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
                    // พยาบาล: ไม่มีแถบงานที่ต้องติดตามด้านล่างแล้ว (ดูในการ์ดภาพรวม)
                    if (_speechOpen && !_loading && !_clyOn) _agentBar(),
                    // แจ้งเตือน + ประวัติการบันทึก (_detailDock) เอาออกไว้ก่อนตามที่ผู้ใช้สั่ง
                    // ลิ้นชักประวัติการคุยกับผู้ช่วย เลื่อนจากซ้าย ทับแถบพูดได้
                    Positioned(
                      left: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      width: 400.0,
                      child: IgnorePointer(
                        ignoring: !_chatOpen,
                        child: AnimatedSlide(
                          offset:
                              _chatOpen ? Offset.zero : const Offset(-1.0, 0.0),
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOutCubic,
                          child: _chatPanel(),
                        ),
                      ),
                    ),
                  ],
                );
              },
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

  /// ปุ่ม "อื่น ๆ": เมนูแท็บรอง · อยู่แท็บรองอยู่ = ปุ่มนี้เป็นสีเลือก แสดงชื่อแท็บนั้น
  /// ลำดับของแท็บบนแถบ (แท็บในเมนู "อื่น ๆ" นับเป็นท้ายสุด)
  int _tabOrder(int i) {
    final k = _barTabIdx.indexOf(i);
    return k >= 0 ? k : _barTabIdx.length + _moreTabIdx.indexOf(i);
  }

  Widget _moreTabItem() {
    final more = _moreTabIdx;
    final on = more.contains(_detailTab);
    return PopupMenuButton<int>(
      tooltip: 'แท็บอื่น ๆ',
      position: PopupMenuPosition.under,
      color: _panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      onSelected: (i) => setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
        _tabDir = _tabOrder(i) >= _tabOrder(_detailTab) ? 1 : -1;
        _detailTab = i;
        _markSeen(_caseP().hn, i);
        _orderEditing = null;
      }),
      itemBuilder: (_) => [
        for (final i in more)
          PopupMenuItem<int>(
            value: i,
            height: 40.0,
            child: Text(_detailTabs[i],
                style: _t(12.0,
                    color: i == _detailTab ? _blue : _inkTitle,
                    weight:
                        i == _detailTab ? FontWeight.w700 : FontWeight.w500)),
          ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 30.0,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? _blue.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (on) ...[
              Text(_detailTabs[_detailTab],
                  maxLines: 1,
                  style: _t(11.0, color: _blue, weight: FontWeight.w700)),
              const SizedBox(width: 2.0),
              const Icon(Icons.expand_more_rounded, size: 15.0, color: _blue),
            ] else
              Text('อื่น ๆ',
                  style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _tabItemBody(int i, bool on) {
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          _tabDir = _tabOrder(i) >= _tabOrder(_detailTab) ? 1 : -1;
          _detailTab = i;
          _markSeen(_caseP().hn, i);
          _orderEditing = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Google style: แท็บที่เลือก = พื้นฟ้าอ่อน (tonal) ตัวกรมท่า
            color: on ? _blue.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(100.0),
          ),
          // เมนูเป็นข้อความทุกแท็บ · ที่เลือก = พื้นฟ้าอ่อน ตัวหนากรมท่า
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_detailTabs[i],
                maxLines: 1,
                style: _t(11.0,
                    color: on ? _blue : _ink2,
                    weight: on ? FontWeight.w700 : FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  /// ภาพรวมแบบ ClyHealth ใช้เมื่ออยู่แท็บภาพรวมในมุมมองภาพ
  bool get _clyOn => _detail && !_summaryOpen;

  List<Widget> _clyOverlays() {
    const bottom = 16.0;
    final sceneW = _clySceneW;
    // แผงข้อมูลซ้าย · หุ่น + workflow ขวา (ox = ขอบซ้ายพื้นที่หุ่น)
    final ox = _clySceneX;
    final open = _speechOpen;
    // workflow กางได้ถึงขอบซ้ายแผงขวาเท่านั้น (เว้น 12) · แผงขวากว้างเท่าเดิม ไม่ถูกทับ
    // ใช้ความกว้างปลายทาง: แผงไม่ resize ทุกเฟรมระหว่างสัดส่วนซ้าย/ขวากำลังเลื่อน
    // แผง workflow กว้างเท่าตอนกางเสมอ (หุบ/กางใช้ความกว้างเดียวกัน ไม่กระโดด)
    final sw = MediaQuery.sizeOf(context).width;
    final wfW = sw * _wfSplit - 12.0;
    // ขอบขวาแผงซ้ายตอนหุบ (สัดส่วนที่ผู้ใช้ลากไว้)
    final oxClosed = sw * (1.0 - _clySplit);
    return [
      if (!open && !_loading) ..._clyLabels(),
      // แตะป้ายอาการ: drill-down เห็นรูปของตำแหน่งนั้น (ทับหุ่น เว้นราง)
      if (!open && _symOpen != null)
        Positioned(
          key: const ValueKey('sym-drill'),
          left: ox + 88.0,
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
      // ปุ่มซูม +/- เอาออก: ซูมหุ่นด้วยการ pinch แทน
      // แผงข้อมูล (กระจก) ด้านซ้าย
      // ขอบเนื้อหาตรงกับปุ่มกลับบนหัวหน้า (14): แผง 2 + ขอบใน 12
      // key คงที่: ป้ายบนหุ่นหาย/โผล่ตอนกาง workflow ทำให้ลำดับลูกใน Stack เลื่อน
      // ไม่มี key = แผงถูกสร้างใหม่ เนื้อหาเล่น animation ปรากฏซ้ำ (กระตุก)
      Positioned(
        key: const ValueKey('cly-panel'),
        left: 2.0,
        // กว้างพอให้ยืดถึงขอบแผง workflow ที่หดแคบกว่าสัดส่วนตอนหุบ
        width: math.max(math.max(oxClosed, _clySceneXTarget), sw - wfW - 12.0) -
            2.0,
        // ขอบบนแถบแท็บตรงกับขอบบนแผง workflow / รางขั้นตอน (16)
        top: 16.0,
        bottom: bottom,
        // ขอบขวาแผงซ้ายถูก "ดัน" โดยขอบซ้ายของแผง workflow ที่กำลังกาง
        // ใช้ tween/curve/เวลาเดียวกับแผง workflow ขอบสองแผงจึงไปพร้อมกันพอดี
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: open ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeInOutCubic,
          child: RepaintBoundary(child: _clyPanel()),
          builder: (context, v, panel) {
            final wfLeft = sw - (80.0 + (wfW - 80.0) * v);
            // กาง: ขอบขวาแผงซ้ายตามขอบแผง workflow เสมอ (ทั้งดันเข้าและยืดออก)
            // ไม่เหลือช่องว่างตอนลากแผง workflow ให้แคบกว่าตอนหุบ
            final edge = oxClosed + (wfLeft - 12.0 - oxClosed) * v;
            // เนื้อหาจัดวางตามความกว้างจริงทุกเฟรม: หดไปพร้อมขอบ ไม่กระโดดไปขนาดปลายทางก่อน
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: math.max(0.0, edge - 2.0), child: panel),
            );
          },
        ),
      ),
      // ที่จับขอบซ้ายแผงขวา: ลากปรับความกว้าง · แตะสองครั้งกลับค่าเริ่ม
      Positioned(
        key: const ValueKey('cly-handle'),
        // ที่จับอยู่ระหว่างแผงข้อมูล (ซ้าย) กับหุ่น/workflow (ขวา) เสมอ
        left: ox - 2.0,
        width: 16.0,
        top: 16.0,
        bottom: bottom,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // ลากปรับสัดส่วนซ้าย/ขวา: workflow ที่กางอยู่ยืดตามขอบแผงขวา
          onHorizontalDragUpdate: (d) => setState(() {
            // ลากไปขวา = แผงข้อมูลกว้างขึ้น พื้นที่หุ่นแคบลง
            final dx = d.delta.dx / MediaQuery.sizeOf(context).width;
            if (_speechOpen) {
              _wfSplit = (_wfSplit - dx).clamp(0.30, 0.55);
            } else {
              _clySplit = (_clySplit - dx).clamp(0.30, 0.55);
            }
          }),
          onDoubleTap: () =>
              setState(() => _speechOpen ? _wfSplit = 0.4 : _clySplit = 0.338),
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
        // ชิดขอบขวาจอ: รางอยู่ขอบขวา กางออกไปทางซ้ายจนถึงแผงข้อมูล
        right: 0.0,
        top: 16.0,
        bottom: bottom,
        // กางได้ถึงขอบแผงขวาเท่านั้น (ไม่ทับกัน)
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
              final w = 80.0 + (box.maxWidth - 80.0) * v;
              final h = railH + (box.maxHeight - railH) * v;
              // กันค้างที่โครง: กางเต็มแล้วแต่ยังไม่ใส่เนื้อหา (เช่นเปิดค้างมาก่อน)
              if (v >= 1.0 && _speechOpen && !_wfReady) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _wfMakeReady());
              }
              // รางหุบชิดขวาบน ตำแหน่งเดียวกับรางในแผงที่กางแล้ว (ไอคอนไม่กระโดด)
              // รางอยู่ชั้นล่างทึบตลอด · การ์ดทึบยืด/หดจากมุมขวาบนทับราง
              // ไม่จางข้ามกัน (เคยเห็นเงาซ้อนตอนใกล้หุบสุด) หดถึงขนาดรางแล้วการ์ดหายพอดี
              return Stack(
                  alignment: Alignment.topRight,
                  clipBehavior: Clip.none,
                  children: [
                    if (v < 1.0)
                      IgnorePointer(
                        ignoring: v > 0.0,
                        child: _MeasureSize(
                          onChange: (sz) {
                            if ((sz.height - _wfRailH).abs() > 1.0) {
                              setState(() => _wfRailH = sz.height);
                            }
                          },
                          child: RepaintBoundary(child: _clyRail()),
                        ),
                      ),
                    if (v > 0.0 && panel != null)
                      SizedBox(
                        width: w,
                        height: h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: OverflowBox(
                            alignment: Alignment.topRight,
                            minWidth: box.maxWidth,
                            maxWidth: box.maxWidth,
                            minHeight: box.maxHeight,
                            maxHeight: box.maxHeight,
                            child: _WfProgress(v: v, child: panel),
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
    // โหลดอยู่ = โครงเดิม แต่ละแผงเป็น skeleton (หุ่น 3D ไม่ต้อง)
    if (_clyOn) return _clyOverlays();
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
    _accPaneDrop();
    _hpiManual = true;
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
    _speechStep = _firstStep;
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
