// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// คำอธิบายของแต่ละขั้น (ชื่อขั้น → จุดประสงค์) ทุกบทบาท
const Map<String, String> _stepPurpose = {
  'คัดกรอง': 'ตรวจทานข้อมูลคัดกรองและประวัติแพ้ยาก่อนเริ่มตรวจ',
  'ประวัติ HPI': 'พิมพ์ พูด หรือใช้เทมเพลตบันทึกอาการปัจจุบัน',
  'ตรวจร่างกาย': 'บันทึกผลตรวจร่างกายทีละระบบว่าปกติหรือผิดปกติ',
  'บาดแผล/หัตถการ': 'ระบุตำแหน่งแผลบนหุ่น ลักษณะแผล และหัตถการที่ทำ',
  'วินิจฉัย': 'ลงวินิจฉัยด้วยรหัส ICD-10 และคำอธิบาย',
  'สั่งการรักษา': 'เลือกชุดคำสั่ง แล้วสั่งยา แล็บ เอกซเรย์ หัตถการ',
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

/// หน้าแนะนำขั้น: อธิบายแบบฟอร์ม (มีอะไร กรอกยังไง) ไม่ใช่รายการช่อง (ซ้ำกับหน้าสรุป)
/// ชื่อขั้น → [(ไอคอน, หัวข้อ, คำอธิบาย)]
const Map<String, List<(IconData, String, String)>> _stepHowTo = {
  'คัดกรอง': [
    (
      Icons.fact_check_rounded,
      'ตรวจทานข้อมูลคัดกรอง',
      'ดูข้อมูลรับเข้า อาการสำคัญ และสัญญาณชีพที่บันทึกไว้แล้ว แก้ได้ถ้าไม่ถูก'
    ),
    (
      Icons.warning_amber_rounded,
      'ยืนยันประวัติแพ้ยา',
      'ต้องยืนยันก่อนเริ่มสั่งยาทุกครั้ง ระบบใช้เตือนตอนสั่งยา'
    ),
  ],
  'ประวัติ HPI': [
    (
      Icons.notes_rounded,
      'เขียนเป็นเรื่องเล่าช่องเดียว',
      'เล่าตั้งแต่เริ่มมีอาการจนมาถึงโรงพยาบาล ยาวได้ไม่จำกัด'
    ),
    (
      Icons.post_add_rounded,
      'เริ่มจากเทมเพลต',
      'เลือกเทมเพลตตามอาการ แล้วเติมส่วนที่เว้นไว้ให้ครบ'
    ),
    (
      Icons.history_rounded,
      'ดูประวัติ HPI',
      'เปิดดูบันทึกครั้งก่อนของผู้ป่วยเพื่อเทียบอาการ'
    ),
  ],
  'ตรวจร่างกาย': [
    (
      Icons.record_voice_over_rounded,
      'ทบทวนระบบ (ROS)',
      'หน้าแรกถามอาการทีละระบบ ไม่มีอาการ = ปกติ มีอาการ = ผิดปกติแล้วระบุอาการ'
    ),
    (
      Icons.rule_rounded,
      'เลือกผลทีละระบบ',
      'แต่ละระบบกด ปกติ ผิดปกติ หรือไม่ได้ตรวจ ระบบที่ปกติจะถูกเก็บไว้ให้หน้าสั้นลง'
    ),
    (
      Icons.done_all_rounded,
      'ที่เหลือปกติ',
      'กดครั้งเดียวให้ทุกระบบที่ยังว่างเป็นปกติ'
    ),
    (
      Icons.error_rounded,
      'ผิดปกติต้องระบุ',
      'เลือกผิดปกติแล้วกรอกรายละเอียดใต้ระบบนั้นทันที'
    ),
    (
      Icons.description_rounded,
      'ตรวจแบบละเอียด',
      'หน้าถัดไปบันทึกผลตรวจเพิ่มเติมได้ยาว ๆ ไม่บังคับ'
    ),
  ],
  'บาดแผล/หัตถการ': [
    (
      Icons.touch_app_rounded,
      'แตะตำแหน่งบนหุ่น',
      'ระบุตำแหน่งแผลบนหุ่นด้านขวา ใส่ได้หลายแผล'
    ),
    (Icons.healing_rounded, 'ลักษณะแผล', 'ชนิด ขนาด และความลึกของแต่ละแผล'),
    (
      Icons.medical_services_rounded,
      'หัตถการ',
      'เลือกหัตถการที่ทำ พร้อมผู้สั่งและผู้ทำ'
    ),
  ],
  'วินิจฉัย': [
    (
      Icons.assignment_rounded,
      'รหัส ICD-10',
      'พิมพ์หรือเลือกรหัส ICD-10 ใส่ได้หลายรายการ'
    ),
    (
      Icons.auto_awesome_rounded,
      'AI แนะนำรหัส',
      'ระบบเสนอรหัสจากอาการและผลตรวจ แพทย์เป็นผู้ยืนยัน'
    ),
  ],
  'สั่งการรักษา': [
    (
      Icons.playlist_add_check_rounded,
      'ชุดคำสั่งแนะนำ',
      'เลือก Order Set ตามโรค แล้วติ๊กเฉพาะรายการที่ต้องการ'
    ),
    (
      Icons.medication_rounded,
      'สั่งยา แล็บ เอกซเรย์',
      'ระบบเตือนทันทีถ้ายาที่สั่งชนกับประวัติแพ้ยา'
    ),
  ],
  'จำหน่าย': [
    (
      Icons.assignment_turned_in_rounded,
      'ผลการรักษา',
      'เลือกสภาพผู้ป่วยและวิธีจำหน่ายออกจาก ER'
    ),
    (
      Icons.schedule_rounded,
      'เวลาออกจากห้อง',
      'ระบุวันที่และเวลาที่ผู้ป่วยออก'
    ),
  ],
  'สัญญาณชีพ': [
    (
      Icons.monitor_heart_rounded,
      'วัดรอบนี้',
      'กรอกค่าที่วัดได้ ค่าผิดปกติจะขึ้นสีแดงให้เห็นทันที'
    ),
    (Icons.show_chart_rounded, 'เทียบรอบก่อน', 'ดูแนวโน้มจากกราฟในแผงข้อมูล'),
  ],
  'ความรุนแรง AIS': [
    (
      Icons.personal_injury_rounded,
      'ประเมินตามส่วนของร่างกาย',
      'ให้คะแนน AIS แต่ละส่วนที่บาดเจ็บ'
    ),
  ],
  'รับคำสั่งแพทย์': [
    (
      Icons.playlist_add_check_rounded,
      'ยืนยันคำสั่ง',
      'ตรวจคำสั่งการรักษาที่แพทย์สั่ง แล้วยืนยันรับทีละรายการ'
    ),
  ],
  'สังเกตอาการ': [
    (
      Icons.visibility_rounded,
      'บันทึกพร้อมเวลา',
      'บันทึกอาการที่สังเกตได้ ระบบใส่เวลาให้อัตโนมัติ'
    ),
  ],
  'การพยาบาล': [
    (
      Icons.volunteer_activism_rounded,
      'กิจกรรมการพยาบาล',
      'เลือกกิจกรรมที่ทำ และบันทึกผลหลังทำ'
    ),
  ],
  'ออกจาก ER': [
    (
      Icons.logout_rounded,
      'สภาพตอนออก',
      'บันทึกสภาพผู้ป่วยและเวลาออกจากห้องฉุกเฉิน'
    ),
  ],
};

extension _FeaturesWorkflowStepIntroPart on _ErFlowHomeWidgetState {
  /// ลำดับขั้นที่แสดงจริง (เลขขั้นตามรายการข้อมูล)
  /// แพทย์: ขั้น 0 เดิม "ทบทวนเคส" (ซ่อนไว้) ทีมเปลี่ยนเป็น "คัดกรอง" (ข้อมูลรับเข้า) จึงแสดงกลับมา
  /// "อุบัติเหตุ" (6) ต่อท้ายรายการแต่แสดงหลัง HPI
  /// เลขขั้นเดิมจึงไม่เลื่อน (HPI = 1 ตรวจร่างกาย = 2 ...) โค้ดที่อ้างเลขขั้นยังถูก
  /// พยาบาลในห้องฉุกเฉิน: ขั้นคัดกรอง (ต่อท้าย เลข 6) แสดงเป็นขั้นแรก
  /// แพทย์: "สั่งการรักษา" (5) มาก่อน "วินิจฉัย" (4) · เลขขั้นเดิมไม่ขยับ
  List<int> get _stepOrder => switch (ErSession.instance.role) {
        ErRole.nurse => const [6, 0, 1, 2, 3, 4, 5],
        ErRole.doctor => const [0, 1, 2, 3, 5, 4, 6],
        _ => [for (var i = 0; i < _steps.length; i++) i],
      };

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
          // hero = ป้ายบอกทางขนาดใหญ่เต็มการ์ด (ชื่อขั้น + ไอคอนขั้นขวามือ) · ใต้ป้าย = คำอธิบาย
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 104.0,
                  child: _WaySign(
                    key: const ValueKey('sign-steps'),
                    names: [for (final i in _stepOrder) _steps[i].$2],
                    icons: [for (final i in _stepOrder) _steps[i].$1],
                    done: [
                      for (final i in _stepOrder)
                        _clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2
                    ],
                    at: _stepPos(step),
                    busy: false,
                    rowH: 60.0,
                    cable: 38.0,
                    tilt: 0.75,
                    depth: 0.0022,
                    style:
                        _t(20.0, color: Colors.white, weight: FontWeight.w700),
                    numStyle: _num(9.5, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Text(_stepPurpose[name] ?? 'กรอกข้อมูลของขั้นนี้ให้ครบ',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.5, color: _ink3, height: 1.35)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18.0),
        // อธิบายแบบฟอร์ม: มีอะไร กรอกยังไง (รายการช่องดูได้ในหน้าสรุป)
        Text('เกี่ยวกับแบบฟอร์มนี้',
            style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
        const SizedBox(height: 10.0),
        ..._appearAll([
          for (final (ic, title, desc) in [
            ...?_stepHowTo[name],
            (
              Icons.mic_rounded,
              'พูดแทนพิมพ์ได้',
              'กดไมค์แล้วพูด ผู้ช่วยกรอกให้ในช่องที่ตรงกัน'
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(ic, size: 17.0, color: _blue),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: _t(12.5,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text(desc, style: _t(11.5, color: _ink2, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ]),
        Text(
            'ทั้งหมด ${labels.length} ช่อง${done > 0 ? ' กรอกแล้ว $done ช่อง' : ''} ตรวจทานได้ในหน้าสรุปก่อนบันทึก',
            style: _t(10.5, color: _ink3)),
      ],
    );
  }
}
