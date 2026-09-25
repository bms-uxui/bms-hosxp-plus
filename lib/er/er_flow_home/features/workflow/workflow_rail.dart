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
      for (var i = 0; i < _steps.length; i++)
        if (_clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2) i
    ].length;
    var cur = 0;
    while (cur < _steps.length - 1 &&
        _clyStep(cur).$2 > 0 &&
        _clyStep(cur).$1 == _clyStep(cur).$2) {
      cur++;
    }
    if (_speechOpen && _speechHn == _caseP().hn) cur = _speechStep;
    return Container(
      width: 64.0,
      padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 8.0),
      decoration:
          _clyCardDeco.copyWith(borderRadius: BorderRadius.circular(14.0)),
      foregroundDecoration: const _InnerGloss(14.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('ขั้นตอน', style: _t(9.0, color: _ink3)),
        Text('$done/${_steps.length}',
            style: _num(13.0, color: _inkTitle, weight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0)
            Container(
              width: 1.5,
              height: 6.0,
              color: i <= done ? _blue.withValues(alpha: 0.5) : _line,
            ),
          _clyRailItem(i, cur),
          if (_tplOn && i == _speechStep) _tplSubmenu(),
        ],
        Container(
          width: 24.0,
          height: 1.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: _line,
        ),
        // สลับเป็นตาราง (แทนปุ่ม ภาพ/ตาราง ของแท็บอื่น)
        Tooltip(
          message: 'ตาราง',
          child: _Press(
            child: GestureDetector(
              onTap: () => setState(() => _tableView = !_tableView),
              child: SizedBox(
                width: 32.0,
                height: 28.0,
                child: Icon(
                    _tableView
                        ? Icons.table_rows_rounded
                        : Icons.table_rows_outlined,
                    size: 17.0,
                    color: _tableView ? _blue : _cySlate),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _clyRailItem(int i, int cur) {
    final (ok, n) = _clyStep(i);
    final complete = n > 0 && ok == n;
    final on = i == cur;
    final active = _speechOpen && _speechStep == i;
    final label = _steps[i].$2;
    return _Press(
      child: GestureDetector(
        onTap: () {
          // ไปขั้นอื่น = ออกจาก template (sub menu ผูกกับขั้น Order Set)
          if (i != _speechStep) _tplOpen = null;
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
        Container(
          width: 72.0,
          padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 8.0),
          decoration: const BoxDecoration(
            color: _panelSoft,
            border: Border(right: BorderSide(color: _line)),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              Text('ขั้นตอน', style: _t(9.0, color: _ink3)),
              const SizedBox(height: 8.0),
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 8.0),
                _clyRailItem(i, _speechStep),
                // เปิด template อยู่: หัวข้อ progress note เป็น sub menu ใต้ขั้นนี้
                if (_tplOn && i == _speechStep) _tplSubmenu(),
              ],
            ]),
          ),
        ),
        // ระหว่างกางออกแสดงโครงเบา ๆ ก่อน เนื้อหาจริง (ฟอร์ม) ค่อยใส่ตอนกางเสร็จ
        // สร้างฟอร์มทั้งก้อนในเฟรมแรกทำจอค้าง animation เลยกระตุก
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _wfReady
                ? KeyedSubtree(
                    key: const ValueKey('wf-body'),
                    child: _tplOn ? _tplBody() : _clyGuideBody())
                : _wfSkeleton(),
          ),
        ),
      ]),
    );
  }

  /// เนื้อหาผู้ช่วยของขั้นที่เลือก (เดิมอยู่แถบล่าง) วางในแผง workflow ที่กางออก
  /// โครงแทนเนื้อหาระหว่างแผงกางออก (เบา วาดเร็ว)
  Widget _wfSkeleton() {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
    return Padding(
      key: const ValueKey('wf-skel'),
      padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(140.0, 18.0),
          const SizedBox(height: 8.0),
          bar(90.0, 10.0),
          const SizedBox(height: 20.0),
          for (var i = 0; i < 4; i++) ...[
            bar(double.infinity, 56.0),
            const SizedBox(height: 10.0),
          ],
        ],
      ),
    );
  }

  Widget _clyGuideBody() {
    final seq = _uiSeq;
    final n = seq.length;
    final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
    final cur = n == 0 ? null : seq[at];
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    if (complete && _reviewShown != _speechStep && n > 0) {
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
    final showChoices = _agentChoices != null &&
        !_agentBusy &&
        cur?.type != ErUiType.form &&
        cur?.data['pe_pick'] != true &&
        cur?.data['hpi_pick'] != true;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // หัว (แถวเดียว): ชื่อขั้น · ขั้น x/y · กรอกแล้ว · ปิด
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 0.0),
            child: Row(children: [
              // หน้าคำแนะนำมีชื่อขั้นพร้อมไอคอนอยู่แล้ว หัวแผงไม่ต้องซ้ำ
              // Flexible + Spacer แบ่งที่กันครึ่งต่อครึ่ง ปุ่มจึงลอยกลาง → ใช้ Expanded ให้ปุ่มชิดขวา
              Expanded(
                child: page > 0
                    ? Text(_steps[_speechStep].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _t(16.0, color: _inkTitle, weight: FontWeight.w600))
                    : const SizedBox.shrink(),
              ),
              _Press(
                child: GestureDetector(
                  onTap: _closeSpeech,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    alignment: Alignment.center,
                    // หุบแผงกลับเป็นรางขั้นตอน (ข้อมูลที่กรอกยังอยู่ครบ)
                    child: const Icon(Icons.keyboard_double_arrow_left_rounded,
                        size: 22.0, color: _ink2),
                  ),
                ),
              ),
            ]),
          ),
          // หน้าคำแนะนำ (หน้าแรก) ยังไม่ต้องมี stepper · เริ่มแสดงเมื่อเข้าหน้ากรอก
          if (total > 1 && page > 0) _pageStepper(seq, page),
          // คำถามของผู้ช่วย (สั้น ๆ 2 บรรทัด) + ปุ่มตัวเลือกตอบแทนการพูด
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                    _agentBusy
                        ? Icons.more_horiz_rounded
                        : Icons.auto_awesome_rounded,
                    size: 14.0,
                    color: _blue),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (a, b) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...b, if (a != null) a]),
                  child: Text(say,
                      key: ValueKey(say),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: busy ? _ink3 : _ink2,
                          weight: FontWeight.w500,
                          height: 1.35)),
                ),
              ),
            ]),
          ),
          if (showChoices)
            Padding(
              padding: const EdgeInsets.fromLTRB(36.0, 6.0, 16.0, 0.0),
              child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final o in _agentChoices!.$2)
                  _optChip(
                      o, false, false, () => _pickChoice(_agentChoices!.$1, o),
                      size: 11.0),
              ]),
            ),
          // เนื้อหาของขั้น (ช่องที่ต้องกรอก / การ์ด) ใช้พื้นที่ที่เหลือทั้งหมด
          // มี key: แถวด้านบนโผล่/หาย (สถานะผู้ช่วย · ชิป · stepper) แล้วเนื้อหาไม่ถูกสร้างใหม่
          // (ถ้าสร้างใหม่ รายการที่เลื่อนไว้จะเด้งกลับบนสุด)
          Expanded(
            key: const ValueKey('wf-content'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 6.0),
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
                      child: ClipRect(
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
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // สถานะเสียง→ข้อความแบบ real time: ฟัง → ถอดเสียง → ตีความ
              _sttStrip(),
              Row(children: [
                Expanded(
                  child: _navBtn('ย้อนกลับ', Icons.chevron_left_rounded,
                      page > 0 ? () => _pageGo(seq, page - 1) : null,
                      primary: false),
                ),
                const SizedBox(width: 10.0),
                // ไมค์แตะเปิด/ปิด + สถานะใต้ปุ่ม
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
                const SizedBox(width: 10.0),
                Expanded(child: _nextBtn(seq, page, total)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
