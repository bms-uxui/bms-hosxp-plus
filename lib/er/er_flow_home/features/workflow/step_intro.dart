// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// คำอธิบายของแต่ละขั้น (ชื่อขั้น → จุดประสงค์) ทุกบทบาท
const Map<String, String> _stepPurpose = {
  'คัดกรอง': 'ตรวจทานข้อมูลคัดกรองและประวัติแพ้ยาก่อนเริ่มตรวจ',
  'ประวัติ HPI': 'พิมพ์ พูด หรือใช้เทมเพลตบันทึกอาการปัจจุบัน',
  'ตรวจร่างกาย': 'บันทึกผลตรวจร่างกายทีละระบบว่าปกติหรือผิดปกติ',
  'บาดแผล/หัตถการ': 'ระบุตำแหน่งแผลบนหุ่น ลักษณะแผล และหัตถการที่ทำ',
  'วินิจฉัย/สั่ง': 'ลงวินิจฉัย และสั่งยา แล็บ เอกซเรย์ หัตถการ',
  'จำหน่าย': 'สรุปสภาพผู้ป่วยออกจาก ER และเวลาออกจากห้อง',
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

/// คำแนะนำว่าช่องนี้ต้องกรอกอะไร (หน้าแนะนำขั้น) · ไม่มีในนี้ = สร้างจากคำใบ้ของช่อง
const Map<String, String> _fieldGuide = {
  'ข้อมูลรับเข้าห้องฉุกเฉิน': 'ข้อมูลรับเข้าห้องฉุกเฉิน และการเข้ารับบริการ',
  'ยืนยันประวัติแพ้ยา': 'ตรวจว่าประวัติแพ้ยาและอาหารถูกต้องก่อนสั่งยา',
  'HPI':
      'เล่าอาการตั้งแต่เริ่มจนมาถึงโรงพยาบาล เวลาเริ่ม ลักษณะอาการ อาการร่วม ประวัติโรคและยาที่ใช้',
  'GA': 'สภาพทั่วไป ความรู้สึกตัว ลักษณะภายนอก',
  'HEENT': 'ศีรษะ ตา หู จมูก คอ',
  'Heart': 'เสียงหัวใจ จังหวะ เสียง murmur',
  'Chest': 'การหายใจ เสียงปอด',
  'Abdomen': 'กดเจ็บ ท้องอืด เสียงลำไส้',
  'Neurological': 'GCS รูม่านตา กำลังกล้ามเนื้อ',
  'Extremities': 'แขนขา ชีพจรส่วนปลาย การผิดรูป',
  'บันทึกการตรวจแบบละเอียด': 'ผลตรวจเพิ่มเติมที่อยากบันทึก ไม่บังคับ',
  'ตำแหน่ง ชนิด ขนาดแผล': 'แตะตำแหน่งบนหุ่น แล้วระบุชนิดและขนาดแผล',
  'หัตถการที่ทำ': 'หัตถการที่ทำจริง เช่น ทำแผล เย็บแผล',
  'รหัสหัตถการ ICD-9-CM': 'ระบบแนะนำรหัสจากหัตถการที่เลือกให้',
  'ถ่ายภาพแผล': 'ถ่ายภาพแผลเก็บไว้ในแฟ้ม หรือข้ามได้',
  'Diagnosis ICD-10': 'รหัสแรกคือการวินิจฉัยหลัก เพิ่มรหัสอื่นได้',
  'สภาพผู้ป่วยออกจากห้อง ER': 'Admit Refer กลับบ้าน หรือสังเกตอาการ',
  'ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป': 'ระบบเรียงตึกที่เหมาะกับเคสให้ก่อน',
};

extension _FeaturesWorkflowStepIntroPart on _ErFlowHomeWidgetState {
  /// ลำดับขั้นที่แสดงจริง (เลขขั้นตามรายการข้อมูล)
  /// แพทย์: ขั้น 0 เดิม "ทบทวนเคส" (ซ่อนไว้) ทีมเปลี่ยนเป็น "คัดกรอง" (ข้อมูลรับเข้า) จึงแสดงกลับมา
  /// "อุบัติเหตุ" (6) ต่อท้ายรายการแต่แสดงหลัง HPI
  /// เลขขั้นเดิมจึงไม่เลื่อน (HPI = 1 ตรวจร่างกาย = 2 ...) โค้ดที่อ้างเลขขั้นยังถูก
  List<int> get _stepOrder => [for (var i = 0; i < _steps.length; i++) i];

  /// ขั้นแรกที่แสดง · จำนวนขั้น · ลำดับที่แสดงของขั้น (เริ่ม 0)
  int get _firstStep => _stepOrder.first;
  int get _stepCount => _stepOrder.length;
  int _stepPos(int i) => _stepOrder.indexOf(i);

  /// ขั้นถัดไป/ก่อนหน้าตามลำดับที่แสดง · ไม่มี = null
  int? _stepNext(int i) {
    final p = _stepPos(i);
    return p >= 0 && p < _stepCount - 1 ? _stepOrder[p + 1] : null;
  }

  int? _stepPrev(int i) {
    final p = _stepPos(i);
    return p > 0 ? _stepOrder[p - 1] : null;
  }

  bool _stepLast(int i) => _stepPos(i) == _stepCount - 1;

  /// คำแนะนำของช่อง: จากตาราง หรือสร้างจากคำใบ้ (ตัวเลือก / ตัวอย่าง)
  String _guideOf(String label) {
    final g = _fieldGuide[label];
    if (g != null) return g;
    final hint = _forms[_speechStep]
            .where((f) => f.$1 == label)
            .map((f) => f.$2)
            .firstOrNull ??
        '';
    if (hint.contains(' / '))
      return 'เลือก ${hint.replaceAll(' / ', ' หรือ ')}';
    if (hint.isNotEmpty) return 'เช่น $hint';
    return _termOf(label) ?? 'กรอกตามที่ตรวจพบจริง';
  }

  /// หน้าคำแนะนำ (หน้าแรกของขั้น): จุดประสงค์ · ช่องที่ต้องกรอก · วิธีใช้ · เริ่ม
  Widget _stepIntro() {
    final step = _speechStep;
    final (icon, name) = _steps[step];
    final labels = [
      for (final (l, _) in _forms[step])
        if (!_dxMerged(step, l)) l
    ];
    final done = labels.where((l) => _fieldDone(step, l)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // การ์ดหัว: ป้ายลำดับขั้น · ชื่อขั้นตัวใหญ่ · คำอธิบาย · ภาพไอคอนขั้นใหญ่มุมขวาล่าง
        // (ปุ่มหุบแผงลอยมุมขวาบน ภาพจึงวางล่างขวาไม่ชนปุ่ม)
        Container(
          height: 150.0,
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(14.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Positioned(
              right: -18.0,
              bottom: -22.0,
              child: Transform.rotate(
                angle: -0.14,
                child: Container(
                  width: 118.0,
                  height: 118.0,
                  decoration: BoxDecoration(
                    gradient: _glossGrad(_blue),
                    borderRadius: BorderRadius.circular(34.0),
                    boxShadow: _glossLift(_blue),
                  ),
                  foregroundDecoration: const _InnerGloss(34.0, dark: true),
                  child: Icon(icon, size: 50.0, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 120.0, 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text('ขั้นที่ ${_stepPos(step) + 1} จาก $_stepCount',
                        style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 2.0),
                  Text(_stepPurpose[name] ?? 'กรอกข้อมูลของขั้นนี้ให้ครบ',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.5, color: _ink3, height: 1.35)),
                ],
              ),
            ),
          ]),
        ),
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
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: _glow.contains(labels[i])
                      ? _blue.withValues(alpha: 0.06)
                      : null,
                  border: const Border(bottom: BorderSide(color: _line)),
                ),
                // ชื่อช่องตัวหนา + คำแนะนำว่าต้องกรอกอะไร · แตะเพื่อไปกรอกช่องนั้น
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Icon(
                            _fieldDone(step, labels[i])
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 17.0,
                            color: _fieldDone(step, labels[i]) ? _green : _g5),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.5,
                                    color: _inkTitle, weight: FontWeight.w700)),
                            const SizedBox(height: 2.0),
                            Text(_guideOf(labels[i]),
                                style: _t(11.5, color: _ink2, height: 1.4)),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 1.0),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 16.0, color: _g5),
                      ),
                    ]),
              ),
            ),
          ),
      ],
    );
  }
}
