import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog configuration supplied at build time with `--dart-define`.
class PosthogEnv {
  static const projectToken = String.fromEnvironment('POSTHOG_PROJECT_TOKEN');
  static const host = String.fromEnvironment('POSTHOG_HOST');
}

/// Initializes the shared PostHog client before the application starts.
Future<void> setupPostHog() async {
  if (PosthogEnv.projectToken.isEmpty) {
    // ไม่มีค่า = ข้าม PostHog (แอปยังเปิดได้ เช่น build เว็บ/รันในเครื่อง) · เตือนใน console ตอน debug
    debugPrint(
        'PostHog ปิดอยู่: ไม่มี POSTHOG_PROJECT_TOKEN (รันด้วย --dart-define-from-file=.env)');
    return;
  }

  if (PosthogEnv.host.isEmpty) {
    // ไม่มีค่า = ข้าม PostHog (แอปยังเปิดได้ เช่น build เว็บ/รันในเครื่อง) · เตือนใน console ตอน debug
    debugPrint(
        'PostHog ปิดอยู่: ไม่มี POSTHOG_HOST (รันด้วย --dart-define-from-file=.env)');
    return;
  }

  final config = PostHogConfig(PosthogEnv.projectToken);
  config.host = PosthogEnv.host;
  config.debug = kDebugMode;

  config.logsConfig.serviceName = 'hosxp-plus';
  config.errorTrackingConfig.captureFlutterErrors = true;
  config.errorTrackingConfig.capturePlatformDispatcherErrors = true;
  config.errorTrackingConfig.captureIsolateErrors = true;
  config.errorTrackingConfig.captureNativeExceptions = true;

  // Session replay: ตอนพัฒนา (ข้อมูลจำลอง) = เห็นข้อความ/รูปจริง ดู UX รู้เรื่อง
  // build release (ข้อมูลผู้ป่วยจริง) = ซ่อนข้อความและรูปทั้งหมด ห้ามเปลี่ยนส่วนนี้
  config.sessionReplay = true;
  config.sessionReplayConfig.maskAllTexts = kReleaseMode;
  config.sessionReplayConfig.maskAllImages = kReleaseMode;

  try {
    await Posthog().setup(config);
    Posthog().logger.info('PostHog log capture initialized');
  } catch (_) {
    if (kDebugMode) {
      debugPrint(
          'PostHog setup failed; analytics are disabled for this launch.');
    }
  }
}
