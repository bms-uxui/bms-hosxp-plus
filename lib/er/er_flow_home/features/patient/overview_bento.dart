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
        Widget pair(Widget big, List<Widget> side, {int bigFlex = 3}) => wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          children: [
            _clyVitals(),
            const SizedBox(height: 10.0),
            pair(_clyCc(), [_bentoTasks(), _bentoXray(), _bentoDx()],
                bigFlex: 2),
            const SizedBox(height: 10.0),
            _clyLabs(),
            const SizedBox(height: 10.0),
            pair(_clyPlan(), [_bentoEmr(), _bentoProgress()]),
            const SizedBox(height: 10.0),
            _clyBanner(),
          ],
        );
      });

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

  /// X-ray / ภาพถ่ายล่าสุด (ความสำคัญข้างเตียง) · แตะ = แท็บภาพถ่าย
  Widget _bentoXray() {
    final imgs = _case.imaging;
    return _bentoTile(
      icon: Icons.image_rounded,
      title: 'X-ray / ภาพถ่าย',
      count: imgs.isEmpty ? '' : '${imgs.length}',
      onTap: () => setState(() => _detailTab = 7),
      child: imgs.isEmpty
          ? Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(11.0, color: _ink3))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(imgs.first.asset,
                    height: 96.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 96.0,
                        color: _panelSoft,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: _ink3))),
              ),
              const SizedBox(height: 6.0),
              Text(imgs.first.name,
                  style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
              Text(imgs.first.result,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(10.0, color: _ink2, height: 1.3)),
            ]),
    );
  }

  /// งานที่ต้องติดตาม: กาง = รายการงานให้ติ๊ก/ตั้งเตือน · หุบ = จำนวนค้าง + งานถัดไป
  Widget _bentoTasks() {
    final tasks = _sortTasks(_allTasks);
    final left = [
      for (final t in tasks)
        if (!_taskDone.contains(t.title)) t
    ];
    final header = Row(children: [
      const Icon(Icons.checklist_rounded, size: 15.0, color: Colors.white),
      const SizedBox(width: 6.0),
      Expanded(
        child: Text('งานที่ต้องติดตาม',
            style: _t(11.5, color: Colors.white, weight: FontWeight.w700)),
      ),
      if (_tasksOpen)
        Text('ค้าง ${left.length}',
            style: _num(11.0,
                color: const Color(0xE6FFFFFF), weight: FontWeight.w600)),
      AnimatedRotation(
        turns: _tasksOpen ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.expand_more_rounded,
            size: 18.0, color: Colors.white),
      ),
    ]);
    // สีเด่น (กรมท่า) เสมอ · แถวงานเป็นการ์ดขาวบนพื้นกรมท่า
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        gradient: _glossGrad(_blue),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: _glossLift(_blue),
      ),
      foregroundDecoration: const _InnerGloss(12.0, dark: true),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // แตะหัวเพื่อกาง/หุบ
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _tasksOpen = !_tasksOpen),
          child: header,
        ),
        const SizedBox(height: 6.0),
        if (_tasksOpen) ...[
          for (var i = 0; i < tasks.length; i++)
            _todoRow(tasks[i], last: i == tasks.length - 1, pad: 6.0),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _detailTab = 3),
              child: Text('ดูในคำสั่งแพทย์ ›',
                  style:
                      _t(10.5, color: Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ] else
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${left.length}',
                style:
                    _num(28.0, color: Colors.white, weight: FontWeight.w600)),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                  left.isEmpty
                      ? 'ไม่มีงานค้าง'
                      : 'ถัดไป: ${left.first.title} · ${left.first.time}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(10.5,
                      color: const Color(0xE6FFFFFF), weight: FontWeight.w600)),
            ),
          ]),
      ]),
    );
  }

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
