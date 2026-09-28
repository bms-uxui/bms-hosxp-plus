import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'er_web_route.dart';

int _seq = 0;

/// ฉาก HTML หนึ่งฉากใน iframe · [run] = รัน JS ในฉาก · [onMessage] = ข้อความจากฉาก
class ErWebFrame {
  ErWebFrame({
    required String html,
    required String channel,
    required List<ErRoute> routes,
    required void Function(String message) onMessage,
  }) : _id = 'erframe${_seq++}' {
    String url(String asset) =>
        Uri.base.resolve(ui_web.assetManager.getAssetUrl(asset)).toString();
    // สคริปต์ <script src="x.js"> แปลงตรงนี้เลย · ไฟล์ที่โหลดทีหลัง (XHR/fetch) แปลงในฉาก
    final doc = html.replaceAllMapped(RegExp(r'src="([^"]+)"'), (m) {
      final hit =
          erRoute(routes, '/${m.group(1)!.replaceFirst(RegExp(r'^\.?/'), '')}');
      return hit == null ? m.group(0)! : 'src="${url(hit.$1)}"';
    });
    final table = jsonEncode([
      for (final (p, asset, _) in routes) [p, url(asset)]
    ]);
    final prelude = '''
<script>
(function () {
  var R = $table;
  function res(u) {
    if (typeof u !== 'string' || /^[a-z]+:/i.test(u)) return u;
    var p = '/' + u.replace(/^\\.?\\//, '');
    for (var i = 0; i < R.length; i++) {
      var m = new RegExp(R[i][0]).exec(p);
      if (m) return R[i][1].replace(/\\\$(\\d)/g, function (_, n) { return m[+n] || ''; });
    }
    return u;
  }
  var open = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function (m, u) {
    arguments[1] = res(u);
    return open.apply(this, arguments);
  };
  var f = window.fetch;
  if (f) window.fetch = function (u, o) { return f.call(window, res(u), o); };
  window.$channel = {
    postMessage: function (s) { parent.postMessage('\\u0001$_id\\u0001' + s, '*'); }
  };
})();
</script>
''';
    final full = doc.contains('<head>')
        ? doc.replaceFirst('<head>', '<head>$prelude')
        : '$prelude$doc';

    final document = globalContext['document'] as JSObject;
    _frame =
        document.callMethod('createElement'.toJS, 'iframe'.toJS) as JSObject;
    _frame['srcdoc'] = full.toJS;
    final style = _frame['style'] as JSObject;
    style['border'] = 'none'.toJS;
    style['width'] = '100%'.toJS;
    style['height'] = '100%'.toJS;
    style['background'] = 'transparent'.toJS;
    _frame.callMethod(
        'setAttribute'.toJS, 'allowtransparency'.toJS, 'true'.toJS);
    final frame = _frame;
    ui_web.platformViewRegistry.registerViewFactory(_id, (int _) => frame);

    final head = '\u0001$_id\u0001';
    _listener = ((JSObject e) {
      final s = e['data'].dartify();
      if (s is String && s.startsWith(head)) {
        onMessage(s.substring(head.length));
      }
    }).toJS;
    globalContext.callMethod(
        'addEventListener'.toJS, 'message'.toJS, _listener);
  }

  final String _id;
  late final JSObject _frame;
  late final JSFunction _listener;

  /// รัน JS ในฉาก (iframe ต้นทางเดียวกับแอป เรียก eval ได้ตรง ๆ)
  void run(String js) {
    final win = _frame['contentWindow'];
    if (win == null || win.isUndefinedOrNull) return;
    try {
      (win as JSObject).callMethod('eval'.toJS, js.toJS);
    } catch (e) {
      debugPrint('ErWebFrame $_id: $e');
    }
  }

  Widget view() => HtmlElementView(viewType: _id);

  void dispose() {
    globalContext.callMethod(
        'removeEventListener'.toJS, 'message'.toJS, _listener);
  }
}
