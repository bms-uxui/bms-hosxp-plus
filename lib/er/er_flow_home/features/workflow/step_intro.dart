// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// หน้าแนะนำขั้น: หัวข้อใหญ่ที่ต้องทำเรียงเป็นลำดับ + คำอธิบายสั้นบรรทัดเดียว
/// ไม่อธิบายวิธีกรอกทุกอย่าง · ชื่อขั้น → [(ไอคอน, สิ่งที่ต้องทำ, ทำอะไร)]
const Map<String, List<(IconData, String, String)>> _stepHowTo = {
  // หัวข้อ = คำนามสั้น ๆ · คำอธิบาย = ตัวอย่างสิ่งที่ต้องกรอก
  'ซักประวัติ': [
    (
      Icons.record_voice_over_outlined,
      'อาการสำคัญ',
      'ทวนอาการจากจุดส่งตรวจ แก้ให้ตรงกับที่ซักได้'
    ),
    (
      Icons.monitor_heart_outlined,
      'สัญญาณชีพ',
      'ความดัน ชีพจร การหายใจ อุณหภูมิ SpO₂ รอบเอว'
    ),
    (
      Icons.warning_amber_outlined,
      'แพ้ยา สูบบุหรี่ ดื่มสุรา',
      'ยาที่แพ้ สูบบุหรี่หรือไม่ ดื่มสุราหรือไม่'
    ),
  ],
  'คัดกรอง': [
    (
      Icons.fact_check_outlined,
      'ข้อมูลรับเข้า',
      'อาการสำคัญ สัญญาณชีพ ระดับความเร่งด่วน'
    ),
    (Icons.warning_amber_outlined, 'ประวัติแพ้ยา', 'ชื่อยาที่แพ้ และอาการแพ้'),
  ],
  'ประวัติ HPI': [
    (
      Icons.notes_outlined,
      'ประวัติการเจ็บป่วยปัจจุบัน',
      'เริ่มมีอาการเมื่อไร อาการเป็นอย่างไร รักษาอะไรมาแล้ว'
    ),
  ],
  'ตรวจร่างกาย': [
    (
      Icons.record_voice_over_outlined,
      'ทบทวนระบบ (ROS)',
      'เช่น ระบบหายใจ หัวใจ ทางเดินอาหาร'
    ),
    (
      Icons.rule_outlined,
      'ผลตรวจร่างกาย',
      'ปกติ ผิดปกติ หรือไม่ได้ตรวจ ในแต่ละระบบ'
    ),
  ],
  'บาดแผล/หัตถการ': [
    (Icons.touch_app_outlined, 'ตำแหน่งแผล', 'เช่น ศีรษะ แขนซ้าย ขาขวา'),
    (Icons.healing_outlined, 'ลักษณะแผล', 'ชนิดแผล ขนาด ความลึก'),
    (
      Icons.medical_services_outlined,
      'หัตถการ',
      'เช่น เย็บแผล ใส่เฝือก ผู้สั่งและผู้ทำ'
    ),
  ],
  'วินิจฉัย': [
    (
      Icons.assignment_outlined,
      'รหัสโรค ICD-10',
      'รหัสโรคหลัก รหัสโรคร่วม และคำวินิจฉัย'
    ),
  ],
  'สั่งการรักษา': [
    (
      Icons.playlist_add_check_outlined,
      'ชุดคำสั่ง (Order Set)',
      'เช่น ชุดเจ็บหน้าอก ชุดปวดท้อง'
    ),
    (
      Icons.medication_outlined,
      'ยา แล็บ เอกซเรย์',
      'ชื่อยา ขนาด วิธีให้ รายการแล็บ และเอกซเรย์'
    ),
  ],
  'จำหน่าย': [
    (
      Icons.assignment_turned_in_outlined,
      'ผลการรักษา',
      'สภาพผู้ป่วย และวิธีจำหน่าย เช่น กลับบ้าน รับไว้ ส่งต่อ'
    ),
    (Icons.schedule_outlined, 'เวลาออกจากห้อง', 'วันที่ และเวลาที่ผู้ป่วยออก'),
  ],
  'สัญญาณชีพ': [
    (
      Icons.monitor_heart_outlined,
      'สัญญาณชีพ',
      'ความดัน ชีพจร การหายใจ อุณหภูมิ SpO₂ รอบเอว'
    ),
  ],
  'ความรุนแรง AIS': [
    (
      Icons.personal_injury_outlined,
      'คะแนน AIS',
      'คะแนนการบาดเจ็บของแต่ละส่วน เช่น ศีรษะ ทรวงอก'
    ),
  ],
  'รับคำสั่งแพทย์': [
    (
      Icons.playlist_add_check_outlined,
      'คำสั่งแพทย์',
      'รายการยา แล็บ และหัตถการที่แพทย์สั่ง'
    ),
  ],
  'สังเกตอาการ': [
    (
      Icons.visibility_outlined,
      'อาการที่สังเกตได้',
      'เช่น ระดับความรู้สึกตัว ความปวด อาการเปลี่ยนแปลง'
    ),
  ],
  'การพยาบาล': [
    (
      Icons.volunteer_activism_outlined,
      'กิจกรรมการพยาบาล',
      'เช่น ให้ยา เช็ดตัวลดไข้ ดูแลแผล และผลหลังทำ'
    ),
  ],
  'ออกจาก ER': [
    (
      Icons.logout_outlined,
      'สภาพตอนออก',
      'ระดับความรู้สึกตัว สัญญาณชีพ และเวลาที่ออก'
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
        // สิ่งที่ต้องทำ: เรียงเป็นลำดับ วงเลข + เส้นเชื่อม · หัวข้อ + คำอธิบายบรรทัดเดียว
        _Appear(
          index: 0,
          child: Builder(builder: (context) {
            final items = _stepHowTo[name] ?? const [];
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text('เกี่ยวกับแบบฟอร์มนี้',
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  for (final (i, (_, title, desc)) in items.indexed)
                    IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // วงเลข + เส้นต่อไปข้อถัดไป
                            SizedBox(
                              width: 32.0,
                              child: Column(children: [
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F0FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text('${i + 1}',
                                      style: _num(14.0, color: _blue)),
                                ),
                                if (i < items.length - 1)
                                  Expanded(
                                    child: Container(
                                        width: 2.0,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        color: const Color(0xFFE8EAED)),
                                  ),
                              ]),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: i < items.length - 1 ? 18.0 : 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: _t(15.0,
                                            color: _inkTitle,
                                            weight: FontWeight.w600)),
                                    const SizedBox(height: 3.0),
                                    Text(desc,
                                        style: _t(13.0,
                                            color: _ink3,
                                            weight: FontWeight.w500,
                                            height: 1.35)),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                ]);
          }),
        ),
      ],
    );
  }
}
