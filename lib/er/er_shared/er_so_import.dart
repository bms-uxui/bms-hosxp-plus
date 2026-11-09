/// นำเข้าใบ Standing order จากรูปหรือไฟล์สแกน
///
/// ตัดคอลัมน์และบรรทัดจากรูปเอง (AI บอกตำแหน่งบรรทัดไม่แม่น)
/// อ่าน 2 รอบ: ทั้งคอลัมน์ = รหัสหมวดที่เขียนกำกับ · ทีละแถบ = ข้อความ แล้วเทียบกัน
/// AI ไม่บอกความไม่มั่นใจเอง จุดที่ต้องตรวจจึงมาจากการเทียบและกฎใน [why] เท่านั้น
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

import 'er_ai.dart';

/// หนึ่งช่องในฟอร์มที่ AI แปลงจากบรรทัดคำสั่ง
class ErSoField {
  ErSoField(this.label, this.type, this.unit, this.opts);
  final String label, type, unit;
  final List<String> opts;
}

/// มองค่าที่เก็บแบบ 'id|ชื่อช่อง' เป็นแผนที่ ชื่อช่อง → ค่า (ให้ช่องของ Form Builder อ่านเขียนได้)
class ErPrefixMap extends MapBase<String, String> {
  ErPrefixMap(this.store, this.prefix);
  final Map<String, String> store;
  final String prefix;
  @override
  String? operator [](Object? key) => store['$prefix|$key'];
  @override
  void operator []=(String key, String value) => store['$prefix|$key'] = value;
  @override
  void clear() {}
  @override
  Iterable<String> get keys => [
        for (final k in store.keys)
          if (k.startsWith('$prefix|')) k.substring(prefix.length + 1)
      ];
  @override
  String? remove(Object? key) => store.remove('$prefix|$key');
}

/// หนึ่งรายการคำสั่งที่อ่านได้ (ผู้ใช้แก้ได้ในหน้าตรวจ)
class ErSoImportLine {
  ErSoImportLine(this.text, this.cats, this.oneDay, this.strips, this.why);

  String text;

  /// ชื่อสั้นของคำสั่ง (AI แปลง) · ว่าง = ใช้ข้อความเต็ม
  String name = '';

  /// ช่องที่แพทย์กรอกตอนสั่ง
  List<ErSoField> doctor = [];

  /// ช่องที่พยาบาลบันทึกผล
  List<ErSoField> nurse = [];
  Set<String> cats;
  bool oneDay;

  /// แถบรูปต้นฉบับของรายการ (หนึ่งแถบต่อหนึ่งบรรทัดบนกระดาษ)
  final List<Uint8List> strips;

  /// รูปใบเต็มของรายการนี้ และตำแหน่งบรรทัดบนรูป (ใช้เปิดดูใบเต็มพร้อมไฮไลต์)
  Uint8List? page;
  List<ErSoSpot> spots = const [];

  /// เหตุที่ต้องตรวจ ว่าง = ระบบไม่พบจุดสงสัย (ไม่ได้แปลว่าถูกแน่)
  final List<String> why;
}

/// ตำแหน่งบรรทัดบนรูปใบ เป็นสัดส่วน 0-1 ของกว้างและสูง
class ErSoSpot {
  const ErSoSpot(this.left, this.top, this.right, this.bottom);
  final double left, top, right, bottom;
}

class ErSoImportResult {
  ErSoImportResult(this.title, this.lines, this.hasCodes, this.failed);

  final String title;
  final List<ErSoImportLine> lines;

  /// พบรหัสหมวดลายมืออย่างน้อยหนึ่งรายการ
  final bool hasCodes;

  /// ส่วนของใบที่อ่านไม่สำเร็จ (ต้องบอกผู้ใช้ ห้ามหายเงียบ)
  final List<String> failed;
}

/// กรอบคอลัมน์ของหนึ่งหน้า (สัดส่วน 0..1): ซ้าย One Day · เส้นแบ่ง · ขวา Continuation · บน · ล่าง
class ErSoGuide {
  ErSoGuide(this.left, this.mid, this.right, this.top, this.bottom,
      {required this.aspect, required this.sure});
  double left, mid, right, top, bottom;

  /// กว้าง/สูงของรูป
  final double aspect;

  /// ระบบหาเส้นตารางเจอ (false = ค่าเดาคร่าว ๆ ผู้ใช้ควรลากเอง)
  final bool sure;
}

class _Column {
  _Column(this.body, this.withMargin, this.strips, this.shows, this.cut,
      this.spots, this.oneDay);
  final Uint8List body;
  final Uint8List withMargin;

  /// แถบส่งให้ AI อ่าน: เฉพาะเนื้อคอลัมน์ ไม่ให้ข้อความคอลัมน์ข้าง ๆ ปน
  final List<Uint8List> strips;

  /// แถบแสดงตอนตรวจ: เผื่อซ้ายให้เห็นรหัสที่เขียนกำกับ
  final List<Uint8List> shows;

  /// บรรทัดนี้มีตัวหนังสือชนขอบขวาของกรอบ = ท้ายบรรทัดอาจถูกตัด
  final List<bool> cut;

  /// ตำแหน่งของแต่ละแถบบนรูปใบ
  final List<ErSoSpot> spots;
  final bool oneDay;
}

class _Page {
  _Page(this.head, this.columns);
  final Uint8List head;
  final List<_Column> columns;
}

class ErSoImport {
  ErSoImport._();

  /// เปิดกล้องโหมดสแกนเอกสาร: จับขอบกระดาษ ดัดภาพ และปรับให้ชัดจากระบบเครื่อง
  /// ครั้งละ 1 หน้า: ใบ Standing order เกือบทั้งหมดมีหน้าเดียว
  static Future<List<Uint8List>?> scan(
      Future<Uint8List> Function(String path) read) async {
    final paths = await CunningDocumentScanner.getPictures(noOfPages: 1);
    if (paths == null || paths.isEmpty) return null;
    return [for (final p in paths) await read(p)];
  }

  /// เลือกไฟล์รูปหรือ PDF สแกน · null = ยกเลิก · ว่าง = PDF ไม่มีรูปสแกนในไฟล์
  static Future<List<Uint8List>?> pickFile() async {
    final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true);
    final f = r?.files.firstOrNull;
    if (f == null || f.bytes == null) return null;
    return f.extension?.toLowerCase() == 'pdf'
        ? pdfPages(f.bytes!)
        : [f.bytes!];
  }

  /// ดึงรูป JPEG ที่ฝังในไฟล์ PDF สแกน · PDF ที่เป็นข้อความล้วนจะได้ลิสต์ว่าง
  static List<Uint8List> pdfPages(Uint8List pdf) {
    final s = latin1.decode(pdf);
    final out = <Uint8List>[];
    var at = 0;
    while (true) {
      final f = s.indexOf('/DCTDecode', at);
      if (f < 0) break;
      final st = s.indexOf('stream', f);
      if (st < 0) break;
      final a = s.indexOf('\xFF\xD8\xFF', st);
      final e = s.indexOf('endstream', st);
      if (a < 0 || e < 0 || a > e) {
        at = f + 10;
        continue;
      }
      out.add(pdf.sublist(a, e));
      at = e;
    }
    return out;
  }

  /// เดากรอบคอลัมน์จากเส้นตาราง · หาไม่เจอ = ค่ากลาง ๆ ให้ผู้ใช้ลาก
  static Future<ErSoGuide?> guess(Uint8List raw) => compute(_guess, raw);

  static ErSoGuide? _guess(Uint8List raw) {
    final d = img.decodeImage(raw);
    if (d == null) return null;
    final im = d.width > 2000 ? img.copyResize(d, width: 2000) : d;
    final w = im.width, h = im.height;
    final gray = _gray(im);
    final t = _tableLines(gray, w, h);
    if (t != null) {
      final (xs, top, bottom) = t;
      final cols = <(int, int)>[];
      for (var i = 0; i + 1 < xs.length; i++) {
        if (xs[i + 1] - xs[i] > w * 0.15) cols.add((xs[i], xs[i + 1]));
      }
      if (cols.length >= 2 && bottom - top > h * 0.15) {
        var co = cols.last, od = cols[cols.length - 2];
        // เส้นขวาสุดจางจนหาไม่เจอ: คอลัมน์ขวาสุดที่เจอที่จริงคือ One Day
        final lost = co.$2 < w * 0.8;
        if (lost) {
          od = co;
          co = (co.$2, (w * 0.96).round());
        }
        final end = _tableEnd(gray, w, top, bottom, h, od.$1, co.$2);
        return ErSoGuide(od.$1 / w, co.$1 / w, co.$2 / w, top / h, end / h,
            aspect: w / h, sure: !lost);
      }
    }
    return ErSoGuide(0.38, 0.68, 0.96, 0.20, 0.88, aspect: w / h, sure: false);
  }

  /// เส้นปิดท้ายตาราง: เส้นแนวตั้งบางใบวิ่งเลยลงไปถึงช่องประวัติแพ้ยา
  /// ดูเป็นแถบหนา เพราะเส้นแนวนอนในรูปถ่ายเอียงเล็กน้อย
  static int _tableEnd(
      Uint8List g, int w, int top, int bottom, int h, int x0, int x1) {
    final band = (h * 0.01).round().clamp(8, 40);
    var paper = 0, seen = 0;
    for (var i = 0; i < g.length; i += 37) {
      paper += g[i];
      seen++;
    }
    final dark = (paper / seen * 0.82).round().clamp(150, 205);
    final from = (top + (bottom - top) ~/ 2).clamp(0, h);
    for (var y = from; y + band < bottom; y += 4) {
      if (bottom - y > h * 0.2) continue;
      var full = 0;
      for (var x = x0; x < x1; x += 2) {
        for (var k = y; k < y + band; k++) {
          if (g[k * w + x] < dark) {
            full++;
            break;
          }
        }
      }
      if (full >= (x1 - x0) / 2 * 0.68) return y;
    }
    return bottom;
  }

  static Uint8List _gray(img.Image im) {
    final g = Uint8List(im.width * im.height);
    for (final p in im) {
      g[p.y * im.width + p.x] = p.luminance.toInt();
    }
    return g;
  }

  static Future<ErSoImportResult> read(List<(Uint8List, ErSoGuide)> pages,
      {void Function(String step, double progress)? onStep}) async {
    final lines = <ErSoImportLine>[];
    final failed = <String>[];
    var title = '';
    var hasCodes = false;
    final spotOf = <Uint8List, (Uint8List, ErSoSpot)>{};
    for (final (pi, (raw, guide)) in pages.indexed) {
      final no = pages.length > 1 ? 'หน้า ${pi + 1} ' : '';
      final base = pi / pages.length, span = 1.0 / pages.length;
      onStep?.call('${no}กำลังหาคอลัมน์และบรรทัด', base * 0.8);
      final page = await compute(_layout, (raw, guide));
      if (page == null) {
        failed.add('${no}หาตารางในรูปไม่พบ');
        continue;
      }
      if (title.isEmpty) {
        try {
          final t = await ErAi.vision(
              'Top of a hospital order sheet. Reply with only the sheet title, '
              'copied exactly.',
              page.head,
              maxTokens: 60);
          final v = t.replaceAll('`', '').trim().split('\n').first;
          // โมเดลตอบเป็นประโยคอธิบาย = ไม่ใช่ชื่อใบ
          if (v.length <= 90 && !v.startsWith('The ')) title = v;
        } catch (_) {}
      }
      final total =
          page.columns.fold<int>(0, (a, c) => a + c.strips.length + 1);
      var done = 0;
      for (final c in page.columns) {
        final name = c.oneDay ? 'One Day' : 'Continuation';
        void tick() {
          done++;
          onStep?.call(
              '${no}กำลังอ่าน $name', (base + span * done / total) * 0.8);
        }

        final codes = await _readCodes(c.withMargin);
        tick();
        if (codes == null) {
          failed.add('$no$name: อ่านรหัสหมวดไม่สำเร็จ');
        }
        final visual = <_Visual>[];
        for (final (i, st) in c.strips.indexed) {
          final show = c.shows[i];
          spotOf[show] = (raw, c.spots[i]);
          final cut = c.cut[i];
          final v = await _readStrip(st);
          tick();
          if (v == null) {
            failed.add('$no$name: อ่านบรรทัดที่ ${i + 1} ไม่สำเร็จ');
            visual.add(_Visual('', show, broken: true, cut: cut));
          } else {
            for (final t in v) {
              visual.add(_Visual(_clean(t), show, cut: cut));
            }
          }
        }
        final merged = _merge(codes ?? const [], visual, c.oneDay);
        hasCodes = hasCodes || merged.any((l) => l.cats.isNotEmpty);
        lines.addAll(merged);
      }
    }
    await _analyze(lines, failed, onStep);
    for (final l in lines) {
      final hits = [
        for (final s in l.strips)
          if (spotOf[s] case final h?) h
      ];
      l.page = hits.isEmpty ? pages.first.$1 : hits.first.$1;
      l.spots = [for (final h in hits) h.$2];
    }
    onStep?.call('เสร็จแล้ว', 1.0);
    return ErSoImportResult(title, lines, hasCodes, failed);
  }

  // ---------- จัดหน้า (รันใน isolate) ----------

  static _Page? _layout((Uint8List, ErSoGuide) arg) {
    final (raw, gd) = arg;
    final d = img.decodeImage(raw);
    if (d == null) return null;
    final im = d.width > 2000 ? img.copyResize(d, width: 2000) : d;
    final w = im.width, h = im.height;
    final g = _gray(im);
    final top = (gd.top * h).round(), bottom = (gd.bottom * h).round();
    final pick = [
      ((gd.left * w).round(), (gd.mid * w).round()),
      ((gd.mid * w).round(), (gd.right * w).round()),
    ];
    final out = <_Column>[];
    for (final (ci, (x0, x1)) in pick.indexed) {
      // เผื่อทางซ้ายให้เห็นรหัสลายมือที่เขียนนอกคอลัมน์
      final mx = (x0 - w * 0.07).round().clamp(0, w);
      final body =
          img.copyCrop(im, x: x0, y: top, width: x1 - x0, height: bottom - top);
      final wide =
          img.copyCrop(im, x: mx, y: top, width: x1 - mx, height: bottom - top);
      final rows = _rows(g, w, x0, x1, top, bottom);
      // ท้ายบรรทัดจริงของแต่ละแถว: เส้นกรอบที่ผู้ใช้วางอาจตัดข้อความ
      final ends = [for (final (a, b) in rows) _lineEnd(g, w, x1, a, b)];
      final starts = [for (final (a, b) in rows) _lineStart(g, w, x0, a, b)];
      Uint8List strip(int a0, int a1, int y0, int y1) {
        final t = (y0 - 8).clamp(0, h - 1);
        return Uint8List.fromList(img.encodeJpg(
            img.copyCrop(im,
                x: a0,
                y: t,
                width: a1 - a0,
                height: (y1 - y0 + 16).clamp(1, h - t)),
            quality: 85));
      }

      out.add(_Column(
        Uint8List.fromList(img.encodeJpg(body, quality: 85)),
        Uint8List.fromList(img.encodeJpg(wide, quality: 85)),
        [
          for (final (i, (a, b)) in rows.indexed)
            strip(starts[i].$1, ends[i].$1, a, b)
        ],
        [for (final (i, (a, b)) in rows.indexed) strip(mx, ends[i].$1, a, b)],
        [for (final (i, e) in ends.indexed) e.$2 || starts[i].$2],
        [
          for (final (i, (a, b)) in rows.indexed)
            ErSoSpot(starts[i].$1 / w, a / h, ends[i].$1 / w, b / h)
        ],
        ci == 0,
      ));
    }
    // ชื่อใบอยู่เหนือตาราง: ตัดแค่ช่วงใกล้ขอบบน ไม่เอาพื้นโต๊ะหรือขอบกระดาษ
    final headFrom = (top - (h * 0.09).round()).clamp(0, h - 1);
    final head = img.copyCrop(im,
        x: 0,
        y: headFrom,
        width: w,
        height: (top + (h * 0.02).round() - headFrom).clamp(1, h - headFrom));
    return _Page(Uint8List.fromList(img.encodeJpg(head, quality: 85)), out);
  }

  /// หาเส้นตารางแนวตั้ง: แบ่งความสูงเป็นช่วง แล้วต่อจุดเข้มข้ามช่วงเป็นสาย
  /// สายขยับข้ามแถบได้ จึงตามเส้นเอียงได้ · ข้อความต่อกันเป็นสายยาวไม่ได้ จึงไม่เกิดเส้นหลอก
  /// คืน (ตำแหน่ง x ของแต่ละเส้น, ขอบบนตาราง, ขอบล่างตาราง)
  static (List<int>, int, int)? _tableLines(Uint8List g, int w, int h) {
    const bin = 8, bands = 60;
    final bins = w ~/ bin + 1;
    final bandH = h ~/ bands;
    // เส้นตารางบางใบจาง: วัดเทียบพื้นกระดาษของรูปนี้
    var paper = 0, seen = 0;
    for (var i = 0; i < g.length; i += 37) {
      paper += g[i];
      seen++;
    }
    final dark = (paper / seen * 0.82).round().clamp(150, 205);
    // len = ความยาวสาย · from = ช่วงเริ่ม · sum = ผลรวมแถบ (ไว้หาค่าเฉลี่ย x)
    var len = List<int>.filled(bins, 0);
    var from = List<int>.filled(bins, 0);
    var sum = List<int>.filled(bins, 0);
    final chains = <(int, int, int, int)>[]; // len, from, to, meanBin
    for (var b = 0; b < bands; b++) {
      final cnt = List<int>.filled(bins, 0);
      for (var y = b * bandH; y < (b + 1) * bandH; y++) {
        for (var x = 0; x < w; x++) {
          if (g[y * w + x] < dark) cnt[x ~/ bin]++;
        }
      }
      final nl = List<int>.filled(bins, 0);
      final nf = List<int>.filled(bins, 0);
      final ns = List<int>.filled(bins, 0);
      for (var i = 0; i < bins; i++) {
        final v = cnt[i] + (i + 1 < bins ? cnt[i + 1] : 0);
        if (v < bandH * 0.45) continue;
        var best = -1;
        for (var k = i - 2; k <= i + 2; k++) {
          if (k >= 0 && k < bins && (best < 0 || len[k] > len[best])) best = k;
        }
        final prev = best >= 0 ? len[best] : 0;
        nl[i] = prev + 1;
        nf[i] = prev > 0 ? from[best] : b;
        ns[i] = (prev > 0 ? sum[best] : 0) + i;
      }
      for (var i = 0; i < bins; i++) {
        if (len[i] >= bands * 0.3) {
          chains.add((len[i], from[i], b - 1, sum[i] ~/ len[i]));
        }
      }
      len = nl;
      from = nf;
      sum = ns;
    }
    for (var i = 0; i < bins; i++) {
      if (len[i] >= bands * 0.3) {
        chains.add((len[i], from[i], bands - 1, sum[i] ~/ len[i]));
      }
    }
    if (chains.isEmpty) return null;
    chains.sort((a, c) => c.$1.compareTo(a.$1));
    final kept = <(int, int, int, int)>[];
    for (final c in chains) {
      if (kept.every((k) => (k.$4 - c.$4).abs() * bin > w * 0.02)) kept.add(c);
    }
    // เส้นตารางยาวใกล้เคียงกัน · สายจุดวงกลมหน้าบรรทัดสั้นกว่ามาก
    final real = [
      for (final k in kept)
        if (k.$1 >= kept.first.$1 * 0.72) k
    ];
    final xs = [for (final k in real) k.$4 * bin + bin]..sort();
    final ts = [for (final k in real) k.$2]..sort();
    final es = [for (final k in real) k.$3]..sort();
    // เส้นเอียงเริ่มไม่เท่ากัน: ใช้จุดเริ่มต่ำสุดที่ไม่ห่างจากค่ากลาง ชื่อใบจะได้ไม่ติดมา
    // ห่างมาก = เส้นขาดเพราะลายมือทับ ไม่ใช่ขอบบนจริง
    final mid = ts[ts.length ~/ 2];
    final top = ts.lastWhere((t) => t <= mid + 2) * bandH;
    final bottom = (es[es.length ~/ 2] + 1) * bandH;
    return (xs, top, bottom);
  }

  /// ท้ายบรรทัดจริง: ถ้าข้อความเลยเส้นกรอบ ขยายไปจนเจอช่องว่างหรือเส้นตาราง
  /// คืน (ขอบขวา, ยังตัดอยู่) · ขยายเกินเพดานแล้วยังไม่จบ = เตือนให้คนเทียบรูป
  static (int, bool) _lineEnd(Uint8List g, int w, int x1, int a, int b) {
    final h = b - a;
    if (h <= 0) return (x1, false);
    int ink(int x) {
      var n = 0;
      for (var y = a; y < b; y++) {
        if (g[y * w + x] < 140) n++;
      }
      return n;
    }

    // เส้นตารางต้องยาวเกินแถวนี้ขึ้นลง ไม่อย่างนั้นก้านตัวเลขอย่าง "3" จะถูกนับเป็นเส้น
    final rows = g.length ~/ w;
    bool isLine(int x) {
      final y0 = (a - h).clamp(0, rows - 1), y1 = (b + h).clamp(0, rows - 1);
      var n = 0;
      for (var y = y0; y < y1; y++) {
        for (var d = -2; d <= 2; d++) {
          if (x + d >= 0 && x + d < w && g[y * w + x + d] < 140) {
            n++;
            break;
          }
        }
      }
      return n >= (y1 - y0) * 0.8;
    }

    final limit = (x1 + w * 0.10).round().clamp(x1, w);
    var x = x1;
    var blank = 0;
    // ถอยเข้ามาหน่อยก่อน: ถ้าเส้นกรอบอยู่ในช่องว่างอยู่แล้วจะหยุดทันที
    while (x < limit) {
      final n = ink(x);
      // เส้นตาราง = เข้มเกือบเต็มความสูง จบคอลัมน์
      if (n >= h * 0.7 && isLine(x)) return (x, false);
      blank = n == 0 ? blank + 1 : 0;
      if (blank >= (w * 0.008).round().clamp(5, 40)) {
        return ((x - blank + 3).clamp(x1, w), false);
      }
      x++;
    }
    return (limit, true);
  }

  /// ต้นบรรทัดจริง: กรอบซ้ายทับตัวหนังสือ (เครื่องหมาย > หรือเลขหลักแรกหาย) ขยายไปซ้ายจนเจอช่องว่าง
  /// คืน (ขอบซ้าย, ยังตัดอยู่)
  static (int, bool) _lineStart(Uint8List g, int w, int x0, int a, int b) {
    final h = b - a;
    if (h <= 0) return (x0, false);
    int ink(int x) {
      var n = 0;
      for (var y = a; y < b; y++) {
        if (g[y * w + x] < 140) n++;
      }
      return n;
    }

    final limit = (x0 - w * 0.06).round().clamp(0, x0);
    final gap = (w * 0.006).round().clamp(4, 30);
    var x = x0, blank = 0;
    while (x > limit) {
      final n = ink(x);
      // เส้นตารางเข้มเต็มความสูง จบคอลัมน์
      if (n >= h * 0.85) return (x + 2, false);
      blank = n == 0 ? blank + 1 : 0;
      if (blank >= gap) return (x + blank - 2, false);
      x--;
    }
    return (limit, true);
  }

  /// แบ่งบรรทัดจากจำนวนจุดเข้มต่อแถว · ไม่นับขอบซ้ายขวา (เส้นตารางเอียงทำบรรทัดติดกัน)
  static List<(int, int)> _rows(
      Uint8List g, int w, int x0, int x1, int top, int bottom) {
    final cw = x1 - x0;
    final m = (cw * 0.045).round();
    final th = (cw * 0.004).clamp(2, 1000);
    List<(int, int)> scan(int from, int to, int dark, int left, int minH) {
      final out = <(int, int)>[];
      int? s;
      for (var y = from; y < to; y++) {
        var n = 0;
        for (var x = left; x < x1 - m; x++) {
          if (g[y * w + x] < dark) n++;
        }
        // เส้นตารางแนวนอน = ไม่ใช่ข้อความ
        if (n > cw * 0.6) n = 0;
        if (n > th) {
          s ??= y;
        } else if (s != null) {
          if (y - s >= minH) out.add((s, y));
          s = null;
        }
      }
      if (s != null && to - s >= minH) out.add((s, to));
      return out;
    }

    final found = scan(top, bottom, 140, x0 + m, 14);
    // ตัวพิมพ์จางอย่าง "3ช.ม." หลุดจากรอบแรก: หาเพิ่มเฉพาะในช่องว่างระหว่างแถว
    // เทียบกับพื้นกระดาษของรูปนี้ และไม่นับขอบซ้าย (ข้อความล้นจากคอลัมน์ข้าง ๆ)
    var sum = 0, cnt = 0;
    for (var y = top; y < bottom; y += 3) {
      for (var x = x0 + m; x < x1 - m; x += 3) {
        sum += g[y * w + x];
        cnt++;
      }
    }
    final faint = cnt == 0 ? 140 : (sum / cnt * 0.78).round().clamp(140, 190);
    final inner = x0 + (cw * 0.12).round();
    final extra = <(int, int)>[];
    var from = top;
    for (final r in [...found, (bottom, bottom)]) {
      if (r.$1 - from >= 12) {
        extra.addAll(scan(from + 2, r.$1 - 2, faint, inner, 10));
      }
      from = r.$2;
    }
    final out = [...found, ...extra]..sort((a, b) => a.$1.compareTo(b.$1));
    final merged = <(int, int)>[];
    for (final r in out) {
      if (merged.isNotEmpty && r.$1 - merged.last.$2 < 6) {
        merged[merged.length - 1] = (merged.last.$1, r.$2);
      } else {
        merged.add(r);
      }
    }
    return merged;
  }

  // ---------- อ่าน ----------

  static dynamic _json(String t) {
    final c = t
        .replaceAll(r'$\ge$', '≥')
        .replaceAll(r'$\geq$', '≥')
        .replaceAll(r'$\le$', '≤')
        .replaceAll(r'$\rightarrow$', '→')
        .replaceAll(r'$\to$', '→')
        .replaceAll(RegExp(r'\\(?!["\\/bfnrtu])'), '');
    final m = RegExp(r'\{[\s\S]*\}').firstMatch(c);
    return m == null ? null : jsonDecode(m.group(0)!);
  }

  /// เรียกซ้ำเมื่อเซิร์ฟเวอร์ล้ม (พบ 502 / timeout เป็นระยะ)
  static Future<T?> _retry<T>(Future<T?> Function() go) async {
    for (var i = 0; i < 3; i++) {
      try {
        final r = await go();
        if (r != null) return r;
      } catch (_) {}
      await Future<void>.delayed(Duration(seconds: 2 + i * 2));
    }
    return null;
  }

  static Future<List<(String, String)>?> _readCodes(Uint8List col) =>
      _retry(() async {
        final t = await ErAi.vision(
            'Column of a printed hospital order sheet. In the LEFT margin of many '
            'orders staff handwrote a blue-pen category code: one of L, X, M, ห, '
            'oth, or a combination such as oth+M or ห+oth. For every printed '
            'order return the code exactly as handwritten and the first words of '
            'the order. code "" when none, "?" if unreadable. '
            'Reply ONLY JSON: {"lines":[{"code":"","text":""}]}',
            col,
            maxTokens: 1500);
        final o = _json(t);
        if (o is! Map || o['lines'] is! List) return null;
        return [
          for (final x in o['lines'] as List)
            if (x is Map)
              ((x['code'] ?? '').toString(), (x['text'] ?? '').toString())
        ];
      });

  static Future<List<String>?> _readStrip(Uint8List st) => _retry(() async {
        final t = await ErAi.vision(
            'Cropped from a printed hospital order sheet; may hold one or several '
            'printed lines. Copy every printed line exactly; never correct or '
            'guess; keep numbers and units exact; write dotted blanks as ___ ; '
            'use [?] for unreadable; ignore check marks, circles and handwriting. '
            'Reply ONLY JSON: {"lines":[""]}',
            st,
            maxTokens: 400);
        final o = _json(t);
        if (o is! Map || o['lines'] is! List) return null;
        return [
          for (final x in o['lines'] as List)
            if (x.toString().trim().isNotEmpty) x.toString().trim()
        ];
      });

  // ---------- แปลงเป็นฟอร์ม ----------

  static const _formPrompt =
      'Break each line of a hospital standing order into the separate tasks a nurse must carry out. '
      'Input: JSON list of lines. Output for EACH line, same order, {"tasks":[task,...]}. '
      'task={"kind":"med|proc|lab|xray|monitor|nursing|notify|other",'
      '"title":short name using words from the line,'
      '"trigger":condition that must be true before doing it copied from the line or "",'
      '"does":what to do copied from the line,'
      '"repeat":timing or frequency copied from the line or "",'
      '"limits":[target or notify thresholds copied from the line],'
      '"doctorFields":[{"label","type":"num|text|choice|time","unit","opts":[]}] '
      'ONE for each ___ or written alternatives (a/b) belonging to this task, nothing else}. '
      'A line with a drug AND a monitoring target is several tasks. '
      'Starting, titrating or adjusting a drug (titrate, เพิ่ม, ลด, ทีละ, ml/hr) always belongs to that drug\'s med task, even when it names a BP or MAP goal; '
      'the monitor task holds only what to measure and its target. '
      'Written alternatives (a/b) stay in does and become one choice field with those opts. '
      'does must always name the drug or thing it acts on, never only a route or rate. '
      'A blank is ONE field: label=the word before it, unit=the word after it; never use a unit as a label. '
      'A sliding scale is one monitor task plus one conditional med task per range. '
      'A plain lab, x-ray or drug line is one task. '
      'Copy all numbers and units EXACTLY as written; never invent or change one. '
      '___ followed by a unit means num with that unit. A เวลา or วันเวลา blank means time. '
      'Reply ONLY JSON {"items":[...]}';

  static const _catByKind = {
    'med': 'Medication',
    'proc': 'Procedure',
    'lab': 'Lab',
    'xray': 'X-ray',
  };

  /// ช่องที่พยาบาลบันทึก มาจากกฎตามชนิดงาน ไม่ให้ AI คิดเอง · เวลาที่ทำอยู่ในหน้ารับคำสั่งแล้ว
  static List<ErSoField> _nurseFor(
      String kind, String text, List<String> limits) {
    final all = '$text ${limits.join(' ')}';
    switch (kind) {
      case 'med':
        return RegExp(r'drip|titrate|ml/hr', caseSensitive: false)
                .hasMatch(text)
            ? [ErSoField('อัตราที่ให้', 'num', 'ml/hr', const [])]
            : [];
      case 'notify':
        return [ErSoField('เวลาที่แจ้งแพทย์', 'time', '', const [])];
      case 'monitor':
        if (RegExp(r'v/s|vital', caseSensitive: false).hasMatch(all)) {
          return [
            ErSoField('สัญญาณชีพ', 'vs', '', const []),
            if (RegExp(r'i/o', caseSensitive: false).hasMatch(all))
              ErSoField('I/O', 'num', 'ml', const []),
            if (RegExp(r'n/s', caseSensitive: false).hasMatch(all))
              ErSoField('N/S', 'text', '', const []),
          ];
        }
        final out = <ErSoField>[];
        for (final (re, label, unit) in const [
          (r'\bSBP\b', 'SBP', 'mmHg'),
          (r'\bDBP\b', 'DBP', 'mmHg'),
          (r'\bBP\b', 'BP', 'mmHg'),
          (r'\bMAP\b', 'MAP', 'mmHg'),
          (r'\bDTX', 'DTX', 'mg/dl'),
          (r'\bSOS\b', 'SOS score', ''),
          (r'\bGCS\b', 'GCS', ''),
          (r'urine', 'Urine output', 'ml'),
          (r'\bEKG\b', 'EKG', ''),
        ]) {
          if (RegExp(re, caseSensitive: false).hasMatch(all)) {
            out.add(ErSoField(
                label,
                unit.isEmpty && label != 'EKG'
                    ? 'num'
                    : label == 'EKG'
                        ? 'text'
                        : 'num',
                unit,
                const []));
          }
        }
        return out.isEmpty
            ? [ErSoField('ผลที่ติดตาม', 'text', '', const [])]
            : out;
      default:
        return [];
    }
  }

  /// เลขทุกตัวในบรรทัดต้องอยู่ครบในงานที่แตก และห้ามมีเลขที่บรรทัดไม่มี
  static String? _numberIssue(String line, Iterable<String> texts) {
    final all = texts.join(' ');
    final a = _nums(line), b = _nums(all);
    if (b.difference(a).isNotEmpty) return 'แตกงานแล้วมีตัวเลขที่ไม่อยู่ในใบ';
    if (a.difference(b).isNotEmpty) return 'แตกงานแล้วตัวเลขไม่ครบ';
    if (_signs(line).difference(_signs(all)).isNotEmpty) {
      return 'แตกงานแล้วเครื่องหมาย < > หาย';
    }
    // ช่วงเลข 3-5 ต้องยังเป็นช่วง ไม่ใช่เหลือ 3 5
    if (_ranges(line).difference(_ranges(all)).isNotEmpty) {
      return 'แตกงานแล้วช่วงตัวเลขเปลี่ยน';
    }
    return null;
  }

  static Future<List?> _askTasks(List<String> texts) => _retry<List>(() async {
        final t = await ErAi.chat([
          {
            'role': 'user',
            'content': '$_formPrompt\n\nLINES:\n${jsonEncode(texts)}'
          }
        ], temperature: 0.0, maxTokens: 5000);
        final o = _json(t);
        if (o is! Map || o['items'] is! List) return null;
        final r = o['items'] as List;
        return r.length == texts.length ? r : null;
      });

  /// แปลงทีละช่วง: 1 บรรทัดเป็นหลายงาน · ผิดเงื่อนไขตัวเลข = คงบรรทัดเดิมไว้แล้วเตือน
  static Future<void> _analyze(List<ErSoImportLine> lines, List<String> failed,
      void Function(String step, double progress)? onStep) async {
    const size = 10;
    final out = <ErSoImportLine>[];
    for (var at = 0; at < lines.length; at += size) {
      onStep?.call('กำลังแปลงเป็นฟอร์ม', 0.8 + 0.2 * at / lines.length);
      final part = lines.sublist(
          at, at + size > lines.length ? lines.length : at + size);
      // ทั้งช่วงล้ม (เซิร์ฟเวอร์ล่มหรือจำนวนไม่ตรง): ถามทีละบรรทัด ไม่ให้เสียทั้งช่วง
      final items = await _askTasks([for (final l in part) l.text]) ??
          [
            for (final l in part)
              (await _askTasks([l.text]))?.first ?? const <String, dynamic>{}
          ];
      for (final (i, l) in part.indexed) {
        final x = items[i];
        List<Map> parse(dynamic x) => [
              if (x is Map && x['tasks'] is List)
                for (final k in x['tasks'] as List)
                  if (k is Map &&
                      (k['does'] ?? '').toString().trim().isNotEmpty)
                    k
            ];
        var tasks = parse(x);
        if (tasks.isEmpty) {
          l.why.add('แปลงเป็นฟอร์มไม่สำเร็จ');
          out.add(l);
          continue;
        }
        String str(dynamic v) => (v ?? '').toString().trim();
        List<String> lims(Map k) => [
              if (k['limits'] is List)
                for (final v in k['limits'] as List) v.toString().trim()
            ];
        String textOf(Map k) {
          final does = str(k['does']),
              trig = str(k['trigger']),
              rep = str(k['repeat']);
          return [
            if (trig.isNotEmpty) trig,
            does,
            if (rep.isNotEmpty && !does.contains(rep)) rep,
            for (final m in lims(k))
              if (!does.contains(m)) m,
          ].join(' ').trim();
        }

        var bad = _numberIssue(l.text, tasks.map(textOf));
        if (bad != null) {
          // เลขไม่ครบ: ถามบรรทัดนี้เดี่ยว ๆ อีกครั้ง ก่อนยอมคงบรรทัดเดิม
          final again = await _askTasks([l.text]);
          if (again != null) {
            final t2 = parse(again.first);
            if (t2.isNotEmpty && _numberIssue(l.text, t2.map(textOf)) == null) {
              tasks = t2;
              bad = null;
            }
          }
        }
        if (bad == null &&
            tasks
                .every((k) => const {'lab', 'xray'}.contains(str(k['kind'])))) {
          // Lab / X-ray หลายตัวในบรรทัดเดียว = ส่งพร้อมกัน ไม่แตก
          l.doctor = l.text.contains('___') || RegExp(r'\w/\w').hasMatch(l.text)
              ? [for (final k in tasks) ..._fields(k['doctorFields'], l.text)]
              : [];
          final seen = <String>{};
          l.doctor.retainWhere((f) => seen.add(f.label));
          if (l.cats.isEmpty) l.cats = {_catByKind[str(tasks.first['kind'])]!};
          if (RegExp(r'\bDTX', caseSensitive: false).hasMatch(l.text)) {
            l.doctor = [];
            l.nurse = [ErSoField('DTX', 'num', 'mg/dl', const [])];
          }
          out.add(l);
          continue;
        }
        if (bad != null) {
          // ไม่เชื่อผลแตกงาน: คงข้อความเดิมจากรูปไว้ ให้คนดู
          l.why.add(bad);
          out.add(l);
          continue;
        }
        final hand = l.cats;
        for (final k in tasks) {
          final kind = str(k['kind']);
          final text = textOf(k);
          final fromKind = _catByKind[kind] ?? 'Other';
          final why = [
            // คำเตือนเรื่องยาไม่เกี่ยวกับงานอื่นที่แตกออกมาจากบรรทัดเดียวกัน
            for (final w in l.why)
              if (kind == 'med' ||
                  !(w.startsWith('ยา') || w.startsWith('เลขต่อ')))
                w
          ];
          // รหัสที่เขียนกำกับคือความจริงของบรรทัด: หมวดของงานต้องอยู่ในนั้น
          if (tasks.length > 1 && hand.isNotEmpty && !hand.contains(fromKind)) {
            why.add('หมวดของงานไม่ตรงรหัสที่เขียนกำกับ');
          }
          final t = ErSoImportLine(
              text,
              tasks.length == 1 && hand.isNotEmpty ? {...hand} : {fromKind},
              l.oneDay,
              l.strips,
              why);
          final title = str(k['title']);
          t.name = title.isEmpty ? '' : title;
          t.doctor = l.text.contains('___') || RegExp(r'\w/\w').hasMatch(l.text)
              ? _fields(k['doctorFields'], l.text)
              : [];
          t.doctor = _withChoice(t.doctor, text);
          // Antibiotic ในใบเป็นช่องว่างให้แพทย์เขียนชื่อยาเอง
          if (RegExp(r'antibiotic', caseSensitive: false).hasMatch(text)) {
            t.doctor = [
              ErSoField('ชื่อยาและขนาด', 'text', '', const []),
              ...t.doctor,
            ];
            t.why.removeWhere((w) => w.startsWith('ยานี้ยังไม่บอก'));
          }
          t.nurse = _nurseFor(kind, text, lims(k));
          // DTX คือค่าที่พยาบาลเจาะได้ ไม่ใช่ค่าที่แพทย์กรอกตอนสั่ง
          if (RegExp(r'\bDTX', caseSensitive: false).hasMatch(text)) {
            t.doctor = [];
            if (t.nurse.isEmpty) {
              t.nurse = [ErSoField('DTX', 'num', 'mg/dl', const [])];
            }
          }
          out.add(t);
        }
      }
    }
    // ชื่องานซ้ำกันแยกไม่ออก: ใช้ข้อความคำสั่งแทนถ้าสั้นพอ
    final count = <String, int>{};
    for (final t in out) {
      count[t.name] = (count[t.name] ?? 0) + 1;
    }
    for (final t in out) {
      if (t.name.isNotEmpty && count[t.name]! > 1 && t.text.length <= 40) {
        t.name = t.text;
      }
    }
    lines
      ..clear()
      ..addAll(out);
  }

  /// ตัวเลือกที่พิมพ์ในใบ (cannula/mask) ต้องมีช่องเลือกเสมอ ไม่ขึ้นกับว่ารอบนี้ AI ตอบอย่างไร
  /// หน่วยอย่าง ml/hr, mg/dl สั้นเกิน 3 ตัวด้านใดด้านหนึ่ง จึงไม่เข้าเงื่อนไข
  static List<ErSoField> _withChoice(List<ErSoField> fields, String text) {
    final m =
        RegExp(r'(?<![A-Za-z/])([A-Za-z]{3,})/([A-Za-z]{3,})(?![A-Za-z/])')
            .firstMatch(text);
    if (m == null) return fields;
    final a = m.group(1)!, b = m.group(2)!;
    if (fields.any((f) => f.type == 'choice' && f.opts.contains(a))) {
      return fields;
    }
    return [
      ErSoField('เลือก', 'choice', '', [a, b]),
      for (final f in fields)
        ErSoField(f.label.replaceAll('(${m.group(0)})', '').trim(), f.type,
            f.unit, f.opts)
    ];
  }

  static const _unitLabel = {
    'ml': 'ปริมาณ',
    'ml/hr': 'อัตราที่ให้',
    'lpm': 'อัตราออกซิเจน',
    'cm': 'ความยาว',
    'mg': 'ขนาดยา',
  };

  static List<ErSoField> _fields(dynamic raw, String line) {
    if (raw is! List) return [];
    final out = <ErSoField>[];
    final digits = RegExp(r'\d+(\.\d+)?');
    for (final f in raw) {
      if (f is! Map) continue;
      final label = (f['label'] ?? '').toString().trim();
      if (label.isEmpty || !RegExp(r'[^_\s.]').hasMatch(label)) continue;
      // ตัวเลขในชื่อช่องต้องมาจากบรรทัดจริง
      if (digits.allMatches(label).any((m) => !line.contains(m.group(0)!))) {
        continue;
      }
      var type = (f['type'] ?? 'text').toString();
      if (!const {'num', 'text', 'choice', 'time', 'vs'}.contains(type)) {
        type = 'text';
      }
      var unit = (f['unit'] ?? '').toString().trim();
      if (unit.isNotEmpty && !line.contains(unit)) unit = '';
      // โมเดลชอบเอาหน่วยมาเป็นชื่อช่อง
      final low = label.toLowerCase();
      final named = _unitLabel[low];
      if (named != null) {
        out.add(ErSoField(named, 'num', unit.isEmpty ? label : unit, const []));
        continue;
      }
      // ชื่อช่องเป็นแค่วิธีให้ยา เช่น "iv drip": เรียกตามหน่วยแทน
      if (RegExp(r'^(iv |im |sc )?(load|drip|push)$').hasMatch(low) &&
          _unitLabel[unit.toLowerCase()] != null) {
        out.add(
            ErSoField(_unitLabel[unit.toLowerCase()]!, 'num', unit, const []));
        continue;
      }
      if (low == 'no' || low == 'no.') {
        out.add(ErSoField('เบอร์', 'num', unit, const []));
        continue;
      }
      final opts = [
        if (f['opts'] is List)
          for (final o in f['opts'] as List)
            if (line.contains(o.toString())) o.toString()
      ];
      if (type == 'choice' && opts.length < 2) type = 'text';
      out.add(ErSoField(label, type, unit, opts));
    }
    return out;
  }

  // ---------- รวมผล 2 รอบ ----------

  static RegExp get _head => RegExp(
      r'^(progress\w*|orders?( for)?|order one|one da\w*|continu\w*|medication|med|date|time|hour)\b',
      caseSensitive: false);

  /// ตัดจุดวงกลมหน้าบรรทัดที่โมเดลอ่านเป็นตัวอักษร
  static String _clean(String t) => t
      .replaceFirst(RegExp(r'^\s*(?:[Oo0○◯•●]|\|)\s+'), '')
      // จุดไข่ปลา = ช่องให้กรอก เหมือน ___
      .replaceAll(RegExp(r'(?:\.{3,}|…+)'), '___')
      .trim();

  static bool _isHead(String t) {
    if (RegExp(r'orders?\s+(for\b|one\b)', caseSensitive: false).hasMatch(t) &&
        t.length < 44) {
      return true;
    }
    final s = t.trim();
    return s.isEmpty ||
        RegExp(r'^[_.\s]+$').hasMatch(s) ||
        (_head.hasMatch(s) && s.length < 28);
  }

  static String _key(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s_.,:;()\-*/]+'), '');

  /// จับคู่ 2 รอบอ่านด้วยคู่อักษรต้นข้อความ: อ่านผิดหรือหายบางตัวก็ยังจับได้
  static bool _same(String a, String b) {
    var x = _key(a), y = _key(b);
    if (x.isEmpty || y.isEmpty) return false;
    final n = x.length < y.length ? x.length : y.length;
    x = x.substring(0, n > 24 ? 24 : n);
    y = y.substring(0, n > 24 ? 24 : n);
    if (x == y) return true;
    if (x.length < 2) return false;
    final pool = <String>[
      for (var i = 0; i + 1 < y.length; i++) y.substring(i, i + 2)
    ];
    var hit = 0;
    for (var i = 0; i + 1 < x.length; i++) {
      if (pool.remove(x.substring(i, i + 2))) hit++;
    }
    return 2.0 * hit / (x.length + y.length - 2) >= 0.6;
  }

  /// คำภาษาอังกฤษยาวที่สุดตรงกัน: คำไทยจางหน้าบรรทัดอาจอ่านไม่ออกในรอบเดียว ("เริ่ม Levophed")
  static bool _sameWord(String a, String b) {
    final w = RegExp(r'[A-Za-z]{6,}').allMatches(a).map((m) => m.group(0)!);
    if (w.isEmpty) return false;
    final top = w.reduce((p, q) => q.length > p.length ? q : p);
    return b.toLowerCase().contains(top.toLowerCase());
  }

  static Set<String> _signs(String s) =>
      {for (final m in RegExp(r'[<>≤≥]').allMatches(s)) m.group(0)!};

  static final _range = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)');
  static Set<String> _ranges(String s) =>
      {for (final m in _range.allMatches(s)) '${m.group(1)}-${m.group(2)}'};

  /// เลขในข้อความ (เทียบค่าระหว่าง 2 รอบ)
  static Set<String> _nums(String s) =>
      {for (final m in RegExp(r'\d+(\.\d+)?').allMatches(s)) m.group(0)!};

  static const _catOf = {
    'l': 'Lab',
    'x': 'X-ray',
    'm': 'Medication',
    'ห': 'Procedure',
    'oth': 'Other',
  };

  static Set<String>? _cats(String code) {
    final c = code.trim().toLowerCase();
    if (c.isEmpty || c == '?') return null;
    final out = <String>{};
    for (final p in c.split(RegExp(r'\s*\+\s*'))) {
      final k = _catOf[p];
      if (k == null) return null;
      out.add(k);
    }
    return out;
  }

  static const _cutWhy =
      'ต้นหรือท้ายบรรทัดอาจถูกตัดที่ขอบกรอบ เทียบกับรูปอีกครั้ง';
  static const _noCodeWhy = 'ไม่เจอรหัสหมวดที่เขียนกำกับ เลือกหมวดให้ถูก';
  static const _noStrip = 'ไม่เจอบรรทัดนี้ในรูป เทียบกับใบจริงอีกครั้ง';

  static final _route = RegExp(
      r'\b(iv|im|sc|sl|oral|po|tab|tabs|cap|sublingual|intramuscle|inhale|neb)\b',
      caseSensitive: false);

  static List<ErSoImportLine> _merge(
      List<(String, String)> codes, List<_Visual> visual, bool oneDay) {
    final orders = <(String, String)>[];
    for (final c in codes) {
      if (_isHead(c.$2)) continue;
      // โมเดลอ่านรายการเดิมซ้ำบ้าง
      if (orders.isNotEmpty && _key(orders.last.$2) == _key(c.$2)) continue;
      orders.add(c);
    }
    final vis = [
      for (final v in visual)
        if (v.broken || !_isHead(v.text)) v
    ];
    final out = <ErSoImportLine>[];
    ErSoImportLine make(
        String code, String text, List<Uint8List> st, List<String> why) {
      final cats = _cats(code);
      final w = [...why];
      if (code.trim() == '?') {
        w.add('อ่านรหัสหมวดไม่ออก เลือกหมวดให้ถูก');
      } else if (code.trim().isNotEmpty && cats == null) {
        w.add('รหัสหมวดไม่รู้จัก "${code.trim()}"');
      } else if (code.trim().isEmpty) {
        w.add(_noCodeWhy);
      }
      return ErSoImportLine(text, cats ?? {}, oneDay, st, w);
    }

    var p = 0;
    // บรรทัดต่อ = ของรายการล่าสุดที่จับคู่รูปได้ · รายการที่ไม่พบรูปไม่รับบรรทัดต่อ
    // ไม่อย่างนั้นข้อความของคำสั่งหนึ่งจะไปปนอีกคำสั่ง
    ErSoImportLine? owner;
    void attach(_Visual v) {
      final l = owner;
      if (l == null) {
        // ก่อนคำสั่งแรกที่จับคู่ได้ คำสั้น ๆ คือเศษหัวตารางที่โมเดลเดา ไม่ใช่คำสั่ง
        final letters = v.text.replaceAll(RegExp(r'[_\s.]'), '').length;
        if (orders.isNotEmpty && !v.broken && letters <= 12) return;
        out.add(make('', v.text, [
          if (v.image != null) v.image!
        ], [
          'อาจไม่ใช่คำสั่ง ถ้าเป็นหัวตารางหรือชื่อใบให้ลบออก',
          if (v.cut) _cutWhy
        ]));
        owner = out.last;
        return;
      }
      if (v.cut && !l.why.contains(_cutWhy)) l.why.add(_cutWhy);
      if (v.image != null && !l.strips.contains(v.image)) {
        l.strips.add(v.image!);
      }
      if (v.broken) {
        l.why.add('มีบรรทัดที่อ่านไม่สำเร็จ');
      } else if (!_key(l.text).endsWith(_key(v.text))) {
        // รอบอ่านซ้ำบรรทัดเดิม = ไม่ต่อข้อความ
        // เลขท้ายบรรทัดต่อเลขต้นบรรทัด มักเป็นช่วงเลขที่ขีดกลางตกหาย (3- 5ml/hr)
        if (RegExp(r'\d\s*$').hasMatch(l.text) &&
            RegExp(r'^\s*\d').hasMatch(v.text)) {
          l.why.add('เลขต่อกันข้ามบรรทัด อาจเป็นช่วงเลข เช่น 3-5 เทียบกับรูป');
        }
        l.text = '${l.text} ${v.text}'.trim();
      }
    }

    for (final (code, first) in orders) {
      var hit = -1;
      // มองหาแค่ช่วงใกล้ ๆ กันไปจับข้อความคล้ายกันที่อยู่ไกล
      for (var j = p; j < vis.length && j < p + 10; j++) {
        if (!vis[j].broken && _same(first, vis[j].text)) {
          hit = j;
          break;
        }
      }
      for (var j = p; hit < 0 && j < vis.length && j < p + 10; j++) {
        if (!vis[j].broken && _sameWord(first, vis[j].text)) hit = j;
      }
      if (hit < 0) {
        // รอบคอลัมน์เห็น แต่รอบแถบไม่เห็น = บรรทัดอาจหาย
        out.add(make(code, first, [], [_noStrip]));
        continue;
      }
      for (var j = p; j < hit; j++) {
        attach(vis[j]);
      }
      final v = vis[hit];
      final diff = _nums(first).difference(_nums(v.text));
      out.add(make(code, v.text, [
        if (v.image != null) v.image!
      ], [
        if (diff.isNotEmpty ||
            _signs(first).difference(_signs(v.text)).isNotEmpty)
          'ไม่แน่ใจตัวเลข อีกรอบอ่านว่า "$first"',
        if (v.cut) _cutWhy,
      ]));
      owner = out.last;
      p = hit + 1;
    }
    for (var j = p; j < vis.length; j++) {
      attach(vis[j]);
    }
    // ใบนี้ไม่ได้เขียนรหัสกำกับเลย: ไม่ต้องเตือนทุกแถว ให้ระบบเลือกหมวดจากเนื้อหา
    if (out.where((l) => l.cats.isNotEmpty).length < out.length * 0.3) {
      for (final l in out) {
        l.why.remove(_noCodeWhy);
      }
    }
    for (final l in out) {
      // ตัวพิมพ์ prn มักถูกอ่านเป็น pm ทุกรอบ
      l.text = l.text.replaceAll(RegExp(r'\bpm\b(?= *(q|for)\b)'), 'prn');
      // ขึ้นต้นด้วยค่าน้ำตาลลอย ๆ = เครื่องหมาย < > หรือเลขหน้าหาย ความหมายเปลี่ยนได้
      if (RegExp(r'^\s*-?\d[\d.]*\s*mg/dl').hasMatch(l.text)) {
        l.why.add('ไม่เห็นเครื่องหมาย < หรือ > หน้าตัวเลข เทียบกับรูปอีกครั้ง');
      }
      // AI เดาเป็นอักษรเขมรหรือลาวเมื่ออ่านไม่ออก
      if (RegExp(r'[\u0E80-\u0EFF\u1780-\u17FF]').hasMatch(l.text)) {
        l.why.add('มีคำที่อ่านไม่ออก ดูจากรูปแล้วพิมพ์แก้');
      }
      if (l.text.contains('[?]'))
        l.why.add('มีคำที่อ่านไม่ออก ดูจากรูปแล้วพิมพ์แทน [?]');
      // ยาหลายบรรทัดต่อกันผิดหรือตกคำได้ง่าย และโมเดลไม่บอกเอง: ให้คนเทียบตัวเลขเสมอ
      if (l.cats.contains('Medication') && l.strips.length > 1) {
        l.why.add('ยาหลายบรรทัด เทียบตัวเลขกับรูปให้ครบทุกบรรทัด');
      }
      if (l.cats.contains('Medication') && !_route.hasMatch(l.text)) {
        l.why.add('ยานี้ยังไม่บอกวิธีให้ เช่น iv หรือ oral');
      }
    }
    return out;
  }
}

class _Visual {
  _Visual(this.text, this.image, {this.broken = false, this.cut = false});
  final bool cut;
  final String text;
  final Uint8List? image;
  final bool broken;
}
