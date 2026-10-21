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
  Widget _boardViewToggle({bool bare = false}) {
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
      // หัวข้อ "รายชื่อผู้ป่วย" อยู่ใน pill เดียวกับปุ่มสลับมุมมอง
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(bare ? 10.0 : 12.0, 0.0, 8.0, 0.0),
          child: Text('รายชื่อผู้ป่วย',
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
        ),
        seg(false, Icons.grid_view_rounded, 'การ์ด'),
        seg(true, Icons.table_rows_rounded, 'ตาราง'),
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
    final steps = [
      0,
      for (final e in _Esi.values)
        if ((n[e] ?? 0) > 0) e.level,
    ];
    final manual = _ovDbg || _boardEsi != null || _boardFt;
    return _OvCycle(
        count: steps.length,
        paused: manual,
        builder: (k) => LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              final cur = _ovDbg
                  ? _ovDbgCur
                  : manual
                      ? (_boardEsi ?? 0)
                      : steps[k % steps.length];
              final ce = cur <= 0 ? null : _Esi.values[cur - 1];
              final alertStep = cur == -1;
              // ฉากพื้นสว่างแบบแอป (ขาว → _bg) ตัวเลขกรมท่า เส้น _line
              // แสงฟุ้ง immersive ตามรอบ: ภาพรวม = กรมท่า · ESI = สีระดับ (เปลี่ยนสีแบบจางข้าม)
              final tint = alertStep ? _red : (ce?.color ?? _blue);
              if (_ovTint.value != tint) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _ovTint.value = tint);
              }
              final cx = w / 2, cy = 140.0;
              const big = 232.0, inner = big - 68.0;
              // ฉากในวงต่อรอบ: ESI 5 = นั่งเล่นมือถือรอ (Figma 577:91) · ESI 4 = นั่งรอหน้าเคาน์เตอร์ (577:95) · ESI 3 = รถเข็นผู้ป่วย (577:103) · ESI 2 = ทีมเข็นเปล (569:81) · ESI 1 = พยาบาลดูแลผู้ป่วยบนเตียง (577:100) · อื่น ๆ = เตียง ER (564:26)
              // (ภาพเต็ม, ภาพตัดพื้นหลัง, ขนาดกรอบ, เลื่อน x/y จากจุดกลาง, เงาพื้น: กลาง x / กว้าง / y ตามสัดส่วนกรอบ)
              final sc = cur == 5
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
                  : cur == 4
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
                      : cur == 3
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
                          : cur == 2
                              ? (
                                  // ทีมเข็นเปลลงจากรถพยาบาล (Figma 569:81): ทั้งภาพในวง ล้นออกเฉพาะหัวบุรุษพยาบาล
                                  img: 'assets/images/er_ov_emergent.jpg',
                                  pop: 'assets/images/er_ov_emergent_pop.png',
                                  size: 367.0,
                                  dx: -157.0,
                                  dy: -208.0,
                                  shX: 0.17,
                                  shW: 0.0,
                                  shY: 0.9,
                                )
                              : cur == 1
                                  ? (
                                      // พยาบาลดูแลผู้ป่วยบนเตียง (Figma 577:100): ล้นออกเฉพาะหัวพยาบาลและหัวผู้ป่วย
                                      img: 'assets/images/er_ov_resus.jpg',
                                      pop: 'assets/images/er_ov_resus_pop.png',
                                      size: 256.0,
                                      dx: -125.0,
                                      dy: -134.0,
                                      shX: 0.0,
                                      shW: 0.0,
                                      shY: 0.0,
                                    )
                                  : (
                                      img: 'assets/images/er_ov_bed.jpg',
                                      pop: 'assets/images/er_ov_bed_pop.png',
                                      size: 250.0,
                                      dx: -124.0,
                                      dy: -129.0,
                                      shX: 0.6,
                                      shW: 120.0,
                                      shY: 0.86,
                                    );
              final tune = _ovTune[sc.img] ?? (sc.size, sc.dx, sc.dy);
              final imgS = tune.$1, imgL = cx + tune.$2, imgT = cy + tune.$3;
              void setTune(double size, double dx, double dy) =>
                  setState(() => _ovTune[sc.img] = (
                        size.clamp(100.0, 420.0).roundToDouble(),
                        dx.roundToDouble(),
                        dy.roundToDouble()
                      ));
              // ขวา: สายรัดข้อมือ ESI (ชิ้นเดียวกับการ์ดผู้ป่วย) กว้างเท่ากันทุกระดับ ป้ายชิดซ้าย (จำนวนดูที่ตัวเลขใหญ่ซ้าย)
              // รอบที่วนถึง/ที่กรอง = เลื่อนออกซ้าย + เรืองสีระดับ · กรองอยู่ = ระดับอื่นจาง
              Widget esiRow(_Esi e) {
                final on = _boardEsi == e.level;
                final hi = on || (!manual && cur == e.level);
                final dim = manual && !on;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _Press(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _boardEsi = on ? null : e.level);
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: dim ? 0.45 : 1.0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeOutCubic,
                          offset: Offset(hi ? -0.06 : 0.0, 0.0),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 360),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: hi
                                          ? const Color(0x1F0B1B3F)
                                          : Colors.transparent,
                                      blurRadius: 14.0),
                                ],
                              ),
                              child: SizedBox(
                                height: 28.0,
                                child: FittedBox(
                                    child: _esiBand(null, e.color,
                                        esi: e, width: 124.0)),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                );
              }

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
                // ---- ซ้าย: ตัวเลขใหญ่ของรอบนั้น
                Positioned(
                  left: 24.0,
                  top: cy - 70.0,
                  width: math.max(130.0, cx - big / 2 - 34.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (c, prev) => Stack(
                        alignment: Alignment.topLeft,
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
                    child: GestureDetector(
                        key: ValueKey(cur),
                        behavior: HitTestBehavior.opaque,
                        onTap: alertStep
                            ? () => setState(() => _alertsOpen = true)
                            : null,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  alertStep
                                      ? 'แจ้งเตือนวิกฤต'
                                      : ce == null
                                          ? 'ห้องฉุกเฉินตอนนี้'
                                          : 'ESI ${ce.level}',
                                  style: _t(13.0,
                                      color: _ink3, weight: FontWeight.w600)),
                              Text(
                                  '${alertStep ? hot.length : ce == null ? all.length : n[ce]}',
                                  // สีเดียวกับระดับ (ภาพรวม = กรมท่า) · ESI 3 ส้มเข้มขึ้นให้อ่านออกบนพื้นอ่อน (แบบ _esiBand)
                                  style: _num(64.0,
                                      color: alertStep
                                          ? _red
                                          : ce == null
                                              ? _blue
                                              : ce.level == 3
                                                  ? Color.lerp(ce.color,
                                                      Colors.black, 0.25)!
                                                  : ce.color,
                                      weight: FontWeight.w800)),
                              Text(
                                  alertStep
                                      ? 'รายการต้องดู'
                                      : ce == null
                                          ? 'ผู้ป่วยทั้งหมด'
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
                                      : ce == null
                                          ? 'วิกฤตและฉุกเฉิน ${(n[_Esi.one] ?? 0) + (n[_Esi.two] ?? 0)} ราย'
                                          : '${(100 * (n[ce] ?? 0) / math.max(1, all.length)).round()}% ของผู้ป่วยในห้อง',
                                  style: _t(12.5,
                                      color: _ink2, weight: FontWeight.w500)),
                            ])),
                  ),
                ),
                // ---- กลาง: วงแก้ว + donut + ภาพเตียงในวง (แตะ = ล้างตัวกรอง)
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
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _panel,
                        border: Border.all(color: _line),
                      ),
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
                                  cur)),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeInOutCubic,
                          builder: (context, knob, child) => CustomPaint(
                            foregroundPainter: _EsiDonutPainter(
                              counts: [for (final e in _Esi.values) n[e] ?? 0],
                              colors: [for (final e in _Esi.values) e.color],
                              sel: cur <= 0 ? null : cur,
                              t: t,
                              knob: knob,
                            ),
                            child: child,
                          ),
                          child: child,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          // ภาพห้อง ER (Figma 564:26) ตัดในวง · ตำแหน่งเดียวกับชั้นเตียงที่ล้นออก
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEEF2F8),
                            ),
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
                                                  weight: FontWeight.w800))),
                                    )
                                  : Stack(
                                      key: ValueKey(sc.img),
                                      clipBehavior: Clip.none,
                                      children: [
                                          Positioned(
                                            left: imgL - (cx - inner / 2),
                                            top: imgT - (cy - inner / 2),
                                            width: imgS,
                                            height: imgS,
                                            child: Image.asset(sc.img,
                                                fit: BoxFit.cover),
                                          ),
                                        ]),
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
                      child: alertStep
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
                                    child:
                                        Image.asset(sc.pop, fit: BoxFit.cover),
                                  ),
                                ]),
                    ),
                  ),
                ),
                // ---- ขวา: สายรัดข้อมือ ESI ชิดขวา (แตะ = กรอง หยุดวน)
                Positioned(
                  right: 24.0,
                  top: cy - 86.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final e in _Esi.values) esiRow(e),
                      ]),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38.0,
            padding: const EdgeInsets.fromLTRB(3.0, 3.0, 12.0, 3.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: mine
                    ? CircleAvatar(
                        key: const ValueKey('me'),
                        radius: 16.0,
                        backgroundImage: AssetImage(me.face))
                    : const CircleAvatar(
                        key: ValueKey('all'),
                        radius: 16.0,
                        backgroundColor: Color(0xFFE8ECF6),
                        child: Icon(Icons.groups_rounded,
                            size: 19.0, color: _blue)),
              ),
              const SizedBox(width: 8.0),
              Text(mine ? 'ผู้ป่วยของฉัน' : 'ผู้ป่วยทั้งหมด',
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                height: 22.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text('$n',
                    style: _num(12.5,
                        color: Colors.white, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.swap_horiz_rounded, size: 18.0, color: _ink3),
            ]),
          ),
        ),
      ),
    );
  }

  /// ชิปกลุ่มย่อย Fast track (แฟ้มที่มีผู้ป่วย) งอกออกทางขวาของปุ่ม Fast track
  /// ยืดความกว้าง + จาง เลื่อนเข้าจากขวา · เลือก = พื้นแดง ตัวขาว
  Widget _ftTypeChips(List<_P> all, double maxW) {
    Widget chip(String? id, String label, int n) {
      final on = _boardFtType == id;
      return Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: _Press(
          child: GestureDetector(
            // แตะซ้ำ = เลิกกรองกลุ่ม (กลับเป็นทุกกลุ่ม)
            onTap: () => setState(() => _boardFtType = on ? null : id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 34.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? _ftRed : const Color(0xFFFCE8E6),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(label,
                    style: _t(13.0,
                        color: on ? Colors.white : _ftRed,
                        weight: FontWeight.w600)),
                const SizedBox(width: 5.0),
                Text('$n',
                    style: _num(12.5,
                        color: on ? Colors.white : _ftRed,
                        weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );
    }

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
              // เลื่อนแนวนอนได้ ไม่ล้นทับแท็บซ้าย
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: math.max(0.0, maxW)),
                // ขอบซ้าย/ขวาฟุ้งจาง (บอกว่าเลื่อนต่อได้)
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0x00FFFFFF),
                  ], stops: [
                    0.0,
                    0.02,
                    0.92,
                    1.0
                  ]).createShader(r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 2.0, right: 14.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      for (final t in erFastTracks)
                        if (ftAll.any((p) => _ftOf(p.hn).containsKey(t.id)))
                          chip(
                              t.id,
                              t.name,
                              ftAll
                                  .where((p) => _ftOf(p.hn).containsKey(t.id))
                                  .length),
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
        onTap: () => setState(() {
          _boardFt = !_boardFt;
          _boardFtType = null;
        }),
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
                                height: 32.0,
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
                const h = 276.0;
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
                          height: 276.0,
                          child: Stack(children: [
                            Positioned.fill(child: _ovCircles(all)),
                            // แพทย์: ผู้ป่วยของฉัน | ทั้งหมด · ปุ่มกลม มุมซ้ายบนของฉาก
                            Positioned(
                                left: 20.0,
                                top: 16.0,
                                child: _boardMineToggle(all)),
                            // แจ้งเตือน: มุมขวาบน
                            Positioned(
                              right: 20.0,
                              top: 16.0,
                              child: Tooltip(
                                  message: 'แจ้งเตือน',
                                  child: _Press(child: _alertBellButton())),
                            ),
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
                                          2.0, 4.0, 0.0, 0.0),
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                        color: _panel,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0)),
                                      ),
                                      child: _boardViewToggle(bare: true),
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
                        child: LayoutBuilder(builder: (context, box) {
                          final alertHn = _footAlertHn;
                          if (_boardTable) {
                            // การ์ดเว้นขวา 6 · ตารางเว้นขวา 16 เท่าหัวตาราง
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: 10.0, bottom: 40.0),
                              child: Builder(builder: (_) {
                                final sorted = _tblSorted(list);
                                final pages = (sorted.length / _tblPer).ceil();
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final (e, ps) in groups) ...[
                                      if (e != groups.first.$1)
                                        const SizedBox(height: 16.0),
                                      _SectionIn(
                                        index:
                                            groups.indexWhere((g) => g.$1 == e),
                                        child: _esiSection(
                                            e,
                                            ps,
                                            (cw) => [
                                                  for (final p in ps)
                                                    SizedBox(
                                                      height: cardH,
                                                      child: _footCard(p,
                                                          alertHn: alertHn,
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
      this.knob = 0.0});
  final List<int> counts;
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
    final total = counts.fold<int>(0, (a, b) => a + b);
    const w = 6.0;
    final r = size.shortestSide / 2 - 10.0;
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: r);
    const top = -math.pi / 2;
    // ราง
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    if (total == 0) return;
    // จุดสีไล่ต่อเนื่อง: แต่ละระดับคงสีกลางช่อง ผสมกันที่รอยต่อ (soft 18% ของช่องที่แคบกว่า)
    final cols = <Color>[], stops = <double>[];
    var acc = 0.0;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      final a = acc / total, b = (acc + counts[i]) / total;
      final soft = (b - a) * 0.18;
      cols
        ..add(colors[i])
        ..add(colors[i]);
      stops
        ..add(a + soft)
        ..add(b - soft);
      acc += counts[i];
    }
    if (cols.isNotEmpty) {
      cols.insert(0, cols.first);
      stops.insert(0, 0.0);
      cols.add(cols.last);
      stops.add(1.0);
    }
    final sweep = math.pi * 2 * t;
    final shader = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      colors: cols,
      stops: stops,
      transform: const GradientRotation(top),
    ).createShader(rect);
    // เส้นไล่สีเรียบ ไม่มีแสงฟุ้ง (clean)
    canvas.drawArc(
        rect,
        top,
        sweep,
        false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round);
    // ระดับที่เลือก: ช่วงนั้นหนาขึ้น (สีระดับทึบ) เรืองแรงขึ้น
    if (sel != null && counts[sel! - 1] > 0 && t >= 1.0) {
      var a0 = 0;
      for (var i = 0; i < sel! - 1; i++) {
        a0 += counts[i];
      }
      final st = top + a0 / total * math.pi * 2;
      final sw = counts[sel! - 1] / total * math.pi * 2;
      final col = colors[sel! - 1];
      canvas.drawArc(
          rect,
          st,
          sw,
          false,
          Paint()
            ..color = col
            ..style = PaintingStyle.stroke
            ..strokeWidth = w + 3.0
            ..strokeCap = StrokeCap.round);
    }
    // หัวชี้: จุดขาว ขอบสีตามตำแหน่ง + เงา
    if (t >= 1.0) {
      final p = c + Offset(math.cos(top + knob), math.sin(top + knob)) * r;
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
      o.counts.join() != counts.join();
}

/// ตัวนับรอบวนอัตโนมัติของภาพรวม (ค้างรอบละ 5 วินาที) · paused = ค้างไว้ (ผู้ใช้กรองเอง)
class _OvCycle extends StatefulWidget {
  const _OvCycle(
      {required this.count, required this.paused, required this.builder});
  final int count;
  final bool paused;
  final Widget Function(int k) builder;
  @override
  State<_OvCycle> createState() => _OvCycleState();
}

class _OvCycleState extends State<_OvCycle> {
  int _k = 0;
  Timer? _t;

  /// ตั้งเวลาใหม่ทุกรอบ (one-shot) ทุกรอบรวมภาพรวมค้างครบ 5 วิ ไม่ถูกตัดสั้นด้วยจังหวะ periodic
  void _arm() {
    _t?.cancel();
    if (widget.paused || widget.count < 2) return;
    _t = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _k = (_k + 1) % widget.count);
      _arm();
    });
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
      _t?.cancel();
    } else if (old.count != widget.count) {
      _arm();
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_k);
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
          const Icon(Icons.notifications_rounded, size: 96.0, color: _red),
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
    return ClipRect(
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
