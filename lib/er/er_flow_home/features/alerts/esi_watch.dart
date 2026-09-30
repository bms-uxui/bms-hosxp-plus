// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ เฝ้าระวังระดับความเร่งด่วน (ESI + ED Trauma Triage Guide)
// ลำดับตาม ESI: ช่วยชีวิตทันที (1) → รอไม่ได้/เสี่ยงสูง (2) → สัญญาณชีพโซนอันตราย ยกจาก 3 ขึ้น 2
// เกณฑ์ตัวเลขตามคู่มือคัดแยกผู้ป่วยอุบัติเหตุในห้องฉุกเฉิน (ATLS 11th + ESI) + Shock Index / hypothermia จาก ATLS 11 primary survey
// ใช้แนะนำและเตือนเท่านั้น: ไม่เปลี่ยน / ไม่ลดระดับ ESI เอง (knowledge ข้อ 46)

/// ผลการประเมิน: ระดับที่ควรเป็น + เหตุผลที่เข้าเกณฑ์ + ควรเรียก Trauma Team
class _EsiAdvice {
  const _EsiAdvice(this.level, this.reasons, {this.traumaTeam = const []});

  final int level;
  final List<String> reasons;

  /// เกณฑ์เปิดใช้ระบบ Trauma Team ที่เข้า (ว่าง = ไม่ต้องเรียก)
  final List<String> traumaTeam;
}

/// ยาต้านการแข็งตัวของเลือด (ผู้สูงอายุที่กินยากลุ่มนี้ = กลุ่มเสี่ยงพิเศษ)
const _anticoag = [
  'warfarin',
  'apixaban',
  'rivaroxaban',
  'dabigatran',
  'edoxaban',
  'enoxaparin',
  'heparin',
  'ละลายลิ่มเลือด',
  'ต้านการแข็งตัว',
];

/// กลไกการบาดเจ็บความเสี่ยงสูง (High-risk MOI) จากคำในอาการสำคัญ/ประวัติ
/// "Trust the mechanism": กลไกรุนแรง = เสี่ยงสูงไว้ก่อนแม้ดูปกติ
const _highMoi = [
  ('ตกจากที่สูง', 'ตกจากที่สูง'),
  ('ความเร็วสูง', 'รถชนความเร็วสูง'),
  ('กระเด็น', 'กระเด็นออกจากรถ'),
  ('เสียชีวิตในที่เกิดเหตุ', 'มีผู้เสียชีวิตในที่เกิดเหตุ'),
  ('รถคว่ำ', 'รถคว่ำ'),
  ('ถูกแทง', 'บาดแผลทะลุ (ถูกแทง)'),
  ('ถูกยิง', 'บาดแผลทะลุ (ถูกยิง)'),
];

/// ประเมินระดับที่ควรเป็นจากข้อมูลผู้ป่วยล่าสุด · null = ไม่มีเกณฑ์ข้อไหนเข้า
_EsiAdvice? _esiAdvise(ErCase c, {bool trauma = false}) {
  double? last(List<double> s) => s.isEmpty ? null : s.last;
  String n(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  final gcs = int.tryParse(c.gcsScore);
  // ค่า 0 = ไม่ได้วัด (ข้อมูลว่าง) ไม่นับเป็นค่าต่ำ
  double? v(List<double> s) => (last(s) ?? 0) > 0 ? last(s) : null;
  final spo2 = v(c.spo2), sbp = v(c.sbp), hr = v(c.hr);
  final rr = last(c.rr), bt = v(c.bt);
  final story = '${c.cc} ${c.hpi}';
  final moi = [
    for (final (k, label) in _highMoi)
      if (story.contains(k)) label
  ];
  final penetrating = moi.any((m) => m.startsWith('บาดแผลทะลุ'));

  // เกณฑ์เปิดใช้ระบบ Trauma Team: SBP < 90 · GCS ≤ 13 · แผลทะลุลำตัว · ตกจากที่สูง > 6 ม.
  final team = !trauma
      ? const <String>[]
      : [
          if (sbp != null && sbp < 90) 'SBP ${n(sbp)} < 90',
          if (gcs != null && gcs <= 13) 'GCS $gcs ≤ 13',
          if (hr != null && sbp != null && sbp > 0 && hr / sbp >= 1)
            'Shock Index ${(hr / sbp).toStringAsFixed(2)} ≥ 1',
          if (penetrating) 'บาดแผลทะลุ',
          if (moi.contains('ตกจากที่สูง')) 'ตกจากที่สูง',
        ];

  // ระดับ 1 (Resuscitation) "กำลังจะตาย": หยุดหายใจ · ช็อกรุนแรง SBP < 90 · GCS ≤ 8
  final lifeSave = [
    if (rr != null && rr == 0) 'หยุดหายใจ',
    if (sbp != null && sbp < 90) 'ช็อก SBP ${n(sbp)} < 90',
    if (gcs != null && gcs <= 8) 'GCS $gcs ≤ 8',
  ];
  if (lifeSave.isNotEmpty) {
    return _EsiAdvice(1, lifeSave, traumaTeam: team);
  }

  // ระดับ 2 (Emergent) "รอไม่ได้": ปวดรุนแรง ≥ 7 · สับสน/ซึมลง · High-risk MOI · กลุ่มพิเศษ
  final high = [
    if ((c.painScore ?? 0) >= 7) 'ปวดรุนแรง ${c.painScore}/10',
    if (c.consciousness.contains('สับสน') ||
        c.consciousness.contains('ซึม') ||
        (c.gcs ?? '').contains('สับสน'))
      'สับสน/ซึมลง',
    ...moi,
    if (trauma &&
        c.age > 65 &&
        c.meds
            .any((m) => _anticoag.any((k) => m.name.toLowerCase().contains(k))))
      'อายุ > 65 ปี กินยาต้านการแข็งตัวของเลือด',
  ];

  // ATLS 11: Shock Index (HR/SBP) ≥ 1 เสียชีวิตสูงขึ้น · ≥ 0.8 ต้องให้เลือด/ผ่าตัดด่วน
  // ผู้สูงอายุ > 65 ปี ใช้ ≥ 0.7 (ชีพจรมักไม่เร็วเพราะยา beta blocker) · ตัวเย็น < 35 °C (lethal triad)
  final si = (hr != null && sbp != null && sbp > 0) ? hr / sbp : null;
  final siCut = c.age > 65 ? 0.7 : 0.8;
  if (trauma && si != null && si >= siCut) {
    high.add('Shock Index ${si.toStringAsFixed(2)} ≥ $siCut');
  }
  if (bt != null && bt < 35) high.add('ตัวเย็น ${n(bt)} °C < 35');

  // Danger zone vital signs (ผู้ใหญ่): HR > 130 หรือ < 50 · RR > 24 หรือ < 10 · SpO₂ < 92
  // เด็ก (< 3 ปี): ไข้ > 39 °C
  final danger = <String>[];
  if (c.age >= 3) {
    if (hr != null && (hr > 130 || hr < 50)) {
      danger.add('ชีพจร ${n(hr)} ${hr > 130 ? '> 130' : '< 50'}');
    }
    if (rr != null && (rr > 24 || rr < 10)) {
      danger.add('RR ${n(rr)} ${rr > 24 ? '> 24' : '< 10'}');
    }
    if (spo2 != null && spo2 < 92) danger.add('SpO₂ ${n(spo2)}% < 92');
  } else if (bt != null && bt > 39) {
    danger.add('ไข้ ${n(bt)} °C > 39 (เด็ก)');
  }

  final reasons = [...high, ...danger];
  if (reasons.isEmpty && team.isEmpty) return null;
  return _EsiAdvice(reasons.isEmpty ? 3 : 2, reasons.isEmpty ? team : reasons,
      traumaTeam: team);
}

extension _FeaturesAlertsEsiWatchPart on _ErFlowHomeWidgetState {
  /// ผู้ป่วยที่ ESI ที่บันทึกไว้ต่ำกว่าที่ควรเป็น (ระดับเลขมากกว่า) → คำแนะนำ
  _EsiAdvice? _esiGap(_P p) {
    final now = p.esi?.level;
    if (now == null) return null; // ยังไม่คัดกรอง: ไปเตือนในขั้นคัดกรองแทน
    final a = _esiAdvise(erCaseOf(p.hn), trauma: p.type == _Ptype.trauma);
    return a != null && a.level < now ? a : null;
  }

  /// การแจ้งเตือน "ควรยกระดับ ESI" ของทุกคนในห้อง (ขึ้นเป็น toast วิกฤต)
  List<_Alert> get _esiAlerts {
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    // รวบเป็นแจ้งเตือนใบเดียว (ไม่ขึ้นทีละคน): Trauma Team ขึ้นก่อน แล้วต่อด้วยควรยกระดับ ESI
    // แตะแล้วเปิดคนที่เร่งด่วนที่สุด · รายชื่อทั้งหมดอยู่ในรายละเอียด · ป้ายรายคนดูที่หัวผู้ป่วย
    final hits = <(_P, String)>[
      for (final p in _patients)
        if (p.type == _Ptype.trauma)
          if (_esiAdvise(erCaseOf(p.hn), trauma: true) case final t?)
            if (t.traumaTeam.isNotEmpty)
              (p, 'เรียก Trauma Team (${t.traumaTeam.first})'),
      for (final p in _patients)
        if (_esiGap(p) case final a?)
          (p, 'ควรเป็น ESI ${a.level} (${a.reasons.first})'),
    ];
    final seen = <String>{};
    final list = [
      for (final h in hits)
        if (seen.add(h.$1.hn)) h
    ];
    if (list.isEmpty) return const [];
    final (top, why) = list.first;
    return [
      _Alert(
        hm,
        list.length == 1
            ? '${top.name} เตียง ${top.bed ?? '—'} · $why'
            : 'ควรเร่งด่วนขึ้น ${list.length} ราย · ${top.name} $why',
        [for (final (p, w) in list) '${p.name}: $w'].join('\n'),
        _Level.critical,
        id: 'esi:${list.map((h) => h.$1.hn).join(',')}',
        hn: top.hn,
      ),
    ];
  }

  /// ป้ายเตือนข้าง pill ESI บนหัวผู้ป่วย · แตะดูเหตุผล
  Widget _esiGapBadge(_P p) {
    final a = _esiGap(p);
    if (a == null) return const SizedBox.shrink();
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      message: 'ควรเป็น ESI ${a.level} ตามเกณฑ์ ESI\n'
          '${a.reasons.map((r) => '• $r').join('\n')}\n'
          'พยาบาล/แพทย์เป็นผู้ยืนยันระดับ',
      child: Container(
        margin: const EdgeInsets.only(left: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: _red),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_upward_rounded, size: 11.0, color: _red),
          const SizedBox(width: 2.0),
          Text('ควรเป็น ESI ${a.level}',
              style: _t(9.5, color: _red, weight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
