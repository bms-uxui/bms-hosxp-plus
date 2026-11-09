/// ดูเอกสาร PDF ของผล Lab (เช่น ใบรายงานผลเพาะเชื้อ) เต็มจอ: เลื่อนหน้า หนีบซูม
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

/// คัดไฟล์ PDF จาก assets ไปไว้ในเครื่อง (ใช้ทั้งดาวน์โหลดและแชร์)
/// docs = true: โฟลเดอร์เอกสารของแอป (ดาวน์โหลดเก็บไว้) · false: โฟลเดอร์ชั่วคราว (แชร์)
Future<File> erPdfToFile(String asset, String name, {bool docs = false}) async {
  final dir = docs
      ? await getApplicationDocumentsDirectory()
      : await getTemporaryDirectory();
  final f = File('${dir.path}/$name.pdf');
  final data = await rootBundle.load(asset);
  await f.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return f;
}

/// เปิด PDF จาก bytes ของ rootBundle (ไม่ใช้ openAsset ที่อ่านจาก bundle ฝั่ง native)
/// ไฟล์ที่แก้แล้วจึงขึ้นทันทีหลัง hot reload และตรงกับไฟล์ที่ดาวน์โหลด/แชร์
Future<PdfDocument> _erPdfOpen(String asset) async =>
    PdfDocument.openData((await rootBundle.load(asset)).buffer.asUint8List());

/// แชร์ไฟล์ PDF ผ่านแผ่นแชร์ของระบบ (AirDrop, Line, อีเมล, บันทึกลงไฟล์)
Future<void> erPdfShare(String asset, String name, {Rect? origin}) async {
  final f = await erPdfToFile(asset, name);
  await Share.shareXFiles([XFile(f.path, mimeType: 'application/pdf')],
      subject: name, sharePositionOrigin: origin);
}

class ErPdfView extends StatefulWidget {
  const ErPdfView({super.key, required this.asset});

  /// ไฟล์ PDF ใน assets
  final String asset;

  @override
  State<ErPdfView> createState() => _ErPdfViewState();
}

class _ErPdfViewState extends State<ErPdfView> {
  late final PdfControllerPinch _ctl =
      PdfControllerPinch(document: _erPdfOpen(widget.asset));

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  // พื้นเทาอ่อนรอบหน้า (ColoredBox) · backgroundDecoration ของ pdfx = กรอบแต่ละหน้า:
  // ขาว ขอบเทาบาง เงาจาง ๆ ให้เห็นขอบเอกสาร
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xFFF1F3F4),
        child: PdfViewPinch(
          controller: _ctl,
          padding: 16.0,
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDADCE0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x140B1B3F),
                  blurRadius: 6.0,
                  offset: Offset(0, 1)),
            ],
          ),
        ),
      );
}

/// ภาพย่อหน้าแรกของ PDF (ส่วนบนของหน้า) ใช้แทนไอคอนในการ์ดผล Lab แบบเดียวกับภาพย่อผลชนิดรูป
class ErPdfThumb extends StatefulWidget {
  const ErPdfThumb(
      {super.key, required this.asset, this.width = 36.0, this.height = 22.0});
  final String asset;
  final double width, height;

  @override
  State<ErPdfThumb> createState() => _ErPdfThumbState();
}

class _ErPdfThumbState extends State<ErPdfThumb> {
  PdfPageImage? _img;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await _erPdfOpen(widget.asset);
    final page = await doc.getPage(1);
    final img = await page.render(
        // คมพอสำหรับจอ 3x แม้ภาพย่อเล็ก
        width: page.width * 1.5,
        height: page.height * 1.5,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF');
    await page.close();
    await doc.close();
    if (mounted) setState(() => _img = img);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        height: widget.height,
        child: _img == null
            ? const ColoredBox(color: Color(0xFFF1F3F4))
            : Image.memory(_img!.bytes,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium),
      );
}
