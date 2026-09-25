part of '../er_flow_home_widget.dart';

/// กราฟผู้ป่วยเข้าออกรายชั่วโมง — แตะหรือลากนิ้วเพื่อดูค่ารายชั่วโมง
///
/// อ่านง่ายขึ้นด้วยเส้นกริด ป้ายชั่วโมงใต้แกน และคำอธิบายสีด้านบน
/// ค่าที่เลือกขึ้นเป็นตัวเลขจริงตรงหัวกราฟ ไม่ต้องเดาความสูงของแท่ง
class _HourChart extends StatefulWidget {
  const _HourChart({required this.t, required this.num});

  final TextStyle Function(double,
      {Color color, FontWeight weight, double? height}) t;
  final TextStyle Function(double, {Color color, FontWeight weight}) num;

  @override
  State<_HourChart> createState() => _HourChartState();
}

class _HourChartState extends State<_HourChart> {
  /// ชั่วโมงที่เลือกอยู่ null = ยังไม่ได้เลือก แสดงยอดรวมทั้งวันแทน
  int? _sel;

  void _pick(Offset local, double width) {
    final i = (local.dx / (width / _HourBars.hours)).floor();
    final c = i.clamp(0, _HourBars.hours - 1);
    if (c != _sel) setState(() => _sel = c);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final n = widget.num;
    final i = _sel;
    final totalIn = _HourBars.inflow.reduce((a, b) => a + b).round();
    final totalOut = _HourBars.outflow.reduce((a, b) => a + b).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ผู้ป่วยเข้าออกรายชั่วโมง',
                style: t(11.0, color: _lpInk2, weight: FontWeight.w600)),
            const Spacer(),
            if (i == null)
              Text('24 ชม.', style: t(10.0, color: _lpInk3))
            else
              Material(
                color: _lpSoft,
                borderRadius: BorderRadius.circular(100.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _sel = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${i.toString().padLeft(2, '0')}:00–'
                            '${i.toString().padLeft(2, '0')}:59 น.',
                            style: n(10.0,
                                color: _lpInk2, weight: FontWeight.w600)),
                        const SizedBox(width: 4.0),
                        const Icon(Icons.close_rounded,
                            size: 11.0, color: _lpInk3),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            _key(Colors.white, 'เข้า',
                i == null ? totalIn : _HourBars.inflow[i].round(), t, n),
            const SizedBox(width: 12.0),
            _key(_lpInk3, 'ออก',
                i == null ? totalOut : _HourBars.outflow[i].round(), t, n),
            const Spacer(),
            Text(i == null ? 'รวมทั้งวัน' : 'ชั่วโมงที่เลือก',
                style: t(9.5, color: _lpInk3)),
          ],
        ),
        const SizedBox(height: 6.0),
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _pick(d.localPosition, c.maxWidth),
            onHorizontalDragUpdate: (d) => _pick(d.localPosition, c.maxWidth),
            child: SizedBox(
              height: 86.0,
              child: CustomPaint(
                painter: _HourBars(selected: _sel),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _key(
          Color color,
          String label,
          int value,
          TextStyle Function(double,
                  {Color color, FontWeight weight, double? height})
              t,
          TextStyle Function(double, {Color color, FontWeight weight}) n) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2.0)),
          ),
          const SizedBox(width: 5.0),
          Text(label, style: t(10.0, color: _lpInk2)),
          const SizedBox(width: 4.0),
          Text('$value',
              style: n(12.0, color: _lpInk, weight: FontWeight.w700)),
        ],
      );
}

/// ตัวกราฟ — ยังเป็นข้อมูลจำลอง
class _HourBars extends CustomPainter {
  const _HourBars({this.selected});

  /// ชั่วโมงที่เลือก ใช้เน้นแท่งและลากเส้นนำสายตา
  final int? selected;

  static const int hours = 24;

  static const List<double> inflow = [
    2, 1, 1, 2, 3, 5, 6, 8, 9, 7, 6, 5, //
    4, 6, 7, 9, 11, 10, 8, 6, 5, 4, 3, 2,
  ];
  static const List<double> outflow = [
    1, 1, 2, 1, 2, 3, 4, 5, 7, 8, 7, 6, //
    5, 4, 5, 6, 7, 9, 9, 7, 6, 5, 4, 3,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 14.0;
    final plot = size.height - labelH;
    final hi = inflow.reduce((a, b) => a > b ? a : b);

    // เส้นกริดแนวนอนสามเส้น พร้อมตัวเลขกำกับ อ่านความสูงได้โดยไม่ต้องเดา
    final grid = Paint()..color = _lpLine;
    for (var g = 1; g <= 3; g++) {
      final v = hi * g / 3;
      final y = plot - (v / hi) * plot * 0.88;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 0.6), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: v.round().toString(),
          style: const TextStyle(
              fontFamily: 'IBMPlexSansThaiLooped',
              fontSize: 8.0,
              color: _lpInk3,
              fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width, y - tp.height - 1.0));
    }

    final slot = size.width / hours;
    final w = slot * 0.32;

    // แถบไฮไลต์ของชั่วโมงที่เลือก วาดก่อนแท่งเพื่อให้อยู่ด้านหลัง
    if (selected != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slot * selected!, 0, slot, plot),
          const Radius.circular(4.0),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.10),
      );
    }

    for (var i = 0; i < hours; i++) {
      final x = slot * i + slot / 2;
      final dim = selected != null && selected != i;
      final hIn = (inflow[i] / hi) * plot * 0.88;
      final hOut = (outflow[i] / hi) * plot * 0.88;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - w - 0.8, plot - hIn, w, hIn),
          const Radius.circular(2.0),
        ),
        Paint()..color = Colors.white.withValues(alpha: dim ? 0.30 : 0.95),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 0.8, plot - hOut, w, hOut),
          const Radius.circular(2.0),
        ),
        Paint()..color = _lpInk3.withValues(alpha: dim ? 0.18 : 0.5),
      );
    }

    // เส้นฐานเข้มกว่ากริด ให้เห็นขอบล่างของกราฟชัด
    canvas.drawRect(Rect.fromLTWH(0, plot - 0.9, size.width, 0.9),
        Paint()..color = _lpInk3);

    // ป้ายชั่วโมงทุกหกชั่วโมง พอให้จับเวลาได้โดยไม่รก
    for (var i = 0; i < hours; i += 6) {
      final on = selected == i;
      final tp = TextPainter(
        text: TextSpan(
          text: '${i.toString().padLeft(2, '0')} น.',
          style: TextStyle(
              fontFamily: 'IBMPlexSansThaiLooped',
              fontSize: 8.5,
              color: on ? Colors.white : _lpInk3,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(slot * i, plot + 3.0));
    }

    // ป้ายชั่วโมงที่เลือก ถ้าไม่ตรงกับป้ายประจำหกชั่วโมง
    if (selected != null && selected! % 6 != 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${selected!.toString().padLeft(2, '0')} น.',
          style: const TextStyle(
              fontFamily: 'IBMPlexSansThaiLooped',
              fontSize: 8.5,
              color: Colors.white,
              fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (slot * selected! + slot / 2 - tp.width / 2)
          .clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, plot + 3.0));
    }
  }

  @override
  bool shouldRepaint(covariant _HourBars old) => old.selected != selected;
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-2.6 + 4.0 * t, -0.3),
            end: Alignment(-0.6 + 4.0 * t, 0.3),
            colors: const [
              Color(0xFFE4E7EB),
              Color(0xFFF7F8FA),
              Color(0xFFE4E7EB),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// วงกลมเพ่งบริเวณอาการ ตามแบบในผัง — วงนอกบาง วงในไล่สี และเส้นรัศมี
class _FocusRing extends CustomPainter {
  const _FocusRing({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // ไล่สีจางจากกลางออกขอบ บอกความรุนแรงโดยไม่บังตัวหุ่น
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.34),
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = color.withValues(alpha: 0.75);
    canvas.drawCircle(c, r, line);
    canvas.drawCircle(
        c,
        r * 0.66,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.55));
    canvas.drawCircle(
        c,
        r * 0.34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.45));

    // เส้นรัศมีสี่ทิศ ช่วยให้อ่านออกว่าเป็นวงเพ่ง ไม่ใช่รอยเปื้อน
    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r * 0.34),
        c + Offset(math.cos(a), math.sin(a)) * r,
        Paint()
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusRing old) => old.color != color;
}

/// เส้นแนวโน้มเล็ก ๆ ในช่องค่าสัญญาณชีพของ Generative UI
class _Spark extends CustomPainter {
  _Spark(this.series, this.color);
  final List<double> series;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2 || size.height <= 0) return;
    final lo = series.reduce(math.min), hi = series.reduce(math.max);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = i / (series.length - 1) * size.width;
      final y = size.height - (series[i] - lo) / span * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_Spark old) => old.series != series || old.color != color;
}

/// คลื่นเสียงรอบปุ่มไมค์: แท่งรัศมีรอบวง ยาวตามความดังจริงช่วงล่าสุด
class _MicWave extends CustomPainter {
  _MicWave({required this.levels, required this.inner, required this.color});

  final List<double> levels;
  final double inner;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;
    final c = size.center(Offset.zero);
    const n = 40;
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (var i = 0; i < n; i++) {
      // วนค่าความดังรอบวงแบบสมมาตร ค่าล่าสุดอยู่ด้านบน
      final k = (i < n / 2 ? i : n - i) * (levels.length - 1) ~/ (n / 2);
      final v = levels[levels.length - 1 - k.clamp(0, levels.length - 1)];
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      final d = Offset(math.cos(a), math.sin(a));
      final len = 2.0 + v * 22.0;
      p.color = color.withValues(alpha: 0.25 + v * 0.6);
      canvas.drawLine(c + d * inner, c + d * (inner + len), p);
    }
  }

  @override
  bool shouldRepaint(_MicWave old) => true;
}

/// micro-interaction ของทุกปุ่ม/การ์ดที่กดได้: ยุบลงเล็กน้อยตอนนิ้วแตะ เด้งกลับตอนปล่อย
/// และสั่นเบา ๆ เมื่อเป็นการแตะจริง (ไม่ใช่การลากเลื่อนรายการ)
/// ใช้ Listener จึงไม่แย่งท่าทางของ InkWell/GestureDetector ข้างใน
class _Press extends StatefulWidget {
  const _Press({required this.child, this.scale = 0.96});
  final Widget child;
  final double scale;

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _down = false;
  Offset _at = Offset.zero;
  DateTime _t = DateTime.now();

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (e) {
          _at = e.position;
          _t = DateTime.now();
          _set(true);
        },
        onPointerMove: (e) {
          if ((e.position - _at).distance > 12.0) _set(false);
        },
        onPointerUp: (e) {
          if (_down && DateTime.now().difference(_t).inMilliseconds < 450) {
            HapticFeedback.selectionClick();
          }
          _set(false);
        },
        onPointerCancel: (_) => _set(false),
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          duration: Duration(milliseconds: _down ? 90 : 160),
          curve: _down ? Curves.easeOut : Curves.easeOutBack,
          child: widget.child,
        ),
      );
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

/// วัดขนาดลูกหลังจัดวาง แจ้งเมื่อเปลี่ยน (ใช้หาความสูงรางขั้นตอน)
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required Widget child})
      : super(child: child);

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
      BuildContext context, _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _old;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _old) return;
    _old = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(size));
  }
}

/// แสดงการเปลี่ยนข้อความที่ผู้ช่วยทำ (ใช้กับ HPI และช่องข้อความยาว)
/// เพิ่ม = พื้นเขียว พิมพ์ทีละตัว · แก้ = ขีดฆ่าของเดิม ตามด้วยของใหม่สีเขียว
/// ลบ = พื้นแดง ขีดฆ่า · พิมพ์ครบแล้วค้างให้อ่าน 2.5 วิ แล้วกลับเป็นข้อความปกติ
class _TextDiff extends StatefulWidget {
  const _TextDiff({
    super.key,
    required this.before,
    required this.after,
    required this.style,
    this.onDone,
  });

  final String before;
  final String after;
  final TextStyle style;
  final VoidCallback? onDone;

  @override
  State<_TextDiff> createState() => _TextDiffState();
}

/// ชนิดของช่วงข้อความ: 0 = เหมือนเดิม · 1 = เพิ่ม · -1 = ลบ
typedef _DiffOp = (int, String);

class _TextDiffState extends State<_TextDiff>
    with SingleTickerProviderStateMixin {
  late final List<_DiffOp> _ops = _diff(widget.before, widget.after);
  late final int _insLen = _ops
      .where((o) => o.$1 == 1)
      .fold(0, (a, o) => a + o.$2.characters.length);
  late final AnimationController _type = AnimationController(
    vsync: this,
    // พิมพ์ ~28 ms ต่อตัว ไม่เกิน 2.4 วิ
    duration: Duration(milliseconds: (_insLen * 28).clamp(300, 2400)),
  )..forward();
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    _type.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _hold = Timer(const Duration(milliseconds: 2500), () {
          widget.onDone?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    _type.dispose();
    super.dispose();
  }

  /// diff ระดับตัวอักษร (LCS) แล้วรวมช่วงเหมือนสั้น ๆ ที่คั่นการแก้ไว้ด้วยกัน
  /// แยกเป็นหน่วย: ช่องว่างของ template "[...]" ทั้งก้อนเป็นหน่วยเดียว นอกนั้นทีละตัวอักษร
  /// เติม "[เพศ/อายุ]" → "หญิง 54 ปี" จึงเห็นเป็นลบทั้งก้อน + เพิ่มทั้งก้อน ไม่แตกเป็นเศษ
  static List<String> _tokens(String t) {
    final out = <String>[];
    final ch = t.characters.toList();
    for (var i = 0; i < ch.length; i++) {
      if (ch[i] == '[') {
        final end = ch.indexOf(']', i);
        if (end > i) {
          out.add(ch.sublist(i, end + 1).join());
          i = end;
          continue;
        }
      }
      out.add(ch[i]);
    }
    return out;
  }

  static List<_DiffOp> _diff(String a, String b) {
    final x = _tokens(a);
    final y = _tokens(b);
    final n = x.length, m = y.length;
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = n - 1; i >= 0; i--) {
      for (var j = m - 1; j >= 0; j--) {
        dp[i][j] = x[i] == y[j]
            ? dp[i + 1][j + 1] + 1
            : math.max(dp[i + 1][j], dp[i][j + 1]);
      }
    }
    final raw = <_DiffOp>[];
    void add(int k, String c) {
      if (raw.isNotEmpty && raw.last.$1 == k) {
        raw[raw.length - 1] = (k, raw.last.$2 + c);
      } else {
        raw.add((k, c));
      }
    }

    var i = 0, j = 0;
    while (i < n && j < m) {
      if (x[i] == y[j]) {
        add(0, x[i]);
        i++;
        j++;
      } else if (dp[i + 1][j] >= dp[i][j + 1]) {
        add(-1, x[i++]);
      } else {
        add(1, y[j++]);
      }
    }
    while (i < n) {
      add(-1, x[i++]);
    }
    while (j < m) {
      add(1, y[j++]);
    }
    // ช่วงเหมือนสั้น (≤2 ตัว) ที่อยู่ระหว่างการแก้: ยุบเป็นลบ+เพิ่ม อ่านง่ายกว่าแตกเป็นเศษ
    final out = <_DiffOp>[];
    var del = '', ins = '';
    void flush() {
      if (del.isNotEmpty) out.add((-1, del));
      if (ins.isNotEmpty) out.add((1, ins));
      del = '';
      ins = '';
    }

    for (var k = 0; k < raw.length; k++) {
      final (t, s) = raw[k];
      final between = k > 0 &&
          k < raw.length - 1 &&
          raw[k - 1].$1 != 0 &&
          raw[k + 1].$1 != 0;
      if (t == 0 && !(between && s.characters.length <= 2)) {
        flush();
        out.add((0, s));
      } else if (t == 0) {
        del += s;
        ins += s;
      } else if (t == -1) {
        del += s;
      } else {
        ins += s;
      }
    }
    flush();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _type,
      builder: (context, _) {
        var left = (_insLen * _type.value).round();
        final spans = <InlineSpan>[];
        for (var k = 0; k < _ops.length; k++) {
          final (t, s) = _ops[k];
          if (t == 0) {
            spans.add(TextSpan(text: s));
          } else if (t == -1) {
            // ตามด้วยการเพิ่ม = แก้ (ขีดฆ่าเฉย ๆ) · ไม่มี = ลบ (พื้นแดง)
            final replaced = k + 1 < _ops.length && _ops[k + 1].$1 == 1;
            spans.add(TextSpan(
              text: s,
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                decorationColor: replaced ? _ink3 : _red,
                color: replaced ? _ink3 : _red,
                backgroundColor: replaced ? null : _red.withValues(alpha: 0.14),
              ),
            ));
          } else {
            final ch = s.characters;
            final shown = math.min(left, ch.length);
            left -= shown;
            if (shown > 0) {
              spans.add(TextSpan(
                text: ch.take(shown).toString(),
                style: TextStyle(
                  color: const Color(0xFF12713F),
                  backgroundColor: _green.withValues(alpha: 0.16),
                ),
              ));
            }
            // เคอร์เซอร์ตรงจุดที่กำลังพิมพ์
            if (shown < ch.length && _type.isAnimating) {
              spans.add(
                  const TextSpan(text: '▍', style: TextStyle(color: _green)));
              left = 0;
            }
          }
        }
        return Text.rich(TextSpan(style: widget.style, children: spans));
      },
    );
  }
}
