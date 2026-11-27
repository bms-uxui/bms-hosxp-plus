import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// หน้ากล้องถ่ายบัตรประชาชน (เต็มจอ): ภาพจากกล้องหลัง + กรอบบัตรให้เล็ง + ปุ่มชัตเตอร์ทางขวาแบบแอปกล้อง
/// คืนค่า path ไฟล์ภาพ · '' = เครื่องไม่มีกล้อง (เช่น iOS simulator) ใช้ภาพจำลองแทน · null = ปิดโดยไม่ถ่าย
/// [simCard] = บัตรจำลองที่เลื่อนเข้ากรอบเมื่อไม่มีกล้อง · [text] = ฟอนต์ของแอป (ข้อความบนจอกล้อง)
Future<String?> showIdCardCamera(BuildContext context,
        {required Widget simCard, required TextStyle text}) =>
    _pushScan(context, IdCardCameraScreen(simCard: simCard, text: text));

/// หน้ากล้องสแกนใบหน้า (เต็มจอ): กล้องหน้า + กรอบวงรีให้ใบหน้าอยู่ในกรอบ · คืนค่าแบบเดียวกับ [showIdCardCamera]
/// [simFace] = รูปใบหน้าจำลอง (asset) เมื่อเครื่องไม่มีกล้อง
Future<String?> showFaceCamera(BuildContext context,
        {required String simFace, required TextStyle text}) =>
    _pushScan(
        context,
        IdCardCameraScreen(
            simCard: const SizedBox(), simFace: simFace, text: text));

Future<String?> _pushScan(BuildContext context, Widget screen) =>
    Navigator.of(context).push<String>(PageRouteBuilder<String>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: ScaleTransition(
            scale: Tween(begin: 1.04, end: 1.0).animate(
                CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child),
      ),
    ));

/// สีเขียวยืนยัน (ชุดเดียวกับป้าย "เครื่องอ่านพร้อม")
const _ok = Color(0xFF1E8E3E);

class IdCardCameraScreen extends StatefulWidget {
  const IdCardCameraScreen(
      {super.key, required this.simCard, required this.text, this.simFace});
  final Widget simCard;
  final TextStyle text;

  /// โหมดสแกนใบหน้า (กล้องหน้า กรอบวงรี) · ค่า = รูปใบหน้าจำลองเมื่อไม่มีกล้อง
  final String? simFace;
  bool get face => simFace != null;

  @override
  State<IdCardCameraScreen> createState() => _IdCardCameraScreenState();
}

class _IdCardCameraScreenState extends State<IdCardCameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cam;

  /// ยังหากล้องอยู่ · ไม่มีกล้อง = ภาพจำลอง
  bool _looking = true, _sim = false, _busy = false, _torch = false;

  late final AnimationController _aim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 6000));
  late final AnimationController _flash = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final cams = await availableCameras();
      // บัตร = กล้องหลัง · ใบหน้า = กล้องหน้า (หันจอให้ผู้ป่วย)
      final want =
          widget.face ? CameraLensDirection.front : CameraLensDirection.back;
      final back = cams.where((c) => c.lensDirection == want);
      if (cams.isEmpty) throw StateError('no camera');
      final c = CameraController(
          back.isNotEmpty ? back.first : cams.first, ResolutionPreset.high,
          enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _cam = c;
        _looking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sim = true;
        _looking = false;
      });
      _aim.repeat();
    }
  }

  @override
  void dispose() {
    _cam?.dispose();
    _aim.dispose();
    _flash.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    if (_busy || _looking) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    _flash.forward(from: 0.0);
    String path = '';
    try {
      if (_cam != null) {
        if (_torch) await _cam!.setFlashMode(FlashMode.off);
        path = (await _cam!.takePicture()).path;
      } else {
        _aim.stop();
        await Future<void>.delayed(const Duration(milliseconds: 260));
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (mounted) Navigator.of(context).pop(path);
  }

  Future<void> _toggleTorch() async {
    final c = _cam;
    if (c == null) return;
    HapticFeedback.selectionClick();
    final on = !_torch;
    try {
      await c.setFlashMode(on ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torch = on);
    } catch (_) {}
  }

  Widget _preview(Size size) {
    final c = _cam;
    if (c != null && c.value.isInitialized) {
      final ps = c.value.previewSize ?? size;
      final land = size.width > size.height;
      final pw =
          land ? math.max(ps.width, ps.height) : math.min(ps.width, ps.height);
      final ph =
          land ? math.min(ps.width, ps.height) : math.max(ps.width, ps.height);
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: pw, height: ph, child: CameraPreview(c)),
        ),
      );
    }
    // ไม่มีกล้อง: พื้นโต๊ะจำลอง
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.1, -0.2),
          radius: 1.0,
          colors: [Color(0xFF5A6478), Color(0xFF1E232B)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap,
          {String? tip, bool on = false}) =>
      Semantics(
        button: true,
        label: tip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: on
                  ? const Color(0xFFFFD54F)
                  : Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, size: 24.0, color: on ? Colors.black : Colors.white),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.text;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        // แถบชัตเตอร์ทางขวา (แนวนอน) · กรอบบัตรอยู่กลางพื้นที่ที่เหลือ
        const bar = 132.0;
        final area = Rect.fromLTWH(0.0, 0.0, size.width - bar, size.height);
        final face = widget.face;
        final fw =
            math.min(area.width * 0.74, (area.height - 190.0) * 290.0 / 184.0);
        final oh = area.height - 240.0;
        final frame = face
            ? Rect.fromCenter(
                center: area.center.translate(0.0, 10.0),
                width: oh * 0.78,
                height: oh)
            : Rect.fromCenter(
                center: area.center.translate(0.0, 10.0),
                width: fw,
                height: fw * 184.0 / 290.0);
        return AnimatedBuilder(
          animation: Listenable.merge([_aim, _flash]),
          builder: (context, _) {
            final tt = _sim && !_busy ? _aim.value : 0.7;
            final p = IdCardPose.at(tt);
            final fp = FacePose.at(tt);
            final fit = _sim && ((face ? fp.fit : p.fit) || _busy);
            return Stack(children: [
              Positioned.fill(child: _preview(size)),
              if (_sim && face)
                Positioned.fill(child: FaceSim(pose: fp, frame: frame)),
              if (_sim && !face)
                Positioned.fromRect(
                  rect: frame,
                  child: Transform.translate(
                    offset: Offset(p.dx * size.width, p.dy * size.height),
                    child: IdCard3D(
                        pose: p, face: widget.simCard, perspective: 0.0008),
                  ),
                ),
              Positioned.fill(
                child: CustomPaint(
                    painter: IdCardFramePainter(
                        frame: frame,
                        fit: fit,
                        snap: face ? fp.snap : p.snap,
                        oval: face)),
              ),
              // คำแนะนำเหนือกรอบ
              Positioned(
                left: area.left,
                width: area.width,
                top: frame.top - 58.0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 9.0),
                    decoration: BoxDecoration(
                      color: fit ? _ok : Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text(
                        _looking
                            ? 'กำลังเปิดกล้อง'
                            : fit
                                ? 'พอดีกรอบแล้ว กดปุ่มถ่ายได้เลย'
                                : face
                                    ? 'ให้ใบหน้าอยู่ในกรอบ'
                                    : 'วางบัตรด้านหน้าให้พอดีกรอบ',
                        style: t.copyWith(fontSize: 15.0, color: Colors.white)),
                  ),
                ),
              ),
              Positioned(
                left: area.left,
                width: area.width,
                top: frame.bottom + 18.0,
                child: Center(
                  child: Text(
                      face
                          ? 'มองตรงที่กล้อง ถอดแมสก์และแว่นดำ'
                          : 'เห็นเลขบัตรและรูปชัด ไม่มีแสงสะท้อน',
                      style: t.copyWith(
                          fontSize: 13.0,
                          color: Colors.white.withValues(alpha: 0.75))),
                ),
              ),
              // ปิด (ซ้ายบน)
              Positioned(
                left: 20.0,
                top: MediaQuery.paddingOf(context).top + 12.0,
                child: _round(
                    Icons.close_rounded, () => Navigator.of(context).pop(),
                    tip: 'ปิดกล้อง'),
              ),
              // แถบขวา: ไฟฉาย · ชัตเตอร์
              Positioned(
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
                width: bar,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_cam != null)
                        _round(
                            _torch
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            _toggleTorch,
                            tip: 'ไฟฉาย',
                            on: _torch)
                      else
                        const SizedBox(height: 48.0),
                      const SizedBox(height: 36.0),
                      Semantics(
                        button: true,
                        label: 'ถ่ายภาพ',
                        child: GestureDetector(
                          onTap: _shoot,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 120),
                            scale: _busy ? 0.9 : 1.0,
                            child: Container(
                              width: 78.0,
                              height: 78.0,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4.0),
                              ),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 84.0),
                    ],
                  ),
                ),
              ),
              if (_looking)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 28.0,
                      height: 28.0,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    ),
                  ),
                ),
              // วาบขาวตอนกดถ่าย
              if (_flash.value > 0.0 && _flash.value < 1.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                        color: Colors.white
                            .withValues(alpha: 0.85 * (1.0 - _flash.value))),
                  ),
                ),
            ]);
          },
        );
      }),
    );
  }
}

/// มาสก์นอกกรอบบัตร (มืดลง) + มุมกรอบ 4 มุม (ขาว · เขียวเมื่อบัตรพอดีกรอบ) + เส้นบางรอบกรอบ
class IdCardFramePainter extends CustomPainter {
  const IdCardFramePainter(
      {required this.frame,
      required this.fit,
      this.snap = 0.0,
      this.oval = false});
  final Rect frame;
  final bool fit;

  /// กรอบวงรี (สแกนใบหน้า): ช่องมองเป็นวงรี มุมกรอบอยู่รอบวงรี
  final bool oval;

  /// 0–1 จังหวะล็อก: มุมกรอบหุบเข้าหาบัตร + เส้นหนาขึ้น + แสงเขียวรอบกรอบ
  final double snap;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(frame, const Radius.circular(14.0));
    Path hole(double grow) => oval
        ? (Path()..addOval(frame.inflate(grow)))
        : (Path()..addRRect(rr.inflate(grow)));
    canvas.drawPath(
        Path.combine(PathOperation.difference,
            Path()..addRect(Offset.zero & size), hole(0.0)),
        Paint()..color = Colors.black.withValues(alpha: 0.45));
    final c = fit ? _ok : Colors.white;
    if (snap > 0.0) {
      canvas.drawPath(
          hole(2.0),
          Paint()
            ..color = _ok.withValues(alpha: 0.55 * snap)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0));
    }
    final pen = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 + 1.5 * snap
      ..strokeCap = StrokeCap.round;
    const l = 34.0, r = 14.0;
    final f = frame.deflate(5.0 * snap);
    for (final (x, y, sx, sy) in [
      (f.left, f.top, 1.0, 1.0),
      (f.right, f.top, -1.0, 1.0),
      (f.left, f.bottom, 1.0, -1.0),
      (f.right, f.bottom, -1.0, -1.0),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(x, y + sy * l)
            ..lineTo(x, y + sy * r)
            ..arcToPoint(Offset(x + sx * r, y),
                radius: const Radius.circular(r), clockwise: sx * sy > 0)
            ..lineTo(x + sx * l, y),
          pen);
    }
    canvas.drawPath(
        hole(0.0),
        Paint()
          ..color = c.withValues(alpha: oval ? 0.8 : 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = oval ? 2.0 : 1.0);
  }

  @override
  bool shouldRepaint(IdCardFramePainter old) =>
      old.snap != snap ||
      old.frame != frame ||
      old.fit != fit ||
      old.oval != oval;
}

/// ท่าบัตรจำลองตามเวลา t (0–1 วน) เล่าเรื่อง "ถือบัตรเข้ามาเล็งให้พอดีกรอบ" ต่อเนื่องเรื่องเดียว:
/// 0–0.1 กรอบว่างรอ · 0.1–0.42 มือยื่นบัตรเข้ามาจากนอกจอมุมขวาล่าง (เอียง ใกล้กล้อง = ใหญ่กว่า)
/// · 0.42–0.54 ขยับปรับนิดเดียวจนตรงกรอบ · 0.54 ล็อก (มุมกรอบหุบเข้า เขียว แสงวาบ [snap])
/// · 0.54–0.84 ค้างพอดีกรอบ · 0.84–1 ดึงบัตรออกทางเดิม (ไม่จาง ไม่พลิกหาย)
/// [dx] [dy] = เลื่อน (สัดส่วนของช่องกล้อง) · มุมเป็นเรเดียน
class IdCardPose {
  const IdCardPose(this.dx, this.dy, this.rx, this.ry, this.rz, this.scale,
      this.fit, this.snap);
  final double dx, dy, rx, ry, rz, scale;
  final bool fit;

  /// 0–1 จังหวะล็อกกรอบ (ขึ้นแล้วลง) ใช้ทำมุมกรอบหุบ + แสงวาบ
  final double snap;
  double get opacity => 1.0;

  // ท่านอกจอ (มือถือบัตรอยู่ใกล้กล้อง เอียง) · ท่าเกือบตรง (ก่อนปรับ) · ท่าตรงกรอบ
  static const _out = [0.95, 0.8, 0.62, -0.5, 0.38, 1.16];
  static const _near = [0.035, 0.03, 0.10, -0.08, 0.035, 1.02];
  static const _fit = [0.0, 0.0, 0.0, 0.0, 0.0, 1.0];

  static IdCardPose _lerp(List<double> a, List<double> b, double k,
          {bool fit = false, double snap = 0.0}) =>
      IdCardPose(
          a[0] + (b[0] - a[0]) * k,
          a[1] + (b[1] - a[1]) * k,
          a[2] + (b[2] - a[2]) * k,
          a[3] + (b[3] - a[3]) * k,
          a[4] + (b[4] - a[4]) * k,
          a[5] + (b[5] - a[5]) * k,
          fit,
          snap);

  static IdCardPose at(double t) {
    if (t < 0.1) return _lerp(_out, _out, 0.0);
    if (t < 0.42) {
      return _lerp(
          _out, _near, Curves.easeOutCubic.transform((t - 0.1) / 0.32));
    }
    if (t < 0.54) {
      return _lerp(
          _near, _fit, Curves.easeInOutCubic.transform((t - 0.42) / 0.12));
    }
    if (t < 0.84) {
      final u = (t - 0.54) / 0.14;
      return _lerp(_fit, _fit, 0.0,
          fit: true, snap: u < 1.0 ? math.sin(math.pi * u) : 0.0);
    }
    return _lerp(_fit, _out, Curves.easeInCubic.transform((t - 0.84) / 0.16));
  }
}

/// บัตรประชาชน 3 มิติ: หน้าบัตร [face] (ผืน 290×184) + ความหนา (ซ้อนแผ่นขอบลึกตามแกน Z ไล่สี)
/// หมุนตาม [pose] มี perspective · หน้าบัตรมืดลงเมื่อเอียงหนีแสง + แสงวาวเลื่อนตามมุม · เงาใต้บัตร
class IdCard3D extends StatelessWidget {
  const IdCard3D(
      {super.key,
      required this.pose,
      required this.face,
      this.perspective = 0.0012,
      this.thickness = 5.5,
      this.layers = 12});
  final IdCardPose pose;
  final Widget face;
  final double perspective, thickness;
  final int layers;

  static const _edgeFront = Color(0xFFF4F7FC), _edgeBack = Color(0xFF8FA3C2);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final p = pose;
        final k = box.maxWidth / 290.0;
        final rad = BorderRadius.circular(12.0 * k);
        Matrix4 m(double dz) => Matrix4.identity()
          ..setEntry(3, 2, perspective)
          ..rotateX(p.rx)
          ..rotateY(p.ry)
          ..rotateZ(p.rz)
          ..scaleByDouble(p.scale, p.scale, 1.0, 1.0)
          ..translateByDouble(0.0, 0.0, dz, 1.0);
        final tilt = (p.ry.abs() + p.rx.abs()).clamp(0.0, 1.4);
        // แสงจากซ้ายบนด้านหน้า: หน้าบัตรสว่างสุดเมื่อหันตรง มืดลงตามมุมที่เอียงหนี
        final lit = math.cos(p.rx + 0.15) * math.cos(p.ry - 0.2);
        final shade = ((1.0 - lit) * 0.55).clamp(0.0, 0.45);
        final g = 0.5 - p.ry * 0.45 + p.rx * 0.2;
        final t = thickness * k;
        return Opacity(
          opacity: p.opacity,
          child: Stack(children: [
            // สันบัตร: แผ่นลึกสุดวาดก่อน (มีเงาใต้บัตร) แล้วไล่เข้าหาหน้าบัตร
            for (var i = layers; i >= 1; i--)
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.center,
                  transform: m(t * i / layers),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.lerp(_edgeFront, _edgeBack, i / layers),
                      borderRadius: rad,
                      boxShadow: i == layers
                          ? [
                              BoxShadow(
                                  color: const Color(0x66000000),
                                  blurRadius: (18.0 + 16.0 * tilt) * k,
                                  offset: Offset(0.0, (8.0 + 12.0 * tilt) * k)),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            // หน้าบัตร
            Positioned.fill(
              child: Transform(
                alignment: Alignment.center,
                transform: m(0.0),
                child: ClipRRect(
                  borderRadius: rad,
                  child: Stack(fit: StackFit.expand, children: [
                    FittedBox(child: face),
                    if (shade > 0.005)
                      ColoredBox(color: Colors.black.withValues(alpha: shade)),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.08 + 0.3 * tilt),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: [
                              (g - 0.22).clamp(0.0, 1.0),
                              g.clamp(0.0, 1.0),
                              (g + 0.22).clamp(0.0, 1.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        );
      });
}

/// ท่ากล้องจำลองตอนสแกนใบหน้า (เวลาเดียวกับ [IdCardPose]): เริ่มถือใกล้เกินและเยื้อง (หน้าใหญ่ ล้นกรอบ)
/// → ถอยและเลื่อนจนหน้าอยู่กลางวงรี → ล็อก (เขียว [snap]) → ค้าง → เยื้องออกอีกครั้ง
/// [dx] [dy] = เลื่อนรูป (สัดส่วนของช่อง) · [scale] = ขยายรูป (1 = หน้าพอดีวงรี)
class FacePose {
  const FacePose(this.dx, this.dy, this.scale, this.yaw, this.fit, this.snap);
  final double dx, dy, scale;

  /// หันศีรษะ 0 = มองตรงกล้อง · 1 = หันข้าง 30°
  final double yaw;
  final bool fit;
  final double snap;

  static const _out = [0.16, 0.1, 1.18, 1.0];
  static const _near = [0.02, 0.015, 1.03, 0.2];
  static const _fit = [0.0, 0.0, 1.0, 0.0];

  static FacePose _lerp(List<double> a, List<double> b, double k,
          {bool fit = false, double snap = 0.0}) =>
      FacePose(a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k,
          a[2] + (b[2] - a[2]) * k, a[3] + (b[3] - a[3]) * k, fit, snap);

  static FacePose at(double t) {
    if (t < 0.1) return _lerp(_out, _out, 0.0);
    if (t < 0.42) {
      return _lerp(
          _out, _near, Curves.easeOutCubic.transform((t - 0.1) / 0.32));
    }
    if (t < 0.54) {
      return _lerp(
          _near, _fit, Curves.easeInOutCubic.transform((t - 0.42) / 0.12));
    }
    if (t < 0.84) {
      final u = (t - 0.54) / 0.14;
      return _lerp(_fit, _fit, 0.0,
          fit: true, snap: u < 1.0 ? math.sin(math.pi * u) : 0.0);
    }
    return _lerp(
        _fit, _out, Curves.easeInOutCubic.transform((t - 0.84) / 0.16));
  }
}

/// ภาพจากกล้องจำลองตอนสแกนใบหน้า: หุ่น 3D ตัวเดียวกับหน้าผู้ป่วย (er_body_realistic เรนเดอร์ด้วย Blender
/// 7 มุม หันศีรษะ 0°–30° ทีละ 5° · er_face3d_0..6.png) วางให้ศีรษะพอดีวงรี [frame] เมื่อพอดีกรอบ
/// มุมระหว่างภาพ = จางสลับสองภาพที่ใกล้ที่สุด · ฉากหลัง = ผนังสีเทากลางไล่นุ่ม (ไม่อมฟ้า) · คอและไหล่จางหายแบบวงรีนุ่มรอบศีรษะ
class FaceSim extends StatelessWidget {
  const FaceSim({super.key, required this.pose, required this.frame});
  final FacePose pose;
  final Rect frame;

  static const frames = [
    'assets/images/er_face3d_0.png',
    'assets/images/er_face3d_1.png',
    'assets/images/er_face3d_2.png',
    'assets/images/er_face3d_3.png',
    'assets/images/er_face3d_4.png',
    'assets/images/er_face3d_5.png',
    'assets/images/er_face3d_6.png',
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, b) {
        final w = b.maxWidth, h = b.maxHeight;
        // ในภาพ: กลางศีรษะราว (50%, 40%) · ศีรษะกว้างราว 32% ของภาพ
        const fx = 0.5, fy = 0.40;
        final p = frame.width * 2.85 * pose.scale;
        final at = frame.center;
        final y = (pose.yaw.clamp(0.0, 1.0) * (frames.length - 1)).toDouble();
        final i0 = y.floor().clamp(0, frames.length - 1);
        final i1 = (i0 + 1).clamp(0, frames.length - 1);
        final k = y - i0;
        Widget img(int i) => Image.asset(frames[i],
            fit: BoxFit.contain,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium);
        return ClipRect(
          child: Stack(children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE9E9EB), Color(0xFFBDBEC2)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: at.dx - fx * p + pose.dx * w,
              top: at.dy - fy * p + pose.dy * h,
              width: p,
              height: p,
              child: Stack(fit: StackFit.expand, children: [
                img(i0),
                if (k > 0.01 && i1 != i0) Opacity(opacity: k, child: img(i1)),
              ]),
            ),
          ]),
        );
      });
}
