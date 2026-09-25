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

/// ขั้นตรวจร่างกายในโหมดพูดของแพทย์
const int _peStep = 2;

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
}

extension _FeaturesPatientExamTabPart on _ErFlowHomeWidgetState {
  /// แท็บตรวจร่างกายในการ์ดขวา: สลับ ROS/PE · รอบการตรวจ · เทียบครั้งก่อน · ระบบ · บันทึก
  List<Widget> _examPanelItems() {
    final rs = _examRounds;
    final at = (_examSel ?? rs.length - 1).clamp(0, rs.length - 1);
    final systems = _examMode == 0 ? _rosSystems : _peSystems;
    final doctor = !ErSession.instance.isNurse;
    return [
      _segmented(
          const ['ทบทวนระบบ (ROS)', 'ตรวจร่างกาย (PE)'],
          _examMode,
          (i) => setState(() {
                _examMode = i;
                _examSel = null;
                _examSys = null;
              })),
      if (doctor && _examMode == 1) ...[
        const SizedBox(height: 8.0),
        Row(children: [
          Expanded(
            child: _uiButton(
                'Template การตรวจ', Icons.bookmarks_rounded, _openPeTemplates,
                primary: false),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _uiButton('บันทึกครั้งใหม่ด้วยเสียง', Icons.mic_rounded,
                () => _openSpeech(step: _peStep)),
          ),
        ]),
      ],
      const SizedBox(height: 10.0),
      _examRoundsCard(rs, at),
      const SizedBox(height: 10.0),
      _examChangeCard(systems, rs, at),
      const SizedBox(height: 10.0),
      for (final sy in systems) _examSysPill(sy, rs, at),
      const SizedBox(height: 6.0),
      _examNoteCard(systems, rs, at),
    ];
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
                                rs[i].time == 'ครั้งนี้' ? 'ใหม่' : rs[i].time,
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

  /// สลับสองทางแบบเต็มความกว้าง ตัวที่เลือกเป็นสีหลัก
  Widget _segmented(List<String> items, int index, ValueChanged<int> onPick) =>
      Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Material(
                  color: i == index ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onPick(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Center(
                        child: Text(items[i],
                            style: _t(10.5,
                                color: i == index ? Colors.white : _ink2,
                                weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
