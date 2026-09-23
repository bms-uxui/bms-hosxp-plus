/// ทางเข้าเดียวของฉากแท่นสามมิติ
///
/// บนมือถือใช้ three.js ใน WebView (er_platform_3d_io.dart)
/// บนเว็บใช้ภาพแทน เพราะ WebView กับ HttpServer ทำงานบนเว็บไม่ได้
library;

export 'er_flow_3d_types.dart';
export 'er_platform_3d_web.dart' if (dart.library.io) 'er_platform_3d_io.dart';
