/// ตารางพื้นฐานรายแท็บของหน้ารายละเอียดผู้ป่วย ER
///
/// แสดงข้อมูลจาก `erTablesFor(hn, tab)` (er_case_tables.dart) เป็นตาราง
/// หัวคอลัมน์ + แถว เส้นขอบบาง เซลล์ผิดปกติเป็นตัวแดงหนา
/// ตารางกว้างเกินจะเลื่อนแนวนอนได้ — วางใน scroll view แนวตั้งของหน้าแม่
library;

import 'package:flutter/material.dart';

import '../er_shared/er_case_tables.dart';

export '../er_shared/er_case_tables.dart' show ErTab, ErTable, erTabLabel;

const _kBorder = Color(0xFFE3E6EA);
const _kHeaderBg = Color(0xFFF1F3F4);
const _kText = Color(0xFF202124);
const _kMuted = Color(0xFF5F6368);
const _kAlert = Color(0xFFD93025);
const _kFont = 'GoogleSans';
const _kFontFallback = ['NotoSansThai'];

/// คำที่กำลังอ้างอิง (จากผลวิเคราะห์ AI) · แถวที่มีคำตรงจะไฮไลต์ฟ้าและเลื่อนมาให้เห็น
/// ค่าว่าง = ไม่ไฮไลต์
final ValueNotifier<Set<String>> erTableHighlight = ValueNotifier(const {});

/// แยกข้อความเป็นคำสำหรับเทียบ: ชื่อ (มีตัวอักษร ≥ 2) และค่าตัวเลข (≥ 2 ตัว เช่น 128, 88/56)
Set<String> erHighlightTokens(String s) => {
      for (final m
          in RegExp(r'[A-Za-z][A-Za-z0-9₂+\-]*|\d+(?:[./]\d+)?').allMatches(s))
        if (m.group(0)!.length >= 2) m.group(0)!.toLowerCase()
    };

class ErDetailTable extends StatelessWidget {
  const ErDetailTable({super.key, required this.hn, required this.tab});

  final String hn;
  final ErTab tab;

  @override
  Widget build(BuildContext context) {
    final tables = erTablesFor(hn, tab);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tables.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          ValueListenableBuilder<Set<String>>(
            valueListenable: erTableHighlight,
            builder: (_, hl, __) => _TableCard(table: tables[i], hl: hl),
          ),
        ],
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, this.hl = const {}});

  final ErTable table;
  final Set<String> hl;

  /// แถวที่ตรงกับคำอ้างอิง: ชื่อในเซลล์ตรงคำ หรือค่าในเซลล์ตรงตัวเลขทั้งเซลล์
  bool _hit(List<String> row) {
    if (hl.isEmpty) return false;
    for (final cell in row) {
      final t = erHighlightTokens(cell);
      if (t.any(hl.contains)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    table.title,
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontFamilyFallback: _kFontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                  ),
                ),
                Text(
                  '${table.rows.length} รายการ',
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontFamilyFallback: _kFontFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
          if (table.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 4, 14, 16),
              child: Text(
                'ยังไม่มีข้อมูล',
                style: TextStyle(
                    fontFamily: _kFont,
                    fontFamilyFallback: _kFontFallback,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kMuted),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: box.maxWidth),
                    child: IntrinsicWidth(child: _grid()),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int get _firstHit {
    for (var r = 0; r < table.rows.length; r++) {
      if (_hit(table.rows[r])) return r;
    }
    return -1;
  }

  Widget _grid() {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      border: TableBorder.all(color: _kBorder, width: 1),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: _kHeaderBg),
          children: [for (final c in table.columns) _cell(c, header: true)],
        ),
        for (var r = 0; r < table.rows.length; r++)
          TableRow(
            // แถวที่ถูกอ้างอิง: พื้นฟ้าอ่อน
            decoration: _hit(table.rows[r])
                ? const BoxDecoration(color: Color(0xFFD3E3FD))
                : null,
            children: [
              for (var c = 0; c < table.columns.length; c++)
                c == 0 && _hit(table.rows[r]) && r == _firstHit
                    // แถวแรกที่ตรง: จุดยึดให้เลื่อนมาให้เห็น
                    ? _ScrollHere(
                        child: _cell(
                          c < table.rows[r].length ? table.rows[r][c] : '',
                          alert: table.isAlert(r, c),
                        ),
                      )
                    : _cell(
                        c < table.rows[r].length ? table.rows[r][c] : '',
                        alert: table.isAlert(r, c),
                      ),
            ],
          ),
      ],
    );
  }

  Widget _cell(String text, {bool header = false, bool alert = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: _kFont,
            fontFamilyFallback: _kFontFallback,
            fontSize: 11,
            height: 1.35,
            fontWeight: header || alert ? FontWeight.w600 : FontWeight.w500,
            color: alert ? _kAlert : (header ? _kMuted : _kText),
          ),
        ),
      ),
    );
  }
}

/// เลื่อนรายการแม่ให้เห็นวิดเจ็ตนี้ครั้งเดียวตอนสร้าง (แถวแรกที่ถูกอ้างอิง)
class _ScrollHere extends StatefulWidget {
  const _ScrollHere({required this.child});

  final Widget child;

  @override
  State<_ScrollHere> createState() => _ScrollHereState();
}

class _ScrollHereState extends State<_ScrollHere> {
  @override
  void initState() {
    super.initState();
    // รอแท็บเลื่อนเข้าเสร็จก่อน แล้วเลื่อนให้แถวอยู่ราวหนึ่งในสามจากบน
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          alignment: 0.3);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
