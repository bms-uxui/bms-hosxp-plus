// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// หน้าแนะนำขั้น: อธิบายแบบฟอร์ม (มีอะไร กรอกยังไง) ไม่ใช่รายการช่อง (ซ้ำกับหน้าสรุป)
/// ชื่อขั้น → [(ไอคอน, หัวข้อ, คำอธิบาย)] · ไอคอนแบบ outline ทั้งหมด (Google style)
const Map<String, List<(IconData, String, String)>> _stepHowTo = {
  'ซักประวัติ': [
    (
      Icons.record_voice_over_outlined,
      'อาการสำคัญ',
      'เลือกอาการจากรายการ หรือพิมพ์อาการที่ไม่มีในรายการ'
    ),
    (
      Icons.monitor_heart_outlined,
      'วัดสัญญาณชีพซ้ำ',
      'แตะการ์ดแล้วหมุนวงล้อเลือกค่า รวมรอบเอวและเส้นรอบศีรษะ'
    ),
    (
      Icons.fact_check_outlined,
      'ข้อมูลตามแบบ HOSxP',
      'ตั้งครรภ์ ให้นมบุตร G6PD และ FP (เฉพาะผู้หญิง)'
    ),
    (
      Icons.warning_amber_outlined,
      'แพ้ยา สูบบุหรี่ ดื่มสุรา',
      'ต้องเลือกก่อนบันทึก ถ้าไม่มีทั้งหมดติ๊ก "ไม่มีทั้งหมด" ได้ในครั้งเดียว'
    ),
    (
      Icons.history_outlined,
      'บันทึกได้หลายครั้ง',
      'ทุกครั้งที่บันทึกจะขึ้นในกิจกรรมพยาบาล ดูย้อนหลังได้'
    ),
  ],
  'คัดกรอง': [
    (
      Icons.fact_check_outlined,
      'ตรวจทานข้อมูลคัดกรอง',
      'ดูข้อมูลรับเข้า อาการสำคัญ และสัญญาณชีพที่บันทึกไว้แล้ว แก้ได้ถ้าไม่ถูก'
    ),
    (
      Icons.warning_amber_outlined,
      'ยืนยันประวัติแพ้ยา',
      'ต้องยืนยันก่อนเริ่มสั่งยาทุกครั้ง ระบบใช้เตือนตอนสั่งยา'
    ),
  ],
  'ประวัติ HPI': [
    (
      Icons.notes_outlined,
      'เขียนเป็นเรื่องเล่าช่องเดียว',
      'เล่าตั้งแต่เริ่มมีอาการจนมาถึงโรงพยาบาล ยาวได้ไม่จำกัด'
    ),
    (
      Icons.post_add_outlined,
      'เริ่มจากเทมเพลต',
      'เลือกเทมเพลตตามอาการ แล้วเติมส่วนที่เว้นไว้ให้ครบ'
    ),
    (
      Icons.history_outlined,
      'ดูประวัติ HPI',
      'เปิดดูบันทึกครั้งก่อนของผู้ป่วยเพื่อเทียบอาการ'
    ),
  ],
  'ตรวจร่างกาย': [
    (
      Icons.record_voice_over_outlined,
      'ทบทวนระบบ (ROS)',
      'หน้าแรกถามอาการทีละระบบ ไม่มีอาการ = ปกติ มีอาการ = ผิดปกติแล้วระบุอาการ'
    ),
    (
      Icons.rule_outlined,
      'เลือกผลทีละระบบ',
      'แต่ละระบบกด ปกติ ผิดปกติ หรือไม่ได้ตรวจ ระบบที่ปกติจะถูกเก็บไว้ให้หน้าสั้นลง'
    ),
    (
      Icons.done_all_outlined,
      'ที่เหลือปกติ',
      'กดครั้งเดียวให้ทุกระบบที่ยังว่างเป็นปกติ'
    ),
    (
      Icons.error_outline_rounded,
      'ผิดปกติต้องระบุ',
      'เลือกผิดปกติแล้วกรอกรายละเอียดใต้ระบบนั้นทันที'
    ),
    (
      Icons.description_outlined,
      'ตรวจแบบละเอียด',
      'หน้าถัดไปบันทึกผลตรวจเพิ่มเติมได้ยาว ๆ ไม่บังคับ'
    ),
  ],
  'บาดแผล/หัตถการ': [
    (
      Icons.touch_app_outlined,
      'แตะตำแหน่งบนหุ่น',
      'ระบุตำแหน่งแผลบนหุ่นด้านขวา ใส่ได้หลายแผล'
    ),
    (Icons.healing_outlined, 'ลักษณะแผล', 'ชนิด ขนาด และความลึกของแต่ละแผล'),
    (
      Icons.medical_services_outlined,
      'หัตถการ',
      'เลือกหัตถการที่ทำ พร้อมผู้สั่งและผู้ทำ'
    ),
  ],
  'วินิจฉัย': [
    (
      Icons.assignment_outlined,
      'รหัส ICD-10',
      'พิมพ์หรือเลือกรหัส ICD-10 ใส่ได้หลายรายการ'
    ),
    (
      Icons.auto_awesome_outlined,
      'AI แนะนำรหัส',
      'ระบบเสนอรหัสจากอาการและผลตรวจ แพทย์เป็นผู้ยืนยัน'
    ),
  ],
  'สั่งการรักษา': [
    (
      Icons.playlist_add_check_outlined,
      'ชุดคำสั่งแนะนำ',
      'เลือก Order Set ตามโรค แล้วติ๊กเฉพาะรายการที่ต้องการ'
    ),
    (
      Icons.medication_outlined,
      'สั่งยา แล็บ เอกซเรย์',
      'ระบบเตือนทันทีถ้ายาที่สั่งชนกับประวัติแพ้ยา'
    ),
  ],
  'จำหน่าย': [
    (
      Icons.assignment_turned_in_outlined,
      'ผลการรักษา',
      'เลือกสภาพผู้ป่วยและวิธีจำหน่ายออกจาก ER'
    ),
    (
      Icons.schedule_outlined,
      'เวลาออกจากห้อง',
      'ระบุวันที่และเวลาที่ผู้ป่วยออก'
    ),
  ],
  'สัญญาณชีพ': [
    (
      Icons.monitor_heart_outlined,
      'วัดรอบนี้',
      'กรอกค่าที่วัดได้ ค่าผิดปกติจะขึ้นสีแดงให้เห็นทันที'
    ),
    (Icons.show_chart_outlined, 'เทียบรอบก่อน', 'ดูแนวโน้มจากกราฟในแผงข้อมูล'),
  ],
  'ความรุนแรง AIS': [
    (
      Icons.personal_injury_outlined,
      'ประเมินตามส่วนของร่างกาย',
      'ให้คะแนน AIS แต่ละส่วนที่บาดเจ็บ'
    ),
  ],
  'รับคำสั่งแพทย์': [
    (
      Icons.playlist_add_check_outlined,
      'ยืนยันคำสั่ง',
      'ตรวจคำสั่งการรักษาที่แพทย์สั่ง แล้วยืนยันรับทีละรายการ'
    ),
  ],
  'สังเกตอาการ': [
    (
      Icons.visibility_outlined,
      'บันทึกพร้อมเวลา',
      'บันทึกอาการที่สังเกตได้ ระบบใส่เวลาให้อัตโนมัติ'
    ),
  ],
  'การพยาบาล': [
    (
      Icons.volunteer_activism_outlined,
      'กิจกรรมการพยาบาล',
      'เลือกกิจกรรมที่ทำ และบันทึกผลหลังทำ'
    ),
  ],
  'ออกจาก ER': [
    (
      Icons.logout_outlined,
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
  /// พยาบาลในห้องฉุกเฉิน: ซักประวัติ (7) เป็นขั้นแรก แล้วคัดกรอง (6)
  /// แพทย์: "สั่งการรักษา" (5) มาก่อน "วินิจฉัย" (4) · เลขขั้นเดิมไม่ขยับ
  List<int> get _stepOrder => switch (ErSession.instance.role) {
        // สัญญาณชีพ (0) รวมอยู่ในซักประวัติแล้ว ไม่แสดงเป็นขั้นแยก
        ErRole.nurse => const [7, 6, 1, 2, 3, 4, 5],
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

  /// ป้ายบอกทางของขั้น (ชื่อขั้น + ไอคอน) ขนาดเล็ก วางขวาของหัวการ์ดคำแนะนำ
  /// มุมเอียง/perspective เดิมของป้าย · สลิงถูกตัดที่ขอบบนกล่องป้าย
  Widget _stepSign() {
    final step = _speechStep;
    final (_, name) = _steps[step];
    const rowH = 50.0;
    final base = _t(16.0, color: Colors.white, weight: FontWeight.w700);
    return SizedBox(
      width: 300.0,
      height: 92.0,
      child: ClipRect(
        child: LayoutBuilder(builder: (context, box) {
          // ชื่อยาว: ย่อตัวอักษรให้เต็มชื่อในป้าย (ไม่ตัด ...)
          const fixed = rowH * (0.34 + 0.2 + 0.55 + 0.6) + 8.0;
          final tp = TextPainter(
              text: TextSpan(text: name, style: base),
              maxLines: 1,
              textDirection: TextDirection.ltr)
            ..layout();
          final k = ((box.maxWidth / 1.12 - fixed) / tp.width).clamp(0.6, 1.0);
          return _WaySign(
            key: const ValueKey('sign-steps'),
            names: [for (final i in _stepOrder) _steps[i].$2],
            icons: [for (final i in _stepOrder) _steps[i].$1],
            done: [
              for (final i in _stepOrder)
                _clyStep(i).$2 > 0 && _clyStep(i).$1 == _clyStep(i).$2
            ],
            at: _stepPos(step),
            busy: false,
            rowH: rowH,
            cable: 30.0,
            tilt: 0.75,
            depth: 0.0022,
            style: base.copyWith(fontSize: 16.0 * k),
            numStyle: _num(9.5, color: Colors.white),
          );
        }),
      ),
    );
  }

  /// หน้าคำแนะนำ (หน้าแรกของขั้น): จุดประสงค์ · ช่องที่ต้องกรอก · วิธีใช้ · เริ่ม
  Widget _stepIntro() {
    final step = _speechStep;
    final (icon, name) = _steps[step];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // การ์ด hero: ป้ายบอกทางของขั้น (แขวนจากขอบบน) แยกจากการ์ดคำแนะนำ
        Container(
          height: 104.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(14.0),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.topLeft,
          // มุมขวา: ไอคอนเมนูของขั้นตัวใหญ่จาง ๆ ล้นขอบการ์ด (ลายพื้น ไม่แย่งป้าย)
          // Stack เต็มการ์ด: ไอคอนชิดขวาล่าง (เลื่อนลงล้นขอบ) · ป้ายชิดซ้ายบน
          child:
              Stack(fit: StackFit.expand, clipBehavior: Clip.none, children: [
            Positioned(
              right: -4.0,
              bottom: -30.0,
              // จางลงจากบนลงล่าง ใส 0 ที่ขอบล่างการ์ด (ส่วนที่ล้นขอบถูกตัดอยู่แล้ว)
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.0, 0.73],
                ).createShader(r),
                child: Icon(_steps[_speechStep].$1,
                    size: 112.0, color: _blue.withValues(alpha: 0.1)),
              ),
            ),
            Align(alignment: Alignment.topLeft, child: _stepSign()),
          ]),
        ),
        const SizedBox(height: 12.0),
        // อธิบายแบบฟอร์ม: หัวข้อ + รายการไอคอนเรียบ มีเส้นคั่นแถว (ไม่ครอบการ์ด)
        _Appear(
          index: 0,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('เกี่ยวกับแบบฟอร์มนี้',
                  style: _t(16.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
            for (final (i, (ic, title, desc)) in [
              ...?_stepHowTo[name],
              (
                Icons.mic_none_outlined,
                'พูดแทนพิมพ์ได้',
                'กดไมค์แล้วพูด ผู้ช่วยกรอกให้ในช่องที่ตรงกัน'
              ),
            ].indexed)
              // เส้นคั่นระหว่างแถว (ไม่มีใต้หัวข้อ)
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : const Border(top: BorderSide(color: Color(0xFFE8EAED))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Icon(ic, size: 22.0, color: _ink2),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: _t(14.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                          const SizedBox(height: 2.0),
                          Text(desc,
                              style: _t(12.5,
                                  color: _ink3,
                                  weight: FontWeight.w500,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      ],
    );
  }
}
