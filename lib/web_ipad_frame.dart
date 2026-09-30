import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// เว็บ: แสดงแอปในกรอบ iPad Air 11" แนวนอน (1180 x 820) ย่อให้พอดีหน้าต่าง
/// แอปข้างในเห็นขนาดจอเท่า iPad จริง layout จึงเหมือนบนเครื่อง
/// ปิดได้ด้วย ?frame=0 ต่อท้าย URL · ไม่มีผลกับแอปบนเครื่องจริง
class WebIpadFrame extends StatelessWidget {
  const WebIpadFrame({super.key, required this.child});

  final Widget child;

  static const Size screen = Size(1180.0, 820.0);
  static const double bezel = 18.0;

  static bool get enabled => kIsWeb && Uri.base.queryParameters['frame'] != '0';

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final mq = MediaQuery.of(context);
    final device = Size(screen.width + bezel * 2, screen.height + bezel * 2);
    return ColoredBox(
      color: const Color(0xFFE6E9EE),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: device.width,
              height: device.height,
              padding: const EdgeInsets.all(bezel),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D20),
                borderRadius: BorderRadius.circular(44.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 40.0,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26.0),
                child: MediaQuery(
                  data: mq.copyWith(
                    size: screen,
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: SizedBox.fromSize(size: screen, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
