// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientOrdersTabState on State<ErFlowHomeWidget> {
  String _template = 'Sepsis';
  final Set<String> _orderPicked = {
    'Piperacillin + Tazobactam 4.5 g',
    '0.9% NSS 1,000 mL',
    'Blood culture ×2',
    'CBC',
    'BUN / Cr',
    'Lactate',
    'Chest X-ray',
    'Oxygen cannula 3 L/min',
    // ใบ sepsis ที่แพทย์ติ๊กจริง (One Day)
    'CBC, BUN, Cr, Electrolyte',
    'DTX',
    'LFT',
    'PT, PTT, INR',
    'Hemoculture × 2',
    'UA, U/C',
    'CXR',
    'Record V/S, I/O',
  };
  int _followTab = 0;

  /// ใบคำสั่ง (generative task list): รายการที่ติ๊ก (ชุด|ข้อความ) + ค่าในช่องเว้นว่าง
  final Set<String> _soTick = {};
  final Map<String, String> _soBlank = {};

  /// สลับแผงซ้ายไปแท็บคำสั่งแพทย์แล้วของเคสไหน (เข้าขั้นสั่งการรักษาครั้งแรก)
  String? _soTabAuto;

  /// หน้าคำสั่งแพทย์ (Figma 331-350): แฟ้มที่เปิดอยู่ 0 Progress Note 1 One Day 2 Continuation
  int _soOpen = 0;

  /// หัวแฟ้มแต่ละใบ (ใช้เลื่อนให้แฟ้มที่เปิดชิดบนจอ)
  final Map<int, GlobalKey> _soFolderKeys = {};

  /// เคส (HN) ที่สั่งต่อจากคำสั่งเดิม: รายการเดิมติ๊กไว้พร้อมสถานะ · เพิ่มรายการใหม่ / ยกเลิกรายการที่ยังไม่ทำ
  final Set<String> _soContHn = {};

  /// หน้าย่อย "เลือกชุด" ของขั้น Order Set เปิดอยู่
  bool _soPickOpen = false;

  /// ชุดที่กาง/หุบรายละเอียดเอง (ค่าเริ่ม: ชุดที่ใช้อยู่กาง ชุดอื่นหุบ)
  final Map<String, bool> _soPickExpand = {};

  /// เคสที่กด "AI แนะนำ" แล้ว (HN) · ยังไม่กด = ไม่แสดงการ์ดชุดแนะนำ (AI ไม่ทำเอง P8)
  final Set<String> _soRecAsked = {};

  /// กำลังวิเคราะห์ชุดแนะนำ (HN) · ขั้นที่กำลังทำ (0..2) แสดงทีละบรรทัด
  final Set<String> _soRecBusy = {};
  int _soRecStep = 0;

  /// เลือกชุดแล้ว: แสดงเฉพาะชุดที่เลือก (ขึ้นบนสุด) ซ่อนชุดอื่น · "ดูชุดอื่น" = แสดงทั้งหมด
  bool _soPickFocus = false;

  /// เคสที่แพทย์เลือก Order Set แล้วในรอบนี้ (HN) · ยังไม่เลือก = แผงซ้ายไม่แสดงสำรับ
  final Set<String> _soSetPicked = {};

  /// หัวข้อ Progress Note ที่ติ๊กแล้ว ('ชุด|หัวข้อ')
  final Set<String> _soPnPick = {
    'Sepsis|SIRS criteria (2 ใน 4 ข้อ)',
    'Sepsis|ตำแหน่งติดเชื้อที่พบ',
  };

  /// สำรับการ์ดฝั่งซ้าย: คำสั่งที่กำลังระบุรายละเอียด + หมายเหตุ + ต้องวัดซ้ำ (key = id รายการ)
  String? _soFocus;

  /// รายการที่เปิดหน้ากรอกรายละเอียดในแผงขวา (หน้าย่อยของแฟ้ม)
  String? _soEdit;
  final Map<String, String> _soNote = {};

  /// นับครั้งที่แตะหมายเหตุด่วน: เปลี่ยน key ช่องพิมพ์ให้แสดงข้อความที่เติมให้
  int _soNoteRev = 0;

  /// หมวดที่แพทย์แก้ต่อคำสั่ง (หนึ่งคำสั่งเป็นได้หลายหมวด เช่น oth + M)
  final Map<String, Set<String>> _soCats = {};

  /// แท็บในการ์ด (0 รายการย่อย 1 วัดซ้ำ 2 หมายเหตุ) และคำสั่งที่ยืนยันแล้ว
  final Map<String, int> _soTab = {};
  final Set<String> _soDone = {};

  /// การ์ดที่กำลังแก้หมวด (เปิดตัวเลือกครบ)
  String? _soCatEdit;

  /// รายการที่ Dr.Note กรอกให้ รอแพทย์ยอมรับ/แก้ทีละรายการ · กำลังกรอกอยู่ไหม
  final Set<String> _soAi = {};
  bool _soAiBusy = false;

  /// ตัวเลือกย่อยที่ติ๊ก (หัวข้อ Progress Note) และค่าในช่องเว้นว่าง ('id|ช่อง')
  /// ค่าเริ่ม = ใบ sepsis ที่แพทย์กรอกจริง (ภาพเอกสาร): SIRS ข้อไข้ · ติดเชื้อที่ปอดและช่องท้อง
  final Map<String, Set<String>> _soOpt = {
    'Sepsis|SIRS criteria (2 ใน 4 ข้อ)': {'T > 38 °C หรือ < 36 °C'},
    'Sepsis|ตำแหน่งติดเชื้อที่พบ': {'Pulmonary', 'Abdominal'},
  };
  final Map<String, String> _soVal = {
    'DTX|ผล': '142',
    'Hemoculture × 2|เวลาเจาะ': '10:32',
    'Record V/S, I/O|ทุก': '15',
  };
  final Set<String> _soRepeat = {};

  /// ตั้งค่าวัดซ้ำ: (ทุกกี่นาที, กี่รอบ) · รอบ 0 = ต่อเนื่องจนแพทย์สั่งหยุด
  final Map<String, (int, int)> _soRepeatCfg = {};

  /// แถวชุดที่ใช้บ่อย (เลื่อนแนวนอน) · ปุ่มถัดไปเลื่อนทีละใบ
}

extension _FeaturesPatientOrdersTabPart on _ErFlowHomeWidgetState {
  // ---------------------------------------------- คำสั่งแพทย์ (Order set)

  /// คอลัมน์ซ้าย: เลือกชุดคำสั่ง แล้วติ๊กรายการ
  Widget _orderLeft() => SizedBox(
        width: 400.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
          children: _orderLeftItems(),
        ),
      );

  /// เนื้อหาคอลัมน์ซ้ายของคำสั่งแพทย์ (ใช้ทั้งแบบลอยและในการ์ดขวา)
  List<Widget> _orderLeftItems() => [
        _orderSetPicker(),
        ..._orderGroupsAndSave(),
      ];

  /// รายการคำสั่งตามกลุ่ม (ยา/เลือด/แล็บ/...) + ปุ่มบันทึกคำสั่ง
  List<Widget> _orderGroupsAndSave({bool save = true}) => [
        // ประเภทที่มี template แบบ progress note ไม่ใช้ชุดติ๊กในหน้านี้
        if ((_orderTemplatesOf[_template] ?? const [])
            .every((t) => t.$1 == 'inline')) ...[
          for (final g in _orderGroups) _orderGroupCard(g),
          if (save) _orderSaveBtn(),
        ],
      ];

  /// การ์ดกลุ่มคำสั่ง ภาษาเดียวกับแผงวินิจฉัย (2026-10-22): ขาว ขอบบาง มุม 16
  /// หัว = ไอคอนกรมท่า + ชื่อ 17 หนา + จำนวนที่เลือก · เนื้อหาใต้หัวในการ์ดเดียวกัน
  Widget _stackCard({
    required String title,
    IconData? icon,
    String? count,
    Widget? trailing,
    Color band = _blue,
    EdgeInsets pad = const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 6.0),
            child: Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 20.0, color: band),
                const SizedBox(width: 8.0),
              ],
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              if (count != null) ...[
                const SizedBox(width: 6.0),
                Text(count,
                    style: _num(13.0, color: _ink2, weight: FontWeight.w600)),
              ],
              if (trailing != null) trailing,
            ]),
          ),
          Padding(padding: pad, child: child),
        ]),
      );

  /// การ์ดเลือก Order Set แบบ preset: ชื่อชุดที่ใช้อยู่ + ภาพแฟ้มซ้อนขวา
  /// action เดียว = แตะเพื่อเปิด sheet เลือกชุด (P9 หนึ่งแผงหนึ่ง action)
  Widget _orderSetPicker() => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 6.0),
              child: Text('STANDING ORDER',
                  style: _t(10.5, color: _ink3, weight: FontWeight.w600)
                      .copyWith(letterSpacing: 0.8)),
            ),
            _Press(
              scale: 0.98,
              child: GestureDetector(
                onTap: _orderSetSheet,
                child: Container(
                  height: 84.0,
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: _line, width: 0.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(children: [
                    const Positioned(
                      right: 14.0,
                      top: 10.0,
                      bottom: -18.0,
                      width: 132.0,
                      child: _PresetStack(),
                    ),
                    Positioned(
                      left: 18.0,
                      top: 0.0,
                      bottom: 0.0,
                      right: 150.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_template,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(17.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          const SizedBox(height: 2.0),
                          Text('ดูและเลือกชุดคำสั่ง',
                              style: _t(12.0,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      );

  /// sheet เลือก Order Set: การ์ดทุกชุด แตะแล้วปิด sheet
  void _orderSetSheet() {
    HapticFeedback.selectionClick();
    _placedSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
          maxWidth: 580.0,
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 28.0),
        decoration: const BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('เลือก Standing Order',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text('ชุดคำสั่งตามโรค เลือกแล้วติ๊กเฉพาะรายการที่ต้องการ',
                style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            const SizedBox(height: 6.0),
            _tplPicker(onPicked: () => Navigator.of(ctx).pop()),
          ],
        ),
      ),
    );
  }

  /// หน้า Order Set ใน workflow (Figma 330-2): การ์ดใหญ่เลือกชุด · ที่ใช้บ่อย · ชุดทั้งหมด
  /// การติ๊กรายการจริงอยู่ในหน้าย่อยของ stepper (ยา / Lab / X-ray / หัตถการ)
  /// ขั้นสั่งการรักษา (Figma 331-350): เลือกชุด standing order + ลำดับคำสั่งที่หยิบมา
  /// ใบคำสั่งแสดงในแท็บคำสั่งแพทย์ฝั่งซ้าย แตะรายการที่นั่นเพื่อหยิบมาเรียงที่นี่
  List<Widget> _orderSetPage() {
    // เข้าขั้นนี้: สลับแผงซ้ายไปแท็บคำสั่งแพทย์ (ใบคำสั่งให้หยิบ) ครั้งเดียวต่อการเข้า
    if (_detailTab != 3 && _soTabAuto != _caseP().hn) {
      _soTabAuto = _caseP().hn;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _detailTab = 3);
      });
    }
    if (_soPickOpen) return [_soPickPage()];
    // เคสที่ยังไม่เคยสั่ง: ล้างใบติ๊กตัวอย่างที่ค้างจากเคสอื่นก่อนเริ่ม
    if (!_soStarted && (_orderPicked.isNotEmpty || _soPnPick.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _orderPicked.clear();
          _soPnPick.clear();
          _soTick.clear();
        });
      });
    }
    // หน้า Order Set (การ์ดใหญ่ · ที่ใช้บ่อย · ตารางทุกชุด)
    // ใบคำสั่งอยู่แผงซ้าย แตะติ๊กรายการที่นั่น
    return _orderSetGrid();
  }

  /// หน้าย่อยเลือกชุดเปิดอยู่ (หัวแผง = breadcrumb · footer ย้อนกลับ)
  bool get _soPickNested =>
      (_soPickOpen || _soEdit != null) &&
      _speechOpen &&
      _steps[_speechStep].$2 == 'สั่งการรักษา';

  void _soPickEnter() {
    HapticFeedback.selectionClick();
    setState(() {
      _formFwd = true;
      _soPickOpen = true;
    });
  }

  void _soPickClose() => setState(() {
        _formFwd = false;
        _soPickOpen = false;
        _soPickFocus = false;
        _soEdit = null;
      });

  /// breadcrumb หน้าย่อย: Order Set › เลือกชุดคำสั่ง · แตะส่วนแรก = กลับ
  Widget _soPickCrumb() => _soEditItem != null
      ? _soEditCrumb(_soEditItem!)
      : Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
          child: Row(children: [
            InkWell(
              onTap: _soPickClose,
              borderRadius: BorderRadius.circular(100.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Standing Order',
                    style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text('เทมเพลต',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        );

  /// ข้อมูลเคสที่ใช้วิเคราะห์ (ค่าจริง) สำหรับแสดงระหว่างวิเคราะห์
  List<String> _soRecReads() {
    final c = _case;
    final p = _caseP();
    String n(double v) =>
        v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return [
      'ประเภทผู้ป่วย ${p.type?.label ?? 'ยังไม่ระบุ'}  อาการสำคัญ ${c.cc}',
      [
        if (c.hr.isNotEmpty) 'HR ${n(c.hr.last)}',
        if (c.sbp.isNotEmpty && c.dbp.isNotEmpty)
          'BP ${n(c.sbp.last)}/${n(c.dbp.last)}',
        if (c.rr.isNotEmpty) 'RR ${n(c.rr.last)}',
        if (c.bt.isNotEmpty) 'BT ${n(c.bt.last)}',
        if (c.spo2.isNotEmpty) 'SpO₂ ${n(c.spo2.last)}',
        if (c.gcs != null)
          'GCS ${RegExp(r'E\d').stringMatch(c.gcs!) ?? ''}'
              '${RegExp(r'V\d').stringMatch(c.gcs!) ?? ''}'
              '${RegExp(r'M\d').stringMatch(c.gcs!) ?? ''}',
      ].join('  '),
      'เทียบกับ Standing Order ทั้งหมดในโรงพยาบาล',
    ];
  }

  /// ชุดที่แนะนำจากข้อมูลจริงของเคส: ให้คะแนนทุกชุดจากประเภทผู้ป่วย อาการสำคัญ/HPI
  /// สัญญาณชีพล่าสุด (เกณฑ์ SIRS/qSOFA) ผลแล็บ และคำวินิจฉัย · คืน (ชุด, เหตุผลที่มีค่าจริง)
  /// คะแนนสูงสุดต่ำกว่า 2 = ไม่แนะนำ (ไม่เดา P1)
  (String, String)? _soRecommend() {
    final c = _case;
    final p = _caseP();
    final text = '${c.cc} ${c.hpi} ${c.dx.map((d) => d.text).join(' ')}';
    bool has(List<String> ws) => ws.any(text.contains);
    String n(double v) =>
        v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    double? last(List<double> xs) => xs.isEmpty ? null : xs.last;
    final hr = last(c.hr), sbp = last(c.sbp), rr = last(c.rr), bt = last(c.bt);
    ErLab? lab(String k) =>
        c.labs.where((l) => l.name.toLowerCase().contains(k)).firstOrNull;
    final score = <String, int>{};
    final why = <String, List<String>>{};
    void add(String set, int pt, String r) {
      score[set] = (score[set] ?? 0) + pt;
      (why[set] ??= []).add(r);
    }

    switch (p.type) {
      case _Ptype.sepsis:
        add('Sepsis', 3, 'ประเภทผู้ป่วย Sepsis');
      case _Ptype.trauma:
        add('Trauma', 3, 'ประเภทผู้ป่วย Trauma');
      case _Ptype.stemi:
        add('Chest Pain', 3, 'ประเภทผู้ป่วย STEMI');
      case _Ptype.stroke:
        add('Stroke Fast Tract', 3, 'ประเภทผู้ป่วย Stroke');
      case null:
        break;
    }
    // Sepsis: SIRS / qSOFA จากสัญญาณชีพล่าสุด + lactate
    if (bt != null && (bt >= 38.0 || bt < 36.0))
      add('Sepsis', 1, 'BT ${n(bt)}');
    if (hr != null && hr > 90) add('Sepsis', 1, 'HR ${n(hr)}');
    if (rr != null && rr >= 22) add('Sepsis', 1, 'RR ${n(rr)}');
    if (sbp != null && sbp <= 100) add('Sepsis', 1, 'SBP ${n(sbp)}');
    if (lab('lactate') case final l? when l.value > 2) {
      add('Sepsis', 2, 'Lactate ${n(l.value)}');
    }
    if (has(const ['ไข้', 'ติดเชื้อ', 'sepsis']))
      add('Sepsis', 1, 'มีไข้/ติดเชื้อ');
    // Trauma
    if (has(const [
      'ล้ม',
      'ชน',
      'อุบัติเหตุ',
      'บาดแผล',
      'บาดเจ็บ',
      'กระแทก',
      'ตก',
      'พลิก',
      'ผิดท่า',
      'เคล็ด',
      'หัก',
      'บวม',
    ])) {
      add('Trauma', 2, 'กลไกบาดเจ็บในอาการสำคัญ');
    }
    // Chest pain
    if (has(const ['เจ็บหน้าอก', 'แน่นหน้าอก']))
      add('Chest Pain', 2, 'เจ็บแน่นหน้าอก');
    if (lab('trop') case final l? when l.value > l.hi && l.hi > 0) {
      add('Chest Pain', 2, 'Troponin ${n(l.value)}');
    }
    // Stroke
    if (has(const ['อ่อนแรง', 'ปากเบี้ยว', 'พูดไม่ชัด'])) {
      add('Stroke Fast Tract', 2, 'อาการทางระบบประสาท');
    }
    // Appendicitis
    if (has(const ['ท้องขวาล่าง', 'ไส้ติ่ง']))
      add('Appendicitis', 3, 'ปวดท้องขวาล่าง');
    // Snake bite
    if (has(const ['งู'])) add('งูกัด', 4, 'ถูกงูกัด');

    if (score.isEmpty) return null;
    final best = score.entries.reduce((a, b) => b.value > a.value ? b : a);
    if (best.value < 2) return null;
    return (best.key, why[best.key]!.take(3).join('  '));
  }

  /// หน้าย่อยเลือกชุด: รายการทุกชุดในการ์ดขาว (แถวแบบรายการวินิจฉัย) แตะ = ใช้ชุดนั้นแล้วกลับ
  /// กด "AI แนะนำ": จังหวะวิเคราะห์ (อ่านประเภทผู้ป่วย → อาการสำคัญ → จับคู่ชุด) แล้วค่อยแสดงชุด
  void _soRecAsk() {
    final hn = _caseP().hn;
    if (_soRecBusy.contains(hn)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _soRecAsked.remove(hn);
      _soRecBusy.add(hn);
      _soRecStep = 0;
    });
    for (final (i, ms) in const [(1, 1100), (2, 2200)]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted && _soRecBusy.contains(hn)) setState(() => _soRecStep = i);
      });
    }
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _soRecBusy.remove(hn);
        _soRecAsked.add(hn);
      });
    });
  }

  /// การ์ดระหว่างวิเคราะห์: พื้นไล่สี AI · วงหมุน + "AI กำลังวิเคราะห์" · ขั้นตอนติ๊กทีละขั้น · skeleton shimmer
  Widget _soRecBusyCard() {
    final steps = _soRecReads();
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE6EEFD), Color(0xFFF1ECFC), Colors.white],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ไอคอนหมวดคำสั่ง (ยา Lab X-ray หัตถการ อื่น ๆ) โคจรรอบดาว AI แล้วรวมเข้ากลาง
        const SizedBox(height: 150.0, child: _SoOrbit()),
        const SizedBox(height: 6.0),
        Center(
          child: Text('AI กำลังวิเคราะห์ข้อมูลเคส',
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
        ),
        const SizedBox(height: 4.0),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                    position:
                        Tween(begin: const Offset(0.0, 0.4), end: Offset.zero)
                            .animate(a),
                    child: c)),
            child: Text(steps[_soRecStep.clamp(0, 2)],
                key: ValueKey(_soRecStep),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }

  /// วิเคราะห์แล้วไม่มีชุดที่ข้อมูลเคสรองรับพอ: บอกตรง ๆ + ค่าที่อ่านมา · ให้เลือกชุดเอง
  Widget _soRecNone() => Container(
        padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ยังไม่มีชุดที่ตรงกับข้อมูลเคส',
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 4.0),
          for (final r in _soRecReads().take(2))
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(r,
                  style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            ),
          const SizedBox(height: 10.0),
          _Press(
            child: GestureDetector(
              onTap: _soPickEnter,
              child: Container(
                height: 36.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: const Color(0xFFC4C7CC)),
                ),
                child: Text('เลือกชุดเอง',
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ),
            ),
          ),
        ]),
      );

  /// recOnly = แสดงเฉพาะชุดที่แนะนำ (วางบนหน้า Order Set หลัก)
  Widget _soPickPage({bool recOnly = false}) {
    final cats = [
      for (final c in _templates) ...[
        if (c == 'Stroke') ...const [
          'Stroke Fast Tract',
          'Stroke Non Fast Tract'
        ] else
          c,
        if (c == 'Sepsis') 'Appendicitis',
      ],
    ];
    // แนะนำเฉพาะการ์ดบนหน้าหลัง (หลังกด AI แนะนำ) · หน้าเทมเพลต = เลือกเอง ไม่มีแนะนำ
    final rec = recOnly ? _soRecommend() : null;
    // ชื่อหมวดสั้นบนการ์ด
    String short(String g) => switch (g) {
          final x when x.startsWith('ยา') => 'ยา',
          final x when x.startsWith('ภาพ') => 'X-ray',
          final x when x.startsWith('แล็บ') => 'Lab',
          _ => g,
        };

    // Figma 611:484: แต่ละ standing order = หัว (ชื่อ + คำอธิบาย) + ปุ่ม pill "เลือกใช้" ขวา
    // · การ์ดขาวขอบบาง มุม 16 = แถวหมวดกระจายเท่ากัน (ไอคอน + ชื่อหมวดหนา + จำนวนรายการ)
    // ไอคอน 3D จาก Figma (Lab 611:205 · ยา 614:524 · X-ray 615:637 · หัตถการ 615:685 · อื่น ๆ 615:721) · หมวดที่ยังไม่มีภาพ = ไอคอนระบบ
    Widget groupIcon(String name) => switch (name) {
          'Lab' => Image.asset('assets/images/er_os_lab.png',
              width: 22.0, height: 28.0, filterQuality: FilterQuality.medium),
          'ยา' => Image.asset('assets/images/er_os_med.png',
              width: 21.0, height: 28.0, filterQuality: FilterQuality.medium),
          'X-ray' => Image.asset('assets/images/er_os_xray.png',
              width: 21.0, height: 28.0, filterQuality: FilterQuality.medium),
          'หัตถการ' => Image.asset('assets/images/er_os_proc.png',
              width: 28.0, height: 28.0, filterQuality: FilterQuality.medium),
          'อื่น ๆ' => Image.asset('assets/images/er_os_other.png',
              width: 23.0, height: 28.0, filterQuality: FilterQuality.medium),
          _ => SizedBox(
              width: 28.0,
              height: 28.0,
              child: Icon(
                  switch (name) {
                    'ยา' => Icons.medication_rounded,
                    'X-ray' => Icons.image_rounded,
                    'หัตถการ' => Icons.healing_rounded,
                    _ => Icons.more_horiz_rounded,
                  },
                  size: 26.0,
                  color: const Color(0xFF3D7BF2))),
        };

    Widget section(int idx, String cat) {
      final on = cat == _template && _soSetPicked.contains(_caseP().hn);
      final groups = [
        for (final (g, items) in _orderSetPages(cat))
          if (items.isNotEmpty) (short(g), items.length)
      ];
      final full = _soFullName[cat] ?? _setName(cat);
      // เลือกแล้วยังอยู่หน้าย่อยนี้ (เห็นว่าชุดไหน "ใช้อยู่") · กลับด้วยปุ่มย้อนกลับ/breadcrumb
      void pick() {
        // แตะ "เลือกอยู่" ซ้ำ = ยกเลิกเลือก (กลับมาเห็นทุกชุด)
        if (on) {
          HapticFeedback.selectionClick();
          setState(() {
            _soSetPicked.remove(_caseP().hn);
            _soPickFocus = false;
          });
          return;
        }
        // หน้าย่อยเลือกชุด: เลือกอย่างเดียว ไม่เด้งเข้าหน้าเทมเพลต (เช่น Snake bite)
        // ชุดแบบเทมเพลตก็อยู่หน้านี้ต่อ เห็น "เลือกอยู่" + รายละเอียดเหมือนชุดอื่น
        HapticFeedback.selectionClick();
        setState(() {
          _template = cat;
          _orderEditing = null;
          _soSetPicked.add(_caseP().hn);
        });
        // เลือกแล้ว: กางรายละเอียด · ชุดนี้ขึ้นบนสุด ชุดอื่นซ่อน · เลื่อนกลับบนสุด
        setState(() {
          if (!recOnly) _soPickExpand[cat] = true;
          _soPickFocus = true;
        });
        // เลื่อนหน้ากลับบนสุดพร้อมกับชุดอื่นหุบ (ระยะเวลา/curve เดียวกัน = ไหลไปด้วยกัน)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final c = _soPickTopKey.currentContext;
          if (c == null || !c.mounted) return;
          final pos = Scrollable.maybeOf(c)?.position;
          if (pos == null || pos.pixels <= 0.0) return;
          pos.animateTo(0.0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic);
        });
      }

      // กาง/หุบทั้งชุด: ปุ่มลูกศรท้ายแถวหมวด (หรือแตะการ์ด) · ชุดที่ใช้อยู่กางเป็นค่าเริ่ม
      // หน้า Order Set หลักเก็บสถานะกาง/หุบแยกจากหน้าเลือกชุด · เริ่มหุบเสมอ
      final ek = recOnly ? 'main|$cat' : cat;
      final open = _soPickExpand[ek] ?? (!recOnly && on);
      void toggle() {
        HapticFeedback.selectionClick();
        setState(() => _soPickExpand[ek] = !open);
      }

      final recd = rec?.$1 == cat;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _Rise(
          index: idx,
          // ชุดที่แนะนำ: ทั้งกลุ่ม (หัว + การ์ด) อยู่บนพื้นไล่ฟ้าม่วงอ่อนทางซ้าย → ขาวทางขวา
          child: Container(
            padding: recd ? const EdgeInsets.all(12.0) : EdgeInsets.zero,
            decoration: recd
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFE6EEFD),
                        Color(0xFFF1ECFC),
                        Colors.white
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  )
                : null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ชื่อชุด + ป้าย "แนะนำ" ข้างชื่อ (แนะนำจากข้อมูลเคส)
                            Row(children: [
                              Flexible(
                                child: Text(_setName(cat),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(15.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 4.0),
                            Text(
                                rec?.$1 == cat
                                    ? 'จากข้อมูลเคส: ${rec!.$2}'
                                    : full,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ]),
                    ),
                    const SizedBox(width: 8.0),
                    // ปุ่มรอง pill ตัวกรมท่า · ยังไม่เลือก = ไม่มีพื้น (ขอบเทา) · เลือกอยู่ = พื้น surface + ติ๊ก
                    _Press(
                      child: GestureDetector(
                        onTap: pick,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 32.0,
                          padding: EdgeInsets.fromLTRB(
                              on ? 10.0 : 16.0, 0.0, 16.0, 0.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // ชุดแนะนำ (ยังไม่เลือก) = pill ไล่สี AI ตัวขาว แทนป้าย "แนะนำ"
                            color: on
                                ? _panelSoft
                                : recd
                                    ? null
                                    : Colors.transparent,
                            gradient: !on && recd
                                ? const LinearGradient(colors: [
                                    Color(0xFF4285F4),
                                    Color(0xFF9B72CB),
                                    Color(0xFFD96570),
                                  ])
                                : null,
                            borderRadius: BorderRadius.circular(100.0),
                            border: !on && recd
                                ? null
                                : Border.all(
                                    color: on
                                        ? _panelSoft
                                        : const Color(0xFFDADCE0)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (on) ...[
                              const Icon(Icons.check_rounded,
                                  size: 16.0, color: _blue),
                              const SizedBox(width: 4.0),
                            ],
                            if (!on && recd) ...[
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 14.0, color: Colors.white),
                              const SizedBox(width: 4.0),
                            ],
                            Text(on ? 'เลือกอยู่' : 'เลือกใช้',
                                style: _t(13.0,
                                    color: !on && recd ? Colors.white : _blue,
                                    weight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8.0),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggle,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                            color: const Color(0xFFDADCE0), width: 0.5),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Figma 611:310: แถวสรุปหมวดคงอยู่ · กาง = กล่องเทาต่อหมวด
                            // (ชื่อหมวดเล็กสีเทา · รายการตัวหนา · ไอคอน 3D ใหญ่โผล่มุมขวาบน)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 16.0, 8.0, 14.0),
                              child: Row(children: [
                                for (final (name, n) in groups)
                                  Expanded(
                                    child: Column(children: [
                                      SizedBox(
                                          height: 28.0,
                                          child:
                                              Center(child: groupIcon(name))),
                                      const SizedBox(height: 8.0),
                                      Text(name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: _t(13.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w700)),
                                      const SizedBox(height: 2.0),
                                      Text('$n รายการ',
                                          style: _t(11.0,
                                              color: _ink3,
                                              weight: FontWeight.w500)),
                                    ]),
                                  ),
                              ]),
                            ),
                            // แบบประวัติการวัด: หุบ = เห็นรายการบนสุดนิดหน่อยแล้วจาง · ปุ่ม "ดูรายการ"
                            AnimatedSize(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: open ? double.infinity : 64.0),
                                child: ShaderMask(
                                  blendMode: BlendMode.dstIn,
                                  shaderCallback: (b) => LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: open
                                        ? const [Colors.black, Colors.black]
                                        : const [
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                  ).createShader(b),
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 0.0, 16.0, 16.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            for (final (k, (g, items))
                                                in _orderSetPages(cat)
                                                    .where(
                                                        (e) => e.$2.isNotEmpty)
                                                    .indexed)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: _Rise(
                                                  index: k,
                                                  child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  12.0,
                                                                  10.0,
                                                                  56.0,
                                                                  12.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _panelSoft,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(short(g),
                                                                    style: _t(
                                                                        12.0,
                                                                        color:
                                                                            _ink3,
                                                                        weight:
                                                                            FontWeight.w500)),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                for (final it
                                                                    in items)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            5.0),
                                                                    child: Text(
                                                                        it,
                                                                        style: _t(
                                                                            13.5,
                                                                            color:
                                                                                _inkTitle,
                                                                            weight:
                                                                                FontWeight.w700)),
                                                                  ),
                                                              ]),
                                                        ),
                                                        // ไอคอน 3D ใหญ่โผล่เหนือขอบบนมุมขวา
                                                        Positioned(
                                                          right: 6.0,
                                                          top: -8.0,
                                                          child: SizedBox(
                                                            width: 40.0,
                                                            height: 48.0,
                                                            child: FittedBox(
                                                                child: groupIcon(
                                                                    short(g))),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 4.0, 16.0, 14.0),
                              child: _Press(
                                child: GestureDetector(
                                  onTap: toggle,
                                  child: Container(
                                    height: 36.0,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _panel,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                          color: const Color(0xFFC4C7CC)),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(open ? 'ซ่อนรายการ' : 'ดูรายการ',
                                              style: _t(13.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w600)),
                                          const SizedBox(width: 6.0),
                                          Icon(
                                              open
                                                  ? Icons
                                                      .keyboard_arrow_up_rounded
                                                  : Icons
                                                      .keyboard_arrow_down_rounded,
                                              size: 18.0,
                                              color: _inkTitle),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    bool isOn(String c) => c == _template && _soSetPicked.contains(_caseP().hn);
    final picked = cats.any(isOn);
    if (recOnly) {
      if (rec == null || !cats.contains(rec.$1)) return const SizedBox.shrink();
      return section(0, rec.$1);
    }

    return Column(
      key: const ValueKey('so-pick'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(key: _soPickTopKey, height: 0.0),
        // ลำดับคงที่ (ไม่สลับตำแหน่งกระโดด) · เลือกแล้ว = ชุดอื่นจาง + หุบพร้อมกัน
        // ชุดที่เลือกจึงเลื่อนขึ้นบนสุดเองแบบต่อเนื่อง (พร้อมเลื่อนหน้ากลับบนสุด)
        for (final (i, cat) in cats.indexed)
          Builder(builder: (context) {
            final hide = _soPickFocus && !isOn(cat) && picked;
            return AnimatedSize(
              key: ValueKey('set-$cat'),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                opacity: hide ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: hide
                    ? const SizedBox(width: double.infinity)
                    : section(i, cat),
              ),
            );
          }),
        if (_soPickFocus && picked)
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _soPickFocus = false);
              },
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20.0, color: _blue),
              label: Text('ดูชุดอื่น (${cats.length - 1})',
                  style: _t(13.0, color: _blue, weight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  /// คำสั่งครั้งล่าสุดของเคส (ไม่มี = ยังไม่เคยสั่ง)
  _SoRound? get _soPrev =>
      _soNoOrderYet.contains(_caseP().hn) || _soHistory.isEmpty
          ? null
          : _soHistory.first;

  /// สถานะของรายการในคำสั่งเดิม (null = รายการใหม่ / ไม่ได้อยู่ในโหมดต่อจากคำสั่งเดิม)
  String? _soPrevStatus(String name) {
    if (!_soContHn.contains(_caseP().hn)) return null;
    for (final it
        in _soPrev?.items ?? const <(String, String, String, bool)>[]) {
      if (it.$1 == name) return it.$3;
    }
    return null;
  }

  /// สั่งเพิ่ม / แก้ไขจากคำสั่งเดิม: ใช้ชุดเดิม ติ๊กรายการเดิมไว้ แล้วไปหน้าใบคำสั่ง
  void _soContinue() {
    final prev = _soPrev;
    if (prev == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _template = prev.set;
      _orderEditing = null;
      _soSetPicked.add(_caseP().hn);
      _soContHn.add(_caseP().hn);
      _orderPicked.addAll([for (final it in prev.items) it.$1]);
    });
    final seq = _uiSeq;
    _pageGo(seq, _pageAt(seq) + 1);
  }

  /// การ์ดคำสั่งเดิม (หน้าแรกของขั้น): ชุด ครั้งที่ เวลา ผู้สั่ง ความคืบหน้า · ปุ่มเดียว สั่งเพิ่ม / แก้ไข
  Widget _soPrevCard() {
    final prev = _soPrev!;
    final done = prev.items.where((i) => i.$3 == 'ทำแล้ว').length;
    return _dxCard(
      'คำสั่งเดิม',
      'ชุด ${_setName(prev.set)} ครั้งที่ ${prev.no} ${_clock(prev.time)} โดย ${prev.by}',
      const SizedBox.shrink(),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text('ความคืบหน้า',
                    style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
              ),
              Text('ทำแล้ว $done/${prev.items.length}',
                  style: _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: LinearProgressIndicator(
                value: prev.items.isEmpty ? 0 : done / prev.items.length,
                minHeight: 6.0,
                color: _green,
                backgroundColor: _panelSoft,
              ),
            ),
          ]),
        ),
        _dxTiles([
          (Icons.edit_note_rounded, 'สั่งเพิ่ม / แก้ไขคำสั่งเดิม', _soContinue),
        ]),
        const SizedBox(height: 8.0),
      ]),
    );
  }

  /// เนื้อหาหน้า Order Set ภาษาเดียวกับแผงวินิจฉัย (2026-10-22):
  /// การ์ด Order Set (ชื่อ + คำอธิบาย + ภาพมุมขวาบน + แผ่นปุ่ม เลือกชุด / AI แนะนำ / ชุดล่าสุด)
  /// ชุดทั้งหมดเปิดจากปุ่ม "เลือกชุด" (ไม่วางตารางในหน้า)
  List<Widget> _orderSetGrid() => [
        // เคยสั่งแล้ว: ต่อจากคำสั่งเดิม (เพิ่ม/แก้) ขึ้นก่อน · หรือเริ่มชุดใหม่จากการ์ดด้านล่าง
        if (_soPrev != null) ...[
          _soPrevCard(),
          const SizedBox(height: 12.0),
        ],
        _dxCard(
          'Standing Order',
          'ชุดคำสั่งตามโรค สั่งครบในครั้งเดียว',
          // hero คลิปบอร์ดตัวเดียวกับการ์ดคำสั่งแพทย์ในภาพรวม (เข้า + เช็กวาดทีละแถว)
          const Padding(
            padding: EdgeInsets.fromLTRB(56.0, 10.0, 24.0, 18.0),
            child: _ClipboardHero(),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // แผ่นปุ่มแถวเดียวแบบ Diagnosis Text (เพิ่ม / เทมเพลต / Re-Diag)
            _dxTiles([
              (Icons.post_add_rounded, 'เทมเพลต', _soPickEnter),
              (Icons.auto_awesome_rounded, 'AI แนะนำ', _soRecAsk),
            ]),
          ]),
        ),
        // AI แนะนำชุดจากข้อมูลเคส (การ์ดเดียวกับหน้าเลือกชุด) · ไม่มีข้อมูลพอ = ไม่แสดง
        // แสดงหลังกด "AI แนะนำ" เท่านั้น · ไล่ขึ้นจากใต้การ์ด Order Set
        AnimatedSize(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _soRecBusy.contains(_caseP().hn)
                ? Padding(
                    key: const ValueKey('rec-busy'),
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _soRecBusyCard(),
                  )
                : !_soRecAsked.contains(_caseP().hn)
                    ? const SizedBox(
                        key: ValueKey('rec-none'), width: double.infinity)
                    : Padding(
                        key: const ValueKey('rec-card'),
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _soRecommend() == null
                            ? _soRecNone()
                            : _soPickPage(recOnly: true),
                      ),
          ),
        ),
      ];

  /// ชื่อชุดคำสั่งที่แสดง: "ใช้บ่อย" เป็นหมวด ไม่ใช่ชื่อชุด จึงแสดงเป็นชุดทั่วไป
  /// ชุดแบบ template ใช้ชื่อ template (เช่น Standing order Snake bite)
  String _setName(String cat) {
    if (cat == 'ใช้บ่อย') return 'General Emergency';
    final tpl = _orderTemplatesOf[cat];
    return tpl != null && tpl.first.$1 != 'inline' ? tpl.first.$2 : cat;
  }

  /// เลือกชุด: ชุดในหน้า (inline) = ตั้งเป็นชุดปัจจุบัน · ชุดแบบ template = เปิด template
  void _orderSetPick(String cat) {
    HapticFeedback.selectionClick();
    final tpl = _orderTemplatesOf[cat];
    if (tpl != null && tpl.first.$1 != 'inline') {
      _tplEnter(tpl.first.$1);
      return;
    }
    setState(() {
      _template = cat;
      _orderEditing = null;
      _soSetPicked.add(_caseP().hn);
    });
  }

  /// มีคำสั่งให้ทำงานต่อ: เคสทั่วไป = มีชุดตัวอย่างอยู่แล้ว · เคสยังไม่เคยสั่ง = ต้องเลือกชุดก่อน
  bool get _soStarted =>
      !_soNoOrderYet.contains(_caseP().hn) ||
      _soSetPicked.contains(_caseP().hn);

  /// แผงซ้ายเป็นสำรับรายละเอียดคำสั่ง: อยู่ขั้นสั่งการรักษา และเลือก Order Set แล้วเท่านั้น
  bool get _soDeckOn =>
      _speechOpen &&
      _steps[_speechStep].$2 == 'สั่งการรักษา' &&
      _soSetPicked.contains(_caseP().hn);

  /// หน้าของการ์ดชุดคำสั่ง (หมวด, รายการ) · Sepsis ใช้รายการจริงของชุด
  List<(String, List<String>)> _orderSetPages(String cat) => switch (cat) {
        _ when _soDocs.containsKey(cat) => [
            for (final (code, title) in _soGroupTitles)
              if (_soDocs[cat]!.any((o) => o.$3 == code))
                (
                  title,
                  [
                    for (final o in _soDocs[cat]!)
                      if (o.$3 == code) o.$1
                  ]
                ),
          ],
        'Chest Pain' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Aspirin 300 mg เคี้ยว',
                'Clopidogrel 300 mg',
                'Nitroglycerin 0.4 mg SL'
              ]
            ),
            ('แล็บ', ['Troponin T', 'CK-MB', 'Electrolytes']),
            ('ภาพถ่าย', ['EKG 12 leads', 'Chest X-ray']),
          ],
        'Stroke' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Alteplase 0.9 mg/kg IV',
                'Labetalol 10 mg IV',
                '0.9% NSS 1,000 mL'
              ]
            ),
            ('แล็บ', ['CBC', 'PT / INR', 'Glucose']),
            ('ภาพถ่าย', ['CT brain non-contrast']),
          ],
        'Trauma' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Tranexamic acid 1 g IV',
                "Ringer's lactate 1,000 mL",
                'Morphine 3 mg IV'
              ]
            ),
            ('แล็บ', ['CBC', 'G/M 2 units', 'Coagulation']),
            ('ภาพถ่าย', ['FAST', 'Chest X-ray', 'Pelvis X-ray']),
          ],
        'งูกัด' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Antivenom ตามชนิดงู',
                'Tetanus toxoid 0.5 mL IM',
                'Paracetamol 500 mg'
              ]
            ),
            ('แล็บ', ['VCT 20 นาที', 'CBC', 'PT / INR']),
            ('หัตถการ', ['ล้างแผล', 'ดามแขนขาส่วนที่ถูกกัด']),
          ],
        _ => const [
            (
              'ยา / เวชภัณฑ์',
              ['Paracetamol 500 mg', 'Ondansetron 4 mg IV', '0.9% NSS 1,000 mL']
            ),
            ('แล็บ', ['CBC', 'Electrolytes', 'BUN / Cr']),
            ('ภาพถ่าย', ['Chest X-ray']),
          ],
      };

  /// กลุ่มคำสั่งของหน้าย่อยใน stepper (จับคู่จากชื่อช่อง)
  List<_OrderGroup> _orderGroupsFor(String field) {
    final f = field.toLowerCase();
    // ชุด Sepsis ตามเอกสารจริง: แยกการ์ด One Day กับ Continuation ของหมวดนั้น
    final doc = _soDocs[_template];
    if (doc != null) {
      final code = f.contains('ยา')
          ? 'M'
          : f.contains('lab') || f.contains('แล็บ')
              ? 'L'
              : f.contains('x-ray') || f.contains('ภาพ')
                  ? 'X'
                  : f.contains('หัตถการ')
                      ? 'ห'
                      : f.contains('อื่น')
                          ? 'oth'
                          : null;
      if (code == null) return const [];
      _OrderGroup part(bool oneDay) => _OrderGroup(
            oneDay ? 'One Day' : 'Continuation',
            oneDay ? Icons.today_rounded : Icons.repeat_rounded,
            _blue,
            [
              // ตามหมวดที่จัดไว้ในตัวจัดโครงสร้าง (บรรทัดหลายหมวดขึ้นทุกหน้าย่อยที่เกี่ยว)
              for (final o in doc)
                if (o.$4 == oneDay &&
                    _soCatsFor(o.$1, o.$3).any((c) =>
                        _soCatDefs.any((d) => d.$1 == c && d.$2 == code)))
                  _OrderItem(o.$1, o.$2, _OrderStatus.pending, '')
            ],
          );
      return [
        for (final g in [part(true), part(false)])
          if (g.items.isNotEmpty) g
      ];
    }
    bool has(String t) => _orderGroups.any((g) => g.title == t);
    final titles = f.contains('ยา')
        ? ['ยา / เวชภัณฑ์']
        : f.contains('lab') || f.contains('แล็บ')
            ? ['เลือด', 'แล็บ']
            : f.contains('x-ray') || f.contains('ภาพ')
                ? ['ภาพถ่าย']
                : f.contains('หัตถการ')
                    ? ['หัตถการ', 'Set OR (ผ่าตัด)']
                    : const <String>[];
    if (f.contains('อื่น')) return const [_otherOrders];
    return [
      for (final t in titles)
        if (has(t)) _orderGroups.firstWhere((g) => g.title == t)
    ];
  }

  /// รายการที่ AI แนะนำจากข้อมูลเคส: ทุกรายการในชุด ยกเว้นยาที่ผู้ป่วยแพ้
  /// (แพ้ Penicillin = ข้ามยากลุ่ม penicillin เช่น Piperacillin)
  List<String> _aiFillWant() {
    final allergy = _case.allergies.join(' ').toLowerCase();
    const penicillins = [
      'piperacillin',
      'amoxicillin',
      'ampicillin',
      'cloxacillin'
    ];
    bool skip(String name) {
      final n = name.toLowerCase();
      return allergy.contains('penicillin') && penicillins.any(n.contains);
    }

    return [
      for (final (_, items) in _orderSetPages(_template))
        for (final name in items)
          if (!skip(name)) name
    ];
  }

  void _aiFillStart() {
    HapticFeedback.lightImpact();
    final byType = switch (_caseP().type) {
      _Ptype.sepsis => 'Sepsis',
      _Ptype.stemi => 'Chest Pain',
      _Ptype.stroke => 'Stroke Fast Tract',
      _Ptype.trauma => 'Trauma',
      _ => null,
    };
    setState(() {
      if (byType != null) _template = byType;
      _soSetPicked.add(_caseP().hn);
      // ล้างทั้งชุด (รวมยาที่แพ้ซึ่ง AI จะไม่เติมกลับ) แล้วติ๊กตามที่ AI แนะนำ
      for (final (_, items) in _orderSetPages(_template)) {
        _orderPicked.removeAll(items);
      }
      _orderEditing = null;
      _orderPicked.addAll(_aiFillWant());
    });
  }

  Widget _orderSaveBtn() => Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Material(
          color: _blue,
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded,
                      size: 15.0, color: Colors.white),
                  const SizedBox(width: 7.0),
                  Text(
                      'บันทึกคำสั่งแพทย์ · เลือกแล้ว ${_orderPicked.length} รายการ',
                      style: _t(11.5,
                          color: Colors.white, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _chip(String label, bool on, VoidCallback onTap) => _Press(
          child: Material(
        color: on ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
            child: Text(label,
                style: _t(10.0,
                    color: on ? Colors.white : _ink2, weight: FontWeight.w600)),
          ),
        ),
      ));

  /// กลุ่มคำสั่งหนึ่งหมวด (ยา / เลือด / แล็บ / X-ray / หัตถการ)
  Widget _orderGroupCard(_OrderGroup g, {_OrderKind? kind}) {
    final picked = g.items.where((i) => _orderPicked.contains(i.name)).length;
    return _stackCard(
      title: g.title,
      icon: g.icon,
      count: '$picked/${g.items.length}',
      pad: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < g.items.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1.0, thickness: 0.5, color: Color(0xFFE8EAED)),
            _orderRow(g.items[i], kind ?? _orderKindOf(g)),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(_OrderItem it, [_OrderKind kind = _OrderKind.other]) {
    final on = _orderPicked.contains(it.name);
    final editing = _orderEditing == it.name;
    return InkWell(
      onTap: () {
        setState(() {
          if (on) {
            _orderPicked.remove(it.name);
            if (editing) _orderEditing = null;
          } else {
            _orderPicked.add(it.name);
          }
        });
        // เลือกแล้วกรอกรายละเอียดต่อที่แผงขวาทันที
        if (!on) _orderOpen(kind, it.name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        // รายการที่กำลังกรอกอยู่ในแผงขวา: พื้นฟ้าจาง
        color: editing ? _blue.withValues(alpha: 0.05) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.0,
              height: 22.0,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: on ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: on ? _blue : _g5, width: 1.5),
              ),
              child: on
                  ? const Icon(Icons.check_rounded,
                      size: 15.0, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(it.name,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w500)),
                    ),
                    if (on && _orderDetail[it.name]?['stat'] == '1') ...[
                      const SizedBox(width: 6.0),
                      _statBadge(),
                    ],
                  ]),
                  Text(it.detail, style: _t(12.0, color: _ink3)),
                  if (on && kind != _OrderKind.other)
                    _orderDetailPill(kind, it.name),
                ],
              ),
            ),
            const SizedBox(width: 6.0),
            _orderStatus(it.status, it.time),
          ],
        ),
      ),
    );
  }

  /// ป้าย STAT ของยาที่ต้องให้ทันที
  Widget _statBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        decoration: BoxDecoration(
          gradient: _glossGrad(_red),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text('STAT',
            style: _t(8.5, color: Colors.white, weight: FontWeight.w700)),
      );

  Widget _orderStatus(_OrderStatus s, String time) {
    final (label, color) = switch (s) {
      _OrderStatus.pending => ('ยังไม่รับ', _g4),
      _OrderStatus.accepted => ('รับแล้ว', _blue),
      _OrderStatus.working => ('กำลังทำ', _blue),
      _OrderStatus.done => ('ทำแล้ว', _blue),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(label,
              style: _t(9.0, color: color, weight: FontWeight.w700)),
        ),
        if (time.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(_clock(time), style: _num(8.5, color: _ink3)),
          ),
      ],
    );
  }

  /// empty state ของแผงซ้ายคำสั่งแพทย์ (ภาพ Figma 605:116 โทนเทา เข้าทีละชิ้น + ข้อความ)
  /// ใช้ทั้งตอนยังไม่มีประวัติคำสั่ง และตอนเลือกชุดแล้วแต่ยังไม่ติ๊กรายการ
  Widget _soEmpty(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('คำสั่งแพทย์',
            style: _t(26.0, color: _inkTitle, weight: FontWeight.w700)),
        Expanded(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ภาพ empty state จาก Figma 605:116 (คลิปบอร์ดว่าง + ใบไม้)
              // appear: ลอยขึ้น + ขยายจาก 0.9 + จางเข้า แล้วข้อความตามมา (เล่นครั้งเดียว)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                builder: (context, t, child) {
                  final a =
                      Curves.easeOutCubic.transform((t / 0.2).clamp(0.0, 1.0));
                  final b = Curves.easeOutCubic
                      .transform(((t - 0.55) / 0.45).clamp(0.0, 1.0));
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    Opacity(
                      opacity: a,
                      child: Transform.translate(
                        offset: Offset(0.0, 16.0 * (1 - a)),
                        // โทนเทา (empty state ไม่ใช้สีเน้น)
                        child: const ColorFiltered(
                          colorFilter: ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 6, //
                            0.2126, 0.7152, 0.0722, 0, 6,
                            0.2126, 0.7152, 0.0722, 0, 12,
                            0, 0, 0, 0.8, 0,
                          ]),
                          child:
                              SizedBox(width: 200.0, child: _EmptyOrdersArt()),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: b,
                      child: Transform.translate(
                          offset: Offset(0.0, 8.0 * (1 - b)), child: child),
                    ),
                  ]);
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 16.0),
                  Text(title,
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 6.0),
                  Text(sub,
                      textAlign: TextAlign.center,
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)
                          .copyWith(height: 1.5)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  /// แท็บคำสั่งแพทย์: ประวัติการบันทึก standing order ครั้งก่อน ๆ (อ่านอย่างเดียว)
  /// การบันทึกครั้งปัจจุบันทำใน workflow ขั้น "สั่งการรักษา" (แผงขวา)
  /// รอบใหม่อยู่บน · แต่ละรอบแยก One Day / Continuation + สถานะการทำ
  Widget _orderRecord() {
    // กำลังสั่งการรักษาใน workflow: แผงซ้ายเป็นสำรับการ์ดระบุรายละเอียดคำสั่ง (Figma 331-350)
    if (_soDeckOn) {
      return _soDeck();
    }
    final hn = _caseP().hn;
    final rounds = _soNoOrderYet.contains(hn) ? const <_SoRound>[] : _soHistory;
    // ยังไม่เคยสั่ง: บอกตรง ๆ ว่ายังไม่มี และสั่งได้ที่ไหน (ไม่แสดงใบตัวอย่าง)
    if (rounds.isEmpty) {
      return _soEmpty('ยังไม่มีคำสั่งแพทย์',
          'เริ่มสั่งได้ที่ขั้น "สั่งการรักษา" ทางขวา\nเลือก Standing Order หรือให้ AI แนะนำ');
    }
    final sel = (_soSel[hn] ?? 0).clamp(0, rounds.length - 1);
    final r = rounds[sel];

    // แถบ tab ครั้งที่บันทึก (ล่าสุดซ้าย) แบบหน้า EMR: เวลา + ครั้งที่
    Widget tab(int i, _SoRound x) {
      final on = i == sel;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _soSel[hn] = i);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text('ครั้งที่ ${x.no}  ${_clock(x.time)}',
                        style: _t(14.0,
                            color: on ? _blue : _ink2,
                            weight: on ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: on ? _blue : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3.0)),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    final tabs = Transform.translate(
      offset: const Offset(-12.0, 0.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (i, x) in rounds.indexed) tab(i, x),
        ]),
      ),
    );

    // สถานะ = ตัวหนังสือสีชิดขวา (ไม่มีกรอบ) แบบหน้ากิจกรรมพยาบาล
    Widget status(String st) => Text(st,
        style: _t(12.5,
            color: switch (st) {
              'ทำแล้ว' => _green,
              'กำลังทำ' => _blue,
              _ => _ink3,
            },
            weight: FontWeight.w600));

    // การ์ดส่วน (One Day / Continuation): หัวข้อ + จำนวน · แถวรายการภาษาเดียวกับ V/S
    Widget part(String title, String sub, List<(String, String, String)> xs) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 6.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text('${xs.length} รายการ',
                  style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            ]),
            const SizedBox(height: 2.0),
            Text(sub, style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            const SizedBox(height: 4.0),
            for (final (i, (name, detail, st)) in xs.indexed)
              _gListRow(
                first: i == 0,
                title: name,
                sub: detail.isEmpty ? '-' : detail,
                trail: status(st),
              ),
          ]),
        );
    final oneDay = [
      for (final o in r.items)
        if (o.$4) (o.$1, o.$2, o.$3)
    ];
    final cont = [
      for (final o in r.items)
        if (!o.$4) (o.$1, o.$2, o.$3)
    ];
    final done = r.items.where((o) => o.$3 == 'ทำแล้ว').length;
    return _clyInfoPage(
      'คำสั่งแพทย์',
      'ชุดคำสั่ง ${r.set}',
      'nurse_act',
      const [],
      by: r.by,
      at: _clock(r.time),
      // แฟ้มคำสั่ง (ภาพเดียวกับการ์ดคำสั่งแพทย์ในภาพรวม)
      heroArt: SizedBox(
        width: 110.0,
        height: 110.0,
        child: Stack(fit: StackFit.expand, children: [
          for (var i = 6; i >= 1; i--)
            Transform(
              alignment: Alignment.center,
              transform: _clipTilt(-i * 1.2),
              child: CustomPaint(painter: const _ClipArt(layer: 1)),
            ),
          for (var i = 3; i >= 1; i--)
            Transform(
              alignment: Alignment.center,
              transform: _clipTilt(i * 0.9),
              child: CustomPaint(painter: const _ClipArt(layer: 2)),
            ),
          Transform(
            alignment: Alignment.center,
            transform: _clipTilt(3.6),
            child: CustomPaint(painter: const _ClipArt()),
          ),
        ]),
      ),
      below: tabs,
      // ความคืบหน้าของครั้งนี้: แถบเขียวตามสัดส่วนที่ทำแล้ว
      lead: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 14.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text('ความคืบหน้า',
                    style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
              ),
              Text('ทำแล้ว $done/${r.items.length}',
                  style: _num(13.0,
                      color: done == r.items.length ? _green : _inkTitle,
                      weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6.0),
            TweenAnimationBuilder<double>(
              key: ValueKey('so-prog-$sel'),
              tween: Tween(
                  begin: 0.0,
                  end: r.items.isEmpty ? 0.0 : done / r.items.length),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 8.0,
                  backgroundColor: const Color(0xFFE8EAED),
                  color: _green,
                ),
              ),
            ),
          ]),
        ),
      ],
      extra: [
        if (oneDay.isNotEmpty)
          part('One Day', 'คำสั่งครั้งเดียว ทำแล้วจบ', oneDay),
        if (cont.isNotEmpty)
          part('Continuation', 'คำสั่งต่อเนื่อง ทำซ้ำตามรอบ', cont),
      ],
    );
  }

  /// คอลัมน์ขวา: งานที่ต้องติดตาม (พยาบาลรอรับ / แพทย์ตรวจซ้ำ)
  Widget _orderRight() => SizedBox(
        width: 330.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
          children: _orderRightItems(),
        ),
      );

  List<Widget> _orderRightItems() {
    final tasks = _sortTasks(_followTab == 0
        ? _allTasks.where((t) => !t.doctor)
        : _allTasks.where((t) => t.doctor));
    final nNurse = _allTasks.where((t) => !t.doctor).length;
    final nDoc = _allTasks.where((t) => t.doctor).length;
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: _line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, size: 15.0, color: _blue),
                const SizedBox(width: 6.0),
                Text('งานที่ต้องติดตาม',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8.0),
            _segmented(
              ['พยาบาลรอรับ $nNurse', 'แพทย์ตรวจซ้ำ $nDoc'],
              _followTab,
              (i) => setState(() => _followTab = i),
            ),
          ],
        ),
      ),
      _remListCard(),
      _todoCard(tasks),
    ];
  }
}

/// ภาพแฟ้มชุดคำสั่งซ้อนกัน 3 แผ่น (หลังลาย teal · กลางไล่สีน้ำเงินม่วง · หน้ากระดาษขาว)
class _PresetStack extends StatelessWidget {
  const _PresetStack();

  Widget _sheet({
    required Gradient fill,
    required double angle,
    required Offset at,
    bool lines = false,
    bool paper = false,
  }) =>
      Positioned(
        left: at.dx,
        top: at.dy,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 74.0,
            height: 92.0,
            padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 0.0),
            decoration: BoxDecoration(
              gradient: fill,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 3)),
              ],
            ),
            child: lines
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final w in [0.55, 0.9, 0.75, 0.9, 0.6])
                        Container(
                          margin: const EdgeInsets.only(bottom: 6.0),
                          height: 4.0,
                          width: 52.0 * w,
                          decoration: BoxDecoration(
                            color: paper
                                ? const Color(0xFFD9DEE8)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                    ],
                  )
                : null,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [
        _sheet(
          fill: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7DD3C0), Color(0xFF2E8B8B)],
          ),
          angle: -0.16,
          at: const Offset(0.0, 10.0),
        ),
        _sheet(
          fill: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6), Color(0xFFF0A3A3)],
          ),
          angle: 0.05,
          at: const Offset(46.0, 0.0),
          lines: true,
        ),
        _sheet(
          fill: const LinearGradient(colors: [Colors.white, Color(0xFFF4F6FA)]),
          angle: -0.04,
          at: const Offset(28.0, 16.0),
          lines: true,
          paper: true,
        ),
      ]);
}

/// เนื้อการ์ดชุดคำสั่งแบบเลื่อนเอง: หัว (ชื่อ + จุดหน้า) + แผ่นขาว (หมวด + รายการ)
/// หน้าใหม่เลื่อนขึ้นจากล่าง หน้าเก่าเลื่อนออกด้านบน (แบบการ์ดแจ้งเตือนหน้าภาพรวม)
class _SetCarousel extends StatefulWidget {
  const _SetCarousel({
    required this.name,
    required this.on,
    required this.pages,
    required this.delay,
    required this.label,
    required this.item,
    required this.title,
  });

  final String name;
  final bool on;
  final List<(String, List<String>)> pages;
  final Duration delay;
  final TextStyle label;
  final TextStyle item;
  final TextStyle title;

  @override
  State<_SetCarousel> createState() => _SetCarouselState();
}

class _SetCarouselState extends State<_SetCarousel> {
  int _i = 0;
  Timer? _start;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    if (widget.pages.length > 1) {
      _start = Timer(widget.delay, () {
        _t = Timer.periodic(const Duration(milliseconds: 3200), (_) {
          if (mounted) setState(() => _i = (_i + 1) % widget.pages.length);
        });
      });
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.on;
    final n = widget.pages.length;
    final (group, items) = widget.pages[_i % n];
    final head = switch (group) {
      'ยา / เวชภัณฑ์' => 'ยาและเวชภัณฑ์',
      'Set OR (ผ่าตัด)' => 'ผ่าตัด',
      _ => group,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: on ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: on ? _blue : _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 9.0, 10.0, 8.0),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.title
                          .copyWith(color: on ? Colors.white : _inkTitle)),
                  const SizedBox(height: 5.0),
                  // จุดบอกหน้า: หน้าปัจจุบันยาวกว่า
                  Row(children: [
                    for (var k = 0; k < n; k++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: k == _i % n ? 12.0 : 5.0,
                        height: 5.0,
                        margin: const EdgeInsets.only(right: 4.0),
                        decoration: BoxDecoration(
                          color: on
                              ? Colors.white
                                  .withValues(alpha: k == _i % n ? 1.0 : 0.35)
                              : (k == _i % n ? _ink2 : _line),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            if (on)
              const Icon(Icons.check_circle_rounded,
                  size: 18.0, color: Colors.white),
          ]),
        ),
        Container(
          // สูงคงที่ หน้าที่รายการน้อยไม่ทำให้การ์ดหด
          height: 96.0,
          padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 8.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (c, prev) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...prev, if (c != null) c]),
              transitionBuilder: (child, anim) {
                final incoming = child.key == ValueKey(_i % n);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, incoming ? 0.6 : -0.6),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: Column(
                key: ValueKey(_i % n),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$head (${items.length})', style: widget.label),
                  for (final m in items.take(3))
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(m,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.item),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// ภาพแฟ้มเอกสาร (โทนกรมท่า): แผ่นหลังเข้ม · กระดาษ 3 แผ่นโผล่จากแฟ้ม
/// · กระเป๋าหน้ามีแถบ tab ซ้าย ไล่สีโปร่งแสงให้เห็นกระดาษจาง ๆ ด้านหลัง
class _FolderArt extends StatefulWidget {
  const _FolderArt();

  @override
  State<_FolderArt> createState() => _FolderArtState();
}

/// ปรากฏครั้งเดียว: แผ่นแรกโผล่ขึ้นจากแฟ้ม แล้วแผ่นหลังคลี่ออกไปทางขวา (ไม่มี idle)
class _FolderArtState extends State<_FolderArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// กระดาษหนึ่งแผ่น: เริ่มซ้อนอยู่ใต้แผ่นแรก แล้วคลี่ไปตำแหน่งของตัวเองตาม fan
  Widget _paper(double left, double top, double angle, double w,
      {bool lead = false}) {
    final rise = Curves.easeOutCubic
        .transform(const Interval(0.0, 0.5).transform(_c.value));
    final fan = Curves.easeOutBack
        .transform(const Interval(0.42, 1.0).transform(_c.value));
    const l0 = 22.0, t0 = 8.0, a0 = -0.06;
    final k = lead ? 1.0 : fan;
    return Positioned(
      left: l0 + (left - l0) * k,
      top: t0 + (top - t0) * k + 46.0 * (1.0 - rise),
      child: Transform.rotate(
        angle: a0 + (angle - a0) * k,
        child: Container(
          width: w,
          height: 56.0,
          padding: const EdgeInsets.fromLTRB(9.0, 9.0, 9.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000F4D),
                  blurRadius: 6.0,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final k in [0.5, 0.85, 0.7])
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  width: (w - 18.0) * k,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DBE7),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Stack(clipBehavior: Clip.none, children: [
                // แผ่นหลังแฟ้ม
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1E3A8A), Color(0xFF0B1F66)],
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                ),
                // แผ่นหลังวาดก่อน (อยู่ใต้แผ่นแรก) แล้วคลี่ออกไปขวา
                _paper(58.0, 14.0, 0.12, 34.0),
                _paper(46.0, 10.0, 0.05, 40.0),
                _paper(22.0, 8.0, -0.06, 50.0, lead: true),
                // กระเป๋าหน้า
                const Positioned.fill(
                  top: 30.0,
                  child: CustomPaint(painter: _FolderFrontPainter()),
                ),
              ])));
}

/// กระเป๋าหน้าแฟ้ม: ขอบบนมีแถบ tab ด้านซ้าย · ไล่สีฟ้าโปร่ง → กรมท่า + เส้นไฮไลต์ขอบบน
class _FolderFrontPainter extends CustomPainter {
  const _FolderFrontPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const r = 12.0;
    final tabW = w * 0.42;
    const step = 9.0;
    final path = Path()
      ..moveTo(0.0, r)
      ..quadraticBezierTo(0.0, 0.0, r, 0.0)
      ..lineTo(tabW - 6.0, 0.0)
      // ไหล่ tab ลาดลงไปขอบบนส่วนที่เหลือ
      ..cubicTo(tabW, 0.0, tabW + 2.0, step, tabW + 10.0, step)
      ..lineTo(w - r, step)
      ..quadraticBezierTo(w, step, w, step + r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0.0, h, 0.0, h - r)
      ..close();
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6A5B8F0), Color(0xF24263C9), Color(0xFF1E3A8A)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    // แสงขาวนุ่มกลางกระเป๋า
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.2),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
    // ไฮไลต์ขอบบน
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_FolderFrontPainter old) => false;
}

/// ปุ่ม AI แบบ elegant: ไล่สีคราม → ม่วง → ชมพูอ่อน · ขอบแสงด้านใน · เงาเรืองม่วงจาง
/// แสงวาบไล่ผ่านช้า ๆ ทุก ~4 วินาที + ประกายกระพริบเบา ๆ (วาดแค่ตัวปุ่ม)
class _AiPill extends StatefulWidget {
  const _AiPill({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  State<_AiPill> createState() => _AiPillState();
}

class _AiPillState extends State<_AiPill> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200));
  Timer? _rest;

  // เล่นครึ่งรอบแรก (วาบ + ประกาย) แล้วพักครึ่งหลังด้วย Timer
  // 0.5 = ประกายกลับมาค่าเดียวกับจุดเริ่ม จึงตัดกลับ 0 ได้ไม่กระตุก
  @override
  void initState() {
    super.initState();
    _run();
  }

  void _run() {
    _c.value = 0.0;
    _c.animateTo(0.5).then((_) {
      if (!mounted) return;
      _c.value = 0.0;
      _rest = Timer(const Duration(milliseconds: 2100), () {
        if (mounted) _run();
      });
    });
  }

  @override
  void dispose() {
    _rest?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.all(Radius.circular(100.0));
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
              blurRadius: 14.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: r,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              // แสงวาบ: วิ่งช่วง 0–30% ของรอบ ที่เหลือพัก
              final k = (_c.value / 0.3).clamp(0.0, 1.0);
              final sweep = -1.6 + 3.2 * Curves.easeInOutSine.transform(k);
              final twinkle =
                  0.75 + 0.25 * math.sin(_c.value * math.pi * 2 * 2);
              return Stack(children: [
                child!,
                if (k > 0.0 && k < 1.0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(sweep - 0.5, -1.0),
                            end: Alignment(sweep + 0.5, 1.0),
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.32),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 11.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Center(
                    child: Opacity(
                      opacity: twinkle,
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * twinkle,
                        child: const Icon(Icons.auto_awesome_rounded,
                            size: 15.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(33.0, 8.0, 15.0, 8.0),
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                    Color(0xFFC026D3),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28), width: 1.0),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: r,
                // แสงบนครึ่งบน ให้ดูมีผิวมัน
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
              child: Text(widget.label,
                  style: widget.style.copyWith(letterSpacing: 0.2)),
            ),
          ),
        ),
      ),
    );
  }
}

/// คำสั่งหมวด "อื่น ๆ" (oth) ของ standing order: Admit · บันทึก · อาหาร
/// จากใบ sepsis / open fracture (knowledge หัวข้อ 10)
const _OrderGroup _otherOrders =
    _OrderGroup('อื่น ๆ', Icons.more_horiz_rounded, _blue, [
  _OrderItem('Admit ward', 'ระบุหอผู้ป่วย', _OrderStatus.pending, ''),
  _OrderItem(
      'Record V/S, I/O', 'ทุก 15 นาที ถึง 1 ชม.', _OrderStatus.pending, ''),
  _OrderItem(
      'Record SOS score', 'Search Out Severity', _OrderStatus.pending, ''),
  _OrderItem('NPO', 'งดน้ำงดอาหาร', _OrderStatus.pending, ''),
  _OrderItem('Soft / regular diet', 'อาหารอ่อน หรือ อาหารธรรมดา',
      _OrderStatus.pending, ''),
]);

/// หมวดคำสั่งตามรหัสที่ทีมกำกับในเอกสาร standing order (knowledge ข้อ 48)
const List<(String, String)> _soGroupTitles = [
  ('M', 'ยา / เวชภัณฑ์'),
  ('L', 'แล็บ'),
  ('X', 'ภาพถ่าย'),
  ('ห', 'หัตถการ'),
  ('oth', 'อื่น ๆ'),
];

/// Standing order for sepsis / severe sepsis / septic shock (รพ.ปากเกร็ด)
/// (ชื่อคำสั่ง, รายละเอียด, หมวด, One Day?) · ตามภาพเอกสาร Figma 332-483 (knowledge 10.2)
/// ชื่อห้ามซ้ำกันในชุด (ใช้เป็น key ของรายการที่ติ๊ก)
const List<(String, String, String, bool)> _sepsisOrders = [
  // One Day
  ('Admit ward', 'ระบุหอผู้ป่วย', 'oth', true),
  ('CBC, BUN, Cr, Electrolyte', 'เจาะพร้อมกัน', 'L', true),
  ('DTX', 'mg/dl', 'L', true),
  ('LFT', 'การทำงานของตับ', 'L', true),
  ('PT, PTT, INR', 'พิจารณาส่งบางราย', 'L', true),
  ('Hemoculture × 2', 'ระบุเวลาเจาะ ก่อนให้ยาปฏิชีวนะ', 'L', true),
  ('Sputum gram, culture', 'เสมหะ', 'L', true),
  ('UA, U/C', 'ปัสสาวะ', 'L', true),
  ('Pus gram, C/S', 'ระบุตำแหน่งแผล', 'L', true),
  ('CXR', 'Chest X-ray', 'X', true),
  ('On oxygen', 'cannula หรือ mask ระบุ LPM', 'ห', true),
  ('On ETT', 'ระบุเบอร์ท่อ และตำแหน่ง mark (cm)', 'ห', true),
  (
    '0.9% NSS load 30 ml/kg',
    'severe sepsis หรือ septic shock ให้ทันที ครบภายใน 3 ชม.',
    'M',
    true
  ),
  ('0.9% NSS 1,000 ml iv load', 'ระบุ ml แล้ว iv drip ml/hr', 'M', true),
  (
    'Levophed (4:250) iv drip',
    'เริ่ม 5–10 ml/hr titrate ทีละ 3–5 ml/hr ทุก 5 นาที keep MAP ≥ 65',
    'M',
    true
  ),
  ('NG tube', 'ใส่สายให้อาหาร', 'ห', true),
  ('Foley catheter', 'เทปัสสาวะที่ค้างใน bladder ออกก่อน', 'ห', true),
  // Continuation
  ('Record V/S, I/O', 'ทุก 15 นาที', 'oth', false),
  ('Record SOS score', 'Search Out Severity', 'oth', false),
  ('Soft / regular diet', 'อาหารอ่อน หรือ อาหารธรรมดา', 'oth', false),
  ('BD (1:1)', 'ระบุ ml × 4 feeds', 'oth', false),
  ('NPO', 'งดน้ำงดอาหาร', 'oth', false),
  ('Dressing wound', 'ทำแผล', 'ห', false),
  ('DTX ติดตาม', 'ตามรอบที่กำหนด', 'ห', false),
  ('Antibiotic', 'ระบุชื่อยา ขนาด และเวลาให้', 'M', false),
];

/// รอบการบันทึก standing order หนึ่งครั้ง
/// items = (ชื่อคำสั่ง, รายละเอียด, สถานะ, One Day?)
/// แท็บคำสั่งแพทย์: ครั้งที่บันทึกที่เลือกดู (ต่อ HN · 0 = ล่าสุด)
final Map<String, int> _soSel = {};

class _SoRound {
  const _SoRound(this.no, this.time, this.by, this.set, this.items);
  final int no;
  final String time;
  final String by;
  final String set;
  final List<(String, String, String, bool)> items;
}

/// ประวัติการบันทึก standing order ของเคส (ค่าจำลอง ใหม่ → เก่า)
/// ครั้งแรกตอนรับเคส · ครั้งที่ 2 หลังประเมินซ้ำ (septic shock)
/// เคสที่ยังไม่เคยสั่ง Order Set (mock): ไม่มีประวัติคำสั่งแพทย์ · ใบติ๊กเริ่มว่าง
/// 670123478 นางสาวปิยะดา (ESI 5 มาขอใบรับรองแพทย์)
const Set<String> _soNoOrderYet = {'670123478'};

const List<_SoRound> _soHistory = [
  // ใบ appendicitis ที่แพทย์ติ๊กจริง (ภาพเอกสาร): สั่ง 14:00 น. ส่ง OR 16:00 น.
  _SoRound(1, '14:00', 'พญ. ศิริพร กิตติวงศ์', 'Appendicitis', [
    (
      "CBC, BUN, Cr, E'lyte, antiHIV",
      'WBC 15,800 neutrophil 86%',
      'ทำแล้ว',
      true
    ),
    ('UA', 'รอเก็บปัสสาวะ', 'รอรับ', true),
    ('UPT', 'negative', 'ทำแล้ว', true),
    ('EKG 12 leads', 'sinus rhythm 98/min', 'ทำแล้ว', true),
    ('Record V/S, I/O', '15 นาที × 4 แล้วทุก 1 ชม.', 'กำลังทำ', false),
    ('Cef3 2 g iv OD', 'ให้ 14:20 น. ก่อนเข้า OR', 'ทำแล้ว', false),
    (
      'Tramol 50 mg iv prn q 6 hr',
      'ให้ 14:10 น. pain 8/10 เหลือ 4/10',
      'ทำแล้ว',
      false
    ),
    ('NPO', 'ตั้งแต่ 13:30 น. เตรียมผ่าตัด', 'กำลังทำ', false),
  ]),
  _SoRound(2, '10:40', 'พญ. ศิริพร กิตติวงศ์', 'Sepsis', [
    (
      'Levophed (4:250) iv drip',
      'เริ่ม 5 ml/hr keep MAP ≥ 65',
      'กำลังทำ',
      true
    ),
    ('0.9% NSS 1,000 ml iv load', '500 ml แล้ว drip 100 ml/hr', 'ทำแล้ว', true),
    ('Hemoculture × 2', 'เจาะ 10:32 น. ก่อนให้ยา', 'ทำแล้ว', true),
    (
      'Antibiotic',
      'Piperacillin + Tazobactam 4.5 g IV q 8 hr',
      'ทำแล้ว',
      false
    ),
    ('Record SOS score', 'ทุก 1 ชม.', 'กำลังทำ', false),
  ]),
  _SoRound(1, '10:05', 'พญ. ศิริพร กิตติวงศ์', 'Sepsis', [
    ('0.9% NSS load 30 ml/kg', '1,900 ml ครบใน 3 ชม.', 'ทำแล้ว', true),
    ('CBC, BUN, Cr, Electrolyte', '', 'ทำแล้ว', true),
    ('DTX', '128 mg/dl', 'ทำแล้ว', true),
    ('UA, U/C', '', 'รอรับ', true),
    ('CXR', 'AP portable', 'ทำแล้ว', true),
    ('On oxygen', 'cannula 3 LPM', 'กำลังทำ', true),
    ('Record V/S, I/O', 'ทุก 15 นาที', 'กำลังทำ', false),
    ('NPO', '', 'กำลังทำ', false),
  ]),
];

/// standing order ที่ถอดจากเอกสารจริง: ชื่อชุด → (ชื่อคำสั่ง, รายละเอียด, หมวด, One Day?)
const Map<String, List<(String, String, String, bool)>> _soDocs = {
  'Sepsis': _sepsisOrders,
  'Stroke Fast Tract': _strokeFastOrders,
  'Stroke Non Fast Tract': _strokeNonFastOrders,
  'Appendicitis': _appendicitisOrders,
};

/// Standing order for appendicitis รพ.ปากเกร็ด (knowledge 10.6)
/// ใบนี้ไม่มีส่วน progress note · Continuation มีหัวข้อ MED แยก (หมวด M)
const List<(String, String, String, bool)> _appendicitisOrders = [
  // One Day
  ('Admit', 'ระบุหอผู้ป่วย', 'oth', true),
  ('Acetar 1,000 ml iv 80 ml/hr', '', 'M', true),
  ("CBC, BUN, Cr, E'lyte, antiHIV", '', 'L', true),
  ('UA', '', 'L', true),
  ('UPT', 'ผู้ป่วยหญิงวัยเจริญพันธุ์', 'L', true),
  ('EKG 12 leads', '', 'ห', true),
  ('CXR', '', 'X', true),
  ('CT lower abdomen with contrast', '', 'X', true),
  ('Set OR for Appendectomy SB', 'ระบุวันเวลา', 'ห', true),
  // Continuation
  ('NPO', '', 'oth', false),
  ('Record V/S, I/O', 'ระบุความถี่ เช่น 15 นาที × 4', 'oth', false),
  ('Dressing OD', '', 'ห', false),
  (
    'DTX q 8 hr',
    'Keep 80–200 mg%, 201–250 ให้ RI 4 u SC, 251–300 ให้ RI 6 u, '
        '301–350 ให้ RI 8 u, 351–400 ให้ RI 10 u, < 80 หรือ > 400 แจ้งแพทย์',
    'ห',
    false
  ),
  ('Urine output q 4 hr', '0.5–1 ml/kg/hr ระบุเกณฑ์ต่อ 4 ชม.', 'oth', false),
  // MED
  ('Metronidazole 500 mg iv q 8 hr', '', 'M', false),
  ('Cef3 2 g iv OD', 'Ceftriaxone', 'M', false),
  ('Tramol 50 mg iv prn q 6 hr', 'เมื่อปวด', 'M', false),
  ('Plasil 10 mg iv prn q 6 hr', 'เมื่อคลื่นไส้อาเจียน', 'M', false),
];

/// DOCTOR'S ORDER SHEET Stroke Unit Admission (Stroke Fast Tract/Rt-PA)
/// F-NUR-008 R/01 (17/05/67) · knowledge 10.4
const List<(String, String, String, bool)> _strokeFastOrders = [
  // One Day
  ('Admit Stroke Unit', '', 'oth', true),
  (
    'CBC, PT, PTT, INR, BUN, Cr, Electrolyte, Blood glucose, Anti-HIV',
    '',
    'L',
    true
  ),
  ('DTX', 'ระบุ mg/dL และน้ำหนักตัว (kg)', 'L', true),
  ('Tomorrow HbA1C, Lipid profile, FBS', 'เจาะพรุ่งนี้เช้า', 'L', true),
  ('CT Brain Non-Contrast Emergency', '', 'X', true),
  ('Chest X-Ray', '', 'X', true),
  ('EKG 12 leads', '', 'ห', true),
  (
    '0.9% NSS 1,000 ml IV drip',
    'ระบุ ml/hr keep SBP < 185 และ DBP < 110',
    'M',
    true
  ),
  (
    'Nicardipine 2.5 mg IV stat',
    'ถ้า BP > 185/110 แล้ว 2.5 mg/hr titrate q 5 min',
    'M',
    true
  ),
  ('Labetalol 10 mg IV', 'over 1–2 minutes', 'M', true),
  (
    'rtPA 0.9 mg/kg (max 90 mg)',
    '10% slow push ใน 1 นาที ที่เหลือหยดใน 60 นาที',
    'M',
    true
  ),
  (
    'Check V/S, N/S หลัง rtPA',
    'q 15 min × 2 hr แล้ว q 30 min × 6 hr แล้ว q 1 hr จนครบ 24 hr',
    'oth',
    true
  ),
  ('Monitor EKG 24 hours', '', 'ห', true),
  (
    'Avoid Foley, NG, central line, arterial puncture, IM',
    'ภายใน 24 ชม. หลังให้ rtPA',
    'oth',
    true
  ),
  ('CT Brain NC 24 hours after rt-PA', '', 'X', true),
  (
    'Consult IMC swallowing evaluation',
    'และ rehabilitation หลัง 24 ชม.',
    'oth',
    true
  ),
  // สงสัยเลือดออกในสมอง (ICH)
  ('Stop rtPA infusion', 'ถ้าสงสัย intracranial hemorrhage', 'M', true),
  ('Repeat CBC, Coagulogram', 'ถ้าสงสัย intracranial hemorrhage', 'L', true),
  ('Emergency CT Brain NC', 'ถ้าสงสัย intracranial hemorrhage', 'X', true),
  (
    'Cryoprecipitate 10 U in 30 min',
    'ถ้าสงสัย intracranial hemorrhage',
    'M',
    true
  ),
  ('Consult Neurosurgeon', 'ถ้าสงสัย intracranial hemorrhage', 'oth', true),
  // Continuation
  ('NPO เว้นยา', '', 'oth', false),
  ('Bedrest, fall precaution', '', 'oth', false),
  ('Record V/S, N/S, I/O', '', 'oth', false),
  ('DTX monitoring', 'premeal, hs', 'ห', false),
  ('Omeprazole 40 mg IV OD', '', 'M', false),
  (
    'ASA (300) 1 tab po pc',
    'หลังได้ rtPA 24 ชม. และ CT ไม่มี hemorrhage',
    'M',
    false
  ),
  ('Atorvastatin (40) 1 tab po hs', '', 'M', false),
  ('Paracetamol (500) 1 tab po prn', 'ไข้ ≥ 37.5 °C และแจ้งแพทย์', 'M', false),
];

/// DOCTOR'S ORDER SHEET Stroke Unit Admission (Stroke Non-Fast Tract/Rt-PA)
/// F-NUR-008 R/00 (13/02/66) · knowledge 10.5
const List<(String, String, String, bool)> _strokeNonFastOrders = [
  // One Day
  ('Admit Stroke Unit ward', 'ระบุหอผู้ป่วย', 'oth', true),
  ('CBC, BUN, Cr, E\'lyte, Blood glucose', '', 'L', true),
  ('PT, PTT, INR', '', 'L', true),
  ('Tomorrow HbA1C, Lipid profile, FBS', 'เจาะพรุ่งนี้เช้า', 'L', true),
  (
    'Thrombophilia work-up (อายุ < 45 ปี)',
    'ANA, Lupus anticoagulant, Protein C, Protein S, Antithrombin III, '
        'Anticardiolipin IgG, Anti-HIV, VDRL',
    'L',
    true
  ),
  ('CT Brain Non-Contrast', '', 'X', true),
  ('Chest X Ray', '', 'X', true),
  ('EKG 12 leads', '', 'ห', true),
  ('Keep Oxygen Saturation > 94%', '', 'ห', true),
  ('Monitor EKG 24 hours', '', 'ห', true),
  (
    '0.9% NSS 1,000 ml IV drip',
    'ระบุ ml/hr keep SBP ≤ 220 และ DBP ≤ 120',
    'M',
    true
  ),
  (
    'Nicardipine 5 mg IV stat',
    'ถ้า BP > 220/120 ลด MAP 15% แล้ว 2.5 mg/hr titrate q 5 min',
    'M',
    true
  ),
  ('Labetalol 10 mg IV', 'over 1–2 minutes', 'M', true),
  ('ASA (300) 1 tab po stat', 'Anticoagulant', 'M', true),
  ('Clopidogrel (75) 4 tab po stat', 'Anticoagulant', 'M', true),
  (
    'Consult IMC swallowing evaluation',
    'และ rehabilitation หลัง 24 ชม.',
    'oth',
    true
  ),
  (
    'Consider Neurosurgery consultation',
    'Malignant MCA, cerebellar infarction, acute hydrocephalus, ซึมลง',
    'oth',
    true
  ),
  (
    'GCS drop ≥ 2 แจ้งแพทย์',
    'หาสาเหตุ เช่น ขาดน้ำ ความดัน ไข้ น้ำตาล ติดเชื้อ stroke ซ้ำ สมองบวม ชัก',
    'oth',
    true
  ),
  // Continuation
  ('NPO เว้นยา', '', 'oth', false),
  ('Soft diet, low salt', '', 'oth', false),
  ('Regular diet, low salt', '', 'oth', false),
  ('Diabetic diet, low salt', '', 'oth', false),
  ('BD', 'ระบุสูตร ml × 4 feeds', 'oth', false),
  ('Bed rest, fall precaution, aspiration precaution', '', 'oth', false),
  ('พลิกตะแคงตัวทุก 2 ชม.', '', 'oth', false),
  ('Record V/S, N/S, I/O', '', 'oth', false),
  ('Retain NG tube', '', 'ห', false),
  ('Retain Foley\'s catheter', '', 'ห', false),
  ('DTX monitoring', 'premeal, hs', 'ห', false),
  ('ASA (81) 1 tab po pc เช้า', '', 'M', false),
  ('ASA (300) 1 tab po pc เช้า', '', 'M', false),
  ('Clopidogrel (75) 1 tab po pc เช้า', '', 'M', false),
  ('Atorvastatin (40) 1 tab po hs', '', 'M', false),
  ('Omeprazole (20) 1 × 1 po ac เช้า', '', 'M', false),
  ('Paracetamol (500) 1 tab po prn', 'ไข้ ≥ 37.5 °C และแจ้งแพทย์', 'M', false),
  ('If seizure consider AED', 'ระบุยากันชัก', 'M', false),
  (
    '20% Mannitol 1 g/kg IV in 30 min',
    'แล้ว 0.5 g/kg ใน 10 min (4–6 ครั้งต่อวัน)',
    'M',
    false
  ),
  ('10% Glycerol 1 g/kg IV', 'วันละ 4 ครั้ง max rate 125 ml/hr', 'M', false),
];

/// ชิ้นส่วนของใบ standing order (ใช้สร้าง task list ตามรูปแบบเอกสาร)
/// h = หัวข้อย่อยในคอลัมน์ (ตัวหนาในใบ เช่น "Fibrinolytic")
/// t = รายการติ๊ก · ข้อความ [หน่วย] = ช่องเว้นว่างให้กรอก (…… ในใบ)
/// n = หมายเหตุ/คำอธิบายต่อจากรายการก่อนหน้า (ไม่มีช่องติ๊ก)
/// alert = หัวข้อกรณีพิเศษ (เช่น สงสัยเลือดออกในสมอง) แสดงเป็นแถบแดงจาง
typedef _SoLine = (String kind, String text);

/// ใบคำสั่งหนึ่งใบ: หัวเอกสาร + 2 คอลัมน์ One Day / Continuation
class _SoDoc {
  const _SoDoc(this.title, this.code, this.oneDay, this.cont);
  final String title;
  final String code;
  final List<_SoLine> oneDay;
  final List<_SoLine> cont;
}

/// ใบที่ถอดโครงเอกสารครบ (หัวข้อ · ช่องเว้นว่าง · หมายเหตุ) · knowledge 10.4
const Map<String, _SoDoc> _soSheets = {
  'Stroke Fast Tract': _SoDoc(
    'Stroke Unit Admission (Stroke Fast Tract/Rt-PA)',
    'F-NUR-008 R/01 (17/05/67)',
    [
      ('t', 'Admit Stroke Unit'),
      ('t', 'CBC, PT, PTT, INR, BUN, Cr, Electrolyte, Blood glucose, Anti-HIV'),
      ('t', 'CT Brain Non-Contrast Emergency'),
      ('t', 'Chest X-Ray'),
      ('t', 'EKG 12 leads'),
      ('t', 'DTX [mg/dL] BW [kg]'),
      ('t', 'Tomorrow HbA1C, Lipid profile, FBS'),
      ('t', '0.9% NSS 1000 ml IV drip [ml/hr]'),
      ('h', 'Keep SBP < 185 และ DBP < 110 mmHg'),
      ('t', 'If BP > 185/110 mmHg give Nicardipine 2.5 mg IV stat'),
      ('n', 'then 2.5 mg/hr and titrate q 5 min'),
      ('t', 'Labetalol 10 mg IV over 1–2 minutes'),
      ('h', 'Fibrinolytic'),
      ('t', 'rtPA (0.9 mg/kg, max 90 mg) Total dose [mg]'),
      ('n', '10% slow push in 1 min then remaining in 60 minutes'),
      ('t', 'Check V/S, N/S and complication after rtPA'),
      ('n', 'q 15 min × 2 hr → q 30 min × 6 hr → q 1 hr until 24 hr'),
      ('n', 'Notify if BP > 180/105 or < 90/60 mmHg or GCS drop ≥ 2'),
      ('t', 'Monitor EKG 24 hours'),
      (
        't',
        'Avoid Foley, NG, central line, arterial puncture, IM within 24 hr of rtPA'
      ),
      ('alert', 'If suspecting intracranial hemorrhage'),
      ('t', 'Stop rtPA infusion'),
      ('t', 'Repeat CBC, Coagulogram'),
      ('t', 'Emergency CT Brain NC'),
      ('t', 'Cryoprecipitate 10 U in 30 min'),
      ('t', 'Consult Neurosurgeon'),
      ('h', 'หลัง 24 ชม.'),
      ('t', 'CT Brain NC 24 hours after rt-PA'),
      ('t', 'Consult IMC for swallowing evaluation and rehabilitation'),
    ],
    [
      ('t', 'NPO เว้นยา'),
      ('t', 'Bedrest, fall precaution'),
      ('t', 'Record V/S, N/S, I/O'),
      ('t', 'DTX monitoring premeal, hs'),
      ('t', 'Other [ระบุ]'),
      ('h', 'Medication'),
      ('t', 'Omeprazole 40 mg IV OD'),
      ('t', 'ASA (300) 1 tab po pc'),
      ('n', 'หลังได้ rtPA 24 ชม. และ CT ไม่มี hemorrhage'),
      ('t', 'Atorvastatin (40) 1 tab po hs'),
      ('t', 'Paracetamol (500) 1 tab po prn for fever ≥ 37.5 °C'),
      ('n', 'and please notify the doctor'),
    ],
  ),
};

extension _FeaturesPatientSoSheetPart on _ErFlowHomeWidgetState {
  /// ใบของชุดที่เลือก: ถอดโครงครบ = ใช้ใบนั้น · ไม่งั้นสร้างจากรายการคำสั่ง (ไม่มีหัวข้อย่อย)
  _SoDoc? _soDocOf(String cat) {
    final full = _soSheets[cat];
    if (full != null) return full;
    final rows = _soDocs[cat];
    if (rows == null) return null;
    List<_SoLine> col(bool oneDay) => [
          for (final r in rows)
            if (r.$4 == oneDay) ...[
              ('t', r.$1),
              if (r.$2.isNotEmpty) ('n', r.$2),
            ],
        ];
    return _SoDoc('Standing order $cat', '', col(true), col(false));
  }

  /// generative task list: วาดใบคำสั่งตามรูปแบบเอกสาร จากข้อมูลโครงใบ
  Widget _soSheet({bool scroll = true}) {
    final doc = _soDocOf(_template);
    if (doc == null) {
      return Center(
          child: Text('ชุดนี้ยังไม่มีใบคำสั่ง', style: _t(12.0, color: _ink3)));
    }
    final ticks = [
      for (final l in [...doc.oneDay, ...doc.cont])
        if (l.$1 == 't') l.$2
    ];
    final done = ticks.where((t) => _soTick.contains('$_template|$t')).length;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // หัวเอกสาร: ชื่อใบ + รหัสฟอร์ม/รุ่น + ความคืบหน้า
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title,
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
                if (doc.code.isNotEmpty)
                  Text(doc.code, style: _t(10.5, color: _ink3)),
              ],
            ),
          ),
          Text('$done/${ticks.length}',
              style: _num(12.0, color: _ink2, weight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10.0),
        _soColumn('Order One Day', Icons.today_rounded, doc.oneDay),
        const SizedBox(height: 10.0),
        _soColumn('Order for Continuation', Icons.repeat_rounded, doc.cont),
      ],
    );
    return scroll ? SingleChildScrollView(child: body) : body;
  }

  /// คอลัมน์หนึ่งของใบ: การ์ดซ้อน หัวกรมท่า + แผ่นขาวรายการตามลำดับเอกสาร
  Widget _soColumn(String title, IconData icon, List<_SoLine> lines) {
    final rows = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      final (kind, text) = lines[i];
      switch (kind) {
        case 'h':
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
            child: Text(text,
                style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
          ));
        case 'alert':
          rows.add(Container(
            margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 14.0, color: _red),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(text,
                    style: _t(11.5, color: _red, weight: FontWeight.w600)),
              ),
            ]),
          ));
        case 'n':
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 4.0),
            child: Text(text, style: _t(10.5, color: _ink3, height: 1.3)),
          ));
        default:
          rows.add(_soTask(text));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14.0, 9.0, 14.0, 9.0),
          child: Row(children: [
            Icon(icon, size: 14.0, color: Colors.white),
            const SizedBox(width: 6.0),
            Text(title,
                style: _t(12.0, color: Colors.white, weight: FontWeight.w600)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 10.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
      ]),
    );
  }

  /// รายการติ๊กหนึ่งบรรทัด · [หน่วย] ในข้อความ = ช่องกรอกในบรรทัด
  Widget _soTask(String text) {
    final key = '$_template|$text';
    final on = _soTick.contains(key);
    final parts = <InlineSpan>[];
    final re = RegExp(r'\[([^\]]+)\]');
    var last = 0;
    var n = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        parts.add(TextSpan(text: text.substring(last, m.start)));
      }
      final bk = '$key#${n++}';
      parts.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: _soBlankField(bk, m.group(1)!),
      ));
      last = m.end;
    }
    if (last < text.length) parts.add(TextSpan(text: text.substring(last)));
    return InkWell(
      onTap: () => setState(() => on ? _soTick.remove(key) : _soTick.add(key)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 18.0,
            height: 18.0,
            margin: const EdgeInsets.only(top: 1.0, right: 12.0),
            decoration: BoxDecoration(
              color: on ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: on ? _blue : _g5, width: 1.5),
            ),
            child: on
                ? const Icon(Icons.check_rounded,
                    size: 13.0, color: Colors.white)
                : null,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(children: parts),
              style: _t(12.0,
                  color: on ? _inkTitle : _ink2,
                  weight: FontWeight.w500,
                  height: 1.45),
            ),
          ),
        ]),
      ),
    );
  }

  /// ช่องเว้นว่างในบรรทัด (…… ในใบ): กล่องเล็ก + หน่วยจาง ๆ เป็น hint
  Widget _soBlankField(String key, String unit) => Container(
        width: unit.length > 4 ? 120.0 : 72.0,
        height: 26.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: _line, width: 0.5),
        ),
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _soBlank[key],
          onChanged: (v) => _soBlank[key] = v,
          style: _num(11.5, color: _inkTitle, weight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: unit,
            hintStyle: _t(10.5, color: _ink3),
          ),
        ),
      );
}

/// ความสูงแถวแท็บหัวแฟ้มบนการ์ดซ้าย
const double _soTabH = 36.0;

/// Progress note (ประเมิน) ที่อยู่คู่กับใบ standing order (knowledge 10.2)
/// ชุดที่ใบจริงไม่มีส่วนประเมิน ไม่แสดงแฟ้มนี้
const Map<String, List<String>> _soProgress = {
  'Sepsis': [
    'เวลาสำคัญ',
    'SIRS criteria (2 ใน 4 ข้อ)',
    'ตำแหน่งติดเชื้อที่พบ',
    'Organ dysfunction (PE)',
    'วินิจฉัยเป็น (Dx)',
    'ประวัติแพ้ยา แพ้อาหาร',
    'ยานอก รพ. และอาหารเสริม',
  ],
};

/// หัวข้อในใบที่ซ้ำกับส่วนอื่นของเวชระเบียน: ไม่ให้กรอกซ้ำ ดึงค่ามาแสดง
/// หัวข้อ → (ที่มา, ไอคอน)
const Map<String, (String, IconData)> _soPnLinked = {
  'เวลาสำคัญ': ('เวลามาถึงจากขั้นคัดกรอง', Icons.schedule_rounded),
  'วินิจฉัยเป็น (Dx)': ('ลงในขั้นวินิจฉัย (ICD-10)', Icons.assignment_rounded),
  'ประวัติแพ้ยา แพ้อาหาร': (
    'ประวัติแพ้ยาในเวชระเบียน',
    Icons.warning_amber_rounded
  ),
};

/// รูปแบบหัวข้อ Progress Note ตามใบจริง: (ชนิด, ตัวเลือก, ช่องเว้นว่าง)
/// ชนิด time = ช่องเวลา · multi = ติ๊กได้หลายข้อ · single = เลือกข้อเดียว
const Map<String, (String, List<String>, List<(String, String)>)> _soPnSpec = {
  'เวลาสำคัญ': (
    'time',
    [],
    [('มาถึง รพ.', 'น.'), ('มาถึง ER', 'น.'), ('วินิจฉัย sepsis', 'น.')]
  ),
  'SIRS criteria (2 ใน 4 ข้อ)': (
    'multi',
    [
      'T > 38 °C หรือ < 36 °C',
      'HR > 90/min',
      'RR > 20/min หรือ PaCO₂ < 32',
      'WBC > 12,000 หรือ < 4,000',
    ],
    []
  ),
  'ตำแหน่งติดเชื้อที่พบ': (
    'multi',
    [
      'Pulmonary',
      'Abdominal',
      'Urinary tract',
      'Skin/soft tissue',
      'CNS',
      'Other',
    ],
    [('ระบุ', '')]
  ),
  'Organ dysfunction (PE)': (
    'multi',
    [
      'Kidney: urine < 0.5 ml/kg/hr, AKI',
      'Heart: CHF',
      'Lung: respiratory failure/ARDS',
      'CNS: ซึมลง สับสน',
      'GI: ท้องอืด ตัวตาเหลือง',
      'Skin: capillary refill > 2 sec',
      'Blood: Plt < 100,000, INR > 1.5',
      'Septic shock',
    ],
    []
  ),
  'วินิจฉัยเป็น (Dx)': (
    'single',
    ['SIRS', 'Sepsis', 'Severe sepsis', 'Septic shock'],
    []
  ),
  'ประวัติแพ้ยา แพ้อาหาร': (
    'single',
    ['ไม่มี', 'มี'],
    [('ชื่อยา/อาหาร', ''), ('อาการแพ้', '')]
  ),
  'ยานอก รพ. และอาหารเสริม': ('single', ['ไม่ใช้', 'ใช้'], [('ระบุ', '')]),
};

/// ช่องเว้นว่าง (……) ในบรรทัดคำสั่งของใบจริง: ชื่อคำสั่ง → (ชื่อช่อง, หน่วย)
const Map<String, List<(String, String)>> _soBlanks = {
  'Admit ward': [('หอผู้ป่วย', '')],
  'DTX': [('ผล', 'mg/dl')],
  'Hemoculture × 2': [('เวลาเจาะ', 'น.')],
  'Pus gram, C/S': [('จากแผลที่', '')],
  'On oxygen': [('ชนิด', 'cannula/mask'), ('อัตรา', 'LPM')],
  'On ETT': [('เบอร์', 'no.'), ('mark', 'cm')],
  '0.9% NSS 1,000 ml iv load': [('load', 'ml'), ('iv drip', 'ml/hr')],
  'BD (1:1)': [('ปริมาณ', 'ml × 4F')],
  'DTX ติดตาม': [('ทุก', 'ครั้ง/วัน')],
  'Antibiotic': [('ชื่อยา ขนาด', ''), ('ให้เวลา', 'น.')],
  'Set OR for Appendectomy SB': [('วันเวลา', 'น.')],
  'Urine output q 4 hr': [('keep ≥', 'ml/4 hr')],
};

/// หมวดที่ทีมกำกับไว้มากกว่า 1 หมวดในใบจริง (เช่น oth + M, ห + oth)
const Map<String, Set<String>> _soCatMulti = {
  '0.9% NSS load 30 ml/kg': {'Other', 'Medication'},
  'Levophed (4:250) iv drip': {'Other', 'Medication'},
  'Foley catheter': {'Procedure', 'Other'},
};

/// ชื่อเต็มของชุดตามหัวใบ standing order
const Map<String, String> _soFullName = {
  'Sepsis': 'Sepsis / severe sepsis / septic shock',
  'Appendicitis': 'Standing order for appendicitis',
};

extension _SoDocPagePart on _ErFlowHomeWidgetState {
  /// หน้าคำสั่งแพทย์ (Figma 331-350): ชุดที่ใช้ + แฟ้มซ้อน Progress Note / One Day / Continuation
  /// เปิดได้ทีละแฟ้ม (P9) แตะหัวแฟ้มเพื่อสลับ
  /// แฟ้มของชุดที่เลือก: (id, ชื่อ, รายการ, ชุดที่ติ๊ก, คีย์นำหน้า)
  /// 0 = Progress Note · 1 = Order for One Day · 2 = Order for Continuation
  List<(int, String, List<(String, String)>, Set<String>, String)>
      _soFolders() {
    final doc = _soDocs[_template];
    final pn = _soProgress[_template] ?? const <String>[];
    final List<(String, String)> oneDay, cont;
    if (doc != null) {
      oneDay = [
        for (final o in doc)
          if (o.$4) (o.$1, o.$2)
      ];
      cont = [
        for (final o in doc)
          if (!o.$4) (o.$1, o.$2)
      ];
    } else {
      oneDay = [
        for (final (_, items) in _orderSetPages(_template))
          for (final n in items) (n, '')
      ];
      cont = const [];
    }
    return <(int, String, List<(String, String)>, Set<String>, String)>[
      if (pn.isNotEmpty)
        (
          0,
          'Progress Note',
          [for (final t in pn) (t, '')],
          _soPnPick,
          '$_template|'
        ),
      if (oneDay.isNotEmpty) (1, 'Order for One Day', oneDay, _orderPicked, ''),
      if (cont.isNotEmpty)
        (2, 'Order for Continuation', cont, _orderPicked, ''),
    ];
  }

  /// หน้าแฟ้มเดียวใน stepper (แยกขั้นต่อแฟ้ม): การ์ดแบบ _dxCard + รายการเต็ม
  Widget _soFolderPage(int id) {
    final ed = _soEditItem;
    if (ed != null && _soSecId(ed.section) == id) return _soEditPage(ed);
    final folders = _soFolders();
    final i = folders.indexWhere((f) => f.$1 == id);
    if (i < 0) return const SizedBox.shrink();
    final (_, title, items, picks, key) = folders[i];
    final done = items
        .where((it) =>
            picks.contains('$key${it.$1}') ||
            (picks == _soPnPick &&
                _soPnLinked.containsKey(it.$1) &&
                _soLinkedValue(it.$1) != null))
        .length;
    final sub = switch (id) {
      0 => 'ประเมินตามเกณฑ์ของชุด',
      1 => 'คำสั่งครั้งเดียว ทำแล้วจบ',
      _ => 'คำสั่งต่อเนื่อง ทำซ้ำตามรอบ',
    };
    final art = switch (id) {
      0 => 'assets/images/er_dx_pencil.png',
      1 => 'assets/images/er_os_med.png',
      _ => 'assets/images/er_os_proc.png',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ชุดที่ใช้อยู่แสดงเฉพาะหน้าแรกของกลุ่มแฟ้ม
        if (i == 0) ...[_soSetRow(), const SizedBox(height: 12.0)],
        _dxCard(
          title,
          sub,
          _dxArtFade(Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 12.0, 16.0, 0.0),
            child: Image.asset(art, fit: BoxFit.contain),
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Text('เลือกแล้ว $done/${items.length}',
                    style: _num(13.0,
                        color: done == items.length ? _green : _ink2,
                        weight: FontWeight.w600)),
              ),
              for (var k = 0; k < items.length; k++) ...[
                const Divider(
                    height: 1.0,
                    thickness: 0.5,
                    indent: 8.0,
                    endIndent: 8.0,
                    color: Color(0xFFE8EAED)),
                _soDocRow(items[k], picks, key),
              ],
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _soDocPage() {
    final folders = _soFolders();
    // -2 = ผู้ใช้หุบทุกใบ · ค่าอื่นที่ไม่มีในชุด = เปิดใบแรก
    final open = _soOpen == -2
        ? -2
        : folders.any((f) => f.$1 == _soOpen)
            ? _soOpen
            : (folders.isEmpty ? -1 : folders.first.$1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _soSetRow(),
        // แฟ้มแต่ละหมวดเป็นการ์ดขาวแบบแผงวินิจฉัย เปิดได้ทีละใบ (P9)
        for (var i = 0; i < folders.length; i++) ...[
          const SizedBox(height: 12.0),
          _soFolder(folders[i], open == folders[i].$1, i,
              last: i == folders.length - 1),
        ],
      ],
    );
  }

  /// ชุดที่ใช้อยู่: แถวกะทัดรัดแบบรายการ ICD-10 ที่เลือกแล้ว (ไอคอน + ชื่อชุด + จำนวน)
  Widget _soSetRow() => Container(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 16.0, 12.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration:
                const BoxDecoration(color: _blue, shape: BoxShape.circle),
            child: const Icon(Icons.assignment_rounded,
                size: 18.0, color: Colors.white),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Standing order',
                      style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
                  Text(_soFullName[_template] ?? _setName(_template),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
                ]),
          ),
          const SizedBox(width: 8.0),
          Text('${_soDeckItems().length}',
              style: _num(17.0, color: _inkTitle, weight: FontWeight.w700)),
        ]),
      );

  Widget _soFolder((int, String, List<(String, String)>, Set<String>, String) f,
      bool open, int depth,
      {bool last = false}) {
    final (id, title, items, picks, key) = f;
    final done = items
        .where((it) =>
            picks.contains('$key${it.$1}') ||
            (picks == _soPnPick &&
                _soPnLinked.containsKey(it.$1) &&
                _soLinkedValue(it.$1) != null))
        .length;
    final sub = switch (id) {
      0 => 'ประเมินตามเกณฑ์ของชุด',
      1 => 'คำสั่งครั้งเดียว ทำแล้วจบ',
      _ => 'คำสั่งต่อเนื่อง ทำซ้ำตามรอบ',
    };
    // การ์ดขาวขอบบาง มุม 16 (ภาษาเดียวกับ _dxCard) · หัว = ชื่อ + คำอธิบาย + จำนวนที่เลือก
    return Container(
      key: _soFolderKeys.putIfAbsent(id, GlobalKey.new),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              // แตะหัวการ์ดที่เปิดอยู่ = หุบ · การ์ดที่ปิด = เปิด (ใบอื่นหุบ)
              setState(() => _soOpen = open ? -2 : id);
              if (open) return;
              // snap: เลื่อนให้หัวการ์ดที่เปิดชิดบนของแผง (รอการ์ดอื่นหุบก่อน)
              Future.delayed(const Duration(milliseconds: 280), () {
                final c = _soFolderKeys[id]?.currentContext;
                if (c != null && c.mounted) {
                  Scrollable.ensureVisible(c,
                      alignment: 0.0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 14.0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(17.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      const SizedBox(height: 2.0),
                      Text(sub,
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ],
                  ),
                ),
                Text('$done/${items.length}',
                    style: _num(13.0,
                        color: done == items.length ? _green : _ink2,
                        weight: FontWeight.w600)),
                const SizedBox(width: 6.0),
                AnimatedRotation(
                  turns: open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22.0, color: _ink3),
                ),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        const Divider(
                            height: 1.0,
                            thickness: 0.5,
                            indent: 16.0,
                            endIndent: 16.0,
                            color: Color(0xFFE8EAED)),
                        _soDocRow(items[i], picks, key),
                      ],
                      const SizedBox(height: 6.0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _soDocRow((String, String) it, Set<String> picks, String key) {
    final id = '$key${it.$1}';
    final on = picks.contains(id);
    final link = picks == _soPnPick ? _soPnLinked[it.$1] : null;
    if (link != null) return _soLinkedRow(it.$1, link);
    // รายการจากคำสั่งเดิม: ทำแล้ว = ล็อก · ยังไม่ทำ = ยกเลิกได้ (ยืนยันก่อน)
    final prevSt = _soPrevStatus(it.$1);
    final locked = prevSt == 'ทำแล้ว';
    Future<void> toggle() async {
      if (locked) {
        HapticFeedback.heavyImpact();
        return;
      }
      if (prevSt != null && on) {
        final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: _panel,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: Text('ยกเลิกคำสั่งนี้?',
                    style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                content: Text('${it.$1} (สถานะ $prevSt)',
                    style: _t(13.5, color: _ink2, weight: FontWeight.w500)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('ยกเลิก',
                          style:
                              _t(14.0, color: _ink2, weight: FontWeight.w600))),
                  FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('ยกเลิกคำสั่ง',
                          style: _t(14.0,
                              color: Colors.white, weight: FontWeight.w600))),
                ],
              ),
            ) ??
            false;
        if (!ok || !mounted) return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        if (on) {
          picks.remove(id);
          _soAi.remove(id);
        } else {
          picks.add(id);
          // ติ๊กแล้วฝั่งซ้ายเปิดการ์ดกรอกรายละเอียดของรายการนั้นทันที
          _soFocus = id;
        }
      });
    }

    // แตะแถว = เปิดหน้ากรอกรายละเอียด (ยังไม่ติ๊ก = ติ๊กให้ก่อน) · แตะวงกลม = ติ๊ก/เอาออก
    return InkWell(
      onTap: () {
        if (locked) {
          HapticFeedback.heavyImpact();
          return;
        }
        if (!on) setState(() => picks.add(id));
        _soEditOpen(id);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(it.$1,
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w500)),
                  ),
                  // Dr.Note กรอกให้ รอแพทย์ยอมรับ
                  if (_soAi.contains(id)) ...[
                    const SizedBox(width: 6.0),
                    _soAiTag(),
                  ],
                  // คำสั่งเดิม: ป้ายสถานะ · ไม่มีป้าย + ติ๊ก = รายการใหม่
                  if (prevSt != null) ...[
                    const SizedBox(width: 6.0),
                    Text(on ? prevSt : 'ยกเลิกแล้ว',
                        style: _t(11.5,
                            color: !on
                                ? _red
                                : prevSt == 'ทำแล้ว'
                                    ? _green
                                    : _blue,
                            weight: FontWeight.w600)),
                  ] else if (on && _soContHn.contains(_caseP().hn)) ...[
                    const SizedBox(width: 6.0),
                    Text('ใหม่',
                        style: _t(11.5, color: _blue, weight: FontWeight.w700)),
                  ],
                ]),
                if (it.$2.isNotEmpty)
                  Text(it.$2, style: _t(12.0, color: _ink3)),
                // ค่าที่กรอกแล้วในหน้ารายละเอียด
                if (on)
                  if (_soDeckItems().where((x) => x.id == id).firstOrNull
                      case final d?)
                    if (_soDetailLine(d) case final l when l.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(l,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.0,
                                color: _soDone.contains(id) ? _green : _blue,
                                weight: FontWeight.w500)),
                      ),
              ],
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? (locked ? _ink3 : _blue) : Colors.transparent,
                      border: Border.all(
                          color: on ? (locked ? _ink3 : _blue) : _g5,
                          width: 1.5),
                    ),
                    child: on
                        ? const Icon(Icons.check_rounded,
                            size: 14.0, color: Colors.white)
                        : null,
                  ))),
        ]),
      ),
    );
  }
}

/// การ์ดหนึ่งใบในสำรับฝั่งซ้าย
class _SoDeckItem {
  const _SoDeckItem(this.id, this.name, this.section, this.cat, this.tone,
      [this.detail = '']);
  final String id;
  final String name;

  /// รายละเอียดบรรทัดในใบ (คำอธิบายใต้ชื่อ)
  final String detail;

  /// แฟ้มที่อยู่: Progress Note / One Day / Continuation
  final String section;

  /// หมวดเริ่มต้นตามรหัสในใบ (Lab, Procedure, X-ray, Medication, Other)
  final String cat;

  /// สีหัวการ์ด = สีแฟ้มที่รายการนี้อยู่ในแผงขวา
  final Color tone;
}

/// id ของการ์ดสรุป (ใบสุดท้ายในสำรับ)
const String _soSummaryId = '__summary__';

/// สีแฟ้มตามชั้น (ใช้ทั้งแฟ้มในแผงขวาและการ์ดในสำรับซ้าย)
const List<Color> _soTones = [
  Color(0xFF3B5FD9),
  Color(0xFF6A88E4),
  Color(0xFF97ADEE),
];

extension _SoDeckPart on _ErFlowHomeWidgetState {
  /// คำสั่งที่ติ๊กในแผงขวา เรียงตามแฟ้ม: Progress Note → One Day → Continuation
  List<_SoDeckItem> _soDeckItems() {
    String cat(String code) => switch (code) {
          'M' => 'Medication',
          'L' => 'Lab',
          'X' => 'X-ray',
          'ห' => 'Procedure',
          _ => 'Other',
        };
    final doc = _soDocs[_template] ?? const [];
    final pn = _soProgress[_template] ?? const <String>[];
    final base = pn.isEmpty ? 0 : 1;
    return [
      // หัวข้อที่ดึงจากส่วนอื่นไม่ต้องระบุรายละเอียดซ้ำ
      for (final t in pn)
        if (_soPnPick.contains('$_template|$t') && !_soPnLinked.containsKey(t))
          _SoDeckItem(
              '$_template|$t', t, 'Progress Note', 'Other', _soTones[0]),
      for (final one in [true, false])
        for (final o in doc)
          if (o.$4 == one && _orderPicked.contains(o.$1))
            _SoDeckItem(o.$1, o.$1, one ? 'One Day' : 'Continuation', cat(o.$3),
                _soTones[(base + (one ? 0 : 1)).clamp(0, 2)], o.$2),
      // ชุดที่ไม่มีใบ standing order แยก (เช่น Trauma General): ใช้รายการจากหมวดของชุด
      // แบบเดียวกับแผงขวา (One Day) · หมวดตามชื่อกลุ่ม
      if (doc.isEmpty)
        for (final (g, items) in _orderSetPages(_template))
          for (final n in items)
            if (_orderPicked.contains(n))
              _SoDeckItem(
                  n,
                  n,
                  'One Day',
                  g.startsWith('ยา')
                      ? 'Medication'
                      : g.startsWith('แล็บ') || g == 'Lab'
                          ? 'Lab'
                          : g.startsWith('ภาพ') || g == 'X-ray'
                              ? 'X-ray'
                              : g.startsWith('หัตถการ')
                                  ? 'Procedure'
                                  : 'Other',
                  _soTones[base.clamp(0, 2)]),
    ];
  }

  /// สำรับการ์ด (Figma 331-350 ฝั่งซ้าย): การ์ดหน้า = คำสั่งที่กำลังระบุรายละเอียด
  /// ใบถัดไปซ้อนอยู่ด้านขวา ปุ่มซ้ายขวาเลื่อนทีละใบ
  Widget _soDeck() {
    final items = _soDeckItems();
    if (items.isEmpty) {
      // เลือกชุดแล้วแต่ยังไม่ติ๊ก: empty state แบบเดียวกับยังไม่มีคำสั่ง (ไม่ใช้แถบ AI สีม่วงเดิม)
      return _soEmpty('ยังไม่ได้เลือกรายการ',
          'ชุด ${_setName(_template)} พร้อมแล้ว ติ๊กคำสั่งในขั้นถัดไปทางขวา\nหรือกด AI แนะนำ ให้ช่วยเลือกชุดจากข้อมูลเคส');
    }
    // แผงซ้าย = สรุปคำสั่งอย่างเดียว · กรอกรายละเอียดรายการอยู่แผงขวา (แตะแถวเพื่อเปิด)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
      child: _soSummaryCard(items),
    );
  }

  /// ปุ่มเลื่อนการ์ดขึ้น/ลง (ซ้ายล่าง thumb zone)
  Widget _soNav(IconData icon, VoidCallback? onTap) => _Press(
        child: GestureDetector(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: _panel,
              shape: BoxShape.circle,
              border: Border.all(color: _line, width: 0.5),
            ),
            child:
                Icon(icon, size: 22.0, color: onTap == null ? _g5 : _inkTitle),
          ),
        ),
      );

  /// จุดบอกลำดับ: ใบปัจจุบันเป็นแท่งยาว · เยอะเกิน 10 ใบแสดงเฉพาะรอบ ๆ + ตัวเลข
  Widget _soDots(int pos, int n) {
    final lo = n <= 10 ? 0 : (pos - 4).clamp(0, n - 10);
    final hi = n <= 10 ? n : lo + 10;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = lo; i < hi; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 4.0),
          width: i == pos ? 18.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: i == pos ? _blue : _g5.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      const SizedBox(width: 6.0),
      Text('${pos + 1}/$n',
          style: _num(11.5, color: _ink3, weight: FontWeight.w600)),
    ]);
  }

  Widget _soBtn(String t, IconData icon, bool primary, VoidCallback onTap) =>
      _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 22.0, vertical: 13.0),
            decoration: BoxDecoration(
              color: primary ? _blue : _panel,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: primary ? _blue : _line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 19.0, color: primary ? Colors.white : _ink2),
              const SizedBox(width: 8.0),
              Text(t,
                  style: _t(14.5,
                      color: primary ? Colors.white : _ink2,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// ยืนยัน/ยอมรับใบนี้ แล้วไปใบถัดไปที่ยังไม่ยืนยัน · ยืนยันแล้วแตะอีกที = แก้ไข
  void _soConfirm(_SoDeckItem it) {
    final items = _soDeckItems();
    final i = items.indexWhere((x) => x.id == it.id);
    setState(() {
      _soAi.remove(it.id);
      if (_soDone.contains(it.id)) {
        _soDone.remove(it.id);
        return;
      }
      _soDone.add(it.id);
      // ใบถัดไป: ที่ Dr.Note กรอกรอตรวจก่อน ไม่มีแล้วค่อยใบที่ยังไม่ยืนยัน
      final rest = items.skip(i + 1);
      final next = rest.where((x) => _soAi.contains(x.id)).firstOrNull ??
          rest.where((x) => !_soDone.contains(x.id)).firstOrNull;
      // ยืนยันครบทุกใบ = ไปหน้าสรุป
      _soFocus = next?.id ??
          (items.every((x) => _soDone.contains(x.id))
              ? _soSummaryId
              : _soFocus);
    });
  }

  /// แถวแท็บหัวแฟ้ม 3 แท็บตามแฟ้มของใบ: Progress Note / One Day / Continuation
  /// แท็บที่เลือก = แฟ้มของการ์ดหน้า (สีขาวต่อกับการ์ด) แตะแท็บ = ไปใบแรกของแฟ้มนั้น
  /// ตัวเลขในแท็บ = ยืนยันแล้ว / ทั้งหมดของแฟ้ม
  Widget _soTabsRow(List<_SoDeckItem> items, int at) {
    final cur = items.isEmpty ? '' : items[at].section;
    final secs = <String>[
      for (final x in items) x.section,
    ].toSet().toList();
    // แท็บเกินความกว้างแผง (สรุป + 3 แฟ้ม) = เลื่อนแนวนอนได้ ไม่ล้นขอบ
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final sec in secs)
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: () {
                final sum = sec == 'Summary';
                // แท็บสรุป: นับยืนยันแล้วจากทุกแฟ้ม
                final ofSec = sum
                    ? items.where((x) => x.id != _soSummaryId).toList()
                    : items.where((x) => x.section == sec).toList();
                final done = ofSec.where((x) => _soDone.contains(x.id)).length;
                if (sum) {
                  return _soHeadTab(
                      'สรุป', _blue, sec == cur, '$done/${ofSec.length}', () {
                    if (sec == cur) return;
                    HapticFeedback.selectionClick();
                    setState(() => _soFocus = _soSummaryId);
                  });
                }
                return _soHeadTab(
                    sec == 'Progress Note' ? 'Progress Note' : 'Order for $sec',
                    ofSec.first.tone,
                    sec == cur,
                    '$done/${ofSec.length}', () {
                  if (sec == cur) return;
                  HapticFeedback.selectionClick();
                  // ไปใบแรกที่ยังไม่ยืนยันของแฟ้มนั้น
                  final to =
                      ofSec.where((x) => !_soDone.contains(x.id)).firstOrNull ??
                          ofSec.first;
                  setState(() => _soFocus = to.id);
                });
              }(),
            ),
        ],
      ),
    );
  }

  /// แท็บแบบ pill (Google style): ที่เลือก = พื้นฟ้าอ่อน ตัวกรมท่าหนา · ไม่เลือก = ตัวเทา ไม่มีพื้น
  Widget _soHeadTab(
      String label, Color tone, bool on, String count, VoidCallback onTap) {
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: _soTabH,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? _blue.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: _t(13.0,
                    color: on ? _blue : _ink2,
                    weight: on ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(width: 6.0),
            Text(count,
                style: _num(12.0,
                    color: on ? _blue : _ink3, weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// การ์ดหน้าสำรับ (stacked card): หัวเทา = หมวด + ชื่อคำสั่ง + ต้องวัดซ้ำ
  /// แผ่นขาวทับด้านล่าง = ช่องหมายเหตุ
  /// แถวข้อมูลแบบ property list: ไอคอน + ชื่อช่อง (คอลัมน์คงที่) | ค่า
  Widget _soPill(String t, Color c, {IconData? icon}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 8.0, color: c),
            const SizedBox(width: 5.0),
          ],
          Text(t, style: _t(10.5, color: c, weight: FontWeight.w600)),
        ]),
      );

  Set<String> _soCatsOf(_SoDeckItem it) =>
      _soCats[it.id] ?? _soCatMulti[it.id] ?? {it.cat};

  /// หมวดแก้ได้ เลือกได้หลายหมวด (ต้องเหลืออย่างน้อย 1) ค่าเริ่มตามรหัสในใบ
  Widget _soCatPicker(_SoDeckItem it) {
    final on = _soCatsOf(it);
    return Wrap(spacing: 6.0, runSpacing: 6.0, children: [
      for (final c in const [
        'Lab',
        'Procedure',
        'X-ray',
        'Medication',
        'Other'
      ])
        GestureDetector(
          onTap: () {
            final next = {...on};
            if (next.contains(c)) {
              if (next.length == 1) return;
              next.remove(c);
            } else {
              next.add(c);
            }
            HapticFeedback.selectionClick();
            setState(() => _soCats[it.id] = next);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: on.contains(c)
                  ? it.tone.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                  color:
                      on.contains(c) ? it.tone.withValues(alpha: 0.5) : _line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (on.contains(c)) ...[
                Icon(Icons.check_rounded, size: 12.0, color: it.tone),
                const SizedBox(width: 3.0),
              ],
              Text(c,
                  style: _t(10.5,
                      color: on.contains(c) ? it.tone : _ink3,
                      weight: FontWeight.w600)),
            ]),
          ),
        ),
      GestureDetector(
        onTap: () => setState(() => _soCatEdit = null),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text('เสร็จ',
              style: _t(11.0, color: _blue, weight: FontWeight.w600)),
        ),
      ),
    ]);
  }

  /// การ์ดหน้าสำรับแบบ task detail: หัวแฟ้ม = breadcrumb · แผ่นขาว = ชื่อ + คำอธิบาย
  /// + property (หมวด สถานะ) + แท็บ (รายการย่อย วัดซ้ำ หมายเหตุ) + ปุ่มยืนยันท้ายการ์ด
  Widget _soDeckCard(_SoDeckItem it,
      {int pos = 0,
      int count = 1,
      List<Color> tones = const [],
      void Function(int)? go}) {
    final pn = it.section == 'Progress Note';
    final done = _soDone.contains(it.id);
    final tab = _soTab[it.id] ?? 0;
    final hasNote = (_soNote[it.id] ?? '').trim().isNotEmpty;
    final crumb =
        '${_setName(_template)}  /  ${pn ? 'Progress Note' : 'Order for ${it.section}'}';
    // การ์ดขาวเรียบ (ไม่มีหัวแฟ้ม) breadcrumb เป็นบรรทัดเล็กเหนือชื่อ
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crumb,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(11.0,
                                color: _ink3, weight: FontWeight.w500)),
                        const SizedBox(height: 4.0),
                        // ชื่อ + สถานะในบรรทัดเดียว
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(it.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(17.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8.0),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: done
                                    ? _soPill('ยืนยันแล้ว', _green,
                                        icon: Icons.circle)
                                    : _soPill('รอยืนยัน', _blue,
                                        icon: Icons.circle),
                              ),
                            ]),
                        if (it.detail.isNotEmpty) ...[
                          const SizedBox(height: 2.0),
                          Text(it.detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.5,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                        const SizedBox(height: 8.0),
                        // หมวด: แสดงเฉพาะที่เลือก แตะเพื่อแก้ (เปิดตัวเลือกครบ 5 หมวด)
                        // หัวข้อ Progress Note เป็นการประเมิน ไม่มีหมวดคำสั่ง
                        if (!pn)
                          _soCatEdit == it.id
                              ? _soCatPicker(it)
                              : GestureDetector(
                                  onTap: () =>
                                      setState(() => _soCatEdit = it.id),
                                  child: Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        for (final c in _soCatsOf(it))
                                          _soPill(c, it.tone),
                                        if (_soRepeat.contains(it.id))
                                          _soPill(
                                              'วัดซ้ำ ${_soRepeatLabel(it.id)}',
                                              _ink2,
                                              icon: Icons.circle),
                                        const Icon(Icons.edit_outlined,
                                            size: 13.0, color: _ink3),
                                      ]),
                                ),
                      ],
                    ),
                  ),
                  // แท็บแบบเส้นใต้
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 4.0, 18.0, 0.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: _line))),
                      child: Row(children: [
                        for (final (i, t) in [
                          (0, pn ? 'ตัวเลือก' : 'รายการย่อย'),
                          if (!pn) (1, 'วัดซ้ำ'),
                          (2, hasNote ? 'หมายเหตุ (1)' : 'หมายเหตุ'),
                        ])
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _soTab[it.id] = i);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 22.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 9.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: tab == i
                                          ? _inkTitle
                                          : Colors.transparent,
                                      width: 2.0),
                                ),
                              ),
                              child: Text(t,
                                  style: _t(12.5,
                                      color: tab == i ? _inkTitle : _ink3,
                                      weight: tab == i
                                          ? FontWeight.w600
                                          : FontWeight.w500)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 0.0),
                      child: switch (tab) {
                        1 when !pn =>
                          SingleChildScrollView(child: _soRepeatTab(it)),
                        2 => _soNotesTab(it),
                        _ => SingleChildScrollView(
                            child: pn ? _soPnTask(it) : _soSubTasks(it)),
                      },
                    ),
                  ),
                  // ท้ายการ์ด: action หลักเดียว = ยืนยันคำสั่งนี้ แล้วไปใบถัดไป
                  Container(
                    padding: const EdgeInsets.fromLTRB(18.0, 10.0, 14.0, 12.0),
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: _line))),
                    child: Row(children: [
                      // ตัวเลื่อนกระชับ ซ้ายล่าง (thumb zone): ขึ้น ลง + ลำดับ
                      // ตัวบอกลำดับในสำรับ (แทนขอบการ์ดที่ซ้อน)
                      _soNav(Icons.keyboard_arrow_up_rounded,
                          go != null && pos > 0 ? () => go(-1) : null),
                      const SizedBox(width: 6.0),
                      _soNav(Icons.keyboard_arrow_down_rounded,
                          go != null && pos < count - 1 ? () => go(1) : null),
                      const SizedBox(width: 12.0),
                      _soDots(pos, count),
                      const Spacer(),
                      if (_soAi.contains(it.id) && !done) ...[
                        // Dr.Note กรอกให้: แก้ (ไปแท็บรายละเอียด) หรือยอมรับแล้วไปใบถัดไป
                        _soBtn('แก้ไข', Icons.edit_rounded, false, () {
                          setState(() {
                            _soAi.remove(it.id);
                            _soTab[it.id] = 0;
                          });
                        }),
                        const SizedBox(width: 8.0),
                        _soBtn('ยอมรับ', Icons.check_rounded, true,
                            () => _soConfirm(it)),
                      ] else
                        _soBtn(
                            done ? 'แก้ไข' : 'ยืนยันคำสั่งนี้',
                            done ? Icons.edit_rounded : Icons.check_rounded,
                            !done,
                            () => _soConfirm(it)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// การ์ดสรุป (ใบสุดท้าย): ทุกคำสั่งแยกตามแฟ้ม หมวด วัดซ้ำ หมายเหตุ สถานะ
  /// แตะรายการ = กลับไปแก้ใบนั้น · action หลักเดียว = ยืนยันที่เหลือ / บันทึกคำสั่ง
  Widget _soSummaryCard(List<_SoDeckItem> items,
      {int pos = 0, int count = 1, void Function(int)? go}) {
    final done = items.where((x) => _soDone.contains(x.id)).length;
    final all = done == items.length;
    final secs = [for (final x in items) x.section].toSet().toList();
    Widget row(_SoDeckItem it) {
      final ok = _soDone.contains(it.id);
      final note = (_soNote[it.id] ?? '').trim();
      final line = _soDetailLine(it);
      final editing = _soEdit == it.id;
      return _Press(
        scale: 0.99,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _soEditOpen(it.id),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44.0),
            padding: const EdgeInsets.symmetric(vertical: 9.0),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _line))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Icon(
                    ok
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18.0,
                    color: ok ? _green : _g5),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.name,
                        style: _t(13.0,
                            color: editing ? _blue : _inkTitle,
                            weight: FontWeight.w600)),
                    if (line.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(line,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(11.5, color: _ink2, weight: FontWeight.w500)),
                    ],
                    if (it.section != 'Progress Note' ||
                        _soRepeat.contains(it.id)) ...[
                      const SizedBox(height: 4.0),
                      Wrap(spacing: 6.0, runSpacing: 4.0, children: [
                        if (it.section != 'Progress Note')
                          for (final c in _soCatsOf(it)) _soPill(c, it.tone),
                        if (_soRepeat.contains(it.id))
                          _soPill('วัดซ้ำ ${_soRepeatLabel(it.id)}', _ink2,
                              icon: Icons.circle),
                      ]),
                    ],
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(11.5, color: _ink2, weight: FontWeight.w500)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20.0, color: _g5),
            ]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_setName(_template),
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                const SizedBox(height: 4.0),
                Row(children: [
                  Expanded(
                    child: Text('สรุปคำสั่ง',
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  all
                      ? _soPill('ยืนยันครบ', _green, icon: Icons.circle)
                      : _soPill('ยืนยันแล้ว $done/${items.length}', _blue,
                          icon: Icons.circle),
                ]),
              ],
            ),
          ),
          // 3 คอลัมน์ตามแฟ้ม (เหมือนใบ standing order จริง) เลื่อนแยกกันในแต่ละคอลัมน์
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 4.0, 18.0, 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var k = 0; k < secs.length; k++) ...[
                    if (k > 0)
                      Container(
                        width: 1.0,
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        color: _line,
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                    color: items
                                        .firstWhere((x) => x.section == secs[k])
                                        .tone,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 7.0),
                              Expanded(
                                child: Text(
                                    secs[k] == 'Progress Note'
                                        ? 'Progress Note'
                                        : 'Order for ${secs[k]}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(12.0,
                                        color: _ink2, weight: FontWeight.w700)),
                              ),
                              Text(
                                  '${items.where((x) => x.section == secs[k] && _soDone.contains(x.id)).length}/${items.where((x) => x.section == secs[k]).length}',
                                  style: _num(11.0,
                                      color: _ink3, weight: FontWeight.w600)),
                            ]),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final it in items
                                      .where((x) => x.section == secs[k]))
                                    row(it),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18.0, 10.0, 14.0, 12.0),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _line))),
            child: Row(children: [
              const Spacer(),
              all
                  ? _soBtn('บันทึกคำสั่ง', Icons.save_rounded, true, () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                              'บันทึกคำสั่ง ${items.length} รายการแล้ว',
                              style: _t(12.0, color: Colors.white))));
                    })
                  : _soBtn('ยืนยันที่เหลือ ${items.length - done} รายการ',
                      Icons.done_all_rounded, true, () {
                      setState(() {
                        for (final x in items) {
                          _soAi.remove(x.id);
                          _soDone.add(x.id);
                        }
                      });
                    }),
            ]),
          ),
        ],
      ),
    );
  }

  /// หัวกลุ่มรายการย่อย: ชื่อ + นับ "x จาก y"
  Widget _soTaskHead(String title, int got, int all) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text('$got จาก $all',
              style: _num(13.0, color: _ink2, weight: FontWeight.w700)),
        ]),
      );

  /// แถวรายการย่อยแบบกล่อง: ช่องติ๊ก + ข้อความ (+ บรรทัดใต้ เช่น ข้อเสนอจากข้อมูลเคส)
  Widget _soTaskRow(String text, bool on, VoidCallback? onTap,
          {Widget? below,
          Widget? trailing,
          bool radio = false,
          bool check = true,
          int? no}) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 15.0),
          decoration: BoxDecoration(
            color: on ? _green.withValues(alpha: 0.05) : _panel,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
                color: on ? _green.withValues(alpha: 0.45) : _line,
                width: on ? 1.5 : 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // เลขข้อ (อ้างอิงตอนสื่อสาร เช่น "SIRS ข้อ 2")
                if (no != null)
                  SizedBox(
                    width: 22.0,
                    child: Text('$no',
                        style: _num(14.0,
                            color: on ? _green : _ink3,
                            weight: FontWeight.w700)),
                  ),
                // แถวช่องกรอก (เวลา/ค่า) ไม่มีช่องติ๊ก: กรอกแล้วกรอบเขียวบอกเอง
                if (check) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: on ? _green : Colors.transparent,
                      shape: radio ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: radio ? null : BorderRadius.circular(7.0),
                      border: Border.all(color: on ? _green : _g5, width: 2.0),
                    ),
                    child: on
                        ? const Icon(Icons.check_rounded,
                            size: 19.0, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14.0),
                ],
                Expanded(
                  // ยาวเกินช่อง: เลื่อนให้อ่านจนจบเอง แล้วกลับต้น
                  child: _Marquee(text,
                      style: _t(15.0,
                          color: _inkTitle,
                          weight: on ? FontWeight.w700 : FontWeight.w600)),
                ),
                if (trailing != null) trailing,
              ]),
              if (below != null)
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, top: 6.0),
                  child: below,
                ),
            ],
          ),
        ),
      );

  /// กล่องกรอกค่าเดี่ยว (ใช้ท้ายแถวรายการย่อย)
  Widget _soBox(String id, String label, String unit) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: unit == 'น.' ? 64.0 : 110.0,
          height: 28.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: _line, width: 0.5),
          ),
          child: TextFormField(
            key: ValueKey('$id|$label|$_soNoteRev'),
            initialValue: _soVal['$id|$label'],
            // ติ๊กของแถวขึ้นเองเมื่อกรอก
            onChanged: (v) {
              final was = (_soVal['$id|$label'] ?? '').isNotEmpty;
              _soVal['$id|$label'] = v;
              if (was != v.isNotEmpty) setState(() {});
            },
            style: _num(12.0, color: _inkTitle, weight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: unit == 'น.' ? '--:--' : '……',
              hintStyle: _t(11.0, color: _ink3),
            ),
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 5.0),
          Text(unit, style: _t(10.5, color: _ink3)),
        ],
        // ช่องเวลา: แตะ "ตอนนี้" ใส่เวลาปัจจุบัน
        if (unit == 'น.') ...[
          const SizedBox(width: 8.0),
          GestureDetector(
            onTap: () {
              final n = DateTime.now();
              HapticFeedback.selectionClick();
              setState(() {
                _soVal['$id|$label'] =
                    '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
                _soNoteRev++;
              });
            },
            child: Text('ตอนนี้',
                style: _t(10.5, color: _blue, weight: FontWeight.w600)),
          ),
        ],
      ]);

  /// Progress Note: ตัวเลือกเป็นรายการย่อย ข้อเสนอจากข้อมูลเคสเป็นบรรทัดสีน้ำเงินใต้ข้อ
  Widget _soPnTask(_SoDeckItem it) {
    final spec = _soPnSpec[it.name];
    if (spec == null) return const SizedBox.shrink();
    final (kind, opts, fields) = spec;
    final on = _soOpt[it.id] ?? const <String>{};
    final hint = _soHint(it.name);
    void tap(String o) {
      HapticFeedback.selectionClick();
      setState(() {
        final next = {...on};
        if (kind == 'single') {
          next
            ..clear()
            ..addAll(on.contains(o) ? const <String>{} : {o});
        } else {
          next.contains(o) ? next.remove(o) : next.add(o);
        }
        _soOpt[it.id] = next;
      });
    }

    final sirs = it.name.startsWith('SIRS');
    final showFields = fields.isNotEmpty &&
        (kind == 'time' ||
            on.contains('มี') ||
            on.contains('ใช้') ||
            on.contains('Other'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (opts.isNotEmpty) ...[
          _soTaskHead(
              sirs
                  ? (on.length >= 2 ? 'เข้าเกณฑ์ SIRS' : 'ยังไม่เข้าเกณฑ์ SIRS')
                  : (kind == 'single' ? 'เลือก 1 ข้อ' : 'ติ๊กข้อที่พบ'),
              on.length,
              kind == 'single' ? 1 : opts.length),
          // ตัวเลือกเป็น grid 2 คอลัมน์ (ข้อเสนอจากข้อมูลเคสเป็นบรรทัดใต้ชื่อ)
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 10.0) / 2;
            return Wrap(spacing: 10.0, children: [
              for (final (n, o) in opts.indexed)
                SizedBox(
                  width: w,
                  child: _soTaskRow(o, on.contains(o), () => tap(o),
                      no: n + 1,
                      radio: kind == 'single',
                      below: hint.contains(o) && !on.contains(o)
                          ? Row(children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 12.0, color: _blue),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(_soOptWhy(o) ?? 'แนะนำจากข้อมูลเคส',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(11.5,
                                        color: _blue, weight: FontWeight.w600)),
                              ),
                            ])
                          : null),
                ),
            ]);
          }),
        ],
        if (showFields) ...[
          const SizedBox(height: 4.0),
          _soTaskHead(
              kind == 'time' ? 'เวลา' : 'ระบุเพิ่ม',
              fields
                  .where((f) => (_soVal['${it.id}|${f.$1}'] ?? '').isNotEmpty)
                  .length,
              fields.length),
          for (final (label, unit) in fields)
            _soTaskRow(
                label, (_soVal['${it.id}|$label'] ?? '').isNotEmpty, null,
                trailing: _soBox(it.id, label, unit), check: false),
        ],
      ],
    );
  }

  /// คำสั่ง: รายการย่อย = ช่องเว้นว่างตามใบ (ติ๊กเองเมื่อกรอกครบ)
  Widget _soSubTasks(_SoDeckItem it) {
    final f = _soBlanks[it.id] ?? const <(String, String)>[];
    if (f.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text('บรรทัดนี้ไม่มีช่องต้องกรอก ตรวจแล้วกดยืนยันได้เลย',
            style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
      );
    }
    final got =
        f.where((x) => (_soVal['${it.id}|${x.$1}'] ?? '').isNotEmpty).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _soTaskHead('ค่าในใบ', got, f.length),
        for (final (label, unit) in f)
          _soTaskRow(label, (_soVal['${it.id}|$label'] ?? '').isNotEmpty, null,
              trailing: _soBox(it.id, label, unit), check: false),
      ],
    );
  }

  Widget _soRepeatTab(_SoDeckItem it) {
    final rep = _soRepeat.contains(it.id);
    final parts = rep ? _soRepeatParts(it.id) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(
                  () => rep ? _soRepeat.remove(it.id) : _soRepeat.add(it.id));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.0,
              height: 24.0,
              padding: const EdgeInsets.all(2.0),
              alignment: rep ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: rep ? _blue : const Color(0xFFD9DCE1),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Container(
                width: 20.0,
                height: 20.0,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Text(rep ? 'วัดซ้ำ ${_soRepeatLabel(it.id)}' : 'ไม่ต้องวัดซ้ำ',
              style: _t(12.0,
                  color: rep ? _blue : _ink2, weight: FontWeight.w600)),
        ]),
        if (parts != null) ...[
          const SizedBox(height: 12.0),
          parts.$1,
          const SizedBox(height: 12.0),
          parts.$2,
        ],
      ],
    );
  }

  Widget _soNotesTab(_SoDeckItem it) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final q in const [
              'STAT',
              'แจ้งผลแพทย์ทันที',
              'ก่อนให้ยาปฏิชีวนะ',
              'ติดตามผลซ้ำใน 6 ชม.',
            ])
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final cur = (_soNote[it.id] ?? '').trim();
                  if (cur.contains(q)) return;
                  setState(() {
                    _soNote[it.id] = cur.isEmpty ? q : '$cur $q';
                    _soNoteRev++;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: _line, width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_rounded, size: 12.0, color: _blue),
                    const SizedBox(width: 3.0),
                    Text(q,
                        style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 10.0),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextFormField(
                key: ValueKey('${it.id}|$_soNoteRev'),
                initialValue: _soNote[it.id],
                onChanged: (v) => _soNote[it.id] = v,
                maxLines: null,
                expands: true,
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'พิมพ์หมายเหตุถึงพยาบาล',
                  hintStyle: _t(11.5, color: _ink3),
                ),
              ),
            ),
          ),
        ],
      );
}

extension _SoRepeatPart on _ErFlowHomeWidgetState {
  static const List<int> _every = [15, 30, 60, 120, 240];

  String _soEvery(int m) => m < 60 ? '$m นาที' : '${m ~/ 60} ชม.';

  /// สรุปบนปุ่มวัดซ้ำ แบบที่เขียนในใบ เช่น "15 นาที × 4"
  String _soRepeatLabel(String id) {
    final (e, r) = _soRepeatCfg[id] ?? (15, 4);
    return r == 0 ? 'ทุก ${_soEvery(e)} ต่อเนื่อง' : '${_soEvery(e)} × $r';
  }

  /// ตั้งวัดซ้ำ: แถบช่วงเวลา (ไฮไลต์เลื่อนตาม) + ปุ่ม − รอบ + (เกิน 8 = ต่อเนื่อง)
  /// ใต้เป็นไทม์ไลน์เวลาวัดจริงทุกรอบ เริ่มจากเวลาถัดไปที่ลงตัว 5 นาที
  (Widget, Widget) _soRepeatParts(String id) {
    final (every, rounds) = _soRepeatCfg[id] ?? (15, 4);
    void set(int e, int r) {
      HapticFeedback.selectionClick();
      setState(() => _soRepeatCfg[id] = (e, r));
    }

    final idx = _every.indexOf(every).clamp(0, _every.length - 1);
    final seg = Container(
      height: 30.0,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / _every.length;
        return Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            left: w * idx,
            width: w,
            top: 0.0,
            bottom: 0.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          ),
          Row(children: [
            for (final e in _every)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => set(e, rounds),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: _t(10.5,
                          color: e == every ? Colors.white : _ink2,
                          weight: FontWeight.w600),
                      child: Text(_soEvery(e)),
                    ),
                  ),
                ),
              ),
          ]),
        ]);
      }),
    );

    Widget step(IconData icon, VoidCallback? onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: 26.0,
            height: 26.0,
            decoration: BoxDecoration(
              color: onTap == null ? const Color(0xFFF0F1F3) : _panel,
              shape: BoxShape.circle,
              border: Border.all(color: _line, width: 0.5),
            ),
            child:
                Icon(icon, size: 15.0, color: onTap == null ? _g5 : _inkTitle),
          ),
        );
    final stepper = Row(mainAxisSize: MainAxisSize.min, children: [
      step(
          Icons.remove_rounded,
          rounds == 0
              ? () => set(every, 8)
              : (rounds > 1 ? () => set(every, rounds - 1) : null)),
      SizedBox(
        width: 46.0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Column(
            key: ValueKey(rounds),
            mainAxisSize: MainAxisSize.min,
            children: [
              rounds == 0
                  ? const Icon(Icons.all_inclusive_rounded,
                      size: 18.0, color: _blue)
                  : Text('$rounds',
                      style: _num(15.0,
                          color: _inkTitle, weight: FontWeight.w700)),
              Text(rounds == 0 ? 'ต่อเนื่อง' : 'รอบ',
                  style: _t(8.5, color: _ink3, weight: FontWeight.w500)),
            ],
          ),
        ),
      ),
      step(Icons.add_rounded,
          rounds == 0 ? null : () => set(every, rounds >= 8 ? 0 : rounds + 1)),
    ]);

    // เวลาวัดแต่ละรอบ (แสดงไม่เกิน 6 จุด เกินนั้น/ต่อเนื่อง = จุดจางท้ายเส้น)
    final now = DateTime.now();
    final start = now.add(Duration(minutes: 5 - now.minute % 5));
    final shown = rounds == 0 ? 5 : rounds.clamp(1, 6);
    final more = rounds == 0 || rounds > 6;
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final timeline = SizedBox(
      height: 40.0,
      child: Stack(children: [
        // เส้นเวลา
        Positioned(
          left: 6.0,
          right: more ? 0.0 : 6.0,
          top: 6.0,
          height: 2.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _blue.withValues(alpha: 0.5),
                _blue.withValues(alpha: more ? 0.0 : 0.5),
              ]),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < shown; i++)
              Expanded(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('$id|$every|$rounds|$i'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 260 + 70 * i),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) => Opacity(
                    opacity: v.clamp(0.0, 1.0),
                    child: Transform.scale(
                        scale: v, alignment: Alignment.topLeft, child: child),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 14.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: i == 0 ? _blue : _panel,
                          shape: BoxShape.circle,
                          border: Border.all(color: _blue, width: 2.0),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(_clock(hm(start.add(Duration(minutes: every * i)))),
                          style: _num(9.5,
                              color: i == 0 ? _blue : _ink2,
                              weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            if (more)
              SizedBox(
                width: 22.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text('…',
                      style: _t(12.0, color: _ink3, weight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ]),
    );

    return (
      Row(children: [
        Expanded(child: seg),
        const SizedBox(width: 10.0),
        stepper,
      ]),
      timeline,
    );
  }
}

extension _SoFillPart on _ErFlowHomeWidgetState {
  /// ข้อที่ระบบเสนอจากข้อมูลจริงของเคส (V/S ล่าสุด, Lab, ประวัติแพ้ยา) ให้แพทย์ยืนยันเอง
  Set<String> _soHint(String title) {
    final c = _case;
    switch (title) {
      case 'SIRS criteria (2 ใน 4 ข้อ)':
        final wbc = c.labs.where((l) => l.name == 'WBC').firstOrNull?.value;
        return {
          if (c.bt.isNotEmpty && (c.bt.last > 38.0 || c.bt.last < 36.0))
            'T > 38 °C หรือ < 36 °C',
          if (c.hr.isNotEmpty && c.hr.last > 90.0) 'HR > 90/min',
          if (c.rr.isNotEmpty && c.rr.last > 20.0)
            'RR > 20/min หรือ PaCO₂ < 32',
          if (wbc != null && (wbc > 12.0 || wbc < 4.0))
            'WBC > 12,000 หรือ < 4,000',
        };
      case 'ประวัติแพ้ยา แพ้อาหาร':
        return {c.allergies.isEmpty ? 'ไม่มี' : 'มี'};
      case 'วินิจฉัยเป็น (Dx)':
        Set<String> got(String t) =>
            _soOpt['$_template|$t'] ?? const <String>{};
        final sirs = got('SIRS criteria (2 ใน 4 ข้อ)').length;
        final organ = got('Organ dysfunction (PE)');
        if (organ.contains('Septic shock')) return {'Septic shock'};
        if (organ.isNotEmpty) return {'Severe sepsis'};
        if (sirs >= 2 && got('ตำแหน่งติดเชื้อที่พบ').isNotEmpty) {
          return {'Sepsis'};
        }
        if (sirs >= 2) return {'SIRS'};
        return const {};
    }
    return const {};
  }

  /// ค่าที่ทำให้ข้อ SIRS นั้นเข้าเกณฑ์ (แสดงใต้ข้อนั้นข้อเดียว)
  String? _soOptWhy(String opt) {
    final c = _case;
    final wbc = c.labs.where((l) => l.name == 'WBC').firstOrNull?.value;
    return switch (opt) {
      'T > 38 °C หรือ < 36 °C' when c.bt.isNotEmpty => 'T ${c.bt.last} °C',
      'HR > 90/min' when c.hr.isNotEmpty => 'HR ${c.hr.last.round()}/min',
      'RR > 20/min หรือ PaCO₂ < 32' when c.rr.isNotEmpty =>
        'RR ${c.rr.last.round()}/min',
      'WBC > 12,000 หรือ < 4,000' when wbc != null =>
        'WBC ${(wbc * 1000).round()}/mm³',
      _ => null,
    };
  }
}

extension _SoAiPart on _ErFlowHomeWidgetState {
  Widget _soAiTag() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF9333EA)]),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 9.0, color: Colors.white),
          const SizedBox(width: 3.0),
          Text('AI',
              style: _t(9.0, color: Colors.white, weight: FontWeight.w700)),
        ]),
      );

  /// hero แผงขวา (stacked card): Dr.Note 3D + คำอธิบาย + ปุ่มเดียว "AI กรอกให้"
  /// กรอกแล้วแสดงจำนวนที่รอแพทย์ยอมรับ (ยอมรับ/แก้ทีละรายการที่การ์ดซ้าย)
  Widget _soHero() {
    final pending = _soAi.length;
    final title = _soAiBusy
        ? 'AI กำลังอ่านข้อมูลเคส'
        : pending > 0
            ? 'กรอกให้แล้ว รอตรวจ $pending รายการ'
            : 'ให้ AI ช่วยกรอกใบนี้';
    final sub = _soAiBusy
        ? 'ดู V/S Lab ประวัติแพ้ยา แล้วเลือกคำสั่งตามใบ'
        : pending > 0
            ? 'ยอมรับหรือแก้ไขทีละรายการที่การ์ดด้านล่าง'
            : 'เลือกคำสั่งและกรอกค่าจากข้อมูลจริงของเคส แพทย์ตรวจก่อนบันทึก';
    // ภาษาเดียวกับการ์ดขอ AI (2026-10-22): พื้นไล่ฟ้าม่วงอ่อน ไม่มีขอบ · ✦ ไล่สี AI · ปุ่มรองขาวขอบเทา
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF3FE), Color(0xFFF7F4FD)],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
          ).createShader(r),
          child: const Icon(Icons.auto_awesome_rounded, size: 26.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(title,
                    key: ValueKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
              const SizedBox(height: 2.0),
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(width: 10.0),
        if (pending == 0 && !_soAiBusy)
          _Press(
            child: GestureDetector(
              onTap: _soAutoFill,
              child: Container(
                height: 40.0,
                padding: const EdgeInsets.fromLTRB(14.0, 0.0, 18.0, 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 16.0, color: _blue),
                  const SizedBox(width: 6.0),
                  Text('AI กรอกให้',
                      style: _t(13.5, color: _blue, weight: FontWeight.w600)),
                ]),
              ),
            ),
          )
        else if (_soAiBusy)
          const SizedBox(
            width: 22.0,
            height: 22.0,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: _blue),
          ),
      ]),
    );
  }

  /// ค่าที่เลือก/กรอกจากข้อมูลจริงของเคสเท่านั้น (ไม่แต่งค่า) แล้วใส่ทีละรายการ
  Future<void> _soAutoFill() async {
    HapticFeedback.mediumImpact();
    setState(() => _soAiBusy = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final c = _case;
    final cc = '${c.cc} ${c.hpi}'.toLowerCase();
    final doc = _soDocs[_template] ?? const [];
    final adds = <void Function()>[];
    void pick(String id, Set<String> into) => adds.add(() {
          into.add(id);
          _soAi.add(id);
        });
    // Progress Note: ข้อที่เข้าเกณฑ์จากข้อมูลเคส
    for (final t in _soProgress[_template] ?? const <String>[]) {
      if (_soPnLinked.containsKey(t)) continue;
      final key = '$_template|$t';
      var opts = _soHint(t);
      if (t == 'ตำแหน่งติดเชื้อที่พบ') {
        opts = {
          if (cc.contains('ไอ') || cc.contains('เสมหะ') || cc.contains('หอบ'))
            'Pulmonary',
          if (cc.contains('ปัสสาวะ')) 'Urinary tract',
          if (cc.contains('ปวดท้อง')) 'Abdominal',
          if (cc.contains('แผล')) 'Skin/soft tissue',
        };
      }
      if (t == 'เวลาสำคัญ') {
        adds.add(() {
          _soVal['$key|มาถึง ER'] = c.times.isNotEmpty ? c.times.first : '';
          _soPnPick.add(key);
          _soAi.add(key);
        });
        continue;
      }
      if (opts.isEmpty) continue;
      adds.add(() {
        _soOpt[key] = {...opts};
        _soPnPick.add(key);
        _soAi.add(key);
      });
    }
    // คำสั่ง: ชุดตามใบ ยกเว้นที่ต้องดูอาการก่อน และยาที่แพ้
    final sbp = c.sbp.isNotEmpty ? c.sbp.last : 120.0;
    final spo2 = c.spo2.isNotEmpty ? c.spo2.last : 98.0;
    final allergy = c.allergies.join(' ').toLowerCase();
    bool want(String n) {
      final l = n.toLowerCase();
      if (l.contains('ett') ||
          l.contains('levophed') ||
          l.contains('ng tube')) {
        return false;
      }
      if (l.contains('30 ml/kg')) return sbp < 90.0;
      if (l.contains('oxygen')) return spo2 < 94.0;
      if (l.contains('pus') || l.contains('dressing'))
        return cc.contains('แผล');
      if (l.contains('bd (') || l.contains('npo') || l.contains('diet')) {
        return false;
      }
      if (allergy.contains('penicillin') && l.contains('piperacillin')) {
        return false;
      }
      return true;
    }

    for (final o in doc) {
      if (want(o.$1)) pick(o.$1, _orderPicked);
    }
    // ค่าในใบจากข้อมูลจริง
    final glu = c.labs
        .where((l) => l.name == 'Glucose' || l.name == 'DTX')
        .firstOrNull
        ?.value;
    adds.add(() {
      if (glu != null) _soVal['DTX|ผล'] = '${glu.round()}';
      if (spo2 < 94.0) _soVal['On oxygen|อัตรา'] = '3';
      _soRepeat.add('Record V/S, I/O');
      _soNoteRev++;
    });
    // ใส่ทีละรายการ (เห็นการไหลเข้า) แล้วเปิดใบแรกที่รอตรวจ
    for (final f in adds) {
      if (!mounted) return;
      setState(f);
      await Future.delayed(const Duration(milliseconds: 70));
    }
    if (!mounted) return;
    setState(() {
      _soAiBusy = false;
      // AI กรอกเสร็จ: เปิดใบสรุปให้เห็นทุกรายการก่อน
      if (_soDeckItems().any((x) => _soAi.contains(x.id))) {
        _soFocus = _soSummaryId;
      }
    });
  }
}

extension _SoPaperPart on _ErFlowHomeWidgetState {
  /// ใบ standing order สัดส่วน A4 (1:1.414): หัวใบ + 3 คอลัมน์
  Widget _soPaper() => Container(
        width: 70.0,
        height: 99.0,
        padding: const EdgeInsets.fromLTRB(6.0, 7.0, 6.0, 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000F4D),
                blurRadius: 8.0,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(children: [
          // หัวใบ
          Container(
            width: 34.0,
            height: 3.5,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 4.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC9D0DC), width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < 3; c++)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(2.5, 0.0, 2.5, 0.0),
                        decoration: BoxDecoration(
                          border: c == 0
                              ? null
                              : const Border(
                                  left: BorderSide(
                                      color: Color(0xFFC9D0DC), width: 0.8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // หัวคอลัมน์
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 3.0),
                              height: 2.5,
                              color: const Color(0xFF8C9AB3),
                            ),
                            for (final k in const [
                              [0.9, 0.6, 0.8, 0.5, 0.7, 0.6],
                              [0.8, 0.9, 0.6, 0.85, 0.5, 0.7],
                              [0.7, 0.85, 0.6, 0.5],
                            ][c])
                              FractionallySizedBox(
                                widthFactor: k,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 3.0),
                                  height: 2.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD5DBE7),
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
      );
}

/// ใบ standing order ถูกหยิบออกจากแฟ้ม: แฟ้มโผล่ขึ้น → กระดาษถูกดึงขึ้นพ้นกระเป๋า
/// เอียงนิด ๆ → แฟ้มเลื่อนลงหายไป เหลือกระดาษล้นขอบล่างการ์ด
class _SoPaperPull extends StatefulWidget {
  const _SoPaperPull({super.key, required this.paper});

  final Widget paper;

  @override
  State<_SoPaperPull> createState() => _SoPaperPullState();
}

class _SoPaperPullState extends State<_SoPaperPull>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _iv(double a, double b, Curve c) =>
      c.transform(Interval(a, b).transform(_c.value));

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final folderIn = _iv(0.0, 0.28, Curves.easeOutCubic);
            final pull = _iv(0.22, 0.72, Curves.easeOutBack);
            final folderOut = _iv(0.68, 1.0, Curves.easeInCubic);
            // แฟ้ม: ขึ้นจากล่าง แล้วลงหายไป
            final fy = 70.0 * (1.0 - folderIn) + 90.0 * folderOut;
            // กระดาษ: จากในแฟ้ม (ต่ำ) ขึ้นไปตำแหน่งจริง top 16
            final py = 16.0 + 54.0 * (1.0 - pull) + 70.0 * (1.0 - folderIn);
            return Stack(clipBehavior: Clip.none, children: [
              // แผ่นหลังแฟ้ม (แบบเดียวกับแฟ้มในหน้าเลือก Order Set)
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 30.0 + fy,
                height: 84.0,
                child: Opacity(
                  opacity: (1.0 - folderOut).clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1E3A8A), Color(0xFF0B1F66)],
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14.0,
                top: py,
                child:
                    Transform.rotate(angle: 0.06 * pull, child: widget.paper),
              ),
              // กระเป๋าหน้าแฟ้มโปร่ง (ทับกระดาษ) ตัวเดียวกับหน้าเลือก Order Set
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 60.0 + fy,
                height: 54.0,
                child: Opacity(
                  opacity: (1.0 - folderOut).clamp(0.0, 1.0),
                  child: const CustomPaint(painter: _FolderFrontPainter()),
                ),
              ),
            ]);
          },
        ),
      );
}

/// หมวดคำสั่งในใบ standing order (รหัสที่ทีมเขียนหน้าบรรทัด L X M ห oth)
const List<(String, String, IconData)> _soCatDefs = [
  ('Lab', 'L', Icons.science_outlined),
  ('X-ray', 'X', Icons.monitor_heart_outlined),
  ('Medication', 'M', Icons.medication_outlined),
  ('Procedure', 'ห', Icons.healing_outlined),
  ('Other', 'oth', Icons.more_horiz_rounded),
];

/// คำบ่งชี้หมวดจากข้อความบรรทัด (จำแนกอัตโนมัติ ให้คนตรวจซ้ำ)
const Map<String, List<String>> _soCatWords = {
  'Lab': [
    'cbc',
    'bun',
    'cr,',
    'cr ',
    'electrolyte',
    "e'lyte",
    'lft',
    'pt,',
    'ptt',
    'inr',
    'culture',
    'h/c',
    'hemoculture',
    'u/c',
    'ua',
    'upt',
    'dtx',
    'hba1c',
    'lipid',
    'fbs',
    'glucose',
    'anti-hiv',
    'antihiv',
    'troponin',
    'lactate',
    'gram',
    'c/s',
    'ana',
    'protein c',
    'vdrl',
  ],
  'X-ray': [
    'cxr',
    'x-ray',
    'x ray',
    'ct ',
    'ct brain',
    'mri',
    'film',
    'ultrasound',
    'echo'
  ],
  'Medication': [
    'iv drip',
    'iv load',
    'nss',
    'acetar',
    'levophed',
    'antibiotic',
    'cef',
    'metronidazole',
    'tramol',
    'plasil',
    'asa',
    'paracetamol',
    'omeprazole',
    'atorvastatin',
    'clopidogrel',
    'mannitol',
    'glycerol',
    'labetalol',
    'alteplase',
    'rt-pa',
    'rtpa',
    'insulin',
    ' ri ',
  ],
  'Procedure': [
    'ett',
    'oxygen',
    'ng tube',
    'foley',
    'dressing',
    'ekg',
    'set or',
    'catheter',
    'retain',
    'appendectomy',
    'suction',
    'splint',
  ],
  'Other': [
    'admit',
    'record',
    'diet',
    'npo',
    'bd (',
    'bed rest',
    'bedrest',
    'consult',
    'notify',
    'แจ้งแพทย์',
    'precaution',
    'urine output',
    'sos score',
  ],
};

Set<String> _soGuessCats(String text) {
  final t = ' ${text.toLowerCase()} ';
  final got = {
    for (final e in _soCatWords.entries)
      if (e.value.any(t.contains)) e.key,
    // ขนาดยา เช่น 500 mg, 4.5 g, 30 ml/kg (ไม่นับหน่วยผล เช่น DTX mg/dl)
    if (RegExp(r'\d\s?(mg|g|ml/kg|mcg)\b(?!/dl)').hasMatch(t)) 'Medication',
  };
  return got.isEmpty ? {'Other'} : got;
}

extension _SoStructPart on _ErFlowHomeWidgetState {
  /// หมวดปัจจุบันของบรรทัด: ที่แก้เอง > ที่ทีมกำกับหลายหมวด > รหัสในใบ
  Set<String> _soCatsFor(String name, String code) =>
      _soCats[name] ??
      _soCatMulti[name] ??
      {
        for (final d in _soCatDefs)
          if (d.$2 == code) d.$1
      };

  /// ตัวจัดโครงสร้างใบ standing order: ทุกบรรทัดของใบ แยกตาม One Day / Continuation
  /// แต่ละบรรทัดเลือกหมวดได้หลายหมวด · ปุ่มจำแนกอัตโนมัติจากคำในบรรทัด (ให้คนตรวจ)
  /// หมวดที่จัดไว้ใช้ต่อทั้งการ์ดซ้ายและหน้าย่อย ยา / Lab / X-ray / หัตถการ
  /// ตัวจัดโครงสร้าง Standing order (หน้าตั้งค่า): เลือกใบ · จำแนกหมวดทุกบรรทัด
  /// cur = ใบที่เลือก · changed = บรรทัดที่จำแนกอัตโนมัติใหม่ (รอคนตรวจ)
  Widget _soStructView(String cur, ValueChanged<String> onPick,
      Set<String> changed, StateSetter setSheet) {
    void upd(VoidCallback f) {
      setState(f);
      setSheet(() {});
    }

    final doc = _soDocs[cur]!;

    final counts = {
      for (final d in _soCatDefs)
        d.$1: doc.where((o) => _soCatsFor(o.$1, o.$3).contains(d.$1)).length
    };
    final multi = doc.where((o) => _soCatsFor(o.$1, o.$3).length > 1).length;
    Widget row((String, String, String, bool) o) {
      final on = _soCatsFor(o.$1, o.$3);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _line))),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(o.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(13.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  if (changed.contains(o.$1)) ...[
                    const SizedBox(width: 6.0),
                    _soAiTag(),
                  ],
                ]),
                if (o.$2.isNotEmpty)
                  Text(o.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          // หมวด: แตะสลับ เลือกได้หลายหมวด ต้องเหลืออย่างน้อย 1
          for (final d in _soCatDefs)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: GestureDetector(
                onTap: () {
                  final next = {...on};
                  if (next.contains(d.$1)) {
                    if (next.length == 1) return;
                    next.remove(d.$1);
                  } else {
                    next.add(d.$1);
                  }
                  HapticFeedback.selectionClick();
                  upd(() {
                    _soCats[o.$1] = next;
                    changed.remove(o.$1);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40.0,
                  height: 30.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on.contains(d.$1) ? _blue : _panel,
                    borderRadius: BorderRadius.circular(8.0),
                    border:
                        Border.all(color: on.contains(d.$1) ? _blue : _line),
                  ),
                  child: Text(d.$2,
                      style: _t(11.5,
                          color: on.contains(d.$1) ? Colors.white : _ink3,
                          weight: FontWeight.w700)),
                ),
              ),
            ),
        ]),
      );
    }

    Widget section(String title, bool one) {
      final lines = [
        for (final o in doc)
          if (o.$4 == one) o
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 2.0),
            child: Row(children: [
              Text(title,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 8.0),
              Text('${lines.length} บรรทัด', style: _t(11.5, color: _ink3)),
            ]),
          ),
          for (final o in lines) row(o),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
      color: _panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('จัดโครงสร้าง Standing order',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 2.0),
                  Text('จำแนกหมวดของแต่ละบรรทัดในใบ ใช้กับทุกเคสที่สั่งชุดนี้',
                      style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                ],
              ),
            ),
            // action เดียวของแผง: จำแนกอัตโนมัติ (คนตรวจทีละบรรทัดต่อ)
            _Press(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  upd(() {
                    changed.clear();
                    for (final o in doc) {
                      final g = _soGuessCats('${o.$1} ${o.$2}');
                      if (!_setEq(g, _soCatsFor(o.$1, o.$3))) {
                        changed.add(o.$1);
                      }
                      _soCats[o.$1] = g;
                    }
                  });
                },
                child: _AiPill(
                    label: 'จำแนกอัตโนมัติ',
                    style:
                        _t(12.0, color: Colors.white, weight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 12.0),
          // เลือกใบ standing order
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final k in _soDocs.keys)
              GestureDetector(
                onTap: () => setSheet(() {
                  onPick(k);
                  changed.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 7.0),
                  decoration: BoxDecoration(
                    color: k == cur ? _blue : _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: k == cur ? _blue : _line),
                  ),
                  child: Text(_soFullName[k] ?? k,
                      style: _t(12.0,
                          color: k == cur ? Colors.white : _ink2,
                          weight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: 12.0),
          // สรุปจำนวนบรรทัดต่อหมวด (หนึ่งบรรทัดนับได้หลายหมวด)
          Wrap(spacing: 8.0, runSpacing: 8.0, children: [
            for (final d in _soCatDefs)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(d.$3, size: 14.0, color: _ink2),
                  const SizedBox(width: 5.0),
                  Text('${d.$1} (${d.$2})',
                      style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
                  const SizedBox(width: 6.0),
                  Text('${counts[d.$1]}',
                      style: _num(12.5,
                          color: _inkTitle, weight: FontWeight.w700)),
                ]),
              ),
            if (multi > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text('หลายหมวด $multi บรรทัด',
                    style: _t(11.5, color: _blue, weight: FontWeight.w600)),
              ),
          ]),
          if (changed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                  'จำแนกใหม่ ${changed.length} บรรทัด ตรวจบรรทัดที่มีป้าย AI',
                  style: _t(11.5, color: _blue, weight: FontWeight.w600)),
            ),
          const SizedBox(height: 4.0),
          Expanded(
            child: ListView(children: [
              section('Order for One Day', true),
              section('Order for Continuation', false),
            ]),
          ),
        ],
      ),
    );
  }
}

bool _setEq(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

extension _SoLinkPart on _ErFlowHomeWidgetState {
  /// ค่าที่ดึงจากส่วนอื่นของเวชระเบียน (ไม่มีค่า = ยังไม่ลง)
  String? _soLinkedValue(String title) {
    final c = _case;
    return switch (title) {
      'เวลาสำคัญ' =>
        c.times.isEmpty ? null : 'มาถึง ER ${_clock(c.times.first)}',
      'วินิจฉัยเป็น (Dx)' => c.dx.isEmpty
          ? null
          : '${c.dx.first.text}${c.dx.first.icd10 == null ? '' : ' (${c.dx.first.icd10})'}',
      'ประวัติแพ้ยา แพ้อาหาร' =>
        c.allergies.isEmpty ? 'ไม่มีประวัติแพ้' : c.allergies.join(', '),
      _ => null,
    };
  }

  /// แถวหัวข้อที่ซ้ำกับส่วนอื่น: แสดงค่าที่ดึงมา + ที่มา ไม่มีช่องติ๊ก (ไม่กรอกซ้ำ)
  Widget _soLinkedRow(String title, (String, IconData) link) {
    final v = _soLinkedValue(title);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w500)),
              const SizedBox(height: 2.0),
              Text(v ?? 'ยังไม่ได้ลง',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0,
                      color: v == null ? _ink3 : _blue,
                      weight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.link_rounded, size: 12.0, color: _ink3),
            const SizedBox(width: 4.0),
            Text(link.$1,
                style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

/// สำรับการ์ดที่ขยับต่อเนื่อง: ตำแหน่งสำรับ t เป็นค่าทศนิยม (ใบ i อยู่ช่อง s = i - t)
/// s = 0 ใบหน้า · s > 0 ซ้อนด้านหลังทางขวา (เล็กลง จางลง) · s < 0 ปลิวออกซ้าย
/// ลากนิ้ว = เลื่อน t ตรง ๆ ปล่อยแล้ว spring ไปใบที่ใกล้ (ส่งความเร็วนิ้วต่อ)
/// ทุกใบเป็นการ์ดจริงตลอดทาง ไม่มีการสลับ widget กลาง animation
class _SoDeckView extends StatefulWidget {
  const _SoDeckView({
    required this.count,
    required this.index,
    required this.keyOf,
    required this.card,
    required this.onIndex,
  });

  final int count;
  final int index;
  final String Function(int) keyOf;
  final Widget Function(int) card;
  final ValueChanged<int> onIndex;

  @override
  State<_SoDeckView> createState() => _SoDeckViewState();
}

class _SoDeckViewState extends State<_SoDeckView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t =
      AnimationController.unbounded(vsync: this, value: widget.index.toDouble())
        ..addListener(() => setState(() {}));
  double _dragFrom = 0.0;

  @override
  void didUpdateWidget(_SoDeckView old) {
    super.didUpdateWidget(old);
    // เปลี่ยนใบจากปุ่มหรือการติ๊กในแผงขวา: เลื่อนสำรับไปเอง
    if (widget.index.toDouble() != _target) _settle(widget.index, 0.0);
  }

  late double _target = widget.index.toDouble();

  void _settle(int to, double velocity) {
    _target = to.toDouble();
    // ปัดเร็ว = ใช้เวลาน้อยลง (ต่อความเร็วนิ้ว) · โค้งจบนุ่มแบบสปริงเล็กน้อย
    final dist = (_target - _t.value).abs();
    final ms = (420.0 * dist.clamp(0.35, 1.0) / (1.0 + velocity.abs() * 0.25))
        .clamp(200.0, 460.0);
    _t.animateTo(_target,
        duration: Duration(milliseconds: ms.round()),
        curve: const Cubic(0.22, 1.0, 0.36, 1.0));
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      // ใบหลังโผล่ใต้ใบหน้า 2 ชั้น ชั้นละ 16
      // ไม่โชว์ขอบใบหลัง (ลำดับไปบอกที่ footer ของการ์ดแทน)
      const peek = 0.0;
      final cardH = c.maxHeight - peek * 2;
      final t = _t.value;
      final lo = (t.floor() - 1).clamp(0, widget.count - 1);
      final hi = (t.floor() + 3).clamp(0, widget.count - 1);
      // วาดจากใบหลังสุดก่อน ใบที่ปลิวออก (s < 0) วาดทีหลังสุด
      final order = [for (var i = hi; i >= lo; i--) i]..sort((a, b) {
          double z(int i) => (i - t) < 0 ? 10.0 - (i - t) : -(i - t);
          return z(a).compareTo(z(b));
        });
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: (_) {
          _t.stop();
          _dragFrom = _t.value;
        },
        onVerticalDragUpdate: (d) {
          final max = (widget.count - 1).toDouble();
          var v = _t.value - d.delta.dy / cardH;
          // เกินใบแรก/ใบสุดท้าย: มีแรงต้าน
          if (v < 0 || v > max) v = _t.value - d.delta.dy / (cardH * 4.0);
          _t.value = v.clamp(-0.25, max + 0.25);
        },
        onVerticalDragEnd: (d) {
          final vel = -(d.primaryVelocity ?? 0.0) / cardH;
          final moved = _t.value - _dragFrom;
          var to = _dragFrom.round();
          if (moved > 0.15 || vel > 0.8) to += 1;
          if (moved < -0.15 || vel < -0.8) to -= 1;
          to = to.clamp(0, widget.count - 1);
          _settle(to, vel);
          if (to != widget.index) widget.onIndex(to);
        },
        // ตัดขอบบนของสำรับ: ใบที่เลื่อนขึ้นหายไปในกรอบ ไม่ทับแถบแท็บ
        child: ClipRect(
          clipper: const _DeckClip(),
          child: Stack(clipBehavior: Clip.none, children: [
            for (final i in order) _slot(i, i - t, cardH, peek),
          ]),
        ),
      );
    });
  }

  Widget _slot(int i, double s, double cardH, double peek) {
    final back = s.clamp(0.0, 2.6);
    final out = s < 0 ? s.clamp(-1.3, 0.0) : 0.0;
    // หลัง: เลื่อนลง + ย่อ (โผล่ขอบล่าง) · ออก: เลื่อนขึ้นพ้นจอแบบ reels ย่อนิดหน่อย
    final dy = peek * back + out * cardH * 1.08;
    final scale = (1.0 - 0.04 * back.clamp(0.0, 1.0)) * (1.0 + out * 0.06);
    final fade = back > 2.0
        ? (2.6 - back) / 0.6
        : s < 0
            ? ((1.0 + s) / 0.3).clamp(0.0, 1.0)
            : 1.0;
    // ใบที่ซ้อนอยู่หลังกลายเป็นเทา (ทึบขึ้นตามความลึก) ใบหน้าเด่นชัด
    final veil = (back * 1.2).clamp(0.0, 1.0);
    return Positioned(
      key: ValueKey(widget.keyOf(i)),
      left: 0.0,
      right: 0.0,
      top: 0.0,
      height: cardH,
      child: IgnorePointer(
        ignoring: s.abs() > 0.02,
        child: Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translateByDouble(0.0, dy, 0.0, 1.0)
              ..scaleByDouble(scale, scale, 1.0, 1.0),
            // ไม่มีเงา: การ์ดเป็นรูปแฟ้ม (มีแท็บ) เงากล่องสี่เหลี่ยมจะโผล่ข้างแท็บ
            child: SizedBox.expand(
              child: Stack(children: [
                Positioned.fill(child: RepaintBoundary(child: widget.card(i))),
                if (veil > 0.0)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // ชั้นที่ 1 เทาอ่อน ชั้นที่ 2 เทาเข้มขึ้น (เห็นลำดับ)
                        color: Color.lerp(
                                const Color(0xFFE4E7EB),
                                const Color(0xFFC3C8D0),
                                (back - 1.0).clamp(0.0, 1.0))!
                            .withValues(alpha: veil),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ตัดเฉพาะด้านบน (ข้างและล่างเผื่อให้เงาการ์ดไม่โดนตัด)
class _DeckClip extends CustomClipper<Rect> {
  const _DeckClip();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-24.0, 0.0, size.width + 24.0, size.height + 24.0);

  @override
  bool shouldReclip(_DeckClip old) => false;
}

/// ข้อความบรรทัดเดียว: พอดีช่อง = แสดงปกติ · ยาวเกิน = เลื่อนไปท้ายช้า ๆ พัก แล้วเลื่อนกลับ
/// ขอบที่ข้อความถูกตัดจางลง (บอกว่ายังมีต่อ)
class _Marquee extends StatefulWidget {
  const _Marquee(this.text, {required this.style, this.once = false});

  final String text;
  final TextStyle style;

  /// true = เลื่อนไปกลับรอบเดียวตอนแสดงครั้งแรก แล้วหยุดที่ต้นข้อความ
  final bool once;

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee>
    with SingleTickerProviderStateMixin {
  // สร้างใน initState (ถ้า lazy จะถูกสร้างครั้งแรกตอน dispose แล้ว error)
  late final AnimationController _c;
  double _over = 0.0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
  }

  // โหมด once: ข้อความนี้เลื่อนไปแล้ว ไม่เลื่อนซ้ำแม้ความกว้างช่องขยับ
  String? _ranFor;

  void _run(double over) {
    if (widget.once) {
      _over = over;
      if (over <= 0.0 || _ranFor == widget.text) return;
      _ranFor = widget.text;
    }
    if (!widget.once && over == _over) return;
    _over = over;
    _c.stop();
    if (over <= 0.0) return;
    // 40 px/วินาที + พักหัวท้าย
    final move = (over / 40.0 * 1000).round();
    _c.duration = Duration(milliseconds: 2 * move + 2400);
    widget.once ? _c.forward(from: 0.0) : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final tp = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr)
        ..layout();
      final over = tp.width - box.maxWidth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _run(over > 0.5 ? over : 0.0);
      });
      final text =
          Text(widget.text, maxLines: 1, softWrap: false, style: widget.style);
      if (over <= 0.5) return text;
      // สูงเท่าบรรทัดข้อความ (OverflowBox ขยายเต็ม constraint ถ้าไม่กำหนด)
      return SizedBox(
          width: box.maxWidth,
          height: tp.height,
          child: ClipRect(
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
                Color(0x00FFFFFF),
              ], stops: [
                0.0,
                0.88,
                1.0
              ]).createShader(r),
              blendMode: BlendMode.dstIn,
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, child) {
                  // พัก 1.2 วิ · เลื่อนไปท้าย · พัก · เลื่อนกลับ
                  final total = _c.duration?.inMilliseconds ?? 1;
                  final ms = _c.value * total;
                  final move = (total - 2400) / 2;
                  double x;
                  if (ms < 1200) {
                    x = 0.0;
                  } else if (ms < 1200 + move) {
                    x = Curves.easeInOut.transform((ms - 1200) / move);
                  } else if (ms < 2400 + move) {
                    x = 1.0;
                  } else {
                    x = 1.0 -
                        Curves.easeInOut.transform(
                            ((ms - 2400 - move) / move).clamp(0.0, 1.0));
                  }
                  return Transform.translate(
                      offset: Offset(-over * x, 0.0), child: child);
                },
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: text,
                ),
              ),
            ),
          ));
    });
  }
}

/// ภาพ empty state คำสั่งแพทย์ (Figma 605:116) แยกชั้น เข้าทีละชิ้น (เล่นครั้งเดียว):
/// ก้อนฟ้า ขยาย → เส้นพื้น ลากออก → คลิปบอร์ด หล่นลงเอียงแล้วตั้ง → ที่หนีบ หนีบลง
/// → แถว skeleton เข้าทีละแถว (ซ้าย→ขวา) → ใบไม้ งอกจากโคน → เส้นประกาย เด้ง
class _EmptyOrdersArt extends StatefulWidget {
  const _EmptyOrdersArt();
  @override
  State<_EmptyOrdersArt> createState() => _EmptyOrdersArtState();
}

class _EmptyOrdersArtState extends State<_EmptyOrdersArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // ขนาดภาพต้นฉบับ (px) ใช้คำนวณจุดหมุนของแต่ละชั้น
  static const _w = 734.0, _h = 554.0;
  static Alignment _at(double x, double y) =>
      Alignment(x / _w * 2 - 1, y / _h * 2 - 1);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: _w / _h,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final v = _c.value;
              double seg(double a, double b, [Curve c = Curves.easeOutCubic]) =>
                  c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));
              Widget img(String k) =>
                  Image.asset('assets/images/er_empty_orders_$k.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      gaplessPlayback: true);
              Widget layer(String k,
                  {double op = 1.0,
                  double sc = 1.0,
                  double sx = 1.0,
                  double dx = 0.0,
                  double dy = 0.0,
                  double rot = 0.0,
                  Alignment at = Alignment.center}) {
                if (op <= 0.0) return const SizedBox.shrink();
                return Positioned.fill(
                  child: Opacity(
                    opacity: op.clamp(0.0, 1.0),
                    child: FractionalTranslation(
                      translation: Offset(dx, dy),
                      child: Transform(
                        alignment: at,
                        transform: Matrix4.identity()
                          ..rotateZ(rot)
                          ..scaleByDouble(sc * sx, sc, 1.0, 1.0),
                        child: img(k),
                      ),
                    ),
                  ),
                );
              }

              final blob = seg(0.0, 0.25, Curves.easeOutBack);
              final ground = seg(0.08, 0.3);
              final drop = seg(0.12, 0.42, Curves.easeOutBack);
              final dropOp = seg(0.12, 0.2);
              final clip = seg(0.36, 0.52, Curves.easeOutBack);
              double row(int i) => seg(0.48 + i * 0.08, 0.64 + i * 0.08);
              final leaf = seg(0.6, 0.85, Curves.easeOutBack);
              final spark = seg(0.78, 0.95, Curves.easeOutBack);
              return Stack(children: [
                layer('blob', op: seg(0.0, 0.12), sc: blob, at: _at(400, 340)),
                layer('ground', op: ground, sx: ground, at: _at(370, 540)),
                // คลิปบอร์ดหล่นลง (เอียงมากกว่าแล้วตั้งเข้าที่) หมุนรอบมุมล่าง
                layer('body',
                    op: dropOp,
                    dy: -0.12 * (1 - drop),
                    rot: -0.12 * (1 - drop),
                    at: _at(380, 530)),
                layer('clip',
                    op: seg(0.36, 0.42),
                    dy: -0.06 * (1 - clip),
                    sc: 0.85 + 0.15 * clip,
                    at: _at(404, 80)),
                for (var i = 0; i < 3; i++)
                  layer('row${i + 1}',
                      op: row(i),
                      sx: row(i),
                      at: _at(const [289.0, 282.0, 276.0][i], 240.0 + i * 72)),
                layer('leaf', op: seg(0.6, 0.68), sc: leaf, at: _at(150, 536)),
                layer('spark',
                    op: seg(0.78, 0.84), sc: spark, at: _at(590, 95)),
              ]);
            },
          ),
        ),
      );
}

/// จุดบนสุดของหน้าย่อยเลือกชุด (เลื่อนกลับบนสุดหลังเลือก)
final GlobalKey _soPickTopKey = GlobalKey();

/// ไอคอนหมวดคำสั่ง 3D โคจรรอบดาว AI (วงรีเอียง มีหน้า/หลัง ขนาดตามความลึก)
/// เริ่มเป็นดาว AI โคจร → morph เป็นไอคอนหมวดทีละชิ้น → วงหดรวมเข้ากลาง ดาวเปล่งแสง · 2.6 วิ
class _SoOrbit extends StatefulWidget {
  const _SoOrbit();
  @override
  State<_SoOrbit> createState() => _SoOrbitState();
}

class _SoOrbitState extends State<_SoOrbit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
    ..forward();

  static const _icons = [
    'assets/images/er_os_med.png',
    'assets/images/er_os_lab.png',
    'assets/images/er_os_xray.png',
    'assets/images/er_os_proc.png',
    'assets/images/er_os_other.png',
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            double seg(double a, double b, [Curve c = Curves.easeInOutCubic]) =>
                c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
            // story (ทุกชิ้นเป็นดาวรูปทรงเดียวกัน = ต่อเนื่อง):
            // 0–0.12 ดาวกลางโผล่ + ชาร์จ · 0.10–0.40 ดาวลูกไหลออกจากดาวกลางทีละดวงเป็นวงโคจร
            // 0.36–0.78 เส้นขอบดาวลูก morph เป็นไอคอนหมวดทีละชิ้น · 0.74–0.95 หมุนวนเข้ารวมดาวกลาง · แสงบาน
            final born = seg(0.0, 0.12, Curves.easeOutBack);
            final merge = seg(0.74, 0.95, Curves.easeInOutCubic);
            final bloom = seg(0.88, 1.0, Curves.easeOutCubic);
            // หมุนสม่ำเสมอ (ไม่เร่งกระชาก) + วนเพิ่มครึ่งรอบตอนรวม = เกลียว
            final spin = 2 * math.pi * 0.9 * Curves.easeInOutSine.transform(t) +
                math.pi * merge;
            return LayoutBuilder(builder: (context, box) {
              final c = Offset(box.maxWidth / 2, box.maxHeight / 2);
              const rx = 112.0, ry = 48.0;
              final items = <(double, Widget)>[];
              for (var i = 0; i < _icons.length; i++) {
                final out =
                    seg(0.10 + i * 0.05, 0.32 + i * 0.05, Curves.easeOutCubic);
                if (out <= 0.0) continue;
                final m = seg(0.36 + i * 0.07, 0.56 + i * 0.07);
                final a = spin + i * 2 * math.pi / _icons.length;
                final depth = math.sin(a);
                final reach = out * (1.0 - merge);
                final pos =
                    c + Offset(math.cos(a) * rx * reach, depth * ry * reach);
                final near = (depth + 1) / 2;
                // ความลึก: หน้าใหญ่ชัด หลังเล็กจาง (ระยะต่างชัด)
                final sz = (14.0 + 28.0 * out) *
                    (0.55 + 0.6 * near) *
                    (1.0 - 0.7 * merge);
                final op = (0.35 + 0.65 * near) *
                    (1.0 - seg(0.88, 0.96, Curves.easeIn));
                items.add((
                  depth,
                  Positioned(
                    left: pos.dx - sz / 2,
                    top: pos.dy - sz / 2,
                    width: sz,
                    height: sz,
                    child: Opacity(
                      opacity: op.clamp(0.0, 1.0),
                      // หมุนตัวเองแบบ 3D: พลิกแกนตั้ง (หันตามทางโคจร) + เอียงแกนนอน มีมุมมอง
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.006)
                          ..rotateY(math.cos(a) * 0.9 +
                              (1 - m) * (t * 2 * math.pi * 1.5 + i))
                          ..rotateX(0.35 * math.sin(a + i)),
                        child: CustomPaint(
                          foregroundPainter: m < 1.0
                              ? _SoMorphFill(_SoMorph.keys[i], m)
                              : null,
                          child: ClipPath(
                            clipper: m < 0.98
                                ? _SoMorphClip(_SoMorph.keys[i], m)
                                : null,
                            child: Opacity(
                              opacity: Curves.easeIn.transform(m),
                              child: Image.asset(_icons[i],
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ));
              }
              items.sort((a, b) => a.$1.compareTo(b.$1));
              // ดาวกลาง (ทรงเดียวกับดาวลูก): ชาร์จใหญ่ → ปล่อยดาวลูกแล้วหดเหลือแกน → ดูดรวมแล้วบาน
              final emitted = seg(0.10, 0.40);
              final breathe =
                  1.0 + 0.06 * math.sin(t * 2 * math.pi * 2.5) * (1 - merge);
              final coreSz =
                  (44.0 * born - 18.0 * emitted + 22.0 * merge + 12.0 * bloom) *
                      breathe;
              return Stack(clipBehavior: Clip.none, children: [
                for (final it in items.where((e) => e.$1 < 0)) it.$2,
                if (bloom > 0)
                  Positioned(
                    left: c.dx - 70.0 * bloom,
                    top: c.dy - 70.0 * bloom,
                    width: 140.0 * bloom,
                    height: 140.0 * bloom,
                    child: Opacity(
                      opacity: (1 - bloom).clamp(0.0, 1.0),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Color(0x669B72CB),
                            Color(0x334285F4),
                            Color(0x004285F4),
                          ]),
                        ),
                      ),
                    ),
                  ),
                if (coreSz > 0.5)
                  Positioned(
                    left: c.dx - coreSz / 2,
                    top: c.dy - coreSz / 2,
                    width: coreSz,
                    height: coreSz,
                    child: CustomPaint(painter: _SoMorphFill('med', 0.0)),
                  ),
                for (final it in items.where((e) => e.$1 >= 0)) it.$2,
              ]);
            });
          },
        ),
      );
}

/// รูปทรงสำหรับ morph ดาว AI → ไอคอนหมวด: รัศมีเชิงขั้ว 48 ทิศ (เริ่มทิศบน ตามเข็ม)
/// ไอคอน = ขอบเงาที่สุ่มจากภาพ er_os_*.png (เกลี่ยแล้ว) · ดาว = ดาว 4 แฉกขอบเว้า
class _SoMorph {
  static const keys = ['med', 'lab', 'xray', 'proc', 'other'];
  static const n = 48;
  static const _r = <String, List<double>>{
    'med': [
      1.062,
      1.035,
      1.003,
      0.903,
      0.712,
      0.531,
      0.436,
      0.386,
      0.349,
      0.327,
      0.313,
      0.304,
      0.299,
      0.304,
      0.313,
      0.463,
      0.776,
      0.971,
      1.030,
      1.085,
      1.103,
      1.103,
      1.103,
      1.075,
      1.007,
      0.944,
      0.939,
      0.962,
      0.980,
      0.994,
      0.976,
      0.912,
      0.839,
      0.785,
      0.749,
      0.731,
      0.726,
      0.731,
      0.749,
      0.785,
      0.867,
      1.003,
      1.125,
      1.180,
      1.175,
      1.148,
      1.125,
      1.098
    ],
    'lab': [
      1.070,
      1.090,
      1.090,
      1.094,
      1.109,
      1.114,
      1.003,
      0.786,
      0.646,
      0.608,
      0.598,
      0.598,
      0.608,
      0.641,
      0.689,
      0.747,
      0.844,
      0.998,
      1.157,
      1.229,
      1.210,
      1.157,
      1.109,
      1.075,
      1.046,
      1.027,
      1.027,
      1.037,
      1.046,
      1.056,
      1.061,
      1.027,
      0.897,
      0.718,
      0.593,
      0.516,
      0.458,
      0.410,
      0.371,
      0.352,
      0.347,
      0.347,
      0.347,
      0.352,
      0.366,
      0.410,
      0.603,
      0.906
    ],
    'xray': [
      0.928,
      0.909,
      0.909,
      0.923,
      0.951,
      0.997,
      1.029,
      1.002,
      0.932,
      0.872,
      0.835,
      0.812,
      0.803,
      0.812,
      0.835,
      0.872,
      0.932,
      1.025,
      1.145,
      1.232,
      1.205,
      1.094,
      0.992,
      0.918,
      0.868,
      0.845,
      0.845,
      0.849,
      0.858,
      0.891,
      0.942,
      0.969,
      0.942,
      0.891,
      0.854,
      0.831,
      0.822,
      0.831,
      0.854,
      0.891,
      0.951,
      1.043,
      1.163,
      1.251,
      1.232,
      1.135,
      1.038,
      0.969
    ],
    'proc': [
      0.417,
      0.534,
      0.718,
      0.927,
      1.160,
      1.289,
      1.307,
      1.197,
      0.963,
      0.822,
      0.675,
      0.442,
      0.307,
      0.276,
      0.264,
      0.252,
      0.245,
      0.239,
      0.227,
      0.221,
      0.227,
      0.245,
      0.270,
      0.295,
      0.331,
      0.399,
      0.485,
      0.552,
      0.608,
      0.865,
      1.129,
      0.945,
      0.663,
      0.583,
      0.540,
      0.485,
      0.423,
      0.368,
      0.325,
      0.301,
      0.295,
      0.295,
      0.288,
      0.282,
      0.295,
      0.313,
      0.331,
      0.368
    ],
    'other': [
      0.846,
      0.815,
      0.795,
      0.785,
      0.800,
      0.815,
      0.795,
      0.749,
      0.698,
      0.657,
      0.632,
      0.611,
      0.601,
      0.611,
      0.632,
      0.657,
      0.698,
      0.866,
      1.131,
      1.243,
      1.212,
      1.156,
      1.080,
      1.004,
      0.948,
      0.912,
      0.886,
      0.876,
      0.886,
      0.922,
      0.973,
      1.014,
      1.019,
      0.983,
      0.942,
      0.917,
      0.907,
      0.917,
      0.942,
      0.983,
      1.049,
      1.151,
      1.258,
      1.299,
      1.233,
      1.095,
      0.973,
      0.897
    ],
  };

  // ดาว 4 แฉกขอบเว้า (superellipse p < 1)
  static double _star(double t) {
    const p = 0.55;
    final c = math.pow(math.cos(t).abs(), p) + math.pow(math.sin(t).abs(), p);
    return 1.0 / math.pow(c, 1 / p);
  }

  static Path path(String k, double m, Size size) {
    final r = _r[k]!;
    final cx = size.width / 2, cy = size.height / 2;
    final R = math.min(size.width, size.height) / 2;
    // ดาวหมุนครึ่งรอบระหว่าง morph
    final rot = (1 - m) * math.pi / 2;
    final p = Path();
    const steps = 96;
    for (var i = 0; i <= steps; i++) {
      final f = i / steps * n;
      final a = f.floor() % n, b = (a + 1) % n, u = f - f.floor();
      final ri = r[a] * (1 - u) + r[b] * u;
      final t = 2 * math.pi * i / steps - math.pi / 2;
      final rs = _star(t + rot) * 1.05;
      final e = Curves.easeInOutCubic.transform(m);
      final rr = (rs * (1 - e) + ri * e) * R;
      final pt = Offset(cx + math.cos(t) * rr, cy + math.sin(t) * rr);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }
}

class _SoMorphClip extends CustomClipper<Path> {
  _SoMorphClip(this.k, this.m);
  final String k;
  final double m;
  @override
  Path getClip(Size size) => _SoMorph.path(k, m, size);
  @override
  bool shouldReclip(_SoMorphClip o) => o.m != m || o.k != k;
}

/// พื้นไล่สี AI ในรูปทรงที่กำลัง morph · จางลงเมื่อเป็นไอคอน
class _SoMorphFill extends CustomPainter {
  _SoMorphFill(this.k, this.m);
  final String k;
  final double m;
  @override
  void paint(Canvas canvas, Size size) {
    final op = (1.0 - Curves.easeIn.transform(m)).clamp(0.0, 1.0);
    if (op <= 0) return;
    final path = _SoMorph.path(k, m, size);
    final rect = Offset.zero & size;
    // หน้าดาว: ไล่สี AI
    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5B9BFF).withValues(alpha: op),
              const Color(0xFF9B72CB).withValues(alpha: op),
              const Color(0xFFE07088).withValues(alpha: op),
            ],
          ).createShader(rect));
    // แสงเงาบนหน้า: สว่างซ้ายบน มืดขวาล่าง (ทรงนูน)
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.45, -0.55),
            radius: 0.9,
            colors: [
              Colors.white.withValues(alpha: 0.55 * op),
              Colors.white.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.18 * op),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SoMorphFill o) => o.m != m || o.k != k;
}

/// หน้าย่อยแผงขวา: กรอกรายละเอียดคำสั่งทีละรายการ ช่องตามประเภท
/// (Lab / X-ray / Medication / Procedure / Other) · แผงซ้ายเป็นสรุป
extension _SoEditPart on _ErFlowHomeWidgetState {
  _SoDeckItem? get _soEditItem => _soEdit == null
      ? null
      : _soDeckItems().where((x) => x.id == _soEdit).firstOrNull;

  /// แฟ้มของรายการ: 0 Progress Note 1 One Day 2 Continuation
  int _soSecId(String section) => switch (section) {
        'Progress Note' => 0,
        'One Day' => 1,
        _ => 2,
      };

  /// เปิดหน้ากรอกของรายการ (จากแผงขวาหรือแตะในสรุปซ้าย): พาแผงขวาไปแฟ้มของรายการก่อน
  void _soEditOpen(String id) {
    final it = _soDeckItems().where((x) => x.id == id).firstOrNull;
    if (it == null) return;
    HapticFeedback.selectionClick();
    final seq = _uiSeq;
    final fid = _soSecId(it.section);
    final at = seq
        .indexWhere((b) => b.data['so_doc'] == true && b.data['folder'] == fid);
    setState(() {
      if (at >= 0) {
        _uiIdx = at;
        _formAt = 0;
      }
      _formFwd = true;
      _soPickOpen = false;
      _soEdit = id;
      _soFocus = id;
    });
  }

  /// ยืนยันรายการนี้แล้วกลับรายการของแฟ้ม
  void _soEditSave() {
    final id = _soEdit;
    if (id == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _soAi.remove(id);
      _soDone.add(id);
      _formFwd = false;
      _soEdit = null;
    });
  }

  /// ค่าเริ่มของช่องจากบรรทัดในใบ เช่น "Cef3 2 g iv OD" → ขนาด 2 g · IV · OD
  String? _soGuess(_SoDeckItem it, String field) {
    final s = '${it.name} ${it.detail}';
    switch (field) {
      case 'ขนาดยา':
        final m =
            RegExp(r'(\d[\d,.]*)\s*(mg|g|mcg|ml|mL|unit|U)\b').firstMatch(s);
        return m == null ? null : '${m.group(1)} ${m.group(2)}';
      case 'วิถีทาง':
        final m =
            RegExp(r'\b(iv|im|po|sc|sl)\b', caseSensitive: false).firstMatch(s);
        return m?.group(1)!.toUpperCase();
      case 'ความถี่':
        final q = RegExp(r'q\s*(\d+)\s*(hr|h|min)', caseSensitive: false)
            .firstMatch(s);
        if (q != null) {
          return 'q ${q.group(1)} ${q.group(2)!.startsWith('m') ? 'min' : 'hr'}';
        }
        final f = RegExp(r'\b(OD|BID|TID|QID|prn|stat)\b', caseSensitive: false)
            .firstMatch(s);
        if (f == null) return null;
        final v = f.group(1)!;
        return v.toLowerCase() == 'stat'
            ? 'ครั้งเดียว'
            : v.toLowerCase() == 'prn'
                ? 'prn'
                : v.toUpperCase();
      case 'อัตราหยด':
        final m = RegExp(r'(\d+)\s*ml/hr', caseSensitive: false).firstMatch(s);
        return m?.group(1);
    }
    return null;
  }

  /// ช่องของแต่ละประเภท: (ชื่อช่อง, ตัวเลือก (ว่าง = พิมพ์), หน่วย)
  List<(String, List<String>, String)> _soFieldsOf(_SoDeckItem it) {
    final cont = it.section == 'Continuation';
    const urgent = ('ความเร่งด่วน', ['STAT', 'ด่วน', 'ปกติ'], '');
    const side = ('ด้าน', ['ซ้าย', 'ขวา', 'ทั้งสองข้าง', 'ไม่ระบุ'], '');
    final cat = _soCatsOf(it).first;
    return switch (cat) {
      'Lab' => [
          urgent,
          ('สิ่งส่งตรวจ', ['เลือด', 'ปัสสาวะ', 'อุจจาระ', 'อื่น ๆ'], ''),
          ('เวลาเก็บ', ['ทันที', 'ก่อนให้ยา', 'ตามเวลานัด'], ''),
          if (cont) ('ตรวจซ้ำ', ['q 4 hr', 'q 6 hr', 'q 12 hr', 'ทุกวัน'], ''),
        ],
      'X-ray' => [
          urgent,
          ('ท่าถ่าย', ['PA', 'AP', 'Lateral', 'Oblique'], ''),
          side,
          (
            'การเคลื่อนย้าย',
            ['เดินได้', 'รถนั่ง', 'เปลนอน', 'ถ่ายข้างเตียง'],
            ''
          ),
          ('ข้อบ่งชี้', const [], ''),
        ],
      'Medication' => [
          ('ขนาดยา', const [], ''),
          ('วิถีทาง', ['IV', 'IM', 'PO', 'SC', 'SL', 'พ่นยา'], ''),
          (
            'ความถี่',
            cont
                ? ['q 4 hr', 'q 6 hr', 'q 8 hr', 'OD', 'BID', 'TID', 'prn']
                : ['ครั้งเดียว', 'prn'],
            ''
          ),
          if (_soVal['${it.id}|วิถีทาง'] == 'IV' ||
              (_soVal['${it.id}|วิถีทาง'] == null &&
                  _soGuess(it, 'วิถีทาง') == 'IV'))
            ('อัตราหยด', const [], 'ml/hr'),
        ],
      'Procedure' => [
          urgent,
          ('ตำแหน่ง', const [], ''),
          side,
          ('ผู้ทำ', ['แพทย์', 'พยาบาล'], ''),
          ('ความยินยอม', ['ได้รับแล้ว', 'ยังไม่ได้รับ', 'ไม่ต้องใช้'], ''),
        ],
      _ => [
          (
            'ความถี่',
            cont
                ? ['q 15 min', 'q 1 hr', 'q 2 hr', 'q 4 hr', 'ต่อเนื่อง']
                : ['ครั้งเดียว'],
            ''
          ),
          ('รายละเอียด', const [], ''),
        ],
    };
  }

  /// ค่าว่างที่บันทึกไว้ = ผู้ใช้ล้างเอง (ไม่เติมค่าจากใบกลับ)
  String? _soFieldVal(_SoDeckItem it, String f) {
    final v = _soVal['${it.id}|$f'];
    if (v != null) return v.isEmpty ? null : v;
    return _soGuess(it, f);
  }

  /// บรรทัดสรุปค่าที่กรอก (ใช้ในการ์ดสรุปฝั่งซ้าย)
  String _soDetailLine(_SoDeckItem it) {
    if (it.section == 'Progress Note') return '';
    return [
      for (final f in _soFieldsOf(it))
        if (_soFieldVal(it, f.$1) case final v?)
          f.$3.isEmpty ? v : '$v ${f.$3}',
    ].join('  ');
  }

  Widget _soFieldLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(t, style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
      );

  Widget _soChips(_SoDeckItem it, String f, List<String> opts) {
    final cur = _soFieldVal(it, f);
    return Wrap(spacing: 8.0, runSpacing: 8.0, children: [
      for (final o in opts)
        _Press(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _soVal['${it.id}|$f'] = cur == o ? '' : o);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: cur == o ? _blue.withValues(alpha: 0.08) : _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    color: cur == o ? _blue : const Color(0xFFDADCE0),
                    width: cur == o ? 1.0 : 0.5),
              ),
              child: Text(o,
                  style: _t(13.0,
                      color: cur == o ? _blue : _ink2,
                      weight: cur == o ? FontWeight.w600 : FontWeight.w500)),
            ),
          ),
        ),
    ]);
  }

  Widget _soInput(_SoDeckItem it, String f, String unit,
          {String hint = 'พิมพ์', int lines = 1, bool note = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('${it.id}|$f|$_soNoteRev'),
              initialValue: note ? _soNote[it.id] : _soFieldVal(it, f),
              minLines: lines,
              maxLines: lines == 1 ? 1 : 6,
              onChanged: (v) {
                if (note) {
                  _soNote[it.id] = v;
                } else {
                  _soVal['${it.id}|$f'] = v;
                }
              },
              onEditingComplete: () => setState(() {}),
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w500),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: _t(13.0, color: _ink3, weight: FontWeight.w500),
              ),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 8.0),
            Text(unit, style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ],
        ]),
      );

  /// การ์ดกรอกรายละเอียด (ภาษาเดียวกับ _dxCard): หัว = ชื่อ + บรรทัดในใบ + หมวด · ช่องตามหมวด
  Widget _soEditPage(_SoDeckItem it) {
    final pn = it.section == 'Progress Note';
    final cat = _soCatsOf(it).first;
    const cats = [
      ('Lab', 'Lab', 'assets/images/er_os_lab.png'),
      ('X-ray', 'X-ray', 'assets/images/er_os_xray.png'),
      ('Medication', 'การให้ยา', 'assets/images/er_os_med.png'),
      ('Procedure', 'หัตถการ', 'assets/images/er_os_proc.png'),
      ('Other', 'อื่น ๆ', 'assets/images/er_os_other.png'),
    ];
    final art = cats.firstWhere((c) => c.$1 == cat, orElse: () => cats.last);
    final blanks = _soBlanks[it.id] ?? const <(String, String)>[];
    Widget sec(String label, Widget child) => Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 18.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_soFieldLabel(label), child]),
        );
    return _dxCard(
      it.name,
      it.detail.isNotEmpty
          ? it.detail
          : pn
              ? 'Progress Note'
              : 'Order for ${it.section}',
      _dxArtFade(Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 12.0, 16.0, 0.0),
        child: Image.asset(art.$3, fit: BoxFit.contain),
      )),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pn)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 18.0),
              child: _soPnTask(it),
            )
          else ...[
            // ประเภทคำสั่ง: เปลี่ยนแล้วช่องด้านล่างเปลี่ยนตาม
            sec(
              'ประเภท',
              Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                for (final c in cats)
                  _Press(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _soCats[it.id] = {c.$1});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.fromLTRB(6.0, 5.0, 14.0, 5.0),
                        decoration: BoxDecoration(
                          color: cat == c.$1
                              ? _blue.withValues(alpha: 0.08)
                              : _panel,
                          borderRadius: BorderRadius.circular(100.0),
                          border: Border.all(
                              color:
                                  cat == c.$1 ? _blue : const Color(0xFFDADCE0),
                              width: cat == c.$1 ? 1.0 : 0.5),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(c.$3, width: 24.0, height: 24.0),
                          const SizedBox(width: 6.0),
                          Text(c.$2,
                              style: _t(13.0,
                                  color: cat == c.$1 ? _blue : _ink2,
                                  weight: cat == c.$1
                                      ? FontWeight.w600
                                      : FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
            for (final (f, opts, unit) in _soFieldsOf(it))
              sec(
                  f,
                  opts.isEmpty
                      ? _soInput(it, f, unit,
                          hint: switch (f) {
                            'ขนาดยา' => 'เช่น 1 g',
                            'อัตราหยด' => 'เช่น 80',
                            'ตำแหน่ง' => 'เช่น หลังมือซ้าย',
                            _ => 'พิมพ์',
                          })
                      : _soChips(it, f, opts)),
            // ช่องเว้นว่างในใบ standing order (เช่น เวลาเจาะ ผล DTX)
            if (blanks.isNotEmpty)
              sec(
                  'ค่าในใบ',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (label, unit) in blanks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(children: [
                            Expanded(
                              child: Text(label,
                                  style: _t(13.0,
                                      color: _ink2, weight: FontWeight.w500)),
                            ),
                            _soBox(it.id, label, unit),
                          ]),
                        ),
                    ],
                  )),
          ],
          sec(
              'หมายเหตุ',
              _soInput(it, 'note', '',
                  hint: 'ไม่บังคับ', lines: 2, note: true)),
        ],
      ),
    );
  }

  /// breadcrumb หน้ากรอกรายการ: แฟ้ม › ชื่อรายการ · แตะส่วนแรก = กลับ
  Widget _soEditCrumb(_SoDeckItem it) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: _soPickClose,
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  it.section == 'Progress Note'
                      ? 'Progress Note'
                      : 'Order for ${it.section}',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(it.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );
}
