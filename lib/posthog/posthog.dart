import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Build-time PostHog configuration supplied with `--dart-define`.
class PosthogEnv {
  static const projectToken = String.fromEnvironment('POSTHOG_PROJECT_TOKEN');
  static const host = String.fromEnvironment('POSTHOG_HOST');
}

/// Configures PostHog once before the application starts.
Future<void> setupPostHog() async {
  if (PosthogEnv.projectToken.isEmpty) {
    // ไม่มีค่า = ข้าม PostHog (แอปยังเปิดได้) · เตือนใน console ตอน debug
    debugPrint(
        'PostHog ปิดอยู่: ไม่มี POSTHOG_PROJECT_TOKEN (รันด้วย --dart-define-from-file=.env)');
    return;
  }

  if (PosthogEnv.host.isEmpty) {
    // ไม่มีค่า = ข้าม PostHog (แอปยังเปิดได้) · เตือนใน console ตอน debug
    debugPrint(
        'PostHog ปิดอยู่: ไม่มี POSTHOG_HOST (รันด้วย --dart-define-from-file=.env)');
    return;
  }

  final config = PostHogConfig(PosthogEnv.projectToken);
  config.host = PosthogEnv.host;
  config.debug = kDebugMode;
  // Keep the SDK-native Logs stream distinct from this app's existing
  // print/debugPrint output. Only PosthogAppLogs emits to this service.
  config.logsConfig.serviceName = 'hosxp-plus-flutter';
  config.logsConfig.environment = kReleaseMode ? 'production' : 'development';

  // Capture uncaught errors centrally rather than at individual screens or
  // flows. Silent framework errors retain the SDK's default exclusion.
  config.errorTrackingConfig.captureFlutterErrors = true;
  config.errorTrackingConfig.capturePlatformDispatcherErrors = true;
  config.errorTrackingConfig.captureIsolateErrors = true;
  config.errorTrackingConfig.captureNativeExceptions = true;

  // Session replay: ตอนพัฒนา (ข้อมูลจำลอง) = เห็นข้อความ/รูปจริง ดู UX รู้เรื่อง
  // build release (ข้อมูลผู้ป่วยจริง) = ซ่อนข้อความและรูปทั้งหมด ห้ามเปลี่ยนส่วนนี้
  config.sessionReplay = true;
  config.sessionReplayConfig.maskAllTexts = kReleaseMode;
  config.sessionReplayConfig.maskAllImages = kReleaseMode;

  await Posthog().setup(config);
}
