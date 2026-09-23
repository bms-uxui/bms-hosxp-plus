/// ทางเข้าเดียวของหุ่นยนต์ผู้ช่วยสามมิติ (โหมดพูดเพื่อบันทึก)
///
/// บนมือถือใช้ three.js ใน WebView เล่นเสียง TTS และขยับปากตามความดังจริง
/// บนเว็บแทนด้วยไอคอนนิ่ง เพราะ WebView กับ HttpServer ทำงานบนเว็บไม่ได้
library;

export 'er_aura_types.dart';
export 'er_aura_web.dart' if (dart.library.io) 'er_aura_io.dart';
