/// หน้า login จำลองของโมดูล ER: เลือกบทบาท (แพทย์ / พยาบาล) แล้วเลือกคน
///
/// ใช้เดโม workflow ตามบทบาทเท่านั้น ไม่ผูกกับ Provider ID / PIN ของระบบจริง
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../er_flow_home/er_flow_home_widget.dart';
import '../er_shared/er_session.dart';

const Color _panel = Color(0xFFFFFFFF);
const Color _ink = Color(0xFF202124);
const Color _ink3 = Color(0xFF6B7178);
const Color _blue = Color(0xFF001B7C);

TextStyle _t(double size,
        {Color color = _ink, FontWeight weight = FontWeight.w400}) =>
    TextStyle(
        fontFamily: 'GoogleSans',
        fontFamilyFallback: const ['NotoSansThai'],
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.3);

class ErLoginWidget extends StatefulWidget {
  const ErLoginWidget({super.key});

  static const String routeName = 'Er_Login';
  static const String routePath = 'erLogin';

  @override
  State<ErLoginWidget> createState() => _ErLoginWidgetState();
}

class _ErLoginWidgetState extends State<ErLoginWidget> {
  ErRole _role = ErRole.doctor;

  bool _entering = false;

  /// เข้าแอป: เปิดหน้าโหลดทับบนสุด (อยู่ต่อข้ามการเปลี่ยนหน้า) ดาว Star of Life ย้ายมากลางจอ
  /// พร้อมแถบโหลด asset หนักจริง แล้วเผยหน้าแอปผ่านรูปดาวที่ขยายออก
  void _enter(ErUser u) {
    if (_entering) return;
    _entering = true;
    final router = GoRouter.of(context);
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _EnterLoader(
        star: erLoginStarRect(MediaQuery.sizeOf(context)),
        enter: () async {
          await ErSession.instance.signIn(u);
          router.goNamed(ErFlowHomeWidget.routeName);
        },
        done: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// คำอธิบายสั้นของบทบาทที่เลือก (ใต้ปุ่มบทบาท)
  static const _roleDesc = {
    ErRole.doctor: 'ทบทวนเคส HPI ตรวจร่างกาย วินิจฉัย สั่งการรักษา และจำหน่าย',
    ErRole.nurse: 'สัญญาณชีพ AIS รับคำสั่งแพทย์ สังเกตอาการ และการพยาบาล',
    ErRole.triage: 'รับเข้า อาการสำคัญ สัญญาณชีพ GCS อุบัติเหตุ และระดับ ESI',
  };

  /// หน้าแรกของ ER (Figma 1248-663): พื้นขาว · Star of Life กรมท่าล้นมุมขวาล่าง + ภาพแพทย์ถือแท็บเล็ต
  /// ซ้าย = แบรนด์ · เลือกบทบาท · เลือกเจ้าหน้าที่ (เวรเช้า)
  @override
  Widget build(BuildContext context) {
    final people = erStaff.where((u) => u.role == _role).toList();
    return Scaffold(
      backgroundColor: _panel,
      body: Stack(children: [
        // ขวา: Star of Life + ภาพแพทย์ + widget จริงของแอป (ErLoginShowcase ใน urgent_strip.dart)
        const Positioned.fill(
            child: ErLoginShowcase(key: ValueKey('er-login-showcase'))),
        // โลโก้แอป HOSxP มุมขวาบน (ไอคอนเดียวกับแอป ไม่มีชื่อ)
        Positioned(
          right: 24.0,
          top: 0.0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _Rise(
                index: 0,
                child: Image.asset('assets/images/app_launcher_icon.png',
                    width: 52.0,
                    height: 52.0,
                    filterQuality: FilterQuality.medium),
              ),
            ),
          ),
        ),
        // ป้ายบอกทางแขวนจากขอบบนจอ (เพดาน) แบบป้ายใน รพ. · ชุดเดียวกับหน้าแนะนำ workflow
        const Positioned(
          left: 48.0,
          top: 0.0,
          child: ErLoginSign(
              key: ValueKey('er-login-sign'), cable: 60.0, rowH: 72.0),
        ),
        // เนื้อหาซ้าย: หัวข้อ · บทบาท · การ์ดรายชื่อเจ้าหน้าที่ · ท้ายหน้า = โลโก้ + หมายเหตุ
        Positioned(
          left: 0.0,
          top: 0.0,
          bottom: 0.0,
          width: 600.0,
          child: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(56.0, 176.0, 40.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // appear: ชิ้นในหน้าลอยขึ้น + จางเข้าไล่ทีละชิ้น (หลังป้ายหย่อนลง)
                      _Rise(
                          index: 0,
                          child: Text('เข้าสู่ระบบ',
                              style: _t(30.0, weight: FontWeight.w700))),
                      const SizedBox(height: 4.0),
                      _Rise(
                          index: 1,
                          child: Text(
                              'เลือกบทบาทและเจ้าหน้าที่เพื่อเริ่มงานในเวร',
                              style: _t(14.0,
                                  color: _ink3, weight: FontWeight.w500))),
                      const SizedBox(height: 22.0),
                      // บทบาท: pill เลือกได้ทีละอัน (เลือก = พื้นฟ้าอ่อน ตัวกรมท่าหนา)
                      _Rise(
                          index: 2,
                          child: Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                            _rolePill(ErRole.doctor,
                                Icons.medical_services_rounded, 'แพทย์ ER'),
                            _rolePill(ErRole.nurse,
                                Icons.health_and_safety_rounded, 'พยาบาล ER'),
                            _rolePill(ErRole.triage, Icons.how_to_reg_rounded,
                                'พยาบาลคัดกรอง'),
                          ])),
                      const SizedBox(height: 16.0),
                      // การ์ดเจ้าหน้าที่ของบทบาทที่เลือก: หัวการ์ด (ชื่อ + คำอธิบายบทบาท) · แถวละคน
                      _Rise(
                        index: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                                color: const Color(0xFFDADCE0), width: 0.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 14.0, 16.0, 6.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('เจ้าหน้าที่เวรเช้า',
                                            style: _t(16.0,
                                                weight: FontWeight.w700)),
                                        const SizedBox(height: 2.0),
                                        Text(_roleDesc[_role]!,
                                            style: _t(12.0,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      ]),
                                ),
                                // เปลี่ยนบทบาท = แถวรายชื่อเล่นเข้าใหม่ไล่ทีละแถว
                                for (final (i, u) in people.indexed) ...[
                                  if (i > 0)
                                    const Divider(
                                        height: 1.0,
                                        indent: 72.0,
                                        color: Color(0xFFEDEFF2)),
                                  _Rise(
                                    key: ValueKey('${_role.name}-${u.id}'),
                                    index: 4 + i,
                                    child: InkWell(
                                      onTap: () => _enter(u),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 12.0, 14.0, 12.0),
                                        child: Row(children: [
                                          CircleAvatar(
                                              radius: 22.0,
                                              backgroundImage:
                                                  AssetImage(u.face)),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(u.name,
                                                    style: _t(14.5,
                                                        weight:
                                                            FontWeight.w700)),
                                                Text(
                                                    '${u.position.replaceAll(' · ', ' ')}  ${u.shift} น.',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: _t(11.5,
                                                        color: _ink3,
                                                        weight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          SizedBox(
                                            width: 34.0,
                                            height: 34.0,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: _blue.withValues(
                                                    alpha: 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18.0,
                                                  color: _blue),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4.0),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ท้ายหน้า: หมายเหตุหน้าจำลอง
              _Rise(
                index: 7,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56.0, 0.0, 40.0, 20.0),
                  child: Row(children: [
                    Flexible(
                      child: Text(
                          'หน้าจำลองสำหรับออกแบบ ไม่ใช้ Provider ID หรือ PIN จริง',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(11.0, color: _ink3, weight: FontWeight.w500)),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _rolePill(ErRole r, IconData icon, String title) {
    final on = _role == r;
    return Material(
      color: on ? _blue.withValues(alpha: 0.08) : _panel,
      shape: StadiumBorder(
          side: BorderSide(
              color: on
                  ? _blue.withValues(alpha: 0.35)
                  : const Color(0xFFDADCE0))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _role = r),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14.0, 10.0, 18.0, 10.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18.0, color: on ? _blue : _ink3),
            const SizedBox(width: 8.0),
            Text(title,
                style: _t(14.0,
                    color: on ? _blue : _ink,
                    weight: on ? FontWeight.w700 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

/// appear ของชิ้นในหน้า login: ลอยขึ้น 16 + จางเข้า ไล่ทีละชิ้นตาม [index] (หลังป้ายหย่อนลง)
class _Rise extends StatefulWidget {
  const _Rise({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));
  late final Timer _go =
      Timer(Duration(milliseconds: 260 + 70 * widget.index), () {
    if (mounted) _c.forward();
  });

  @override
  void initState() {
    super.initState();
    _go;
  }

  @override
  void dispose() {
    _go.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
              offset: Offset(0.0, 16.0 * (1.0 - t)), child: child),
        );
      },
    );
  }
}

/// หน้าโหลดก่อนเข้าแอป (ทับบนสุด อยู่ต่อข้ามการเปลี่ยนหน้า)
/// 1. หน้าขาวจางเข้า ดาวกรมท่าจากหน้าแรก ([star]) ลอยมากลางจอ หมุน 60° (ดาว 6 แฉก ท่าจบเหมือนเดิม)
/// 2. แถบโหลด + ข้อความว่ากำลังเตรียมอะไร ตามไฟล์ที่โหลดจริง · ดาวเต้นเบา ๆ เป็นจังหวะชีพจร
/// 3. ครบ 100% แล้วเข้าแอปใต้หน้านี้ ([enter]) → รูปดาวกลางจอขยายเผยหน้าแอป → [done]
class _EnterLoader extends StatefulWidget {
  const _EnterLoader(
      {required this.star, required this.enter, required this.done});

  final Rect star;
  final Future<void> Function() enter;
  final VoidCallback done;

  @override
  State<_EnterLoader> createState() => _EnterLoaderState();
}

class _EnterLoaderState extends State<_EnterLoader>
    with SingleTickerProviderStateMixin {
  late final _tick = createTicker(_frame);
  int _ms = 0;

  /// ไฟล์ที่โหลดเสร็จ / ทั้งหมด · ข้อความของกลุ่มไฟล์ที่กำลังโหลด
  double _real = 0.0;
  String _label = 'เตรียมภาพประกอบ';
  bool _loaded = false, _entered = false;
  int? _navAt, _doneAt;

  /// asset หนักของหน้าแอป เรียงจากสำคัญน้อยไปมาก: image cache ทิ้งไฟล์ที่ใช้นานสุดก่อน
  /// ฉากภาพรวม (หน้าแรกหลังเข้า) โหลดท้ายสุดจึงยังอยู่ใน cache
  static const _heavy = [
    ('assets/images/ChatGPT_Image_', 'เตรียมภาพประกอบ'),
    ('assets/images/er_hero_', 'เตรียมภาพประกอบ'),
    ('assets/images/flow/', 'เตรียมฉากขั้นตอนงาน'),
    ('assets/images/er_dx_', 'เตรียมหน้าวินิจฉัย'),
    ('assets/images/er_os_', 'เตรียมคำสั่งการรักษา'),
    ('assets/images/er_vs_', 'เตรียมภาพสัญญาณชีพ'),
    ('assets/images/alert_bed', 'เตรียมฉากห้องฉุกเฉิน'),
    ('assets/images/er_ov_', 'เตรียมฉากห้องฉุกเฉิน'),
  ];

  @override
  void initState() {
    super.initState();
    _tick.start();
    _preload();
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  /// โหลดภาพจริงเข้า image cache (ทีละ 6 ไฟล์พร้อมกัน) · ไฟล์ไหนโหลดไม่ได้ = ข้ามไป ไม่ค้าง
  Future<void> _preload() async {
    // cache ขนาดเดียวกับหน้าแอป (ErFlowHome) ไม่ให้ภาพที่โหลดไว้ถูกทิ้งก่อนเข้า
    PaintingBinding.instance.imageCache
      ..maximumSizeBytes = 400 << 20
      ..maximumSize = 3000;
    try {
      await _load();
    } finally {
      _real = 1.0;
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final all = manifest.listAssets();
    final files = [
      for (final (pre, label) in _heavy)
        for (final a in all)
          if (a.startsWith(pre) &&
              (a.endsWith('.png') || a.endsWith('.jpg') || a.endsWith('.webp')))
            (a, label)
    ];
    var done = 0, next = 0;
    Future<void> worker() async {
      while (next < files.length && mounted) {
        final (a, label) = files[next++];
        _label = label;
        try {
          await precacheImage(AssetImage(a), context);
        } catch (_) {}
        _real = ++done / files.length;
      }
    }

    await Future.wait([for (var i = 0; i < 6; i++) worker()]);
  }

  /// หน้าแอปพร้อม (0–1): เข้าแอปใต้หน้านี้ทันทีที่โหลดภาพครบ แล้วรอหน้าแรกจำลองโหลด 900ms จบ
  /// เผยหน้าแอปตอนเนื้อหาจริงขึ้นแล้ว (ไม่เห็น skeleton)
  double get _home =>
      _navAt == null ? 0.0 : ((_ms - _navAt!) / 950.0).clamp(0.0, 1.0);

  /// แถบที่แสดง: ภาพ 90% + หน้าแรก 10% ไม่เกินของจริง และวิ่งไม่เร็วกว่า 1.5 วิ นับจากแถบโผล่
  double get _shown => math.min(
      0.9 * _real + 0.1 * _home, ((_ms - 800) / 1500.0).clamp(0.0, 1.0));

  /// เผยหน้าแอป: หลังครบ 100% ค้างแป๊บ ข้อความจางออก (450ms)
  int? get _revealAt => _doneAt == null ? null : _doneAt! + 450;

  void _frame(Duration now) {
    final ms = now.inMilliseconds;
    setState(() => _ms = ms);
    if (_loaded && !_entered) {
      _entered = true;
      widget.enter().whenComplete(() => _navAt = _ms);
    }
    if (_doneAt == null && _shown >= 1.0) _doneAt = ms;
    if (_revealAt case final r? when ms >= r + 950) {
      _tick.stop();
      widget.done();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final still = MediaQuery.of(context).disableAnimations;
    final ms = _ms;
    double seg(num a, num b, [Curve c = Curves.easeOutCubic]) =>
        c.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));

    // ดาวกลางจอ (ขยับขึ้นเหนือกลางเล็กน้อย เว้นที่ให้แถบโหลดข้างล่าง)
    const s = 168.0;
    final c = Offset(size.width / 2, size.height / 2 - 56.0);
    final to = Rect.fromCenter(center: c, width: s, height: s);
    final fade = still ? 1.0 : seg(0, 350);
    final fly = still ? 1.0 : seg(300, 1050, Curves.easeInOutCubic);
    final d = _doneAt;
    final out = d == null ? 0.0 : seg(d + 200, d + 450);
    final textA = seg(800, 1100) * (1.0 - out);

    // ชีพจร: ทุก 1.4 วิ เต้น 2 จังหวะ (ตุบ-ตุบ) + เส้นขอบดาวกระจายออกจางหาย · หยุดนุ่ม ๆ ตอนครบ
    final x = ms < 1050 ? 0.0 : ((ms - 1050) % 1400) / 1400.0;
    double bump(double at) => math.exp(-math.pow((x - at) / 0.05, 2));
    final live = ms < 1050 || still ? 0.0 : 1.0 - out;
    final beat = (bump(0.08) + 0.6 * bump(0.26)) * live;

    // เผยหน้าแอป: รูปดาวขยายเร่งแบบ iris จนส่วนกลางดาวคลุมมุมจอไกลสุด
    final rv = _revealAt;
    final tr = rv == null ? 0.0 : ((ms - rv) / 950.0).clamp(0.0, 1.0);
    final e = Curves.easeInOutCubic.transform(tr);
    final far = [
      Offset.zero,
      Offset(size.width, 0.0),
      Offset(0.0, size.height),
      Offset(size.width, size.height),
    ].map((p) => (p - c).distance).reduce(math.max);
    final sc = 1.0 + (far / (s * 0.13) - 1.0) * math.pow(e, 2.2);
    final rot = -math.pi / 3 * fly - 0.3 * e;
    final k = sc * (1.0 + 0.045 * beat);
    final hole = rv == null
        ? null
        : erStarPath(to).transform((Matrix4.identity()
              ..translateByDouble(c.dx, c.dy, 0.0, 1.0)
              ..rotateZ(rot)
              ..scaleByDouble(sc, sc, 1.0, 1.0)
              ..translateByDouble(-c.dx, -c.dy, 0.0, 1.0))
            .storage);

    final page = Stack(children: [
      Positioned.fill(
          child: CustomPaint(painter: _StarHole(hole, still ? 0.0 : 1.0 - e))),
      if (x > 0.0 && live > 0.0)
        Positioned.fill(child: CustomPaint(painter: _StarEcho(to, x, live))),
      Positioned.fromRect(
        rect: Rect.lerp(widget.star, to, fly)!,
        child: Opacity(
          opacity: (1.0 - tr / 0.35).clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(rot)..scaleByDouble(k, k, 1.0, 1.0),
            child: Image.asset('assets/images/er_login_star.png',
                fit: BoxFit.fill, filterQuality: FilterQuality.medium),
          ),
        ),
      ),
      // ข้อความ + แถบโหลด ใต้ดาว
      Positioned(
        left: 0.0,
        right: 0.0,
        top: to.bottom + 40.0,
        child: Opacity(
          opacity: textA,
          child: Transform.translate(
            offset: Offset(0.0, 12.0 * (1.0 - seg(800, 1100))),
            child: Column(children: [
              Text('กำลังเข้าสู่ห้องฉุกเฉิน',
                  style: _t(20.0, weight: FontWeight.w700)),
              const SizedBox(height: 18.0),
              SizedBox(
                width: 300.0,
                child: Column(children: [
                  LinearProgressIndicator(
                      value: _shown,
                      minHeight: 6.0,
                      borderRadius: BorderRadius.circular(3.0),
                      color: _blue,
                      backgroundColor: _blue.withValues(alpha: 0.1)),
                  const SizedBox(height: 10.0),
                  Row(children: [
                    Expanded(
                      child: Text(
                          _shown >= 1.0
                              ? 'พร้อมแล้ว'
                              : _loaded
                                  ? 'เตรียมหน้าแรก'
                                  : _label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(13.0, color: _ink3, weight: FontWeight.w500)),
                    ),
                    Text('${(_shown * 100).round()}%',
                        style: _t(13.0, color: _blue, weight: FontWeight.w700)
                            .copyWith(fontFeatures: const [
                          FontFeature.tabularFigures()
                        ])),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    ]);

    return AbsorbPointer(
      child: Material(
        type: MaterialType.transparency,
        child: fade >= 1.0 ? page : Opacity(opacity: fade, child: page),
      ),
    );
  }
}

/// พื้นขาวของหน้าโหลด เว้น [hole] รูปดาว (ตอนเผยหน้าแอป) · ขอบรูมีเส้นกรมท่าบาง จางตาม [rim]
class _StarHole extends CustomPainter {
  _StarHole(this.hole, this.rim);
  final Path? hole;
  final double rim;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    if (hole case final h?) bg.addPath(h, Offset.zero);
    canvas.drawPath(bg, Paint()..color = _panel);
    if (hole case final h? when rim > 0.0) {
      canvas.drawPath(
          h,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 2.0
            ..color = _blue.withValues(alpha: 0.9 * rim));
    }
  }

  @override
  bool shouldRepaint(_StarHole old) => true;
}

/// เส้นขอบดาวกระจายออกจากดาวกลางจอ 1 วงต่อจังหวะชีพจร ([x] = ช่วงในรอบ 0–1)
class _StarEcho extends CustomPainter {
  _StarEcho(this.star, this.x, this.a);
  final Rect star;
  final double x, a;

  @override
  void paint(Canvas canvas, Size size) {
    final k = 1.0 + 0.9 * Curves.easeOutCubic.transform(x);
    canvas.drawPath(
        erStarPath(Rect.fromCenter(
            center: star.center,
            width: star.width * k,
            height: star.height * k)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 1.5
          ..color = _blue.withValues(alpha: 0.28 * a * math.pow(1.0 - x, 2)));
  }

  @override
  bool shouldRepaint(_StarEcho old) => old.x != x || old.a != a;
}
