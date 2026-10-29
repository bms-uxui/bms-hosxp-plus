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

  /// คำสั่งที่แพทย์เพิ่มเองนอกใบ ต่อชุด: (ชื่อ, รายละเอียด, รหัสหมวด M L X ห oth, One Day)
  final Map<String, List<(String, String, String, bool)>> _soExtra = {};
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
  /// selectedOnly: การ์ดชุดที่เลือกอยู่ใบเดียว (หน้า Standing Order หลัก) แบบการ์ดปกติ ไม่ใช่สี AI
  Widget _soPickPage({bool recOnly = false, bool selectedOnly = false}) {
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
          final x when x.startsWith('ยา') => 'การให้ยา',
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
          'การให้ยา' => Image.asset('assets/images/er_os_med.png',
              width: 21.0, height: 28.0, filterQuality: FilterQuality.medium),
          'X-ray' => Image.asset('assets/images/er_os_xray.png',
              width: 21.0, height: 28.0, filterQuality: FilterQuality.medium),
          'หัตถการ' => Image.asset('assets/images/er_os_proc_cap.png',
              width: 28.0, height: 28.0, filterQuality: FilterQuality.medium),
          'อื่น ๆ' => Image.asset('assets/images/er_os_other.png',
              width: 23.0, height: 28.0, filterQuality: FilterQuality.medium),
          _ => SizedBox(
              width: 28.0,
              height: 28.0,
              child: Icon(
                  switch (name) {
                    'การให้ยา' => Icons.medication_rounded,
                    'X-ray' => Icons.image_rounded,
                    'หัตถการ' => Icons.healing_rounded,
                    _ => Icons.more_horiz_rounded,
                  },
                  size: 26.0,
                  color: const Color(0xFF3D7BF2))),
        };

    // ชุดที่ใช้อยู่: เลือกในรอบนี้ · ยังไม่เลือก = ชุดของคำสั่งที่บันทึกล่าสุด (เคยสั่งแล้ว)
    final prevSet = _soPrev?.set.toLowerCase();
    final pickedNow = _soSetPicked.contains(_caseP().hn);
    Widget section(int idx, String cat) {
      final on = pickedNow
          ? cat == _template
          : prevSet != null &&
              (cat.toLowerCase() == prevSet ||
                  cat.toLowerCase().endsWith(' $prevSet'));
      final groups = [
        for (final (g, items) in _orderSetPages(cat))
          if (items.isNotEmpty) (short(g), items.length)
      ];
      final full = _soFullName[cat] ?? _setName(cat);
      // เลือกแล้วยังอยู่หน้าย่อยนี้ (เห็นว่าชุดไหน "ใช้อยู่") · กลับด้วยปุ่มย้อนกลับ/breadcrumb
      Future<void> pick() async {
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
        if (!await _soConfirmReplace(cat)) return;
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
      // หน้า Order Set หลักเก็บสถานะกาง/หุบแยกจากหน้าเลือกชุด
      // ชุดที่เลือก/สั่งไว้แล้ว = กางเป็นค่าเริ่มทั้งสองหน้า (กลับเข้ามาเห็นรายการทันที)
      final ek = recOnly || selectedOnly ? 'main|$cat' : cat;
      final open = _soPickExpand[ek] ?? on;
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
                              const _SolarIcon('ph-check',
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
                                  // ตัดขอบแทน scroll view (เดิม scroll view จำตำแหน่งจาก PageStorage/แผง
                                  // หุบแล้วเห็นหมวดท้ายแทนหมวดแรก) · ชิดบนเสมอ
                                  child: ClipRect(
                                    child: UnconstrainedBox(
                                      constrainedAxis: Axis.horizontal,
                                      alignment: Alignment.topCenter,
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 0.0, 16.0, 16.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              for (final (k, (g, items))
                                                  in _orderSetPages(cat)
                                                      .where((e) =>
                                                          e.$2.isNotEmpty)
                                                      .indexed)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                                              color: _inkTitle,
                                                                              weight: FontWeight.w700)),
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
                                                                      short(
                                                                          g))),
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
    if (selectedOnly) {
      return _soSetPicked.contains(_caseP().hn) && _template != _soCustom
          ? section(0, _template)
          : const SizedBox.shrink();
    }
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
  _SoRound? get _soPrev => _soRoundsOf(_caseP().hn).firstOrNull;

  /// ประวัติคำสั่งของเคส (ใหม่ → เก่า): ที่บันทึกในแอป + ชุดตัวอย่าง (เคสที่ยังไม่เคยสั่ง = ไม่มีตัวอย่าง)
  List<_SoRound> _soRoundsOf(String hn) => [
        ...?_soSaved[hn],
        if (!_soNoOrderYet.contains(hn)) ..._soHistory,
      ];

  /// บันทึกแบบร่างเป็นคำสั่งครั้งใหม่ (กดบันทึกขั้นสั่งการรักษา): ครั้งที่ต่อจากเดิม เวลาตอนนี้
  /// ผู้สั่ง = แพทย์ที่ล็อกอิน · รายการ = แบบร่าง (One Day / Continuation) สถานะเริ่ม "รอรับ"
  void _soCommit() {
    final hn = _caseP().hn;
    final items = [
      for (final x in _soDeckItems())
        if (x.section != 'Progress Note') x
    ];
    if (items.isEmpty) return;
    final now = DateTime.now();
    final round = _SoRound(
      _soRoundsOf(hn).length + 1,
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ErSession.instance.user?.name ?? 'แพทย์ผู้สั่ง',
      _template == _soCustom ? 'สั่งเอง' : _setName(_template),
      [
        for (final x in items)
          (x.name, _soDetailLine(x), 'รอรับ', x.section == 'One Day')
      ],
    );
    (_soSaved[hn] ??= []).insert(0, round);
    _soSel[hn] = 0;
  }

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
  /// วันที่ไทยแบบย่อ เช่น 29 ต.ค. 2569
  String _thDateShort(DateTime d) {
    const m = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year + 543}';
  }

  Widget _soPrevCard() {
    final prev = _soPrev!;
    bool done((String, String, String, bool) o) =>
        o.$3 == 'ทำแล้ว' || _taskDone.contains(o.$1);
    // สรุปต่อแฟ้ม (วงความคืบหน้าแบบแท็บแฟ้ม) · ภาษาเดียวกับการ์ด Standing Order
    Widget folder(String name, bool oneDay) {
      final xs = [
        for (final o in prev.items)
          if (o.$4 == oneDay) o
      ];
      final d = xs.where(done).length;
      final f = xs.isEmpty ? 0.0 : d / xs.length;
      return Expanded(
        child: Row(children: [
          SizedBox.square(
            dimension: 26.0,
            child: f >= 1.0 && xs.isNotEmpty
                ? Container(
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle),
                    child: const _SolarIcon('ph-check',
                        size: 15.0, color: Colors.white),
                  )
                : CustomPaint(painter: _MiniDonut(f, _blue)),
          ),
          const SizedBox(width: 10.0),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
            Text(xs.isEmpty ? 'ไม่มีรายการ' : 'ทำแล้ว $d/${xs.length}',
                style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
          ]),
        ]),
      );
    }

    return _dxCard(
      // หัว = ชื่อชุด standing order · รอง = แพทย์ผู้สั่ง + วันเวลา · ไม่มี hero
      _setName(prev.set),
      '${prev.by} ${_thDateShort(DateTime.now())} ${_clock(prev.time)}',
      const SizedBox.shrink(),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // การ์ดซ้อน: ความคืบหน้าแยกแฟ้ม
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 10.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              folder('One Day', true),
              folder('Continuation', false),
            ]),
          ]),
        ),
        // แผ่นปุ่มแถวเดียวแบบการ์ด Standing Order
        _dxTiles([
          (Icons.add_circle_outline_rounded, 'สั่งเพิ่ม', _soContinue),
          (Icons.edit_note_rounded, 'แก้ไขคำสั่ง', _soContinue),
          (Icons.post_add_rounded, 'เริ่มชุดใหม่', _soPickEnter),
        ]),
        // ล่างเท่าขอบข้าง (การ์ดซ้อนห่างขอบ 8)
        const SizedBox(height: 2.0),
      ]),
    );
  }

  /// Progress Note ที่ผูกกับคำสั่งเดิม: วันเวลา แพทย์ผู้บันทึก + SOAP
  /// S = อาการสำคัญ · O = สัญญาณชีพรอบที่ใกล้เวลาสั่งที่สุด · A = การวินิจฉัย · P = คำสั่งครั้งนี้
  Widget _soPrevNote() {
    final prev = _soPrev!;
    final c = erCaseOf(_caseP().hn);
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    // รอบ V/S ล่าสุดที่วัดก่อนหรือเท่ากับเวลาสั่ง (ไม่มี = รอบแรก)
    var vi = 0;
    for (var i = 0; i < c.times.length; i++) {
      if (c.times[i].compareTo(prev.time) <= 0) vi = i;
    }
    String at(List<double> v) =>
        v.isEmpty ? '-' : f(v[math.min(vi, v.length - 1)]);
    const mon = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    final d = DateTime.now();
    final date = '${d.day} ${mon[d.month - 1]} ${d.year + 543}';
    final soap = <(String, String, String)>[
      ('S', 'Subjective', c.cc),
      (
        'O',
        'Objective',
        'BP ${at(c.sbp)}/${at(c.dbp)} mmHg  HR ${at(c.hr)}/min  RR ${at(c.rr)}/min  SpO₂ ${at(c.spo2)}%  BT ${at(c.bt)} °C'
            '${c.painScore != null ? '  Pain ${c.painScore}/10' : ''}'
      ),
      (
        'A',
        'Assessment',
        c.dx.isEmpty
            ? '-'
            : [
                for (final x in c.dx)
                  x.icd10 != null ? '${x.text} (${x.icd10})' : x.text
              ].join(', ')
      ),
      (
        'P',
        'Plan',
        'Standing order ${_setName(prev.set)} ครั้งที่ ${prev.no}: ${[
          for (final it in prev.items) it.$1
        ].join(', ')}'
      ),
    ];
    // เนื้อหาแท็บ Progress Note: วันเวลา + แพทย์ แล้ว SOAP เต็ม (ตัวนำสีกรมท่า)
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('$date ${_clock(prev.time)}  ${prev.by}',
          style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
      for (final (k, en, v) in soap)
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 22.0,
              child: Text(k,
                  style: _t(14.0, color: _blue, weight: FontWeight.w700)),
            ),
            Expanded(
              child: Text(v,
                  style: _t(13.5, color: _inkTitle, weight: FontWeight.w500)),
            ),
          ]),
        ),
    ]);
  }

  /// folder แท็บแบบเส้นขอบ 0.5 ไม่มีพื้น: เส้นแท็บที่เลือกต่อกับเส้นตัว folder ด้วยมุมเว้า
  /// แท็บอื่น = ตัวหนังสือเทา · ตัวเลข = จำนวนรายการ
  /// แท็บ = (ชื่อ, จำนวน, ตัวสร้างเนื้อหา) · สร้างเฉพาะแท็บที่เปิด (สลับแท็บไม่ต้องคำนวณทุกแฟ้ม)
  /// prog: ความคืบหน้าต่อแท็บ (ชื่อแท็บ → 0..1) แทนการนับจากแบบร่าง (ใช้กับประวัติคำสั่ง)
  Widget _soDeckFolder(List<(String, int?, Widget Function())> tabs,
      {Map<String, double>? prog}) {
    if (tabs.isEmpty) return const SizedBox.shrink();
    // สลับแท็บวาดใหม่เฉพาะแฟ้ม (ทั้งหน้ามีฉาก 3D/WebView วาดใหม่แล้วเฟรมค้าง motion ไม่ทัน)
    return ValueListenableBuilder<int>(
        valueListenable: _soDeckTabTick,
        builder: (context, _, __) => _soDeckFolderBody(tabs, prog: prog));
  }

  Widget _soDeckFolderBody(List<(String, int?, Widget Function())> tabs,
      {Map<String, double>? prog}) {
    final cur = _soDeckTab.clamp(0, tabs.length - 1);
    const th = 40.0, f = 10.0, lc = Color(0xFFDADCE0);
    // ความกว้างแต่ละแท็บ (วัดจากข้อความ) → ตำแหน่งคงที่ · หัวแฟ้มเลื่อนจากแท็บเดิมไปแท็บใหม่
    final sc = MediaQuery.textScalerOf(context);
    double tw(String t, TextStyle st) => (TextPainter(
            text: TextSpan(text: t, style: st),
            textDirection: TextDirection.ltr,
            textScaler: sc)
          ..layout())
        .width;
    final ws = [
      for (final (label, n, _) in tabs)
        32.0 +
            tw(label, _t(14.0, weight: FontWeight.w700)) +
            (n == null
                ? 0.0
                : 6.0 +
                    tw('$n', _num(12.5, weight: FontWeight.w700)) +
                    (n > 0 ? 22.0 : 0.0)) +
            12.0
    ];
    final xs = <double>[];
    var acc = 0.0;
    for (final w in ws) {
      xs.add(acc);
      acc += w + 2 * f;
    }
    final labels = Positioned(
      left: 0.0,
      top: 0.0,
      right: 0.0,
      height: th + 1.0,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final (i, (label, n, _)) in tabs.indexed) ...[
          // ช่องฟิลเลตมีทุกแท็บ (ว่างเมื่อไม่เลือก) ตำแหน่งแท็บไม่กระโดดตอนสลับ
          if (i > 0) const SizedBox(width: f),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              if (i == _soDeckTab) return;
              _soDeckTabFrom = _soDeckTab;
              _soDeckTab = i;
              _soDeckTabTick.value++;
            },
            // ข้อความแท็บอยู่กับที่ (กรอบหัวแฟ้มเลื่อนมาหา) · สีตัวอักษรเปลี่ยนนุ่ม
            child: SizedBox(
              width: ws[i],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      // น้ำหนักเท่ากันทุกแท็บ (ความกว้างไม่เปลี่ยน) ต่างแค่สี
                      style: _t(14.0,
                          color: i == cur ? _inkTitle : _ink2,
                          weight: FontWeight.w700),
                      child: Text(label),
                    ),
                    if (n != null) ...[
                      const SizedBox(width: 6.0),
                      Text('$n',
                          style: _num(12.5,
                              color: i == cur ? _blue : _ink3,
                              weight: FontWeight.w700)),
                      // วงความคืบหน้า: กรอกแล้ว / ทั้งหมดของแฟ้ม (ครบ = เขียว)
                      if (n > 0) ...[
                        const SizedBox(width: 6.0),
                        () {
                          final xs = prog != null
                              ? const <_SoDeckItem>[]
                              : _soDeckItems()
                                  .where((x) => x.section == label)
                                  .toList();
                          final done =
                              xs.where((x) => _soDone.contains(x.id)).length;
                          final f = prog?[label] ??
                              (xs.isEmpty ? 0.0 : done / xs.length);
                          return TweenAnimationBuilder<double>(
                            tween: Tween(end: f),
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            // ครบทั้งแฟ้ม = วงเขียวทึบมี ✓ (เด้งเข้า) แทนวงความคืบหน้า
                            builder: (context, v, _) => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutBack,
                              transitionBuilder: (c, a) =>
                                  ScaleTransition(scale: a, child: c),
                              child: f >= 1.0
                                  ? Container(
                                      key: const ValueKey('done'),
                                      width: 16.0,
                                      height: 16.0,
                                      decoration: const BoxDecoration(
                                          color: _green,
                                          shape: BoxShape.circle),
                                      child: const _SolarIcon('ph-check',
                                          size: 11.0, color: Colors.white),
                                    )
                                  : SizedBox.square(
                                      key: const ValueKey('ring'),
                                      dimension: 16.0,
                                      child: CustomPaint(
                                          painter: _MiniDonut(v, _blue)),
                                    ),
                            ),
                          );
                        }(),
                      ],
                    ],
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: f),
        ],
      ]),
    );
    return TweenAnimationBuilder<Offset>(
      tween: Tween(end: Offset(xs[cur], ws[cur])),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      // ต่อเฟรมสร้างเฉพาะหัวแฟ้ม/กรอบ · เนื้อหาและแถวชื่อแท็บสร้างครั้งเดียว (child / labels)
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (c, prev) =>
            Stack(alignment: Alignment.topCenter, children: [
          // หน้าเดิมสูงเท่าเดิม (ไม่บีบให้เท่าหน้าใหม่ = ไม่ overflow ระหว่างสลับ)
          for (final p in prev)
            Positioned(left: 0.0, top: 0.0, right: 0.0, child: p),
          if (c != null) c,
        ]),
        transitionBuilder: (c, an) {
          final incoming = c.key == ValueKey(cur);
          final dx =
              (_soDeckTabFrom <= cur ? 1.0 : -1.0) * (incoming ? 0.06 : -0.06);
          return FadeTransition(
            opacity: an,
            child: SlideTransition(
                position:
                    Tween(begin: Offset(dx, 0.0), end: Offset.zero).animate(an),
                child: c),
          );
        },
        child: KeyedSubtree(key: ValueKey(cur), child: tabs[cur].$3()),
      ),
      builder: (context, o, content) {
        final x = o.dx, w = o.dy;
        // แท็บแรก (ชิดซ้าย) = ไม่มีฟิลเลตซ้าย มุมซ้ายบนของแฟ้มเหลี่ยม · ค่อย ๆ เปลี่ยนตามระยะ
        final away = (x / 20.0).clamp(0.0, 1.0);
        return Stack(children: [
          // ตัว folder (เส้นขอบรอบ) · แท็บแรกเลือก = มุมซ้ายบนเหลี่ยมต่อเส้นแท็บ
          Padding(
            padding: const EdgeInsets.only(top: th),
            // ไม่มี AnimatedSize: ปล่อยให้แถวที่กำลังกาง (SizeTransition) ดันความสูงเองลื่นกว่า
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 14.0, 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: lc, width: 0.5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0 * away),
                    topRight: const Radius.circular(16.0),
                    bottomLeft: const Radius.circular(16.0),
                    bottomRight: const Radius.circular(16.0)),
              ),
              // สลับแท็บ: เนื้อหาจาง + เลื่อนตามทิศ (ขวา→ซ้าย เมื่อไปแท็บถัดไป) · ความสูงยืดตามนุ่ม ๆ
              // ไม่มี AnimatedSize: จัด layout ทั้งแฟ้มทุกเฟรม = กระตุก · สลับแบบจาง+เลื่อนสั้น ๆ
              child: content,
            ),
          ),
          // หัวแฟ้ม (กรอบแท็บ + ฟิลเลต) ชิ้นเดียว เลื่อน/ยืดตามแท็บที่เลือก
          Positioned(
            left: x - f,
            top: 0.0,
            width: w + 2 * f,
            height: th + 1.0,
            child: Stack(children: [
              Positioned(
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                width: f,
                child: Opacity(
                    opacity: away,
                    child: const CustomPaint(
                        painter: _TabFillet(th: th, color: lc, left: true))),
              ),
              Positioned(
                left: f,
                top: 0.0,
                bottom: 0.0,
                width: w,
                child: CustomPaint(
                    painter: _TabOutline(
                        th: th,
                        f: f,
                        color: lc,
                        first: away < 0.5,
                        bg: _panel)),
              ),
              Positioned(
                left: f + w,
                top: 0.0,
                bottom: 0.0,
                width: f,
                child:
                    const CustomPaint(painter: _TabFillet(th: th, color: lc)),
              ),
            ]),
          ),
          labels,
        ]);
      },
    );
  }

  /// เนื้อหาหน้า Order Set ภาษาเดียวกับแผงวินิจฉัย (2026-10-22):
  /// การ์ด Order Set (ชื่อ + คำอธิบาย + ภาพมุมขวาบน + แผ่นปุ่ม เลือกชุด / AI แนะนำ / ชุดล่าสุด)
  /// ชุดทั้งหมดเปิดจากปุ่ม "เลือกชุด" (ไม่วางตารางในหน้า)
  List<Widget> _orderSetGrid() => [
        // เคยสั่งแล้ว: ต่อจากคำสั่งเดิม (เพิ่ม/แก้) ขึ้นก่อน · หรือเริ่มชุดใหม่จากการ์ดด้านล่าง
        // เคยสั่งแล้ว = มีแค่การ์ดคำสั่งเดิม (สั่งเพิ่ม/แก้) ไม่มีการ์ดเริ่มชุดใหม่ด้านล่าง
        if (_soPrev != null)
          _soPrevCard()
        else ...[
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
                // ไม่ใช้เทมเพลต: เปิดใบเปล่า แล้วเพิ่มรายการเองตามหมวดในหน้า One Day / Continuation
                (Icons.edit_note_rounded, 'สั่งเอง', _soCustomStart),
                (Icons.auto_awesome_rounded, 'AI แนะนำ', _soRecAsk),
              ]),
            ]),
          ),
          // เลือกชุดแล้ว: การ์ดชุดที่เลือกอยู่ (แบบการ์ดในหน้าเลือกชุด สีปกติ) แทนการ์ด AI แนะนำ
          if (_soSetPicked.contains(_caseP().hn) && _template != _soCustom)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _soPickPage(selectedOnly: true),
            )
          else
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
        ],
      ];

  /// ชื่อชุดคำสั่งที่แสดง: "ใช้บ่อย" เป็นหมวด ไม่ใช่ชื่อชุด จึงแสดงเป็นชุดทั่วไป
  /// ชุดแบบ template ใช้ชื่อ template (เช่น Standing order Snake bite)
  /// ใบเปล่า (สั่งเองไม่ใช้เทมเพลต): ไปหน้า One Day เลย
  Future<void> _soCustomStart() async {
    if (!await _soConfirmReplace(_soCustom,
        title: 'เริ่มสั่งเองใหม่?', action: 'เริ่มใหม่')) return;
    HapticFeedback.selectionClick();
    setState(() {
      _template = _soCustom;
      _orderEditing = null;
      _soPickOpen = false;
      _soSetPicked.add(_caseP().hn);
    });
    _pageGo(_uiSeq, _pageAt(_uiSeq) + 1);
  }

  String _setName(String cat) {
    if (cat == _soCustom) return 'สั่งเอง';
    if (cat == 'ใช้บ่อย') return 'General Emergency';
    final tpl = _orderTemplatesOf[cat];
    return tpl != null && tpl.first.$1 != 'inline' ? tpl.first.$2 : cat;
  }

  /// เลือกชุด: ชุดในหน้า (inline) = ตั้งเป็นชุดปัจจุบัน · ชุดแบบ template = เปิด template
  Future<void> _orderSetPick(String cat) async {
    if (!await _soConfirmReplace(cat)) return;
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

  /// เปลี่ยนชุด/สั่งเอง/AI เติม ทับแบบร่างที่มีรายการแล้ว: ถามก่อนเสมอ (ยกเลิก + แทนที่สีแดง)
  /// ไม่มีรายการในแบบร่าง หรือเลือกชุดเดิม = ไม่ถาม
  Future<bool> _soConfirmReplace(String to,
      {String? title, String? action, bool force = false}) async {
    if (!_soSetPicked.contains(_caseP().hn) || (to == _template && !force)) {
      return true;
    }
    final items = _soDeckItems();
    if (items.isEmpty) return true;
    final filled = items.where((x) => _soDone.contains(x.id)).length;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _panel,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(title ?? 'เปลี่ยนเป็นชุด ${_setName(to)}?',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            // กว้างพอดีอ่าน (ไม่ยืดเต็มจอ) · บอกผลที่จะเกิดกับรายการที่เลือกไว้
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380.0),
              child: Text(
                  // ตัดบรรทัดเองเป็นวลีสั้น (Flutter ตัดคำไทยกลางคำได้ถ้าปล่อยให้ wrap เอง)
                  'คำสั่ง ${items.length} รายการที่เลือกไว้จะหายไป'
                  '${filled > 0 ? '\nรวมถึงรายละเอียดที่กรอกไว้ด้วย' : ''}',
                  style: _t(13.5, color: _ink2, weight: FontWeight.w500)),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('ยกเลิก',
                      style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
              FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _red),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(action ?? 'เปลี่ยนชุด',
                      style: _t(14.0,
                          color: Colors.white, weight: FontWeight.w600))),
            ],
          ),
        ) ??
        false;
    return ok && mounted;
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

  Future<void> _aiFillStart() async {
    final byType = switch (_caseP().type) {
      _Ptype.sepsis => 'Sepsis',
      _Ptype.stemi => 'Chest Pain',
      _Ptype.stroke => 'Stroke Fast Tract',
      _Ptype.trauma => 'Trauma',
      _ => null,
    };
    // AI ล้างแล้วติ๊กใหม่ทั้งชุด: มีรายการอยู่แล้ว = ถามก่อน (แม้ชุดเดิม)
    if (!await _soConfirmReplace(byType ?? _template,
        force: true, title: 'ใช้คำสั่งที่ AI แนะนำ?', action: 'ใช้คำแนะนำ')) {
      return;
    }
    HapticFeedback.lightImpact();
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
                  ? const _SolarIcon('ph-check',
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
    final rounds = _soRoundsOf(hn);
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
    // ทำแล้ว = บอกผู้ทำและเวลาใต้สถานะ
    // แท็บนี้อ่านอย่างเดียว: รับคำสั่งทำที่ขั้น "รับคำสั่งแพทย์" ของพยาบาล (แผงขวา)
    Widget status(String st, [String? name]) {
      final ak = '$hn|${r.no}|${r.time}|$name';
      final got = name == null ? null : _soAccepted[ak];
      // ทำเป็นรอบ (×N) เริ่มแล้ว: ไม่มีป้ายขวา (แถบรอบใต้รายการบอกแล้ว)
      final rec = name == null ? null : _taskRounds['$hn|$name'];
      if (name != null &&
          _soRoundTotal(name) != null &&
          (rec?.isNotEmpty ?? false) &&
          !_taskDone.contains(name)) {
        return const SizedBox.shrink();
      }
      if (st == 'รอรับ' && got != null) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('รับแล้ว',
                  style: _t(12.5, color: _blue, weight: FontWeight.w600)),
              Text(got.$1,
                  style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
              Text(_clock(got.$2),
                  style: _num(12.0, color: _ink3, weight: FontWeight.w500)),
            ]);
      }
      // ติ๊กทำเสร็จจากการ์ดคำสั่งในภาพรวม/ขั้นรับคำสั่ง = ทำแล้ว (ผู้ทำ + เวลาจากงาน)
      if (st != 'ทำแล้ว' && name != null && _taskDone.contains(name)) {
        st = 'ทำแล้ว';
      }
      // ผู้ทำ/เวลาอยู่ใน footer ของการ์ด (foot) · ขวาบนเหลือแค่สถานะ
      // ทำแล้ว/รอรับ = เหรียญหน้าสุดของการ์ด (_SoStatusCoin)
      if (st == 'ทำแล้ว') return const SizedBox.shrink();
      return const SizedBox.shrink();
    }

    // ผู้ทำ + เวลาที่ทำของรายการที่ทำแล้ว (null = ยังไม่ทำ / ทำเป็นรอบยังไม่ครบ)
    (String, String)? doneBy(String st, String name) {
      final done = st == 'ทำแล้ว' || _taskDone.contains(name);
      if (!done) return null;
      final at = _taskDoneAt[name];
      final w = _taskDoneBy[name];
      return w != null && at != null
          ? (
              w,
              '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}'
            )
          : _soDoneBy['${r.time}|$name'];
    }

    // การ์ดส่วน (One Day / Continuation): หัวข้อ + จำนวน · แถวรายการภาษาเดียวกับ V/S
    // bare = อยู่ในแฟ้มแท็บแล้ว: ไม่มีกรอบการ์ด/หัวซ้ำ (ชื่อแฟ้มอยู่บนแท็บ)
    Widget part(String title, String sub, List<(String, String, String)> xs,
            {bool bare = false}) =>
        Container(
          margin: bare ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12.0),
          padding: bare
              ? const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0.0)
              : const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 6.0),
          decoration: bare
              ? null
              : BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!bare) ...[
              Row(children: [
                Expanded(
                  child: Text(title,
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                ),
                Text('${xs.length} รายการ',
                    style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              ]),
              const SizedBox(height: 2.0),
              Text(sub, style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              const SizedBox(height: 4.0),
            ],
            for (final (i, (name, detail, st)) in xs.indexed)
              _gListRow(
                first: i == 0,
                title: name,
                sub: detail.isEmpty ? (bare && st.isEmpty ? '' : '-') : detail,
                trail: st.isEmpty ? null : status(st, name),
              ),
          ]),
        );
    // แฟ้ม One Day / Continuation: จัดกลุ่มตามประเภทแบบหน้าตอนสั่ง (ภาพประเภท · ทำแล้ว x/y ·
    // เส้นต้นไม้ · การ์ดรายการเส้นขอบ 0.5)
    String catOf(String name) {
      if (_soCatMulti[name] case final c?) return c.first;
      for (final o in _soLinesOf(r.set)) {
        if (o.$1 == name) {
          return switch (o.$3) {
            'M' => 'Medication',
            'L' => 'Lab',
            'X' => 'X-ray',
            'ห' => 'Procedure',
            _ => 'Other',
          };
        }
      }
      for (final (g, items) in _orderSetPages(r.set)) {
        if (items.contains(name)) {
          return g.startsWith('ยา')
              ? 'Medication'
              : g.startsWith('แล็บ') || g == 'Lab'
                  ? 'Lab'
                  : g.startsWith('ภาพ') || g == 'X-ray'
                      ? 'X-ray'
                      : g.startsWith('หัตถการ')
                          ? 'Procedure'
                          : 'Other';
        }
      }
      return 'Other';
    }

    // Lab ทำแล้ว: มีค่าผลในรายละเอียด = ผลออกแล้ว · ว่าง/ยังเป็นขั้นเก็บ (เจาะ เก็บ รอ) = รอผล
    bool labResult(String detail) =>
        detail.trim().isNotEmpty &&
        !RegExp(r'^(เจาะ|เก็บ|รอ|ส่ง)').hasMatch(detail.trim());

    bool doneOf(String name, String st) =>
        st == 'ทำแล้ว' || _taskDone.contains(name);

    // X-ray: ถึงขั้นไหนแล้ว (0 = ยังไม่รับตัว … 4 = ยืนยันผล) · ค่าจำลอง: ทำแล้ว = ฉายแล้ว
    // มีผลอ่านในรายละเอียด (ปกติ/ผิดปกติ/คำอ่าน) = ยืนยันผลแล้ว
    int xrayStage(String name, String st, String detail) {
      if (!doneOf(name, st)) return 0;
      return RegExp(r'ปกติ|normal|infiltrat|fracture|effusion|ผล',
                  caseSensitive: false)
              .hasMatch(detail)
          ? 4
          : 2;
    }

    Widget xraySteps(int stage) => Row(children: [
          for (final (k, t) in const [
            'รับตัว',
            'ฉายรังสี',
            'อ่านฟิล์ม',
            'ยืนยันผล'
          ].indexed) ...[
            if (k > 0)
              Container(
                width: 12.0,
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                color: k < stage ? _green : const Color(0xFFDADCE0),
              ),
            Icon(
                k < stage
                    ? Icons.check_circle_rounded
                    : k == stage
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                size: 14.0,
                color: k < stage
                    ? _green
                    : k == stage
                        ? _blue
                        : _g5),
            const SizedBox(width: 3.0),
            Text(t,
                style: _t(11.5,
                    color: k < stage
                        ? _ink2
                        : k == stage
                            ? _blue
                            : _ink3,
                    weight: k == stage ? FontWeight.w700 : FontWeight.w500)),
          ],
        ]);

    Widget leaf((String, String, String) x, [int idx = 0]) {
      final (name, detail, st) = x;
      final done = doneOf(name, st);
      final coin = done ||
          _soRoundTotal(name) == null ||
          (_taskRounds['$hn|$name']?.isEmpty ?? true);
      // สถานะ: เหรียญเอียงแบบ 3D หน้าสุดของการ์ด (_SoStatusCoin)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Stack(clipBehavior: Clip.none, children: [
          Material(
            color: _panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // เหรียญสถานะหน้าสุด: ทำแล้ว = เขียว ✓ · รอรับ = เทา นาฬิกา
                                if (coin) ...[
                                  // appear: เหรียญหมุนรอบแกน Y โผล่ขึ้นมาจากใต้ขอบล่างการ์ด
                                  // (การ์ดตัดขอบ = เห็นโผล่จากล่าง) หมุนช้าลงจนหยุดที่มุมเดิม ไล่ทีละแถว
                                  TweenAnimationBuilder<double>(
                                    key: ValueKey('coin-$name-$done'),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration:
                                        Duration(milliseconds: 900 + 90 * idx),
                                    curve: Interval(
                                        (90 * idx) / (900 + 90 * idx), 1.0,
                                        curve: Curves.easeOutCubic),
                                    builder: (context, v, child) =>
                                        Transform.translate(
                                      offset: Offset(0.0, (1.0 - v) * 56.0),
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.003)
                                          ..rotateY((1.0 - v) * math.pi * 3.0),
                                        child: child,
                                      ),
                                    ),
                                    child: !done
                                        ? const _SoStatusCoin.wait()
                                        : catOf(name) == 'X-ray'
                                            ? xrayStage(name, st, detail) >= 4
                                                ? const _SoStatusCoin.result()
                                                : const _SoStatusCoin.lab()
                                            : catOf(name) != 'Lab'
                                                ? const _SoStatusCoin.done()
                                                : labResult(detail)
                                                    ? const _SoStatusCoin
                                                        .result()
                                                    : const _SoStatusCoin.lab(),
                                  ),
                                  const SizedBox(width: 12.0),
                                ],
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(name,
                                          style: _t(14.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w500)),
                                      if (detail.isNotEmpty)
                                        Text(detail,
                                            style: _t(12.5,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      // X-ray: ขั้นงานรังสีแบบ HOSxP (รับตัว · ฉายรังสี · อ่านฟิล์ม · ยืนยันผล)
                                      if (catOf(name) == 'X-ray')
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: xraySteps(
                                              xrayStage(name, st, detail)),
                                        ),
                                      // ทำเป็นรอบ: แถบรอบตัวเดียวกับสรุปยาในแบบร่าง (ทำแล้ว · ถัดไป · ต่อไป)
                                      if (!done && _soRoundTotal(name) != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: _soRoundTrackOf(hn, name),
                                        ),
                                    ])),
                                const SizedBox(width: 8.0),
                                // ทำแล้ว: เวลาที่ทำ + ผู้ทำ ชิดขวา
                                if (doneBy(st, name) case final b?)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // Lab: บน = #เลขที่สั่ง (สีตามสถานะผล รอผล ฟ้า · ผลออกแล้ว เขียว)
                                        // ล่าง = ฟอร์มใบสั่ง (คอลัมน์ ฟอร์ม ของ HOSxP) แทนเวลา/ผู้ทำ
                                        if (catOf(name) == 'Lab')
                                          Text('#${_soLabNo(r.time, name)}',
                                              style: _t(12.0,
                                                  color: labResult(detail)
                                                      ? _green
                                                      : _blue,
                                                  weight: FontWeight.w700)),
                                        // เวลาเด่น (บรรทัดบน) · ชื่อผู้ทำรอง (เทา) · Lab ไม่มีเวลา (เลขที่สั่งแทน)
                                        if (catOf(name) != 'Lab')
                                          Text(_clock(b.$2),
                                              style: _num(12.5,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w700)),
                                        Text(
                                            catOf(name) == 'Lab'
                                                ? _soLabForm(name)
                                                : b.$1,
                                            style: _t(12.5,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      ])
                                else
                                  status(st, name),
                              ]),
                        ]),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      );
    }

    Widget groups(List<(String, String, String)> xs) {
      final present = [
        for (final g in _soCatGroups)
          if (xs.any((x) => catOf(x.$1) == g.$1)) g
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final (k, (cat, label, icon)) in present.indexed)
          if ([
            for (final x in xs)
              if (catOf(x.$1) == cat) x
          ]
              case final g)
            Container(
              margin: EdgeInsets.only(top: k == 0 ? 0.0 : 22.0),
              padding: const EdgeInsets.only(left: 2.0),
              child: Stack(clipBehavior: Clip.none, children: [
                // ภาพประเภทมุมขวาบน ปลายล่างฟุ้ง (แบบหน้าตอนสั่ง)
                Positioned(
                  right: -2.0,
                  top: -6.0,
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rc) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent
                        ],
                        stops: [0.0, 0.45, 0.85],
                      ).createShader(rc),
                      child: Image.asset(icon, width: 52.0, height: 52.0),
                    ),
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(label,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      Text(
                          'ทำแล้ว ${g.where((x) => doneOf(x.$1, x.$3)).length}/${g.length}',
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w500)),
                      for (final (i, x) in g.indexed)
                        IntrinsicHeight(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 28.0,
                                  child: CustomPaint(
                                      painter:
                                          _SoTreeLine(last: i == g.length - 1)),
                                ),
                                Expanded(child: leaf(x, i)),
                              ]),
                        ),
                    ]),
              ]),
            ),
      ]);
    }

    // คำสั่งที่ทำเป็นรอบ (×N) ของเคส: อยู่ใน Continuation ของรอบที่สั่ง (รอบล่าสุดที่เวลาสั่งไม่เกินเวลางาน)
    final all = [...r.items, ..._soRepeatItems(hn, r, rounds)];
    final oneDay = [
      for (final o in all)
        if (o.$4) (o.$1, o.$2, o.$3)
    ];
    final cont = [
      for (final o in all)
        if (!o.$4) (o.$1, o.$2, o.$3)
    ];
    final done =
        all.where((o) => o.$3 == 'ทำแล้ว' || _taskDone.contains(o.$1)).length;
    return _clyInfoPage(
      'คำสั่งแพทย์',
      'ชุดคำสั่ง ${r.set}',
      'nurse_act',
      const [],
      by: r.by,
      at: _clock(r.time),
      // ไม่มีภาพประกอบ (ผู้ใช้ขอเอาออกไว้ก่อน 2026-10-28)
      showArt: false,
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
              Text('ทำแล้ว $done/${all.length}',
                  style: _num(13.0,
                      color: done == all.length ? _green : _inkTitle,
                      weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6.0),
            TweenAnimationBuilder<double>(
              key: ValueKey('so-prog-$sel'),
              tween:
                  Tween(begin: 0.0, end: all.isEmpty ? 0.0 : done / all.length),
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
      // แฟ้มเดียวมีแท็บ Progress Note | One Day | Continuation แบบเดียวกับตอนสั่ง
      // วงบนแท็บ = ทำแล้ว / ทั้งหมดของแฟ้ม
      extra: [
        _soDeckFolder([
          if (_soProgress[r.set] case final pn? when pn.isNotEmpty)
            (
              'Progress Note',
              null,
              () => part('Progress Note', 'ประเมินตามเกณฑ์ของชุด',
                  [for (final t in pn) (t, '', '')],
                  bare: true)
            ),
          (
            'One Day',
            oneDay.length,
            () => oneDay.isEmpty
                ? _soDeckTabEmpty('รอบนี้ไม่มีคำสั่ง One Day')
                : groups(oneDay)
          ),
          (
            'Continuation',
            cont.length,
            () => cont.isEmpty
                ? _soDeckTabEmpty('รอบนี้ไม่มีคำสั่งต่อเนื่อง')
                : groups(cont)
          ),
        ], prog: {
          'One Day': oneDay.isEmpty
              ? 0.0
              : oneDay
                      .where(
                          (o) => o.$3 == 'ทำแล้ว' || _taskDone.contains(o.$1))
                      .length /
                  oneDay.length,
          'Continuation': cont.isEmpty
              ? 0.0
              : cont
                      .where(
                          (o) => o.$3 == 'ทำแล้ว' || _taskDone.contains(o.$1))
                      .length /
                  cont.length,
        }),
      ],
    );
  }

  /// ชื่อแพทย์เดียวกันไหม: ข้อมูลเก่าใช้นามสกุลเต็ม ("ศิริพร กิตติวงศ์") master ใช้ย่อ ("ศิริพร ก.")
  bool _soSameDoctor(String a, String b) {
    String first(String n) => n
        .replaceAll(RegExp(r'^(พญ\.|นพ\.|พย\.)\s*'), '')
        .trim()
        .split(RegExp(r'\s+'))
        .first;
    return first(a) == first(b);
  }

  /// แถบรอบของคำสั่งทำเป็นรอบ (×N) ในประวัติ: รอบที่บันทึกแล้ว (_taskRounds) + รอบที่เหลือ
  /// ห่างตามชื่อ ("ทุก 15 นาที" · "ทุก 1 ชม." · "ห่าง 3 ชม.") ไม่บอก = 1 ชม. · เริ่มนับจากเวลาสั่ง
  Widget _soRoundTrackOf(String hn, String name) {
    final n = _soRoundTotal(name) ?? 1;
    final rec = _taskRounds['$hn|$name'] ?? const <(String, DateTime)>[];
    final g = RegExp(r'(\d+)\s*(นาที|ชม|ชั่วโมง)').firstMatch(name);
    final gap = g == null
        ? const Duration(hours: 1)
        : g.group(2) == 'นาที'
            ? Duration(minutes: int.parse(g.group(1)!))
            : Duration(hours: int.parse(g.group(1)!));
    final task = _tasksOfHn(hn).where((t) => t.title == name).firstOrNull;
    final now = DateTime.now();
    final hm = (task?.time ?? '').split(':');
    final ordered = hm.length == 2
        ? DateTime(
            now.year, now.month, now.day, int.parse(hm[0]), int.parse(hm[1]))
        : now;
    final done = rec.length > 2 ? rec.sublist(rec.length - 2) : rec;
    final from = rec.isNotEmpty ? rec.last.$2 : ordered;
    final up = [
      for (var k = 1; k <= n - rec.length && k <= 4 - done.length; k++)
        from.add(gap * k)
    ];
    return _soRoundTrack(done, up, col: task?.urgent ?? false ? _red : _blue);
  }

  /// ฟอร์มใบสั่ง Lab ของ HOSxP ตามชนิดรายการ (ค่าจำลอง: เดาจากชื่อ)
  String _soLabForm(String name) {
    final n = name.toLowerCase();
    if (RegExp(r'culture|gram|stain').hasMatch(n)) return 'Microbiology';
    if (RegExp(r'hiv|hbs|syphilis|hcv|atk|sars').hasMatch(n)) {
      return 'Immunology';
    }
    if (RegExp(
            r'glucose|bun|cr\b|creatinine|electrolyte|e.lyte|lft|lipid|troponin|lactate')
        .hasMatch(n)) {
      return 'Biochemistry';
    }
    return 'ใบสั่ง LAB';
  }

  /// เลขที่สั่ง Lab (ค่าจำลอง คงที่ต่อรอบ+รายการ) 6 หลักแบบ lab_order_number ของ HOSxP
  String _soLabNo(String time, String name) =>
      '${365000 + ('$time|$name'.codeUnits.fold<int>(7, (a, c) => (a * 31 + c) % 9973) % 900)}';

  /// จำนวนรอบของคำสั่งที่ทำเป็นรอบ (ชื่อลงท้าย ×N) · null = ทำครั้งเดียว
  int? _soRoundTotal(String name) =>
      int.tryParse(RegExp(r'×\s*(\d+)\s*$').firstMatch(name)?.group(1) ?? '');

  /// คำสั่งทำเป็นรอบของเคส (ข้อมูลจำลอง _repeatOrders) ที่ผูกกับรอบการสั่งนี้:
  /// รอบการสั่งล่าสุดที่เวลาสั่งไม่เกินเวลาของงาน · ก่อนทุกรอบ = รอบแรก (เก่าสุด)
  List<(String, String, String, bool)> _soRepeatItems(
      String hn, _SoRound r, List<_SoRound> rounds) {
    int mins(String hm) {
      final p = hm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    return [
      for (final o in _repeatOrders[hn] ?? const <_RepeatOrder>[])
        if ((rounds
                    .where((x) => mins(x.time) <= mins(o.task.time))
                    .firstOrNull ??
                rounds.last) ==
            r)
          (o.task.title, o.task.detail, 'รอรับ', false),
    ];
  }

  /// แฟ้มคำสั่ง (ภาพเดียวกับการ์ดคำสั่งแพทย์ในภาพรวม)
  Widget _soClipHero() => SizedBox(
        width: 110.0,
        height: 110.0,
        child: Stack(fit: StackFit.expand, children: [
          // ความหนาแผ่นรองบาง (3 ชั้น) ให้เข้ากับมุมหมุนของหน้าแฟ้ม ไม่เป็นก้อนหนาด้านขวา
          for (var i = 3; i >= 1; i--)
            Transform(
              alignment: Alignment.center,
              transform: _clipTilt(-i * 1.0),
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
      );

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
/// 670123478 นางสาวปิยะดา (ESI 5 มาขอใบรับรองแพทย์) · 670123479 นายประยูร (งูเขียวหางไหม้กัด)
/// แท็บที่เปิดใน folder แบบร่างคำสั่งแพทย์ (Progress Note | One Day | Continuation)
int _soDeckTabV = 0;
int get _soDeckTab => _soDeckTabV;
set _soDeckTab(int v) => _soDeckTabV = v;

/// กดแท็บแฟ้ม = เปลี่ยนค่านี้ (ไม่ setState ทั้งหน้า) · แฟ้มฟังเองแล้ววาดใหม่เฉพาะตัว
final ValueNotifier<int> _soDeckTabTick = ValueNotifier(0);

/// แท็บก่อนสลับ (กำหนดทิศเลื่อนของเนื้อหา)
int _soDeckTabFrom = 0;

/// เวลาที่เห็นรายการในแบบร่างครั้งแรก (เล่น appear เฉพาะที่เพิ่งเห็น < 0.5 วิ)
/// ตอนเปิดแบบร่างครั้งแรก รายการเดิมลงเวลาเก่า (ไม่เล่น)
final Map<String, DateTime> _soSeenAt = {};

/// รายการในแบบร่างรอบก่อน (หาแถวที่ถูกลบ) · แถวที่กำลังเล่น disappear: (รายการ, ตำแหน่งเดิม, เวลาเริ่ม)
List<_SoDeckItem> _soLastDeck = const [];
final Map<String, (_SoDeckItem, int, DateTime)> _soLeaving = {};
bool _soSeenReady = false;

/// คำสั่งที่บันทึกในแอป ต่อ HN (ใหม่ก่อน)
final Map<String, List<_SoRound>> _soSaved = {};

/// รับคำสั่งทีละรายการ (รอบที่แพทย์คนอื่นสั่ง): 'HN|ครั้งที่|เวลาสั่ง|ชื่อคำสั่ง' → (ผู้รับ, เวลารับ)
final Map<String, (String, String)> _soAccepted = {};

/// การ์ดวิธีใช้ในฟอร์มยา (เลื่อนให้เห็นทั้งการ์ดเมื่อเปลี่ยนโหมด)
/// ต่อรายการ: ตอนเปลี่ยนรายการ (ก่อนหน้า/ถัดไป) หน้าเก่ากับหน้าใหม่อยู่บนจอพร้อมกัน
/// key ร่วมตัวเดียว = GlobalKey ซ้ำ (assert _elements.contains)
final Map<String, GlobalKey> _soUsageKeys = {};

/// การ์ดหัตถการ (เลื่อนให้เห็นเมื่อกางช่องความถี่กำหนดเอง)
final Map<String, GlobalKey> _soProcKeys = {};

const Set<String> _soNoOrderYet = {'670123478', '670123479'};

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
    ('Record V/S, I/O', '15 นาที × 4 แล้วทุก 1 ชม.', 'รอรับ', false),
    ('Cef3 2 g iv OD', 'ให้ 14:20 น. ก่อนเข้า OR', 'ทำแล้ว', false),
    (
      'Tramol 50 mg iv prn q 6 hr',
      'ให้ 14:10 น. pain 8/10 เหลือ 4/10',
      'ทำแล้ว',
      false
    ),
    ('NPO', 'ตั้งแต่ 13:30 น. เตรียมผ่าตัด', 'รอรับ', false),
  ]),
  // ครั้งที่ 2 แพทย์เวรอีกคนสั่ง (ทดลองการรับคำสั่งต่อ)
  _SoRound(2, '10:40', 'นพ. ธีรภัทร อ.', 'Sepsis', [
    ('Levophed (4:250) iv drip', 'เริ่ม 5 ml/hr keep MAP ≥ 65', 'รอรับ', true),
    ('0.9% NSS 1,000 ml iv load', '500 ml แล้ว drip 100 ml/hr', 'ทำแล้ว', true),
    ('Hemoculture × 2', 'เจาะ 10:32 น. ก่อนให้ยา', 'ทำแล้ว', true),
    (
      'Antibiotic',
      'Piperacillin + Tazobactam 4.5 g IV q 8 hr',
      'ทำแล้ว',
      false
    ),
    ('Record SOS score', 'ทุก 1 ชม.', 'รอรับ', false),
  ]),
  _SoRound(1, '10:05', 'พญ. ศิริพร กิตติวงศ์', 'Sepsis', [
    ('0.9% NSS load 30 ml/kg', '1,900 ml ครบใน 3 ชม.', 'ทำแล้ว', true),
    ('CBC, BUN, Cr, Electrolyte', '', 'ทำแล้ว', true),
    ('DTX', '128 mg/dl', 'ทำแล้ว', true),
    ('UA, U/C', '', 'รอรับ', true),
    ('CXR', 'AP portable', 'ทำแล้ว', true),
    ('On oxygen', 'cannula 3 LPM', 'รอรับ', true),
    ('Record V/S, I/O', 'ทุก 15 นาที', 'รอรับ', false),
    ('NPO', '', 'รอรับ', false),
  ]),
];

/// ผู้ทำและเวลาของรายการที่ทำแล้วในประวัติคำสั่ง (ค่าจำลอง): 'เวลาสั่ง|ชื่อคำสั่ง' → (ผู้ทำ, เวลา)
const Map<String, (String, String)> _soDoneBy = {
  "14:00|CBC, BUN, Cr, E'lyte, antiHIV": ('พย. ณัฐพร ล.', '14:12'),
  '14:00|UPT': ('พย. ณัฐพร ล.', '14:15'),
  '14:00|EKG 12 leads': ('พย. วราภรณ์ ส.', '14:08'),
  '14:00|Cef3 2 g iv OD': ('พย. วราภรณ์ ส.', '14:20'),
  '14:00|Tramol 50 mg iv prn q 6 hr': ('พย. วราภรณ์ ส.', '14:10'),
  '10:40|0.9% NSS 1,000 ml iv load': ('พย. ณัฐพร ล.', '10:45'),
  '10:40|Hemoculture × 2': ('พย. ณัฐพร ล.', '10:32'),
  '10:40|Antibiotic': ('พย. วราภรณ์ ส.', '10:50'),
  '10:05|0.9% NSS load 30 ml/kg': ('พย. วราภรณ์ ส.', '10:10'),
  '10:05|CBC, BUN, Cr, Electrolyte': ('พย. ณัฐพร ล.', '10:12'),
  '10:05|DTX': ('พย. ณัฐพร ล.', '10:08'),
  '10:05|CXR': ('นพ. กิตติพัฒน์ ร.', '10:25'),
};

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
                ? const _SolarIcon('ph-check', size: 13.0, color: Colors.white)
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
/// ตัวแรก = หมวดหลัก (ใช้จัดกลุ่มทั้งแผงซ้ายและขวา) ต้องตรงกับรหัสในใบ
const Map<String, Set<String>> _soCatMulti = {
  '0.9% NSS load 30 ml/kg': {'Medication', 'Other'},
  'Levophed (4:250) iv drip': {'Medication', 'Other'},
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
    final custom = _template == _soCustom;
    final doc =
        _soDocs[_template] == null && !custom ? null : _soLinesOf(_template);
    final extra = _soExtra[_template] ?? const [];
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
          for (final n in items) (n, ''),
        for (final o in extra)
          if (o.$4) (o.$1, o.$2)
      ];
      cont = [
        for (final o in extra)
          if (!o.$4) (o.$1, o.$2)
      ];
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
      if (oneDay.isNotEmpty || custom)
        (1, 'Order for One Day', oneDay, _orderPicked, ''),
      // Continuation มีเสมอ (ไม่บังคับ): ชุดที่ไม่มีคำสั่งต่อเนื่อง แพทย์เพิ่มเองจาก master ได้
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
    final (_, title, raw, picks, key) = folders[i];
    // ยา STAT ขึ้นบนสุดของแฟ้ม
    final items = [
      for (final x in raw)
        if (_soStat('$key${x.$1}')) x,
      for (final x in raw)
        if (!_soStat('$key${x.$1}')) x,
    ];
    final done = items
        .where((it) =>
            picks.contains('$key${it.$1}') ||
            (picks == _soPnPick &&
                _soPnLinked.containsKey(it.$1) &&
                _soLinkedValue(it.$1) != null))
        .length;
    final sub = switch (id) {
      0 => 'ประเมินตามเกณฑ์ของชุด',
      1 => 'ทำครั้งเดียวภายในวันนี้ เช่น เจาะเลือด ถ่ายภาพ ให้ยาครั้งเดียว',
      _ => 'ทำซ้ำตามรอบเวลา จนกว่าแพทย์จะสั่งหยุด',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // หัวแฟ้ม: ชื่อ + คำอธิบาย (ไม่มีการ์ด/แผ่นปุ่ม)
        if (id != 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(id == 1 ? 'One Day' : 'Continuation',
                  style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 2.0),
              // บอกสิ่งที่ต้องทำในหน้านี้ (สั้น ๆ)
              Text(
                  id == 1
                      ? 'เลือกรายการที่ทำครั้งเดียววันนี้'
                      : 'เลือกรายการที่ทำซ้ำตามรอบ',
                  style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
            ]),
          ),
        // แฟ้มว่าง (ชุดไม่มีคำสั่งในแฟ้มนี้ เช่น Continuation): หัวการ์ด + ป้าย "ไม่บังคับ"
        // ข้างในเป็นแถวประเภท (ภาพ 3D ชุดการ์ดหมวด · ตัวอย่างคำสั่ง · ปุ่ม +) คั่นเส้นบาง
        // แตะแถว = แผ่นเลือกจาก master ของประเภทนั้น
        if ((id != 0 && items.isEmpty, _soContOpen.contains(_caseP().hn))
            case (true, final open))
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 6.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // กางแล้ว: หัวชิดซ้าย + ป้ายขวา (เหนือรายการประเภท)
                  if (open)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('มีคำสั่งที่ต้องทำซ้ำหรือไม่',
                                    style: _t(15.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                                Text(
                                    open
                                        ? 'แตะประเภทเพื่อเลือกรายการ'
                                        : 'ถ้าไม่มี ข้ามขั้นนี้ได้เลย',
                                    style: _t(12.5,
                                        color: _ink3, weight: FontWeight.w500)),
                              ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(
                                color: const Color(0xFFDADCE0), width: 0.5),
                          ),
                          child: Text('ไม่บังคับ',
                              style: _t(12.0,
                                  color: _ink2, weight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  // เริ่มแบบหุบ: ปุ่มเดียว "เพิ่มคำสั่งต่อเนื่อง" (ไม่ดูเหมือนต้องกรอก) · แตะ = กางประเภท
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: !open
                        ? Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 4.0, 8.0, 12.0),
                            // หุบ = empty state จัดกลาง: ภาพ → ป้ายไม่บังคับ → หัว → คำอธิบาย → ปุ่ม
                            child: Column(children: [
                              // ภาพประกอบ: ไอคอนประเภทสีเทาวางบนกระดาษเปล่า (ยังไม่มีรายการ)
                              const _SoEmptyPaperArt(),
                              const SizedBox(height: 14.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  border: Border.all(
                                      color: const Color(0xFFDADCE0),
                                      width: 0.5),
                                ),
                                child: Text('ไม่บังคับ',
                                    style: _t(12.0,
                                        color: _ink2, weight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8.0),
                              Text('มีคำสั่งที่ต้องทำซ้ำหรือไม่',
                                  textAlign: TextAlign.center,
                                  style: _t(16.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              const SizedBox(height: 2.0),
                              Text('ถ้าไม่มี ข้ามขั้นนี้ได้เลย',
                                  textAlign: TextAlign.center,
                                  style: _t(13.0,
                                      color: _ink3, weight: FontWeight.w500)),
                              const SizedBox(height: 16.0),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _blue,
                                  backgroundColor: _panel,
                                  side: const BorderSide(
                                      color: Color(0xFFDADCE0), width: 0.5),
                                  shape: const StadiumBorder(),
                                  minimumSize: const Size(0.0, 40.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _soContOpen.add(_caseP().hn));
                                },
                                icon: const Icon(Icons.add_rounded, size: 18.0),
                                label: Text('เพิ่มคำสั่งต่อเนื่อง',
                                    style: _t(13.0,
                                        color: _blue, weight: FontWeight.w600)),
                              ),
                            ]),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                ..._soCatAddRows(id, _soCatGroups),
                              ]),
                  ),
                ]),
          ),
        if (id == 0)
          _dxCard(
            title,
            sub,
            const SizedBox.shrink(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
          )
        else
          for (final (cat, label, icon) in _soCatGroups)
            if ([
              for (final x in items)
                if (_soCatOfName(x.$1) == cat) x
            ]
                case final xs when xs.isNotEmpty)
              // แต่ละประเภท = การ์ดแยก (ไม่มีหัว "รายการ")
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                // การ์ดซ้อน: การ์ดในห่างขอบ 8 (แถวมี padding 8 เอง) น้อยกว่าหัวข้อ 16
                // ล่าง 4 + แถว 4 = 8 เท่าขอบข้าง
                padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 4.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: // หัวกลุ่ม: ชื่อประเภท + เลือกอยู่ x/x · ไอคอน 3D ใหญ่มุมขวาบน
                    // ส่วนล่างของรูปมุดหลังการ์ดใบแรก (โผล่จากมุมบนของลิสต์)
                    Stack(clipBehavior: Clip.none, children: [
                  Positioned(
                    right: 20.0,
                    top: 8.0,
                    // ปลายล่างของรูปจางฟุ้ง ก่อนมุดหลังการ์ด
                    child: IgnorePointer(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent
                          ],
                          stops: [0.0, 0.45, 0.85],
                        ).createShader(r),
                        child: Image.asset(icon, width: 52.0, height: 52.0),
                      ),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 14.0, 90.0, 6.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(label,
                                            style: _t(14.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w700)),
                                        Text('พบในเทมเพลต ${xs.length} รายการ',
                                            style: _t(12.0,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      ]),
                                ),
                              ]),
                        ),
                        // เกิน 5 รายการ: แสดง 5 แรก (แถวสุดท้ายจางลง) + ปุ่ม "ดูรายการทั้งหมด"
                        // แบบการ์ดชุดคำสั่ง
                        ...() {
                          final ek = 'cat|$key|$cat';
                          final open = _soPickExpand[ek] ?? false;
                          final many = xs.length > 5;
                          final shown =
                              many && !open ? xs.take(5).toList() : xs;
                          return [
                            for (var k = 0; k < shown.length; k++)
                              many && !open && k == shown.length - 1
                                  ? ShaderMask(
                                      blendMode: BlendMode.dstIn,
                                      shaderCallback: (r) =>
                                          const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0x66FFFFFF),
                                          Color(0x00FFFFFF)
                                        ],
                                      ).createShader(r),
                                      child: IgnorePointer(
                                          child:
                                              _soDocRow(shown[k], picks, key)),
                                    )
                                  : _soDocRow(shown[k], picks, key),
                            // เปิดแล้วเปิดเลย (ไม่มีปุ่มซ่อน)
                            if (many && !open)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 2.0, 8.0, 6.0),
                                child: _Press(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _soPickExpand[ek] = !open);
                                    },
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
                                            Text(
                                                open
                                                    ? 'ซ่อนรายการ'
                                                    : 'ดูรายการทั้งหมด',
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
                            // เพิ่มเอง: ท้ายการ์ดหมวด ปุ่มแคปซูลทับกลางเส้นคั่น (เส้นไม่ชนขอบการ์ด)
                            SizedBox(
                              height: 48.0,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                Container(
                                    height: 1.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    color: const Color(0xFFE3E8F2)),
                                Container(
                                  color: _panel,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _blue,
                                      backgroundColor: _panel,
                                      side: const BorderSide(
                                          color: Color(0xFFDADCE0), width: 0.5),
                                      shape: const StadiumBorder(),
                                      minimumSize: const Size(0.0, 36.0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                    ),
                                    onPressed: () => _soAddOrder(id,
                                        code0: switch (cat) {
                                          'Medication' => 'M',
                                          'Lab' => 'L',
                                          'X-ray' => 'X',
                                          'Procedure' => 'ห',
                                          _ => 'oth',
                                        }),
                                    icon: const Icon(Icons.add_rounded,
                                        size: 16.0),
                                    label: Text('เพิ่มรายการ$label',
                                        style: _t(12.5,
                                            color: _blue,
                                            weight: FontWeight.w600)),
                                  ),
                                ),
                              ]),
                            ),
                          ];
                        }(),
                      ]),
                ]),
              ),
        // ท้ายแฟ้ม: สั่งประเภทที่ยังไม่มีในแฟ้มนี้เพิ่มได้ (เช่น X-ray ที่เทมเพลตไม่มี)
        if (id != 0 && items.isNotEmpty)
          if ([
            for (final g in _soCatGroups)
              if (!items.any((x) => _soCatOfName(x.$1) == g.$1)) g
          ]
              case final rest when rest.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 8.0, 6.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('สั่งประเภทอื่นเพิ่ม',
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('ประเภทที่ยังไม่มีในหน้านี้',
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    const SizedBox(height: 4.0),
                    ..._soCatAddRows(id, rest),
                  ]),
            ),
      ],
    );
  }

  /// แถวเพิ่มคำสั่งตามประเภท (ภาพ 3D ชุดการ์ดหมวด · ตัวอย่างคำสั่งของแฟ้ม · ปุ่ม +) คั่นเส้นบาง
  /// แตะ = แผ่นเลือกจาก master ของประเภทนั้น
  List<Widget> _soCatAddRows(int fid, List<(String, String, String)> cats) => [
        for (final (k, (cat, label, icon)) in cats.indexed) ...[
          if (k > 0)
            const Divider(
                height: 1.0,
                thickness: 0.5,
                indent: 52.0,
                endIndent: 8.0,
                color: Color(0xFFE8EAED)),
          InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () => _soAddOrder(fid,
                code0: switch (cat) {
                  'Medication' => 'M',
                  'Lab' => 'L',
                  'X-ray' => 'X',
                  'Procedure' => 'ห',
                  _ => 'oth',
                }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 8.0, 10.0),
              child: Row(children: [
                Image.asset(icon, width: 40.0, height: 40.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: _t(14.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                        Text(
                            fid == 2
                                ? switch (cat) {
                                    'Medication' => 'เช่น ยาให้ทุก 6 ชม.',
                                    'Lab' => 'เช่น เจาะ DTX ทุก 6 ชม.',
                                    'X-ray' => 'เช่น ถ่ายภาพซ้ำตามนัด',
                                    'Procedure' => 'เช่น ทำแผลวันละ 2 ครั้ง',
                                    _ => 'เช่น วัดสัญญาณชีพทุก 4 ชม.',
                                  }
                                : switch (cat) {
                                    'Medication' =>
                                      'เช่น ยาให้ครั้งเดียวตอนนี้',
                                    'Lab' => 'เช่น CBC, Electrolyte',
                                    'X-ray' => 'เช่น CXR, CT brain',
                                    'Procedure' => 'เช่น เย็บแผล ใส่สายสวน',
                                    _ => 'เช่น งดน้ำงดอาหาร',
                                  },
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                ),
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                  ),
                  child:
                      const Icon(Icons.add_rounded, size: 18.0, color: _blue),
                ),
              ]),
            ),
          ),
        ],
      ];

  /// บรรทัดคำสั่งของชุด = ใบ standing order + ที่แพทย์เพิ่มเอง
  List<(String, String, String, bool)> _soLinesOf(String t) =>
      [...?_soDocs[t], ...?_soExtra[t]];

  /// รายการในแฟ้มที่ติ๊กได้ (ไม่รวมคำสั่งเดิมที่ทำแล้ว)
  List<String> _soFolderIds(int fid) {
    final f = _soFolders().where((x) => x.$1 == fid).firstOrNull;
    if (f == null) return const [];
    return [
      for (final it in f.$3)
        if (_soPrevStatus(it.$1) != 'ทำแล้ว') '${f.$5}${it.$1}'
    ];
  }

  /// เลือกทั้งหมด / ล้างที่เลือก ของแฟ้ม
  void _soSelectAll(int fid) {
    final f = _soFolders().where((x) => x.$1 == fid).firstOrNull;
    if (f == null) return;
    final ids = _soFolderIds(fid);
    final all = ids.every(f.$4.contains);
    HapticFeedback.selectionClick();
    setState(() {
      if (all) {
        f.$4.removeAll(ids);
        for (final id in ids) {
          _soDone.remove(id);
          _soAi.remove(id);
        }
      } else {
        f.$4.addAll(ids);
      }
    });
  }

  /// AI แนะนำในแฟ้ม: ติ๊กรายการที่เข้ากับเคส · ข้ามยาที่ชนประวัติแพ้ ·
  /// ข้ามรายการมีเงื่อนไข (ถ้า… / Stop / If) และ UPT ถ้าไม่ใช่หญิงวัยเจริญพันธุ์
  void _soAiPick(int fid) {
    final f = _soFolders().where((x) => x.$1 == fid).firstOrNull;
    if (f == null) return;
    final c = _case;
    var picked = 0, cond = 0, allergy = 0;
    setState(() {
      for (final (name, detail) in f.$3) {
        final id = '${f.$5}$name';
        if (f.$4.contains(id) || _soPrevStatus(name) == 'ทำแล้ว') continue;
        final l = '$name $detail'.toLowerCase();
        if (detail.trimLeft().startsWith('ถ้า') ||
            l.startsWith('stop') ||
            l.startsWith('if ') ||
            detail.contains('ระบุยา')) {
          cond++;
          continue;
        }
        if (name.toUpperCase().contains('UPT') &&
            !(c.sex.contains('หญิง') && c.age >= 12 && c.age <= 50)) {
          cond++;
          continue;
        }
        if (_soCatOfName(name) == 'Medication' && _soAllergyHit(name) != null) {
          allergy++;
          continue;
        }
        f.$4.add(id);
        _soAi.add(id);
        picked++;
      }
    });
    HapticFeedback.lightImpact();
    _wfToast([
      'AI เลือก $picked รายการ',
      if (cond > 0) 'ข้ามรายการมีเงื่อนไข $cond',
      if (allergy > 0) 'ข้ามยาที่แพ้ $allergy',
    ].join('  '));
  }

  /// เพิ่มคำสั่งนอกใบ: ชื่อ + ประเภท → ติ๊กให้แล้วเปิดหน้ากรอกรายละเอียด
  /// เพิ่มคำสั่งนอกเทมเพลตของหมวด: แผ่น filter จาก master (er_order_item_*)
  /// ซ้าย = กลุ่มตามชุดคำสั่ง (Stroke · STEMI · Sepsis ...) · ค้นหาได้ทุกกลุ่ม
  /// ไม่มีในรายการ = "ระบุเอง" (พิมพ์ชื่อ) · เลือกแล้วติ๊กให้และเปิดหน้ากรอกรายละเอียด
  Future<void> _soAddOrder(int fid, {String code0 = 'M'}) async {
    final master = switch (code0) {
      'M' => 'er_order_item_med',
      'L' => 'er_order_item_lab',
      'X' => 'er_order_item_xray',
      'ห' => 'er_order_item_procedure',
      _ => 'er_nursing_activity',
    };
    const groups = [
      ('template_general_emergency', 'ฉุกเฉินทั่วไป'),
      ('template_sepsis', 'Sepsis'),
      ('template_stemi', 'STEMI'),
      ('template_stroke', 'Stroke'),
      ('template_trauma', 'Trauma'),
      ('template_non_emergent', 'ตรวจโรคทั่วไป'),
    ];
    final items = [
      for (final x in _procMaster(master))
        if (x.name.trim() != 'อื่นๆ') x
    ];
    List<String> inGroup(String g) => [
          for (final x in items)
            if ((x.extra['templates'] as List?)?.contains(g) ?? false) x.name
        ];
    final cats = <(String, List<String>)>[
      for (final (g, t) in groups)
        if (inGroup(g).isNotEmpty) (t, inGroup(g)),
      // กิจกรรมพยาบาล (master ไม่มีกลุ่ม): จัดหมวดตามรหัส NA ให้หาง่ายแบบแผ่น filter
      if (master == 'er_nursing_activity')
        for (final (t, codes) in const [
          ('เฝ้าระวังอาการ', ['NA01', 'NA07', 'NA09', 'NA17', 'NA18', 'NA12']),
          ('ความปวด', ['NA02', 'NA03', 'NA04', 'NA06']),
          ('ตามแผนการรักษา', ['NA05', 'NA08', 'NA11']),
          ('ดูแลทั่วไป', ['NA10', 'NA13', 'NA14', 'NA15']),
          ('ให้ข้อมูล', ['NA16']),
        ])
          if ([
            for (final x in items)
              if (codes.contains(x.code)) x.name
          ]
              case final xs when xs.isNotEmpty)
            (t, xs),
      // master อื่นที่ไม่มีกลุ่ม = หมวดเดียว · กิจกรรมที่ยังไม่จัดหมวด = อื่น ๆ
      if (master != 'er_nursing_activity' &&
          items.every((x) => x.extra['templates'] == null))
        ('ทั้งหมด', [for (final x in items) x.name]),
      if (master == 'er_nursing_activity')
        if ([
          for (final x in items)
            if (!RegExp(r'^NA(0[1-9]|1[0-8])$').hasMatch(x.code)) x.name
        ]
            case final xs when xs.isNotEmpty)
          ('อื่น ๆ', xs),
    ];
    const types = {
      'M': 'การให้ยา',
      'L': 'Lab',
      'X': 'X-ray',
      'ห': 'หัตถการ',
      'oth': 'อื่น ๆ',
    };
    void add(String n) {
      if (!mounted || n.trim().isEmpty) return;
      setState(() {
        _soExtra
            .putIfAbsent(_template, () => [])
            .add((n.trim(), '', code0, fid != 2));
        _orderPicked.add(n.trim());
      });
      _soEditOpen(n.trim());
    }

    await _soFilterSheet(
      title: 'เพิ่มรายการ${types[code0] ?? ''}',
      sub: 'คำสั่งนอกเทมเพลต ${fid == 2 ? 'Continuation' : 'One Day'}',
      cats: cats,
      current: null,
      onPick: add,
      customLabel: 'ระบุเอง',
      onCustom: () => _soAddCustom(fid, code0: code0),
    );
  }

  /// ระบุเอง: พิมพ์ชื่อรายการที่ไม่มีใน master
  Future<void> _soAddCustom(int fid, {String code0 = 'M'}) async {
    final name = TextEditingController();
    var code = code0;
    const types = [
      ('M', 'การให้ยา'),
      ('L', 'Lab'),
      ('X', 'X-ray'),
      ('ห', 'หัตถการ'),
      ('oth', 'อื่น ๆ'),
    ];
    // bottom sheet (ย้ายตำแหน่งได้แบบแผ่นอื่น) · หัว = เพิ่มรายการ{หมวด} · ปุ่มหลักเดียว "เพิ่ม"
    String hint(String c) => switch (c) {
          'M' => 'เช่น Ondansetron 4 mg IV stat',
          'L' => 'เช่น Troponin T',
          'X' => 'เช่น CT brain non-contrast',
          'ห' => 'เช่น ใส่สายสวนปัสสาวะ',
          _ => 'เช่น NPO, Record I/O',
        };
    final icon = switch (code) {
      'M' => 'assets/images/er_os_med.png',
      'L' => 'assets/images/er_os_lab.png',
      'X' => 'assets/images/er_os_xray.png',
      'ห' => 'assets/images/er_os_proc_cap.png',
      _ => 'assets/images/er_os_other.png',
    };
    final catName = types.firstWhere((t) => t.$1 == code).$2;
    // bottom sheet (ย้ายตำแหน่งได้): รูปหมวดมุมขวาบน · หัว + คำอธิบาย · ช่องพิมพ์ชื่อ
    // ประเภทมาจากการ์ดหมวดที่กด (ไม่ต้องเลือกซ้ำ) · ปุ่มหลักเดียว "เพิ่ม"
    final ok = await _placedSheet<bool>(
          context: context,
          constraints: const BoxConstraints(maxWidth: 560.0),
          builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
            final can = name.text.trim().isNotEmpty;
            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Stack(children: [
                  Positioned(
                    right: 56.0,
                    top: 10.0,
                    child: IgnorePointer(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.transparent],
                          stops: [0.5, 1.0],
                        ).createShader(r),
                        child: Image.asset(icon, width: 64.0, height: 64.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 20.0, 12.0, 20.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('เพิ่มรายการ$catName',
                                            style: _t(22.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w700)),
                                        const SizedBox(height: 2.0),
                                        Text(
                                            'คำสั่งนอกเทมเพลต ${fid == 2 ? 'Continuation' : 'One Day'}',
                                            style: _t(13.0,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      ]),
                                ),
                                IconButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    icon: const Icon(Icons.close_rounded,
                                        color: _ink2)),
                              ]),
                          const SizedBox(height: 18.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: TextField(
                              controller: name,
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => setD(() {}),
                              onSubmitted: (_) {
                                if (name.text.trim().isNotEmpty) {
                                  Navigator.pop(ctx, true);
                                }
                              },
                              style: _t(16.0,
                                  color: _inkTitle, weight: FontWeight.w500),
                              decoration: InputDecoration(
                                labelText: 'ชื่อรายการ',
                                labelStyle: _t(14.0,
                                    color: _ink3, weight: FontWeight.w500),
                                floatingLabelStyle: _t(13.0,
                                    color: _blue, weight: FontWeight.w600),
                                hintText: hint(code),
                                hintStyle: _t(14.0, color: _ink3),
                                filled: true,
                                fillColor: _panel,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFDADCE0), width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: const BorderSide(
                                      color: _blue, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                                'เพิ่มแล้วติ๊กให้ทันที และเปิดหน้ากรอกรายละเอียดต่อ',
                                style: _t(12.5,
                                    color: _ink3, weight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 160),
                              opacity: can ? 1.0 : 0.4,
                              child: SizedBox(
                                height: 52.0,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _blue,
                                    disabledBackgroundColor: _blue,
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: can
                                      ? () => Navigator.pop(ctx, true)
                                      : null,
                                  child: Text('เพิ่ม',
                                      style: _t(15.0,
                                          color: Colors.white,
                                          weight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ]),
              ),
            );
          }),
        ) ??
        false;
    final n = name.text.trim();
    // dispose หลังหน้าต่างปิดสุด (ระหว่างแอนิเมชันปิด TextField ยังใช้ controller อยู่)
    Future.delayed(const Duration(milliseconds: 600), name.dispose);
    if (!ok || n.isEmpty || !mounted) return;
    setState(() {
      _soExtra.putIfAbsent(_template, () => []).add((n, '', code, fid != 2));
      _orderPicked.add(n);
    });
    _soEditOpen(n);
  }

  /// ประเภทแรกที่มีรายการในชุดนี้ (ไม่มีเส้นคั่นด้านบน)
  String? _soFirstCat(List<_SoDeckItem> xs) {
    for (final (cat, _, _) in _soCatGroups) {
      if (xs.any((x) => _soCatsOf(x).first == cat)) return cat;
    }
    return null;
  }

  /// ลำดับกลุ่มประเภทในหน้าแฟ้ม: (หมวด, ชื่อ, ไอคอน)
  List<(String, String, String)> get _soCatGroups => const [
        ('Medication', 'การให้ยา', 'assets/images/er_os_med.png'),
        ('Lab', 'Lab', 'assets/images/er_os_lab.png'),
        ('X-ray', 'X-ray', 'assets/images/er_os_xray.png'),
        ('Procedure', 'หัตถการ', 'assets/images/er_os_proc_cap.png'),
        ('Other', 'อื่น ๆ', 'assets/images/er_os_other.png'),
      ];

  /// ประเภทของรายการตามรหัสในใบ (M L X ห) · ชุดไม่มีใบ = ตามชื่อกลุ่มของชุด
  String _soCatOfName(String name) {
    if (_soCats[name] case final c? when c.isNotEmpty) return c.first;
    for (final o in _soLinesOf(_template)) {
      if (o.$1 == name) {
        return switch (o.$3) {
          'M' => 'Medication',
          'L' => 'Lab',
          'X' => 'X-ray',
          'ห' => 'Procedure',
          _ => 'Other',
        };
      }
    }
    for (final (g, items) in _orderSetPages(_template)) {
      if (items.contains(name)) {
        return g.startsWith('ยา')
            ? 'Medication'
            : g.startsWith('แล็บ') || g == 'Lab'
                ? 'Lab'
                : g.startsWith('ภาพ') || g == 'X-ray'
                    ? 'X-ray'
                    : g.startsWith('หัตถการ')
                        ? 'Procedure'
                        : 'Other';
      }
    }
    return 'Other';
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
      1 => 'ทำครั้งเดียวภายในวันนี้ เช่น เจาะเลือด ถ่ายภาพ ให้ยาครั้งเดียว',
      _ => 'ทำซ้ำตามรอบเวลา จนกว่าแพทย์จะสั่งหยุด',
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

    // แตะแถว = ติ๊ก/เอาออก (ยังไม่เข้าหน้ากรอก) · รายการที่ติ๊กแล้วมีปุ่ม "ระบุรายละเอียด"
    // แต่ละรายการเป็นการ์ด (น่ากด): ติ๊กแล้ว = พื้นเทาอ่อน · ยังไม่ติ๊ก = ขาวขอบเทา
    // พื้น + ขอบอยู่ที่ Material (ripple วาดบนพื้น ไม่ถูกพื้นขาวทับ)
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: Material(
        color: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: toggle,
          splashColor: _blue.withValues(alpha: 0.10),
          highlightColor: _blue.withValues(alpha: 0.04),
          splashFactory: InkRipple.splashFactory,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
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
                      // ยา STAT: ป้ายด่วนแบบงานด่วนในการ์ดคำสั่งแพทย์
                      if (on && _soStat(id)) ...[
                        const SizedBox(width: 6.0),
                        _soStatBadge(),
                      ],
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
                            style: _t(11.5,
                                color: _blue, weight: FontWeight.w700)),
                      ],
                    ]),
                    if (it.$2.isNotEmpty)
                      Text(it.$2, style: _t(12.0, color: _ink3)),
                    // รายละเอียดที่กรอกไม่ซ้ำที่นี่: แผงซ้ายแสดงอยู่แล้ว
                  ],
                ),
              ),
              // ไม่มีลูกศร: เข้าหน้ากรอกจากแถวในแบบร่างฝั่งซ้าย
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
                          color: on
                              ? (locked ? _ink3 : _blue)
                              : Colors.transparent,
                          border: Border.all(
                              color: on ? (locked ? _ink3 : _blue) : _g5,
                              width: 1.5),
                        ),
                        child: on
                            ? const _SolarIcon('ph-check',
                                size: 14.0, color: Colors.white)
                            : null,
                      ))),
            ]),
          ),
        ),
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

/// ชื่อชุดของใบเปล่า (สั่งเองไม่ใช้เทมเพลต)
const String _soCustom = '__custom__';

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
    final doc = _soLinesOf(_template);
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
      if (_soDocs[_template] == null && _template != _soCustom)
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
    final live = _soDeckItems();
    // เปิดแบบร่างครั้งแรก: รายการที่มีอยู่แล้วไม่เล่น appear (เล่นเฉพาะที่เพิ่มทีหลัง)
    if (!_soSeenReady) {
      for (final x in live) {
        _soSeenAt[x.id] = DateTime(2000);
      }
      _soSeenReady = true;
    }
    // ยกเลิกติ๊กแล้ว = ลืม (ติ๊กกลับมาเล่น appear อีกครั้ง) · ดูจากรายการที่ติ๊กจริง
    // (Progress Note ใช้ id "ชุด|หัวข้อ" ไม่อยู่ใน _orderPicked: ไม่แตะ)
    _soSeenAt
        .removeWhere((k, _) => !k.contains('|') && !_orderPicked.contains(k));
    // รายการใหม่ (ยังไม่เคยเห็น): ลงเวลาตอนนี้ แล้วสลับแท็บ folder ไปที่หัวข้อของรายการนั้น
    // (แถวในแท็บที่ไม่ได้เปิดยังไม่ถูกสร้าง จึงต้องเช็กที่นี่ ไม่ใช่ตอนสร้างแถว)
    final newly = [
      for (final x in live)
        if (!_soSeenAt.containsKey(x.id)) x
    ];
    if (newly.isNotEmpty) {
      final now = DateTime.now();
      for (final x in newly) {
        _soSeenAt[x.id] = now;
      }
      bool has(String sec) => live.any((x) => x.section == sec);
      final order = [
        if (_soPrev != null || has('Progress Note')) 'Progress Note',
        if (has('One Day')) 'One Day',
        if (has('Continuation')) 'Continuation',
      ];
      final t = order.indexOf(newly.last.section);
      if (t >= 0) _soDeckTab = t;
    }
    // ลบออก (ยกเลิกติ๊ก): เก็บแถวที่หายไว้เล่น disappear (เลื่อนหา + แสงแดง + หาย ≤ 1.6 วิ) ในตำแหน่งเดิม
    // แล้วสลับแท็บ folder ไปที่หัวข้อของรายการนั้น
    final now = DateTime.now();
    final liveIds = {for (final x in live) x.id};
    final gone = [
      for (final (i, x) in _soLastDeck.indexed)
        if (!liveIds.contains(x.id) && !_soLeaving.containsKey(x.id)) (i, x)
    ];
    for (final (i, x) in gone) {
      _soLeaving[x.id] = (x, i, now);
    }
    _soLeaving.removeWhere((k, v) =>
        liveIds.contains(k) || now.difference(v.$3).inMilliseconds > 1600);
    if (gone.isNotEmpty) {
      bool has(String sec) =>
          live.any((x) => x.section == sec) ||
          gone.any((g) => g.$2.section == sec);
      final order = [
        if (_soPrev != null || has('Progress Note')) 'Progress Note',
        if (has('One Day')) 'One Day',
        if (has('Continuation')) 'Continuation',
      ];
      final t = order.indexOf(gone.last.$2.section);
      if (t >= 0) _soDeckTab = t;
      // ล้างแถวที่เล่นจบแล้ว
      Future.delayed(const Duration(milliseconds: 1050), () {
        if (mounted) setState(() {});
      });
    }
    _soLastDeck = live;
    final items = [...live];
    for (final v in (_soLeaving.values.toList()..sort((a, b) => a.$2 - b.$2))) {
      items.insert(v.$2.clamp(0, items.length), v.$1);
    }
    // เลือกชุดแล้วแต่ยังไม่ติ๊ก: ยังเป็นแฟ้มมีแท็บ One Day | Continuation (แท็บว่างบอกในแท็บ)
    // ยังไม่มีรายการเลย: เปิดแท็บแรก (One Day) ไม่ค้างแท็บจากชุดก่อน
    if (items.isEmpty && _soPrev == null) _soDeckTab = 0;
    // แผงซ้าย = สรุปคำสั่ง ภาษาเดียวกับหน้าประวัติคำสั่งแพทย์ (หัว + แฟ้ม + ความคืบหน้า + การ์ดแยกแฟ้ม)
    // แตะแถว = แผงขวาเปิดหน้ากรอกรายละเอียดของรายการนั้น
    final done = items.where((x) => _soDone.contains(x.id)).length;
    // แบบร่างทุกรายการรอยืนยันอยู่แล้ว (หัวกลุ่มบอก 0/n): แสดงเฉพาะกำลังกรอก/ยืนยันแล้ว
    Widget status(_SoDeckItem it) {
      if (_soDone.contains(it.id)) {
        // เพิ่งยืนยัน (ไม่เกิน 2 วิ) = เล่น motion พร้อมแสงเขียวบนการ์ด · ที่เหลือแสดงนิ่ง
        final at = _soDoneAt[it.id];
        return _SoDoneBadge(
            key: ValueKey('done_${it.id}_$at'),
            style: _t(12.5, color: _green, weight: FontWeight.w600),
            fresh: at != null &&
                DateTime.now().difference(at) < const Duration(seconds: 2));
      }
      // ยังไม่ระบุ (วงเทา ดินสอนิ่ง) → กำลังกรอก (badge ฟ้า ดินสอเขียน)
      // แถวถูกสร้างใหม่ตอนเปิดหน้ากรอก → badge เล่น morph เองตอนสร้าง
      return _SoEditBadge(editing: _soEdit == it.id);
    }

    Widget row(_SoDeckItem it, bool first) => _gListRow(
          first: first,
          title: it.name,
          note: _soStat(it.id) ? 'ด่วน' : null,
          noteColor: _red,
          sub: switch (_soDetailLine(it)) {
            final l when l.isNotEmpty => l,
            _ => it.detail.isEmpty ? '-' : it.detail,
          },
          // สลับสถานะ (ต้องระบุ/กำลังกรอก → ยืนยันแล้ว) = จางไขว้นุ่ม ๆ
          trail: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (cur, prev) => Stack(
                alignment: Alignment.centerRight,
                children: [...prev, if (cur != null) cur]),
            child: KeyedSubtree(
                key: ValueKey(_soDone.contains(it.id)), child: status(it)),
          ),
          onTap: () => _soEditOpen(it.id),
        );

    // แถวในเธรด: ชื่อ + สถานะชิดบนบรรทัดเดียวกัน (เส้นโค้งเข้าที่บรรทัดชื่อเสมอ)
    // รายละเอียดใต้ชื่อเฉพาะที่มี · ไม่มีเส้นคั่น
    Widget leaf(_SoDeckItem it) {
      final line = switch (_soDetailLine(it)) {
        final l when l.isNotEmpty => l,
        _ => it.detail,
      };
      // ทุกรายการเป็นการ์ดเส้นขอบ 0.5 พื้นขาว
      // พื้น/ขอบอยู่ที่ Material ให้ ripple วาดบนพื้น
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
          // กำลังกรอก: ไม่เปลี่ยนพื้น (บอกด้วย badge ดินสอ + ชื่อสีกรมท่า)
          color: _panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            // เพิ่งยืนยัน: แสงเขียวกวาดจากขอบขวา (ใต้เนื้อหา)
            if (_soDone.contains(it.id))
              Positioned.fill(
                child: IgnorePointer(
                  child: _SoSuccessSweep(
                      key: ValueKey('sweep_${it.id}_${_soDoneAt[it.id]}'),
                      fresh: _soDoneAt[it.id] != null &&
                          DateTime.now().difference(_soDoneAt[it.id]!) <
                              const Duration(seconds: 2)),
                ),
              ),
            // ถูกลบ: แสงแดงกวาดจากขอบขวา ก่อนแถวหุบหาย (_SoAppear leaving)
            if (_soLeaving.containsKey(it.id))
              Positioned.fill(
                child: IgnorePointer(
                  child: _SoSuccessSweep(
                      key: ValueKey('sweep_del_${it.id}'),
                      color: _red,
                      fresh: true),
                ),
              ),
            InkWell(
              onTap: () => _soEditOpen(it.id),
              splashColor: _blue.withValues(alpha: 0.10),
              highlightColor: _blue.withValues(alpha: 0.04),
              splashFactory: InkRipple.splashFactory,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(TextSpan(
                                        style: _t(14.0,
                                            color: _soEdit == it.id
                                                ? _blue
                                                : _inkTitle,
                                            weight: FontWeight.w500),
                                        children: [
                                          // ป้าย STAT อยู่หน้าสุดของแถวป้ายยาด้านล่าง
                                          TextSpan(text: it.name),
                                        ])),
                                    if (_soCatsOf(it).first ==
                                        'Medication') ...[
                                      // ยา: ป้ายเฉพาะข้อมูลที่ชื่อยาไม่ได้บอก + timeline เมื่อระบุความถี่แล้ว
                                      // แถวป้าย (ซ้าย) + ครั้งถัดไปกี่โมง (ขวา)
                                      // ป้ายยา: มีการ์ดเส้นเวลา = ป้ายอยู่ในหัวการ์ด · ไม่มี (ยังไม่ระบุความถี่) = แถวป้ายตรงนี้
                                      if (_soMedTagsExtra(it) case final tags
                                          when tags.isNotEmpty &&
                                              !(_soStat(it.id) ||
                                                  _soFieldVal(
                                                          it, 'ความถี่ยา') !=
                                                      null)) ...[
                                        const SizedBox(height: 6.0),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Wrap(
                                                    spacing: 6.0,
                                                    runSpacing: 6.0,
                                                    children: [
                                                      for (final (ic, t)
                                                          in tags)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  6.0,
                                                                  3.0,
                                                                  8.0,
                                                                  3.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _panelSoft,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                          ),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(ic,
                                                                    size: 13.0,
                                                                    color:
                                                                        _ink3),
                                                                const SizedBox(
                                                                    width: 4.0),
                                                                Text(t,
                                                                    style: _t(
                                                                        12.0,
                                                                        color:
                                                                            _ink2,
                                                                        weight:
                                                                            FontWeight.w600)),
                                                              ]),
                                                        ),
                                                    ]),
                                              ),
                                            ]),
                                      ],
                                      // timeline การ์ดขาวเต็มความกว้าง อยู่ใต้แถวชื่อ (ไม่แบ่งที่กับป้ายสถานะ)
                                      if (_soStat(it.id) ||
                                          _soFieldVal(it, 'ความถี่ยา') != null)
                                        ...[]
                                      else ...[
                                        const SizedBox(height: 4.0),
                                        Text('ยังไม่ระบุความถี่',
                                            style: _t(12.0,
                                                color: _ink3,
                                                weight: FontWeight.w500)),
                                      ],
                                    ] else if (line.isNotEmpty) ...[
                                      const SizedBox(height: 2.0),
                                      Text(line,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: _t(12.5,
                                              color: _ink3,
                                              weight: FontWeight.w500)),
                                    ],
                                  ]),
                            ),
                            const SizedBox(width: 12.0),
                            Padding(
                                padding: EdgeInsets.zero,
                                // กำลังลบ (แสงแดง): badge "กรอกแล้ว" สีเขียวจางหาย ไม่ขัดกับแดง
                                child: AnimatedOpacity(
                                    opacity: _soLeaving.containsKey(it.id)
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 180),
                                    child: status(it))),
                          ]),
                      if ((_soCatsOf(it).first == 'Medication' ||
                              _soCatsOf(it).first == 'Procedure') &&
                          _soFreqOf(it) != null) ...[
                        const SizedBox(height: 8.0),
                        _soFreqTimeline(it, compact: true),
                      ],
                    ]),
              ),
            ),
          ]),
        ),
      );
    }

    // bare = อยู่ในตัว folder แท็บ (ไม่มีกรอบการ์ด ไม่มีหัวข้อ ชื่ออยู่บนแท็บแล้ว)
    Widget part(String title, String sub, List<_SoDeckItem> xs,
            {bool bare = false}) =>
        Container(
          margin: bare ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12.0),
          padding: bare
              ? EdgeInsets.zero
              : const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 6.0),
          decoration: bare
              ? null
              : BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!bare) ...[
              Row(children: [
                Expanded(
                  child: Text(title,
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                ),
                Text('${xs.length} รายการ',
                    style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              ]),
              const SizedBox(height: 2.0),
              Text(sub, style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            ],
            const SizedBox(height: 4.0),
            // จัดกลุ่มตามประเภทแบบแผงขวา · Progress Note ไม่แบ่ง
            if (title == 'Progress Note')
              for (final (i, it) in xs.indexed) row(it, i == 0)
            else
              for (final (cat, label, icon) in _soCatGroups)
                if ([
                  for (final x in xs)
                    if (_soCatsOf(x).first == cat) x
                ]
                    case final g when g.isNotEmpty)
                  // หัวข้อใหญ่แต่ละประเภท: ไม่มีกรอบการ์ด ไม่มีเส้นคั่น (ลดชั้นซ้อนใน folder) แยกด้วยระยะห่าง
                  // ข้างในแบบเธรดคอมเมนต์ (Reddit)
                  Container(
                    margin: EdgeInsets.only(
                        top: _soFirstCat(xs) == cat ? 0.0 : 22.0),
                    padding: EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
                    // ไอคอนประเภทใหญ่มุมขวาบน ปลายล่างฟุ้ง มุดหลังการ์ดใบแรก (แบบแผงขวา)
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        right: -2.0,
                        top: -6.0,
                        child: IgnorePointer(
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (r) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent
                              ],
                              stops: [0.0, 0.45, 0.85],
                            ).createShader(r),
                            child: Image.asset(icon, width: 52.0, height: 52.0),
                          ),
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // หัวประเภท: ชื่อ + "กรอกแล้ว x/x" ใต้ชื่อ
                            Row(children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(label,
                                        style: _t(14.0,
                                            color: _inkTitle,
                                            weight: FontWeight.w700)),
                                    Text(
                                        'กรอกแล้ว ${g.where((x) => _soDone.contains(x.id)).length}/${g.length}',
                                        style: _t(12.0,
                                            color: _ink3,
                                            weight: FontWeight.w500)),
                                  ]),
                              const Spacer(),
                            ]),
                            for (final (i, it) in g.indexed)
                              // รายการที่เพิ่งเพิ่มจากแผงขวา: กางออก + จางขึ้น + เลื่อนเข้าจากขวา (ครั้งเดียว)
                              _SoAppear(
                                key: ValueKey('so-ap-${it.id}'),
                                leaving: _soLeaving.containsKey(it.id),
                                // build ซ้ำหลายรอบในเฟรมเดียวได้: ใช้เวลาที่เห็นครั้งแรกแทน set
                                animate: DateTime.now()
                                        .difference(_soSeenAt.putIfAbsent(
                                            it.id, DateTime.now))
                                        .inMilliseconds <
                                    500,
                                child: IntrinsicHeight(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: 28.0,
                                          child: CustomPaint(
                                              painter: _SoTreeLine(
                                                  last: i == g.length - 1)),
                                        ),
                                        Expanded(child: leaf(it)),
                                      ]),
                                ),
                              ),
                          ]),
                    ]),
                  ),
          ]),
        );
    // ยา STAT ขึ้นบนสุดของแฟ้ม
    List<_SoDeckItem> sec(String s) => [
          for (final x in items)
            if (x.section == s && _soStat(x.id)) x,
          for (final x in items)
            if (x.section == s && !_soStat(x.id)) x
        ];
    return _clyInfoPage(
      'คำสั่งแพทย์',
      // บอกล่วงหน้าว่าตอนบันทึกจะลงชื่อแพทย์ผู้สั่ง (คนที่ล็อกอิน) พร้อมเวลา
      '${_template == _soCustom ? 'แบบร่าง ยังไม่ได้ส่งคำสั่ง สั่งเองไม่ใช้เทมเพลต' : 'แบบร่าง ยังไม่ได้ส่งคำสั่ง ชุด ${_setName(_template)}'}'
          '\nเมื่อบันทึก ระบบจะลงชื่อ ${ErSession.instance.user?.name ?? 'แพทย์ผู้สั่ง'} เป็นผู้สั่งพร้อมเวลา',
      'nurse_act',
      const [],
      by: '-',
      // แบบร่าง: ไม่มีภาพประกอบ (ผู้ใช้ขอเอาออก)
      showArt: false,
      // ไม่มีแถบครั้งที่: เว้นที่ให้แถบความคืบหน้าพ้นภาพแฟ้ม
      below: const SizedBox(height: 36.0),
      // ไม่มีแถว "ต้องระบุรายละเอียดอีก n รายการ" (ดูจากวงความคืบหน้าบนแท็บแทน)
      extra: [
        // folder เดียว 3 แท็บ: Progress Note | One Day | Continuation (แตะแท็บ = สลับเนื้อหา)
        _soDeckFolder([
          if (_soPrev != null || sec('Progress Note').isNotEmpty)
            (
              'Progress Note',
              null,
              () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_soPrev != null) _soPrevNote(),
                        if (sec('Progress Note') case final xs
                            when xs.isNotEmpty) ...[
                          if (_soPrev != null) const SizedBox(height: 12.0),
                          part('Progress Note', 'ประเมินตามเกณฑ์ของชุด', xs,
                              bare: true),
                        ],
                      ])
            ),
          // One Day / Continuation มีแท็บเสมอ · ยังไม่มีรายการ = ข้อความว่างในแท็บ
          if (sec('One Day') case final xs)
            (
              'One Day',
              xs.length,
              () => xs.isEmpty
                  ? _soDeckTabEmpty(
                      'เลือกรายการที่ทำครั้งเดียววันนี้ในหน้า One Day ทางขวา')
                  : part(
                      'One Day',
                      'ทำครั้งเดียวภายในวันนี้ เช่น เจาะเลือด ถ่ายภาพ ให้ยาครั้งเดียว',
                      xs,
                      bare: true)
            ),
          if (sec('Continuation') case final xs)
            (
              'Continuation',
              xs.length,
              () => xs.isEmpty
                  ? _soDeckTabEmpty(
                      'ถ้ามีคำสั่งที่ทำซ้ำ เพิ่มได้ในหน้า Continuation ทางขวา')
                  : part('Continuation',
                      'ทำซ้ำตามรอบเวลา จนกว่าแพทย์จะสั่งหยุด', xs,
                      bare: true)
            ),
        ]),
      ],
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
      _soDoneAt[it.id] = DateTime.now();
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
                _SolarIcon('ph-check', size: 12.0, color: it.tone),
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
                                    ? _soPill('กรอกแล้ว', _green,
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
                      : _soPill('กรอกแล้ว $done/${items.length}', _blue,
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
                          _soDoneAt[x.id] = DateTime.now();
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
                        ? const _SolarIcon('ph-check',
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
    'assets/images/er_os_proc_cap.png',
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

  /// รายการในแฟ้มเดียวกับที่กำลังกรอก เรียงตามแผงซ้าย (ประเภท → STAT ก่อน)
  /// footer หน้ากรอกใช้เลื่อนก่อนหน้า/ถัดไป ไม่ต้องกลับไปแตะทางซ้าย
  List<_SoDeckItem> _soEditSeq() {
    final it = _soEditItem;
    if (it == null) return const [];
    final xs = [
      for (final x in _soDeckItems())
        if (x.section == it.section && _soStat(x.id)) x,
      for (final x in _soDeckItems())
        if (x.section == it.section && !_soStat(x.id)) x,
    ];
    if (it.section == 'Progress Note') return xs;
    return [
      for (final (cat, _, _) in _soCatGroups)
        for (final x in xs)
          if (_soCatsOf(x).first == cat) x
    ];
  }

  bool get _soEditPrev =>
      _soEdit != null && _soEditSeq().indexWhere((x) => x.id == _soEdit) > 0;
  bool get _soEditNext {
    final seq = _soEditSeq();
    final i = seq.indexWhere((x) => x.id == _soEdit);
    return i >= 0 && i < seq.length - 1;
  }

  /// เลื่อนไปรายการก่อนหน้า (-1) / ถัดไป (+1) ในแฟ้มเดียวกัน · ถัดไป = ยืนยันใบนี้ก่อน
  Future<void> _soEditStep(int dir) async {
    final seq = _soEditSeq();
    final i = seq.indexWhere((x) => x.id == _soEdit);
    final j = i + dir;
    if (i < 0 || j < 0 || j >= seq.length) return;
    final id = _soEdit!;
    if (dir > 0 && !_soDone.contains(id)) {
      await _soEditSave();
      // ยกเลิกตอนเตือนแพ้ยา = อยู่ใบเดิม
      if (!mounted || !_soDone.contains(id)) return;
    }
    _soEditOpen(seq[j].id);
    if (dir < 0) setState(() => _formFwd = false);
  }

  /// แท็บแฟ้มที่ยังไม่มีรายการ: ข้อความสั้นกลางแท็บ บอกว่าเพิ่มได้ที่ไหน
  Widget _soDeckTabEmpty(String hint) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
        child: Column(children: [
          Text('ยังไม่มีรายการ',
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 4.0),
          Text(hint,
              textAlign: TextAlign.center,
              style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
        ]),
      );

  /// แฟ้มของรายการ: 0 Progress Note 1 One Day 2 Continuation
  int _soSecId(String section) => switch (section) {
        'Progress Note' => 0,
        'One Day' => 1,
        _ => 2,
      };

  GlobalKey get _soUsageKey =>
      _soUsageKeys.putIfAbsent(_soEdit ?? '', GlobalKey.new);
  GlobalKey get _soProcKey =>
      _soProcKeys.putIfAbsent(_soEdit ?? '', GlobalKey.new);

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
  Future<void> _soEditSave() async {
    final id = _soEdit;
    if (id == null) return;
    final it = _soEditItem;
    final med = it != null && _soCatsOf(it).first == 'Medication';
    // ยา: เช็กกับประวัติแพ้ยาก่อนยืนยัน
    if (med) {
      final hit = _soAllergyHit(it.name);
      if (hit != null) {
        final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: _panel,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: Text('ผู้ป่วยแพ้ $hit',
                    style: _t(17.0, color: _red, weight: FontWeight.w700)),
                content: Text(
                    '${it.name} อาจเป็นยาที่ผู้ป่วยแพ้ ตรวจสอบก่อนสั่ง',
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
                      child: Text('ยืนยันสั่ง',
                          style: _t(14.0,
                              color: Colors.white, weight: FontWeight.w600))),
                ],
              ),
            ) ??
            false;
        if (!ok || !mounted) return;
      }
    }
    HapticFeedback.lightImpact();
    if (it != null) _soStatTask(it, med && _soStat(id));
    setState(() {
      _soAi.remove(id);
      _soDone.add(id);
      _soDoneAt[id] = DateTime.now();
      _formFwd = false;
      _soEdit = null;
    });
  }

  /// ชื่อแพ้ยาที่ชนกับยานี้ (null = ไม่ชน) · กลุ่ม penicillin เทียบแบบเดียวกับ AI แนะนำ
  String? _soAllergyHit(String drug) {
    final d = drug.toLowerCase();
    const penicillins = [
      'piperacillin',
      'amoxicillin',
      'ampicillin',
      'cloxacillin',
      'penicillin'
    ];
    for (final a in _case.allergies) {
      final al = a.toLowerCase();
      final key = al.split(RegExp(r'[\s(]')).first;
      if (key.length >= 3 && d.contains(key)) return a;
      if (al.contains('penicillin') && penicillins.any(d.contains)) return a;
      if (al.contains('sulfa') &&
          (d.contains('sulfa') ||
              d.contains('bactrim') ||
              d.contains('co-trimoxazole'))) {
        return a;
      }
    }
    return null;
  }

  /// ยา STAT → งานด่วนของพยาบาล (ขึ้นบนสุดของงานที่ต้องติดตาม/การ์ดผังเตียง)
  /// เลิกติ๊ก STAT = เอางานออก
  void _soStatTask(_SoDeckItem it, bool on) {
    final hn = _caseP().hn;
    final title = 'ให้ยา STAT ${it.name}';
    final list = _taskExtra.putIfAbsent(hn, () => []);
    list.removeWhere((t) => t.title == title);
    if (!on) return;
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final how = _soDetailLine(it);
    list.add(_Task(title, how.isEmpty ? 'ให้ทันทีครั้งเดียว' : how,
        Icons.medication_rounded, _redHue, hm, _soStatTargetMin,
        urgent: true, by: ErSession.instance.user?.name ?? 'แพทย์'));
  }

  /// ค่าเริ่มของช่องจากบรรทัดในใบ เช่น "Cef3 2 g iv OD" → ขนาด 2 g · IV · OD
  String? _soGuess(_SoDeckItem it, String field) {
    final s = '${it.name} ${it.detail}';
    // ยา: ถอดจากบรรทัดในใบด้วยตัวแปลงเดียว (ชื่อเขียนได้หลายแบบ)
    if (_soCatsOf(it).first == 'Medication') {
      final rx = _soParseRx(it.name, it.detail);
      switch (field) {
        case 'ขนาดยา':
          return rx.dose;
        case 'หน่วย':
          return rx.unit;
        case 'หน่วยบรรจุ':
          return rx.pack ?? _soPackAuto(it);
        case 'ความถี่ยา':
          return _soStat(it.id) ? _soStatFreq : rx.freq;
        case 'เวลา':
          return rx.time;
        case 'จำนวน':
          return _soStat(it.id) ? (rx.qty ?? '1') : rx.qty;
        case 'วิธีใช้':
          return _soUsageAuto(it) ?? rx.usage;
        case 'ฉลากช่วย':
          return _soUsageAuto(it);
      }
    }
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
      case 'จำนวน':
        // ยา STAT ให้ครั้งเดียว: จำนวนเริ่ม 1
        return _soStat(it.id) ? '1' : null;
      case 'ความถี่ยา':
        final q =
            RegExp(r'q\s*(\d+)\s*(hr|h)\b', caseSensitive: false).firstMatch(s);
        if (q != null) return 'ทุก ${q.group(1)} ชั่วโมง';
        final f = RegExp(r'\b(OD|BID|TID|QID|prn|stat)\b', caseSensitive: false)
            .firstMatch(s);
        return switch (f?.group(1)?.toLowerCase()) {
          'od' => 'วันละ 1 ครั้ง',
          'bid' => 'วันละ 2 ครั้ง',
          'tid' => 'วันละ 3 ครั้ง',
          'qid' => 'วันละ 4 ครั้ง',
          'prn' => 'เมื่อมีอาการ',
          'stat' => _soStatFreq,
          _ => null,
        };
      case 'อัตราหยด':
        final m = RegExp(r'(\d+)\s*ml/hr', caseSensitive: false).firstMatch(s);
        return m?.group(1);
    }
    return null;
  }

  /// ช่องของแต่ละประเภท: (ชื่อช่อง, ตัวเลือก (ว่าง = พิมพ์), หน่วย)
  /// ฟอร์มสั่ง X-ray (ตามหน้า X-Ray Request ของ HOSxP · ตัดท่า ประเภทเครื่อง จุดที่สั่ง)
  /// รายการ · ด้าน · ความเร่งด่วน · ห้อง | Clinical Information (จาก CC) · Clinical Diagnosis
  /// (จาก Diagnosis Text) · สภาพผู้ป่วย | แพทย์ผู้สั่ง · สั่งทำวันที่ | หมายเหตุ
  List<T> _soXrayForm<T>(_SoDeckItem it, T Function(String, Widget) sec) {
    final id = it.id;
    final hn = _caseP().hn;
    // เติมค่าเริ่มครั้งแรก (แก้ได้): CI = อาการสำคัญ · CDx = Diagnosis Text ของขั้นวินิจฉัย
    if (_soVal['$id|ci'] == null) {
      final cc = erCaseOf(hn).cc.trim();
      if (cc.isNotEmpty) _soVal['$id|ci'] = cc;
    }
    // สภาพผู้ป่วย: เลือกไว้ให้จากสภาพแรกรับ (เดินมา/รถนั่ง/เปลนอน) แก้ได้
    if (_soVal['$id|สภาพผู้ป่วย'] == null) {
      final c = erCaseOf(hn).condition.trim();
      if (c.isNotEmpty) _soVal['$id|สภาพผู้ป่วย'] = c;
    }
    if (_soVal['$id|cdx'] == null) {
      final dxStep = _steps.indexWhere((s) => s.$2 == 'วินิจฉัย');
      final dx = dxStep < 0 ? '' : (_filled[dxStep][_dxTextLabel] ?? '').trim();
      if (dx.isNotEmpty) _soVal['$id|cdx'] = dx;
    }
    String? v(String k) => switch (_soVal['$id|$k']) {
          final x? when x.trim().isNotEmpty => x,
          _ => null,
        };
    final by = v('by') ?? _soProcVal(it, 'by');
    Future<void> pickAt() async {
      final now = DateTime.now();
      final d = await _dtSheet(
          title: 'สั่งทำวันที่',
          sub: it.name,
          initial: now,
          first: now.subtract(const Duration(days: 1)),
          last: now.add(const Duration(days: 7)));
      if (d == null || !mounted) return;
      setState(() => _soVal['$id|at'] = _procAtText(d));
    }

    Widget text(String k, String hint) => Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: _soInput(it, k, '', hint: hint, lines: 2),
        );
    Widget label(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
          child:
              Text(t, style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
        );
    return [
      sec(
          'X-ray',
          Column(mainAxisSize: MainAxisSize.min, children: [
            _procRow('รายการ', v('xitem') ?? it.name, first: true,
                // แผ่น filter แบ่งตามชนิดการตรวจ (X-ray · CT · Ultrasound · หัวใจ)
                onTap: () {
              final all = _soMaster('er_order_item_xray');
              String kind(String n) {
                final l = n.toLowerCase();
                if (l.startsWith('ct')) return 'CT';
                if (l.contains('ultrasound') || l.startsWith('u/s')) {
                  return 'Ultrasound';
                }
                if (l.contains('ecg') || l.contains('echo')) return 'หัวใจ';
                return 'X-ray';
              }

              _soFilterSheet(
                title: 'รายการ X-ray',
                sub: it.name,
                cats: [
                  for (final k in const ['X-ray', 'CT', 'Ultrasound', 'หัวใจ'])
                    if ([
                      for (final n in all)
                        if (kind(n) == k) n
                    ]
                        case final xs when xs.isNotEmpty)
                      (k, xs),
                ],
                current: v('xitem') ?? it.name,
                onPick: (o) => setState(() => _soVal['$id|xitem'] = o),
              );
            }),
            // ด้าน (HOSxP) = ทิศที่รังสีผ่าน ไม่ใช่ซ้าย/ขวา: PA (ด้านหลัง) · AP (ด้านหน้า) · Lateral · Oblique
            // การ์ดตัวเลือก 2×2 มีภาพประกอบ (มองจากบน: ผู้ป่วยหันหน้าลง · ลำรังสีจากหลอด → แผ่นรับภาพ)
            const Divider(
                height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _soFieldLabel('ด้าน'),
                    ),
                    for (final row in const [
                      [('PA (ด้านหลัง)', 0.0), ('AP (ด้านหน้า)', math.pi)],
                      [
                        ('Lateral (ด้านข้าง)', -math.pi / 2),
                        ('Oblique (เฉียง)', -math.pi / 4)
                      ],
                    ]) ...[
                      Row(children: [
                        for (final (k, (t, a)) in row.indexed) ...[
                          if (k > 0) const SizedBox(width: 8.0),
                          Expanded(
                            child: _soOptTile(_soVal['$id|ด้าน'] == t, t, () {
                              HapticFeedback.selectionClick();
                              setState(() => _soVal['$id|ด้าน'] = t);
                            },
                                art: CustomPaint(
                                    painter: _XrViewPainter(a,
                                        on: _soVal['$id|ด้าน'] == t))),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 8.0),
                    ],
                  ]),
            ),
            _procRow('ความเร่งด่วน', v('ความเร่งด่วน'),
                placeholder: 'เลือก',
                onTap: () => _soPickSheet(it, 'ความเร่งด่วน', 'ความเร่งด่วน',
                    _soMaster('er_order_priority'))),
            _procRow('ห้อง', v('ห้อง'),
                placeholder: 'เลือกห้อง',
                onTap: () => _soPickSheet(it, 'ห้อง', 'ห้อง X-ray', const [
                      'ห้อง X-ray ER',
                      'ห้อง X-ray 1 (ทั่วไป)',
                      'ห้อง X-ray 2 (ทั่วไป)',
                      'ห้อง CT',
                      'ห้อง Ultrasound',
                      'ถ่ายข้างเตียง (Portable)',
                    ])),
          ])),
      sec(
          'ข้อมูลทางคลินิก',
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                label('Clinical Information'),
                text('ci', 'อาการสำคัญ/ข้อบ่งชี้'),
                label('Clinical Diagnosis'),
                text('cdx', 'การวินิจฉัย'),
                _procRow('สภาพผู้ป่วย', v('สภาพผู้ป่วย'),
                    first: true,
                    sub: v('สภาพผู้ป่วย') != null &&
                            v('สภาพผู้ป่วย') == erCaseOf(hn).condition.trim()
                        ? 'จากสภาพแรกรับ'
                        : null,
                    placeholder: 'เลือก',
                    onTap: () => _soPickSheet(it, 'สภาพผู้ป่วย', 'สภาพผู้ป่วย',
                        _soMaster('er_patient_condition'))),
              ])),
      sec(
          'ผู้สั่ง',
          Column(mainAxisSize: MainAxisSize.min, children: [
            _procRow('แพทย์ผู้สั่ง', by,
                first: true,
                faces: by == null ? null : _procFaces([by]),
                placeholder: 'เลือกแพทย์',
                onTap: () =>
                    _soPickSheet(it, 'by', 'แพทย์ผู้สั่ง', _dxDoctors)),
            _procRow('สั่งทำวันที่', _soProcVal(it, 'at'),
                placeholder: 'เลือกวันเวลา', onTap: pickAt),
          ])),
    ];
  }

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
    // ความถี่กำหนดเอง: "ทุก N หน่วย"
    if (f == 'ความถี่ยา' && _soVal['${it.id}|freqCustom'] == '1') {
      final n = (_soVal['${it.id}|freqN'] ?? '').trim();
      final u = _soVal['${it.id}|freqU'] ?? 'ชั่วโมง';
      return n.isEmpty ? null : 'ทุก $n $u';
    }
    final v = _soVal['${it.id}|$f'];
    if (v != null) return v.isEmpty ? null : v;
    return _soGuess(it, f);
  }

  /// บรรทัดสรุปค่าที่กรอก (ใช้ในการ์ดสรุปฝั่งซ้าย)
  /// บรรทัดสรุป (มี cache): คำนวณจริงช้า (~8ms/รายการ เดาค่าจากชื่อยา/master)
  /// cache ตามค่าที่กรอกของรายการนั้น + STAT · ค่าที่กรอกเปลี่ยน = คำนวณใหม่
  String _soDetailLine(_SoDeckItem it) {
    final pre = '${it.id}|';
    final sig = Object.hashAll([
      _soStat(it.id),
      _template,
      for (final e in _soVal.entries)
        if (e.key.startsWith(pre)) Object.hash(e.key, e.value),
    ]);
    final hit = _soDetailCache[it.id];
    if (hit != null && hit.$1 == sig) return hit.$2;
    final v = _soDetailLineRaw(it);
    _soDetailCache[it.id] = (sig, v);
    return v;
  }

  String _soDetailLineRaw(_SoDeckItem it) {
    if (it.section == 'Progress Note') return '';
    if (_soCatsOf(it).first == 'Procedure') {
      final code = _FeaturesWorkflowProcPart(this)
          ._icd9Codes[_soProcVal(it, 'icd') ?? ''];
      final doers = _soProcLines(it, 'doer');
      final fq = _soVal['${it.id}|freqCustom'] == '1'
          ? _soFieldVal(it, 'ความถี่ยา')
          : _soProcVal(it, 'freq');
      return [
        if (fq != null) fq,
        if (code != null) 'ICD-9-CM $code',
        if (doers.isNotEmpty)
          'ผู้ทำ ${_procPersonName(doers.first)}${doers.length > 1 ? ' และอีก ${doers.length - 1} คน' : ''}',
      ].join('  ');
    }
    if (_soCatsOf(it).first == 'Medication') {
      String? v(String f) => _soFieldVal(it, f);
      final dose = _soMedMode(it) == 2
          ? v('วิธีใช้')
          : [
              for (final f in const ['ขนาดยา', 'หน่วย', 'ความถี่ยา', 'เวลา'])
                if (v(f) case final x?) x,
            ].join(' ');
      return [
        if (dose != null && dose.isNotEmpty) dose,
        if (v('จำนวน') case final n?) '$n ${v('หน่วยบรรจุ') ?? ''}'.trim(),
      ].join('  ');
    }
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
              setState(() {
                _soVal['${it.id}|$f'] = cur == o ? '' : o;
                // ฉลากช่วย: เติมข้อความลงช่องวิธีใช้ให้แก้ต่อได้
                if (f == 'ฉลากช่วย' && cur != o) {
                  _soVal['${it.id}|วิธีใช้'] = o;
                  _soNoteRev++;
                }
              });
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
  /// หน้ากรอกรายละเอียด + ท้ายหน้า "ลบคำสั่งนี้" (เฉพาะรายการที่ยืนยันแล้ว)
  /// action รองแบบตัวอักษรแดงท้ายเนื้อหา ไม่แย่งปุ่มหลักใน footer (P9)
  Widget _soEditPage(_SoDeckItem it) {
    final body = _soEditBody(it);
    if (!_soDone.contains(it.id)) return body;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          const SizedBox(height: 4.0),
          Center(
            child: TextButton.icon(
              onPressed: () => _soDeleteOrder(it),
              style: TextButton.styleFrom(
                foregroundColor: _red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18.0),
              label: Text('ลบคำสั่งนี้',
                  style: _t(14.0, color: _red, weight: FontWeight.w600)),
            ),
          ),
        ]);
  }

  /// ลบคำสั่งที่ยืนยันแล้วออกจากแบบร่าง (ยืนยันก่อน) แล้วกลับรายการ
  Future<void> _soDeleteOrder(_SoDeckItem it) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _panel,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text('ลบคำสั่งนี้?',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            content: Text(
                '${it.name} จะถูกเอาออกจากแบบร่าง รายละเอียดที่กรอกไว้จะหายไปด้วย',
                style: _t(13.5, color: _ink2, weight: FontWeight.w500)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('ยกเลิก',
                      style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
              FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _red),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('ลบคำสั่ง',
                      style: _t(14.0,
                          color: Colors.white, weight: FontWeight.w600))),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      for (final f in _soFolders()) {
        f.$4
          ..remove(it.id)
          ..remove('${f.$5}${it.name}');
      }
      _orderPicked.remove(it.id);
      _soPnPick.remove(it.id);
      _soDone.remove(it.id);
      _soDoneAt.remove(it.id);
      _soAi.remove(it.id);
      _soVal.removeWhere((k, _) => k.startsWith('${it.id}|'));
      _formFwd = false;
      _soEdit = null;
    });
  }

  Widget _soEditBody(_SoDeckItem it) {
    final pn = it.section == 'Progress Note';
    final cat = _soCatsOf(it).first;
    const cats = [
      ('Lab', 'Lab', 'assets/images/er_os_lab.png'),
      ('X-ray', 'X-ray', 'assets/images/er_os_xray.png'),
      ('Medication', 'การให้ยา', 'assets/images/er_os_med.png'),
      ('Procedure', 'หัตถการ', 'assets/images/er_os_proc_cap.png'),
      ('Other', 'อื่น ๆ', 'assets/images/er_os_other.png'),
    ];
    final art = cats.firstWhere((c) => c.$1 == cat, orElse: () => cats.last);
    final blanks = _soBlanks[it.id] ?? const <(String, String)>[];
    // หัตถการ: หน้าตาเดียวกับเมนูหัตถการ (การ์ดขาวแยกส่วน · หัวข้อ 16 หนา ·
    // รายละเอียดเป็นหัวข้อ + ช่องพิมพ์ไม่มีการ์ดครอบ) ไม่ใช้การ์ดรวมที่มีภาพประกอบ
    // ทุกประเภท (ยกเว้น Progress Note): หัวรายการ + hero นอกการ์ด · ส่วนต่าง ๆ เป็นการ์ดขาวแยก
    if (!pn) {
      Widget card(String title, Widget child) => Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 6.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                    child: Text(title,
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  child,
                ]),
          );
      // ช่องในการ์ด: หัวช่อง + ตัวเลือก/ช่องพิมพ์ (ห่างขอบการ์ด 16 เท่าหัวการ์ด)
      Widget field(String label, Widget child) => Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_soFieldLabel(label), child]),
          );
      final parts = cat == 'Medication'
          ? _soMedForm<(String, Widget)>(it, (t, w) => (t, w))
          : cat == 'Procedure'
              ? _soProcForm<(String, Widget)>(it, (t, w) => (t, w))
              : cat == 'X-ray'
                  ? <(String, Widget)>[
                      ..._soXrayForm<(String, Widget)>(it, (t, w) => (t, w)),
                      (
                        'หมายเหตุ',
                        _soInput(it, 'note', '',
                            hint: 'ไม่บังคับ', lines: 2, note: true)
                      ),
                    ]
                  : <(String, Widget)>[
                      // Lab / X-ray / อื่น ๆ: ช่องตามประเภท · ค่าในใบ · หมายเหตุ
                      (
                        it.name,
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ไม่มีช่อง "รายละเอียด" (พิมพ์อิสระ) ซ้ำกับหมายเหตุ: ใช้หมายเหตุช่องเดียว
                              for (final (f, opts, unit) in _soFieldsOf(it)
                                  .where((x) => x.$1 != 'รายละเอียด'))
                                // ความถี่: แถวเลือกแบบหัตถการ (แผ่นตัวเลือก + กำหนดเอง "ทุก N หน่วย")
                                if (f == 'ความถี่')
                                  Padding(
                                    // แถวมี padding ในตัว (แบบการ์ดหัตถการ): ไม่เว้นข้างซ้ำ
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _procRow(
                                              'ความถี่',
                                              _soVal['${it.id}|freqCustom'] ==
                                                      '1'
                                                  ? (_soFieldVal(
                                                          it, 'ความถี่ยา') ??
                                                      'กำหนดเอง')
                                                  : _soFieldVal(it, f),
                                              first: true,
                                              placeholder: 'เลือกความถี่',
                                              onTap: () => _soPickSheet(
                                                      it, f, 'ความถี่', [
                                                    ...{
                                                      ...opts,
                                                      ..._soMaster(
                                                          'er_drug_frequency'),
                                                    },
                                                    _soFreqCustom
                                                  ])),
                                          if (_soVal['${it.id}|freqCustom'] ==
                                              '1')
                                            ..._soEveryRows(it),
                                        ]),
                                  )
                                else
                                  field(
                                      f,
                                      opts.isEmpty
                                          ? _soInput(it, f, unit,
                                              hint: switch (f) {
                                                'อัตราหยด' => 'เช่น 80',
                                                'ตำแหน่ง' => 'เช่น หลังมือซ้าย',
                                                _ => 'พิมพ์',
                                              })
                                          : _soChips(it, f, opts)),
                            ])
                      ),
                      if (blanks.isNotEmpty)
                        (
                          'ค่าในใบ',
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final (label, unit) in blanks)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(children: [
                                      Expanded(
                                        child: Text(label,
                                            style: _t(13.0,
                                                color: _ink2,
                                                weight: FontWeight.w500)),
                                      ),
                                      _soBox(it.id, label, unit),
                                    ]),
                                  ),
                              ],
                            ),
                          )
                        ),
                      (
                        'หมายเหตุ',
                        _soInput(it, 'note', '',
                            hint: 'ไม่บังคับ', lines: 2, note: true)
                      ),
                    ];
      // hero ตามประเภท: ยา = ขวด · หัตถการ = หมวกพยาบาล · อื่น ๆ = ภาพของประเภท
      final heroW = switch (cat) {
        'Medication' => 60.0,
        'Procedure' => 84.0,
        _ => 60.0,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, (t, w)) in parts.indexed)
            // ชื่อรายการ = หัวข้อนอกการ์ด + hero (ยา: การ์ดแรกชื่อยา · หัตถการ: ก่อนการ์ดแรก)
            if (t == it.name ||
                (i == 0 && (cat == 'Procedure' || cat == 'X-ray'))) ...[
              // hero: รูปประเภท (ขวดยา/หัตถการ) ใหญ่ขวา ปลายล่างฟุ้ง มุดหลังการ์ดถัดไป
              Stack(clipBehavior: Clip.none, children: [
                Positioned(
                  right: 12.0,
                  top: -6.0,
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent
                        ],
                        stops: [0.0, 0.5, 0.9],
                      ).createShader(r),
                      // หัตถการ = หมวกพยาบาล ชุดเดียวกับไอคอนหมวดหัตถการ (Figma 682:460)
                      child: Image.asset(art.$3, width: heroW, height: 60.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 2.0, heroW + 16.0, 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.name,
                            style: _t(18.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        // คำอธิบายจากใบ standing order (เช่น เงื่อนไขการให้) ใต้ชื่อ
                        if (it.detail.isNotEmpty &&
                            cat != 'Medication' &&
                            cat != 'Procedure')
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(it.detail,
                                style: _t(13.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ),
                      ]),
                ),
              ]),
              // ยา: การ์ดประเภทการสั่งยา · หัตถการ: การ์ดแรกตามหัวเดิม · อื่น ๆ: รายละเอียดคำสั่ง
              card(
                  switch (cat) {
                    'Medication' => 'ประเภทการสั่งยา',
                    'Procedure' || 'X-ray' => t,
                    _ => 'รายละเอียดคำสั่ง',
                  },
                  w),
            ] else if (t == 'รายละเอียด' || t == 'หมายเหตุ') ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 8.0),
                child: Text(t,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Padding(padding: const EdgeInsets.only(left: 4.0), child: w),
            ] else
              card(t, w),
        ],
      );
    }
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
            // ประเภทมาจากรหัสในใบ standing order (ไม่ให้เลือกเอง)
            if (cat == 'Medication')
              ..._soMedForm(it, sec)
            else if (cat == 'Procedure')
              ..._soProcForm(it, sec)
            else
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
            // ยาใช้เฉพาะช่องตามแบบใบสั่งยา (ไม่มีค่าในใบ/หมายเหตุ)
            if (blanks.isNotEmpty && cat != 'Medication')
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
          if (pn || (cat != 'Medication' && cat != 'Procedure'))
            sec(
                'หมายเหตุ',
                _soInput(it, 'note', '',
                    hint: 'ไม่บังคับ', lines: 2, note: true)),
        ],
      ),
    );
  }

  /// ช่องเลือกแบบ dropdown (ตามแบบใบสั่งยา): พื้นเทาอ่อน ลูกศรขวา · เมนูกว้างเท่าช่อง ติ๊กตัวที่เลือก
  Widget _soSelect(_SoDeckItem it, String f, String hint, List<String> opts) {
    final cur = _soFieldVal(it, f);
    return LayoutBuilder(
      builder: (context, box) => PopupMenuButton<String>(
        tooltip: '',
        position: PopupMenuPosition.under,
        constraints:
            BoxConstraints(minWidth: box.maxWidth, maxWidth: box.maxWidth),
        color: _panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        onSelected: (o) {
          HapticFeedback.selectionClick();
          setState(() {
            // ความถี่: "กำหนดเอง" เปิดช่องพิมพ์ทุก N นาที/ชั่วโมง/วัน
            if (o == _soFreqCustom) {
              _soVal['${it.id}|freqCustom'] = '1';
              return;
            }
            if (f == 'ความถี่ยา') _soVal['${it.id}|freqCustom'] = '';
            _soVal['${it.id}|$f'] = o;
            // ฉลากช่วย: เติมข้อความลงช่องวิธีใช้ให้แก้ต่อได้
            if (f == 'ฉลากช่วย') {
              _soVal['${it.id}|วิธีใช้'] = o;
              _soNoteRev++;
            }
          });
        },
        itemBuilder: (_) => [
          for (final o in opts)
            PopupMenuItem<String>(
              value: o,
              height: 44.0,
              child: Row(children: [
                Expanded(
                  child: Text(o,
                      style: _t(13.5,
                          color: o == cur ? _blue : _inkTitle,
                          weight:
                              o == cur ? FontWeight.w600 : FontWeight.w500)),
                ),
                if (o == cur)
                  const _SolarIcon('ph-check', size: 18.0, color: _blue),
              ]),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(children: [
            Expanded(
              child: Text(cur ?? hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0,
                      color: cur == null ? _ink3 : _inkTitle,
                      weight: FontWeight.w500)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20.0, color: _ink2),
          ]),
        ),
      ),
    );
  }

  static const _soStatFreq = 'ทันที (ครั้งเดียว)';
  static const _soFreqCustom = 'กำหนดเอง';

  /// ตัวเลือกท้ายรายการฉลากยา: พิมพ์วิธีใช้เอง
  static const _soUsageCustom = 'ระบุเอง';

  /// ช่องพิมพ์ที่เก็บค่าตรง ๆ (ไม่เติมจากใบ) · พิมพ์แล้ววาด timeline ใหม่
  Widget _soInputRaw(_SoDeckItem it, String f, {String hint = ''}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextFormField(
          key: ValueKey('${it.id}|$f|$_soNoteRev'),
          initialValue: _soVal['${it.id}|$f'],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => setState(() => _soVal['${it.id}|$f'] = v),
          style: _num(14.0, color: _inkTitle, weight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: hint,
            hintStyle: _t(13.0, color: _ink3, weight: FontWeight.w500),
          ),
        ),
      );

  /// เวลาให้ยาใน 24 ชม. ข้างหน้า ตามความถี่ + เวลา (มื้อ/ก่อนนอน)
  /// (เวลาทั้งหมด, prn) · STAT = ตอนนี้ครั้งเดียว · prn = ไม่มีเวลาตายตัว
  /// ความถี่ที่ใช้คิดรอบเวลา: ยา = ความถี่ยา · หัตถการ = ช่องความถี่ (ครั้งเดียว = ไม่มีรอบ)
  String? _soFreqOf(_SoDeckItem it) {
    if (_soStat(it.id)) return _soStatFreq;
    if (_soCatsOf(it).first == 'Procedure' &&
        _soVal['${it.id}|freqCustom'] != '1') {
      final f = _soProcVal(it, 'freq');
      return f == null || f.isEmpty || f == 'ครั้งเดียว' ? null : f;
    }
    return _soFieldVal(it, 'ความถี่ยา');
  }

  (List<DateTime>, bool) _soDoseTimes(_SoDeckItem it) {
    final now = DateTime.now();
    final freq = _soFreqOf(it);
    final time = _soFieldVal(it, 'เวลา') ?? '';
    if (freq == null) return (const [], false);
    if (freq == _soStatFreq) return ([now], false);
    if (freq == 'เมื่อมีอาการ') return (const [], true);
    final end = now.add(const Duration(hours: 24));
    // ทุก N นาที/ชั่วโมง/วัน: นับจากตอนนี้
    final every =
        RegExp(r'ทุก\s*(\d+(?:\.\d+)?)\s*(นาที|ชั่วโมง|วัน)').firstMatch(freq);
    if (every != null) {
      final n = double.parse(every.group(1)!);
      final mins = (n *
              switch (every.group(2)) {
                'นาที' => 1,
                'วัน' => 1440,
                _ => 60,
              })
          .round();
      if (mins <= 0) return (const [], false);
      return (
        [
          for (var t = now;
              t.isBefore(end) && t.difference(now).inMinutes < 1440;
              t = t.add(Duration(minutes: mins)))
            t
        ].take(48).toList(),
        false
      );
    }
    // วันละ k ครั้ง / ก่อนนอน: เวลามาตรฐานของหอผู้ป่วย (ตามมื้อถ้าระบุก่อน/หลังอาหาร)
    final k = int.tryParse(
            RegExp(r'วันละ\s*(\d)').firstMatch(freq)?.group(1) ?? '') ??
        (freq.contains('ก่อนนอน') ? 0 : 1);
    final ac = time.contains('ก่อนอาหาร');
    final pc = time.contains('หลังอาหาร');
    final hours = k == 0 || time.contains('ก่อนนอน')
        ? [21]
        : switch (k) {
            1 => time.contains('เย็น')
                ? [ac ? 17 : 18]
                : time.contains('กลางวัน')
                    ? [ac ? 11 : 13]
                    : [ac ? 7 : (pc ? 8 : 9)],
            2 => ac ? [7, 17] : (pc ? [8, 18] : [9, 21]),
            3 => ac ? [7, 11, 17] : (pc ? [8, 13, 18] : [6, 14, 22]),
            _ => [6, 12, 18, 24],
          };
    final out = <DateTime>[];
    for (var d = 0; d < 2; d++) {
      for (final h in hours) {
        final t =
            DateTime(now.year, now.month, now.day + d).add(Duration(hours: h));
        if (t.isAfter(now) && t.isBefore(end)) out.add(t);
      }
    }
    return (out, false);
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// ครั้งที่ให้ไปแล้ว (ยาที่ต่อจากคำสั่งเดิม): นับจากเวลาสั่งครั้งเดิม (เลยตอนนี้ = เมื่อวาน)
  /// ทุกรอบความถี่จนถึงตอนนี้ · รอบ = ระยะระหว่างครั้งถัดไปสองครั้ง (มีครั้งเดียว = วันละครั้ง)
  /// ผู้ทำ = พยาบาลในทีมของเคส (ข้อมูลจำลอง)
  List<(String, DateTime)> _soGivenDoses(_SoDeckItem it, List<DateTime> next) {
    final prev = _soPrev;
    if (prev == null || next.isEmpty) return const [];
    if (!prev.items.any((o) => o.$1 == it.name)) return const [];
    final p = prev.time.split(':');
    final now = DateTime.now();
    var start = DateTime(
        now.year, now.month, now.day, int.parse(p[0]), int.parse(p[1]));
    if (start.isAfter(now)) start = start.subtract(const Duration(days: 1));
    final gap = next.length > 1
        ? next[1].difference(next[0])
        : const Duration(hours: 24);
    final team = erCaseOf(_caseP().hn).team;
    final nurse = [
          for (final m in team)
            if (m.$2.startsWith('พย.')) m.$2
        ].firstOrNull ??
        'พย. วราภรณ์ สุขใจ';
    final out = <(String, DateTime)>[];
    for (var t = next.first.subtract(gap);
        !t.isBefore(start) && out.length < 3;
        t = t.subtract(gap)) {
      if (t.isBefore(now)) out.insert(0, (nurse, t));
    }
    return out;
  }

  /// แถบแบ่งช่วงของยา (สรุปซ้าย, ref ติดตามออเดอร์): หนึ่งช่องต่อหนึ่งครั้ง (ไม่เกิน 4)
  /// ให้แล้ว = แถบเต็ม + ชื่อผู้ให้ เวลา · ครั้งถัดไป = แถบเติมตามเวลาที่ผ่าน (ปุ่มกลมปลาย) + อีกกี่นาที
  /// ครั้งต่อไป = แถบเทา + เวลา
  /// แถบรอบ (ใช้ร่วม: สรุปยาในแบบร่าง · คำสั่งทำเป็นรอบในประวัติคำสั่ง)
  /// ทำแล้ว = แถบเขียว + ✓ เวลา + ผู้ทำ · ครั้งถัดไป = แถบคืบหน้า + เวลาหนา + อีกกี่นาที · ต่อไป = แถบว่าง
  Widget _soRoundTrack(List<(String, DateTime)> done, List<DateTime> up,
      {Color col = _blue}) {
    if (up.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    const track = Color(0xFFE3E6EC);
    String short(String who) => who.split(' ').take(2).join(' ');
    // ความคืบหน้าสู่ครั้งถัดไป: จากครั้งก่อน (หรือหนึ่งรอบก่อนครั้งถัดไป)
    final gap =
        up.length > 1 ? up[1].difference(up[0]) : const Duration(hours: 24);
    final prevT = done.isNotEmpty ? done.last.$2 : up.first.subtract(gap);
    final total = up.first.difference(prevT).inSeconds;
    final prog = total <= 0
        ? 1.0
        : (now.difference(prevT).inSeconds / total).clamp(0.0, 1.0);
    final mins = up.first.difference(now).inMinutes;
    String left() => mins <= 0
        ? 'ถึงเวลาแล้ว'
        : mins < 60
            ? 'อีก $mins นาที'
            : 'อีก ${mins ~/ 60} ชม. ${mins % 60} นาที';

    Widget bar(double v, {bool knob = false, Color? c0}) => SizedBox(
          height: 12.0,
          child: LayoutBuilder(builder: (context, c) {
            final x = c.maxWidth * v;
            return Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 3.0,
                height: 6.0,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: track,
                        borderRadius: BorderRadius.circular(100.0))),
              ),
              Positioned(
                left: 0.0,
                width: x,
                top: 3.0,
                height: 6.0,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: c0 ?? col,
                        borderRadius: BorderRadius.circular(100.0))),
              ),
              if (knob)
                Positioned(
                  left: (x - 6.0).clamp(0.0, c.maxWidth - 12.0),
                  top: 0.0,
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    decoration:
                        BoxDecoration(color: col, shape: BoxShape.circle),
                  ),
                ),
            ]);
          }),
        );

    // ใต้แถบ: เวลาอย่างเดียว (ให้แล้ว = ติ๊กเขียว + ผู้ให้ · ถัดไป = ตัวหนา + อีกกี่นาที)
    Widget seg(Widget b, Widget title, String? sub) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            b,
            const SizedBox(height: 7.0),
            title,
            if (sub != null)
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
          ]),
        );
    Widget time(DateTime t, Color c, {bool bold = false, bool check = false}) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (check) ...[
            Icon(Icons.check_circle_rounded, size: 13.0, color: c),
            const SizedBox(width: 3.0),
          ],
          Text(_clock(_hm(t)),
              style: _t(12.0,
                  color: c, weight: bold ? FontWeight.w700 : FontWeight.w600)),
        ]);

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final (i, d) in done.indexed) ...[
        if (i > 0) const SizedBox(width: 6.0),
        seg(bar(1.0, c0: _green), time(d.$2, _green, check: true), short(d.$1)),
      ],
      for (final (k, t) in up.indexed) ...[
        if (done.isNotEmpty || k > 0) const SizedBox(width: 6.0),
        k == 0
            ? seg(bar(prog, knob: true), time(t, col, bold: true), left())
            : seg(bar(0.0), time(t, _ink3), null),
      ],
    ]);
  }

  Widget _soDoseSteps(_SoDeckItem it, List<DateTime> times) {
    final all = _soGivenDoses(it, times);
    final done = all.length > 2 ? all.sublist(all.length - 2) : all;
    final up = times.take(4 - done.length).toList();
    final col = _soStat(it.id) ? _red : _blue;

    // การ์ดเส้นขอบ 0.5: หัว = ความถี่ (ซ้าย) · ครั้งถัดไป (ขวา) · แถบแบ่งช่วง · เวลาใต้แถบ
    return Container(
      // ไม่มีกรอบ: อยู่ในการ์ดรายการแล้ว (ไม่ซ้อนกรอบ)
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // หัวการ์ด: ป้ายยา (ความถี่ จำนวน ฯลฯ) ซ้าย · ครั้งถัดไป ขวา
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              // ยา STAT: ป้าย STAT หน้าสุดของแถวป้าย
              if (_soStat(it.id)) _soStatBadge(chip: true),
              if (_soCatsOf(it).first == 'Medication')
                for (final (ic, t) in _soMedTagsExtra(it))
                  Container(
                    padding: const EdgeInsets.fromLTRB(6.0, 3.0, 8.0, 3.0),
                    decoration: BoxDecoration(
                      // พื้นจางกว่า _panelSoft (ป้ายไม่แย่งสายตา)
                      color: const Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      // ไอคอน Phosphor ชุดเดียวกับรางเมนู (ไม่มีในชุด = Material เดิม)
                      switch (ic) {
                        Icons.schedule_rounded => const _SolarIcon('ph-clock',
                            size: 13.0, color: _ink3, grow: 0.6),
                        // จำนวนที่เบิก: ยาฉีด (VIAL/AMP) = เข็มฉีดยา · อื่น ๆ = เม็ดยา
                        Icons.inventory_2_outlined => _SolarIcon(
                            RegExp(r'vial|amp|ขวด|หลอด', caseSensitive: false)
                                    .hasMatch(t)
                                ? 'ph-syringe'
                                : 'ph-pill',
                            size: 13.0,
                            color: _ink3,
                            grow: 0.6),
                        Icons.alt_route_rounded => const _SolarIcon('ph-path',
                            size: 13.0, color: _ink3, grow: 0.6),
                        Icons.medication_outlined => const _SolarIcon('ph-pill',
                            size: 13.0, color: _ink3, grow: 0.6),
                        Icons.restaurant_outlined => const _SolarIcon('ph-fork',
                            size: 13.0, color: _ink3, grow: 0.6),
                        _ => Icon(ic, size: 13.0, color: _ink3),
                      },
                      const SizedBox(width: 4.0),
                      Text(t,
                          style:
                              _t(12.0, color: _ink2, weight: FontWeight.w600)),
                    ]),
                  ),
            ]),
          ),
          if (_soNextDose(it) case final nx?) ...[
            const SizedBox(width: 8.0),
            nx,
          ],
        ]),
        // ให้ทันทีครั้งเดียว (STAT หรือความถี่ "ทันที"): ไม่มีแถบเวลา (ป้ายบอกแล้ว)
        if (!_soStat(it.id) && _soFieldVal(it, 'ความถี่ยา') != _soStatFreq) ...[
          const SizedBox(height: 10.0),
          _soRoundTrack(done, up, col: col),
        ],
      ]),
    );
  }

  /// "ครั้งถัดไป HH:MM น." ชิดขวาแถวป้ายยา · ให้ทันที/ยังไม่ระบุความถี่/prn = null
  Widget? _soNextDose(_SoDeckItem it) {
    final (times, prn) = _soDoseTimes(it);
    final stat =
        _soStat(it.id) || (_soFieldVal(it, 'ความถี่ยา') == _soStatFreq);
    // ให้ทันทีครั้งเดียว: ป้าย "ทันที (ครั้งเดียว)" บอกแล้ว เวลา "ตอนนี้" ไม่มีความหมาย = ไม่แสดง
    if (prn || stat || times.isEmpty) return null;
    final at = times.first;
    return Text.rich(TextSpan(children: [
      TextSpan(
          text: 'ครั้งถัดไป ',
          style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
      TextSpan(
          text: _clock(_hm(at)),
          style: _t(12.5, color: _blue, weight: FontWeight.w700)),
    ]));
  }

  /// timeline ความถี่: แถบ 24 ชม. จากตอนนี้ จุด = เวลาให้ยา จุดแรกเข้ม + เวลาครั้งถัดไป
  Widget _soFreqTimeline(_SoDeckItem it, {bool compact = false}) {
    final (times, prn) = _soDoseTimes(it);
    final now = DateTime.now();
    final stat =
        _soStat(it.id) || (_soFieldVal(it, 'ความถี่ยา') == _soStatFreq);
    final caption = prn
        ? 'ให้เมื่อมีอาการ ไม่มีเวลาตายตัว'
        : times.isEmpty
            ? 'ยังไม่ระบุความถี่'
            : stat
                ? 'ให้ทันที ${_clock(_hm(now))}'
                : 'ครั้งถัดไป ${_clock(_hm(times.first))}  ใน 24 ชม. ${times.length} ครั้ง';
    // ย่อ (สรุปซ้าย): ขั้นรอบภาษาเดียวกับหน้ารับคำสั่ง (วงเขียวติ๊ก = ให้แล้ว + ผู้ทำ เวลา
    // วงเส้นประ = ครั้งถัดไป · วงขาว = ครั้งต่อ ๆ ไป) · prn / ยังไม่ระบุ = ข้อความ
    if (compact) {
      if (prn || times.isEmpty) {
        return Text(caption,
            style: _t(11.5, color: _ink2, weight: FontWeight.w500));
      }
      return _soDoseSteps(it, times);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: compact ? 30.0 : 34.0,
        child: CustomPaint(
          painter: _SoTimelinePainter(
            now: now,
            times: times,
            prn: prn,
            stat: stat,
            labels: true,
            ink: _ink3,
            dot: stat ? _red : _blue,
          ),
        ),
      ),
      const SizedBox(height: 4.0),
      Text(caption,
          style:
              _t(compact ? 11.5 : 12.0, color: _ink2, weight: FontWeight.w500)),
    ]);
  }

  /// ป้ายยาในสรุปซ้ายที่ไม่ซ้ำกับชื่อ (เช่น "Tetanus toxoid 0.5 mL IM" ไม่ต้องมีป้าย ฉีด IM / 0.5 ml)
  List<(IconData, String)> _soMedTagsExtra(_SoDeckItem it) {
    String norm(String x) => x.toLowerCase().replaceAll(' ', '');
    final nm = norm(it.name);
    final routeInName =
        RegExp(r'\b(IM|IV|PO|SC|SL)\b', caseSensitive: false).hasMatch(it.name);
    return [
      for (final t in _soMedTags(it))
        if (t.$1 == Icons.alt_route_rounded
            ? !routeInName
            : !nm.contains(norm(t.$2)))
          t
    ];
  }

  /// ป้ายรายละเอียดยาในสรุปซ้าย: ทาง · ขนาด · ความถี่ · เวลา · จำนวน
  List<(IconData, String)> _soMedTags(_SoDeckItem it) {
    final rx = _soParseRx(it.name, it.detail);
    String? v(String f) => _soFieldVal(it, f);
    final route = switch (rx.route) {
      'PO' => 'รับประทาน',
      'IV' => rx.form == 'fluid' ? 'หยด IV' : 'ฉีด IV',
      'IM' => 'ฉีด IM',
      'SC' => 'ฉีด SC',
      'SL' => 'อมใต้ลิ้น',
      _ => null,
    };
    final freq = _soStat(it.id) ? _soStatFreq : v('ความถี่ยา');
    return [
      if (route != null) (Icons.alt_route_rounded, route),
      if (v('ขนาดยา') case final d?) (Icons.medication_outlined, d),
      if (freq != null) (Icons.schedule_rounded, freq),
      if (v('เวลา') case final t?) (Icons.restaurant_outlined, t),
      if (v('จำนวน') case final n?)
        (Icons.inventory_2_outlined, '$n ${v('หน่วยบรรจุ') ?? ''}'.trim()),
    ];
  }

  /// ตัวเลือกจาก master HOSxP (assets/jsons/er_master_data.json)
  List<String> _soMaster(String id) => _masterNames(id);

  /// ฉลากช่วย/ความถี่ที่เป็นรอบ (ใช้กับยา STAT ไม่ได้)
  bool _soIsRound(String? v) =>
      v != null && (v.contains('วันละ') || v.contains('ชั่วโมง'));

  /// ยา STAT (ติ๊กในฟอร์มยา)
  /// ยังไม่ติ๊กเอง = ดูจากชื่อในใบ (เช่น "Nicardipine 2.5 mg IV stat")
  bool _soStat(String id) => switch (_soVal['$id|STAT']) {
        '1' => true,
        '' => false,
        _ => _soParseRx(id, '').stat,
      };

  /// เวลาเป้าให้ยา STAT นับจากสั่ง (นาที) · knowledge.md ข้อ 59 (ค่าตั้งต้น รอยืนยันจาก รพ.)
  static const _soStatTargetMin = 30;

  /// หน่วยยา / หน่วยบรรจุ: รู้จากข้อมูลยาแล้ว = แสดงอย่างเดียว ไม่ต้องเลือก
  /// ไม่รู้ (ยาที่ชื่อไม่บอกรูปแบบ) = เลือกจาก master
  Widget _soUnitField(_SoDeckItem it, String f, String hint, String master) {
    final g = _soGuess(it, f);
    if (g == null) return _soSelect(it, f, hint, _soMaster(master));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(children: [
        Expanded(
          child: Text(g,
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w500)),
        ),
        Text('จากข้อมูลยา',
            style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
      ]),
    );
  }

  /// หัตถการในใบ → รายการใน master er_procedure (ชื่ออังกฤษในวงเล็บ / ชื่อไทย · EKG = ECG)
  ErMasterItem? _soProcMatch(String name) {
    // ชื่อในใบสั่ง (เช่น "ล้างแผล", "On ETT", "EKG 12 leads") → หัตถการใน master
    // เทียบทั้งชื่อไทยแต่ละท่อน ("ล้างแผล / ตัดเนื้อตาย") และคำอังกฤษในวงเล็บ · เลือกที่ตรงยาวสุด
    final n = name.toLowerCase().replaceAll('ekg', 'ecg');
    ErMasterItem? best;
    var score = 0;
    for (final m in _procMaster('er_procedure')) {
      final en = RegExp(r'\(([^)]*)\)').firstMatch(m.name)?.group(1) ?? '';
      final th = m.name.split('(').first;
      final keys = [
        for (final t in th.split('/'))
          if (t.trim().length >= 3) t.trim().toLowerCase(),
        ...en
            .toLowerCase()
            .split(RegExp(r'[^a-z&]+'))
            .where((w) => w.length >= 3 && w != 'tube'),
      ];
      for (final k in keys) {
        if (n.contains(k) && k.length > score) {
          best = m;
          score = k.length;
        }
      }
    }
    return best;
  }

  /// ค่าช่องหัตถการของรายการ: ที่กรอกแล้ว หรือค่าเริ่ม (ชื่อ/ICD จาก master · ผู้สั่ง = แพทย์ที่ login · เวลา = ตอนนี้)
  String? _soProcVal(_SoDeckItem it, String k) {
    final v = _soVal['${it.id}|$k'];
    if (v != null) return v.isEmpty ? null : v;
    final m = _soProcMatch(it.name);
    switch (k) {
      case 'proc':
        return m?.name ?? it.name;
      case 'icd':
        final code = '${m?.extra['icd9cm'] ?? ''}';
        if (code.isEmpty) return null;
        for (final x in _procMaster('er_icd9cm')) {
          if (x.code == code) return x.name;
        }
        return null;
      case 'at':
        return _procAtText(DateTime.now());
      // ความถี่จากชื่อในใบ (เช่น "DTX q 8 hr" → ทุก 8 ชั่วโมง) · ไม่บอก = ยังไม่เลือก
      case 'freq':
        return _soParseRx(it.name, it.detail).freq;
      case 'by':
        final me = ErSession.instance.user;
        if (me == null || ErSession.instance.role != ErRole.doctor) return null;
        final p = me.name.split(' ');
        final first = p.length > 1 ? p[1] : me.name;
        return _procMaster('er_doctor')
                .where((x) => x.name.contains(first))
                .map((x) => x.name)
                .firstOrNull ??
            me.name;
    }
    return null;
  }

  List<String> _soProcLines(_SoDeckItem it, String k) => [
        for (final x in (_soVal['${it.id}|$k'] ?? '').split('\n'))
          if (x.trim().isNotEmpty) x.trim()
      ];

  /// ฟอร์มหัตถการในใบสั่ง: ชุดเดียวกับเมนูหัตถการ (ชื่อ · ICD-9-CM · วันที่ทำ · ผู้สั่ง · ผู้ทำ/ผู้ช่วย · รายละเอียด)
  /// แถวแบบ _procRow · แตะ = sheet เลือกต่อเนื่อง (_listFlow) เหมือนเมนูหัตถการ
  List<T> _soProcForm<T>(_SoDeckItem it, T Function(String, Widget) sec) {
    final id = it.id;
    final proc = _soProcVal(it, 'proc');
    final icd = _soProcVal(it, 'icd');
    final code =
        icd == null ? null : _FeaturesWorkflowProcPart(this)._icd9Codes[icd];
    final doers = _soProcLines(it, 'doer');
    final assists = _soProcLines(it, 'assist');
    final by = _soProcVal(it, 'by');
    void put(String k, String v) => setState(() => _soVal['$id|$k'] = v);
    Future<void> flow(int from) {
      _ListStep st(String k, String table, String short,
              {Map<String, String>? codes,
              List<String>? opts,
              bool people = false,
              bool confirm = false}) =>
          // หัวแผ่น = ชื่อไทย (short) ไม่ใช่คีย์ภายใน (proc/icd/by)
          _ListStep(short, opts ?? [for (final x in _procMaster(table)) x.name],
              codes: codes,
              short: short,
              people: people,
              confirm: confirm,
              current: () => _soProcVal(it, k),
              apply: (o) {
                put(k, o);
                // เลือกหัตถการใหม่ = เติม ICD-9-CM ตาม master
                if (k == 'proc') {
                  final m = _procMaster('er_procedure')
                      .where((x) => x.name == o)
                      .firstOrNull;
                  final c = '${m?.extra['icd9cm'] ?? ''}';
                  for (final x in _procMaster('er_icd9cm')) {
                    if (x.code == c) put('icd', x.name);
                  }
                }
              });
      final steps = [
        st('proc', 'er_procedure', 'หัตถการ'),
        st('icd', 'er_icd9cm', 'ICD-9-CM',
            codes: _FeaturesWorkflowProcPart(this)._icd9Codes, confirm: true),
        st('by', 'er_doctor', 'ผู้สั่ง', opts: _dxDoctors, people: true),
        _ListStep('ผู้ทำและผู้ช่วย',
            [for (final x in _procMaster('er_staff')) x.name],
            short: 'ผู้ทำ',
            people: true,
            many: true,
            tags: const ['ผู้ทำ', 'ผู้ช่วย'],
            tagOf: (o) => _soProcLines(it, 'doer').contains(o)
                ? 'ผู้ทำ'
                : _soProcLines(it, 'assist').contains(o)
                    ? 'ผู้ช่วย'
                    : null,
            setTag: (o, t) => setState(() {
                  final d = _soProcLines(it, 'doer')..remove(o);
                  final a = _soProcLines(it, 'assist')..remove(o);
                  if (t == 'ผู้ทำ') d.add(o);
                  if (t == 'ผู้ช่วย') a.add(o);
                  _soVal['$id|doer'] = d.join('\n');
                  _soVal['$id|assist'] = a.join('\n');
                }),
            current: () => _soVal['$id|doer'],
            apply: (_) {}),
      ];
      return _listFlow(steps.sublist(from));
    }

    // ICD-9-CM: แผ่น filter แบ่งหมวดเดียวกับหัตถการ (หมวดจาก master er_procedure ที่ใช้รหัสนั้น)
    // หมวดแรก "แนะนำ" = รหัสของหัตถการที่เลือก · ปิดแผ่น = ข้าม · chain = ต่อไปผู้สั่ง/ผู้ทำ
    Future<void> icdSheet({bool chain = false}) async {
      final codes = _FeaturesWorkflowProcPart(this)._icd9Codes;
      final grp = <String, String>{};
      for (final x in _procMaster('er_procedure')) {
        grp.putIfAbsent(
            '${x.extra['icd9cm'] ?? ''}', () => '${x.extra['group']}');
      }
      String groupOf(String code) =>
          grp[code] ??
          (code.startsWith('87') || code.startsWith('88')
              ? 'diagnostic'
              : code.startsWith('99')
                  ? 'medication'
                  : 'other');
      final names = [for (final x in _procMaster('er_icd9cm')) x.name];
      final p = _soProcVal(it, 'proc');
      final pc =
          '${(_procMaster('er_procedure').where((x) => x.name == p).firstOrNull ?? _soProcMatch(p ?? it.name))?.extra['icd9cm'] ?? ''}';
      final rec = [
        for (final n in names)
          if (codes[n] == pc) n
      ];
      await _soFilterSheet(
        title: 'ICD-9-CM',
        sub: p ?? 'เลือกรหัสหัตถการ',
        cats: [
          if (rec.isNotEmpty) ('แนะนำ', rec),
          for (final g in {..._soProcGroups, 'other': 'อื่น ๆ'}.entries)
            (
              g.value,
              [
                for (final n in names)
                  if (groupOf(codes[n] ?? '') == g.key) n
              ]
            )
        ].where((c) => c.$2.isNotEmpty).toList(),
        current: _soProcVal(it, 'icd'),
        note: (o) => codes[o] ?? '',
        onPick: (o) => put('icd', o),
      );
      if (chain && mounted) {
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) await flow(2);
      }
    }

    Future<void> pickAt() async {
      final now = DateTime.now();
      final d = await _dtSheet(
          title: 'วันที่ทำ',
          sub: proc ?? it.name,
          initial: now,
          first: now.subtract(const Duration(days: 1)),
          last: now.add(const Duration(days: 7)));
      if (d == null || !mounted) return;
      put('at', _procAtText(d));
    }

    return [
      sec(
          'หัตถการ',
          Column(
              key: _soProcKeys.putIfAbsent(id, GlobalKey.new),
              mainAxisSize: MainAxisSize.min,
              children: [
                // ชื่อหัตถการ: แผ่น filter แบ่งหมวด (master group) · เลือกแล้วไปต่อ ICD-9-CM
                _procRow('ชื่อหัตถการ', proc,
                    first: true,
                    placeholder: 'เลือกหัตถการ',
                    onTap: () => _soFilterSheet(
                          title: 'หัตถการ',
                          sub: 'เลือกหัตถการที่สั่ง',
                          cats: [
                            for (final g in _soProcGroups.entries)
                              (
                                g.value,
                                [
                                  for (final x in _procMaster('er_procedure'))
                                    if ('${x.extra['group']}' == g.key) x.name
                                ]
                              )
                          ].where((c) => c.$2.isNotEmpty).toList(),
                          current: proc,
                          // "ทำแผล (Dressing)" → หัว "ทำแผล" · รอง "Dressing"
                          label: (o) => o.split(' (').first,
                          note: (o) => o.contains(' (')
                              ? o
                                  .substring(o.indexOf(' (') + 2)
                                  .replaceAll(')', '')
                              : '',
                          onPick: (o) {
                            put('proc', o);
                            final m = _procMaster('er_procedure')
                                .where((x) => x.name == o)
                                .firstOrNull;
                            final c = '${m?.extra['icd9cm'] ?? ''}';
                            for (final x in _procMaster('er_icd9cm')) {
                              if (x.code == c) put('icd', x.name);
                            }
                            Future.delayed(const Duration(milliseconds: 300),
                                () => icdSheet(chain: true));
                          },
                        )),
                _procRow('ICD-9-CM', icd,
                    lead: code, placeholder: 'เลือกรหัส', onTap: icdSheet),
                _procRow('วันที่ทำ', _soProcVal(it, 'at'),
                    placeholder: 'เลือกวันเวลา', onTap: pickAt),
                // ความถี่ (ทำซ้ำ เช่น DTX ทุก 8 ชม. · ทำแผลวันละ 2 ครั้ง) · ครั้งเดียว = ทันที
                _procRow(
                    'ความถี่',
                    _soVal['$id|freqCustom'] == '1'
                        ? (_soFieldVal(it, 'ความถี่ยา') ?? 'กำหนดเอง')
                        : _soProcVal(it, 'freq'),
                    placeholder: 'ครั้งเดียว',
                    onTap: () => _soPickSheet(it, 'freq', 'ความถี่',
                        [..._soMaster('er_drug_frequency'), _soFreqCustom])),
                if (_soVal['$id|freqCustom'] == '1') ..._soEveryRows(it),
              ])),
      sec(
          'ผู้ดูแลหัตถการ',
          Column(mainAxisSize: MainAxisSize.min, children: [
            _procRow('ผู้สั่ง', by,
                first: true,
                faces: by == null ? null : _procFaces([by]),
                placeholder: 'เลือกแพทย์',
                onTap: () => flow(2)),
            _procRow(
                'ผู้ทำ', doers.isEmpty ? null : _procPersonName(doers.first),
                placeholder: 'เลือกผู้ทำ',
                sub: doers.length > 1
                    ? 'และอีก ${doers.length - 1} คน'
                    : doers.isEmpty
                        ? null
                        : _procPersonRole(doers.first),
                faces: doers.isEmpty ? null : _procFaces(doers),
                onTap: () => flow(3)),
            if (assists.isNotEmpty)
              _procRow('ผู้ช่วย', _procPersonName(assists.first),
                  sub: assists.length > 1
                      ? 'และอีก ${assists.length - 1} คน'
                      : _procPersonRole(assists.first),
                  faces: _procFaces(assists),
                  onTap: () => flow(3)),
          ])),
      sec(
          'รายละเอียด',
          Container(
            constraints: const BoxConstraints(minHeight: 96.0),
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _line, width: 0.5),
            ),
            child: TextFormField(
              key: ValueKey('${it.id}|note|$_soNoteRev'),
              initialValue: _soNote[it.id],
              minLines: 3,
              maxLines: 8,
              onChanged: (v) => _soNote[it.id] = v,
              style: _t(15.0,
                  color: _inkTitle, weight: FontWeight.w500, height: 1.45),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'เช่น ทำแผลอุบัติเหตุบริเวณหัวเข่า',
                hintStyle: _t(14.0, color: _ink3),
              ),
            ),
          )),
    ];
  }

  /// วิธีใช้ยา: 2 = เขียนวิธีใช้ (ฉลากช่วย) · 3 = Dose / ความถี่ (ค่าเริ่ม 2 ตามแบบ HOSxP)
  int _soMedMode(_SoDeckItem it) => _soVal['${it.id}|mode'] == '3' ? 3 : 2;

  /// ฟอร์มสั่งยา (แบบหน้าสั่งยาของ HOSxP): ยา STAT · วิธีใช้ 2 โหมด · จำนวน + หน่วยบรรจุ
  /// เลือกค่าช่องยา (ใช้ร่วม dropdown / sheet): กำหนดเอง · ฉลากช่วยเติมวิธีใช้
  void _soPick(_SoDeckItem it, String f, String o) {
    HapticFeedback.selectionClick();
    // ฉลากยา "ระบุเอง": พิมพ์วิธีใช้เองในหน้าต่าง
    if (f == 'ฉลากช่วย' && o == _soUsageCustom) {
      Future.delayed(
          const Duration(milliseconds: 250), () => _soUsageWrite(it));
      return;
    }
    setState(() {
      // ความถี่ทุกประเภท (ยา 'ความถี่ยา' · หัตถการ 'freq' · อื่น ๆ 'ความถี่') ใช้ "ทุก N หน่วย" ชุดเดียวกัน
      final freq = f == 'ความถี่ยา' || f == 'freq' || f == 'ความถี่';
      if (o == _soFreqCustom) {
        _soVal['${it.id}|freqCustom'] = '1';
        // ช่องที่ไม่ใช่ของยา: ล้างค่าที่เลือกไว้ แถวแสดง "ทุก N หน่วย" แทน
        if (f != 'ความถี่ยา') _soVal['${it.id}|$f'] = '';
        // กางช่อง "ทุก N" + เส้นเวลา: เลื่อนให้เห็นทั้งการ์ดวิธีใช้
        if (f == 'ความถี่ยา') _soReveal(_soUsageKey);
        if (f == 'freq') _soReveal(_soProcKey);
        return;
      }
      if (f == 'ความถี่ยา' || f == 'ฉลากช่วย') _soReveal(_soUsageKey);
      if (freq) _soVal['${it.id}|freqCustom'] = '';
      _soVal['${it.id}|$f'] = o;
      if (f == 'ฉลากช่วย') {
        _soVal['${it.id}|วิธีใช้'] = o;
        _soNoteRev++;
      }
    });
  }

  /// วิถีให้ยาจากชื่อยา (knowledge: HOSxP er_drug_route) · null = บอกไม่ได้
  /// ใช้ตัวแยกคำสั่งยาเดิม (PO IV IM SC SL) + รูปแบบยาที่บอกวิถี (หยอดตา พ่นจมูก ครีม เหน็บ ฯลฯ)
  String? _soDrugRoute(_SoDeckItem it) {
    final n = '${it.name} ${it.detail}'.toLowerCase();
    bool has(String re) => RegExp(re, caseSensitive: false).hasMatch(n);
    if (has(r'eye ?drop|ophth|หยอดตา|ป้ายตา|\be/d\b')) return 'EYE';
    if (has(r'ear ?drop|\botic\b|หยอดหู')) return 'EAR';
    if (has(r'nasal|พ่นจมูก|nose')) return 'NAS';
    if (has(r'\bneb|nebul|พ่นละออง')) return 'NEB';
    if (has(r'inhal|\bmdi\b|evohaler|accuhaler|พ่นสูด')) return 'INH';
    if (has(r'cream|ointment|\boint\b|\bgel\b|lotion|ครีม|ขี้ผึ้ง|ทา')) {
      return 'TOP';
    }
    if (has(r'supp|suppos|เหน็บ|\bpr\b')) return 'PR';
    if (has(r'\bng\b|ทางสาย')) return 'NG';
    final r = _soParseRx(it.name, it.detail).route;
    if (r != null) return r;
    if (has(r'\btab\b|\bcap\b|เม็ด|แคปซูล|syr|ยาน้ำ')) return 'PO';
    return null;
  }

  /// วิถีของฉลากยา (master er_drugusage มี route ต่อรายการ)
  String? _soUsageRoute(String label) {
    final m = ErMaster.maybe;
    if (m == null) return null;
    for (final t in m.tables) {
      if (t.id != 'er_drugusage') continue;
      for (final i in t.activeItems) {
        if (i.name == label) return i.extra['route'] as String?;
      }
    }
    return null;
  }

  /// ฉลากยาที่ใช้ได้กับยานี้: วิถีตรงกับชื่อยา · บอกวิถีไม่ได้ = ทุกฉลาก · STAT ตัดฉลากที่เป็นรอบ
  /// ท้ายรายการ = "ระบุเอง"
  List<String> _soUsageOptions(_SoDeckItem it, bool stat) {
    final r = _soDrugRoute(it);
    final all = [
      for (final o in _soMaster('er_drugusage'))
        if (!stat || !_soIsRound(o)) o
    ];
    final fit = r == null
        ? all
        : [
            for (final o in all)
              if (_soUsageRoute(o) == r) o
          ];
    return [...fit, _soUsageCustom];
  }

  /// หมวดของฉลาก: ครั้งเดียว · ตามรอบ · เมื่อมีอาการ (อ่านจากข้อความฉลาก)
  String _soUsageKind(String l) =>
      l.contains('ทันที') || l.contains('ครั้งเดียว')
          ? 'ครั้งเดียว'
          : l.contains('เมื่อ')
              ? 'เมื่อมีอาการ'
              : 'ตามรอบ';

  /// ฉลากแนะนำสำหรับยานี้ (สูงสุด 3): วิถีตรง + ความถี่/ชนิดในชื่อยาตรงกับข้อความฉลาก
  List<String> _soUsageRecommend(_SoDeckItem it, List<String> opts) {
    final rx = _soParseRx(it.name, it.detail);
    final want = rx.stat
        ? 'ครั้งเดียว'
        : rx.prn
            ? 'เมื่อมีอาการ'
            : rx.freq != null
                ? 'ตามรอบ'
                : null;
    int score(String o) {
      var sc = 0;
      if (rx.freq != null && o.contains(rx.freq!)) sc += 3;
      if (want != null && _soUsageKind(o) == want) sc += 2;
      return sc;
    }

    final ranked = [
      for (final o in opts)
        if (score(o) > 0) o
    ]..sort((a, b) => score(b) - score(a));
    return ranked.take(3).toList();
  }

  /// ฉลากยาที่เลือกให้จากชื่อยา (knowledge ข้อ 60): เลือกเฉพาะเมื่อมั่นใจ
  /// = วิถีตรง + ความถี่ในชื่อยาอยู่ในข้อความฉลาก + ชนิดตรง (STAT/PRN/ตามรอบ) และมีฉลากแบบนี้อันเดียว
  /// ฉลากที่เลือกให้จากชื่อยา (ขึ้นกับชื่อ/รายละเอียด + master) · cache ต่อรายการ
  String? _soUsageAuto(_SoDeckItem it) => _soUsageAutoCache.putIfAbsent(
      // ขึ้นกับ STAT และค่าที่กรอกของรายการด้วย (วิถีทาง ฯลฯ)
      '${it.name}\u0000${it.detail}\u0000${_soStat(it.id)}\u0000${Object.hashAll([
            for (final e in _soVal.entries)
              if (e.key.startsWith('${it.id}|')) Object.hash(e.key, e.value)
          ])}',
      () => _soUsageAutoRaw(it));

  String? _soUsageAutoRaw(_SoDeckItem it) {
    if (_soCatsOf(it).first != 'Medication') return null;
    final rx = _soParseRx(it.name, it.detail);
    final route = _soDrugRoute(it);
    if (route == null) return null;
    final stat = _soStat(it.id);
    final kind = stat
        ? 'ครั้งเดียว'
        : rx.prn
            ? 'เมื่อมีอาการ'
            : rx.freq != null
                ? 'ตามรอบ'
                : null;
    if (kind == null) return null;
    final hits = [
      for (final o in _soMaster('er_drugusage'))
        if (_soUsageRoute(o) == route &&
            _soUsageKind(o) == kind &&
            (stat || (rx.freq != null && o.contains(rx.freq!))))
          o
    ];
    return hits.length == 1 ? hits.first : null;
  }

  /// รายการ master ทั้งแถว (มี code / extra) ของตาราง id
  List<ErMasterItem> _soMasterItems(String id) {
    final m = ErMaster.maybe;
    if (m == null) return const [];
    for (final t in m.tables) {
      if (t.id == id) return t.activeItems;
    }
    return const [];
  }

  /// แผ่นเลือกฉลากยา: หมวด แนะนำ (จากชื่อยา) · ครั้งเดียว · ตามรอบ · เมื่อมีอาการ
  /// (บอกวิถีไม่ได้ = หมวดตามวิถี) · ท้าย = ระบุวิธีใช้เอง
  Future<void> _soUsageSheet(_SoDeckItem it, bool stat) {
    final opts = _soUsageOptions(it, stat)..remove(_soUsageCustom);
    final rec = _soUsageRecommend(it, opts);
    final route = _soDrugRoute(it);
    final routeName = {
      for (final i in _soMasterItems('er_drug_route')) i.code: i.name
    };
    final cats = <(String, List<String>)>[
      if (rec.isNotEmpty) ('แนะนำ', rec),
      if (route != null)
        for (final k in const ['ครั้งเดียว', 'ตามรอบ', 'เมื่อมีอาการ'])
          (
            k,
            [
              for (final o in opts)
                if (_soUsageKind(o) == k) o
            ]
          )
      else
        for (final r in routeName.keys)
          (
            routeName[r]!,
            [
              for (final o in opts)
                if (_soUsageRoute(o) == r) o
            ]
          ),
    ].where((c) => c.$2.isNotEmpty).toList();
    return _soFilterSheet(
      title: 'ฉลากยา',
      sub: route == null ? it.name : '${it.name}  ${routeName[route] ?? route}',
      cats: cats,
      current: _soFieldVal(it, 'ฉลากช่วย'),
      onPick: (o) => _soPick(it, 'ฉลากช่วย', o),
      customLabel: 'ระบุวิธีใช้เอง',
      onCustom: () => _soPick(it, 'ฉลากช่วย', _soUsageCustom),
    );
  }

  /// หมวดหัตถการ ER (master er_procedure.group) → ชื่อไทย
  static const _soProcGroups = {
    'wound': 'แผล',
    'resus': 'กู้ชีพ',
    'airway': 'ทางเดินหายใจ',
    'chest': 'ทรวงอก',
    'vascular': 'หลอดเลือด',
    'ortho': 'กระดูกและข้อ',
    'gi': 'ทางเดินอาหาร',
    'gu': 'ทางเดินปัสสาวะ',
    'medication': 'ให้ยา',
    'diagnostic': 'ตรวจวินิจฉัย',
  };

  /// แผ่นเลือกวันเวลา (แทน date/time picker ตั้งต้น): bottom sheet ย้ายได้ (_placedSheet)
  /// ปุ่มลัด (ตอนนี้ / อีก 30 นาที / อีก 1 ชม. / พรุ่งนี้ 08:00 น.) · ปฏิทินไทย พ.ศ. ซ้าย
  /// วงล้อชั่วโมง:นาทีขวา · แถวล่างสรุปวันเวลา + ปุ่มหลักเดียว "ใช้เวลานี้"
  /// เนื้อหาเลือกวันเวลา (ปุ่มลัด · ปฏิทินไทย พ.ศ. · วงล้อชั่วโมง:นาที · สรุป + "ใช้เวลานี้")
  /// ใช้ร่วม: แผ่นเลือกวันเวลา (_dtSheet) · หน้าย่อยในแผ่นรับคำสั่ง (กรอกเวลาเอง)
  Widget _dtPanel(_DtState st, void Function(void Function()) set,
      {required DateTime first,
      required DateTime last,
      required void Function(DateTime) onUse}) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', //
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    const days = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
    bool inRange(DateTime d) =>
        !dayOf(d).isBefore(dayOf(first)) && !dayOf(d).isAfter(dayOf(last));
    String hm(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    void jump(DateTime d) {
      set(() {
        st.sel = d;
        st.month = DateTime(d.year, d.month);
      });
      st.hc.animateToItem(d.hour,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic);
      st.mc.animateToItem(d.minute,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic);
    }

    final now = DateTime.now();
    final tm = DateTime(now.year, now.month, now.day + 1, 8);
    final quick = [
      ('ตอนนี้', now),
      ('อีก 30 นาที', now.add(const Duration(minutes: 30))),
      ('อีก 1 ชม.', now.add(const Duration(hours: 1))),
      ('พรุ่งนี้ ${_clock('08:00')}', tm),
      // ปุ่มลัดต้องอยู่ในช่วงจริง (เช่น บันทึกเวลาที่ทำ = ไม่เกินตอนนี้ ไม่มี "อีก 30 นาที")
    ].where((q) => inRange(q.$2) && !q.$2.isAfter(last)).toList();

    Widget chip(String t, DateTime d) {
      final on = hm(d) == hm(st.sel) && dayOf(d) == dayOf(st.sel);
      return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          jump(d);
        },
        borderRadius: BorderRadius.circular(100.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(
                color: on ? _blue : const Color(0xFFDADCE0), width: 0.5),
          ),
          child: Text(t,
              style: _t(13.5,
                  color: on ? Colors.white : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w600)),
        ),
      );
    }

    // ---- ปฏิทิน: หัวเดือน พ.ศ. + ‹ › · ตาราง 7 คอลัมน์ วันนอกช่วงจาง
    final firstWd = DateTime(st.month.year, st.month.month, 1).weekday % 7;
    final nDays = DateTime(st.month.year, st.month.month + 1, 0).day;
    final canPrev =
        !DateTime(st.month.year, st.month.month, 0).isBefore(dayOf(first));
    final canNext =
        !DateTime(st.month.year, st.month.month + 1, 1).isAfter(dayOf(last));
    Widget nav(IconData ic, bool ok, int dm) => IconButton(
          onPressed: ok
              ? () => set(
                  () => st.month = DateTime(st.month.year, st.month.month + dm))
              : null,
          icon: Icon(ic, size: 22.0, color: ok ? _ink2 : _g5),
        );
    final cal = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48.0,
            child: Row(children: [
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                    '${months[st.month.month - 1]} ${st.month.year + 543}',
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              nav(Icons.chevron_left_rounded, canPrev, -1),
              nav(Icons.chevron_right_rounded, canNext, 1),
            ]),
          ),
          const SizedBox(height: 4.0),
          Row(children: [
            for (final d in days)
              Expanded(
                child: Center(
                  child: Text(d,
                      style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: 4.0),
          for (var r = 0; r < ((firstWd + nDays) / 7).ceil(); r++)
            Row(children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(builder: (_) {
                    final n = r * 7 + c - firstWd + 1;
                    if (n < 1 || n > nDays) {
                      return const SizedBox(height: 40.0);
                    }
                    final d = DateTime(st.month.year, st.month.month, n);
                    final ok = inRange(d);
                    final on = dayOf(st.sel) == d;
                    final today = dayOf(now) == d;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: ok
                          ? () {
                              HapticFeedback.selectionClick();
                              set(() => st.sel = DateTime(d.year, d.month,
                                  d.day, st.sel.hour, st.sel.minute));
                            }
                          : null,
                      child: SizedBox(
                        height: 40.0,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 34.0,
                            height: 34.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: on ? _blue : Colors.transparent,
                              shape: BoxShape.circle,
                              border: today && !on
                                  ? Border.all(color: _blue, width: 1.0)
                                  : null,
                            ),
                            child: Text('$n',
                                style: _num(14.0,
                                    color: on
                                        ? Colors.white
                                        : ok
                                            ? _inkTitle
                                            : _g5,
                                    weight: on
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ]),
        ]);

    // ---- วงล้อเวลา: ชั่วโมง : นาที (แถบกลาง = ค่าที่เลือก)
    Widget wheel(FixedExtentScrollController c, int n, bool hour) => SizedBox(
          width: 56.0,
          child: ListWheelScrollView.useDelegate(
            controller: c,
            itemExtent: 44.0,
            diameterRatio: 1.6,
            perspective: 0.004,
            // ค่านอกแถบกลางจางลง ให้เห็นค่าที่เลือกชัด
            overAndUnderCenterOpacity: 0.35,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (v) {
              HapticFeedback.selectionClick();
              set(() => st.sel = DateTime(st.sel.year, st.sel.month, st.sel.day,
                  hour ? v : st.sel.hour, hour ? st.sel.minute : v));
            },
            childDelegate: ListWheelChildLoopingListDelegate(children: [
              for (var i = 0; i < n; i++)
                Center(
                  child: Text(i.toString().padLeft(2, '0'),
                      style: _num(20.0,
                          color: _inkTitle, weight: FontWeight.w600)),
                ),
            ]),
          ),
        );
    // คอลัมน์เวลา: หัว "เวลา" แนวเดียวกับหัวเดือน · วงล้อสูงเท่าตารางวัน
    // แถบกลางกรมท่าจาง (ค่าที่เลือก) · "น." อยู่ในแถบ
    final time =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 48.0,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text('เวลา',
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
        ),
      ),
      Expanded(
        child: Stack(alignment: Alignment.center, children: [
          Container(
            height: 44.0,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            wheel(st.hc, 24, true),
            Text(':',
                style: _num(20.0, color: _inkTitle, weight: FontWeight.w700)),
            wheel(st.mc, 60, false),
            Text('น.', style: _t(14.0, color: _ink2, weight: FontWeight.w600)),
          ]),
        ]),
      ),
    ]);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12.0),
          Wrap(spacing: 8.0, runSpacing: 8.0, children: [
            for (final (t, d) in quick) chip(t, d),
          ]),
          const SizedBox(height: 12.0),
          const Divider(height: 1.0, color: _line),
          const SizedBox(height: 8.0),
          IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: cal),
              const VerticalDivider(width: 24.0, thickness: 0.5, color: _line),
              SizedBox(width: 168.0, child: time),
            ]),
          ),
          const SizedBox(height: 8.0),
          const Divider(height: 1.0, color: _line),
          const SizedBox(height: 12.0),
          Row(children: [
            Expanded(
              child: Text('${_thDate(st.sel)} ${_clock(hm(st.sel))}',
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 14.0),
                shape: const StadiumBorder(),
              ),
              // วงล้อหมุนเลยช่วงได้: ใช้ค่าในช่วง (ไม่ก่อน first ไม่เกิน last)
              onPressed: () => onUse(st.sel.isAfter(last)
                  ? last
                  : st.sel.isBefore(first)
                      ? first
                      : st.sel),
              child: Text('ใช้เวลานี้',
                  style:
                      _t(15.0, color: Colors.white, weight: FontWeight.w700)),
            ),
          ]),
        ]);
  }

  Future<DateTime?> _dtSheet({
    required String title,
    String? sub,
    required DateTime initial,
    required DateTime first,
    required DateTime last,
  }) {
    final st = _DtState(initial);
    return _placedSheet<DateTime>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 640.0),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Container(
          decoration: const BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: _t(22.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          if (sub != null)
                            Text(sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(13.0,
                                    color: _ink3, weight: FontWeight.w500)),
                        ]),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: _ink2)),
                ]),
                _dtPanel(st, set,
                    first: first,
                    last: last,
                    onUse: (v) => Navigator.pop(ctx, v)),
              ]),
        ),
      ),
    ).whenComplete(st.dispose);
  }

  /// แผ่นเลือกแบบ filter (ref All filters): ซ้าย = หมวด (จำนวน) · ขวา = ค้นหา + รายการวงเลือก
  /// bottom sheet ไม่เต็มจอ · ค้นหา = ทุกหมวด · [custom] = ปุ่มท้าย (เช่น ระบุเอง) · [label] = ข้อความแถว
  Future<void> _soFilterSheet({
    required String title,
    String? sub,
    required List<(String, List<String>)> cats,
    required String? current,
    required void Function(String) onPick,
    String? customLabel,
    VoidCallback? onCustom,
    String Function(String)? label,
    String Function(String)? note,
  }) {
    final opts = [for (final c in cats) ...c.$2].toSet().toList();
    var sel = cats.indexWhere((c) => current != null && c.$2.contains(current));
    if (sel < 0) sel = 0;
    var q = '';
    // bottom sheet ไม่เต็มจอ: กว้างไม่เกิน 720 (กลางจอ) สูงไม่เกิน 560
    // sheet กลางของ ER (_placedSheet): ย้ายซ้าย/กลาง/ขวาได้ จำตำแหน่งไว้ (design rule)
    return _placedSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 720.0),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final cur = current;
        final searching = q.trim().isNotEmpty;
        final list = searching
            ? [
                for (final o in opts)
                  if (o.toLowerCase().contains(q.trim().toLowerCase())) o
              ]
            : (cats.isEmpty ? <String>[] : cats[sel].$2);
        void pick(String o) {
          Navigator.pop(ctx);
          onPick(o);
        }

        Widget cat(int i, String title, int n) {
          final on = i == sel && !searching;
          return InkWell(
            onTap: () => set(() {
              sel = i;
              q = '';
            }),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 12.0, 16.0),
              decoration: BoxDecoration(
                gradient: on
                    ? LinearGradient(colors: [
                        _blue.withValues(alpha: 0.0),
                        _blue.withValues(alpha: 0.08),
                      ])
                    : null,
                border: Border(
                    right: BorderSide(
                        color: on ? _blue : Colors.transparent, width: 3.0)),
              ),
              child: Row(children: [
                if (title == 'แนะนำ') ...[
                  Icon(Icons.auto_awesome_rounded,
                      size: 14.0, color: on ? _blue : _ink3),
                  const SizedBox(width: 4.0),
                ],
                Expanded(
                  child: Text(title,
                      style: _t(15.0,
                          color: on ? _blue : _ink2,
                          weight: on ? FontWeight.w700 : FontWeight.w500)),
                ),
                Text('$n',
                    style: _num(12.0, color: _ink3, weight: FontWeight.w600)),
              ]),
            ),
          );
        }

        Widget row(String o) {
          final on = o == cur;
          return InkWell(
            onTap: () => pick(o),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 4.0, 16.0),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label?.call(o) ?? o,
                            style: _t(15.0,
                                color: on ? _blue : _inkTitle,
                                weight:
                                    on ? FontWeight.w700 : FontWeight.w500)),
                        if (note?.call(o) case final n? when n.isNotEmpty)
                          Text(n,
                              style: _t(12.5,
                                  color: _ink3, weight: FontWeight.w500)),
                      ]),
                ),
                const SizedBox(width: 12.0),
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? _blue : Colors.transparent,
                    border: Border.all(color: on ? _blue : _g5, width: 1.5),
                  ),
                  child: on
                      ? const _SolarIcon('ph-check',
                          size: 15.0, color: Colors.white)
                      : null,
                ),
              ]),
            ),
          );
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: SizedBox(
            height: math.min(520.0, MediaQuery.of(ctx).size.height * 0.62),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 22.0, 12.0, 12.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: _t(22.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              if (sub != null)
                                Text(sub,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(13.0,
                                        color: _ink3, weight: FontWeight.w500)),
                            ]),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: _ink2)),
                    ]),
                  ),
                  Flexible(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ---- ซ้าย: หมวด (เลือกอยู่ = แถบกรมท่าขวา + พื้นจาง) · หมวดเดียว = ไม่มีแถบซ้าย
                          if (cats.length > 1)
                            Container(
                              width: 180.0,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Color(0xFFE3E6EC)))),
                              child:
                                  ListView(padding: EdgeInsets.zero, children: [
                                for (final (i, (title, xs)) in cats.indexed)
                                  cat(i, title, xs.length),
                              ]),
                            ),
                          // ---- ขวา: ค้นหา + รายการ + ระบุเอง
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 0.0, 20.0, 4.0),
                                    child: TextField(
                                      onChanged: (v) => set(() => q = v),
                                      style: _t(15.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w500),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: const Icon(
                                            Icons.search_rounded,
                                            size: 22.0,
                                            color: _ink3),
                                        hintText: 'ค้นหา',
                                        hintStyle: _t(15.0, color: _ink3),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F3F6),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 14.0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: list.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Text(
                                                'ไม่พบฉลากที่ตรงกับ "${q.trim()}"',
                                                style: _t(14.0,
                                                    color: _ink2,
                                                    weight: FontWeight.w500)),
                                          )
                                        : ListView.separated(
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 0.0, 20.0, 8.0),
                                            itemCount: list.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(
                                                    height: 1.0,
                                                    color: Color(0xFFE3E6EC)),
                                            itemBuilder: (_, i) => row(list[i]),
                                          ),
                                  ),
                                  if (customLabel != null)
                                    Container(height: 0.5, color: _line),
                                  if (customLabel != null)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        onCustom?.call();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24.0, 16.0, 20.0, 20.0),
                                        child: Row(children: [
                                          const Icon(Icons.edit_outlined,
                                              size: 18.0, color: _blue),
                                          const SizedBox(width: 8.0),
                                          Text(customLabel ?? '',
                                              style: _t(15.0,
                                                  color: _blue,
                                                  weight: FontWeight.w600)),
                                        ]),
                                      ),
                                    ),
                                ]),
                          ),
                        ]),
                  ),
                ]),
          ),
        );
      }),
    );
  }

  /// ฉลากที่เลือกไม่ตรงวิถีของยา (เช่น ยาฉีดแต่ฉลาก "รับประทาน") · null = ไม่มีปัญหา
  String? _soUsageMismatch(_SoDeckItem it) {
    final l = _soFieldVal(it, 'ฉลากช่วย');
    if (l == null || l == _soUsageCustom) return null;
    final r = _soDrugRoute(it), lr = _soUsageRoute(l);
    if (r == null || lr == null || r == lr) return null;
    return 'ฉลากไม่ตรงกับรูปแบบยา ($r)';
  }

  /// พิมพ์วิธีใช้เอง (จากตัวเลือก "ระบุเอง" ในฉลากยา) · ค่าเดิมเติมให้แก้ต่อ
  Future<void> _soUsageWrite(_SoDeckItem it) async {
    final ctl = TextEditingController(text: _soFieldVal(it, 'วิธีใช้') ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('ระบุวิธีใช้เอง',
            style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
        content: SizedBox(
          width: 420.0,
          child: TextField(
            controller: ctl,
            autofocus: true,
            minLines: 2,
            maxLines: 3,
            style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'เช่น รับประทานครั้งละ 1 เม็ด หลังอาหารเช้า',
              hintStyle: _t(14.0, color: _ink3),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () => Navigator.pop(ctx, ctl.text.trim()),
              child: Text('ใช้วิธีนี้',
                  style:
                      _t(14.0, color: Colors.white, weight: FontWeight.w600))),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), ctl.dispose);
    if (v == null || v.isEmpty || !mounted) return;
    setState(() {
      _soVal['${it.id}|ฉลากช่วย'] = _soUsageCustom;
      _soVal['${it.id}|วิธีใช้'] = v;
      _soNoteRev++;
    });
  }

  /// แผ่นเลือกแบบเมนูหัตถการ (sheet รายการ) สำหรับช่องยาหนึ่งช่อง
  /// ตัวเลือกทั่วไปของฟอร์ม = แผ่น filter ตัวเดียวกับฉลากยา/หัตถการ (จัดหมวดจากข้อความ)
  /// "กำหนดเอง" = ปุ่มท้ายแผ่น
  Future<void> _soPickSheet(
      _SoDeckItem it, String f, String title, List<String> opts) {
    final custom = opts.contains(_soFreqCustom);
    return _soFilterSheet(
      title: title,
      sub: it.name,
      cats: _soPickCats([
        for (final o in opts)
          if (o != _soFreqCustom) o
      ]),
      current: _soFieldVal(it, f),
      note: (o) => _soDoseUnitNote[o] ?? '',
      onPick: (o) => _soPick(it, f, o),
      customLabel: custom ? 'กำหนดเอง' : null,
      onCustom: custom ? () => _soPick(it, f, _soFreqCustom) : null,
    );
  }

  /// แผ่นเลือกหน่วย (ใช้ร่วม หน่วยที่เบิก / หน่วยขนาดยา): หมวดชุดเดียวกัน ลำดับเดียวกัน
  Future<void> _soUnitSheet(
      _SoDeckItem it, String f, String title, List<String> opts) {
    final codes = {for (final o in opts) _soUnitCode(o)};
    final rec = f == 'doseU' ? _soDoseUnitRecommend(it) : const <String>[];
    final cats = [
      if (rec.isNotEmpty) ('แนะนำ', rec),
      for (final (c, xs) in _soDoseUnitCats)
        (
          c,
          [
            for (final x in xs)
              if (codes.contains(x)) x
          ]
        )
    ].where((c) => c.$2.isNotEmpty).toList();
    final cur = f == 'doseU' ? _soDoseUnit(it) : _soFieldVal(it, f);
    return _soFilterSheet(
      title: title,
      sub: it.name,
      cats: cats,
      current: cur == null ? null : _soUnitCode(cur),
      note: (o) => _soDoseUnitNote[o] ?? '',
      onPick: (o) => setState(() {
        if (f == 'doseU') {
          _soVal['${it.id}|doseU'] = o;
          _soDoseSave(it, _soDoseNumOf(it), o);
        } else {
          _soPick(it, f, o);
        }
      }),
    );
  }

  /// หน่วยขนาดยาที่เข้ากับยานี้: หน่วยที่เบิก + หน่วยความแรงในชื่อ (500 mg → mg) + ml (ยาน้ำ/สารน้ำ)
  /// เช่น Antivenom → VIAL ml · Paracetamol 500 mg → TAB mg · NSS 1,000 ml → BAG ml
  List<String> _soDoseUnitRecommend(_SoDeckItem it) {
    final n = '${it.name} ${it.detail}';
    final rx = _soParseRx(it.name, it.detail);
    final out = <String>[];
    void add(String? u) {
      if (u != null && u.isNotEmpty && !out.contains(u)) out.add(u);
    }

    final pack = _soFieldVal(it, 'หน่วยบรรจุ');
    add(pack == null ? null : _soUnitCode(pack));
    for (final m in RegExp(r'\d[\d,.]*\s*(mcg|mg|g|ml|mL|U|unit)\b',
            caseSensitive: false)
        .allMatches(n)) {
      final u = m.group(1)!.toLowerCase();
      add(switch (u) { 'unit' || 'u' => 'U', _ => u });
    }
    if (rx.form == 'fluid' ||
        RegExp(r'antivenom|เซรุ่ม|syr|ยาน้ำ|susp', caseSensitive: false)
            .hasMatch(n)) {
      add('ml');
    }
    return out;
  }

  /// จัดหมวดตัวเลือกจากข้อความ (ความถี่ ช่วงเวลา หน่วยบรรจุ) · ไม่เข้าหมวด = อื่น ๆ
  List<(String, List<String>)> _soPickCats(List<String> opts) {
    String bucket(String o) => switch (o) {
          'TAB' || 'CAP' => 'เม็ดและแคปซูล',
          'AMP' || 'VIAL' => 'ยาฉีด',
          'BAG' || 'BOT' || 'TUBE' => 'ถุง ขวด หลอด',
          'BOX' || 'PACK' || 'PCS' => 'กล่องและชิ้น',
          _ when o.startsWith('วันละ') => 'วันละกี่ครั้ง',
          _ when o.startsWith('ทุก') => 'ทุกกี่ชั่วโมง',
          _ when o.contains('ครึ่งเม็ด') => 'ครึ่งเม็ด',
          _ when o.startsWith('ก่อนอาหาร') => 'ก่อนอาหาร',
          _ when o.startsWith('หลังอาหาร') => 'หลังอาหาร',
          _ => 'อื่น ๆ',
        };
    final out = <String, List<String>>{};
    for (final o in opts) {
      (out[bucket(o)] ??= []).add(o);
    }
    // อื่น ๆ ไว้ท้าย
    final rest = out.remove('อื่น ๆ');
    return [
      for (final e in out.entries) (e.key, e.value),
      if (rest != null) (out.isEmpty ? 'ทั้งหมด' : 'อื่น ๆ', rest),
    ];
  }

  /// แถวแบบการ์ดหัตถการ: ชื่อช่องซ้าย · ค่าชิดขวา (หรือ trailing) · ลูกศรเมื่อแตะได้
  Widget _soRow(String label,
          {String? value,
          String? placeholder,
          Widget? trailing,
          VoidCallback? onTap,
          bool first = false,
          bool req = false,
          String? sub,
          Color subColor = _ink3,
          bool flush = false}) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        if (!first)
          const Divider(height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 10.0, 4.0, 10.0),
                child: Row(children: [
                  Text.rich(
                      TextSpan(children: [
                        TextSpan(text: label),
                        if (req)
                          TextSpan(text: ' *', style: _t(14.0, color: _red)),
                      ]),
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: trailing ??
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(value ?? placeholder ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: _t(14.0,
                                    color: value == null ? _ink3 : _inkTitle,
                                    weight: value == null
                                        ? FontWeight.w500
                                        : FontWeight.w600)),
                            if (sub != null)
                              Text(sub,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: _t(12.0,
                                      color: subColor,
                                      weight: FontWeight.w500)),
                          ],
                        ),
                  ),
                  // flush = trailing ชิดขอบขวา (ไม่เว้นที่ลูกศร)
                  if (!flush) ...[
                    const SizedBox(width: 4.0),
                    if (onTap != null)
                      const Icon(Icons.chevron_right_rounded,
                          size: 22.0, color: _ink3)
                    else
                      const SizedBox(width: 22.0),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ]);

  /// ช่องพิมพ์ชิดขวาในแถว (Dose · จำนวน · ทุก N)
  Widget _soRowInput(_SoDeckItem it, String f, String hint,
          {bool raw = false}) =>
      TextFormField(
        key: ValueKey('${it.id}|$f|$_soNoteRev'),
        initialValue: raw ? _soVal['${it.id}|$f'] : _soFieldVal(it, f),
        textAlign: TextAlign.right,
        onChanged: (v) => setState(() => _soVal['${it.id}|$f'] = v),
        style: _t(14.0, color: _inkTitle, weight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: _t(14.0, color: _ink3, weight: FontWeight.w500),
        ),
      );

  /// ฟอร์มสั่งยา (ตามฟอร์ม HOSxP) ในภาษาเดียวกับเมนูหัตถการ:
  /// การ์ด "ยา" (ชื่อ · STAT) → "วิธีใช้" (2 โหมด + timeline) → "การจ่ายยา" (จำนวน · หน่วยบรรจุ)
  List<T> _soMedForm<T>(_SoDeckItem it, T Function(String, Widget) sec) {
    final id = it.id;
    final mode = _soMedMode(it);
    final stat = _soStat(id);
    void setStat(bool on) => setState(() {
          _soVal['$id|STAT'] = on ? '1' : '';
          if (on) {
            _soVal['$id|ความถี่ยา'] = _soStatFreq;
            if ((_soVal['$id|จำนวน'] ?? '').isEmpty) _soVal['$id|จำนวน'] = '1';
            if (_soIsRound(_soVal['$id|ฉลากช่วย'])) _soVal['$id|ฉลากช่วย'] = '';
          } else if (_soVal['$id|ความถี่ยา'] == _soStatFreq) {
            _soVal['$id|ความถี่ยา'] = '';
          }
          _soNoteRev++;
        });
    Widget unitRow(String label, String f, String master, {bool req = false}) {
      final g = _soGuess(it, f);
      return g != null
          ? _soRow(label, value: g, sub: 'จากข้อมูลยา', req: req)
          : _soRow(label,
              value: _soFieldVal(it, f),
              placeholder: 'เลือก$label',
              req: req,
              onTap: () => _soPickSheet(it, f, label, _soMaster(master)));
    }

    final freq = _soFieldVal(it, 'ความถี่ยา');
    return [
      // หัวการ์ด = ชื่อยา (ไม่มีแถว "ชื่อยา" ซ้ำ)
      sec(
          it.name,
          Column(mainAxisSize: MainAxisSize.min, children: [
            // ให้ยาเมื่อไร: ตามเวลา (ความถี่) หรือทันทีครั้งเดียว (STAT) · เลือกได้ทางเดียว
            // ให้ยาเมื่อไร: 2 ตัวเลือกแถวเดียวกัน แบ่งครึ่ง (ชื่ออย่างเดียว) · เลือกแล้ว = ขอบเข้ม + วงเลือก
            // การ์ดซ้อน: ช่องตัวเลือกห่างขอบการ์ด 8 (น้อยกว่าหัวข้อ 16)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 8.0),
              child: Row(children: [
                for (final (i, (on, _, t, _)) in [
                  (
                    false,
                    Icons.schedule_rounded,
                    'ตามรอบเวลา',
                    'ให้ตามรอบความถี่'
                  ),
                  (
                    true,
                    Icons.bolt_rounded,
                    'ให้ทันที (STAT)',
                    'ครั้งเดียว ตอนนี้'
                  ),
                ].indexed) ...[
                  if (i > 0) const SizedBox(width: 8.0),
                  Expanded(
                    child: Material(
                      color: _panel,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                            color: stat == on ? _blue : const Color(0xFFDADCE0),
                            width: stat == on ? 1.2 : 0.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          if (stat == on) return;
                          HapticFeedback.selectionClick();
                          setStat(on);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                          // 2 แถวในช่อง: บน = ภาพประกอบ + วงเลือก · ล่าง = ชื่อ
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ตามรอบเวลา = ขวดยา + นาฬิกา (Figma 673:141) · STAT = ขวดยาป้าย STAT (Figma 674:286)
                                      Image.asset(
                                          on
                                              ? 'assets/images/er_os_med_stat.png'
                                              : 'assets/images/er_os_med_sched.png',
                                          width: 48.0,
                                          height: 48.0),
                                      const Spacer(),
                                      // วงติ๊ก (แบบรายการฝั่งขวา): เลือก = กรมท่าทึบ + ✓ · ไม่เลือก = วงว่าง
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        width: 22.0,
                                        height: 22.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: stat == on
                                              ? _blue
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: stat == on ? _blue : _g5,
                                              width: 1.5),
                                        ),
                                        child: stat == on
                                            ? const _SolarIcon('ph-check',
                                                size: 14.0, color: Colors.white)
                                            : null,
                                      ),
                                    ]),
                                const SizedBox(height: 8.0),
                                Text(t,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(13.5,
                                        color: stat == on ? _blue : _ink2,
                                        weight: FontWeight.w700)),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ])),
      // เบิกจากห้องยา: คำอธิบาย + แถวจำนวน (stepper) + แถวหน่วย
      sec(
          'จำนวนที่เบิกจากห้องยา',
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 6.0),
                  child: Text(
                      'จำนวนยาทั้งหมดที่ห้องยาจ่ายให้ ไม่ใช่ขนาดต่อครั้ง',
                      style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                ),
                // แถวเดียว: แคปซูลเดียว [− n + | หน่วย] อ่านเป็น "1 VIAL"
                _soRow('จำนวน',
                    first: true,
                    flush: true,
                    trailing: Align(
                        alignment: Alignment.centerRight,
                        child: _soQtyStepper(it))),
              ])),
      sec(
          'วิธีใช้',
          Column(
              key: _soUsageKeys.putIfAbsent(id, GlobalKey.new),
              mainAxisSize: MainAxisSize.min,
              children: [
                // วิธีกำหนด: 2 ช่องแบบการ์ดตัวเลือก (ภาษาเดียวกับประเภทการสั่งยา)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                  child: Row(children: [
                    Expanded(
                        child: _soOptTile(mode == 2, 'ตามฉลาก', () {
                      HapticFeedback.selectionClick();
                      setState(() => _soVal['$id|mode'] = '2');
                      _soReveal(_soUsageKey);
                    }, img: 'assets/images/er_os_med_label.png')),
                    const SizedBox(width: 8.0),
                    Expanded(
                        child: _soOptTile(mode == 3, 'กำหนดเอง', () {
                      HapticFeedback.selectionClick();
                      setState(() => _soVal['$id|mode'] = '3');
                      _soReveal(_soUsageKey);
                    })),
                  ]),
                ),
                if (mode == 2) ...[
                  // วิธีใช้ = แถวเดียวแบบฟอร์มอื่น: ค่าอยู่ขวา · แตะ = เลือกจากฉลากยา (master er_drugusage)
                  _soRow('วิธีใช้',
                      value: switch (_soFieldVal(it, 'วิธีใช้')) {
                        final v? when v.isNotEmpty => v,
                        _ => _soFieldVal(it, 'ฉลากช่วย'),
                      },
                      placeholder: 'เลือกจากฉลากยา',
                      // validation: ฉลากต้องตรงวิถีให้ยาจากชื่อยา · เลือกให้อัตโนมัติ = บอกให้ตรวจ
                      sub: _soUsageMismatch(it) ??
                          (_soVal['$id|ฉลากช่วย'] == null &&
                                  _soVal['$id|วิธีใช้'] == null &&
                                  _soUsageAuto(it) != null
                              ? 'เลือกให้จากชื่อยา ตรวจก่อนยืนยัน'
                              : null),
                      subColor: _soUsageMismatch(it) != null ? _red : _blue,
                      first: true,
                      onTap: () => _soUsageSheet(it, stat)),
                ] else ...[
                  // ขนาดต่อครั้ง + หน่วย · ยา STAT ให้ครั้งเดียว = ไม่มีแถวความถี่/ช่วงเวลา (เลือก STAT ไว้ด้านบนแล้ว)
                  // ขนาดต่อครั้ง = แถวเดียว: แคปซูลเดียวแบ่งสองช่อง [ตัวเลข | หน่วย ▾] อ่านเป็น "1 VIAL"
                  _soRow('ขนาดต่อครั้ง',
                      first: true,
                      flush: true,
                      trailing: Align(
                          alignment: Alignment.centerRight,
                          child: _soDoseGroup(it))),
                  if (!stat) ...[
                    _soRow('ความถี่',
                        value: _soVal['$id|freqCustom'] == '1'
                            ? (freq ?? 'กำหนดเอง')
                            : freq,
                        placeholder: 'เลือกความถี่',
                        onTap: () => _soPickSheet(it, 'ความถี่ยา', 'ความถี่', [
                              ..._soMaster('er_drug_frequency'),
                              _soFreqCustom
                            ])),
                    if (_soVal['$id|freqCustom'] == '1') ..._soEveryRows(it),
                    _soRow('ช่วงเวลา',
                        value: _soFieldVal(it, 'เวลา'),
                        placeholder: 'เช่น หลังอาหาร',
                        onTap: () => _soPickSheet(
                            it, 'เวลา', 'ช่วงเวลา', _soMaster('er_drug_time'))),
                  ],
                ],
                // ไม่มีสรุป/เส้นเวลาในฟอร์ม: ค่าอยู่ในช่องแล้ว (สรุปดูที่แบบร่างฝั่งซ้าย)
              ])),
    ];
  }

  /// หน่วยบรรจุจากชื่อยา/วิถี เมื่อตัวแยกคำสั่งบอกรูปแบบไม่ได้ (knowledge ข้อ 61)
  /// เซรุ่ม/วัคซีน/ท็อกซอยด์ = VIAL · หยอดตา/หู/จมูก ยาน้ำ = BOT · ครีม/ขี้ผึ้ง/เจล = TUBE
  /// ผงเกลือแร่/ซอง = PACK · พ่นสูด แผ่นแปะ ยาเหน็บ = PCS · พ่นละออง (nebule) = AMP
  String? _soPackAuto(_SoDeckItem it) {
    final n = '${it.name} ${it.detail}'.toLowerCase();
    bool has(String re) => RegExp(re, caseSensitive: false).hasMatch(n);
    if (has(
        r'antivenom|เซรุ่ม|serum|vaccine|วัคซีน|toxoid|immunoglobulin|\btig\b|\brig\b|insulin')) {
      return 'VIAL';
    }
    if (has(r'\bors\b|เกลือแร่|sachet|ซอง|ผง')) return 'PACK';
    if (has(r'patch|แผ่นแปะ')) return 'PCS';
    switch (_soDrugRoute(it)) {
      case 'EYE':
      case 'EAR':
      case 'NAS':
        return 'BOT';
      case 'TOP':
        return 'TUBE';
      case 'INH':
      case 'PR':
        return 'PCS';
      case 'NEB':
        return 'AMP';
    }
    if (has(r'syr|syrup|ยาน้ำ|susp|mixt')) return 'BOT';
    return null;
  }

  /// หมวดของหน่วยขนาดยา (แผ่น filter)
  static const _soDoseUnitCats = [
    // หมวดชุดเดียวกันทั้งหน่วยที่เบิกและหน่วยขนาดยา (หน่วยที่เบิกใช้แค่ 4 หมวดแรก)
    ('เม็ดและแคปซูล', ['TAB', 'CAP']),
    ('ยาฉีด', ['AMP', 'VIAL']),
    ('ถุง ขวด หลอด', ['BAG', 'BOT', 'TUBE']),
    ('กล่องและชิ้น', ['BOX', 'PACK', 'PCS']),
    ('น้ำหนัก', ['mg', 'g', 'mcg']),
    ('ปริมาตร', ['ml', 'หยด']),
    ('อื่น ๆ', ['U', 'กด']),
  ];

  static const _soDoseUnitNote = {
    'TAB': 'เม็ด',
    'CAP': 'แคปซูล',
    'AMP': 'แอมพูล',
    'VIAL': 'ขวดยาฉีด',
    'BAG': 'ถุง',
    'BOT': 'ขวด',
    'TUBE': 'หลอด',
    'mg': 'มิลลิกรัม',
    'g': 'กรัม',
    'mcg': 'ไมโครกรัม',
    'ml': 'มิลลิลิตร',
    'U': 'ยูนิต',
    'กด': 'ยาพ่น',
    'BOX': 'กล่อง',
    'PACK': 'แพ็ก',
    'PCS': 'ชิ้น',
  };

  /// หน่วยนับที่ต้องตรงกับหน่วยที่เบิก (หน่วยวัด mg/ml ฯลฯ ไม่ต้องตรง)
  static const _soCountUnits = {
    'TAB',
    'CAP',
    'AMP',
    'VIAL',
    'BAG',
    'BOT',
    'TUBE',
    'PACK',
    'PCS'
  };

  /// ทำหน่วยให้เป็นคำเดียวกันทั้งฟอร์ม: เม็ด → TAB · แคปซูล → CAP · ขวด → BOT · ถุง → BAG · unit → U
  String _soUnitCode(String u) {
    final t = u.trim();
    final l = t.toLowerCase();
    return switch (l) {
      'เม็ด' || 'tab' || 'tablet' || 'tab (เม็ด)' => 'TAB',
      'แคปซูล' || 'cap' || 'capsule' || 'cap (แคปซูล)' => 'CAP',
      'amp' || 'แอมพูล' => 'AMP',
      'vial' || 'vial (ขวด)' => 'VIAL',
      'ถุง' || 'bag' || 'bag (ถุง)' => 'BAG',
      'ขวด' || 'bot' || 'bot (ขวด)' => 'BOT',
      'หลอด' || 'tube' || 'tube (หลอด)' => 'TUBE',
      'unit' || 'units' || 'u' => 'U',
      _ => t,
    };
  }

  /// ขนาดต่อครั้งเก็บเป็นข้อความเดียว "2 g" (ช่อง ขนาดยา) · แยกเลข/หน่วยเมื่อแสดง
  RegExpMatch? _soDoseParts(_SoDeckItem it) => RegExp(r'^([\d.,]+)\s*(.*)$')
      .firstMatch((_soFieldVal(it, 'ขนาดยา') ?? '').trim());
  String _soDoseNumOf(_SoDeckItem it) => _soDoseParts(it)?.group(1) ?? '';
  String? _soDoseUnit(_SoDeckItem it) {
    final u = _soVal['${it.id}|doseU'] ?? '';
    if (u.isNotEmpty) return _soUnitCode(u);
    final p = (_soDoseParts(it)?.group(2) ?? '').trim();
    if (p.isNotEmpty) return _soUnitCode(p);
    // ยังไม่เลือก: ใช้หน่วยที่เบิก (เช่น 1 VIAL ต่อครั้ง) ไม่ต้องเลือกซ้ำ เปลี่ยนได้ถ้าต่างกัน
    return _soFieldVal(it, 'หน่วยบรรจุ');
  }

  /// หน่วยขนาดยายังเป็นค่าตามหน่วยที่เบิก (ผู้ใช้ยังไม่ได้เลือกเอง)
  bool _soDoseUnitFollows(_SoDeckItem it) =>
      (_soVal['${it.id}|doseU'] ?? '').isEmpty &&
      (_soDoseParts(it)?.group(2) ?? '').trim().isEmpty &&
      _soFieldVal(it, 'หน่วยบรรจุ') != null;

  void _soDoseSave(_SoDeckItem it, String n, String u) =>
      _soVal['${it.id}|ขนาดยา'] =
          [n.trim(), _soUnitCode(u)].where((x) => x.isNotEmpty).join(' ');

  /// หน่วยขนาดยาเป็นหน่วยนับแต่ไม่ตรงกับหน่วยที่เบิก (เช่น สั่ง 1 CAP แต่เบิก TAB) · null = ตรง/ไม่ต้องตรง
  String? _soDoseUnitMismatch(_SoDeckItem it) {
    final d = _soDoseUnit(it), pk = _soFieldVal(it, 'หน่วยบรรจุ');
    if (d == null || pk == null) return null;
    final dc = _soUnitCode(d), pc = _soUnitCode(pk);
    if (!_soCountUnits.contains(dc) || dc == pc) return null;
    return 'ไม่ตรงกับหน่วยที่เบิก ($pc)';
  }

  /// ช่องตัวเลขขนาดต่อครั้ง: กรอบมนแบบตัวนับจำนวน · แป้นตัวเลข (ทศนิยมได้)
  /// ขนาด + หน่วย ในกรอบเดียว: ซ้าย = พิมพ์ตัวเลข · ขวา = หน่วย (แตะ = แผ่น filter หน่วย)
  /// ใต้กรอบ: ที่มาของหน่วย / เตือนหน่วยไม่ตรงกับที่เบิก
  Widget _soDoseGroup(_SoDeckItem it) {
    final unit = _soDoseUnit(it);
    final n0 = double.tryParse(_soDoseNumOf(it).trim());
    final warn = _soDoseNumOf(it).trim().isNotEmpty && (n0 == null || n0 <= 0)
        ? 'ขนาดต้องมากกว่า 0'
        : _soDoseUnitMismatch(it);
    final sub = warn ?? (_soDoseUnitFollows(it) ? 'หน่วยตามที่เบิก' : null);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                  color: warn != null ? _red : const Color(0xFFDADCE0),
                  width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 84.0,
                child: TextFormField(
                  key: ValueKey('${it.id}|doseN|$_soNoteRev'),
                  initialValue: _soDoseNumOf(it),
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // ตัวเลขทศนิยมเท่านั้น (คีย์บอร์ด iPad พิมพ์ตัวอักษรได้)
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  onChanged: (v) =>
                      setState(() => _soDoseSave(it, v, _soDoseUnit(it) ?? '')),
                  style: _num(17.0, color: _inkTitle, weight: FontWeight.w700),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: _num(17.0, color: _ink3),
                  ),
                ),
              ),
              Container(
                  width: 0.5, height: 24.0, color: const Color(0xFFDADCE0)),
              InkWell(
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(100.0)),
                // แผ่น filter แบ่งหมวด: หน่วยนับ / น้ำหนัก / ปริมาตร / อื่น ๆ
                onTap: () => _soUnitSheet(it, 'doseU', 'หน่วยขนาดยา',
                    [for (final c in _soDoseUnitCats) ...c.$2]),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 0.0, 8.0, 0.0),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(unit ?? 'หน่วย',
                        style: _t(14.0,
                            color: unit == null ? _ink3 : _inkTitle,
                            weight: FontWeight.w600)),
                    const SizedBox(width: 2.0),
                    const Icon(Icons.expand_more_rounded,
                        size: 20.0, color: _ink3),
                  ]),
                ),
              ),
            ]),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4.0),
            Text(sub,
                maxLines: 2,
                textAlign: TextAlign.right,
                style: _t(12.0,
                    color: warn != null ? _red : _ink3,
                    weight: FontWeight.w500)),
          ],
        ]);
  }

  /// ความถี่กำหนดเอง: กล่องเดียวต่อใต้แถวความถี่ (พื้นอ่อน) ให้เห็นว่าเป็นกลุ่มเดียวกัน
  /// บรรทัด 1 = "ทุก" + ตัวนับ − n + · บรรทัด 2 = segmented นาที/ชั่วโมง/วัน เต็มกว้าง
  /// บรรทัด 3 = อ่านเป็นประโยค "ทำทุก 4 ชั่วโมง"
  List<Widget> _soEveryRows(_SoDeckItem it) {
    final id = it.id;
    final n = int.tryParse((_soVal['$id|freqN'] ?? '').trim()) ?? 0;
    final u =
        (_soVal['$id|freqU'] ?? '').isEmpty ? 'ชั่วโมง' : _soVal['$id|freqU']!;
    void setN(int v) => setState(() {
          _soVal['$id|freqN'] = '${v < 1 ? 1 : v}';
          _soVal['$id|freqU'] = u;
          _soNoteRev++;
        });
    Widget btn(IconData ic, VoidCallback? f) => InkWell(
          onTap: f,
          customBorder: const CircleBorder(),
          child: SizedBox(
              width: 38.0,
              height: 38.0,
              child: Icon(ic, size: 20.0, color: f == null ? _g5 : _blue)),
        );
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 10.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 12.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(14.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text('ทุก',
                    style: _t(14.0, color: _ink2, weight: FontWeight.w600)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  btn(Icons.remove_rounded, n > 1 ? () => setN(n - 1) : null),
                  SizedBox(
                    width: 44.0,
                    child: TextFormField(
                      key: ValueKey('$id|freqN|$_soNoteRev'),
                      initialValue: n == 0 ? '' : '$n',
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => setState(() {
                        _soVal['$id|freqN'] = v;
                        _soVal['$id|freqU'] = u;
                      }),
                      style:
                          _num(17.0, color: _inkTitle, weight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0',
                        hintStyle: _num(17.0, color: _ink3),
                      ),
                    ),
                  ),
                  btn(Icons.add_rounded, () => setN(n + 1)),
                ]),
              ),
            ]),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(children: [
                for (final x in const ['นาที', 'ชั่วโมง', 'วัน'])
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _soVal['$id|freqU'] = x);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: x == u ? _blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text(x,
                            style: _t(13.5,
                                color: x == u ? Colors.white : _ink2,
                                weight: x == u
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8.0),
            Text(n > 0 ? 'ทำทุก $n $u' : 'ระบุจำนวน แล้วเลือกหน่วยเวลา',
                style: _t(12.5,
                    color: n > 0 ? _blue : _ink3, weight: FontWeight.w600)),
          ]),
        ),
      ),
    ];
  }

  /// ตัวนับจำนวนเบิก: − ค่า + (ขั้นละ 1 ต่ำสุด 1) · แตะตัวเลข = พิมพ์ได้
  Widget _soQtyStepper(_SoDeckItem it) {
    final n = int.tryParse((_soFieldVal(it, 'จำนวน') ?? '').trim()) ?? 0;
    final unit = _soFieldVal(it, 'หน่วยบรรจุ');
    // หน่วยอ่านจากชื่อยา = ล็อก · เดาจากชนิด/วิถี = เลือกไว้ให้แต่เปลี่ยนได้ (ข้อ 61)
    final locked = _soParseRx(it.name, it.detail).pack != null;
    void setN(int v) => setState(() {
          _soVal['${it.id}|จำนวน'] = '${v < 1 ? 1 : v}';
          _soNoteRev++;
        });
    Widget btn(IconData ic, VoidCallback? f) => InkWell(
          onTap: f,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: Icon(ic, size: 20.0, color: f == null ? _g5 : _blue),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove_rounded, n > 1 ? () => setN(n - 1) : null),
        SizedBox(
          width: 48.0,
          child: TextFormField(
            key: ValueKey('${it.id}|จำนวน|$_soNoteRev'),
            initialValue: n == 0 ? '' : '$n',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => _soVal['${it.id}|จำนวน'] = v,
            style: _num(17.0, color: _inkTitle, weight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              hintStyle: _num(17.0, color: _ink3),
            ),
          ),
        ),
        btn(Icons.add_rounded, () => setN(n + 1)),
        Container(width: 0.5, height: 24.0, color: const Color(0xFFDADCE0)),
        // หน่วยบรรจุ: มีในชื่อยา = ล็อก (ไม่มีลูกศร) · ไม่มี = แตะเลือก
        InkWell(
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(100.0)),
          onTap: locked
              ? null
              : () => _soUnitSheet(it, 'หน่วยบรรจุ', 'หน่วยที่เบิก',
                  _soMaster('er_drug_package_unit')),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.0, 0.0, locked ? 16.0 : 8.0, 0.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(unit ?? 'หน่วย',
                  style: _t(14.0,
                      color: unit == null ? _ink3 : _inkTitle,
                      weight: FontWeight.w600)),
              if (!locked) ...[
                const SizedBox(width: 2.0),
                const Icon(Icons.expand_more_rounded, size: 20.0, color: _ink3),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  /// รายการในแบบร่างที่ยังไม่ยืนยันรายละเอียด (id) · ใช้ในหน้าสรุปและปุ่มท้าย
  List<String> _soReviewMissing() => [
        for (final x in _soDeckItems())
          if (!_soDone.contains(x.id)) x.id
      ];

  /// หน้าสรุปก่อนบันทึกของขั้นสั่งการรักษา: จากแบบร่างจริง
  /// การ์ดละแฟ้ม (One Day / Continuation / Progress Note) · ในการ์ดแบ่งประเภท
  /// แต่ละรายการ: ชื่อ + รายละเอียดที่กรอก + สถานะ (ยืนยันแล้ว / ต้องระบุ) · แตะ = เปิดหน้ากรอก
  Widget _soReview() {
    final items = _soDeckItems();
    final missing = _soReviewMissing();
    final done = items.isNotEmpty && missing.isEmpty;
    Widget item(_SoDeckItem it) {
      final ok = _soDone.contains(it.id);
      final line = _soDetailLine(it);
      return InkWell(
        onTap: () => _soEditOpen(it.id),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Icon(ok ? Icons.check_circle_rounded : Icons.edit_outlined,
                  size: 16.0, color: ok ? _green : _blue),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                        TextSpan(children: [
                          TextSpan(text: it.name),
                          if (_soStat(it.id))
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: _soStatBadge())),
                        ]),
                        style: _t(13.5,
                            color: _inkTitle, weight: FontWeight.w600)),
                    Text(
                        ok
                            ? (line.isEmpty ? 'กรอกแล้ว' : line)
                            : 'ต้องระบุรายละเอียด',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5,
                            color: ok ? _ink2 : _blue,
                            weight: FontWeight.w500)),
                  ]),
            ),
          ]),
        ),
      );
    }

    Widget card(String sec, List<_SoDeckItem> xs) => Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 8.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text(sec,
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text(
                  'กรอกแล้ว ${xs.where((x) => _soDone.contains(x.id)).length}/${xs.length}',
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ]),
            for (final (cat, label, _) in _soCatGroups)
              if ([
                for (final x in xs)
                  if (_soCatsOf(x).first == cat) x
              ]
                  case final g when g.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
                  child: Text(label,
                      style: _t(12.5, color: _ink3, weight: FontWeight.w600)),
                ),
                for (final x in g) item(x),
              ],
            if (sec == 'Progress Note')
              for (final x in xs) item(x),
          ]),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('สรุปก่อนบันทึก',
            style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
        const SizedBox(height: 2.0),
        Text(
            items.isEmpty
                ? 'ยังไม่มีรายการคำสั่ง'
                : done
                    ? 'ทุกรายการระบุครบแล้ว ตรวจทานแล้วกดบันทึก'
                    : 'ยังต้องระบุอีก ${missing.length} รายการ แตะรายการเพื่อระบุ',
            style:
                _t(12.5, color: done ? _ink3 : _blue, weight: FontWeight.w500)),
        const SizedBox(height: 16.0),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 88.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final sec in const [
                    'Progress Note',
                    'One Day',
                    'Continuation'
                  ])
                    if ([
                      for (final x in items)
                        if (x.section == sec) x
                    ]
                        case final xs when xs.isNotEmpty)
                      card(sec, xs),
                ]),
          ),
        ),
      ],
    );
  }

  /// ป้าย STAT (แทนคำว่า "ด่วน"): พื้นแดงจาง ตัวแดงหนา มุมโค้ง
  /// chip = อยู่ในแถวป้ายยา: สูง/มุม/ตัวอักษรเท่าป้ายข้าง ๆ (เรียงแนวเดียวกัน)
  Widget _soStatBadge({bool chip = false}) => Container(
        padding: chip
            ? const EdgeInsets.fromLTRB(6.0, 3.0, 8.0, 3.0)
            : const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(chip ? 6.0 : 5.0),
        ),
        // chip: สายฟ้านำหน้า (ด่วน) ชุด Phosphor เดียวกับป้ายข้าง ๆ
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (chip) ...[
            const _SolarIcon('ph-lightning',
                size: 13.0, color: _red, grow: 0.6),
            const SizedBox(width: 3.0),
          ],
          Text('STAT',
              style: _t(chip ? 12.0 : 11.0,
                  color: _red,
                  weight: chip ? FontWeight.w700 : FontWeight.w800)),
        ]),
      );

  /// เลือกตัวเลือกแล้วมีรายละเอียดกางด้านล่าง: เลื่อนแผงให้ทั้งการ์ดอยู่ในจอ (พ้นปุ่ม footer)
  /// การ์ดยาวกว่าจอ = ชิดบนการ์ด · รอ 2 เฟรมให้รายละเอียดใหม่ layout เสร็จ
  void _soReveal(GlobalKey k) {
    void run() {
      final ctx = k.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      final sc = ctx == null ? null : Scrollable.maybeOf(ctx);
      final view = sc?.context.findRenderObject() as RenderBox?;
      if (box == null || sc == null || view == null) return;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final vTop = view.localToGlobal(Offset.zero).dy;
      final vBottom = vTop + view.size.height - _wfFootH - 8.0;
      final pos = sc.position;
      double d = 0.0;
      if (bottom > vBottom) d = bottom - vBottom;
      // ไม่ดันหัวการ์ดพ้นขอบบน
      if (top - d < vTop + 8.0) d = top - vTop - 8.0;
      if (d.abs() < 1.0) return;
      pos.animateTo(
          (pos.pixels + d).clamp(pos.minScrollExtent, pos.maxScrollExtent),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic);
    }

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => WidgetsBinding.instance.addPostFrameCallback((_) => run()));
  }

  /// ช่องตัวเลือกแบบการ์ด 2 แถว (ภาษาเดียวกับประเภทการสั่งยา): บน = ภาพ 48 + วงติ๊ก · ล่าง = ชื่อ
  /// ไม่มีภาพ = ไอคอนในกล่อง 48 แทน · เลือก = ขอบกรมท่า
  Widget _soOptTile(bool on, String t, VoidCallback tap,
          {String? img, IconData icon = Icons.tune_rounded, Widget? art}) =>
      Material(
        color: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
              color: on ? _blue : const Color(0xFFDADCE0),
              width: on ? 1.2 : 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: on ? null : tap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                art != null
                    ? SizedBox(width: 48.0, height: 48.0, child: art)
                    : img != null
                        ? Image.asset(img, width: 48.0, height: 48.0)
                        : SizedBox(
                            width: 48.0,
                            height: 48.0,
                            child: Icon(icon,
                                size: 30.0, color: on ? _blue : _ink3)),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? _blue : Colors.transparent,
                    border: Border.all(color: on ? _blue : _g5, width: 1.5),
                  ),
                  child: on
                      ? const _SolarIcon('ph-check',
                          size: 14.0, color: Colors.white)
                      : null,
                ),
              ]),
              const SizedBox(height: 8.0),
              Text(t,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5,
                      color: on ? _blue : _ink2, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

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

/// เส้นเธรดแบบคอมเมนต์ Reddit: เส้นแนวตั้งใต้ไอคอนหัวกลุ่ม (x = 12) โค้งเข้าแถว
/// last = แถวสุดท้าย เส้นจบที่โค้ง ไม่ลากต่อ
class _SoTreeLine extends CustomPainter {
  const _SoTreeLine({required this.last});
  final bool last;

  @override
  void paint(Canvas canvas, Size size) {
    // โค้งเข้าตรงกึ่งกลางบรรทัดชื่อ (padding บน 9 + ครึ่งบรรทัด 14pt ≈ 11)
    const x = 12.0, r = 8.0;
    const mid = 20.0;
    final paint = Paint()
      ..color = const Color(0xFFD5D8DD)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(x, 0.0)
      ..lineTo(x, mid - r)
      ..quadraticBezierTo(x, mid, x + r, mid)
      ..lineTo(size.width - 2.0, mid);
    if (!last) {
      path
        ..moveTo(x, mid - r)
        ..lineTo(x, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SoTreeLine o) => o.last != last;
}

/// ค่าที่ถอดจากบรรทัดคำสั่งยา (ชื่อ + รายละเอียดในใบ) สำหรับเติมฟอร์มยาให้เอง
/// ชื่อในใบเขียนหลายแบบ: "Cef3 2 g iv OD" · "ASA (300) 1 tab po pc" · "Tramol 50 mg iv prn q 6 hr"
/// "0.9% NSS 1,000 ml IV drip" · "Piperacillin + Tazobactam 4.5 g" + "IV ทุก 8 ชม."
class _SoRx {
  _SoRx({
    this.dose,
    this.route,
    this.freq,
    this.time,
    this.stat = false,
    this.prn = false,
    this.rate,
    this.form,
    this.reason,
  });

  /// ขนาดต่อครั้ง เช่น "2 g" "1 เม็ด" "1,000 ml"
  final String? dose;

  /// PO IV IM SC SL
  final String? route;

  /// ตามคำใน master er_drug_frequency
  final String? freq;

  /// ตามคำใน master er_drug_time
  final String? time;
  final bool stat;
  final bool prn;

  /// อัตราหยด เช่น "80 ml/hr"
  final String? rate;

  /// tab cap fluid amp vial
  final String? form;

  /// เงื่อนไข prn เช่น "เมื่อปวด"
  final String? reason;

  /// หน่วยจ่าย (master er_drug_unit) และหน่วยบรรจุ (er_drug_package_unit)
  String? get unit => switch (form) {
        'tab' => 'TAB (เม็ด)',
        'cap' => 'CAP (แคปซูล)',
        'fluid' => 'BAG (ถุง)',
        'amp' => 'AMP',
        'vial' => 'VIAL (ขวด)',
        _ => null,
      };
  String? get pack => switch (form) {
        'tab' => 'TAB',
        'cap' => 'CAP',
        'fluid' => 'BAG',
        'amp' => 'AMP',
        'vial' => 'VIAL',
        _ => null,
      };

  /// จำนวนจ่าย: สารน้ำ 1 ถุง · STAT ตามขนาดครั้งเดียว (เม็ด) หรือ 1
  String? get qty {
    if (form == 'fluid') return '1';
    if (!stat) return null;
    final n = RegExp(r'^(\d+)\s*(เม็ด|แคปซูล)').firstMatch(dose ?? '');
    return n?.group(1) ?? '1';
  }

  /// วิธีใช้เป็นประโยค (ช่องวิธีใช้ แบบฉลากช่วย)
  String? get usage {
    final verb = switch (route) {
      'PO' => 'รับประทาน',
      'IV' => rate != null || form == 'fluid'
          ? 'หยดเข้าหลอดเลือดดำ'
          : 'ฉีดเข้าหลอดเลือดดำ',
      'IM' => 'ฉีดเข้ากล้ามเนื้อ',
      'SC' => 'ฉีดใต้ผิวหนัง',
      'SL' => 'อมใต้ลิ้น',
      _ => null,
    };
    // ไม่รู้ทางให้ยา = ยังเขียนประโยคไม่ได้ (ให้แพทย์เลือกฉลากเอง)
    if (verb == null) return null;
    // ฉลาก HOSxP: "รับประทานครั้งละ 1 เม็ด" (ติดกัน) · "ฉีดเข้ากล้ามเนื้อ ครั้งละ 1 เข็ม"
    final parts = <String>[
      if (verb != null && route == 'PO' && dose != null)
        '$verbครั้งละ $dose'
      else ...[
        if (verb != null) verb,
        if (dose != null && rate == null)
          form == 'fluid' ? dose! : 'ครั้งละ $dose',
      ],
      if (rate != null) rate!,
      if (stat)
        'ทันที 1 ครั้ง'
      else if (freq != null && freq != 'เมื่อมีอาการ')
        freq!,
      if (time != null && time != freq) time!,
      if (prn) reason ?? 'เมื่อมีอาการ',
    ];
    return parts.join(' ');
  }
}

/// ถอดบรรทัดยา (pure: ผลขึ้นกับข้อความอย่างเดียว) · cache กันคำนวณ regex ซ้ำทุกเฟรม
final Map<String, _SoRx> _soRxCache = {};
_SoRx _soParseRx(String name, String detail) => _soRxCache.putIfAbsent(
    '$name\u0000$detail', () => _soParseRxRaw(name, detail));

_SoRx _soParseRxRaw(String name, String detail) {
  final s = '$name $detail';
  final l = s.toLowerCase();
  bool has(String p) => RegExp(p, caseSensitive: false).hasMatch(s);
  String? grab(String p, [int g = 1]) =>
      RegExp(p, caseSensitive: false).firstMatch(s)?.group(g);

  // route
  String? route;
  if (has(r'\bpo\b|รับประทาน|กิน')) {
    route = 'PO';
  } else if (has(r'\bi\.?v\.?\b|drip|หลอดเลือดดำ')) {
    route = 'IV';
  } else if (has(r'\bi\.?m\.?\b|กล้ามเนื้อ')) {
    route = 'IM';
  } else if (has(r'\bs\.?c\.?\b|ใต้ผิวหนัง')) {
    route = 'SC';
  } else if (has(r'\bsl\b|ใต้ลิ้น')) {
    route = 'SL';
  }

  // form
  String? form;
  if (has(r'\btab\b|เม็ด') || (route == 'PO' && has(r'\d\s*×'))) {
    form = 'tab';
  } else if (has(r'\bcap\b|แคปซูล')) {
    form = 'cap';
  } else if (has(r'\bamp\b')) {
    form = 'amp';
  } else if (has(r'nss|acetar|ringer|\bd5|glycerol|mannitol') ||
      ((double.tryParse((grab(r'([\d,]+(?:\.\d+)?)\s*ml\b') ?? '')
                  .replaceAll(',', '')) ??
              0) >=
          100)) {
    form = 'fluid';
  } else if (route == 'IV' || route == 'IM' || route == 'SC') {
    // ยาฉีด = vial · ไม่บอกทาง = ไม่เดา (ให้เลือกเอง)
    form = 'vial';
  }

  // rate
  // อัตราหยดเอาจากชื่อเท่านั้น (ในรายละเอียดมักเป็นเงื่อนไข เช่น "ถ้า BP > … แล้ว 2.5 mg/hr")
  final rate = RegExp(r'(\d+(?:\.\d+)?\s*(?:ml|mg|u)/(?:hr|h|min))\b',
          caseSensitive: false)
      .firstMatch(name)
      ?.group(1);

  // dose: "(300) 1 tab" → 1 เม็ด · "1 × 1" → 1 เม็ด · "2 g" · "1,000 ml" · "0.9 mg/kg"
  String? dose;
  final tabN = grab(r'(\d+(?:\.\d+)?)\s*(?:tab|เม็ด|cap|×)');
  if (tabN != null && (form == 'tab' || form == 'cap' || has(r'\d\s*×'))) {
    dose = '$tabN ${form == 'cap' ? 'แคปซูล' : 'เม็ด'}';
  } else {
    final m = RegExp(
            r'(\d[\d,]*(?:\.\d+)?)\s*(mg/kg|g/kg|mcg|mg|g|ml|mL|units?|u)\b(?!/)',
            caseSensitive: false)
        .firstMatch(name.replaceAll(RegExp(r'^\d+(\.\d+)?%\s*'), ''));
    if (m != null)
      dose =
          '${m.group(1)} ${m.group(2)!.toLowerCase().replaceAll('unit', 'U').replaceAll(RegExp(r'^u$'), 'U')}';
  }

  // frequency → master wording
  String? freq;
  final q = grab(r'(?:\bq\s*|ทุก\s*)(\d+)\s*(?:hr|h|ชม|ชั่วโมง)');
  if (q != null) {
    freq = 'ทุก $q ชั่วโมง';
  } else if (has(r'\b(od|qd)\b|วันละ\s*(1\s*)?ครั้ง')) {
    freq = 'วันละ 1 ครั้ง';
  } else if (has(r'\bbid\b|วันละ\s*2\s*ครั้ง')) {
    freq = 'วันละ 2 ครั้ง';
  } else if (has(r'\btid\b|วันละ\s*3\s*ครั้ง')) {
    freq = 'วันละ 3 ครั้ง';
  } else if (has(r'\bqid\b|วันละ\s*4\s*ครั้ง')) {
    freq = 'วันละ 4 ครั้ง';
  }
  final stat = has(r'\bstat\b');
  final prn = has(r'\bprn\b|เมื่อ(ปวด|มีอาการ|คลื่นไส้)');
  if (stat) {
    freq = 'ทันที (ครั้งเดียว)';
  } else if (freq == null && prn) {
    freq = 'เมื่อมีอาการ';
  }

  // time → master wording (pc/ac + มื้อ · hs)
  String? time;
  final meal = grab(r'\b(pc|ac)\b\s*(เช้า|กลางวัน|เย็น)?', 2);
  if (has(r'\bpc\b')) {
    time = meal == null ? 'หลังอาหาร' : 'หลังอาหาร$meal';
  } else if (has(r'\bac\b')) {
    time = meal == null ? 'ก่อนอาหาร' : 'ก่อนอาหาร$meal';
  } else if (has(r'\bhs\b|ก่อนนอน')) {
    time = 'ก่อนนอน';
  }

  // prn reason from detail ("เมื่อปวด" / "ไข้ ≥ 37.5")
  String? reason;
  if (prn) {
    reason = grab(r'(เมื่อ[^\s,]+)') ??
        (detail.contains('ไข้') ? 'เมื่อมีไข้' : null);
  }
  return _SoRx(
      dose: dose,
      route: route,
      freq: freq,
      time: time,
      stat: stat,
      prn: prn,
      rate: rate,
      form: form,
      reason: reason);
}

/// แถบเวลา 24 ชม. จากตอนนี้: เส้นฐาน · ขีดทุก 6 ชม. (ป้ายชั่วโมง) · จุดเวลาให้ยา
/// จุดแรกเข้ม (ครั้งถัดไป) · prn = เส้นประ ไม่มีจุด · STAT = จุดแดงที่ตอนนี้
class _SoTimelinePainter extends CustomPainter {
  const _SoTimelinePainter({
    required this.now,
    required this.times,
    required this.prn,
    required this.stat,
    required this.labels,
    required this.ink,
    required this.dot,
  });
  final DateTime now;
  final List<DateTime> times;
  final bool prn, stat, labels;
  final Color ink, dot;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 4.0;
    final y = labels ? 10.0 : size.height / 2 - 2.0;
    final w = size.width - r * 2;
    double xOf(DateTime t) =>
        r + w * (t.difference(now).inMinutes / 1440.0).clamp(0.0, 1.0);
    final base = Paint()
      ..color = const Color(0xFFE3E5E8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    if (prn) {
      for (var x = r; x < size.width - r; x += 8.0) {
        canvas.drawLine(Offset(x, y), Offset(x + 4.0, y), base);
      }
    } else {
      canvas.drawLine(Offset(r, y), Offset(size.width - r, y), base);
    }
    // ขีดทุก 6 ชม. ตามนาฬิกาจริง + ป้ายชั่วโมง
    final tick = Paint()
      ..color = const Color(0xFFC9CDD2)
      ..strokeWidth = 1.0;
    final first =
        DateTime(now.year, now.month, now.day, (now.hour ~/ 6 + 1) * 6);
    for (var t = first;
        t.isBefore(now.add(const Duration(hours: 24)));
        t = t.add(const Duration(hours: 6))) {
      final x = xOf(t);
      canvas.drawLine(Offset(x, y - 5.0), Offset(x, y + 5.0), tick);
      if (labels) {
        final tp = TextPainter(
          text: TextSpan(
              text: '${t.hour.toString().padLeft(2, '0')}:00 น.',
              style: TextStyle(
                  fontSize: 10.0, color: ink, fontWeight: FontWeight.w500)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y + 8.0));
      }
    }
    // ตอนนี้: ขีดตั้งเข้มต้นแถบ
    canvas.drawLine(
        Offset(r, y - 7.0),
        Offset(r, y + 7.0),
        Paint()
          ..color = ink
          ..strokeWidth = 1.5);
    for (var i = 0; i < times.length; i++) {
      final c = Offset(xOf(times[i]), y);
      canvas.drawCircle(c, i == 0 ? r + 1.5 : r,
          Paint()..color = i == 0 ? dot : dot.withValues(alpha: 0.45));
      canvas.drawCircle(
          c,
          i == 0 ? r + 1.5 : r,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_SoTimelinePainter o) =>
      o.times != times || o.prn != prn || o.stat != stat || o.labels != labels;
}

/// มุมเว้าระหว่างแท็บหัว folder ของ Progress Note กับตัว folder (สีตัว folder)
class _NoteFillet extends CustomPainter {
  const _NoteFillet(
      {required this.bodyTop, required this.color, this.left = false});
  final double bodyTop;
  final Color color;

  /// left = มุมเว้าอยู่ซ้ายของแท็บ
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width;
    final sq = Path()..addRect(Rect.fromLTWH(0.0, bodyTop - r, r, r));
    final hole = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(left ? 0.0 : r, bodyTop - r), radius: r));
    canvas.drawPath(Path.combine(PathOperation.difference, sq, hole),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NoteFillet o) =>
      o.bodyTop != bodyTop || o.color != color || o.left != left;
}

/// เส้นขอบแท็บที่เลือก (บน + ข้าง ไม่มีล่าง) มุมบนโค้ง · พื้นสีแผงปิดเส้นบนของตัว folder ใต้แท็บ
/// ข้างที่มีมุมเว้า เส้นข้างหยุดก่อนถึงขอบ folder (มุมเว้าวาดต่อในกล่องข้าง ๆ)
class _TabOutline extends CustomPainter {
  const _TabOutline(
      {required this.th,
      required this.f,
      required this.color,
      required this.first,
      required this.bg});
  final double th, f;
  final Color color, bg;
  final bool first;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0;
    final w = size.width;
    canvas.drawRect(Rect.fromLTWH(0.0, 0.5, w, th + 0.5), Paint()..color = bg);
    final yl = first ? th + 1.0 : th - f, yr = th - f;
    final path = Path()
      ..moveTo(0.25, yl)
      ..lineTo(0.25, r)
      ..arcToPoint(Offset(r, 0.25), radius: const Radius.circular(r))
      ..lineTo(w - r, 0.25)
      ..arcToPoint(Offset(w - 0.25, r), radius: const Radius.circular(r))
      ..lineTo(w - 0.25, yr);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = color);
  }

  @override
  bool shouldRepaint(_TabOutline o) =>
      o.th != th || o.first != first || o.color != color || o.bg != bg;
}

/// มุมเว้าระหว่างแท็บกับเส้นบนตัว folder (เส้น 0.5) · ปิดเส้นบนตัว folder ใต้มุมด้วยสีแผง
class _TabFillet extends CustomPainter {
  const _TabFillet({required this.th, required this.color, this.left = false});
  final double th;
  final Color color;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final f = size.width;
    canvas.drawRect(
        Rect.fromLTWH(0.0, th - f, f, f + 1.0), Paint()..color = _panel);
    final p = Path();
    if (left) {
      p
        ..moveTo(f - 0.25, th - f)
        ..arcToPoint(Offset(0.0, th + 0.25),
            radius: Radius.circular(f), clockwise: true);
    } else {
      p
        ..moveTo(0.25, th - f)
        ..arcToPoint(Offset(f, th + 0.25),
            radius: Radius.circular(f), clockwise: false);
    }
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = color);
  }

  @override
  bool shouldRepaint(_TabFillet o) =>
      o.th != th || o.color != color || o.left != left;
}

/// เวลาที่ยืนยันแต่ละรายการ (ระดับไฟล์: hot reload ได้) ใช้ตัดสินว่าเล่น motion หรือไม่
final Map<String, DateTime> _soDoneAt = {};

/// HN ที่กางเมนูเพิ่มคำสั่งต่อเนื่องแล้ว (แฟ้มว่าง)
final Set<String> _soContOpen = {};

/// cache บรรทัดสรุปรายการ (id → (ลายเซ็นค่าที่กรอก, ข้อความ))
final Map<String, (int, String)> _soDetailCache = {};
final Map<String, String?> _soUsageAutoCache = {};

/// "ยืนยันแล้ว": ตอนเพิ่งยืนยัน วงเขียวเด้งขึ้น (เกินแล้วหดกลับ) ข้อความเลื่อนเข้าจากซ้าย
/// พื้นเขียวจางวาบแล้วหาย · fresh = false = แสดงนิ่ง
class _SoDoneBadge extends StatefulWidget {
  const _SoDoneBadge({super.key, required this.fresh, required this.style});
  final bool fresh;
  final TextStyle style;
  @override
  State<_SoDoneBadge> createState() => _SoDoneBadgeState();
}

class _SoDoneBadgeState extends State<_SoDoneBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: widget.fresh ? 0.0 : 1.0);

  @override
  void initState() {
    super.initState();
    if (widget.fresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // นุ่ม: ไม่เด้งเกิน · วงขยายจาก 0.6 + จางเข้า · ข้อความตามมาติด ๆ
          final pop = Curves.easeOutCubic.transform((t / 0.38).clamp(0.0, 1.0));
          final txt =
              Curves.easeOutCubic.transform(((t - 0.1) / 0.4).clamp(0.0, 1.0));
          // ระหว่างแสงเขียวกวาด (1.4 วิ เท่ากัน): badge กลับสีเป็นพื้นเขียวทึบ ไม่กลืนกับแสง
          // ครึ่งหลังพื้นขาวจางพร้อมแสง
          final chip = t >= 1.0
              ? 0.0
              : t < 0.5
                  // ขึ้นพร้อมวงเขียว (ไม่โผล่เป็นแคปซูลว่างก่อน)
                  ? pop
                  : 1.0 - Curves.easeInOut.transform((t - 0.5) / 0.5);
          return Container(
            padding: const EdgeInsets.fromLTRB(6.0, 3.0, 8.0, 3.0),
            decoration: BoxDecoration(
              // ระหว่างแสงกวาด: กลับสี = พื้นเขียวทึบ ตัวขาว (เขียวเดียวกับต้นแสง ไม่ใช่เขียวอ่อนคนละโทน)
              color: _green.withValues(alpha: chip),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Opacity(
                opacity: pop,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * pop,
                  child: Icon(Icons.check_circle_rounded,
                      size: 15.0, color: Color.lerp(_green, _panel, chip)),
                ),
              ),
              const SizedBox(width: 4.0),
              Opacity(
                opacity: txt,
                child: Transform.translate(
                  offset: Offset(-4.0 * (1.0 - txt), 0.0),
                  child: Text('กรอกแล้ว',
                      style: widget.style
                          .copyWith(color: Color.lerp(_green, _panel, chip))),
                ),
              ),
            ]),
          );
        },
      );
}

/// แสงสำเร็จบนการ์ดที่เพิ่งยืนยัน: gradient เขียวกวาดจากขอบขวาไปซ้าย แล้วจางหาย
/// อยู่ใต้เนื้อหาการ์ด · fresh = false = ไม่วาด
class _SoSuccessSweep extends StatefulWidget {
  const _SoSuccessSweep({super.key, required this.fresh, this.color = _green});
  final bool fresh;

  /// สีแสง: เขียว = ยืนยัน · แดง = ลบ
  final Color color;
  @override
  State<_SoSuccessSweep> createState() => _SoSuccessSweepState();
}

class _SoSuccessSweepState extends State<_SoSuccessSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: widget.fresh ? 0.0 : 1.0);

  @override
  void initState() {
    super.initState();
    if (widget.fresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          if (t >= 1.0) return const SizedBox.shrink();
          // ขอบนำเลื่อนจากขวา (0) ไปซ้าย (1) · ช่วงท้ายทั้งผืนจางออก
          final reach =
              Curves.easeOutCubic.transform((t / 0.65).clamp(0.0, 1.0));
          final fade =
              t < 0.5 ? 1.0 : 1.0 - Curves.easeInOut.transform((t - 0.5) / 0.5);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  widget.color.withValues(alpha: 0.45 * fade),
                  widget.color.withValues(alpha: 0.28 * fade),
                  widget.color.withValues(alpha: 0.0),
                ],
                stops: [
                  0.0,
                  (reach * 0.75).clamp(0.0, 1.0),
                  reach.clamp(0.001, 1.0),
                ],
              ),
            ),
          );
        },
      );
}

/// สถานะแถวในแบบร่าง: วงเทาดินสอนิ่ง (ต้องระบุ) ↔ badge ฟ้าดินสอเขียน (กำลังกรอก)
/// morph กล่องเดียว: ยืดกว้าง + เปลี่ยนสี + สลับไอคอน · สร้างใหม่ขณะ editing = เล่นจากวงเทา
class _SoEditBadge extends StatefulWidget {
  const _SoEditBadge({required this.editing});
  final bool editing;
  @override
  State<_SoEditBadge> createState() => _SoEditBadgeState();
}

class _SoEditBadgeState extends State<_SoEditBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    // เริ่มหลังเฟรมแรก (แถวเพิ่งสร้าง) ให้เห็นวงเทาก่อนแล้วค่อยยืด
    if (widget.editing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.editing) _c.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _SoEditBadge old) {
    super.didUpdateWidget(old);
    if (widget.editing != old.editing) {
      widget.editing ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Tooltip(
        message: widget.editing ? 'กำลังระบุรายละเอียด' : 'ต้องระบุรายละเอียด',
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_c.value);
            // ไอคอน: นิ่งจาง/ย่อออกช่วงแรก · เขียนจาง/ขยายเข้าช่วงหลัง
            final outT = (t / 0.5).clamp(0.0, 1.0);
            final inT = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
            return Container(
              width: 26.0 + 16.0 * t,
              height: 26.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.lerp(
                    const Color(0xFFF1F3F6), const Color(0xFFE6EDFA), t),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Stack(alignment: Alignment.center, children: [
                if (outT < 1.0)
                  Opacity(
                    opacity: 1.0 - outT,
                    child: Transform.scale(
                        scale: 1.0 - 0.3 * outT,
                        child: const Icon(Icons.edit_outlined,
                            size: 14.0, color: _ink2)),
                  ),
                if (inT > 0.0)
                  Opacity(
                    opacity: inT,
                    child: Transform.scale(
                        scale: 0.7 + 0.3 * inT,
                        child: const Padding(
                            padding: EdgeInsets.only(left: 2.0),
                            child: _PencilWriting())),
                  ),
              ]),
            );
          },
        ),
      );
}

/// ดินสอกำลังเขียน (วนลูป นุ่ม): ดินสอลากเส้นตรงจากซ้ายไปขวา แล้วเส้นค่อย ๆ จาง
/// ดินสอเลื่อนกลับจุดเริ่ม แล้วเขียนใหม่
class _PencilWriting extends StatefulWidget {
  const _PencilWriting();
  @override
  State<_PencilWriting> createState() => _PencilWritingState();
}

class _PencilWritingState extends State<_PencilWriting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 30.0,
        height: 20.0,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            // 0..0.65 ลากเส้น · 0.65..1 เส้นจาง + ดินสอเลื่อนกลับ
            final draw =
                Curves.easeInOutSine.transform((t / 0.65).clamp(0.0, 1.0));
            final back = t < 0.65
                ? 0.0
                : Curves.easeInOutSine.transform((t - 0.65) / 0.35);
            const x0 = 2.0, len = 18.0, base = 16.0;
            final tipX = x0 + len * (draw - back);
            final fade = 1.0 - back;
            return Stack(clipBehavior: Clip.none, children: [
              // เส้นตรงที่เขียนแล้ว (จางลงตอนดินสอกลับ)
              Positioned(
                left: x0,
                top: base - 0.6,
                child: Container(
                  width: len * draw,
                  height: 1.2,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.5 * fade),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
              ),
              // ปลายดินสอ (มุมล่างซ้ายของไอคอน) อยู่บนเส้น
              Positioned(
                left: tipX - 1.0,
                top: base - 13.0,
                child: const Icon(Icons.edit_rounded, size: 14.0, color: _blue),
              ),
            ]);
          },
        ),
      );
}

/// appear ของแถวที่เพิ่งเพิ่ม: เลื่อนให้อยู่ในจอก่อน → กางความสูง + จาง + เลื่อนจากขวา
/// → พื้นแถวไฮไลต์ฟ้าจางแล้วค่อย ๆ หาย · animate = false = แสดงทันที
class _SoAppear extends StatefulWidget {
  const _SoAppear(
      {super.key,
      required this.animate,
      this.leaving = false,
      required this.child});
  final bool animate;

  /// ถูกลบ: เล่นย้อน (จาง + เลื่อนออกขวา + หุบ)
  final bool leaving;
  final Widget child;
  @override
  State<_SoAppear> createState() => _SoAppearState();
}

class _SoAppearState extends State<_SoAppear> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: widget.animate ? 0.0 : 1.0);
  late final AnimationController _hl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    // ถูกลบ (สร้างใหม่ในแท็บที่สลับไป): เริ่มเต็มแล้วเล่นหาย
    if (widget.leaving) {
      _c.value = 1.0;
      _c.duration = const Duration(milliseconds: 420);
      // เลื่อนให้เห็นก่อน แล้วค่อยเล่นหาย
      // เลื่อนให้เห็น → แสงแดงกวาด (การ์ด) ~0.45 วิ → หุบหาย
      _reveal()
          .then((_) => Future.delayed(const Duration(milliseconds: 450)))
          .then((_) {
        if (mounted) _c.reverse(from: 1.0);
      });
      return;
    }
    if (!widget.animate) return;
    // กาง + ไฮไลต์เริ่มพร้อมกันทันที · เลื่อนหาเฉพาะเมื่อแถวอยู่นอกจอ (พร้อมกัน ไม่ต่อคิว)
    _c.forward();
    _hl.forward();
    _reveal();
  }

  /// เลื่อนหาเฉพาะเมื่อแถวอยู่นอกจอ
  /// เสร็จเมื่อเลื่อนเสร็จ (ไม่ต้องเลื่อน = เสร็จทันทีหลังเฟรมนี้)
  Future<void> _reveal() {
    final done = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = mounted ? context.findRenderObject() as RenderBox? : null;
      final sc = mounted ? Scrollable.maybeOf(context) : null;
      final view = sc?.context.findRenderObject() as RenderBox?;
      if (box != null && view != null) {
        final top = box.localToGlobal(Offset.zero).dy;
        final vt = view.localToGlobal(Offset.zero).dy;
        // ความสูงจริงหลังกาง ~ 64: นอกจอ (บน/ล่าง) ค่อยเลื่อน
        if (top < vt || top + 64.0 > vt + view.size.height) {
          await Scrollable.ensureVisible(context,
              alignment: 0.4,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic);
        }
      }
      done.complete();
    });
    return done.future;
  }

  @override
  void didUpdateWidget(_SoAppear old) {
    super.didUpdateWidget(old);
    if (widget.leaving && !old.leaving) {
      _hl.value = 0.0;
      _c.duration = const Duration(milliseconds: 420);
      _reveal()
          .then((_) => Future.delayed(const Duration(milliseconds: 450)))
          .then((_) {
        // ติ๊กกลับมาระหว่างรอเลื่อน: ไม่ต้องหาย
        if (mounted && widget.leaving) _c.reverse(from: 1.0);
      });
    } else if (!widget.leaving &&
        (old.leaving || (!_c.isAnimating && _c.value < 1.0))) {
      // ติ๊กกลับมาก่อนหายเสร็จ (กดเลือก/ไม่เลือกรัว ๆ): กางกลับจากจุดที่ค้าง ไม่ค้างหุบ
      _c.duration = const Duration(milliseconds: 320);
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _hl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);
    final fade = CurvedAnimation(
        parent: _c, curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    // ไฮไลต์: ขึ้นเร็วช่วงแรก แล้วจางยาว
    final hl = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 80),
    ]).animate(_hl);
    return SizeTransition(
      sizeFactor: size,
      axisAlignment: -1.0,
      child: AnimatedBuilder(
        animation: Listenable.merge([fade, hl]),
        builder: (context, c) => DecoratedBox(
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08 * hl.value),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Opacity(
            opacity: fade.value,
            child: Transform.translate(
                offset: Offset((1.0 - fade.value) * 12.0, 0.0), child: c),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// วงความคืบหน้าเล็กบนแท็บแฟ้ม: รางเทา + ส่วนที่กรอกแล้ว (เริ่ม 12 นาฬิกา)
class _MiniDonut extends CustomPainter {
  const _MiniDonut(this.v, this.color);
  final double v;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 3.0;
    final r = Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        r, 0.0, math.pi * 2, false, p..color = const Color(0xFFE3E6EC));
    if (v > 0.0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v.clamp(0.0, 1.0), false,
          p..color = color);
    }
  }

  @override
  bool shouldRepaint(_MiniDonut o) => o.v != v || o.color != color;
}

/// ภาพประกอบแฟ้มว่าง: กระดาษ A4 เปล่าวางราบบนโต๊ะ (มุมมอง 3/4) มุมซ้ายล่างม้วนขึ้น
/// (ม้วนแบบเดียวกับกระดาษปลาย stepper) มีเงานุ่มใต้แผ่น
class _SoEmptyPaperArt extends StatelessWidget {
  const _SoEmptyPaperArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220.0,
      height: 136.0,
      child: Stack(clipBehavior: Clip.none, children: [
        // เงาโต๊ะใต้กระดาษ
        Positioned(
          left: 24.0,
          right: 24.0,
          top: 64.0,
          height: 70.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              gradient: const RadialGradient(colors: [
                Color(0x1A001B7C),
                Color(0x00001B7C),
              ]),
            ),
          ),
        ),
        Positioned(
          left: 61.0,
          top: -2.0,
          child: Transform(
            alignment: Alignment.center,
            // วางราบแบบมุมมอง 3/4: เอนลง ~40° แล้วหมุนในระนาบ 30° · perspective อ่อน
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..rotateX(0.7)
              ..rotateZ(-0.52),
            // กระดาษ A4 (1 : 1.414): แผ่น · เส้นบรรทัด · ม้วนมุมวาดทับหน้าสุด
            child: CustomPaint(
              painter: const _SoDogEarPaper(),
              foregroundPainter: const _SoDogEarPaper(curl: true),
              child: Container(
                width: 98.0,
                height: 138.6,
                padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final lw in const [
                        40.0,
                        70.0,
                        60.0,
                        74.0,
                        66.0,
                        48.0
                      ])
                        Container(
                          width: lw,
                          height: 4.0,
                          margin: const EdgeInsets.only(bottom: 11.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F6),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                    ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// กระดาษขาวขอบบาง มุมซ้ายล่างม้วนขึ้น: แผ่นตัดโค้งที่มุม + ด้านหลังกระดาษ (เทาอมกรมท่า
/// ไล่เข้มที่รอยม้วน) แบบกระดาษปลาย stepper · curl = วาดเฉพาะส่วนม้วน (ทับเส้นบรรทัด)
class _SoDogEarPaper extends CustomPainter {
  const _SoDogEarPaper({this.curl = false});
  final bool curl;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const f = 30.0, r = 5.0;
    // จุดที่แผ่นเริ่มม้วน: ขอบล่าง (a) และขอบซ้าย (b)
    final a = Offset(f * 1.15, h), b = Offset(0.0, h - f * 1.1);
    if (!curl) {
      final sheet = Path()
        ..moveTo(r, 0.0)
        ..lineTo(w - r, 0.0)
        ..quadraticBezierTo(w, 0.0, w, r)
        ..lineTo(w, h - r)
        ..quadraticBezierTo(w, h, w - r, h)
        ..lineTo(a.dx, a.dy)
        // รอยม้วน: โค้งเว้าเข้าหาในแผ่น
        ..quadraticBezierTo(f * 0.55, h - f * 0.55, b.dx, b.dy)
        ..lineTo(0.0, r)
        ..quadraticBezierTo(0.0, 0.0, r, 0.0)
        ..close();
      canvas.drawPath(sheet, Paint()..color = const Color(0xFFF7F8FB));
      canvas.drawPath(
          sheet,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFFE6E9EF));
      return;
    }
    // ด้านหลังที่ม้วนขึ้น: จากรอยม้วนโป่งเข้าในแผ่น ปลายแหลมชี้ขึ้นขวา
    final tip = Offset(f * 1.05, h - f * 1.0);
    final back = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(f * 1.25, h - f * 0.45, tip.dx, tip.dy)
      ..quadraticBezierTo(f * 0.45, h - f * 1.05, b.dx, b.dy)
      ..quadraticBezierTo(f * 0.55, h - f * 0.55, a.dx, a.dy)
      ..close();
    canvas.drawPath(
        back,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF7D86A8), Color(0xFFC9CEDD)],
          ).createShader(Rect.fromPoints(Offset(0.0, h), tip)));
  }

  @override
  bool shouldRepaint(covariant _SoDogEarPaper old) => old.curl != curl;
}

/// สถานะของตัวเลือกวันเวลา (_dtPanel): ค่าที่เลือก · เดือนที่แสดง · วงล้อชั่วโมง/นาที
class _DtState {
  _DtState(DateTime initial)
      : sel = initial,
        month = DateTime(initial.year, initial.month),
        hc = FixedExtentScrollController(initialItem: initial.hour),
        mc = FixedExtentScrollController(initialItem: initial.minute);
  DateTime sel;
  DateTime month;
  final FixedExtentScrollController hc, mc;
  void dispose() {
    hc.dispose();
    mc.dispose();
  }
}

/// เหรียญสถานะเอียงเฉียงแบบ perspective (หมุนแกน Y/X) มีความหนาที่ขอบ ไม่มีเงา
/// done = เขียว ✓ (ทำแล้ว) · wait = เทาอมฟ้า นาฬิกา (รอรับ) · หน้าเหรียญไล่สีมีจุดแสงมุมซ้ายบน
class _SoStatusCoin extends StatelessWidget {
  const _SoStatusCoin.done()
      : icon = 'ph-check',
        ink = Colors.white,
        face = const [Color(0xFF5BE08F), Color(0xFF22B45E)],
        side = const [Color(0xFF1B8F4C), Color(0xFF0F6B37)];
  const _SoStatusCoin.wait()
      : icon = 'ph-clock',
        ink = const Color(0xFF5F6B7D),
        face = const [Color(0xFFF4F6FA), Color(0xFFD6DCE6)],
        side = const [Color(0xFFBCC4D0), Color(0xFF9EA8B7)];

  /// Lab เก็บสิ่งส่งตรวจแล้ว รอผล = ฟ้า นาฬิกาทราย
  const _SoStatusCoin.lab()
      : icon = 'ph-hourglass',
        ink = Colors.white,
        face = const [Color(0xFF8DB4FF), Color(0xFF3E73E6)],
        side = const [Color(0xFF2F5CC4), Color(0xFF1E3F94)];

  /// Lab ผลออกแล้ว = เขียว ใบผล
  const _SoStatusCoin.result()
      : icon = 'ph-file-text',
        ink = Colors.white,
        face = const [Color(0xFF5BE08F), Color(0xFF22B45E)],
        side = const [Color(0xFF1B8F4C), Color(0xFF0F6B37)];

  final String icon;
  final Color ink;
  final List<Color> face, side;

  @override
  Widget build(BuildContext context) {
    // เหรียญ 3D จริง: แผ่นซ้อนหลายชั้นตามแกน Z (ขอบหนา) · หน้าเหรียญอยู่ชั้นหน้าสุด
    // หมุนแล้วเห็นความหนาทุกมุม (ไม่แบนเป็นเส้นตอนพลิก)
    Widget disc(Widget child, double z) => Transform(
          transform: Matrix4.translationValues(0.0, 0.0, z),
          child: child,
        );
    const n = 6;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.003)
        ..rotateY(0.55)
        ..rotateX(0.18),
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: Stack(children: [
          // ขอบหนา: ชั้นหลังเข้ม → ชั้นหน้าสว่าง
          for (var k = n; k >= 1; k--)
            Positioned.fill(
              child: disc(
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(side.first, side.last, k / n),
                  ),
                ),
                // ชั้นขอบอยู่หลังหน้าเหรียญ (z ลบ) = ความหนาโผล่ทางซ้าย หน้าเหรียญหันขวา
                -k * 0.9,
              ),
            ),
          // หน้าเหรียญ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0.4, -0.5),
                  radius: 1.0,
                  colors: face,
                ),
              ),
            ),
          ),
          Center(
            child: _SolarIcon(icon,
                size: icon == 'ph-check' ? 20.0 : 19.0,
                color: ink,
                grow: icon == 'ph-check' ? 0.0 : 0.6),
          ),
        ]),
      ),
    );
  }
}

/// ภาพประกอบทิศถ่าย X-ray (มองจากบน): ลำตัว + ศีรษะหันหน้าลง (จมูกชี้ล่าง)
/// ลำรังสีเส้นประจากหลอดเอกซเรย์ทะลุตัวไปแผ่นรับภาพ · angle = หมุนลำรังสีรอบตัว
/// (0 = PA หลัง→หน้า · π = AP หน้า→หลัง · −π/2 = Lateral ซ้าย→ขวา · −π/4 = Oblique)
class _XrViewPainter extends CustomPainter {
  const _XrViewPainter(this.angle, {this.on = false});
  final double angle;
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final beam = on ? _blue : const Color(0xFF8A94A6);
    // ลำรังสี + หลอด + แผ่นรับภาพ (หมุนรอบตัวผู้ป่วย)
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final dash = Paint()
      ..color = beam
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (var y = -17.0; y < 14.0; y += 5.0) {
      canvas.drawLine(Offset(0.0, y), Offset(0.0, y + 2.5), dash);
    }
    // หัวลูกศรก่อนถึงแผ่น
    canvas.drawPath(
        Path()
          ..moveTo(-4.0, 13.0)
          ..lineTo(4.0, 13.0)
          ..lineTo(0.0, 18.0)
          ..close(),
        Paint()..color = beam);
    // หลอดเอกซเรย์ (ต้นลำ)
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-6.0, -24.0, 12.0, 6.0),
            const Radius.circular(2.0)),
        Paint()..color = const Color(0xFF5F6B7D));
    // แผ่นรับภาพ (ปลายลำ)
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-14.0, 19.5, 28.0, 3.5),
            const Radius.circular(1.5)),
        Paint()
          ..color = on ? const Color(0xFF8DB4FF) : const Color(0xFFC9D1DE));
    canvas.restore();
    // ผู้ป่วยมองจากบน: ไหล่ (วงรี) + ศีรษะ + จมูกชี้ลง = ด้านหน้า
    final body = Paint()..color = const Color(0xFFF1F3F7);
    final edge = Paint()
      ..color = const Color(0xFF8A94A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final torso = Rect.fromCenter(center: c, width: 30.0, height: 14.0);
    canvas.drawOval(torso, body);
    canvas.drawOval(torso, edge);
    canvas.drawCircle(c, 6.0, body);
    canvas.drawCircle(c, 6.0, edge);
    canvas.drawPath(
        Path()
          ..moveTo(c.dx - 2.2, c.dy + 5.2)
          ..lineTo(c.dx + 2.2, c.dy + 5.2)
          ..lineTo(c.dx, c.dy + 8.5)
          ..close(),
        Paint()..color = const Color(0xFF8A94A6));
  }

  @override
  bool shouldRepaint(covariant _XrViewPainter old) =>
      old.angle != angle || old.on != on;
}
