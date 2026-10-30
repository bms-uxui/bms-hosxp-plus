// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ระบบใน log → ชื่อช่องในฟอร์มตรวจร่างกายของโหมดพูด (คอลัมน์ "ครั้งนี้")
const Map<String, String> _peField = {
  'pe_ga': 'GA',
  'pe_heent': 'HEENT',
  'pe_heart': 'Heart',
  'pe_chest': 'Chest',
  'pe_abd': 'Abdomen',
  'pe_ext': 'Extremities',
  'pe_neuro': 'Neurological',
};

// ขั้นตรวจร่างกายในโหมดพูด: _peStep (pe_templates.dart) ตามบทบาท

// สไตล์การ์ดหน้านี้: ขาวโปร่งลอยบนฉาก 3D มุมโค้งมาก (ไม่ใช้ blur เพราะทับ WebView)
final BoxDecoration _glass = BoxDecoration(
  color: Colors.white.withValues(alpha: 0.82),
  borderRadius: BorderRadius.circular(20.0),
  border: Border.all(color: Colors.white),
  boxShadow: const [
    BoxShadow(color: Color(0x140B1B3F), blurRadius: 24.0, offset: Offset(0, 8)),
  ],
);

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientExamTabState on State<ErFlowHomeWidget> {
  // ---- แท็บของแพทย์
  /// แท็บตรวจร่างกาย: 0 = ทบทวนระบบ (ROS) · 1 = ตรวจร่างกาย (PE)
  int _examMode = 1;

  /// รอบที่เลือกดู (null = ล่าสุด) และระบบที่เลือก (null = ภาพรวม)
  int? _examSel;
  String? _examSys;

  /// ไฮไลต์ขอบการ์ดประวัติการตรวจชั่วครู่ (เปิดมาจาก "ดูประวัติการตรวจร่างกาย")
  bool _examFlash = false;
  Timer? _examFlashT;
}

extension _FeaturesPatientExamTabPart on _ErFlowHomeWidgetState {
  /// แท็บตรวจร่างกายในการ์ดขวา: สลับ ROS/PE · รอบการตรวจ · เทียบครั้งก่อน · ระบบ · บันทึก
  /// แท็บตรวจร่างกาย = หน้า monitor ประวัติการตรวจ (บันทึกใหม่ทำใน workflow)
  /// สรุปล่าสุด · ตารางระบบ × ครั้งที่ตรวจ · ความเปลี่ยนแปลงของระบบที่เลือก
  Widget _examPage() {
    final rs = _examRounds;
    final systems = _examMode == 0 ? _rosSystems : _peSystems;
    final last = rs.isEmpty ? null : rs.last;
    return _clyInfoPage(
      'ตรวจร่างกาย',
      'ประวัติการทบทวนระบบและตรวจร่างกายทุกครั้ง',
      'exam',
      const [],
      by: last?.by,
      at: last == null ? null : _examTime(last.time),
      // ภาพแพทย์ฟังปอดผู้ป่วย (Figma 484:150) ยืนบนเส้นใต้ tab แบบหน้า EMR
      heroArt: const SizedBox(width: 210.0, height: 150.0, child: _ExamHero()),
      below: Transform.translate(
        offset: const Offset(-4.0, 0.0),
        child: _segmented(
            const ['ทบทวนระบบ (ROS)', 'ตรวจร่างกาย (PE)'],
            _examMode,
            (i) => setState(() {
                  _examMode = i;
                  _examSel = null;
                  _examSys = null;
                }),
            line: false),
      ),
      // ตารางระบบ × ครั้งที่ตรวจ เต็มความกว้าง · ช่องเป็นข้อความผลตรวจ อ่านได้โดยไม่ต้องแตะ
      extra: [
        _examGrid(systems, rs),
        // แท็บ PE: ภาพการตรวจร่างกาย (วาด/ปักบนหุ่นในขั้นตรวจร่างกาย) ใต้ตารางประวัติ
        if (_examMode == 1 && _peShotList.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          _peShotsCard(),
        ],
      ],
    );
  }

  /// การ์ดภาพการตรวจร่างกาย: แถวละภาพ (ใหม่สุดบน) คั่นเส้นบาง
  /// ภาพย่อซ้าย · ขวา = เวลา ผู้บันทึก แล้วรายการบริเวณที่ปัก + รายละเอียดของบริเวณนั้น
  /// รูปประกอบของบริเวณ: ภาพย่อ 44 เรียงแถว (เกิน 4 = +x บนภาพสุดท้าย)
  Widget _peAttachRow(List<Uint8List> list) =>
      Wrap(spacing: 6.0, runSpacing: 6.0, children: [
        for (final (k, b) in list.take(4).indexed)
          Container(
            width: 44.0,
            height: 44.0,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Stack(fit: StackFit.expand, children: [
              Image.memory(b, fit: BoxFit.cover, cacheWidth: 132),
              if (k == 3 && list.length > 4)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Text('+${list.length - 3}',
                        style: _t(13.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
      ]);

  Widget _peShotsCard() {
    final shots = _peShotList.reversed.toList();
    Widget row(_PeShot x) {
      // บริเวณที่ปักบนหุ่น (ไม่ซ้ำ ตามลำดับที่ปัก)
      final regions = <String>[
        for (final st in x.d3)
          if (st['region'] != null) '${st['region']}'
      ].toSet().toList();
      // สิ่งที่พบบนผิว (ภาพรุ่นก่อนที่เลือกชนิดไว้) + รายละเอียดที่พิมพ์ของบริเวณนั้น
      final skin = {
        for (final f in x.findings)
          if (f.$2 == 'skin' && f.$3.isNotEmpty) f.$4: f.$3
      };
      String? noteOf(String name) {
        final parts = [
          if (skin[name] != null) skin[name]!,
          for (final n in x.said)
            if (n.startsWith('$name:')) n.substring(name.length + 1).trim(),
        ].where((t) => t.isNotEmpty);
        return parts.isEmpty ? null : parts.join(' ');
      }

      // สิ่งที่พบใต้ผิว (กระดูก/อวัยวะ) จากการวิเคราะห์ภาพ
      final deep = [
        for (final f in x.findings)
          if (f.$2 != 'skin') f
      ];
      // แตะ = เปิดดู · ของตัวเองแก้ได้ ของคนอื่นดูอย่างเดียว
      final mine = x.by == (ErSession.instance.user?.name ?? '');
      // ภาพจากหุ่น 3D (studio): หัวแถว วันเวลา ผู้บันทึก + แก้ไข · ใต้ลงมาเป็นแถวต่อบริเวณ
      // แบบรายการใน studio: รูปแผล (หลายรูป = ซ้อน +x) ซ้าย · ชื่อ + รายละเอียดขวา · คั่นเส้นบาง
      if (regions.isNotEmpty) {
        Widget thumb(String r) {
          final l = x.attachBy[r] ?? const <Uint8List>[];
          if (l.length > 1) {
            return _photoStack(l, 48.0,
                _t(11.0, color: Colors.white, weight: FontWeight.w700));
          }
          return Container(
            width: 48.0,
            height: 48.0,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
            ),
            // ไม่ได้แนบรูป = ภาพซูมบริเวณนั้นบนหุ่น · ไม่มีทั้งคู่ = ไอคอนหมุด
            child: l.isNotEmpty
                ? Image.memory(l.first, fit: BoxFit.cover, cacheWidth: 144)
                : x.focusBy[r] != null
                    ? Image.memory(x.focusBy[r]!,
                        fit: BoxFit.cover, cacheWidth: 144)
                    : const Icon(Icons.location_on_outlined,
                        size: 22.0, color: _blue),
          );
        }

        // แผ่นแสดงอย่างเดียว: เข้าไปดู/แก้ด้วยปุ่ม "ดูรายละเอียด" ที่หัวการ์ด
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // หัวแผ่น: ชื่อแพทย์ (หัวข้อ) · วันเวลาที่บันทึก (รอง)
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(x.by.isEmpty ? 'ไม่ระบุผู้บันทึก' : x.by,
                          style: _t(13.5,
                              color: _inkTitle, weight: FontWeight.w700)),
                      if (x.at.isNotEmpty)
                        Text(_peStamp(x.at),
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
            ]),
            const SizedBox(height: 4.0),
            for (final (k, r) in regions.indexed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  border: k == 0
                      ? null
                      : const Border(
                          top:
                              BorderSide(color: Color(0xFFE8EAED), width: 0.5)),
                ),
                child: Row(children: [
                  SizedBox(
                    width: 56.0,
                    child:
                        Align(alignment: Alignment.centerLeft, child: thumb(r)),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_peName(r),
                              style: _t(13.5,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          if (noteOf(_peName(r)) case final n?
                              when n.isNotEmpty)
                            Text(n,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.5,
                                    color: _ink2,
                                    height: 1.35,
                                    weight: FontWeight.w500)),
                        ]),
                  ),
                ]),
              ),
            for (final f in deep)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text([f.$3, f.$4].where((t) => t.isNotEmpty).join(' '),
                    style: _t(13.0, color: _red, weight: FontWeight.w600)),
              ),
          ]),
        );
      }
      return _Press(
          child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => x.d3.isNotEmpty
            ? _peOpenStudio(x)
            : _peOpenDraw(x, at: _peShotList.indexOf(x)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _peThumb(x, 96.0),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        [
                          // วันที่ + เวลา ("19 ต.ค. 69 16:06 น.") · ค่าเก่าที่มีแต่เวลา = วันนี้
                          if (x.at.isNotEmpty) _peStamp(x.at),
                          if (x.by.isNotEmpty) x.by,
                        ].join('  '),
                        style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
                    const SizedBox(height: 6.0),
                    if (regions.isEmpty)
                      Text(x.name,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    // แต่ละบริเวณเป็นบล็อกเดียว: จุด + ชื่อ / รายละเอียด / รูปของบริเวณนั้น
                    // (ข้อความกับรูปชิดแนวเดียวกันใต้ชื่อ)
                    for (final (k, r) in regions.indexed)
                      Padding(
                        padding: EdgeInsets.only(top: k == 0 ? 0.0 : 12.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                margin:
                                    const EdgeInsets.only(top: 7.0, right: 8.0),
                                decoration: BoxDecoration(
                                    color: _red, shape: BoxShape.circle),
                              ),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_peName(r),
                                          style: _t(14.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w700)),
                                      if (noteOf(_peName(r)) case final n?
                                          when n.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Text(n,
                                              style: _t(13.5,
                                                  color: _ink2,
                                                  height: 1.35,
                                                  weight: FontWeight.w500)),
                                        ),
                                      if ((x.attachBy[r] ?? const <Uint8List>[])
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: _peAttachRow(x.attachBy[r]!),
                                        ),
                                    ]),
                              ),
                            ]),
                      ),
                    for (final f in deep)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                            [f.$3, f.$4].where((t) => t.isNotEmpty).join(' '),
                            style:
                                _t(13.0, color: _red, weight: FontWeight.w600)),
                      ),
                    // รูปประกอบ: ภาพย่อเรียงแถว (เกิน 4 = ป้าย +x บนภาพสุดท้าย)
                    if (x.attach.isNotEmpty && x.attachBy.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                          for (final (k, b) in x.attach.take(4).indexed)
                            Container(
                              width: 48.0,
                              height: 48.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: _panelSoft,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: const Color(0xFFDADCE0), width: 0.5),
                              ),
                              child: Stack(fit: StackFit.expand, children: [
                                Image.memory(b,
                                    fit: BoxFit.cover, cacheWidth: 144),
                                if (k == 3 && x.attach.length > 4)
                                  ColoredBox(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    child: Center(
                                      child: Text('+${x.attach.length - 3}',
                                          style: _t(13.0,
                                              color: Colors.white,
                                              weight: FontWeight.w700)),
                                    ),
                                  ),
                              ]),
                            ),
                        ]),
                      ),
                  ]),
            ),
            // สิทธิ์ + ลูกศรเข้าไปดู
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(mine ? 'แก้ไข' : 'ดู',
                  style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              const Icon(Icons.chevron_right_rounded, size: 20.0, color: _blue),
            ]),
          ]),
        ),
      ));
    }

    // แบบเดียวกับการ์ดประวัติ: หัวข้อ + คำอธิบาย แล้วแผ่นในขาวขอบบาง แถวคั่นเส้นบาง
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
      decoration: _clyCardDeco.copyWith(
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ภาพการตรวจร่างกาย',
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 2.0),
                    Text('${shots.length} ภาพ',
                        style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
            // ปุ่มเข้าไปดู/แก้ไข มุมขวาหัวการ์ด: เปิดภาพล่าสุดของตัวเอง (ไม่มี = เริ่มใหม่)
            Tooltip(
              message: 'ดูรายละเอียดภาพตรวจร่างกาย',
              child: _Press(
                child: GestureDetector(
                  onTap: () {
                    final me = ErSession.instance.user?.name ?? '';
                    final own = _peShotList
                        .where((x) => x.d3.isNotEmpty && x.by == me)
                        .toList();
                    _peOpenStudio(own.isEmpty ? null : own.last);
                  },
                  child: Container(
                    height: 36.0,
                    padding: const EdgeInsets.fromLTRB(14.0, 0.0, 8.0, 0.0),
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('ดูรายละเอียด',
                          style:
                              _t(13.0, color: _blue, weight: FontWeight.w600)),
                      const Icon(Icons.chevron_right_rounded,
                          size: 20.0, color: _blue),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
        // ภาพละแผ่น (แยกตามผู้บันทึก/ครั้ง) เว้นระยะ 8
        for (final (i, x) in shots.indexed)
          Container(
            margin: EdgeInsets.only(top: i == 0 ? 0.0 : 8.0),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: row(x),
          ),
      ]),
    );
  }

  /// ไปแท็บตรวจร่างกาย (PE) แล้วไฮไลต์ขอบการ์ดประวัติการตรวจ 2.5 วิ ค่อยจาง
  void _showPeHistory({bool ros = false}) {
    _examFlashT?.cancel();
    setState(() {
      _detailTab = 2;
      _examMode = ros ? 0 : 1;
      _examFlash = true;
    });
    _examFlashT = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _examFlash = false);
    });
  }

  /// เวลาของครั้งที่ตรวจ: มี "น." ต่อท้ายเสมอ ("ครั้งนี้" คงเดิม)
  String _examTime(String t) => t == 'ครั้งนี้' ? t : _clock(t);

  /// ชื่อระบบแบบเดียวกับรายการช่องใน workflow ตรวจร่างกาย (GA, HEENT, Heart, Chest …)
  /// ROS ใช้ชื่ออังกฤษ
  String _sysName(_System x) => _peField[x.key] ?? x.en;

  /// ตารางระบบ × ครั้งที่ตรวจ (เก่า → ใหม่ · ล่าสุดขวาสุด)
  /// ช่อง = ผลเป็นคำ (ผิดปกติแดง) + บันทึกย่อ · แถวที่เลือกดูแนวโน้มทางขวา
  Widget _examGrid(List<_System> systems, List<_ExamRound> rs) {
    // ช่องผลตรวจเป็นข้อความ (ไม่ใช้ไอคอน): ผิดปกติ = ข้อความเต็มตัวเข้ม + จุดแดง
    // ปกติ/ไม่ได้ตรวจ = ตัวเทาจาง ให้ตาไปหยุดที่ความผิดปกติก่อน
    Widget cell(int i, _System x) {
      final (f, note) = rs[i].of(x.key);
      final ch = _changeAt(rs, i, x.key);
      final tag = switch (ch) {
        _Change.newAbn => ('ใหม่', _red),
        _Change.worse => ('เปลี่ยน', _red),
        _Change.better => ('ดีขึ้น', _green),
        _ => null,
      };
      final Widget body = switch (f) {
        _Finding.abnormal =>
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.only(top: 7.0, right: 6.0),
              decoration:
                  BoxDecoration(color: _red, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(note.isEmpty ? 'ผิดปกติ' : note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5,
                      color: _inkTitle, height: 1.35, weight: FontWeight.w500)),
            ),
          ]),
        _Finding.normal =>
          Text('ปกติ', style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
        _Finding.notDone => Text('ไม่ได้ตรวจ',
            style: _t(13.0, color: _g5, weight: FontWeight.w500)),
        _ => Text('–', style: _t(13.0, color: _g5, weight: FontWeight.w500)),
      };
      return Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 8.0, 10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            body,
            // การเปลี่ยนแปลงเทียบครั้งก่อน ใต้ผลตรวจ (ผลตรวจทุกช่องเริ่มแนวเดียวกัน)
            if (tag != null)
              Padding(
                padding: EdgeInsets.only(
                    top: 3.0, left: f == _Finding.abnormal ? 12.0 : 0.0),
                child: Text(tag.$1,
                    style: _t(11.5, color: tag.$2, weight: FontWeight.w700)),
              ),
          ]),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 10.0),
      // การ์ดแบบเมนูวินิจฉัย: หัวข้อ + คำอธิบาย แล้วแผ่นในขาวขอบบาง · ไฮไลต์ = ขอบกรมท่า
      decoration: _clyCardDeco.copyWith(
        border: Border.all(
            color: _examFlash ? _blue : const Color(0xFFDADCE0),
            width: _examFlash ? 2.0 : 0.5),
        boxShadow: [
          ...?_clyCardDeco.boxShadow,
          if (_examFlash)
            BoxShadow(
                color: _blue.withValues(alpha: 0.18),
                blurRadius: 16.0,
                spreadRadius: 1.0),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _examMode == 0
                    ? 'ประวัติการทบทวนระบบ'
                    : 'ประวัติการตรวจร่างกาย',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text('ตรวจ ${rs.length} ครั้ง',
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          ]),
        ),
        // ตารางเรียบในการ์ด (ไม่มีกรอบซ้อน) · แถวคั่นเส้นบาง
        Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
              child: Row(children: [
                const SizedBox(width: 136.0),
                for (var i = 0; i < rs.length; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 6.0, 4.0),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(_examTime(rs[i].time),
                                      style: _num(13.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w700)),
                                ]),
                                Text(rs[i].by,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(11.5,
                                        color: _ink3, weight: FontWeight.w500)),
                              ]),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ),
            for (final x in systems)
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFFE8EAED), width: 0.5))),
                // สูงตามข้อความ (ผลผิดปกติอ่านได้ครบ ไม่ตัด …)
                child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 136.0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 10.0, 4.0, 10.0),
                            child: Text(_sysName(x),
                                style: _t(14.0,
                                    color: _inkTitle, weight: FontWeight.w700)),
                          ),
                        ),
                        for (var i = 0; i < rs.length; i++) cell(i, x),
                      ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 4.0),
      ]),
    );
  }

  // ---------------------------------------------- ตรวจร่างกาย: log ตามเวลา
  // แท็บนี้เป็นประวัติการตรวจทุกครั้งเรียงตามเวลา (ซ้าย → ขวา = เก่า → ใหม่)
  // แถว = ระบบ · คอลัมน์ = ครั้งที่ตรวจ · คอลัมน์สุดท้าย = ครั้งนี้ (บันทึกต่อ)
  // แพทย์เปิดดูแล้วเทียบกับครั้งก่อน ๆ ได้ทันที แล้วพูดบันทึกครั้งใหม่ต่อจากตรงนี้

  List<_ExamRound> get _rounds => _examMode == 0 ? _rosRounds : _peRounds;

  /// การเปลี่ยนแปลงของระบบ key ในครั้งที่ i เทียบกับครั้งก่อนหน้า
  _Change _changeAt(List<_ExamRound> rs, int i, String key) {
    if (i == 0) return _Change.none;
    final now = rs[i].of(key).$1;
    final prev = rs[i - 1].of(key).$1;
    // ครั้งนี้ยังไม่ได้กรอกระบบนี้ = ยังไม่มีความเปลี่ยนแปลง (ไม่ใช่ "ดีขึ้น")
    if (now == _Finding.none || now == _Finding.notDone) return _Change.none;
    if (now == _Finding.abnormal && prev != _Finding.abnormal) {
      return _Change.newAbn;
    }
    if (now != _Finding.abnormal && prev == _Finding.abnormal) {
      return _Change.better;
    }
    if (now == _Finding.abnormal &&
        prev == _Finding.abnormal &&
        rs[i].of(key).$2 != rs[i - 1].of(key).$2) {
      return _Change.worse;
    }
    return _Change.same;
  }

  /// ผลที่กำลังบันทึกด้วยเสียงรอบนี้ (ถ้ามี) เป็น "ครั้งนี้" ต่อท้ายเส้นเวลา
  _ExamRound? _draftRound() {
    if (_examMode != 1 || _peStep >= _filled.length) return null;
    final f = _filled[_peStep];
    final m = <String, (_Finding, String)>{};
    for (final e in _peField.entries) {
      final v = f[e.value];
      if (v == null) continue;
      final fd = switch (v) {
        'ปกติ' => _Finding.normal,
        'ผิดปกติ' => _Finding.abnormal,
        'ไม่ได้ตรวจ' => _Finding.notDone,
        _ => _Finding.none,
      };
      m[e.key] = (fd, f['${e.value} - รายละเอียด'] ?? '');
    }
    if (m.isEmpty) return null;
    return _ExamRound('ครั้งนี้', ErSession.instance.user?.name ?? 'ฉัน', m);
  }

  List<_ExamRound> get _examRounds =>
      [..._rounds, if (_draftRound() case final d?) d];

  List<Widget> _examOverlays() {
    final rs = _examRounds;
    final at = (_examSel ?? rs.length - 1).clamp(0, rs.length - 1);
    final r = rs[at];
    final systems = _examMode == 0 ? _rosSystems : _peSystems;
    final doctor = !ErSession.instance.isNurse;
    return [
      // หัวหน้า: สลับ ROS/PE + การกระทำ (ลอยกลางบน)
      Positioned(
        top: 12.0,
        left: 16.0,
        right: 16.0,
        child: Row(children: [
          SizedBox(
            width: 280.0,
            child: _segmented(
                const ['ทบทวนระบบ (ROS)', 'ตรวจร่างกาย (PE)'],
                _examMode,
                (i) => setState(() {
                      _examMode = i;
                      _examSel = null;
                      _examSys = null;
                    })),
          ),
          const Spacer(),
          if (doctor && _examMode == 1) ...[
            _uiButton(
                'Template การตรวจ', Icons.bookmarks_rounded, _openPeTemplates,
                primary: false),
            const SizedBox(width: 8.0),
            _uiButton('บันทึกครั้งใหม่ด้วยเสียง', Icons.mic_rounded,
                () => _openSpeech(step: _peStep)),
          ],
        ]),
      ),
      // ซ้าย: รายการระบบ + บันทึกการตรวจแบบละเอียด
      Positioned(
        left: 16.0,
        top: 60.0,
        bottom: 16.0,
        width: 290.0,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80.0),
          children: [
            for (final sy in systems) _examSysPill(sy, rs, at),
            const SizedBox(height: 6.0),
            _examNoteCard(systems, rs, at),
          ],
        ),
      ),
      // ขวา: รอบการตรวจ (เลือกดูได้) + การเปลี่ยนแปลงเทียบครั้งก่อน
      Positioned(
        right: 16.0,
        top: 60.0,
        bottom: 16.0,
        width: 270.0,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80.0),
          children: [
            _examRoundsCard(rs, at),
            const SizedBox(height: 12.0),
            _examChangeCard(systems, rs, at),
          ],
        ),
      ),
      // ป้ายรอบที่ดูอยู่ ใต้หุ่นกลางจอ
      Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 20.0,
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration:
                  _glass.copyWith(borderRadius: BorderRadius.circular(100.0)),
              child: Text(
                  '${r.time == 'ครั้งนี้' ? 'ครั้งนี้' : '${r.time} น.'} · ${r.by}'
                  '${_examSys == null ? '' : ' · ${systems.firstWhere((x) => x.key == _examSys).th}'}',
                  style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    ];
  }

  /// ระบบหนึ่งแถว: ไอคอนในวงกลม ชื่อ และผล (แดง = ผิดปกติ) แตะเพื่อดูเฉพาะระบบนี้
  Widget _examSysPill(_System sy, List<_ExamRound> rs, int at) {
    final (f, note) = rs[at].of(sy.key);
    final bad = f == _Finding.abnormal;
    final on = _examSys == sy.key;
    final ch = _changeAt(rs, at, sy.key);
    final status = switch (f) {
      _Finding.abnormal => note.isEmpty ? 'ผิดปกติ' : note,
      _Finding.normal => note.isEmpty ? 'ปกติ' : note,
      _Finding.notDone => 'ไม่ได้ตรวจ',
      _Finding.none => 'ยังไม่บันทึก',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _Press(
        scale: 0.98,
        child: GestureDetector(
          onTap: () => setState(() => _examSys = on ? null : sy.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 12.0, 8.0),
            decoration: _glass.copyWith(
              color: on ? _panel : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                  color: on ? (bad ? _red : _blue) : Colors.white, width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: (bad ? _red : _blue).withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(sy.icon, size: 18.0, color: bad ? _red : _blue),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(
                            _examMode == 1 && sy.en != sy.th
                                ? '${sy.th} · ${sy.en}'
                                : sy.th,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                      ),
                      if (ch == _Change.newAbn || ch == _Change.better) ...[
                        const SizedBox(width: 6.0),
                        Text(ch == _Change.newAbn ? 'ใหม่' : 'ดีขึ้น',
                            style: _t(9.0,
                                color: ch == _Change.newAbn ? _red : _blue,
                                weight: FontWeight.w700)),
                      ],
                    ]),
                    Text(status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.0,
                            color: bad
                                ? _red
                                : (f == _Finding.normal ? _ink3 : _g5))),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// การ์ดบันทึกละเอียด: เลือกระบบ = ผลของระบบนั้นทุกครั้ง · ไม่เลือก = สรุปผิดปกติรอบนี้
  Widget _examNoteCard(List<_System> systems, List<_ExamRound> rs, int at) {
    final r = rs[at];
    final sy =
        _examSys == null ? null : systems.firstWhere((x) => x.key == _examSys);
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
      decoration: _glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(sy == null ? 'บันทึกการตรวจแบบละเอียด' : sy.th,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 10.0),
          if (sy == null) ...[
            Row(children: [
              Expanded(
                child: Text(r.by,
                    style: _t(11.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text(r.time == 'ครั้งนี้' ? 'ครั้งนี้' : '${r.time} น.',
                  style: _num(9.5, color: _ink3)),
            ]),
            const SizedBox(height: 6.0),
            Text(
                [
                  for (final x in systems)
                    if (r.of(x.key).$1 == _Finding.abnormal)
                      '${x.th}: ${r.of(x.key).$2.isEmpty ? 'ผิดปกติ' : r.of(x.key).$2}'
                ].join(' · ').ifEmpty('ไม่พบความผิดปกติในรอบนี้'),
                style: _t(10.5, color: _ink2, height: 1.55)),
          ] else
            for (var i = rs.length - 1; i >= 0; i--)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(top: 5.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: rs[i].of(sy.key).$1 == _Finding.abnormal
                            ? _red
                            : _blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${rs[i].time == 'ครั้งนี้' ? 'ครั้งนี้' : '${rs[i].time} น.'} · ${rs[i].by}',
                              style: _num(9.0, color: _ink3)),
                          Text(
                              rs[i]
                                  .of(sy.key)
                                  .$2
                                  .ifEmpty(switch (rs[i].of(sy.key).$1) {
                                    _Finding.abnormal => 'ผิดปกติ',
                                    _Finding.normal => 'ปกติ',
                                    _Finding.notDone => 'ไม่ได้ตรวจ',
                                    _Finding.none => '—',
                                  }),
                              style: _t(10.5,
                                  color:
                                      rs[i].of(sy.key).$1 == _Finding.abnormal
                                          ? _red
                                          : _ink,
                                  weight: i == at
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  /// รอบการตรวจ: เลือกรอบที่จะดู (แบบปฏิทินในภาพต้นแบบ แต่เป็นเวลาในวันนี้)
  Widget _examRoundsCard(List<_ExamRound> rs, int at) {
    final systems = _examMode == 0 ? _rosSystems : _peSystems;
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0),
      decoration: _glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text('รอบการตรวจ',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 10.0),
          for (var i = rs.length - 1; i >= 0; i--)
            Builder(builder: (_) {
              final on = i == at;
              final abn = systems
                  .where((x) => rs[i].of(x.key).$1 == _Finding.abnormal)
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: _Press(
                  scale: 0.98,
                  child: Material(
                    color: on ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.0),
                      onTap: () => setState(() => _examSel = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        child: Row(children: [
                          Container(
                            width: 44.0,
                            height: 44.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: on
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : _blue.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                                rs[i].time == 'ครั้งนี้'
                                    ? 'ใหม่'
                                    : _examTime(rs[i].time),
                                style: _num(10.5,
                                    color: on ? Colors.white : _blueHue,
                                    weight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rs[i].by,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(11.5,
                                        color: on ? Colors.white : _inkTitle,
                                        weight: FontWeight.w700)),
                                Text(
                                    i == rs.length - 1
                                        ? 'ล่าสุด · ผิดปกติ $abn ระบบ'
                                        : 'ผิดปกติ $abn ระบบ',
                                    style: _t(9.5, color: on ? _pInk2 : _ink3)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// การเปลี่ยนแปลงของรอบที่ดูเทียบรอบก่อน: พบใหม่ / ค่าเปลี่ยน / ดีขึ้น
  Widget _examChangeCard(List<_System> systems, List<_ExamRound> rs, int at) {
    final rows = [
      for (final sy in systems)
        if (_changeAt(rs, at, sy.key) case final c
            when c == _Change.newAbn ||
                c == _Change.worse ||
                c == _Change.better)
          (sy, c)
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
      decoration: _glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text('เทียบกับครั้งก่อน',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 10.0),
          if (at == 0)
            Text('รอบแรก ยังไม่มีครั้งก่อนให้เทียบ',
                textAlign: TextAlign.center, style: _t(10.5, color: _ink3))
          else if (rows.isEmpty)
            Text('ไม่มีการเปลี่ยนแปลง',
                textAlign: TextAlign.center, style: _t(10.5, color: _ink3)),
          for (final (i, (sy, c)) in rows.indexed) ...[
            if (i > 0) const Divider(height: 14.0, color: _line),
            Row(children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: (c == _Change.better ? _blue : _red)
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(sy.icon,
                    size: 17.0, color: c == _Change.better ? _blue : _red),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sy.th,
                        style: _t(11.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text(
                        switch (c) {
                          _Change.newAbn => 'พบความผิดปกติใหม่',
                          _Change.worse =>
                            'ค่าเปลี่ยน · ${rs[at].of(sy.key).$2}',
                          _ => 'ดีขึ้น · กลับเป็นปกติ',
                        },
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _t(9.5, color: c == _Change.better ? _blue : _red)),
                  ],
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  /// แถบ tab แบบหน้า EMR: ชื่อ tab · ที่เลือก = ตัวหนากรมท่า + เส้นใต้ · เส้นคั่นล่างเต็มกว้าง
  Widget _segmented(List<String> items, int index, ValueChanged<int> onPick,
          {bool line = true}) =>
      Container(
        decoration: line
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: _line)))
            : null,
        child: Row(children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: () => onPick(i),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 10.0),
                margin: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: i == index ? _blue : Colors.transparent,
                          width: 3.0)),
                ),
                child: Text(items[i],
                    style: _t(14.0,
                        color: i == index ? _blue : _ink2,
                        weight:
                            i == index ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
        ]),
      );
}

/// รูปหัวหน้าตรวจร่างกาย: แพทย์ฟังปอดผู้ป่วย (Figma 484:150) วาดจาก path
/// idle motion: หัวใจบนโปสเตอร์เต้นเบา ๆ · ใบไม้ในกระถางไหวช้า ๆ
class _ExamHero extends StatefulWidget {
  const _ExamHero();

  @override
  State<_ExamHero> createState() => _ExamHeroState();
}

class _ExamHeroState extends State<_ExamHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _ExamHeroArt(_c.value), size: Size.infinite),
        ),
      );
}

class _ExamHeroArt extends CustomPainter {
  const _ExamHeroArt(this.t);
  final double t;

  static List<Path>? _cache;
  static List<Path> get _paths => _cache ??= [
        for (final (d, _, eo) in _examArtPaths)
          _SolarPainter._parse(d)
            ..fillType = eo ? PathFillType.evenOdd : PathFillType.nonZero
      ];

  /// กรอบเนื้อภาพในพิกัด 512 (ตัดขอบว่างออก)
  static const _box = Rect.fromLTRB(12.0, 95.0, 500.0, 456.0);
  static const _heart = 32;
  static const _leaves = {48, 49, 50};

  @override
  void paint(Canvas canvas, Size size) {
    // ย่อให้พอดีกล่อง ชิดล่างขวา
    final k = math.min(size.width / _box.width, size.height / _box.height);
    canvas.save();
    canvas.translate(
        size.width - _box.width * k, size.height - _box.height * k);
    canvas.scale(k);
    canvas.translate(-_box.left, -_box.top);
    // หัวใจเต้นสองจังหวะต่อรอบ (lub-dub) แล้วพัก
    double beat(double x) => math.exp(-math.pow((t - x) / 0.025, 2).toDouble());
    final hs = 1.0 + 0.14 * (beat(0.08) + 0.6 * beat(0.16));
    // ใบไม้ไหวรอบโคนกระถาง
    final sway = math.sin(t * 2 * math.pi) * 0.045;
    for (final (i, p) in _paths.indexed) {
      final paint = Paint()..color = Color(_examArtPaths[i].$2);
      if (i == _heart) {
        const c = Offset(87.5, 156.0);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(hs);
        canvas.translate(-c.dx, -c.dy);
        canvas.drawPath(p, paint);
        canvas.restore();
      } else if (_leaves.contains(i)) {
        const c = Offset(62.0, 318.0);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(sway * (i == 49 ? -1.0 : 1.0));
        canvas.translate(-c.dx, -c.dy);
        canvas.drawPath(p, paint);
        canvas.restore();
      } else {
        canvas.drawPath(p, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ExamHeroArt o) => o.t != t;
}

/// ภาพหัวหน้าตรวจร่างกาย (Figma 484:150) แปลงจาก SVG 512×512 · (path, สี, evenOdd)
const List<(String, int, bool)> _examArtPaths = [
  (
    'M166.5 137.23C168.7 125.88 172.28 116.63 181 108.52C198.38 92.35 227.97 95.24 243.57 112.44C252.6 122.41 253.41 136.47 242.86 145.7C241.6 157.31 237.23 174.65 227.5 181.97C229.67 188.28 229.88 201.98 226.95 208.35C231.48 223.52 243.57 240.93 256.35 250.25C258.78 252.03 261.88 253.83 264.56 255.28C270.46 258.44 276.9 260.46 283.55 261.25C286.43 261.43 289.46 259.84 292.22 260.96C293.69 260.98 294.22 260.74 295.62 260.33C295.24 256.1 300.73 241.54 302.86 237.29C303.78 235.42 304.9 233.65 306.2 232.02C311.76 225.12 320.32 221.29 328.41 218.37C331.12 217.39 334 215.7 336.86 215.38C335.87 220.81 336.39 225.99 342.14 228.54C352.38 233.09 369.88 222.34 373.59 212.98C375.82 213.25 380 214.85 382.19 215.64C392.4 219.3 404.69 224.56 411.47 233.46C420.65 245.53 424.11 265.35 426.75 280.04C427.47 284.07 428.7 290.58 428.62 294.44C425.63 295.06 422.6 295.45 419.54 295.62C418.56 308.93 418.09 328.33 413.58 340.61C414.42 343.71 413.09 355.42 413.99 356.81C416.48 356.17 424.37 356.5 427.34 356.5L455.43 356.51L479.38 356.44C482.64 356.43 487.75 356.24 490.85 356.37C492.24 356.44 493.6 356.85 494.8 357.56C496.88 358.76 498.33 360.47 498.69 362.89C500.05 372.12 498.76 381.84 499.24 391.18C499.3 392.29 499.33 393.65 499.29 394.74C499.56 399.7 499.19 406.06 499.25 411.2C499.29 413.7 499.39 421.75 499.12 423.91C499.16 430.85 499.17 437.83 499.25 444.77C499.28 447.45 498.45 450.64 496.68 452.7C491.13 455.29 477.69 454.32 471.21 454.3L437.43 454.35L329.96 454.26C313.73 454.15 296.41 453.99 280.21 454.3C278.55 454.58 275.11 454.61 273.48 454.34C269.87 454 261.55 454.23 257.75 454.23L227.22 454.28C220.24 454.51 213.24 454.42 206.25 454.34C184.31 454.08 162.25 454.73 140.32 454.41C138.75 454.46 136.75 454.7 135.41 453.91C135.05 452.63 136.54 434.7 136.96 433.75C134.83 433.12 126.48 432.18 125.94 429.83C124.89 425.28 126.72 417.02 127.46 412.35L130.3 394.56C133.43 375.06 136.9 355.62 140.7 336.24L146.08 311.25C147.09 306.68 148.28 301.76 149 297.17C149.21 295.84 149.1 291.63 149.08 290.17C149.01 285.49 148.9 280.81 148.75 276.13C148.46 264.99 148.35 253.25 149.56 242.15C149.91 238.96 151.06 233.88 151.68 230.61C154 218.53 158.92 205.85 165.9 195.7C167.84 192.88 170.64 190.28 172.67 187.39C173.87 185.68 178.32 178.28 179.65 177.4L180.64 176.49C179.4 176.6 178.24 177.86 177.06 178.32C168.22 181.6 159.27 180.54 152.39 173.9C143.67 165.5 143.72 151.16 151.99 142.53C155.72 138.64 161.13 137.24 166.5 137.23ZM308.75 350.1C308.73 348.4 309 346.29 309.19 344.56C308.04 345.16 304.24 349.64 303.53 350.79C304.42 351.26 307.29 350.33 308.75 350.1ZM180.64 176.49L179.65 177.4C178.32 178.28 173.87 185.68 172.67 187.39C170.64 190.28 167.84 192.88 165.9 195.7C158.92 205.85 154 218.53 151.68 230.61C151.06 233.88 149.91 238.96 149.56 242.15C148.35 253.25 148.46 264.99 148.75 276.13C148.9 280.81 149.01 285.49 149.08 290.17C149.1 291.63 149.21 295.84 149 297.17C148.28 301.76 147.09 306.68 146.08 311.25L140.7 336.24C136.9 355.62 133.43 375.06 130.3 394.56L127.46 412.35C126.72 417.02 124.89 425.28 125.94 429.83C126.48 432.18 134.83 433.12 136.96 433.75C136.54 434.7 135.05 452.63 135.41 453.91C136.75 454.7 138.75 454.46 140.32 454.41C162.25 454.73 184.31 454.08 206.25 454.34C213.24 454.42 220.24 454.51 227.22 454.28L257.75 454.23C261.55 454.23 269.87 454 273.48 454.34C273.33 451.41 273.48 447.42 273.48 444.37L273.45 424.02C273.29 421.67 272.99 416.29 274.14 414.43C273.02 412.39 273.63 409.91 273.7 407.67C273.92 400.89 276.49 394.71 280.58 389.37C281.19 388.56 281.9 387.88 282.51 387.08L282.79 386.69C280.93 385.26 279.8 384.17 278.4 382.23C275.26 377.81 273.87 372.37 274.52 366.98C274.81 364.65 275.43 362.36 275.81 360.01C278.19 350.57 282.16 340.22 285.72 331.15C287.19 327.42 289.66 323.52 290.97 319.73C291.19 319.08 291.75 315.8 291.76 315.24C291.8 312.87 292.98 296.64 292.77 295.63L293.37 295.2C294.08 290.54 294.14 286.87 294.13 282.19C294.13 278.03 293.86 273.88 293.31 269.75C292.99 267.38 292.2 263.19 292.22 260.96C289.46 259.84 286.43 261.43 283.55 261.25C276.9 260.46 270.46 258.44 264.56 255.28C261.88 253.83 258.78 252.03 256.35 250.25C243.57 240.93 231.48 223.52 226.95 208.35C229.88 201.98 229.67 188.28 227.5 181.97C237.23 174.65 241.6 157.31 242.86 145.7C253.41 136.47 252.6 122.41 243.57 112.44C227.97 95.24 198.38 92.35 181 108.52C172.28 116.63 168.7 125.88 166.5 137.23C161.13 137.24 155.72 138.64 151.99 142.53C143.72 151.16 143.67 165.5 152.39 173.9C159.27 180.54 168.22 181.6 177.06 178.32C178.24 177.86 179.4 176.6 180.64 176.49Z',
    0xFF479FFE,
    false
  ),
  (
    'M166.5 137.23C168.7 125.88 172.28 116.63 181 108.52C198.38 92.35 227.97 95.24 243.57 112.44C252.6 122.41 253.41 136.47 242.86 145.7C241.6 157.31 237.23 174.65 227.5 181.97C229.67 188.28 229.88 201.98 226.95 208.35C231.48 223.52 243.57 240.93 256.35 250.25C258.78 252.03 261.88 253.83 264.56 255.28C270.46 258.44 276.9 260.46 283.55 261.25C286.43 261.43 289.46 259.84 292.22 260.96C292.2 263.19 292.99 267.38 293.31 269.75C293.86 273.88 294.13 278.03 294.13 282.19C294.14 286.87 294.08 290.54 293.37 295.2L292.77 295.63C290.75 296.5 288.31 296.53 286.17 297.11C273.79 300.45 244.41 307.83 232.61 303.18C231.06 302.57 229.56 301.8 228.06 301.07C227.94 306.46 228.54 310.97 229.25 316.3C231.76 335.34 234.07 354.42 236.31 373.49C236.63 376.17 237.03 378.67 237.18 381.38C240.05 379.59 243.36 376.37 246.74 374.31C256.15 368.55 265.61 364.14 275.81 360.01C275.43 362.36 274.81 364.65 274.52 366.98C273.87 372.37 275.26 377.81 278.4 382.23C279.8 384.17 280.93 385.26 282.79 386.69L282.51 387.08C281.9 387.88 281.19 388.56 280.58 389.37C276.49 394.71 273.92 400.89 273.7 407.67C273.63 409.91 273.02 412.39 274.14 414.43C272.99 416.29 273.29 421.67 273.45 424.02L273.48 444.37C273.48 447.42 273.33 451.41 273.48 454.34C269.87 454 261.55 454.23 257.75 454.23L227.22 454.28C220.24 454.51 213.24 454.42 206.25 454.34C184.31 454.08 162.25 454.73 140.32 454.41C138.75 454.46 136.75 454.7 135.41 453.91C135.05 452.63 136.54 434.7 136.96 433.75C134.83 433.12 126.48 432.18 125.94 429.83C124.89 425.28 126.72 417.02 127.46 412.35L130.3 394.56C133.43 375.06 136.9 355.62 140.7 336.24L146.08 311.25C147.09 306.68 148.28 301.76 149 297.17C149.21 295.84 149.1 291.63 149.08 290.17C149.01 285.49 148.9 280.81 148.75 276.13C148.46 264.99 148.35 253.25 149.56 242.15C149.91 238.96 151.06 233.88 151.68 230.61C154 218.53 158.92 205.85 165.9 195.7C167.84 192.88 170.64 190.28 172.67 187.39C173.87 185.68 178.32 178.28 179.65 177.4L180.64 176.49C179.4 176.6 178.24 177.86 177.06 178.32C168.22 181.6 159.27 180.54 152.39 173.9C143.67 165.5 143.72 151.16 151.99 142.53C155.72 138.64 161.13 137.24 166.5 137.23ZM225.88 226.57L225.97 226.78C226.79 228.58 228.88 235.09 229.53 236.19C232.15 240.64 237.42 263.54 239.93 265.47C243.9 266.73 264.45 264.35 269.02 263.15L269.13 262.66C268.31 262.09 266.09 261.1 265.04 260.59C243.7 250.22 230.4 231.56 222.88 209.5C221.73 209.2 218.68 208.13 218.05 208.03C219.12 212.05 220.81 214.89 222.51 218.65C223.59 221.05 224.65 224.36 225.88 226.57ZM223.81 184.08C220.05 185.19 215.13 185.15 211.48 183.58C210.4 184.35 210.06 185.1 209.33 186.22C209.5 186.62 209.68 187.01 209.86 187.41C211.35 190.7 219.72 207.24 223.85 204.97C225.39 202.3 225.41 185.94 223.81 184.08Z',
    0xFFFCFCFC,
    false
  ),
  (
    'M166.5 137.23C168.7 125.88 172.28 116.63 181 108.52C198.38 92.35 227.97 95.24 243.57 112.44C252.6 122.41 253.41 136.47 242.86 145.7C241.6 157.31 237.23 174.65 227.5 181.97C229.67 188.28 229.88 201.98 226.95 208.35C231.48 223.52 243.57 240.93 256.35 250.25C258.78 252.03 261.88 253.83 264.56 255.28C270.46 258.44 276.9 260.46 283.55 261.25C280.14 262.33 272.47 263.6 269.02 263.15L269.13 262.66C268.31 262.09 266.09 261.1 265.04 260.59C243.7 250.22 230.4 231.56 222.88 209.5C221.73 209.2 218.68 208.13 218.05 208.03C216.53 207.1 209.41 195.97 208.15 193.9C207.96 194.27 207.6 194.85 207.53 195.23C206.88 196.43 206.78 196.67 206.44 197.99C204.73 197.63 184.78 176.16 180.27 177.5L179.65 177.4L180.64 176.49C179.4 176.6 178.24 177.86 177.06 178.32C168.22 181.6 159.27 180.54 152.39 173.9C143.67 165.5 143.72 151.16 151.99 142.53C155.72 138.64 161.13 137.24 166.5 137.23ZM223.81 184.08C220.05 185.19 215.13 185.15 211.48 183.58C210.4 184.35 210.06 185.1 209.33 186.22C209.5 186.62 209.68 187.01 209.86 187.41C211.35 190.7 219.72 207.24 223.85 204.97C225.39 202.3 225.41 185.94 223.81 184.08Z',
    0xFF312B2B,
    false
  ),
  (
    'M207.26 149.99C214.41 149.63 219.66 149.01 226.07 145.45C233.49 141.33 238.39 135.09 240.69 126.96C243.61 135.52 242.2 137.59 242.84 145.43L242.86 145.7C241.6 157.31 237.23 174.65 227.5 181.97C229.67 188.28 229.88 201.98 226.95 208.35C231.48 223.52 243.57 240.93 256.35 250.25C258.78 252.03 261.88 253.83 264.56 255.28C270.46 258.44 276.9 260.46 283.55 261.25C280.14 262.33 272.47 263.6 269.02 263.15L269.13 262.66C268.31 262.09 266.09 261.1 265.04 260.59C243.7 250.22 230.4 231.56 222.88 209.5C221.73 209.2 218.68 208.13 218.05 208.03C216.53 207.1 209.41 195.97 208.15 193.9C207.96 194.27 207.6 194.85 207.53 195.23C206.88 196.43 206.78 196.67 206.44 197.99C204.73 197.63 184.78 176.16 180.27 177.5L179.65 177.4L180.64 176.49L180.8 176.42C180.91 176.06 180.94 175.96 181.2 175.68C182.41 174.39 183.93 171.36 184.32 169.61C189.34 167.64 190.92 165.88 194.02 161.53C182.85 150.07 201 135.29 207.26 149.99ZM223.81 184.08C220.05 185.19 215.13 185.15 211.48 183.58C210.4 184.35 210.06 185.1 209.33 186.22C209.5 186.62 209.68 187.01 209.86 187.41C211.35 190.7 219.72 207.24 223.85 204.97C225.39 202.3 225.41 185.94 223.81 184.08Z',
    0xFFFEBC8D,
    false
  ),
  (
    'M199.9 174.48C198.44 169.91 193.66 156.13 198.85 153.48C200.63 152.57 204.76 155.22 200.47 159.16C201.62 165.74 204.13 175.31 207.22 181.22C208.9 181.93 210.53 183.39 211.48 183.58C210.4 184.35 210.06 185.1 209.33 186.22C209.5 186.62 209.68 187.01 209.86 187.41C211.35 190.7 219.72 207.24 223.85 204.97C225.39 202.3 225.41 185.94 223.81 184.08C224.81 183.65 226.29 182.58 227.5 181.97C229.67 188.28 229.88 201.98 226.95 208.35C231.48 223.52 243.57 240.93 256.35 250.25C258.78 252.03 261.88 253.83 264.56 255.28C270.46 258.44 276.9 260.46 283.55 261.25C280.14 262.33 272.47 263.6 269.02 263.15L269.13 262.66C268.31 262.09 266.09 261.1 265.04 260.59C243.7 250.22 230.4 231.56 222.88 209.5C221.73 209.2 218.68 208.13 218.05 208.03C216.53 207.1 209.41 195.97 208.15 193.9C207.83 192.91 205.68 188.98 205.09 187.84C203.25 183.25 201.49 179.17 199.9 174.48Z',
    0xFF2B3D57,
    false
  ),
  (
    'M207.22 181.22C208.9 181.93 210.53 183.39 211.48 183.58C210.4 184.35 210.06 185.1 209.33 186.22C208.5 184.55 207.81 182.99 207.22 181.22Z',
    0xFFFA9A68,
    false
  ),
  (
    'M199.9 174.48C201.49 179.17 203.25 183.25 205.09 187.84C202.49 187.03 199.32 178.84 199.07 176.11C198.99 175.22 199.36 175.04 199.9 174.48Z',
    0xFFFA9A68,
    false
  ),
  (
    'M237.18 381.38C240.05 379.59 243.36 376.37 246.74 374.31C256.15 368.55 265.61 364.14 275.81 360.01C275.43 362.36 274.81 364.65 274.52 366.98C273.87 372.37 275.26 377.81 278.4 382.23C279.8 384.17 280.93 385.26 282.79 386.69L282.51 387.08C281.9 387.88 281.19 388.56 280.58 389.37C276.49 394.71 273.92 400.89 273.7 407.67C273.63 409.91 273.02 412.39 274.14 414.43C272.99 416.29 273.29 421.67 273.45 424.02L273.48 444.37C273.48 447.42 273.33 451.41 273.48 454.34C269.87 454 261.55 454.23 257.75 454.23L227.22 454.28C227.62 437.19 225.49 419.59 226.3 402.44C226.75 392.91 230.96 387.95 237.18 381.38Z',
    0xFF2B3D57,
    false
  ),
  (
    'M215.53 293.28C219.83 296.1 223.64 298.49 228.06 301.07C227.94 306.46 228.54 310.97 229.25 316.3C231.76 335.34 234.07 354.42 236.31 373.49C236.63 376.17 237.03 378.67 237.18 381.38C230.96 387.95 226.75 392.91 226.3 402.44C225.49 419.59 227.62 437.19 227.23 454.28C220.24 454.51 213.24 454.42 206.25 454.34C184.31 454.08 162.25 454.73 140.32 454.41C138.75 454.46 136.75 454.7 135.41 453.91C135.05 452.63 136.54 434.7 136.96 433.75C137.41 434.01 137.1 433.89 137.68 433.96C164.23 437.15 189.22 435.65 215.51 430.65C218.45 429.54 219.35 428.65 219.48 425.39C219.61 422.11 219.43 418.82 219.33 415.54L218.81 398.17L216.85 335.93L216.16 317.27C216.01 313.47 215.73 309.11 215.81 305.38C215.79 301.35 215.46 297.27 215.53 293.28Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M136.96 433.75C137.41 434.01 137.1 433.89 137.68 433.96C164.23 437.15 189.22 435.65 215.51 430.65C215.46 438.35 215.32 446.05 215.08 453.75C207.02 453.98 141.59 453.5 140.32 454.41C138.75 454.46 136.75 454.7 135.41 453.91C135.05 452.63 136.54 434.7 136.96 433.75Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M180.27 177.5C184.78 176.16 204.73 197.63 206.44 197.99C206.78 196.67 206.88 196.43 207.53 195.23C208.72 197.52 210.2 201.35 211.22 203.8C213.44 209.03 215.57 214.29 217.61 219.58C218.94 223.14 220.21 227.16 221.57 230.6C221.7 231.94 223.53 237.06 223.92 238.62C225.02 242.92 225.61 246.98 226.36 251.32C223.15 247.84 212.4 236.01 211.52 232.46C209.55 224.46 206.87 218.49 203.85 210.81C196.71 196.49 191.6 189.04 180.27 177.5Z',
    0xFF479FFE,
    false
  ),
  (
    'M168.35 251.38C178.92 261.85 186.46 269.78 198.18 279.74C201.54 282.6 204.99 285.36 208.52 288C209.86 289 214.68 292.4 215.53 293.28C215.46 297.27 215.79 301.35 215.81 305.38C213.14 304.98 206.91 300.25 204.52 298.38C192.57 288.96 182.31 277.18 174.59 264.07C172.22 260.05 170.29 255.62 168.35 251.38Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M162.2 334.55C166.16 334.39 196.12 334.01 197.74 334.89C198.33 335.21 198.81 336.05 199.05 336.65C199.91 338.86 199.9 342.91 198.69 345C198.29 345.68 197.96 345.72 197.27 345.98C193.06 346.35 164.29 346.64 161.62 345.85C160.97 345.65 160.59 345.26 160.29 344.68C159.36 342.89 159.38 338.22 160.12 336.35C160.55 335.27 161.19 334.95 162.2 334.55Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M413.99 356.81C416.48 356.17 424.37 356.5 427.34 356.5L455.43 356.51L479.38 356.44C482.64 356.43 487.75 356.24 490.85 356.37C492.24 356.44 493.6 356.85 494.8 357.56C496.88 358.76 498.33 360.47 498.69 362.89C500.05 372.12 498.76 381.84 499.24 391.18C499.3 392.29 499.33 393.65 499.29 394.74C499.56 399.7 499.19 406.06 499.25 411.2C499.29 413.7 499.39 421.75 499.12 423.91C499.16 430.85 499.17 437.83 499.25 444.77C499.28 447.45 498.45 450.64 496.68 452.7C491.13 455.29 477.69 454.32 471.21 454.3L437.43 454.35L329.96 454.26L329.9 423.96C329.64 421.79 330.05 417.09 330.94 415.13C333.8 408.83 345.69 406.88 351.72 405.5C360.75 403.48 369.81 401.58 378.89 399.78C385.42 398.46 393.18 397.19 399.24 394.82L399.54 394.7C410.71 388.64 410.98 380.29 412.25 369.13C414.4 365.42 412.77 358.97 413.99 356.81Z',
    0xFF479FFE,
    false
  ),
  (
    'M329.9 423.96L499.12 423.91C499.16 430.85 499.17 437.83 499.25 444.77C499.28 447.45 498.45 450.64 496.68 452.7C491.13 455.29 477.69 454.32 471.21 454.3L437.43 454.35L329.96 454.26L329.9 423.96Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M413.99 356.81C416.48 356.17 424.37 356.5 427.34 356.5L455.43 356.51L479.38 356.44C482.64 356.43 487.75 356.24 490.85 356.37C492.24 356.44 493.6 356.85 494.8 357.56C496.88 358.76 498.33 360.47 498.69 362.89C500.05 372.12 498.76 381.84 499.24 391.18C499.3 392.29 499.33 393.65 499.29 394.74L499.03 395.12C498.31 395.19 491.95 395.01 490.63 395.02L468.06 395.06C445.97 395.06 423.86 395.06 401.76 395.02C400.89 395.01 400.31 395.11 399.54 394.7C410.71 388.64 410.98 380.29 412.25 369.13C414.4 365.42 412.77 358.97 413.99 356.81Z',
    0xFFFCFCFC,
    false
  ),
  (
    'M381.32 360.09C383.2 361.31 387.75 361.94 390.09 362.72C397.09 365.05 405.44 366.48 412.25 369.13C410.98 380.29 410.71 388.64 399.54 394.7L399.24 394.82C393.18 397.19 385.42 398.46 378.89 399.78C369.81 401.58 360.75 403.48 351.72 405.5C345.69 406.88 333.8 408.83 330.94 415.13C330.05 417.09 329.64 421.79 329.9 423.96L329.96 454.26C313.73 454.15 296.41 453.99 280.21 454.3C278.55 454.58 275.11 454.61 273.48 454.34C273.33 451.41 273.48 447.42 273.48 444.37L273.45 424.02C273.29 421.67 272.99 416.29 274.14 414.43C273.02 412.39 273.63 409.91 273.7 407.67C273.92 400.89 276.49 394.71 280.58 389.37C281.19 388.56 281.9 387.88 282.51 387.08L282.79 386.69C284.73 387.8 285.7 388.25 287.91 388.81C290.05 385.65 297.44 382.75 298.81 380.67C299.82 378.49 300.19 376.9 300.68 374.58C303.35 374.14 303.89 371.1 307.94 372.63C307.07 374.1 306.41 374.98 306.24 376.72C306.69 377.35 307.33 378.14 308.12 378.48C316.54 382.07 334.43 378.48 342.38 375.16C344.97 374.08 348.33 370.45 350.83 369.7C355.49 368.29 359.84 367.15 364.39 365.81C370.17 364.12 375.69 361.77 381.32 360.09Z',
    0xFF2B3D57,
    false
  ),
  (
    'M273.45 424.02C275.17 423.99 277.62 424 279.27 423.83C279.56 433.26 280.31 445.16 280.21 454.3C278.55 454.58 275.11 454.61 273.48 454.34C273.33 451.41 273.48 447.42 273.48 444.37L273.45 424.02Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M282.79 386.69C284.73 387.8 285.7 388.25 287.91 388.81L287.69 389.12C287.04 390.08 286 391.12 285.15 392.13C282.51 395.29 281.26 397.88 280.05 401.94C279.48 403.88 279.15 409.25 279.14 411.61C279.04 411.7 278.93 411.79 278.83 411.88C276.77 412.63 275.88 412.98 274.14 414.43C273.02 412.39 273.63 409.91 273.7 407.67C273.92 400.89 276.49 394.71 280.58 389.37C281.19 388.56 281.9 387.88 282.51 387.08L282.79 386.69Z',
    0xFF202E42,
    false
  ),
  (
    'M278.83 411.88C279.18 412.95 279.23 422 279.27 423.83C277.62 424 275.17 423.99 273.45 424.02C273.29 421.67 272.99 416.29 274.14 414.43C275.88 412.98 276.77 412.63 278.83 411.88Z',
    0xFF479FFE,
    false
  ),
  (
    'M300.68 374.58C303.35 374.14 303.89 371.1 307.94 372.63C307.07 374.1 306.41 374.98 306.24 376.72C304.13 378.21 301.39 380.5 298.81 380.67C299.82 378.49 300.19 376.9 300.68 374.58Z',
    0xFF202E42,
    false
  ),
  (
    'M385.73 298.33C393.38 298.21 402.41 296.88 410.09 296.35C413.21 296.13 416.39 295.64 419.54 295.62C418.56 308.93 418.09 328.33 413.58 340.61C414.42 343.71 413.09 355.42 413.99 356.81C412.77 358.97 414.4 365.42 412.25 369.13C405.44 366.48 397.09 365.05 390.09 362.72C387.75 361.94 383.2 361.31 381.32 360.09C375.69 361.77 370.17 364.12 364.39 365.81C359.84 367.15 355.49 368.29 350.83 369.7C348.33 370.45 344.97 374.08 342.38 375.16C334.43 378.48 316.54 382.07 308.12 378.48C307.33 378.14 306.69 377.35 306.24 376.72C306.41 374.98 307.07 374.1 307.94 372.63C303.89 371.1 303.35 374.14 300.68 374.58L300.7 374.08C300.89 368.84 300.07 363.46 296.36 359.48C297.62 357.84 299.03 356.12 300.26 354.48C300.88 353.66 303.38 351.25 303.53 350.79C304.42 351.26 307.29 350.33 308.75 350.1C320.29 350.79 333.46 350.95 344.81 353.47C346.67 352.29 348.99 350.62 350.75 349.25C361.96 340.5 375.09 332.54 385.99 323.55C386 315.12 385.8 306.75 385.73 298.33Z',
    0xFFFEBC8D,
    false
  ),
  (
    'M303.53 350.79C304.42 351.26 307.29 350.33 308.75 350.1C320.29 350.79 333.46 350.95 344.81 353.47C340.5 356.98 338.47 356.25 333.13 357.11C322.28 358.84 314.4 363.76 307.94 372.63C303.89 371.1 303.35 374.14 300.68 374.58L300.7 374.08C300.89 368.84 300.07 363.46 296.36 359.48C297.62 357.84 299.03 356.12 300.26 354.48C300.88 353.66 303.38 351.25 303.53 350.79Z',
    0xFF2B3D57,
    false
  ),
  (
    'M413.58 340.61C414.42 343.71 413.09 355.42 413.99 356.81C412.77 358.97 414.4 365.42 412.25 369.13C405.44 366.48 397.09 365.05 390.09 362.72C387.75 361.94 383.2 361.31 381.32 360.09C382.45 359.48 383.74 358.99 384.92 358.48C392.96 354.98 401.38 351.49 408.33 346.06C410.21 344.59 411.71 342.44 413.42 340.76L413.58 340.61Z',
    0xFF479FFE,
    false
  ),
  (
    'M293.37 295.2C298.18 295.6 302.31 296.69 306.74 297.14C308.42 297.44 310.11 297.69 311.8 297.9L312.68 298.17C313.56 299.94 314.32 319.67 314.59 322.97C314.8 325.4 310.62 343.42 309.19 344.56C308.04 345.16 304.24 349.64 303.53 350.79C303.38 351.25 300.88 353.66 300.26 354.48C299.03 356.12 297.62 357.84 296.36 359.48C300.07 363.46 300.89 368.84 300.7 374.08L300.68 374.58C300.19 376.9 299.82 378.49 298.81 380.67C297.44 382.75 290.05 385.65 287.91 388.81C285.7 388.25 284.73 387.8 282.79 386.69C280.93 385.26 279.8 384.17 278.4 382.23C275.26 377.81 273.87 372.37 274.52 366.98C274.81 364.65 275.43 362.36 275.81 360.01C278.19 350.57 282.16 340.22 285.72 331.15C287.19 327.42 289.66 323.52 290.97 319.73C291.19 319.08 291.75 315.8 291.76 315.24C291.8 312.87 292.98 296.64 292.77 295.63L293.37 295.2Z',
    0xFFFEBC8D,
    false
  ),
  (
    'M295.62 260.33C296.41 260.25 298.35 259.98 298.92 259.57C305.18 255.24 308.53 247.89 316.38 245.49C321.51 243.92 326.08 245.27 330.7 247.68C331.41 248.12 333.46 249.56 334 249.86L334.15 250.19C335.02 252.04 337 254.67 336.1 256.97C335.4 258.73 334.38 260.78 333.53 262.48C332.78 263.45 332.1 264.34 331.4 265.36C324.4 273.17 317.85 277.48 307.03 276.85C305.38 276.75 296.07 281.28 294.13 282.19C294.13 278.03 293.86 273.88 293.31 269.75C292.99 267.38 292.2 263.19 292.22 260.96C293.69 260.98 294.22 260.74 295.62 260.33Z',
    0xFFFEBC8D,
    false
  ),
  (
    'M330.7 247.68C334.87 243.7 340.71 243.64 344.72 247.9C353.16 256.87 343.4 273.26 331.4 265.36C332.1 264.34 332.78 263.45 333.53 262.48C334.38 260.78 335.4 258.73 336.1 256.97C337 254.67 335.02 252.04 334.15 250.19L334 249.86C333.46 249.56 331.41 248.12 330.7 247.68Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M334 249.86C337.96 248.56 341.49 249.59 342.78 253.88C343.34 255.79 343.11 257.85 342.14 259.59C340.19 263.14 337.07 263.41 333.53 262.48C334.38 260.78 335.4 258.73 336.1 256.97C337 254.67 335.02 252.04 334.15 250.19L334 249.86Z',
    0xFF2B3D57,
    false
  ),
  (
    'M307.14 277.09L311.26 276.97C311.3 279.86 313.1 296.32 312.46 297.71L311.8 297.9C310.11 297.69 308.42 297.44 306.74 297.14C306.92 290.8 307.28 283.34 307.14 277.09Z',
    0xFF0F7FF1,
    false
  ),
  (
    'M381.26 262.84L381.72 263.29C382.03 264.91 382 270.17 382.06 272.08C382.41 280.87 382.56 289.67 382.5 298.46L378.44 298.53C377.74 298.45 378.02 298.61 377.53 298.13C377.41 296.25 378.13 288.07 378.42 285.93C379.3 279.35 379.81 269.14 381.26 262.84Z',
    0xFF0F7FF1,
    false
  ),
  (
    'M37.31 102.06C43.86 101.95 50.66 102.17 57.25 102.17L98.42 102.18L119.5 102.15C122.62 102.16 125.91 102.09 129.02 102.26C130.47 102.34 131.46 103.02 132.68 103.77C133.33 105.1 133.88 106.51 133.92 107.99C134.16 116.26 133.97 124.7 134 132.94C134.23 150.01 134.25 167.08 134.06 184.15L134 221.96C134 227.74 134.08 233.56 134 239.33C133.96 241.97 133.19 242.59 131.31 244.28C128.33 245.49 117.89 244.99 113.99 244.99L88.57 245.04L60.4 244.89C53.5 244.91 46.57 245.28 39.68 245.01C38.56 244.97 37.44 244.89 36.38 244.51C34.65 243.89 34.07 243.12 33.36 241.45C32.56 239.54 32.99 210.83 32.99 206.62C32.79 183.77 32.8 160.91 33.03 138.05C33.05 128.18 32.91 118.28 32.95 108.41C32.96 107.22 33.13 105.91 33.66 104.83C34.49 103.15 35.64 102.63 37.31 102.06Z',
    0xFFFCFCFC,
    false
  ),
  (
    'M80.19 114.28C83.63 114.11 86.85 114.74 88.54 118.12C89.6 120.24 90.18 123.66 91.22 126.02C91.94 127.64 86.43 132.66 86.37 134.16C86.18 138.97 96.27 139.05 98.27 143.25C100.94 148.95 100.83 155.75 102.57 161.72C104.31 167.7 106.55 173.66 108.44 179.6C109.15 181.85 110.52 184.14 109.75 186.53C108.66 189.95 104.48 190.37 103.02 186.97C101.92 184.43 101.67 181.75 100.81 179.14C99.62 175.68 97.99 172.2 96.73 168.74C95.92 166.69 95.22 164.19 94.4 162.36C93.49 164.14 94.57 178.44 94.5 181.67C94.37 187.89 93.67 193.57 93.07 199.75L90.16 228.97C91.53 230.04 93.83 231.57 94.25 233.25C95.24 237.24 85.7 236.38 83.94 235.15C83.51 234.86 83.09 233.29 83.09 232.76C83.17 227.16 83.01 221.57 82.99 215.98C82.95 206.01 82.78 196.04 82.46 186.07C82.31 185.94 82.11 185.9 81.9 185.82C81.45 186.26 81.39 186.61 81.38 187.25C81.24 196.56 80.76 205.81 80.85 215.13C80.89 220.1 80.22 225.19 80.65 230.18C80.76 231.43 80.99 233.22 80.27 234.37C78.76 236.41 71.66 236.64 69.91 235.01C69.48 234.62 69.28 234.03 69.36 233.46C69.65 231.58 72.14 230.06 73.58 229.01C73.13 227 72.87 224.56 72.72 222.47C71.52 205.61 68.31 188.68 69.57 171.75C69.83 168.23 69.75 164.5 69.72 160.99C66.98 169.42 63.22 177.42 60.85 186.01C59.77 189.92 55.91 190.74 54.18 186.9C53.12 184.51 55.27 180.16 56.01 177.63C57.55 172.37 59.52 166.97 61.11 161.69C62.86 155.62 62.55 148.53 65.64 142.9C67.44 139.71 75.6 138.32 77.07 136.05C78.26 132.63 73.64 129.88 72.62 127.08C72.06 125.67 73.15 124.85 73.49 123.65C74.82 118.96 74.78 115.93 80.19 114.28Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M83.54 149.76C84.9 149.88 85.68 150.44 86.92 150.88C87.86 151.22 88.96 149.77 90.04 149.79C91.97 149.81 93.57 150.75 93.51 152.89C93.43 155.8 91.92 157.5 90 159.43C89.17 160.23 88.2 160.92 87.27 161.63C83.71 159.34 76.56 152.59 83.54 149.76Z',
    0xFFFC726C,
    false
  ),
  (
    'M44.99 118.32C50.01 118.04 58.34 117.9 63.4 118.74C64.41 118.91 65.68 122.37 62.44 123.14C57.17 123.44 50.79 123.34 45.48 123.11C42.89 122.99 40.81 119.53 44.99 118.32Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M43.66 206.77L44.11 206.75C49.65 206.43 56.36 206.7 61.99 206.77C64.17 206.8 65 209.85 62.68 211.47L62.09 211.49C56.68 211.65 50.48 211.65 45.03 211.47C42.06 211.38 40.68 209.07 43.66 206.77Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M105.33 118.32C109.92 118.11 114.63 118.27 119.24 118.19C121.15 118.16 123.48 118.3 124.48 120.17C124.66 121.8 124.17 122.52 122.69 123.05C118.33 123.51 113.56 123.16 109.16 123.3C107.18 123.36 104.59 123.31 103.45 121.43C103.16 119.91 104.03 118.92 105.33 118.32Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M43.58 217.28C45.04 217.22 66.12 215.66 57.89 221.97C53.62 222.04 49.27 222.22 45.01 222C42.03 221.84 40.75 218.94 43.58 217.28Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M62.79 316.12L65.94 316.12C74.86 317.08 80.43 312.27 77.63 325.5C76.73 329.75 76.21 334.62 74.79 338.79C79.35 338.45 83.87 338.64 88.44 338.74C92.61 338.85 96.79 338.81 100.96 338.87C106.97 338.96 113.03 338.34 119.02 338.78C120.27 338.87 121.47 339.31 122.47 340.1C123.6 340.99 123.72 341.92 123.71 343.31C123.68 349.73 123.55 356.14 123.54 362.56L123.5 415.09C123.51 424.27 123.71 433.46 123.59 442.63C123.54 445.83 123.72 450.87 123.24 453.95C122.58 454.39 122.11 454.47 121.32 454.47C113.74 454.47 106.13 454.4 98.55 454.39L53 454.4L30.95 454.4C26.85 454.41 15.13 455.12 13.83 451.95C12.37 448.4 12.83 431.38 12.92 426.83C13.05 420.3 12.6 413.84 12.88 408L12.94 404.38L12.91 367.06L12.99 351.18C12.87 348.38 12.25 342.36 14.17 340.27C15.91 338.38 22.08 338.53 24.57 338.62C32.74 338.89 40.87 338.62 49.03 338.64C47.27 333.85 46.62 327.21 45.4 322.26C44.79 317.6 44.54 315.99 49.83 316.16C51.95 316.22 55.21 316.33 57.24 316.12C58.41 316.25 58.99 316.23 60.17 316.19C60.93 316.2 62.08 316.26 62.79 316.12Z',
    0xFFFCFCFC,
    false
  ),
  (
    'M12.99 351.18C14.03 352.44 14.37 352.32 16.09 352.44C24.79 353.02 33.78 352.77 42.5 352.76L90.4 352.76L104.39 352.75C106.83 352.73 112.83 351.83 113.6 354.89C113.32 355.61 112.97 355.91 112.26 356.21C109.47 357.4 96.55 356.65 92.59 356.64L42.83 356.66L23.58 356.64C20.76 356.67 15.85 356.63 13.17 356.93C13.27 359.13 13.62 365.19 12.91 367.06L12.99 351.18Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M12.94 404.38L13.17 404.4C16.06 404.64 20.39 404.55 23.39 404.55L39.77 404.51L90 404.53C93.67 404.53 110.89 404.12 112.66 404.98C113.54 406.04 113.41 406.92 112.36 407.71C107.85 408.21 100.3 408 95.48 408L66.32 407.99L29.8 407.98C25.3 407.98 17.09 408.26 12.88 408L12.94 404.38Z',
    0xFFE0E7EF,
    false
  ),
  (
    'M51.07 371.06C54.86 370.99 71.05 370.35 73.59 371.67C74.31 372.05 74.78 372.71 74.95 373.5C75.14 374.38 75.1 375.47 74.58 376.23C73.93 377.19 72.93 377.49 71.86 377.72C68.38 377.85 51.44 378.38 49.48 377.28C48.84 376.92 48.25 376.26 48.06 375.54C47.84 374.68 47.84 373.18 48.38 372.43C49.02 371.55 50.06 371.26 51.07 371.06Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M50.36 422.08C54.22 421.83 70.2 421.44 73.15 422.43C73.91 422.68 74.49 423.18 74.8 423.94C75.12 424.76 75.21 426.06 74.76 426.85C74.2 427.81 73.51 428.15 72.5 428.48C66.65 428.79 60.74 428.63 54.89 428.73C53.36 428.75 49.07 428.82 48.41 427.32C47.23 424.67 48 423.22 50.36 422.08Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M337.59 131.37C347.12 127.43 356.83 124.49 367.05 128.58C375.1 131.8 376.47 135.99 380.32 142.44C393.64 147.96 395.57 161.46 390.62 173.75C387.06 182.58 376.93 193.98 369.01 199.52C369.55 202.27 370.42 209 371.25 211.18C372.2 212.18 372.38 212.3 373.59 212.98C369.88 222.34 352.38 233.09 342.14 228.54C336.39 225.99 335.87 220.81 336.86 215.38C337.71 215.11 337.97 215.06 338.75 214.57C339.2 213.57 338.99 213.48 338.89 212.21C338.52 209.88 338.4 207.85 338.61 205.49C337.4 205.95 336.64 206.07 335.32 205.99C311.99 204.57 318.03 171.6 321.56 156.43C311.56 150.06 315.6 132.56 327.63 130.92C331.74 130.36 333.45 130.51 337.59 131.37Z',
    0xFFFEBC8D,
    false
  ),
  (
    'M337.59 131.37C347.12 127.43 356.83 124.49 367.05 128.58C375.1 131.8 376.47 135.99 380.32 142.44C393.64 147.96 395.57 161.46 390.62 173.75C387.06 182.58 376.93 193.98 369.01 199.52C365.65 196.98 364.19 191.64 363.54 187.71C369.08 185.86 373 181.16 372.52 175.08C372.19 170.79 368.36 167.15 363.93 168C360.47 168.67 358.52 170.84 356.58 173.57C348.82 170.36 347.14 162.5 347.23 154.97C338.24 155.18 332.33 154.44 325.43 148.12C324.3 150.29 322.46 154.91 321.56 156.43C311.56 150.06 315.6 132.56 327.63 130.92C331.74 130.36 333.45 130.51 337.59 131.37Z',
    0xFF202E42,
    false
  ),
  (
    'M338.61 205.49C343.84 204.61 349.55 202.36 354.24 199.9C351.08 207.45 346.73 210.55 338.89 212.21C338.52 209.88 338.4 207.85 338.61 205.49Z',
    0xFFFA9A68,
    false
  ),
  (
    'M444.63 96.14C464.42 95.68 480.86 111.3 481.4 131.09C481.95 150.88 466.41 167.38 446.62 168.03C426.71 168.67 410.07 153 409.51 133.09C408.96 113.17 424.71 96.6 444.63 96.14Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M442.7 102.36C459.14 100.88 473.67 113.03 475.1 129.48C476.53 145.92 464.33 160.4 447.88 161.78C431.5 163.15 417.11 151.02 415.68 134.65C414.26 118.28 426.34 103.84 442.7 102.36Z',
    0xFFFCFCFC,
    false
  ),
  (
    'M444.92 112.48C446.36 112.5 447.64 112.76 447.8 114.41C448.25 119.43 448.01 125 447.98 130.02C451.12 129.99 459.59 129.21 461.38 131.49C461.84 133.08 461.16 133.94 459.82 134.7C456.96 135.02 445.67 135.57 443.69 134.07C442.5 131.58 443.09 118.2 443.23 114.77C443.27 113.63 444.07 113.08 444.92 112.48Z',
    0xFFC0D6F1,
    false
  ),
  (
    'M54.78 307.1C46.03 303.44 39.92 298.44 36.21 289.53C33.98 284.15 32.72 275.89 33.9 270.17C34.57 266.94 43.48 272.68 44.7 273.55C51.62 278.38 56.33 285.77 57.77 294.09C58.57 298.94 57.97 302.05 58.1 306.55C58.14 308.22 59.76 313.7 60.17 316.19C58.99 316.23 58.41 316.25 57.24 316.12C56.77 313.35 55.87 309.66 54.78 307.1Z',
    0xFF159B53,
    false
  ),
  (
    'M62.79 316.12C67.01 305.23 69.98 294.57 81.87 289.5C84.31 288.46 97.33 284.45 100.22 287.82C101.06 288.81 98.59 294.76 97.92 295.83C94.21 302.83 88.3 308.01 80.69 310.32C76.88 311.48 72.06 311.98 68.08 311.85C67.38 313.27 66.67 314.7 65.94 316.12L62.79 316.12Z',
    0xFF159B53,
    false
  ),
  (
    'M76.9 257.98C77.56 257.9 77.31 257.9 77.98 258.08C78.44 258.53 78.83 259.07 79.04 259.68C83.3 271.86 77.61 288.4 65.32 293.84L64.5 293.98C64.06 293.77 63.69 293.4 63.53 292.94C59.13 280.41 65.33 264.05 76.9 257.98Z',
    0xFF159B53,
    false
  ),
];
