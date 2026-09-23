/// ตัวควบคุมหุ่นยนต์ผู้ช่วยสามมิติ ใช้ร่วมกันทั้งฝั่งมือถือและเว็บ
library;

import 'dart:typed_data';

/// อารมณ์/สถานะของหุ่น กำหนดสีวงแหวนหน้าอกกับท่าทาง
enum ErAuraMood { idle, listening, thinking, talking }

/// สะพานจากหน้า Flutter ไปยังหุ่นใน WebView
///
/// หน้าเรียก [speak] ด้วยไบต์ MP3 จาก TTS แล้วหุ่นจะเล่นเสียงและขยับปาก
/// ตามความดังจริง เมื่อพูดจบจะเรียก [onSpeechEnd]
class ErAuraController {
  ErAuraMood mood = ErAuraMood.idle;
  void Function()? onSpeechEnd;

  /// ต่อกับ widget ที่มีตัวจริง (ฝั่งมือถือ) — ฝั่งเว็บไม่มีก็แค่ไม่ทำอะไร
  Future<void> Function(Uint8List mp3)? speakImpl;
  void Function()? flushImpl;
  void Function(ErAuraMood mood)? moodImpl;
  void Function()? stopImpl;

  /// ต่อคลิปเข้าคิว (ทีละประโยค) เล่นต่อกันทันทีที่คลิปแรกมาถึง
  Future<void> speak(Uint8List mp3) async {
    mood = ErAuraMood.talking;
    moodImpl?.call(mood);
    await speakImpl?.call(mp3);
  }

  /// ส่งครบทุกประโยคแล้ว หุ่นจะเรียก [onSpeechEnd] เมื่อเล่นคิวหมด
  void flush() {
    final impl = flushImpl;
    if (impl == null) {
      // ไม่มีตัวเล่นเสียง (เช่นบนเว็บ) ถือว่าพูดจบทันที
      onSpeechEnd?.call();
      return;
    }
    impl();
  }

  void setMood(ErAuraMood m) {
    mood = m;
    moodImpl?.call(m);
  }

  void stop() => stopImpl?.call();
}
