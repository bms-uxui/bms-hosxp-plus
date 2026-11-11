/// ตัวเรียกบริการ AI ของ BMS Cloud (เหมือน src/services/ai ใน cis-redesign-2026)
///
/// ทุกปลายทางเป็นแบบ OpenAI-compatible
///   LLM  vllm-gemma (หลัก) / vllm-qwen (เร็ว)  POST /v1/chat/completions
///   ASR  asr2 (Qwen3-ASR)                     POST /v1/audio/transcriptions
///   TTS  vox-cpm                              POST /v1/audio/speech
///
/// ยังไม่ส่งข้อมูลระบุตัวคนไข้ (PHI) ออกไป — ส่งเฉพาะข้อความที่หมอพูด
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../posthog/posthog_logs.dart';

export 'er_so_import.dart';
export 'er_pdf_view.dart';

class ErAi {
  ErAi._();

  static const String llmBase = 'https://vllm-gemma.bmscloud.in.th';
  static const String llmFastBase = 'https://vllm-qwen.bmscloud.in.th';
  static const String asrBase = 'https://asr2.bmscloud.in.th';
  static const String ttsBase = 'https://vox-cpm.bmscloud.in.th';

  // One AI Observability session covers this app process because the shared
  // LLM client has no conversation identifier. Each request gets its own
  // trace below, while PostHog's existing ER identity attributes it to staff.
  static final Random _random = Random();
  static final String _aiSessionId =
      'er-ai-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';
  static int _traceSequence = 0;

  // Manual captures include prompt and completion content by default. Supply
  // --dart-define=POSTHOG_AI_PRIVACY_MODE=true before handling sensitive AI
  // content to omit those fields from newly captured generations.
  static const bool _aiPrivacyMode =
      bool.fromEnvironment('POSTHOG_AI_PRIVACY_MODE', defaultValue: false);

  static String _newTraceId() =>
      'er-ai-${DateTime.now().microsecondsSinceEpoch}-${_traceSequence++}-${_random.nextInt(1 << 32)}';

  /// คุยกับ LLM คืนข้อความคำตอบล้วน ๆ
  static Future<String> chat(
    List<Map<String, String>> messages, {
    bool fast = false,
    bool json = false,
    double temperature = 0.2,
    int maxTokens = 700,
  }) async {
    final base = fast ? llmFastBase : llmBase;
    final traceId = _newTraceId();
    final startedAt = DateTime.now();
    int? statusCode;
    final input = messages
        .map<Map<String, dynamic>>((message) => Map<String, dynamic>.from(message))
        .toList();

    try {
      final res = await http
          .post(
            Uri.parse('$base/v1/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'default',
              'messages': messages,
              'temperature': temperature,
              'max_tokens': maxTokens,
              if (json) 'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 60));
      statusCode = res.statusCode;
      if (statusCode != 200) {
        throw ErAiError('llm', statusCode, res.body);
      }

      final data =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      final msg = choices.isEmpty
          ? null
          : choices.first['message'] as Map<String, dynamic>?;
      final output = (msg?['content'] as String?) ?? '';
      _captureGeneration(
        traceId: traceId,
        name: 'chat_completion',
        base: base,
        input: input,
        output: output,
        data: data,
        statusCode: statusCode,
        startedAt: startedAt,
        temperature: temperature,
        maxTokens: maxTokens,
      );
      return output;
    } catch (_) {
      _captureGeneration(
        traceId: traceId,
        name: 'chat_completion',
        base: base,
        input: input,
        statusCode: statusCode,
        startedAt: startedAt,
        temperature: temperature,
        maxTokens: maxTokens,
        isError: true,
      );
      rethrow;
    }
  }

  /// ถามโมเดลพร้อมรูป (Gemma รองรับภาพ) คืนข้อความคำตอบ · ใช้อ่านตัวเลขจากจอ monitor
  static Future<String> vision(String prompt, Uint8List image,
      {String mime = 'image/jpeg', int maxTokens = 300}) async {
    final traceId = _newTraceId();
    final startedAt = DateTime.now();
    int? statusCode;
    final input = <Map<String, dynamic>>[
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:$mime;base64,${base64Encode(image)}'},
          },
        ],
      },
    ];

    try {
      final res = await http
          .post(
            Uri.parse('$llmBase/v1/chat/completions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'default',
              'temperature': 0.0,
              'max_tokens': maxTokens,
              'messages': input,
            }),
          )
          .timeout(const Duration(seconds: 60));
      statusCode = res.statusCode;
      if (statusCode != 200) {
        throw ErAiError('vision', statusCode, res.body);
      }

      final data =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      final msg = choices.isEmpty
          ? null
          : choices.first['message'] as Map<String, dynamic>?;
      final output = (msg?['content'] as String?) ?? '';
      _captureGeneration(
        traceId: traceId,
        name: 'vision_completion',
        base: llmBase,
        input: input,
        output: output,
        data: data,
        statusCode: statusCode,
        startedAt: startedAt,
        temperature: 0.0,
        maxTokens: maxTokens,
      );
      return output;
    } catch (_) {
      _captureGeneration(
        traceId: traceId,
        name: 'vision_completion',
        base: llmBase,
        input: input,
        statusCode: statusCode,
        startedAt: startedAt,
        temperature: 0.0,
        maxTokens: maxTokens,
        isError: true,
      );
      rethrow;
    }
  }

  /// Captures the completed request without delaying its clinical workflow.
  static void _captureGeneration({
    required String traceId,
    required String name,
    required String base,
    required List<Map<String, dynamic>> input,
    required DateTime startedAt,
    required double temperature,
    required int maxTokens,
    String? output,
    Map<String, dynamic>? data,
    int? statusCode,
    bool isError = false,
  }) {
    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    if (isError) {
      PosthogAppLogs.aiGenerationFailed(
        requestType: name,
        statusCode: statusCode,
        durationMs: durationMs,
      );
    } else {
      PosthogAppLogs.aiGenerationCompleted(
        requestType: name,
        statusCode: statusCode,
        durationMs: durationMs,
      );
    }

    try {
      final usage = data?['usage'] as Map?;
      final choices = data?['choices'] as List<dynamic>? ?? const [];
      final firstChoice = choices.isEmpty ? null : choices.first as Map?;
      final properties = <String, Object>{
        r'$ai_trace_id': traceId,
        r'$ai_session_id': _aiSessionId,
        r'$ai_span_id': _newTraceId(),
        r'$ai_span_name': name,
        r'$ai_model': data?['model']?.toString() ?? 'default',
        r'$ai_provider': 'vllm',
        r'$ai_base_url': base,
        r'$ai_request_url': '$base/v1/chat/completions',
        r'$ai_latency':
            DateTime.now().difference(startedAt).inMicroseconds / 1000000,
        r'$ai_temperature': temperature,
        r'$ai_max_tokens': maxTokens,
        if (!_aiPrivacyMode) r'$ai_input': input,
        if (!_aiPrivacyMode && output != null)
          r'$ai_output_choices': [
            {'role': 'assistant', 'content': output},
          ],
        if (usage?['prompt_tokens'] != null)
          r'$ai_input_tokens': usage!['prompt_tokens'],
        if (usage?['completion_tokens'] != null)
          r'$ai_output_tokens': usage!['completion_tokens'],
        if (statusCode != null) r'$ai_http_status': statusCode,
        if (firstChoice?['finish_reason'] != null)
          r'$ai_stop_reason': firstChoice!['finish_reason'],
        if (isError) r'$ai_is_error': true,
      };

      unawaited(
        Posthog()
            .capture(eventName: r'$ai_generation', properties: properties)
            .catchError((_) {}),
      );
    } catch (_) {
      // Observability must never interrupt the existing LLM request.
    }
  }

  /// ดึง JSON object ตัวแรกจากคำตอบ ทนต่อ ```json ... ``` และข้อความนำหน้า
  static Map<String, dynamic>? extractJson(String text) {
    final t = text.trim();
    try {
      return jsonDecode(t) as Map<String, dynamic>;
    } catch (_) {}
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(t);
    if (fence != null) {
      try {
        return jsonDecode(fence.group(1)!.trim()) as Map<String, dynamic>;
      } catch (_) {}
    }
    final start = t.indexOf('{');
    if (start < 0) return null;
    var depth = 0;
    var inStr = false;
    var esc = false;
    for (var i = start; i < t.length; i++) {
      final c = t[i];
      if (inStr) {
        if (esc) {
          esc = false;
        } else if (c == r'\') {
          esc = true;
        } else if (c == '"') {
          inStr = false;
        }
        continue;
      }
      if (c == '"') {
        inStr = true;
      } else if (c == '{') {
        depth++;
      } else if (c == '}') {
        depth--;
        if (depth == 0) {
          try {
            return jsonDecode(t.substring(start, i + 1))
                as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        }
      }
    }
    return null;
  }

  /// ถอดเสียงจากไฟล์ WAV (16 kHz mono) — ไม่ระบุภาษาให้โมเดลเดาเอง
  /// เพราะหมอพูดไทยปนอังกฤษ
  static Future<String> transcribe(Uint8List wav) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$asrBase/v1/audio/transcriptions'))
      ..files
          .add(http.MultipartFile.fromBytes('file', wav, filename: 'clip.wav'))
      ..fields['model'] = 'Qwen/Qwen3-ASR-1.7B'
      // บริบทให้โมเดลเอนไปทางไทยปนศัพท์แพทย์ ลดการเดาเป็นภาษาอื่นตอนเสียงไม่ชัด
      ..fields['prompt'] =
          'แพทย์ห้องฉุกเฉินบันทึกอาการผู้ป่วยเป็นภาษาไทย ปนศัพท์แพทย์อังกฤษ'
      ..fields['response_format'] = 'json';
    final streamed = await req.send().timeout(const Duration(seconds: 90));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw ErAiError('asr', res.statusCode, res.body);
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return cleanTranscript((data['text'] as String?) ?? '');
  }

  /// Qwen3-ASR ชอบแปะแท็กภาษา เช่น `language Thai<asr_text>` ไว้หน้าข้อความ
  static String cleanTranscript(String text) {
    const langs =
        r'(?:thai|english|chinese|mandarin|cantonese|yue|japanese|korean|vietnamese|burmese|lao|malay)';
    return text
        .replaceAll(RegExp(r'<\|?/?[A-Za-z_-]{1,24}\|?>'), '')
        .replaceAll(
            RegExp('(?:^|\\s)language\\s*[:：-]?\\s*$langs\\b',
                caseSensitive: false),
            ' ')
        .replaceAll(
            RegExp('^\\s*$langs\\s*[:：-]?\\s+', caseSensitive: false), '')
        // เสียงไม่ชัดโมเดลเดาเป็นจีน/ญี่ปุ่น/เกาหลี (เช่น "等下我。") ตัดทิ้ง ไม่ใช่คำพูดในห้อง
        .replaceAll(
            RegExp(r'[\u3000-\u30FF\u3400-\u9FFF\uAC00-\uD7AF\uFF00-\uFFEF]'),
            '')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }

  /// สังเคราะห์เสียงพูดไทย คืนไบต์ MP3
  static Future<Uint8List> speak(String text, {String voice = 'female'}) async {
    final res = await http
        .post(
          Uri.parse('$ttsBase/v1/audio/speech'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'input': text,
            'voice': voice,
            'response_format': 'mp3',
          }),
        )
        .timeout(const Duration(seconds: 90));
    if (res.statusCode != 200) {
      throw ErAiError('tts', res.statusCode, res.body);
    }
    return res.bodyBytes;
  }
}

class ErAiError implements Exception {
  ErAiError(this.service, this.status, String body)
      : message = body.length > 200 ? body.substring(0, 200) : body;
  final String service;
  final int status;
  final String message;

  @override
  String toString() => '[$service] $status $message';
}
