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
const _kFont = 'NotoSansThai';

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
          _TableCard(table: tables[i]),
        ],
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table});

  final ErTable table;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
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
            children: [
              for (var c = 0; c < table.columns.length; c++)
                _cell(
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
