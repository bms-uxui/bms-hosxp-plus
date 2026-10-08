/// Heartbeat ระหว่าง Dart กับหน้าเว็บใน WebView (เฉพาะ debug)
///
/// hot restart ทิ้ง Dart ทั้งหมดแต่ WKWebView ฝั่ง native ยังรันต่อ ถ้า JS ยัง
/// postMessage (เช่นส่งตำแหน่งทุกเฟรม) เข้า Dart ตัวใหม่ที่ไม่รู้จัก channel เดิม
/// webview_flutter_wkwebview จะ fatalError ทั้งแอป
///
/// Dart ส่ง `window.__erAlive` ทุก 250 ms · JS ส่งข้อความเฉพาะตอน heartbeat ยังสด
/// (ดู [js]) หลัง restart heartbeat หยุด JS จึงเงียบก่อน Dart ตัวใหม่ขึ้น
/// release ไม่ส่ง heartbeat และ JS ไม่ตั้ง `__erDbg` = ส่งได้ตามปกติ
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;

class ErWebAlive {
  ErWebAlive(this._run);

  final void Function(String js) _run;
  Timer? _timer;

  /// เงื่อนไขใน JS ใส่ต้นฟังก์ชันส่งข้อความ: `if (!__erOk()) return;`
  static const String js =
      'function __erOk(){return !window.__erDbg||Date.now()-(window.__erAlive||0)<700;}';

  void start() {
    if (!kDebugMode) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _run('window.__erDbg=1;window.__erAlive=Date.now();');
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
