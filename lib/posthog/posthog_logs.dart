import 'package:posthog_flutter/posthog_flutter.dart';

/// Dedicated, allowlisted Logs emitter for app-level operational milestones.
///
/// This deliberately does not attach to print, debugPrint, or other existing
/// loggers, so only the lines explicitly added here are exported to PostHog.
class PosthogAppLogs {
  PosthogAppLogs._();

  static void erWorkflowSignedIn({required String staffRole}) {
    _info(
      'ER workflow signed in',
      {'event': 'er_workflow_signed_in', 'staff_role': staffRole},
    );
  }

  static void erWorkflowSignedOut({required String staffRole}) {
    _info(
      'ER workflow signed out',
      {'event': 'er_workflow_signed_out', 'staff_role': staffRole},
    );
  }

  static void aiGenerationCompleted({
    required String requestType,
    required int? statusCode,
    required int durationMs,
  }) {
    _info(
      'AI generation completed',
      {
        'event': 'ai_generation_completed',
        'request_type': requestType,
        if (statusCode != null) 'http_status_code': statusCode,
        'duration_ms': durationMs,
      },
    );
  }

  static void aiGenerationFailed({
    required String requestType,
    required int? statusCode,
    required int durationMs,
  }) {
    _warn(
      'AI generation failed',
      {
        'event': 'ai_generation_failed',
        'request_type': requestType,
        if (statusCode != null) 'http_status_code': statusCode,
        'duration_ms': durationMs,
      },
    );
  }

  static void _info(String body, Map<String, Object> attributes) {
    try {
      Posthog().logger.info(body, attributes);
    } catch (_) {
      // Observability must never affect the ER workflow.
    }
  }

  static void _warn(String body, Map<String, Object> attributes) {
    try {
      Posthog().logger.warn(body, attributes);
    } catch (_) {
      // Observability must never affect the ER workflow.
    }
  }
}
