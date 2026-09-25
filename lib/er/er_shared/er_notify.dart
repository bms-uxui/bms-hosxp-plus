import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// แจ้งเตือนระดับระบบ (Android notification) ของห้องฉุกเฉิน
///
/// ใช้กับการเตือนระดับวิกฤตเท่านั้น (ครบเวลาคำสั่งแพทย์ / ผู้ป่วยรอเกินเกณฑ์)
/// เด้งบนหน้าจอล็อกและแถบแจ้งเตือนแม้แอปอยู่เบื้องหลัง
/// แตะแล้วเปิดหน้าผู้ป่วยตาม HN ที่แนบมา (ไม่ต้องใช้เซิร์ฟเวอร์)
class ErNotify {
  ErNotify._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// ผู้ฟังการแตะแจ้งเตือน: รับ HN (อาจว่างถ้าไม่ผูกผู้ป่วย)
  static void Function(String hn)? onOpen;

  /// HN ที่เปิดแอปขึ้นมาจากการแตะแจ้งเตือน (แอปปิดอยู่ตอนแตะ)
  static String? launchHn;

  static const _channel = AndroidNotificationDetails(
    'er_critical',
    'การเตือนวิกฤต ห้องฉุกเฉิน',
    channelDescription: 'ครบเวลาคำสั่งแพทย์ และผู้ป่วยรอเกินเกณฑ์',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    color: Color(0xFFD93025),
    ticker: 'การเตือนวิกฤต',
  );

  static Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (r) {
          final hn = r.payload ?? '';
          onOpen?.call(hn);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        launchHn = launch!.notificationResponse?.payload;
      }
      // Android 13+ ต้องขออนุญาตก่อนเด้งได้
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      debugPrint('ErNotify init failed: $e');
    }
  }

  /// เด้งแจ้งเตือนหนึ่งรายการ · key เดิมจะแทนที่ใบเดิม ไม่ซ้อน
  static Future<void> show(String key, String title, String body,
      {String? hn}) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      await _plugin.show(
        id: key.hashCode & 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(android: _channel),
        payload: hn,
      );
    } catch (e) {
      debugPrint('ErNotify show failed: $e');
    }
  }

  /// ยกเลิกแจ้งเตือนที่รับทราบแล้ว
  static Future<void> cancel(String key) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: key.hashCode & 0x7fffffff);
    } catch (_) {}
  }
}
