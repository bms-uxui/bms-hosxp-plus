// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ Dr.Note ช่วยคิด (ต้นแบบ)
// วินิจฉัยแยกโรค (differential) จากข้อมูลเคส + เหตุผล + สิ่งที่ควรทำต่อ + ข้อมูลที่ยังขาด
// ใช้ LLM ผ่าน ErAi.chat (OpenAI-compatible) · เปลี่ยนเป็น MedGemma ได้ด้วยการชี้ endpoint ใหม่
// ข้อเสนอเท่านั้น: ไม่ลงวินิจฉัย/สั่งเอง แพทย์กดเลือกทุกครั้ง · ไม่ส่งชื่อ/HN ออกไป

/// หนึ่งโรคที่ควรนึกถึง
class _DxIdea {
  const _DxIdea(this.dx, this.icd, this.level, this.why, this.next, this.ref);

  final String dx;
  final String icd;

  /// 'สูง' · 'ปานกลาง' · 'ต้องตัดออก'
  final String level;
  final List<String> why;
  final List<String> next;
  final String ref;
}

/// ข้อเสนอที่เห็นแอนิเมชันสแกนแล้ว · ที่เล่นตอนจบ (outro) เสร็จแล้ว
/// ผลที่มาตอนกำลังสแกน = เล่นตอนจบก่อนค่อยแสดงรายการ (ต่อเนื่อง ไม่สลับแข็ง)
final Set<String> _dxScanned = {};
final Set<String> _dxRevealed = {};

/// นับรอบเปลี่ยนข้อเสนอ: ให้ bottom sheet (นอก tree ของหน้า) วาดใหม่
final ValueNotifier<int> _dxTick = ValueNotifier(0);

class _DxResult {
  const _DxResult(this.ideas, this.missing);

  final List<_DxIdea> ideas;
  final List<String> missing;
}

mixin _FeaturesWorkflowDxAssistState on State<ErFlowHomeWidget> {
  /// ผลต่อเคส (key = HN|ลายเซ็นข้อมูล) · null = กำลังคิด
  final Map<String, _DxResult?> _dxAi = {};

  /// ความเห็นแพทย์ต่อข้อเสนอ (key|โรค → true ตรง / false ไม่ตรง) เก็บไว้วัดความแม่น
  final Map<String, bool> _dxVote = {};

  String? _dxAiErr;

  /// ICD-10 ที่ AI แนะนำจาก Diagnosis Text (key = HN|ข้อความวินิจฉัย) · null = กำลังคิด
  final Map<String, List<(String, String, String)>?> _icdAi = {};
  String? _icdAiErr;

  /// template HPI ที่ AI เลือกจากข้อมูลเคส (key = HN) → (id, เหตุผล) · null = กำลังคิด
  final Map<String, (String, String)?> _hpiAi = {};
}

extension _FeaturesWorkflowDxAssistPart on _ErFlowHomeWidgetState {
  /// ข้อมูลเคสที่ส่งให้โมเดล (ไม่มีชื่อ/HN)
  String _dxCaseText() {
    final c = _case;
    String last(List<double> s) => s.isEmpty
        ? '-'
        : (s.last % 1 == 0 ? s.last.toStringAsFixed(0) : '${s.last}');
    final f = _filled;
    String filledOf(bool Function(String) keep) => [
          for (final m in f)
            for (final e in m.entries)
              if (keep(e.key) && e.value.trim().isNotEmpty)
                '${e.key}: ${e.value}'
        ].join('; ');
    final pe = filledOf((k) =>
        _peField.values.contains(k) ||
        k.endsWith(' - รายละเอียด') ||
        k == _peNoteLabel);
    final ros = filledOf((k) => k.startsWith('ROS '));
    final hpi = [for (final m in f) m['HPI']].whereType<String>().join(' ');
    final labs = [
      for (final l in c.labs)
        if (l.isNumeric)
          '${l.name} ${l.value}${l.abnormal ? ' (ผิดปกติ ${l.lo}-${l.hi})' : ''}'
        else
          '${l.name} ${l.text}${l.flagged ? ' (ผิดปกติ)' : ''}'
    ].join('; ');
    return [
      'อายุ ${c.age} ปี เพศ ${c.sex}',
      'อาการสำคัญ: ${c.cc}',
      'ประวัติปัจจุบัน: ${hpi.isNotEmpty ? _richPlain(hpi) : c.hpi}',
      'สัญญาณชีพล่าสุด: HR ${last(c.hr)}, BP ${last(c.sbp)}/${last(c.dbp)}, RR ${last(c.rr)}, SpO2 ${last(c.spo2)}, BT ${last(c.bt)}',
      'GCS: ${c.gcsScore} · ความรู้สึกตัว: ${c.consciousness} · pain ${c.painScore ?? '-'}/10 · รูม่านตา: ${erPupilOf(c)}',
      if (ros.isNotEmpty) 'ทบทวนระบบ: $ros',
      if (pe.isNotEmpty) 'ตรวจร่างกาย: $pe',
      if (labs.isNotEmpty) 'แล็บ: $labs',
      'โรคประจำตัว: ${c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', ')}',
      'ยาที่ใช้: ${c.meds.isEmpty ? 'ไม่มี' : c.meds.map((m) => m.name).join(', ')}',
      'แพ้ยา: ${c.allergies.isEmpty ? 'ไม่มี' : c.allergies.join(', ')}',
    ].join('\n');
  }

  String get _dxKey => '${_caseP().hn}|${_dxCaseText().hashCode}';

  /// ขอความเห็นจากโมเดล (ครั้งเดียวต่อข้อมูลชุดเดียวกัน · force = คิดใหม่)
  Future<void> _dxThink({bool force = false}) async {
    final key = _dxKey;
    if (!force && _dxAi.containsKey(key)) return;
    _dxSet(() {
      _dxAi[key] = null;
      _dxAiErr = null;
    });
    const sys =
        'คุณเป็นผู้ช่วยแพทย์ห้องฉุกเฉิน ช่วยคิดวินิจฉัยแยกโรคจากข้อมูลผู้ป่วย '
        'ตอบเป็น JSON เท่านั้น รูปแบบ {"differentials":[{"dx":"ชื่อโรคภาษาอังกฤษ","icd10":"รหัส",'
        '"likelihood":"สูง|ปานกลาง|ต้องตัดออก","why":["เหตุผลจากข้อมูลที่ให้ ข้อละ 1 เรื่องสั้น ๆ"],'
        '"next":["สิ่งที่ควรตรวจ/ทำต่อ ข้อละ 1 อย่าง"],"ref":"guideline ที่อ้าง เช่น ATLS 11, Sepsis-3, AHA Stroke 2019"}],'
        '"missing":["ข้อมูลสำคัญที่ยังขาดและจะเปลี่ยนการวินิจฉัย"]} '
        'ให้ 3-5 โรค เรียงจากเป็นไปได้มากสุด ใส่ภาวะอันตรายที่ต้องตัดออกเสมอ '
        'เหตุผลต้องอ้างข้อมูลที่ได้รับเท่านั้น ห้ามแต่งค่าที่ไม่มี ตอบภาษาไทย ยกเว้นชื่อโรค';
    try {
      final out = await ErAi.chat([
        {'role': 'system', 'content': sys},
        {'role': 'user', 'content': _dxCaseText()},
      ], json: true, temperature: 0.1, maxTokens: 900);
      final j = ErAi.extractJson(out);
      if (j == null) throw 'อ่านคำตอบไม่ได้';
      List<String> strs(dynamic v) =>
          [for (final x in (v as List? ?? const [])) '$x'];
      final ideas = [
        for (final d in (j['differentials'] as List? ?? const []))
          if (d is Map)
            _DxIdea(
                '${d['dx'] ?? ''}',
                '${d['icd10'] ?? ''}',
                '${d['likelihood'] ?? ''}',
                strs(d['why']),
                strs(d['next']),
                '${d['ref'] ?? ''}'),
      ].where((d) => d.dx.isNotEmpty).take(5).toList();
      if (!mounted) return;
      _dxSet(() => _dxAi[key] = _DxResult(ideas, strs(j['missing'])));
    } catch (e) {
      if (!mounted) return;
      _dxSet(() {
        _dxAi.remove(key);
        _dxAiErr = 'Dr.Note คิดไม่สำเร็จ ลองใหม่อีกครั้ง';
      });
      debugPrint('Dr.Note ช่วยคิด ผิดพลาด: $e');
    }
  }

  /// รายการ ICD-10 ของข้อเสนอ: ชื่อตาม master ถ้ามี ไม่งั้น "รหัส ชื่อโรค"
  String? _dxIcdEntry(_DxIdea d) {
    final code = d.icd.trim().toUpperCase();
    if (code.isEmpty) return null;
    final byCode = {for (final e in _icd10Codes().entries) e.value: e.key};
    return byCode[code] ?? byCode[code.replaceAll('.', '')] ?? '$code ${d.dx}';
  }

  /// แตะเดียวลงทั้ง Diagnosis Text + รหัส ICD-10 ของข้อเสนอ (ต่อท้าย ไม่ทับของเดิม)
  /// แตะซ้ำ (ใส่แล้ว) = เอาออกทั้งคู่ · ค่าที่ลงมีไฮไลต์ให้เห็น (P8)
  void _dxUse(_DxIdea d) {
    final st = _speechStep;
    final txt = _multiItems(_filled[st][_dxTextLabel]);
    final icd = _multiItems(_filled[st][_icd10Label], icd: true);
    final entry = _dxIcdEntry(d);
    final used = txt.contains(d.dx);
    ErFeedback.confirm();
    _dxSet(() {
      final t2 = used ? (txt..remove(d.dx)) : [...txt, d.dx];
      // เอาออก: ลบรายการ ICD ของโรคนี้ทั้งที่ชื่อตรงและที่ขึ้นต้นด้วยรหัสเดียวกัน
      final code = d.icd.trim().toUpperCase();
      final i2 = entry == null
          ? icd
          : used
              ? (icd
                ..removeWhere((x) =>
                    x == entry ||
                    (code.isNotEmpty && x.toUpperCase().startsWith('$code '))))
              : (icd.contains(entry) ? icd : [...icd, entry]);
      for (final (k, v) in [(_dxTextLabel, t2), (_icd10Label, i2)]) {
        if (v.isEmpty) {
          _filled[st].remove(k);
        } else {
          _filled[st][k] = v.join('\n');
        }
      }
      if (!used) {
        _stampBy(_dxTextLabel, [d.dx]);
        if (entry != null) _stampBy(_icd10Label, [entry]);
        _flashGlow({_dxTextLabel, if (entry != null) _icd10Label});
      }
    });
  }

  /// "Dr.Note ช่วยคิด" บนสุดของหน้าวินิจฉัย (Google style ไม่มีกรอบซ้อนกรอบ)
  /// หัว = ชื่อ + ที่มาข้อมูลบรรทัดรอง + ปุ่ม tonal "คิดใหม่" · รายการโรคในการ์ดขาวขอบเทาใบเดียว
  /// บนหน้าวินิจฉัย: การ์ดขอ AI แบบ AI Overview อย่างเดียว · ข้อเสนอทั้งหมดอยู่ใน bottom sheet
  /// ไม่คิดเองอัตโนมัติ (P8) · ปุ่ม: ยังไม่ขอ = "ช่วยคิด" · มีผลแล้ว = "ดูข้อเสนอ"
  Widget _dxAssistCard(bool big) {
    return _aiAskCard(
      // หัวข้อบอกว่าฟีเจอร์ทำอะไร (ไม่ใช่ชื่อผู้ช่วย) · คำอธิบายบอกที่มาและผลที่ได้
      title: 'AI ช่วยวินิจฉัย',
      sub: 'Dr.Note เสนอโรคพร้อม ICD-10',
      // ปุ่มคำเดียวตลอด (ผู้ใช้กำหนด) · มีผลแล้ว = เปิดดูผลเดิม (วิเคราะห์ใหม่ได้ใน sheet)
      btn: 'เริ่มวิเคราะห์',
      onTap: _dxOpenSheet,
      compact: true,
      // ภาพแว่นขยายสไตล์เดียวกับนาฬิกา Fast track (ไม่ใช้ตัวละคร 3D)
      art: const _MagnifierHero(),
    );
  }

  /// setState + แจ้ง sheet ข้อเสนอให้วาดใหม่ (sheet อยู่นอก tree ของหน้า)
  void _dxSet(VoidCallback f) {
    setState(f);
    _dxTick.value++;
  }

  /// เปิด bottom sheet ข้อเสนอ Dr.Note (ยังไม่เคยขอ = เริ่มคิดพร้อมเปิด)
  Future<void> _dxOpenSheet() async {
    if (!_dxAi.containsKey(_dxKey)) _dxThink();
    await _placedSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 640.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.78,
        child: ValueListenableBuilder<int>(
          valueListenable: _dxTick,
          builder: (_, __, ___) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 24.0),
            // ความสูงเปลี่ยนนุ่ม ๆ จากแผงสแกนเป็นรายการโรค (ไม่กระโดด)
            child: AnimatedSize(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _dxSuggestBody(),
            ),
          ),
        ),
      ),
    );
  }

  /// เนื้อหาใน sheet: หัว + คิดใหม่ · กำลังคิด / ผิดพลาด / รายการโรค · ข้อมูลที่ยังขาด · ที่มา
  Widget _dxSuggestBody() {
    final key = _dxKey;
    final r = _dxAi[key];
    final thinking = _dxAi.containsKey(key) && r == null;
    // ป้ายโอกาส: ต้องตัดออก = ภาวะอันตราย (แดง) · สูง = กรมท่า · อื่น ๆ = เทา
    (Color, Color) tone(String l) => l.contains('ตัด')
        ? (_red.withValues(alpha: 0.08), _red)
        : l.contains('สูง')
            ? (_blue.withValues(alpha: 0.08), _blue)
            : (_panelSoft, _ink2);
    final note = _t(12.5, color: _ink3, weight: FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // หัวส่วนบรรทัดเดียว (ขนาดเท่าหัวส่วนอื่นในหน้า) · คิดใหม่ = ไอคอนชิดขวา
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 18.0, color: _blue),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text('AI ช่วยวินิจฉัย',
                  style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
            if (!thinking)
              // ปุ่มมีข้อความ: ไอคอนหมุนอย่างเดียวไม่สื่อว่าจะเกิดอะไร
              _miniBtn(Icons.refresh_rounded, 'วิเคราะห์ใหม่',
                  () => _dxThink(force: true),
                  tooltip: 'ให้ Dr.Note วิเคราะห์ใหม่จากข้อมูลล่าสุดของเคส'),
          ]),
          Text('โรคที่ควรนึกถึงจากข้อมูลเคส เรียงจากโอกาสสูงสุด',
              style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(height: 14.0),
          if (thinking ||
              (r != null &&
                  _dxScanned.contains(key) &&
                  !_dxRevealed.contains(key)))
            () {
              if (thinking) {
                _dxScanned.add(key);
                _dxRevealed.remove(key);
              }
              return _DxAnalyzing(
                  items: _dxScanItems(),
                  groups: _dxScanGroups,
                  base: _t(12.5),
                  done: r != null,
                  onDone: () => _dxSet(() => _dxRevealed.add(key)));
            }()
          else if (r == null)
            Text(_dxAiErr ?? '',
                style: _t(12.5, color: _red, weight: FontWeight.w500))
          else ...[
            if (r.ideas.isEmpty)
              Text('ยังไม่มีข้อเสนอจากข้อมูลตอนนี้', style: note)
            else
              // การ์ดละโรค เรียงตามโอกาส (ใน sheet มีที่พอ แสดงรายละเอียดครบไม่ต้องกาง)
              // การ์ดลอยขึ้นทีละใบต่อจากตอนจบของการสแกน
              for (var i = 0; i < r.ideas.length; i++)
                _Appear(
                    key: ValueKey('dx-idea-$key-$i'),
                    index: i,
                    child: _dxIdeaRow(
                        i + 1, r.ideas[i], key, tone(r.ideas[i].level))),
            // ข้อมูลที่ยังขาด: หัวข้อ + บรรทัดละเรื่อง (ไม่อัดเป็นประโยคยาว)
            if (r.missing.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.help_outline_rounded,
                          size: 18.0, color: _ink2),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ข้อมูลที่ยังขาด',
                                  style: _t(13.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              for (final m in r.missing)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(m,
                                      style: _t(14.0,
                                          color: _ink2,
                                          height: 1.45,
                                          weight: FontWeight.w500)),
                                ),
                            ]),
                      ),
                    ]),
              ),
            ],
          ],
          const SizedBox(height: 8.0),
          // ที่มาข้อมูลย้ายมาท้ายส่วน (ไม่เป็นบรรทัดรองใต้หัว)
          Text(
              'ข้อเสนอจาก AI อ่านจาก CC, HPI, สัญญาณชีพ, ตรวจร่างกาย และแล็บ แพทย์เป็นผู้ตัดสิน',
              style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// หนึ่งโรคใน sheet (การ์ดเต็ม อ่านง่าย): อันดับ + ชื่อโรคตัวใหญ่ · ชิปรหัส + ป้ายโอกาส
  /// ปุ่ม "ลงวินิจฉัย" มีข้อความ (ลงทั้งคำวินิจฉัยและรหัส) · เหตุผล / ควรทำ เป็นรายการทีละบรรทัด
  /// ท้ายการ์ด: อ้างอิง + โหวตตรง/ไม่ตรง
  Widget _dxIdeaRow(int n, _DxIdea d, String key, (Color, Color) tone) {
    final vote = _dxVote['$key|${d.dx}'];
    final used = _multiItems(_filled[_speechStep][_dxTextLabel]).contains(d.dx);
    Widget thumb(bool up) => IconButton(
          onPressed: () => _dxSet(() => _dxVote['$key|${d.dx}'] = up),
          tooltip: up ? 'ตรงกับเคสนี้' : 'ไม่ตรงกับเคสนี้',
          iconSize: 20.0,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
          icon: Icon(
              up
                  ? (vote == true
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_outlined)
                  : (vote == false
                      ? Icons.thumb_down_alt_rounded
                      : Icons.thumb_down_alt_outlined),
              color: vote == up ? _blue : _ink3),
        );
    // โมเดลบางครั้งรวมหลายเรื่องในข้อเดียว (คั่นจุลภาค) → แยกเป็นบรรทัดละเรื่อง อ่านง่าย
    List<String> split(List<String> xs) => [
          for (final x in xs)
            for (final p in x.split(RegExp(r',\s+')))
              if (p.trim().isNotEmpty) p.trim()
        ];
    // หัวข้อย่อย + รายการทีละบรรทัด (จุดนำหน้า ไม่ใช้ "·" คั่น)
    Widget group(IconData icon, String title, List<String> items) => Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 16.0, color: _ink2),
              const SizedBox(width: 6.0),
              Text(title,
                  style: _t(13.0, color: _ink2, weight: FontWeight.w700)),
            ]),
            for (final it in items)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5.0,
                        height: 5.0,
                        margin: const EdgeInsets.only(top: 8.0, right: 10.0),
                        decoration: const BoxDecoration(
                            color: _ink3, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Text(it.trim(),
                            style: _t(14.0,
                                color: _ink,
                                height: 1.5,
                                weight: FontWeight.w500)),
                      ),
                    ]),
              ),
          ]),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 12.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color:
                used ? _green.withValues(alpha: 0.6) : const Color(0xFFDADCE0),
            width: used ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 28.0,
              height: 28.0,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE), shape: BoxShape.circle),
              child: Text('$n',
                  style: _num(13.0, color: _blue, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.dx,
                        style: _t(17.0,
                            color: _inkTitle,
                            height: 1.3,
                            weight: FontWeight.w700)),
                    const SizedBox(height: 6.0),
                    Wrap(spacing: 6.0, runSpacing: 4.0, children: [
                      if (d.icd.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text('ICD-10  ${d.icd}',
                              style: _num(12.5,
                                  color: _blue, weight: FontWeight.w700)),
                        ),
                      if (d.level.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: tone.$1,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text(
                              d.level.contains('ตัด')
                                  ? d.level
                                  : 'โอกาส${d.level}',
                              style: _t(12.0,
                                  color: tone.$2, weight: FontWeight.w700)),
                        ),
                    ]),
                  ]),
            ),
            const SizedBox(width: 8.0),
            // ลงทั้งคำวินิจฉัย + รหัส · ลงแล้ว = เขียว แตะซ้ำเอาออก
            _Press(
              radius: 100.0,
              child: GestureDetector(
                onTap: () => _dxUse(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: used ? _green : const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(used ? Icons.check_rounded : Icons.add_rounded,
                        size: 18.0, color: used ? Colors.white : _blue),
                    const SizedBox(width: 6.0),
                    Text(used ? 'ลงแล้ว' : 'ลงวินิจฉัย',
                        style: _t(13.5,
                            color: used ? Colors.white : _blue,
                            weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (d.why.isNotEmpty)
                    group(Icons.fact_check_outlined, 'เหตุผลจากข้อมูลเคส',
                        split(d.why)),
                  if (d.next.isNotEmpty)
                    group(Icons.playlist_add_check_rounded, 'ควรตรวจหรือทำต่อ',
                        split(d.next)),
                  const SizedBox(height: 10.0),
                  const Divider(height: 1.0, color: _line),
                  Row(children: [
                    Expanded(
                      child: Text(d.ref.isEmpty ? '' : 'อ้างอิง ${d.ref}',
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w500)),
                    ),
                    Text('ตรงกับเคสไหม',
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                    thumb(true),
                    thumb(false),
                  ]),
                ]),
          ),
        ],
      ),
    );
  }

  /// กลุ่มผลวิเคราะห์ฝั่งขวาของแอนิเมชันกำลังวิเคราะห์
  List<String> get _dxScanGroups =>
      const ['ไหลเวียนและหายใจ', 'อาการและระบบประสาท', 'ผลแล็บ'];

  /// ข้อมูลเคสที่ป้อนเข้าเครื่องสแกน: (ค่าดิบ, ความหมายหลังวิเคราะห์, กลุ่ม, ผิดปกติ)
  /// ใช้เฉพาะค่าที่ผิดปกติจริงจากเคส (P1) + อาการสำคัญ ไม่เกิน 7 ชิ้น
  List<(String, String, int, bool)> _dxScanItems() {
    final c = _case;
    String f(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';
    final out = <(String, String, int, bool)>[];
    if (c.cc.trim().isNotEmpty) {
      final cc = c.cc.trim().split(RegExp(r'[ ,]')).first;
      out.add(('CC $cc', 'อาการนำ', 1, false));
    }
    if (c.hr.isNotEmpty && (c.hr.last > 100 || c.hr.last < 60)) {
      out.add((
        'HR ${f(c.hr.last)}',
        c.hr.last > 100 ? 'หัวใจเต้นเร็ว' : 'หัวใจเต้นช้า',
        0,
        true
      ));
    }
    if (c.sbp.isNotEmpty && (c.sbp.last < 90 || c.sbp.last >= 140)) {
      out.add((
        'BP ${c.bp}',
        c.sbp.last < 90 ? 'ความดันต่ำ' : 'ความดันสูง',
        0,
        true
      ));
    }
    if (c.rr.isNotEmpty && (c.rr.last > 20 || c.rr.last < 12)) {
      out.add((
        'RR ${f(c.rr.last)}',
        c.rr.last > 20 ? 'หายใจเร็ว' : 'หายใจช้า',
        0,
        true
      ));
    }
    if (c.spo2.isNotEmpty && c.spo2.last < 95) {
      out.add(('SpO₂ ${f(c.spo2.last)}', 'ออกซิเจนต่ำ', 0, true));
    }
    if (c.bt.isNotEmpty && (c.bt.last >= 37.5 || c.bt.last < 36)) {
      out.add((
        'BT ${f(c.bt.last)}',
        c.bt.last >= 37.5 ? 'มีไข้' : 'อุณหภูมิต่ำ',
        1,
        true
      ));
    }
    final gcs = int.tryParse(c.gcsScore);
    if (gcs != null && gcs < 15) {
      out.add(('GCS $gcs', 'ความรู้สึกตัวลดลง', 1, true));
    }
    for (final l in c.labs) {
      if (out.length >= 7) break;
      if (!l.isNumeric || !l.abnormal) continue;
      out.add((
        '${l.name} ${f(l.value)}',
        '${l.name} ${l.value > l.hi ? 'สูง' : 'ต่ำ'}',
        2,
        true
      ));
    }
    return out.take(7).toList();
  }

  // ------------------------------------------------ AI แนะนำ ICD-10
  // จาก Diagnosis Text ที่แพทย์ลง + ข้อมูลเคส → รหัส ICD-10 (WHO 2019/TM ไทย)
  // แพทย์แตะชิปเพื่อเพิ่มเท่านั้น · รหัสที่มีใน master ลงเป็นชื่อตาม master

  String get _icdAiKey =>
      '${_caseP().hn}|${_filled[_speechStep][_dxTextLabel] ?? ''}';

  Future<void> _icdSuggest() async {
    final dx = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final key = _icdAiKey;
    setState(() {
      _icdAi[key] = null;
      _icdAiErr = null;
    });
    const sys =
        'คุณเป็นผู้ช่วยลงรหัสโรคห้องฉุกเฉิน แนะนำรหัส ICD-10 (WHO 2019 / ICD-10-TM) '
        'ที่ตรงที่สุดกับการวินิจฉัยของแพทย์ ใช้รหัสระดับละเอียดที่สุดที่ข้อมูลรองรับ '
        'ถ้าเป็นการบาดเจ็บให้เพิ่มรหัสสาเหตุภายนอก (V/W/X/Y) เมื่อข้อมูลบอกกลไก '
        'ตอบเป็น JSON เท่านั้น {"codes":[{"code":"S72.00","name":"ชื่อภาษาอังกฤษ",'
        '"for":"วินิจฉัยข้อไหนของแพทย์"}]} ไม่เกิน 6 รหัส เรียงวินิจฉัยหลักก่อน ห้ามแต่งรหัสที่ไม่มีจริง '
        'ก่อนตอบให้ตรวจทุกรหัสว่าชื่อทางการของรหัสนั้นใน ICD-10 ตรงกับโรคจริง (ตัวอักษรหมวดต้องถูก เช่น C = เนื้องอก '
        'S/T = การบาดเจ็บ R = อาการ) ถ้าไม่แน่ใจให้ใช้รหัสระดับหมวดที่แน่ใจแทน '
        'ภาวะช็อกจากการเสียเลือดจากอุบัติเหตุ = T79.4 ช็อกจากการเสียเลือดที่ไม่ใช่อุบัติเหตุ = R57.1';
    try {
      final out = await ErAi.chat([
        {'role': 'system', 'content': sys},
        {
          'role': 'user',
          'content': 'การวินิจฉัยของแพทย์:\n'
              '${dx.isEmpty ? '(ยังไม่ได้ลง ใช้ข้อมูลเคส)' : dx.map((d) => '- $d').join('\n')}\n\n'
              'ข้อมูลเคส:\n${_dxCaseText()}'
        },
      ], json: true, temperature: 0.1, maxTokens: 500);
      final j = ErAi.extractJson(out);
      if (j == null) throw 'อ่านคำตอบไม่ได้';
      final codes = [
        for (final c in (j['codes'] as List? ?? const []))
          if (c is Map && '${c['code'] ?? ''}'.trim().isNotEmpty)
            (
              '${c['code']}'.trim().toUpperCase(),
              '${c['name'] ?? ''}'.trim(),
              '${c['for'] ?? ''}'.trim()
            ),
      ].take(6).toList();
      if (!mounted) return;
      setState(() => _icdAi[key] = codes);
    } catch (e) {
      debugPrint('AI แนะนำ ICD-10 ผิดพลาด: $e');
      if (!mounted) return;
      setState(() {
        _icdAi.remove(key);
        _icdAiErr = 'แนะนำรหัสไม่สำเร็จ ลองใหม่อีกครั้ง';
      });
    }
  }

  /// ข้อเสนอ ICD-10 จาก AI (แบบ cis-redesign-2026 DxRow pending):
  /// แถวไล่สีส้ม→ฟ้าจาง · ประกายส้ม · รหัสตัวหนา + ชื่อ · ป้ายหลัก/รอง · ✕ ปฏิเสธ · ✓ ยอมรับ
  /// ใต้รายการ = ปุ่มเส้นประ "ให้ AI ช่วยแนะนำ" (กำลังคิด = หมุน + กำลังให้ AI วิเคราะห์…)
  Widget _icdAiChips(bool big) {
    final key = _icdAiKey;
    final asked = _icdAi.containsKey(key);
    final list = _icdAi[key];
    final loading = asked && list == null;
    const blue = Color(0xFF3965E1);
    final byCode = {for (final e in _icd10Codes().entries) e.value: e.key};
    final have = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    String? master((String, String, String) c) =>
        byCode[c.$1] ?? byCode[c.$1.replaceAll('.', '')];
    String entry((String, String, String) c) => master(c) ?? '${c.$1} ${c.$2}';
    final pending = [
      for (final c in list ?? const <(String, String, String)>[])
        if (!have.contains(entry(c))) c
    ];
    void drop((String, String, String) c) =>
        setState(() => _icdAi[key] = [...?list]..remove(c));
    Widget row((String, String, String) c, int i) {
      final main = have.isEmpty && i == 0;
      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: const LinearGradient(colors: [
            Color(0x1AFF9C78),
            Color(0x1A3965E1),
          ]),
        ),
        child: Row(children: [
          Icon(Icons.drag_indicator_rounded,
              size: 16.0, color: _ink.withValues(alpha: 0.25)),
          const SizedBox(width: 6.0),
          const Icon(Icons.auto_awesome_rounded,
              size: 20.0, color: Color(0xFFFF7A59)),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '${c.$1} ',
                    style: _num(14.0, color: _ink, weight: FontWeight.w700)),
                TextSpan(
                    text: master(c) == null ? c.$2 : master(c)!,
                    style: _t(14.0, color: _ink, weight: FontWeight.w500)),
              ]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          // เลข Type แบบรายการที่ลงแล้ว: ยังไม่มีรหัส = 1 (หลัก) · ที่เหลือ = 2
          Builder(builder: (context) {
            final (bg, fg) = _diagTypeTone(main ? '1' : '2');
            return Container(
              width: 24.0,
              height: 24.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Text(main ? '1' : '2',
                  style: _num(12.0, color: fg, weight: FontWeight.w700)),
            );
          }),
          const SizedBox(width: 4.0),
          IconButton(
            onPressed: () => drop(c),
            tooltip: 'ไม่ใช้รหัสนี้',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
            icon: const Icon(Icons.close_rounded,
                size: 20.0, color: Color(0xFFFF383C)),
          ),
          _Press(
            radius: 8.0,
            child: GestureDetector(
              onTap: () => _setMulti(_icd10Label, [...have, entry(c)]),
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                    color: blue, borderRadius: BorderRadius.circular(8.0)),
                child: const Icon(Icons.check_rounded,
                    size: 20.0, color: Colors.white),
              ),
            ),
          ),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, c) in pending.indexed) row(c, i),
        if (asked && list != null && list.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            decoration: BoxDecoration(
              color: _ink.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 16.0, color: _ink.withValues(alpha: 0.45)),
              const SizedBox(width: 6.0),
              Text('AI ยังเสนอไม่ได้ ลองค้นรหัสเอง',
                  style: _t(12.0,
                      color: _ink.withValues(alpha: 0.45),
                      weight: FontWeight.w500)),
            ]),
          ),
        if (_icdAiErr != null && !asked)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_icdAiErr!,
                style: _t(12.5, color: _red, weight: FontWeight.w500)),
          ),
        const SizedBox(height: 8.0),
        // ปุ่มเส้นประท้ายรายการ
        _Press(
          radius: 12.0,
          child: GestureDetector(
            onTap: loading ? null : _icdSuggest,
            child: CustomPaint(
              painter:
                  const _DashedRRect(color: Color(0x663965E1), radius: 12.0),
              child: SizedBox(
                height: 44.0,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  loading
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.0, color: blue))
                      : const Icon(Icons.add_rounded, size: 18.0, color: blue),
                  const SizedBox(width: 8.0),
                  Text(loading ? 'กำลังให้ AI วิเคราะห์…' : 'ให้ AI ช่วยแนะนำ',
                      style: _t(13.0, color: blue, weight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// กรอบเส้นประมุมโค้ง (ปุ่ม "ให้ AI ช่วยแนะนำ")
class _DashedRRect extends CustomPainter {
  const _DashedRRect({required this.color, this.radius = 12.0});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.5), Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final m in (Path()..addRRect(rr)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8.0) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4.0, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect o) => o.color != color;
}

/// สถานะ "กำลังวิเคราะห์" ของ Dr.Note (แบบ KPI scan): ชิปข้อมูลเคสไหลแนวนอนเป็นแถว
/// ซ้ายเส้นสแกน = ข้อมูลดิบ (จุดอ่านไม่ออก) · ผ่านเส้น = แปลงเป็นความหมาย + เช็ก ทีละส่วนตรงเส้น
/// เส้นสแกนฟ้าแนวตั้ง + ป้ายบนสุด (วงหมุน) · หมอกฟ้าฝั่งซ้ายของเส้น + จุดประกายลอย
/// ไม่ใช้ blur (กฎ performance): ความฟุ้งวาดด้วย gradient และจุด
class _DxAnalyzing extends StatefulWidget {
  const _DxAnalyzing(
      {required this.items,
      required this.groups,
      required this.base,
      this.done = false,
      this.onDone});

  /// ได้ผลแล้ว: เล่นตอนจบ (เส้นกวาดไปซ้ายสุด ทุกชิปเป็นผล → จางออก) แล้วเรียก onDone
  final bool done;
  final VoidCallback? onDone;

  /// (ค่าดิบ, ความหมาย, กลุ่ม, ผิดปกติ)
  final List<(String, String, int, bool)> items;
  final List<String> groups;

  /// สไตล์ตัวอักษรพื้นฐาน (_t 12.5 จาก state หลัก: ฟอนต์ + ขนาดตามการตั้งค่า)
  final TextStyle base;

  @override
  State<_DxAnalyzing> createState() => _DxAnalyzingState();
}

class _DxAnalyzingState extends State<_DxAnalyzing>
    with TickerProviderStateMixin {
  late final AnimationController _c;

  /// ตอนจบ 0..1: 0–0.6 เส้นกวาดไปซ้าย · 0.45–0.75 ป้าย/เส้น/หมอกจาง · 0.7–1 ทั้งก้อนจางขึ้น
  late final AnimationController _out = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 950));

  /// เข้าฉาก 0..1: ป้ายหล่นลง → เส้นยืดลงจากป้าย → หมอกจางเข้า → ชิปไหลเข้าทีละแถว
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..forward();

  @override
  void initState() {
    super.initState();
    // นาฬิกาวนยาว ใช้เวลาเป็นวินาทีต่อเนื่อง (ตำแหน่งชิปคิดจากเวลา)
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
    if (widget.done) _finish();
  }

  @override
  void didUpdateWidget(_DxAnalyzing old) {
    super.didUpdateWidget(old);
    if (widget.done && !old.done) _finish();
  }

  void _finish() {
    _out.forward().whenComplete(() {
      if (mounted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _in.dispose();
    _out.dispose();
    _c.dispose();
    super.dispose();
  }

  static double _seg(double v, double a, double b) =>
      Curves.easeInOutCubic.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  TextStyle _t(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      widget.base.copyWith(
          fontSize: (widget.base.fontSize ?? 12.5) * size / 12.5,
          color: color,
          fontWeight: weight);

  @override
  Widget build(BuildContext context) {
    final items = widget.items.isEmpty
        ? const [('ข้อมูลเคส', 'ข้อมูลเคส', 1, false)]
        : widget.items;
    // โปร่งกว่าเดิม: 4 แถว สูง 52 ชิป 38 ห่างกัน 16 · วิ่งช้า ๆ แบบสายพาน
    const rows = 4, rowH = 52.0, chipH = 38.0, topH = 64.0, gapX = 16.0;
    final st = _t(14.0, color: _inkTitle, weight: FontWeight.w600);
    final sc = MediaQuery.textScalerOf(context);
    double tw(String s) => (TextPainter(
            text: TextSpan(text: s, style: st),
            textDirection: TextDirection.ltr,
            textScaler: sc)
          ..layout())
        .width;
    final rowChips = [
      for (var r = 0; r < rows; r++)
        [for (var k = 0; k < 3; k++) items[(r * 3 + k) % items.length]]
    ];
    double cw((String, String, int, bool) it) => tw(it.$2) + 18.0 + 28.0 + 12.0;
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final cx0 = (w * 0.46).roundToDouble();
      const h = topH + rows * rowH + 12.0;
      return SizedBox(
        height: h,
        child: AnimatedBuilder(
          animation: Listenable.merge([_c, _out, _in]),
          builder: (context, _) {
            final t = _c.value * 60.0;
            final o = _out.value;
            final ii = _in.value;
            final labelK = _seg(ii, 0.0, 0.3);
            final stemK = _seg(ii, 0.15, 0.5);
            final hazeK = _seg(ii, 0.4, 0.8);
            double rowK(int r) => _seg(ii, 0.25 + r * 0.06, 0.55 + r * 0.06);
            // ฝั่งขวาเส้นเริ่มเป็นข้อมูลดิบ แล้วผลค่อย ๆ เผยจากเส้นออกไปทางขวา (ผ่านการสแกนก่อนเสมอ)
            final front = cx0 + (w - cx0 + 60.0) * _seg(ii, 0.5, 1.0);
            final sweep = _seg(o, 0.0, 0.6);
            final fx = 1 - _seg(o, 0.4, 0.65); // ป้าย/เส้น/หมอก
            final fall = 1 - _seg(o, 0.6, 1.0); // ทั้งก้อน
            // เส้นสแกนกวาดไปซ้ายสุด: ชิปทุกอันผ่านเส้น = กลายเป็นผลครบ
            final cx = cx0 + (-40.0 - cx0) * sweep;
            final chips = <Widget>[];
            for (var r = 0; r < rows; r++) {
              final list = rowChips[r];
              final widths = [for (final c in list) cw(c)];
              final period = widths.fold<double>(0.0, (a, b) => a + b + gapX);
              final speed = 22.0 + r * 4.0;
              final shift = (t * speed + r * 71.0) % period;
              // พิกัดในกรอบแถบชิป (เริ่มใต้ป้ายลงมา 4px)
              final y = 4.0 + r * rowH + (rowH - chipH) / 2;
              for (var rep = -1; rep * period < w + period; rep++) {
                var x = rep * period + shift - period;
                for (var k = 0; k < list.length; k++) {
                  final wc = widths[k];
                  if (x + wc > 0 && x < w) {
                    chips.add(Positioned(
                      left: x,
                      top: y,
                      width: wc,
                      height: chipH,
                      // เข้าฉาก: จางเข้าทีละแถว (ไม่เลื่อน ไม่ชนกับสายพาน)
                      child: Opacity(
                        opacity: rowK(r),
                        child: _scanChip(list[k], wc, chipH, cx - x, st,
                            end: front - x),
                      ),
                    ));
                  }
                  x += wc + gapX;
                }
              }
            }
            // ประกายลอยขึ้นช้า ๆ ในหมอกฝั่งซ้ายของเส้น (ไกลเส้น = จางกว่า)
            final sparks = <Widget>[];
            for (var k = 0; k < 16; k++) {
              final dx = ((k * 41) % 120).toDouble() + 4.0;
              final span = rows * rowH;
              final py =
                  topH + span - ((k * 47.0 + t * (10.0 + k % 4 * 4.0)) % span);
              final tw2 = math.sin(t * 3.2 + k * 1.7) * 0.5 + 0.5;
              final o = (1 - dx / 130.0) * (0.35 + 0.65 * tw2);
              final sz = k % 3 == 0 ? 4.0 : 2.5;
              sparks.add(Positioned(
                left: cx - dx,
                top: py,
                child: Container(
                  width: sz,
                  height: sz,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: o.clamp(0.0, 1.0)),
                      shape: BoxShape.circle),
                ),
              ));
            }
            return Opacity(
              opacity: fall,
              child: Transform.translate(
                offset: Offset(0.0, -12.0 * (1 - fall)),
                child: Stack(clipBehavior: Clip.none, children: [
                  // แถบชิป: ขอบซ้าย/ขวาจางเข้า-ออก (ไม่โผล่หายที่ขอบแข็ง)
                  Positioned.fill(
                    top: topH - 4.0,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(colors: [
                        Color(0x00FFFFFF),
                        Colors.white,
                        Colors.white,
                        Color(0x00FFFFFF),
                      ], stops: [
                        0.0,
                        0.12,
                        0.9,
                        1.0
                      ]).createShader(r),
                      // ตัดชิปที่ล้นกรอบ: ส่วนที่ล้นอยู่นอก mask จะไม่ถูกจาง (เห็นขอบแข็ง)
                      child: Stack(clipBehavior: Clip.hardEdge, children: [
                        ...chips,
                      ]),
                    ),
                  ),
                  // หมอกฟ้า: ฟุ้งทั้งแนวนอน (เข้มชิดเส้น) และแนวตั้ง (จางหัวท้าย) ไม่เป็นกล่อง
                  Positioned(
                    left: cx - 170.0,
                    width: 170.0,
                    top: topH,
                    bottom: 0.0,
                    child: IgnorePointer(
                      child: Opacity(
                          opacity: fx * hazeK,
                          child: CustomPaint(painter: const _ScanHaze())),
                    ),
                  ),
                  if (fx > 0.0)
                    for (final sp in sparks)
                      Opacity(opacity: fx * hazeK, child: sp),
                  // ป้าย + เส้นสแกนเป็นชิ้นเดียว (โคนโค้งแบบตัว T)
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 0.0,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: fx,
                        child: CustomPaint(
                            painter: _ScanStem(
                                cx: cx,
                                labelBottom: 44.0,
                                top: 52.0,
                                grow: stemK,
                                // กวาดแล้วเส้นหลุดจากป้าย: เหลือเส้นตรงอย่างเดียว
                                joined: sweep <= 0.0)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    height: 44.0,
                    child: Center(
                      child: Transform.translate(
                        // ป้ายอยู่ที่เดิม (เส้นกวาดออกไปเอง) แล้วบอกว่าเสร็จ
                        offset: Offset(cx0 - w / 2, -10.0 * (1 - labelK)),
                        child: Opacity(
                          opacity: labelK,
                          child: Transform.scale(
                            scale: 0.9 + 0.1 * labelK,
                            child: Container(
                              height: 44.0,
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 0.0, 16.0, 0.0),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF5C9BFF),
                                      Color(0xFF2F7BF2)
                                    ]),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: widget.done
                                          ? const DecoratedBox(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF8CF5C2),
                                                  shape: BoxShape.circle),
                                              child: Icon(Icons.check_rounded,
                                                  size: 15.0,
                                                  color: Color(0xFF1A4FB8)),
                                            )
                                          : Transform.rotate(
                                              angle: t * 4.0,
                                              child:
                                                  const CircularProgressIndicator(
                                                value: 0.68,
                                                strokeWidth: 2.6,
                                                strokeCap: StrokeCap.round,
                                                color: Color(0xFF8CF5C2),
                                                backgroundColor:
                                                    Color(0x40FFFFFF),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                        widget.done
                                            ? 'วิเคราะห์เสร็จ'
                                            : 'กำลังวิเคราะห์',
                                        style: _t(15.0,
                                            color: Colors.white,
                                            weight: FontWeight.w600)),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      );
    });
  }

  /// ชิปหนึ่งอัน แบ่งที่เส้นสแกน: ซ้าย (cut px แรก) = ดิบ เทาเป็นจุด · ขวา = ผล + เช็ก
  /// ผลใช้ตัวเข้มทั้งหมด (ไม่แดง) ให้สงบตา · เช็กเขียว = วิเคราะห์แล้ว
  Widget _scanChip((String, String, int, bool) it, double w, double h,
      double cut, TextStyle st,
      {double end = double.infinity}) {
    final raw = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F3),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: CustomPaint(painter: _ScrambleDots(it.$1.hashCode)),
    );
    final done = Container(
      padding: const EdgeInsets.fromLTRB(18.0, 0.0, 6.0, 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Row(children: [
        Expanded(
          child:
              Text(it.$2, maxLines: 1, overflow: TextOverflow.clip, style: st),
        ),
        Container(
          width: 24.0,
          height: 24.0,
          decoration:
              const BoxDecoration(color: _green, shape: BoxShape.circle),
          child:
              const Icon(Icons.check_rounded, size: 16.0, color: Colors.white),
        ),
      ]),
    );
    // ช่วงผล = [cut, end) · นอกช่วง = ดิบ
    final a = cut.clamp(0.0, w), b = end.clamp(0.0, w);
    if (b <= a) return raw;
    if (a <= 0 && b >= w) return done;
    return Stack(children: [
      Positioned.fill(child: raw),
      Positioned.fill(child: ClipRect(clipper: _HClip(a, b), child: done)),
    ]);
  }
}

/// หมอกฟ้าซ้ายเส้นสแกน: ไล่แนวนอน (เข้มชิดเส้น) × ไล่แนวตั้ง (จางหัวท้าย)
class _ScanHaze extends CustomPainter {
  const _ScanHaze();
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.saveLayer(r, Paint());
    canvas.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(colors: [
            Color(0x004A8BFF),
            Color(0x264A8BFF),
            Color(0x994A8BFF),
          ], stops: [
            0.0,
            0.55,
            1.0
          ]).createShader(r));
    canvas.drawRect(
        r,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFFFF),
              Colors.white,
              Colors.white,
              Color(0x00FFFFFF),
            ],
            stops: [0.0, 0.25, 0.75, 1.0],
          ).createShader(r));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScanHaze o) => false;
}

/// เส้นสแกนต่อจากป้าย: โคนบานโค้ง (fillet) ใต้ป้าย แล้วเป็นเส้นตรงลงล่าง ปลายมน
class _ScanStem extends CustomPainter {
  const _ScanStem(
      {required this.cx,
      required this.labelBottom,
      required this.top,
      this.grow = 1.0,
      this.joined = true});
  final double cx, labelBottom, top, grow;
  final bool joined;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 3.0, f = 10.0;
    const col = Color(0xFF2F7BF2);
    // เข้าฉาก: เส้นยืดลงจากใต้ป้าย (grow 0→1)
    if (grow <= 0.0) return;
    size = Size(size.width, labelBottom + (size.height - labelBottom) * grow);
    if (!joined) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - w / 2, top, w, size.height - top),
              const Radius.circular(w / 2)),
          Paint()..color = col);
      return;
    }
    final p = Path()
      ..moveTo(cx - w / 2 - f, labelBottom - 0.5)
      ..quadraticBezierTo(
          cx - w / 2, labelBottom - 0.5, cx - w / 2, labelBottom + f)
      ..lineTo(cx - w / 2, size.height - w)
      ..arcToPoint(Offset(cx + w / 2, size.height - w),
          radius: const Radius.circular(w / 2), clockwise: false)
      ..lineTo(cx + w / 2, labelBottom + f)
      ..quadraticBezierTo(
          cx + w / 2, labelBottom - 0.5, cx + w / 2 + f, labelBottom - 0.5)
      ..close();
    // แสงเรืองบาง ๆ รอบเส้น
    canvas.drawRect(
        Rect.fromLTWH(cx - 5.0, top, 10.0, size.height - top),
        Paint()
          ..shader = const LinearGradient(colors: [
            Color(0x002F7BF2),
            Color(0x332F7BF2),
            Color(0x002F7BF2),
          ]).createShader(Rect.fromLTWH(cx - 5.0, top, 10.0, 1.0)));
    canvas.drawPath(p, Paint()..color = col);
  }

  @override
  bool shouldRepaint(_ScanStem o) =>
      o.cx != cx || o.joined != joined || o.grow != grow;
}

/// ตัดแนวนอนช่วง [a, b) ของกล่อง
class _HClip extends CustomClipper<Rect> {
  const _HClip(this.a, this.b);
  final double a, b;
  @override
  Rect getClip(Size size) => Rect.fromLTRB(a, 0.0, b, size.height);
  @override
  bool shouldReclip(_HClip o) => o.a != a || o.b != b;
}

/// ข้อความดิบที่ยังอ่านไม่ออก: จุดเทาสุ่มแบบคงที่ (seed ตามข้อความ) เรียงเป็นแถวตัวอักษร
class _ScrambleDots extends CustomPainter {
  const _ScrambleDots(this.seed);
  final int seed;
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final p = Paint();
    final top = size.height * 0.3, bot = size.height * 0.7;
    for (var x = 14.0; x < size.width - 12.0; x += 2.6) {
      for (var y = top; y < bot; y += 2.6) {
        if (rnd.nextDouble() > 0.42) continue;
        p.color = Color.fromRGBO(120, 128, 140, 0.25 + rnd.nextDouble() * 0.45);
        canvas.drawCircle(Offset(x, y), 0.9 + rnd.nextDouble() * 0.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_ScrambleDots o) => o.seed != seed;
}

/// แว่นขยาย (ภาษาภาพเดียวกับนาฬิกาจับเวลา Fast track: 3 มิติจริงวาดด้วย CustomPainter)
/// idle: หมุนรอบแกนตั้ง 1 รอบ แล้วพักที่มุมสามส่วนสี่ ระหว่างพักมีแสง shimmer กวาดผ่านกระจก
class _MagnifierHero extends StatefulWidget {
  const _MagnifierHero();

  @override
  State<_MagnifierHero> createState() => _MagnifierHeroState();
}

class _MagnifierHeroState extends State<_MagnifierHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
              painter: _MagnifierArt(_c.value), size: Size.infinite),
        ),
      );
}

class _MagnifierArt extends CustomPainter {
  const _MagnifierArt(this.t);

  /// 0..1 หนึ่งรอบ (5 วิ): เข้า → ส่องกวาด → เจอ (เต้น + ประกาย) → แสงวิ้ง → กลับจุดเริ่ม
  final double t;

  static const _cam = 6.0;
  static const _light = (-0.45, 0.65, 0.62);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // เรื่องเล่า 1 รอบ: เข้า (เด้งขึ้น) → ย่อตัวก่อนออก (anticipation) → ส่องกวาดจอคลื่นหัวใจ
    // → หยุดเลยไปนิดแล้วดีดกลับ (overshoot) ที่จุดผิดปกติ → คลื่นแดง + วงกระจาย
    // → payoff: เช็กเขียวเด้งออกพร้อมประกาย → แสงวิ้งบนกระจก → เลื่อนกลับจุดเริ่ม (วนต่อเนื่อง)
    double ph(double tt, double a, double b,
            [Curve c = Curves.easeInOutCubic]) =>
        c.transform(((tt - a) / (b - a)).clamp(0.0, 1.0));
    final x0 = w * 0.3, x1 = w * 0.6;
    double lxAt(double tt) {
      // easeInOutBack: ถอยนิดก่อนพุ่ง + เลยเป้านิดแล้วดีดกลับ ในเส้นโค้งเดียว (ความเร็วต่อเนื่อง)
      final mv = ph(tt, 0.08, 0.5, Curves.easeInOutBack);
      final bk = ph(tt, 0.84, 1.0);
      return x0 + (x1 - x0) * (mv - bk);
    }

    final back = ph(t, 0.84, 1.0);
    final found = ((t - 0.5) / 0.3).clamp(0.0, 1.0);
    final pulse =
        found > 0 && found < 0.4 ? math.sin(found / 0.4 * math.pi) : 0.0;
    final lx = lxAt(t);
    // ความเร็ว (หน่วยความกว้าง/รอบ) → เอียง/หมุนตามน้ำหนักการเคลื่อนที่
    final vel = (lxAt(math.min(1.0, t + 0.004)) - lx) / (0.004 * w);
    final base = math.min(w, h) * 0.26;
    // ไม่มีท่าเข้าฉากซ้ำทุกรอบ (เคยเด้งตอนวนรอบใหม่ = กระตุก)
    final k = base * (1 + 0.1 * pulse);
    final o = Offset(lx, h * 0.46);
    final yaw = -0.5 + (vel * 0.18).clamp(-0.45, 0.45);
    final roll = (-vel * 0.05).clamp(-0.25, 0.25);
    // จอมอนิเตอร์ (ฉากหลัง): กรมท่า มุมโค้ง · คลื่นหัวใจวิ่งอยู่ในจอเท่านั้น
    final mon = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.46),
            width: w * 0.92,
            height: h * 0.5),
        Radius.circular(h * 0.08));
    final y0 = h * 0.5, per = base * 0.9;
    double ecgY(double x) {
      final n = ((x - x1) / per).roundToDouble();
      final v = (x - x1 - n * per) / base;
      final amp = base * (n == 0 ? 0.5 : 0.2);
      if (v > -0.05 && v <= 0) return y0 - amp * (v + 0.05) / 0.05;
      if (v > 0 && v <= 0.07) return y0 - amp + amp * 1.25 * (v / 0.07);
      if (v > 0.07 && v <= 0.11) {
        return y0 + amp * 0.25 * (1 - (v - 0.07) / 0.04);
      }
      return y0;
    }

    Path ecgPath() {
      final p = Path()..moveTo(mon.left, ecgY(mon.left));
      for (var x = mon.left; x <= mon.right; x += 1.0) {
        p.lineTo(x, ecgY(x));
      }
      return p;
    }

    // จอโทนสว่าง (ฟ้าอ่อน) ตามภาษาการ์ด · ขอบฟ้าบาง
    canvas.drawRRect(mon, Paint()..color = const Color(0xFFE8F0FE));
    canvas.drawRRect(
        mon,
        Paint()
          ..color = const Color(0xFFAECBFA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    canvas.save();
    canvas.clipRRect(mon);
    // เส้นกริดจาง ๆ ในจอ
    for (var gx = mon.left + 8.0; gx < mon.right; gx += 8.0) {
      canvas.drawLine(Offset(gx, mon.top), Offset(gx, mon.bottom),
          Paint()..color = const Color(0x1F1A73E8));
    }
    canvas.drawPath(
        ecgPath(),
        Paint()
          ..color = const Color(0xB31A73E8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();
    // แว่นทั้งชิ้นหมุนรอบจุดกลางเลนส์ตามความเร็ว
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(roll);
    canvas.translate(-o.dx, -o.dy);
    const pitch = 0.18;
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final light = _p3Norm(_light);

    _P3 rot(_P3 p) {
      final x = p.$1 * cy + p.$3 * sy;
      final z = -p.$1 * sy + p.$3 * cy;
      return (x, p.$2 * cp - z * sp, p.$2 * sp + z * cp);
    }

    Offset proj(_P3 p) {
      final r = rot(p);
      final s = _cam / (_cam - r.$3) * k;
      return o + Offset(r.$1 * s, -r.$2 * s);
    }

    bool facing(_P3 p, _P3 n) {
      final r = rot(p), rn = rot(n);
      return _p3Dot(rn, (-r.$1, -r.$2, _cam - r.$3)) > 0;
    }

    Color shade(Color base, _P3 n, {double amb = 0.5}) {
      final d = math.max(0.0, _p3Dot(rot(n), light));
      final l = (amb + (1.0 - amb) * d).clamp(0.0, 1.0);
      final hsl = HSLColor.fromColor(base);
      final dark = hsl.withLightness(hsl.lightness * 0.55).toColor();
      return Color.lerp(dark, base, l)!;
    }

    Path poly(List<_P3> pts) =>
        Path()..addPolygon([for (final p in pts) proj(p)], true);
    void fill(Path p, Color c) {
      canvas.drawPath(p, Paint()..color = c);
      canvas.drawPath(
          p,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6);
    }

    // ทรงกระบอก (ใช้กับด้ามจับ)
    void cylinder(_P3 p0, _P3 a, double len, double r, Color base,
        {Color? cap, int seg = 24}) {
      a = _p3Norm(a);
      final ref = a.$3.abs() > 0.9 ? (1.0, 0.0, 0.0) : (0.0, 0.0, 1.0);
      final u = _p3Norm(_p3Cross(a, ref)), v = _p3Cross(a, u);
      final p1 = _p3Add(p0, _p3Mul(a, len));
      _P3 ring(_P3 c, double tt) => _p3Add(
          c, _p3Add(_p3Mul(u, math.cos(tt) * r), _p3Mul(v, math.sin(tt) * r)));
      for (var i = 0; i < seg; i++) {
        final t0 = i / seg * math.pi * 2, t1 = (i + 1) / seg * math.pi * 2;
        final tm = (t0 + t1) / 2;
        final n = _p3Add(_p3Mul(u, math.cos(tm)), _p3Mul(v, math.sin(tm)));
        final q = [ring(p0, t0), ring(p0, t1), ring(p1, t1), ring(p1, t0)];
        if (!facing(_p3Mul(_p3Add(q[0], q[2]), 0.5), n)) continue;
        fill(poly(q), shade(base, n));
      }
      for (final (c, n) in [(p1, a), (p0, _p3Mul(a, -1.0))]) {
        if (!facing(c, n)) continue;
        fill(
            poly(
                [for (var i = 0; i < seg; i++) ring(c, i / seg * math.pi * 2)]),
            shade(cap ?? base, n, amb: 0.7));
      }
    }

    // ---- ขอบเลนส์: วงแหวนหนา (ด้านนอก + ผนังใน + หน้าวงแหวนสองฝั่ง)
    const ro = 1.0, ri = 0.8, d = 0.26, seg = 44;
    const rim = Color(0xFF1A73E8);
    _P3 at(double r, double a, double z) =>
        (math.cos(a) * r, math.sin(a) * r, z);
    // ด้ามจับ: ปลอกเหลือง (แบบปุ่มนาฬิกา Fast track) + ด้ามเทาเข้ม · เฉียงลงขวา
    final dir = _p3Norm((0.62, -0.78, 0.0));
    void handle() {
      cylinder(_p3Mul(dir, 0.96), dir, 0.24, 0.16, const Color(0xFFFBBC04),
          cap: const Color(0xFFE8A600));
      cylinder(_p3Mul(dir, 1.18), dir, 0.92, 0.14, const Color(0xFF3C4043),
          cap: const Color(0xFF202124));
    }

    final handleBehind = rot(_p3Mul(dir, 1.6)).$3 < 0;
    if (handleBehind) handle();
    // ด้านนอก (ส่วนที่หันเข้ากล้อง)
    for (var i = 0; i < seg; i++) {
      final a0 = i / seg * math.pi * 2, a1 = (i + 1) / seg * math.pi * 2;
      final am = (a0 + a1) / 2;
      final n = (math.cos(am), math.sin(am), 0.0);
      final q = [
        at(ro, a0, -d / 2),
        at(ro, a1, -d / 2),
        at(ro, a1, d / 2),
        at(ro, a0, d / 2)
      ];
      if (!facing(_p3Mul(_p3Add(q[0], q[2]), 0.5), n)) continue;
      fill(poly(q), shade(rim, n));
    }
    // ผนังด้านใน (ฝั่งไกลที่มองเห็นผ่านรู)
    for (var i = 0; i < seg; i++) {
      final a0 = i / seg * math.pi * 2, a1 = (i + 1) / seg * math.pi * 2;
      final am = (a0 + a1) / 2;
      final n = (-math.cos(am), -math.sin(am), 0.0);
      final q = [
        at(ri, a0, -d / 2),
        at(ri, a1, -d / 2),
        at(ri, a1, d / 2),
        at(ri, a0, d / 2)
      ];
      if (!facing(_p3Mul(_p3Add(q[0], q[2]), 0.5), n)) continue;
      fill(poly(q), shade(const Color(0xFF174EA6), n, amb: 0.6));
    }
    // กระจก: ฟ้าใส ไล่แสง + shimmer กวาดตอนพัก
    final lens = poly(
        [for (var i = 0; i < seg; i++) at(ri, i / seg * math.pi * 2, 0.0)]);
    final lb = lens.getBounds();
    canvas.drawPath(
        lens,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xCCEAF2FF), Color(0xB3A8C7FA), Color(0xCC7BAAF7)],
          ).createShader(lb));
    // ในเลนส์: คลื่นขยาย 1.8 เท่า (ภาพซูม) · จังหวะผิดปกติเป็นสีแดงเมื่อเจอ
    canvas.save();
    canvas.clipPath(lens);
    canvas.translate(o.dx, o.dy);
    canvas.scale(1.8);
    canvas.translate(-o.dx, -o.dy);
    canvas.drawPath(
        ecgPath(),
        Paint()
          ..color = Color.lerp(const Color(0xFF1A73E8), const Color(0xFFD93025),
              ((found / 0.15).clamp(0.0, 1.0) * (1 - back)))!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round);
    canvas.restore();
    // เจอแล้ว: วงคลื่นแดงกระจายในเลนส์
    if (found > 0 && found < 0.5) {
      final f = found / 0.5;
      canvas.save();
      canvas.clipPath(lens);
      canvas.drawCircle(
          o,
          base * (0.15 + 0.7 * f),
          Paint()
            ..color = const Color(0xFFD93025).withValues(alpha: 0.55 * (1 - f))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
      canvas.restore();
    }
    final sh = ((t - 0.68) / 0.16).clamp(0.0, 1.0);
    if (sh > 0.0 && sh < 1.0) {
      canvas.save();
      canvas.clipPath(lens);
      final cx = lb.left - lb.width * 0.5 + lb.width * 2.0 * sh;
      final band = Rect.fromCenter(
          center: Offset(cx, lb.center.dy),
          width: lb.width * 0.38,
          height: lb.height * 2.0);
      canvas.translate(band.center.dx, band.center.dy);
      canvas.rotate(0.45);
      canvas.translate(-band.center.dx, -band.center.dy);
      canvas.drawRect(
          band,
          Paint()
            ..shader = const LinearGradient(colors: [
              Color(0x00FFFFFF),
              Color(0xD9FFFFFF),
              Color(0x00FFFFFF),
            ]).createShader(band));
      canvas.restore();
    }
    // แสงสะท้อนโค้งซ้ายบนบนกระจก (แบบหน้าปัดนาฬิกา)
    final glint = Path();
    for (var i = 0; i <= 14; i++) {
      final a = math.pi * (0.58 + 0.32 * i / 14);
      final p = proj(at(ri * 0.74, a, 0.0));
      i == 0 ? glint.moveTo(p.dx, p.dy) : glint.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        glint,
        Paint()
          ..color = const Color(0xE6FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = k * 0.08
          ..strokeCap = StrokeCap.round);
    // หน้าวงแหวน (ฝั่งที่หันเข้ากล้อง) ไล่แสงจากซ้ายบน
    for (final z in [d / 2, -d / 2]) {
      final n = (0.0, 0.0, z > 0 ? 1.0 : -1.0);
      if (!facing(at((ro + ri) / 2, 0.0, z), n)) continue;
      final ring = Path()
        ..fillType = PathFillType.evenOdd
        ..addPolygon([
          for (var i = 0; i < seg; i++) proj(at(ro, i / seg * math.pi * 2, z))
        ], true)
        ..addPolygon([
          for (var i = 0; i < seg; i++) proj(at(ri, i / seg * math.pi * 2, z))
        ], true);
      canvas.drawPath(
          ring,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.45, -0.55),
              radius: 1.05,
              colors: [Color(0xFFAECBFA), Color(0xFF4285F4), Color(0xFF1967D2)],
              stops: [0.0, 0.5, 1.0],
            ).createShader(ring.getBounds()));
    }
    if (!handleBehind) handle();
    canvas.restore();
    // payoff: เช็กเขียวเด้งออกมุมขวาบนของแว่น + ประกายแตกออก · หดกลับตอนแว่นเลื่อนกลับ
    final pop =
        Curves.easeOutBack.transform(((found - 0.25) / 0.25).clamp(0.0, 1.0)) *
            (1 - back);
    if (pop > 0.01) {
      final c0 = o + Offset(k * 0.78, -k * 0.78);
      final r = base * 0.4 * pop;
      final burst = ((found - 0.25) / 0.35).clamp(0.0, 1.0);
      if (burst > 0 && burst < 1) {
        for (var i = 0; i < 6; i++) {
          final a = i / 6 * math.pi * 2 - math.pi / 2;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(
              c0 + d * (r + base * 0.1 + base * 0.25 * burst),
              c0 + d * (r + base * 0.18 + base * 0.3 * burst),
              Paint()
                ..color = const Color(0xFFFBBC04).withValues(alpha: 1 - burst)
                ..strokeWidth = 2.0
                ..strokeCap = StrokeCap.round);
        }
      }
      canvas.drawCircle(c0, r + 1.5, Paint()..color = Colors.white);
      canvas.drawCircle(c0, r, Paint()..color = const Color(0xFF1E9E5A));
      final ck = Path()
        ..moveTo(c0.dx - r * 0.45, c0.dy + r * 0.02)
        ..lineTo(c0.dx - r * 0.1, c0.dy + r * 0.35)
        ..lineTo(c0.dx + r * 0.5, c0.dy - r * 0.32);
      canvas.drawPath(
          ck,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.5, r * 0.28)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
  }

  @override
  bool shouldRepaint(_MagnifierArt o) => o.t != t;
}
