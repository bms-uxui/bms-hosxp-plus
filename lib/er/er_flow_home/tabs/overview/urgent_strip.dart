// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsOverviewUrgentStripState on State<ErFlowHomeWidget> {
  /// แถบล่างของหน้าภาพรวม ชุดเดียวกับหน้าผังเตียง: ค้นหา + การ์ดเตียง
  final ScrollController _footScroll = ScrollController();
  final String _footQuery = '';
  _FootSort _footSort = _FootSort.esi;
}

extension _TabsOverviewUrgentStripPart on _ErFlowHomeWidgetState {
  /// ฉากอาคารแผนกสามมิติ สี่ปีกคือสี่ขั้นของกระแสงาน โถงกลางคือที่นั่งรอ
  /// ไอคอนกับตัวเลขเป็นวิดเจ็ตของ Flutter ที่ลอยตามตำแหน่งปีกซึ่งฝั่งสามมิติ
  /// คำนวณส่งกลับมา ข้อความไทยจึงคมเท่าส่วนอื่นของหน้า
  // ------------------------------------------------- แถบรายชื่อเร่งด่วน
  /// ผู้ป่วยทั้งห้องเรียงตามความเร่งด่วน กรองด้วยคำค้นในแถบล่าง
  ///
  /// เฉพาะผู้ป่วยที่มีเตียง · เรียงระดับ ESI ก่อน แล้วค่อยเวลารอมาก→น้อย
  List<_P> get _footFiltered {
    final q = _footQuery.trim().toLowerCase();
    final list = _patients.where((p) {
      // หน้าภาพรวมแสดงเฉพาะผู้ป่วยที่ได้เตียงแล้ว
      if (p.bed == null) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.hn.contains(q) ||
          (p.bed ?? '').toLowerCase().contains(q) ||
          p.note.toLowerCase().contains(q) ||
          (p.esi?.label ?? 'ยังไม่คัดกรอง').contains(q) ||
          p.stage.label.contains(q);
    }).toList();
    list.sort((a, b) {
      switch (_footSort) {
        case _FootSort.esi:
          final ea = a.esi?.level ?? 9;
          final eb = b.esi?.level ?? 9;
          if (ea != eb) return ea.compareTo(eb);
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.wait:
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.bed:
          // มีเตียงมาก่อน เรียงรหัสเตียง แล้วคนไม่มีเตียงตามเวลารอ
          if (a.bed != null && b.bed != null) return a.bed!.compareTo(b.bed!);
          if (a.bed != null) return -1;
          if (b.bed != null) return 1;
          return b.waitMin.compareTo(a.waitMin);
      }
    });
    return list;
  }

  /// ตัวเลือกวิธีเรียงในแถบล่าง กดแล้วมีเมนูให้เลือก
  Widget _footSortPill() => _Press(
          child: PopupMenuButton<_FootSort>(
        tooltip: 'เรียงตาม',
        position: PopupMenuPosition.over,
        color: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: _line),
        ),
        onSelected: (v) => setState(() => _footSort = v),
        itemBuilder: (context) => [
          for (final o in _FootSort.values)
            PopupMenuItem(
              value: o,
              height: 38.0,
              child: Row(
                children: [
                  Icon(
                    o == _footSort
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16.0,
                    color: o == _footSort ? _blue : _ink3,
                  ),
                  const SizedBox(width: 8.0),
                  Text(o.label, style: _t(12.0)),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            gradient: _glossWhite,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: _line),
            boxShadow: _glossLift(const Color(0xFF0B1B3F)),
          ),
          foregroundDecoration: const _InnerGloss(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เรียงตาม ', style: _t(12.0, color: _ink2)),
              Text(_footSort.label, style: _t(12.0, weight: FontWeight.w600)),
              const SizedBox(width: 4.0),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 17.0, color: _ink2),
            ],
          ),
        ),
      ));

  /// สถานะเตียงแบบย่อ มุมขวาของแถบล่าง: เตียงที่ใช้ + จำนวนแต่ละระดับ

  /// การ์ดผู้ป่วยหนึ่งใบในแถบล่าง โครงเดียวกับการ์ดเตียงของหน้าผังเตียง
  ///
  /// ป้ายมุมซ้ายบนคือรหัสเตียง (ยังไม่ได้เตียง = ขีด) รูปเตียงจางเมื่อไม่มีเตียง
  /// รูปผู้ป่วยวงกลมในการ์ดแถบล่าง วงแหวนเป็นสี ESI
  Widget _footAvatar(_P p) {
    final color = p.esi?.color ?? _ink3;
    return Container(
      width: 46.0,
      height: 46.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _panelSoft,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2.0),
      ),
      child: ClipOval(
        child: Image.asset(
          _faceUrl(p.hn),
          width: 46.0,
          height: 46.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: _panelSoft,
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, size: 20.0, color: _ink3),
          ),
        ),
      ),
    );
  }

  /// หมายเลขคิว (QN) จำลองตามลำดับการมาถึง — รอต่อเลขคิวจริงของ HOSxP
  String _qn(_P p) => (_patients.indexWhere((x) => x.hn == p.hn) + 1)
      .toString()
      .padLeft(3, '0');

  Widget _footCard(_P p) {
    final color = p.esi?.color ?? _ink3;
    final on = p.hn == _sceneHn;
    return _Press(
        scale: 0.98,
        child: Container(
          width: 148.0,
          margin: const EdgeInsets.only(right: 10.0),
          clipBehavior: Clip.antiAlias,
          decoration: _clyCardDeco.copyWith(
            border:
                Border.all(color: on ? color : _line, width: on ? 2.0 : 1.0),
          ),
          foregroundDecoration: const _InnerGloss(12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() {
                _sceneHn = p.hn;
                _open = _Phase.of(p.stage);
              }),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ซ้าย = เวลาที่ค้าง · มุมขวา = QN + เตียง
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                              p.waitMin >= 60
                                  ? '${p.waitMin ~/ 60}:${(p.waitMin % 60).toString().padLeft(2, '0')} ชม.'
                                  : '${p.waitMin} นาที',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _num(10.5,
                                  color: p.over ? _red : _ink3,
                                  weight: FontWeight.w600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(color: _line),
                          ),
                          child: Text('QN ${_qn(p)}',
                              style: _num(10.0,
                                  color: _ink2, weight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 4.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(p.bed ?? '—',
                              style: _num(10.5,
                                  color: Colors.white,
                                  weight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    _footAvatar(p),
                    const SizedBox(height: 6.0),
                    Text(p.name,
                        style: _t(12.5, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (p.type != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: _typeBadge(p.type!),
                      )
                    else
                      Text(p.note.isEmpty ? p.stage.label : p.note,
                          style: _t(11.0, color: _ink2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  /// แถบล่างของหน้าภาพรวม ยกมาจากหน้าผังเตียง
  /// แถวบน: ตัวเรียง ช่องค้นหา สถานะเตียง · แถวล่าง: การ์ดผู้ป่วยเลื่อนแนวนอน
  /// ปุ่มเลื่อนแถวการ์ดผู้ป่วยในแถบล่าง ทีละราวสามใบ
  Widget _footScrollButton(IconData icon, int dir) => _Press(
          child: Material(
        color: _panelSoft,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!_footScroll.hasClients) return;
            final to = (_footScroll.offset + dir * 474.0)
                .clamp(0.0, _footScroll.position.maxScrollExtent);
            _footScroll.animateTo(to,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic);
          },
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: Icon(icon, size: 20.0, color: _ink2),
          ),
        ),
      ));

  Widget _urgentStrip() {
    final list = _footFiltered;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _footSortPill(),
              const SizedBox(width: 10.0),
              Text('${list.length} ราย', style: _t(11.0, color: _ink2)),
              const Spacer(),
              // ปุ่มเลื่อนแถวการ์ด อยู่ขวาสุดของแถบ
              _footScrollButton(Icons.chevron_left_rounded, -1),
              const SizedBox(width: 6.0),
              _footScrollButton(Icons.chevron_right_rounded, 1),
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            // ฟอนต์ไทยสูงกว่าฟอนต์ที่หน้าผังเตียงจูนไว้ เผื่ออีก 6px
            height: 144.0,
            child: _loading
                ? _Shimmer(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: _bone(148.0, 128.0, radius: 14.0),
                          ),
                      ],
                    ),
                  )
                : list.isEmpty
                    ? Center(
                        child: Text('ไม่มีผู้ป่วยในเงื่อนไขนี้',
                            style: _t(12.0, color: _ink3)),
                      )
                    : ListView.builder(
                        controller: _footScroll,
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, i) => _footCard(list[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
