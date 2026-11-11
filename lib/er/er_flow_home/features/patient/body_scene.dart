// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// หน้าผู้ป่วย: ชนิดป้ายบนหุ่นที่แสดง (toggle แยก PE · CC · DX)
/// ค่าเริ่มต้นต่อผู้ป่วย: เปิด CC เสมอ · เปิด DX/PE เมื่อผู้ป่วยมีป้ายชนิดนั้น
final Set<String> _bodyTags = {'CC'};

/// HN ที่ตั้งค่าเริ่มต้นของ _bodyTags แล้ว (เปลี่ยนคน = ตั้งใหม่ · ผู้ใช้สลับเองแล้วคงไว้)
String? _bodyTagsHn;

/// ชื่อส่วนของร่างกายจากกระดูก rig (.L/.R = ซ้าย/ขวาของผู้ป่วย)
const Map<String, String> _boneTh = {
  'Head': 'ศีรษะ',
  'Neck': 'คอ',
  'Chest': 'หน้าอก',
  'Belly': 'ท้อง',
  'Pelvis': 'สะโพก/ท้องน้อย',
  'Collar': 'ไหล่',
  'UpperArm': 'ต้นแขน',
  'Forearm': 'แขนท่อนล่าง',
  'Palm': 'มือ',
  'Hip': 'ต้นขา',
  'Shin': 'ขาท่อนล่าง',
  'Foot': 'เท้า',
  'Toes': 'นิ้วเท้า',
};

String _organTh(Object? o) => switch (o) {
      'brain' => 'สมอง',
      'heart' => 'หัวใจ',
      'lungs' => 'ปอด',
      'liver' => 'ตับ',
      'stomach' => 'กระเพาะ',
      'kidneys' => 'ไต',
      'intestine' => 'ลำไส้',
      'bladder' => 'กระเพาะปัสสาวะ',
      _ => '',
    };

/// เดาอวัยวะจากคำในวินิจฉัยและอาการสำคัญ (คำไทย/อังกฤษที่พบบ่อยใน ER)
List<String> _organsOfCase(ErCase c) {
  // ใช้ตัว map กลาง (er_body_map.dart) เอาเฉพาะอวัยวะ
  final out = [
    for (final t in erBodyTargets(c))
      if (t.kind == ErBodyKind.organ) t.id,
  ];
  return out.isEmpty ? const ['heart'] : out.take(3).toList();
}

/// ตำแหน่งบนร่างกายของเคส (อวัยวะ + กระดูก) ส่งให้หุ่นสามมิติ
List<String> _bodyCodesOfCase(ErCase c) => erBodyCodes(c);

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
/// สั่งฉาก 3D หน้าผู้ป่วย (ถ่ายภาพหุ่นให้ transition เข้า studio วาดภาพ)
final ErRoomDrawCtl _sceneCtl = ErRoomDrawCtl();

/// ระยะกล้องตั้งต้น: เห็นหุ่นทั้งตัว (หัวถึงเท้า) ในพื้นที่หุ่นฝั่งขวา
const double _clyZoomFit = 1.4;

mixin _FeaturesPatientBodySceneState on State<ErFlowHomeWidget> {
  /// สัดส่วนความกว้างฉากหุ่น (ซ้าย) · ลากขอบแผงขวาเพื่อปรับ
  double _clySplit = 0.338;

  /// สัดส่วนฝั่งขวาตอนกาง workflow (เริ่ม 40% · ลากปรับได้แยกจากตอนหุบ)
  double _wfSplit = 0.4;

  /// สัดส่วนระหว่าง animate กาง/หุบ workflow (ตั้งใน _detailPage ทุกเฟรม)
  double? _clySplitNow;

  /// ชั้นกายวิภาคที่กำลังดูในหน้ารายละเอียด skin | bone | organ | vessel
  String _layer = 'skin';

  /// ตำแหน่งบนจอของจุดสำคัญบนตัวหุ่น (จากฉากสามมิติ) ไว้วางเครื่องหมายอาการ
  /// ฉากส่งมาทุกเฟรมตอนกล้องเคลื่อน: เก็บใน notifier ให้ rebuild แค่ชั้นป้าย/วงเพ่ง ไม่ใช่ทั้งหน้า
  final ValueNotifier<List<ErBedScreenPos>> _hotspotsN =
      ValueNotifier(const []);
  List<ErBedScreenPos> get _hotspots => _hotspotsN.value;

  /// ตำแหน่งอาการที่กดเข้าไปดูรายละเอียด (drill-down) · null = ไม่เปิด
  ErBodyTarget? _symOpen;

  // ------------------------------------------------ ภาพรวม: แบบ ClyHealth
  // ซ้าย = รางระบบร่างกาย + หุ่น 3D ครึ่งจอ + การ์ดแจ้งเตือนมุมล่าง
  // ขวา = แผงกระจก: หัวระบบ + แถบความเสี่ยง · KPI · ค่าที่ต้องจับตา
  //        · แผนการดูแล (แท็บ) · แถบขั้นถัดไป

  /// ระบบที่เลือกบนราง (0 = ภาพรวม)
  int _clySys = 0;

  /// ซูมหุ่น (ปุ่ม + / − / พอดีจอ)
  /// ทิศที่เลื่อนผู้ป่วยล่าสุด (‹ = -1 · › = 1) ใช้เลื่อนการ์ดเข้าจากฝั่งนั้น
  int _sceneDir = 1;
  double _clyZoom = _clyZoomFit;
  int _clyZoomTick = 1;
}

/// debug: ค่ากล้องฉากเตียงหน้า ward ที่ปรับจากแผง (ค่าเริ่มต้น = ErCam())
ErCam _roomCam = const ErCam();
bool _roomDbg = false;

extension _FeaturesPatientBodyScenePart on _ErFlowHomeWidgetState {
  /// ฉากสามมิติที่ใช้ในแต่ละโหมด
  ///
  /// ภาพรวม = ฉากทั้งแผนกจากโมเดล Meshy (ย่อจาก 22.9 MB เหลือ 1.3 MB)
  /// เลือกช่วงงานแล้ว = ฉากเตียงชุดเดียวกับหน้าผังเตียง เห็นว่าใครอยู่เตียงไหน
  Widget _sceneFor(_Phase? phase) {
    if (phase == null) {
      // ภาพฉากกระแสงานจาก Figma (175:2979) เป็น PNG พื้นโปร่ง
      // จึงไม่มีปัญหาสีพื้นไม่ตรงกับพื้นแอปเหมือนตอนใช้วิดีโอ
      // เว้นขอบบนให้พ้นปุ่มกระดิ่ง ฉากจึงจัดกลางในพื้นที่ที่มองเห็นจริง
      // กว้าง 88% ของฝั่งขวา จัดกลาง — ใหญ่กว่าแบบ contain ล้วน
      // ส่วนที่ล้นบน-ล่างถูก ClipRect ของฉากตัด
      return Padding(
        // ขอบบนมากกว่าล่าง = ฉากอยู่ต่ำลงจากกึ่งกลางเล็กน้อย
        padding: const EdgeInsets.only(top: 66.0),
        child: Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.88,
            child: OverflowBox(
              alignment: Alignment.center,
              maxHeight: double.infinity,
              child: Image.asset(
                'assets/images/flow/er_flow_scene.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      );
    }
    final people = _ofPhase(phase);
    // เตียงในฉากมีคงที่ตามห้อง คนที่ยังไม่ได้เตียงจึงไม่ปรากฏในฉากนี้
    final byBed = {
      for (final p in people)
        if (p.bed != null) p.bed!: p,
    };
    final sel = _sceneSelected(phase);
    bool female(String hn) => erCaseOf(hn).sex.contains('หญิง');
    // ผู้ป่วยที่ยังไม่ได้เตียง: หน้ารายละเอียดยืมเตียงแรกแสดงร่าง ใช้เพศของคนนี้แทน
    final borrow = _detail && sel.bed == null ? _roomBeds.first : null;
    final beds = [
      for (final code in _roomBeds)
        ErRoomBed(
          code: code,
          color: byBed[code]?.esi?.color ?? _ink3,
          vacant: !byBed.containsKey(code) && code != borrow,
          female: code == borrow
              ? female(sel.hn)
              : (byBed[code] != null && female(byBed[code]!.hn)),
        ),
    ];
    // studio วาดภาพเปิดอยู่: ใช้ฉากตัวเดิม แต่ค่าตาม studio (หุ่นลายเส้น หมุด ป้าย)
    _peSeedOnce();
    Widget room0(_PeSceneCfg? cfg) => ErRoom3D(
          // GlobalObjectKey ให้ WebView ตัวเดิมย้ายไปอยู่หน้ารายละเอียดได้
          // กล้องจึงเลื่อนต่อเนื่อง ไม่ต้องโหลดฉากใหม่
          // key เดียวทุกช่วงงาน: สลับช่วงงานใช้ WebView ตัวเดิม (ส่งเตียงใหม่ผ่าน JS)
          // ไม่สร้างฉากใหม่ = ไม่โหลด three.js + ห้อง 3 MB ซ้ำทุกครั้งที่กดแท็บ
          key: const GlobalObjectKey('er-room-3d'),
          // ถ่ายภาพฉากหุ่นตอนเปิด studio วาดภาพ (ภาพเริ่มของ transition หุ่น → ซ้าย)
          drawCtl: _sceneCtl,
          beds: beds,
          // ยังไม่ได้เตียง: หน้าผังเตียง = กล้องไปที่นั่งรอ · หน้ารายละเอียดยืมเตียงแรก
          // ไม่มีเตียง = ช่องนั่งรอของคนนี้ (ลำดับเดียวกับรายการ waiting ด้านล่าง)
          selectedCode: sel.bed ??
              (_detail
                  ? _roomBeds.first
                  : 'WAIT:${[
                      for (final p in people)
                        if (p.bed == null) p.hn
                    ].indexOf(sel.hn).clamp(0, 999)}'),
          cam: _roomCam,
          onBedTap: (code) {
            final hit = byBed[code];
            if (hit != null) setState(() => _sceneHn = hit.hn);
          },
          topView: _detail,
          pageBg: _clyOn ? 0xF1F3F4 : 0xFFFFFF,
          zoom: _clyZoom,
          zoomTick: _clyZoomTick,
          layer: cfg != null ? 'skin' : (_detail ? _layer : 'skin'),
          highlight: cfg != null
              ? cfg.highlight
              : _detail
                  ? (_summaryOpen ? _summaryOrgans() : _highlightOrgans())
                  : const [],
          regionLines: cfg != null,
          cloth: cfg == null,
          regionSel: cfg?.regionSel,
          draw: cfg?.draw,
          onDrawStroke: cfg?.onStroke,
          onDrawErase: cfg?.onErase,
          onHotspots: (list) {
            if (cfg != null) {
              cfg.onHotspots?.call(list);
              return;
            }
            if (!mounted || !_detail) return;
            // ฉากส่งตำแหน่งมาเรื่อย ๆ (แม้นิ่ง) · อัปเดตเฉพาะตอนขยับจริง
            if (!_samePos(_hotspots, list)) _hotspotsN.value = list;
          },
          // เส้นที่วาดบนหุ่น 3D ในภาพการตรวจร่างกาย (studio) แสดงบนตัวหุ่นของผู้ป่วยรายนี้
          drawings: cfg != null
              ? cfg.drawings
              : _detail
                  ? [
                      for (final x in _peShots[_case.hn] ?? const <_PeShot>[])
                        ...x.d3
                    ]
                  : const [],
          // ช่องตำแหน่งบาดแผลเปิดอยู่: แตะบนหุ่นเพื่อระบุตำแหน่ง
          pickMode: cfg == null && _detail && _woundField != null,
          onBodyPick: _onBodyPick,
          // หน้าภาพรวมห้อง: จอ monitor เหนือหัวเตียงที่เลือกแสดง V/S · หน้ารายละเอียด = ซ่อน
          vitals: _detail ? null : _sceneVitalsData(sel),
          // คนที่ยังไม่ได้เตียง: นั่งเก้าอี้แถวต่อท้ายแถวเตียง · มารถนั่ง = รถเข็น
          // (ข้อมูลจำลองไม่มีสภาพ "รถนั่ง" จึงถือว่ารถพยาบาล/ส่งต่อมาด้วยรถเข็น)
          waiting: _detail
              ? const []
              : [
                  for (final p in people)
                    if (p.bed == null)
                      () {
                        final c = erCaseOf(p.hn);
                        final how = _regSent[p.hn]?.$1 ?? c.arrival;
                        return ErRoomWaiter(
                          color: p.esi?.color ?? _ink3,
                          female: c.sex.contains('หญิง'),
                          wheelchair: how == 'รถนั่ง' ||
                              how.startsWith('ส่งตัว') ||
                              how.startsWith('ส่งต่อ'),
                        );
                      }(),
                ],
        );
    final room = ValueListenableBuilder<_PeSceneCfg?>(
      valueListenable: _peScene,
      builder: (_, cfg, __) => room0(_studioOn ? cfg : null),
    );
    // debug: ปุ่มเปิดแผงปรับกล้องฉากเตียง (ย้ายมาจากหน้า bed view เดิม) เฉพาะหน้า ward
    if (!kDebugMode || _detail) return room;
    return Stack(children: [
      Positioned.fill(child: room),
      Positioned(
        left: 12.0,
        top: 12.0,
        child: _Press(
          radius: 100.0,
          child: GestureDetector(
            onTap: () => setState(() => _roomDbg = !_roomDbg),
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: _roomDbg ? _blue : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded,
                  size: 18.0, color: _roomDbg ? Colors.white : _ink2),
            ),
          ),
        ),
      ),
      if (_roomDbg) Positioned(left: 60.0, top: 12.0, child: _roomDbgPanel()),
    ]);
  }

  /// แผงปรับกล้องฉากเตียง (debug): จูนแล้วกดคัดลอกค่าส่งกลับมาตั้งเป็นค่าเริ่มต้น
  Widget _roomDbgPanel() {
    Widget slider(String label, double v, double min, double max,
            ErCam Function(double) set) =>
        Row(children: [
          SizedBox(
              width: 86.0,
              child: Text(label,
                  style: _t(11.5, color: _ink2, weight: FontWeight.w500))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: Slider(
                value: v.clamp(min, max),
                min: min,
                max: max,
                activeColor: _blue,
                onChanged: (x) => setState(() => _roomCam = set(x)),
              ),
            ),
          ),
          SizedBox(
            width: 44.0,
            child: Text(v.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: _num(11.0, color: _inkTitle, weight: FontWeight.w500)),
          ),
        ]);
    final c = _roomCam;
    return Container(
      width: 320.0,
      padding: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 16.0, offset: Offset(0, 4))
        ],
      ),
      // ฉากเหนือการ์ดผู้ป่วยเตี้ย: จำกัดความสูง เลื่อนในแผง ไม่ให้การ์ดบัง
      constraints: const BoxConstraints(maxHeight: 290.0),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Text('ปรับกล้องฉากเตียง',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
          const Spacer(),
          TextButton(
            onPressed: () async {
              final text = 'ErCam(\n'
                  '  iso: ${c.iso},\n'
                  '  zoom: ${c.zoom.toStringAsFixed(2)},\n'
                  '  pitch: ${c.pitch.toStringAsFixed(1)},\n'
                  '  height: ${c.height.toStringAsFixed(2)},\n'
                  '  distance: ${c.distance.toStringAsFixed(2)},\n'
                  '  fov: ${c.fov.toStringAsFixed(1)},\n'
                  '  yaw: ${c.yaw.toStringAsFixed(1)},\n'
                  '  lookY: ${c.lookY.toStringAsFixed(2)},\n'
                  '  shiftX: ${c.shiftX.toStringAsFixed(2)},\n'
                  '  shiftY: ${c.shiftY.toStringAsFixed(2)},\n'
                  '  bedTurn: ${c.bedTurn.toStringAsFixed(1)},\n'
                  '  screenX: ${c.screenX.toStringAsFixed(0)},\n'
                  '  tagLift: ${c.tagLift.toStringAsFixed(2)},\n'
                  ')';
              await Clipboard.setData(ClipboardData(text: text));
              debugPrint('ค่ากล้องฉากเตียง:\n$text');
            },
            child: Text('คัดลอกค่า',
                style: _t(12.0, color: _blue, weight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => setState(() => _roomCam = const ErCam()),
            child: Text('คืนค่า',
                style: _t(12.0, color: _blue, weight: FontWeight.w600)),
          ),
        ]),
        Row(children: [
          for (final iso in const [false, true])
            Padding(
              padding: const EdgeInsets.only(right: 6.0, bottom: 4.0),
              child: ChoiceChip(
                label: Text(iso ? 'ไอโซเมตริก' : 'เพอร์สเปกทีฟ',
                    style: _t(11.5,
                        color: c.iso == iso ? Colors.white : _ink2,
                        weight: FontWeight.w600)),
                selected: c.iso == iso,
                selectedColor: _blue,
                showCheckmark: false,
                onSelected: (_) =>
                    setState(() => _roomCam = c.copyWith(iso: iso)),
              ),
            ),
        ]),
        if (c.iso) ...[
          slider('ขนาดภาพ', c.zoom, 1.5, 14.0, (v) => c.copyWith(zoom: v)),
          slider('มุมก้ม', c.pitch, 5.0, 80.0, (v) => c.copyWith(pitch: v)),
        ] else ...[
          slider(
              'ความสูงกล้อง', c.height, 0.5, 7.0, (v) => c.copyWith(height: v)),
          slider('ระยะห่าง', c.distance, 1.2, 16.0,
              (v) => c.copyWith(distance: v)),
          slider('มุมมองภาพ', c.fov, 16.0, 70.0, (v) => c.copyWith(fov: v)),
        ],
        slider('มุมเอียง', c.yaw, -90.0, 90.0, (v) => c.copyWith(yaw: v)),
        slider('จุดเล็ง', c.lookY, -2.0, 2.5, (v) => c.copyWith(lookY: v)),
        slider(
            'เลื่อนแนวนอน', c.shiftX, -6.0, 6.0, (v) => c.copyWith(shiftX: v)),
        slider(
            'เลื่อนแนวตั้ง', c.shiftY, -3.0, 3.0, (v) => c.copyWith(shiftY: v)),
        slider('หมุนเตียง', c.bedTurn, -180.0, 180.0,
            (v) => c.copyWith(bedTurn: v)),
        slider('เลื่อนภาพบนจอ', c.screenX, -500.0, 500.0,
            (v) => c.copyWith(screenX: v)),
        slider(
            'ยกป้ายเตียง', c.tagLift, -0.3, 1.2, (v) => c.copyWith(tagLift: v)),
      ])),
    );
  }

  /// ช่องตำแหน่งแผลที่ flipbook เปิดอยู่ตอนนี้ (null = ไม่ได้อยู่ที่ช่องนั้น)
  String? get _woundField {
    if (!_speechOpen) return null;
    for (final (l, _) in _forms[_speechStep]) {
      if (l.contains('ตำแหน่ง') && l.contains('แผล')) return l;
    }
    return null;
  }

  /// แตะบนหุ่นตอนกรอกตำแหน่งแผล: เติมชื่อส่วนของร่างกายต่อท้ายช่อง (แตะหลายจุดได้)
  void _onBodyPick(String bone) {
    final f = _woundField;
    if (f == null) return;
    final part = bone.split('.');
    final th = _boneTh[part.first] ?? part.first;
    final side = part.length > 1 ? (part[1] == 'R' ? 'ขวา' : 'ซ้าย') : '';
    final where = side.isEmpty ? th : '$th$side';
    setState(() {
      final old = _filled[_speechStep][f];
      _lastFilled = [(_speechStep, f, old)];
      _filled[_speechStep][f] = old == null || old.isEmpty
          ? where
          : (old.contains(where) ? old : '$old, $where');
    });
    HapticFeedback.selectionClick();
  }

  /// เลื่อนคนที่ฉากเล็งอยู่ไปคนก่อนหน้า/ถัดไปในช่วงงานนี้ (วนรอบ)
  ///
  /// ไล่ตามรหัสเตียง A1→A2→… ให้ตรงกับที่กล้องกวาดไปทางซ้าย/ขวาในห้อง
  /// คนที่ยังไม่ได้เตียงต่อท้าย
  void _stepPatient(int dir) {
    final people = _ofPhase(_open!);
    if (people.isEmpty) return;
    final withBed = people.where((p) => p.bed != null).toList()
      ..sort((a, b) => a.bed!.compareTo(b.bed!));
    final ordered = [...withBed, ...people.where((p) => p.bed == null)];
    final cur = _sceneSelected(_open!);
    var i = ordered.indexWhere((p) => p.hn == cur.hn);
    if (i < 0) i = 0;
    i = (i + dir + ordered.length) % ordered.length;
    setState(() {
      _sceneDir = dir;
      _sceneHn = ordered[i].hn;
    });
  }

  /// ปุ่มกลมลอยข้างฉาก ซ้าย/ขวา
  Widget _stepButton(IconData icon, int dir) => _Press(
          child: Material(
        color: _panel.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 3.0,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTap: () => _stepPatient(dir),
          child: SizedBox(
            width: 44.0,
            height: 44.0,
            child: Icon(icon, size: 26.0, color: _ink),
          ),
        ),
      ));

  /// ผู้ป่วยที่ฉากกำลังเล็งอยู่ในช่วงงานนี้
  ///
  /// ยึดคนที่แตะเลือกไว้ก่อน ถ้าคนนั้นไม่ได้อยู่ช่วงงานนี้แล้วให้ถอยไปคนแรก
  /// ช่วงคัดกรองยังไม่มีใครได้เตียง จึงเลือกจากลำดับรายชื่อแทน
  _P _sceneSelected(_Phase phase) {
    final people = _ofPhase(phase);
    if (people.isEmpty) return _patients.first;
    return people.firstWhere((p) => p.hn == _sceneHn,
        orElse: () => people.firstWhere((p) => p.bed != null,
            orElse: () => people.first));
  }

  /// ความกว้างพื้นที่หุ่น/workflow ฝั่งขวา
  /// กาง workflow = _wfSplit (40%) · หุบ = _clySplit ที่ผู้ใช้ลากไว้
  double get _clySceneW =>
      MediaQuery.sizeOf(context).width * (_clySplitNow ?? _clySplitTarget);

  /// สัดส่วนปลายทาง (ไม่ animate) ใช้กับฉาก 3D: WebView ไม่ต้อง resize ทุกเฟรม
  double get _clySplitTarget => _speechOpen ? _wfSplit : _clySplit;

  /// ขอบซ้ายฉาก 3D ตามสัดส่วนปลายทาง
  double get _clySceneXTarget =>
      MediaQuery.sizeOf(context).width * (1.0 - _clySplitTarget);

  /// ขอบซ้ายของพื้นที่หุ่น/workflow: แผงข้อมูลอยู่ซ้าย หุ่น + workflow อยู่ขวา
  double get _clySceneX => MediaQuery.sizeOf(context).width - _clySceneW;

  /// อวัยวะที่ไฮไลต์บนหุ่นตามระบบที่เลือก (null = ตามเคส)
  List<String>? _clyHighlight() {
    if (!_clyOn || _clySys == 0) return null;
    final s = _clySystems[_clySys];
    if (_clySys == 6) {
      final bones = [
        for (final t in erBodyTargets(_case))
          if (t.kind == ErBodyKind.bone) t.code,
      ];
      return bones.isEmpty ? const ['bone:pelvis'] : bones;
    }
    return s.$3.isEmpty ? _bodyCodesOfCase(_case) : s.$3;
  }

  /// วลีจากอาการสำคัญที่พูดถึงตำแหน่งนี้ (เช่น "ศีรษะกระแทก" "ปวดต้นขาขวาผิดรูป")
  /// null = CC ไม่ได้พูดถึง
  String? _clyCcPhrase(ErBodyTarget t) {
    final cc = _case.cc;
    final hit = t.hit;
    if (hit.isEmpty) return null;
    final i = cc.toLowerCase().indexOf(hit.toLowerCase());
    if (i < 0) return null;
    // สรุปใจความ "เกิดอะไร + ที่ไหน" (ผู้ใช้ 2026-11-02: เดิมตัดจากตำแหน่งไปข้างหน้า
    // ได้ "หลังเท้าขวาขณะทำสวน" ไม่รู้ว่าเป็นอะไรมา)
    // เหตุ = ข้อความในวลีเดียวกันก่อนตำแหน่ง (ตัด "ถูก" หน้า · "ที่/บริเวณ" ท้าย)
    final start = [
          cc.lastIndexOf(' ', i),
          cc.lastIndexOf(',', i),
        ].reduce(math.max) +
        1;
    var ev = cc.substring(start, i).trim();
    for (final t in const ['ที่บริเวณ', 'บริเวณ', 'ที่']) {
      if (ev.endsWith(t)) {
        ev = ev.substring(0, ev.length - t.length).trim();
        break;
      }
    }
    if (ev.startsWith('ถูก')) ev = ev.substring(3).trim();
    // ไม่มีเหตุในวลี = อาการหลักจากทั้งข้อความ (ปวด บวม เจ็บ ชา แผล ผื่น)
    if (ev.isEmpty) {
      ev = [
        for (final k in const ['ปวด', 'บวม', 'เจ็บ', 'ชา', 'ผื่น', 'แผล'])
          if (cc.contains(k)) k
      ].take(2).join('');
    }
    // ตำแหน่ง + ข้าง (ซ้าย/ขวา) ที่ต่อท้ายทันที
    var loc = cc.substring(i, i + hit.length);
    final after = cc.substring(i + hit.length);
    for (final side in const ['ขวา', 'ซ้าย', 'ทั้งสองข้าง']) {
      if (after.startsWith(side)) {
        loc += side;
        break;
      }
    }
    final out = ev.isEmpty ? loc : '$ev $loc';
    // ป้ายขึ้น 2 บรรทัดได้: ยาวเกิน 44 ตัวอักษรค่อยตัด
    return out.length > 44 ? '${out.substring(0, 43)}…' : out;
  }

  /// ป้ายสั้นของตำแหน่ง: ใช้วินิจฉัยที่มีคำนั้น (ตัดวงเล็บ) ถ้าไม่มีใช้ชื่อไทย
  String _clyLabelText(ErBodyTarget t) {
    final hit = t.hit.toLowerCase();
    for (final d in _case.dx) {
      if (hit.isNotEmpty && d.text.toLowerCase().contains(hit)) {
        final s = d.text.split('(').first.trim();
        return s.length > 26 ? '${s.substring(0, 25)}…' : s;
      }
    }
    return t.th;
  }

  /// ที่มาของจุดบนหุ่น: แผล = ตำแหน่งแผล · DX = การวินิจฉัย · PE = ตรวจร่างกาย
  /// (เฉพาะที่ผิดปกติ รอบล่าสุด)
  /// · CC = อาการสำคัญ/ประวัติ · ผลภาพถ่ายนับเป็น DX
  String _clySource(ErBodyTarget t) {
    final hit = t.hit.toLowerCase();
    if (hit.isEmpty) return 'CC';
    final c = _case;
    // ตำแหน่งแผล: ช่องแผลใน workflow หรือข้อความที่มีคำบอกแผลอยู่ติดตำแหน่งนี้
    const wound = ['แผล', 'ฉีกขาด', 'ถลอก', 'laceration', 'wound', 'abrasion'];
    final woundField = [
      for (final m in _filled)
        for (final e in m.entries)
          if (e.key.contains('แผล')) e.value.toLowerCase()
    ].join(' ');
    bool nearWound(String text) {
      final i = text.indexOf(hit);
      if (i < 0) return false;
      final a = (i - 12).clamp(0, text.length);
      final b = (i + hit.length + 12).clamp(0, text.length);
      return wound.any(text.substring(a, b).contains);
    }

    if (woundField.contains(hit) ||
        c.dx.any((d) => nearWound(d.text.toLowerCase())) ||
        nearWound(c.cc.toLowerCase())) {
      return 'แผล';
    }
    if (c.dx.any((d) => d.text.toLowerCase().contains(hit))) return 'DX';
    final pe = _peRounds.isEmpty ? null : _peRounds.last;
    if (pe != null &&
        pe.findings.values.any((f) =>
            f.$1 == _Finding.abnormal && f.$2.toLowerCase().contains(hit))) {
      return 'PE';
    }
    if ('${c.cc} ${c.hpi}'.toLowerCase().contains(hit)) return 'CC';
    return c.imaging.any((i) => i.result.toLowerCase().contains(hit))
        ? 'DX'
        : 'CC';
  }

  /// สวิตช์ป้ายบนหุ่น ใต้หุ่น: pill เดียว เรียง PE · CC · DX แต่ละชนิดมีสวิตช์เล็กของตัวเอง
  Widget _bodyTagToggles() {
    Widget item(String t) {
      final on = _bodyTags.contains(t);
      void flip() {
        HapticFeedback.selectionClick();
        setState(() => on ? _bodyTags.remove(t) : _bodyTags.add(t));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: flip,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(t,
              style: _t(12.5,
                  color: on ? _inkTitle : _ink3, weight: FontWeight.w700)),
          SizedBox(
            height: 28.0,
            child: FittedBox(
              child: Switch(
                value: on,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeThumbColor: Colors.white,
                activeTrackColor: t == 'PE' ? _red : _blue,
                onChanged: (_) => flip(),
              ),
            ),
          ),
        ]),
      );
    }

    return Container(
      height: 40.0,
      padding: const EdgeInsets.fromLTRB(14.0, 0.0, 6.0, 0.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (i, t) in const ['PE', 'CC', 'DX'].indexed) ...[
          if (i > 0)
            Container(
                width: 1.0,
                height: 18.0,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                color: _line),
          item(t),
        ],
      ]),
    );
  }

  /// ป้ายชี้อาการบนหุ่น: จุดขาวบนตัว + เส้นนำ + ป้ายเม็ดยาสีเข้ม
  List<Widget> _clyLabels() {
    final spots = {
      for (final h in _hotspots)
        if (h.visible) h.code: h,
    };
    if (spots.isEmpty) return const [];
    final used = <String>{};
    final picks = <(ErBodyTarget, Offset)>[];
    // สอดคล้องกับอาการสำคัญ: ตำแหน่งที่ CC พูดถึงขึ้นก่อน แล้วจึงตามด้วยวินิจฉัย/ตรวจร่างกาย
    final ccText = _case.cc.toLowerCase();
    bool inCc(ErBodyTarget t) =>
        t.hit.isNotEmpty && ccText.contains(t.hit.toLowerCase());
    final targets = [...erBodyTargets(_case)]
      ..sort((a, b) => (inCc(a) ? 0 : 1).compareTo(inCc(b) ? 0 : 1));
    for (final t in targets) {
      if (picks.length >= 3) break;
      final key = t.code;
      if (used.contains(key)) continue;
      final spot = spots[key];
      if (spot == null) continue;
      used.add(key);
      // พิกัดจากฉาก (ภายในพื้นที่หุ่น) → พิกัดจอ
      picks.add((t, Offset(spot.dx + _clySceneXTarget, spot.dy)));
    }
    // หมุดที่ปักในภาพการตรวจร่างกาย (studio): ป้ายแดงชื่อบริเวณ + สิ่งที่พบ
    // แบบป้ายในหน้าวาดภาพ (2026-10-20): บริเวณ + รายละเอียดล่าสุด + รูปเล็ก/ภาพซ้อนของบริเวณ
    final pins = <(String, Offset, List<Uint8List>)>[];
    final seen = <String>{};
    final shots = _peShots[_case.hn] ?? const <_PeShot>[];
    for (final x in shots.reversed) {
      for (final st in x.d3) {
        if ((st['pts'] as List?)?.length != 1) continue;
        final spot = spots['pin:${st['id']}'];
        final r = st['region'] as String?;
        if (spot == null || r == null || !seen.add(r)) continue;
        final where = _peName(r);
        String note = '';
        final photos = <Uint8List>[];
        for (final y in shots) {
          final log = y.noteLogBy[r];
          if (log != null && log.isNotEmpty) note = log.last.$1;
          if (note.isEmpty) note = y.notesBy[r] ?? '';
          photos.addAll(y.attachBy[r] ?? const <Uint8List>[]);
        }
        pins.add((
          [
            st['label'] == null ? where : '${_peLabel(st)}$where',
            if (note.trim().isNotEmpty) note.trim().split('\n').first,
          ].join(' '),
          Offset(spot.dx + _clySceneXTarget, spot.dy),
          photos,
        ));
      }
    }
    // ป้ายแบบเดิม (คอลัมน์ข้างหุ่น + เส้นนำ) แต่เรียบขึ้น:
    // เส้นนำบางเส้นเดียวแนวนอน→หักมุมครั้งเดียว · จุดวงขาวแกนสี · pill ขาวมีจุดสีตรงกับจุดบนหุ่น
    if (picks.isEmpty && pins.isEmpty) {
      // ไม่มีป้ายเลย: คนใหม่ = กลับเป็นค่าเริ่มต้น CC
      if (_bodyTagsHn != _case.hn) {
        _bodyTagsHn = _case.hn;
        _bodyTags
          ..clear()
          ..add('CC');
      }
      return const [];
    }
    // รวมเป็นรายการเดียว: (ที่มา, ข้อความ, จุด, สี, แตะ)
    const palette = [
      Color(0xFFE5484D),
      Color(0xFFF59E0B),
      Color(0xFF7C5CFF),
      Color(0xFF12A594),
    ];
    final items =
        <(String, String, Offset, Color, VoidCallback, List<Uint8List>)>[
      // แสดงเฉพาะชนิดที่เปิดไว้ในเมนูป้าย (PE · CC · DX)
      for (final (i, (t, spot)) in picks.indexed)
        () {
          final ccPhrase = _clyCcPhrase(t);
          return (
            ccPhrase != null ? 'CC' : _clySource(t),
            ccPhrase ?? _clyLabelText(t),
            spot,
            palette[i % palette.length],
            () => setState(() => _symOpen = t),
            const <Uint8List>[],
          );
        }(),
      for (final (text, spot, ph) in pins.take(6))
        ('PE', text, spot, _red, _peOpenStudio, ph),
    ];
    // ค่าเริ่มต้นเมื่อเปิดผู้ป่วยคนใหม่: CC + ชนิดที่มีป้าย (DX/PE)
    if (_bodyTagsHn != _case.hn) {
      _bodyTagsHn = _case.hn;
      final next = {
        'CC',
        if (items.any((it) => it.$1 == 'DX')) 'DX',
        if (items.any((it) => it.$1 == 'PE')) 'PE',
      };
      if (next.length != _bodyTags.length || !next.containsAll(_bodyTags)) {
        _bodyTags
          ..clear()
          ..addAll(next);
        // สวิตช์ใต้หุ่นอาจวาดไปก่อนแล้วในเฟรมนี้: วาดใหม่ให้ตรง
        WidgetsBinding.instance
            .addPostFrameCallback((_) => mounted ? setState(() {}) : null);
      }
    }
    items.retainWhere((it) => _bodyTags.contains(it.$1));
    if (items.isEmpty) return const [];
    // ป้าย 2 บรรทัดสูง ~44: เว้นระยะพอไม่ให้ทับกัน
    const gap = 48.0;
    items.sort((p, q) => p.$3.dy.compareTo(q.$3.dy));
    final sw = MediaQuery.sizeOf(context).width;
    // แบบหน้าวาดภาพ: ป้ายของแต่ละจุดวางชิดจุดตัวเอง (ขวาก่อน ไม่พอ = ซ้าย) ทับบนหุ่นได้
    // ไม่ล้นใต้รางขวา/แผงซ้าย · เรียงความสูงรวมกันไม่ให้ป้ายทับกัน
    final railX = sw - 96.0;
    final leftX = _clySceneXTarget + 12.0;
    const want = 170.0;
    final side = <bool>[];
    final colXs = <double>[];
    final colWs = <double>[];
    for (final it in items) {
      final x = it.$3.dx;
      final wr = railX - (x + 20.0), wl = (x - 20.0) - leftX;
      final r = wr >= want || wr >= wl;
      side.add(r);
      colXs.add(r ? x + 20.0 : x - 20.0);
      colWs.add((r ? wr : wl).clamp(90.0, 240.0));
    }
    final ys = <double>[];
    for (final it in items) {
      ys.add(ys.isEmpty ? it.$3.dy : math.max(it.$3.dy, ys.last + gap));
    }
    final out = <Widget>[];
    final leaders = <List<Offset>>[];
    final leaderCols = <Color>[];
    for (var i = 0; i < items.length; i++) {
      final (src, text, spot, col, onTap, photos) = items[i];
      final pe = src == 'PE';
      final ly = ys[i];
      final right = side[i];
      final colX = colXs[i];
      final colW = colWs[i];
      // ที่แคบ: ป้ายย่อ ไม่มีลูกศร (ที่มายังอยู่) ข้อความยาวตัด …
      final compact = colW < 130.0;
      // เส้นตรงเฉียงจากจุดไปหาแนวป้าย แล้วหักเข้าป้ายสั้น ๆ
      // (ไม่ใช้แนวตั้งร่วมกัน เส้นหลายเส้นจะซ้อนกันอ่านไม่ออก)
      final knee = right ? colX - 10.0 : colX + 10.0;
      leaders.add([spot, Offset(knee, ly), Offset(colX, ly)]);
      leaderCols
          .add(pe ? _red.withValues(alpha: 0.55) : const Color(0xFFB8BEC6));
      out.add(Positioned(
        left: spot.dx - (pe ? 10.0 : 7.0),
        top: spot.dy - (pe ? 10.0 : 7.0),
        child: IgnorePointer(
          child: pe
              // หมุด PE แบบหน้าวาดภาพ: วงแดงจาง + จุดแดงขอบขาว
              ? Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red.withValues(alpha: 0.22)),
                  alignment: Alignment.center,
                  child: Container(
                    width: 11.0,
                    height: 11.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                  ),
                )
              : Container(
                  width: 14.0,
                  height: 14.0,
                  padding: const EdgeInsets.all(3.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 3.0,
                          offset: Offset(0, 1)),
                    ],
                  ),
                  child: DecoratedBox(
                      decoration:
                          BoxDecoration(color: col, shape: BoxShape.circle)),
                ),
        ),
      ));
      out.add(Positioned(
        left: right ? colX : null,
        right: right ? null : sw - colX,
        top: ly - 15.0,
        child: _Press(
          child: GestureDetector(
            // แตะป้าย = ดูรูปของตำแหน่งนั้น · ป้าย PE = เปิดหน้าวาดภาพ
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(maxWidth: colW, minHeight: 30.0),
              padding: const EdgeInsets.fromLTRB(8.0, 5.0, 4.0, 5.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                // แบบหน้าวาดภาพ: รูปเล็ก/ภาพซ้อน · ป้ายที่มา (PE แดงอ่อน · CC/DX ฟ้าอ่อน) · ข้อความ
                if (photos.isNotEmpty) ...[
                  photos.length > 1
                      ? _photoStack(photos, 22.0,
                          _t(8.0, color: Colors.white, weight: FontWeight.w700))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: Image.memory(photos.last,
                              width: 22.0, height: 22.0, fit: BoxFit.cover),
                        ),
                  const SizedBox(width: 6.0),
                ] else if (!pe) ...[
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration:
                        BoxDecoration(color: col, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6.0),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color:
                        pe ? const Color(0xFFFCE8E6) : const Color(0xFFE2EAF8),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(src,
                      style: _t(10.0,
                          color: pe ? _red : _blue, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 6.0),
                // ยาวเกินช่อง = ขึ้นบรรทัดที่ 2 (อ่านครบในทีเดียว ไม่ต้องรอเลื่อน)
                Flexible(
                  child: Text(text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.5,
                          color: _inkTitle,
                          weight: FontWeight.w600,
                          height: 1.3)),
                ),
                if (!compact)
                  const Icon(Icons.chevron_right_rounded,
                      size: 16.0, color: _ink3)
                else
                  const SizedBox(width: 4.0),
              ]),
            ),
          ),
        ),
      ));
    }
    // เส้นนำอยู่ใต้จุดและป้าย (เทาอ่อนบาง)
    out.insert(
        0,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
                painter: _LeaderLines(leaders, const Color(0xFFB8BEC6),
                    colors: leaderCols)),
          ),
        ));
    return out;
  }

  List<String> _highlightOrgans() {
    final sys = _clyHighlight();
    if (sys != null) return sys;
    // หน้าอื่น: ส่วนที่วาดไว้ในภาพการตรวจร่างกาย (ใหม่สุดก่อน) + อวัยวะ/กระดูก
    // ที่ map จากอาการสำคัญ/วินิจฉัยของผู้ป่วยรายนี้
    final drawn = [
      // ผิวหนังมีหมุดบอกจุดอยู่แล้ว ไม่ต้องเรืองแสงซ้ำ (โซนผิวคลาดจากท่าหุ่น)
      for (final s in (_peShots[_case.hn] ?? const <_PeShot>[]).reversed)
        for (final f in s.findings)
          if (f.$2 != 'skin') f.$1,
    ];
    if (drawn.isEmpty) return _bodyCodesOfCase(_case);
    return {...drawn, ..._bodyCodesOfCase(_case)}.take(6).toList();
  }

  /// ภาพ X-ray/CT ของเคสที่ตรงกับบริเวณนั้น
  List<ErImage> _symImages(ErBodyTarget t) {
    final part = t.part;
    final keys = switch (part) {
      'brain' || 'skull' || 'head' || 'cspine' => ['brain', 'skull', 'head'],
      'lungs' || 'heart' || 'ribs' || 'chest' || 'clavicle' || 'trachea' => [
          'cxr',
          'chest'
        ],
      'abdomen' ||
      'liver' ||
      'stomach' ||
      'intestine' ||
      'kidneys' ||
      'epigastric' ||
      'ruq' ||
      'rlq' ||
      'llq' ||
      'luq' =>
        ['abdomen', 'kub', 'ultrasound'],
      _ => [part],
    };
    return [
      for (final im in _case.imaging)
        if (keys.any((k) => im.name.toLowerCase().contains(k))) im
    ];
  }

  /// หน้า drill-down ของตำแหน่งอาการ: วินิจฉัย · บาดแผล · ภาพถ่ายทางรังสี
  Widget _symDrill() {
    final t = _symOpen!;
    final hit = t.hit.toLowerCase();
    final dx = [
      for (final d in _case.dx)
        if (hit.isNotEmpty && d.text.toLowerCase().contains(hit)) d
    ];
    final imgs = _symImages(t);
    final side =
        switch (t.side) { 'l' => 'ด้านซ้าย', 'r' => 'ด้านขวา', _ => '' };
    Widget sectionTitle(String s) => Padding(
          padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
          child:
              Text(s, style: _t(10.5, color: _ink3, weight: FontWeight.w700)),
        );
    return Container(
      decoration:
          _clyCardDeco.copyWith(borderRadius: BorderRadius.circular(16.0)),
      foregroundDecoration: const _InnerGloss(16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 12.0, 6.0),
          child: Row(children: [
            IconButton(
              tooltip: 'กลับ',
              onPressed: () => setState(() => _symOpen = null),
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 20.0, color: _blue),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clyLabelText(t),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text([t.th, if (side.isNotEmpty) side].join(' · '),
                      style: _t(10.5, color: _ink3)),
                ],
              ),
            ),
          ]),
        ),
        const Divider(height: 1.0, color: _line),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
            children: [
              if (dx.isNotEmpty) ...[
                sectionTitle('ตำแหน่ง'),
                for (final d in dx)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(children: [
                      Expanded(
                        child: Text(d.text,
                            style: _t(12.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                      ),
                      if (d.icd10 != null)
                        Text(d.icd10!,
                            style: _num(11.0,
                                color: _ink2, weight: FontWeight.w600)),
                      if (d.level == ErLevel.critical) ...[
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: _red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text('วิกฤต',
                              style: _t(9.5,
                                  color: _red, weight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                  ),
              ],
              if (_clySource(t) == 'แผล') ..._woundSection(sectionTitle),
              // ภาพรังสี: ไม่แสดงที่จุดแผล และซ่อนหัวข้อเมื่อไม่มีภาพ
              if (imgs.isNotEmpty && _clySource(t) != 'แผล') ...[
                sectionTitle('ภาพถ่ายทางรังสี'),
                for (final im in imgs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            color: Colors.black,
                            height: 220.0,
                            child: Image.asset(im.asset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.white54))),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(children: [
                          Expanded(
                            child: Text(im.name,
                                style: _t(11.5,
                                    color: _inkTitle, weight: FontWeight.w600)),
                          ),
                          Text(im.result,
                              style: _t(10.5,
                                  color: im.result.startsWith('รอ')
                                      ? _ink3
                                      : _blue,
                                  weight: FontWeight.w600)),
                        ]),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  /// รูปบาดแผลของตำแหน่งนี้: บันทึกเมื่อ/โดย · แถบรูปหลายรูป · แตะดูเต็มจอ
  List<Widget> _woundSection(Widget Function(String) title) {
    final ph = erWoundPhotos(_case);
    if (ph.isEmpty) return const [];
    return [
      title('บาดแผล · ${ph.length} รูป'),
      // รูปละหนึ่งแถว: รูปย่อ (แตะดูเต็มจอ) · วันเวลา · ผู้บันทึก
      for (var i = 0; i < ph.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _Press(
            child: GestureDetector(
              onTap: () => _woundViewer(ph, i),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(ph[i].asset,
                      width: 96.0, height: 68.0, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${ph[i].date} ${ph[i].time} น.',
                            style: _num(11.5,
                                color: _inkTitle, weight: FontWeight.w600)),
                        Text(ph[i].by, style: _t(10.0, color: _ink3)),
                      ]),
                ),
                const SizedBox(width: 8.0),
                // ปุ่มดูรูปเต็มจอ ขวาสุดของแถว
                Container(
                  height: 30.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    gradient: _glossWhite,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: _line, width: 0.5),
                    boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                  ),
                  foregroundDecoration: const _InnerGloss(8.0),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.fullscreen_rounded,
                        size: 15.0, color: _blue),
                    const SizedBox(width: 4.0),
                    Text('ดูรูปภาพ',
                        style: _t(10.5, color: _blue, weight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
    ];
  }

  /// ดูรูปแผลเต็มจอ: ปัดซ้าย/ขวาเปลี่ยนรูป · หุบนิ้วซูม · บอกเวลา/ผู้บันทึกของรูป
  void _woundViewer(List<ErWoundPhoto> ph, int start) {
    final ctl = PageController(initialPage: start);
    var at = start;
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx, set) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(children: [
              PageView.builder(
                controller: ctl,
                itemCount: ph.length,
                onPageChanged: (i) => set(() => at = i),
                itemBuilder: (_, i) => InteractiveViewer(
                  maxScale: 5.0,
                  child: Center(
                      child: Image.asset(ph[i].asset, fit: BoxFit.contain)),
                ),
              ),
              Positioned(
                left: 8.0,
                top: 8.0,
                right: 8.0,
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 24.0),
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ph[at].note,
                              style: _t(14.0,
                                  color: Colors.white,
                                  weight: FontWeight.w700)),
                          Text(
                              '${ph[at].date} ${ph[at].time} น. · ${ph[at].by}',
                              style: _t(11.0,
                                  color: Colors.white.withValues(alpha: 0.8))),
                        ]),
                  ),
                  Text('${at + 1} / ${ph.length}',
                      style: _num(13.0,
                          color: Colors.white, weight: FontWeight.w700)),
                  const SizedBox(width: 12.0),
                ]),
              ),
              // แถบรูปย่อด้านล่าง แตะเพื่อข้ามไปรูปนั้น
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 12.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < ph.length; i++)
                      GestureDetector(
                        onTap: () => ctl.animateToPage(i,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: i == at
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                width: 2.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.asset(ph[i].asset,
                                width: 64.0, height: 44.0, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// เส้นนำจากจุดบนหุ่นไปหาป้าย (ป้ายอาจถูกดันลงไม่ให้ทับกัน)
class _LeaderLines extends CustomPainter {
  const _LeaderLines(this.lines, this.color, {this.colors = const []});

  final List<List<Offset>> lines;
  final Color color;

  /// สีต่อเส้น (ว่าง = ใช้ color) · หมุด PE = แดงแบบหน้าวาดภาพ
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (final (i, pts) in lines.indexed) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      p
        ..color = i < colors.length ? colors[i] : color
        ..strokeWidth = i < colors.length && colors[i] != color ? 1.5 : 1.0;
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderLines old) =>
      old.color != color ||
      old.colors.length != colors.length ||
      old.lines.length != lines.length ||
      [
        for (var i = 0; i < lines.length; i++)
          old.lines[i].join() != lines[i].join()
      ].any((x) => x);
}

// ------------------------------------------------- ฉาก 3D ชั้นเดียวถาวร (เปลี่ยนหน้าแบบต่อเนื่อง)
// หน้าภาพรวมเตียงและหน้าผู้ป่วยวาง [_SceneSlot] ไว้ตรงที่จะแสดงฉาก · ฉากจริง (ErRoom3D ตัวเดียว)
// อยู่ที่ [_SceneFly] ใต้เนื้อหาหน้า ไม่ย้ายต้นไม้ (Android ไม่ต้องต่อ WebView ใหม่ = ไม่สะดุด)
// เปลี่ยนหน้า = กรอบฉากเลื่อน/ยืดจากช่องเดิมไปช่องใหม่ต่อเนื่อง

class _SceneSlotInfo {
  const _SceneSlotInfo(this.token, this.id, this.rect, this.on);
  final int token;
  final String id;

  /// กรอบบนจอ (พิกัด global รวม transform เช่นซูมหน้าภาพรวม)
  final Rect rect;
  final bool on;
}

final ValueNotifier<_SceneSlotInfo?> _sceneSlot = ValueNotifier(null);
int _sceneSlotSeq = 0;

/// ช่องว่างโปร่ง (ไม่รับแตะ) บอกตำแหน่งให้ฉากจริงมาวางทับ · on = false = ซ่อนฉาก (ยัง mount อยู่)
class _SceneSlot extends LeafRenderObjectWidget {
  const _SceneSlot({required this.id, required this.on});
  final String id;
  final bool on;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSceneSlot(id, on);
  @override
  void updateRenderObject(BuildContext context, _RenderSceneSlot r) {
    r
      ..id = id
      ..on = on;
    r.markNeedsPaint();
  }
}

class _RenderSceneSlot extends RenderBox {
  _RenderSceneSlot(this.id, this.on);
  String id;
  bool on;
  int _token = 0;

  @override
  bool get sizedByParent => true;
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // ช่องที่ mount ทีหลังชนะเมื่อสถานะ on เท่ากัน (หน้าผู้ป่วยทับหน้าเตียงที่ยังคงอยู่)
    _token = ++_sceneSlotSeq;
  }

  @override
  void detach() {
    _sceneSlots.remove(_token);
    _sceneSlotPick();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!hasSize) return;
    final r =
        MatrixUtils.transformRect(getTransformTo(null), Offset.zero & size);
    final cur = _sceneSlots[_token];
    if (cur != null && cur.rect == r && cur.on == on && cur.id == id) return;
    _sceneSlots[_token] = _SceneSlotInfo(_token, id, r, on);
    _sceneSlotPick();
  }
}

/// ทุกช่องที่ยังอยู่ (รวมหน้าเตียงที่ซ่อนไว้) · เลือกเจ้าของฉาก: ช่องของหน้าที่กำลังแสดง
/// ([_sceneOnDetail]) ก่อน แล้วช่อง on อื่น แล้วช่องใหม่สุด
final Map<int, _SceneSlotInfo> _sceneSlots = {};
bool _sceneSlotQueued = false;

/// หน้าผู้ป่วยกำลังแสดง (ตั้งโดย [_PageCross] ทันทีที่กด ไม่ต้องรอ build หน้าใหม่)
bool _sceneOnDetail = false;

int _sceneSlotScore(_SceneSlotInfo s) {
  if (!s.on) return 0;
  final mine = s.id == 'detail' ? _sceneOnDetail : !_sceneOnDetail;
  return mine ? 2 : 1;
}

void _sceneSlotPick() {
  if (_sceneSlotQueued) return;
  _sceneSlotQueued = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _sceneSlotQueued = false;
    _SceneSlotInfo? best;
    for (final s in _sceneSlots.values) {
      final a = _sceneSlotScore(s),
          b = best == null ? -1 : _sceneSlotScore(best);
      if (a > b || (a == b && s.token > best!.token)) {
        best = s;
      }
    }
    _sceneSlot.value = best;
  });
  WidgetsBinding.instance.ensureVisualUpdate();
}

/// หน้าเตียง ↔ หน้าผู้ป่วย: หน้าเตียง mount ค้างไว้ตลอด (กดกลับไม่ต้องสร้างใหม่)
/// หน้าผู้ป่วยสร้างเสร็จก่อน 1 เฟรม (โปร่งเกือบหมด) แล้วค่อยเริ่มจาง = เฟรมหนักไม่ตกกลางแอนิเมชัน
class _PageCross extends StatefulWidget {
  const _PageCross(
      {required this.detail, required this.detailPage, required this.beds});
  final bool detail;
  final Widget Function() detailPage;
  final Widget beds;
  @override
  State<_PageCross> createState() => _PageCrossState();
}

class _PageCrossState extends State<_PageCross>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.detail ? 1.0 : 0.0)
    ..addStatusListener((_) => setState(() {}));
  // ไม่ลงไปถึง 0: หน้าที่เพิ่ง mount ยังวาดช่องฉาก (บอกตำแหน่งให้ฉากบินได้ทันที)
  late final Animation<double> _in = Tween(begin: 0.01, end: 1.0)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  late final Animation<double> _out = Tween(begin: 1.0, end: 0.0)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeInCubic));
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0.0, 0.015), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  Widget? _detailCache;
  late Widget _bedsCache = widget.beds;
  // กลับมาหน้าเตียงแล้ว: ใช้หน้าเตียงชุดเดิมต่ออีกครู่ (ฉากยังบินอยู่) ค่อยอัปเดตทีหลัง
  Timer? _thaw;
  bool _frozen = false;

  @override
  void initState() {
    super.initState();
    _sceneOnDetail = widget.detail;
  }

  @override
  void didUpdateWidget(_PageCross old) {
    super.didUpdateWidget(old);
    if (old.detail == widget.detail) return;
    _sceneOnDetail = widget.detail;
    _sceneSlotPick();
    _thaw?.cancel();
    _frozen = true;
    if (widget.detail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.detail) _c.forward();
      });
    } else {
      _c.reverse();
      _thaw = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _frozen = false);
      });
    }
  }

  @override
  void dispose() {
    _thaw?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ระหว่างเปลี่ยนหน้า/หน้าเตียงซ่อนอยู่: ใช้ widget ชุดเดิม (Flutter ข้ามการ build ทั้งกิ่ง)
    // เฟรมที่กดจึงไม่ต้องสร้างหน้าเตียงใหม่ทั้งหน้า
    if (!widget.detail && !_frozen) _bedsCache = widget.beds;
    if (widget.detail) {
      _detailCache = widget.detailPage();
    } else if (_c.isDismissed) {
      _detailCache = null;
    }
    return Stack(fit: StackFit.expand, children: [
      // ไม่ใช้ Offstage: สลับแล้วต้อง layout หน้าเตียงใหม่ทั้งหน้า (~55 ms)
      // จางถึง 0 แล้วไม่ถูกวาดอยู่แล้ว · กันแตะทะลุด้วย IgnorePointer
      IgnorePointer(
        ignoring: widget.detail,
        child: TickerMode(
          enabled: !widget.detail && !_frozen,
          child: FadeTransition(
            opacity: _out,
            child: RepaintBoundary(child: _bedsCache),
          ),
        ),
      ),
      if (_detailCache != null)
        IgnorePointer(
          ignoring: !widget.detail,
          child: FadeTransition(
            opacity: _in,
            child: SlideTransition(
              position: _slide,
              child: RepaintBoundary(
                  child: KeyedSubtree(
                      key: const ValueKey('page-detail'),
                      child: _detailCache!)),
            ),
          ),
        ),
    ]);
  }
}

/// ฉากจริงชั้นเดียว: ช่องเดิม = ตามทันที · ย้ายไปช่องใหม่ (id ต่าง) = บินกรอบต่อเนื่อง 560 ms
class _SceneFly extends StatefulWidget {
  const _SceneFly({required this.rect, required this.id, required this.child});
  final Rect rect;
  final String id;
  final Widget child;
  @override
  State<_SceneFly> createState() => _SceneFlyState();
}

class _SceneFlyState extends State<_SceneFly>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560), value: 1.0);
  late Rect _from = widget.rect;
  late Rect _to = widget.rect;

  Rect get _now => Rect.lerp(
      _from, _to, Curves.easeInOutCubicEmphasized.transform(_c.value))!;

  @override
  void didUpdateWidget(_SceneFly old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _from = _now;
      _to = widget.rect;
      _c.forward(from: 0.0);
    } else if (_c.isAnimating) {
      _to = widget.rect;
    } else {
      _from = _to = widget.rect;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // ระหว่างบิน: ฉากวางขนาดปลายทางคงที่ (WebView ไม่ resize ทุกเฟรม = ไม่สะดุด)
  // แล้วย่อ/ขยายแบบสัดส่วนเดิมให้เต็มกรอบที่กำลังเลื่อน (cover + ตัดขอบ)
  // โครงเดียวตลอด (นิ่งแล้ว scale = 1) ไม่สลับ widget = WebView ไม่ถูกย้าย
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: SizedBox.fromSize(size: _to.size, child: widget.child),
        builder: (context, child) => Positioned.fromRect(
          rect: _now,
          child: ClipRect(
            child: FittedBox(fit: BoxFit.cover, child: child),
          ),
        ),
      );
}

extension _SceneHostPart on _ErFlowHomeWidgetState {
  /// ชั้นฉาก 3D ใต้เนื้อหาหน้า (วางใน Stack ของ body) · พื้นไล่สีหน้าผู้ป่วยอยู่ใต้ฉาก
  Widget _sceneHost() => Positioned.fill(
        child: LayoutBuilder(builder: (context, box) {
          return ValueListenableBuilder<_SceneSlotInfo?>(
            valueListenable: _sceneSlot,
            builder: (context, info, _) {
              final hb = context.findRenderObject();
              final o = hb is RenderBox && hb.attached && hb.hasSize
                  ? hb.localToGlobal(Offset.zero)
                  : Offset.zero;
              final scene = RepaintBoundary(child: _sceneFor(_open));
              return Stack(children: [
                // พื้นไล่สีเทาฟ้าของหน้าผู้ป่วย (ย้ายมาใต้ฉาก: หน้าอยู่ชั้นบนแล้ว)
                if (_detail && _open != null && _clyOn)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_cyBgTop, _cyBgBottom],
                        ),
                      ),
                    ),
                  ),
                // studio วาดภาพเปิด: ฉากตัวเดิมย้ายไปชั้น studio (GlobalKey เดียว)
                if (_studioOn)
                  const SizedBox.shrink()
                else if (info == null || !info.on || _regOpen)
                  Positioned.fill(child: Offstage(offstage: true, child: scene))
                else
                  _SceneFly(
                      id: info.id, rect: info.rect.shift(-o), child: scene),
              ]);
            },
          );
        }),
      );
}
