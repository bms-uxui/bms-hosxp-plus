// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ สรุปความเร่งด่วน (คัดกรอง)
// ทบทวนเคสตามจุดตัดสินใจของ ESI v4 แล้วแนะนำระดับพร้อมเหตุผล ให้พยาบาลยืนยัน
//  A ต้องช่วยชีวิตทันที → 1 · B เสี่ยงสูง/สับสน/ปวดรุนแรง → 2
//  C จำนวนทรัพยากรที่คาดว่าใช้ (≥2 → 3, 1 → 4, 0 → 5) · D สัญญาณชีพโซนอันตราย → พิจารณา 2

const List<String> _esiOptions = [
  'ภาวะวิกฤต',
  'เร่งด่วน',
  'เร่งด่วนปานกลาง',
  'อาการไม่รุนแรงมาก',
  'ไม่เร่งด่วน',
];

extension _FeaturesWorkflowEsiAssistPart on _ErFlowHomeWidgetState {
  /// ผลประเมิน: ระดับ · เหตุผล (ข้อความ, สำคัญ) · สัญญาณชีพเสี่ยง · ประโยคสรุป
  ({int level, List<(String, bool)> why, List<String> danger, String summary})
      _esiAssess() {
    final c = _case;
    final p = _caseP();
    final hr = c.hr.last, sbp = c.sbp.last, spo2 = c.spo2.last;
    final rr = c.rr.last, bt = c.bt.last;
    final gcs = int.tryParse(c.gcsScore);
    final pain = c.painScore;
    final text = '${c.cc} ${c.hpi} ${c.condition}'.toLowerCase();
    bool has(List<String> ws) => ws.any(text.contains);
    final why = <(String, bool)>[];
    final danger = <String>[
      if (hr > 100) 'HR ${hr.round()}',
      if (rr > 20) 'RR ${rr.round()}',
      if (spo2 < 92) 'SpO₂ ${spo2.round()}%',
      if (sbp < 90) 'BP ${c.bp}',
      if (bt >= 38.5) 'BT ${bt.toStringAsFixed(1)}',
    ];
    int level;
    // A: ต้องช่วยชีวิตทันที
    final a = <String>[
      if (gcs != null && gcs <= 8) 'ไม่ตอบสนอง (GCS $gcs)',
      if (spo2 < 90) 'ออกซิเจนต่ำมาก (SpO₂ ${spo2.round()}%)',
      if (sbp < 90 && hr > 100) 'ภาวะช็อก (BP ${c.bp} · HR ${hr.round()})',
      if (rr < 8 || rr > 35) 'หายใจผิดปกติรุนแรง (RR ${rr.round()})',
      if (has(['หยุดหายใจ', 'หัวใจหยุด', 'cardiac arrest']))
        'หัวใจ/การหายใจหยุด',
    ];
    if (a.isNotEmpty) {
      level = 1;
      for (final x in a) {
        why.add((x, true));
      }
    } else {
      // B: เสี่ยงสูง สับสน/ซึม ปวดรุนแรง
      final b = <String>[
        if (p.type != null) 'เข้าเกณฑ์ช่องทางด่วน ${p.type!.label}',
        if (gcs != null && gcs < 15) 'ซึม/สับสน (GCS $gcs)',
        if (pain != null && pain >= 7) 'ปวดรุนแรง ($pain/10)',
        if (has(['เจ็บหน้าอก', 'แน่นหน้าอก']) && c.age >= 35)
          'เจ็บหน้าอกในผู้ใหญ่ อาจเป็นหัวใจขาดเลือด',
        if (has(['พูดไม่ชัด', 'ปากเบี้ยว', 'อ่อนแรงซีก']))
          'อาการสงสัยหลอดเลือดสมอง',
      ];
      if (b.isNotEmpty) {
        level = 2;
        for (final x in b) {
          why.add((x, true));
        }
      } else {
        // C: คาดการณ์ทรัพยากร (แล็บ ภาพถ่าย IV/ยาฉีด หัตถการ ปรึกษา)
        final many = has([
          'ปวดท้อง',
          'อุบัติเหตุ',
          'ล้ม',
          'หัก',
          'ผิดรูป',
          'ไข้',
          'หอบ',
          'อาเจียน',
          'เลือด',
          'ชัก',
          'หมดสติ',
        ]);
        final one =
            has(['แผล', 'ข้อเท้า', 'แพลง', 'ไอ', 'เจ็บคอ', 'ผื่น', 'ปวดหลัง']);
        if (many) {
          level = 3;
          why.add(
              ('คาดว่าต้องใช้ทรัพยากร ≥ 2 อย่าง (แล็บ · ภาพถ่าย · IV)', false));
        } else if (one) {
          level = 4;
          why.add(('คาดว่าต้องใช้ทรัพยากร 1 อย่าง', false));
        } else {
          level = 5;
          why.add(('ไม่น่าต้องใช้ทรัพยากรเพิ่ม', false));
        }
        // D: สัญญาณชีพโซนอันตราย → พิจารณาเลื่อนเป็น 2
        if (level == 3 && danger.isNotEmpty) {
          level = 2;
          why.add(('สัญญาณชีพอยู่ในโซนอันตราย: ${danger.join(', ')}', true));
        }
      }
    }
    final esi = _Esi.values[level - 1];
    final vit =
        'HR ${hr.round()} · BP ${c.bp} · SpO₂ ${spo2.round()}% · RR ${rr.round()}';
    final summary =
        '${c.sex} ${c.ageText} ${c.cc.split(' ').take(6).join(' ')} · $vit'
        ' → แนะนำ ESI $level (${esi.label}) ${level <= 2 ? 'ควรพบแพทย์ทันที' : level == 3 ? 'รอตรวจได้ไม่เกิน 30 นาที' : 'รอตามคิวได้'}';
    return (level: level, why: why, danger: danger, summary: summary);
  }

  Widget _esiAiCard() {
    final r = _esiAssess();
    final esi = _Esi.values[r.level - 1];
    const field = 'ระดับความเร่งด่วน (ESI)';
    final chosen = _filled[_speechStep][field];
    final applied = chosen == _esiOptions[r.level - 1];
    final saved = _caseP().esi;
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
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
            const Icon(Icons.auto_awesome_rounded, size: 14.0, color: _blue),
            const SizedBox(width: 5.0),
            Expanded(
              child: Text('สรุปความเร่งด่วนโดย AI',
                  style: _t(12.0, color: _blueHue, weight: FontWeight.w700)),
            ),
            Text('ตรวจทานก่อนยืนยัน', style: _t(9.5, color: _ink3)),
          ]),
          const SizedBox(height: 10.0),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 64.0,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: esi.color,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(children: [
                Text('ESI', style: _t(9.5, color: Colors.white)),
                Text('${r.level}',
                    style: _num(26.0,
                        color: Colors.white, weight: FontWeight.w700)),
                Text(esi.label,
                    style:
                        _t(9.5, color: Colors.white, weight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(r.summary,
                  style: _t(11.5, color: _inkTitle, height: 1.4)),
            ),
          ]),
          const SizedBox(height: 10.0),
          Text('เหตุผล', style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 2.0),
          for (final w in r.why)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.only(top: 5.0, right: 7.0),
                  decoration: BoxDecoration(
                      color: w.$2 ? _red : _g5, shape: BoxShape.circle),
                ),
                Expanded(
                    child:
                        Text(w.$1, style: _t(11.0, color: _ink, height: 1.35))),
              ]),
            ),
          if (saved != null && saved.level != r.level)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                  'ต่างจากที่บันทึกไว้ (ESI ${saved.level} · ${saved.label}) ควรทบทวน',
                  style: _t(10.5, color: _red, weight: FontWeight.w600)),
            ),
          const SizedBox(height: 12.0),
          Row(children: [
            Expanded(
              child: _Press(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _lastFilled = [(_speechStep, field, chosen)];
                      _filled[_speechStep][field] = _esiOptions[r.level - 1];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 36.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: applied ? _panelSoft : _blue,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                        applied
                            ? '✓ ใช้ ESI ${r.level} แล้ว'
                            : 'ใช้ ESI ${r.level} · ${esi.label}',
                        style: _t(11.5,
                            color: applied ? _blue : Colors.white,
                            weight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6.0),
          Text(
              'ประเมินตามเกณฑ์ ESI v4 จากอาการสำคัญ สัญญาณชีพ GCS และระดับความปวด · เลือกระดับอื่นได้ในฟอร์ม',
              style: _t(9.0, color: _ink3, height: 1.35)),
        ],
      ),
    );
  }
}
