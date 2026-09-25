// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

String _numText(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

// ================================================= กระดาน widget หน้าภาพรวม
// ทุกการ์ดในหน้าภาพรวมเป็น widget: มีแบบเต็ม (full) และแบบย่อ (compact)
// กดค้างแล้วลากไปวางช่องไหนก็ได้ในทุกคอลัมน์ · โหมดปรับแต่ง = ย่อ/ขยาย ลบ เพิ่ม
// จัดวางจำแยกตามผู้ใช้ (shared_preferences)

/// widget ทั้งหมดที่วางได้: รหัส → (ไอคอน, ชื่อ)
const Map<String, (IconData, String)> _boardCatalog = {
  'about': (Icons.badge_rounded, 'ข้อมูลผู้ป่วย'),
  'v_hr': (Icons.favorite_rounded, 'กราฟ HR'),
  'v_bp': (Icons.monitor_heart_rounded, 'กราฟ BP'),
  'v_spo2': (Icons.bubble_chart_rounded, 'กราฟ SpO₂'),
  'v_rr': (Icons.air_rounded, 'กราฟ RR'),
  'v_bt': (Icons.thermostat_rounded, 'กราฟ BT'),
  'allergy': (Icons.warning_amber_rounded, 'แพ้ยา / แพ้อาหาร'),
  'problems': (Icons.biotech_rounded, 'ปัญหา / วินิจฉัย'),
  'meds': (Icons.medication_rounded, 'ยาที่ให้แล้ว'),
  'labs': (Icons.science_rounded, 'ผลแล็บล่าสุด'),
  'imaging': (Icons.photo_library_rounded, 'ภาพถ่ายทางรังสี'),
  'follow': (Icons.checklist_rounded, 'งานที่ต้องติดตาม'),
  'activity': (Icons.timeline_rounded, 'กิจกรรมแพทย์ / พยาบาล'),
  'triage': (Icons.fact_check_rounded, 'ผลคัดกรอง'),
  'team': (Icons.groups_rounded, 'ทีมผู้ดูแล'),
  'note': (Icons.sticky_note_2_rounded, 'บันทึกล่าสุด'),
  'advice': (Icons.auto_awesome_rounded, 'คำแนะนำของระบบ'),
};

/// ความกว้างของ 4 คอลัมน์ (ซ้าย → ขวา) คอลัมน์ 2 กับ 3 ขนาบฉาก 3D
const List<double> _boardW = [250.0, 216.0, 264.0, 236.0];

const List<List<String>> _boardDefault = [
  ['v_hr', 'v_bp', 'v_spo2', 'v_rr'],
  ['allergy', 'problems', 'meds'],
  ['labs', 'imaging'],
  ['about', 'follow', 'activity', 'triage'],
];

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientSideBoardState on State<ErFlowHomeWidget> {
  /// การ์ดข้างวงโค้งตอนพูด: false = checklist · true = การ์ดฟอร์มจริง (generative UI)

  /// รอบสัญญาณชีพที่เลือกในกราฟแท่ง (key = ชื่อค่า) ไม่มี = รอบล่าสุด
  final Map<String, int> _vsPick = {};

  /// คอลัมน์ → [(รหัส widget, แบบย่อ)]
  List<List<(String, bool)>> _board = [
    for (final c in _boardDefault) [for (final id in c) (id, false)]
  ];
  bool _boardEdit = false;

  /// ตำแหน่งที่กำลังลากผ่าน (คอลัมน์, ช่อง) ไว้วาดเส้นบอกจุดวาง
  (int, int)? _boardHover;

  bool _boardDragging = false;

  /// ตารางคัดกรองต่อ HN (ข้อมูลจำลองคงที่) คำนวณครั้งเดียว ไม่สร้างใหม่ทุก build
  final Map<String, ErTable> _triageTable = {};

  int _bedVsAt = 0;
}

extension _FeaturesPatientSideBoardPart on _ErFlowHomeWidgetState {
  /// คอลัมน์ซ้าย: กราฟแท่งสัญญาณชีพทีละค่า + ช่องเพิ่ม
  Widget _problemsCard() => _detailBlock('ปัญหา / วินิจฉัย', [
        if (_case.dx.isEmpty)
          Text('ยังไม่มีการวินิจฉัย', style: _t(10.5, color: _ink3)),
        for (final d in _case.dx)
          Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7.0,
                  height: 7.0,
                  margin: const EdgeInsets.only(top: 4.0, right: 7.0),
                  decoration: BoxDecoration(
                      color: _levelColor(d.level), shape: BoxShape.circle),
                ),
                Expanded(
                  child:
                      Text(d.text, style: _t(11.0, color: _ink, height: 1.25)),
                ),
              ],
            ),
          ),
      ]);

  Widget _medsCard() => _detailBlock('ยาที่ให้แล้ว', [
        if (_case.meds.isEmpty)
          Text('ยังไม่ได้ให้ยา', style: _t(10.5, color: _ink3)),
        for (final m in _case.meds)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, weight: FontWeight.w600)),
                Row(
                  children: [
                    Expanded(
                      child: Text(m.route,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(9.5, color: _ink2)),
                    ),
                    Text(m.time, style: _num(9.5, color: _ink3)),
                  ],
                ),
              ],
            ),
          ),
      ]);

  Widget _labsCard() => _detailBlock('ผลแล็บล่าสุด · ${_case.times.last} น.', [
        if (_case.labs.isEmpty)
          Text('ยังไม่มีผลแล็บ', style: _t(10.5, color: _ink3)),
        if (_case.labs.isNotEmpty) ...[
          _labHead(),
          for (final l in _case.labs) _labRow(_labTuple(l)),
        ],
      ]);

  Widget _imagingCard() => _detailBlock('ภาพถ่ายทางรังสี', [
        if (_case.imaging.isEmpty)
          Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(10.5, color: _ink3)),
        Row(
          children: [
            for (final img in _case.imaging)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          height: 62.0,
                          color: Colors.black,
                          child: Image.asset(img.asset,
                              fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(img.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(9.5, weight: FontWeight.w600)),
                      Text(img.result,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(8.5, color: _ink2)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ]);

  /// หัวคอลัมน์ของตารางแล็บ
  Widget _labHead() => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          children: [
            Expanded(child: Text('รายการ', style: _t(8.5, color: _ink3))),
            Text('ค่า / ปกติ', style: _t(8.5, color: _ink3)),
          ],
        ),
      );

  /// ค่าแล็บหนึ่งบรรทัด — ชื่อ แถบจุดบอกว่าอยู่ตรงไหนของช่วง และค่า/ค่าปกติ
  ///
  /// แถบเป็นจุดถี่ ๆ ไม่ใช่แท่งทึบ อ่านระดับได้เป็นขั้น ๆ ตามผัง 181:3803
  /// ขีดคั่นคือเพดานปกติ จุดที่เลยขีดไปคือส่วนที่ผิดปกติ
  Widget _labRow((String, double, double, double) l) {
    final (name, value, lo, hi) = l;
    final bad = value < lo || value > hi;
    final tone = bad ? _red : _blue;
    const dots = 16;
    final scale = hi * 1.45;
    final filled = ((value / scale) * dots).round().clamp(0, dots);
    final markAt = ((hi / scale) * dots).round().clamp(1, dots - 1);
    // ค่าผิดปกติ: ตัวเลขแดงหนา + ป้าย H/L แบบรายงานแล็บ ไม่ลงสีทั้งแถว
    return Padding(
      padding: const EdgeInsets.only(bottom: 9.0),
      child: Row(
        children: [
          SizedBox(
            width: 58.0,
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.5, color: _ink, weight: FontWeight.w700)),
          ),
          Expanded(
            child: Container(
              height: 12.0,
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < dots; i++) ...[
                    if (i == markAt)
                      Container(
                        width: 1.2,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        color: _ink3,
                      ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 3.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: i < filled
                                ? tone
                                : _ink3.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            width: 70.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_numText(value),
                    style: _num(12.0,
                        color: bad ? _red : _ink,
                        weight: bad ? FontWeight.w800 : FontWeight.w600)),
                Text(' | ', style: _t(9.5, color: _ink3)),
                Text(_numText(hi), style: _num(9.5, color: _ink3)),
              ],
            ),
          ),
          SizedBox(
            width: 22.0,
            child: bad
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(value > hi ? 'H' : 'L',
                          style: _t(9.0,
                              color: Colors.white, weight: FontWeight.w800)),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------- คอลัมน์ 4 สรุปและทีม
  /// การ์ดหัวสีหลักคือสิ่งที่จะเกิดต่อไป ใต้ลงมาเป็นทีมดูแล บันทึก และคำแนะนำ
  Widget _sideWidget(String id) => switch (id) {
        'activity' => _activityCard(),
        'triage' => _triageCard(),
        'team' => _detailBlock('ทีมผู้ดูแล', [
            for (var i = 0; i < _case.team.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                  ClipOval(
                    child: Image.asset('assets/images/faces/face$i.jpg',
                        width: 26.0, height: 26.0, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_case.team[i].$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(10.5, weight: FontWeight.w600)),
                        Text(_case.team[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(9.0, color: _ink2)),
                      ],
                    ),
                  ),
                ]),
              ),
          ]),
        'note' => _detailBlock('บันทึกล่าสุด', [
            if (_case.lastNote == null)
              Text('ยังไม่มีบันทึก', style: _t(10.5, color: _ink3))
            else ...[
              Text('${_case.lastNote!.time} น. · ${_case.lastNote!.by}',
                  style: _t(9.5, color: _ink3)),
              const SizedBox(height: 3.0),
              Text(_case.lastNote!.text,
                  style: _t(10.5, color: _ink, height: 1.35)),
            ],
          ]),
        'advice' => _detailBlock('คำแนะนำของระบบ', [
            if (_case.advice.isEmpty)
              Text('ไม่มีคำแนะนำเพิ่มเติม', style: _t(10.5, color: _ink3)),
            for (final a in _case.advice)
              Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child:
                          Text(a, style: _t(10.0, color: _ink2, height: 1.3)),
                    ),
                  ],
                ),
              ),
          ]),
        _ => const SizedBox.shrink(),
      };

  String get _boardKey => 'er_overview_board_v2_$_uid';

  Future<void> _loadBoard() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_boardKey);
      if (raw == null) return;
      final cols = jsonDecode(raw) as List<dynamic>;
      final b = [
        for (final c in cols)
          [
            for (final w in c as List<dynamic>)
              if (_boardCatalog.containsKey(w['id']))
                ('${w['id']}', w['c'] == true)
          ]
      ];
      if (b.length == 4 && mounted) setState(() => _board = b);
    } catch (_) {}
  }

  Future<void> _saveBoard() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _boardKey,
          jsonEncode([
            for (final c in _board)
              [
                for (final (id, c) in c) {'id': id, 'c': c}
              ]
          ]));
    } catch (_) {}
  }

  void _boardSet(void Function() f) {
    setState(f);
    _saveBoard();
  }

  /// ย้าย widget (จากคอลัมน์ fc ช่อง fi) ไปคอลัมน์ tc ก่อนช่อง ti
  void _boardMove(int fc, int fi, int tc, int ti) => _boardSet(() {
        _boardHover = null;
        final w = _board[fc].removeAt(fi);
        if (fc == tc && fi < ti) ti -= 1;
        _board[tc].insert(ti.clamp(0, _board[tc].length), w);
      });

  Widget _boardFull(String id) {
    final vi = const ['v_hr', 'v_bp', 'v_spo2', 'v_rr', 'v_bt'].indexOf(id);
    if (vi >= 0) return _vitalBarsCard(_caseVitals()[vi]);
    return switch (id) {
      'about' => _aboutPatientCard(),
      'allergy' => _allergyCard(),
      'problems' => _problemsCard(),
      'meds' => _medsCard(),
      'labs' => _labsCard(),
      'imaging' => _imagingCard(),
      'follow' => _followWidget(),
      _ => _sideWidget(id),
    };
  }

  /// แบบย่อ: บรรทัดสรุปบรรทัดเดียวถึงสองบรรทัด ใช้พื้นที่น้อย
  Widget _boardCompact(String id) {
    final c = _case;
    final p = _sceneSelected(_open!);
    final (icon, name) = _boardCatalog[id]!;
    var tone = _ink;
    String value;
    final vi = const ['v_hr', 'v_bp', 'v_spo2', 'v_rr', 'v_bt'].indexOf(id);
    if (vi >= 0) {
      final v = _caseVitals()[vi];
      value = '${v.display ?? _vsValue(v, v.series.length - 1)} ${v.unit}';
      tone = v.color;
    } else {
      final abnLabs = [
        for (final l in c.labs)
          if (l.abnormal) l.name
      ];
      value = switch (id) {
        'about' => '${p.name} · ${c.sex} ${c.age} ปี · กรุ๊ป ${c.bloodGroup}',
        'allergy' => c.allergies.isEmpty ? 'ไม่มี' : c.allergies.join(', '),
        'problems' => c.dx.isEmpty ? 'ยังไม่มี' : c.dx.first.text,
        'meds' => c.meds.isEmpty
            ? 'ยังไม่ได้ให้ยา'
            : '${c.meds.length} รายการ · ล่าสุด ${c.meds.first.name}',
        'labs' => abnLabs.isEmpty
            ? 'ปกติทั้งหมด'
            : 'ผิดปกติ ${abnLabs.length}: ${abnLabs.join(', ')}',
        'imaging' => c.imaging.isEmpty
            ? 'ยังไม่ได้ส่ง'
            : c.imaging.map((i) => '${i.name} (${i.result})').join(', '),
        'activity' => c.events.isEmpty
            ? 'ยังไม่มี'
            : '${c.events.first.time} ${c.events.first.text}',
        'triage' =>
          '${p.esi == null ? 'รอคัดกรอง' : 'ESI ${p.esi!.level}'} · ${c.cc}',
        'follow' => () {
            final due = _reminders
                .where((r) => r.hn == p.hn && !r.done)
                .toList()
              ..sort((a, b) => a.due.compareTo(b.due));
            return '${_followTasks.length} งาน'
                '${due.isEmpty ? '' : ' · เตือนถัดไป ${due.first.title}'}';
          }(),
        'team' => c.team.map((t) => t.$1).join(', '),
        'note' => c.lastNote?.text ?? 'ยังไม่มีบันทึก',
        'advice' => c.advice.isEmpty ? 'ไม่มี' : c.advice.first,
        _ => '',
      };
      if ((id == 'allergy' && c.allergies.isNotEmpty) ||
          (id == 'labs' && abnLabs.isNotEmpty)) {
        tone = _red;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 9.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
            color: tone == _red ? _red.withValues(alpha: 0.35) : _line),
      ),
      child: Row(children: [
        Icon(icon, size: 15.0, color: tone == _red ? _red : _ink3),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: _t(9.0, color: _ink3)),
              Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.0,
                      color: tone == _red ? _red : _inkTitle,
                      weight: FontWeight.w700,
                      height: 1.3)),
            ],
          ),
        ),
      ]),
    );
  }

  /// เส้นบอกจุดวาง (ก่อนช่อง i ของคอลัมน์ col) ขึ้นเมื่อลากผ่าน
  Widget _boardLine(int col, int i) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: _boardHover == (col, i) ? 4.0 : 0.0,
        margin: EdgeInsets.only(bottom: _boardHover == (col, i) ? 8.0 : 0.0),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(100.0),
        ),
      );

  /// พื้นที่ท้ายคอลัมน์รับการวาง (ขยายสูงตอนกำลังลาก ให้วางท้ายคอลัมน์ได้ง่าย)
  Widget _boardTail(int col) => DragTarget<(int, int)>(
        onWillAcceptWithDetails: (_) {
          final at = (col, _board[col].length);
          if (_boardHover != at) setState(() => _boardHover = at);
          return true;
        },
        onAcceptWithDetails: (d) =>
            _boardMove(d.data.$1, d.data.$2, col, _board[col].length),
        builder: (_, cand, __) =>
            SizedBox(height: _boardDragging ? 160.0 : 8.0),
      );

  Widget _boardItem(int col, int i) {
    final (id, compact) = _board[col][i];
    final body = compact ? _boardCompact(id) : _boardFull(id);
    final w = _boardW[col] - 18.0;
    final card = !_boardEdit
        ? body
        : Stack(children: [
            // โหมดปรับแต่ง: ปิดการแตะในการ์ด (แต่ยังรับการกดค้างเพื่อลาก)
            // เหลือปุ่มควบคุมมุมขวาบน
            AbsorbPointer(child: body),
            Positioned(
              top: 6.0,
              right: 6.0,
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: _line),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x1A0B1B3F),
                        blurRadius: 8.0,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _boardCtl(
                      compact
                          ? Icons.unfold_more_rounded
                          : Icons.unfold_less_rounded,
                      compact ? 'ขยาย' : 'ย่อ',
                      () => _boardSet(() => _board[col][i] = (id, !compact))),
                  _boardCtl(Icons.close_rounded, 'เอาออก',
                      () => _boardSet(() => _board[col].removeAt(i)),
                      color: _red),
                ]),
              ),
            ),
          ]);
    final drag = LongPressDraggable<(int, int)>(
      data: (col, i),
      hapticFeedbackOnStart: true,
      delay: Duration(milliseconds: _boardEdit ? 120 : 380),
      // จุดยึดที่นิ้ว: การ์ดลอยอยู่ใต้นิ้ว และตำแหน่งวางคิดจากนิ้วจริง
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => setState(() => _boardDragging = true),
      onDragEnd: (_) => setState(() {
        _boardHover = null;
        _boardDragging = false;
      }),
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.2),
        child: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.03,
            child: Container(
              width: w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x330B1B3F),
                      blurRadius: 24.0,
                      offset: Offset(0, 10)),
                ],
              ),
              child: IgnorePointer(child: body),
            ),
          ),
        ),
      ),
      childWhenDragging:
          Opacity(opacity: 0.25, child: IgnorePointer(child: body)),
      child: card,
    );
    // การ์ดเป็นเป้าวาง: ครึ่งบน = วางก่อน ครึ่งล่าง = วางหลัง
    return Builder(
      builder: (ctx) => DragTarget<(int, int)>(
        onMove: (d) {
          final box = ctx.findRenderObject() as RenderBox?;
          if (box == null) return;
          final y = box.globalToLocal(d.offset).dy;
          final at = (col, y < box.size.height / 2 ? i : i + 1);
          if (_boardHover != at) setState(() => _boardHover = at);
        },
        onAcceptWithDetails: (d) {
          final at = _boardHover;
          if (at != null && at.$1 == col) {
            _boardMove(d.data.$1, d.data.$2, col, at.$2);
          }
        },
        builder: (_, __, ___) => drag,
      ),
    );
  }

  Widget _boardCtl(IconData icon, String tip, VoidCallback onTap,
          {Color color = _ink2}) =>
      _Press(
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tip,
            child: SizedBox(
                width: 28.0,
                height: 28.0,
                child: Icon(icon, size: 16.0, color: color)),
          ),
        ),
      );

  /// หนึ่งคอลัมน์ของกระดาน: ช่องวางคั่นทุกการ์ด + ท้ายคอลัมน์
  /// เผื่อที่ใต้คอลัมน์ให้พ้นแถบงานพยาบาล / ปุ่มลัด
  double get _boardBottom => ErSession.instance.isNurse ? 100.0 : 80.0;

  Widget _boardColumn(int col) {
    final items = _board[col];
    final pad = switch (col) {
      0 => EdgeInsets.fromLTRB(12.0, 12.0, 6.0, _boardBottom),
      3 => EdgeInsets.fromLTRB(6.0, 12.0, 12.0, _boardBottom),
      _ => EdgeInsets.fromLTRB(6.0, 12.0, 6.0, _boardBottom),
    };
    return SizedBox(
      width: _boardW[col],
      child: ListView(
        padding: pad,
        children: [
          for (var i = 0; i < items.length; i++)
            // พยาบาลเห็นงานที่ต้องติดตามในแถบล่างแล้ว ไม่ซ้ำในกระดาน
            if (!(items[i].$1 == 'follow' && ErSession.instance.isNurse)) ...[
              _boardLine(col, i),
              KeyedSubtree(
                  key: ValueKey('${items[i].$1}_$col'),
                  child: _boardItem(col, i)),
            ],
          _boardLine(col, items.length),
          _boardTail(col),
          if (_boardEdit) _boardAdd(col),
        ],
      ),
    );
  }

  /// ปุ่มเพิ่ม widget ท้ายคอลัมน์ (โหมดปรับแต่ง): เมนูเล็กติดปุ่ม เลือก widget ที่ยังไม่ได้วาง
  Widget _boardAdd(int col) {
    final placed = {
      for (final c in _board)
        for (final (id, _) in c) id
    };
    final left = [
      for (final e in _boardCatalog.entries)
        if (!placed.contains(e.key)) e
    ];
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4.0),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(_panel),
        elevation: const WidgetStatePropertyAll(8.0),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
      ),
      menuChildren: [
        if (left.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('วางครบทุก widget แล้ว', style: _t(10.5, color: _ink3)),
          ),
        for (final e in left)
          MenuItemButton(
            style: MenuItemButton.styleFrom(
              minimumSize: const Size(220.0, 40.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
            leadingIcon: Icon(e.value.$1, size: 17.0, color: _ink3),
            onPressed: () =>
                _boardSet(() => _board[col] = [..._board[col], (e.key, false)]),
            child: Text(e.value.$2,
                style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
          ),
      ],
      builder: (_, menu, __) => _Press(
        scale: 0.98,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.0),
            onTap: () => menu.isOpen ? menu.close() : menu.open(),
            child: Container(
              height: 44.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: _line, width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, size: 18.0, color: _ink3),
                const SizedBox(width: 4.0),
                Text('เพิ่ม widget',
                    style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  /// ปุ่มเข้า/ออกโหมดปรับแต่งหน้า (มุมบนกลาง ข้างปุ่มสลับภาพ/ตาราง)
  Widget _boardEditButton() => _Press(
        child: Material(
          color: _boardEdit ? _blue : _panel,
          borderRadius: BorderRadius.circular(100.0),
          elevation: 2.0,
          shadowColor: const Color(0x220B1B3F),
          child: InkWell(
            borderRadius: BorderRadius.circular(100.0),
            onTap: () => setState(() => _boardEdit = !_boardEdit),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    _boardEdit
                        ? Icons.check_rounded
                        : Icons.dashboard_customize_rounded,
                    size: 15.0,
                    color: _boardEdit ? Colors.white : _ink2),
                const SizedBox(width: 5.0),
                Text(_boardEdit ? 'เสร็จ' : 'ปรับแต่ง',
                    style: _t(11.0,
                        color: _boardEdit ? Colors.white : _ink2,
                        weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );

  /// ย้อนการจัดวางเป็นค่าเริ่มต้น
  Widget _boardResetButton() => _Press(
        child: TextButton(
          onPressed: () => _boardSet(() => _board = [
                for (final c in _boardDefault) [for (final id in c) (id, false)]
              ]),
          child: Text('คืนค่าเริ่มต้น',
              style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
        ),
      );

  Widget _sideKpi(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: _t(9.0, color: _pInk3)),
          Text(value, style: _num(12.5, color: _pInk, weight: FontWeight.w700)),
        ],
      );

  /// กล่องหัวข้อหนึ่งบล็อกในคอลัมน์ของหน้ารายละเอียด
  /// การ์ดข้อมูลผู้ป่วย + ขั้นถัดไป (การ์ดหลักคอลัมน์ขวา พื้นสีหลัก)
  /// บน: ตัวตนและข้อมูลพื้นฐาน · ล่าง: สิ่งที่จะเกิดต่อไป เตียง ESI เวลารอ
  Widget _aboutPatientCard() {
    final p = _sceneSelected(_open!);
    final c = _case;
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70.0,
                child: Text(label, style: _t(9.5, color: _pInk3)),
              ),
              Expanded(
                child: Text(value.isEmpty ? '—' : value,
                    style: _t(10.5, color: _pInk, weight: FontWeight.w600)),
              ),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ข้อมูลผู้ป่วย',
              style: _t(10.5, color: _pInk3, weight: FontWeight.w600)),
          const SizedBox(height: 6.0),
          Text(p.name, style: _t(14.0, color: _pInk, weight: FontWeight.w700)),
          Text('${c.sex} · ${c.age} ปี · HN ${p.hn}',
              style: _t(10.0, color: _pInk2)),
          const SizedBox(height: 8.0),
          row('หมู่เลือด', c.bloodGroup),
          row('สิทธิการรักษา', c.right),
          row('โรคประจำตัว', c.underlying.join(', ')),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1.0, thickness: 1.0, color: _pLine),
          ),
          Text('ขั้นถัดไป',
              style: _t(10.5, color: _pInk3, weight: FontWeight.w600)),
          const SizedBox(height: 4.0),
          Text(c.nextStep.isEmpty ? 'รอแพทย์' : c.nextStep,
              style: _t(15.0, color: _pInk, weight: FontWeight.w700)),
          if (c.nextDetail.isNotEmpty)
            Text(c.nextDetail, style: _t(10.5, color: _pInk2)),
          const SizedBox(height: 10.0),
          Row(
            children: [
              _sideKpi('เตียง', p.bed ?? '—'),
              const SizedBox(width: 14.0),
              _sideKpi('ESI', '${p.esi?.level ?? '—'}'),
              const SizedBox(width: 14.0),
              _sideKpi('รอแล้ว', _hm(p.waitMin)),
            ],
          ),
        ],
      ),
    );
  }

  /// การ์ดกิจกรรมของแพทย์และพยาบาล: เส้นเวลาใหม่ → เก่า 5 รายการล่าสุด
  /// จุดสีหลัก = แพทย์ · จุดเขียว = พยาบาล · "ดูทั้งหมด" เปิดลิ้นชักเส้นเวลา
  Widget _activityCard() {
    final ev = _case.events;
    final shown = ev.take(5).toList();
    return _detailBlock('กิจกรรมแพทย์ / พยาบาล', [
      if (ev.isEmpty) Text('ยังไม่มีกิจกรรม', style: _t(10.5, color: _ink3)),
      for (var i = 0; i < shown.length; i++)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 14.0,
                child: Column(children: [
                  const SizedBox(height: 4.0),
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: shown[i].byDoctor ? _blue : _blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < shown.length - 1)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        color: _line,
                      ),
                    ),
                ]),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${shown[i].time} น. · ${shown[i].byDoctor ? 'แพทย์' : 'พยาบาล'}',
                          style: _num(9.0, color: _ink3)),
                      const SizedBox(height: 1.0),
                      Text(shown[i].text,
                          style: _t(10.5, color: _ink, height: 1.3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      if (ev.length > shown.length)
        GestureDetector(
          onTap: () => setState(() => _timelineOpen = true),
          child: Text('ดูทั้งหมด ${ev.length} รายการ',
              style: _t(10.0, color: _blue, weight: FontWeight.w700)),
        ),
    ]);
  }

  /// การ์ดผลคัดกรอง: สรุปจากแบบคัดกรอง (ตารางเดียวกับแท็บคัดกรอง)
  /// ESI + การมา + อาการสำคัญ + สัญญาณชีพแรกรับ + GCS/รูม่านตา
  Widget _triageCard() {
    final p = _sceneSelected(_open!);
    final t =
        _triageTable.putIfAbsent(p.hn, () => erTableFor(p.hn, ErTab.triage));
    final val = <String, String>{};
    final bad = <String>{};
    for (var i = 0; i < t.rows.length; i++) {
      val[t.rows[i][1]] = t.rows[i][2];
      if (t.isAlert(i, 2)) bad.add(t.rows[i][1]);
    }
    String g(String k) => val[k] ?? '-';
    String first(String k) => g(k).split(' ').first;
    final esi = p.esi;
    Widget tile(String label, String key, String unit) {
      final alert = bad.contains(key);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: alert ? _red.withValues(alpha: 0.08) : _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: _t(9.0, color: alert ? _red : _ink3)),
            Text.rich(
                maxLines: 1,
                TextSpan(children: [
                  TextSpan(
                      text: g(key),
                      style: _num(12.0,
                          color: alert ? _red : _ink, weight: FontWeight.w700)),
                  TextSpan(text: unit, style: _t(8.5, color: _ink3)),
                ])),
          ],
        ),
      );
    }

    return _detailBlock('ผลคัดกรอง', [
      Text(g('พยาบาลคัดกรอง / เวลา'), style: _t(9.5, color: _ink3)),
      const SizedBox(height: 8.0),
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: esi == null ? _g5 : esi.hue,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(
              esi == null ? 'รอประเมิน' : 'ESI ${esi.level} · ${esi.label}',
              style: _t(9.5, color: Colors.white, weight: FontWeight.w700)),
        ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(g('ประเภทผู้ป่วย'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 10.0),
      Text(g('อาการสำคัญ'),
          style: _t(10.5, color: _ink, weight: FontWeight.w600, height: 1.35)),
      const SizedBox(height: 12.0),
      for (final r in const [
        [
          ('BT', 'อุณหภูมิ (°C)', '°C'),
          ('BP', 'ความดัน (mmHg)', ''),
          ('PR', 'อัตราการเต้นชีพจร (/min)', ''),
        ],
        [
          ('RR', 'อัตราการหายใจ (/min)', ''),
          ('SpO₂', 'ออกซิเจนในเลือด (%)', '%'),
          ('Pain', 'ระดับความเจ็บปวด (0-10)', '/10'),
        ],
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(children: [
            for (var i = 0; i < r.length; i++) ...[
              if (i > 0) const SizedBox(width: 6.0),
              Expanded(child: tile(r[i].$1, r[i].$2, r[i].$3)),
            ],
          ]),
        ),
      const SizedBox(height: 6.0),
      Text(
          'GCS ${first('การลืมตา')} ${first('ตอบสนองการพูด')} ${first('การเคลื่อนไหว')}'
          ' · ${g('ความรู้สึกตัว')} · Pupils ${g('ด้านซ้าย (L)').split(' · ').first}',
          style: _t(9.5,
              color: bad.contains('ความรู้สึกตัว') ? _red : _ink2,
              weight: FontWeight.w600)),
    ]);
  }

  /// การ์ดแพ้ยา/แพ้อาหาร: โครงเดียวกับการ์ดอื่น (_detailBlock)
  /// เน้นด้วยสีแดงเฉพาะจุด: ขอบจาง หัวข้อมีไอคอนเตือน ป้ายชื่อสิ่งที่แพ้ตัวหนาขึ้น
  Widget _allergyCard() {
    final list = _case.allergies;
    if (list.isEmpty) {
      return _detailBlock('แพ้ยา / แพ้อาหาร', [
        Text('ไม่มีประวัติแพ้', style: _t(10.5, color: _ink3)),
      ]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _red.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 14.0, color: _red),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text('แพ้ยา / แพ้อาหาร',
                    style: _t(10.5, color: _red, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                for (final a in list)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text(a,
                        style: _t(11.5, color: _red, weight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBlock(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }

  /// การ์ดกราฟแท่งของสัญญาณชีพหนึ่งค่า แท่งสุดท้ายคือค่าล่าสุด
  /// ค่าของแท่งที่ i (ความดันแสดงเป็น ตัวบน/ตัวล่าง)
  String _vsValue(ErVital v, int i) {
    final c = _case;
    if (v.unit == 'mmHg' && i < c.sbp.length && i < c.dbp.length) {
      return '${c.sbp[i].round()}/${c.dbp[i].round()}';
    }
    final x = v.series[i];
    return x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
  }

  /// กราฟแท่งสัญญาณชีพ: ทุกแท่งมีค่ากำกับ แตะหรือลากนิ้วบนกราฟเพื่อเลือกรอบ
  /// หัวการ์ดแสดงค่า + เวลาของรอบที่เลือก (ตั้งต้น = รอบล่าสุด)
  Widget _vitalBarsCard(ErVital v, {List<String>? times, bool bare = false}) {
    final ts = times ?? _case.times;
    // สีเดียว (น้ำเงิน) ทุกกราฟ แดงเฉพาะค่าล่าสุดที่ผิดปกติ
    final acc = v.color == _red ? _red : _blue;
    final lo = v.series.reduce((a, b) => a < b ? a : b);
    final hi = v.series.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;
    final n = v.series.length;
    final pick = (_vsPick[v.label] ?? n - 1).clamp(0, n - 1);
    final picked = pick != n - 1;
    final time = pick < ts.length ? ts[pick] : '';
    void choose(double dx, double w) {
      final idx = (dx / w * n).floor().clamp(0, n - 1);
      if (idx != _vsPick[v.label]) setState(() => _vsPick[v.label] = idx);
    }

    return Container(
      margin: bare ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10.0),
      padding: bare
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
      decoration: bare
          ? null
          : BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: picked ? acc : _line),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(v.icon, size: 14.0, color: acc),
              const SizedBox(width: 6.0),
              Text(v.label,
                  style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
              const Spacer(),
              if (picked) ...[
                Text('$time น.', style: _num(9.0, color: _ink3)),
                const SizedBox(width: 5.0),
              ],
              // ค่าเปลี่ยนตามแท่งที่แตะ: เลื่อนขึ้นจาง ๆ ให้รู้ว่าค่าเปลี่ยน
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position:
                        Tween(begin: const Offset(0, 0.35), end: Offset.zero)
                            .animate(a),
                    child: c,
                  ),
                ),
                child: Text(
                    key: ValueKey(pick),
                    picked
                        ? _vsValue(v, pick)
                        : (v.display ?? _vsValue(v, pick)),
                    style: _num(14.0, color: v.color, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 3.0),
              Text(v.unit, style: _t(9.5, color: _ink3)),
            ],
          ),
          const SizedBox(height: 6.0),
          SizedBox(
            height: 84.0,
            child: LayoutBuilder(builder: (context, box) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => choose(d.localPosition.dx, box.maxWidth),
                // ในการ์ดรายเตียง ลากแนวนอน = เลื่อนไปกราฟถัดไป (แตะเพื่อเลือกเวลา)
                onHorizontalDragUpdate: bare
                    ? null
                    : (d) => choose(d.localPosition.dx, box.maxWidth),
                onDoubleTap: () => setState(() => _vsPick.remove(v.label)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(_vsValue(v, i),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: _num(n > 4 ? 7.5 : 8.5,
                                    color: i == pick ? v.color : _ink3,
                                    weight: i == pick
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                            const SizedBox(height: 2.0),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              height: 10.0 + (v.series[i] - lo) / span * 34.0,
                              decoration: BoxDecoration(
                                // ประวัติเป็นเทา สีอยู่ที่แท่งที่เลือก/ล่าสุดเท่านั้น
                                color: i == pick
                                    ? acc
                                    : _g5.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(i < ts.length ? ts[i] : '',
                                style: _num(8.0,
                                    color: i == pick ? _ink2 : _ink3)),
                          ],
                        ),
                      ),
                      if (i < n - 1) const SizedBox(width: 6.0),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// กราฟสัญญาณชีพของการ์ดรายเตียง: หน้าละหนึ่งค่า ปัดเปลี่ยน + จุดบอกหน้า
  Widget _bedVitals(ErCase c) {
    final vs = _vitalsFor(c);
    final at = _bedVsAt.clamp(0, vs.length - 1);
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: vs.length,
            onPageChanged: (i) => setState(() => _bedVsAt = i),
            itemBuilder: (_, i) =>
                _vitalBarsCard(vs[i], times: c.times, bare: true),
          ),
        ),
        const SizedBox(height: 6.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < vs.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: i == at ? 14.0 : 5.0,
                height: 5.0,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: i == at ? _blue : _ink3.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
