// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

extension _TabsPhasePatientListPart on _ErFlowHomeWidgetState {
  /// รูปผู้ป่วยในรายชื่อแผงซ้าย: วงสี ESI และป้ายเลขระดับที่มุมล่าง
  /// ยังไม่คัดกรอง = วงเทา ป้าย "?"
  Widget _rowAvatar(_P p) {
    final esi = p.esi;
    final ring = esi == null ? _lpInk3 : _onLight(esi.color);
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2.0),
            ),
            child: ClipOval(
              child: Image.asset(
                _faceUrl(p.hn),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: _panelSoft,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded,
                      size: 18.0, color: _ink3),
                ),
              ),
            ),
          ),
          Positioned(
            right: -2.0,
            bottom: -2.0,
            child: Tooltip(
              message: esi == null
                  ? 'ยังไม่คัดกรอง'
                  : 'ESI ${esi.level} · ${esi.label}',
              child: Container(
                width: 18.0,
                height: 18.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esi == null ? _g5 : esi.hue,
                  border: Border.all(color: _blue, width: 1.5),
                ),
                child: Text(esi == null ? '?' : '${esi.level}',
                    style: _num(10.0,
                        color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ภาพหุ่น 3D จาก BodyParts3D (เรนเดอร์ไว้ใน assets/images/bodymap)
  /// อวัยวะ/กระดูก = ภาพที่ชิ้นนั้นเป็นสีแดง
  /// โซนอาการไม่ระบุตำแหน่ง = ภาพฐานกึ่งกลางที่โซน + heatmap วาดทับ
  Widget _bodyMapThumb(ErBodyTarget? t) {
    if (t == null) {
      return Center(
        child: Text('ไม่ระบุตำแหน่ง',
            textAlign: TextAlign.center, style: _t(9.0, color: _ink3)),
      );
    }
    final file = switch (t.kind) {
      ErBodyKind.organ => t.id,
      ErBodyKind.bone => 'bone_${t.id}',
      ErBodyKind.zone => 'zone_${t.id}',
    };
    final img = Image.asset('assets/images/bodymap/$file.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const SizedBox.shrink());
    if (t.kind != ErBodyKind.zone) return img;
    return LayoutBuilder(builder: (context, c) {
      // ภาพฐานสูง 560 มม. จริง รัศมีโซนจึงแปลงเป็นพิกเซลตามสัดส่วนนี้
      final r = (erZoneRadiusMm[t.id] ?? 90.0) / 560.0 * c.maxHeight;
      return Stack(fit: StackFit.expand, children: [
        img,
        Center(
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0xD9E1190F),
                Color(0xB3EE501C),
                Color(0x61FAB432),
                Color(0x00FCDC5A),
              ], stops: [
                0.0,
                0.3,
                0.62,
                1.0
              ]),
            ),
          ),
        ),
      ]);
    });
  }

  /// รูปผู้ป่วยบนพื้นขาว วงสี ESI (แบบเดียวกับรายชื่อแต่คนละพื้น)
  Widget _rowAvatarLight(_P p) {
    final ring = p.esi?.hue ?? _g5;
    return Container(
      width: 30.0,
      height: 30.0,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          _faceUrl(p.hn),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: _panelSoft,
            child: const Icon(Icons.person_rounded, size: 16.0, color: _ink3),
          ),
        ),
      ),
    );
  }

  /// แถวรายชื่อผู้ป่วยในแผงซ้าย
  ///
  /// คั่นด้วยเส้น ไม่ใช่การ์ดแยกใบ — ภาษาเดียวกับหน้าแก้ไขเวลาเข้า-ออกงาน
  /// ตาไล่ลงมาทีละคอลัมน์ได้รวดเดียว ไม่ต้องข้ามขอบการ์ดทุกแถว
  /// แถวที่เกินเกณฑ์ไม่ลงพื้นสีและไม่มีแถบซ้าย บอกด้วยตัวเลขเวลาสีแดงอย่างเดียว
  Widget _personRow(_P p) {
    final limit = _limitFor(p.stage, p.esi);
    return _Press(
        scale: 0.98,
        child: InkWell(
          onTap: () => _openPatient(p),
          child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _lpLine)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // คอลัมน์ 1 รูปผู้ป่วย วงสีตามระดับความเร่งด่วน + ป้ายเลข ESI
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _rowAvatar(p),
                  ),
                  // คอลัมน์ 2 ชื่อ · HN และอาการ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(13.0,
                                      color: _lpInk, weight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8.0),
                            if (p.bed != null) ...[
                              const Icon(Icons.bed_rounded,
                                  size: 13.0, color: _lpInk3),
                              const SizedBox(width: 3.0),
                              Text(p.bed!,
                                  style: _num(11.5,
                                      color: _lpInk2, weight: FontWeight.w600)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                            p.note.isEmpty
                                ? 'HN ${p.hn}'
                                : 'HN ${p.hn} · ${p.note}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(10.5, color: _lpInk2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // คอลัมน์ 3 เวลาที่อยู่ในขั้นนี้
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // เวลาที่อยู่ในขั้นนี้ · เกินเกณฑ์ = ตัวเลขแดง
                      Text(
                          limit == 0 && p.over
                              ? 'ต้องพบแพทย์ทันที'
                              : 'อยู่ในขั้นตอนมา',
                          style: _t(9.5,
                              color: p.over ? _onLight(_red) : _lpInk3)),
                      Text(_hm(p.waitMin),
                          style: _num(13.5,
                              color: p.over ? _onLight(_red) : _lpInk,
                              weight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
