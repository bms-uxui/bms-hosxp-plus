import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:h_o_sx_p_plus_v5/er/er_flow_home/er_flow_home_widget.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_feedback.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_master.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_session.dart';
import 'package:h_o_sx_p_plus_v5/er/er_shared/er_speech_dialog.dart';

// The unrelated 3D scene is a native platform view; form widgets stay real.
class _WebPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
          PlatformWebViewControllerCreationParams params) =>
      _WebController(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      _WebWidget(params);
}

class _WebController extends PlatformWebViewController {
  _WebController(super.params) : super.implementation();
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
  @override
  Future<void> runJavaScript(String script) async {}
}

class _WebWidget extends PlatformWebViewWidget {
  _WebWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  testWidgets('Accident analysis, selection, conflict and invalidation flow',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    WebViewPlatform.instance = _WebPlatform();
    ErFeedback.sound = false;
    ErSession.instance.signIn(erStaff.first);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null);
    await tester.runAsync(() async {
      await ErMaster.load();
      await (FontLoader('IBMPlexSansThaiLooped')
            ..addFont(rootBundle
                .load('assets/fonts/IBMPlexSansThaiLooped-Regular.ttf')))
          .load();
    });

    var calls = 0;
    Completer<http.Response>? pending;
    http.Response response() => http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'suggestions': [
                    {
                      'field': 'จุดเกิดเหตุ',
                      'value': 'ถนนทดสอบ',
                      'evidence': 'ถนนทดสอบ',
                      'status': 'matched',
                    },
                    {
                      'field': 'หมายเหตุ',
                      'value': 'ทดสอบใหม่',
                      'evidence': 'หมายเหตุ ทดสอบใหม่',
                      'status': 'needs_review',
                    },
                  ],
                }),
              },
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'});
    final client = MockClient((request) async {
      calls++;
      final body = jsonDecode(request.body) as Map;
      expect((body['messages'] as List).last['content'],
          'ถนนทดสอบ หมายเหตุ ทดสอบใหม่');
      if (pending != null) return pending!.future;
      return response();
    });

    Future<void> tap(Finder finder) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(finder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    final narrative = find.widgetWithText(
        TextField, 'พูดหรือพิมพ์เหตุการณ์ แล้วตรวจข้อความก่อนให้ AI จัดข้อมูล');
    final place = find.widgetWithText(TextField, 'ระบุถนน / บริเวณที่เกิดเหตุ');
    final notes = find.widgetWithText(TextField, 'ระบุหมายเหตุเพิ่มเติม');
    String value(Finder f) => tester.widget<TextField>(f).controller!.text;
    final suggestions = find.byType(CheckboxListTile);
    Finder choice(String label) => find.widgetWithText(CheckboxListTile, label);
    Finder apply(int n) => find.text('นำข้อมูลที่เลือกไปกรอก ($n)');

    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: ErFlowHomeWidget()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tap(find.text('หลังการตรวจ').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      if (find.text('เปิดช่วงงานนี้').evaluate().isNotEmpty) {
        await tap(find.text('เปิดช่วงงานนี้'));
      }
      await tap(find.text('อุบัติเหตุ').first);
      expect(narrative, findsOneWidget);
      expect(suggestions, findsNothing);
      expect(find.textContaining('พบข้อมูลแล้ว'), findsNothing);
      expect(find.byTooltip('ล้างค่าจุดเกิดเหตุ'), findsNothing);
      await tester.enterText(narrative, 'ถนนทดสอบ หมายเหตุ ทดสอบใหม่');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(calls, 0);
      expect(suggestions, findsNothing);
      expect(find.textContaining('พบข้อมูลแล้ว'), findsNothing);
      await tap(find.text('ให้ AI จัดข้อมูล'));
      expect(calls, 1);
      expect(suggestions, findsNWidgets(2));
      expect(find.byTooltip('จุดเกิดเหตุ · พบข้อมูลแล้ว'), findsOneWidget);
      expect(
          find.byTooltip('วันที่/เวลาเกิดเหตุ · ยังขาดข้อมูล'), findsOneWidget);
      await tap(find.text('ดูทั้งหมด (17)'));
      expect(find.byTooltip('หมายเหตุ · ต้องตรวจสอบ'), findsOneWidget);
      expect(value(place), isEmpty);
      expect(value(notes), isEmpty);

      await tap(find.text('เลือกทั้งหมด'));
      expect(
          tester
              .widgetList<CheckboxListTile>(suggestions)
              .every((w) => w.value == true),
          isTrue);
      await tap(find.text('ล้างทั้งหมด').first);
      expect(
          tester
              .widgetList<CheckboxListTile>(suggestions)
              .every((w) => w.value == false),
          isTrue);
      await tap(choice('จุดเกิดเหตุ'));
      await tap(apply(1));
      expect(value(place), 'ถนนทดสอบ');
      expect(value(notes), isEmpty);
      expect(
          tester
              .widgetList<CheckboxListTile>(suggestions)
              .every((w) => w.value == false),
          isTrue);
      // Reapplying the system's own value is idempotent, not a conflict.
      await tap(choice('จุดเกิดเหตุ'));
      await tap(apply(1));
      expect(find.text('ตรวจทานข้อมูลที่มีอยู่แล้ว'), findsNothing);

      await tester.ensureVisible(notes);
      await tester.enterText(notes, 'ค่าเดิม');
      await tap(choice('หมายเหตุ'));
      await tap(apply(1));
      expect(find.text('ข้อมูลเดิม: ค่าเดิม'), findsOneWidget);
      expect(find.text('ข้อมูลใหม่: ทดสอบใหม่'), findsOneWidget);
      expect(find.text('คงข้อมูลเดิม'), findsOneWidget);
      await tap(find.text('ยืนยัน'));
      expect(value(notes), 'ค่าเดิม');
      await tap(choice('หมายเหตุ'));
      await tap(apply(1));
      await tap(find.widgetWithText(CheckboxListTile, 'ข้อมูลเดิม: ค่าเดิม'));
      expect(find.text('ใช้ข้อมูลใหม่'), findsOneWidget);
      await tap(find.text('ยืนยัน'));
      expect(value(notes), 'ทดสอบใหม่');

      // Clearing after analysis should allow filling an empty field directly.
      await tap(find.byTooltip('ล้างค่าจุดเกิดเหตุ'));
      expect(find.byTooltip('ล้างค่าจุดเกิดเหตุ'), findsNothing);
      await tap(choice('จุดเกิดเหตุ'));
      await tap(apply(1));
      expect(find.text('ตรวจทานข้อมูลที่มีอยู่แล้ว'), findsNothing);
      expect(value(place), 'ถนนทดสอบ');

      await tap(choice('หมายเหตุ'));
      await tester.ensureVisible(narrative);
      await tester.enterText(narrative, 'แก้ข้อความ');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(suggestions, findsNothing);
      expect(find.byTooltip('จุดเกิดเหตุ · พบข้อมูลแล้ว'), findsNothing);
      // Returning to the original text cannot resurrect an in-flight result.
      await tester.enterText(narrative, 'ถนนทดสอบ หมายเหตุ ทดสอบใหม่');
      pending = Completer<http.Response>();
      await tap(find.text('ให้ AI จัดข้อมูล'));
      await tester.enterText(narrative, 'แก้ระหว่างวิเคราะห์');
      await tester.enterText(narrative, 'ถนนทดสอบ หมายเหตุ ทดสอบใหม่');
      pending!.complete(response());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(suggestions, findsNothing);
      expect(find.textContaining('ข้อความมีการเปลี่ยนแปลงระหว่างวิเคราะห์'),
          findsOneWidget);
      pending = null;
      await tap(find.text('ให้ AI จัดข้อมูล'));
      expect(
          tester
              .widgetList<CheckboxListTile>(suggestions)
              .every((w) => w.value == false),
          isTrue);
      await tap(choice('หมายเหตุ'));

      // Existing master dropdowns, editable care fields and trailing clear.
      await tap(find.text('เลือกยานพาหนะ'));
      final vehicle = ErMaster.maybe!
          .table('accident_vehicle_type')!
          .activeItems
          .first
          .name;
      await tap(find.text(vehicle).last);
      expect(find.byTooltip('ล้างค่ายานพาหนะ'), findsOneWidget);
      await tap(find.byTooltip('ล้างค่ายานพาหนะ'));
      expect(find.byTooltip('ล้างค่ายานพาหนะ'), findsNothing);
      const careFields = [
        ('การดูแลการหายใจ', 'accident_airway_type'),
        ('การห้ามเลือด', 'accident_bleed_type'),
        ('การให้ IV fluid', 'accident_fluid_type'),
        ('การใส่ Splint/Slab', 'accident_splint_type'),
        ('การ Immobilize C-spine', 'accident_cspine_type'),
      ];
      for (var i = 0; i < careFields.length; i++) {
        final (label, table) = careFields[i];
        final editor = find
            .widgetWithText(TextField, 'เลือกจากรายการ หรือพิมพ์รายละเอียด')
            .at(i);
        final arrow = find.byTooltip('เลือกค่ามาตรฐาน$label');
        final clear = find.byTooltip('ล้างค่า$label');
        expect(clear, findsNothing);
        expect(find.byTooltip('พูดเพื่อกรอก$label'), findsNothing);
        await tap(arrow);
        final option = ErMaster.maybe!.table(table)!.activeItems.first.name;
        await tap(find.text(option).last);
        expect(value(editor), option);
        expect(clear, findsOneWidget);
        expect(tester.getRect(arrow).overlaps(tester.getRect(clear)), isFalse);
        await tap(clear);
        expect(value(editor), isEmpty);
        expect(clear, findsNothing);
        await tester.ensureVisible(editor);
        await tester.enterText(editor, 'รายละเอียดเพิ่มเติม');
        await tester.pump();
        expect(clear, findsOneWidget);
        await tap(clear);
      }
      // Shared voice editor returns text only, and does not invoke extraction.
      final beforeVoice = calls;
      await tap(find.byTooltip('พูดบันทึกข้อมูลอิสระ'));
      expect(find.byType(ErSpeechDialog), findsOneWidget);
      final voiceText = find.descendant(
          of: find.byType(ErSpeechDialog), matching: find.byType(TextField));
      await tester.enterText(voiceText, 'ข้อความจากหน้าพูด');
      await tap(find.text('ใช้ข้อความนี้'));
      expect(value(narrative), 'ข้อความจากหน้าพูด');
      expect(calls, beforeVoice);
      expect(suggestions, findsNothing);
      await tap(find.byTooltip('ปิด').last);
      await tap(find.text('อุบัติเหตุ').first);
      expect(value(place), 'ถนนทดสอบ');
      expect(value(notes), 'ทดสอบใหม่');
      expect(value(narrative), 'ข้อความจากหน้าพูด');
      expect(suggestions, findsNothing);
      await tap(find.byTooltip('ปิด').last);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 400));
    }, () => client);
    expect(tester.takeException(), isNull);
  });
}
