// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

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
    if (_speechOpen && _speechHn == _caseP().hn) cur = _speechStep;
    return Container(
      width: 64.0,
      padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 8.0),
      decoration:
          _clyCardDeco.copyWith(borderRadius: BorderRadius.circular(14.0)),
      foregroundDecoration: const _InnerGloss(14.0),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ขั้นตอน', style: _t(9.0, color: _ink3)),
          Text('$done/$_stepCount',
              style: _num(13.0, color: _inkTitle, weight: FontWeight.w600)),
          const SizedBox(height: 8.0),
          for (final i in _stepOrder) ...[
            if (i != _firstStep) _railLine(_stepPos(i) <= done),
            _clyRailItem(i, cur),
            if (_tplOn && i == _speechStep) _tplSubmenu(),
            if (_steps[i].$2 == 'วินิจฉัย/สั่ง') ...[
              _railLine(_stepPos(i) < done),
              _accidentRailItem(),
            ],
          ],
        ]),
      ),
    );
  }

  /// เปิดฟอร์มอุบัติเหตุใน workflow panel (panel ยังไม่กาง = กางก่อน)
  void _openAccidentPane() {
    final p = _caseP();
    if (_accPane != null && _speechHn == p.hn && _speechOpen) return;
    if (!_speechOpen || _speechHn != p.hn) {
      _openSpeech(step: _speechHn == p.hn ? _speechStep : null);
    }
    _accPaneDrop();
    final (form, close) = _accidentForm(p, embedded: true, done: (_) {
      if (!mounted) return;
      setState(() {
        _accPane = null;
        _accPaneClose = null;
      });
    });
    setState(() {
      _accPaneClose = close;
      _accPane = KeyedSubtree(
          // PageStorageKey: ไม่รับตำแหน่งเลื่อนค้างจากฟอร์มขั้นอื่น
          key: PageStorageKey('acc-${p.hn}'),
          child: form);
    });
  }

  /// ทิ้งฟอร์มอุบัติเหตุใน panel (เก็บค่าที่กรอกเป็นร่าง) · เรียกก่อน/ใน setState
  void _accPaneDrop() {
    _accPaneClose?.call(false, false);
    _accPane = null;
    _accPaneClose = null;
  }

  /// Additional patient action; does not change the required workflow count.
  /// จำนวนขั้นที่ทำครบ (ใช้ระบายเส้น timeline ในราง)
  int get _railDoneN => [
        for (final i in _stepOrder)
          if (_clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2) i
      ].length;

  /// เส้น timeline เชื่อมขั้นในราง: ผ่านมาแล้ว = กรมท่า · ยังไม่ถึง = เทา
  Widget _railLine(bool passed) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 2.0,
        height: 14.0,
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        decoration: BoxDecoration(
          color: passed ? _blue : _ink3.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1.0),
        ),
      );

  Widget _accidentRailItem() {
    final patient = _caseP();
    final saved = _accSaved(patient.hn);
    final on = _speechOpen && _accPane != null;
    return Semantics(
      button: true,
      label: 'อุบัติเหตุ${saved ? ' บันทึกแล้ว' : ''}',
      child: Tooltip(
        message: 'บันทึกข้อมูลอุบัติเหตุ',
        child: _Press(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAccidentPane,
            child: SizedBox(
              width: 56,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: on
                        ? _glossGrad(_blue)
                        : saved
                            ? _glossGrad(_green)
                            : _glossWhite,
                    border: Border.all(color: on ? _blue : _line),
                  ),
                  foregroundDecoration: _InnerGloss(100, dark: saved || on),
                  child: Icon(
                    saved && !on
                        ? Icons.check_circle_rounded
                        : Icons.car_crash_rounded,
                    size: 18,
                    color: saved || on ? Colors.white : _cySlate,
                  ),
                ),
                const SizedBox(height: 3),
                Text('อุบัติเหตุ',
                    style: _t(8.5,
                        color: on ? _inkTitle : _ink3,
                        weight: on ? FontWeight.w600 : FontWeight.w500),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _clyRailItem(int i, int cur) {
    final (ok, n) = _clyStep(i);
    final complete = n > 0 && ok == n;
    final on = i == cur;
    final active = _speechOpen && _speechStep == i && _accPane == null;
    final label = _steps[i].$2;
    return _Press(
      child: GestureDetector(
        onTap: () {
          // ไปขั้นอื่น = ออกจาก template (sub menu ผูกกับขั้น Order Set)
          if (i != _speechStep) _tplOpen = null;
          _accPaneDrop();
          _openSpeech(step: i);
        },
        child: SizedBox(
          width: 56.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 34.0,
              height: 34.0,
              child: Stack(alignment: Alignment.center, children: [
                // วงความคืบหน้ารอบไอคอน · วิ่งไปค่าใหม่ทุกครั้งที่กรอกเพิ่ม
                TweenAnimationBuilder<double>(
                  tween: Tween(end: n == 0 ? 0.0 : ok / n),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  // ครบแล้วไม่ต้องมีวงรอบ วงเขียวเต็มขนาดแทน
                  builder: (context, v, _) => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: complete ? 0.0 : 1.0,
                    child: SizedBox(
                      width: 34.0,
                      height: 34.0,
                      child: CircularProgressIndicator(
                        value: v,
                        strokeWidth: 2.2,
                        backgroundColor: _line,
                        color: _blue,
                      ),
                    ),
                  ),
                ),
                // ครบแล้ว: วงเขียวเด้งขึ้น · ยังไม่ครบ: กรมท่า (กำลังทำ) / ขาว
                TweenAnimationBuilder<double>(
                  key: ValueKey('rail$i$complete'),
                  tween: Tween(begin: complete ? 0.55 : 1.0, end: 1.0),
                  duration: Duration(milliseconds: complete ? 520 : 1),
                  curve: Curves.elasticOut,
                  builder: (context, k, child) =>
                      Transform.scale(scale: k, child: child),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: complete ? 34.0 : 27.0,
                    height: complete ? 34.0 : 27.0,
                    decoration: BoxDecoration(
                      gradient: complete
                          ? _glossGrad(_green)
                          : (active || on ? _glossGrad(_blue) : _glossWhite),
                      shape: BoxShape.circle,
                      boxShadow: complete ? _glossLift(_green) : null,
                    ),
                    foregroundDecoration:
                        _InnerGloss(100.0, dark: complete || active || on),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween(begin: -0.25, end: 0.0).animate(anim),
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: Icon(complete ? Icons.check_rounded : _steps[i].$1,
                          key: ValueKey(complete),
                          size: complete ? 16.0 : 14.0,
                          color: complete || active || on
                              ? Colors.white
                              : _cySlate),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 3.0),
            Text(label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: _t(8.5,
                    color: on || active ? _inkTitle : _ink3,
                    weight: on || active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.15)),
          ]),
        ),
      ),
    );
  }

  /// workflow ที่กางออกทับหุ่น: รายการขั้นซ้าย + ผู้ช่วยของขั้นที่เลือก
  Widget _clyWorkflowOpen() {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: _cyEdge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // รายการขั้นอยู่ขวา (แผงชิดขวาจอ) · เนื้อหาซ้าย
        // ระหว่างกางออกเป็นแผงว่าง เนื้อหาจริง (ฟอร์ม) ค่อยจางเข้าตอนกางเสร็จ
        // สร้างฟอร์มทั้งก้อนในเฟรมแรกทำจอค้าง animation เลยกระตุก
        // ไม่ใช้ skeleton: skeleton ใช้เฉพาะข้อมูลที่รอโหลดจาก server
        Expanded(
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
        Container(
          width: 72.0,
          padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 8.0),
          decoration: const BoxDecoration(
            color: _panelSoft,
            border: Border(left: BorderSide(color: _line)),
          ),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Text('ขั้นตอน', style: _t(9.0, color: _ink3)),
                  const SizedBox(height: 8.0),
                  for (final i in _stepOrder) ...[
                    if (i != _firstStep) _railLine(_stepPos(i) <= _railDoneN),
                    _clyRailItem(i, _speechStep),
                    // เปิด template อยู่: หัวข้อ progress note เป็น sub menu ใต้ขั้นนี้
                    if (_tplOn && i == _speechStep) _tplSubmenu(),
                    if (_steps[i].$2 == 'วินิจฉัย/สั่ง') ...[
                      _railLine(_stepPos(i) < _railDoneN),
                      _accidentRailItem(),
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

  Widget _clyGuideBody() {
    final seq = _uiSeq;
    final n = seq.length;
    final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
    final cur = n == 0 ? null : seq[at];
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    // กำลังพิมพ์ในช่องอยู่: รอพิมพ์เสร็จ (ออกจากช่อง) ค่อยพาไปหน้าตรวจสอบ
    if (complete && _reviewShown != _speechStep && n > 0 && !_inlineTyping) {
      _reviewShown = _speechStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _uiIdx = _uiSeq.length - 1);
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
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
            // หน้าคำแนะนำ (หน้าแรก) ยังไม่ต้องมี stepper · เริ่มแสดงเมื่อเข้าหน้ากรอก
            if (total > 1 && page > 0) _pageStepper(seq, page),
            // ไม่แสดงข้อความผู้ช่วยและชิปตัวเลือกคำตอบเหนือหัวข้อหน้า (ผู้ใช้สั่งเอาออก)
            // เนื้อหาของขั้น (ช่องที่ต้องกรอก / การ์ด) ใช้พื้นที่ที่เหลือทั้งหมด
            // มี key: แถวด้านบนโผล่/หาย (สถานะผู้ช่วย · ชิป · stepper) แล้วเนื้อหาไม่ถูกสร้างใหม่
            // (ถ้าสร้างใหม่ รายการที่เลื่อนไว้จะเด้งกลับบนสุด)
            Expanded(
              key: const ValueKey('wf-content'),
              child: Padding(
                // หน้าแนะนำ (ไม่มีแถวหัว): ขอบบนเท่าขอบข้าง 16
                padding:
                    EdgeInsets.fromLTRB(16.0, page > 0 ? 6.0 : 10.0, 16.0, 4.0),
                child: cur == null
                    ? Center(
                        child: Text('แตะไมค์แล้วพูดได้เลย',
                            style: _t(12.0, color: _ink3)))
                    : GestureDetector(
                        onHorizontalDragEnd: n < 2 || cur.type == ErUiType.form
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
                                        (incoming ? 0.22 : -0.22) * dir, 0.0),
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
            // ล่าง: แถบความคืบหน้าของหน้า + ปุ่มใหญ่ ย้อนกลับ · ไมค์ · ถัดไป
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // สถานะเสียง→ข้อความแบบ real time: ฟัง → ถอดเสียง → ตีความ
                _sttStrip(),
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
          ],
        ),
      ),
    ]);
  }
}

/// ตัดขอบตามกล่อง แต่ยื่นเลยขอบขวาออกไป [dx] (เนื้อหาล้นถึงขอบแผงได้)
class _ClipPastRight extends CustomClipper<Rect> {
  const _ClipPastRight(this.dx);
  final double dx;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0.0, 0.0, size.width + dx, size.height);

  @override
  bool shouldReclip(_ClipPastRight old) => old.dx != dx;
}
