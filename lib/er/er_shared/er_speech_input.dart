import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'er_ai.dart';

enum ErSpeechState {
  idle,
  permission,
  listening,
  processing,
  success,
  noSpeech,
  permissionDenied,
  error
}

abstract class ErAudioCapture {
  Future<bool> hasPermission();
  Future<void> start();
  Future<Uint8List> stop();
  Future<void> dispose();
}

/// PCM streaming avoids dart:io and temporary paths on the web.
class ErRecordCapture implements ErAudioCapture {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  BytesBuilder _bytes = BytesBuilder(copy: false);
  Object? _streamError;
  @override
  Future<bool> hasPermission() => _recorder.hasPermission();
  @override
  Future<void> start() async {
    _bytes = BytesBuilder(copy: false);
    _streamError = null;
    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    ));
    _subscription = stream.listen(_bytes.add, onError: (Object e) {
      _streamError = e;
    });
  }

  @override
  Future<Uint8List> stop() async {
    await _recorder.stop();
    await _subscription?.cancel();
    _subscription = null;
    if (_streamError != null) throw StateError('Audio stream failed');
    return _bytes.takeBytes();
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _recorder.dispose();
  }
}

Uint8List erPcmToWav(Uint8List pcm) {
  final out = Uint8List(44 + pcm.length);
  final data = ByteData.sublistView(out);
  void text(int offset, String value) =>
      out.setRange(offset, offset + value.length, value.codeUnits);
  text(0, 'RIFF');
  data.setUint32(4, 36 + pcm.length, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, 16000, Endian.little);
  data.setUint32(28, 32000, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  text(36, 'data');
  data.setUint32(40, pcm.length, Endian.little);
  out.setRange(44, out.length, pcm);
  return out;
}

class ErSpeechInput extends ChangeNotifier {
  ErSpeechInput(
      {ErAudioCapture? capture,
      Future<String> Function(Uint8List)? transcribe,
      String? unavailableReason})
      : _capture = capture,
        _transcribe = transcribe ?? ErAi.transcribe,
        _unavailableReason = unavailableReason;
  ErAudioCapture? _capture;
  final Future<String> Function(Uint8List) _transcribe;
  final String? _unavailableReason;
  static ErSpeechInput? _active;
  ErSpeechState state = ErSpeechState.idle;
  String transcript = '';
  String message = 'แตะไมค์เพื่อพูด · ข้อความจะแสดงหลังหยุด';
  int seconds = 0;
  Timer? _timer;
  bool _closed = false;
  int _generation = 0;
  bool get busy =>
      state == ErSpeechState.permission || state == ErSpeechState.processing;
  void _set(ErSpeechState next, String text) {
    if (_closed) return;
    state = next;
    message = text;
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_closed || busy) return;
    if (state == ErSpeechState.listening) {
      await _stop();
      return;
    }
    if (_unavailableReason != null) {
      _set(ErSpeechState.error, _unavailableReason!);
      return;
    }
    if (_active != null && _active != this) {
      _set(ErSpeechState.error, 'มีไมค์อื่นกำลังทำงาน กรุณาหยุดก่อน');
      return;
    }
    final generation = ++_generation;
    _active = this;
    _set(ErSpeechState.permission, 'กำลังขอสิทธิ์ไมโครโฟน');
    try {
      final capture = _capture ??= ErRecordCapture();
      final permitted = await capture.hasPermission();
      if (_closed || generation != _generation) return;
      if (!permitted) {
        _active = null;
        _set(ErSpeechState.permissionDenied,
            'ไม่ได้รับสิทธิ์ไมค์ · อนุญาตในเบราว์เซอร์แล้วลองใหม่');
        return;
      }
      await capture.start();
      if (_closed || generation != _generation) return;
      seconds = 0;
      transcript = '';
      _set(ErSpeechState.listening, 'กำลังฟัง · แตะหยุดเพื่อถอดเสียง');
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        seconds++;
        if (seconds >= 60) {
          unawaited(_stop());
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      if (_active == this) _active = null;
      final denied = e.toString().contains('NotAllowed') ||
          e.toString().toLowerCase().contains('permission');
      _set(
          denied ? ErSpeechState.permissionDenied : ErSpeechState.error,
          denied
              ? 'ไม่ได้รับสิทธิ์ไมค์ · ตรวจสิทธิ์แล้วลองใหม่'
              : 'เปิดไมค์ไม่สำเร็จ · ตรวจ HTTPS และอุปกรณ์ไมโครโฟน');
    }
  }

  Future<void> _stop() async {
    if (_closed || state != ErSpeechState.listening) return;
    final generation = _generation;
    _timer?.cancel();
    _set(ErSpeechState.processing, 'กำลังถอดเสียง…');
    try {
      final pcm = await _capture!.stop();
      if (_closed || generation != _generation) return;
      final samples = ByteData.sublistView(pcm);
      double energy = 0;
      for (var i = 0; i + 1 < pcm.length; i += 2) {
        final sample = samples.getInt16(i, Endian.little);
        energy += sample * sample;
      }
      if (pcm.length < 3200 || math.sqrt(energy / (pcm.length / 2)) < 10) {
        _set(ErSpeechState.noSpeech, 'ไม่ได้ยินเสียงพูด · ลองอีกครั้ง');
        return;
      }
      final text =
          ErAi.cleanTranscript(await _transcribe(erPcmToWav(pcm))).trim();
      if (_closed || generation != _generation) return;
      if (!RegExp(r'[ก-๙A-Za-z0-9]').hasMatch(text)) {
        _set(ErSpeechState.noSpeech, 'ไม่พบข้อความจากเสียง · ลองอีกครั้ง');
        return;
      }
      transcript = text;
      _set(ErSpeechState.success, 'ถอดเสียงแล้ว · ตรวจและแก้ข้อความก่อนใช้');
    } catch (_) {
      _set(ErSpeechState.error,
          'ถอดเสียงไม่สำเร็จ · ตรวจการเชื่อมต่อบริการแล้วลองใหม่');
    } finally {
      if (_active == this) _active = null;
    }
  }

  @override
  void dispose() {
    _closed = true;
    _generation++;
    _timer?.cancel();
    if (_active == this) _active = null;
    final capture = _capture;
    if (capture != null) unawaited(capture.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
