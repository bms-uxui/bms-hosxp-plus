// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ แท็บภาพรวมแบบ bento
// ขนาดช่องตามความสำคัญข้างเตียง: V/S เต็มแถว · CC/HPI ใหญ่ + ช่องเล็ก
// (งานติดตาม · X-ray · วินิจฉัย) · Lab เต็มแถว · แผน + ทางลัด EMR/Progress note

extension _FeaturesPatientOverviewBentoPart on _ErFlowHomeWidgetState {
  /// เรียงผล lab อัตโนมัติ: ผิดปกติก่อน → ตัวเลขปกติ → ข้อความ → รูป
  /// (คงลำดับเดิมในกลุ่มเดียวกัน) · eGFR อยู่หัวเสมอเมื่อเปิด profile ไต
  List<ErLab> _sortLabs(List<ErLab> labs) {
    int rank(ErLab l) => l.name == 'eGFR'
        ? -1
        : l.abnormal
            ? 0
            : l.isNumeric
                ? 1
                : (l.type == ErLabType.image ? 3 : 2);
    return [
      for (final r in [-1, 0, 1, 2, 3])
        for (final l in labs)
          if (rank(l) == r) l
    ];
  }

  /// แผงขวาของแท็บภาพรวม · แคบกว่า 560 = คอลัมน์เดียว
  Widget _clyBento() => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 640.0;
        // fill: การ์ดใหญ่สูงเต็มเท่าคอลัมน์ข้าง (IntrinsicHeight + stretch)
        Widget pair(Widget big, List<Widget> side,
                {int bigFlex = 3, bool fill = false}) =>
            wide
                ? _bentoRow(fill, [
                    Expanded(flex: bigFlex, child: big),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 2,
                      child: Column(children: [
                        for (var i = 0; i < side.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10.0),
                          side[i],
                        ],
                      ]),
                    ),
                  ])
                : Column(children: [
                    big,
                    for (final s in side) ...[const SizedBox(height: 10.0), s],
                  ]);
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: _appearAll([
            _clyVitals(),
            const SizedBox(height: 10.0),
            pair(_clyCc(), [_bentoTasks(), _bentoXray(), _bentoDx()],
                bigFlex: 2, fill: true),
            const SizedBox(height: 10.0),
            _clyLabs(),
            const SizedBox(height: 10.0),
            // ไม่มีแผนการดูแลและแถบขั้นถัดไป (ผู้ใช้ให้เอาออก) · EMR คู่ Progress note
            wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _bentoEmr()),
                    const SizedBox(width: 10.0),
                    Expanded(child: _bentoProgress()),
                  ])
                : Column(children: [
                    _bentoEmr(),
                    const SizedBox(height: 10.0),
                    _bentoProgress(),
                  ]),
          ]),
        );
      });

  Widget _bentoRow(bool fill, List<Widget> children) => fill
      ? IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children))
      : Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);

  /// ช่อง bento มาตรฐาน: หัว (ไอคอน · ชื่อ · ตัวนับ ›) + เนื้อหา · แตะเพื่อไปแท็บเต็ม
  Widget _bentoTile({
    required IconData icon,
    required String title,
    String count = '',
    required Widget child,
    VoidCallback? onTap,
    bool dark = false,
  }) {
    final fg = dark ? Colors.white : _inkTitle;
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 12.0),
          decoration: dark
              ? BoxDecoration(
                  gradient: _glossGrad(_blue),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: _glossLift(_blue),
                )
              : _clyCardDeco,
          foregroundDecoration: _InnerGloss(12.0, dark: dark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(icon, size: 15.0, color: dark ? Colors.white : _blue),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(title,
                      style: _t(11.5, color: fg, weight: FontWeight.w700)),
                ),
                if (count.isNotEmpty)
                  Text(count,
                      style: _num(11.0,
                          color: dark ? Colors.white : _ink3,
                          weight: FontWeight.w600)),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 16.0, color: dark ? Colors.white : _ink3),
              ]),
              const SizedBox(height: 8.0),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// X-ray: แกลเลอรีสูงสุด 3 ภาพ · แตะภาพ = ดูเต็มจอ · แตะหัว = แท็บ X-ray
  Widget _bentoXray() {
    final imgs = _case.imaging;
    final show = imgs.take(3).toList();
    Widget thumb(int i) => _Press(
          child: GestureDetector(
            onTap: () => _xrayView(imgs, i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(show[i].asset,
                      height: 72.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 72.0,
                          color: _panelSoft,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: _ink3))),
                ),
                const SizedBox(height: 4.0),
                Text(show[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
                Text(show[i].result,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5, color: _ink2)),
              ],
            ),
          ),
        );
    return _bentoTile(
      icon: Icons.image_rounded,
      title: 'X-ray',
      count: imgs.isEmpty ? '' : '${imgs.length}',
      onTap: () => setState(() => _detailTab = _xrayTab),
      child: imgs.isEmpty
          ? Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(11.0, color: _ink3))
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6.0),
                // ช่องว่างคงที่ 3 ช่อง ภาพน้อยกว่า 3 ก็ขนาดเท่าเดิม
                Expanded(child: i < show.length ? thumb(i) : const SizedBox()),
              ],
            ]),
    );
  }

  /// งานที่ต้องติดตาม แบบ to-do: แถบกรมท่าด้านบน (ชื่อซ้าย วันที่ขวา) แผ่นขาวซ้อนทับ
  /// แถว = ช่องติ๊ก · ชื่องาน · เวลาสั่ง/รอบวัด · ปุ่มเตือน
  Widget _bentoTasks() {
    final tasks = _sortTasks(_allTasks, inPlace: true);
    final left = [
      for (final t in tasks)
        if (!_taskDone.contains(t.title)) t
    ];
    final allDone = tasks.isNotEmpty && left.isEmpty;
    final now = DateTime.now();
    const days = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final date = 'วัน${days[now.weekday - 1]} ${now.day} '
        '${months[now.month - 1]} ${now.year + 543}';

    final band = Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 9.0, 16.0, 9.0),
      child: Row(children: [
        Text('คำสั่งแพทย์',
            style: _t(12.0, color: Colors.white, weight: FontWeight.w700)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _t(11.0,
                  color: const Color(0xCCFFFFFF), weight: FontWeight.w500)),
        ),
      ]),
    );

    final sheet = Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: const _DotGridPainter(),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 6.0),
          for (final t in tasks) _taskCheckRow(t),
          // ท้ายการ์ด: เส้นคั่น + ทางไปคำสั่งแพทย์ (ตำแหน่ง "Add a note" ของต้นแบบ)
          const Divider(height: 1.0, thickness: 1.0, color: _line),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _detailTab = 3),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Text('ดูในคำสั่งแพทย์ ›',
                  style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: allDone ? _green : _blue,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        band,
        // มุมโค้งบนของแผ่นขาวเผยสีแถบวันที่ด้านหลัง
        sheet,
      ]),
    );
  }

  String _taskClock(DateTime d) => _clock(
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');

  /// แถวงาน: ชื่องาน · เวลาสั่ง/รอบวัด · ปุ่ม "รับคำสั่ง" ขวาสุด (ไม่มีปุ่มเตือน/ตรวจซ้ำ)
  /// เสร็จแล้ว = ชื่อสีจาง + ใครทำ/เวลาเสร็จ + ป้ายเขียว "เสร็จแล้ว"
  Widget _taskCheckRow(_Task t) {
    final done = _taskDone.contains(t.title);
    final at = _taskDoneAt[t.title];
    final rec = _taskRounds[_roundKey(t)];
    final partial = !done && rec != null && rec.isNotEmpty;
    final meta = partial
        ? 'รอบ ${rec.length} เสร็จ ${_taskClock(rec.last.$2)} โดย ${rec.last.$1}'
        : done
            ? 'เสร็จ${at == null ? '' : ' ${_taskClock(at)}'}'
                '${_taskDoneBy[t.title] == null ? '' : ' โดย ${_taskDoneBy[t.title]}'}'
            : t.detail.startsWith('รอบที่')
                ? 'วัด ${_clock(t.time)} ${t.detail}'
                : 'สั่ง ${_clock(t.time)}';
    final metaColor = done ? _ink3 : (t.urgent ? _red : _blue);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 7.0, 14.0, 7.0),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0,
                      color: done ? _ink3 : (t.urgent ? _red : _inkTitle),
                      weight: FontWeight.w600,
                      height: 1.25)),
              const SizedBox(height: 3.0),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(done ? Icons.check_rounded : Icons.schedule_rounded,
                    size: 13.0, color: metaColor),
                const SizedBox(width: 3.0),
                Flexible(
                  child: Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(10.5, color: metaColor, weight: FontWeight.w600)),
                ),
                if (!done && t.urgent) ...[
                  const SizedBox(width: 10.0),
                  const Icon(Icons.priority_high_rounded,
                      size: 13.0, color: _red),
                  Text('ด่วน',
                      style: _t(10.5, color: _red, weight: FontWeight.w700)),
                ],
              ]),
            ],
          ),
        ),
        if (!done) ...[
          const SizedBox(width: 6.0),
          _Press(
            child: GestureDetector(
              onTap: () => _taskAcceptSheet(t),
              child: Container(
                height: 30.0,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: _blue, width: 1.2),
                ),
                child: Text('รับคำสั่ง',
                    style: _t(11.0, color: _blue, weight: FontWeight.w700)),
              ),
            ),
          ),
        ] else
          Container(
            height: 26.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text('เสร็จแล้ว',
                style: _t(10.5, color: _green, weight: FontWeight.w700)),
          ),
      ]),
    );
  }

  /// รับคำสั่ง: อธิบายว่าจะบันทึกอะไร แล้วเลื่อน "ทำเสร็จ" เพื่อยืนยัน
  void _taskAcceptSheet(_Task t) {
    final name = _taskDoer;
    final now = DateTime.now();
    final rounds = _taskRoundInfo(t);
    final round = rounds == null ? null : (rounds.cur + 1, rounds.n);
    final hm = t.time.split(':');
    final ordered = hm.length == 2
        ? DateTime(now.year, now.month, now.day, int.tryParse(hm[0]) ?? 0,
            int.tryParse(hm[1]) ?? 0)
        : null;
    final mins = ordered == null ? null : now.difference(ordered).inMinutes;
    final ago = mins == null || mins < 0
        ? 'สั่งเมื่อ ${_clock(t.time)}'
        : mins < 60
            ? 'สั่งเมื่อ $mins นาทีที่ผ่านมา'
            : 'สั่งเมื่อ ${mins ~/ 60} ชม. ${mins % 60} นาทีที่ผ่านมา';
    showModalBottomSheet<void>(
      context: context,
      // bottom sheet กว้างไม่เกิน 580 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 580.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) {
        // หัวข้อชิดซ้าย · ค่าชิดขวา (ไม่มีไอคอน)
        Widget line(String k, String v, {bool first = false}) => Padding(
              padding: EdgeInsets.only(top: first ? 0.0 : 8.0),
              child: Row(children: [
                Text(k, style: _t(12.0, color: _ink3)),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(v,
                      textAlign: TextAlign.right,
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
                ),
              ]),
            );
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // แถบหัวตาม Figma (HOSXP V6 ER 322:1006): ภาพประกอบซ้าย ·
                // รับคำสั่งแพทย์ · ชื่องาน + ป้ายรอบ · สั่งเมื่อกี่นาที · ลำดับขั้นเป็นวงกลม
                Container(
                  height: rounds == null ? 184.0 : 206.0,
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/order_accept.png',
                          height: 172.0, fit: BoxFit.contain),
                      const SizedBox(width: 18.0),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // บรรทัดบน: หัวข้อซ้าย · สั่งเมื่อ มุมขวาบน
                              Row(children: [
                                Text('รับคำสั่งแพทย์',
                                    style: _t(12.0,
                                        color: _ink2, weight: FontWeight.w600)),
                                const Spacer(),
                                const Icon(Icons.schedule_rounded,
                                    size: 13.0, color: _ink3),
                                const SizedBox(width: 3.0),
                                Text(ago,
                                    style: _t(11.0,
                                        color: _ink2, weight: FontWeight.w500)),
                              ]),
                              const SizedBox(height: 4.0),
                              Text(t.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(19.0,
                                      color: t.urgent ? _red : _inkTitle,
                                      weight: FontWeight.w700,
                                      height: 1.2)),
                              // รอบปัจจุบันเป็นข้อความใต้ชื่อคำสั่ง
                              if (round != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                      'รอบที่ ${round.$1} จาก ${round.$2}',
                                      style: _t(12.0,
                                          color: _ink2,
                                          weight: FontWeight.w600)),
                                ),
                              // timeline เฉพาะคำสั่งที่ต้องทำซ้ำหลายรอบ
                              if (round != null) ...[
                                const Spacer(),
                                _orderSteps(rounds!),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),
                // หัวข้อซ้าย · คำอธิบายชิดขวาในแถวเดียวกัน
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('ข้อมูลที่จะถูกบันทึก',
                      style:
                          _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                        'เมื่อเลื่อน "ทำเสร็จ" ระบบจะบันทึกชื่อและเวลาที่ทำเสร็จ',
                        textAlign: TextAlign.right,
                        style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line('ชื่อผู้ทำ', name, first: true),
                      line('เวลา', '${_taskClock(now)} (เวลาจริงตอนเลื่อน)'),
                      if (t.by.isNotEmpty)
                        line('ผู้สั่ง', '${t.by} เวลา ${_clock(t.time)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),
                _SlideConfirm(
                  label: 'เลื่อนเพื่อทำเสร็จ',
                  style: _t(13.0, color: _blue, weight: FontWeight.w700),
                  onDone: () {
                    final at = DateTime.now();
                    // ×N: บันทึกรอบนี้ · ครบทุกรอบแล้วค่อยนับว่าคำสั่งเสร็จ
                    final multi = rounds != null && rounds.own;
                    var label = t.title;
                    if (multi) {
                      final recs =
                          _taskRounds.putIfAbsent(_roundKey(t), () => []);
                      setState(() => recs.add((name, at)));
                      label = '${t.title} รอบ ${recs.length}/${rounds.n}';
                      if (recs.length >= rounds.n &&
                          !_taskDone.contains(t.title)) {
                        _taskToggle(t);
                      }
                    } else if (!_taskDone.contains(t.title)) {
                      _taskToggle(t);
                    }
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    _taskNotice(
                        'บันทึกแล้ว $label โดย $name ${_taskClock(at)}');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ข้อมูลรอบของคำสั่งที่ทำซ้ำ: n รอบ · รอบปัจจุบัน (0-based) · ใครทำ/เมื่อไรของแต่ละรอบ
  /// own = บันทึกรอบในคำสั่งนี้เอง (×N) · ไม่ใช่ = แต่ละรอบเป็นงานแยก ("รอบที่ i/n")
  ({int n, int cur, List<(String, DateTime)?> done, bool own})? _taskRoundInfo(
      _Task t) {
    final rm = RegExp(r'รอบที่\s*(\d+)\s*/\s*(\d+)').firstMatch(t.detail);
    if (rm != null) {
      final i = int.parse(rm.group(1)!), n = int.parse(rm.group(2)!);
      // รอบอื่นคืองานชื่อเดียวกัน (ก่อนวงเล็บเวลา) ที่ detail เป็น "รอบที่ k/n"
      final base = t.title.split(' (').first;
      final done = <(String, DateTime)?>[
        for (var k = 1; k <= n; k++)
          () {
            for (final o in _allTasks) {
              if (o.title.split(' (').first == base &&
                  o.detail.startsWith('รอบที่ $k/$n') &&
                  _taskDone.contains(o.title)) {
                final at = _taskDoneAt[o.title];
                return at == null ? null : (_taskDoneBy[o.title] ?? '', at);
              }
            }
            return null;
          }(),
      ];
      return (n: n, cur: (i - 1).clamp(0, n - 1), done: done, own: false);
    }
    final xm = RegExp(r'[×x]\s*(\d+)\s*$').firstMatch(t.title);
    final n = xm == null ? 0 : int.parse(xm.group(1)!);
    if (n < 2) return null;
    final recs = _taskRounds[_roundKey(t)] ?? const [];
    return (
      n: n,
      cur: recs.length.clamp(0, n),
      done: [for (var k = 0; k < n; k++) k < recs.length ? recs[k] : null],
      own: true,
    );
  }

  /// timeline รอบของคำสั่งที่ต้องทำซ้ำ (Figma): วงละรอบ ต่อด้วยเส้น
  /// รอบที่ทำแล้ว = เขียว + ใครทำ เมื่อไร · รอบนี้ = กรมท่า · รอบถัดไป = ขาว
  Widget _orderSteps(
      ({int n, int cur, List<(String, DateTime)?> done, bool own}) r) {
    final n = r.n.clamp(1, 12);
    String short(String who) => who.split(' ').take(2).join(' ');
    // จังหวะปรากฏ: วงถัดไปช้ากว่ากัน 140ms (เส้นเชื่อมขึ้นระหว่างวง)
    const step = 140;
    Widget dot(int i) {
      final ok = r.done[i] != null;
      // รอบนี้ = วงเส้นประกรมท่า + นาฬิกา (ยังไม่ทำ ไม่ถม)
      if (!ok && i == r.cur) {
        return SizedBox(
          width: 36.0,
          height: 36.0,
          child: CustomPaint(
            painter: const _DashRing(_blue),
            child: const Icon(Icons.schedule_rounded, size: 18.0, color: _blue),
          ),
        );
      }
      return Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ok ? _green : _panel,
        ),
        // เครื่องหมายถูกเด้งขึ้นหลังวงปรากฏ
        child: ok
            ? _PopIn(
                delay: Duration(milliseconds: 180 + step * 2 * i + 160),
                child: const Icon(Icons.check_rounded,
                    size: 18.0, color: Colors.white),
              )
            : null,
      );
    }

    Widget label(int i) {
      final d = r.done[i];
      final lines = d != null
          ? [short(d.$1), _taskClock(d.$2)]
          // รอบนี้ = ชื่อผู้ใช้ + เวลาตอนนี้ (สิ่งที่จะถูกบันทึกเมื่อเลื่อนทำเสร็จ)
          : i == r.cur
              ? [short(_taskDoer), _taskClock(DateTime.now())]
              : ['รอบ ${i + 1}', 'ยังไม่ทำ'];
      return SizedBox(
        height: 30.0,
        child: OverflowBox(
          maxWidth: 110.0,
          maxHeight: 30.0,
          // ไอคอนคน = ผู้ทำ · นาฬิกา = เวลา (รอบที่ยังไม่ถึงไม่มีไอคอน)
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (d != null || i == r.cur) ...[
                Icon(Icons.person_rounded,
                    size: 11.0, color: i == r.cur ? _blue : _ink3),
                const SizedBox(width: 2.0),
              ],
              Flexible(
                child: Text(lines[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.0,
                        color: d != null || i == r.cur ? _inkTitle : _ink3,
                        weight: i == r.cur ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2)),
              ),
            ]),
            if (lines[1].isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (d != null || i == r.cur) ...[
                  const Icon(Icons.schedule_rounded, size: 10.0, color: _ink3),
                  const SizedBox(width: 2.0),
                ],
                Text(lines[1],
                    style: _num(9.5, color: _ink3, weight: FontWeight.w500)
                        .copyWith(height: 1.2)),
              ]),
          ]),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < n; i++) ...[
        if (i > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 17.0),
              // เส้นเชื่อมยืดจากซ้ายไปขวาก่อนวงถัดไปจะขึ้น
              child: _GrowLine(
                delay: Duration(milliseconds: 180 + step * (2 * i - 1)),
                color: r.done[i - 1] != null
                    ? _green.withValues(alpha: 0.6)
                    : _panel,
              ),
            ),
          ),
        SizedBox(
          width: 36.0,
          child: _PopIn(
            delay: Duration(milliseconds: 180 + step * 2 * i),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              dot(i),
              const SizedBox(height: 4.0),
              label(i),
            ]),
          ),
        ),
      ],
    ]);
  }

  void _taskNotice(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  /// วินิจฉัย (สูงสุด 3 รายการ) พร้อมรหัส ICD-10
  Widget _bentoDx() {
    // รุนแรงก่อน: critical → urgent → normal (คงลำดับเดิมในระดับเดียวกัน)
    final dx = [
      for (final lv in ErLevel.values)
        for (final d in _case.dx)
          if (d.level == lv) d
    ];
    return _bentoTile(
      icon: Icons.assignment_rounded,
      title: 'วินิจฉัย',
      count: dx.isEmpty ? '' : '${dx.length}',
      child: dx.isEmpty
          ? Text('ยังไม่มีการวินิจฉัย', style: _t(11.0, color: _ink3))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final d in dx.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6.0,
                          height: 6.0,
                          margin: const EdgeInsets.only(top: 5.0, right: 6.0),
                          decoration: BoxDecoration(
                              color: _levelColor(d.level),
                              shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(d.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0,
                                  color: _inkTitle,
                                  weight: FontWeight.w600,
                                  height: 1.3)),
                        ),
                        if (d.icd10 != null)
                          Text(d.icd10!,
                              style: _num(10.0,
                                  color: _ink3, weight: FontWeight.w600)),
                      ]),
                ),
            ]),
    );
  }

  /// ทางลัด EMR: จำนวน visit + CC ครั้งก่อน
  Widget _bentoEmr() {
    final hv = erHpiVisits(_case);
    final prev = hv.length > 1 ? hv[1] : null;
    return _bentoTile(
      icon: Icons.folder_shared_rounded,
      title: 'EMR',
      count: '${hv.length} visit',
      onTap: () => setState(() => _detailTab = 9),
      child: Text(
          prev == null
              ? 'ไม่มีประวัติ visit ก่อนหน้า'
              : '${prev.date} · ${prev.cc}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _t(10.5, color: _ink2, weight: FontWeight.w600, height: 1.3)),
    );
  }

  /// ทางลัด Progress note: ข้อความล่าสุด หรือชวนเริ่มเขียน
  Widget _bentoProgress() {
    final text = _progress[_case.hn]?.text.trim() ?? '';
    return _bentoTile(
      icon: Icons.edit_note_rounded,
      title: 'Progress note',
      onTap: () => setState(() => _detailTab = 10),
      child: Text(text.isEmpty ? 'ยังไม่ได้เขียน' : text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: _t(10.5,
              color: text.isEmpty ? _ink3 : _ink,
              weight: FontWeight.w500,
              height: 1.35)),
    );
  }
}

/// ลายจุดจาง ๆ บนแผ่นงาน (แบบกระดาษโน้ตของต้นแบบ)
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x140B1B3F);
    const step = 16.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.9, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

/// ปุ่มเลื่อนยืนยัน: ลากวงกลมไปสุดขวา (≥ 85%) = ยืนยัน · ปล่อยก่อน = เด้งกลับ
class _SlideConfirm extends StatefulWidget {
  const _SlideConfirm(
      {required this.label, required this.style, required this.onDone});

  final String label;
  final TextStyle style;
  final VoidCallback onDone;

  @override
  State<_SlideConfirm> createState() => _SlideConfirmState();
}

class _SlideConfirmState extends State<_SlideConfirm> {
  double _x = 0.0;
  bool _fired = false;

  @override
  Widget build(BuildContext context) {
    const h = 56.0, knob = 48.0, pad = 4.0;
    return LayoutBuilder(builder: (context, box) {
      final max = box.maxWidth - knob - pad * 2;
      final v = max <= 0 ? 0.0 : (_x / max).clamp(0.0, 1.0);
      return Container(
        height: h,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFE8ECF5), _green, v)!,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Stack(children: [
          Center(
            child: Opacity(
              opacity: 1.0 - v,
              child: Text(widget.label, style: widget.style),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: _x == 0.0 ? 220 : 0),
            curve: Curves.easeOutCubic,
            left: pad + _x,
            top: pad,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                if (_fired) return;
                setState(() => _x = (_x + d.delta.dx).clamp(0.0, max));
              },
              onHorizontalDragEnd: (_) {
                if (_fired) return;
                if (_x >= max * 0.85) {
                  setState(() {
                    _x = max;
                    _fired = true;
                  });
                  widget.onDone();
                } else {
                  setState(() => _x = 0.0);
                }
              },
              child: Container(
                width: knob,
                height: knob,
                decoration: BoxDecoration(
                  color: v >= 0.85 ? Colors.white : _blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    v >= 0.85
                        ? Icons.check_rounded
                        : Icons.keyboard_double_arrow_right_rounded,
                    color: v >= 0.85 ? _green : Colors.white,
                    size: 24.0),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

/// วงเส้นประรอบวงกลม (รอบที่กำลังจะทำ)
class _DashRing extends CustomPainter {
  const _DashRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 1.2;
    final c = size.center(Offset.zero);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const dashes = 14;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep,
          sweep * 0.55, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashRing old) => old.color != color;
}

/// ปรากฏหลังหน่วงเวลา: ขยายจาก 0.4 แบบเด้ง (elasticOut) + จาง
class _PopIn extends StatefulWidget {
  const _PopIn({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Opacity(
          opacity: Curves.easeOut.transform((_c.value * 2.0).clamp(0.0, 1.0)),
          child: Transform.scale(
            scale: 0.4 + 0.6 * Curves.elasticOut.transform(_c.value),
            child: child,
          ),
        ),
        child: widget.child,
      );
}

/// เส้นเชื่อมยืดจากซ้ายไปขวาหลังหน่วงเวลา
class _GrowLine extends StatefulWidget {
  const _GrowLine({required this.delay, required this.color});

  final Duration delay;
  final Color color;

  @override
  State<_GrowLine> createState() => _GrowLineState();
}

class _GrowLineState extends State<_GrowLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: Curves.easeOutCubic.transform(_c.value),
            child: Container(height: 2.0, color: widget.color),
          ),
        ),
      );
}
