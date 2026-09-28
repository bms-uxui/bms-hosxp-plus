import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// เสียง + การสั่นเมื่อกดปุ่ม ใช้ร่วมทั้งโมดูล ER
///
/// - [tap] ปุ่มทั่วไป: คลิกเบา ๆ + selectionClick
/// - [confirm] การกระทำที่บันทึก/ส่งต่อ: เสียงสองโน้ต + mediumImpact
/// - ปิดเสียงได้ด้วย [sound] (การสั่นยังอยู่) — ห้อง ER บางช่วงต้องเงียบ
class ErFeedback {
  ErFeedback._();

  /// เปิดเสียงปุ่ม
  static bool sound = true;

  static const double _volume = 0.35;
  // player ตัวเดียวต่อเสียง: กดรัว = ตัดเสียงเดิมแล้วเริ่มใหม่ ไม่ซ้อนจนดังขึ้น
  static AudioPlayer? _tapPlayer;
  static AudioPlayer? _confirmPlayer;

  static AudioPlayer _make() {
    final p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    // Android: SoundPool หน่วงต่ำ เหมาะกับเสียงคลิกสั้น ๆ
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      p.setPlayerMode(PlayerMode.lowLatency);
    }
    p.setVolume(_volume);
    return p;
  }

  // สร้างตอนใช้ครั้งแรก (ไม่ใช้ธง ready: hot reload ไม่ล้าง static เดิม)
  static AudioPlayer get _tapP => _tapPlayer ??= _make();
  static AudioPlayer get _confirmP => _confirmPlayer ??= _make();

  static Future<void> _play(AudioPlayer p, String file) async {
    try {
      await p.stop();
      await p.play(AssetSource('audios/$file'), volume: _volume);
    } catch (e) {
      debugPrint('ErFeedback เล่นเสียงไม่ได้: $e');
    }
  }

  static DateTime _last = DateTime(0);

  static void tap() {
    // ปุ่มซ้อนกัน (เช่น _Press ครอบ InkWell) หรือดักหลายชั้น: เล่นครั้งเดียว
    final now = DateTime.now();
    if (now.difference(_last).inMilliseconds < 90) return;
    _last = now;
    HapticFeedback.selectionClick();
    if (!sound) return;
    _play(_tapP, 'ui_tap.wav');
  }

  static void confirm() {
    // กดปุ่มยืนยัน: ใช้เสียงยืนยันแทนเสียงคลิก (ตัดคลิกที่เพิ่งเล่น/กันคลิกที่ตามมา)
    _last = DateTime.now();
    HapticFeedback.mediumImpact();
    if (!sound) return;
    _tapPlayer?.stop();
    _play(_confirmP, 'ui_confirm.wav');
  }
}
