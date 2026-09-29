import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_speech_input.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_speech_dialog.dart';

class Capture implements ErAudioCapture {
  bool permitted = true, disposed = false, failStart = false;
  Uint8List bytes =
      Uint8List.fromList(List.generate(6400, (i) => i.isEven ? 255 : 10));
  @override
  Future<bool> hasPermission() async => permitted;
  @override
  Future<void> start() async {
    if (failStart) throw StateError('device failed');
  }

  @override
  Future<Uint8List> stop() async => bytes;
  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  test('PCM is wrapped as 16 kHz mono WAV', () {
    final wav = erPcmToWav(Uint8List.fromList([1, 2, 3, 4]));
    expect(String.fromCharCodes(wav.take(4)), 'RIFF');
    expect(ByteData.sublistView(wav).getUint32(24, Endian.little), 16000);
    expect(wav.sublist(44), [1, 2, 3, 4]);
  });
  test('real state sequence and no transcription on denied permission',
      () async {
    final capture = Capture()..permitted = false;
    var calls = 0;
    final input = ErSpeechInput(
        capture: capture,
        transcribe: (_) async {
          calls++;
          return 'test';
        });
    await input.toggle();
    expect(input.state, ErSpeechState.permissionDenied);
    expect(calls, 0);
    capture.permitted = true;
    final states = <ErSpeechState>[];
    input.addListener(() => states.add(input.state));
    await input.toggle();
    await input.toggle();
    expect(
        states,
        containsAllInOrder([
          ErSpeechState.permission,
          ErSpeechState.listening,
          ErSpeechState.processing,
          ErSpeechState.success
        ]));
    expect(calls, 1);
    input.dispose();
  });
  test('silence and service errors never fake success', () async {
    final capture = Capture()..bytes = Uint8List(6400);
    var calls = 0;
    final input = ErSpeechInput(
        capture: capture,
        transcribe: (_) async {
          calls++;
          throw StateError('network');
        });
    await input.toggle();
    await input.toggle();
    expect(input.state, ErSpeechState.noSpeech);
    expect(calls, 0);
    capture.bytes = Capture().bytes;
    await input.toggle();
    await input.toggle();
    expect(input.state, ErSpeechState.error);
    expect(calls, 1);
    input.dispose();
  });
  test('closing while processing discards a late result', () async {
    final result = Completer<String>();
    final input =
        ErSpeechInput(capture: Capture(), transcribe: (_) => result.future);
    await input.toggle();
    final stop = input.toggle();
    await Future<void>.delayed(Duration.zero);
    input.dispose();
    result.complete('late');
    await stop;
    expect(input.transcript, isEmpty);
  });
  test('HTTP/network capability error never starts a mock session', () async {
    final input = ErSpeechInput(unavailableReason: 'HTTPS required');
    await input.toggle();
    expect(input.state, ErSpeechState.error);
    expect(input.message, 'HTTPS required');
    input.dispose();
  });
  for (final size in [const Size(390, 844), const Size(1024, 768)]) {
    testWidgets('voice dialog edits and returns transcript at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = ErSpeechInput(
          capture: Capture(), transcribe: (_) async => 'ข้อความจากเสียง');
      String? result;
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () async {
                          result = await showDialog<String>(
                              context: context,
                              builder: (_) => ErSpeechDialog(
                                  title: 'หมายเหตุ',
                                  initial: 'เดิม',
                                  hint: 'พูด',
                                  okText: 'ใช้ข้อความนี้',
                                  input: input));
                        },
                        child: const Text('open')),
                  ))));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('เริ่มพูด'));
      await tester.pump();
      await tester.pump();
      expect(find.byTooltip('หยุดและถอดเสียง'), findsOneWidget);
      await tester.tap(find.byTooltip('หยุดและถอดเสียง'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'เดิม ข้อความจากเสียง');
      await tester.enterText(find.byType(TextField), 'แก้ไขด้วยคีย์บอร์ด');
      await tester.tap(find.text('ใช้ข้อความนี้'));
      await tester.pumpAndSettle();
      expect(result, 'แก้ไขด้วยคีย์บอร์ด');
      expect(tester.takeException(), isNull);
    });
  }
}
