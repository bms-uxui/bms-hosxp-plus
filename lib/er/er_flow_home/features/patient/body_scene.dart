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
  List<ErBedScreenPos> _hotspots = const [];

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
      // หน้าภาพรวมห้อง: จอ monitor เหนือหัวเตียงที่เลือกแสดง V/S · หน้ารายละเอียด = ซ่อน
      vitals: _detail ? null : _sceneVitalsData(sel),
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

  void _clySetZoom(double z) => setState(() {
        _clyZoom = z.clamp(0.5, 1.6);
        _clyZoomTick++;
      });

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
    var a = i;
    for (final v in const ['ปวด', 'เจ็บ', 'บวม', 'ชา']) {
      if (a >= v.length && cc.substring(a - v.length, a) == v) {
        a -= v.length;
        break;
      }
    }
    var b = math.min(cc.length, i + hit.length + 10);
    final rest = cc.substring(i + hit.length, b);
    for (final stop in const ['และ', ' ', ',', '·', ' ร่วม', 'มา']) {
      final k = rest.indexOf(stop);
      if (k >= 0) b = math.min(b, i + hit.length + k);
    }
    return cc.substring(a, b).trim();
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
    // ป้ายแบบเดิม (คอลัมน์ข้างหุ่น + เส้นนำ) แต่เรียบขึ้น:
    // เส้นนำบางเส้นเดียวแนวนอน→หักมุมครั้งเดียว · จุดวงขาวแกนสี · pill ขาวมีจุดสีตรงกับจุดบนหุ่น
    if (picks.isEmpty) return const [];
    const palette = [
      Color(0xFFE5484D),
      Color(0xFFF59E0B),
      Color(0xFF7C5CFF),
      Color(0xFF12A594),
    ];
    const gap = 38.0;
    picks.sort((p, q) => p.$2.dy.compareTo(q.$2.dy));
    final sw = MediaQuery.sizeOf(context).width;
    final maxX = picks.map((p) => p.$2.dx).reduce(math.max);
    final minX = picks.map((p) => p.$2.dx).reduce(math.min);
    // ป้ายวางฝั่งที่ว่างกว่า ความกว้างป้ายตามที่ว่าง (ไม่ล้นใต้รางขวา/แผงซ้าย ตัด … แทน)
    final railX = sw - 96.0;
    final leftX = _clySceneXTarget + 12.0;
    final spaceR = railX - (maxX + 24.0);
    final spaceL = (minX - 24.0) - leftX;
    final right = spaceR >= spaceL;
    final colW = (right ? spaceR : spaceL).clamp(90.0, 200.0);
    final colX = right ? maxX + 24.0 : minX - 24.0;
    final ys = <double>[];
    for (final (_, spot) in picks) {
      ys.add(ys.isEmpty ? spot.dy : math.max(spot.dy, ys.last + gap));
    }
    final out = <Widget>[];
    final leaders = <List<Offset>>[];
    for (var i = 0; i < picks.length; i++) {
      final (t, spot) = picks[i];
      final col = palette[i % palette.length];
      final ly = ys[i];
      // หักมุมครั้งเดียวใกล้ป้าย: จุด → แนวนอนถึงก่อนคอลัมน์ → ขึ้น/ลงถึงแนวป้าย
      final elbow = right ? colX - 12.0 : colX + 12.0;
      leaders.add(
          [spot, Offset(elbow, spot.dy), Offset(elbow, ly), Offset(colX, ly)]);
      out.add(Positioned(
        left: spot.dx - 7.0,
        top: spot.dy - 7.0,
        child: IgnorePointer(
          child: Container(
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
                decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          ),
        ),
      ));
      // ตำแหน่งที่อยู่ในอาการสำคัญ: ป้าย CC + วลีจาก CC (ตรงกับการ์ดอาการสำคัญ)
      final ccPhrase = _clyCcPhrase(t);
      final src = ccPhrase != null ? 'CC' : _clySource(t);
      final text = ccPhrase ?? _clyLabelText(t);
      out.add(Positioned(
        left: right ? colX : null,
        right: right ? null : sw - colX,
        top: ly - 15.0,
        child: _Press(
          child: GestureDetector(
            // แตะป้าย = เข้าไปดูรูปของตำแหน่งนั้น
            onTap: () => setState(() => _symOpen = t),
            child: Container(
              height: 30.0,
              constraints: BoxConstraints(maxWidth: colW),
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6.0),
                Text(src,
                    style: _t(10.0, color: _ink3, weight: FontWeight.w700)),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 16.0, color: _ink3),
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
                painter: _LeaderLines(leaders, const Color(0xFFB8BEC6))),
          ),
        ));
    return out;
  }

  List<String> _highlightOrgans() {
    final sys = _clyHighlight();
    if (sys != null) return sys;
    // หน้าอื่น: อวัยวะ + กระดูกที่ map จากอาการสำคัญ/วินิจฉัยของผู้ป่วยรายนี้
    return _bodyCodesOfCase(_case);
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
                    border: Border.all(color: _line),
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
  const _LeaderLines(this.lines, this.color);

  final List<List<Offset>> lines;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (final pts in lines) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderLines old) =>
      old.color != color ||
      old.lines.length != lines.length ||
      [
        for (var i = 0; i < lines.length; i++)
          old.lines[i].join() != lines[i].join()
      ].any((x) => x);
}
