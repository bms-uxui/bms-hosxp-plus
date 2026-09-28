import 'package:flutter/widgets.dart';

import 'er_web_route.dart';

/// มือถือ: ไม่ใช้ (ฉากเปิดใน WebView) · มีไว้ให้คอมไพล์ผ่าน
class ErWebFrame {
  ErWebFrame({
    required String html,
    required String channel,
    required List<ErRoute> routes,
    required void Function(String message) onMessage,
  }) {
    throw UnsupportedError('ErWebFrame ใช้ได้บนเว็บเท่านั้น');
  }

  void run(String js) {}
  Widget view() => const SizedBox.shrink();
  void dispose() {}
}
