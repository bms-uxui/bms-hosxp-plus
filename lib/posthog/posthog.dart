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
    if (kDebugMode) {
      throw StateError(
        'POSTHOG_PROJECT_TOKEN variable required by PostHog is missing or un-configured, this causes events to be silently missed. This error stops appearing once POSTHOG_PROJECT_TOKEN is configured',
      );
    }
    return;
  }

  if (PosthogEnv.host.isEmpty) {
    if (kDebugMode) {
      throw StateError(
        'POSTHOG_HOST variable required by PostHog is missing or un-configured, this causes events to be silently missed. This error stops appearing once POSTHOG_HOST is configured',
      );
    }
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

  try {
    await Posthog().setup(config);
    Posthog().logger.info('PostHog log capture initialized');
  } catch (_) {
    if (kDebugMode) {
      debugPrint('PostHog setup failed; analytics are disabled for this launch.');
    }
  }
}
