// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ตัวกรองระดับ ESI ของรายชื่อผู้ป่วยหน้าภาพรวม (null = ทั้งหมด)
int? _boardEsi;

/// กรองเฉพาะผู้ป่วยที่เปิดแฟ้ม fast track (หน้าภาพรวม)
bool _boardFt = false;

/// กลุ่มย่อย Fast track ที่กรอง (id แฟ้ม เช่น stroke) · null = ทุกกลุ่ม
String? _boardFtType;

/// แพทย์: แสดงเฉพาะผู้ป่วยที่ assign ให้ตัวเอง (ค่าเริ่มต้น = เปิด) ER-3819
bool _boardMine = true;

/// ตัวปรับภาพในวงภาพรวม (debug build เท่านั้น · กดค้างวงกลางเพื่อเปิด)
/// _ovTune[ภาพ] = (ขนาดกรอบ, เลื่อน x, เลื่อน y) ทับค่าในโค้ดชั่วคราว จนกว่าจะคัดลอกไปใส่
bool _ovDbg = false;
int _ovDbgCur = 0;
final Map<String, (double, double, double)> _ovTune = {};
double _ovPinch0 = 0.0;

/// ตำแหน่งแผงปรับภาพ (ลากที่หัวแผงเพื่อย้าย)
Offset _ovDbgPos = const Offset(12.0, 58.0);

/// สีย้อมของรอบที่วนอยู่ (ฉากภาพรวม) ให้พื้นหลังบอร์ดใต้รายชื่อไหลสีต่อจากฉาก
final _ovTint = ValueNotifier<Color>(_blue);

/// ตัวเลื่อนรายชื่อหน้าภาพรวม (ใช้ดูดฉากหัวให้กาง/หุบสุดตอนปล่อยนิ้ว)
final _ovScroll = ScrollController();

/// มุมมองรายชื่อหน้าภาพรวม: false = การ์ด · true = ตาราง
bool _boardTable = false;

/// คอลัมน์ที่เรียงในตาราง (ดัชนี _tblCols) · null = ลำดับตั้งต้น (ESI แล้วเวลารอ) · asc = น้อยไปมาก
int? _tblSort;
bool _tblAsc = true;

/// หน้าของตาราง (เกิน 20 คนแบ่งหน้า หน้าละ 20)
int _tblPage = 0;
const int _tblPer = 20;

extension _TabsOverviewOverviewTabPart on _ErFlowHomeWidgetState {
  // ---------------------------------------------------------------- หัวหน้า
  /// สีประจำขั้น ใช้ทั้งกับแท่นในฉากและป้ายบนจอ
  Color _stageColor(_Stage stage) {
    switch (stage) {
      // ไล่เข้มอ่อนในสีรองสีเดียว ไม่ใช่สี่สีแข่งกับสีเน้น
      case _Stage.triage:
        return _mono ? _g2 : _blue;
      case _Stage.waitDoctor:
        return _mono ? _g3 : _blue2;
      case _Stage.treatment:
        return _mono ? _g4 : _blue3;
      case _Stage.discharge:
        return _mono ? _g5 : _blue4;
      case _Stage.observe:
        return _mono ? _g5 : _blue3;
    }
  }

  /// ตัวเลขใหญ่หนึ่งช่องในแผงซ้าย เป็นการ์ดมีเส้นขอบ
  /// หน่วยต่อท้ายด้วยขนาดเล็กกว่า ตัวเลขจะได้ไม่ต้องแบกความหมายเอง
  /// อ่านง่ายบนพื้นกรมท่า: ป้ายขาวทึบเกือบเต็ม ตัวเลขขาวเสมอ (สีจางบนน้ำเงินอ่านยาก)
  /// สถานะที่ต้องสังเกต (เช่น เตียงเต็ม) บอกด้วยป้าย [tag] มุมขวาบนแทนการเปลี่ยนสีตัวเลข
  Widget _bigStat(String label, String value,
          {String? unit, Color color = _lpInk, String? tag}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
        decoration: _lpCardDeco,
        foregroundDecoration: const _InnerGloss(12.0, dark: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Text(label,
                    style: _t(12.0, color: _lpInk2, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(tag,
                      style: _t(10.0,
                          color: Colors.white, weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // ค่าใหญ่ย่อลงเองเมื่อช่องแคบ (เช่น "2:18") ไม่ล้นขวา
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        style:
                            _num(28.0, color: color, weight: FontWeight.w700)),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _t(12.0, color: _lpInk2, weight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

  // คำอธิบายสีเคยลอยบนฉาก · หน้าภาพรวมใช้กระดานแล้ว (ป้าย ESI บอกระดับในการ์ดเอง)
  Widget _legend() => const SizedBox.shrink();

  Widget _overviewPanel() {
    final over = _patients.where((p) => p.over).length;
    // นับจากข้อมูลจริง ให้ตรงกับแถบล่างที่นับเตียงที่ใช้
    final vacant =
        _roomBeds.length - _patients.where((p) => p.bed != null).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          18.0, 6.0, 0.0, 76.0), // ล่างเว้นให้ป้ายผู้ใช้
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ภาพรวมห้องฉุกเฉิน',
                        style:
                            _t(19.0, color: _lpInk, weight: FontWeight.w700)),
                    Text('อัปเดทข้อมูลทุก 30 วินาที',
                        style: _t(10.5, color: _lpInk3)),
                  ],
                ),
              ),
              _collapseButton(),
            ],
          ),
          // เนื้อหาที่เหลือกลับมามีขอบขวา 16 เหมือนเดิม
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                // ลงทะเบียนผู้ป่วยใหม่ = งานแรกของห้อง ER วางบนสุดของหน้าแรก
                Row(children: [
                  Expanded(flex: 3, child: _registerButton()),
                  const SizedBox(width: 8.0),
                  Expanded(flex: 2, child: _faceScanButton()),
                ]),
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat(
                          'ผู้ป่วยในห้องตอนนี้', '${_patients.length}',
                          unit: 'ราย'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('ค้างเกินเกณฑ์', '$over',
                          unit: 'ราย',
                          color: over > 0 ? _onLight(_red) : _lpInk),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat('เวลาเฉลี่ยใน ER', '2:18', unit: 'ชม.'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat(
                          'เตียงว่าง', '$vacant/${_roomBeds.length}',
                          unit: 'เตียง', tag: vacant == 0 ? 'เต็ม' : null),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                  decoration: _lpCardDeco,
                  foregroundDecoration: const _InnerGloss(12.0, dark: true),
                  child: _HourChart(t: _t, num: _num),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- กระดานภาพรวม
  /// หน้าภาพรวม (ขวาของแผง KPI): 2 หน้าต่าง
  /// ซ้าย = visualization (placeholder รอออกแบบ) · ขวา = รายชื่อผู้ป่วย 2 คอลัมน์ เรียงตามความเร่งด่วน
  /// chip ระดับ ESI: จุดสีระดับ + ชื่อ + จำนวน · เลือกแล้ว = พื้นสีระดับอ่อน ขอบสี
  /// ปุ่มสลับมุมมองรายชื่อ (segmented ไอคอน): การ์ด | ตาราง
  Widget _boardViewToggle({bool bare = false, List<_P>? mine}) {
    Widget seg(bool table, IconData icon, String tip) {
      final on = _boardTable == table;
      return Tooltip(
        message: tip,
        child: GestureDetector(
          onTap: () => setState(() => _boardTable = table),
          // ที่เลือก = pill กรมท่า ไอคอน + ข้อความกำกับ · ที่ไม่เลือก = ไอคอนอย่างเดียว
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 34.0,
            padding: EdgeInsets.symmetric(horizontal: on ? 14.0 : 11.0),
            decoration: BoxDecoration(
              color: on ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 20.0, color: on ? Colors.white : _ink2),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: on
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(tip,
                            style: _t(14.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      )
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2.0),
      // bare = อยู่ในแท็บหัว folder (ไม่มีพื้น/ขอบของตัวเอง)
      decoration: bare
          ? null
          : BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
      // หัวข้อ "รายชื่อผู้ป่วย" ตัวเล็กบางอยู่เหนือแถวปุ่ม (มุมมอง · ของฉัน · ESI)
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              seg(false, Icons.grid_view_rounded, 'การ์ด'),
              seg(true, Icons.table_rows_rounded, 'ตาราง'),
              // ตัวกรองผู้ป่วยของฉัน (แพทย์) ย้ายจากมุมฉากมาอยู่ในหัวรายชื่อ
              if (mine != null) ...[
                Container(
                    width: 1.0,
                    height: 20.0,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    color: _line),
                _boardMineToggle(mine),
              ],
              Container(
                  width: 1.0,
                  height: 20.0,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: _line),
              _esiFilterButton(mine ?? const []),
            ]),
          ]),
    );
  }

  /// มุมมองตาราง: แถวละคน · ESI · ชื่อ/HN · เตียง · ประเภท · Fast track KPI · อยู่ใน ER · ช่วงงาน
  /// แตะแถว = เปิดผู้ป่วย
  static const _tblCols = [
    ('ESI', 58.0),
    ('ผู้ป่วย', 0.0),
    ('เตียง', 52.0),
    ('ประเภท', 80.0),
    ('Fast track', 150.0),
    ('อยู่ใน ER', 92.0),
  ];

  /// หัวตาราง (ค้างบนสุดเมื่อเลื่อน ใต้หัวรายชื่อผู้ป่วย) · มุมบนโค้ง ต่อกับตัวตาราง
  /// หัวตาราง (ค้างบนสุดเมื่อเลื่อน ใต้หัวรายชื่อผู้ป่วย) · มุมบนโค้ง ต่อกับตัวตาราง
  /// แตะหัวคอลัมน์ = เรียง (แตะซ้ำ สลับขึ้น/ลง · ครั้งที่สาม = กลับลำดับตั้งต้น)
  Widget _boardTableHead() {
    Widget head(int i) {
      final c = _tblCols[i];
      final on = _tblSort == i;
      final w = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (_tblSort != i) {
              _tblSort = i;
              _tblAsc = true;
            } else if (_tblAsc) {
              _tblAsc = false;
            } else {
              _tblSort = null;
            }
          });
        },
        child: SizedBox(
          height: 38.0,
          child: Row(children: [
            Flexible(
              child: Text(c.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0,
                      color: on ? _blue : _ink2,
                      weight: on ? FontWeight.w700 : FontWeight.w600)),
            ),
            const SizedBox(width: 2.0),
            Icon(
                on
                    ? (_tblAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14.0,
                color: on ? _blue : _ink3),
          ]),
        ),
      );
      return c.$2 == 0.0 ? Expanded(child: w) : SizedBox(width: c.$2, child: w);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        border: Border(
          top: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          left: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          right: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
      ),
      child: Row(children: [for (var i = 0; i < _tblCols.length; i++) head(i)]),
    );
  }

  /// ตัวแบ่งหน้าตาราง: "1–20 จาก 22" · ก่อนหน้า · เลขหน้า · ถัดไป
  Widget _tblPager(int pages, int total) {
    Widget btn(IconData ic, bool on, VoidCallback f) => _Press(
          child: GestureDetector(
            onTap: on ? f : null,
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: _panel,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Icon(ic, size: 20.0, color: on ? _inkTitle : _ink3),
            ),
          ),
        );
    final from = _tblPage * _tblPer + 1;
    final to = math.min(total, from + _tblPer - 1);
    return Row(children: [
      Text('$from–$to จาก $total ราย',
          style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
      const Spacer(),
      btn(Icons.chevron_left_rounded, _tblPage > 0,
          () => setState(() => _tblPage--)),
      const SizedBox(width: 6.0),
      for (var i = 0; i < pages; i++) ...[
        GestureDetector(
          onTap: () => setState(() => _tblPage = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == _tblPage ? _blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text('${i + 1}',
                style: _num(13.0,
                    color: i == _tblPage ? Colors.white : _ink2,
                    weight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 4.0),
      ],
      const SizedBox(width: 2.0),
      btn(Icons.chevron_right_rounded, _tblPage < pages - 1,
          () => setState(() => _tblPage++)),
    ]);
  }

  /// แถวตารางไล่เข้า: เหลื่อมเวลาตามลำดับ (สูงสุด 12 แถวแรก ที่เหลือขึ้นพร้อมแถวที่ 12)
  Widget _tblRise(int i, Key key, Widget child) {
    final d = math.min(i, 12);
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + 30 * d),
      builder: (context, v, c) {
        final t = Curves.easeOutCubic
            .transform(Interval((30 * d) / (380 + 30 * d), 1.0).transform(v));
        return Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0.0, 8.0 * (1 - t)), child: c),
        );
      },
      child: child,
    );
  }

  /// เรียงรายชื่อตามคอลัมน์ที่เลือก (ค่าว่างไปท้ายเสมอ)
  List<_P> _tblSorted(List<_P> list) {
    final k = _tblSort;
    if (k == null) return list;
    // Fast track: เกินเป้ามากสุดก่อน (ค่า + = นาทีที่เกิน, - = นาทีที่เหลือ)
    num? ft(_P p) {
      final b = _ftKpiBrief(p.hn).firstOrNull;
      if (b == null || b.$3 == _ink3) return null;
      final n =
          int.tryParse(RegExp(r'(\d+) นาที').firstMatch(b.$2)?.group(1) ?? '');
      if (n == null) return null;
      return b.$2.startsWith('เกิน') ? n : -n;
    }

    Comparable? key(_P p) => switch (k) {
          0 => p.esi?.level as Comparable?,
          1 => p.name as Comparable?,
          2 => p.bed as Comparable?,
          3 => p.type?.label as Comparable?,
          4 => ft(p) as Comparable?,
          _ => p.waitMin as Comparable?,
        };
    final out = [...list];
    out.sort((a, b) {
      final x = key(a), y = key(b);
      if (x == null && y == null) return 0;
      if (x == null) return 1;
      if (y == null) return -1;
      final r = Comparable.compare(x, y);
      return _tblAsc ? r : -r;
    });
    return out;
  }

  Widget _boardTableView(List<_P> list) {
    const cols = _tblCols;
    Widget cell(int i, Widget w) => cols[i].$2 == 0.0
        ? Expanded(child: w)
        : SizedBox(width: cols[i].$2, child: w);
    String hm(int m) => m >= 60 ? '${m ~/ 60} ชม. ${m % 60} นาที' : '$m นาที';
    // ตัวตาราง (หัวแยกไปเป็น sliver ค้าง): มุมล่างโค้ง ไม่มีขอบบน (ต่อจากหัว)
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        border: Border(
          left: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          right: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                textAlign: TextAlign.center,
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          ),
        for (final (i, p) in list.indexed) ...[
          if (i > 0)
            const Divider(
                height: 1.0, thickness: 0.5, color: Color(0xFFE8EAED)),
          // เปิดตาราง/เปลี่ยนการเรียง: แถวไล่เข้าบนลงล่าง (จาง + เลื่อนขึ้นจากล่างเล็กน้อย)
          _tblRise(
              i,
              ValueKey('tr-$_tblSort-$_tblAsc-$_tblPage-${p.hn}'),
              InkWell(
                onTap: () => _openPatient(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(children: [
                    cell(
                        0,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: p.esi == null
                              ? Text('-', style: _t(13.0, color: _ink3))
                              // สายรัดข้อมือชิ้นเดียวกับการ์ด ป้ายพิมพ์เลขระดับ
                              : SizedBox(
                                  height: 22.0,
                                  child: FittedBox(
                                      child: _esiBand(p, p.esi!.color,
                                          label: '${p.esi!.level}')),
                                ),
                        )),
                    cell(
                        1,
                        Row(children: [
                          ClipOval(
                            child: Image.asset(_faceUrl(p.hn),
                                width: 30.0, height: 30.0, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(14.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w600)),
                                  Text('HN ${p.hn}',
                                      style: _num(11.5,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                                ]),
                          ),
                        ])),
                    cell(
                        2,
                        Text(p.bed ?? '-',
                            style: _num(13.0,
                                color: _inkTitle, weight: FontWeight.w600))),
                    cell(
                        3,
                        Text(p.type?.label ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500))),
                    cell(4, Builder(builder: (_) {
                      final k = _ftKpiBrief(p.hn).firstOrNull;
                      if (k == null || k.$3 == _ink3) {
                        return Text(_ftOf(p.hn).isEmpty ? '-' : 'รอเริ่มนับ',
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500));
                      }
                      return Row(children: [
                        const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CustomPaint(painter: _StopwatchArt(1.0))),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(k.$2.split(' (').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(12.5,
                                  color: k.$3, weight: FontWeight.w700)),
                        ),
                      ]);
                    })),
                    cell(
                        5,
                        Text(hm(p.waitMin),
                            style: _t(13.0,
                                color: p.over ? _red : _inkTitle,
                                weight: FontWeight.w600))),
                  ]),
                ),
              )),
        ],
      ]),
    );
  }

  /// ตัวกรอง Fast track = ป้ายแฟ้มชิ้นเดียวกับในการ์ดผังเตียง (_ftBadge แดงทึบ นาฬิกา 3D)
  /// แบบเดียวกับชิป ESI (สายรัดข้อมือ): เลือก = ยกลอย + เงาแดง · ระหว่างกรอง ESI อื่น = จาง
  /// ตัวกรอง "ผู้ป่วยของฉัน" ใช้เฉพาะบทบาทแพทย์
  bool get _mineOn => _boardMine && ErSession.instance.role == ErRole.doctor;

  /// ผู้ป่วยที่ assign ให้แพทย์ที่ login (ทีมเคสมีชื่อแพทย์คนนี้ เทียบชื่อต้น)
  bool _isMine(_P p) {
    final me = ErSession.instance.user;
    if (me == null) return true;
    final parts = me.name.split(' ');
    final first = parts.length > 1 ? parts[1] : me.name;
    return erCaseOf(p.hn)
        .team
        .any((m) => m.$2.contains('แพทย์') && m.$1.contains(first));
  }

  /// ช่วงปกติของสัญญาณชีพ (ชื่อ, ค่า, ต่ำสุด, สูงสุด, ขั้นต่ำที่นับว่าเปลี่ยน)
  List<(String, List<double>, double, double, double)> _ovVitalRanges(
          ErCase c) =>
      [
        ('HR', c.hr, 60.0, 100.0, 2.0),
        ('SBP', c.sbp, 90.0, 140.0, 4.0),
        ('RR', c.rr, 12.0, 20.0, 1.0),
        ('SpO₂', c.spo2, 95.0, 100.0, 0.5),
        ('BT', c.bt, 36.0, 37.5, 0.2),
      ];

  /// คำอธิบายแนวโน้มเป็นประโยค: อะไรเปลี่ยนไปทางไหน ในช่วงเวลาเท่าไร + ความหมายทางคลินิกคร่าว ๆ
  /// เช่น "ชีพจรเร็วขึ้นและความดันลดลงใน 22 นาที เข้าเกณฑ์เฝ้าระวังภาวะช็อก"
  String _ovTrendStory(
      int kind, ErCase c, List<(String, double, double, double, double)> ch,
      {List<(String, double, double, double, double)> minor = const []}) {
    if (ch.isEmpty) {
      return kind == 6 ? 'สัญญาณชีพแย่ลง' : 'สัญญาณชีพดีขึ้น';
    }
    String word(String lb, double a, double b, double lo, double hi) {
      final up = b > a;
      final inRange = b >= lo && b <= hi;
      return switch (lb) {
        'HR' =>
          up ? 'ชีพจรเร็วขึ้น' : (inRange ? 'ชีพจรกลับสู่ปกติ' : 'ชีพจรช้าลง'),
        'SBP' => up
            ? (inRange ? 'ความดันกลับสู่ปกติ' : 'ความดันสูงขึ้น')
            : (inRange ? 'ความดันลดลงสู่ปกติ' : 'ความดันลดลง'),
        'RR' => up
            ? 'หายใจเร็วขึ้น'
            : (inRange ? 'การหายใจกลับสู่ปกติ' : 'หายใจช้าลง'),
        'SpO₂' => up ? 'ออกซิเจนในเลือดดีขึ้น' : 'ออกซิเจนในเลือดลดลง',
        'BT' => up ? 'ไข้สูงขึ้น' : (inRange ? 'ไข้ลดลง' : 'อุณหภูมิต่ำลง'),
        _ => lb,
      };
    }

    final parts = [
      for (final x in ch.take(3)) word(x.$1, x.$2, x.$3, x.$4, x.$5)
    ];
    final joined = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(' ')} และ${parts.last}';
    // ช่วงเวลา: จากรอบที่เทียบถึงรอบล่าสุด
    String span = '';
    if (c.times.length >= 2) {
      int m(String t) {
        final q = t.split(':');
        return int.parse(q[0]) * 60 + int.parse(q[1]);
      }

      try {
        final d = m(c.times.last) - m(c.times[math.max(0, c.times.length - 3)]);
        if (d > 0) span = ' ใน $d นาที';
      } catch (_) {}
    }
    // ความหมายทางคลินิก (กติกาง่าย ๆ ตามค่าล่าสุด)
    double? last(String lb) {
      for (final x in ch) {
        if (x.$1 == lb) return x.$3;
      }
      return null;
    }

    final hr = last('HR') ?? (c.hr.isEmpty ? null : c.hr.last);
    final sbp = last('SBP') ?? (c.sbp.isEmpty ? null : c.sbp.last);
    final spo2 = last('SpO₂') ?? (c.spo2.isEmpty ? null : c.spo2.last);
    String hint = '';
    if (kind == 6) {
      if (hr != null && sbp != null && hr > 100 && sbp < 100) {
        hint = ' เข้าเกณฑ์เฝ้าระวังภาวะช็อก';
      } else if (spo2 != null && spo2 < 94) {
        hint = ' ควรประเมินการหายใจ';
      } else {
        hint = ' ควรประเมินซ้ำ';
      }
    } else {
      final allNormal = ch.every((x) => x.$3 >= x.$4 && x.$3 <= x.$5);
      hint = allNormal ? ' อยู่ในช่วงปกติแล้ว' : ' ตอบสนองต่อการรักษา';
    }
    // ค่าที่สวนทาง (ส่วนน้อย): ต่อท้ายด้วย "แต่…"
    final but = minor.isEmpty
        ? ''
        : ' แต่${[
            for (final x in minor.take(2)) word(x.$1, x.$2, x.$3, x.$4, x.$5)
          ].join(' ')}';
    return '$joined$span$but$hint';
  }

  String _ovUnit(String lb) => switch (lb) {
        'HR' => 'bpm',
        'SBP' => 'mmHg',
        'RR' => '/min',
        'SpO₂' => '%',
        'BT' => '°C',
        _ => '',
      };

  /// ระยะที่ค่าออกนอกช่วงปกติ (อยู่ในช่วง = 0)
  double _ovOut(double v, double lo, double hi) =>
      v < lo ? lo - v : (v > hi ? v - hi : 0.0);

  /// แนวโน้มอาการจากสัญญาณชีพ 3 รอบล่าสุด (รอบเก่าสุดในช่วง เทียบรอบล่าสุด): + ดีขึ้น · − แย่ลง · 0 คงที่/ไม่พอ
  /// แต่ละค่า (HR SBP RR SpO₂ BT) เทียบระยะห่างจากค่ากลางปกติ รอบล่าสุดกับรอบก่อน
  int _ovTrend(_P p) {
    final c = erCaseOf(p.hn);
    var better = 0, worse = 0;
    for (final (_, v, lo, hi, tol) in _ovVitalRanges(c)) {
      if (v.length < 2) continue;
      final d0 = _ovOut(v[math.max(0, v.length - 3)], lo, hi),
          d1 = _ovOut(v.last, lo, hi);
      // เข้า/ออกช่วงผิดปกติ นับเสมอ · ผิดปกติอยู่แล้ว = ต้องเปลี่ยนเกินขั้นต่ำ
      if (d1 < d0 - tol || (d1 == 0 && d0 > 0)) better++;
      if (d1 > d0 + tol || (d0 == 0 && d1 > 0)) worse++;
    }
    return worse > better ? -1 : (better > worse ? 1 : 0);
  }

  /// FYI: เกณฑ์ที่ hero ใช้เลือกผู้ป่วยแต่ละแบบ (อ่านจากโค้ดจริง: _ovTrend · _ovVitalRanges · _ovDueOf)
  Future<void> _ovTrendInfo() {
    Widget sec(IconData ic, Color c, String title, List<String> lines) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(ic, size: 18.0, color: c),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 4.0),
                    for (final l in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(l,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500)),
                      ),
                  ]),
            ),
          ]),
        );
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('แนวโน้มในภาพรวมคำนวณอย่างไร',
                      style:
                          _t(18.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 4.0),
                  Text(
                      'ระบบเลือกผู้ป่วยขึ้นแต่ละแบบด้วยเกณฑ์นี้ เป็นการช่วยเตือน ไม่ใช่การวินิจฉัย',
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                  const SizedBox(height: 18.0),
                  sec(Icons.trending_down_rounded, _red, 'แนวโน้มแย่ลง', [
                    'เทียบสัญญาณชีพรอบล่าสุดกับรอบที่วัดก่อนหน้า 2 รอบ (ดู 3 รอบล่าสุด)',
                    'ดู 5 ค่าเทียบช่วงปกติ: HR 60–100, SBP 90–140, RR 12–20, SpO₂ 95–100, BT 36.0–37.5',
                    'นับว่าแย่ลงเมื่อค่าออกนอกช่วงปกติ หรือห่างจากช่วงปกติมากขึ้นเกินขั้นต่ำ (HR 2, SBP 4, RR 1, SpO₂ 0.5, BT 0.2)',
                    'ค่าที่แย่ลงมากกว่าค่าที่ดีขึ้น = แนวโน้มแย่ลง',
                  ]),
                  sec(Icons.trending_up_rounded, _green, 'แนวโน้มดีขึ้น', [
                    'ใช้ 3 รอบล่าสุดและช่วงปกติเดียวกัน',
                    'นับว่าดีขึ้นเมื่อค่ากลับเข้าช่วงปกติ หรือเข้าใกล้ช่วงปกติเกินขั้นต่ำ',
                    'ค่าที่ดีขึ้นมากกว่าค่าที่แย่ลง = แนวโน้มดีขึ้น',
                  ]),
                  sec(Icons.schedule_rounded, _blue, 'ถึงเวลาดูแล', [
                    'งานจากคำสั่งแพทย์และ Fast track ที่ตั้งเวลาไว้ และเวลาถึงแล้วแต่ยังไม่บันทึกว่าทำ',
                    'คนที่มีงานค้างมากสุดขึ้นก่อน',
                  ]),
                  sec(Icons.format_list_numbered_rounded, _ink2,
                      'ลำดับที่แสดง', [
                    'แต่ละแบบแสดงไม่เกิน 3 คน แนวโน้มเรียงตาม ESI ด่วนก่อน',
                    'ค่าที่แย่ลงและดีขึ้นเท่ากัน หรือมีสัญญาณชีพไม่ถึง 2 รอบ จะไม่ขึ้นในแนวโน้ม',
                  ]),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('เข้าใจแล้ว',
                          style:
                              _t(14.0, color: _blue, weight: FontWeight.w700)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  /// headline รายบุคคล: ชื่อ → ข้อความ (ชนิดแจ้ง + เตียง/ESI) → ค่า → ปุ่มดูเคส · ตัวบอกรอบใต้สุด
  Widget _ovWhoHeadline(int kind, _P p, String label, Color col,
      List<int> steps, List<(int, _P)> people, int cur, Color tint) {
    final c = erCaseOf(p.hn);
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    // ค่า: แย่ลง/ดีขึ้น = ค่าที่เปลี่ยน (ก่อน → ล่าสุด) · ถึงเวลา = งานที่เลยเวลา
    final vals = <(String, String)>[];
    // แถวรายละเอียด: (ชื่อ, ค่าทุกรอบสำหรับกราฟเล็ก, ก่อน → ล่าสุด, ช่วงปกติ)
    final vrows = <(String, List<double>, String, String)>[];
    // ไทล์: (ชื่อ, ค่าทุกรอบ, ก่อน, ล่าสุด, ต่ำ, สูง)
    final tiles =
        <(String, List<double>, double, double, double, double, Color)>[];
    // งานที่เลยเวลา: (เวลา, ชื่องาน, เลยกี่นาที)
    final trows = <(String, String, int)>[];
    String meta = '';
    String msg;
    if (kind == 8) {
      final now = DateTime.now();
      final hm =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final t = _tasksOfHn(p.hn)
          .where((t) =>
              !_taskDone.contains(t.title) &&
              RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
              t.time.compareTo(hm) <= 0)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      msg = t.isEmpty ? 'มีงานถึงเวลาแล้ว' : t.first.title;
      if (t.isNotEmpty) {
        final p0 = t.first.time.split(':');
        final due = DateTime(
            now.year, now.month, now.day, int.parse(p0[0]), int.parse(p0[1]));
        vals.add(('ถึงเวลา', _clock(t.first.time)));
        vals.add(('เลยมา', '${now.difference(due).inMinutes} นาที'));
        if (t.length > 1) vals.add(('งานค้าง', '${t.length} งาน'));
        for (final x in t.take(3)) {
          final q = x.time.split(':');
          final d = DateTime(
              now.year, now.month, now.day, int.parse(q[0]), int.parse(q[1]));
          trows.add((x.time, x.title, now.difference(d).inMinutes));
        }
        meta = 'งานค้าง ${t.length} งาน  ผู้สั่ง ${t.first.by}';
      }
    } else {
      msg = kind == 6 ? 'สัญญาณชีพแย่ลง' : 'สัญญาณชีพดีขึ้น';
      // ทุกค่าที่เปลี่ยน (คนหนึ่งอาจมีทั้งดีขึ้นและแย่ลง) · สีตามทิศของค่านั้น · ทิศส่วนมากขึ้นก่อน
      final same =
          <(String, List<double>, double, double, double, double, Color)>[];
      final other =
          <(String, List<double>, double, double, double, double, Color)>[];
      for (final (lb, v, lo, hi, tol) in _ovVitalRanges(c)) {
        if (v.length < 2) continue;
        final a = v[math.max(0, v.length - 3)], b = v.last;
        final d0 = _ovOut(a, lo, hi), d1 = _ovOut(b, lo, hi);
        final worse = d1 > d0 + tol || (d0 == 0 && d1 > 0);
        final better = d1 < d0 - tol || (d1 == 0 && d0 > 0);
        if (!worse && !better) continue;
        final series = v.length > 6 ? v.sublist(v.length - 6) : v;
        final t = (lb, series, a, b, lo, hi, worse ? _red : _green);
        ((kind == 6) == worse ? same : other).add(t);
        if ((kind == 6) == worse) vals.add((lb, '${f(a)} → ${f(b)}'));
      }
      tiles.addAll(same);
      tiles.addAll(other);
      final minor = [for (final t in other) (t.$1, t.$3, t.$4, t.$5, t.$6)];
      msg = _ovTrendStory(
          kind, c, [for (final t in same) (t.$1, t.$3, t.$4, t.$5, t.$6)],
          minor: minor);
      final n = c.hr.length;
      final last = c.times.isEmpty ? null : c.times.last;
      meta = [
        'วัด $n รอบ',
        if (last != null) 'ล่าสุด ${_clock(last)}',
      ].join('  ');
    }
    // ข้างป้ายแนวโน้ม: HN อย่างเดียว
    final where = 'HN ${p.hn}';
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชนิดแจ้งเตือน (สีตามชนิด) + ที่อยู่ผู้ป่วย
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(label,
                  style: _t(12.0, color: col, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(where,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6.0),
          // ชื่อ + ปุ่มดูเคสชิดขวาของชื่อ (ไม่บังไทล์)
          Row(mainAxisSize: MainAxisSize.min, children: [
            // รูปหน้าผู้ป่วย + ป้าย ESI / สายฟ้า fast track (ชิ้นเดียวกับรายชื่อ)
            SizedBox(
              width: 32.0,
              height: 32.0,
              child: FittedBox(child: _rowAvatar(p)),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(22.0,
                      color: _inkTitle, weight: FontWeight.w800, height: 1.2)),
            ),
            // ปุ่มดูเคสหลังชื่อทุกรอบ (ถึงเวลาดูแลด้วย)
            ...[
              const SizedBox(width: 10.0),
              _Press(
                child: GestureDetector(
                  onTap: () => _openPatient(p),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 5.0, 8.0, 5.0),
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('ดูเคส',
                          style: _t(12.5,
                              color: Colors.white, weight: FontWeight.w600)),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16.0, color: Colors.white),
                    ]),
                  ),
                ),
              ),
            ],
          ]),
          // ข้อความใต้ชื่อ (ถึงเวลาดูแลไม่มี: การ์ดงานด้านล่างบอกครบแล้ว)
          if (trows.isEmpty) ...[
            const SizedBox(height: 2.0),
            Text(msg,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _t(13.0,
                    color: _ink2, weight: FontWeight.w500, height: 1.5)),
          ],
          const SizedBox(height: 6.0),
          // รายละเอียด: แนวโน้ม = ไทล์ต่อค่า (ค่าล่าสุดใหญ่ · ต่างจากเดิม · กราฟทุกรอบบนแถบช่วงปกติ)
          // ถึงเวลาดูแล = รายการงานที่เลยเวลา
          if (tiles.isNotEmpty) ...[
            // ล้นความกว้าง = เลื่อนแนวนอนได้ · ขยายพื้นที่เลื่อนเข้าไปในระยะขอบซ้าย 24
            // (เลื่อนแล้วไทล์ล้นออกซ้ายได้) ฟุ้งจางทั้งสองขอบ
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Flexible(
                child: Transform.translate(
                  offset: const Offset(-24.0, 0.0),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => LinearGradient(
                      colors: const [
                        Color(0x00FFFFFF),
                        Colors.white,
                        Colors.white,
                        Color(0x00FFFFFF)
                      ],
                      stops: [0.0, 20.0 / r.width, 0.84, 1.0],
                    ).createShader(r),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 40.0, bottom: 10.0),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        for (final (i, (lb, series, a, b, lo, hi, tc))
                            in tiles.indexed) ...[
                          if (i > 0) const SizedBox(width: 8.0),
                          Container(
                            width: 128.0,
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                            decoration: BoxDecoration(
                              color: _panel,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0F0B1B3F),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(lb,
                                        style: _t(11.5,
                                            color: _ink3,
                                            weight: FontWeight.w600)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 1.0),
                                      decoration: BoxDecoration(
                                        color: tc.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                                b >= a
                                                    ? Icons.trending_up_rounded
                                                    : Icons
                                                        .trending_down_rounded,
                                                size: 14.0,
                                                color: tc),
                                            const SizedBox(width: 3.0),
                                            Text(f((b - a).abs()),
                                                style: _num(10.5,
                                                    color: tc,
                                                    weight: FontWeight.w700)),
                                          ]),
                                    ),
                                  ]),
                                  const SizedBox(height: 2.0),
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: f(b),
                                        style: _num(22.0,
                                            color: tc,
                                            weight: FontWeight.w800)),
                                    TextSpan(
                                        text: ' ${_ovUnit(lb)}',
                                        style: _t(10.5,
                                            color: _ink3,
                                            weight: FontWeight.w500)),
                                  ])),
                                  Text('จาก ${f(a)}',
                                      style: _t(10.5,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                                  const SizedBox(height: 4.0),
                                  SizedBox(
                                    height: 30.0,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _OvSpark(series, tc,
                                            lo: lo, hi: hi)),
                                  ),
                                  // footer: เวลาวัดล่าสุดของค่านี้
                                  const SizedBox(height: 6.0),
                                  Container(height: 0.5, color: _line),
                                  const SizedBox(height: 4.0),
                                  Text(
                                      c.times.isEmpty
                                          ? 'วัดล่าสุด -'
                                          : 'วัดล่าสุด ${_clock(c.times.last)}',
                                      style: _t(10.5,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                                ]),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          ],
          // งานที่เลยเวลา: การ์ดเรียงแนวนอนแบบไทล์สัญญาณชีพ (เวลา · งาน · เลยกี่นาที)
          if (trows.isNotEmpty)
            // กว้างตามที่เหลือในหัว (ไม่เกิน 420) แบ่งเท่ากันทุกใบ
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 420.0, maxHeight: 96.0),
              child: Row(children: [
                for (final (k, (tm, title, late)) in trows.indexed) ...[
                  if (k > 0) const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0F0B1B3F),
                              blurRadius: 10.0,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // เวลา + ไอคอนประเภทงานมุมขวาบน (ชุดเดียวกับหมวดในแฟ้มคำสั่ง)
                            Row(children: [
                              Expanded(
                                child: Text(_clock(tm),
                                    style: _num(11.5,
                                        color: _ink3, weight: FontWeight.w600)),
                              ),
                              Image.asset(_ovTaskImg(title),
                                  width: 22.0, height: 22.0),
                            ]),
                            const SizedBox(height: 2.0),
                            Expanded(
                              child: Text(title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(13.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                            ),
                            Text('เลย $late นาที',
                                style: _num(12.0,
                                    color: _red, weight: FontWeight.w700)),
                          ]),
                    ),
                  ),
                ],
              ]),
            ),
          // เวลาวัดล่าสุด (ปุ่มดูเคสอยู่ข้างชื่อ)
          // เวลาวัดล่าสุดอยู่ใน footer ของไทล์แล้ว
          if (meta.isNotEmpty && tiles.isEmpty) ...[
            const SizedBox(height: 2.0),
            Text(meta, style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
          ],
        ]);
  }

  /// รายละเอียดรายบุคคล: แย่ลง/ดีขึ้น = ค่าที่เปลี่ยน (ก่อน → ล่าสุด) · ถึงเวลา = งานแรกที่เลยเวลา
  String _ovWhoDetail(int kind, _P p) {
    if (kind == 8) {
      final now = DateTime.now();
      final hm =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final t = _tasksOfHn(p.hn)
          .where((t) =>
              !_taskDone.contains(t.title) &&
              RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
              t.time.compareTo(hm) <= 0)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      if (t.isEmpty) return '';
      final more = t.length > 1 ? ' และอีก ${t.length - 1} งาน' : '';
      return '${t.first.title} ถึงเวลา ${_clock(t.first.time)}$more';
    }
    final c = erCaseOf(p.hn);
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    final out = <String>[];
    for (final (label, v, lo, hi, tol) in _ovVitalRanges(c)) {
      if (v.length < 2) continue;
      final a = v[math.max(0, v.length - 3)], b = v.last;
      final d0 = _ovOut(a, lo, hi), d1 = _ovOut(b, lo, hi);
      final hit = kind == 6
          ? d1 > d0 + tol || (d0 == 0 && d1 > 0)
          : d1 < d0 - tol || (d1 == 0 && d0 > 0);
      if (hit) out.add('$label ${f(a)} → ${f(b)}');
    }
    return out.take(3).join('  ');
  }

  /// ประเภทงานที่เลยเวลาของผู้ป่วย: (ภาพ 3D, นาทีที่เลยมากสุด, จำนวนงาน, งานที่เลยนานสุด)
  /// เรียงเลยนานก่อน สูงสุด 3 ประเภท
  List<(String, int, int, String)> _ovDueKinds(_P p) {
    final now = DateTime.now();
    final m = now.hour * 60 + now.minute;
    final by = <String, (int, int, String)>{};
    for (final t in _tasksOfHn(p.hn)) {
      if (_taskDone.contains(t.title) ||
          !RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time)) {
        continue;
      }
      final d = m -
          (int.parse(t.time.substring(0, 2)) * 60 +
              int.parse(t.time.substring(3)));
      if (d <= 0) continue;
      final k = _ovTaskImg(t.title);
      final o = by[k];
      by[k] = o == null
          ? (d, 1, t.title)
          : (d > o.$1 ? d : o.$1, o.$2 + 1, d > o.$1 ? t.title : o.$3);
    }
    final out = [
      for (final e in by.entries) (e.key, e.value.$1, e.value.$2, e.value.$3)
    ]..sort((a, b) => b.$2 - a.$2);
    return out.take(3).toList();
  }

  /// ชื่อหมวดของภาพ 3D ตามประเภทงาน (ตรงกับหมวดในแฟ้มคำสั่ง)
  String _ovKindLabel(String img) => switch (img) {
        'assets/images/er_os_xray.png' => 'X-ray',
        'assets/images/er_os_lab.png' => 'Lab',
        'assets/images/er_os_med.png' => 'การให้ยา',
        'assets/images/er_os_proc_cap.png' => 'หัตถการ',
        _ => 'อื่น ๆ',
      };

  /// ภาพ 3D ตามประเภทงาน (ชุดเดียวกับไอคอนหมวดในแฟ้มคำสั่ง)
  String _ovTaskImg(String title) {
    final n = title.toLowerCase();
    bool has(String re) => RegExp(re).hasMatch(n);
    if (has(r'x-?ray|cxr|\bct\b|film|mri|ultrasound|\bu/s\b')) {
      return 'assets/images/er_os_xray.png';
    }
    if (has(
        r'cbc|bun|\bcr\b|e.?lyte|electrolyte|dtx|lab|\bua\b|culture|lactate|lft|\binr\b|trop|glucose|hemoculture')) {
      return 'assets/images/er_os_lab.png';
    }
    if (has(r'\bmg\b|\bml\b|nss|acetar|ringer|\biv\b|load|tab|inj|ยา')) {
      return 'assets/images/er_os_med.png';
    }
    if (has(r'ekg|foley|ng tube|เย็บ|ทำแผล|ใส่|ดาม')) {
      return 'assets/images/er_os_proc_cap.png';
    }
    return 'assets/images/er_os_other.png';
  }

  /// งานที่ถึงเวลาแล้วยังไม่ได้ทำของผู้ป่วย (เวลาสั่ง ≤ ตอนนี้)
  int _ovDueOf(_P p) {
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return _tasksOfHn(p.hn)
        .where((t) =>
            !_taskDone.contains(t.title) &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
            t.time.compareTo(hm) <= 0)
        .length;
  }

  /// ภาพรวมห้องฉุกเฉินแบบฉากเต็มพื้นที่ (ref GUNKUL hero):
  /// พื้น = ภาพห้อง ER เบลอเต็ม section ย้อมสีตามรอบที่วน (ภาพรวม = น้ำเงิน · ESI = สีระดับ)
  /// กลาง = วงแก้ว + donut ESI + ภาพเตียง (เตียงล้นพ้นวงออกมา) · ซ้าย = ตัวเลขใหญ่ของรอบนั้น
  /// ขวา = แถบแก้ว ESI 5 ระดับ (แตะ = กรอง หยุดวน) · วนอัตโนมัติ ภาพรวม → ESI ที่มีผู้ป่วย
  Widget _ovCircles(List<_P> all) {
    final n = {
      for (final e in _Esi.values) e: all.where((p) => p.esi == e).length
    };
    // แจ้งเตือนไม่อยู่ในรอบวนแล้ว (แสดงเป็นการ์ดซ้อนใต้ headline แทน) · โค้ดรอบแจ้งเตือน (-1) เก็บไว้
    final hot = _allAlerts.where((a) => a.level == _Level.critical).toList();
    // รอบเพิ่ม: 6 = แนวโน้มแย่ลง · 7 = แนวโน้มดีขึ้น · 8 = ถึงเวลาดูแล (มีผู้ป่วยถึงแสดง)
    final worse = [
      for (final p in all)
        if (_ovTrend(p) < 0) p
    ];
    final better = [
      for (final p in all)
        if (_ovTrend(p) > 0) p
    ];
    // seed งานของทุกคนก่อนคัด: งานที่ทำแล้วเก็บตามชื่องาน (ข้ามผู้ป่วย) และ seed ทีละคนตอนเรียกครั้งแรก
    // ไม่ seed ก่อน = คัดคนเข้ารอบตอนงานยังค้าง แล้ว headline ว่างเมื่อคนถัดไป seed ชื่องานซ้ำ
    for (final p in all) {
      _tasksOfHn(p.hn);
    }
    final due = [
      for (final p in all)
        if (_ovDueOf(p) > 0) p
    ];
    // แต่ละกลุ่มวนไม่เกิน 3 คน: แย่ลง/ดีขึ้น เรียงตาม ESI (ด่วนก่อน) · ถึงเวลา = มีงานค้างมากสุดก่อน
    int esiOf(_P p) => p.esi?.level ?? 9;
    // รายบุคคล: หนึ่งรอบต่อผู้ป่วยหนึ่งคน (รหัสรอบ 100 + ลำดับ) · (ชนิด 6/7/8, ผู้ป่วย)
    final people = [
      for (final p in ([...worse]..sort((a, b) => esiOf(a) - esiOf(b))).take(3))
        (6, p),
      for (final p
          in ([...better]..sort((a, b) => esiOf(a) - esiOf(b))).take(3))
        (7, p),
      for (final p in ([...due]..sort((a, b) => _ovDueOf(b) != _ovDueOf(a)
              ? _ovDueOf(b) - _ovDueOf(a)
              : esiOf(a) - esiOf(b)))
          .take(3))
        (8, p),
    ];
    final steps = [
      // story แรก = ภาพรวม แล้วไล่ ESI ที่มีผู้ป่วยทีละระดับในตัว (sub) · ต่อด้วยรายบุคคล
      0,
      for (var i = 0; i < people.length; i++) 100 + i,
    ];
    final manual = _ovDbg || _boardEsi != null || _boardFt;
    final levels = [
      for (final e in _Esi.values)
        if ((n[e] ?? 0) > 0) e.level,
    ];
    return _OvCycle(
        key: const ValueKey('ov-cycle-sub'),
        count: steps.length,
        paused: manual,
        // story ภาพรวม: ภาพรวม 1 จังหวะ + ESI ละ 1 จังหวะ (2.6 วิต่อจังหวะ) · story อื่น 7 วิ
        // ไม่ไล่ ESI ทีละระดับแล้ว: ทุก story จังหวะเดียว
        subsOf: (k) => 1,
        durationOf: (k) => const Duration(seconds: 7),
        builder: (k, sub, ctl) => LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              final cur = _ovDbg
                  ? _ovDbgCur
                  : manual
                      ? (_boardEsi ?? 0)
                      : steps[k % steps.length] == 0 && sub > 0
                          ? levels[(sub - 1).clamp(0, levels.length - 1)]
                          : steps[k % steps.length];
              final ce = cur <= 0 || cur > 5 ? null : _Esi.values[cur - 1];
              final who = cur >= 100 && cur - 100 < people.length
                  ? people[cur - 100]
                  : null;
              final alertStep = cur == -1;
              // รอบสถานะผู้ป่วย: (หัวข้อ, ชื่อ, คำอธิบาย, สี)
              final spec = switch (who?.$1) {
                6 => (
                    'แนวโน้มแย่ลง',
                    'Deteriorating',
                    'สัญญาณชีพรอบล่าสุดห่างจากค่าปกติมากขึ้น',
                    _red
                  ),
                7 => (
                    'แนวโน้มดีขึ้น',
                    'Improving',
                    'สัญญาณชีพรอบล่าสุดเข้าใกล้ค่าปกติ',
                    _green
                  ),
                8 => (
                    'ถึงเวลาดูแล',
                    'Care due',
                    'มีงานที่ถึงเวลาแล้วยังไม่ได้ทำ',
                    _blue
                  ),
                _ => null,
              };
              final whoP = who?.$2;
              // ฉากในวงของรอบสถานะ: ยืมฉากเดิม (แย่ลง = ดูแลบนเตียง · ดีขึ้น = นั่งรอสบาย · ถึงเวลา = พยาบาลเข็น)
              final scCur =
                  switch (who?.$1) { 6 => 1, 7 => 5, 8 => 3, _ => cur };
              // ฉากพื้นสว่างแบบแอป (ขาว → _bg) ตัวเลขกรมท่า เส้น _line
              // แสงฟุ้ง immersive ตามรอบ: ภาพรวม = กรมท่า · ESI = สีระดับ (เปลี่ยนสีแบบจางข้าม)
              final tint = alertStep ? _red : (spec?.$4 ?? ce?.color ?? _blue);
              if (_ovTint.value != tint) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _ovTint.value = tint);
              }
              // ฉากกลางชิดขวา (เหลือที่ซ้ายให้ headline)
              final cx = w - 116.0 - 48.0, cy = 152.0;
              // วงกลาง: รูปเว้นขอบ 14 (ชิดเส้นวง) · เดิมเว้น 34
              const big = 232.0, inner = big;
              // ฉากในวงต่อรอบ: ESI 5 = นั่งเล่นมือถือรอ (Figma 577:91) · ESI 4 = นั่งรอหน้าเคาน์เตอร์ (577:95) · ESI 3 = รถเข็นผู้ป่วย (577:103) · ESI 2 = ทีมเข็นเปล (569:81) · ESI 1 = พยาบาลดูแลผู้ป่วยบนเตียง (577:100) · อื่น ๆ = เตียง ER (564:26)
              // (ภาพเต็ม, ภาพตัดพื้นหลัง, ขนาดกรอบ, เลื่อน x/y จากจุดกลาง, เงาพื้น: กลาง x / กว้าง / y ตามสัดส่วนกรอบ)
              final sc = who?.$1 == 7
                  ? (
                      // อาการดีขึ้น: ผู้ป่วยนั่งพักบนเตียงยิ้ม (Figma 566:75)
                      img: 'assets/images/er_ov_better.jpg',
                      pop: 'assets/images/er_ov_better_pop.png',
                      // กรอบเดียวกับฉากแนวโน้มแย่ลง (er_ov_resus) = ขนาดเท่ากัน เปลี่ยนภาพไม่กระโดด
                      size: 256.0,
                      dx: -125.0,
                      dy: -134.0,
                      shX: 0.0,
                      shW: 0.0,
                      shY: 0.0,
                    )
                  : who?.$1 == 8
                      ? (
                          // ถึงเวลาดูแล: พยาบาลบันทึกงานข้างเตียงผู้ป่วย (Figma 682:454)
                          // ทั้งภาพในวง ล้นออกเฉพาะหัวกับไหล่พยาบาล (ภาพตัดช่วงบน ขอบขาวสติกเกอร์
                          // จางลงช่วงอก ตัวไล่จางช่วงเอวซึ่งอยู่ในวงแล้ว) · ผู้ป่วยบนเตียงอยู่ในวงขวา
                          img: 'assets/images/er_ov_care.jpg',
                          pop: 'assets/images/er_ov_care_pop.png',
                          size: 260.0,
                          dx: -136.0,
                          dy: -84.0,
                          shX: 0.0,
                          shW: 0.0,
                          shY: 0.0,
                        )
                      : scCur == 5
                          ? (
                              // นั่งเล่นมือถือรอ (Figma 577:91): ทั้งภาพในวง ล้นออกเฉพาะหัว
                              img: 'assets/images/er_ov_nonurg.jpg',
                              pop: 'assets/images/er_ov_nonurg_pop.png',
                              size: 340.0,
                              dx: -135.0,
                              dy: -185.0,
                              shX: 0.0,
                              shW: 0.0,
                              shY: 0.0,
                            )
                          : scCur == 4
                              ? (
                                  // นั่งรอหน้าเคาน์เตอร์ (Figma 577:95): ทั้งภาพในวง ล้นออกเฉพาะหัว
                                  img: 'assets/images/er_ov_lessurg.jpg',
                                  pop: 'assets/images/er_ov_lessurg_pop.png',
                                  size: 361.0,
                                  dx: -178.0,
                                  dy: -186.0,
                                  shX: 0.0,
                                  shW: 0.0,
                                  shY: 0.0,
                                )
                              : scCur == 3
                                  ? (
                                      // พยาบาลเข็นรถเข็นผู้ป่วยเข้าห้องฉุกเฉิน (Figma 577:103): ล้นออกเฉพาะหัวพยาบาล
                                      img: 'assets/images/er_ov_urgent.jpg',
                                      pop: 'assets/images/er_ov_urgent_pop.png',
                                      size: 300.0,
                                      dx: -124.0,
                                      dy: -165.0,
                                      shX: 0.0,
                                      shW: 0.0,
                                      shY: 0.0,
                                    )
                                  : scCur == 2
                                      ? (
                                          // ทีมเข็นเปลลงจากรถพยาบาล (Figma 569:81): ทั้งภาพในวง ล้นออกเฉพาะหัวบุรุษพยาบาล
                                          img:
                                              'assets/images/er_ov_emergent.jpg',
                                          pop:
                                              'assets/images/er_ov_emergent_pop.png',
                                          size: 367.0,
                                          dx: -157.0,
                                          dy: -208.0,
                                          shX: 0.17,
                                          shW: 0.0,
                                          shY: 0.9,
                                        )
                                      : scCur == 1
                                          ? (
                                              // พยาบาลดูแลผู้ป่วยบนเตียง (Figma 577:100): ล้นออกเฉพาะหัวพยาบาลและหัวผู้ป่วย
                                              img:
                                                  'assets/images/er_ov_resus.jpg',
                                              pop:
                                                  'assets/images/er_ov_resus_pop.png',
                                              size: 256.0,
                                              dx: -125.0,
                                              dy: -134.0,
                                              shX: 0.0,
                                              shW: 0.0,
                                              shY: 0.0,
                                            )
                                          : (
                                              // ภาพรวม: โถงห้องฉุกเฉิน (Figma 646:111) เต็มวง ไม่มีภาพตัดล้น
                                              img:
                                                  'assets/images/er_ov_lobby.jpg',
                                              // มุมบนซ้ายของกำแพงป้าย ER โผล่พ้นขอบซ้ายบนของวง (ป้าย + คนอยู่ในวงครบ)
                                              pop:
                                                  'assets/images/er_ov_lobby_pop.png',
                                              size: 400.0,
                                              // มุมกำแพง (146, 113 ของภาพ 640) อยู่นอกขอบวง 40 px ตามแนวทแยง
                                              dx: -193.05,
                                              dy: -168.18,
                                              shX: 0.0,
                                              shW: 0.0,
                                              shY: 0.0,
                                            );
              final tune = _ovTune[sc.img] ?? (sc.size, sc.dx, sc.dy);
              final imgS = tune.$1, imgL = cx + tune.$2, imgT = cy + tune.$3;
              void setTune(double size, double dx, double dy) =>
                  setState(() => _ovTune[sc.img] = (
                        size.clamp(100.0, 420.0).roundToDouble(),
                        dx.roundToDouble(),
                        dy.roundToDouble()
                      ));
              return Stack(clipBehavior: Clip.none, children: [
                // ---- ฉากหลัง (immersive แต่โทนแอป): ภาพห้องเบลอ + ม่านขาว (ขอบทึบกว่า กลางเห็นห้อง)
                // ไล่ลงล่างจางหาพื้นบอร์ด (ขาว → _bg) ต่อเนื่องกับรายชื่อ
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF),
                          Color(0x00FFFFFF)
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ).createShader(r),
                      child: Stack(fit: StackFit.expand, children: [
                        // ---- แสงสีของระดับ (immersive): พื้นอ่อนสีระดับทั้งฉาก + แสงส่องจากด้านข้าง
                        // จางข้ามสีตอนเปลี่ยนรอบ · ภาพรวม = กรมท่า
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          color: Color.lerp(_panel, tint, 0.14),
                        ),
                        // แสงสีระดับส่องเข้ามาจากขอบซ้าย/ขวา (กลางฉากสว่าง ไม่มีแสงหลังวง)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(-1.15, 0.0),
                              radius: 0.95,
                              colors: [
                                tint.withValues(alpha: 0.38),
                                tint.withValues(alpha: 0.12),
                                tint.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(1.15, 0.0),
                              radius: 0.95,
                              colors: [
                                tint.withValues(alpha: 0.6),
                                tint.withValues(alpha: 0.22),
                                tint.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        // ม่านขาวหลัง headline (ฟุ้งเป็นวง ไม่เป็นแถบ) ตัวเลข/ชื่อระดับไม่กลืนกับแสงสี
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.78, -0.05),
                              radius: 0.55,
                              colors: [
                                _panel.withValues(alpha: 0.85),
                                _panel.withValues(alpha: 0.5),
                                _panel.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                _panel.withValues(alpha: 0.35),
                                _panel.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.3],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                // ---- ควบคุมเอง (แบบ IG story): แตะซ้าย 1/3 = ย้อน · ขวา = ถัดไป · กดค้าง = หยุด
                // อยู่ใต้ชั้นเนื้อหา (ปุ่ม/ชิปยังกดได้ตามปกติ)
                if (!manual)
                  Positioned.fill(
                    child: Row(children: [
                      for (final fwd in [false, true])
                        Expanded(
                          flex: fwd ? 2 : 1,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: fwd ? ctl.next : ctl.prev,
                            onLongPressStart: (_) => ctl.hold(true),
                            onLongPressEnd: (_) => ctl.hold(false),
                            // ปัด = อ่านที่ _OvCycleState (Listener) ทั้งพื้นที่ hero
                          ),
                        ),
                    ]),
                  ),
                // ---- FYI มุมขวาล่าง: อธิบายว่าแนวโน้มแต่ละแบบคำนวณจากอะไร
                Positioned(
                  right: 10.0,
                  bottom: 10.0,
                  child: Tooltip(
                    message: 'แนวโน้มคำนวณอย่างไร',
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ctl.hold(true);
                          _ovTrendInfo().whenComplete(() => ctl.hold(false));
                        },
                        child: const SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: Icon(Icons.info_outline_rounded,
                              size: 18.0, color: _ink2),
                        ),
                      ),
                    ),
                  ),
                ),
                // ---- ตัวบอกรอบ (indicator) แนวตั้ง ชิดขวา กึ่งกลางแนวตั้ง · รอบปัจจุบัน = ขีดยาวสีตามรอบ · แตะ = ไปรอบนั้น
                Positioned(
                  right: 10.0,
                  top: 0.0,
                  bottom: 0.0,
                  width: 16.0,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      for (var i = 0; i < steps.length; i++) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => ctl.go(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 6.0,
                                height: i == k % steps.length ? 18.0 : 6.0,
                                decoration: BoxDecoration(
                                  color: i == k % steps.length
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.55),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x290B1B3F),
                                        blurRadius: 3.0),
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
                // ---- ซ้าย: ตัวเลขใหญ่ของรอบนั้น
                Positioned(
                  left: 24.0,
                  // กึ่งกลางแนวตั้งของฉาก (เว้นล่างให้ตัวบอกรอบ) ทุกรอบ
                  top: 16.0,
                  bottom: 0.0,
                  // รายบุคคล: จบก่อนลูกศรที่ทะลุออกซ้ายของรูปทรง (ไทล์ฟุ้งจางก่อนถึงรูป)
                  width: math.max(
                      130.0, cx - big / 2 - (whoP != null ? 40.0 : 34.0)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (c, prev) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...prev, if (c != null) c]),
                      transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                              position: Tween(
                                      begin: const Offset(0.0, 0.12),
                                      end: Offset.zero)
                                  .animate(a),
                              child: c)),
                      // รอบแจ้งเตือน: แตะ headline = เปิดแผงแจ้งเตือน
                      child: whoP != null
                          ? KeyedSubtree(
                              key: ValueKey(cur),
                              child: _ovWhoHeadline(who!.$1, whoP, spec!.$1,
                                  spec.$4, steps, people, cur, tint))
                          : GestureDetector(
                              key: ValueKey(cur),
                              behavior: HitTestBehavior.opaque,
                              onTap: alertStep
                                  ? () => setState(() => _alertsOpen = true)
                                  : null,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        alertStep
                                            ? 'แจ้งเตือนวิกฤต'
                                            : spec != null
                                                ? spec.$1
                                                : ce == null
                                                    ? 'ผู้ป่วยในห้องฉุกเฉิน'
                                                    : 'ESI ${ce.level}',
                                        style: _t(13.0,
                                            color: _ink3,
                                            weight: FontWeight.w600)),
                                    Text.rich(
                                        TextSpan(children: [
                                          TextSpan(
                                              text: whoP != null
                                                  ? whoP.name
                                                  : '${alertStep ? hot.length : ce == null ? all.length : n[ce]}'),
                                          // ภาพรวม/ESI: หน่วย "ราย" ต่อท้ายตัวเลข
                                          if (whoP == null && !alertStep)
                                            TextSpan(
                                                text: ' ราย',
                                                style: _t(22.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w700)),
                                        ]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        // สีเดียวกับระดับ (ภาพรวม = กรมท่า) · ESI 3 ส้มเข้มขึ้นให้อ่านออกบนพื้นอ่อน (แบบ _esiBand)
                                        style: whoP != null
                                            ? _t(26.0,
                                                color: spec!.$4,
                                                weight: FontWeight.w800,
                                                height: 1.2)
                                            : _num(64.0,
                                                color: alertStep
                                                    ? _red
                                                    : spec != null
                                                        ? spec.$4
                                                        : ce == null
                                                            ? _blue
                                                            : ce.level == 3
                                                                ? Color.lerp(
                                                                    ce.color,
                                                                    Colors
                                                                        .black,
                                                                    0.25)!
                                                                : ce.color,
                                                weight: FontWeight.w800)),
                                    // ภาพรวม: ไม่มีบรรทัดชื่อ (ตัวเลข + ราย อ่านจบในตัว)
                                    if (!(ce == null &&
                                        whoP == null &&
                                        !alertStep))
                                      Text(
                                          alertStep
                                              ? 'รายการต้องดู'
                                              : whoP != null
                                                  ? [
                                                      if (whoP.bed != null)
                                                        'เตียง ${whoP.bed}',
                                                      if (whoP.esi != null)
                                                        'ESI ${whoP.esi!.level}',
                                                    ].join('  ')
                                                  : ce == null
                                                      ? ''
                                                      : ce.en,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: _t(20.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w800)),
                                    const SizedBox(height: 2.0),
                                    Text(
                                        maxLines: 2,
                                        alertStep
                                            ? 'ล่าสุด ${hot.first.time} น. ${hot.first.title}'
                                            : whoP != null
                                                ? _ovWhoDetail(who!.$1, whoP)
                                                : ce == null
                                                    ? 'เมื่อ ${_clock('${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}')}'
                                                    : '${(100 * (n[ce] ?? 0) / math.max(1, all.length)).round()}% ของผู้ป่วยในห้อง',
                                        style: _t(12.5,
                                            color: _ink2,
                                            weight: FontWeight.w500)),
                                    // ภาพรวม: แถบสัดส่วนแบ่งช่องตาม ESI (กว้างตามจำนวน) + ป้ายใต้แถบ · แตะช่อง = กรองระดับนั้น
                                    if (!alertStep &&
                                        whoP == null &&
                                        ce == null) ...[
                                      const SizedBox(height: 12.0),
                                      SizedBox(
                                        width: 300.0,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: SizedBox(
                                                  height: 14.0,
                                                  child: Row(children: [
                                                    for (final (i, e) in [
                                                      for (final e
                                                          in _Esi.values)
                                                        if ((n[e] ?? 0) > 0) e
                                                    ].indexed) ...[
                                                      if (i > 0)
                                                        const SizedBox(
                                                            width: 2.0),
                                                      Expanded(
                                                        flex: n[e]!,
                                                        child: GestureDetector(
                                                          onTap: () => setState(
                                                              () => _boardEsi =
                                                                  e.level),
                                                          child: Container(
                                                              color: e.color),
                                                        ),
                                                      ),
                                                    ],
                                                  ]),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Wrap(
                                                  spacing: 12.0,
                                                  runSpacing: 4.0,
                                                  children: [
                                                    for (final e in _Esi.values)
                                                      if ((n[e] ?? 0) > 0)
                                                        Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 8.0,
                                                                height: 8.0,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        e.color,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            2.0)),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4.0),
                                                              Text(
                                                                  'ESI ${e.level}',
                                                                  style: _t(
                                                                      11.5,
                                                                      color:
                                                                          _ink2,
                                                                      weight: FontWeight
                                                                          .w500)),
                                                              const SizedBox(
                                                                  width: 4.0),
                                                              Text('${n[e]}',
                                                                  style: _num(
                                                                      12.5,
                                                                      color:
                                                                          _inkTitle,
                                                                      weight: FontWeight
                                                                          .w700)),
                                                            ]),
                                                  ]),
                                            ]),
                                      ),
                                    ],
                                  ])),
                    ),
                  ),
                ),
                // ---- กลาง: วงแก้ว + donut + ภาพเตียงในวง (แตะ = ล้างตัวกรอง) · ภาพรวมไม่มีวง
                Positioned(
                  left: cx - big / 2,
                  top: cy - big / 2,
                  width: big,
                  height: big,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _boardEsi = null;
                      _boardFt = false;
                    }),
                    // debug: กดค้าง = เปิด/ปิดตัวปรับภาพ · ระหว่างเปิด ลาก = เลื่อน บีบ = ย่อขยาย
                    onLongPress: kDebugMode
                        ? () => setState(() {
                              _ovDbg = !_ovDbg;
                              _ovDbgCur = cur;
                            })
                        : null,
                    onScaleStart: _ovDbg ? (_) => _ovPinch0 = imgS : null,
                    onScaleUpdate: _ovDbg
                        ? (d) => setTune(
                            d.pointerCount > 1 ? _ovPinch0 * d.scale : imgS,
                            tune.$2 + d.focalPointDelta.dx,
                            tune.$3 + d.focalPointDelta.dy)
                        : null,
                    // รอบภาพรวม/ESI = วงกลม donut · รอบรายบุคคล = morph เป็น Star of Life (Figma 638:23)
                    // น้ำหนักรูป (ดาว, นาฬิกา): ภาพรวม/ESI = วงกลม · แย่ลง/ดีขึ้น = ดาว · ถึงเวลาดูแล = นาฬิกาจับเวลา
                    child: TweenAnimationBuilder<Offset>(
                      tween: Tween(
                          end: Offset(whoP != null && who!.$1 != 8 ? 1.0 : 0.0,
                              whoP != null && who!.$1 == 8 ? 1.0 : 0.0)),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeInOutCubic,
                      builder: (context, morph, _) => CustomPaint(
                        painter: _ErStarFrame(morph),
                        // รูปทรงดาว/นาฬิกา: กรอบ เส้นขอบ และรูป ใช้กรอบเดียวกัน (ชิดกันเต็มพื้นที่)
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            // หัวชี้วิ่งไปกลางช่องของระดับที่วนถึง (ภาพรวม = จุดบนสุด)
                            builder: (context, t, child) =>
                                TweenAnimationBuilder<double>(
                              tween: Tween(
                                  end: _EsiDonutPainter.midOf(
                                      [for (final e in _Esi.values) n[e] ?? 0],
                                      cur > 5 ? 0 : cur)),
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeInOutCubic,
                              builder: (context, knob, child) => CustomPaint(
                                foregroundPainter: _EsiDonutPainter(
                                  // ภาพรวม: สัดส่วนอยู่ในพิซซ่าแล้ว วงนอกเหลือรางเปล่า
                                  counts: [
                                    for (final e in _Esi.values) n[e] ?? 0
                                  ],
                                  colors: [
                                    for (final e in _Esi.values) e.color
                                  ],
                                  sel: cur <= 0 || cur > 5 ? null : cur,
                                  t: t,
                                  knob: knob,
                                  morph: morph,
                                  solid: spec?.$4,
                                ),
                                child: child,
                              ),
                              child: child,
                            ),
                            // รูปทรงดาว/นาฬิกา: ขยายพื้นที่รูปเกือบเต็มกรอบ (วงกลมเว้น 24 แบบเดิม)
                            child: Padding(
                              padding: EdgeInsets.zero,
                              // ภาพห้อง ER (Figma 564:26) ตัดในวง · ตำแหน่งเดียวกับชั้นเตียงที่ล้นออก
                              child: ClipPath(
                                clipper: _ErStarClip(morph, slices: null),
                                child: ColoredBox(
                                  color: const Color(0xFFEEF2F8),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    layoutBuilder: (c, prev) => Stack(
                                        clipBehavior: Clip.none,
                                        fit: StackFit.expand,
                                        children: [...prev, if (c != null) c]),
                                    // รอบแจ้งเตือน: กระดิ่งแกว่ง บนพื้นแดงอ่อน · รอบอื่น = ภาพฉาก
                                    child: alertStep
                                        ? Container(
                                            key: const ValueKey('alert-bell'),
                                            color: const Color(0xFFFCE8E6),
                                            alignment: Alignment.center,
                                            child: _OvBell(
                                                label: Text('${hot.length}',
                                                    style: _num(17.0,
                                                        color: _red,
                                                        weight:
                                                            FontWeight.w800))),
                                          )
                                        : Stack(
                                            key: ValueKey(sc.img),
                                            clipBehavior: Clip.none,
                                            children: [
                                                // พื้นที่รูปกว้างขึ้นตามรูปทรง: ชดเชยตำแหน่ง + ขยายภาพให้เต็มแขนดาว/ตัวนาฬิกา
                                                Positioned(
                                                  left: imgL -
                                                      (cx -
                                                          (inner +
                                                                  0.0 *
                                                                      (morph.dx +
                                                                              morph
                                                                                  .dy)
                                                                          .clamp(
                                                                              0.0,
                                                                              1.0)) /
                                                              2),
                                                  top: imgT -
                                                      (cy -
                                                          (inner +
                                                                  0.0 *
                                                                      (morph.dx +
                                                                              morph
                                                                                  .dy)
                                                                          .clamp(
                                                                              0.0,
                                                                              1.0)) /
                                                              2),
                                                  width: imgS,
                                                  height: imgS,
                                                  child: Transform.scale(
                                                    scale: 1.0 +
                                                        0.18 *
                                                            (morph.dx +
                                                                    morph.dy)
                                                                .clamp(
                                                                    0.0, 1.0),
                                                    child: Image.asset(sc.img,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // เงาพื้น + ตัวแบบตัดพื้นหลังล้นพ้นวงออกมา (เปลี่ยนฉากแบบจางข้าม)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      layoutBuilder: (c, prev) => Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [...prev, if (c != null) c]),
                      // ตัวแบบล้นพ้นวง/รูปทรงออกมาทุกรอบ (ยกเว้นรอบแจ้งเตือน และภาพที่ไม่มีภาพตัด)
                      child: alertStep || sc.pop.isEmpty
                          ? const SizedBox.shrink(key: ValueKey('alert-nopop'))
                          : Stack(
                              key: ValueKey(sc.pop),
                              clipBehavior: Clip.none,
                              children: [
                                  if (sc.shW > 0)
                                    Positioned(
                                      left: imgL + imgS * sc.shX - sc.shW / 2,
                                      top: imgT + imgS * sc.shY,
                                      width: sc.shW,
                                      height: 18.0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.elliptical(
                                                  sc.shW / 2, 9.0)),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0x1F0B1B3F),
                                                blurRadius: 14.0,
                                                spreadRadius: -2.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    left: imgL,
                                    top: imgT,
                                    width: imgS,
                                    height: imgS,
                                    // ขยายเท่ารูปในรูปทรง (ดาว/นาฬิกา) ให้ตัวแบบซ้อนตรงกัน
                                    child: Transform.scale(
                                        scale: whoP != null ? 1.18 : 1.0,
                                        child: Image.asset(sc.pop,
                                            fit: BoxFit.cover)),
                                  ),
                                ]),
                    ),
                  ),
                ),
                // อาการแย่ลง: ลูกศรพุ่งออกจากแขนซ้ายของดาว ผ่านหน้ารูป แล้วทะลุเลยขอบขวาออกไป
                if (who?.$1 == 6)
                  Positioned(
                    left: cx - big / 2 + 10.0,
                    top: cy - big / 2 + 74.0,
                    width: big + 30.0,
                    height: big + 30.0,
                    // ส่วนในดาวถูกตัดตามรูปดาว (เป็นเนื้อเดียวกับรูป) · ส่วนที่พ้นขอบซ้ายล่างโผล่ทะลุออกมา
                    child: IgnorePointer(
                        child: ClipPath(
                            clipper: const _TrendClip(
                                Rect.fromLTWH(-10.0, -74.0, big, big)),
                            // key ต่อคน: เปลี่ยนคนในกลุ่มเดียวกัน = เล่นท่าปรากฏใหม่
                            child: _TrendDownMark(
                                key: ValueKey('trend-${whoP!.hn}')))),
                  ),
                // แนวโน้มดีขึ้น: ลูกศรเขียวพุ่งขึ้นซ้าย หางในดาว หัวทะลุมุมซ้ายบน (ฝั่งเดียวกับลูกศรแย่ลง)
                if (who?.$1 == 7)
                  Positioned(
                    left: cx - big / 2 + 2.0,
                    top: cy - big / 2 + 30.0,
                    width: big + 30.0,
                    height: big + 30.0,
                    child: IgnorePointer(
                        child: ClipPath(
                            clipper: const _TrendClip(
                                Rect.fromLTWH(-2.0, -30.0, big, big),
                                up: true),
                            child: _TrendDownMark(
                                key: ValueKey('trend-up-${whoP!.hn}'),
                                up: true))),
                  ),
                // ถึงเวลาดูแล: ของของงานที่เลยเวลา แยกตามประเภท (ยา Lab X-ray หัตถการ) ขึ้นสลับทีละชิ้น
                // อยู่ในนาฬิกาเป็นส่วนของฉาก ส่วนบนล้นพ้นขอบออกไปแบบหัวพยาบาล
                if (who?.$1 == 8)
                  if (_ovDueKinds(whoP!) case final kinds when kinds.isNotEmpty)
                    Positioned(
                      left: cx - big / 2,
                      top: cy - big / 2,
                      width: big,
                      height: big,
                      child: IgnorePointer(
                          child: _CareDueObject(
                              key: ValueKey(
                                  'care-${whoP.hn}-${kinds.map((k) => k.$1).join()}'),
                              // ป้าย: งานที่เลยนานสุดของประเภทนั้น (+ จำนวนที่เหลือ) แล้วเลยกี่นาที
                              items: [
                            for (final (img, late, n, title) in kinds)
                              (
                                img,
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // หมวดงาน (ป้ายขาวตัวแดง) นำหน้าชื่องาน
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0,
                                                      vertical: 1.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0)),
                                              child: Text(_ovKindLabel(img),
                                                  style: _t(10.5,
                                                      color: _red,
                                                      weight: FontWeight.w700)),
                                            ),
                                            const SizedBox(width: 6.0),
                                            Flexible(
                                              child: Text(
                                                  n > 1
                                                      ? '$title และอีก ${n - 1}'
                                                      : title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: _t(12.0,
                                                      color: Colors.white,
                                                      weight: FontWeight.w700)),
                                            ),
                                          ]),
                                      const SizedBox(height: 2.0),
                                      Text('เลยเวลา $late นาที',
                                          style: _t(10.5,
                                              color: const Color(0xE6FFFFFF),
                                              weight: FontWeight.w600)),
                                    ])
                              )
                          ])),
                    ),
                // สายรัดข้อมือ ESI ย้ายไปอยู่หัวส่วนรายชื่อผู้ป่วย (_esiFilterBar)
                // ---- ปุ่มควบคุมย้อน/ถัดไป: มุมขวาบน (คู่กัน) · ชั้นบนสุด ไม่ถูกวงกลางทับ
                if (!manual)
                  for (final fwd in [false, true])
                    Positioned(
                      right: fwd ? 16.0 : 58.0,
                      top: 12.0,
                      child: _Press(
                        child: GestureDetector(
                          onTap: fwd ? ctl.next : ctl.prev,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: _panel.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: _line, width: 0.5),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x140B1B3F), blurRadius: 8.0),
                              ],
                            ),
                            child: Icon(
                                fwd
                                    ? Icons.chevron_right_rounded
                                    : Icons.chevron_left_rounded,
                                size: 22.0,
                                color: _ink2),
                          ),
                        ),
                      ),
                    ),
                // แผงปรับภาพอยู่ชั้นบนสุด (ไม่ถูกสายรัดข้อมือทับ)
                if (_ovDbg)
                  // จำกัดให้อยู่ในฉาก: ส่วนที่พ้นขอบฉากแตะ/ลากไม่ได้ (hit test ไม่ถึง)
                  // เก็บค่าที่ clamp กลับ ลากครั้งต่อไปเริ่มจากตำแหน่งที่เห็นจริง
                  Positioned(
                    left: (_ovDbgPos = Offset(
                            _ovDbgPos.dx.clamp(0.0, math.max(0.0, w - 270.0)),
                            _ovDbgPos.dy.clamp(
                                0.0, math.max(0.0, box.maxHeight - 186.0))))
                        .dx,
                    top: _ovDbgPos.dy,
                    width: 270.0,
                    child: _ovDbgPanel(sc.img, tune, setTune),
                  ),
              ]);
            }));
  }

  /// แผงปรับภาพ (debug): เลือกฉาก · slider ขนาด/เลื่อน · คัดลอกค่าไปวางในโค้ด · รีเซ็ต
  Widget _ovDbgPanel(String img, (double, double, double) tune,
      void Function(double, double, double) set) {
    Widget slider(String label, double v, double min, double max,
            void Function(double) on) =>
        Row(children: [
          SizedBox(
              width: 40.0,
              child: Text(label,
                  style: _t(11.5,
                      color: const Color(0xB3FFFFFF),
                      weight: FontWeight.w600))),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                  trackHeight: 2.0,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Color(0x40FFFFFF),
                  thumbColor: Colors.white),
              child: Slider(
                  value: v.clamp(min, max), min: min, max: max, onChanged: on),
            ),
          ),
          SizedBox(
              width: 40.0,
              child: Text(v.toStringAsFixed(0),
                  textAlign: TextAlign.right,
                  style: _num(12.0,
                      color: Colors.white, weight: FontWeight.w700))),
        ]);
    Widget btn(String label, VoidCallback on) => GestureDetector(
          onTap: on,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(8.0)),
            child: Text(label,
                style: _t(11.5, color: Colors.white, weight: FontWeight.w600)),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: const Color(0xE60B1220),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // หัวแผง = ที่จับลาก (ย้ายแผงไปที่อื่นได้ ไม่บังภาพ)
        Row(children: [
          Expanded(
            // Listener อ่านการขยับนิ้วทุกทิศ · GestureDetector ลากเปล่าไว้ชนะรายการเลื่อน (scroll ไม่แย่ง)
            child: Listener(
              // เริ่มลากจากตำแหน่งที่แสดงจริง (หลัง clamp) ไม่สะสมค่าที่ล้นขอบ
              onPointerMove: (e) => setState(() => _ovDbgPos = Offset(
                  math.max(0.0, _ovDbgPos.dx + e.delta.dx),
                  math.max(0.0, _ovDbgPos.dy + e.delta.dy))),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (_) {},
                onHorizontalDragUpdate: (_) {},
                child: Row(children: [
                  const Icon(Icons.drag_indicator_rounded,
                      size: 16.0, color: Color(0x99FFFFFF)),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text('ปรับภาพ ${img.split('/').last}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ]),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _ovDbg = false),
            child: const Icon(Icons.close_rounded,
                size: 18.0, color: Colors.white),
          ),
        ]),
        const SizedBox(height: 6.0),
        // ฉาก: รวม + ESI 1–5
        Row(children: [
          for (var i = 0; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: GestureDetector(
                onTap: () => setState(() => _ovDbgCur = i),
                child: Container(
                  width: i == 0 ? 40.0 : 28.0,
                  height: 24.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        _ovDbgCur == i ? Colors.white : const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(i == 0 ? 'รวม' : '$i',
                      style: _t(11.5,
                          color: _ovDbgCur == i ? _inkTitle : Colors.white,
                          weight: FontWeight.w700)),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 4.0),
        slider('size', tune.$1, 100.0, 420.0, (v) => set(v, tune.$2, tune.$3)),
        slider('x', tune.$2, -260.0, 120.0, (v) => set(tune.$1, v, tune.$3)),
        slider('y', tune.$3, -280.0, 80.0, (v) => set(tune.$1, tune.$2, v)),
        Text('ลากในวง = เลื่อนภาพ บีบสองนิ้ว = ย่อขยาย',
            style: _t(10.5,
                color: const Color(0x99FFFFFF), weight: FontWeight.w500)),
        const SizedBox(height: 6.0),
        Row(children: [
          btn('คัดลอกค่า', () {
            Clipboard.setData(ClipboardData(
                text:
                    'size: ${tune.$1}, dx: ${tune.$2}, dy: ${tune.$3}, // $img'));
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                content: Text(
                    'คัดลอกแล้ว size ${tune.$1.toStringAsFixed(0)} x ${tune.$2.toStringAsFixed(0)} y ${tune.$3.toStringAsFixed(0)}')));
          }),
          const SizedBox(width: 6.0),
          btn('รีเซ็ต', () => setState(() => _ovTune.remove(img))),
        ]),
      ]),
    );
  }

  /// สวิตช์ ผู้ป่วยของฉัน | ทั้งหมด (แพทย์เท่านั้น) มุมซ้ายบนของฉาก
  /// การ์ดขาวลอยเงานุ่ม: หัวเล็ก "ผู้ป่วยที่แสดง" · แท็บใหญ่ (รูปแพทย์ + ของฉัน n | ทั้งหมด n)
  /// FYI ใต้แท็บ: ที่มาของ "ของฉัน" = แพทย์เวรที่พยาบาลคัดกรองเลือกตอนส่งตรวจ
  /// สวิตช์ ผู้ป่วยของฉัน | ทั้งหมด แบบกะทัดรัด: pill เดียว แตะสลับ
  /// [รูปแพทย์/ไอคอนกลุ่มคน] ข้อความโหมด + จำนวน + ไอคอนสลับ (บอกว่าแตะได้)
  /// ที่มาของ "ของฉัน" อยู่ใน tooltip (กดค้าง)
  Widget _boardMineToggle(List<_P> all) {
    final me = ErSession.instance.user;
    if (ErSession.instance.role != ErRole.doctor || me == null) {
      return const SizedBox.shrink();
    }
    final mine = _boardMine;
    final n = mine ? all.where(_isMine).length : all.length;
    return Tooltip(
      message: mine
          ? 'ผู้ป่วยของฉัน = พยาบาลคัดกรองเลือกคุณเป็นแพทย์เวรตอนส่งตรวจ'
          : 'ผู้ป่วยทั้งหมดในห้องฉุกเฉิน',
      child: _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _boardMine = !_boardMine);
          },
          // ภาษาเดียวกับปุ่มสลับมุมมองข้าง ๆ: สูง 34 ตัว 14 · ของฉัน = พื้นกรมท่าจาง (tonal)
          // ไม่ใช้กรมท่าทึบซ้ำกับปุ่มมุมมองที่เลือกอยู่ · ทั้งหมด = ไอคอน + ข้อความเทา
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 34.0,
            padding: EdgeInsets.fromLTRB(mine ? 4.0 : 10.0, 0.0, 12.0, 0.0),
            decoration: BoxDecoration(
              color: mine ? _blue.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              mine
                  ? CircleAvatar(
                      radius: 13.0, backgroundImage: AssetImage(me.face))
                  : const Icon(Icons.groups_rounded, size: 20.0, color: _ink2),
              const SizedBox(width: 6.0),
              Text(mine ? 'ของฉัน' : 'ทั้งหมด',
                  style: _t(14.0,
                      color: mine ? _blue : _ink2, weight: FontWeight.w600)),
              const SizedBox(width: 6.0),
              Text('$n',
                  style: _num(14.0,
                      color: mine ? _blue : _ink3, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }

  /// bottom sheet เลือกค่าตัวกรอง: หัวข้อ + แถวตัวเลือก (ซ้าย = widget ป้าย · ขวา = จำนวน + ติ๊กตัวที่เลือก)
  Future<void> _ovPickSheet<T>(String title, List<(T, Widget, int?)> opts,
      T current, void Function(T) onPick) {
    return _placedSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 520.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD5D8DD),
                        borderRadius: BorderRadius.circular(100.0)),
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(title,
                    style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(height: 8.0),
                for (final (v, label, n) in opts)
                  InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(ctx);
                      onPick(v);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: _line, width: 0.5))),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft, child: label)),
                        if (n != null)
                          Text('$n คน',
                              style: _num(14.0,
                                  color: _ink2, weight: FontWeight.w600)),
                        const SizedBox(width: 12.0),
                        SizedBox(
                          width: 22.0,
                          child: v == current
                              ? const Icon(Icons.check_rounded,
                                  size: 22.0, color: _blue)
                              : null,
                        ),
                      ]),
                    ),
                  ),
              ]),
        ),
      ),
    );
  }

  /// ตัวกรอง ESI ปุ่มเดียวในหัวรายชื่อ: ยังไม่กรอง = ไอคอน + "ESI" · กรองอยู่ = สายรัดข้อมือของระดับนั้น
  /// แตะ = เมนูสายรัดข้อมือ 5 ระดับ + ทุกระดับ
  Widget _esiFilterButton(List<_P> all) {
    final cur = _boardEsi == null ? null : _Esi.values[_boardEsi! - 1];
    return GestureDetector(
      onTap: () => _ovPickSheet<int>(
          'กรองระดับ ESI',
          [
            (
              0,
              Text('ทุกระดับ',
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
              all.length
            ),
            for (final e in _Esi.values)
              (
                e.level,
                SizedBox(
                  height: 28.0,
                  child: FittedBox(
                      child: _esiBand(null, e.color, esi: e, width: 124.0)),
                ),
                all.where((p) => p.esi == e).length
              ),
          ],
          _boardEsi ?? 0,
          (v) => setState(() => _boardEsi = v == 0 ? null : v)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 34.0,
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 0.0),
        decoration: BoxDecoration(
          color:
              cur == null ? Colors.transparent : _blue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (cur == null) ...[
            const _EsiLevelIcon(),
            const SizedBox(width: 6.0),
            Text('ESI', style: _t(14.0, color: _ink2, weight: FontWeight.w600)),
          ] else
            SizedBox(
              height: 22.0,
              child: FittedBox(
                  child: _esiBand(null, cur.color, esi: cur, width: 124.0)),
            ),
          const SizedBox(width: 2.0),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18.0, color: _ink3),
        ]),
      ),
    );
  }

  /// ชิปกลุ่มย่อย Fast track (แฟ้มที่มีผู้ป่วย) งอกออกทางขวาของปุ่ม Fast track
  /// ยืดความกว้าง + จาง เลื่อนเข้าจากขวา · เลือก = พื้นแดง ตัวขาว
  Widget _ftTypeChips(List<_P> all, double maxW) {
    final ftAll = all.where((p) => _ftOf(p.hn).isNotEmpty).toList();
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: !_boardFt
          ? const SizedBox(height: 34.0)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                      offset: Offset(-24.0 * (1 - v), 0.0), child: child)),
              // ปุ่มเดียวเลือกประเภท Fast track (เมนู) แทนชิปทุกประเภท
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () => _ovPickSheet<String>(
                      'ประเภท Fast track',
                      [
                        (
                          '',
                          Text('ทุกประเภท',
                              style: _t(15.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                          ftAll.length
                        ),
                        for (final t in erFastTracks)
                          if (ftAll.any((p) => _ftOf(p.hn).containsKey(t.id)))
                            (
                              t.id,
                              _ftBadge(t.name),
                              ftAll
                                  .where((p) => _ftOf(p.hn).containsKey(t.id))
                                  .length
                            ),
                      ],
                      _boardFtType ?? '',
                      (id) => setState(
                          () => _boardFtType = id.isEmpty ? null : id)),
                  child: Container(
                    height: 34.0,
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
                    decoration: BoxDecoration(
                      color: _boardFtType != null
                          ? _ftRed
                          : const Color(0xFFFCE8E6),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                          _boardFtType == null
                              ? 'ทุกประเภท'
                              : (erFastTrackById(_boardFtType!)?.name ??
                                  _boardFtType!),
                          style: _t(13.0,
                              color:
                                  _boardFtType != null ? Colors.white : _ftRed,
                              weight: FontWeight.w600)),
                      const SizedBox(width: 2.0),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: _boardFtType != null ? Colors.white : _ftRed),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _boardFtChip(int n) {
    final on = _boardFt;
    final dim = _boardEsi != null && !on;
    return _Press(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _boardFt = !_boardFt;
            _boardFtType = null;
          });
          // เปิด Fast track: หุบ hero ให้รายชื่อขึ้นมาเต็ม (ยังไม่หุบเท่านั้น)
          if (_boardFt && _ovScroll.hasClients && _ovScroll.offset < 296.0) {
            _ovScroll.animateTo(296.0,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic);
          }
        },
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: dim ? 0.4 : 1.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              offset: Offset.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  // เลือกแล้ว: ไม่ลอย ไม่มีเงาแดงฟุ้ง (แบน ตาม design rules)
                ),
                // ป้ายแดง + นาฬิกา 3D ใหญ่ล้นขอบบน/ซ้าย (ท่า idle สายฟ้าหมุนเป็นรอบ ๆ แบบ hero)
                child: SizedBox(
                  height: 34.0,
                  child: Stack(clipBehavior: Clip.none, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 34.0,
                      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 14.0, 0.0),
                      alignment: Alignment.center,
                      // ยังไม่เลือก = ไม่มีพื้น ตัวแดง · เลือกแล้ว = แดงทึบ ตัวขาว
                      decoration: BoxDecoration(
                        color: on ? _ftRed : Colors.transparent,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('Fast track',
                          style: _t(14.0,
                              color: on ? Colors.white : _ftRed,
                              weight: FontWeight.w700)),
                    ),
                    // นาฬิกากึ่งกลางแนวตั้งของปุ่ม (สูง 34)
                    const Positioned(
                      left: 2.0,
                      top: 2.0,
                      width: 28.0,
                      height: 30.0,
                      child:
                          IgnorePointer(child: _StopwatchHero(boltScale: 1.3)),
                    ),
                  ]),
                ),
              ),
            )),
      ),
    );
  }

  /// section ของกลุ่ม ESI (ref แอปประกัน): หัวข้อใหญ่ + คำอธิบาย ซ้าย · ภาพประกอบระดับโผล่ขวา
  /// มีแสงสีระดับฟุ้งหลังภาพ · ใต้หัว = แผงโค้งพื้นสีระดับอ่อน ครอบการ์ดผู้ป่วย
  /// แถบล่างของแผง = สรุปของกลุ่ม (จำนวน + เกินเกณฑ์) · cards(cw) = การ์ดตามความกว้างที่เหลือในแผง
  Widget _esiSection(
      _Esi? e, List<_P> ps, List<Widget> Function(double cw) cards) {
    final col = e?.color ?? _ink3;
    // ภาพประกอบ: ตัวแบบตัดพื้นหลังชุดเดียวกับฉากภาพรวม มุมขวาบน ซ่อนปลายล่างไว้หลังแผง
    final fig = switch (e?.level) {
      1 => 'assets/images/er_ov_resus_fig.png',
      2 => 'assets/images/er_ov_emergent_fig.png',
      3 => 'assets/images/er_ov_urgent_fig.png',
      4 => 'assets/images/er_ov_lessurg_fig.png',
      5 => 'assets/images/er_ov_nonurg_fig.png',
      _ => null,
    };
    final sub = switch (e?.level) {
      1 => 'ต้องช่วยชีวิตทันที ทีมพร้อมข้างเตียง',
      2 => 'เสี่ยงสูง ต้องพบแพทย์ภายใน 10 นาที',
      3 => 'ต้องใช้ทรัพยากรหลายอย่าง เฝ้าสัญญาณชีพ',
      4 => 'ต้องใช้ทรัพยากรอย่างเดียว รอได้',
      5 => 'ไม่ต้องใช้ทรัพยากร ตรวจรักษาเบื้องต้น',
      _ => 'รอพยาบาลคัดกรองระดับความเร่งด่วน',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, right: 10.0),
      child: Stack(clipBehavior: Clip.none, children: [
        // ภาพประกอบอยู่หลังแผง (แบบ ref): ส่วนล่างถูกแผงบัง ดูเหมือนโผล่จากหลังแผง
        if (fig != null)
          Positioned(
            right: 34.0,
            top: 0.0,
            height: 96.0,
            child: IgnorePointer(
              child: Image.asset(fig, fit: BoxFit.contain),
            ),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ---- หัว: ข้อความซ้าย · ภาพวงกลมโผล่ขวา ทับขอบบนของแผง
          SizedBox(
            // หัวกระชับ (ชื่อ + คำอธิบาย) · ภาพประกอบสูง 96 โผล่ 60 ซ่อนหลังแผง 36 ยอดเสมอหัวข้อ
            height: 60.0,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 4.0,
                top: 0.0,
                right: 16.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // หัวข้อ = สายรัดข้อมือระดับ (ชิ้นเดียวกับการ์ดผู้ป่วย) ขนาดหัวข้อ · ยังไม่คัดกรอง = ข้อความ
                      e == null
                          ? Text('ยังไม่คัดกรอง',
                              style: _t(20.0,
                                  color: _inkTitle, weight: FontWeight.w700))
                          : Row(children: [
                              // คลี่ม้วนสายรัดตอนปรากฏ (ท่าเดียวกับการ์ดผู้ป่วย) · จำนวนอยู่บนสาย
                              SizedBox(
                                height: 24.0,
                                child: FittedBox(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.2, end: 1.0),
                                    duration:
                                        const Duration(milliseconds: 1100),
                                    builder: (context, v, _) => RepaintBoundary(
                                        child: _esiBand(null, col,
                                            esi: e, count: ps.length, t: v)),
                                  ),
                                ),
                              ),
                            ]),
                      const SizedBox(height: 4.0),
                      Text(sub,
                          maxLines: 2,
                          style:
                              _t(13.0, color: _ink2, weight: FontWeight.w500)),
                    ]),
              ),
            ]),
          ),
          // ---- แผง: พื้นสีระดับอ่อน มุมโค้ง · การ์ด 2 ใบต่อแถว · แถบสรุปล่าง
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // การ์ดผู้ป่วยแถวเดียว เลื่อนแนวนอน (เห็นพร้อมกัน ~2.2 ใบ บอกว่าเลื่อนต่อได้)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 10.0),
                    child: LayoutBuilder(
                      builder: (context, b) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cards(
                                (b.maxWidth / (ps.length > 2 ? 2.2 : 2) - 10.0)
                                    .floorToDouble())),
                      ),
                    ),
                  ),
                ]),
          ),
        ]),
      ]),
    );
  }

  Widget _overviewBoard() {
    final all = [..._patients]..sort((a, b) {
        final e = (a.esi?.level ?? 9).compareTo(b.esi?.level ?? 9);
        return e != 0 ? e : b.waitMin.compareTo(a.waitMin);
      });
    final list = [
      for (final p in all)
        if ((_boardEsi == null || p.esi?.level == _boardEsi) &&
            (!_boardFt || _ftOf(p.hn).isNotEmpty) &&
            (!_boardFt ||
                _boardFtType == null ||
                _ftOf(p.hn).containsKey(_boardFtType)) &&
            (!_mineOn || _isMine(p)))
          p
    ];
    // เลื่อนรายชื่อขึ้น = visualize เลื่อนพ้นจอไป (แบบ SliverAppBar) · หัวข้อ + chip ค้างบนสุด
    final cardH = 206.0 + (_txtScale - 1.0) * 60.0;
    // ไม่มี padding ข้าง: ฉาก 3D เต็มความกว้างเป็นพื้นหลังของ section · ส่วนอื่นเว้น 16 เอง
    // ฉาก 3D ห้องฉุกเฉิน (three.js) = พื้นหลังของ section ขวา ไม่มีการ์ดครอบ ค้างอยู่กับที่
    // รายชื่อผู้ป่วยเลื่อนขึ้นมาทับขอบล่างของฉากเล็กน้อย (Flutter วาดทับ platform view ได้)
    return Container(
      color: _bg,
      child: Stack(children: [
        // พื้นบอร์ด: สีย้อมของรอบที่วนอยู่ ไหลต่อจากฉากลงใต้หัวรายชื่อแล้วจางหาย (อยู่ใต้รายการ ไม่ทับเนื้อหา)
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          height: 560.0,
          child: IgnorePointer(
            child: ValueListenableBuilder<Color>(
              valueListenable: _ovTint,
              builder: (context, tint, _) => AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      tint.withValues(alpha: 0.16),
                      tint.withValues(alpha: 0.1),
                      tint.withValues(alpha: 0.04),
                      tint.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.4, 0.62, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        // ไม่เด้งเกินขอบบน (ดึงลงแล้วไม่เห็นพื้นว่างเหนือภาพรวม)
        // ปล่อยนิ้วกลางทางระหว่างฉากหุบ: ดูดเข้าเต็ม/หุบสุด (snap) ไม่ค้างครึ่ง ๆ
        NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              final m = n.metrics;
              if (n.depth == 0 && m.axis == Axis.vertical) {
                const h = 296.0;
                final o = m.pixels;
                if (o > 0.0 && o < h) {
                  final to = o < h * 0.4 ? 0.0 : h;
                  Future.microtask(() => _ovScroll.animateTo(to,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic));
                }
              }
              return false;
            },
            child: CustomScrollView(
                controller: _ovScroll,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // พื้นที่โปร่งเหนือรายชื่อ: เห็นฉากด้านหลัง · หัวรายชื่อเริ่มที่ 306 ทับฐานแท่นเล็กน้อย
                  // ภาพรวมแบบวงกลมซ้อน (แทนฉาก 3D): อยู่ในรายการเลื่อน แตะวงได้ เลื่อนพ้นไปพร้อมรายชื่อ
                  // สวิตช์ของฉัน/ทั้งหมด + กระดิ่ง อยู่ในส่วนนี้ เลื่อนพ้นไปด้วย (ค้างเฉพาะ header)
                  // ฉากภาพรวมหุบแบบ sliver header ตอนเลื่อนลง: เลื่อนช้ากว่า (parallax) ย่อ + จางหาย
                  SliverPersistentHeader(
                      delegate: _HeroCollapse(
                          height: 296.0,
                          child: Stack(children: [
                            Positioned.fill(child: _ovCircles(all)),
                            // กระดิ่งแจ้งเตือนย้ายไปแท็บหัวขวา ข้างปุ่ม Fast track
                          ]))),
                  // ---- หัวข้อ + chip ระดับ ESI: ค้างบนสุดเมื่อเลื่อน
                  // ซ้าย 16 · ขวาไม่เว้น: แถวชิปเลื่อนล้นถึงขอบขวาของแผง (เว้นปลายใน scroll แทน)
                  SliverPadding(
                    padding: EdgeInsets.zero,
                    sliver: SliverPersistentHeader(
                      pinned: true,
                      delegate: _BoardHeader(
                        height: 60.0,
                        card: 1,
                        // หัว folder: แท็บขาว (หัวข้อ + สลับมุมมอง) ซ้ายบน ต่อเนื้อเดียวกับตัวการ์ดใหญ่
                        // ขวา: ตัวกรองลอยบนพื้นหน้า เหนือขอบบนของตัว folder
                        child: LayoutBuilder(builder: (context, hb) {
                          // ชิปกลุ่มย่อยกว้างได้ไม่เกินช่องว่างระหว่างแท็บซ้าย (~268) กับปุ่ม Fast track + ขอบ (~168)
                          final ftMaxW = hb.maxWidth - 268.0 - 168.0;
                          return Stack(children: [
                            Positioned(
                              left: 10.0,
                              top: 4.0,
                              bottom: 0.0,
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          6.0, 6.0, 0.0, 0.0),
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                        color: _panel,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0)),
                                      ),
                                      child: _boardViewToggle(
                                          bare: true, mine: all),
                                    ),
                                    // มุมเว้า (fillet) ต่อแท็บกับขอบบนตัว folder
                                    const SizedBox(
                                        width: 20.0,
                                        child: CustomPaint(
                                            painter:
                                                _FolderFillet(bodyTop: 42.0))),
                                  ]),
                            ),
                            // แท็บหัว folder ฝั่งขวา (กลับด้าน): มุมเว้าซ้าย + แท็บขาว ใส่ตัวกรอง Fast track
                            Positioned(
                              right: 10.0,
                              top: 4.0,
                              bottom: 0.0,
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(
                                        width: 20.0,
                                        child: CustomPaint(
                                            painter: _FolderFillet(
                                                bodyTop: 42.0, left: true))),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 5.0, 8.0, 0.0),
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                        color: _panel,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0)),
                                      ),
                                      // เปิด Fast track: ชิปกลุ่มย่อยงอกออกทางขวาของปุ่ม (แท็บยืดไปทางซ้าย)
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _boardFtChip(all
                                                .where((p) =>
                                                    _ftOf(p.hn).isNotEmpty)
                                                .length),
                                            _ftTypeChips(all, ftMaxW),
                                          ]),
                                    ),
                                  ]),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                  // ---- โหมดตาราง: หัวตารางค้างบนสุด (ต่อใต้หัวรายชื่อผู้ป่วย)
                  if (_boardTable)
                    SliverPadding(
                      padding: EdgeInsets.zero,
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: _BoardHeader(
                            height: 38.0,
                            card: 2,
                            pad: const EdgeInsets.symmetric(horizontal: 22.0),
                            child: _boardTableHead()),
                      ),
                    ),
                  // ---- การ์ดผู้ป่วย 2 ใบต่อแถว เต็มความกว้าง
                  // การ์ดมีระยะขวา 10 ในตัว: เว้นขวา 6 ให้ขอบขวารวม 16 เท่าซ้าย
                  // การ์ดขาวใบใหญ่ช่วงล่าง (ต่อจากหัวรายชื่อ) มุมล่างโค้ง
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 24.0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 2.0, 0.0),
                        decoration: const BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24.0)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ตัวกรองระดับ ESI (ย้ายจากฉากภาพรวม) บนสุดของส่วนรายชื่อ

                              LayoutBuilder(builder: (context, box) {
                                final alertHn = _footAlertHn;
                                if (_boardTable) {
                                  // การ์ดเว้นขวา 6 · ตารางเว้นขวา 16 เท่าหัวตาราง
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, bottom: 40.0),
                                    child: Builder(builder: (_) {
                                      final sorted = _tblSorted(list);
                                      final pages =
                                          (sorted.length / _tblPer).ceil();
                                      if (_tblPage >= pages)
                                        _tblPage = math.max(0, pages - 1);
                                      final page = sorted
                                          .skip(_tblPage * _tblPer)
                                          .take(_tblPer)
                                          .toList();
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _boardTableView(page),
                                            if (pages > 1) ...[
                                              const SizedBox(height: 12.0),
                                              _tblPager(pages, sorted.length),
                                            ],
                                          ]);
                                    }),
                                  );
                                }
                                return Padding(
                                  // เลื่อนสุดแล้วการ์ดแถวสุดท้ายเห็นครบ พ้นมุมโค้งของจอ
                                  padding: const EdgeInsets.only(bottom: 40.0),
                                  // แตกเป็น section ตาม ESI (_esiSection) · ไม่มีระดับ = ยังไม่คัดกรอง (ท้ายสุด)
                                  child: Builder(builder: (_) {
                                    final groups = <(_Esi?, List<_P>)>[
                                      for (final e in [..._Esi.values, null])
                                        (
                                          e,
                                          [
                                            for (final p in list)
                                              if (p.esi == e) p
                                          ]
                                        ),
                                    ].where((g) => g.$2.isNotEmpty).toList();
                                    var order = 0;
                                    // เปลี่ยนตัวกรอง = key ใหม่ → section/การ์ดเล่นท่าปรากฏใหม่ (เลื่อนขึ้น + จาง ไล่ทีละ section)
                                    return Column(
                                        key: ValueKey(
                                            'sec|$_boardEsi|$_boardFt|$_boardFtType|$_boardMine|$_boardTable'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (final (e, ps) in groups) ...[
                                            if (e != groups.first.$1)
                                              const SizedBox(height: 16.0),
                                            _SectionIn(
                                              index: groups
                                                  .indexWhere((g) => g.$1 == e),
                                              child: _esiSection(
                                                  e,
                                                  ps,
                                                  (cw) => [
                                                        for (final p in ps)
                                                          SizedBox(
                                                            height: cardH,
                                                            child: _footCard(p,
                                                                alertHn:
                                                                    alertHn,
                                                                order: order++,
                                                                width: cw),
                                                          ),
                                                      ]),
                                            ),
                                          ],
                                        ]);
                                  }),
                                );
                              }),
                            ]),
                      ),
                    ),
                  ),
                ])),
      ]),
    );
  }
}

/// หัวรายชื่อที่ค้างบนสุดตอนเลื่อน (ความสูงคงที่)
class _BoardHeader extends SliverPersistentHeaderDelegate {
  _BoardHeader(
      {required this.height,
      required this.child,
      this.pad = EdgeInsets.zero,
      this.card = 0});
  final double height;
  final Widget child;

  /// การ์ดขาวใบใหญ่ครอบรายชื่อ: 0 = ไม่มี · 1 = ต้นการ์ด (มุมบนโค้ง) · 2 = ช่วงกลาง (ไม่โค้ง)
  final int card;

  /// ระยะของเนื้อหาข้างใน (ฝ้าเบลอเต็มความกว้าง ไม่โดนตัดที่ขอบเนื้อหา)
  final EdgeInsets pad;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  // อยู่เหนือฉาก = โปร่ง · ค้างบนสุดแล้วมีเนื้อหาลอดใต้ = ฝ้าเบลอฟุ้ง ๆ (ไม่ทาสีทึบ)
  Widget build(BuildContext context, double shrink, bool overlaps) {
    final frost = overlaps || shrink > 0;
    return ClipRect(
      child: Stack(fit: StackFit.expand, children: [
        // หัว folder ค้างบนสุด: พื้นทึบสีหน้า (ไม่ให้การ์ดลอดใต้ช่องว่างข้างแท็บ)
        if (frost && card == 1)
          const Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              height: 46.0,
              child: ColoredBox(color: _bg)),
        if (frost && card != 1)
          // ขอบล่างฟุ้งจางลง (ไม่เป็นเส้นตรงแข็ง)
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.7, 1.0],
            ).createShader(r),
            child: ErFrost(tint: _bg.withValues(alpha: 0.6)),
          ),
        if (card > 0)
          Padding(
            // card 1 = ตัว folder เริ่มที่ y 46 (แท็บหัวอยู่ซ้ายบน) มุมขวาบนโค้ง
            padding:
                EdgeInsets.fromLTRB(10.0, card == 1 ? 46.0 : 0.0, 10.0, 0.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panel,
                // card 1: มุมบนทั้งสองถูกแท็บซ้าย/ขวาคลุม = ไม่โค้ง
              ),
            ),
          ),
        Padding(padding: pad, child: child),
      ]),
    );
  }

  @override
  bool shouldRebuild(_BoardHeader o) => true;
}

/// กรอบเส้นประมุมโค้ง (พื้นที่ placeholder)
class _DashRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12.0));
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..color = const Color(0xFFC4C9D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10.0) {
        canvas.drawPath(m.extractPath(d, d + 5.0), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashRectPainter o) => false;
}

/// ตัดเฉพาะขอบซ้าย (บน/ล่าง/ขวาปล่อยล้นได้)
class _LeftClip extends CustomClipper<Rect> {
  const _LeftClip();
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0.0, -100.0, size.width + 1000.0, size.height + 100.0);
  @override
  bool shouldReclip(_LeftClip old) => false;
}

/// donut สัดส่วนผู้ป่วยตาม ESI แบบเส้นเดียวไล่สีต่อเนื่อง (sweep gradient) เรียบ ไม่มีแสงฟุ้ง
/// สีเปลี่ยนนุ่ม ๆ ที่รอยต่อระดับ · หัวชี้ (knob) = มุมกลางช่องของระดับที่วนถึง วาดเป็นจุดขาวขอบสีระดับ
/// sel = ระดับที่วนถึง/กรอง (ช่วงนั้นหนาขึ้น) · t = กวาดเข้าตอนเปิด (0..1) · knob = มุม (rad, 0 = บนสุด)
class _EsiDonutPainter extends CustomPainter {
  const _EsiDonutPainter(
      {required this.counts,
      required this.colors,
      this.sel,
      this.t = 1.0,
      this.knob = 0.0,
      this.morph = Offset.zero,
      this.solid});
  final List<int> counts;

  /// น้ำหนักรูป (ดาว, นาฬิกา) · (0, 0) = วงกลม
  final Offset morph;

  /// รอบรายบุคคล: เส้นสีเดียวตลอดรอบ ไม่แบ่งช่อง ESI ไม่มีหัวชี้
  final Color? solid;
  final List<Color> colors;
  final int? sel;
  final double t;
  final double knob;

  /// มุมกลางช่องของระดับ (rad จากบนสุด ตามเข็ม) · 0 = ภาพรวม/ไม่มีผู้ป่วย
  static double midOf(List<int> counts, int level) {
    final total = counts.fold<int>(0, (a, b) => a + b);
    if (level <= 0 || total == 0) return 0.0;
    var acc = 0;
    for (var i = 0; i < level - 1; i++) {
      acc += counts[i];
    }
    return (acc + counts[level - 1] / 2) / total * math.pi * 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ไม่มีเส้นวง/หัวชี้แล้ว (ผู้ใช้ขอเอาออก) · สัดส่วน ESI ดูที่ชิปใต้หัวข้อ
    return;
    final total = counts.fold<int>(0, (a, b) => a + b);
    // เส้นวงบาง (รูปเต็มวงขึ้น)
    const w = 3.0;
    // เส้นรอบ Star of Life (แทนวงกลม) · ตำแหน่งตามสัดส่วนความยาวเส้น เริ่มกลางแขนบน ตามเข็ม
    // วงกลม = เส้นทับขอบรูปพอดี (รูปเว้น 4 ในกรอบนี้) · ดาว/นาฬิกา = เส้นตรงขอบรูปพอดี
    final mm = (morph.dx + morph.dy).clamp(0.0, 1.0);
    final star =
        _ovShapePath((Offset.zero & size).deflate(4.0 * (1.0 - mm)), morph);
    final m = star.computeMetrics().first;
    final len = m.length;
    // จุดเริ่ม = จุดบนเส้นที่ใกล้กลางขอบบนที่สุด
    var o0 = 0.0, best = double.infinity;
    final topMid = Offset(size.width / 2, 10.0);
    for (var d = 0.0; d < len; d += len / 400) {
      final p = m.getTangentForOffset(d)!.position;
      final e = (p - topMid).distanceSquared;
      if (e < best) {
        best = e;
        o0 = d;
      }
    }
    Path seg(double a, double b) {
      // a, b = สัดส่วน 0..1 ของรอบ (ห่อรอบได้)
      final s0 = (o0 + a * len) % len;
      final s1 = s0 + (b - a) * len;
      if (s1 <= len) return m.extractPath(s0, s1);
      return m.extractPath(s0, len)
        ..addPath(m.extractPath(0.0, s1 - len), Offset.zero);
    }

    Offset at(double f) =>
        m.getTangentForOffset((o0 + f * len) % len)!.position;
    // ราง
    canvas.drawPath(
        star,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    // รายบุคคล (ดาว/นาฬิกา): ไม่มีเส้นขอบ เหลือแต่รูปทรง
    if (solid != null) return;
    if (total == 0) return;
    // ช่วงของแต่ละระดับตามสัดส่วนผู้ป่วย (สีระดับ) · วาดทีละช่วงตามความคืบหน้า t
    var acc = 0.0;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      final a = acc / total, b = (acc + counts[i]) / total;
      acc += counts[i];
      final e = math.min(b, t);
      if (e <= a) continue;
      canvas.drawPath(
          seg(a, e),
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = sel == i + 1 && t >= 1.0 ? w + 3.0 : w
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
    // หัวชี้: จุดขาว ขอบสีตามตำแหน่ง
    if (t >= 1.0) {
      final p = at(knob / (math.pi * 2));
      final kc = sel != null ? colors[sel! - 1] : _blue;
      canvas.drawCircle(p, 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(
          p,
          6.5,
          Paint()
            ..color = kc
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(_EsiDonutPainter o) =>
      o.t != t ||
      o.sel != sel ||
      o.knob != knob ||
      o.morph != morph ||
      o.solid != solid ||
      o.counts.join() != counts.join();
}

/// ตัวนับรอบวนอัตโนมัติของภาพรวม (ค้างรอบละ 5 วินาที) · paused = ค้างไว้ (ผู้ใช้กรองเอง)
class _OvCycle extends StatefulWidget {
  const _OvCycle(
      {super.key,
      required this.count,
      required this.paused,
      required this.builder,
      required this.subsOf,
      required this.durationOf});
  final int count;
  final bool paused;
  final Widget Function(int k, int sub, _OvCycleState c) builder;

  /// จังหวะย่อยใน story (เช่น ภาพรวมไล่ ESI) และความยาวของแต่ละ story
  final int Function(int k) subsOf;
  final Duration Function(int k) durationOf;
  @override
  State<_OvCycle> createState() => _OvCycleState();
}

/// ตัววนรอบแบบ IG story: รอบละ 5 วิ (progress = แถบบนสุด) · แตะซ้าย/ขวา = ย้อน/ถัดไป ·
/// แตะแถบ = กระโดด · กดค้าง = หยุดชั่วคราว ปล่อย = เดินต่อ · paused (กรองเอง) = ไม่วน
class _OvCycleState extends State<_OvCycle>
    with SingleTickerProviderStateMixin {
  int _k = 0;
  int _sub = 0;
  late final AnimationController progress =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..addListener(() {
          final n = widget.subsOf(_k);
          final s = (progress.value * n).floor().clamp(0, n - 1);
          if (s != _sub && mounted) setState(() => _sub = s);
        })
        ..addStatusListener((st) {
          if (st == AnimationStatus.completed && mounted) {
            setState(() {
              _k = (_k + 1) % math.max(1, widget.count);
              _sub = 0;
            });
            _start();
          }
        });

  void _start() {
    progress.duration = widget.durationOf(_k);
    progress.forward(from: 0.0);
  }

  void _arm() {
    if (widget.paused || (widget.count < 2 && widget.subsOf(_k) < 2)) {
      progress.stop();
      return;
    }
    _start();
  }

  /// ไปรอบ i (วนรอบ) แล้วนับ 5 วิใหม่
  void go(int i) {
    if (widget.count == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _k = (i % widget.count + widget.count) % widget.count;
      _sub = 0;
    });
    if (!widget.paused) _start();
  }

  /// ถัดไป: มีจังหวะย่อยเหลือ = ไปจังหวะถัดไป · ครบ = story ถัดไป
  void next() {
    final n = widget.subsOf(_k);
    if (_sub < n - 1) {
      HapticFeedback.selectionClick();
      final to = (_sub + 1) / n;
      setState(() => _sub += 1);
      if (!widget.paused) progress.forward(from: to);
      return;
    }
    go(_k + 1);
  }

  /// ย้อน: อยู่ในจังหวะย่อย (ไล่ ESI) = ถอยทีละจังหวะ · จังหวะแรก = story ก่อนหน้า
  void prev() {
    final n = widget.subsOf(_k);
    if (_sub > 0 && n > 1) {
      HapticFeedback.selectionClick();
      final to = (_sub - 1) / n;
      setState(() => _sub -= 1);
      if (!widget.paused) progress.forward(from: to);
      return;
    }
    go(_k - 1);
  }

  /// กดค้าง = หยุด · ปล่อย = เดินต่อจากจุดเดิม
  void hold(bool on) {
    if (widget.paused) return;
    on ? progress.stop() : progress.forward();
  }

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(_OvCycle old) {
    super.didUpdateWidget(old);
    if (old.paused && !widget.paused) {
      // กลับจากกรองเอง: เริ่มที่ภาพรวมใหม่ นับ 5 วิเต็ม
      _k = 0;
      _arm();
    } else if (!old.paused && widget.paused) {
      progress.stop();
    } else if (old.count != widget.count) {
      if (_k >= widget.count) _k = 0;
      _arm();
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    progress.dispose();
    super.dispose();
  }

  @override

  /// ผู้ใช้กำลังแตะ/เลื่อนในฉาก: หยุดวน · ไม่แตะครบ 6 วิ ค่อยเดินต่อจากจุดเดิม
  Timer? _idle;
  void touch() {
    if (widget.paused) return;
    progress.stop();
    _idle?.cancel();
    _idle = Timer(const Duration(seconds: 6), () {
      if (mounted && !widget.paused) progress.forward();
    });
  }

  // ปัดซ้าย/ขวา: อ่านจาก Listener (ได้ทุก pointer แม้ปุ่ม/การ์ด/รายการเลื่อนข้างในชนะ gesture ไปแล้ว)
  Offset? _down;
  DateTime _downAt = DateTime.now();
  // นิ้วนี้ลากตัวเลื่อนแนวนอนข้างใน (การ์ด V/S รายเตียง แถวชิป) ไปแล้ว = ไม่เปลี่ยนหน้า
  bool _inner = false;

  void _swipeEnd(Offset up) {
    final d0 = _down;
    _down = null;
    if (d0 == null || widget.paused || _inner) return;
    final d = up - d0;
    final ms = DateTime.now().difference(_downAt).inMilliseconds;
    // แนวนอนชัด (> 1.5 เท่าแนวตั้ง) · ไกลพอ หรือเร็วพอ
    if (d.dx.abs() < d.dy.abs() * 1.5) return;
    if (d.dx.abs() < 60.0 && !(d.dx.abs() > 30.0 && ms < 250)) return;
    d.dx < 0 ? next() : prev();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          _down = e.position;
          _downAt = DateTime.now();
          _inner = false;
          touch();
        },
        onPointerMove: (_) => touch(),
        onPointerUp: (e) {
          _swipeEnd(e.position);
          touch();
        },
        onPointerCancel: (e) => _swipeEnd(e.position),
        // ตัวเลื่อนแนวนอนข้างในเริ่มลากด้วยนิ้ว (มี dragDetails · เลื่อนเองไม่นับ)
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.horizontal && n.dragDetails != null) {
              _inner = true;
            }
            return false;
          },
          child: widget.builder(_k, widget.paused ? 0 : _sub, this),
        ),
      );
}

/// กระดิ่งแจ้งเตือนในวงภาพรวม: แกว่งเป็นช่วง ๆ (สั่น 3 ครั้งแล้วพัก) + ป้ายจำนวนแดง
class _OvBell extends StatefulWidget {
  const _OvBell({required this.label});
  final Widget label;
  @override
  State<_OvBell> createState() => _OvBellState();
}

class _OvBellState extends State<_OvBell> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          // 0..0.45 = แกว่งลดแรงลง · ที่เหลือพัก
          final v = _c.value;
          final a = v < 0.45
              ? math.sin(v / 0.45 * math.pi * 6) * 0.28 * (1 - v / 0.45)
              : 0.0;
          return Transform.rotate(
              angle: a, alignment: const Alignment(0.0, -0.8), child: child);
        },
        child: Stack(clipBehavior: Clip.none, children: [
          Icon(Icons.notifications_rounded, size: 96.0, color: _red),
          Positioned(
            right: -2.0,
            top: 4.0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 34.0),
              height: 34.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(17.0),
                border: Border.all(color: _red, width: 2.5),
              ),
              child: widget.label,
            ),
          ),
        ]),
      );
}

/// มุมเว้าระหว่างแท็บหัว folder กับขอบบนตัว folder (ขาว ลบวงกลมมุมขวาบน)
class _FolderFillet extends CustomPainter {
  const _FolderFillet({required this.bodyTop, this.left = false});
  final double bodyTop;

  /// left = มุมเว้าอยู่ซ้ายของแท็บ (แท็บฝั่งขวา) วงกลมที่ลบอยู่มุมซ้ายบน
  final bool left;
  @override
  void paint(Canvas canvas, Size size) {
    const r = 20.0;
    final sq = Path()..addRect(Rect.fromLTWH(0.0, bodyTop - r, r, r));
    final hole = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(left ? 0.0 : r, bodyTop - r), radius: r));
    canvas.drawPath(Path.combine(PathOperation.difference, sq, hole),
        Paint()..color = _panel);
  }

  @override
  bool shouldRepaint(_FolderFillet o) => o.bodyTop != bodyTop || o.left != left;
}

/// ฉากหัวหน้าภาพรวมที่หุบตอนเลื่อน: เนื้อหาสูงเต็มคงที่ แล้วเลื่อนขึ้นครึ่งเดียวของระยะหด
/// (parallax) ย่อเล็กน้อยจากด้านบน และจางหายก่อนหุบสุด
class _HeroCollapse extends SliverPersistentHeaderDelegate {
  _HeroCollapse({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => 0.0;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrink, bool overlaps) {
    final p = Curves.easeIn.transform((shrink / height).clamp(0.0, 1.0));
    // ลื่น: เนื้อหาวาดครั้งเดียว (RepaintBoundary) แล้วแค่เลื่อน (ไม่ย่อ ไม่ใช้ Opacity = ไม่ saveLayer)
    // จางด้วยม่านสีพื้นทับด้านบน (ถูกกว่า) ไล่จากบนลงล่างให้ขอบบนหายก่อน
    // ยังไม่เลื่อน = ไม่ตัดขอบ (ลูกศร/ตัวแบบล้นลงไปทับช่องว่างหัวรายชื่อได้) · เลื่อนแล้วค่อยตัด
    return ClipRect(
      clipBehavior: shrink > 0.5 ? Clip.hardEdge : Clip.none,
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: height,
        maxHeight: height,
        child: Stack(fit: StackFit.expand, children: [
          Transform.translate(
            offset: Offset(0.0, shrink * 0.45),
            child: RepaintBoundary(child: child),
          ),
          if (p > 0.0)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _bg.withValues(alpha: (p * 1.6).clamp(0.0, 1.0)),
                      _bg.withValues(alpha: (p * 0.9).clamp(0.0, 1.0)),
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  bool shouldRebuild(_HeroCollapse o) => true;
}

/// ท่าปรากฏของ section รายชื่อ (หลังเปลี่ยนตัวกรอง): เลื่อนขึ้น 16 + จางเข้า ไล่ลำดับ 70ms ต่อ section
class _SectionIn extends StatefulWidget {
  const _SectionIn({required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  State<_SectionIn> createState() => _SectionInState();
}

class _SectionInState extends State<_SectionIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 70 * widget.index.clamp(0, 6)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.0, 0.06), end: Offset.zero)
              .animate(_a),
          child: widget.child,
        ),
      );
}

/// เครื่องหมาย Star of Life (ER department · Figma 638:23) ในกรอบ r · เริ่มที่มุมบนซ้ายของแขนบน
Path _erStarPath(Rect r) {
  double x(double v) => r.left + v * r.width;
  double y(double v) => r.top + v * r.height;
  return Path()
    ..moveTo(x(0.38590), y(0.00425))
    ..cubicTo(
        x(0.40647), y(0.00360), x(0.42844), y(0.00430), x(0.44916), y(0.00433))
    ..cubicTo(
        x(0.50439), y(0.00441), x(0.55967), y(0.00399), x(0.61489), y(0.00458))
    ..cubicTo(
        x(0.61772), y(0.00438), x(0.63323), y(0.00696), x(0.63404), y(0.00865))
    ..cubicTo(
        x(0.64051), y(0.02214), x(0.63821), y(0.07841), x(0.63821), y(0.08944))
    ..lineTo(x(0.63815), y(0.20261))
    ..cubicTo(
        x(0.63807), y(0.22277), x(0.63735), y(0.24610), x(0.63902), y(0.26591))
    ..cubicTo(
        x(0.65083), y(0.26080), x(0.67691), y(0.24464), x(0.68975), y(0.23735))
    ..lineTo(x(0.79913), y(0.17520))
    ..cubicTo(
        x(0.81382), y(0.16689), x(0.85675), y(0.13894), x(0.86768), y(0.14265))
    ..cubicTo(
        x(0.87846), y(0.14630), x(0.91688), y(0.21853), x(0.92370), y(0.23008))
    ..lineTo(x(0.96573), y(0.30159))
    ..cubicTo(
        x(0.97596), y(0.31886), x(0.99236), y(0.34400), x(0.99831), y(0.36199))
    ..cubicTo(
        x(0.99693), y(0.36685), x(0.99504), y(0.37191), x(0.99101), y(0.37513))
    ..cubicTo(
        x(0.97982), y(0.38405), x(0.96498), y(0.39128), x(0.95248), y(0.39855))
    ..lineTo(x(0.83794), y(0.46369))
    ..cubicTo(
        x(0.82438), y(0.47133), x(0.78614), y(0.49154), x(0.77632), y(0.50073))
    ..cubicTo(
        x(0.78373), y(0.50679), x(0.81525), y(0.52378), x(0.82554), y(0.52954))
    ..lineTo(x(0.93180), y(0.59023))
    ..cubicTo(
        x(0.94978), y(0.60050), x(0.96837), y(0.60993), x(0.98577), y(0.62104))
    ..cubicTo(
        x(0.99560), y(0.62732), x(1.00138), y(0.63348), x(0.99600), y(0.64516))
    ..cubicTo(
        x(0.98876), y(0.66086), x(0.97968), y(0.67557), x(0.97094), y(0.69049))
    ..lineTo(x(0.92758), y(0.76429))
    ..cubicTo(
        x(0.91749), y(0.78147), x(0.90753), y(0.79873), x(0.89772), y(0.81607))
    ..cubicTo(
        x(0.89018), y(0.82926), x(0.87554), y(0.86496), x(0.85708), y(0.85680))
    ..cubicTo(
        x(0.84121), y(0.84979), x(0.82605), y(0.83994), x(0.81088), y(0.83144))
    ..lineTo(x(0.70178), y(0.76948))
    ..cubicTo(
        x(0.68642), y(0.76059), x(0.65388), y(0.74052), x(0.63914), y(0.73426))
    ..cubicTo(
        x(0.63704), y(0.74846), x(0.63787), y(0.77403), x(0.63788), y(0.78897))
    ..lineTo(x(0.63795), y(0.90700))
    ..cubicTo(
        x(0.63798), y(0.92240), x(0.64009), y(0.98067), x(0.63348), y(0.99187))
    ..cubicTo(
        x(0.62833), y(0.99573), x(0.62113), y(0.99505), x(0.61466), y(0.99510))
    ..lineTo(x(0.46128), y(0.99463))
    ..cubicTo(
        x(0.43567), y(0.99463), x(0.40994), y(0.99536), x(0.38451), y(0.99513))
    ..cubicTo(
        x(0.37100), y(0.99499), x(0.36872), y(0.98892), x(0.36790), y(0.97702))
    ..cubicTo(
        x(0.36650), y(0.95665), x(0.36699), y(0.93464), x(0.36694), y(0.91427))
    ..lineTo(x(0.36692), y(0.79630))
    ..cubicTo(
        x(0.36696), y(0.78140), x(0.36780), y(0.74857), x(0.36564), y(0.73525))
    ..cubicTo(
        x(0.35260), y(0.73925), x(0.32162), y(0.75846), x(0.30818), y(0.76624))
    ..lineTo(x(0.20995), y(0.82244))
    ..cubicTo(
        x(0.19134), y(0.83315), x(0.17259), y(0.84365), x(0.15385), y(0.85453))
    ..cubicTo(
        x(0.13280), y(0.86676), x(0.12639), y(0.84783), x(0.11676), y(0.83254))
    ..cubicTo(
        x(0.11080), y(0.82307), x(0.10536), y(0.81240), x(0.09971), y(0.80256))
    ..lineTo(x(0.06484), y(0.74292))
    ..lineTo(x(0.03067), y(0.68471))
    ..cubicTo(
        x(0.02395), y(0.67327), x(-0.00323), y(0.63622), x(0.01159), y(0.62580))
    ..cubicTo(
        x(0.02883), y(0.61368), x(0.05006), y(0.60244), x(0.06864), y(0.59190))
    ..lineTo(x(0.19150), y(0.52199))
    ..cubicTo(
        x(0.19669), y(0.51902), x(0.22469), y(0.50413), x(0.22751), y(0.50148))
    ..cubicTo(
        x(0.22336), y(0.49055), x(0.04508), y(0.39896), x(0.01585), y(0.37727))
    ..cubicTo(
        x(0.01300), y(0.37516), x(0.01037), y(0.37285), x(0.00874), y(0.36966))
    ..cubicTo(
        x(0.00679), y(0.36584), x(0.00635), y(0.36093), x(0.00780), y(0.35688))
    ..cubicTo(
        x(0.01211), y(0.34477), x(0.02039), y(0.33309), x(0.02683), y(0.32193))
    ..lineTo(x(0.06746), y(0.25243))
    ..lineTo(x(0.10814), y(0.18295))
    ..cubicTo(
        x(0.11628), y(0.16904), x(0.12933), y(0.13385), x(0.14958), y(0.14410))
    ..cubicTo(
        x(0.16874), y(0.15380), x(0.18761), y(0.16530), x(0.20628), y(0.17608))
    ..cubicTo(
        x(0.24581), y(0.19907), x(0.28557), y(0.22166), x(0.32557), y(0.24385))
    ..cubicTo(
        x(0.33803), y(0.25072), x(0.35277), y(0.26092), x(0.36576), y(0.26555))
    ..cubicTo(
        x(0.36715), y(0.24302), x(0.36674), y(0.21709), x(0.36677), y(0.19430))
    ..lineTo(x(0.36674), y(0.08507))
    ..cubicTo(
        x(0.36673), y(0.06221), x(0.36629), y(0.03911), x(0.36753), y(0.01631))
    ..cubicTo(
        x(0.36808), y(0.00621), x(0.37819), y(0.00501), x(0.38590), y(0.00425))
    ..close();
}

/// พื้นกรอบรูปดาว: ขาว + เส้นขอบบาง (แทน BoxShape.circle)
class _ErStarFrame extends CustomPainter {
  const _ErStarFrame(this.morph);
  final Offset morph;
  @override
  void paint(Canvas canvas, Size size) {
    final p = _ovShapePath(Offset.zero & size, morph);
    canvas.drawPath(p, Paint()..color = _panel);
    // ขอบขาวแบบสติกเกอร์รอบรูป ระยะเท่ากันทุกรูปทรง (วงกลม ดาว นาฬิกา)
    canvas.drawPath(
        p,
        Paint()
          ..color = _panel
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(
        p,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(_ErStarFrame o) => o.morph != morph;
}

/// ตัดภาพฉากในวงเป็นรูปดาว
class _ErStarClip extends CustomClipper<Path> {
  const _ErStarClip(this.morph, {this.slices});
  final Offset morph;

  /// ภาพรวม: ตัดภาพเป็นชิ้นพิซซ่าตามจำนวนผู้ป่วยแต่ละ ESI (เริ่มบนสุด ตามเข็ม เว้นร่องระหว่างชิ้น)
  final List<int>? slices;
  @override
  Path getClip(Size size) {
    final r = Offset.zero & size;
    final total = slices?.fold<int>(0, (a, b) => a + b) ?? 0;
    if (slices == null || total == 0 || morph.distance > 0.01) {
      return _ovShapePath(r, morph);
    }
    final c = r.center;
    final rad = size.shortestSide / 2;
    const gap = 0.045; // ครึ่งร่องระหว่างชิ้น (rad)
    final path = Path();
    var acc = 0;
    final nz = slices!.where((x) => x > 0).length;
    for (final k in slices!) {
      if (k == 0) continue;
      final a0 = -math.pi / 2 + acc / total * math.pi * 2;
      final sw = k / total * math.pi * 2;
      acc += k;
      if (nz == 1) return Path()..addOval(r);
      // ชิ้นขยับออกจากกลางเล็กน้อย = เห็นร่องชัดแบบพิซซ่าที่ตัดแล้ว
      final mid = a0 + sw / 2;
      final off = Offset(math.cos(mid), math.sin(mid)) * 3.0;
      path.addPath(
          Path()
            ..moveTo(c.dx, c.dy)
            ..arcTo(Rect.fromCircle(center: c, radius: rad), a0 + gap,
                math.max(0.0, sw - gap * 2), false)
            ..close(),
          off);
    }
    return path;
  }

  @override
  bool shouldReclip(_ErStarClip o) =>
      o.morph != morph || o.slices?.join() != slices?.join();
}

/// รูปกรอบกลางหน้าภาพรวม: ผสมวงกลม / Star of Life / นาฬิกาจับเวลา ตามน้ำหนัก w (ดาว, นาฬิกา)
/// แต่ละรูปสุ่มจุดเท่ากันตามความยาวเส้น เริ่มจุดใกล้กลางขอบบน วนตามเข็ม แล้วผสมทีละจุด
Path _ovShapePath(Rect r, Offset w) {
  const eps = 0.001;
  if (w.dx < eps && w.dy < eps) return Path()..addOval(r);
  if (w.dx > 1 - eps && w.dy < eps) return _erStarPath(r);
  if (w.dy > 1 - eps && w.dx < eps) return _erClockPath(r);
  const n = 240;
  final circle = [
    for (var i = 0; i <= n; i++)
      r.center +
          Offset(math.cos(-math.pi / 2 + i / n * math.pi * 2) * r.width / 2,
              math.sin(-math.pi / 2 + i / n * math.pi * 2) * r.height / 2)
  ];
  final star = w.dx > eps ? _ovSample(_erStarPath(r), r, n) : circle;
  final clock = w.dy > eps ? _ovSample(_erClockPath(r), r, n) : circle;
  final wc = (1.0 - w.dx - w.dy).clamp(0.0, 1.0);
  final path = Path();
  for (var i = 0; i <= n; i++) {
    final p = circle[i] * wc + star[i] * w.dx + clock[i] * w.dy;
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path..close();
}

/// สุ่ม n+1 จุดตามความยาวเส้นรอบนอก เริ่มจุดใกล้กลางขอบบน ทิศตามเข็ม (บนจอ)
List<Offset> _ovSample(Path shape, Rect r, int n) {
  final m = shape.computeMetrics().first;
  final len = m.length;
  var o0 = 0.0, best = double.infinity;
  final topMid = Offset(r.center.dx, r.top);
  for (var d = 0.0; d < len; d += len / 300) {
    final e = (m.getTangentForOffset(d)!.position - topMid).distanceSquared;
    if (e < best) {
      best = e;
      o0 = d;
    }
  }
  var pts = [
    for (var i = 0; i <= n; i++)
      m.getTangentForOffset((o0 + i / n * len) % len)!.position
  ];
  // ทิศ: shoelace บวก = ตามเข็มบนจอ (แกน y ลง) · ไม่ใช่ = กลับทิศ (คงจุดเริ่ม)
  var area = 0.0;
  for (var i = 0; i < n; i++) {
    area += pts[i].dx * pts[i + 1].dy - pts[i + 1].dx * pts[i].dy;
  }
  if (area < 0) pts = [pts.first, ...pts.sublist(1).reversed];
  return pts;
}

/// นาฬิกาจับเวลา (ถึงเวลาดูแล): ตัวกลม + ก้านและปุ่มบน + ปุ่มข้างเฉียงขวา · รวมเป็นเส้นรอบนอกเดียว
Path _erClockPath(Rect r) {
  final s = r.shortestSide;
  final c = Offset(r.center.dx, r.top + s * 0.56);
  final rad = s * 0.42;
  var p = Path()..addOval(Rect.fromCircle(center: c, radius: rad));
  Path rrect(Rect b, double rr) =>
      Path()..addRRect(RRect.fromRectAndRadius(b, Radius.circular(rr)));
  // ก้าน + ปุ่มกดบน
  p = Path.combine(
      PathOperation.union,
      p,
      rrect(
          Rect.fromCenter(
              center: Offset(c.dx, c.dy - rad - s * 0.04),
              width: s * 0.09,
              height: s * 0.12),
          s * 0.02));
  p = Path.combine(
      PathOperation.union,
      p,
      rrect(
          Rect.fromCenter(
              center: Offset(c.dx, c.dy - rad - s * 0.10),
              width: s * 0.24,
              height: s * 0.07),
          s * 0.035));
  // ปุ่มข้าง เฉียง 45° ขวาบน
  final side = rrect(
      Rect.fromCenter(center: Offset.zero, width: s * 0.10, height: s * 0.07),
      s * 0.02);
  final a = -math.pi / 4;
  final at = c + Offset(math.cos(a), math.sin(a)) * (rad + s * 0.02);
  final m4 = Matrix4.identity()
    ..translate(at.dx, at.dy)
    ..rotateZ(a + math.pi / 2);
  p = Path.combine(PathOperation.union, p, side.transform(m4.storage));
  return p;
}

/// ลูกศรกราฟดิ่งลง 3D (จากไฟล์ SVG ที่ผู้ใช้ให้มา 265×338): ชิ้นสันเข้ม + หน้าแดง
/// ท่าทาง: เผยจากหัวลงหาง (clip ไล่ตามแนวเฉียง) แล้วลอยขึ้นลง + เอียง perspective เล็กน้อย
/// ของของงานที่เลยเวลาในรอบ "ถึงเวลาดูแล" (ภาพ 3D ชุดเดียวกับหมวดคำสั่ง) หนึ่งชิ้นต่อประเภท
/// อยู่ในนาฬิกามุมขวาล่าง (เป็นส่วนของฉาก) ส่วนบนล้นพ้นขอบแล้วจาง · ป้ายแดง "เลย N นาที" ของประเภทนั้น
/// หลายประเภท = ขึ้นสลับทีละชิ้น (เลยนานสุดก่อน): เลื่อนออกจากหลังนาฬิกา ค้าง แล้วหลบกลับ
class _CareDueObject extends StatefulWidget {
  const _CareDueObject({super.key, required this.items});

  /// (ภาพ, ป้าย) เรียงเลยนานก่อน
  final List<(String, Widget)> items;
  @override
  State<_CareDueObject> createState() => _CareDueObjectState();
}

class _CareDueObjectState extends State<_CareDueObject>
    with SingleTickerProviderStateMixin {
  // หนึ่งรอบต่อชิ้น: ออก 0–0.2 · ค้าง · หลบกลับ 0.85–1 (ชิ้นเดียว = ออกแล้วค้าง)
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200));
  Timer? _wait;
  int _i = 0;

  bool get _multi => widget.items.length > 1;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((st) {
      if (st == AnimationStatus.completed && _multi && mounted) {
        setState(() => _i = (_i + 1) % widget.items.length);
        _c.forward(from: 0.0);
      }
    });
    _wait = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        final s = size.shortestSide;
        // ตัวกลมกลาง 0.56s รัศมี 0.42s ตาม _erClockPath
        // ของวางในนาฬิกามุมขวาล่าง (เป็นส่วนหนึ่งของฉาก) · ส่วนบนล้นพ้นขอบออกไปแบบหัวพยาบาล
        final cc = Offset(size.width / 2, s * 0.56);
        final rad = s * 0.42;
        const a = math.pi * 0.10, sz = 104.0;
        final dir = Offset(math.cos(a), math.sin(a));
        final home = cc + dir * (rad - sz * 0.30);
        final (img, tag) = widget.items[_i % widget.items.length];
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = _c.value;
            // gentle (design rule): ease นุ่ม ไม่เด้ง · เข้า 0–0.22 · ออก 0.84–1
            final inP =
                Curves.easeOutCubic.transform((v / 0.22).clamp(0.0, 1.0));
            final outP = !_multi
                ? 0.0
                : Curves.easeInOutCubic
                    .transform(((v - 0.84) / 0.16).clamp(0.0, 1.0));
            final k = inP * (1 - outP);
            // เข้า: ลอยขึ้นสั้น ๆ พร้อมจางเข้า · ออก: จางออกพร้อมจมลงนิด
            final c = home + Offset(0.0, (1 - k) * sz * 0.22);
            final op = k;
            final tagA =
                Curves.easeOut.transform(((v - 0.16) / 0.12).clamp(0.0, 1.0)) *
                    (1 - outP);
            Widget obj({bool fade = false}) => Positioned(
                  left: c.dx - sz / 2,
                  top: c.dy - sz * 0.58,
                  width: sz,
                  height: sz * 1.16,
                  child: Opacity(
                    opacity: op,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: fade
                          // ส่วนที่ล้นพ้นขอบ: จางลงช่วงกลางตัว (แบบภาพตัดหัวพยาบาล) ไม่เห็นรอยตัด
                          ? ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (r) => const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Color(0x00FFFFFF)
                                    ],
                                    stops: [0.0, 0.42, 0.62],
                                  ).createShader(r),
                              child: Image.asset(img, fit: BoxFit.contain))
                          : Image.asset(img, fit: BoxFit.contain),
                    ),
                  ),
                );
            return Stack(clipBehavior: Clip.none, children: [
              // ในนาฬิกา: ทั้งชิ้น (ตัดตามรูปนาฬิกาแบบภาพฉาก)
              Positioned.fill(
                child: ClipPath(
                  clipper: const _InClockClip(),
                  child: Stack(clipBehavior: Clip.none, children: [obj()]),
                ),
              ),
              // นอกนาฬิกา: เฉพาะส่วนบนที่ล้นออกไป
              Positioned.fill(
                child: ClipPath(
                  clipper: const _OutsideClockClip(),
                  child: Stack(
                      clipBehavior: Clip.none, children: [obj(fade: true)]),
                ),
              ),
              // ป้ายแดงล่างกลางในวงนาฬิกา: ไม่ทับขอบ ไม่ยื่นพ้นวง
              // ขอบล่างป้ายอยู่ที่ 0.58 รัศมีใต้จุดกลาง → กว้างได้ราว 1.6 รัศมี (คอร์ดของวงตรงนั้น)
              Positioned(
                left: cc.dx - rad * 0.8,
                width: rad * 1.6,
                bottom: size.height - (cc.dy + rad * 0.58),
                child: Center(
                  child: Opacity(
                    opacity: tagA,
                    child: Transform.translate(
                      offset: Offset(0.0, (1 - tagA) * 6.0),
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 6.0),
                        decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: tag,
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          },
        );
      });
}

/// ตัดตามรูปนาฬิกา (ชิ้นที่อยู่ในฉาก)
class _InClockClip extends CustomClipper<Path> {
  const _InClockClip();
  @override
  Path getClip(Size size) => _erClockPath(Offset.zero & size);
  @override
  bool shouldReclip(_InClockClip o) => false;
}

/// ตัดเฉพาะนอกตัวนาฬิกา (ส่วนที่ล้นพ้นขอบ)
class _OutsideClockClip extends CustomClipper<Path> {
  const _OutsideClockClip();
  @override
  Path getClip(Size size) => Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTRB(
            -400.0, -400.0, size.width + 400.0, size.height + 400.0)),
      _erClockPath(Offset.zero & size));
  @override
  bool shouldReclip(_OutsideClockClip o) => false;
}

class _TrendDownMark extends StatefulWidget {
  const _TrendDownMark({super.key, this.up = false});

  /// true = แนวโน้มดีขึ้น (เขียว พุ่งขึ้นขวา)
  final bool up;
  @override
  State<_TrendDownMark> createState() => _TrendDownMarkState();
}

class _TrendDownMarkState extends State<_TrendDownMark>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat();
  Timer? _wait;

  /// เริ่มหลังรูปทรง morph เป็นดาวเสร็จ (650 ms) + เว้นจังหวะนิด
  @override
  void initState() {
    super.initState();
    _wait = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _in.forward();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_in, _loop]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_in.value);
          final ph = _loop.value * math.pi * 2;
          // วาดจากหางที่แขนซ้ายไปถึงหัวที่ทะลุขอบขวา แล้วลอยขึ้นลงเบา ๆ
          return Transform.translate(
            offset: Offset(0.0, math.sin(ph) * 3.0),
            child: CustomPaint(painter: _TrendDownPainter(t, up: widget.up)),
          );
        },
      );
}

class _TrendDownPainter extends CustomPainter {
  const _TrendDownPainter(this.t, {this.up = false});
  final double t;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    // ลูกศรริบบอน 2.5D แบบ ref: ไกล (ต้นทาง) แคบ → ใกล้ (หัว) กว้าง = perspective
    // หน้าแดงอ่อนสว่าง · สันหนาด้านล่างขวาสีเข้ม (หนาตามระยะใกล้) · หัวใหญ่กว่าตัว
    final s = size.shortestSide;
    Offset q(double x, double y) =>
        Offset((size.width - s) / 2 + x * s, (size.height - s) / 2 + y * s);
    // ซิกแซกลงซ้าย: ท่อนยาว · ท่อนสั้นหักกลับ · ท่อนยาวถึงหัว
    // กลับซ้าย-ขวา: หางที่แขนขวาของดาว หัวพุ่งลงซ้ายทะลุขอบซ้าย
    // แย่ลง: ขวาบน → ซ้ายล่าง · ดีขึ้น: ซ้ายล่าง → ขวาบน (ซิกแซกแบบกราฟขึ้น)
    final pts = up
        // หางอยู่ในแขนล่างของดาว (ไม่ตัดผ่านร่องระหว่างแขน) · หัวออกซ้ายบน
        ? [q(0.80, 0.64), q(0.52, 0.48), q(0.40, 0.60), q(0.14, 0.36)]
        : [q(0.78, 0.20), q(0.56, 0.42), q(0.44, 0.32), q(0.16, 0.58)];
    final face = up ? const Color(0xFF5FD68C) : const Color(0xFFFF7A7A);
    final side = up ? const Color(0xFF1E8E3E) : const Color(0xFFC0182E);
    final lens = [
      for (var i = 0; i < pts.length - 1; i++) (pts[i + 1] - pts[i]).distance
    ];
    final total = lens.fold<double>(0, (a, b) => a + b);
    // ความกว้างครึ่งหนึ่ง/ความหนาตามระยะทาง (0 = ต้น · 1 = หัว)
    double halfAt(double u) => s * (0.035 + 0.035 * u);
    // หันอีกทาง: เห็นสันหนาด้านบน (กล้องมองจากใต้ลูกศร)
    Offset extAt(double u) => Offset(s * 0.012, s * 0.035) * (0.5 + 0.8 * u);
    final upto = total * Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    var acc = 0.0;
    var end = pts.first;
    var dir = const Offset(0, 1);
    var uEnd = 0.0;
    final faces = <Path>[], sides = <Path>[];
    for (var i = 0; i < pts.length - 1; i++) {
      if (acc >= upto) break;
      final a0 = pts[i], b0 = pts[i + 1];
      final d = (b0 - a0) / lens[i];
      final f = math.min(1.0, (upto - acc) / lens[i]);
      final b1 = a0 + d * lens[i] * f;
      final u0 = acc / total, u1 = (acc + lens[i] * f) / total;
      acc += lens[i];
      final n = Offset(-d.dy, d.dx);
      // ยืดต้นท่อนย้อนนิดให้ข้อพับต่อเนื่อง
      final a1 = i == 0 ? a0 : a0 - d * halfAt(u0);
      final quad = [
        a1 + n * halfAt(u0),
        b1 + n * halfAt(u1),
        b1 - n * halfAt(u1),
        a1 - n * halfAt(u0),
      ];
      faces.add(Path()..addPolygon(quad, true));
      sides.add(Path()
        ..addPolygon([
          quad[0] + extAt(u0),
          quad[1] + extAt(u1),
          quad[2] + extAt(u1),
          quad[3] + extAt(u0),
        ], true));
      end = b1;
      dir = d;
      uEnd = u1;
    }
    // หัวลูกศร: กว้าง 2.4 เท่าตัว ยาวพุ่งต่อทิศท่อนสุดท้าย
    final hk = ((t - 0.7) / 0.3).clamp(0.0, 1.0);
    if (hk > 0) {
      final n = Offset(-dir.dy, dir.dx);
      final hw = halfAt(1.0) * 2.1 * hk;
      final tip = end + dir * s * 0.13 * hk;
      final head = [end + n * hw, tip, end - n * hw];
      faces.add(Path()..addPolygon(head, true));
      sides.add(
          Path()..addPolygon([for (final p in head) p + extAt(1.0)], true));
    }
    // รวมทุกท่อน + หัวเป็นรูปเดียว (ไม่มีรอยต่อ) · สันใช้รูปรวมของสันทุกท่อน
    Path union(List<Path> ps) => ps.isEmpty
        ? Path()
        : ps
            .skip(1)
            .fold(ps.first, (a, b) => Path.combine(PathOperation.union, a, b));
    final faceAll = union(faces);
    final sideAll = union(sides);
    // ผนังเชื่อมหน้า→สัน: รูปรวมของหน้าเลื่อนทีละนิดจนถึงสัน (ทึบต่อเนื่อง)
    const steps = 10;
    for (var k = steps; k >= 1; k--) {
      final f = k / steps;
      canvas.drawPath(faceAll.shift(extAt(0.8) * f), Paint()..color = side);
    }
    canvas.drawPath(sideAll, Paint()..color = side);
    canvas.drawPath(faceAll, Paint()..color = face);
    canvas.drawPath(
        faceAll,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeJoin = StrokeJoin.round);
    if (uEnd < 0) return;
  }

  @override
  bool shouldRepaint(_TrendDownPainter o) => o.t != t;
}

/// ไอคอนปุ่มเลือกระดับ ESI (Figma 642:77): พีระมิดแถบสี 4 ชั้น + วงกรองฟ้ามุมขวาล่าง
/// ปรากฏ: แถบเลื่อนเข้าจากซ้ายทีละชั้น (ล่างขึ้นบน) แล้ววงกรองเด้งขึ้น
class _EsiLevelIcon extends StatefulWidget {
  const _EsiLevelIcon();
  @override
  State<_EsiLevelIcon> createState() => _EsiLevelIconState();
}

class _EsiLevelIconState extends State<_EsiLevelIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28.0,
        height: 23.0,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _EsiLevelPainter(_c.value)),
        ),
      );
}

class _EsiLevelPainter extends CustomPainter {
  const _EsiLevelPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // พิกัดจาก Figma (กรอบ 512) เฉพาะส่วนภาพ x 104–425 · y 134–393
    const ox = 104.0, oy = 134.0, bw = 321.0, bh = 259.0;
    final k = math.min(size.width / bw, size.height / bh);
    Offset p(double x, double y) => Offset((x - ox) * k, (y - oy) * k);
    // แถบพีระมิด: (x, y, กว้าง, สูง, สี) ล่าง → บน · ข้างเฉียงเข้าด้านบน
    const bars = [
      (104.7, 306.0, 176.6, 50.7, Color(0xFFE64A45)),
      (131.8, 248.1, 180.7, 47.6, Color(0xFFFA8231)),
      (157.5, 190.4, 145.3, 47.5, Color(0xFFFBBC2C)),
      (182.2, 134.4, 96.1, 45.1, Color(0xFF34A853)),
    ];
    for (var i = 0; i < bars.length; i++) {
      final (x, y, w, h, col) = bars[i];
      final a =
          Curves.easeOutCubic.transform(((t - i * 0.12) / 0.5).clamp(0.0, 1.0));
      if (a <= 0) continue;
      const slant = 13.0;
      final r = 8.0 * k;
      final dx = -18.0 * (1.0 - a) * k * 3;
      final path = Path()
        ..moveTo(p(x + slant, y).dx + r + dx, p(x, y).dy)
        ..lineTo(p(x + w - slant, y).dx - r + dx, p(x, y).dy)
        ..quadraticBezierTo(p(x + w - slant, y).dx + dx, p(x, y).dy,
            p(x + w - slant, y).dx + dx + r * 0.3, p(x, y).dy + r)
        ..lineTo(p(x + w, y + h).dx + dx, p(x, y + h).dy - r)
        ..quadraticBezierTo(p(x + w, y + h).dx + dx, p(x, y + h).dy,
            p(x + w, y + h).dx + dx - r, p(x, y + h).dy)
        ..lineTo(p(x, y + h).dx + dx + r, p(x, y + h).dy)
        ..quadraticBezierTo(p(x, y + h).dx + dx, p(x, y + h).dy,
            p(x, y + h).dx + dx + r * 0.3, p(x, y + h).dy - r)
        ..lineTo(p(x + slant, y).dx + dx - r * 0.3, p(x, y).dy + r)
        ..quadraticBezierTo(p(x + slant, y).dx + dx, p(x, y).dy,
            p(x + slant, y).dx + dx + r, p(x, y).dy)
        ..close();
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: a));
    }
    // วงกรอง: ขอบขาวคั่น + พื้นฟ้าอ่อน + กรวยฟ้า · เด้งขึ้นหลังแถบ
    final b = Curves.easeOutBack.transform(((t - 0.45) / 0.55).clamp(0.0, 1.0));
    if (b > 0) {
      final c = p(282.7 + 70.9, 251.1 + 70.9);
      final rad = 70.9 * k * b;
      canvas.drawCircle(c, rad + 9.0 * k, Paint()..color = Colors.white);
      canvas.drawCircle(c, rad, Paint()..color = const Color(0xFFD3E3FD));
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(b);
      final f = Path()
        ..moveTo(-41.0 * k, -34.0 * k)
        ..lineTo(41.0 * k, -34.0 * k)
        ..lineTo(9.0 * k, 4.0 * k)
        ..lineTo(9.0 * k, 44.0 * k)
        ..lineTo(-9.0 * k, 34.0 * k)
        ..lineTo(-9.0 * k, 4.0 * k)
        ..close();
      canvas.drawPath(
          f,
          Paint()
            ..color = const Color(0xFF4285F4)
            ..strokeJoin = StrokeJoin.round);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EsiLevelPainter o) => o.t != t;
}

/// พื้นที่ที่ลูกศรมองเห็น: ภายในดาว ∪ ด้านซ้ายล่างนอกดาว (ให้หัวลูกศรโผล่ทะลุกรอบ)
/// star = กรอบดาวในพิกัดของกล่องลูกศร
class _TrendClip extends CustomClipper<Path> {
  const _TrendClip(this.star, {this.up = false});
  final Rect star;

  /// true = เปิดมุมขวาบนนอกดาว (ลูกศรขึ้น) · false = มุมซ้ายล่าง
  final bool up;
  @override
  Path getClip(Size size) => Path.combine(
      PathOperation.union,
      _erStarPath(star),
      Path()
        ..addRect(up
            // เปิดทั้งฝั่งซ้ายของดาว: หัวลูกศรทะลุออกได้เต็มรูป ไม่ถูกขอบแขนตัด
            ? Rect.fromLTRB(-400.0, -400.0, star.center.dx - star.width * 0.08,
                size.height + 400.0)
            : Rect.fromLTRB(-400.0, star.center.dy + star.height * 0.12,
                star.center.dx - star.width * 0.12, size.height + 400.0)));
  @override
  bool shouldReclip(_TrendClip o) => o.star != star || o.up != up;
}

/// กราฟเส้นเล็กของสัญญาณชีพทุกรอบ (จุดสุดท้ายเด่น)
class _OvSpark extends CustomPainter {
  const _OvSpark(this.v, this.col, {this.lo, this.hi});
  final List<double> v;
  final Color col;

  /// ช่วงปกติ: แถบเขียวจาง + เส้นประขอบที่ใกล้ข้อมูล · null = ไม่แสดง
  final double? lo, hi;
  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
    // สเกลตามข้อมูล (เห็นความชันชัด) ขยายรวมขอบช่วงปกติที่อยู่ใกล้ ๆ
    var mn = v.reduce(math.min), mx = v.reduce(math.max);
    final span0 = math.max(mx - mn, 1e-6);
    if (lo != null && lo! < mn && mn - lo! < span0 * 1.2) mn = lo!;
    if (hi != null && hi! > mx && hi! - mx < span0 * 1.2) mx = hi!;
    final pad = (mx - mn) * 0.18 + 1e-6;
    mn -= pad;
    mx += pad;
    double y(double x) => size.height * (1.0 - (x - mn) / (mx - mn));
    final bounds = Offset.zero & size;
    canvas.save();
    canvas
        .clipRRect(RRect.fromRectAndRadius(bounds, const Radius.circular(4.0)));
    // ช่วงปกติ: แถบเขียวจาง + เส้นประที่ขอบ
    if (lo != null && hi != null) {
      final top = y(hi!).clamp(0.0, size.height),
          bot = y(lo!).clamp(0.0, size.height);
      if (bot > top) {
        canvas.drawRect(Rect.fromLTRB(0, top, size.width, bot),
            Paint()..color = const Color(0xFF1E8E3E).withValues(alpha: 0.07));
      }
      for (final b in [hi!, lo!]) {
        final yy = y(b);
        if (yy <= 0 || yy >= size.height) continue;
        for (var x = 0.0; x < size.width; x += 5.0) {
          canvas.drawLine(
              Offset(x, yy),
              Offset(x + 2.5, yy),
              Paint()
                ..color = const Color(0xFF1E8E3E).withValues(alpha: 0.45)
                ..strokeWidth = 1.0);
        }
      }
    }
    Offset at(int i) =>
        Offset(4.0 + (size.width - 8.0) * i / (v.length - 1), y(v[i]));
    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < v.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    // พื้นใต้เส้นไล่จาง
    final area = Path.from(line)
      ..lineTo(at(v.length - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [col.withValues(alpha: 0.22), col.withValues(alpha: 0.0)],
          ).createShader(bounds));
    canvas.restore();
    canvas.drawPath(
        line,
        Paint()
          ..color = col
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);
    for (var i = 0; i < v.length - 1; i++) {
      canvas.drawCircle(at(i), 2.0, Paint()..color = Colors.white);
      canvas.drawCircle(
          at(i),
          2.0,
          Paint()
            ..color = col.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }
    canvas.drawCircle(at(v.length - 1), 4.0, Paint()..color = Colors.white);
    canvas.drawCircle(at(v.length - 1), 3.0, Paint()..color = col);
  }

  @override
  bool shouldRepaint(_OvSpark o) => o.v != v || o.col != col;
}
