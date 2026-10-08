// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

// ---------------------------------------------------------------- ชุดสี
// ชุดเดียวกับ er-registry design language ที่ใช้ทั้งโมดูล
/// Material 3 (Google): surface โทนฟ้าเทาอ่อน การ์ดขาวลอยบนพื้น
const Color _bg = Color(0xFFF0F4F9);

// โทนของหน้าสรุปเคส AI (โทนสว่างเดียวกับทั้งแอป)
const Color _dPanel = Color(0xF2FFFFFF);
const Color _dLine = Color(0xFFE3E6EA);
const Color _dInk = Color(0xFF202124);
const Color _dInk2 = Color(0xFF6B7178);
const Color _dRed = Color(0xFFD93025);
const Color _dAccent = Color(0xFF001B7C);
const Color _panel = Color(0xFFFFFFFF);

/// M3 surface container: พื้นของการ์ดย่อย ชิป ช่องกรอก
const Color _panelSoft = Color(0xFFF0F4F9);
const Color _line = Color(0xFFE3E6EA);
const Color _ink = Color(0xFF202124);

/// สีหัวข้อ = primaryText ของธีมแอป เข้มกว่าตัวอักษรทั่วไปหนึ่งขั้น
const Color _inkTitle = Color(0xFF14181B);

/// โทนสีภายในแผงซ้าย พื้นเป็นสีหลัก ตัวอักษรกลับเป็นขาว
/// แยกชุดจากโทนบนพื้นขาวของทั้งหน้า เพื่อไม่ให้สับสนว่าตัวไหนใช้ที่ไหน
const Color _pBg = _blue;
const Color _pInk = Color(0xFFFFFFFF);
const Color _pInk2 = Color(0xE6FFFFFF);
const Color _pInk3 = Color(0xBDFFFFFF);
const Color _pLine = Color(0x2EFFFFFF);
const Color _pSoft = Color(0x1FFFFFFF);

/// โทนแผงซ้าย (ภาพรวม / ช่วงงาน) แบบ Google (2026-10-08): พื้นขาว ตัวอักษรเข้ม
/// การ์ดขาวขอบเทา #DADCE0 มุม 12 ไม่มีเงา (เดิมพื้นกรมท่า + การ์ดกระจก)
const Color _lpBg = _panel;
const Color _lpInk = _inkTitle;
const Color _lpInk2 = _ink2;
const Color _lpInk3 = _ink3;
const Color _lpLine = _line;
const Color _lpSoft = _panelSoft;

/// สีเน้นบนพื้นแผงซ้าย: พื้นขาวแล้ว ใช้สีเดิม (ไม่ต้องดันให้สว่าง)
Color _onLight(Color c) => c;

/// การ์ดบนแผงซ้าย: ขาว ขอบเทาบาง มุม 12 (แบบการ์ดหน้าคัดกรอง)
final BoxDecoration _lpCardDeco = BoxDecoration(
  color: _panel,
  borderRadius: BorderRadius.circular(12.0),
  border: Border.all(color: const Color(0xFFDADCE0)),
);

/// ดันสีเน้นให้สว่างพอจะอ่านออกบนพื้นสีหลัก
/// สี ESI กับสีระดับแจ้งเตือนเดิมเข้มเกินไปเมื่ออยู่บนน้ำเงินเข้ม
Color _onDark(Color c) => Color.lerp(c, Colors.white, 0.42)!;

/// สัดส่วนตำแหน่งการ์ดของแต่ละช่วงงานบนฉาก อิงผังใน Figma
/// ใช้เป็นจุดยึดตอนซูมเข้าไปดูมุมนั้นด้วย การ์ดกับมุมที่ขยายจึงตรงกัน

/// ไล่ลงขวาตามขั้นบันไดในภาพ การ์ดจึงเดินคู่ไปกับลำดับงาน
/// ไม่ใช่กระจายสามมุมแบบเดิมที่ไม่สัมพันธ์กับฉาก
const Map<_Phase, Offset> _spots = {
  _Phase.triage: Offset(0.13, 0.30),
  _Phase.treatment: Offset(0.36, 0.56),
  _Phase.after: Offset(0.66, 0.72),
  _Phase.observe: Offset(0.70, 0.30),
};
const Color _ink2 = Color(0xFF474C52);
const Color _ink3 = Color(0xFF6B7178);

/// สัดส่วนสีทั้งหน้าเป็นกฎ 60-30-10
/// 60 = พื้นและแผง (_bg _panel _panelSoft _line)
/// 30 = โครงสร้างและตัวรอง (_ink _ink2 _ink3 และ _blue ที่เป็นสีรอง)
/// 10 = สีเน้น (_red _blue และสี ESI) ใช้เฉพาะจุดที่ต้องการให้สะดุดตา
/// สีเน้นจะโผล่เฉพาะตอนผิดปกติ สถานะปกติใช้สีตัวอักษรธรรมดา
const bool _mono = false;

/// สีหลักของระบบ — น้ำเงินเข้ม ใช้เป็นสีรองในกฎ 60-30-10
/// (ส่วน 30) ไม่ใช่สีเน้น สีเน้นยังเป็นแดง/เหลืองกับสี ESI
const Color _blueHue = Color(0xFF001B7C);

/// ไล่เฉดจากสีหลัก ใช้กับของที่ต้องแยกลำดับกันในตระกูลสีเดียว
const Color _blue2 = Color(0xFF2B3F96);
const Color _blue3 = Color(0xFF5A69B4);
const Color _blue4 = Color(0xFF9AA3D2);
const Color _redHue = Color(0xFFD93025);

/// ระดับเทาที่ใช้แทนสีเน้นระหว่างโหมดยังไม่ลงสี เรียงจากเข้มไปอ่อน
const Color _g1 = Color(0xFF202124);
const Color _g2 = Color(0xFF3C4043);
const Color _g3 = Color(0xFF5F6368);
const Color _g4 = Color(0xFF80868B);
const Color _g5 = Color(0xFF9AA0A6);

const Color _blue = _mono ? _g2 : _blueHue;
const Color _red = _mono ? _g1 : _redHue;

/// เขียว: ใช้เฉพาะขั้นตอนที่ทำครบแล้ว (ผู้ใช้กำหนด ยกเว้นจากกฎ 60-30-10)
const Color _green = _mono ? _g3 : Color(0xFF1E9E5A);

/// ฟอนต์มาจากไฟล์ที่ฝังในแอป ไม่ได้โหลดจากเน็ต จอในห้องฉุกเฉินจึงไม่พังตอนเน็ตหลุด
/// น้ำหนักตัวอักษรต่ำสุดของหน้านี้คือ Medium (w500) บาง/ปกติจะถูกดันขึ้นเป็น w500
FontWeight _minW(FontWeight w) =>
    w.value < FontWeight.w500.value ? FontWeight.w500 : w;

/// พื้นปุ่ม/ป้ายสี: design language แบบ clean flat = สีเรียบทึบ ไม่ไล่แสง
/// (คงชื่อเดิมไว้ ทุกที่ที่เรียกจะแบนตามทั้งแอป)
LinearGradient _glossGrad(Color c) => LinearGradient(colors: [c, c]);

/// พื้นปุ่มขาว: ขาวเรียบ
const LinearGradient _glossWhite =
    LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]);

/// flat: ไม่มีเงาใต้ปุ่ม/ป้าย
List<BoxShadow> _glossLift(Color c) => const [];

/// เงาด้านในแบบเล่นแสง: ขอบบนสว่าง (แสงตกจากบน) ขอบล่างมืด
/// (แสงสะท้อนอยู่ในพื้น gradient ของการ์ด ไม่วาดทับเนื้อหา)
/// ใช้เป็น foregroundDecoration · วาดด้วย shader ไล่สี ไม่ใช้ blur (blur ทำ raster ช้า ~50 ms/เฟรม)
/// design language แบบ clean flat: ปิดแสงเงานูนทั้งแอป
const bool _flat = true;

class _InnerGloss extends Decoration {
  const _InnerGloss(this.radius, {this.dark = false});

  final double radius;
  final bool dark;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _InnerGlossPainter(this);
}

class _InnerGlossPainter extends BoxPainter {
  _InnerGlossPainter(this.d);

  final _InnerGloss d;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    // flat: ไม่วาดแสง/เงาด้านใน (คง class ไว้ ที่เรียกใช้ไม่ต้องแก้)
    if (_flat) return;
    final size = cfg.size;
    if (size == null || size.isEmpty) return;
    final rect = offset & size;
    final r = math.min(d.radius, size.shortestSide / 2);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));
    // ไม่ใช้ blur/clip (หนักบน GPU) ใช้ shader ไล่สีแทน
    // 1) ขอบด้านใน: เส้นไล่สี บนสว่าง → กลางใส → ล่างมืด
    final edge = rr.deflate(1.0);
    canvas.drawRRect(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: d.dark ? 0.45 : 1.0),
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.0),
              (d.dark ? Colors.black : const Color(0xFF0B1B3F))
                  .withValues(alpha: d.dark ? 0.28 : 0.08),
            ],
            stops: const [0.0, 0.35, 0.7, 1.0],
          ).createShader(rect));
    // 2) เงาด้านล่างในตัว: แถบไล่สีบาง ๆ ชิดขอบล่าง
    final band = math.min(10.0, size.height * 0.3);
    final bottom =
        Rect.fromLTRB(rect.left, rect.bottom - band, rect.right, rect.bottom);
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (d.dark ? Colors.black : const Color(0xFF0B1B3F))
                  .withValues(alpha: d.dark ? 0.18 : 0.04),
            ],
          ).createShader(bottom)
          ..blendMode = BlendMode.srcOver);
  }
}

extension _CoreThemePart on _ErFlowHomeWidgetState {
  TextStyle _t(double size,
          {Color color = _ink,
          FontWeight weight = FontWeight.w500,
          double? height}) =>
      TextStyle(
          fontFamily: 'GoogleSans',
          fontFamilyFallback: const ['NotoSansThai'],
          fontSize: size * _txtScale,
          color: color,
          fontWeight: _minW(weight),
          height: height);

  TextStyle _num(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: 'GoogleSans',
          fontFamilyFallback: const ['NotoSansThai'],
          fontSize: size * _txtScale,
          color: color,
          fontWeight: _minW(weight));
}
