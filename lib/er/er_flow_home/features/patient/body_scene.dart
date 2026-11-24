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
    // ลำดับเตียงในฉาก = ลำดับรายชื่อฝั่งซ้าย (คนที่มีเตียงก่อน แล้วเตียงที่เหลือ)
    // ฉากจัดเตียงเรียงตามนี้ · กดคนถัดไปในรายชื่อ กล้องเลื่อนไปเตียงข้าง ๆ ไม่กระโดดข้าม
    final bedOrder = [
      for (final p in people)
        if (p.bed != null && _roomBeds.contains(p.bed)) p.bed!,
      for (final code in _roomBeds)
        if (!people.any((p) => p.bed == code)) code,
    ];
    final beds = [
      for (final code in bedOrder)
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
          // หรือกำลังเลือกบริเวณที่ทำหัตถการ (แผง workflow หุบชั่วคราว)
          pickMode: cfg == null &&
              _detail &&
              (_woundField != null || _procSitePick != null),
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
        // ฉากยื่นเข้าใต้มุมโค้งแผงรายชื่อ 24: เลื่อนปุ่มพ้นแผง
        left: 36.0,
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
    final part = bone.split('.');
    final th = _boneTh[part.first] ?? part.first;
    final side = part.length > 1 ? (part[1] == 'R' ? 'ขวา' : 'ซ้าย') : '';
    final where = side.isEmpty ? th : '$th$side';
    // เลือกบริเวณที่ทำหัตถการ: ลงช่องแล้วกลับหน้าแก้หัตถการ
    if (_procSitePick != null) {
      HapticFeedback.selectionClick();
      _procSiteDone(where);
      return;
    }
    final f = _woundField;
    if (f == null) return;
    setState(() {
      final old = _filled[_speechStep][f];
      _lastFilled = [(_speechStep, f, old)];
      _filled[_speechStep][f] = old == null || old.isEmpty
          ? where
          : (old.contains(where) ? old : '$old, $where');
    });
    HapticFeedback.selectionClick();
  }

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
  String? _clyCcPhrase(ErBodyTarget t, [ErCase? of]) {
    final cc = (of ?? _case).cc;
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
            () => _openSymPane(t),
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

  /// หน้ารายการ (ผู้ป่วยนั่งรอ): สไลด์การ์ดสรุปฝั่งขวาของโถง อาการสำคัญ สัญญาณชีพ สถานะ
  List<_WaitSlide> _waitSlides(_P p) {
    final c = erCaseOf(p.hn);
    // อาการสำคัญ: หัวเรื่อง = วลีแรกของข้อความ (คนอ่านรู้เรื่องทันที) · รายละเอียด = ส่วนที่เหลือ
    final cc = c.cc.trim();
    final parts = cc.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    var take = parts.isEmpty ? 0 : 1;
    // วลีแรกสั้นมาก (เช่น "ไอ") = ต่อวลีถัดไปให้พอเข้าใจ
    while (take < parts.length && parts.take(take).join(' ').length < 6) {
      take++;
    }
    final ccTitle = parts.take(take).join(' ');
    final ccRest = parts.skip(take).join(' ');
    final bad = [
      for (final v in _vitalsFor(c))
        if (v.color == _red && (v.display ?? '').isNotEmpty) v
    ];
    final at = c.times.isEmpty ? null : _clock(c.times.last);
    String val(ErVital v) => '${v.label} ${v.display} ${v.unit}'.trim();
    return [
      _WaitSlide(
        'อาการสำคัญ',
        'assets/images/notepad_3d.png',
        ccTitle.isEmpty ? 'ยังไม่ได้บันทึก' : ccTitle,
        ccRest.isEmpty
            ? (cc.isEmpty
                ? 'ยังไม่มีอาการสำคัญจากการส่งตรวจ'
                : 'ตามที่ผู้ป่วยหรือญาติแจ้งตอนมาถึง')
            : ccRest,
        glyph: Icons.assignment_rounded,
      ),
      _WaitSlide(
        'สัญญาณชีพ',
        'assets/images/er_vs_bt3d.png',
        at == null
            ? 'ยังไม่ได้วัด'
            : bad.isEmpty
                ? 'ปกติทุกค่า'
                : 'ผิดปกติ ${bad.length} ค่า',
        at == null
            ? 'รอพยาบาลวัดสัญญาณชีพตอนคัดกรอง'
            : bad.isEmpty
                ? 'วัดล่าสุดเมื่อ $at ทุกค่าอยู่ในช่วงปกติ'
                // ค่าผิดปกติบรรทัดแรก (คั่นจุลภาค) · เวลาวัดบรรทัดสอง
                : '${bad.take(3).map(val).join(', ')}\nวัดล่าสุดเมื่อ $at',
        alert: bad.isNotEmpty,
        glyph: Icons.monitor_heart_rounded,
      ),
      _WaitSlide(
        p.stage.label,
        p.esi == null
            ? 'assets/images/notepad_3d.png'
            : 'assets/images/ESI${p.esi!.level}.png',
        'รอมาแล้ว ${_hm(p.waitMin)}',
        p.esi == null
            ? 'ยังไม่ได้คัดกรอง จึงยังไม่มีระดับความเร่งด่วน (ESI)'
            : 'คัดกรองแล้ว ระดับความเร่งด่วน ESI ${p.esi!.level} (${p.esi!.label})',
        // นาฬิกาแบบทึบ (เข็มเป็นช่องขาว): ไอคอนเส้นโปร่งจะเห็นแผ่นรองขาวเป็นกล่องในหน้าปัด
        glyph: Icons.watch_later_rounded,
      ),
    ];
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

  /// แตะป้ายอาการบนหุ่น: เปิดข้อมูลของตำแหน่งนั้นใน workflow panel (ช่อง _accPane แบบใบรับรองแพทย์)
  /// ปิด = กลับสภาพเดิม (เดิมไม่ได้กางแผง = หุบแผงกลับเป็นราง)
  void _openSymPane(ErBodyTarget t) {
    final was = _speechOpen && _speechHn == _caseP().hn;
    final p = _accPaneReset();
    void close() {
      if (was) {
        setState(_accPaneDrop);
      } else {
        _closeSpeech();
      }
    }

    setState(() {
      _symPaneOn = true;
      _accPane = KeyedSubtree(
        key: PageStorageKey('sym-${p.hn}-${t.code}'),
        child: Builder(builder: (_) => _symPane(t, close)),
      );
    });
  }

  /// ขั้น workflow ที่เป็นที่มาของป้ายนี้ (ตามบทบาทที่ login) · ไม่มีขั้นนั้นในบทบาทนี้ = null
  /// CC = อาการสำคัญ/ซักประวัติ/HPI · DX = วินิจฉัย · PE = ตรวจร่างกาย · แผล = ขั้นที่มีช่องแผล
  int? _symSourceStep(ErBodyTarget t) {
    final labels = [for (final s in _steps) s.$2];
    int? first(List<String> names) {
      for (final n in names) {
        final i = labels.indexOf(n);
        if (i >= 0) return i;
      }
      return null;
    }

    // ป้ายที่ขึ้นเป็น CC (ข้อความจากอาการสำคัญ) = ที่มาคืออาการสำคัญ ตามที่ผู้ใช้เห็นบนหุ่น
    return switch (_clyCcPhrase(t) != null ? 'CC' : _clySource(t)) {
      'DX' => first(['วินิจฉัย']),
      'PE' => first(['ตรวจร่างกาย']),
      'แผล' => () {
          final f = _forms;
          for (var i = 0; i < labels.length && i < f.length; i++) {
            if (f[i].any((x) => x.$1.contains('แผล'))) return i;
          }
          return first(['ตรวจร่างกาย']);
        }(),
      _ => first(['อาการสำคัญ', 'ซักประวัติ', 'ประวัติ HPI', 'คัดกรอง']),
    };
  }

  /// จากหน้าข้อมูลตำแหน่ง ไปขั้นที่มาใน workflow เดียวกัน (แก้ไขต่อได้ทันที)
  /// ข้ามหน้าแนะนำ: เข้าหน้ากรอกแรกของขั้นเลย (ส่วนแรกของขั้นที่มา = ข้อมูลของป้ายนี้
  /// เช่น ซักประวัติเริ่มที่อาการสำคัญ)
  void _symGoStep(int i) {
    ErFeedback.tap();
    if (i != _speechStep) _tplOpen = null;
    setState(_accPaneDrop);
    _openSpeech(step: i);
    // ขั้นของพยาบาลที่ครอบด้วยหน้าแนะนำ (_wfIntroGate ใน _clyGuideBody): หน้า 1 = ฟอร์ม
    const gated = {
      'รับคำสั่งแพทย์',
      'สัญญาณชีพ',
      'ซักประวัติ',
      'คัดกรอง',
      'ความรุนแรง AIS',
      'สังเกตอาการ',
    };
    final nurseGate =
        ErSession.instance.role == ErRole.nurse && gated.contains(_steps[i].$2);
    if (nurseGate) {
      setState(() => _uiIdx = 1);
    } else {
      final seq = _uiSeq;
      if (_pageCount(seq) > 1) _pageGo(seq, 1);
    }
  }

  /// หน้าข้อมูลของตำแหน่งอาการใน workflow panel: ชื่อบริเวณ · การวินิจฉัย · บาดแผล · ภาพถ่ายทางรังสี
  /// การ์ดชุดเดียวกับขั้นอื่น (_dxCard) · ปุ่มปิดลอยด้านล่าง (_wfFadePage)
  Widget _symPane(ErBodyTarget t, VoidCallback close) {
    final hit = t.hit.toLowerCase();
    final dx = [
      for (final d in _case.dx)
        if (hit.isNotEmpty && d.text.toLowerCase().contains(hit)) d
    ];
    final wound = _clySource(t) == 'แผล';
    // ภาพรังสี: ไม่แสดงที่จุดแผล
    final imgs = wound ? const <ErImage>[] : _symImages(t);
    final woundRows = wound
        ? _woundSection((_) => const SizedBox.shrink())
        : const <Widget>[];
    final side =
        switch (t.side) { 'l' => 'ด้านซ้าย', 'r' => 'ด้านขวา', _ => '' };
    final title = _clyLabelText(t);
    // ชื่อรองซ้ำกับหัวข้อ = ไม่แสดงซ้ำ (เหลือเฉพาะข้างซ้าย/ขวา)
    final sub = [if (t.th != title) t.th, if (side.isNotEmpty) side].join(' ');
    Widget card(String title, String sub, Widget art, List<Widget> body) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _dxCard(
              title,
              sub,
              art,
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: body),
              )),
        );
    final empty = dx.isEmpty && woundRows.isEmpty && imgs.isEmpty;
    // ที่มาของป้าย (ปุ่มหลัก) · แถววินิจฉัยแตะไปขั้นวินิจฉัย · ภาพรังสีแตะไปหน้า Lab/X-Ray แผงซ้าย
    final src = _symSourceStep(t);
    final dxStep = [for (final s in _steps) s.$2].indexOf('วินิจฉัย');
    return _wfFadePage(
      ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 96.0),
        children: [
          // หัวหน้า: ชื่อตำแหน่ง + บริเวณ
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2.0),
                Text(sub,
                    style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
              ],
            ]),
          ),
          // ไม่มีข้อมูลของบริเวณนี้เลย = ภาพเทา + บอกชัด ๆ (ชุดเดียวกับ empty state แผงซ้าย)
          if (empty)
            _clyEmptyState(
                Image.asset('assets/images/er_dx_doctor_t.png'),
                'ยังไม่มีข้อมูลของบริเวณนี้',
                'เมื่อมีการวินิจฉัย บาดแผล หรือภาพถ่ายทางรังสีของบริเวณนี้ จะแสดงที่นี่'),
          if (dx.isNotEmpty)
            card('การวินิจฉัย', 'การวินิจฉัยที่ตรงกับบริเวณนี้',
                _mcArt('assets/images/er_dx_doctor_t.png'), [
              for (final (i, d) in dx.indexed)
                _gListRow(
                  first: i == 0,
                  inset: 8.0,
                  lead: _McGIcon(Icons.assignment_rounded, on: true),
                  title: d.text,
                  titleLines: 3,
                  onTap: dxStep < 0 ? null : () => _symGoStep(dxStep),
                  sub: d.icd10 ?? 'การวินิจฉัย',
                  trail: d.level == ErLevel.critical
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: _red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text('วิกฤต',
                              style: _t(11.0,
                                  color: _red, weight: FontWeight.w700)),
                        )
                      : null,
                ),
            ]),
          if (woundRows.isNotEmpty)
            card('บาดแผล', 'รูปบาดแผลที่บันทึกไว้ แตะเพื่อดูเต็มจอ',
                const SizedBox.shrink(), [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: woundRows),
              ),
            ]),
          if (imgs.isNotEmpty)
            card('ภาพถ่ายทางรังสี', 'แตะภาพเพื่อเปิดหน้า Lab/X-Ray',
                _mcArt('assets/images/er_os_xray.png'), [
              for (final im in imgs)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 10.0),
                  child: _Press(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ErFeedback.tap();
                      setState(() => _detailTab = _xrayTab);
                    },
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
                        const SizedBox(height: 6.0),
                        Row(children: [
                          Expanded(
                            child: Text(im.name,
                                style: _t(13.0,
                                    color: _inkTitle, weight: FontWeight.w600)),
                          ),
                          Text(im.result,
                              style: _t(12.0,
                                  color: im.result.startsWith('รอ')
                                      ? _ink3
                                      : _blue,
                                  weight: FontWeight.w600)),
                        ]),
                      ],
                    ),
                  )),
                ),
            ]),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        // มีขั้นที่มา: ← ปิด · ปุ่มหลัก = ไปแก้ที่ขั้นนั้น · ไม่มี (บทบาทนี้ไม่มีขั้นนั้น) = ปิดอย่างเดียว
        child: Row(children: [
          _wfFootBack(src == null ? null : close),
          Expanded(
              child: src == null
                  ? _navBtn('ปิด', Icons.close_rounded, close)
                  : _navBtn('แก้ไขที่${_steps[src].$2}',
                      Icons.chevron_right_rounded, () => _symGoStep(src),
                      trailing: true)),
        ]),
      ),
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

/// ฉากเป็นของหน้าผู้ป่วย (ตั้งโดย [_PageCross] ทันทีที่กด ไม่ต้องรอ build หน้าใหม่)
bool _sceneOnDetail = false;

/// จังหวะเปลี่ยนหน้า 0 = หน้าเตียง · 1 = หน้าผู้ป่วย (แผง [_PagePart] เลื่อนตามค่านี้)
final ValueNotifier<double> _pageT = ValueNotifier(0.0);

/// แผงที่เลื่อนเข้า/ออกตอนเปลี่ยนหน้าเตียง ↔ หน้าผู้ป่วย (แทนการจางทั้งหน้า)
/// [dir] = ทิศที่แผงหนีออกไป (สัดส่วนขนาดแผง) · [detail] = แผงของหน้าผู้ป่วย (เลื่อนเข้า)
/// โครง widget คงที่ทุกสถานะ (ไม่สร้างเนื้อหาใหม่) · ค่าเปลี่ยน = วาดแค่ชั้น transform
class _PagePart extends StatelessWidget {
  const _PagePart(
      {required this.dir, required this.detail, required this.child});
  final Offset dir;
  final bool detail;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
        valueListenable: _pageT,
        child: RepaintBoundary(child: child),
        builder: (context, t, child) {
          // หน้าเตียงออกช่วงแรก (เร่งออก) · หน้าผู้ป่วยเข้าช่วงหลัง (ชะลอเข้าที่)
          final k = detail
              ? 1.0 -
                  Curves.easeOutCubic
                      .transform(((t - 0.3) / 0.7).clamp(0.0, 1.0))
              : Curves.easeInCubic.transform((t / 0.55).clamp(0.0, 1.0));
          return FractionalTranslation(
            translation: dir * k,
            child: Opacity(opacity: (1.0 - k).clamp(0.0, 1.0), child: child),
          );
        },
      );
}

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
      // เท่ากับเวลาฉากบิน (560 ms): หน้าใหม่ขึ้นเต็มพร้อมฉากถึงที่
      duration: const Duration(milliseconds: 560),
      value: widget.detail ? 1.0 : 0.0)
    ..addStatusListener((_) => setState(() {}))
    ..addListener(_tick);
  // ทั้งสองหน้าทึบตลอด: แผงในหน้าเลื่อนเข้า/ออกเอง ([_PagePart]) ไม่จางทั้งหน้า
  // หน้าเตียงหายเมื่อหน้าผู้ป่วยขึ้นเต็มแล้วเท่านั้น · หน้าผู้ป่วยหายเมื่อกลับถึงหน้าเตียง
  late final Animation<double> _out = ReverseAnimation(
      CurvedAnimation(parent: _c, curve: const Threshold(1.0)));
  late final Animation<double> _in = Tween(begin: 0.01, end: 1.0)
      .animate(CurvedAnimation(parent: _c, curve: const Threshold(0.001)));
  Widget? _detailCache;
  late Widget _bedsCache = widget.beds;
  // กลับมาหน้าเตียงแล้ว: ใช้หน้าเตียงชุดเดิมต่ออีกครู่ (ฉากยังบินอยู่) ค่อยอัปเดตทีหลัง
  Timer? _thaw;
  bool _frozen = false;

  @override
  void initState() {
    super.initState();
    _sceneOnDetail = widget.detail;
    _pageT.value = widget.detail ? 1.0 : 0.0;
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

  void _tick() => _pageT.value = _c.value;

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
            child: RepaintBoundary(
                child: KeyedSubtree(
                    key: const ValueKey('page-detail'), child: _detailCache!)),
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

  // ระหว่างบิน: WebView ขยาย/หดตามกรอบจริงทุกเฟรม กล้อง 3D จัดเฟรมใหม่ต่อเนื่อง
  // (เดิมวางขนาดปลายทางแล้ว cover ย่อ/ขยาย = ภาพซูมกระโดดตอนเริ่ม หุ่นแกว่ง)
  // โครงเดียวตลอด ไม่สลับ widget = WebView ไม่ถูกย้าย
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final r = _now;
          return Positioned.fromRect(
            rect: r,
            child: ClipRect(
              child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox.fromSize(size: r.size, child: child)),
            ),
          );
        },
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

/// สไลด์ของการ์ดสรุปผู้ป่วยนั่งรอ: ป้ายหัวข้อ ไอคอน 3D หัวเรื่อง รายละเอียด
class _WaitSlide {
  const _WaitSlide(this.tag, this.icon, this.title, this.body,
      {this.alert = false, this.glyph = Icons.info_rounded});
  final String tag, icon, title, body;

  /// ไอคอนตัวหนาในกรอบสีบนการ์ด (ภาพ 3D [icon] ใช้ในหน้าต่าง FYI)
  final IconData glyph;

  /// รายละเอียดเป็นค่าผิดปกติ (ตัวหนังสือแดง)
  final bool alert;
}

/// การ์ดสรุปผู้ป่วยฝั่งขวาของโถงนั่งรอ: เปลี่ยนสไลด์เองทุก 4.5 วิ (จางเข้า เลื่อนขึ้นนิด)
/// ภาษาเดียวกับแอป: การ์ดลอยเหนือฉาก ขาว ขอบ #DADCE0 มุม 14 เงา navy จาง · ภาพ 3D มุมขวาบนไม่มีกล่อง/เงา
/// เปิดหน้าต่าง FYI ของการ์ดสรุปผู้ป่วยนั่งรอ = การ์ดหยุดเปลี่ยนสไลด์
final ValueNotifier<bool> _waitInfoOpen = ValueNotifier(false);

/// FYI: การ์ดสรุปมีอะไรบ้าง และแต่ละใบคิดมาจากข้อมูลไหน (ตามโค้ด _waitSlides)
Future<void> _showWaitInfo(BuildContext context) {
  // ไอคอนชุดเดียวกับการ์ด: ตัวหนาสีขาวในกรอบมนกรมท่า
  Widget sec(IconData icon, String title, List<String> lines) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ไอคอนชุดเดียวกับการ์ดสรุป (สองโทนบนวงสีอ่อน แบบหน้าใบรับรองแพทย์)
          _McGIcon(icon, on: true),
          const SizedBox(width: 12.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: _pt(15.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 4.0),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(l,
                      style: _pt(13.0, color: _ink2, weight: FontWeight.w500)),
                ),
            ]),
          ),
        ]),
      );
  _waitInfoOpen.value = true;
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: _panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('การ์ดสรุปผู้ป่วยมาจากไหน',
                    style:
                        _pt(18.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(height: 4.0),
                Text(
                    'สรุปจากข้อมูลที่บันทึกไว้ในระบบ เปลี่ยนเรื่องให้ดูเองทุก 4–5 วินาที เป็นข้อมูลช่วยดูภาพรวม ไม่ใช่การวินิจฉัย',
                    style: _pt(13.0, color: _ink3, weight: FontWeight.w500)),
                const SizedBox(height: 18.0),
                sec(Icons.assignment_rounded, 'อาการสำคัญ', [
                  'หัวเรื่องคือวลีแรกของอาการสำคัญ ส่วนที่เหลืออยู่ในรายละเอียด',
                  'ข้อความเต็มคืออาการสำคัญที่บันทึกตอนส่งตรวจหรือคัดกรอง',
                ]),
                sec(Icons.monitor_heart_rounded, 'สัญญาณชีพ', [
                  'ใช้ค่าที่วัดล่าสุด เทียบช่วงปกติของผู้ใหญ่',
                  'HR 60–100, BP 90–139/60–89, RR 12–20, BT 36.5–37.5 และ SpO₂ ≥ 94',
                  'ค่าที่อยู่นอกช่วงขึ้นเป็นสีแดง แสดงได้สูงสุด 3 ค่า พร้อมเวลาที่วัด',
                ]),
                sec(Icons.watch_later_rounded, 'สถานะและเวลารอ', [
                  'ขั้นตอนปัจจุบันของผู้ป่วยในห้องฉุกเฉิน',
                  'เวลารอนับตั้งแต่ลงทะเบียนมาถึง ER',
                  'ระดับความเร่งด่วน (ESI) จากพยาบาลคัดกรอง ยังไม่คัดกรองจะยังไม่มี ESI',
                ]),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('เข้าใจแล้ว',
                        style:
                            _pt(14.0, color: _blue, weight: FontWeight.w700)),
                  ),
                ),
              ]),
        ),
      ),
    ),
  ).whenComplete(() => _waitInfoOpen.value = false);
}

class _WaitSummaryCard extends StatefulWidget {
  const _WaitSummaryCard({super.key, required this.slides});
  final List<_WaitSlide> slides;
  @override
  State<_WaitSummaryCard> createState() => _WaitSummaryCardState();
}

class _WaitSummaryCardState extends State<_WaitSummaryCard>
    with TickerProviderStateMixin {
  int _i = 0;
  Timer? _t;

  /// เดินจากการ์ดใบเดิมไปใบใหม่ (0 = เพิ่งเปลี่ยน · 1 = จบ)
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560), value: 1.0);

  /// ตอนการ์ดโผล่ครั้งแรก: กองลอยขึ้น + ใบหลังคลี่ออกมาจากใต้ใบหน้า
  /// รอให้ผู้ป่วยในฉาก 3D จางเข้าจนชัดก่อน (โถง ~0.75 วิ · เปลี่ยนคน ~0.45 วิ) การ์ดค่อยตามมา
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 820));
  Timer? _inDelay;

  @override
  void initState() {
    super.initState();
    _inDelay = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _in.forward();
    });
    _t = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!mounted ||
          widget.slides.length < 2 ||
          !_in.isCompleted ||
          _waitInfoOpen.value) {
        return;
      }
      setState(() => _i = (_i + 1) % widget.slides.length);
      _c.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _inDelay?.cancel();
    _c.dispose();
    _in.dispose();
    super.dispose();
  }

  /// การ์ดหนึ่งใบ (สูงเท่ากันทุกใบ ซ้อนกันได้พอดี)
  /// เนื้อหาสไลด์หนึ่งใบ (แบบ widget กระจก): หัวข้อเล็ก · ไอคอนในกรอบมน · หัวเรื่องตัวใหญ่ · รายละเอียดสั้น
  Widget _content(int idx) {
    final s = widget.slides[idx];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 20.0, 40.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.tag, style: _pt(15.0, color: _ink2, weight: FontWeight.w600)),
          const SizedBox(height: 18.0),
          // ไอคอนสองโทนบนวงสีอ่อน ชุดเดียวกับหน้าใบรับรองแพทย์ (_McGIcon) · ผิดปกติ = โทนแดง
          _McGIcon(s.glyph, on: true, alert: s.alert, size: 56.0),
          const SizedBox(height: 16.0),
          Text(s.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _pt(24.0, color: _inkTitle, weight: FontWeight.w800)
                  .copyWith(height: 1.2)),
          const SizedBox(height: 6.0),
          Text(s.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _pt(13.0,
                      color: s.alert ? _red : _ink2,
                      weight: s.alert ? FontWeight.w600 : FontWeight.w500)
                  .copyWith(height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.slides.length;
    return AnimatedBuilder(
      animation: Listenable.merge([_c, _in]),
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        final rise =
            Curves.easeOutCubic.transform((_in.value / 0.6).clamp(0.0, 1.0));
        // เปลี่ยนสไลด์: เนื้อหาเดิมเลื่อนขึ้นจางหาย เนื้อหาใหม่เลื่อนขึ้นจากล่าง (ตามจุดแนวตั้ง)
        Widget slide(int idx, double y, double op) => Opacity(
              opacity: op.clamp(0.0, 1.0),
              child: Transform.translate(
                  offset: Offset(0.0, y), child: _content(idx)),
            );
        final body = Stack(children: [
          // ตัววัดความสูง: สไลด์ที่ยาวสุด = ความสูงการ์ด (ทุกสไลด์สูงเท่ากัน)
          for (var k = 0; k < n; k++)
            Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _content(k)),
          if (t < 0.999 && n > 1)
            Positioned.fill(
                child: slide((_i - 1 + n) % n, -24.0 * t, 1.0 - t * 1.6)),
          Positioned.fill(
              child:
                  slide(_i, 24.0 * (1.0 - t), t < 0.999 ? t * 1.4 - 0.4 : 1.0)),
          // จุดบอกสไลด์แนวตั้ง มุมขวาบน
          Positioned(
            right: 18.0,
            top: 22.0,
            child: Column(children: [
              for (var k = 0; k < n; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.only(bottom: 9.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: k == _i ? _blue : const Color(0xFFC9CED8),
                    shape: BoxShape.circle,
                  ),
                ),
            ]),
          ),
        ]);
        // การ์ดกระจกขาว: ฉากด้านหลังเบลอ + ขาวโปร่ง + ขอบขาว
        final card = ClipRRect(
          borderRadius: BorderRadius.circular(28.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.86),
                    Colors.white.withValues(alpha: 0.70),
                  ],
                ),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: body,
            ),
          ),
        );
        if (rise >= 0.999) return card;
        return Opacity(
          opacity: rise,
          child: Transform.translate(
            offset: Offset(0.0, (1.0 - rise) * 24.0),
            child: Transform.scale(scale: 0.96 + 0.04 * rise, child: card),
          ),
        );
      },
    );
  }
}
