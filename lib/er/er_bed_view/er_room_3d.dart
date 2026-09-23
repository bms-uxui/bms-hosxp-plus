/// ทางเข้าเดียวของฉากห้องฉุกเฉินสามมิติ
///
/// บนมือถือใช้ three.js ใน WebView (er_room_3d_io.dart)
/// บนเว็บ (tablet simulator) ใช้ภาพนิ่งแทน เพราะ WebView กับ HttpServer
/// ทำงานบนเว็บไม่ได้ (er_room_3d_web.dart)
library;

export 'er_room_types.dart';
export 'er_room_3d_web.dart' if (dart.library.io) 'er_room_3d_io.dart';
