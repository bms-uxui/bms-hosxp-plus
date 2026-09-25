// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

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
mixin _FeaturesPatientBodySceneState on State<ErFlowHomeWidget> {
  /// ชั้นกายวิภาคที่กำลังดูในหน้ารายละเอียด skin | bone | organ | vessel
  String _layer = 'skin';

  /// ตำแหน่งบนจอของจุดสำคัญบนตัวหุ่น (จากฉากสามมิติ) ไว้วางเครื่องหมายอาการ
  List<ErBedScreenPos> _hotspots = const [];

  // ------------------------------------------------ ภาพรวม: แบบ ClyHealth
  // ซ้าย = รางระบบร่างกาย + หุ่น 3D ครึ่งจอ + การ์ดแจ้งเตือนมุมล่าง
  // ขวา = แผงกระจก: หัวระบบ + แถบความเสี่ยง · KPI · ค่าที่ต้องจับตา
  //        · แผนการดูแล (แท็บ) · แถบขั้นถัดไป

  /// ระบบที่เลือกบนราง (0 = ภาพรวม)
  int _clySys = 0;

  /// ซูมหุ่น (ปุ่ม + / − / พอดีจอ)
  double _clyZoom = 1.15;
  int _clyZoomTick = 1;
}

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
    final beds = [
      for (final code in _roomBeds)
        ErRoomBed(
          code: code,
          color: byBed[code]?.esi?.color ?? _ink3,
          vacant: !byBed.containsKey(code),
        ),
    ];
    final sel = _sceneSelected(phase);
    return ErRoom3D(
      // GlobalObjectKey ให้ WebView ตัวเดิมย้ายไปอยู่หน้ารายละเอียดได้
      // กล้องจึงเลื่อนต่อเนื่อง ไม่ต้องโหลดฉากใหม่
      key: GlobalObjectKey(phase),
      beds: beds,
      selectedCode: sel.bed ?? _roomBeds.first,
      cam: const ErCam(),
      onBedTap: (code) {
        final hit = byBed[code];
        if (hit != null) setState(() => _sceneHn = hit.hn);
      },
      topView: _detail,
      pageBg: _clyOn ? 0xF1F3F4 : 0xFFFFFF,
      zoom: _clyZoom,
      zoomTick: _clyZoomTick,
      layer: _detail ? _layer : 'skin',
      highlight: _detail
          ? (_summaryOpen ? _summaryOrgans() : _highlightOrgans())
          : const [],
      onHotspots: (list) {
        if (!mounted || !_detail) return;
        // ฉากส่งตำแหน่งมาเรื่อย ๆ (แม้นิ่ง) ใช้แค่วาดวงเพ่งอาการ
        // rebuild ทั้งหน้าเฉพาะตอนมีวงเพ่งและตำแหน่งขยับจริง
        final moved = !_samePos(_hotspots, list);
        _hotspots = list;
        if (moved && (_focusSpot != null || _clyOn)) setState(() {});
      },
      // ช่องตำแหน่งบาดแผลเปิดอยู่: แตะบนหุ่นเพื่อระบุตำแหน่ง
      pickMode: _detail && _woundField != null,
      onBodyPick: _onBodyPick,
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
    setState(() => _sceneHn = ordered[i].hn);
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

  void _clySetZoom(double z) => setState(() {
        _clyZoom = z.clamp(0.5, 1.6);
        _clyZoomTick++;
      });

  /// ความกว้างพื้นที่หุ่น (ครึ่งซ้ายของจอ)
  double get _clySceneW => MediaQuery.sizeOf(context).width * 0.47;

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

  /// ป้ายชี้อาการบนหุ่น: จุดขาวบนตัว + เส้นนำ + ป้ายเม็ดยาสีเข้ม
  List<Widget> _clyLabels() {
    final spots = {
      for (final h in _hotspots)
        if (h.visible) h.code: h,
    };
    if (spots.isEmpty) return const [];
    final w = _clySceneW;
    final used = <String>{};
    final out = <Widget>[];
    var n = 0;
    for (final t in erBodyTargets(_case)) {
      if (n >= 3) break;
      final key = t.code;
      if (used.contains(key)) continue;
      final spot = spots[key];
      if (spot == null) continue;
      used.add(key);
      n++;
      final x = spot.dx;
      final y = spot.dy;
      final right = x < w * 0.55;
      const len = 46.0;
      final bad = t.kind != ErBodyKind.zone;
      out.add(Positioned(
        left: right ? x : x - len,
        top: y - 0.5,
        child: IgnorePointer(
          child: Container(
              width: len, height: 1.0, color: _blue.withValues(alpha: 0.45)),
        ),
      ));
      out.add(Positioned(
        left: x - 5.0,
        top: y - 5.0,
        child: IgnorePointer(
          child: Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: bad ? _red : _cySlate,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                    color: (bad ? _red : _cySlate).withValues(alpha: 0.4),
                    blurRadius: 8.0),
              ],
            ),
          ),
        ),
      ));
      final label = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
        decoration: BoxDecoration(
          gradient: _glossGrad(_blue),
          borderRadius: BorderRadius.circular(100.0),
          boxShadow: _glossLift(_blue),
        ),
        foregroundDecoration: const _InnerGloss(100.0, dark: true),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6.0, height: 1.5, color: Colors.white),
          const SizedBox(width: 5.0),
          Text(_clyLabelText(t),
              style: _t(10.5, color: Colors.white, weight: FontWeight.w500)),
        ]),
      );
      out.add(Positioned(
        left: right ? x + len : null,
        right: right ? null : MediaQuery.sizeOf(context).width - (x - len),
        top: y - 11.0,
        child: IgnorePointer(child: label),
      ));
    }
    return out;
  }

  List<String> _highlightOrgans() {
    final sys = _clyHighlight();
    if (sys != null) return sys;
    // หน้าอื่น: อวัยวะ + กระดูกที่ map จากอาการสำคัญ/วินิจฉัยของผู้ป่วยรายนี้
    return _bodyCodesOfCase(_case);
  }
}
