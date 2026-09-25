// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ปุ่มหลักของเมนูลัด หมุนเป็นกากบาทเมื่อกางเมนูอยู่
// ================================================== แท็บของแพทย์
// สามหน้าจอของแพทย์ (Figma 165:2618 ทบทวนระบบ · 165:2615 ตรวจร่างกาย
// · 169:2801 คำสั่งแพทย์) ยุบมาอยู่ในหน้ารายละเอียดเดียวกัน
// ใช้ภาษาเดียวกับหน้านี้: การ์ดขาว ขอบ _line มุม 14 ตัวอักษร IBM Plex Sans Thai Looped
// หุ่นสามมิติยังเป็นพื้นหลังเสมอ แผงทั้งหมดลอยทับ

/// แผงที่ลอยทับฉากตามแท็บที่เลือก
/// แท็บ → ตารางข้อมูล (แท็บฟอร์ม HOSxP ไม่มีตาราง)
const List<ErTab?> _tabTables = [
  ErTab.overview,
  ErTab.triage,
  ErTab.exam,
  ErTab.orders,
  ErTab.vitals,
  ErTab.meds,
  ErTab.labs,
  ErTab.imaging,
  null,
];

extension _FeaturesPatientTableViewPart on _ErFlowHomeWidgetState {
  /// แท็บที่มีหน้าตาแบบภาพอยู่แล้ว สลับเป็นตารางได้ · แท็บอื่นเป็นตารางอย่างเดียว
  // 0 ภาพรวม · 1 คัดกรอง · 2 ตรวจร่างกาย · 3 คำสั่งแพทย์ · 4 สัญญาณชีพ
  // 5 ยา · 6 แล็บ · 7 ภาพถ่าย · 8 ฟอร์ม HOSxP
  bool get _tableOnly =>
      _detailTab == 1 || (_detailTab >= 4 && _detailTab <= 7);

  /// แท็บที่มีทั้งหน้าตาแบบภาพและตาราง
  bool get _hasToggle => const {0, 3}.contains(_detailTab);

  List<Widget> _tableOverlays() {
    final tab = _tabTables[_detailTab]!;
    return [
      Positioned(
        left: 16.0,
        top: _tableOnly ? 14.0 : 58.0,
        bottom: 16.0,
        child: LayoutBuilder(builder: (context, c) {
          return SizedBox(
            width: math.min(820.0, MediaQuery.of(context).size.width * 0.64),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: ErDetailTable(hn: _caseP().hn, tab: tab),
            ),
          );
        }),
      ),
    ];
  }

  /// ปุ่มสลับ ภาพ | ตาราง ของแท็บภาพรวม ตรวจร่างกาย คำสั่งแพทย์
  Widget _viewToggle() => Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: _line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (i, label, icon) in [
            (0, 'ภาพ', Icons.view_quilt_rounded),
            (1, 'ตาราง', Icons.table_rows_rounded),
          ])
            Material(
              color: (_tableView ? 1 : 0) == i ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => _tableView = i == 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: Row(children: [
                    Icon(icon,
                        size: 14.0,
                        color:
                            (_tableView ? 1 : 0) == i ? Colors.white : _ink3),
                    const SizedBox(width: 4.0),
                    Text(label,
                        style: _t(10.5,
                            color: (_tableView ? 1 : 0) == i
                                ? Colors.white
                                : _ink2,
                            weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
        ]),
      );
}
