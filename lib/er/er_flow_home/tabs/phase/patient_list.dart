// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

extension _TabsPhasePatientListPart on _ErFlowHomeWidgetState {
  /// รูปผู้ป่วยในรายชื่อแผงซ้าย: วงสี ESI และป้ายเลขระดับที่มุมล่าง
  /// ยังไม่คัดกรอง = วงเทา ป้าย "?"
  Widget _rowAvatar(_P p) {
    final esi = p.esi;
    // วงรอบรูปเป็นขาวจางทุกคน สี ESI เหลือแค่ป้ายเลขที่มุม (ลดสีในแผง)
    const ring = _lpLine;
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            padding: const EdgeInsets.all(2.0),
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
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded,
                      size: 18.0, color: _ink3),
                ),
              ),
            ),
          ),
          // เคส fast track: สายฟ้าซ้อนหลังเลข ESI แบบ stacked avatar
          if (_ftOf(p.hn).isNotEmpty)
            Positioned(
              right: 10.0,
              bottom: -6.0,
              child: Tooltip(
                message: [
                  for (final id in _ftOf(p.hn).keys)
                    erFastTrackById(id)?.name ?? id
                ].join(' + '),
                child: const _FtBolt(),
              ),
            ),
          Positioned(
            // ดันออกนอกขอบรูปมากขึ้น ไม่บังหน้า
            right: -6.0,
            bottom: -6.0,
            child: Tooltip(
              message: esi == null ? 'ยังไม่คัดกรอง' : esi.en,
              child: Container(
                width: 22.0,
                height: 22.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esi == null ? _g5 : esi.hue,
                  border: Border.all(color: _blue, width: 1.5),
                ),
                child: Text(esi == null ? '?' : '${esi.level}',
                    style: _num(12.0,
                        color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// แถวรายชื่อผู้ป่วยในแผงซ้าย (Google list บนพื้นกรมท่า)
  ///
  /// แถวแบนไม่มีการ์ด คั่นด้วยเส้นจาง · แตะแล้วมี ripple เต็มแถว มุมโค้ง
  /// คนที่เปิดดูอยู่ = พื้นขาวจาง · เกินเกณฑ์ = เวลาเป็นแดงอ่อน (ผิดปกติเท่านั้นที่แดง)
  Widget _personRow(_P p, {bool first = false}) {
    final limit = _limitFor(p.stage, p.esi);
    final sel = _open != null && _sceneSelected(_open!).hn == p.hn;
    // เวลาเป็นขาวทุกแถว · เกินเกณฑ์บอกด้วยป้ายเล็กใต้เวลาเท่านั้น
    const timeCol = _lpInk;
    final sub = 'HN ${p.hn}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!first) const Divider(height: 1.0, thickness: 1.0, color: _lpLine),
      Material(
        color: sel ? const Color(0x1FFFFFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: const Color(0x29FFFFFF),
          highlightColor: const Color(0x14FFFFFF),
          // รอคัดกรองยังไม่มี ESI = เปิดหน้าคัดกรอง
          // อื่น ๆ = ไปที่เตียงของคนนี้ในผังเตียง (กล้องเลื่อนไป) ไม่เปิดหน้ารายละเอียด
          // เปิดรายละเอียดจากปุ่ม "ดูข้อมูล" ในการ์ดใต้ผังเตียง
          onTap: () {
            if (p.stage == _Stage.triage && p.esi == null) {
              _openTriage(p);
              return;
            }
            HapticFeedback.selectionClick();
            setState(() => _sceneHn = p.hn);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 10.0, 12.0),
            child: Row(children: [
              _rowAvatar(p),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.5,
                                color: _lpInk, weight: FontWeight.w600)),
                      ),
                      if (p.bed != null) ...[
                        const SizedBox(width: 8.0),
                        // เตียง = ชิปเล็กขอบจาง
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(color: _lpLine),
                          ),
                          child: Text(p.bed!,
                              style: _num(12.0,
                                  color: _lpInk, weight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3.0),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _t(12.0, color: _lpInk2, weight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      // ป้ายสีขาวเดียวกันทุกแถว (ไม่แดงเมื่อเกินเกณฑ์ · ผู้ใช้ 2026-10-14)
                      limit == 0 && p.over ? 'ต้องพบแพทย์ทันที' : 'อยู่ใน ER',
                      style: _t(11.0, color: _lpInk2, weight: FontWeight.w500)),
                  const SizedBox(height: 1.0),
                  Text(_hm(p.waitMin),
                      style:
                          _num(14.0, color: timeCol, weight: FontWeight.w600)),
                ],
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

/// วงสายฟ้า fast track บนรูปในรายชื่อ: idle เป็นรอบ ๆ
/// สายฟ้าเด้ง + ส่าย + สว่างวาบ และวงคลื่นแดงกระจายออก แล้วพัก
/// พักด้วย Timer ไม่มี ticker ค้าง · ไม่อยู่บนจอ (TickerMode ปิด) = ข้ามรอบ
class _FtBolt extends StatefulWidget {
  const _FtBolt();

  @override
  State<_FtBolt> createState() => _FtBoltState();
}

class _FtBoltState extends State<_FtBolt> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  Timer? _wait;

  @override
  void initState() {
    super.initState();
    _rest(const Duration(milliseconds: 600));
  }

  void _rest([Duration d = const Duration(milliseconds: 3600)]) {
    _wait = Timer(d, () {
      if (!mounted) return;
      if (!TickerMode.valuesOf(context).enabled) return _rest();
      _c.forward(from: 0.0).whenComplete(() {
        if (mounted) _rest();
      });
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final up = math.sin(math.pi * const Interval(0.0, 0.5).transform(t));
          final wave = const Interval(0.1, 1.0).transform(t);
          return SizedBox(
            width: 22.0,
            height: 22.0,
            child: Stack(clipBehavior: Clip.none, children: [
              // วงคลื่นกระจายออกจากวง
              if (t > 0.0 && t < 1.0)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.0 + 0.8 * wave,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _ftRed.withValues(alpha: 0.7 * (1 - wave)),
                            width: 2.0),
                      ),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ftRed,
                  border: Border.all(color: _blue, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 0.35 * math.sin(math.pi * 3 * t) * (1 - t),
                  child: Transform.scale(
                    scale: 1.0 + 0.3 * up,
                    child: Icon(Icons.bolt_rounded,
                        size: 15.0,
                        color: Color.lerp(
                            const Color(0xFFFDD663), Colors.white, 0.7 * up)),
                  ),
                ),
              ),
            ]),
          );
        },
      );
}
