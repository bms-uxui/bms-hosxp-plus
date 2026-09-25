// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _SidebarPinnedState on State<ErFlowHomeWidget> {
  /// HN ของผู้ป่วยที่ปักหมุดไว้ที่แถบขวา
  final Set<String> _pinned = {'670123461', '670123471'};

  Offset _pinPressAt = Offset.zero;
}

extension _SidebarPinnedPart on _ErFlowHomeWidgetState {
  String get _pinKey => 'er_pinned_$_uid';

  Future<void> _loadPins() async {
    try {
      final p = await SharedPreferences.getInstance();
      final l = p.getStringList(_pinKey);
      if (l != null && mounted) {
        setState(() => _pinned
          ..clear()
          ..addAll(l));
      }
    } catch (_) {}
  }

  void _setPin(String hn, bool on) {
    setState(() => on ? _pinned.add(hn) : _pinned.remove(hn));
    HapticFeedback.selectionClick();
    SharedPreferences.getInstance()
        .then((p) => p.setStringList(_pinKey, _pinned.toList()))
        .catchError((_) => true);
  }

  // ------------------------------------------------- รายการปักหมุดในแถบซ้าย
  /// ผู้ป่วยที่ปักหมุด แตะแล้วกระโดดไปช่วงงานที่เขาอยู่
  ///
  /// แสดงรูปโปรไฟล์จริง วงแหวนรอบรูปบอกระดับความเร่งด่วน
  /// แดงหนาเมื่อค้างเกินเกณฑ์ ป้ายมุมล่างบอกรหัสเตียง
  Widget _pinPatient(_P p) {
    final ring = p.over ? _red : (p.esi?.color ?? _ink3);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openPatient(p),
          // กดค้าง = เมนู เปิด / เลิกปักหมุด
          onLongPress: () async {
            final box = context.findRenderObject() as RenderBox?;
            final at = _pinPressAt;
            final v = await showMenu<int>(
              context: context,
              position: RelativeRect.fromLTRB(at.dx + 12.0, at.dy, at.dx + 13.0,
                  (box?.size.height ?? 0) - at.dy),
              items: [
                PopupMenuItem(
                    value: 0,
                    child: Text('เปิดข้อมูลผู้ป่วย',
                        style: _t(12.0, weight: FontWeight.w600))),
                PopupMenuItem(
                    value: 1,
                    child: Text('เลิกปักหมุด',
                        style: _t(12.0, color: _red, weight: FontWeight.w600))),
              ],
            );
            if (v == 0) _openPatient(p);
            if (v == 1) _setPin(p.hn, false);
          },
          onTapDown: (d) => _pinPressAt = d.globalPosition,
          child: Tooltip(
            message: p.bed == null ? p.name : '${p.name} · ${p.bed}',
            child: SizedBox(
              width: 52.0,
              height: 56.0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 46.0,
                    height: 46.0,
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: ring, width: p.over ? 2.0 : 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _faceUrl(p.hn),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                          color: ring.withValues(alpha: 0.12),
                          alignment: Alignment.center,
                          child: Icon(Icons.person_rounded,
                              size: 20.0, color: ring),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: ring,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(p.bed ?? '—',
                          style: _num(9.5,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// หน้าต่างเลือกผู้ป่วยมาปักหมุด: ค้นชื่อ/HN/เตียง แตะเพื่อปักหรือเลิกปัก
  Future<void> _openPinPicker() async {
    var q = '';
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ปิด',
      barrierColor: Colors.black.withValues(alpha: 0.12),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(-0.04, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => StatefulBuilder(builder: (ctx, set) {
        final list = [
          for (final p in _patients)
            if (q.isEmpty ||
                p.name.contains(q) ||
                p.hn.contains(q) ||
                (p.bed ?? '').toLowerCase().contains(q.toLowerCase()))
              p
        ]..sort((a, b) => (a.esi?.level ?? 9).compareTo(b.esi?.level ?? 9));
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 76.0),
            child: Material(
              color: _panel,
              elevation: 12.0,
              shadowColor: const Color(0x330B1B3F),
              borderRadius: BorderRadius.circular(18.0),
              child: SizedBox(
                width: 340.0,
                height: MediaQuery.sizeOf(ctx).height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 8.0, 4.0),
                      child: Row(children: [
                        Expanded(
                          child: Text('ปักหมุดผู้ป่วย',
                              style: _t(15.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                        ),
                        Text('${_pinned.length} คน',
                            style: _t(10.5, color: _ink3)),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, size: 19.0),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
                      child: TextField(
                        autofocus: false,
                        onChanged: (v) => set(() => q = v.trim()),
                        style: _t(12.5),
                        decoration: InputDecoration(
                          isDense: true,
                          prefixIcon:
                              const Icon(Icons.search_rounded, size: 18.0),
                          hintText: 'ค้นชื่อ HN หรือเตียง',
                          hintStyle: _t(12.0, color: _ink3),
                          filled: true,
                          fillColor: _panelSoft,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final p = list[i];
                          final on = _pinned.contains(p.hn);
                          return _Press(
                            scale: 0.98,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                _setPin(p.hn, !on);
                                set(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 7.0),
                                child: Row(children: [
                                  _rowAvatar(p),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: _t(12.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w600)),
                                        Text(
                                            '${p.bed == null ? '' : '${p.bed} · '}${p.stage.label} · HN ${p.hn}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: _t(9.5, color: _ink3)),
                                      ],
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 160),
                                    transitionBuilder: (c, a) =>
                                        ScaleTransition(scale: a, child: c),
                                    child: Icon(
                                        key: ValueKey(on),
                                        on
                                            ? Icons.push_pin_rounded
                                            : Icons.push_pin_outlined,
                                        size: 19.0,
                                        color: on ? _blue : _ink3),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// ช่องเปล่าท้ายรายการ สำหรับปักหมุดผู้ป่วยเพิ่ม
  Widget _pinAdd() => Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openPinPicker,
          child: Container(
            width: 46.0,
            height: 46.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _line, width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, size: 18.0, color: _ink3),
          ),
        ),
      );
}
