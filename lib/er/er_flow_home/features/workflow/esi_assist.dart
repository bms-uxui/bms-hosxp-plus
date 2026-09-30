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
            Column(mainAxisSize: MainAxisSize.min, children: [
              _EsiGauge(
                level: r.level,
                mark: saved?.level,
                width: 140.0,
                center: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('ESI',
                      style: _t(9.5, color: _ink2, weight: FontWeight.w500)),
                  Text('${r.level}',
                      style:
                          _num(30.0, color: _inkTitle, weight: FontWeight.w700)
                              .copyWith(height: 1.0)),
                ]),
              ),
              const SizedBox(height: 6.0),
              // ป้ายชื่อระดับใต้หน้าปัด แบบป้ายเป้าหมายของต้นฉบับ
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: esi.color,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(esi.label,
                    style:
                        _t(11.0, color: Colors.white, weight: FontWeight.w700)),
              ),
            ]),
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

/// หน้าปัดครึ่งวงแบ่ง 5 ช่อง ESI 5 (ซ้าย) → ESI 1 (ขวา) แบบ SegmentDial ของ er-registry
/// ช่องหนามุมมน ไล่สีตามระดับ เติมจากซ้ายถึงระดับปัจจุบัน
/// เข็มปลายจุด = ระดับที่ควรเป็น/ที่บันทึกไว้ เมื่อไม่ตรงกับระดับปัจจุบัน
class _EsiGauge extends StatefulWidget {
  const _EsiGauge({
    super.key,
    required this.level,
    required this.center,
    this.mark,
    this.markColor = _inkTitle,
    this.width = 132.0,
  });

  final int level;
  final int? mark;
  final Color markColor;
  final Widget center;
  final double width;

  @override
  State<_EsiGauge> createState() => _EsiGaugeState();
}

class _EsiGaugeState extends State<_EsiGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  double _from = 0.0;

  double get _to => (6 - widget.level).toDouble();

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didUpdateWidget(_EsiGauge old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level) {
      _from = _value;
      _c.forward(from: 0.0);
    }
  }

  double get _value =>
      _from + (_to - _from) * Curves.easeOutCubic.transform(_c.value);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    return SizedBox(
      width: w,
      height: _EsiGaugePainter.heightFor(w),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => CustomPaint(
          painter: _EsiGaugePainter(_value, widget.mark, widget.markColor),
          child: child,
        ),
        child: Align(alignment: Alignment.bottomCenter, child: widget.center),
      ),
    );
  }
}

class _EsiGaugePainter extends CustomPainter {
  _EsiGaugePainter(this.value, this.mark, this.markColor);

  /// 0..5 จำนวนช่องที่เติม (ESI n = 6 - n ช่อง)
  final double value;
  final int? mark;
  final Color markColor;

  /// ระยะเผื่อรอบวงให้จุดปลายเข็ม
  static double _pad(double w) => w * 0.06;
  static double heightFor(double w) => w / 2 + 1.0;

  /// ช่องครึ่งวงมุมมนจริง (โค้งนอก → มุม → ขอบรัศมี → มุม → โค้งใน)
  static Path _sector(
      Offset c, double rIn, double rOut, double a0, double a1, double k) {
    Offset at(double r, double a) => c + Offset(math.cos(a), math.sin(a)) * r;
    final dO = k / rOut, dI = k / rIn;
    final corner = Radius.circular(k);
    return Path()
      ..moveTo(at(rOut, a0 + dO).dx, at(rOut, a0 + dO).dy)
      ..arcTo(Rect.fromCircle(center: c, radius: rOut), a0 + dO,
          a1 - a0 - dO * 2, false)
      ..arcToPoint(at(rOut - k, a1), radius: corner)
      ..lineTo(at(rIn + k, a1).dx, at(rIn + k, a1).dy)
      ..arcToPoint(at(rIn, a1 - dI), radius: corner)
      ..arcTo(Rect.fromCircle(center: c, radius: rIn), a1 - dI,
          -(a1 - a0 - dI * 2), false)
      ..arcToPoint(at(rIn + k, a0), radius: corner)
      ..lineTo(at(rOut - k, a0).dx, at(rOut - k, a0).dy)
      ..arcToPoint(at(rOut, a0 + dO), radius: corner)
      ..close();
  }

  /// เข็มจากขอบในทะลุขอบนอก ขอบขาวรอบ ปลายเป็นจุด
  static void _needle(Canvas canvas, Offset c, double a, double rIn,
      double rOut, double reach, double w, Color color) {
    final dir = Offset(math.cos(a), math.sin(a));
    final p1 = c + dir * (rIn - (rOut - rIn) * 0.12);
    final p2 = c + dir * (rOut + reach);
    final pen = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..strokeWidth = w * 2.0;
    canvas.drawLine(p1, p2, pen);
    canvas.drawCircle(p2, w * 1.7, pen..style = PaintingStyle.fill);
    pen
      ..color = color
      ..strokeWidth = w;
    canvas.drawLine(p1, p2, pen);
    canvas.drawCircle(p2, w * 1.15, pen);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pad = _pad(size.width);
    final rOut = size.width / 2 - pad;
    final th = rOut * 0.28;
    final rIn = rOut - th;
    final c = Offset(size.width / 2, pad + rOut);
    final k = math.max(1.5, th * 0.16);
    const seg = math.pi / 5;
    final gap = math.max(1.5, th * 0.14) / rOut;
    final level = (6 - value.round()).clamp(1, 5);
    final hue = _Esi.values[level - 1].color;
    final bounds = Rect.fromLTWH(0, pad, size.width, rOut);

    // แสงฟุ้งสีระดับกลางหน้าปัด (ครึ่งบน)
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, c.dy));
    final glow = Rect.fromCenter(
        center: c + Offset(0, -rOut * 0.1),
        width: rOut * 1.6,
        height: rOut * 1.3);
    canvas.drawOval(
        glow,
        Paint()
          ..shader = RadialGradient(colors: [
            hue.withValues(alpha: 0.18),
            hue.withValues(alpha: 0.0),
          ]).createShader(glow));
    canvas.restore();

    // เงามันด้านบนของทุกช่อง แบบ specular ของต้นฉบับ
    final gloss = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.6],
    ).createShader(bounds);

    const trackFill = Color(0xFFFBFAF7);
    const trackRim = Color(0xFFE8E4DA);
    for (var i = 0; i < 5; i++) {
      final t = (value - i).clamp(0.0, 1.0);
      // ช่องที่เติมไล่จากสีระดับแบบอ่อนไปเข้ม ตาม ramp ของต้นฉบับ
      final ramp = Color.lerp(Color.lerp(hue, Colors.white, 0.55)!,
          Color.lerp(hue, Colors.white, 0.05)!, i / 4)!;
      final fill = Color.lerp(trackFill, ramp, t)!;
      final rim = Color.lerp(trackRim, Color.lerp(ramp, hue, 0.6)!, t)!;
      final a0 = math.pi + i * seg + gap / 2;
      final path = _sector(c, rIn, rOut, a0, a0 + seg - gap, k);
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(path, Paint()..shader = gloss);
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(0.8, th * 0.07)
            ..color = rim);
    }

    final w = math.max(1.6, th * 0.2);
    // เข็มแดง = ระดับที่ควรเป็น เมื่อไม่ตรงกับระดับปัจจุบัน
    final m = mark;
    if (m != null && m != level) {
      _needle(canvas, c, math.pi + (5.5 - m) * seg, rIn, rOut, pad * 0.45, w,
          markColor);
    }
    // เส้นกำกับชี้กลางช่องระดับปัจจุบัน วิ่งตามสีที่เติม
    final at = (value - 0.5).clamp(0.5, 4.5);
    _needle(canvas, c, math.pi + at * seg, rIn, rOut, pad * 0.45, w,
        Color.lerp(hue, Colors.black, 0.1)!);
  }

  @override
  bool shouldRepaint(_EsiGaugePainter old) =>
      old.value != value || old.mark != mark || old.markColor != markColor;
}
