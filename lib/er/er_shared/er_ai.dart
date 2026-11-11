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
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:posthog_flutter/posthog_flutter.dart';

export 'er_so_import.dart';
export 'er_pdf_view.dart';

class ErAi {
  ErAi._();

  static const String llmBase = 'https://vllm-gemma.bmscloud.in.th';
  static const String llmFastBase = 'https://vllm-qwen.bmscloud.in.th';
  static const String asrBase = 'https://asr2.bmscloud.in.th';
  static const String ttsBase = 'https://vox-cpm.bmscloud.in.th';

  // This app has no durable conversation ID, so one app process is one AI
  // session. Each completion gets its own trace within that session.
  static final String _aiSessionId =
      'er-ai-${DateTime.now().microsecondsSinceEpoch}';
  static int _generationSequence = 0;

  static const bool _captureContent = false;

  static String _newTraceId() =>
      'er-ai-${DateTime.now().microsecondsSinceEpoch}-${++_generationSequence}';

  static void _captureGeneration({
    required String traceId,
    required String model,
    required String baseUrl,
    required String spanName,
    required Object input,
    String? output,
    required double latency,
    int? statusCode,
    int? inputTokens,
    int? outputTokens,
    Object? error,
    required double temperature,
    required int maxTokens,
  }) {
    final properties = <String, dynamic>{
      r'$ai_trace_id': traceId,
      r'$ai_session_id': _aiSessionId,
      r'$ai_span_name': spanName,
      r'$ai_model': model,
      r'$ai_provider': 'bms_cloud',
      r'$ai_base_url': baseUrl,
      r'$ai_request_url': '$baseUrl/v1/chat/completions',
      r'$ai_latency': latency,
      r'$ai_temperature': temperature,
      r'$ai_max_tokens': maxTokens,
      if (statusCode != null) r'$ai_http_status': statusCode,
      if (inputTokens != null) r'$ai_input_tokens': inputTokens,
      if (outputTokens != null) r'$ai_output_tokens': outputTokens,
      if (_captureContent) r'$ai_input': input,
      if (_captureContent && output != null)
        r'$ai_output_choices': [
          {'role': 'assistant', 'content': output},
        ],
      if (error != null) ...{
        r'$ai_is_error': true,
        r'$ai_error': error.runtimeType.toString(),
      },
    };

    // Observability must never delay or fail an existing clinical AI request.
    unawaited(Posthog().capture(
      eventName: r'$ai_generation',
      properties: properties,
    ).catchError((_) {}));
  }

  /// คุยกับ LLM คืนข้อความคำตอบล้วน ๆ
  static Future<String> chat(
    List<Map<String, String>> messages, {
    bool fast = false,
    bool json = false,
    double temperature = 0.2,
    int maxTokens = 700,
  }) async {
    final base = fast ? llmFastBase : llmBase;
    final model = fast ? 'vllm-qwen' : 'vllm-gemma';
    final traceId = _newTraceId();
    final startedAt = DateTime.now();
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
      if (res.statusCode != 200) {
        throw ErAiError('llm', res.statusCode, res.body);
      }
      final data =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      final msg = choices.isEmpty
          ? null
          : choices.first['message'] as Map<String, dynamic>?;
      final output = (msg?['content'] as String?) ?? '';
      final usage = data['usage'] as Map<String, dynamic>?;
      _captureGeneration(
        traceId: traceId,
        model: model,
        baseUrl: base,
        spanName: 'chat_completion',
        input: messages,
        output: output,
        latency: DateTime.now().difference(startedAt).inMicroseconds / 1000000,
        statusCode: res.statusCode,
        inputTokens: usage?['prompt_tokens'] as int?,
        outputTokens: usage?['completion_tokens'] as int?,
        temperature: temperature,
        maxTokens: maxTokens,
      );
      return output;
    } catch (error) {
      _captureGeneration(
        traceId: traceId,
        model: model,
        baseUrl: base,
        spanName: 'chat_completion',
        input: messages,
        latency: DateTime.now().difference(startedAt).inMicroseconds / 1000000,
        statusCode: error is ErAiError ? error.status : null,
        error: error,
        temperature: temperature,
        maxTokens: maxTokens,
      );
      rethrow;
    }
  }

  /// ถามโมเดลพร้อมรูป (Gemma รองรับภาพ) คืนข้อความคำตอบ · ใช้อ่านตัวเลขจากจอ monitor
  static Future<String> vision(String prompt, Uint8List image,
      {String mime = 'image/jpeg', int maxTokens = 300}) async {
    final traceId = _newTraceId();
    final startedAt = DateTime.now();
    // Retain the textual instruction but not the source image itself: image
    // data can exceed event limits and may contain sensitive clinical details.
    final input = [
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {'type': 'image', 'mime_type': mime, 'size_bytes': image.length},
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
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': prompt},
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:$mime;base64,${base64Encode(image)}'
                      }
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 60));
      if (res.statusCode != 200) {
        throw ErAiError('vision', res.statusCode, res.body);
      }
      final data =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      final msg = choices.isEmpty
          ? null
          : choices.first['message'] as Map<String, dynamic>?;
      final output = (msg?['content'] as String?) ?? '';
      final usage = data['usage'] as Map<String, dynamic>?;
      _captureGeneration(
        traceId: traceId,
        model: 'vllm-gemma',
        baseUrl: llmBase,
        spanName: 'vision_completion',
        input: input,
        output: output,
        latency: DateTime.now().difference(startedAt).inMicroseconds / 1000000,
        statusCode: res.statusCode,
        inputTokens: usage?['prompt_tokens'] as int?,
        outputTokens: usage?['completion_tokens'] as int?,
        temperature: 0.0,
        maxTokens: maxTokens,
      );
      return output;
    } catch (error) {
      _captureGeneration(
        traceId: traceId,
        model: 'vllm-gemma',
        baseUrl: llmBase,
        spanName: 'vision_completion',
        input: input,
        latency: DateTime.now().difference(startedAt).inMicroseconds / 1000000,
        statusCode: error is ErAiError ? error.status : null,
        error: error,
        temperature: 0.0,
        maxTokens: maxTokens,
      );
      rethrow;
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
