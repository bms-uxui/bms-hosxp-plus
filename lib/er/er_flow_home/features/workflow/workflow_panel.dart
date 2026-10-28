// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ความสูงคงที่ของการ์ดช่องกรอกใน flipbook
const double _flipH = 128.0;

/// บล็อกที่แสดงอยู่ตอนนี้: ของผู้ช่วย (รอบล่าสุดของขั้นนี้) + บล็อกตั้งต้น
/// ฟอร์มกับหน้าสรุปยืนยันใช้ของขั้นเสมอ (ผู้ช่วยส่งมาแทนไม่ได้)
/// การ์ดของระบบที่ผู้ช่วยแทนไม่ได้ (เลือก template · สรุปความเร่งด่วน)
bool _pinnedBlock(ErUiBlock b) =>
    b.data['order_pick'] == true ||
    b.data['so_doc'] == true ||
    b.data['esi_ai'] == true ||
    b.data['hpi_pick'] == true ||
    b.data['pe_pick'] == true ||
    b.data['appt'] == true;

/// ลำดับการนำเสนอการ์ด: ภาพรวม → อันตราย → ข้อมูลประกอบ → สิ่งที่ต้องทำ → ไปต่อ
const Map<ErUiType, int> _uiOrder = {
  ErUiType.brief: 0,
  ErUiType.alert: 1,
  ErUiType.timer: 2,
  ErUiType.vitals: 3,
  ErUiType.labs: 4,
  ErUiType.imaging: 5,
  ErUiType.checklist: 6,
  ErUiType.form: 7,
  ErUiType.orderSet: 8,
  ErUiType.nextStep: 9,
};

/// แผงผู้ช่วยข้างวงล้อ: ข้อความ → ลำดับสิ่งที่ชี้ → คำอธิบาย หรือการ์ดที่ต้องลงมือทำ
/// หน้าตาเดียวกับแผงในหน้า (ขาว ขอบบาง มุม 14) ไม่ใช่การ์ดชนิดใหม่
/// แถบผู้ช่วยแถบเดียวติดล่างจอ: ทำทีละเรื่อง
/// ซ้าย = ขั้น + คำถามของผู้ช่วย · กลาง = ช่องที่ต้องกรอกตอนนี้ช่องเดียว
/// ขวา = เปลี่ยนหน้า + ไมค์ (กดค้างพูด) + ปิด · สูงคงที่ ไม่บังหน้าจอส่วนบน
const double _barH = 176.0;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowWorkflowPanelState on State<ErFlowHomeWidget> {
  /// รุ่นของหน้าผู้ช่วย (เปลี่ยนแล้วการ์ดสลับใหม่)
  int _agentUiGen = 0;
  final Set<int> _speechDone = {};

  /// ช่องข้อความที่ผู้ช่วยเพิ่งแก้: ข้อความเดิม + รุ่น (แสดง diff แบบพิมพ์ทีละตัว)
  final Map<String, (String, int)> _diffs = {};

  // ---------------------------------------------- โหมดพูดเพื่อบันทึก
  // ตามแบบ 186:68 — แถบโค้งครึ่งวงกลมด้านล่าง ไมค์ใหญ่ตรงกลาง
  // ขั้นตอนเรียงเป็นวงกลมบนแถบโค้ง (แบบอ้างอิง: มาตรวัดที่ติ๊กขั้นที่ผ่านแล้ว)
  // เขียวมีเครื่องหมายถูก = ทำแล้ว · ขอบน้ำเงิน = ขั้นปัจจุบัน · ขาว = ยังไม่ถึง

  /// HN ของคนไข้ที่ข้อมูลการพูดปัจจุบันเป็นของ
  String? _speechHn;

  final ScrollController _stepperScroll = ScrollController();
}

extension _FeaturesWorkflowWorkflowPanelPart on _ErFlowHomeWidgetState {
  /// ไม่ระบุขั้น = ขั้นแรกที่แสดง (แพทย์ข้ามขั้นทบทวนเคสที่ซ่อนไว้)
  void _openSpeech({int? step}) {
    if (_speechHn != _caseP().hn) {
      _resetSpeechCase();
      _speechHn = _caseP().hn;
    }
    final wasOpen = _speechOpen && _wfReady;
    setState(() {
      _speechOpen = true;
      _wfShown = true;
      _speechStep = step ?? _firstStep;
      _summaryOpen = false;
      // กดเมนูขั้นใน workflow = กลับหน้าคำแนะนำ (หน้าแรกของขั้น) ทุกครั้ง
      // ตั้ง _reviewShown ไว้ด้วย ไม่ให้ขั้นที่ครบแล้วเด้งไปหน้าสรุปเอง
      if (step != null) {
        _uiIdx = 0;
        _formAt = 0;
        // โหมดกางแถวปกติ (แก้ไข) ใช้ชั่วคราวในหน้านั้น: เปลี่ยนขั้นแล้วกลับเป็นซ่อน
        _peShowNormal = false;
        _formFwd = false;
        _reviewShown = step;
        // การรับเข้าห้อง ER แบบ stepper: เปิดขั้นใหม่ = เริ่มหน้าแรก
        _admPage = 0;
        // พยาบาล การรับเข้าห้อง ER: ซ้ายเปิดข้อมูลจากจุดส่งตรวจ (อ่านอย่างเดียว) ไว้ยืนยัน 2026-10-20
        if (ErSession.instance.isNurse && _steps[step].$2 == 'คัดกรอง') {
          _detailTab = 1;
        }
      }
    });
    // แผงยังไม่กาง: รอกางเสร็จ (560 ms) ค่อยใส่เนื้อหา + ให้ผู้ช่วยทักทาย
    // ไม่แย่งเฟรม animation · หน้าที่ไม่ใช่ภาพรวม (ไม่มีแผงกาง) ทักทายเลย
    if (wasOpen || !_clyOn) {
      _agentGreet();
    } else {
      Future.delayed(const Duration(milliseconds: 580), _wfMakeReady);
    }
  }

  /// ใส่เนื้อหาจริงของแผง workflow + ทักทาย (เรียกซ้ำได้ ทำครั้งเดียว)
  void _wfMakeReady() {
    if (!mounted || !_speechOpen || _wfReady) return;
    setState(() => _wfReady = true);
    _agentGreet();
  }

  void _confirmStep() {
    _skipAsked = -1;
    _uiIdx = 0;
    _formAt = 0;
    _orderPick.clear();
    _uiTicks.clear();
    _stopRecord(send: false);
    _robot.stop();
    setState(() {
      _speechDone.add(_speechStep);
      _speechStep = _stepNext(_speechStep) ?? _speechStep;
    });
    _agentGreet();
  }

  void _closeSpeech() {
    _agentGen++;
    _robot.stop();
    _stopRecord(send: false);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _speechOpen = false;
      // หุบกลับด้านกับตอนกาง: เนื้อหาจางออกก่อน (220ms) เหลือการ์ดขาวว่างหดกลับเป็นราง
      _wfReady = false;
      _accPaneDrop();
      _orderEditing = null;
      _agentBusy = false;
      _agentStatus = '';
      _agentChoices = null;
    });
  }

  /// หน้าสรุปก่อนบันทึก: ทุกช่องของขั้นพร้อมค่า แตะแถวเพื่อกลับไปแก้ช่องนั้น
  /// ครบแล้วจึงกดยืนยันได้ ยังไม่ครบปุ่มจะพาไปช่องแรกที่ขาด
  Widget _reviewCard(ErUiBlock b) {
    // สั่งการรักษา: สรุปจากแบบร่างคำสั่งจริง (One Day / Continuation · แยกประเภท) ไม่ใช่ช่องฟอร์มเดิม
    if (_steps[_speechStep].$2 == 'สั่งการรักษา') return _soReview();
    final labels = _stepLabels(_speechStep);
    final known = _filled[_speechStep];
    final missing = [
      for (final l in labels)
        if (!_fieldDone(_speechStep, l)) l
    ];
    final seq = _uiSeq;
    final formIdx = seq.indexWhere((x) => x.type == ErUiType.form);
    void editAt(String l) {
      if (formIdx < 0) return;
      // หัตถการ: "proc:i" = เปิดหน้าแก้หัตถการรายการที่ i
      if (l.startsWith('proc:')) {
        setState(() {
          _formFwd = false;
          _uiIdx = formIdx;
          _formAt = 0;
        });
        _procOpen(int.tryParse(l.substring(5)));
        return;
      }
      final i = _isDxStep(_speechStep)
          ? _dxPageOf(l)
          : _formFields(seq[formIdx]).indexOf(l);
      setState(() {
        _formFwd = false;
        _uiIdx = formIdx;
        _formAt = i < 0 ? 0 : i;
      });
    }

    final done = missing.isEmpty;
    final stepName = _steps[_speechStep].$2;
    // ค่าที่แสดง: หลายค่าขึ้นบรรทัดใหม่ (ไม่ใช้ "·") · ICD-10 บรรทัดละรหัส
    String plain(String v) => v.replaceAll(' · ', '  ');
    String valueOf(String l) => _needsDetail(_speechStep, l)
        ? 'ผิดปกติ ต้องระบุรายละเอียด'
        : l == _erInLabel
            ? _erInSummary()
            : [
                known[l] ?? 'ยังไม่ได้กรอก',
                if ((known['$l - รายละเอียด'] ?? '').isNotEmpty)
                  known['$l - รายละเอียด']!,
              ].join('\n');
    // แยกเป็นการ์ดตามหมวด แบบหน้าสรุปซักประวัติของพยาบาล:
    // (ชื่อการ์ด, [(หัวข้อ, ค่า, ครบ, ช่องที่จะกลับไปแก้)])
    final secs = <(String, List<(String, String, bool, String)>)>[];
    final rest = <(String, String, bool, String)>[];
    for (final l in labels) {
      final ok = _fieldDone(_speechStep, l);
      // หัตถการ: การ์ดละรายการ (ชื่อหัตถการเป็นหัวการ์ด) ICD-9 วันที่ ผู้สั่ง ผู้ทำ ผู้ช่วย รายละเอียด
      if (l == _procLabel) {
        final items = _procItems();
        final codes = _FeaturesWorkflowProcPart(this)._icd9Codes;
        String ppl(String? v) =>
            (v ?? '').split('\n').where((x) => x.trim().isNotEmpty).join('\n');
        if (items.isEmpty) {
          rest.add((l, 'ยังไม่ได้กรอก', false, l));
        }
        for (final (i, m) in items.indexed) {
          final e = 'proc:$i';
          secs.add((
            m['proc'] ?? 'หัตถการ',
            [
              (
                'ICD-9-CM',
                m['icd'] == null
                    ? 'ยังไม่ได้เลือก'
                    : [if (codes[m['icd']] case final c?) c, m['icd']!]
                        .join('  '),
                m['icd'] != null,
                e
              ),
              if (m['at'] case final a?) ('วันที่ทำ', a, true, e),
              ('ผู้สั่ง', m['by'] ?? 'ยังไม่ได้เลือก', m['by'] != null, e),
              (
                'ผู้ทำ',
                ppl(m['doer']).isEmpty ? 'ยังไม่ได้เลือก' : ppl(m['doer']),
                ppl(m['doer']).isNotEmpty,
                e
              ),
              if (ppl(m['assist']).isNotEmpty)
                ('ผู้ช่วย', ppl(m['assist']), true, e),
              if ((m['note'] ?? '').trim().isNotEmpty)
                ('รายละเอียด', m['note']!.trim(), true, e),
            ]
          ));
        }
        continue;
      }
      if (l == _icd9Label && labels.contains(_procLabel)) continue;
      if (l == _icd10Label && _hasDxText(_speechStep)) {
        final dx = _multiItems(known[_dxTextLabel]);
        secs.add((
          'การวินิจฉัย',
          [
            (
              'Diagnosis Text',
              dx.isEmpty
                  ? 'ยังไม่ได้กรอก'
                  : [for (final (i, d) in dx.indexed) '${i + 1}. $d']
                      .join('\n'),
              dx.isNotEmpty,
              _dxTextLabel
            ),
            (
              'รหัส ICD-10',
              known[_icd10Label] == null
                  ? 'ยังไม่ได้กรอก'
                  : plain(_icd10Lines(known[_icd10Label])),
              known[_icd10Label] != null,
              l
            ),
            if (known[_icd9DxLabel] != null)
              ('รหัส ICD-9-CM', known[_icd9DxLabel]!, true, _icd9DxLabel),
          ]
        ));
        if (known[_noteLabel] != null) {
          secs.add(
              ('Doctor Note', [('', known[_noteLabel]!, true, _noteLabel)]));
        }
      } else {
        rest.add((l, plain(valueOf(l)), ok, l));
      }
    }
    if (rest.isNotEmpty) secs.insert(0, (stepName, rest));

    Widget card(String name, List<(String, String, bool, String)> rows) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 8.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(name,
                style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
            const SizedBox(height: 4.0),
            // แตะแถว = กลับไปแก้ช่องนั้น
            for (final (k, v, ok, edit) in rows)
              InkWell(
                onTap: () => editAt(edit),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (k.isNotEmpty)
                          SizedBox(
                            width: 116.0,
                            child: Text(k,
                                style: _t(13.0,
                                    color: _ink2, weight: FontWeight.w500)),
                          ),
                        Expanded(
                          // ค่า rich text (HPI ฯลฯ) แสดงรูปแบบจริง ไม่เห็นเครื่องหมาย # **
                          child: Text.rich(_richSpan(
                              v,
                              _t(13.5,
                                  color: ok ? _inkTitle : _blue,
                                  height: 1.4,
                                  weight: FontWeight.w600))),
                        ),
                      ]),
                ),
              ),
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
            done
                ? 'ตรวจทานข้อมูล${_stepShown(stepName)} แตะรายการเพื่อแก้'
                : 'ยังขาด ${missing.length} ช่อง แตะรายการเพื่อกรอก',
            style:
                _t(12.5, color: done ? _ink3 : _blue, weight: FontWeight.w500)),
        const SizedBox(height: 16.0),
        Flexible(
          child: SingleChildScrollView(
            // เลื่อนการ์ดสุดท้ายขึ้นพ้นปุ่ม footer ที่ลอยทับได้
            padding: const EdgeInsets.only(bottom: 88.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // สรุปการรับบริการ (ฟอร์ม HOSxP) ในหน้าสรุปขั้นคัดกรอง/จำหน่าย
                  if (const ['คัดกรอง', 'จำหน่าย'].contains(stepName))
                    Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFDADCE0)),
                      ),
                      child: _visitSummary(full: stepName == 'จำหน่าย'),
                    ),
                  for (final (name, rows) in secs) card(_stepShown(name), rows),
                ]),
          ),
        ),
      ],
    );
  }

  Widget _formFlip(
      ErUiBlock b, List<String> fields, Map<String, String> items) {
    final known = _filled[_speechStep];
    final n = fields.length;
    final at = _formAt.clamp(0, n - 1);
    void go(int d) => _formGo(d, n);

    final f = fields[at];
    final tall = _flipFill;
    final hpiPage = f == 'HPI' && _isHpiStep(_speechStep);
    // หน้ารวมวินิจฉัย: แต่ละส่วนมีหัวข้อของตัวเองแล้ว ไม่มีแถวหัวช่องซ้ำ
    final dxPage = f == _icd10Label && _hasDxText(_speechStep);
    // หน้าหัตถการ: เทมเพลต ชื่อหัตถการ + ICD9 ผู้ดูแล รายละเอียด ในหน้าเดียว ไม่มีแถวหัวช่อง
    final procPage = f == _procLabel;
    // สั่งการรักษา (ยา/Lab/X-ray/หัตถการ/อื่น ๆ): การ์ดกลุ่มคำสั่งของหน้าเองแล้ว
    // ไม่ครอบกรอบซ้ำ (ภาษาเดียวกับหน้าวินิจฉัย 2026-10-22) · ยังมีหัวช่อง
    final orderPage = _steps[_speechStep].$2 == 'สั่งการรักษา';
    // ซักประวัติ: หน้าวัด V/S ซ้ำ ใช้การ์ดสัญญาณชีพของหน้าคัดกรองทั้งใบ
    final vsPage = f == _hxVsLabel && _steps[_speechStep].$2 == 'ซักประวัติ';
    // ช่องพิมพ์อิสระ (ไม่มีตัวเลือก/หน่วย) ยืดเต็มความสูงได้ · ช่องตัวเลือกเลื่อนภายใน
    final free = f != _destLabel &&
        _fieldOptions(f, items[f]!).isEmpty &&
        _fieldUnit(items[f]!).isEmpty &&
        _fieldGroups(f).length <= 1;
    // การ์ดสูงตามเนื้อหา: ช่องพิมพ์อิสระ ช่องตัวเลข และหน้าช่องย่อยของซักประวัติ
    final compact = !hpiPage &&
        !dxPage &&
        !vsPage &&
        (free ||
            _fieldUnit(items[f]!).isNotEmpty ||
            _localGroups.containsKey(f));
    final front = Container(
      key: ValueKey('flip_${_speechStep}_$f'),
      // สูงเท่ากันทุกช่อง ไม่ว่าจะเป็นช่องพิมพ์หรือตัวเลือกหลายแถว
      // ช่องพิมพ์อิสระ: การ์ดสูงตามเนื้อหา (ไม่ยืดเต็มแผง)
      height: compact && tall != null ? null : (tall ?? _flipH),
      // สูงตามเนื้อหาแต่ไม่เกินแผง (เกินแล้วเลื่อนภายในการ์ด)
      constraints:
          compact && tall != null ? BoxConstraints(maxHeight: tall) : null,
      // การ์ด section แบบหน้าส่งตรวจ (Google AdSense): ขอบเทาบาง มุม 8 ไม่มีเงา
      // หน้ารวมวินิจฉัย: วางบนแผงขาวตรง ๆ ไม่มีกรอบครอบ (ในหน้ามีการ์ดของตัวเองแล้ว)
      padding: vsPage
          ? EdgeInsets.zero
          : dxPage || hpiPage || procPage
              ? const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0)
              : orderPage
                  ? const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0)
                  : const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      decoration: vsPage
          ? null
          // หน้า HPI / วินิจฉัย / หัตถการ: การ์ดของหน้าเอง ไม่มีกรอบครอบซ้ำ
          : dxPage || hpiPage || procPage || orderPage
              // ผู้ช่วยเพิ่งลงค่า: พื้นฟ้าจางชั่วครู่ (ไม่มีขอบ)
              ? BoxDecoration(
                  color: _glow.contains(f) ? const Color(0xFFF2F6FE) : _panel,
                  borderRadius: BorderRadius.circular(12.0),
                )
              : BoxDecoration(
                  // ช่องที่ผู้ช่วยเพิ่งลง/แก้: พื้นฟ้าจาง ๆ ชั่วครู่ (AI glow)
                  color: _glow.contains(f) ? const Color(0xFFF2F6FE) : _panel,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFDADCE0)),
                ),
      // แถวเดียว: ซ้ายชื่อช่อง ขวาช่องกรอก · แผงกาง: ชื่อบน ช่องกรอกเต็มความสูง
      child: procPage
          ? _procPage()
          : vsPage
              ? _hxVsPage()
              : tall != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize:
                          compact ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        // HPI: ไม่มีแถวหัวช่อง (ชื่อขั้นอยู่บนหัวแผงแล้ว สถานะดูจาก stepper)
                        if (!hpiPage && !dxPage) ...[
                          // หัว section: ชื่อช่อง (16) + คำอธิบายเล็กใต้ชื่อ · สถานะชิดขวา
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(f,
                                            style: _t(16.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w600)),
                                        if (_termOf(f) case final sub?) ...[
                                          const SizedBox(height: 2.0),
                                          Text(sub,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: _t(12.5,
                                                  color: _ink3,
                                                  weight: FontWeight.w500)),
                                        ],
                                      ]),
                                ),
                                if (_fieldDone(_speechStep, f))
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 13.0, color: _blue),
                                        const SizedBox(width: 3.0),
                                        Text('บันทึกแล้ว',
                                            style: _t(10.0,
                                                color: _blue,
                                                weight: FontWeight.w600)),
                                      ]),
                              ]),
                          const SizedBox(height: 16.0),
                        ],
                        // การ์ดสูงตามเนื้อหา แต่ไม่เกินแผง: เกินแล้วเลื่อนในการ์ด
                        compact
                            ? Flexible(
                                child: SingleChildScrollView(
                                    child: _fieldWithExtras(
                                        f,
                                        _guideFieldCard(
                                            f, items[f]!, known[f], true,
                                            big: true,
                                            onPick: () => Future.delayed(
                                                    const Duration(
                                                        milliseconds: 380), () {
                                                  if (mounted &&
                                                      _formAt == at) {
                                                    go(1);
                                                  }
                                                })),
                                        fill: false,
                                        scroll: false)))
                            : _flexIf(
                                true,
                                _fieldWithExtras(
                                    f,
                                    _guideFieldCard(
                                        f, items[f]!, known[f], true,
                                        big: true,
                                        // ช่องพิมพ์อิสระ: สูงพอดีเนื้อหา (ขั้นต่ำ ~4 บรรทัด)
                                        fill: free && (hpiPage || dxPage),
                                        onPick: () => Future.delayed(
                                                const Duration(
                                                    milliseconds: 380), () {
                                              if (_isPeStep(_speechStep) &&
                                                  _filled[_speechStep][f] ==
                                                      'ผิดปกติ') {
                                                return;
                                              }
                                              if (mounted && _formAt == at)
                                                go(1);
                                            })),
                                    fill: !compact,
                                    scroll: !free),
                              ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(f,
                                  style: _t(13.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              if (_termOf(f) case final sub?)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(sub,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          _t(10.0, color: _ink3, height: 1.3)),
                                ),
                              if (_fieldDone(_speechStep, f))
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 12.0, color: _blue),
                                        const SizedBox(width: 3.0),
                                        Text('บันทึกแล้ว',
                                            style: _t(9.5,
                                                color: _blue,
                                                weight: FontWeight.w600)),
                                      ]),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // ช่องกรอกตัวจริง (ขนาดใหญ่) ใช้ร่วมกับโหมด checklist
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: _fieldWithExtras(
                                  f,
                                  _guideFieldCard(f, items[f]!, known[f], true,
                                      big: true,
                                      onPick: () => Future.delayed(
                                              const Duration(milliseconds: 380),
                                              () {
                                            // ผิดปกติ = รอกรอกรายละเอียดก่อน ไม่พลิกหน้าเอง
                                            if (_isPeStep(_speechStep) &&
                                                _filled[_speechStep][f] ==
                                                    'ผิดปกติ') return;
                                            if (mounted && _formAt == at) go(1);
                                          }))),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200) go(1);
            if (v > 200) go(-1);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // แอนิเมชันเปลี่ยนหน้าทำที่ชั้นนอก (_clyGuideBody) ที่นี่ไม่ซ้อนอีกชั้น
              AnimatedSwitcher(
                duration: Duration.zero,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (cur, prev) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...prev, if (cur != null) cur]),
                transitionBuilder: (child, anim) {
                  final incoming = child.key == front.key;
                  final sign = (_formFwd ? 1.0 : -1.0) * (incoming ? 1 : -1);
                  return AnimatedBuilder(
                    animation: anim,
                    child: child,
                    builder: (_, ch) => Opacity(
                      opacity: anim.value.clamp(0.0, 1.0),
                      child: Transform(
                        alignment: _formFwd
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(sign * (1 - anim.value) * math.pi / 2.2),
                        child: ch,
                      ),
                    ),
                  );
                },
                child: front,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  /// สีและไอคอนตามความหมายของตัวเลือก (ปกติ = เขียว ผิดปกติ = แดง ไม่ได้ตรวจ = เทา)
  (Color, IconData?) _choiceTone(String o) => switch (o) {
        'ปกติ' || 'ไม่มี' || 'สวม' || 'คาด' || 'ไม่ดื่ม' || 'ไม่ใช้' => (
            _blue,
            Icons.check_circle_rounded
          ),
        'ผิดปกติ' || 'มี' => (_red, Icons.error_rounded),
        'ไม่ได้ตรวจ' || 'ไม่ทราบ' || 'ข้าม' => (
            _ink3,
            Icons.remove_circle_rounded
          ),
        _ => (_blue, null),
      };

  /// ปุ่มตัวเลือกใหญ่ เต็มช่อง สูง 44 (เป้ากดใหญ่ ใช้มือเดียวได้)
  Widget _bigChoice(String o, bool on, VoidCallback onTap,
      {double height = 44.0, bool left = false}) {
    final (col, icon) = _choiceTone(o);
    return _Press(
        child: Material(
      color: on ? col : _panel,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: height,
          alignment: left ? Alignment.centerLeft : Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: on ? col : col.withValues(alpha: 0.35), width: 1.5),
          ),
          padding: EdgeInsets.symmetric(horizontal: left ? 12.0 : 6.0),
          // ย่อทั้งปุ่มลงเมื่อแคบ ไม่ตัดคำ ("ไม่ได้ตรวจ" ต้องอ่านครบ)
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 15.0, color: on ? Colors.white : col),
                const SizedBox(width: 4.0),
              ],
              Text(o,
                  maxLines: 1,
                  style: _t(12.5,
                      color: on ? Colors.white : col, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    ));
  }

  /// ตัวเลือกแบบหน้าคัดกรองส่งตรวจ (_qOpt ใน _qGrid): 2 คอลัมน์ ชื่อยาวลงแถวละตัว
  Widget _wfOptGrid(
          List<String> opts, String? cur, ValueChanged<String> pick) =>
      _qGrid(opts.any((o) => o.length > 22) ? 1 : 2, [
        for (final o in opts) _qOpt(o, null, o == cur, () => pick(o), h: 44.0),
      ]);

  /// ชิปตัวเลือก: size = ขนาดตัวอักษรกำหนดเอง (ใช้ในช่องย่อยที่พื้นที่แคบ)
  Widget _optChip(String o, bool on, bool big, VoidCallback onTap,
          {double? size}) =>
      _Press(
          child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)
              : EdgeInsets.symmetric(
                  horizontal: size == null ? 8.0 : 10.0,
                  vertical: size == null ? 3.0 : 4.0),
          decoration: BoxDecoration(
            color: on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: on ? _blue : _line),
          ),
          child: Text(o,
              style: _t(size ?? (big ? 11.5 : 9.0),
                  color: on ? Colors.white : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w500)),
        ),
      ));

  /// เลือกจากรายการ master ยาว ๆ (ICD-10 ยา Lab ตึก ...) มีช่องค้นหา
  /// เลือกช่องทั้งช่องจากรายการยาว แล้วบันทึกลงฟอร์ม
  Future<void> _pickFromList(String label, List<String> opts,
      {VoidCallback? onPick, Map<String, String>? codes}) async {
    final picked = await _listSheet(label, opts,
        current: _filled[_speechStep][label], codes: codes);
    if (picked == null || !mounted) return;
    _applyPick(label, picked);
    onPick?.call();
  }

  /// บันทึกค่าที่เลือกจากรายการลงฟอร์ม (ใช้ทั้งเลือกเดี่ยวและ sheet หลายขั้น)
  void _applyPick(String label, String picked) {
    setState(() {
      _lastFilled = [(_speechStep, label, _filled[_speechStep][label])];
      _filled[_speechStep][label] = picked;
      // เปลี่ยนหัตถการ = ICD9 ตามรหัสที่ผูกไว้กับหัตถการใหม่
      if (label == _procLabel) {
        _filled[_speechStep].remove(_icd9Label);
        _autoIcd9();
      }
      _allergyWarn = _allergyConflict();
    });
  }

  /// codes: ตัวเลือก → รหัส (แสดงรหัสตัวหนาหน้าชื่อ · ค้นหาด้วยรหัสได้)
  Future<String?> _listSheet(String label, List<String> opts,
      {String? current,
      Map<String, String>? codes,
      bool people = false}) async {
    String? picked;
    await _listFlow([
      _ListStep(label, opts,
          codes: codes,
          people: people,
          current: () => current,
          apply: (o) => picked = o)
    ]);
    return picked;
  }

  /// ยืนยันก่อนลบทุกครั้ง (กฎ: การลบทุกจุดต้องมี confirmation) · ยกเลิก + ปุ่มแดง
  Future<bool> _askDelete(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _panel,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(title,
              style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
          content: Text(body,
              style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก',
                    style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action,
                    style: _t(14.0,
                        color: Colors.white, weight: FontWeight.w600))),
          ],
        ),
      ) ==
      true;

  /// ตัวสลับบทบาทเล็กท้ายแถว (แบบ segmented): ที่เลือก = พื้นกรมท่า ตัวขาว
  Widget _tagSwitch(List<String> tags, String on, ValueChanged<String> pick) =>
      Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final t in tags)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => pick(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: t == on ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(t,
                    style: _t(13.0,
                        color: t == on ? Colors.white : _ink2,
                        weight: FontWeight.w600)),
              ),
            ),
        ]),
      );

  /// sheet หลายขั้น: เลือกแล้วเลื่อนไปช่องถัดไปใน sheet เดิม (ไม่ปิด-เปิดใหม่)
  /// หัว = ขั้นที่ · ย้อน · ถัดไป (ข้ามโดยคงค่าเดิม) / เสร็จ
  Future<void> _listFlow(List<_ListStep> steps) async {
    await _placedSheet<void>(
      context: context,
      // bottom sheet กว้างไม่เกิน 640 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 640.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) {
        var q = '';
        var k = 0;
        var fwd = true;
        // รายการแบบแถว: เปิดขั้นแล้วเลื่อนให้ตัวที่เลือกอยู่ในจอ (หนึ่ง controller ต่อขั้น)
        final rowCtl = <int, ScrollController>{};
        return StatefulBuilder(builder: (ctx, set) {
          final st = steps[k];
          final label = st.label;
          final opts = st.opts;
          final codes = st.codes;
          final current = st.current();
          final multi = steps.length > 1;
          // หลายรายการ: ค่าปัจจุบันบรรทัดละรายการ
          bool isOn(String o) => st.tags != null
              ? st.tagOf!(o) != null
              : st.many
                  ? (current ?? '').split('\n').contains(o)
                  : current == o;
          final last = k == steps.length - 1;
          // แบบ sheet วัด V/S: แตะ = เลือก (sheet ยังอยู่) · ถัดไป = ช่องแรกหลังจากนี้ที่ยังว่าง
          // ไม่เหลือ = เสร็จ · ข้าม = ไปขั้นถัดไปโดยไม่เปลี่ยนค่า
          final int? next = !multi
              ? null
              : [
                  for (var j = k + 1; j < steps.length; j++)
                    if ((steps[j].current() ?? '').isEmpty || steps[j].confirm)
                      j
                ].firstOrNull;
          void goTo(int? j) {
            if (j == null) {
              Navigator.pop(ctx);
              return;
            }
            set(() {
              fwd = j > k;
              k = j;
              q = '';
            });
          }

          void pick(String o) {
            HapticFeedback.selectionClick();
            // มีบทบาทย่อย (ผู้ทำ/ผู้ช่วย): แตะ = เลือก / เอาออก
            // คนแรกที่เลือก = บทบาทแรก (ผู้ทำ) · มีผู้ทำแล้ว คนต่อไป = บทบาทถัดไป (ผู้ช่วย)
            if (st.tags != null) {
              final tg = st.tags!;
              final hasFirst = st.opts.any((x) => st.tagOf!(x) == tg.first);
              st.setTag!(
                  o,
                  st.tagOf!(o) != null
                      ? null
                      : (hasFirst && tg.length > 1 ? tg[1] : tg.first));
              set(() {});
              return;
            }
            if (st.many) {
              final sel = [
                for (final x in (current ?? '').split('\n'))
                  if (x.trim().isNotEmpty) x.trim()
              ];
              sel.contains(o) ? sel.remove(o) : sel.add(o);
              st.apply(sel.join('\n'));
              set(() {});
              return;
            }
            st.apply(o);
            if (multi) {
              set(() {});
            } else {
              Navigator.pop(ctx);
            }
          }

          final list = [
            for (final o in opts)
              if (q.isEmpty ||
                  o.toLowerCase().contains(q.toLowerCase()) ||
                  (codes?[o] ?? '').contains(q))
                o
          ];
          return SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.7,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (c, a) {
                final inbound = c.key == ValueKey(k);
                final dx = (inbound == fwd) ? 0.12 : -0.12;
                return FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: Offset(dx, 0.0), end: Offset.zero)
                        .animate(a),
                    child: c,
                  ),
                );
              },
              layoutBuilder: (cur, prev) =>
                  Stack(children: [...prev, if (cur != null) cur]),
              child: Column(key: ValueKey(k), children: [
                // หัว: ชื่อรายการใหญ่ + จำนวน (อ่านง่ายบน iPad)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
                  child: Row(children: [
                    Expanded(
                      child: Text(label,
                          style: _t(18.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    Text(
                        st.many
                            ? 'เลือกได้หลายคน  เลือกแล้ว ${st.tags != null ? list.where(isOn).length : (current ?? '').split('\n').where((x) => x.trim().isNotEmpty).length}'
                            : '${list.length} รายการ',
                        style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
                ),
                // ตัวเลือกน้อย (เห็นครบในจอเดียว เช่น ประเภทการวินิจฉัย 1–7): ไม่มีช่องค้นหา
                if (opts.length > 10)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                    child: TextField(
                      onChanged: (v) => set(() => q = v.trim()),
                      style:
                          _t(16.0, color: _inkTitle, weight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'ค้นหา',
                        hintStyle: _t(16.0, color: _ink3),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 22.0, color: _ink3),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        filled: true,
                        fillColor: _panelSoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text('ไม่พบรายการ',
                              style: _t(15.0, color: _ink3)))
                      // grid 2 คอลัมน์: แผ่นขาว เส้นขอบบาง 0.5 · ที่เลือก = ขอบน้ำเงิน + เครื่องหมายถูก
                      // ชื่อยาว (เช่น ICD-9-CM ภาษาอังกฤษ): แถวเต็มความกว้าง รหัสคอลัมน์ซ้าย ชื่อบรรทัดเดียว
                      // บุคลากร: แถว avatar + ชื่อเต็ม (บทบาทเป็นบรรทัดรอง) แบบเมนูแพทย์ผู้สั่ง
                      : st.people
                          ? ListView(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 24.0),
                              children: [
                                // เว้น 4 ระหว่างแถว ที่เลือกติดกันไม่รวมเป็นก้อนเดียว
                                for (final o in list)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: _Press(
                                      child: Material(
                                        color: isOn(o)
                                            ? _blue.withValues(alpha: 0.06)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          onTap: () => pick(o),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 10.0),
                                            child: Row(children: [
                                              _docAvatar(o, 40.0),
                                              const SizedBox(width: 14.0),
                                              Expanded(
                                                  child: _docName(o,
                                                      size: 16.0,
                                                      bold: isOn(o))),
                                              // เลือกแล้ว + มีบทบาทย่อย: ตัวสลับ ผู้ทำ | ผู้ช่วย
                                              if (isOn(o) && st.tags != null)
                                                _tagSwitch(
                                                    st.tags!, st.tagOf!(o)!,
                                                    (t) {
                                                  HapticFeedback
                                                      .selectionClick();
                                                  st.setTag!(o, t);
                                                  set(() {});
                                                })
                                              else if (isOn(o))
                                                const Icon(Icons.check_rounded,
                                                    color: _blue, size: 22.0),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : list.any((o) =>
                                  o
                                      .replaceFirst(
                                          RegExp(r'\s*\([^()]*\)\s*$'), '')
                                      .length >
                                  32)
                              ? ListView.separated(
                                  controller: rowCtl.putIfAbsent(k, () {
                                    // แถวละ ~57 (บรรทัดเดียว + เส้นคั่น) · เว้นแถวก่อนหน้าไว้ 1 แถว
                                    final at = current == null
                                        ? -1
                                        : list.indexOf(current);
                                    return ScrollController(
                                        initialScrollOffset:
                                            at <= 1 ? 0.0 : (at - 1) * 57.0);
                                  }),
                                  padding: const EdgeInsets.fromLTRB(
                                      12.0, 4.0, 12.0, 24.0),
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Divider(
                                        height: 1.0,
                                        thickness: 0.5,
                                        color: Color(0xFFDADCE0)),
                                  ),
                                  itemBuilder: (_, i) {
                                    final o = list[i];
                                    final on = current == o;
                                    final codeM = RegExp(
                                            r'^([A-Z0-9][A-Z0-9.\-]*) · (.*)$')
                                        .firstMatch(o);
                                    final code = codeM?.group(1) ?? codes?[o];
                                    final title = codeM?.group(2) ?? o;
                                    return _Press(
                                      child: Material(
                                        color: on
                                            ? _blue.withValues(alpha: 0.06)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          onTap: () => pick(o),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 16.0),
                                            child: Row(children: [
                                              if (code != null)
                                                SizedBox(
                                                  width: 64.0,
                                                  child: Text(code,
                                                      style: _num(15.0,
                                                          color: on
                                                              ? _blue
                                                              : _inkTitle,
                                                          weight:
                                                              FontWeight.w700)),
                                                ),
                                              Expanded(
                                                child: Text(title,
                                                    style: _t(16.0,
                                                        color: on
                                                            ? _blue
                                                            : _inkTitle,
                                                        weight: on
                                                            ? FontWeight.w600
                                                            : FontWeight.w500)),
                                              ),
                                              if (on)
                                                const Icon(Icons.check_rounded,
                                                    color: _blue, size: 22.0),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 4.0, 20.0, 24.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                    mainAxisExtent: 88.0,
                                  ),
                                  itemCount: list.length,
                                  itemBuilder: (_, i) {
                                    final o = list[i];
                                    final del = o.startsWith('ลบ');
                                    final on = current == o;
                                    // "รหัส · ชื่อ" = รหัสตัวหนาบน · "ไทย (English)" = ไทยบรรทัดหลัก English บรรทัดรอง
                                    final codeM = RegExp(
                                            r'^([A-Z0-9][A-Z0-9.\-]*) · (.*)$')
                                        .firstMatch(o);
                                    final code = codeM?.group(1) ?? codes?[o];
                                    final rest = codeM?.group(2) ?? o;
                                    final enM =
                                        RegExp(r'^(.*?)\s*\(([^()]*)\)\s*$')
                                            .firstMatch(rest);
                                    final title = enM?.group(1) ?? rest;
                                    final sub = enM?.group(2);
                                    final fg =
                                        del ? _red : (on ? _blue : _inkTitle);
                                    return _Press(
                                      child: Material(
                                        color: on
                                            ? _blue.withValues(alpha: 0.04)
                                            : _panel,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          side: BorderSide(
                                              color: on
                                                  ? _blue
                                                  : const Color(0xFFDADCE0),
                                              width: on ? 1.0 : 0.5),
                                        ),
                                        child: InkWell(
                                          customBorder: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14.0)),
                                          onTap: () => pick(o),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                14.0, 10.0, 10.0, 10.0),
                                            child: Row(children: [
                                              if (del) ...[
                                                const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: _red,
                                                    size: 22.0),
                                                const SizedBox(width: 10.0),
                                              ],
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (code != null)
                                                        Text(code,
                                                            style: _num(12.5,
                                                                color: on
                                                                    ? _blue
                                                                    : _ink3,
                                                                weight:
                                                                    FontWeight
                                                                        .w500)),
                                                      Text(title,
                                                          maxLines: sub != null
                                                              ? 1
                                                              : 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: _t(15.0,
                                                              color: fg,
                                                              weight: on || del
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w500)),
                                                      if (sub != null &&
                                                          sub.isNotEmpty)
                                                        Text(sub,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: _t(12.5,
                                                                color: _ink3,
                                                                weight:
                                                                    FontWeight
                                                                        .w500)),
                                                    ]),
                                              ),
                                              if (on)
                                                const Icon(Icons.check_rounded,
                                                    color: _blue, size: 20.0),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
                // ท้าย sheet หลายขั้น (แบบ sheet วัด V/S): ข้าม | ถัดไป ชื่อขั้นถัดไป / เสร็จ
                // เลือกได้หลายรายการ: มี footer เสมอ (แตะรายการไม่ปิด sheet)
                if (multi || st.many)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                    child: SafeArea(
                      top: false,
                      child: Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48.0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFDADCE0), width: 0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                              onPressed: () => goTo(last ? null : k + 1),
                              child: Text('ข้าม',
                                  style: _t(14.0,
                                      color: _ink2, weight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48.0,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                              onPressed: () => goTo(next),
                              child: Text(
                                  next == null
                                      ? 'เสร็จ'
                                      : 'ถัดไป  ${steps[next].short}',
                                  style: _t(15.0,
                                      color: Colors.white,
                                      weight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ),
          );
        });
      },
    );
  }

  Widget _guideFieldCard(String label, String hint, String? value, bool done,
      {bool big = false, bool fill = false, VoidCallback? onPick}) {
    final opts = _fieldOptions(label, hint);
    final unit = _fieldUnit(hint);
    // ตัวเลือกที่ตรงกับค่า: ตรงทั้งคำก่อน แล้วค่อยคำที่อยู่ในค่า (ยาวสุดชนะ)
    String? sel;
    if (value != null && opts.isNotEmpty) {
      sel = opts.contains(value)
          ? value
          : (opts.where((o) => value.contains(o)).toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .firstOrNull;
    }
    Widget field;
    final groups = _fieldGroups(label);
    if (_isMultiField(label)) {
      // Diagnosis Text / ICD-10: หลายรายการ เพิ่ม/แก้/ลบทีละรายการ
      field = _multiList(label, value, big: big, fill: fill);
    } else if (groups.length > 1) {
      // หลายช่องย่อย: ค่ารวมเป็น "ตัวเลือก · ตัวเลือก" ตามลำดับกลุ่ม
      String? pickOf(List<String> o) {
        if (value == null) return null;
        final hit = o.where((x) => value.contains(x)).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        return hit.firstOrNull;
      }

      // ค่าเก็บตามตำแหน่งกลุ่ม "a · b" (กลุ่มที่ยังไม่เลือก = "-")
      // กลุ่มที่ตัวเลือกซ้ำกัน (รูม่านตาซ้าย/ขวา) จึงแยกกันได้
      final parts = value?.split(' · ');
      final cur = [
        for (var gi = 0; gi < groups.length; gi++)
          parts != null && parts.length == groups.length
              ? (groups[gi].$2.contains(parts[gi]) ? parts[gi] : null)
              : pickOf(groups[gi].$2)
      ];
      void setGroup(int gi, String o) {
        final next = [...cur]..[gi] = o;
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = next.map((x) => x ?? '-').join(' · ');
        });
        // ครบทุกกลุ่มแล้วค่อยพลิกไปช่องถัดไป
        if (next.every((x) => x != null)) onPick?.call();
      }

      // ช่องย่อยละก้อน: ชื่อเล็กด้านบน · ตัวเลือกไม่เกิน 4 เป็นชิป มากกว่านั้นเป็นปุ่มเลือกจากรายการ
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var gi = 0; gi < groups.length; gi++)
            Padding(
              padding: EdgeInsets.only(top: gi == 0 ? 0 : (big ? 16.0 : 5.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(groups[gi].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(big ? 12.5 : 8.5,
                          color: _ink2, weight: FontWeight.w600)),
                  SizedBox(height: big ? 8.0 : 3.0),
                  big && groups[gi].$2.length <= 4
                      ? _wfOptGrid(
                          groups[gi].$2, cur[gi], (o) => setGroup(gi, o))
                      : groups[gi].$2.length <= 4
                          ? Wrap(
                              spacing: big ? 8.0 : 5.0,
                              runSpacing: big ? 8.0 : 5.0,
                              children: [
                                for (final o in groups[gi].$2)
                                  _optChip(o, o == cur[gi], false,
                                      () => setGroup(gi, o),
                                      size: big ? 13.0 : 9.0),
                              ],
                            )
                          : InkWell(
                              onTap: () async {
                                final o = await _listSheet(
                                    groups[gi].$1, groups[gi].$2,
                                    current: cur[gi]);
                                if (o != null && mounted) setGroup(gi, o);
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 7.0),
                                decoration: BoxDecoration(
                                  color: _panelSoft,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: cur[gi] != null
                                          ? _blue.withValues(alpha: 0.5)
                                          : _line),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(cur[gi] ?? 'เลือก…',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _t(big ? 12.0 : 9.5,
                                            color: cur[gi] != null
                                                ? _inkTitle
                                                : _ink3,
                                            weight: cur[gi] != null
                                                ? FontWeight.w600
                                                : FontWeight.w400)),
                                  ),
                                  const Icon(Icons.expand_more_rounded,
                                      size: 16.0, color: _ink3),
                                ]),
                              ),
                            ),
                ],
              ),
            ),
        ],
      );
    } else if (big && label.contains('วันที่') && label.contains('เวลา')) {
      // วันที่-เวลา: ปุ่ม "ตอนนี้" + date time picker
      field = _dateTimeField(label, value, onPick);
    } else if (big && label == _dispLabel && opts.isNotEmpty) {
      // สภาพผู้ป่วยออกจาก ER: การ์ดเลือกในหน้าเลย (ไม่เปิดรายการซ้อน)
      field = _dispCards(opts, sel, (o) {
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = o;
        });
        // ยังไม่ระบุวันที่/เวลาออกจากห้อง (อยู่หน้าเดียวกัน) = ยังไม่พลิกไปหน้าถัดไป
        if (_hasOutTime(_speechStep) &&
            (_filled[_speechStep][_outTimeLabel] ?? '').isEmpty) {
          return;
        }
        onPick?.call();
      });
    } else if (big && opts.length >= 2 && opts.length <= 4) {
      // ตัวเลือกน้อย (ปกติ/ผิดปกติ/ไม่ได้ตรวจ, มี/ไม่มี ...): ปุ่มใหญ่กว้างเท่ากัน กดง่าย
      void pick(String o) {
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = o;
        });
        // ผิดปกติ: บังคับระบุรายละเอียดทันที
        if (_needsDetail(_speechStep, label)) {
          // โฟกัสช่องรายละเอียดใต้ตัวเลือก พิมพ์ต่อได้ทันที (ไม่เปิด dialog)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _inlineFocusOf('$label - รายละเอียด').requestFocus();
          });
          return;
        }
        onPick?.call();
      }

      // ตัวเลือกยาว (เช่น ข้อบ่งชี้กรณีฉุกเฉิน): เรียงคนละบรรทัด อ่านครบ ไม่ย่อ
      final stacked = opts.any((o) => o.length > 10);
      field = stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < opts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 5.0),
                  _bigChoice(opts[i], opts[i] == sel, () => pick(opts[i]),
                      height: 34.0, left: true),
                ],
              ],
            )
          : Row(children: [
              for (var i = 0; i < opts.length; i++) ...[
                if (i > 0) const SizedBox(width: 6.0),
                Expanded(
                    child: _bigChoice(
                        opts[i], opts[i] == sel, () => pick(opts[i]))),
              ],
            ]);
    } else if (big && opts.isNotEmpty && opts.length <= 8) {
      // แผง workflow ใช้ชิปตัวเลือกชุดเดียวกับหน้าคัดกรองส่งตรวจ
      field = _wfOptGrid(opts, sel, (o) {
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = o;
        });
        onPick?.call();
      });
    } else if (opts.isNotEmpty && opts.length <= 8) {
      field = Wrap(
        spacing: big ? 7.0 : 4.0,
        runSpacing: big ? 7.0 : 4.0,
        children: [
          for (final o in opts)
            InkWell(
              onTap: () {
                setState(() {
                  _lastFilled = [(_speechStep, label, value)];
                  _filled[_speechStep][label] = o;
                });
                onPick?.call();
              },
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                padding: big
                    ? const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 7.0)
                    : const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: o == sel ? _blue : _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: o == sel ? _blue : _line),
                ),
                child: Text(o,
                    style: _t(big ? 12.5 : 9.0,
                        color: o == sel ? Colors.white : _ink2,
                        weight: o == sel ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
        ],
      );
    } else {
      // ช่องพิมพ์ (หรือ dropdown ที่ตัวเลือกยาว แสดงเป็นช่องเลือก)
      final dropdown = opts.length > 8;
      final hpiBox = big && label == 'HPI' && _isHpiStep(_speechStep);
      // ช่องพิมพ์: พิมพ์ในช่องได้เลย (ไม่เปิด dialog) · แตะขอบกล่องก็โฟกัสช่อง
      field = InkWell(
        onTap: () => dropdown
            ? _pickFromList(label, opts, onPick: onPick)
            : _inlineFocusOf(label).requestFocus(),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: fill && unit.isEmpty && !dropdown ? double.infinity : null,
          alignment: fill ? Alignment.topLeft : null,
          padding: hpiBox
              ? const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0)
              : big
                  ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0)
                  : const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
          // ช่อง HPI: การ์ดขาวมุมโค้งในกรอบ _hpiShell
          // Google outlined text field: พื้นขาว เส้นขอบเทา มีค่าแล้ว = ขอบฟ้า
          decoration: BoxDecoration(
            color: _panel,
            borderRadius:
                BorderRadius.circular(hpiBox ? 14.0 : (big ? 12.0 : 8.0)),
            border: Border.all(
                // แบบช่องกรอกหน้าส่งตรวจ: ขอบเทาเข้ม · มีค่า = ขอบฟ้าหนา
                color:
                    value != null && !hpiBox ? _blue : const Color(0xFF80868B),
                width: value != null && !hpiBox ? 2.0 : 1.0),
          ),
          child: Row(children: [
            Expanded(
              child: value != null && unit.isEmpty && _diffs[label] != null
                  // ผู้ช่วยเพิ่งแก้: พิมพ์ส่วนที่เพิ่มทีละตัว (เขียว) ขีดฆ่าส่วนที่แก้ ส่วนที่ลบเป็นแดง
                  ? _TextDiff(
                      key: ValueKey('diff_${label}_${_diffs[label]!.$2}'),
                      before: _diffs[label]!.$1,
                      after: value,
                      style: _t(big ? 13.5 : 10.0,
                          color: _inkTitle, weight: FontWeight.w600),
                      onDone: () {
                        if (mounted) setState(() => _diffs.remove(label));
                      },
                    )
                  : dropdown
                      ? Text(value ?? (hint.isEmpty ? 'เลือก…' : hint),
                          maxLines: big ? 8 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: _t(big ? 13.5 : 10.0,
                              color: value != null ? _inkTitle : _ink3,
                              weight: value != null
                                  ? FontWeight.w600
                                  : FontWeight.w400))
                      : _inlineInput(label, value,
                          hint: unit.isNotEmpty
                              ? '–'
                              : hint.isEmpty
                                  ? 'พิมพ์หรือพูด…'
                                  : hint,
                          // ข้อความในช่องพิมพ์: medium (ตัวเลขยังหนา)
                          style: unit.isEmpty
                              ? _t(big ? 13.5 : 10.0,
                                  color: _inkTitle, weight: FontWeight.w500)
                              : _num(big ? 20.0 : 12.0,
                                  color: _inkTitle, weight: FontWeight.w700),
                          hintStyle: unit.isEmpty
                              ? _t(big ? 13.5 : 10.0, color: _ink3)
                              : _num(big ? 20.0 : 12.0,
                                  color: _ink3, weight: FontWeight.w700),
                          fill: fill && unit.isEmpty,
                          // ช่องใหญ่: สูงตามจำนวนบรรทัดที่พิมพ์ ไม่จำกัด (ไม่เลื่อนในช่อง)
                          maxLines: big ? null : 3,
                          numeric: unit.isNotEmpty),
            ),
            if (unit.isNotEmpty)
              Text(unit, style: _t(big ? 12.0 : 9.0, color: _ink3)),
            if (dropdown)
              const Icon(Icons.expand_more_rounded, size: 15.0, color: _ink3),
          ]),
        ),
      );
    }
    // flipbook มีหัวการ์ดของตัวเอง ใช้เฉพาะช่องกรอก
    if (big) return field;
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: _lastFilled.any((f) => f.$2 == label)
                ? _blue
                : (done ? _line : _blue.withValues(alpha: 0.35))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(label,
                  style: _t(9.5, color: _ink2, weight: FontWeight.w700)),
            ),
            Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 13.0,
                color: done ? _blue : _g5),
          ]),
          const SizedBox(height: 5.0),
          field,
        ],
      ),
    );
  }

  // ================================================ Generative UI ของผู้ช่วย
  // ผู้ช่วยตอบเป็นบล็อก UI (er_genui.dart) วาดในแผงขวาระหว่างโหมดพูด
  // แพทย์เห็นข้อมูลที่ต้องใช้ + ลงมือได้ในที่เดียว ไม่ต้องสลับแท็บ
  // แต่ละขั้นมีบล็อกตั้งต้น (_guideUi) เสมอ ผู้ช่วยเสริม/แทนที่ได้ตามบทสนทนา

  /// บล็อกตั้งต้นของขั้น: พาแพทย์ไปตามเส้นทางเคสแม้ผู้ช่วยยังไม่ตอบ UI มา
  List<ErUiBlock> _guideUi(int step) {
    final c = _case;
    final p = _caseP();
    final out = <ErUiBlock>[];
    ErUiBlock b(String type, Map<String, dynamic> d) => erParseUi([
          {'type': type, ...d}
        ]).map((x) => ErUiBlock(x.type, x.data, source: 'guide')).first;
    final allergy = c.allergies.isEmpty
        ? null
        : b('alert', {
            'level': 'critical',
            'title': 'แพ้ยา / แพ้อาหาร',
            'text': c.allergies.join(' · '),
          });
    final fast = switch (p.type) {
      _Ptype.stroke => ('Door-to-needle (rtPA)', 60),
      _Ptype.stemi => ('Door-to-balloon (PCI)', 90),
      _Ptype.sepsis => ('Sepsis bundle 1 ชม.', 60),
      _Ptype.trauma => ('Golden hour', 60),
      _ => null,
    };
    final arrive = c.times.isEmpty ? null : c.times.first;
    ErUiBlock? timer() => fast == null || arrive == null
        ? null
        : b('timer', {
            'label': fast.$1,
            'since': c.onset ?? arrive,
            'target_min': fast.$2
          });

    // พยาบาลคัดกรอง ขั้นระดับ ESI: สรุปความเร่งด่วนโดยผู้ช่วย + ระดับที่แนะนำ
    if (ErSession.instance.isTriage && step == _steps.length - 1) {
      out.add(b('brief', {'title': 'สรุปความเร่งด่วน', 'esi_ai': true}));
    }
    if (ErSession.instance.isNurse) {
      if (step == 1)
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
      if (allergy != null) out.add(allergy);
      return _withReview(out, step, b);
    }
    switch (step) {
      case 0:
        out.add(b('brief', {
          'title':
              '${c.sex} ${c.ageText} · ${p.esi == null ? 'รอคัดกรอง' : 'ESI ${p.esi!.level}'}',
          'points': [
            c.cc,
            if (c.underlying.isNotEmpty)
              'โรคประจำตัว: ${c.underlying.join(', ')}',
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.first.text}',
          ],
        }));
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
        if (allergy != null) out.add(allergy);
        final t = timer();
        if (t != null) out.add(t);
      case 1:
      case 2:
      case 3:
        // ตรวจร่างกาย: เปิดมาเป็นหน้ารวมทุกระบบเลย (เลือกเทมเพลตจากแท็บบนการ์ด)
        break;
      case 4:
        // วินิจฉัย: ฟอร์ม ICD-10 อย่างเดียว (แล็บผิดปกติดูได้จากแผงขวา)
        break;
      case 5:
        // สั่งการรักษา: เลือก Order Set ก่อน (ย้ายมาจากแท็บคำสั่งแพทย์)
        out.add(
            b('brief', {'title': 'สั่ง Standing Order', 'order_pick': true}));
        // ใบคำสั่งของชุดที่เลือก (Figma 331-350): Progress Note / One Day / Continuation
        // แต่ละแฟ้มเป็นขั้นย่อยของตัวเองใน stepper (Progress Note / One Day / Continuation)
        for (final f in _soFolders())
          out.add(b('brief', {'title': f.$2, 'so_doc': true, 'folder': f.$1}));
        if (allergy != null) out.add(allergy);
        // รายละเอียดคำสั่งกรอกทีละรายการในหน้า One Day / Continuation แล้ว
        // ไม่มีหน้าย่อยแยกหมวด (ยา Lab X-ray หัตถการ) ซ้ำอีก
        final t = timer();
        if (t != null) out.add(t);
      default:
        // จำหน่าย: หน้าลงนัดติดตาม ต่อจากฟอร์ม (แผงขวาลงข้อมูล · แท็บนัดหมายซ้ายแสดงผล)
        if (_steps[step].$2 == 'จำหน่าย') {
          out.add(b('brief', {'title': 'นัดหมาย', 'appt': true}));
        }
        out.add(b('brief', {
          'title': 'สรุปก่อนจำหน่าย',
          'points': [
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.map((d) => d.text).join(', ')}',
            'ขั้นถัดไป: ${c.nextStep}${c.nextDetail.isEmpty ? '' : ' · ${c.nextDetail}'}',
            if (c.disposition.isNotEmpty) 'Disposition: ${c.disposition}',
          ],
        }));
    }
    return _withReview(out, step, b);
  }

  /// ท้ายทุกขั้นของทุกบทบาท: ฟอร์มครบทุกช่อง + หน้าสรุปก่อนยืนยันบันทึก
  List<ErUiBlock> _withReview(List<ErUiBlock> out, int step,
      ErUiBlock Function(String, Map<String, dynamic>) b) {
    final last = _stepLast(step);
    return [
      ...out,
      b('form', {
        'title': _steps[step].$2,
        'fields': [for (final (l, _) in _forms[step]) l],
      }),
      b('next_step', {
        'review': true,
        'title': last ? 'ยืนยันและจบเคส' : 'ยืนยันบันทึก',
        'action': last ? 'summary' : 'confirm_step',
      }),
    ];
  }

  List<ErUiBlock> get _uiSeq {
    // สั่งการรักษา: กรอกรายละเอียดทีละรายการในหน้า One Day / Continuation แล้ว
    // ฟอร์มแยกหมวด (ยา/เวชภัณฑ์ Lab X-ray หัตถการ อื่น ๆ) ซ้ำกับหน้านั้น ไม่แสดง
    final orders = _steps[_speechStep].$2 == 'สั่งการรักษา';
    // ข้อมูลที่หน้ารายละเอียดแสดงอยู่แล้ว (สัญญาณชีพ แล็บ แพ้ยา ...) ไม่แสดงซ้ำ
    // ตัดตามชนิดข้อมูล ไม่ขึ้นกับแท็บ แผงผู้ช่วยจึงเหมือนเดิมทุกแท็บ
    // ไม่ใช้ generative UI แล้ว: แสดงเป็นขั้น ๆ เฉพาะตัวช่วยกรอก → ช่องฟอร์มทีละช่อง → สรุปยืนยัน
    final list = [
      // หน้าแรกของทุกขั้น: หน้าคำแนะนำ (ขั้นนี้ทำอะไร กรอกอะไร ใช้งานยังไง)
      ErUiBlock(ErUiType.brief, const {'intro': true}, source: 'guide'),
      for (final b in _guideUi(_speechStep))
        if (_pinnedBlock(b) ||
            (b.type == ErUiType.form && !orders) ||
            b.type == ErUiType.nextStep)
          b
    ];
    int rank(ErUiBlock b) => b.data['intro'] == true
        ? -2
        : (b.type == ErUiType.alert && b.str('level') == 'critical')
            ? -1
            // นัดหมาย: หลังฟอร์มจำหน่าย ก่อนสรุป
            : b.data['appt'] == true
                ? _uiOrder[ErUiType.orderSet]!
                : _uiOrder[b.type]!;
    // stable sort
    final idx = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : idx[a]!.compareTo(idx[b]!);
    });
    return list;
  }

  void _uiGo(int d, int n) {
    final to = (_uiIdx + d).clamp(0, n - 1);
    if (to != _uiIdx) {
      setState(() {
        _formFwd = d > 0;
        _uiIdx = to;
      });
    }
  }

  Widget _agentBar() {
    final seq = _uiSeq;
    final n = seq.length;
    final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
    final cur = n == 0 ? null : seq[at];
    // กรอกครบทุกช่องของขั้น: พาไปหน้าสรุปยืนยันเอง (ครั้งเดียวต่อการครบ)
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    // กำลังพิมพ์ในช่องอยู่: รอพิมพ์เสร็จ (ออกจากช่อง) ค่อยพาไปหน้าตรวจสอบ
    // วินิจฉัย: ลงได้หลายโรค ไม่เด้งไปหน้าสรุปเองหลังลงโรคแรก (แพทย์กด "ถัดไป" เอง)
    if (complete &&
        _reviewShown != _speechStep &&
        n > 0 &&
        !_inlineTyping &&
        !_isDxStep(_speechStep)) {
      _reviewShown = _speechStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _uiIdx = _uiSeq.length - 1);
      });
    } else if (!complete && _reviewShown == _speechStep) {
      _reviewShown = -1;
    }
    final busy = _agentStatus.isNotEmpty;
    final say = busy
        ? _agentStatus
        : (_agentSay.isEmpty ? 'น้องช่วยพร้อมค่ะ' : _agentSay);
    final total = _pageCount(seq);
    final page = _pageAt(seq);
    final showChoices = _agentChoices != null &&
        !_agentBusy &&
        cur?.type != ErUiType.form &&
        cur?.data['pe_pick'] != true &&
        cur?.data['hpi_pick'] != true;
    return Positioned(
      left: 12.0,
      right: 12.0,
      bottom: 12.0,
      height: _barH,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: _line),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x220B1B3F),
                  blurRadius: 28.0,
                  offset: Offset(0, 10)),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ---- ซ้าย: ขั้น + คำถาม
            SizedBox(
              width: 290.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _barSteps(),
                    const SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22.0,
                          height: 22.0,
                          margin: const EdgeInsets.only(top: 1.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Color(0xFF3B5BDB), Color(0xFF001B7C)]),
                          ),
                          child: Icon(
                              _agentBusy
                                  ? Icons.more_horiz_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 12.0,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            layoutBuilder: (a, b) => Stack(
                                alignment: Alignment.topLeft,
                                children: [...b, if (a != null) a]),
                            child: Text(say,
                                key: ValueKey(say),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.5,
                                    color: busy ? _ink3 : _inkTitle,
                                    weight: FontWeight.w600,
                                    height: 1.4)),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (showChoices)
                      SizedBox(
                        height: 28.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final o in _agentChoices!.$2)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: _optChip(o, false, false,
                                    () => _pickChoice(_agentChoices!.$1, o),
                                    size: 11.0),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1.0, color: _line),
            // ---- กลาง: สิ่งที่ต้องทำตอนนี้ (ช่องเดียว / การ์ดเดียว)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 4.0),
                child: cur == null
                    ? Center(
                        child: Text('แตะไมค์แล้วพูดได้เลย',
                            style: _t(12.0, color: _ink3)))
                    : GestureDetector(
                        onHorizontalDragEnd: n < 2 || cur.type == ErUiType.form
                            ? null
                            : (d) {
                                final v = d.primaryVelocity ?? 0;
                                if (v < -200) _uiGo(1, n);
                                if (v > 200) _uiGo(-1, n);
                              },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          layoutBuilder: (a, b) => Stack(
                              alignment: Alignment.topLeft,
                              children: [...b, if (a != null) a]),
                          child: KeyedSubtree(
                            key: ValueKey(
                                '${_speechStep}_${at}_${cur.key}_$_agentUiGen'),
                            child: SizedBox(
                              height: _barH - 16.0,
                              child: _uiBlock(cur),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const VerticalDivider(width: 1.0, color: _line),
            // ---- ขวา: หน้า + ไมค์ + ปิด
            SizedBox(
              width: 112.0,
              child: Stack(children: [
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: _dockArrow(Icons.close_rounded, _closeSpeech),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (total > 1)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        _dockArrow(Icons.chevron_left_rounded,
                            page > 0 ? () => _pageGo(seq, page - 1) : null),
                        Text('${page + 1}/$total',
                            style: _num(10.5,
                                color: _ink2, weight: FontWeight.w700)),
                        _dockArrow(
                            Icons.chevron_right_rounded,
                            page < total - 1
                                ? () => _pageGo(seq, page + 1)
                                : null),
                      ])
                    else
                      const SizedBox(height: 22.0),
                    const SizedBox(height: 8.0),
                    _barMic(),
                    const SizedBox(height: 6.0),
                    ValueListenableBuilder<int>(
                      valueListenable: _micFrame,
                      builder: (_, __, ___) => _micLabel(),
                    ),
                  ],
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// จุดความคืบหน้าของขั้น (แตะเพื่อข้ามไปขั้นนั้น) + ชื่อขั้นปัจจุบัน
  Widget _barSteps() => Row(children: [
        for (final i in _stepOrder)
          GestureDetector(
            onTap: () {
              if (i == _speechStep) return;
              _robot.stop();
              _stopRecord(send: false);
              setState(() => _speechStep = i);
              _agentGreet();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == _speechStep ? 18.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: _speechDone.contains(i)
                    ? _blue
                    : (i == _speechStep ? _blue : _line),
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
              'ขั้น ${_stepPos(_speechStep) + 1}/$_stepCount · ${_steps[_speechStep].$2}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
        ),
      ]);

  /// ไมค์ในแถบ: แตะเปิด แตะอีกครั้งปิดแล้วส่ง · คลื่นรอบปุ่มตามเสียงจริงตอนฟัง
  Widget _barMic() {
    const r = 26.0;
    return SizedBox(
      width: r * 2 + 28.0,
      height: r * 2 + 28.0,
      child: Stack(alignment: Alignment.center, children: [
        if (_recording)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: _micFrame,
                builder: (_, __, ___) => CustomPaint(
                  painter: _MicWave(levels: _wave, inner: r + 3.0, color: _red),
                ),
              ),
            ),
          ),
        Material(
          color: _recording ? _red : (_agentBusy ? _g5 : _blue),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          shadowColor: _blue.withValues(alpha: 0.4),
          // แตะ = เปิดไมค์ · แตะอีกครั้ง = ปิดแล้วส่ง (ไม่ต้องกดค้าง)
          child: InkWell(
            onTap: _micToggle,
            child: SizedBox(
              width: r * 2,
              height: r * 2,
              child: Icon(
                  _recording
                      ? Icons.graphic_eq_rounded
                      : (_agentBusy
                          ? Icons.more_horiz_rounded
                          : Icons.mic_rounded),
                  size: 24.0,
                  color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  /// ข้อความสถานะใต้ไมค์ (บรรทัดเดียว)
  Widget _micLabel() {
    final talking = _robot.mood == ErAuraMood.talking;
    final (text, col) = _recording
        ? (
            'แตะเพื่อส่ง ${_recSec ~/ 60}:${(_recSec % 60).toString().padLeft(2, '0')}',
            _red
          )
        : _agentBusy
            ? ('กำลังคิด…', _ink2)
            : talking
                // ผู้ช่วยพูดออกเสียงอยู่ (ไม่ใช่ไมค์เปิด)
                ? ('ผู้ช่วยพูดอยู่', _blue)
                : ('แตะเพื่อพูด', _ink3);
    return Text(text,
        maxLines: 1, style: _num(9.5, color: col, weight: FontWeight.w700));
  }

  /// จำนวนหน้าของขั้นนี้: การ์ดทั่วไป 1 หน้า ฟอร์ม 1 หน้าต่อช่อง
  /// ขั้นที่แสดงทุกช่องของฟอร์มในหน้าเดียว (ไม่แบ่งหน้าละช่อง)
  /// พยาบาล "ออกจาก ER": ช่องสั้นและกรอกต่อเนื่องกัน ดูพร้อมกันสะดวกกว่า
  /// แพทย์ "ตรวจร่างกาย": ทุกระบบอยู่หน้าเดียว (การ์ดแบบ HPI)
  bool get _formAllAtOnce =>
      _isPeStep(_speechStep) ||
      (ErSession.instance.role == ErRole.nurse &&
          _speechStep < _steps.length &&
          _steps[_speechStep].$2 == 'ออกจาก ER');

  /// ตรวจร่างกาย: ผลตรวจ (PE) → บันทึกการตรวจแบบละเอียด → [ทบทวนระบบ (ROS)]
  int _pagesOf(ErUiBlock b) => b.type != ErUiType.form
      ? 1
      : _isPeStep(_speechStep)
          ? _pePages(_formFields(b)).length
          : _isDxStep(_speechStep)
              ? _dxPages.length
              : _formAllAtOnce
                  ? 1
                  : math.max(1, _formFields(b).length);

  /// หน้าย่อยของฟอร์มตรวจร่างกาย ตามช่องที่มี: 'ros' · 'pe' · 'draw' · 'note'
  /// ลำดับ (2026-10-19): PE → PE ละเอียด (free text) → ROS
  List<String> _pePages(List<String> fields) => [
        'pe',
        if (fields.contains(_peNoteLabel)) 'note',
        if (fields.any(_isRos)) 'ros',
        // วาดภาพแยกเป็นเมนูของตัวเองบนราง (ใต้ตรวจร่างกาย) ไม่อยู่ในหน้าย่อยนี้แล้ว
      ];

  int _pageCount(List<ErUiBlock> seq) => seq.fold(0, (a, b) => a + _pagesOf(b));

  /// หน้าปัจจุบัน (นับรวมทุกการ์ด)
  int _pageAt(List<ErUiBlock> seq) {
    if (seq.isEmpty) return 0;
    final at = _uiIdx.clamp(0, seq.length - 1);
    var p = 0;
    for (var i = 0; i < at; i++) {
      p += _pagesOf(seq[i]);
    }
    return p +
        (seq[at].type == ErUiType.form
            ? _formAt.clamp(0, _pagesOf(seq[at]) - 1)
            : 0);
  }

  /// ไปหน้าที่ p: หาการ์ดที่หน้านั้นอยู่ แล้วตั้งช่องของฟอร์มถ้าเป็นฟอร์ม
  void _pageGo(List<ErUiBlock> seq, int p) {
    final cur = _pageAt(seq);
    var rest = p;
    for (var i = 0; i < seq.length; i++) {
      final n = _pagesOf(seq[i]);
      if (rest < n) {
        setState(() {
          _formFwd = p > cur;
          _uiIdx = i;
          _formAt = seq[i].type == ErUiType.form ? rest : 0;
          // เปลี่ยนหน้าแล้วแถวปกติกลับเป็นซ่อน (โหมดแก้ไขไม่ติดข้ามหน้า)
          _peShowNormal = false;
          _peNoteEdit = false;
          _soPickOpen = false;
          _soEdit = null;
        });
        return;
      }
      rest -= n;
    }
  }

  /// ช่องนี้มีค่าที่กรอกจริง (ไม่นับกฎช่องไม่บังคับ)
  bool _hasVal(int st, String l) =>
      (_filled[st][l] ?? '').trim().isNotEmpty && _fieldDone(st, l);

  /// หน้าในขั้นนี้: (ชื่อหน้า, ครบแล้ว) เรียงตามลำดับหน้าใน stepper
  List<(String, bool)> _pageMeta(List<ErUiBlock> seq) {
    final step = _speechStep;
    final all = _stepLabels(step).every((l) => _fieldDone(step, l));
    return [
      for (final b in seq)
        if (b.type == ErUiType.form && _isPeStep(step)) ...[
          // ตรวจร่างกาย: ช่องว่างนับว่า "ผ่าน" ได้ (ไม่บังคับ) แต่ stepper ต้องบอกว่ากรอกจริงหรือยัง
          for (final pg in _pePages(_formFields(b)))
            switch (pg) {
              'ros' => (
                  'ทบทวนระบบ',
                  _formFields(b).where(_isRos).every((f) => _hasVal(step, f))
                ),
              'note' => ('ตรวจแบบละเอียด', _hasVal(step, _peNoteLabel)),
              'draw' => ('วาดภาพ', _peShotList.isNotEmpty),
              _ => (
                  'ผลตรวจ',
                  _formFields(b)
                      .where((f) => f != _peNoteLabel && !_isRos(f))
                      .every((f) => _hasVal(step, f))
                ),
            },
        ] else if (b.type == ErUiType.form && _isDxStep(step)) ...[
          // ชื่อหน้าไม่ซ้ำชื่อขั้น ("วินิจฉัย" อยู่หัวแผงแล้ว)
          (
            'บันทึกคำวินิจฉัยและรหัสโรค',
            _multiItems(_filled[step][_dxTextLabel]).isNotEmpty &&
                _fieldDone(step, _icd10Label)
          ),
          (
            'เพิ่มเติม',
            (_filled[step][_noteLabel] ?? '').trim().isNotEmpty ||
                (_filled[step][_icd9DxLabel] ?? '').trim().isNotEmpty
          ),
        ] else if (b.type == ErUiType.form && _formAllAtOnce)
          ('แบบฟอร์ม', _formFields(b).every((f) => _fieldDone(step, f)))
        else if (b.type == ErUiType.form)
          for (final f in _formFields(b)) (f, _fieldDone(step, f))
        else if (b.data['intro'] == true)
          ('เริ่มต้น', true)
        else if (b.data['hpi_pick'] == true || b.data['pe_pick'] == true)
          ('Template', true)
        // เคสที่ยังไม่เคยสั่ง Order Set: ครบเมื่อเลือกชุดในรอบนี้แล้วเท่านั้น
        else if (b.data['order_pick'] == true)
          ('Standing Order', _soStarted && _orderPicked.isNotEmpty)
        else if (b.data['so_doc'] == true)
          (
            switch (b.data['folder']) {
              0 => 'Progress Note',
              1 => 'One Day',
              2 => 'Continuation',
              _ => 'คำสั่งแพทย์',
            },
            // Continuation ไม่บังคับ: ครบเมื่อมีรายการในแฟ้มนี้ (ว่าง = เทา ไม่ใช่ ✓)
            _soStarted &&
                (b.data['folder'] == 2
                    ? _soDeckItems().any((x) => x.section == 'Continuation')
                    : _orderPicked.isNotEmpty)
          )
        else if (b.data['esi_ai'] == true)
          ('ESI แนะนำ', true)
        else if (b.data['appt'] == true)
          ('นัดหมาย', true)
        else if (b.type == ErUiType.nextStep)
          ('สรุป', all)
        else
          (b.str('title', 'ข้อมูล'), true),
    ];
  }

  /// stepper ด้านบน: แต่ละหน้ามีแถบ · ชื่อ · สถานะครบ (✓) แตะเพื่อไปหน้านั้น
  /// หน้ามากเกินความกว้าง เลื่อนแนวนอนได้ และเลื่อนให้หน้าปัจจุบันอยู่ในจอเอง
  /// Expanded เฉพาะเมื่อ [on] (ไม่งั้นสูงตามเนื้อหา)
  static const String _hxVsLabel = 'สัญญาณชีพ';

  /// หน้า V/S ของซักประวัติ: เคสใหม่ล้างค่ารอบก่อน (วัดซ้ำ) แล้วสรุปลงฟอร์มให้หน้าสรุปเห็น
  Widget _hxVsPage() {
    final hn = _caseP().hn;
    if (_wfVsFor != hn) {
      _wfVsFor = hn;
      for (final k in const ['sbp', 'dbp', 'hr', 'rr', 'bt', 'spo2', 'dtx']) {
        _triCtl(k).text = '';
      }
      _triVsAt = null;
    }
    final st = _speechStep;
    final sum = _triVsSum();
    if ((_filled[st][_hxVsLabel] ?? '') != sum) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => sum.isEmpty
            ? _filled[st].remove(_hxVsLabel)
            : _filled[st][_hxVsLabel] = sum);
      });
    }
    _qCardNarrow = true;
    final card = _triAssessCards().first;
    _qCardNarrow = false;
    return ListView(padding: EdgeInsets.zero, children: [card]);
  }

  Widget _flexIf(bool on, Widget child) => on ? Expanded(child: child) : child;

  Widget _pageStepper(List<ErUiBlock> seq, int page) {
    // ตัดหน้าคำแนะนำออก: ช่องที่ k ของ stepper = หน้าที่ k+1
    final meta = _pageMeta(seq).skip(1).toList();
    final at = page - 1;
    // ทุกขั้น (2026-10-20): stepper วงเลขอย่างเดียวแบบซักประวัติ ไม่มีชื่อหน้า
    // หน้าเยอะเกิน (> 8) ค่อยใช้แถบเลื่อนแบบเดิม
    if (meta.length <= 8) {
      return _hxStepper(meta, at, onTap: (i) => _pageGo(seq, i + 1));
    }
    return LayoutBuilder(builder: (context, box) {
      final avail = box.maxWidth - 32.0;
      final w = math.max(76.0, avail / meta.length);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_stepperScroll.hasClients) return;
        final target = (at * w - (avail - w) / 2)
            .clamp(0.0, _stepperScroll.position.maxScrollExtent);
        if ((_stepperScroll.offset - target).abs() > 1.0) {
          _stepperScroll.animateTo(target,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic);
        }
      });
      return SizedBox(
        height: 32.0,
        child: ListView.builder(
          controller: _stepperScroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: meta.length,
          itemBuilder: (context, i) {
            final (title, done) = meta[i];
            final cur = i == at;
            final bar =
                cur ? _blue : (done ? _green.withValues(alpha: 0.7) : _line);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _pageGo(seq, i + 1),
              child: SizedBox(
                width: w,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3.0,
                        decoration: BoxDecoration(
                          color: bar,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Row(children: [
                        if (done) ...[
                          const Icon(Icons.check_circle_rounded,
                              size: 11.0, color: _green),
                          const SizedBox(width: 3.0),
                        ],
                        Expanded(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0,
                                  color: cur ? _blue : _ink3,
                                  weight:
                                      cur ? FontWeight.w600 : FontWeight.w500)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// ปุ่มขวาล่าง: เริ่มกรอก → ถัดไป → หน้าสรุป: ครบ = "บันทึก" (เช็กเขียวแล้วไปขั้นถัดไป)
  /// ยังขาด = "ไปช่องที่ขาด" · ขั้นสุดท้ายครบ = "จบเคส" (เปิดสรุปเคส)
  Widget _nextBtn(List<ErUiBlock> seq, int page, int total) {
    if (page == 0 && total > 1) {
      return _navBtn(
          'เริ่มกรอก', Icons.chevron_right_rounded, () => _pageGo(seq, 1),
          trailing: true);
    }
    if (page < total - 1) {
      // หน้าถัดไปเป็นหน้าสรุป: บอกให้ชัดว่าไปตรวจทาน (แบบซักประวัติพยาบาล)
      final toReview = page == total - 2 &&
          seq.isNotEmpty &&
          seq.last.type == ErUiType.nextStep &&
          seq.last.data['review'] == true;
      // หัตถการ: ยังไม่มีรายการ = ปุ่มไปต่อกดไม่ได้
      final noProc =
          _steps[_speechStep].$2 == 'หัตถการ' && _procItems().isEmpty;
      // หน้า Order Set: ยังไม่เลือกชุด = ปุ่มไปต่อกดไม่ได้
      final noSet = _uiIdx < seq.length &&
          seq[_uiIdx].data['order_pick'] == true &&
          !_soSetPicked.contains(_caseP().hn);
      return _navBtn(
          toReview ? 'ตรวจทาน' : 'ถัดไป',
          Icons.chevron_right_rounded,
          noProc || noSet ? null : () => _pageGo(seq, page + 1),
          trailing: true);
    }
    final step = _speechStep;
    // สั่งการรักษา: ขาด = รายการในแบบร่างที่ยังไม่ยืนยันรายละเอียด
    final soMissing =
        _steps[step].$2 == 'สั่งการรักษา' ? _soReviewMissing() : null;
    final missing = soMissing ??
        [
          for (final l in _stepLabels(step))
            if (!_fieldDone(step, l)) l
        ];
    if (soMissing != null && soMissing.isNotEmpty) {
      return _navBtn('ระบุรายการที่ขาด (${soMissing.length})',
          Icons.chevron_right_rounded, () => _soEditOpen(soMissing.first),
          trailing: true);
    }
    // สั่งข้ามขั้นนี้แล้ว: ยังไม่ครบก็ไปต่อได้ (ช่องที่ขาดยังเห็นในหน้าตรวจสอบ)
    if (missing.isNotEmpty && _skipAsked == step) {
      return _navBtn('ข้ามไปขั้นต่อไป', Icons.chevron_right_rounded, () {
        _formFwd = true;
        _confirmStep();
      }, trailing: true);
    }
    if (missing.isNotEmpty) {
      return _navBtn(
          'ไปช่องที่ขาด (${missing.length})', Icons.chevron_right_rounded, () {
        final fi = seq.indexWhere((x) => x.type == ErUiType.form);
        if (fi < 0) return;
        final pgs = _pePages(_formFields(seq[fi]));
        final k = _isPeStep(step)
            // ตรวจร่างกาย: ไปหน้าย่อยที่ช่องที่ขาดอยู่ (ROS / ผลตรวจ / ละเอียด)
            ? pgs.indexOf(_isRos(missing.first)
                ? 'ros'
                : missing.first == _peNoteLabel
                    ? 'note'
                    : 'pe')
            : _isDxStep(step)
                ? _dxPageOf(missing.first)
                : _formFields(seq[fi]).indexOf(missing.first);
        setState(() {
          _formFwd = false;
          _uiIdx = fi;
          _formAt = k < 0 ? 0 : k;
        });
      }, trailing: true);
    }
    return KeyedSubtree(
      key: _wfSaveBtnKey,
      child: _navBtn('บันทึก', Icons.check_rounded, () {
        // ขั้นสุดท้ายบันทึกแบบเดียวกับขั้นอื่น (ยังไม่เปิดหน้าสรุปเคส 2026-10-19)
        _wfSaveBurst(_steps[step].$2,
            // ลงว่าขั้นนี้เสร็จตอนเขียวเต็มแผง (รางขึ้นเช็กก่อนวงหดเข้าไป)
            atFull: () => setState(() {
                  _speechDone.add(step);
                  // สั่งการรักษา: แบบร่างกลายเป็นคำสั่งครั้งใหม่ (แผงซ้ายเห็นใบคำสั่งทันที)
                  if (_steps[step].$2 == 'สั่งการรักษา') _soCommit();
                }),
            onClose: () {
              _skipAsked = -1;
              _uiIdx = 0;
              _formAt = 0;
              _closeSpeech();
              // บันทึก HPI แล้ว: แผงซ้ายเลื่อนไป HPI ในการ์ดอาการสำคัญ + ไฮไลต์
              if (_isHpiStep(step)) _showHpiHistory();
            });
      }),
    );
  }

  /// แอนิเมชันบันทึกสำเร็จของทุกขั้นใน workflow (ใช้ร่วมกันทุกปุ่มบันทึก)
  /// เขียวแผ่จากปุ่มบันทึก (_wfSaveBtnKey) → เช็ก ค้างให้อ่าน → [atFull] ตอนเขียวเต็มแผง
  /// → หดเข้าไอคอนขั้นบนราง + [onClose] (ปกติ = หุบแผง) · กันกดซ้ำระหว่างเล่น
  void _wfSaveBurst(String name,
      {VoidCallback? atFull, required VoidCallback onClose}) {
    if (_wfSaving) return;
    _wfSaving = true;
    HapticFeedback.mediumImpact();
    final panel = _wfRectOf(_wfPanelKey);
    final btn = _wfRectOf(_wfSaveBtnKey);
    if (panel == null || btn == null) {
      _wfSaving = false;
      atFull?.call();
      onClose();
      return;
    }
    late final OverlayEntry e;
    e = OverlayEntry(
        builder: (_) => _SaveBurst(
            panel: panel,
            tab: _wfRectOf(_wfSelCellKey),
            from: btn.center,
            to: _wfRectOf(_wfSelIconKey)?.center,
            base: _t(16.0),
            step: name,
            onClose: () {
              _wfSaving = false;
              if (mounted) onClose();
            },
            onEnd: () => e.remove()));
    Overlay.of(context).insert(e);
    if (atFull != null) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) atFull();
      });
    }
  }

  /// ปุ่มเปลี่ยนหน้าขนาดใหญ่ (สูง 44) กดง่ายบนแท็บเล็ต
  Widget _navBtn(String label, IconData icon, VoidCallback? onTap,
      {bool primary = true, bool trailing = false}) {
    final on = onTap != null;
    final fg = primary && on ? Colors.white : (on ? _blue : _g5);
    final ic = Icon(icon, size: 20.0, color: fg);
    // footer ทุกปุ่มมีแต่ข้อความ ไม่มีไอคอน (กฎ footer แผงขวา 2026-10-19)
    const arrow = true;
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          // Google style: filled pill (หลัก) / outlined pill (รอง) ไม่มีเงาวาว
          height: 48.0,
          decoration: BoxDecoration(
            color: primary && on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(
                color: primary && on
                    ? _blue
                    : (on ? const Color(0xFFC4C7C5) : _line)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            // ระยะไอคอน-ข้อความ 6 ไม่ให้ไอคอนชิดตัวอักษร
            if (!trailing && !arrow) ...[ic, const SizedBox(width: 6.0)],
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: fg, weight: FontWeight.w600)),
            ),
            if (trailing && !arrow) ...[const SizedBox(width: 6.0), ic],
          ]),
        ),
      ),
    );
  }

  Widget _dockArrow(IconData icon, VoidCallback? onTap) => _Press(
          child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 22.0,
          height: 22.0,
          child: Icon(icon, size: 16.0, color: onTap == null ? _g5 : _blue),
        ),
      ));

  /// เนื้อการ์ดในแผ่นล่าง: หัวข้อ + เนื้อหาเลื่อนได้ (แผ่นเป็นพื้นให้ ไม่มีกรอบซ้อน)
  Widget _uiCard(ErUiBlock b,
      {required IconData icon,
      required String title,
      Color? accent,
      Widget? trailing,
      required Widget child}) {
    final a = accent ?? _blue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 22.0,
            height: 22.0,
            decoration: BoxDecoration(
              color: a.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Icon(icon, size: 13.0, color: a),
          ),
          const SizedBox(width: 7.0),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
          ),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 6.0),
        Flexible(child: SingleChildScrollView(child: child)),
      ],
    );
  }
}

/// หนึ่งขั้นของ sheet เลือกรายการ: current อ่านสด (ค่าอาจเปลี่ยนจากขั้นก่อน เช่น ICD9 ตามหัตถการ)
class _ListStep {
  const _ListStep(this.label, this.opts,
      {this.codes,
      String? short,
      this.people = false,
      this.many = false,
      this.confirm = false,
      this.tags,
      this.tagOf,
      this.setTag,
      required this.current,
      required this.apply})
      : short = short ?? label;
  final String label;

  /// รายชื่อบุคลากร: แถว avatar + ชื่อ (แบบเมนูเลือกแพทย์ผู้สั่ง)
  final bool people;

  /// เลือกได้หลายรายการ: แตะ = สลับเลือก · ค่าเก็บบรรทัดละรายการ
  final bool many;

  /// ปุ่มถัดไปหยุดที่ขั้นนี้เสมอ แม้มีค่าแล้ว (ค่าเติมให้อัตโนมัติ ให้ผู้ใช้ยืนยัน เช่น ICD-9-CM)
  final bool confirm;

  /// บทบาทย่อยของรายการที่เลือก (เช่น ผู้ทำ / ผู้ช่วย): tagOf = บทบาทปัจจุบัน (null = ไม่ได้เลือก)
  final List<String>? tags;
  final String? Function(String)? tagOf;
  final void Function(String, String?)? setTag;

  /// ชื่อสั้นบนปุ่ม "ถัดไป …"
  final String short;
  final List<String> opts;
  final Map<String, String>? codes;
  final String? Function() current;
  final void Function(String) apply;
}
