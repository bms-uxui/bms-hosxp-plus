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
    setState(() {
      _dxAi[key] = null;
      _dxAiErr = null;
    });
    const sys =
        'คุณเป็นผู้ช่วยแพทย์ห้องฉุกเฉิน ช่วยคิดวินิจฉัยแยกโรคจากข้อมูลผู้ป่วย '
        'ตอบเป็น JSON เท่านั้น รูปแบบ {"differentials":[{"dx":"ชื่อโรคภาษาอังกฤษ","icd10":"รหัส",'
        '"likelihood":"สูง|ปานกลาง|ต้องตัดออก","why":["เหตุผลจากข้อมูลที่ให้ สั้น ๆ"],'
        '"next":["สิ่งที่ควรตรวจ/ทำต่อ"],"ref":"guideline ที่อ้าง เช่น ATLS 11, Sepsis-3, AHA Stroke 2019"}],'
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
      setState(() => _dxAi[key] = _DxResult(ideas, strs(j['missing'])));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dxAi.remove(key);
        _dxAiErr = 'Dr.Note คิดไม่สำเร็จ ลองใหม่อีกครั้ง';
      });
      debugPrint('Dr.Note ช่วยคิด ผิดพลาด: $e');
    }
  }

  /// ใส่โรคนี้ลง Diagnosis Text (ต่อบรรทัดใหม่ ไม่ทับของเดิม)
  void _dxUse(_DxIdea d) {
    final cur = _multiItems(_filled[_speechStep][_dxTextLabel]);
    if (cur.contains(d.dx)) return;
    ErFeedback.confirm();
    setState(
        () => _filled[_speechStep][_dxTextLabel] = [...cur, d.dx].join('\n'));
  }

  /// การ์ด "Dr.Note ช่วยคิด" บนสุดของหน้าวินิจฉัย
  Widget _dxAssistCard(bool big) {
    final key = _dxKey;
    if (!_dxAi.containsKey(key) && _dxAiErr == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dxThink();
      });
    }
    final r = _dxAi[key];
    final thinking = _dxAi.containsKey(key) && r == null;
    Color levelColor(String l) => l.contains('สูง')
        ? _red
        : l.contains('ตัด')
            ? _blue
            : _ink2;
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 18.0, color: _blue),
            const SizedBox(width: 6.0),
            Text('Dr.Note ช่วยคิด',
                style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text('อ่านจาก CC, HPI, สัญญาณชีพ, ตรวจร่างกาย, แล็บ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(10.5, color: _ink3)),
            ),
            if (!thinking)
              _miniBtn(
                  Icons.refresh_rounded, 'คิดใหม่', () => _dxThink(force: true),
                  tooltip: 'ให้ Dr.Note คิดใหม่จากข้อมูลล่าสุด'),
          ]),
          const SizedBox(height: 10.0),
          if (thinking)
            _CcAiSkeleton(
                label: 'Dr.Note กำลังคิดวินิจฉัยแยกโรค…',
                style: _t(11.5, color: _ink3),
                rows: 4)
          else if (r == null)
            Text(_dxAiErr ?? '', style: _t(11.5, color: _red))
          else ...[
            if (r.ideas.isEmpty)
              Text('ยังไม่มีข้อเสนอจากข้อมูลตอนนี้',
                  style: _t(11.5, color: _ink3)),
            for (var i = 0; i < r.ideas.length; i++) ...[
              if (i > 0) const Divider(height: 18.0, color: _line),
              _dxIdeaRow(i + 1, r.ideas[i], key, levelColor(r.ideas[i].level)),
            ],
            if (r.missing.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.help_outline_rounded,
                          size: 16.0, color: _ink2),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text('ข้อมูลที่ยังขาด: ${r.missing.join(', ')}',
                            style: _t(11.0, color: _ink2, height: 1.4)),
                      ),
                    ]),
              ),
            ],
          ],
          const SizedBox(height: 8.0),
          Text('ข้อเสนอจาก AI ไม่ใช่คำวินิจฉัย แพทย์เป็นผู้ตัดสิน',
              style: _t(9.5, color: _ink3)),
        ],
      ),
    );
  }

  Widget _dxIdeaRow(int n, _DxIdea d, String key, Color col) {
    final vote = _dxVote['$key|${d.dx}'];
    final used = _multiItems(_filled[_speechStep][_dxTextLabel]).contains(d.dx);
    Widget thumb(bool up) => InkWell(
          borderRadius: BorderRadius.circular(100.0),
          onTap: () => setState(() => _dxVote['$key|${d.dx}'] = up),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
                up ? Icons.thumb_up_alt_rounded : Icons.thumb_down_alt_rounded,
                size: 15.0,
                color: vote == up ? _blue : _g5),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 20.0,
            height: 20.0,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: _blue, shape: BoxShape.circle),
            child: Text('$n',
                style:
                    _num(10.0, color: Colors.white, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: d.dx,
                  style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
              if (d.icd.isNotEmpty)
                TextSpan(text: '  ${d.icd}', style: _num(10.5, color: _ink3)),
            ])),
          ),
          if (d.level.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(d.level,
                  style: _t(10.0, color: col, weight: FontWeight.w700)),
            ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (d.why.isNotEmpty)
                Text('เพราะ: ${d.why.join(' · ')}',
                    style: _t(11.0, color: _ink2, height: 1.4)),
              if (d.next.isNotEmpty)
                Text('ควรทำ: ${d.next.join(' · ')}',
                    style: _t(11.0, color: _ink2, height: 1.4)),
              const SizedBox(height: 6.0),
              Row(children: [
                _miniBtn(used ? Icons.check_rounded : Icons.add_rounded,
                    used ? 'ใส่แล้ว' : 'ใช้เป็นวินิจฉัย', () => _dxUse(d),
                    tooltip: 'เพิ่มลง Diagnosis Text'),
                const Spacer(),
                if (d.ref.isNotEmpty)
                  Flexible(
                    child: Text('อ้างอิง: ${d.ref}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(9.5, color: _ink3)),
                  ),
                const SizedBox(width: 4.0),
                thumb(true),
                thumb(false),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
