// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// คำอธิบายของแต่ละขั้น (ชื่อขั้น → จุดประสงค์) ทุกบทบาท
const Map<String, String> _stepPurpose = {
  'ทบทวนเคส': 'ตรวจทานข้อมูลคัดกรองและประวัติแพ้ยาก่อนเริ่มตรวจ',
  'ประวัติ HPI': 'บันทึกประวัติการเจ็บป่วยปัจจุบันจาก template ตามอาการ',
  'ตรวจร่างกาย': 'บันทึกผลตรวจร่างกายทีละระบบ ปกติ/ผิดปกติ',
  'บาดแผล/หัตถการ': 'ระบุตำแหน่งแผลบนหุ่น ลักษณะแผล และหัตถการที่ทำ',
  'วินิจฉัย/สั่ง': 'ลงวินิจฉัย และสั่งยา แล็บ เอกซเรย์ หัตถการ',
  'จำหน่าย': 'สรุปสภาพผู้ป่วยออกจาก ER และปลายทาง (Admit ต้องเลือกตึก)',
  'สัญญาณชีพ': 'วัดและบันทึกสัญญาณชีพรอบนี้',
  'ความรุนแรง AIS': 'ประเมินความรุนแรงการบาดเจ็บตามส่วนของร่างกาย',
  'รับคำสั่งแพทย์': 'รับและยืนยันคำสั่งการรักษาที่แพทย์สั่ง',
  'สังเกตอาการ': 'บันทึกอาการระหว่างสังเกตอาการ พร้อมเวลา',
  'การพยาบาล': 'บันทึกกิจกรรมการพยาบาลที่ทำ',
  'ออกจาก ER': 'บันทึกเวลาและสภาพผู้ป่วยตอนออกจาก ER',
  'รับเข้า': 'ลงทะเบียนรับผู้ป่วยเข้าห้องฉุกเฉิน',
  'อาการสำคัญ': 'บันทึกอาการสำคัญที่มาโรงพยาบาล',
  'GCS/รูม่านตา': 'ประเมินระดับความรู้สึกตัวและรูม่านตา',
  'อุบัติเหตุ': 'บันทึกข้อมูลอุบัติเหตุ (ถ้ามี)',
  'ระดับ ESI': 'จัดระดับความเร่งด่วน ESI 1-5 โดยมีคำแนะนำจากระบบ',
};

extension _FeaturesWorkflowStepIntroPart on _ErFlowHomeWidgetState {
  /// หน้าคำแนะนำ (หน้าแรกของขั้น): จุดประสงค์ · ช่องที่ต้องกรอก · วิธีใช้ · เริ่ม
  Widget _stepIntro() {
    final step = _speechStep;
    final (icon, name) = _steps[step];
    final labels = [for (final (l, _) in _forms[step]) l];
    final done = labels.where((l) => _fieldDone(step, l)).length;
    Widget how(IconData i, String t) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(children: [
            Icon(i, size: 15.0, color: _blue),
            const SizedBox(width: 8.0),
            Expanded(child: Text(t, style: _t(11.5, color: _ink2))),
          ]),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              gradient: _glossGrad(_blue),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: _glossLift(_blue),
            ),
            foregroundDecoration: const _InnerGloss(12.0, dark: true),
            child: Icon(icon, size: 22.0, color: Colors.white),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
                Text(_stepPurpose[name] ?? 'กรอกข้อมูลของขั้นนี้ให้ครบ',
                    style: _t(11.5, color: _ink2, height: 1.35)),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16.0),
        Row(children: [
          Text('สิ่งที่ต้องกรอก',
              style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
          const Spacer(),
          Text('$done/${labels.length} ช่อง',
              style: _num(11.0, color: _ink2, weight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6.0),
        for (var i = 0; i < labels.length; i++)
          _Press(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // แตะชื่อช่องเพื่อข้ามไปกรอกช่องนั้นเลย
              onTap: () {
                final seq = _uiSeq;
                final fi = seq.indexWhere((x) => x.type == ErUiType.form);
                if (fi < 0) return;
                final k = _formFields(seq[fi]).indexOf(labels[i]);
                setState(() {
                  _formFwd = true;
                  _uiIdx = fi;
                  _formAt = k < 0 ? 0 : k;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: _glow.contains(labels[i])
                      ? _blue.withValues(alpha: 0.06)
                      : null,
                  border: const Border(bottom: BorderSide(color: _line)),
                ),
                child: Row(children: [
                  Icon(
                      _fieldDone(step, labels[i])
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16.0,
                      color: _fieldDone(step, labels[i]) ? _green : _g5),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0, color: _inkTitle)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16.0, color: _g5),
                ]),
              ),
            ),
          ),
        const SizedBox(height: 16.0),
        Text('วิธีใช้', style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
        const SizedBox(height: 6.0),
        how(Icons.mic_rounded,
            'แตะไมค์แล้วพูด แตะอีกครั้งเพื่อส่ง ผู้ช่วยแยกข้อมูลลงช่องให้'),
        how(Icons.touch_app_rounded, 'หรือแตะเลือก / พิมพ์ในแต่ละช่องเอง'),
        how(Icons.swipe_rounded, 'กดถัดไป หรือปัดซ้าย-ขวาเพื่อเปลี่ยนช่อง'),
      ],
    );
  }
}
