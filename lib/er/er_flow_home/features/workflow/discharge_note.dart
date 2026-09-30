// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ Dr.Note ร่างเอกสารจำหน่าย (ต้นแบบ)
// ร่างจากข้อมูลทั้งเคสตามสภาพที่เลือก: Refer = ใบส่งต่อ · Admit = บันทึกรับไว้รักษา
// · อื่น ๆ (กลับบ้าน/สังเกตอาการ) = สรุปจำหน่าย + คำแนะนำผู้ป่วยภาษาง่าย
// แพทย์แก้ได้ทุกบรรทัดก่อนใช้ · ใช้ LLM ผ่าน ErAi.chat · ไม่ส่งชื่อ/HN

/// ช่องเก็บร่างเอกสาร (ไม่ใช่ช่องบังคับของฟอร์ม)
const String _dcNoteLabel = 'สรุปจำหน่าย';

mixin _FeaturesWorkflowDischargeNoteState on State<ErFlowHomeWidget> {
  /// กำลังร่างอยู่ (HN)
  final Set<String> _dcBusy = {};
  String? _dcErr;
}

extension _FeaturesWorkflowDischargeNotePart on _ErFlowHomeWidgetState {
  /// ชนิดเอกสารตามสภาพผู้ป่วยออกจาก ER
  (String title, String instruct) _dcKind() {
    final disp = _filled[_speechStep][_dispLabel] ?? '';
    final dest = _filled[_speechStep][_destLabel] ?? '';
    if (disp.contains('Refer') || disp.contains('ส่งต่อ')) {
      return (
        'ใบส่งต่อผู้ป่วย (Refer)',
        'เขียนใบส่งต่อผู้ป่วยถึงแพทย์ปลายทาง${dest.isEmpty ? '' : ' ($dest)'} '
            'หัวข้อ: เหตุผลที่ส่งต่อ, อาการสำคัญและประวัติ, ผลตรวจร่างกายที่สำคัญ, '
            'สัญญาณชีพล่าสุด, ผลแล็บ/ภาพถ่ายที่สำคัญ, การวินิจฉัย, การรักษาที่ให้แล้วใน ER (ยา เวลา), '
            'ปัญหาที่ต้องเฝ้าระวังระหว่างส่งต่อ'
      );
    }
    if (disp.contains('Admit') || disp.contains('รับไว้')) {
      return (
        'บันทึกรับไว้รักษา (Admission note)',
        'เขียนบันทึกส่งผู้ป่วยเข้ารักษาใน${dest.isEmpty ? 'หอผู้ป่วย' : ' $dest'} '
            'หัวข้อ: การวินิจฉัย, สรุปอาการและประวัติ, ผลตรวจสำคัญ, การรักษาที่ให้แล้วใน ER, '
            'แผนการรักษาต่อและสิ่งที่ต้องติดตาม'
      );
    }
    return (
      'สรุปจำหน่ายและคำแนะนำ',
      'เขียนสรุปการรักษาในห้องฉุกเฉินสำหรับเวชระเบียน (การวินิจฉัย, สรุปอาการ, การรักษาที่ให้) '
          'แล้วตามด้วยหัวข้อ "คำแนะนำผู้ป่วย" เป็นภาษาง่ายสำหรับคนทั่วไป: การดูแลตัวเอง, ยาที่ได้รับ, '
          'อาการที่ต้องกลับมาโรงพยาบาลทันที, การนัดติดตาม'
    );
  }

  /// การวินิจฉัยที่ลงไว้ทุกขั้น
  String _dcDiagnoses() => [
        for (final m in _filled)
          for (final k in const [_dxTextLabel, _icd10Label])
            if ((m[k] ?? '').trim().isNotEmpty) m[k]!.trim()
      ].join('\n');

  Future<void> _dcDraft() async {
    final hn = _caseP().hn;
    if (_dcBusy.contains(hn)) return;
    final (title, instruct) = _dcKind();
    final step = _speechStep;
    setState(() {
      _dcBusy.add(hn);
      _dcErr = null;
    });
    final c = _case;
    final given = [
      for (final m in c.meds) '${m.name} ${m.route} เวลา ${m.time}'
    ].join('; ');
    final data = [
      _dxCaseText(),
      'การวินิจฉัยที่แพทย์ลง: ${_dcDiagnoses().isEmpty ? 'ยังไม่ได้ลง' : _dcDiagnoses()}',
      'ยา/การรักษาที่ให้ใน ER: ${given.isEmpty ? 'ไม่มีบันทึก' : given}',
      'สภาพผู้ป่วยออกจาก ER: ${_filled[step][_dispLabel] ?? '-'}',
      if ((_filled[step][_destLabel] ?? '').isNotEmpty)
        'ปลายทาง: ${_filled[step][_destLabel]}',
    ].join('\n');
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': 'คุณเป็นผู้ช่วยแพทย์ห้องฉุกเฉิน $instruct '
              'ใช้เฉพาะข้อมูลที่ได้รับ ห้ามแต่งค่าหรือการรักษาที่ไม่มี ถ้าข้อมูลไม่มีให้เขียนว่า "ไม่มีข้อมูล" '
              'รูปแบบ: หัวข้อขึ้นบรรทัดด้วย "# " รายการขึ้นต้นด้วย "• " ไม่ใส่ชื่อผู้ป่วย กระชับ อ่านง่าย ภาษาไทย'
        },
        {'role': 'user', 'content': data},
      ], temperature: 0.2, maxTokens: 1100);
      if (!mounted) return;
      setState(() {
        _filled[step][_dcNoteLabel] = out.trim();
        _inlineCtl['$step|$_dcNoteLabel']?.text = out.trim();
      });
    } catch (e) {
      debugPrint('ร่างเอกสารจำหน่าย ผิดพลาด: $e');
      if (mounted) setState(() => _dcErr = 'ร่างไม่สำเร็จ ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _dcBusy.remove(hn));
    }
  }

  /// การ์ดร่างเอกสาร ใต้สภาพผู้ป่วย/เวลาออก ในขั้นจำหน่าย
  Widget _dcCard() {
    final (title, _) = _dcKind();
    final busy = _dcBusy.contains(_caseP().hn);
    final text = _filled[_speechStep][_dcNoteLabel] ?? '';
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
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
            Expanded(
              child: Text('Dr.Note ร่าง: $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
            ),
            if (!busy)
              _miniBtn(
                  text.isEmpty
                      ? Icons.edit_note_rounded
                      : Icons.refresh_rounded,
                  text.isEmpty ? 'ร่างให้' : 'ร่างใหม่',
                  _dcDraft,
                  tooltip: 'ร่างจากข้อมูลทั้งเคส'),
            if (text.isNotEmpty && !busy) ...[
              const SizedBox(width: 6.0),
              _miniBtn(Icons.copy_rounded, 'คัดลอก',
                  () => _copyText(title, _richPlain(text), notify: true)),
            ],
          ]),
          const SizedBox(height: 10.0),
          if (busy)
            _CcAiSkeleton(
                label: 'Dr.Note กำลังร่าง$title…',
                style: _t(11.5, color: _ink3),
                rows: 5)
          else if (text.isEmpty)
            Text(
                _dcErr ??
                    'กด "ร่างให้" แล้ว Dr.Note จะเขียนจากอาการ ผลตรวจ การวินิจฉัย และการรักษาใน ER ให้แพทย์ตรวจแก้',
                style:
                    _t(11.5, color: _dcErr == null ? _ink3 : _red, height: 1.4))
          else
            Container(
              constraints: const BoxConstraints(minHeight: 120.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _line),
              ),
              child: _inlineInput(_dcNoteLabel, text,
                  hint: '',
                  style: _t(12.5, color: _inkTitle, height: 1.5),
                  hintStyle: _t(12.5, color: _ink3),
                  rich: true,
                  maxLines: null),
            ),
          const SizedBox(height: 8.0),
          Text('ร่างโดย AI แพทย์ต้องตรวจทานและแก้ไขก่อนใช้',
              style: _t(9.5, color: _ink3)),
        ],
      ),
    );
  }
}
