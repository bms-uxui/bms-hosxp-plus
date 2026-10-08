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
            if (_aovOn) ...[
              _aiOverview(),
              const SizedBox(height: 10.0),
            ],
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
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
          decoration: dark
              ? BoxDecoration(
                  gradient: _glossGrad(_blue),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: _glossLift(_blue),
                )
              : _clyCardDeco,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(icon, size: 18.0, color: dark ? Colors.white : _blue),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(title,
                      style: _t(15.0, color: fg, weight: FontWeight.w600)),
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

    // แพทย์ผู้สั่ง (ไม่ซ้ำ ตามลำดับที่พบ) เป็นบรรทัดรองใต้หัวการ์ด
    final doctors = <String>[
      for (final t in tasks)
        if (t.by.isNotEmpty) t.by
    ].toSet().toList();
    final band = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('คำสั่งแพทย์',
                style: _t(17.0,
                    color: allDone ? _green : _inkTitle,
                    weight: FontWeight.w700)),
            if (doctors.isNotEmpty) ...[
              const SizedBox(height: 2.0),
              Text(doctors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
            ],
          ]),
        ),
        // เว้นที่ให้ภาพแฟ้ม (วาดแยกด้านหลังการ์ดคำสั่ง)
        const SizedBox(width: 92.0),
      ]),
    );

    // Google style (แบบ Google Tasks): รายการที่ต้องทำก่อน · เสร็จแล้วรวมเป็นกลุ่มท้าย
    // ไม่มีลายจุด/ป้ายสี · แถวเรียบ มีเส้นคั่นบาง
    final doneList = [
      for (final t in tasks)
        if (_taskDone.contains(t.title)) t
    ];
    final sheet =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final t in left) _taskCheckRow(t),
      if (doneList.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 16.0, 4.0),
          child: Text('เสร็จแล้ว ${doneList.length} รายการ',
              style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
        ),
        for (final t in doneList) _taskCheckRow(t),
      ],
      const SizedBox(height: 4.0),
      // ท้ายการ์ด: ลิงก์ข้อความสีฟ้าแบบ Google
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: TextButton(
            onPressed: () => setState(() => _detailTab = 3),
            child: Text('ดูทั้งหมดในคำสั่งแพทย์',
                style: _t(12.5, color: _blue, weight: FontWeight.w600)),
          ),
        ),
      ),
    ]);

    // การ์ดขาวขอบเทาแบบหน้าคัดกรอง (หัวไม่ใช่แถบกรมท่าทึบ)
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // ภาพแฟ้มหนีบกระดาษใหญ่ เอียงแบบ perspective อยู่หลังการ์ดงาน
        // ปลายล่างจมใต้การ์ดงานใบแรก (แบบรูป hero หน้าส่งตรวจ)
        Positioned(
          right: 18.0,
          top: 8.0,
          width: 80.0,
          height: 93.0,
          // เข้าฉาก + วน: แฟ้มโผล่ขึ้นครั้งเดียว แล้วเช็ก/ข้อความวาดเข้าซ้ำเป็นรอบ
          child: const _ClipboardHero(),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          band,
          sheet,
        ]),
      ]),
    );
  }

  String _taskClock(DateTime d) => _clock(
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');

  /// แถวงาน: ชื่องาน · เวลาสั่ง/รอบวัด · ปุ่ม "รับคำสั่ง" ขวาสุด (ไม่มีปุ่มเตือน/ตรวจซ้ำ)
  /// เสร็จแล้ว = ชื่อสีจาง + ใครทำ/เวลาเสร็จ + ป้ายเขียว "เสร็จแล้ว"
  /// compact = แถวเดียวเตี้ย (การ์ดในผังเตียง): ชื่อ 1 บรรทัด + เวลาต่อท้ายเล็ก วงติ๊กเล็ก
  Widget _taskCheckRow(_Task t, {bool compact = false}) {
    final done = _taskDone.contains(t.title);
    final at = _taskDoneAt[t.title];
    final rec = _taskRounds[_roundKey(t)];
    final partial = !done && rec != null && rec.isNotEmpty;
    // ไม่บอกผู้ทำในการ์ดนี้ (ดูได้ในแท็บคำสั่งแพทย์) เหลือแค่รอบ/เวลา
    final meta = partial
        ? 'รอบ ${rec.length} เสร็จ ${_taskClock(rec.last.$2)}'
        : done
            ? 'เสร็จ${at == null ? '' : ' ${_taskClock(at)}'}'
            : t.detail.startsWith('รอบที่')
                ? 'วัด ${_clock(t.time)} ${t.detail}'
                : 'สั่ง ${_clock(t.time)}';
    final metaColor = done ? _ink3 : _ink2;
    // แต่ละคำสั่งอยู่ในการ์ดพื้น surface (เทาฟ้าอ่อน) มุมโค้ง 12
    // แตะได้ทั้งการ์ด = รับคำสั่ง (ยังไม่เสร็จ)
    return _Press(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: done ? null : () => _taskAcceptSheet(t),
            child: Container(
              margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, compact ? 6.0 : 8.0),
              padding: compact
                  ? const EdgeInsets.fromLTRB(12.0, 6.0, 4.0, 6.0)
                  : const EdgeInsets.fromLTRB(14.0, 8.0, 6.0, 8.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.title,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: _t(13.0,
                                  // ชื่อสีปกติ · ด่วนบอกด้วย chip แดงเล็กท้ายบรรทัดรอง (แดงไม่ท่วมแถว)
                                  color: done ? _ink3 : _inkTitle,
                                  weight:
                                      done ? FontWeight.w500 : FontWeight.w600,
                                  height: 1.25)
                              .copyWith(
                                  decoration:
                                      done ? TextDecoration.lineThrough : null,
                                  decorationColor: _ink3)),
                      SizedBox(height: compact ? 0.0 : 2.0),
                      Row(children: [
                        Flexible(
                          child: Text(meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0,
                                  color: metaColor, weight: FontWeight.w500)),
                        ),
                        // ด่วน = ไฟไซเรน 3D (ErSiren3D ชุดเดียวกับปุ่มส่ง RESUS) แทน chip
                        if (!done && t.urgent) ...[
                          const SizedBox(width: 6.0),
                          // ขยายโมเดลเต็มกล่อง (ค่าตั้งต้น 0.63 เผื่อที่ว่างรอบตัว)
                          const SizedBox(
                              width: 24.0,
                              height: 18.0,
                              child: ErSiren3D(
                                  pose: (-0.13, -1.98, -0.2, 1.15),
                                  glow: false)),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // ขวา: วงติ๊กแทนปุ่ม · แตะวงว่าง = รับคำสั่ง (กดค้างยืนยัน) · เสร็จ = เช็กเขียว
                IgnorePointer(
                  child: GestureDetector(
                    child: SizedBox(
                      width: compact ? 30.0 : 40.0,
                      height: compact ? 30.0 : 40.0,
                      child: Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: compact ? 20.0 : 26.0,
                          color: done ? _green : _ink3),
                    ),
                  ),
                ),
              ]),
            )));
  }

  /// รับคำสั่ง: อธิบายว่าจะบันทึกอะไร แล้วเลื่อน "ทำเสร็จ" เพื่อยืนยัน
  void _taskAcceptSheet(_Task t) {
    final name = _taskDoer;
    final now = DateTime.now();
    // ครบแล้ว = ค้าง sheet ไว้ แถบหัวไล่สีเขียว + confetti แล้วค่อยปิด
    var celebrate = false;
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
    _placedSheet<void>(
      context: context,
      // bottom sheet กว้างไม่เกิน 580 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 580.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final rounds = _taskRoundInfo(t);
        final round = rounds == null
            ? null
            : ((rounds.cur + 1).clamp(1, rounds.n), rounds.n);
        final onDark = celebrate;
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
                Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: rounds == null ? 184.0 : 206.0,
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(children: [
                      // ไล่สีเขียวจากซ้ายไปขวาเมื่อทำครบ
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: celebrate ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeInOutCubic,
                          builder: (context, v, _) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: v,
                              heightFactor: 1.0,
                              child: const ColoredBox(color: _green),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/order_accept.png',
                              height: 172.0, fit: BoxFit.contain),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 20.0, 20.0, 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // บรรทัดบน: หัวข้อซ้าย · สั่งเมื่อ มุมขวาบน
                                  Row(children: [
                                    Text(
                                        celebrate
                                            ? 'ทำครบแล้ว'
                                            : 'รับคำสั่งแพทย์',
                                        style: _t(12.0,
                                            color:
                                                onDark ? Colors.white : _ink2,
                                            weight: FontWeight.w600)),
                                    const Spacer(),
                                    Icon(Icons.schedule_rounded,
                                        size: 13.0,
                                        color: onDark ? Colors.white70 : _ink3),
                                    const SizedBox(width: 3.0),
                                    Text(ago,
                                        style: _t(11.0,
                                            color:
                                                onDark ? Colors.white70 : _ink2,
                                            weight: FontWeight.w500)),
                                  ]),
                                  const SizedBox(height: 4.0),
                                  Text(t.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(19.0,
                                          color: onDark
                                              ? Colors.white
                                              : (t.urgent ? _red : _inkTitle),
                                          weight: FontWeight.w700,
                                          height: 1.2)),
                                  // รอบปัจจุบันเป็นข้อความใต้ชื่อคำสั่ง
                                  if (round != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                          celebrate
                                              ? 'ครบ ${round.$2} รอบ'
                                              : 'รอบที่ ${round.$1} จาก ${round.$2}',
                                          style: _t(12.0,
                                              color:
                                                  onDark ? Colors.white : _ink2,
                                              weight: FontWeight.w600)),
                                    ),
                                  // timeline เฉพาะคำสั่งที่ต้องทำซ้ำหลายรอบ
                                  if (round != null) ...[
                                    const Spacer(),
                                    _orderSteps(rounds!, onDark: onDark),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  // confetti พุ่งจากกลางแถบหัวเมื่อทำครบ
                  if (celebrate)
                    const Positioned.fill(
                      child: IgnorePointer(child: _Confetti()),
                    ),
                ]),
                const SizedBox(height: 18.0),
                // หัวข้อซ้าย · คำอธิบายชิดขวาในแถวเดียวกัน
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('ข้อมูลที่จะถูกบันทึก',
                      style:
                          _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                        'กดค้างจนเต็ม ระบบจะบันทึกชื่อและเวลาที่รับคำสั่ง',
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
                      line('เวลา', '${_taskClock(now)} (เวลาจริงตอนกดยืนยัน)'),
                      if (t.by.isNotEmpty)
                        line('ผู้สั่ง', '${t.by} เวลา ${_clock(t.time)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),
                _SlideConfirm(
                  label: 'กดค้างเพื่อรับคำสั่ง',
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
                    final finished = _taskDone.contains(t.title);
                    void close() {
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      _taskNotice(
                          'บันทึกแล้ว $label โดย $name ${_taskClock(at)}');
                    }

                    if (!finished) {
                      close();
                      return;
                    }
                    // ทำครบ: ค้างหน้าไว้ ไล่เขียว + confetti แล้วปิดเอง
                    setSheet(() => celebrate = true);
                    HapticFeedback.heavyImpact();
                    Future.delayed(const Duration(milliseconds: 2000), close);
                  },
                ),
              ],
            ),
          ),
        );
      }),
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
      ({int n, int cur, List<(String, DateTime)?> done, bool own}) r,
      {bool onDark = false}) {
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
          border:
              onDark && ok ? Border.all(color: Colors.white, width: 2.0) : null,
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
          // รอบนี้ = ชื่อผู้ใช้ + เวลาตอนนี้ (สิ่งที่จะถูกบันทึกเมื่อกดค้างยืนยัน)
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
                    size: 11.0,
                    color:
                        onDark ? Colors.white : (i == r.cur ? _blue : _ink3)),
                const SizedBox(width: 2.0),
              ],
              Flexible(
                child: Text(lines[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.0,
                        color: onDark
                            ? Colors.white
                            : (d != null || i == r.cur ? _inkTitle : _ink3),
                        weight: i == r.cur ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2)),
              ),
            ]),
            if (lines[1].isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (d != null || i == r.cur) ...[
                  Icon(Icons.schedule_rounded,
                      size: 10.0, color: onDark ? Colors.white70 : _ink3),
                  const SizedBox(width: 2.0),
                ],
                Text(lines[1],
                    style: _num(9.5,
                            color: onDark ? Colors.white70 : _ink3,
                            weight: FontWeight.w500)
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
                color: onDark
                    ? Colors.white
                    : r.done[i - 1] != null
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

/// แฟ้มหนีบกระดาษแบบ 2D flat (สี Google): แผ่นรองฟ้า · กระดาษขาว · ตัวหนีบเหลือง
/// บนกระดาษมีเช็กเขียว 2 บรรทัด + บรรทัดเทาว่าง (คำสั่งที่ยังไม่ทำ)
/// แฟ้มหนีบกระดาษบนการ์ดคำสั่งแพทย์: โผล่ขึ้น (ครั้งแรก) แล้ววนรอบ
/// เช็กและข้อความวาดเข้าทีละแถว ค้างไว้ จางหาย แล้ววาดใหม่
class _ClipboardHero extends StatefulWidget {
  const _ClipboardHero();

  @override
  State<_ClipboardHero> createState() => _ClipboardHeroState();
}

class _ClipboardHeroState extends State<_ClipboardHero>
    with TickerProviderStateMixin {
  // หนึ่งรอบ 11.8 วิ: appear 1.8 วิ (แฟ้มโผล่ + เช็ก/ข้อความวาด) · idle 10 วิ
  // (มุมกระดาษพับลงแล้วคลี่ระหว่าง idle) · แล้ววนกลับ appear ใหม่
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 5800))
    ..repeat();
  late final AnimationController _loop = AnimationController(vsync: this);

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_in, _loop]),
      builder: (context, _) {
        // ไม่มี idle ยาว: จบท่าพับแล้วออก แล้ววนเข้าใหม่ทันที
        const total = 5.8, appear = 1.8;
        final sec = _in.value * total;
        final t = (sec / appear).clamp(0.0, 1.0);
        // appear: 0–0.45 แฟ้มโผล่ · 0.4–1 เช็ก/ข้อความวาดทีละแถว
        final e = Curves.easeOutBack
            .transform(const Interval(0.0, 0.45).transform(t));
        final reveal = const Interval(0.4, 1.0).transform(t);
        // idle: พับมุม + ดึง 3 จังหวะ · ก่อนวนใหม่จางออก 0.4 วิสุดท้าย
        double fold = 0.0;
        // พับลงครั้งเดียว (2.2–2.6) → ค้างแล้วดึงเบา ๆ 3 จังหวะ (2.6–4.1) → คลี่กลับ (4.1–4.5)
        if (sec > 2.2 && sec < 4.5) {
          fold = sec < 2.6
              ? Curves.easeOutCubic.transform((sec - 2.2) / 0.4)
              : sec < 4.1
                  ? 1.0 + 0.12 * math.sin(((sec - 2.6) % 0.5) / 0.5 * math.pi)
                  : 1.0 - Curves.easeInOutCubic.transform((sec - 4.1) / 0.4);
        }
        // ออกก่อนวนใหม่ (สะท้อนท่าเข้า): เช็ก/ข้อความหดกลับ 0.5 วิ แล้วแฟ้มจมลง
        // หมุนเอียงไปท่าเริ่มต้นเดียวกับตอนเข้า 0.6 วิ → รอบใหม่ต่อได้ไม่สะดุด
        final erase = ((sec - (total - 1.1)) / 0.5).clamp(0.0, 1.0);
        final sink = Curves.easeInCubic
            .transform(((sec - (total - 0.6)) / 0.6).clamp(0.0, 1.0));
        final pos = sink > 0 ? 1.0 - sink : e;
        final shown = erase > 0 ? reveal * (1.0 - erase) : reveal;
        return Opacity(
          opacity: const Interval(0.0, 0.2).transform(t) *
              (1.0 - const Interval(0.5, 1.0).transform(sink)),
          child: Transform.translate(
            offset: Offset(0.0, 40.0 * (1.0 - pos)),
            child: Transform.rotate(
              angle: -0.35 * (1.0 - pos),
              // ซ้อนหลายชั้นตามแกนลึก (z) = เห็นสันหนาของแผ่นรองและปึกกระดาษ
              child: Stack(fit: StackFit.expand, children: [
                for (var i = 6; i >= 1; i--)
                  Transform(
                    alignment: Alignment.center,
                    transform: _clipTilt(-i * 1.2),
                    child: CustomPaint(painter: _ClipArt(layer: 1)),
                  ),
                for (var i = 3; i >= 1; i--)
                  Transform(
                    alignment: Alignment.center,
                    transform: _clipTilt(i * 0.9),
                    child: CustomPaint(painter: _ClipArt(layer: 2)),
                  ),
                Transform(
                  alignment: Alignment.center,
                  transform: _clipTilt(3.6),
                  child:
                      CustomPaint(painter: _ClipArt(reveal: shown, fold: fold)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// มุมเอียงของแฟ้ม (perspective) เลื่อนตามแกนลึก z ก่อนหมุน
Matrix4 _clipTilt(double z) => Matrix4.identity()
  ..setEntry(3, 2, 0.0022)
  ..rotateX(0.28)
  ..rotateY(-0.42)
  ..rotateZ(0.12)
  ..translate(0.0, 0.0, z);

class _ClipArt extends CustomPainter {
  /// 0 = หน้าเต็ม · 1 = สันแผ่นรอง · 2 = ขอบปึกกระดาษ
  const _ClipArt(
      {this.layer = 0, this.reveal = 1.0, this.fold = 0.0, this.fade = 1.0});
  final int layer;

  /// ความทึบของเช็ก/ข้อความ (สงวนไว้)
  final double fade;

  /// 0..1 มุมบนขวาของกระดาษพับลง (idle)
  final double fold;

  /// 0..1 เช็กและเส้นข้อความบนกระดาษวาดเข้าทีละแถว (appear)
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final board = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.1, w * 0.84, h * 0.88),
        Radius.circular(w * 0.12));
    if (layer == 1) {
      canvas.drawRRect(board, Paint()..color = const Color(0xFF1A5BC4));
      return;
    }
    canvas.drawRRect(board, Paint()..color = const Color(0xFF4285F4));
    // กระดาษ
    final paper = RRect.fromRectAndRadius(
        // ขอบแผ่นรองบาง: กระดาษกินพื้นที่เกือบเต็มแผ่นรอง
        Rect.fromLTWH(
            w * 0.13, h * 0.14, w * 0.74, h * 0.80), // ขอบบนแตะใต้คลิปหนีบพอดี
        Radius.circular(w * 0.07));
    if (layer == 2) {
      canvas.drawRRect(paper, Paint()..color = const Color(0xFFE3E7EE));
      return;
    }
    canvas.drawRRect(paper, Paint()..color = Colors.white);
    // มุมพับบนขวา: ตัดมุมกระดาษ (เห็นแผ่นรองฟ้า) + แผ่นพับเทาอ่อนพร้อมเงา
    if (fold > 0.001) {
      final r = paper.outerRect;
      final d = w * 0.17 * fold;
      final tr = r.topRight;
      canvas.drawPath(
          Path()
            ..moveTo(tr.dx - d, tr.dy)
            ..lineTo(tr.dx, tr.dy)
            ..lineTo(tr.dx, tr.dy + d)
            ..close(),
          Paint()..color = const Color(0xFF4285F4));
      final flap = Path()
        ..moveTo(tr.dx - d, tr.dy)
        ..lineTo(tr.dx - d, tr.dy + d)
        ..lineTo(tr.dx, tr.dy + d)
        ..close();
      canvas.drawPath(
          flap.shift(Offset(-w * 0.012, h * 0.012)),
          Paint()
            ..color = const Color(0x33000000)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
      canvas.drawPath(flap, Paint()..color = const Color(0xFFE8EAED));
    }
    // บรรทัด: เช็กเขียว 2 บรรทัดบน · วงเทาบรรทัดล่าง
    final check = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = Paint()
      ..color = const Color(0xFFDADCE0)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    // แต่ละแถวเริ่มห่างกัน: เช็กลากเส้นเข้า แล้วเส้นข้อความยืดออกตาม
    Path part(Path p, double k) {
      if (k <= 0) return Path();
      final out = Path();
      for (final m in p.computeMetrics()) {
        out.addPath(
            m.extractPath(0, m.length * k.clamp(0.0, 1.0)), Offset.zero);
      }
      return out;
    }

    for (var i = 0; i < 3; i++) {
      final y = h * (0.34 + i * 0.15);
      final x0 = w * 0.28;
      final k = ((reveal - i * 0.22) / 0.45).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final kc = (k / 0.45).clamp(0.0, 1.0);
      final kl = ((k - 0.35) / 0.65).clamp(0.0, 1.0);
      if (i < 2) {
        canvas.drawPath(
            part(
                Path()
                  ..moveTo(x0, y)
                  ..lineTo(x0 + w * 0.05, y + h * 0.04)
                  ..lineTo(x0 + w * 0.13, y - h * 0.04),
                kc),
            check);
      } else {
        canvas.drawCircle(
            Offset(x0 + w * 0.06, y),
            w * 0.05 * Curves.easeOutBack.transform(kc),
            Paint()
              ..color = const Color(0xFFDADCE0)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.035);
      }
      if (kl > 0) {
        final xs = x0 + w * 0.2, xe = w * 0.68;
        canvas.drawLine(Offset(xs, y), Offset(xs + (xe - xs) * kl, y), line);
      }
    }
    // ตัวหนีบเหลือง + ห่วง
    final clip = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.04, w * 0.4, h * 0.14),
        Radius.circular(w * 0.05));
    canvas.drawRRect(clip, Paint()..color = const Color(0xFFFBBC04));
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.06,
        Paint()..color = const Color(0xFFFBBC04));
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.06), w * 0.025, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ClipArt old) =>
      old.layer != layer || old.reveal != reveal || old.fold != fold;
}

/// ปุ่มกดค้างยืนยัน: กดค้าง 1.2 วิ พื้นเขียวกระจายจากกลาง ครบ = ยืนยัน · ปล่อยก่อน = ถอยกลับ
/// (ชื่อเดิม _SlideConfirm คงไว้ ผู้เรียกไม่ต้องแก้)
class _SlideConfirm extends StatefulWidget {
  const _SlideConfirm(
      {required this.label, required this.style, required this.onDone});

  final String label;
  final TextStyle style;
  final VoidCallback onDone;

  @override
  State<_SlideConfirm> createState() => _SlideConfirmState();
}

class _SlideConfirmState extends State<_SlideConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..addStatusListener((st) {
      if (st == AnimationStatus.completed && !_fired) {
        _fired = true;
        HapticFeedback.heavyImpact();
        widget.onDone();
      }
    });
  bool _fired = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    if (_fired) return;
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _up() {
    if (_fired) return;
    _c.animateBack(0.0, duration: const Duration(milliseconds: 220));
  }

  @override
  Widget build(BuildContext context) {
    const h = 56.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          final done = _fired || v >= 1.0;
          Widget label(Color c) =>
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(done ? Icons.check_rounded : Icons.touch_app_rounded,
                    size: 20.0, color: c),
                const SizedBox(width: 8.0),
                Text(done ? 'เสร็จแล้ว' : widget.label,
                    style: widget.style.copyWith(color: c)),
              ]);
          return Container(
            height: h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFE8ECF5),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Stack(children: [
              // พื้นเขียวกระจายออกจากกลางปุ่มไปสองข้างตามเวลาที่กดค้าง
              Center(
                child: FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
              // ข้อความสองชั้น: กรมท่าบนพื้นเทา · ขาวเฉพาะช่วงที่เขียวทับ (ไม่ขาดครึ่งตัว)
              Center(child: label(widget.style.color!)),
              ClipRect(
                clipper: _CenterClip(v),
                child: Center(child: label(Colors.white)),
              ),
            ]),
          );
        },
      ),
    );
  }
}

/// ตัดให้เห็นช่วงกลางกว้าง k (0..1) ของความกว้าง
class _CenterClip extends CustomClipper<Rect> {
  const _CenterClip(this.k);
  final double k;

  @override
  Rect getClip(Size size) => Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * k,
      height: size.height);

  @override
  bool shouldReclip(_CenterClip old) => old.k != k;
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

/// confetti พุ่งขึ้นจากกลางล่างแล้วตกตามแรงโน้มถ่วง หมุนและจางลง (1.8 วิ)
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..forward();
  final _bits = List.generate(70, (i) {
    final r = math.Random(i * 7919);
    final ang = -math.pi / 2 + (r.nextDouble() - 0.5) * 2.2;
    final sp = 260.0 + r.nextDouble() * 320.0;
    return (
      vx: math.cos(ang) * sp,
      vy: math.sin(ang) * sp,
      spin: (r.nextDouble() - 0.5) * 14.0,
      w: 5.0 + r.nextDouble() * 5.0,
      h: 3.0 + r.nextDouble() * 4.0,
      color: const [
        Color(0xFFFFC53D),
        Color(0xFF4ADE80),
        Colors.white,
        Color(0xFF60A5FA),
        Color(0xFFF472B6),
      ][i % 5],
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter(_c, _bits), size: Size.infinite);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.bits) : super(repaint: anim);

  final Animation<double> anim;
  final List<
      ({
        double vx,
        double vy,
        double spin,
        double w,
        double h,
        Color color
      })> bits;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 1.8; // วินาที
    const g = 620.0;
    final o = Offset(size.width * 0.62, size.height * 0.85);
    final fade = (1.0 - (anim.value - 0.7) / 0.3).clamp(0.0, 1.0);
    final p = Paint();
    for (final b in bits) {
      final x = o.dx + b.vx * t;
      final y = o.dy + b.vy * t + 0.5 * g * t * t;
      p.color = b.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(b.spin * t);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
