// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ หน้าคัดกรอง (พยาบาลคัดกรอง)
// งานเดียว: ตัดสินระดับ ESI ให้เร็ว แล้วส่งเข้าห้องตรวจ
// ซ้าย = ข้อมูลจากหน้าลงทะเบียน (ไม่ถามซ้ำ) · กลาง = วัดและประเมิน
// ขวา = ESI ที่ระบบแนะนำ + เหตุผล พยาบาลยืนยันเสมอ
// เกณฑ์ตามบัตร "การคัดแยกระดับความรุนแรง ESI 5 ระดับ"
// (MOPH ED Triage กรมการแพทย์ กระทรวงสาธารณสุข 2561) กติกาข้อ 51

/// ขั้น 1 จะเสียชีวิต ต้องช่วยทันที → ESI 1 (ส่วนที่เป็นตัวเลขคำนวณจาก V/S)
const List<(String, IconData)> _triLifeOpts = [
  ('ต้อง CPR', Icons.monitor_heart_rounded),
  ('ต้องใส่ท่อช่วยหายใจ', Icons.air_rounded),
  ('ต้องใส่ ICD', Icons.medical_services_rounded),
  ('หยุดหายใจ (Apnea)', Icons.do_not_disturb_on_rounded),
  ('หัวใจเต้นผิดจังหวะ', Icons.favorite_rounded),
  ('ชัก', Icons.bolt_rounded),
  ('น้ำตาลในเลือดต่ำ', Icons.water_drop_rounded),
  ('กินยาเกินขนาด', Icons.medication_rounded),
  ('Trauma ต้องให้สารน้ำ', Icons.car_crash_rounded),
  ('ตกที่สูงและซึม', Icons.stairs_rounded),
  ('แพ้รุนแรง (Anaphylaxis)', Icons.coronavirus_rounded),
];

/// ขั้น 2 เสี่ยง ซึม ปวด → ESI 2 (GCS 9–12, ปวด ≥ 7, ไข้ทารก คำนวณให้)
const List<(String, IconData)> _triRiskOpts = [
  ('Fast track', Icons.bolt_rounded),
  ('ซึม สับสน', Icons.psychology_alt_rounded),
  ('เสี่ยงต่อการฆ่าตัวตาย', Icons.report_rounded),
  ('เข็มทิ่มตำ เจ้าหน้าที่', Icons.vaccines_rounded),
  ('ได้ยาเคมีบำบัดแล้วมีไข้', Icons.thermostat_rounded),
  ('ถูกข่มขืน', Icons.shield_rounded),
];

/// อาการสำคัญที่เข้าข่าย Fast track: (คำในอาการ, ชื่อ fast track)
/// จากการทดสอบกับข้อมูลจริง เคสที่ควรเป็น ESI 2 แต่หลุดเป็น 3 ส่วนใหญ่คือ
/// เจ็บหน้าอกกับอาการ stroke ระบบจึงเตือนให้ติ๊ก (พยาบาลยืนยันเอง)
/// Fast track ที่เปิดในหน้าคัดกรองนี้: รหัสแฟ้ม → เวลาเปิด (ส่งต่อไป _ftOpened ตอนส่ง)
final Map<String, DateTime> _triFt = {};

/// การ์ด Fast track ในหน้าคัดกรอง (แบนเนอร์ ESI แตะแล้วเลื่อนมาหา)
final GlobalKey _triFtKey = GlobalKey();

/// เกณฑ์ที่ใช้เปิดแฟ้ม fast track ต่อเคส (HN → รหัสแฟ้ม → เกณฑ์)
final Map<String, Map<String, List<String>>> _ftCriteria = {};

/// แฟ้มที่บังคับ ESI อย่างน้อย 2 (ช่องทางด่วนทางหลอดเลือด/ติดเชื้อ)
const Set<String> _ftEsi2 = {'stroke', 'stemi', 'sepsis'};

const List<(String, String)> _triFastWords = [
  ('เจ็บหน้าอก', 'STEMI'),
  ('แน่นหน้าอก', 'STEMI'),
  ('เจ็บอก', 'STEMI'),
  // stroke เฉพาะอาการชัด (ข้างเดียว/พูด/หน้า) คำกว้างอย่าง "แขนขาอ่อนแรง"
  // เตือนเกินจริง: ทดสอบแล้ว 42 จาก 75 รายผู้เชี่ยวชาญให้ระดับ 3
  ('อ่อนแรงครึ่งซีก', 'Stroke'),
  ('อ่อนแรงซีก', 'Stroke'),
  ('อ่อนแรงข้างเดียว', 'Stroke'),
  ('พูดไม่ชัด', 'Stroke'),
  ('ปากเบี้ยว', 'Stroke'),
  ('หน้าเบี้ยว', 'Stroke'),
  ('ชาครึ่งซีก', 'Stroke'),
  ('ชาซีก', 'Stroke'),
];

/// Red Flag 4 โรคสำคัญ (แบบฟอร์ม ER TRIAGE AUDIT ข้อ 4): (โรค, เกณฑ์)
/// เกณฑ์ช่วงเวลา (< 24 ชม. / < 72 ชม.) ใช้ประกอบ ไม่นับเป็น red flag เดี่ยว ๆ
const List<(String, List<String>)> _triRedFlags = [
  (
    'TBI',
    ['< 24 ชม.', 'GCS < 15', 'หมดสติ', 'อาเจียนซ้ำ', 'ชัก', 'ปวดศีรษะมาก']
  ),
  ('STEMI', ['Chest pain', 'เหงื่อแตก', 'ECG STEMI']),
  (
    'Stroke',
    [
      '< 72 ชม.',
      'FAST (+)',
      'แขนขาอ่อนแรง',
      'พูดไม่ชัด',
      'ปากเบี้ยว',
      'ชาครึ่งซีก'
    ]
  ),
  ('Sepsis', ['NEWS > 4', 'ซึม', 'สงสัยติดเชื้อ', 'V/S ผิดปกติ']),
];
const Set<String> _triRedWindow = {'< 24 ชม.', '< 72 ชม.'};

/// ประเภทผู้ป่วย: (ชื่อ, ไอคอน, ระดับขั้นต่ำ) · null = ไม่บังคับระดับ
/// Stroke/STEMI/Sepsis = fast track → อย่างน้อย ESI 2 · Septic shock = ESI 1
/// Trauma/TBI = ใช้จัดกลุ่มและเรียก trauma team ระดับตามอาการ
const List<(String, IconData, int?)> _triTypeOpts = [
  // ประเภทหลักตาม master er_patient_type (ไม่รวม fast track Stroke/STEMI/Sepsis)
  ('อุบัติเหตุ', Icons.car_crash_rounded, null),
  ('ฉุกเฉิน', Icons.emergency_rounded, null),
  ('ตรวจโรคทั่วไป', Icons.medical_services_outlined, null),
];

/// ตัวเลือกจากหน้าคัดกรองเดิม (add_screening)
const List<String> _qShifts = ['เวรเช้า', 'เวรบ่าย', 'เวรดึก'];
const List<String> _qArrTypes = [
  'มาเอง',
  'ส่งตัวโดย First responder',
  'ส่งตัวโดย BLS',
  'ส่งตัวโดย ILS',
  'ส่งตัวโดย ALS',
  'ส่งต่อจากสถานพยาบาลอื่นๆ',
  'อื่นๆ',
  'ไม่ทราบ',
];
const List<String> _qFroms = [
  'สถานีอนามัย',
  'โรงพยาบาลชุมชน',
  'โรงพยาบาลทั่วไป (จังหวัด)',
  'โรงพยาบาลศูนย์',
  'โรงพยาบาลมหาวิทยาลัย',
  'โรงพยาบาลจิตเวช',
];
const List<String> _qBringers = [
  'มาเอง',
  'ญาติ',
  'หน่วยกู้ชีพ ระดับพื้นฐาน (BLS)',
  'หน่วยกู้ชีพ ระดับกลาง (ILS)',
  'หน่วยกู้ชีพ ระดับสูง (ALS)',
  'รถพยาบาลโรงพยาบาลต้นทาง',
  'เจ้าหน้าที่ตำรวจ',
  'อื่นๆ',
];
const List<String> _triEOpts = [
  'E4 ลืมตาได้เอง',
  'E3 ลืมตาเมื่อถูกเรียก',
  'E2 ลืมเมื่อเจ็บ',
  'E1 ไม่ลืมเลย(ไม่มีการตอบสนอง)',
  'C-ตาบวมปิด',
];
const List<String> _triVOpts = [
  'V5 พูดคุยได้แต่ไม่สับสน',
  'V4 พูดคุยได้แต่สับสน',
  'V3 พูดเป็นคำๆ',
  'V2 ส่งเสียงไม่เป็นคำ',
  'V1 ไม่ออกเสียงเลย',
];
const List<String> _triMOpts = [
  'M6 ทำตามคำสั่งได้',
  'M5 ทราบตำแหน่งที่ได้รับบาดเจ็บ',
  'M4 ซักแขนขาหนี',
  'M3 แขนที่ Ab.flex',
  'M2 แขนมี Ab.ext',
  'M1 ไม่เคลื่อนไหว',
];
const List<String> _triLocOpts = [
  'ตื่นดี',
  'สับสน',
  'ซึม',
  'ซึมมาก',
  'ไม่รู้สึกตัว',
];
const List<String> _triPupilSizes = ['1', '2', '3', '4', '5', '6', '7', '8'];
const List<String> _triPupilReacts = ['React', 'Sluggish', 'Fixed'];

/// ข้อมูลรับเข้าห้องฉุกเฉิน (ตามฟอร์ม HOSxP "การรับเข้าห้องฉุกเฉิน")

/// แผนก: backend ผูกกับจุดบริการอยู่แล้ว แสดงอย่างเดียว (จำลอง)
const String _qDeptName = 'อุบัติเหตุและฉุกเฉิน';

/// ธงรับเข้า: (ชื่อ, ไอคอน)
const List<(String, IconData)> _qFlagOpts = [
  ('เป็นการรักษาด่วน (UCEP)', Icons.emergency_rounded),
  ('กลับมารักษาซ้ำ', Icons.replay_rounded),
  ('ผู้ป่วยคดี', Icons.gavel_rounded),
  ('เสียชีวิตก่อนมาถึง รพ.', Icons.heart_broken_rounded),
];

/// ขั้น 3 กิจกรรมที่คาดว่าต้องทำ: 0 = ESI 5, 1 = ESI 4, มากกว่า 1 = ESI 3
/// นับตามชนิด ไม่ใช่จำนวนการตรวจ (CBC + ปัสสาวะ = Lab 1 อย่าง) ตาม ESI v5
/// หัตถการใหญ่ (ให้ยานอนหลับทำหัตถการ) นับ 2
const List<String> _triActOpts = [
  'Lab',
  'X-ray',
  'EKG',
  'U/S',
  'CT/MRI',
  'IV fluid',
  'ยาฉีด/พ่นยา',
  'Consult',
  'หัตถการง่าย',
  'หัตถการใหญ่',
];

/// V/S dangerous zone ตามกลุ่มอายุ: (กลุ่ม, PR เกิน, RR เกิน) · SpO₂ < 92 ทุกกลุ่ม
const List<(String, double, double)> _triBands = [
  ('< 3 เดือน', 180.0, 50.0),
  ('3 เดือน-3 ปี', 160.0, 40.0),
  ('3-8 ปี', 140.0, 30.0),
  ('> 8 ปี', 100.0, 20.0),
];

/// สัญญาณชีพ: (key, ชื่อ, หน่วย) เรียงตามใบคัดกรองกระดาษ
/// BP PR RR BT SpO₂ GCS DTX (sbp/dbp แสดงเป็นแถว BP เดียว)
const List<(String, String, String)> _triVsFields = [
  ('sbp', 'ความดันโลหิต', 'mmHg'),
  ('dbp', 'ความดันตัวล่าง', 'mmHg'),
  ('hr', 'อัตราการเต้นหัวใจ', 'bpm'),
  ('rr', 'อัตราการหายใจ', '/min'),
  ('bt', 'อุณหภูมิ', '°C'),
  ('spo2', 'ออกซิเจนในเลือด', '%'),
  ('gcs', 'ความรู้สึกตัว', '/15'),
  ('dtx', 'น้ำตาลปลายนิ้ว', 'mg/dL'),
  ('wt', 'น้ำหนัก / ส่วนสูง', 'kg'),
  ('ht', 'ส่วนสูง', 'cm'),
  ('waist', 'รอบเอว', 'cm'),
  ('head', 'เส้นรอบศีรษะ', 'cm'),
];

/// การ์ด V/S แสดงรอบเอว เส้นรอบศีรษะ เพิ่ม (ขั้นสัญญาณชีพของพยาบาล ตามแบบ HOSxP)
bool _triVsExtra = false;

/// ชื่อหลักของแถวตามใบคัดกรองกระดาษ (ชื่อไทยเป็นป้ายจางต่อท้าย)
const Map<String, String> _triVsEn = {
  'sbp': 'BP',
  'hr': 'HR',
  'rr': 'RR',
  'bt': 'BT',
  'spo2': 'SpO₂',
  'gcs': 'GCS',
  'dtx': 'DTX',
  'wt': 'น้ำหนัก',
  'ht': 'ส่วนสูง',
  'waist': 'รอบเอว',
  'head': 'เส้นรอบศีรษะ',
};

/// ที่ตรวจและเวลาที่ต้องได้รับการช่วยเหลือตามระดับ (ตามบัตร)
(String, String) _triZoneOf(int level) => switch (level) {
      1 => ('ห้องฉุกเฉิน', 'ช่วยเหลือทันที'),
      2 => ('ห้องฉุกเฉิน', 'ภายใน 15 นาที'),
      3 => ('OPD/ER', 'ภายใน 30 นาที'),
      4 => ('OPD', 'ภายใน 60 นาที'),
      _ => ('OPD', 'รอได้ 120 นาที'),
    };

extension _TriagePagePart on _ErFlowHomeWidgetState {
  TextEditingController _triCtl(String k) =>
      _triIn.putIfAbsent(k, TextEditingController.new);

  double? _triVal(String k) => double.tryParse(_triCtl(k).text.trim());

  /// ข้อความอาการสำคัญของผู้ป่วยที่กำลังคัดกรอง
  /// (หน้าคัดกรอง = จากการลงทะเบียน/แฟ้ม · หน้าลงทะเบียน = ที่เลือกอยู่)
  String _triCcText() {
    final p = _triP;
    if (p == null) return '${_qCc.join(' ')} ${_regCtl('cc').text}';
    final reg = _regSent[p.hn];
    if (reg != null) return reg.$2.join(' ');
    return erCases[p.hn]?.cc ?? p.note;
  }

  /// Fast track ที่อาการสำคัญเข้าข่าย: (คำที่เจอ, ชนิด) · null = ไม่เข้าข่าย
  (String, String)? _triFastHint() {
    final cc = _triCcText();
    for (final w in _triFastWords) {
      if (cc.contains(w.$1)) return w;
    }
    return null;
  }

  /// กลุ่มอายุจากอายุเป็นปี (0 ปี แยก < 3 เดือนไม่ได้ ให้พยาบาลเลือกเอง)
  /// อายุไม่ทราบ = ผู้ใหญ่ (> 8 ปี) · 0 ปี (< 1 ปี) ถือเป็น 3 เดือน-3 ปี
  String? _triBandOf(int? age) => age == null
      ? '> 8 ปี'
      : age == 0
          ? '3 เดือน-3 ปี'
          : age >= 9
              ? '> 8 ปี'
              : age >= 3
                  ? '3-8 ปี'
                  : '3 เดือน-3 ปี';

  /// โหลดตำแหน่ง sheet ที่จำไว้ในเครื่อง (ครั้งแรกครั้งเดียว) ใช้ร่วมกับ sheet V/S
  void _loadSheetAlign() {
    if (_wheelAlignLoaded) return;
    _wheelAlignLoaded = true;
    SharedPreferences.getInstance().then((p) {
      final v = p.getString('er_wheel_align');
      final seen = p.getBool('er_wheel_drag_seen') ?? false;
      if (mounted) {
        setState(() {
          if (v != null) _wheelAlign = v;
          _wheelDragSeen = seen;
        });
      }
    });
  }

  /// bottom sheet กลางของ ER: การ์ดลอยมุม 20 วางซ้าย/กลาง/ขวาตามที่จำไว้
  /// ตำแหน่งอื่นเป็นกรอบ ghost ข้าง sheet แตะเพื่อย้าย (design rule: ทุก sheet ต้องมี)
  /// รับพารามิเตอร์ชื่อเดียวกับ showModalBottomSheet ใช้แทนกันได้ทันที
  Future<T?> _placedSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    Color? barrierColor,
    bool isScrollControlled = true,
    BoxConstraints? constraints,
    ShapeBorder? shape,
  }) {
    _loadSheetAlign();
    final maxW = (constraints?.maxWidth.isFinite ?? false)
        ? constraints!.maxWidth
        : 560.0;
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final size = MediaQuery.sizeOf(ctx);
        final sw = size.width;
        final w = math.min(maxW, sw - 24.0);
        const order = ['left', 'center', 'right'];
        final x0 = switch (_wheelAlign) {
          'left' => 12.0,
          'right' => sw - 12.0 - w,
          _ => (sw - w) / 2,
        };
        final cur = order.indexOf(_wheelAlign);
        List<(String, double, double)> slots(
            List<String> vs, double from, double to) {
          if (vs.isEmpty || to - from < 120.0) return const [];
          final gw = (to - from - 12.0 * (vs.length - 1)) / vs.length;
          return [
            for (final (n, v) in vs.indexed) (v, from + n * (gw + 12.0), gw)
          ];
        }

        final ghosts = [
          ...slots(order.sublist(0, cur), 12.0, x0 - 12.0),
          ...slots(order.sublist(cur + 1), x0 + w + 12.0, sw - 12.0),
        ];
        const names = {'left': 'ซ้าย', 'center': 'กลาง', 'right': 'ขวา'};
        const icons = {
          'left': Icons.align_horizontal_left_rounded,
          'center': Icons.align_horizontal_center_rounded,
          'right': Icons.align_horizontal_right_rounded,
        };
        final card = Container(
          width: w,
          constraints: BoxConstraints(maxHeight: size.height * 0.88),
          margin: const EdgeInsets.only(bottom: 12.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: builder(ctx),
        );
        // แตะพื้นที่ว่างเหนือ sheet = ปิด (พื้นที่ sheet เต็มจอ barrier รับแตะไม่ถึง)
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).maybePop(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: sw,
              child: Stack(children: [
                for (final (v, gx, gw) in ghosts)
                  AnimatedPositioned(
                    key: ValueKey('ghost-$v'),
                    duration: _sheetMove,
                    curve: Curves.easeOutCubic,
                    left: gx,
                    width: gw,
                    top: 0.0,
                    bottom: 12.0,
                    child: _ghostIn(_Press(
                      radius: 20.0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _wheelAlign = v);
                          setS(() {});
                          SharedPreferences.getInstance()
                              .then((p) => p.setString('er_wheel_align', v));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 6.0, 12.0, 6.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(icons[v], size: 16.0, color: _ink2),
                              const SizedBox(width: 6.0),
                              Text('ย้ายมา${names[v]}',
                                  style: _t(12.0,
                                      color: _ink2, weight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ),
                    )),
                  ),
                // การ์ดไม่ positioned = Stack สูงเท่าการ์ด ghost จึงสูงเท่า sheet
                Align(
                  alignment: Alignment.bottomLeft,
                  heightFactor: 1.0,
                  child: AnimatedPadding(
                    duration: _sheetMove,
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(left: x0),
                    // กันแตะในการ์ดทะลุไปปิด sheet
                    child: GestureDetector(onTap: () {}, child: card),
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  /// เวลาเลื่อน sheet ไปตำแหน่งใหม่ (ghost เลื่อนตามช่วงเดียวกัน)
  static const _sheetMove = Duration(milliseconds: 420);

  /// ghost ใหม่ (ตรงที่ sheet เพิ่งออกไป) ค่อย ๆ โผล่หลัง sheet เลื่อนพ้น
  Widget _ghostIn(Widget child) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: _sheetMove,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
        builder: (_, v, c) => Opacity(
          opacity: v,
          child: Transform.scale(scale: 0.96 + 0.04 * v, child: c),
        ),
        child: child,
      );

  /// ปุ่มหัวการ์ด (แผงแคบ): tonal ฟ้าอ่อน สูง 40 มุม 10 แบบปุ่ม "ดูการส่งตรวจ"
  Widget _triIconBtn(IconData ic, String tip, VoidCallback onTap,
          {bool busy = false}) =>
      TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: _blue,
          backgroundColor: const Color(0xFFE8F0FE),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          minimumSize: const Size(0.0, 40.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        onPressed: busy ? null : onTap,
        icon: busy
            ? const SizedBox(
                width: 16.0,
                height: 16.0,
                child:
                    CircularProgressIndicator(strokeWidth: 2.0, color: _blue))
            : Icon(ic, size: 18.0),
        label: Text(busy ? 'กำลังอ่าน' : tip,
            style: _t(12.5, color: _blue, weight: FontWeight.w600)),
      );

  /// ปุ่มแคปซูลหัวการ์ด (ทึบ = หลัก · ขอบ = รอง)
  Widget _triPill(IconData ic, String t, VoidCallback onTap,
          {bool busy = false, bool primary = true}) =>
      _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: busy ? null : onTap,
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: primary ? _blue : _panel,
              borderRadius: BorderRadius.circular(100.0),
              border:
                  Border.all(color: primary ? _blue : const Color(0xFFDADCE0)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (busy)
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.0, color: primary ? Colors.white : _blue),
                )
              else
                Icon(ic, size: 18.0, color: primary ? Colors.white : _blue),
              const SizedBox(width: 6.0),
              Text(busy ? 'กำลังอ่าน' : t,
                  style: _t(12.5,
                      color: primary ? Colors.white : _blue,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// สแกนจอ monitor (OCR): ถ่ายรูป/เลือกรูป → AI อ่านตัวเลขบนจอ → เติมลงช่อง
  /// ส่งเฉพาะรูปจอ monitor (ไม่มีข้อมูลระบุตัวผู้ป่วย) · พยาบาลตรวจทานก่อนยืนยัน
  Future<void> _triVsScan() async {
    final src = await _placedSheet<ImageSource>(
      context: context,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: 520.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('สแกนจอ monitor',
                  style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              Text('ถ่ายให้เห็นตัวเลข HR BP SpO₂ RR ชัด ๆ ระบบจะอ่านค่าให้',
                  style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              const SizedBox(height: 14.0),
              _qOpt('ถ่ายรูปจอ', Icons.photo_camera_rounded, false,
                  () => Navigator.of(ctx).pop(ImageSource.camera),
                  h: 52.0),
              const SizedBox(height: 8.0),
              _qOpt('เลือกรูปจากเครื่อง', Icons.photo_library_rounded, false,
                  () => Navigator.of(ctx).pop(ImageSource.gallery),
                  h: 52.0),
            ],
          ),
        ),
      ),
    );
    if (src == null || !mounted) return;
    XFile? shot;
    try {
      shot = await ImagePicker()
          .pickImage(source: src, maxWidth: 1280, imageQuality: 80);
    } catch (_) {
      shot = null;
    }
    if (shot == null || !mounted) {
      if (src == ImageSource.camera && mounted) {
        _triToast('เปิดกล้องไม่ได้ ลองเลือกรูปจากเครื่อง');
      }
      return;
    }
    setState(() => _triOcrBusy = true);
    try {
      final text = await ErAi.vision(
          'This is a patient vital-sign monitor screen. '
          'Read the numbers and reply ONLY JSON: '
          '{"sbp":n,"dbp":n,"hr":n,"rr":n,"spo2":n,"bt":n}. '
          'Use null for values not shown. BP shown as SYS/DIA. '
          'Temperature in Celsius.',
          await shot.readAsBytes());
      final m = ErAi.extractJson(text) ?? const <String, dynamic>{};
      var n = 0;
      if (!mounted) return;
      setState(() {
        for (final k in const ['sbp', 'dbp', 'hr', 'rr', 'spo2', 'bt']) {
          final v = m[k];
          if (v is num) {
            _triCtl(k).text =
                v == v.roundToDouble() ? '${v.toInt()}' : v.toString();
            n++;
          }
        }
      });
      _triToast(n == 0
          ? 'อ่านตัวเลขจากรูปไม่ได้ ลองถ่ายใหม่ให้ชัดขึ้น'
          : 'อ่านจากจอแล้ว $n ช่อง ตรวจทานก่อนยืนยัน');
    } catch (_) {
      _triToast('ส่งรูปไปอ่านไม่สำเร็จ ลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _triOcrBusy = false);
    }
  }

  void _triToast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(t, style: _t(12.0, color: Colors.white))));
  }

  /// พูดสัญญาณชีพทั้งชุด → ถอดเสียง (หน้าต่างพูดของ workflow) → แยกตัวเลขลงช่อง
  Future<void> _triVsSpeak() async {
    final text = await _voiceTextDialog(
      title: 'พูดสัญญาณชีพ',
      initial: '',
      hint: 'เช่น ความดัน 120/80 ชีพจร 88 หายใจ 20 ออกซิเจน 98 '
          'อุณหภูมิ 37.5 GCS 15',
      okText: 'ใส่ค่า',
      autoMic: true,
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final got = _triVsParse(text);
    setState(() {
      for (final e in got.entries) {
        _triCtl(e.key).text = e.value;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            got.isEmpty
                ? 'ไม่พบตัวเลขสัญญาณชีพในคำพูด'
                : 'ใส่ค่าแล้ว ${got.length} ช่อง ตรวจทานก่อนยืนยัน',
            style: _t(12.0, color: Colors.white))));
  }

  /// แยกค่า V/S จากข้อความ: คำนำ (ไทย/อังกฤษ) ตามด้วยตัวเลข · BP รับ 120/80
  Map<String, String> _triVsParse(String raw) {
    final t = raw.toLowerCase().replaceAll(',', ' ');
    final out = <String, String>{};
    const numRe = r'(\d{1,3}(?:\.\d)?)';
    final bp = RegExp(
            r'(?:ความดัน|bp|บีพี|ความดันโลหิต)\D{0,6}(\d{2,3})\s*(?:/|ทับ|ส่วน|over)\s*(\d{2,3})')
        .firstMatch(t);
    if (bp != null) {
      out['sbp'] = bp.group(1)!;
      out['dbp'] = bp.group(2)!;
    }
    const words = {
      'hr': ['ชีพจร', 'หัวใจ', 'hr', 'pulse', 'พีอาร์', 'pr'],
      'rr': ['หายใจ', 'rr', 'อาร์อาร์'],
      'spo2': ['ออกซิเจน', 'ออกซิ', 'sat', 'spo2', 'โอทู', 'o2'],
      'bt': ['อุณหภูมิ', 'ไข้', 'temp', 'บีที', 'bt'],
      'gcs': ['gcs', 'จีซีเอส', 'ความรู้สึกตัว'],
      'sbp': ['sbp'],
      'dbp': ['dbp'],
    };
    for (final e in words.entries) {
      if (out.containsKey(e.key)) continue;
      for (final w in e.value) {
        final m = RegExp('${RegExp.escape(w)}\\D{0,8}$numRe').firstMatch(t);
        if (m != null) {
          out[e.key] = m.group(1)!;
          break;
        }
      }
    }
    return out;
  }

  /// สรุป V/S บรรทัดเดียว (หัว accordion ตอนย่อ)
  String _triVsSum() {
    String? f(String k) {
      final v = _triVal(k);
      if (v == null) return null;
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }

    return [
      if (f('sbp') != null) 'BP ${f('sbp')}/${f('dbp') ?? '-'}',
      if (f('hr') != null) 'HR ${f('hr')}',
      if (f('rr') != null) 'RR ${f('rr')}',
      if (f('spo2') != null) 'SpO₂ ${f('spo2')}%',
      if (f('bt') != null) 'T ${f('bt')}',
      if (f('gcs') != null) 'GCS ${f('gcs')}',
    ].join('  ');
  }

  /// ล้างค่าประเมินคัดกรอง (เปิดหน้าคัดกรอง/ลงทะเบียนใหม่)
  void _triReset({int? age}) {
    for (final c in _triIn.values) {
      c.clear();
    }
    _triBand = _triBandOf(age);
    _triPain = null;
    _triRisk.clear();
    _triAct.clear();
    _triPick = null;
    _triO2 = false;
    _triCopd = false;
    _triWaive.clear();
    _triType.clear();
    _triFt.clear();
    _triRed.clear();
    _triLkw = null;
    _triE = _triV = _triM = null;
    _triPupil.clear();
    _triLoc = null;
  }

  /// ประเภทหลักสำหรับรายชื่อ/ทางด่วน (enum เดิมมี 4 ชนิด)
  _Ptype? _triPtype() {
    if (_triType.contains('Sepsis')) {
      return _Ptype.sepsis;
    }
    if (_triType.contains('STEMI')) return _Ptype.stemi;
    if (_triType.contains('Stroke')) return _Ptype.stroke;
    if (_triType.contains('อุบัติเหตุ')) {
      return _Ptype.trauma;
    }
    return null;
  }

  /// NEWS ตามแบบประเมินสัญญาณชีพและ NEWS ของ รพ. (ประเมินในผู้ป่วยสงสัย Sepsis)
  /// คืน (คะแนนรวม, [(รายการ, คะแนน)]) · null = ยังไม่มีค่าใดเลย
  (int, List<(String, int)>)? _triNews() {
    final bt = _triVal('bt'), hr = _triVal('hr'), sbp = _triVal('sbp');
    final rr = _triVal('rr'), spo2 = _triVal('spo2'), gcs = _triVal('gcs');
    if ([bt, hr, sbp, rr, spo2].every((v) => v == null)) return null;
    final parts = <(String, int)>[
      if (bt != null)
        (
          'T',
          bt <= 35
              ? 3
              : bt <= 36
                  ? 1
                  : bt <= 38
                      ? 0
                      : bt <= 39
                          ? 1
                          : 2
        ),
      if (hr != null)
        (
          'HR',
          hr <= 40
              ? 3
              : hr <= 50
                  ? 1
                  : hr <= 90
                      ? 0
                      : hr <= 110
                          ? 1
                          : hr <= 130
                              ? 2
                              : 3
        ),
      if (sbp != null)
        (
          'SBP',
          sbp <= 90
              ? 3
              : sbp <= 100
                  ? 2
                  : sbp <= 110
                      ? 1
                      : sbp <= 219
                          ? 0
                          : 3
        ),
      if (rr != null)
        (
          'RR',
          rr <= 8
              ? 3
              : rr <= 11
                  ? 1
                  : rr <= 20
                      ? 0
                      : rr <= 24
                          ? 2
                          : 3
        ),
      if (spo2 != null)
        (
          _triCopd ? 'SpO₂ (COPD)' : 'SpO₂',
          !_triCopd
              ? (spo2 <= 91
                  ? 3
                  : spo2 <= 93
                      ? 2
                      : spo2 <= 95
                          ? 1
                          : 0)
              // แถว COPD: 88-92 หรือ ≥ 93 หายใจเอง = 0 · ให้ O2 แล้วยิ่งสูงยิ่งได้คะแนน
              : spo2 <= 83
                  ? 3
                  : spo2 <= 85
                      ? 2
                      : spo2 <= 87
                          ? 1
                          : spo2 <= 92 || !_triO2
                              ? 0
                              : spo2 <= 94
                                  ? 1
                                  : spo2 <= 96
                                      ? 2
                                      : 3
        ),
      ('O2', _triO2 ? 2 : 0),
      (
        'ความรู้สึกตัว',
        // CVPU = สับสนใหม่ / ตอบเสียง / ตอบเจ็บ / ไม่ตอบสนอง
        _triRisk.contains('ซึม สับสน') ||
                (gcs != null && gcs < 15) ||
                (_triLoc != null && _triLoc != 'ตื่นดี')
            ? 3
            : 0
      ),
    ];
    return (parts.fold(0, (a, p) => a + p.$2), parts);
  }

  /// เปิดหน้าคัดกรองของผู้ป่วยรายนี้ (ล้างค่าประเมินเดิม)
  /// คัดกรองผู้ป่วยในคิว: ใช้หน้าเดียวกับ "ส่งตรวจและคัดกรอง" (layout/ข้อมูลชุดเดียวกัน)
  /// เติมข้อมูลจากการลงทะเบียน/เคส แล้วเริ่มที่ คัดกรอง › อาการ
  void _openTriage(_P p) {
    final c = erCases[p.hn];
    final reg = _regSent[p.hn];
    _openQuickRegister();
    setState(() {
      _triReset(age: c?.age);
      _triP = p;
      _qIntro = false;
      _qFound = true;
      _qTab = 'คัดกรอง';
      _qSubOf['คัดกรอง'] = 'อาการ';
      _regHn = p.hn;
      // เวลามาถึง = ตอนเข้าคิว (เวลาที่รอจริง)
      _qAt = DateTime.now().subtract(Duration(minutes: p.waitMin));
      // แยกคำนำหน้าออกจากชื่อ
      const pre = ['นางสาว', 'นาง', 'นาย', 'ด.ช.', 'ด.ญ.'];
      final px = pre.where(p.name.startsWith).firstOrNull;
      if (px != null) _regPick['prefix'] = px;
      _regCtl('name').text =
          px == null ? p.name : p.name.substring(px.length).trim();
      _regPhoto = _faceUrl(p.hn);
      if (c != null) {
        _regSex = c.sex;
        _regDob = DateTime(DateTime.now().year - c.age, 1, 1);
      }
      _regAllergy
        ..clear()
        ..addAll(reg?.$3 ?? c?.allergies ?? const []);
      _qArrive = reg?.$1 ?? c?.arrival ?? _qArrive;
      _qCc
        ..clear()
        ..addAll(reg?.$2 ?? const []);
      if (_qCc.isEmpty && c != null) _regCtl('cc').text = c.cc;
    });
  }

  void _closeTriage() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _triP = null;
      _regOpen = false;
      _regQuick = false;
    });
  }

  /// ค่า V/S ที่เข้าเกณฑ์ dangerous zone ของกลุ่มอายุ (ว่าง = ปกติ)
  /// suffix '' = ค่าแรก · '2' = ค่าที่วัดซ้ำ
  List<String> _triDanger([String suffix = '']) {
    String n(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    final band = _triBands.where((b) => b.$1 == _triBand).firstOrNull;
    final hr = _triVal('hr$suffix'), rr = _triVal('rr$suffix');
    final spo2 = _triVal('spo2$suffix');
    return [
      if (band != null && hr != null && hr > band.$2)
        'ชีพจร ${n(hr)} > ${n(band.$2)}',
      if (band != null && rr != null && rr > band.$3)
        'หายใจ ${n(rr)} > ${n(band.$3)}',
      if (spo2 != null && spo2 < 92) 'SpO₂ ${n(spo2)}% < 92',
    ];
  }

  /// วัดซ้ำครบทุกค่าที่เกิน และกลับมาปกติทั้งหมด (ESI v5: reassess ก่อน uptriage)
  /// ทดสอบแล้ว: ติ๊กเฉย ๆ ลดผิด 15-18% จึงต้องกรอกค่าที่วัดซ้ำจริง
  bool _triRecheckOk() {
    final band = _triBands.where((b) => b.$1 == _triBand).firstOrNull;
    if (band == null) return false;
    final hr = _triVal('hr'), rr = _triVal('rr'), spo2 = _triVal('spo2');
    final hr2 = _triVal('hr2'), rr2 = _triVal('rr2'), sp2 = _triVal('spo22');
    if (hr != null && hr > band.$2 && (hr2 == null || hr2 > band.$2)) {
      return false;
    }
    if (rr != null && rr > band.$3 && (rr2 == null || rr2 > band.$3)) {
      return false;
    }
    if (spo2 != null && spo2 < 92 && (sp2 == null || sp2 < 92)) return false;
    return _triDanger().isNotEmpty;
  }

  /// เกณฑ์ red flag ที่ระบบติ๊กให้เองจากข้อมูลที่กรอก ('โรค:เกณฑ์')
  Set<String> _triRedAuto() {
    final gcs = _triVal('gcs');
    final news = _triNews()?.$1;
    return {
      if (gcs != null && gcs < 15) 'TBI:GCS < 15',
      if (news != null && news > 4) 'Sepsis:NEWS > 4',
      if (const ['ซึม', 'ซึมมาก'].contains(_triLoc) ||
          _triRisk.contains('ซึม สับสน'))
        'Sepsis:ซึม',
      if (_triDanger().isNotEmpty) 'Sepsis:V/S ผิดปกติ',
    };
  }

  /// โรคที่เข้า red flag: (โรค, เกณฑ์ที่พบ) · ต้องมีเกณฑ์ที่พยาบาลติ๊กเองอย่างน้อย 1 ข้อ
  /// (ไม่นับช่วงเวลา) ข้อที่ระบบติ๊กให้ใช้ประกอบ ไม่ยกระดับเองลำพัง
  List<(String, List<String>)> _triRedHits() {
    final auto = _triRedAuto();
    return [
      // นับเฉพาะกลุ่มที่เปิดแฟ้มอยู่ (ชิปเกณฑ์มีเฉพาะแฟ้มที่เปิด)
      for (final (g, items) in _triRedFlags)
        if (_triFt.containsKey(_ftIdOf(g)) &&
            items.any(
                (i) => !_triRedWindow.contains(i) && _triRed.contains('$g:$i')))
          (
            g,
            [
              for (final i in items)
                if (_triRed.contains('$g:$i') || auto.contains('$g:$i')) i
            ]
          ),
    ];
  }

  /// ไล่ตามบัตร MOPH ED Triage 2561:
  /// จะเสียชีวิต → เสี่ยง ซึม ปวด → นับกิจกรรม → ESI 3 + V/S ผิดปกติ = ESI 2
  /// คืน (ระดับ, เหตุผล) · ระดับ null = ข้อมูลยังไม่พอตัดสิน
  (int?, List<String>) _triAdvise() {
    String n(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    final sbp = _triVal('sbp'), dbp = _triVal('dbp'), rr = _triVal('rr');
    final spo2 = _triVal('spo2'), bt = _triVal('bt'), gcs = _triVal('gcs');
    final map = (sbp != null && dbp != null) ? (sbp + 2 * dbp) / 3 : null;

    // 1 จะเสียชีวิต ต้องช่วยทันที
    final life = <String>[
      for (final (t, _, lv) in _triTypeOpts)
        if (lv == 1 && _triType.contains(t)) t,
      for (final (o, _) in _triLifeOpts)
        if (_triRisk.contains(o)) o,
      if (gcs != null && gcs <= 8) 'GCS ${n(gcs)} ≤ 8',
      if (_triLoc == 'ไม่รู้สึกตัว') 'ความรู้สึกตัว: ไม่รู้สึกตัว',
      if (spo2 != null && spo2 < 90) 'SpO₂ ${n(spo2)}% < 90',
      if (sbp != null && sbp < 90) 'Shock: SBP ${n(sbp)} < 90',
      if (map != null && map < 60 && !(sbp != null && sbp < 90))
        'Shock: MAP ${map.round()} < 60',
      if (rr != null && rr <= 6) 'หายใจ ${n(rr)} ครั้ง/นาที',
    ];
    if (life.isNotEmpty) return (1, life);

    // 2 เสี่ยง ซึม ปวด
    final risk = <String>[
      for (final (t, _, lv) in _triTypeOpts)
        if (lv == 2 && _triType.contains(t)) 'Fast track $t',
      // เปิด Fast track Stroke/STEMI/Sepsis = อย่างน้อย ESI 2
      for (final id in _triFt.keys)
        if (_ftEsi2.contains(id))
          'Fast track ${erFastTrackById(id)?.name ?? id}',
      for (final (g, f) in _triRedHits()) 'Red flag $g: ${f.join(', ')}',
      for (final (o, _) in _triRiskOpts)
        if (_triRisk.contains(o)) o,
      if (gcs != null && gcs >= 9 && gcs <= 12) 'GCS ${n(gcs)} (9-12)',
      if (const ['สับสน', 'ซึม', 'ซึมมาก'].contains(_triLoc))
        'ความรู้สึกตัว: $_triLoc',
      if ((_triPain ?? 0) >= 7 && !_triWaive.contains('pain'))
        'Pain score $_triPain ≥ 7',
      if (_triBand == '< 3 เดือน' && bt != null && bt > 38)
        'อายุ < 3 เดือน ไข้ ${n(bt)} °C > 38',
      if (_triBand == '< 3 เดือน' && bt != null && bt < 36)
        'อายุ < 3 เดือน ตัวเย็น ${n(bt)} °C < 36',
    ];
    if (risk.isNotEmpty) return (2, risk);

    // 3 ประเมินแนวโน้มการใช้ทรัพยากร
    final acts = _triAct.where((a) => a != 'ไม่มี').toList();
    final nAct = acts.length + (acts.contains('หัตถการใหญ่') ? 1 : 0);
    final kidFever = _triBand == '3 เดือน-3 ปี' && bt != null && bt > 39;
    if (nAct > 1 || kidFever) {
      final why = [
        if (nAct > 1) 'มีมากกว่า 1 กิจกรรม: ${acts.join(', ')}',
        if (kidFever) 'อายุ 3 เดือน-3 ปี ไข้ ${n(bt)} °C > 39',
      ];
      // ESI 3 + V/S ผิดปกติ → ESI 2
      final danger = _triDanger();
      if (danger.isNotEmpty && !_triRecheckOk()) {
        return (2, ['ESI 3 + V/S dangerous zone', ...danger, ...why]);
      }
      return (
        3,
        [
          ...why,
          if (danger.isNotEmpty) 'วัด V/S ซ้ำแล้วกลับมาปกติ',
        ]
      );
    }
    if (nAct == 1) return (4, ['มี 1 กิจกรรม: ${acts.first}']);
    if (_triAct.contains('ไม่มี')) return (5, ['ไม่มีกิจกรรม']);
    return (null, const []);
  }

  /// ส่งค่า V/S ที่กรอกตอนคัดกรองไปเป็นรอบล่าสุดของผู้ป่วย (หน้าผู้ป่วยเห็นทันที)
  /// ค่าที่ไม่ได้วัด ใช้ค่าล่าสุดเดิมของเคส · ไม่กรอกเลย = ไม่เพิ่มรอบ
  void _triVsCommit(String hn) {
    const keys = ['hr', 'sbp', 'dbp', 'spo2', 'rr', 'bt'];
    if (keys.every((k) => _triVal(k) == null)) return;
    final c = erCases[hn] == null ? null : erCaseOf(hn);
    double v(String k, List<double>? old) =>
        _triVal(k) ?? (old == null || old.isEmpty ? 0.0 : old.last);
    erVsAdd(
        hn,
        _qClock(_triVsAt ?? DateTime.now()),
        v('hr', c?.hr),
        v('sbp', c?.sbp),
        v('dbp', c?.dbp),
        v('spo2', c?.spo2),
        v('rr', c?.rr),
        v('bt', c?.bt));
  }

  void _triSend(int level) {
    final p = _triP!;
    _triVsCommit(p.hn);
    final i = _patients.indexWhere((x) => x.hn == p.hn);
    final cc = _regSent[p.hn]?.$2 ?? const [];
    _triLogAdd(p.hn, p.esi?.level, level, _triAdvise().$2.join(', '));
    final done = _P(p.hn, p.name, _Stage.waitDoctor, 0,
        esi: _Esi.values[level - 1],
        bed: p.bed,
        type: _triPtype() ?? p.type,
        note: cc.isEmpty ? p.note : cc.join(', '));
    if (i >= 0) {
      _patients[i] = done;
    } else {
      _patients.insert(0, done);
    }
    // fast track ที่เปิดในหน้านี้ไปติดตามต่อในหน้าผู้ป่วย (ไม่เปิด = ไม่มีแฟ้ม)
    _ftOpened[p.hn] = Map.of(_triFt);
    _ftCriteria[p.hn] = _triFtCriteria();
    ErFeedback.confirm();
    _closeTriage();
    setState(() => _open = _Phase.of(_Stage.waitDoctor));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'คัดกรอง ${p.name} เป็น ESI $level แล้ว ส่ง${_triZoneOf(level).$1} ${_triZoneOf(level).$2}',
            style: _t(12.0, color: Colors.white))));
  }

  /// การ์ด ESI ใต้คำอธิบายหน้าคัดกรอง: ระดับที่ระบบแนะนำ อัปเดตทันทีที่กรอก
  /// แตะเพื่อไปแท็บย่อย "ระดับ ESI" ดูเหตุผลและยืนยัน
  Widget _triEsiDock() {
    final (sug, why) = _triAdvise();
    final level = _triPick ?? sug;
    final esi = level == null ? null : _Esi.values[level - 1];
    // สีสายรัด: ระดับ ESI · ยังไม่มีระดับ = สายเทา
    final tone = esi?.color ?? const Color(0xFFBDC1C6);
    // ตัวอักษรสีระดับบนป้ายขาว: ESI 3 (ส้ม) เข้มขึ้นให้อ่านผ่าน AA
    final ink = esi?.level == 3 ? Color.lerp(tone, Colors.black, 0.45)! : tone;
    // บรรทัด Fast track: เปิดแล้วก่อน ไม่มีค่อยดูที่ระบบแนะนำ
    final ftWhy = _triFt.isEmpty ? _triFtWhy() : const <String, String>{};
    String nm(String id) => erFastTrackById(id)?.name ?? id;
    final (String, Color)? ft = _triFt.isNotEmpty
        ? (
            '${_triFt.keys.map(nm).join(', ')}  เปิดเมื่อ ${_taskClock(_triFt.values.reduce((a, b) => a.isBefore(b) ? a : b))} นาฬิกาเดินแล้ว',
            _ftRed
          )
        : ftWhy.isNotEmpty
            ? (
                'แนะนำ ${nm(ftWhy.keys.first)} จาก${ftWhy.values.first}',
                const Color(0xFFB06000)
              )
            : null;

    // การ์ดขาวขอบสีระดับ: เลขระดับ + ชื่อ + ที่มา | เหตุผล
    final label = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 18.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: (esi?.color ?? _g5).withValues(alpha: 0.5)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              // เลขระดับในกล่องสี ESI เปลี่ยนแบบเลื่อนจางเมื่อระดับเปลี่ยน
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 48.0,
                height: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: esi == null ? _panelSoft : esi.color,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(
                          scale: Tween(begin: 0.6, end: 1.0).animate(a),
                          child: c)),
                  child: Text(level == null ? '?' : '$level',
                      key: ValueKey(level),
                      style: _num(22.0,
                          color: esi == null ? _ink3 : Colors.white,
                          weight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          esi == null
                              ? 'ESI ยังประเมินไม่ได้'
                              : 'ESI $level ${esi.en}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(15.0,
                              color: esi == null ? _ink2 : esi.color,
                              weight: FontWeight.w700)),
                      Text(
                          esi == null
                              ? 'กรอกอาการ สัญญาณชีพ และกิจกรรมที่ต้องทำ'
                              : _triPick != null
                                  ? 'เลือกโดยพยาบาล'
                                  : 'แนะนำโดยระบบ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
              if (level != null) ...[
                const SizedBox(width: 10.0),
                // แบนเนอร์แคบ: เหตุผลหดก่อน ชื่อระดับไม่โดนบีบ
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200.0),
                    child: Text(
                        why.isEmpty
                            ? 'พยาบาลเลือกระดับเอง'
                            : why.length == 1
                                ? why.first
                                : '${why.first} และอีก ${why.length - 1} ข้อ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(width: 4.0),
              const Icon(Icons.chevron_right_rounded, size: 22.0, color: _ink3),
            ]),
            // Fast track ในป้ายเดียวกัน: เปิดแล้ว (แดง) หรือแนะนำ (ส้ม)
            // เคสทั่วไปไม่มีบรรทัดนี้ · แตะ = ไปการ์ด Fast track
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: ft == null
                  ? const SizedBox(width: double.infinity)
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _triGoFt,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(children: [
                          const Divider(height: 1.0, color: Color(0xFFE8EAED)),
                          const SizedBox(height: 8.0),
                          Row(children: [
                            Icon(Icons.bolt_rounded, size: 18.0, color: ft.$2),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(ft.$1,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(13.0,
                                      color: ft.$2, weight: FontWeight.w600)),
                            ),
                            Text(_triFt.isEmpty ? 'ไปเปิดแฟ้ม' : 'ดูแฟ้ม',
                                style: _t(12.5,
                                    color: _blue, weight: FontWeight.w600)),
                            const SizedBox(width: 26.0),
                          ]),
                        ]),
                      ),
                    ),
            ),
          ]),
    );

    return _Press(
      radius: 8.0,
      child: GestureDetector(
        onTap: () => setState(() => _qSubOf['คัดกรอง'] = 'ระดับ ESI'),
        child: label,
      ),
    );
  }

  /// ไปการ์ด Fast track (แท็บย่อยอาการ) แล้วเลื่อนให้เห็น
  void _triGoFt() {
    HapticFeedback.selectionClick();
    setState(() => _qSubOf['คัดกรอง'] = 'อาการ');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _triFtKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          alignment: 0.05);
    });
  }

  // ------------------------------------------------------------ หน้า
  Widget _triagePage() {
    final p = _triP!;
    final c = erCases[p.hn];
    final reg = _regSent[p.hn];
    final (sug, why) = _triAdvise();
    final level = _triPick ?? sug;

    return Material(
      color: _qFlat ? _panel : _panelSoft,
      child: Column(children: [
        _triHeader(p, c, reg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(width: 300.0, child: _triInfoPanel(p, c, reg)),
              const SizedBox(width: 12.0),
              Expanded(child: _triAssessPanel()),
              const SizedBox(width: 12.0),
              SizedBox(width: 300.0, child: _triEsiPanel(sug, why, level)),
            ]),
          ),
        ),
      ]),
    );
  }

  /// header แบบโปรไฟล์ผู้ป่วย + เวลารอคัดกรอง (เป้า 10 นาที)
  Widget _triHeader(
      _P p, ErCase? c, (String, List<String>, List<String>)? reg) {
    final meta = [
      if (c != null) '${c.age} ปี',
      if (c != null) c.sex,
      'HN ${p.hn}',
    ];
    final late = p.waitMin > 10;
    return Container(
      height: 58.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(children: [
        _topIcon(Icons.arrow_back_rounded, false, _closeTriage),
        const SizedBox(width: 12.0),
        Container(
          width: 38.0,
          height: 38.0,
          decoration:
              const BoxDecoration(color: _panelSoft, shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: c != null
              ? Image.asset(_faceUrl(p.hn), fit: BoxFit.cover)
              : const Icon(Icons.person_rounded, size: 22.0, color: _ink3),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5, color: _inkTitle, weight: FontWeight.w600)),
              Text(meta.join('   '),
                  style: _t(10.5, color: _ink2, weight: FontWeight.w500)),
            ],
          ),
        ),
        Text('คัดกรอง',
            style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
        const Expanded(child: SizedBox()),
        // เวลารอคัดกรอง: เกิน 10 นาทีเป็นสีแดง
        Container(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: late ? _red.withValues(alpha: 0.08) : _panelSoft,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.timer_outlined, size: 18.0, color: late ? _red : _ink2),
            const SizedBox(width: 6.0),
            Text('รอคัดกรอง ${_hm(p.waitMin)}',
                style: _t(12.5,
                    color: late ? _red : _inkTitle, weight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ------------------------------------------------------------ ซ้าย
  Widget _triInfoPanel(
      _P p, ErCase? c, (String, List<String>, List<String>)? reg) {
    final cc = reg != null
        ? (reg.$2.isEmpty ? 'ยังไม่ระบุ' : reg.$2.join(', '))
        : (c?.cc ?? (p.note.isEmpty ? 'ยังไม่ระบุ' : p.note));
    final arrive = reg?.$1 ?? c?.arrival ?? '-';
    final allergy = reg?.$3 ?? c?.allergies ?? const <String>[];
    final under = c?.underlying ?? const <String>[];
    Widget row(IconData ic, String k, String v, {bool bad = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(ic, size: 18.0, color: bad ? _red : _ink3),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k,
                      style: _t(11.0,
                          color: bad ? _red : _ink3, weight: FontWeight.w500)),
                  const SizedBox(height: 2.0),
                  Text(v,
                      style: _t(14.0,
                          color: bad ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                ],
              ),
            ),
          ]),
        );
    return _qPanel([
      _qCard(
        'ข้อมูลจากการลงทะเบียน',
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          row(Icons.monitor_heart_outlined, 'อาการสำคัญ', cc),
          row(Icons.accessible_rounded, 'สภาพ', arrive),
          row(
              Icons.warning_rounded,
              'แพ้ยา',
              allergy.isEmpty
                  ? 'ไม่มีประวัติ'
                  : allergy.join(', ').toUpperCase(),
              bad: allergy.isNotEmpty),
          row(Icons.medical_information_outlined, 'โรคประจำตัว',
              under.isEmpty ? 'ไม่มีประวัติ' : under.join(', ')),
        ]),
      ),
      _triLogCard(p.hn),
    ]);
  }

  // ------------------------------------------------------------ กลาง
  /// บันทึกประวัติการคัดแยก (เวลาจัดความเร่งด่วนเสร็จ = เวลาของรายการแรก)
  void _triLogAdd(String hn, int? from, int to, String why) {
    final log = _triLog.putIfAbsent(hn, () => []);
    log.add((
      DateTime.now(),
      from,
      to,
      log.isEmpty ? 'คัดแยกครั้งแรก' : 'คัดแยกซ้ำ',
      why,
      ErSession.instance.user?.name ?? '-',
    ));
  }

  /// ตารางประวัติการคัดแยก (แบบ HOSxP): เวลา ระดับเดิม → ใหม่ ครั้ง เหตุผล ผู้บันทึก
  Widget _triLogCard(String hn) {
    final log = _triLog[hn] ?? const [];
    String hm(DateTime t) => _clock(
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
    return _qCard(
      'ประวัติการคัดแยก',
      count: log.isEmpty ? 'ยังไม่เคยคัดแยก' : '${log.length} ครั้ง',
      log.isEmpty
          ? Text('คัดแยกครั้งแรกจะถูกบันทึกเมื่อยืนยัน ESI',
              style: _t(11.5, color: _ink3, weight: FontWeight.w500))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final (t, from, to, kind, why, by) in log.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(hm(t),
                            style: _num(12.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(width: 8.0),
                        Text(from == null ? 'ESI $to' : 'ESI $from → $to',
                            style: _t(12.0,
                                color: _Esi.values[to - 1].color,
                                weight: FontWeight.w700)),
                        const Spacer(),
                        Text(kind,
                            style: _t(10.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                      if (why.isNotEmpty)
                        Text(why,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(11.0,
                                color: _ink2, weight: FontWeight.w500)),
                      Text('บันทึกโดย $by',
                          style:
                              _t(10.5, color: _ink3, weight: FontWeight.w500)),
                    ],
                  ),
                ),
            ]),
    );
  }

  /// ข้อมูลรับเข้าห้องฉุกเฉิน: เวลารับเข้า สภาพ ประเภท แผนก + ธง (UCEP ซ้ำ คดี DOA)
  Widget _qAdmitCard() {
    const subs = {
      'เป็นการรักษาด่วน (UCEP)': 'เข้าเกณฑ์เจ็บป่วยวิกฤต ใช้สิทธิ UCEP',
      'กลับมารักษาซ้ำ': 'กลับมาด้วยอาการเดิมภายใน 48 ชั่วโมง',
      'ผู้ป่วยคดี': 'ต้องเก็บหลักฐาน แจ้งตำรวจ',
      'เสียชีวิตก่อนมาถึง รพ.': 'Dead on arrival',
    };
    return _qCard(
      'การรับเข้าห้องฉุกเฉิน',
      count: 'ข้อมูลประกอบการรับบริการ',
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // แผนก: มีอยู่แล้วจาก backend (ผูกกับจุดบริการ) = แถวอ่านอย่างเดียว
        _qRow('แผนก', _qDeptName, src: 'ตามจุดบริการที่ลงชื่อเข้าใช้'),
        // ตัวเลือกเปิด/ปิด = แถวสวิตช์
        for (var i = 0; i < _qFlagOpts.length; i++)
          _qSwitchRow(
              _qFlagOpts[i].$1,
              subs[_qFlagOpts[i].$1] ?? '',
              _qFlags.contains(_qFlagOpts[i].$1),
              (v) => setState(() => v
                  ? _qFlags.add(_qFlagOpts[i].$1)
                  : _qFlags.remove(_qFlagOpts[i].$1)),
              last: i == _qFlagOpts.length - 1),
      ]),
    );
  }

  // ------------------------------------------------ รูปแบบแสดงข้อมูลแบบ Google settings
  // ข้อมูลที่มีอยู่แล้ว = แถวอ่านอย่างเดียว (ชื่อช่องเทาซ้าย | ค่า | ✎ แก้)
  // ข้อมูลที่ต้องกรอก = ช่องกรอก/ตัวเลือก · ประกาศสำคัญ = banner ไอคอน + ข้อความ
  // ตัวเลือกเปิด/ปิด = แถวสวิตช์

  /// แถวข้อมูลอ่านอย่างเดียว · onEdit = แตะทั้งแถวเพื่อแก้ (มี ✎) · src = ที่มาของข้อมูล
  Widget _qRow(String k, String v,
      {VoidCallback? onEdit,
      bool bad = false,
      String? src,
      bool last = false}) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 180.0,
          child:
              Text(k, style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.isEmpty ? '-' : v,
                  style: _t(14.0,
                      color: bad ? _red : (v.isEmpty ? _ink3 : _inkTitle),
                      weight: FontWeight.w500)),
              if (src != null)
                Text(src,
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
            ],
          ),
        ),
        if (onEdit != null)
          const Icon(Icons.edit_outlined, size: 18.0, color: _blue),
      ]),
    );
    if (onEdit == null) return row;
    return _Press(
      scale: 0.99,
      radius: 4.0,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: onEdit, child: row),
    );
  }

  /// banner แบบ Google (AdSense): พื้นสีอ่อนเรียบ ไม่มีขอบ ไอคอนวงกลมซ้าย
  /// หัวข้อ + คำอธิบาย · ปุ่มข้อความ (text button) ชิดขวา
  Widget _qBanner(IconData ic, String text, Color tone,
      {String? sub, String? action, VoidCallback? onAction}) {
    final isRed = tone == _red;
    final bg = isRed ? const Color(0xFFFCE8E6) : const Color(0xFFE8F0FE);
    final fg = isRed ? const Color(0xFFC5221F) : const Color(0xFF1967D2);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(children: [
        Container(
          width: 36.0,
          height: 36.0,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(ic, size: 20.0, color: fg),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: _t(14.0,
                      color: const Color(0xFF202124), weight: FontWeight.w600)),
              if (sub != null) ...[
                const SizedBox(height: 2.0),
                Text(sub,
                    style: _t(13.0,
                        color: const Color(0xFF5F6368),
                        weight: FontWeight.w500)),
              ],
            ],
          ),
        ),
        if (action != null)
          _Press(
            radius: 4.0,
            child: GestureDetector(
              onTap: onAction,
              child: Container(
                constraints: const BoxConstraints(minHeight: 40.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.center,
                child: Text(action,
                    style: _t(14.0, color: fg, weight: FontWeight.w600)),
              ),
            ),
          ),
      ]),
    );
  }

  /// แถวสวิตช์ (เปิด/ปิด) แบบหน้าตั้งค่า: ชื่อ + คำอธิบาย | Switch
  Widget _qSwitchRow(String k, String sub, bool on, ValueChanged<bool> set,
          {bool last = false}) =>
      _Press(
        scale: 0.99,
        radius: 4.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            set(!on);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 56.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              border: last
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k,
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w500)),
                    Text(sub,
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ],
                ),
              ),
              Switch(
                value: on,
                activeThumbColor: Colors.white,
                activeTrackColor: _blue,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  set(v);
                },
              ),
            ]),
          ),
        ),
      );

  /// แถวเลือกค่า: การ์ดแสดงค่า แตะแล้วเปิด bottom sheet (แบบหน้าคัดกรองเดิม)
  Widget _qPick(String k, IconData ic, String? v, List<String> opts,
      ValueChanged<String> on) {
    // key ตามชื่อช่อง ให้ปุ่ม "ไปที่ช่องที่ยังว่าง" เลื่อนมาหาได้
    const keyOf = {
      'อาชีพ': 'job',
      'หมู่เลือด': 'blood',
      'เชื้อชาติ': 'ethnic',
      'สัญชาติ': 'nation',
      'ศาสนา': 'religion',
      'สถานภาพ': 'marital',
    };
    return KeyedSubtree(
      key: _qFieldKeys.putIfAbsent(keyOf[k] ?? 'pick:$k', GlobalKey.new),
      child: _qPickBody(k, ic, v, opts, on),
    );
  }

  /// bottom sheet เลือกค่าจากรายการ (ใช้ทั้งช่องเลือกและแถวเลือก)
  void _qSheetPick(
      String k, String? v, List<String> opts, ValueChanged<String> on) {
    HapticFeedback.selectionClick();
    _placedSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: _line,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(k,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(height: 8.0),
                for (final o in opts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: _qOpt(o, null, o == v, () {
                      on(o);
                      Navigator.of(ctx).pop();
                    }, h: 52.0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _qPickBody(String k, IconData ic, String? v, List<String> opts,
      ValueChanged<String> on) {
    return _Press(
      child: GestureDetector(
        onTap: () => _qSheetPick(k, v, opts, on),
        // ช่องเลือกแบบ outlined ของ Google: ขอบเทาบาง พื้นขาว
        child: Container(
          constraints: const BoxConstraints(minHeight: 52.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child: Row(children: [
            Icon(ic, size: 18.0, color: _ink2),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(k,
                      style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
                  Text(v ?? 'เลือก',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(13.0,
                          color: v == null ? _ink3 : _inkTitle,
                          weight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 20.0, color: _ink3),
          ]),
        ),
      ),
    );
  }

  /// grid คอลัมน์เท่ากัน
  Widget _qGrid(int cols, List<Widget> kids, {double gap = 8.0}) =>
      LayoutBuilder(builder: (context, bc) {
        final w = (bc.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final k in kids) SizedBox(width: w, child: k),
        ]);
      });

  /// การเข้าห้องฉุกเฉิน: วันที่ เวลา เวร + สภาพผู้ป่วย (หน้าคัดกรองเดิม ส่วนแรก)
  Widget _qVisitInCard(Widget arrive) {
    final hhmm =
        '${_qAt.hour.toString().padLeft(2, '0')}:${_qAt.minute.toString().padLeft(2, '0')}';
    return _qCard(
      'การเข้าห้องฉุกเฉิน',
      sum: '${_thDate(_qAt)} ${_clock(hhmm)}  ${_qShift ?? ''}  $_qArrive',
      done: _qShift != null,
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // วันเวลา เวร: ระบบเติมให้แล้ว = แถวอ่าน แตะเพื่อแก้
        _qRow('วันที่เข้าห้องฉุกเฉิน', _thDate(_qAt), onEdit: () async {
          final d = await showDatePicker(
              context: context,
              initialDate: _qAt,
              firstDate: DateTime.now().subtract(const Duration(days: 7)),
              lastDate: DateTime.now());
          if (d != null) {
            setState(() => _qAt =
                DateTime(d.year, d.month, d.day, _qAt.hour, _qAt.minute));
          }
        }),
        _qRow('เวลาที่เข้าห้องฉุกเฉิน', _clock(hhmm), onEdit: () async {
          final t = await showTimePicker(
              context: context, initialTime: TimeOfDay.fromDateTime(_qAt));
          if (t != null) {
            setState(() => _qAt =
                DateTime(_qAt.year, _qAt.month, _qAt.day, t.hour, t.minute));
          }
        }),
        _qRow('เวร', _qShift ?? '', onEdit: () {
          final i = _qShifts.indexOf(_qShift ?? '');
          setState(() => _qShift = _qShifts[(i + 1) % _qShifts.length]);
        }, src: 'ตามเวลาปัจจุบัน แตะเพื่อเปลี่ยน', last: true),
        const SizedBox(height: 16.0),
        Text('สภาพผู้ป่วย',
            style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
        const SizedBox(height: 6.0),
        arrive,
      ]),
    );
  }

  /// ข้อมูลการมา: ประเภทการมา มาจากหน่วยบริการ (เฉพาะส่งต่อ) ผู้นำส่ง
  Widget _qArrivalCard() {
    final refer = _qArrType == 'ส่งต่อจากสถานพยาบาลอื่นๆ';
    return _qCard(
      'ข้อมูลการมา',
      sum: [_qArrType, if (refer) _qFrom, _qBringer]
          .whereType<String>()
          .join('  '),
      done: _qArrType != null && _qBringer != null,
      _qGrid(refer ? 3 : 2, [
        _qPick(
            'ประเภทการมา',
            Icons.directions_run_rounded,
            _qArrType,
            _qArrTypes,
            (v) => setState(() {
                  _qArrType = v;
                  // เติมผู้นำส่งตามประเภทการมา (แก้ทีหลังได้)
                  final by = switch (v) {
                    'มาเอง' => 'มาเอง',
                    'ส่งตัวโดย BLS' => 'หน่วยกู้ชีพ ระดับพื้นฐาน (BLS)',
                    'ส่งตัวโดย ILS' => 'หน่วยกู้ชีพ ระดับกลาง (ILS)',
                    'ส่งตัวโดย ALS' => 'หน่วยกู้ชีพ ระดับสูง (ALS)',
                    'ส่งต่อจากสถานพยาบาลอื่นๆ' => 'รถพยาบาลโรงพยาบาลต้นทาง',
                    _ => null,
                  };
                  if (by != null) _qBringer = by;
                })),
        if (refer)
          _qPick('มาจากหน่วยบริการ', Icons.local_hospital_rounded, _qFrom,
              _qFroms, (v) => setState(() => _qFrom = v)),
        _qPick('ผู้นำส่ง', Icons.person_pin_rounded, _qBringer, _qBringers,
            (v) => setState(() => _qBringer = v)),
      ]),
    );
  }

  /// ความรู้สึกตัว + GCS (E V M → คะแนนลงช่อง GCS) + รูม่านตา ซ้าย/ขวา
  Widget _triNeuroCard() {
    int? sc(String? s) => s == null ? null : int.tryParse(s.substring(1, 2));
    final e = _triE == 'C-ตาบวมปิด' ? null : sc(_triE);
    final v = sc(_triV), m = sc(_triM);
    void syncGcs() {
      final ee = _triE == 'C-ตาบวมปิด' ? null : sc(_triE);
      final vv = sc(_triV), mm = sc(_triM);
      // คะแนนรวมมาจาก E V M เท่านั้น เลือกไม่ครบ = ยังไม่มีค่า
      _triCtl('gcs').text =
          ee != null && vv != null && mm != null ? '${ee + vv + mm}' : '';
    }

    String pupil(String side) {
      final s = _triPupil[side], r = _triPupil['${side}r'];
      if (s == null && r == null) return '-';
      return '${s == null ? '-' : '$s mm'} ${r ?? ''}'.trim();
    }

    final gcsText = e != null && v != null && m != null
        ? 'GCS ${e + v + m} (E$e V$v M$m)'
        : null;
    return KeyedSubtree(
      key: _qFieldKeys.putIfAbsent('gcs:card', GlobalKey.new),
      child: _qCard(
        'ความรู้สึกตัว GCS และรูม่านตา',
        sum: [
          if (_triLoc != null) _triLoc!,
          if (gcsText != null) gcsText,
          if (_triPupil.isNotEmpty) 'รูม่านตา L ${pupil('L')} R ${pupil('R')}',
        ].join('  '),
        done: _triLoc != null && gcsText != null,
        count: gcsText,
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ความรู้สึกตัว',
              style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
          const SizedBox(height: 6.0),
          _qGrid(
              5,
              [
                for (final o in _triLocOpts)
                  _qOpt(o, null, _triLoc == o,
                      () => setState(() => _triLoc = _triLoc == o ? null : o),
                      h: 44.0),
              ],
              gap: 6.0),
          const SizedBox(height: 12.0),
          // GCS แบบภาพ: แตะการ์ดภาพของแต่ละข้อ คะแนนรวมขึ้นทันที
          _gcsTotal(e, v, m),
          const SizedBox(height: 12.0),
          _gcsRow(
              'การลืมตา',
              'E',
              _triEOpts,
              _triE,
              (x) => setState(() {
                    _triE = _triE == x ? null : x;
                    syncGcs();
                  })),
          const SizedBox(height: 10.0),
          _gcsRow(
              'การตอบสนองทางวาจา',
              'V',
              _triVOpts,
              _triV,
              (x) => setState(() {
                    _triV = _triV == x ? null : x;
                    syncGcs();
                  })),
          const SizedBox(height: 10.0),
          _gcsRow(
              'การตอบสนองทางการเคลื่อนไหว',
              'M',
              _triMOpts,
              _triM,
              (x) => setState(() {
                    _triM = _triM == x ? null : x;
                    syncGcs();
                  })),
          const SizedBox(height: 16.0),
          Text('รูม่านตา (Pupils)',
              style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
          const SizedBox(height: 6.0),
          // วงกลมขนาดจริงตามมิลลิเมตร แบบแผ่นวัดรูม่านตา
          // ตาขวาของผู้ป่วยอยู่ซ้ายจอ (มองหน้าผู้ป่วย)
          // ฉาก 3D + แผงเลือกตาขวา (ซ้ายจอ) / ตาซ้าย (ขวาจอ) ลอยในฉาก
          _pupilFace(),
          // รูม่านตาไม่เท่ากัน ≥ 1 มม.: banner แดงแบบเดียวกับแพ้ยา
          if (_triPupil['R'] != null &&
              _triPupil['L'] != null &&
              (double.parse(_triPupil['R']!) - double.parse(_triPupil['L']!))
                      .abs() >=
                  1) ...[
            const SizedBox(height: 10.0),
            _qBanner(
                Icons.warning_rounded,
                'รูม่านตาไม่เท่ากัน ขวา ${_triPupil['R']} มม. ซ้าย ${_triPupil['L']} มม.',
                _red,
                sub:
                    'Anisocoria ต่างกันตั้งแต่ 1 มม. ประเมินระบบประสาทซ้ำและแจ้งแพทย์'),
          ],
        ]),
      ),
    );
  }

  // ---------------------------------------------------------- GCS แบบภาพ
  /// ป้ายสั้นใต้ภาพของแต่ละตัวเลือก (ตามลำดับใน _triEOpts/_triVOpts/_triMOpts)
  static const Map<String, List<String>> _gcsShort = {
    // คำตามแผ่นประเมิน GCS มาตรฐาน
    'E': [
      'ลืมตาเอง',
      'ลืมตาเมื่อเรียก',
      'ลืมตาเมื่อเจ็บ',
      'ไม่ลืมตา',
      'ตาบวมปิด'
    ],
    'V': [
      'พูดคุยรู้เรื่อง',
      'พูดสับสน',
      'พูดเป็นคำ ๆ',
      'ส่งเสียงไม่เป็นคำ',
      'ไม่ออกเสียง'
    ],
    'M': [
      'ทำตามคำสั่งได้',
      'ระบุตำแหน่งเจ็บ',
      'ถอนหนีความเจ็บ',
      'เกร็งงอผิดปกติ',
      'เกร็งเหยียด',
      'ไม่ตอบสนอง'
    ],
  };

  /// คะแนนรวมตัวใหญ่ + แถบระดับ (13–15 เล็กน้อย · 9–12 ปานกลาง · ≤ 8 รุนแรง)
  Widget _gcsTotal(int? e, int? v, int? m) {
    final full = e != null && v != null && m != null;
    final sum = full ? e + v + m : null;
    final (lv, tone) = sum == null
        ? ('เลือกให้ครบ E V M', _ink3)
        : sum <= 8
            ? ('Severe ต้องดูแลทางเดินหายใจ', _red)
            : sum <= 12
                ? ('Moderate', const Color(0xFFDC8610))
                : ('Mild', _inkTitle);
    String part(String k, int? x) => '$k${x ?? '-'}';
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(12.0),
      ),
      // แผงแคบ (workflow): คะแนนบรรทัดบน · ระดับ + แถบบรรทัดล่าง ไม่ล้นขวา
      child: LayoutBuilder(builder: (context, box) {
        final score = Row(mainAxisSize: MainAxisSize.min, children: [
          Text('GCS', style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
          const SizedBox(width: 10.0),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(
                    scale: Tween(begin: 0.8, end: 1.0).animate(a), child: c)),
            child: Text(sum == null ? '–' : '$sum',
                key: ValueKey(sum),
                style: _num(30.0, color: tone, weight: FontWeight.w700)),
          ),
          Text(' /15', style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(width: 14.0),
          Text('${part('E', e)}  ${part('V', v)}  ${part('M', m)}',
              style: _num(14.0, color: _ink2, weight: FontWeight.w600)),
        ]);
        final level = [
          Flexible(
            child: Text(lv,
                maxLines: 2,
                style: _t(13.0, color: tone, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 12.0),
          // แถบ 3–15 แบ่งสามช่วง จุดบอกตำแหน่งคะแนน
          SizedBox(
            width: 120.0,
            height: 14.0,
            child: CustomPaint(painter: _GcsBarPainter(sum)),
          ),
        ];
        if (box.maxWidth < 560.0) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                score,
                const SizedBox(height: 6.0),
                Row(children: level),
              ]);
        }
        return Row(children: [score, const Spacer(), ...level]);
      }),
    );
  }

  /// หนึ่งข้อของ GCS: ป้ายซ้าย + การ์ดภาพเรียงจากดีสุดไปแย่สุด
  Widget _gcsRow(String name, String key, List<String> opts, String? cur,
      ValueChanged<String> on) {
    final short = _TriagePagePart._gcsShort[key]!;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 96.0,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // อักษรแรกตัวใหญ่ (E V M) ต่อด้วยส่วนที่เหลือของคำทันที
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: key,
                    style:
                        _num(22.0, color: _inkTitle, weight: FontWeight.w700)),
                TextSpan(
                    text: const {
                      'E': 'ye opening',
                      'V': 'erbal response',
                      'M': 'otor response',
                    }[key]!,
                    style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
              ]),
            ),
            Text(name, style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
          ]),
        ),
      ),
      Expanded(
        child: Row(children: [
          for (var i = 0; i < opts.length; i++) ...[
            if (i > 0) const SizedBox(width: 6.0),
            Expanded(
              child: _gcsTile(key, i, opts[i], short[i], cur == opts[i], () {
                HapticFeedback.selectionClick();
                on(opts[i]);
              }),
            ),
          ],
        ]),
      ),
    ]);
  }

  Widget _gcsTile(
      String key, int i, String opt, String label, bool on, VoidCallback tap) {
    // คะแนนจากตัวเลือก (E4, V5, M6) · C = ตาบวมปิด
    final score = opt.startsWith('C') ? 'C' : opt.substring(1, 2);
    return _Press(
      radius: 10.0,
      child: GestureDetector(
        onTap: tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 132.0,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: on ? const Color(0xFFE8F0FE) : const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(12.0),
          ),
          // ขอบวาดทับด้านบนสุด (ภาพ/เบลอไม่กลบขอบ) · เลือกแล้ว = ขอบน้ำเงินหนา
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: on ? _blue : Colors.black.withValues(alpha: 0.06),
                width: on ? 2.5 : 1.0),
          ),
          child: Stack(children: [
            // พื้นหลังภาพ (ภาพทุกแถวเต็มการ์ด)
            Positioned.fill(
                child: ColoredBox(
                    color: on
                        ? const Color(0xFFD2E3FC)
                        : const Color(0xFFE9EDF1))),
            // M: ภาพท่าจากหุ่น 3D ตัวเดียวกับหน้าผู้ป่วย (จัดท่าแขนแล้วเรนเดอร์ flat)
            // V: หน้าด้านข้างจากหุ่น 3D (อ้าปาก / ปิดปากหลับตา) + กล่องคำพูดทับด้านขวา
            if (key == 'V') ...[
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                top: 0.0,
                child: Image.asset(
                    'assets/images/er_gcs_v_${i == 4 ? 'silent' : 'talk'}.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(-1.0, -0.3)),
              ),
              Positioned.fill(
                  child: CustomPaint(painter: _GcsPicPainter('Vb', i, on))),
            ],
            // E: ภาพใกล้ตาจากหุ่น 3D (ลืม / หลับ / บวมปิด) เต็มแถบล่าง
            if (key == 'E')
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                top: 0.0,
                child: Image.asset(
                    'assets/images/er_gcs_${const [
                      'e4',
                      'e3',
                      'e2',
                      'e_closed',
                      'e_swollen'
                    ][i]}.png',
                    fit: BoxFit.cover,
                    // ตาชิดซ้ายบน จมูกขวาล่าง (เห็นว่าเป็นหน้าคน)
                    alignment: const Alignment(-0.45, -0.1)),
              ),
            if (key == 'M')
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                top: 0.0,
                child: Opacity(
                  opacity: i == 5 ? 0.45 : 1.0,
                  // M4–M1 นอนบนเตียง: ใกล้ครึ่งบน เห็นหัว อก แขน
                  child: Image.asset('assets/images/er_gcs_m${6 - i}.png',
                      fit: BoxFit.cover,
                      alignment: i >= 2
                          ? const Alignment(-0.3, -1.0)
                          // M6 มือชูนิ้วโป้งอยู่ขวา: เลื่อนกรอบให้เห็นทั้งหน้าและมือ
                          : i == 0
                              ? const Alignment(0.55, -1.0)
                              : Alignment.topCenter),
                ),
              ),
            // M3 M2: สายฟ้า 3D = เกร็ง (แบบภาพ GCS มาตรฐาน)
            if (key == 'M' && (i == 3 || i == 4))
              Positioned(
                left: 8.0,
                top: 8.0,
                width: 30.0,
                height: 30.0,
                child: Image.asset('assets/images/er_gcs_bolt.png'),
              ),
            // E3: ขีดเสียงเรียก 3D กระจายจากขวาเข้าหาหน้า
            if (key == 'E' && i == 1)
              Positioned(
                right: 6.0,
                top: 14.0,
                width: 26.0,
                height: 44.0,
                child: Image.asset('assets/images/er_gcs_call.png'),
              ),
            // เบลอไล่ระดับด้านล่าง bake ไว้ในไฟล์ภาพแล้ว (ไม่ใช้ BackdropFilter: แพงมากเมื่อมี 16 การ์ด)
            // ไล่สีพื้นจากใสไปทึบ ให้ตัวอักษรอ่านชัด
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              height: 64.0,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.55, 1.0],
                      colors: [
                        (on ? const Color(0xFFE8F0FE) : _panel)
                            .withValues(alpha: 0.0),
                        (on ? const Color(0xFFE8F0FE) : _panel)
                            .withValues(alpha: 0.6),
                        (on ? const Color(0xFFE8F0FE) : _panel)
                            .withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10.0,
              right: 8.0,
              bottom: 8.0,
              child: Row(children: [
                Text(score,
                    style: _num(20.0,
                        color: on ? _blue : _inkTitle,
                        weight: FontWeight.w700)),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.5,
                          color: on ? _blue : _ink2, weight: FontWeight.w600)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// ใบหน้าเดียว สองตา: ตาขวาของผู้ป่วยอยู่ซ้ายจอ (มองหน้าผู้ป่วย)
  /// ลากซ้าย/ขวาบนตาข้างไหน = ปรับขนาดรูม่านตาข้างนั้น
  Widget _pupilFace() {
    double? mmOf(String side) =>
        _triPupil[side] == null ? null : double.parse(_triPupil[side]!);

    return LayoutBuilder(builder: (context, bc) {
      return GestureDetector(
        child: Container(
          height: 320.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          // ใบหน้าจากหุ่น 3D ตัวเดียวกับหน้ารายละเอียดผู้ป่วย
          child: Stack(children: [
            Positioned.fill(
              child: ErFace3D(
                  key: const ValueKey('face3d-v13'),
                  mmR: mmOf('R'),
                  mmL: mmOf('L'),
                  female: _regSex == 'หญิง'),
            ),
            // แผงกระชับ จัดกึ่งกลางแนวตั้ง เว้นขอบ 16
            Positioned(
                left: 16.0,
                top: 0.0,
                bottom: 0.0,
                child: Center(child: _pupilPanel('R', 'ตาขวา'))),
            Positioned(
                right: 16.0,
                top: 0.0,
                bottom: 0.0,
                child: Center(child: _pupilPanel('L', 'ตาซ้าย'))),
          ]),
        ),
      );
    });
  }

  /// แผงเลือกรูม่านตาหนึ่งข้าง ลอยในฉาก 3D (กระชับ ไม่เต็มความสูง):
  /// หัวแผง = ชื่อ + ค่าปัจจุบัน + ปุ่มคัดลอกจากอีกข้าง · ขนาด 1–8 (4×2) · ปฏิกิริยาแบบ segmented
  Widget _pupilPanel(String side, String name) {
    final size = _triPupil[side], react = _triPupil['${side}r'];
    final other = side == 'R' ? 'L' : 'R';
    void tap(VoidCallback f) {
      HapticFeedback.selectionClick();
      setState(f);
    }

    Widget sizeBtn(String v) {
      final on = size == v;
      return _Press(
        radius: 10.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              tap(() => on ? _triPupil.remove(side) : _triPupil[side] = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 54.0,
            decoration: BoxDecoration(
              color: on ? _blue : _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
            ),
            // จุดรูม่านตาตามมิลลิเมตร + ตัวเลขด้านล่าง อ่านเทียบกันง่าย
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 18.0,
                child: Center(
                  child: Container(
                    width: 2.0 + double.parse(v) * 2.0,
                    height: 2.0 + double.parse(v) * 2.0,
                    decoration: BoxDecoration(
                        color: on ? Colors.white : const Color(0xFF1B1310),
                        shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(height: 3.0),
              Text(v,
                  style: _num(13.0,
                      color: on ? Colors.white : _inkTitle,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      );
    }

    return Container(
      width: 236.0,
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16.0,
              offset: const Offset(0.0, 4.0)),
        ],
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w600)),
                      Text(
                          size == null && react == null
                              ? 'ยังไม่ประเมิน'
                              : [
                                  if (size != null) '$size mm',
                                  if (react != null) react
                                ].join('  '),
                          style: size == null && react == null
                              ? _t(14.0, color: _ink3, weight: FontWeight.w500)
                              : _num(16.0,
                                  color: _blue, weight: FontWeight.w700)),
                    ]),
              ),
              // คัดลอกค่าจากอีกข้าง (ส่วนใหญ่สองข้างเท่ากัน)
              if (_triPupil[other] != null)
                Tooltip(
                  message: 'เท่า${other == 'R' ? 'ตาขวา' : 'ตาซ้าย'}',
                  child: _Press(
                    radius: 18.0,
                    child: GestureDetector(
                      onTap: () => tap(() {
                        _triPupil[side] = _triPupil[other]!;
                        final r = _triPupil['${other}r'];
                        if (r != null) _triPupil['${side}r'] = r;
                      }),
                      child: Container(
                        height: 36.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.sync_alt_rounded,
                              size: 16.0, color: _blue),
                          const SizedBox(width: 4.0),
                          Text('เท่า${other == 'R' ? 'ขวา' : 'ซ้าย'}',
                              style: _t(12.0,
                                  color: _blue, weight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
              child: Text('ขนาดรูม่านตา (มม.)',
                  style: _t(11.5, color: _ink3, weight: FontWeight.w600)),
            ),
            _qGrid(4, [for (final v in _triPupilSizes) sizeBtn(v)], gap: 6.0),
            const SizedBox(height: 10.0),
            // ปฏิกิริยาต่อแสง: segmented control แถวเดียว
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
              child: Text('ปฏิกิริยาต่อแสง',
                  style: _t(11.5, color: _ink3, weight: FontWeight.w600)),
            ),
            Container(
              height: 40.0,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(children: [
                for (final r in _triPupilReacts)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => tap(() => react == r
                          ? _triPupil.remove('${side}r')
                          : _triPupil['${side}r'] = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: react == r ? _panel : _panelSoft,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: react == r
                              ? [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4.0,
                                      offset: const Offset(0.0, 1.0)),
                                ]
                              : null,
                        ),
                        child: Text(r,
                            style: _t(12.5,
                                color: react == r ? _blue : _ink2,
                                weight: react == r
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    ),
                  ),
              ]),
            ),
          ]),
    );
  }

  /// การ์ดประเภทผู้ป่วย (อยู่บนสุดของส่วนคัดกรอง/หน้าลงทะเบียน)
  Widget _triTypeCard() {
    // คำอธิบายสั้นใต้ชื่อ (แบบการ์ดตัวเลือก onboarding)
    const desc = {
      'อุบัติเหตุ': 'บาดเจ็บ (Trauma)',
      'ฉุกเฉิน': 'เจ็บป่วยฉุกเฉิน',
      'ตรวจโรคทั่วไป': 'ไม่ฉุกเฉิน',
      'Stroke': 'อ่อนแรงครึ่งซีก พูดไม่ชัด',
      'STEMI': 'เจ็บหน้าอกจากหัวใจ',
      'Sepsis': 'สงสัยติดเชื้อในกระแสเลือด',
    };
    Widget tile(String t, IconData ic, int? lv) {
      final on = _triType.contains(t);
      // fast track = แดง · กลุ่มทั่วไป = กรมท่า
      final tone = lv == null ? _blue : _red;
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => on ? _triType.remove(t) : _triType.add(t));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 104.0,
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
            // แบบ Google: เลือกแล้ว = พื้นอ่อน ขอบสี ไม่ทึบ
            decoration: BoxDecoration(
              color: on ? tone.withValues(alpha: 0.08) : _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: on ? tone : const Color(0xFFDADCE0),
                  width: on ? 1.5 : 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(ic, size: 24.0, color: tone),
                  const Spacer(),
                  if (on)
                    Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        color: tone,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 15.0, color: Colors.white),
                    ),
                ]),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(t,
                      maxLines: 1,
                      style: _t(16.0,
                          color: on ? tone : _inkTitle,
                          weight: FontWeight.w700)),
                ),
                const SizedBox(height: 2.0),
                Text(desc[t] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return _qCard(
      'ประเภทผู้ป่วย',
      sum: _triType.join(', '),
      done: _triType.isNotEmpty,
      count: 'เลือกได้หลายอย่าง',
      _qGrid(3, [for (final (t, ic, lv) in _triTypeOpts) tile(t, ic, lv)],
          gap: 10.0),
    );
  }

  Widget _triAssessPanel() => _qPanel([_triTypeCard(), ..._triAssessCards()]);

  /// การ์ดประเมินคัดกรอง (ใช้ทั้งหน้าคัดกรองและหน้าลงทะเบียน)
  List<Widget> _triAssessCards() {
    // GCS ไม่ต้องกรอก: คำนวณจาก E V M ทุกครั้ง (เลือกไม่ครบ / ตาบวมปิด = ว่าง)
    int? sc(String? x) =>
        x == null || x.startsWith('C') ? null : int.tryParse(x.substring(1, 2));
    final ge = sc(_triE), gv = sc(_triV), gm = sc(_triM);
    _triCtl('gcs').text =
        ge != null && gv != null && gm != null ? '${ge + gv + gm}' : '';
    final band = _triBands.where((b) => b.$1 == _triBand).firstOrNull;
    // ค่าผิดปกติ (แดง): เกณฑ์จากบัตร ED Triage
    // ค่าวัดซ้ำ (hr2, rr2, spo22) ใช้เกณฑ์เดียวกับค่าแรก
    bool bad(String key, double v) => switch (const {
              'hr2': 'hr',
              'rr2': 'rr',
              'spo22': 'spo2',
            }[key] ??
            key) {
          'sbp' => v < 90,
          'hr' => band != null && v > band.$2,
          'rr' => v <= 6 || (band != null && v > band.$3),
          'spo2' => v < 92,
          'bt' => v > 38,
          'gcs' => v <= 12,
          'dtx' => v < 70,
          _ => false,
        };
    // ช่องกรอกตัวเลข (outlined) ใช้ทั้งแถวและกล่องวัดซ้ำ
    // เปิด wheel เลือกค่า (กำหนดหลังตาราง range ด้านล่าง)
    late final void Function(String) openWheel;
    Widget vsInput(String k, String unit, bool red,
        {double width = 132.0, String hint = '-'}) {
      final node = _triFocus.putIfAbsent(k, FocusNode.new);
      return SizedBox(
        width: width,
        height: 44.0,
        child: TextField(
          controller: _triCtl(k),
          focusNode: node,
          // เลือกค่าด้วย wheel เท่านั้น
          readOnly: true,
          showCursor: false,
          onTap: () => openWheel(k),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // ตัวเลขไม่เกิน 3 หลัก ทศนิยม 1 ตำแหน่ง
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d?)?')),
          ],
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.right,
          // ตัวเลข placeholder และหน่วยอยู่กึ่งกลางแนวตั้งของช่องเดียวกัน
          textAlignVertical: TextAlignVertical.center,
          expands: true,
          maxLines: null,
          onChanged: (_) => setState(() {}),
          style: _num(18.0,
              color: red ? _red : _inkTitle, weight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintMaxLines: 1,
            // ขนาด/ความสูงบรรทัดเท่าตัวเลขที่พิมพ์ ไม่งั้น placeholder ตกลงล่าง
            hintStyle: _num(18.0, color: _g5, weight: FontWeight.w500)
                .copyWith(fontSize: 14.0, height: 18.0 / 14.0),
            // หน่วยแสดงตลอด (suffixText ซ่อนตอนช่องว่าง)
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 14.0),
              child: Align(
                widthFactor: 1.0,
                child: Text(unit,
                    style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0.0),
            filled: true,
            fillColor: red ? _red.withValues(alpha: 0.05) : _panel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: red ? _red : const Color(0xFFDADCE0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: red ? _red : _blue, width: 2.0)),
          ),
        ),
      );
    }

    // ช่วงค่าที่เป็นไปได้ทางสรีระ: นอกช่วง = น่าจะพิมพ์ผิด (ไม่ใช่ค่าผิดปกติ)
    const range = {
      'sbp': (40.0, 300.0),
      'dbp': (20.0, 200.0),
      'hr': (20.0, 250.0),
      'rr': (4.0, 80.0),
      'bt': (30.0, 43.0),
      'spo2': (50.0, 100.0),
      'gcs': (3.0, 15.0),
      'dtx': (10.0, 800.0),
      'wt': (0.5, 300.0),
      'ht': (30.0, 250.0),
      'waist': (30.0, 200.0),
      'head': (25.0, 70.0),
    };
    String fmt(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toString();
    openWheel = (String k) {
      if (!_wheelAlignLoaded) {
        _wheelAlignLoaded = true;
        SharedPreferences.getInstance().then((p) {
          final v = p.getString('er_wheel_align');
          final seen = p.getBool('er_wheel_drag_seen') ?? false;
          if (mounted) {
            setState(() {
              if (v != null) _wheelAlign = v;
              _wheelDragSeen = seen;
            });
          }
        });
      }
      // ค่าที่วัดคู่กัน เลือกใน sheet เดียว: BP ตัวบน/ตัวล่าง · น้ำหนัก/ส่วนสูง
      final keys = switch (k) {
        'sbp' || 'dbp' => const ['sbp', 'dbp'],
        'wt' || 'ht' => const ['wt', 'ht'],
        _ => [k],
      };
      // ลำดับกรอก: น้ำหนัก/ส่วนสูง → BP → HR → RR → BT → SpO₂
      const order = ['wt', 'sbp', 'hr', 'rr', 'bt', 'spo2'];
      final at = order.indexOf(keys.first);
// ถัดไป = ค่าแรกหลังจากนี้ที่ยังว่าง (กรอกแล้ว/ดึงจาก visit ก่อน = ข้าม) · ไม่เหลือ = เสร็จ
      bool empty(String o) => switch (o) {
            'sbp' => _triVal('sbp') == null || _triVal('dbp') == null,
            'wt' => _triVal('wt') == null || _triVal('ht') == null,
            _ => _triVal(o) == null,
          };
      final String? next =
          at < 0 ? null : order.skip(at + 1).where(empty).firstOrNull;
      String baseOf(String x) =>
          x.endsWith('2') && x != 'spo2' ? x.substring(0, x.length - 1) : x;
      // จุดเริ่ม wheel: ค่าที่กรอกแล้ว > ค่าจาก visit ล่าสุด > ค่ากลางของช่วงปกติ
      final last = _qLastWt;
      double start(String x) =>
          _triVal(x) ??
          switch (baseOf(x)) {
            'wt' => last?.$1 ?? 60.0,
            'ht' => last?.$2 ?? 165.0,
            'sbp' => 120.0,
            'dbp' => 80.0,
            'hr' => 80.0,
            'rr' => 18.0,
            'bt' => 36.8,
            'spo2' => 98.0,
            'dtx' => 100.0,
            'waist' => 80.0,
            'head' => 55.0,
            _ => 0.0,
          };
      const colName = {
        'sbp': 'ตัวบน',
        'dbp': 'ตัวล่าง',
        'wt': 'น้ำหนัก',
        'ht': 'ส่วนสูง',
      };
      const units = {
        'sbp': 'mmHg',
        'dbp': 'mmHg',
        'hr': 'bpm',
        'rr': '/min',
        'bt': '°C',
        'spo2': '%',
        'dtx': 'mg/dL',
        'waist': 'cm',
        'head': 'cm',
        'wt': 'kg',
        'ht': 'cm',
      };
      void put(String x, double v) {
        _triCtl(x).text = fmt(double.parse(v.toStringAsFixed(1)));
        setState(() {});
      }

      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        // สูงตามเนื้อหา (ค่าเริ่มต้นจำกัด 9/16 จอ ทำให้ปุ่มล้นบน iPad mini)
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
          Widget wheel(int count, int initial, String Function(int) label,
                  bool Function(int) hot, ValueChanged<int> on,
                  {double? width}) =>
              SizedBox(
                width: width,
                height: 220.0,
                child: ListWheelScrollView.useDelegate(
                  controller: FixedExtentScrollController(initialItem: initial),
                  itemExtent: 44.0,
                  diameterRatio: 1.8,
                  perspective: 0.004,
                  useMagnifier: true,
                  magnification: 1.18,
                  overAndUnderCenterOpacity: 0.35,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.selectionClick();
                    on(i);
                    setS(() {});
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: count,
                    builder: (_, i) => Center(
                      child: Text(label(i),
                          style: _num(24.0,
                              color: hot(i) ? _red : _inkTitle,
                              weight: FontWeight.w700)),
                    ),
                  ),
                ),
              );

          Widget column(String x) {
            final base = baseOf(x);
            final (lo, hi) = range[base]!;
            final v = _triVal(x) ?? start(x);
            final mn = lo.ceil(), mx = hi.floor();
            final whole = v.floor().clamp(mn, mx);
            final cols = <Widget>[
              Expanded(
                  flex: 2,
                  child: wheel(mx - mn + 1, whole - mn, (i) => '${mn + i}',
                      (i) => bad(base, (mn + i).toDouble()), (i) {
                    final d = base == 'bt'
                        ? (_triVal(x) ?? v) - (_triVal(x) ?? v).floor()
                        : 0.0;
                    put(x, mn + i + d);
                  })),
              // BT มีทศนิยม 1 ตำแหน่ง: wheel ที่สอง
              if (base == 'bt') ...[
                Text('.',
                    style:
                        _num(24.0, color: _inkTitle, weight: FontWeight.w700)),
                Expanded(
                    child: wheel(
                  10,
                  ((v - v.floor()) * 10).round().clamp(0, 9),
                  (i) => '$i',
                  (i) => bad(base, (_triVal(x) ?? v).floor() + i / 10),
                  (i) => put(x, (_triVal(x) ?? v).floor() + i / 10),
                )),
              ],
            ];
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                  '${colName[base] ?? (_triVsEn[base] ?? base)}  ${units[base] ?? ''}',
                  style: _t(12.5, color: _ink2, weight: FontWeight.w600)),
              const SizedBox(height: 6.0),
              Row(children: cols),
            ]);
          }

          // ตำแหน่ง sheet ซ้าย/กลาง/ขวา (ถนัดมือ) จำค่าในเครื่อง
          Alignment at(String v) => switch (v) {
                'left' => Alignment.bottomLeft,
                'right' => Alignment.bottomRight,
                _ => Alignment.bottomCenter,
              };
          // ตำแหน่งอื่นแสดงเป็นกรอบ ghost ในพื้นที่ว่างข้าง sheet (ไม่ทับ sheet)
          // แตะ ghost = ย้าย sheet ไปตำแหน่งนั้น (จำในเครื่อง)
          final sw = MediaQuery.sizeOf(ctx).width;
          final w = math.min(520.0, sw - 24.0);
          const order = ['left', 'center', 'right'];
          final x0 = switch (_wheelAlign) {
            'left' => 12.0,
            'right' => sw - 12.0 - w,
            _ => (sw - w) / 2,
          };
          final cur = order.indexOf(_wheelAlign);
          final leftSide = order.sublist(0, cur),
              rightSide = order.sublist(cur + 1);
          // แบ่งพื้นที่ว่างแต่ละฝั่งให้ ghost เท่า ๆ กัน
          List<(String, double, double)> slots(
              List<String> vs, double from, double to) {
            if (vs.isEmpty || to - from < 120.0) return const [];
            final gw = (to - from - 12.0 * (vs.length - 1)) / vs.length;
            return [
              for (final (n, v) in vs.indexed) (v, from + n * (gw + 12.0), gw)
            ];
          }

          final ghosts = [
            ...slots(leftSide, 12.0, x0 - 12.0),
            ...slots(rightSide, x0 + w + 12.0, sw - 12.0),
          ];
          const names = {'left': 'ซ้าย', 'center': 'กลาง', 'right': 'ขวา'};
          const icons = {
            'left': Icons.align_horizontal_left_rounded,
            'center': Icons.align_horizontal_center_rounded,
            'right': Icons.align_horizontal_right_rounded,
          };
          return Stack(children: [
            for (final (v, gx, gw) in ghosts)
              AnimatedPositioned(
                key: ValueKey('ghost-$v'),
                duration: _sheetMove,
                curve: Curves.easeOutCubic,
                left: gx,
                width: gw,
                top: 0.0,
                bottom: 12.0,
                child: _ghostIn(_Press(
                  radius: 20.0,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _wheelAlign = v);
                      setS(() {});
                      SharedPreferences.getInstance()
                          .then((p) => p.setString('er_wheel_align', v));
                    },
                    // เบา ๆ: กรอบเส้นจาง + ชิปเล็กตรงกลาง (ไม่แย่งสายตาจาก sheet)
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 6.0, 12.0, 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icons[v], size: 16.0, color: _ink2),
                          const SizedBox(width: 6.0),
                          Text('ย้ายมา${names[v]}',
                              style: _t(12.0,
                                  color: _ink2, weight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                )),
              ),
            AnimatedAlign(
                duration: _sheetMove,
                curve: Curves.easeOutCubic,
                heightFactor: 1.0,
                alignment: at(_wheelAlign),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520.0),
                  margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        // ชื่อค่า + ชื่อไทยจาง ๆ ต่อท้าย
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: keys.length > 1 && keys.first == 'sbp'
                                  ? 'BP'
                                  : keys.length > 1
                                      ? 'น้ำหนัก / ส่วนสูง'
                                      : (_triVsEn[baseOf(k)] ?? k),
                              style: _t(17.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          // ชื่อไทยซ้ำชื่อหลัก (รอบเอว เส้นรอบศีรษะ) ไม่ต่อท้าย
                          if (!const {'wt', 'waist', 'head'}.contains(
                              keys.first))
                            TextSpan(
                                text:
                                    '  ${_triVsFields.firstWhere((f) => f.$1 == baseOf(keys.first)).$2}',
                                style: _t(13.0,
                                    color: _ink3, weight: FontWeight.w500)),
                        ])),
                        const Spacer(),
                      ]),
                      const SizedBox(height: 8.0),
                      Stack(alignment: Alignment.center, children: [
                        // แถบเลือกกลาง wheel
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          top: 24.0 + 110.0 - 22.0,
                          height: 44.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _panelSoft,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final (n, x) in keys.indexed) ...[
                                if (n > 0)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 24.0, 16.0, 0.0),
                                    child: Text(keys.first == 'sbp' ? '/' : '',
                                        style: _num(26.0,
                                            color: _ink3,
                                            weight: FontWeight.w500)),
                                  ),
                                Expanded(child: column(x)),
                              ],
                            ]),
                      ]),
                      const SizedBox(height: 12.0),
                      Row(children: [
                        // ไม่ได้วัดค่านี้: ล้างค่า แล้วไปค่าถัดไป
                        Expanded(
                          child: SizedBox(
                            height: 48.0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFDADCE0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                              onPressed: () {
                                for (final x in keys) {
                                  _triCtl(x).clear();
                                }
                                setState(() {});
                                Navigator.pop(ctx);
                                if (next != null) {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => openWheel(next));
                                }
                              },
                              child: Text('ข้าม ไม่ได้วัด',
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
                              // ยังไม่เลื่อน = ใช้ค่าที่ wheel แสดงอยู่ · แล้วเปิดค่าถัดไปต่อเลย
                              onPressed: () {
                                for (final x in keys) {
                                  if (_triVal(x) == null) put(x, start(x));
                                }
                                Navigator.pop(ctx);
                                if (next != null) {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => openWheel(next));
                                }
                              },
                              child: Text(
                                  next == null
                                      ? 'เสร็จ'
                                      : 'ถัดไป  ${_triVsEn[next] ?? next}',
                                  style: _t(15.0,
                                      color: Colors.white,
                                      weight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                )),
          ]);
        }),
      );
    };
    // ข้อความเตือนของแถว (null = ถูกต้อง)
    String? invalid(String k) {
      final ks = k == 'sbp' ? ['sbp', 'dbp'] : [k];
      for (final x in ks) {
        final v = _triVal(x);
        final r = range[x];
        if (_triCtl(x).text.trim().isNotEmpty && v == null)
          return 'ตัวเลขไม่ถูกต้อง';
        if (v != null && r != null && (v < r.$1 || v > r.$2)) {
          return 'ค่าที่เป็นไปได้ ${fmt(r.$1)}–${fmt(r.$2)}';
        }
      }
      final sb = _triVal('sbp'), db = _triVal('dbp');
      if (k == 'sbp' && sb != null && db != null && db >= sb) {
        return 'ตัวล่างต้องน้อยกว่าตัวบน';
      }
      return null;
    }

    // ค่าปกติเป็น placeholder จาง ๆ ในช่อง (ไม่มีข้อความใต้ชื่อ ให้หน้าโล่ง)
    // เกณฑ์อันตรายใช้เตือนสีแดงในช่อง
    String normal(String k) => switch (k) {
          'sbp' => '90–139',
          'dbp' => '60–89',
          'hr' => band == null ? '-' : '≤ ${band.$2.toInt()}',
          'rr' => band == null ? '-' : '≤ ${band.$3.toInt()}',
          'spo2' => '≥ 92',
          'bt' => '36.5–37.5',
          'gcs' => '15',
          'dtx' => '70–140',
          _ => '-',
        };

    // แถวเดียว: ชื่อ + ค่าปกติซ้าย | ช่องกรอกขวาสุด (แบบหน้าตั้งค่า)
    Widget vsBox((String, String, String) f, {bool last = false}) {
      final (k, label, unit) = f;
      final v = _triVal(k);
      final red = v != null && bad(k, v);
      final base =
          k.endsWith('2') && k != 'spo2' ? k.substring(0, k.length - 1) : k;
      final hint = normal(k == 'spo22' ? 'spo2' : base);
      return Container(
        key: _qFieldKeys.putIfAbsent('vs:$k', GlobalKey.new),
        constraints: const BoxConstraints(minHeight: 52.0),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: _triVsEn[base] ?? label,
                      style: _t(14.0,
                          color: red ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  // ช่องไม่บังคับ: ป้ายจางต่อท้าย
                  if (base == 'dtx')
                    TextSpan(
                        text: '  ถ้ามี',
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                ])),
                if (invalid(base) case final err?)
                  Text(err,
                      style: _t(11.5, color: _red, weight: FontWeight.w500)),
                // ค่าตรงกับ visit ล่าสุด (เติมให้อัตโนมัติ): บอกที่มา
                if (_qLastWt
                    case (final double w, final double h, final DateTime d)
                    when base == 'wt' &&
                        _triVal('wt') == w &&
                        _triVal('ht') == h)
                  Text(
                      'จาก visit ล่าสุด ${d.day} ${_FeaturesRegisterRegisterPagePart._thMonths[d.month - 1]} ${(d.year + 543) % 100}',
                      style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
                // น้ำหนัก ส่วนสูง: ดึงค่าจาก visit ล่าสุดใน HOSxP (แตะเพื่อใช้)
                if (_qLastWt
                    case (final double w, final double h, final DateTime d)
                    when base == 'wt' &&
                        (_triVal('wt') != w || _triVal('ht') != h))
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _Press(
                      radius: 100.0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _triCtl('wt').text = w.toStringAsFixed(0);
                            _triCtl('ht').text = h.toStringAsFixed(0);
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 4.0, 10.0, 4.0),
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.history_rounded,
                                size: 14.0, color: _blue),
                            const SizedBox(width: 4.0),
                            Flexible(
                              child: Text(
                                  '${w.toStringAsFixed(0)} kg ${h.toStringAsFixed(0)} cm '
                                  '(${d.day} ${_FeaturesRegisterRegisterPagePart._thMonths[d.month - 1]} ${(d.year + 543) % 100})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(11.5,
                                      color: _blue, weight: FontWeight.w600)),
                            )
                          ]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // BP: ตัวบน / ตัวล่าง ในแถวเดียว (แบบใบกระดาษ)
          if (k == 'sbp') ...[
            vsInput('sbp', '', red, width: 92.0, hint: normal('sbp')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text('/',
                  style: _num(20.0, color: _ink3, weight: FontWeight.w500)),
            ),
            vsInput('dbp', unit,
                _triVal('dbp') != null && bad('dbp', _triVal('dbp')!),
                width: 128.0, hint: normal('dbp')),
          ] else if (k == 'gcs')
            // ไม่ต้องกรอก: คำนวณจากการ์ด GCS ด้านล่าง แตะเพื่อเลื่อนไปเลือก
            _Press(
              radius: 8.0,
              child: GestureDetector(
                onTap: () {
                  final c = _qFieldKeys['gcs:card']?.currentContext;
                  if (c != null) {
                    Scrollable.ensureVisible(c,
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutCubic);
                  }
                },
                child: Container(
                  width: 132.0,
                  height: 44.0,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: red ? _red.withValues(alpha: 0.05) : _panelSoft,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                          _triVal('gcs') == null
                              ? 'เลือก E V M'
                              : fmt(_triVal('gcs')!),
                          textAlign: TextAlign.right,
                          style: _triVal('gcs') == null
                              ? _t(12.0, color: _ink3, weight: FontWeight.w500)
                              : _num(18.0,
                                  color: red ? _red : _inkTitle,
                                  weight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8.0),
                    Text(unit,
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
                ),
              ),
            )
          else
            vsInput(k, unit, red, hint: hint),
        ]),
      );
    }

    Widget grid(int cols, List<Widget> kids,
            {double gap = 8.0, double? runGap}) =>
        LayoutBuilder(builder: (context, bc) {
          final w = (bc.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(spacing: gap, runSpacing: runGap ?? gap, children: [
            for (final k in kids) SizedBox(width: w, child: k),
          ]);
        });

    // การ์ด V/S หนึ่งค่า: ชื่อ + ไอคอนมุมขวา, ค่าใหญ่, ช่วงปกติ | เส้นคั่น | ลิงก์กรอกค่า
    // แตะทั้งการ์ด = เปิด wheel · สลับพิมพ์เองแล้วค่าเป็นช่องกรอก
    Widget vsCard(String k) {
      const icons = {
        'sbp': Icons.speed_rounded,
        'hr': Icons.monitor_heart_rounded,
        'rr': Icons.air_rounded,
        'bt': Icons.thermostat_rounded,
        'spo2': Icons.water_drop_rounded,
        'wt': Icons.monitor_weight_rounded,
        'ht': Icons.height_rounded,
        'dtx': Icons.bloodtype_rounded,
        'waist': Icons.straighten_rounded,
        'head': Icons.face_rounded,
      };
      const th = {
        'sbp': 'ความดันโลหิต',
        'hr': 'อัตราการเต้นหัวใจ',
        'rr': 'การหายใจ',
        'bt': 'อุณหภูมิ',
        'spo2': 'ออกซิเจนในเลือด',
        'wt': 'น้ำหนัก',
        'ht': 'ส่วนสูง',
        'dtx': 'น้ำตาลปลายนิ้ว',
        'waist': 'รอบเอว',
        'head': 'เส้นรอบศีรษะ',
      };
      final unit = _triVsFields.firstWhere((f) => f.$1 == k).$3;
      final keys = k == 'sbp' ? const ['sbp', 'dbp'] : [k];
      final vals = [for (final x in keys) _triVal(x)];
      final has = vals.every((v) => v != null);
      final red = [
        for (final (n, x) in keys.indexed)
          if (vals[n] != null && bad(x, vals[n]!)) x
      ].isNotEmpty;
      final err = invalid(k);
      // กรอกแล้ว = การ์ดทึบ ตัวหนังสือขาว (ปกติ = เขียว · ผิดปกติ = แดง)
      final solid = has;
      final fill = red ? _red : _green;
      // วงหลังไอคอน: สีการ์ดเข้มขึ้น · ยังไม่กรอก = เทา
      final surface = !solid
          ? const Color(0xFFEDEDF0)
          : Color.lerp(fill, Colors.black, 0.22)!;
      final last = _qLastWt;
      final fromVisit = last != null &&
          ((k == 'wt' && vals.first == last.$1) ||
              (k == 'ht' && vals.first == last.$2));
      final range0 = switch (k) {
        'wt' || 'ht' || 'waist' || 'head' => null,
        'sbp' => 'ปกติ ${normal('sbp')}/${normal('dbp')}',
        'dtx' => 'ถ้ามี  ปกติ ${normal(k)}',
        _ => 'ปกติ ${normal(k)}',
      };
      final desc = err ??
          (fromVisit
              ? 'จาก visit ล่าสุด ${last.$3.day} ${_FeaturesRegisterRegisterPagePart._thMonths[last.$3.month - 1]} ${(last.$3.year + 543) % 100}'
              : th[k]!);
      // แผง workflow (วัดซ้ำ): เทียบกับค่ารอบก่อนของเคส บอกว่าเพิ่ม/ลดเท่าไร
      String? delta;
      if (_qCardNarrow && has) {
        final c = erCaseOf(_caseP().hn);
        final prev = switch (k) {
          'sbp' => c.sbp,
          'hr' => c.hr,
          'rr' => c.rr,
          'bt' => c.bt,
          'spo2' => c.spo2,
          _ => const <double>[],
        };
        if (prev.isNotEmpty) {
          final d = vals.first! - prev.last;
          final dec = k == 'bt' ? 1 : 0;
          final mag = d.abs().toStringAsFixed(dec);
          delta = d.abs() < (k == 'bt' ? 0.05 : 0.5)
              ? 'เท่ารอบก่อน'
              : '${d > 0 ? '↑' : '↓'} $mag จากรอบก่อน';
        }
      }
      // แผงแคบ (workflow): แถวแบบหน้าตั้งค่า Google เหมือนขั้นแพ้ยา บุหรี่ สุรา
      // ไอคอน + ชื่อ + ค่า (แดง = ผิดปกติ) แตะแล้วเลือกค่าด้วยวงล้อ
      if (_qCardNarrow) {
        final value = has
            ? '${vals.map((v) => fmt(v!)).join('/')} $unit${delta == null ? '' : '   $delta'}'
            : 'ยังไม่วัด';
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (k != 'wt')
            const Divider(
                height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
          InkWell(
            key: _qFieldKeys.putIfAbsent('vs:$k', GlobalKey.new),
            onTap: () => openWheel(k),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(children: [
                // รูปประกอบเดิมของการ์ด V/S: BP/HR = ภาพ Figma บนวงสี · อื่น = ไอคอนในวง
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: red
                              ? _red.withValues(alpha: 0.12)
                              : has
                                  ? _green.withValues(alpha: 0.12)
                                  : _blue.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    if (const {'sbp', 'hr'}.contains(k))
                      Positioned.fill(
                        child: Image.asset(
                            'assets/images/er_vs_${k == 'sbp' ? 'bp' : 'pr'}.png'),
                      )
                    else
                      Center(
                        child: Icon(icons[k],
                            size: 20.0,
                            color: red
                                ? _red
                                : has
                                    ? _green
                                    : _blue),
                      ),
                  ]),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: th[k]!,
                              style: _t(14.5,
                                  color: _inkTitle, weight: FontWeight.w500)),
                          if (range0 != null)
                            TextSpan(
                                text: '  $range0',
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                        ])),
                        const SizedBox(height: 2.0),
                        Text(err ?? (fromVisit ? '$value  ($desc)' : value),
                            style: _t(13.0,
                                color: err != null || red
                                    ? _red
                                    : has
                                        ? _blue
                                        : _ink3,
                                weight: FontWeight.w500)),
                      ]),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 22.0, color: _ink3),
              ]),
            ),
          ),
        ]);
      }
      return _Press(
        child: GestureDetector(
          onTap: () => openWheel(k),
          child: AnimatedContainer(
            key: _qFieldKeys.putIfAbsent('vs:$k', GlobalKey.new),
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              // กรอกแล้ว = พื้นเขียวอ่อนทั้งใบ · ผิดปกติ = แดง · ยังไม่กรอก = ขาว
              color: solid ? fill : _panel,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color: solid ? fill : const Color(0xFFDADCE0), width: 1.0),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 12.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ค่าปกติต่อท้ายชื่อ (ป้ายจาง)
                                  Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                          text: _triVsEn[k] ?? k,
                                          style: _t(15.0,
                                              color: solid
                                                  ? Colors.white
                                                  : _inkTitle,
                                              weight: FontWeight.w600)),
                                      if (range0 != null)
                                        TextSpan(
                                            text: '   $range0',
                                            style: _t(12.0,
                                                color: solid
                                                    ? Colors.white70
                                                    : _ink3,
                                                weight: FontWeight.w500)),
                                    ]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                          text: has
                                              ? vals
                                                  .map((v) => fmt(v!))
                                                  .join('/')
                                              : '–',
                                          style: _num(26.0,
                                              color: !has ? _g5 : Colors.white,
                                              weight: FontWeight.w700)),
                                      TextSpan(
                                          text: '  $unit',
                                          style: _t(12.0,
                                              color: solid
                                                  ? Colors.white70
                                                  : _ink3,
                                              weight: FontWeight.w500)),
                                      if (delta != null)
                                        TextSpan(
                                            text: '   $delta',
                                            style: _t(12.5,
                                                color: Colors.white,
                                                weight: FontWeight.w700)),
                                    ]),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(desc,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(11.5,
                                          color: solid
                                              ? Colors.white70
                                              : err != null
                                                  ? _red
                                                  : _ink3,
                                          weight: FontWeight.w500)),
                                ]),
                          ),
                          const SizedBox(width: 8.0),
                          // BP PR: ภาพประกอบจาก Figma (HOSXP V6 ER node 365:7, 365:18)
                          if (const {'sbp', 'hr'}.contains(k))
                            // วงพื้นวาดเอง (สีตามสถานะ) รูป PR มีขอบบนเผื่อมือล้นวง
                            SizedBox(
                              width: 56.0,
                              height: 56.0,
                              child: Stack(clipBehavior: Clip.none, children: [
                                Positioned(
                                  left: 0.0,
                                  bottom: 0.0,
                                  width: k == 'hr' ? 56.0 * 0.895 : 56.0,
                                  height: k == 'hr' ? 56.0 * 0.895 : 56.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                        color: surface, shape: BoxShape.circle),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Image.asset(
                                      'assets/images/er_vs_${k == 'sbp' ? 'bp' : 'pr'}.png'),
                                ),
                              ]),
                            )
                          else
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: solid
                                    ? surface
                                    : _blue.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icons[k],
                                  size: 20.0,
                                  color: solid ? Colors.white : _blue),
                            ),
                        ]),
                  ),
                ]),
          ),
        ),
      );
    }

    // ติ๊กได้หลายข้อ (ขั้น 1 และ 2 ใช้ชุดเดียวกัน)
    Widget check(String o, IconData ic) {
      final on = _triRisk.contains(o);
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => on ? _triRisk.remove(o) : _triRisk.add(o));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 44.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: on ? _red.withValues(alpha: 0.08) : _panel,
              borderRadius: BorderRadius.circular(12.0),
              border:
                  Border.all(color: on ? _red : _line, width: on ? 1.6 : 1.0),
            ),
            child: Row(children: [
              Icon(ic, size: 18.0, color: on ? _red : _ink2),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(o,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.5,
                        color: on ? _red : _inkTitle,
                        weight: on ? FontWeight.w700 : FontWeight.w600)),
              ),
              if (on)
                const Icon(Icons.check_circle_rounded, size: 18.0, color: _red),
            ]),
          ),
        ),
      );
    }

    void toggleAct(String a) => setState(() {
          if (a == 'ไม่มี') {
            final was = _triAct.contains('ไม่มี');
            _triAct.clear();
            if (!was) _triAct.add('ไม่มี');
          } else {
            _triAct.remove('ไม่มี');
            _triAct.contains(a) ? _triAct.remove(a) : _triAct.add(a);
          }
        });
    final acts = _triAct.where((a) => a != 'ไม่มี').length +
        (_triAct.contains('หัตถการใหญ่') ? 1 : 0);
    // ยืนยันไม่ยกระดับ (ESI v5): ติ๊กแล้วระบบไม่นับข้อนั้นเป็น ESI 2
    Widget waive(String key, String label) {
      final on = _triWaive.contains(key);
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => on ? _triWaive.remove(key) : _triWaive.add(key));
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 44.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _qFlat ? _panel : _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(children: [
              Icon(
                  on
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 20.0,
                  color: on ? _blue : _ink3),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(label,
                    style: _t(12.0,
                        color: on ? _blue : _ink2, weight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      );
    }

    // จับเวลาวัดตอนมีค่าแรก ล้างค่าหมด = ยังไม่ได้วัด
    // น้ำหนัก ส่วนสูง (อาจดึงจาก visit ก่อน) ไม่นับเป็นเวลาวัด
    final anyVs = _triVsFields.any((f) =>
        !const {'wt', 'ht', 'waist', 'head'}.contains(f.$1) &&
        _triVal(f.$1) != null);
    if (!anyVs) {
      _triVsAt = null;
    } else {
      _triVsAt ??= DateTime.now();
    }
    return [
      // NEWS2: banner ใต้การ์ดสัญญาณชีพ ขึ้นเมื่อค่าพอคำนวณ
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _qCard(
          'สัญญาณชีพ',
          sum: _triVsSum(),
          done: _triVal('hr') != null &&
              _triVal('rr') != null &&
              _triVal('sbp') != null,
          count: _triVsAt == null
              ? 'แตะการ์ดเพื่อหมุนเลือกค่า'
              : 'วัดเมื่อ ${_clock(_qClock(_triVsAt!))}',
          // ทางลัดกรอก V/S: สแกนจอ monitor (OCR) หรือพูดค่าทั้งชุด
          // แผงแคบ (workflow): ไอคอนเล็กขวามือหัวข้อ ไม่แย่งปุ่มหลักของแผง (P9)
          action: _qCardNarrow
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  _triIconBtn(
                      Icons.document_scanner_outlined, 'สแกนจอ', _triVsScan,
                      busy: _triOcrBusy),
                  const SizedBox(width: 8.0),
                  _triIconBtn(Icons.mic_none_rounded, 'พูด', _triVsSpeak),
                ])
              : null,
          trailing: _qCardNarrow
              ? null
              : Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                  _triPill(Icons.document_scanner_rounded, 'สแกนจอ', _triVsScan,
                      busy: _triOcrBusy, primary: false),
                  _triPill(Icons.mic_rounded, 'กรอกโดยใช้เสียง', _triVsSpeak),
                ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // กลุ่มอายุ (dangerous zone) คำนวณจากอายุผู้ป่วยเอง ไม่ต้องเลือก
            // การ์ดค่าละใบ 2 คอลัมน์ (ลำดับตามใบคัดกรอง) แตะเพื่อเลือกค่าด้วย wheel
            grid(_qCardNarrow ? 1 : 2, gap: _qCardNarrow ? 0.0 : 12.0, [
              // น้ำหนัก ส่วนสูง บนสุด (ไม่มี DTX)
              for (final k in [
                'wt',
                'ht',
                if (_triVsExtra) ...['waist', 'head'],
                'sbp',
                'hr',
                'rr',
                'bt',
                'spo2',
              ])
                vsCard(k),
            ]),
            // V/S เกินเกณฑ์: วัดซ้ำ ถ้ากลับมาปกติครบจึงไม่ยกเป็น ESI 2
          ]),
        ),
        if (_triNewsBanner() case final b?) b,
      ]),
      _triNeuroCard(),
      _triNewsCard(),
      _qCard(
        '1  จะเสียชีวิต ต้องช่วยทันที',
        sum: [
          for (final (o, _) in _triLifeOpts)
            if (_triRisk.contains(o)) o
        ].join(', '),
        done: _triAdvise().$1 != null,
        count: 'ใช่ = ESI 1',
        grid(2, [for (final (o, ic) in _triLifeOpts) check(o, ic)]),
      ),
      _qCard(
        '2  เสี่ยง ซึม ปวด',
        sum: [
          for (final (o, _) in _triRiskOpts)
            if (_triRisk.contains(o)) o,
          if (_triPain != null) 'Pain $_triPain',
        ].join(', '),
        done: _triAdvise().$1 != null,
        count: 'ใช่ = ESI 2',
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // อาการสำคัญเข้าข่าย Fast track แต่ยังไม่ติ๊ก = เตือนให้ยืนยัน
          if (_triFastHint() case (final w, final kind)
              when !_triRisk.contains('Fast track') &&
                  !_triType.contains(kind)) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                const Icon(Icons.bolt_rounded, size: 18.0, color: _red),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text('อาการ "$w" เข้าข่าย Fast track $kind',
                      style: _t(12.5, color: _red, weight: FontWeight.w700)),
                ),
                _Press(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _triType.add(kind);
                        // เปิด fast track พร้อมเวลาเปิด (นาฬิกาเริ่มเดิน)
                        _triFt.putIfAbsent(
                            kind.toLowerCase(), () => DateTime.now());
                      });
                    },
                    child: Container(
                      height: 36.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text('เลือก $kind',
                          style: _t(12.0,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8.0),
          ],
          grid(2, [for (final (o, ic) in _triRiskOpts) check(o, ic)]),
        ]),
      ),
      _qCard(
        '3  กิจกรรมที่คาดว่าต้องทำ',
        sum: _triAct.map((a) => a == 'ไม่มี' ? 'ไม่มีกิจกรรม' : a).join(', '),
        done: _triAct.isNotEmpty || (_triAdvise().$1 ?? 9) <= 2,
        // ยังไม่เลือก = ต้องเลือก (จากการทดสอบ ข้อนี้มีผลต่อความแม่นมากที่สุด)
        // ได้ ESI 1-2 จากขั้น 1-2 แล้ว ไม่ต้องนับกิจกรรม
        trailing: _triAct.isEmpty && _triAdvise().$1 == null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text('ต้องเลือก',
                    style:
                        _t(11.0, color: Colors.white, weight: FontWeight.w700)),
              )
            : null,
        count: _triAct.isEmpty
            ? 'มากกว่า 1 = ESI 3, 1 = ESI 4, ไม่มี = ESI 5'
            : _triAct.contains('ไม่มี')
                ? 'ไม่มีกิจกรรม'
                : '$acts กิจกรรม',
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          grid(5, [
            for (final a in _triActOpts)
              _qOpt(a, null, _triAct.contains(a), () => toggleAct(a), h: 44.0),
          ]),
          const SizedBox(height: 6.0),
          Text(
              'นับตามชนิด (เลือดกับปัสสาวะ = Lab 1 อย่าง) หัตถการใหญ่ (ให้ยานอนหลับ) นับ 2  '
              'ไม่นับ: DTX ข้างเตียง ยากิน วัคซีนบาดทะยัก ทำแผลธรรมดา เฝือก',
              style: _t(10.5, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(height: 8.0),
          _qOpt('ไม่มีกิจกรรม (มาตามนัด ขอใบรับรองแพทย์)', null,
              _triAct.contains('ไม่มี'), () => toggleAct('ไม่มี'),
              h: 44.0),
        ]),
      ),
      _triPainCard(waive),
      _triRedCard(),
    ];
  }

  /// การ์ด Fast track (รวม Red Flag 4 โรค) แบบหน้า Settings ของ Google:
  /// แฟ้มละแถว (ไอคอนในวงกลม · ชื่อ · บรรทัดรอง) เปิดด้วยสวิตช์
  /// บรรทัดรอง = เหตุผลที่ระบบแนะนำ หรือเวลาเปิด · เปิดแล้วกางเกณฑ์เป็นชิปให้ติ๊กประกอบ
  /// เหตุผลที่ระบบแนะนำแต่ละแฟ้ม fast track (รหัสแฟ้ม → เหตุผล)
  Map<String, String> _triFtWhy() {
    final auto = _triRedAuto();
    // ไม่นับเกณฑ์ที่ติ๊กในการ์ด (ชิปมีไว้บันทึกเหตุผลของแฟ้มที่เปิดแล้ว)
    final why = <String, String>{};
    if (_triFastHint() case (final w, final kind)) {
      why[kind.toLowerCase()] = 'อาการ "$w"';
    }
    for (final k in auto) {
      why[_ftIdOf(k.split(':').first)] ??= 'ระบบคำนวณ ${k.split(':').last}';
    }
    if (_triType.contains('อุบัติเหตุ')) why['trauma'] ??= 'ประเภทอุบัติเหตุ';
    return why;
  }

  Widget _triRedCard() {
    final auto = _triRedAuto();
    final why = _triFtWhy();
    final lift = why.keys.toSet();
    const order = ['trauma', 'stroke', 'stemi', 'sepsis', 'head'];
    const groupOf = {
      'stroke': 'Stroke',
      'stemi': 'STEMI',
      'sepsis': 'Sepsis',
      'head': 'TBI'
    };
    const icons = {
      'stroke': Icons.psychology_outlined,
      'stemi': Icons.monitor_heart_outlined,
      'sepsis': Icons.coronavirus_outlined,
      'head': Icons.personal_injury_outlined,
      'trauma': Icons.car_crash_outlined,
    };

    // เกณฑ์เป็น filter chip · ข้อที่ระบบคำนวณได้ติ๊กให้เอง
    Widget chip(String g, String i) {
      final k = '$g:$i';
      final isAuto = auto.contains(k);
      final on = isAuto || _triRed.contains(k);
      return FilterChip(
        selected: on,
        showCheckmark: true,
        label: Text(isAuto ? '$i (อัตโนมัติ)' : i),
        labelStyle: _t(12.5,
            color: on ? _ftRedDeep : _ink2,
            weight: on ? FontWeight.w600 : FontWeight.w500),
        selectedColor: _ftRedSoft,
        checkmarkColor: _ftRed,
        backgroundColor: _panel,
        side: BorderSide(color: on ? _ftRed : const Color(0xFFDADCE0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        visualDensity: VisualDensity.compact,
        onSelected: isAuto
            ? null
            : (_) {
                HapticFeedback.selectionClick();
                setState(() => on ? _triRed.remove(k) : _triRed.add(k));
              },
      );
    }

    Widget lkwChip() => ActionChip(
          avatar: const Icon(Icons.schedule_rounded, size: 16.0, color: _ink2),
          label: Text(_triLkw == null
              ? 'เวลาปกติครั้งสุดท้าย (LKW)'
              : 'LKW ${_clock('${_triLkw!.hour.toString().padLeft(2, '0')}:${_triLkw!.minute.toString().padLeft(2, '0')}')}'),
          labelStyle: _t(12.5, color: _ink2, weight: FontWeight.w600),
          backgroundColor: _panel,
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            final t = await showTimePicker(
                context: context, initialTime: _triLkw ?? TimeOfDay.now());
            if (t != null) setState(() => _triLkw = t);
          },
        );

    Widget row(String id, {bool first = false}) {
      final t = erFastTrackById(id)!;
      final at = _triFt[id];
      final on = at != null;
      final hint = why[id];
      final g = groupOf[id];
      void toggle(bool v) {
        HapticFeedback.selectionClick();
        setState(() {
          if (v) {
            _triFt[id] = DateTime.now();
          } else {
            // ปิดแฟ้ม = ล้างเกณฑ์ที่ติ๊กไว้ (ไม่ค้างแบบมองไม่เห็นแล้วยังดัน ESI)
            _triFt.remove(id);
            if (g != null) _triRed.removeWhere((k) => k.startsWith('$g:'));
            if (id == 'stroke') _triLkw = null;
          }
        });
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!first) const Divider(height: 1.0, color: Color(0xFFE8EAED)),
        InkWell(
          onTap: () => toggle(!on),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // เปิดแล้ว = วงแดงทึบ เด่นสุดในการ์ด
                  color: on
                      ? _ftRed
                      : hint != null
                          ? const Color(0xFFFEF7E0)
                          : _blue.withValues(alpha: 0.08),
                ),
                child: Icon(icons[id],
                    size: 20.0,
                    color: on
                        ? Colors.white
                        : hint != null
                            ? const Color(0xFFB06000)
                            : _blue),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name,
                        style: _t(15.0,
                            color: on ? _ftRed : _inkTitle,
                            weight: on ? FontWeight.w700 : FontWeight.w600)),
                    const SizedBox(height: 2.0),
                    Text(
                        on
                            ? 'เปิดเมื่อ ${_taskClock(at)} นาฬิกาเริ่มเดินแล้ว'
                            : hint != null
                                ? 'แนะนำ: $hint'
                                : t.criteria.first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5,
                            color: on
                                ? _ftRed
                                : hint != null
                                    ? const Color(0xFFB06000)
                                    : _ink3,
                            weight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Switch(
                value: on,
                onChanged: toggle,
                activeThumbColor: Colors.white,
                activeTrackColor: _ftRed,
              ),
            ]),
          ),
        ),
        // เปิดแล้ว หรือแนะนำ = กางเกณฑ์ (ติ๊กประกอบ ไม่บังคับ)
        // กางเฉพาะแฟ้มที่เปิดแล้ว = บันทึกว่าเปิดเพราะเกณฑ์ข้อไหน
        // กาง/หุบ: ความสูงยืดตาม แล้วชิปค่อย ๆ โผล่ไล่ทีละอัน (จาง + ลอยขึ้น)
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: g != null && on
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(54.0, 0.0, 0.0, 14.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // หัวข้อย่อยคั่นชื่อแฟ้มกับเกณฑ์
                        Text('เกณฑ์ที่พบ (เลือกได้หลายข้อ)',
                            style: _t(12.5,
                                color: _ink2, weight: FontWeight.w600)),
                        const SizedBox(height: 8.0),
                        Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                          for (final (n, w) in [
                            for (final i
                                in _triRedFlags.firstWhere((e) => e.$1 == g).$2)
                              chip(g, i),
                            if (g == 'Stroke') lkwChip(),
                          ].indexed)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 260 + 45 * n),
                              curve: Interval((45 * n) / (260 + 45 * n), 1.0,
                                  curve: Curves.easeOutCubic),
                              builder: (context, v, child) => Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0.0, 8.0 * (1.0 - v)),
                                  child: Transform.scale(
                                      scale: 0.92 + 0.08 * v, child: child),
                                ),
                              ),
                              child: w,
                            ),
                        ]),
                      ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]);
    }

    return KeyedSubtree(
      key: _triFtKey,
      child: _qCard(
        'Fast track',
        sum: [for (final id in _triFt.keys) erFastTrackById(id)?.name ?? id]
            .join(', '),
        done: _triFt.isNotEmpty,
        // อธิบายว่า fast track คืออะไร (สถานะรายแฟ้มอยู่ในแต่ละแถวแล้ว)
        count:
            'ช่องทางด่วนสำหรับโรคที่รอไม่ได้ เปิดแล้วทีมเริ่มจับเวลาตามเป้าการรักษา',
        // แดงจาง ๆ จากขอบบน บอกว่าเป็นเรื่องเร่งด่วน (ไม่ทาแดงทั้งการ์ด)
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // อ่อนมาก + สั้น: ตัวหนังสือหัวการ์ดยังคมชัด
          colors: [Color(0xFFFEF4F3), Color(0x00FFFFFF)],
          stops: [0.0, 0.3],
        ),
        // hero นาฬิกาจับเวลา (ชุดเดียวกับแท็บ Fast track ในการ์ดคำสั่ง)
        // ภาพใหญ่แต่ไม่ดันหัวการ์ดให้สูงขึ้น: ล้นขึ้น/ลงจากช่องหัวข้อได้
        action: SizedBox(
          width: 96.0,
          height: 44.0,
          child: OverflowBox(
            maxWidth: 96.0,
            maxHeight: 108.0,
            child: Transform.translate(
              offset: const Offset(0.0, 12.0),
              child: const SizedBox(
                width: 96.0,
                height: 108.0,
                child: _StopwatchHero(key: ValueKey('tri-ft')),
              ),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ที่ระบบแนะนำ (จากอาการ ประเภท ค่าที่คำนวณ) ขึ้นก่อน
          // กดสวิตช์หรือติ๊กเกณฑ์ในการ์ดนี้แล้วแถวไม่ย้ายที่
          for (final (k, id) in [
            ...order.where(lift.contains),
            ...order.where((id) => !lift.contains(id)),
          ].indexed)
            row(id, first: k == 0),
        ]),
      ),
    );
  }

  /// เกณฑ์ที่ใช้เปิดแต่ละแฟ้ม (ติ๊กเอง + ระบบคำนวณ + LKW ของ Stroke)
  /// เก็บไปกับแฟ้มตอนส่ง ให้ทีมที่รับต่อและการทบทวน KPI เห็นเหตุผล
  Map<String, List<String>> _triFtCriteria() {
    final auto = _triRedAuto();
    return {
      for (final id in _triFt.keys)
        id: [
          for (final (g, items) in _triRedFlags)
            if (_ftIdOf(g) == id)
              for (final i in items)
                if (_triRed.contains('$g:$i') || auto.contains('$g:$i')) i,
          if (id == 'stroke' && _triLkw != null)
            'LKW ${_clock('${_triLkw!.hour.toString().padLeft(2, '0')}:${_triLkw!.minute.toString().padLeft(2, '0')}')}',
        ],
    };
  }

  /// รหัสแฟ้ม fast track ของกลุ่ม red flag (TBI = Head injury)
  String _ftIdOf(String g) => g == 'TBI' ? 'head' : g.toLowerCase();

  /// ระดับปวด (NRS 0–10): ช่วงตามใบคัดกรอง ≥ 7 = ปวดมาก พิจารณา ESI 2
  static const _painBands = [
    (0, 0, 'ไม่ปวด', Icons.sentiment_very_satisfied_rounded),
    (1, 3, 'ปวดน้อย', Icons.sentiment_satisfied_rounded),
    (4, 6, 'ปวดปานกลาง', Icons.sentiment_dissatisfied_rounded),
    (7, 10, 'ปวดมาก', Icons.sentiment_very_dissatisfied_rounded),
  ];

  Widget _triPainCard(Widget Function(String, String) waive) {
    final cur = _triPain;
    final band = cur == null
        ? null
        : _painBands.firstWhere((b) => cur >= b.$1 && cur <= b.$2);
    Widget btn(int i) {
      final on = cur == i;
      final hot = i >= 7;
      final b = _painBands.firstWhere((b) => i >= b.$1 && i <= b.$2);
      final tone = hot ? _red : _blue;
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _triPain = on ? null : i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 72.0,
            decoration: BoxDecoration(
              color: on ? tone : _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(b.$4,
                  size: 22.0,
                  color: on
                      ? Colors.white
                      : hot
                          ? _red.withValues(alpha: 0.7)
                          : _ink3),
              const SizedBox(height: 4.0),
              Text('$i',
                  style: _num(17.0,
                      color: on
                          ? Colors.white
                          : hot
                              ? _red
                              : _inkTitle,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      );
    }

    return _qCard(
      'ระดับความปวด',
      sum: cur == null ? '' : 'Pain $cur/10 ${band!.$3}',
      done: cur != null,
      count: cur == null
          ? 'ให้ผู้ป่วยบอกระดับปวด 0 ไม่ปวด ถึง 10 ปวดมากที่สุด'
          : '$cur/10 ${band!.$3}',
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          for (var i = 0; i <= 10; i++) ...[
            if (i > 0) const SizedBox(width: 6.0),
            Expanded(child: btn(i)),
          ],
        ]),
        const SizedBox(height: 8.0),
        // แถบช่วงใต้ปุ่ม กว้างตามจำนวนปุ่มในช่วง
        Row(children: [
          for (final (k, b) in _painBands.indexed) ...[
            if (k > 0) const SizedBox(width: 6.0),
            Expanded(
              flex: b.$2 - b.$1 + 1,
              child: Column(children: [
                Container(
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: band == b
                        ? (b.$1 >= 7 ? _red : _blue)
                        : b.$1 >= 7
                            ? _red.withValues(alpha: 0.25)
                            : _ink3.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(b.$1 == b.$2 ? b.$3 : '${b.$3} ${b.$1}–${b.$2}',
                    style: _t(11.0,
                        color: b.$1 >= 7 ? _red : _ink2,
                        weight: band == b ? FontWeight.w700 : FontWeight.w500)),
              ]),
            ),
          ],
        ]),
        // ESI v5: ปวด ≥ 7 "พิจารณา" ESI 2 ไม่ใช่ทุกราย
        // ปวดจากกระดูก/กล้ามเนื้อที่ไม่มีปัญหาเส้นเลือด/ประสาท รอได้
        if ((cur ?? 0) >= 7) ...[
          const SizedBox(height: 10.0),
          waive('pain',
              'ปวดจากกระดูก/กล้ามเนื้อ ไม่มีปัญหาเส้นเลือด/ประสาท ให้ยาแก้ปวดแล้วรอได้'),
        ],
      ]),
    );
  }

  /// ระดับความเสี่ยง NEWS2 (RCP 2017): (ชื่อ, การตอบสนอง, ระดับ 0-3)
  /// 0 = 0 · 1-4 ต่ำ · มีข้อใดได้ 3 = ต่ำ-กลาง · 5-6 กลาง · ≥ 7 สูง
  (String, String, int)? _triNewsRisk() {
    final n = _triNews();
    if (n == null) return null;
    final (total, parts) = n;
    if (total >= 7) {
      return ('เสี่ยงสูง', 'ทีมฉุกเฉินประเมินทันที เฝ้าระวังต่อเนื่อง', 3);
    }
    if (total >= 5) {
      return ('เสี่ยงปานกลาง', 'แพทย์ประเมินด่วน วัด V/S ทุก 1 ชม.', 2);
    }
    if (parts.any((p) => p.$2 >= 3)) {
      return ('เสี่ยงต่ำ-ปานกลาง', 'มีข้อได้ 3 คะแนน แจ้งแพทย์ประเมินด่วน', 1);
    }
    if (total >= 1) return ('เสี่ยงต่ำ', 'วัด V/S ทุก 4-6 ชม.', 0);
    return ('ปกติ', 'วัด V/S ทุก 12 ชม.', 0);
  }

  /// การ์ด NEWS: คะแนนรวมจาก V/S ที่กรอก + ได้ O2 / COPD
  /// ≥ 4 = รายงานแพทย์เพื่อ Take protocol sepsis (ตามแบบประเมินของ รพ.)
  /// banner NEWS2 ใต้คำอธิบายหน้าคัดกรอง · null = ค่ายังไม่พอคำนวณ
  /// เสี่ยงปานกลางขึ้นไป (หรือ ≥ 4) = แดง พร้อมการตอบสนองตามระดับ
  Widget? _triNewsBanner() {
    final news = _triNews();
    final risk = _triNewsRisk();
    if (news == null || risk == null) return null;
    final total = news.$1;
    final alarm = risk.$3 >= 1 || total >= 4;
    // แผงแคบ (workflow): ปุ่ม "สูตร" อยู่ใน banner ด้านขวา (ช่อง action ของ banner)
    // ข้อความตัดขึ้นบรรทัดใหม่ก่อนถึงปุ่ม ไม่ทับกัน
    if (_qCardNarrow) {
      return _qBanner(
          alarm ? Icons.warning_rounded : Icons.monitor_heart_rounded,
          'NEWS2 $total คะแนน ${risk.$1}',
          alarm ? _red : _blue,
          sub: total >= 4
              ? '${risk.$2} รายงานแพทย์ เพื่อ Take protocol sepsis'
              : risk.$2,
          action: 'สูตร',
          onAction: () => _triNewsInfo(news.$2));
    }
    return Stack(children: [
      _qBanner(alarm ? Icons.warning_rounded : Icons.monitor_heart_rounded,
          'NEWS2 $total คะแนน ${risk.$1}', alarm ? _red : _blue,
          sub: total >= 4
              ? '${risk.$2} รายงานแพทย์ เพื่อ Take protocol sepsis'
              : risk.$2),
      // ปุ่ม i + ป้าย "สูตรคำนวณ": พื้นขาว กึ่งกลางแนวตั้งของ banner
      Positioned(
        right: 12.0,
        top: 0.0,
        bottom: 0.0,
        child: Center(
          child: _Press(
            radius: 18.0,
            child: GestureDetector(
              onTap: () => _triNewsInfo(news.$2),
              child: Container(
                height: 36.0,
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 12.0, 0.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18.0, color: alarm ? _red : _blue),
                  const SizedBox(width: 5.0),
                  Text('สูตรคำนวณ',
                      style: _t(12.5,
                          color: alarm ? _red : _blue,
                          weight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  /// sheet อธิบายสูตร NEWS2 (RCP 2017) พร้อมคะแนนแต่ละข้อของผู้ป่วย
  void _triNewsInfo(List<(String, int)> parts) {
    const rows = <(String, List<String>)>[
      // (ข้อ, ช่วงค่าที่ได้คะแนน 3 2 1 0 1 2 3)
      ('RR (/min)', ['≤ 8', '', '9–11', '12–20', '', '21–24', '≥ 25']),
      ('SpO₂ ชุด 1 (%)', ['≤ 91', '92–93', '94–95', '≥ 96', '', '', '']),
      (
        'SpO₂ ชุด 2 COPD (%)',
        [
          '≤ 83',
          '84–85',
          '86–87',
          '88–92 หรือ ≥ 93 ไม่ได้ O₂',
          '93–94 ได้ O₂',
          '95–96 ได้ O₂',
          '≥ 97 ได้ O₂'
        ]
      ),
      ('ได้ออกซิเจน', ['', 'ได้', '', 'ไม่ได้', '', '', '']),
      ('SBP (mmHg)', ['≤ 90', '91–100', '101–110', '111–219', '', '', '≥ 220']),
      (
        'HR (/min)',
        ['≤ 40', '', '41–50', '51–90', '91–110', '111–130', '≥ 131']
      ),
      ('ความรู้สึกตัว', ['', '', '', 'ตื่นดี (A)', '', '', 'สับสนใหม่ V P U']),
      (
        'อุณหภูมิ (°C)',
        ['≤ 35.0', '', '35.1–36.0', '36.1–38.0', '38.1–39.0', '≥ 39.1', '']
      ),
    ];
    const pts = ['3', '2', '1', '0', '1', '2', '3'];
    Widget cell(String t, {bool head = false, Color? bg}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          color: bg,
          alignment: Alignment.center,
          child: Text(t,
              textAlign: TextAlign.center,
              style: _t(head ? 12.0 : 11.5,
                  color: head ? _ink2 : _inkTitle,
                  weight: head ? FontWeight.w700 : FontWeight.w500)),
        );
    Color? tint(int col) => switch (col) {
          0 || 6 => _red.withValues(alpha: 0.10),
          1 || 5 => const Color(0xFFDC8610).withValues(alpha: 0.10),
          2 || 4 => const Color(0xFFF2C94C).withValues(alpha: 0.14),
          _ => null,
        };
    _placedSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 820.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('สูตรคำนวณ NEWS2',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            Text(
                'National Early Warning Score 2 (Royal College of Physicians 2017) '
                'ให้คะแนน 0–3 ทีละข้อจากสัญญาณชีพ แล้วรวมกัน',
                style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
            const SizedBox(height: 12.0),
            Table(
              border: TableBorder.all(color: _line),
              columnWidths: const {0: FlexColumnWidth(1.6)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                    decoration: const BoxDecoration(color: _panelSoft),
                    children: [
                      cell('คะแนน', head: true),
                      for (final p in pts) cell(p, head: true),
                    ]),
                for (final (n, v) in rows)
                  TableRow(children: [
                    cell(n, head: true),
                    for (var k = 0; k < 7; k++)
                      cell(v[k], bg: v[k].isEmpty ? null : tint(k)),
                  ]),
              ],
            ),
            const SizedBox(height: 14.0),
            Text('แปลผลคะแนนรวม',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 4.0),
            for (final t in const [
              '0–4 เสี่ยงต่ำ ประเมินตามรอบปกติ',
              'มี 3 คะแนนในข้อใดข้อหนึ่ง เสี่ยงต่ำ-ปานกลาง แจ้งแพทย์ประเมิน',
              '5–6 เสี่ยงปานกลาง แพทย์ประเมินด่วน',
              '7 ขึ้นไป เสี่ยงสูง ทีมฉุกเฉินประเมินทันที เฝ้าระวังต่อเนื่อง',
              'ER นี้: NEWS ≥ 4 รายงานแพทย์ เพื่อ Take protocol sepsis',
            ])
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(t,
                    style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
              ),
            const SizedBox(height: 14.0),
            Text('คะแนนของผู้ป่วยรายนี้',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 6.0),
            Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final (k, v) in parts)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: v >= 3 ? _red.withValues(alpha: 0.1) : _panelSoft,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text('$k  $v',
                      style: _t(12.0,
                          color: v >= 3 ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _triNewsCard() {
    final news = _triNews();
    final total = news?.$1;
    final hot = (total ?? 0) >= 4;
    final risk = _triNewsRisk();
    final riskC = (risk?.$3 ?? 0) >= 1 ? _red : _ink2;
    Widget toggle(String l, bool on, VoidCallback tap) =>
        _qOpt(l, null, on, () => setState(tap), h: 44.0);
    return _qCard(
      'NEWS2',
      sum: total == null ? '' : 'รวม $total คะแนน ${risk!.$1}',
      done: total != null,
      count: total == null ? 'กรอกสัญญาณชีพ' : 'รวม $total คะแนน',
      trailing: total == null
          ? null
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: (risk?.$3 ?? 0) >= 1 ? _red : _panelSoft,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(risk?.$1 ?? '',
                  style: _t(11.0,
                      color: (risk?.$3 ?? 0) >= 1 ? Colors.white : _ink2,
                      weight: FontWeight.w700)),
            ),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: toggle('ได้ออกซิเจน', _triO2, () => _triO2 = !_triO2)),
          const SizedBox(width: 8.0),
          Expanded(
              child:
                  toggle('ผู้ป่วย COPD', _triCopd, () => _triCopd = !_triCopd)),
        ]),
        if (news != null) ...[
          const SizedBox(height: 10.0),
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final (k, v) in news.$2)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: v >= 3
                      ? _red.withValues(alpha: 0.1)
                      : v > 0
                          ? _panelSoft
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: v >= 3 ? _red : _line),
                ),
                child: Text('$k  $v',
                    style: _t(11.5,
                        color: v >= 3 ? _red : _inkTitle,
                        weight: FontWeight.w600)),
              ),
          ]),
        ],
        // การตอบสนองตามระดับ NEWS2
        if (risk != null) ...[
          const SizedBox(height: 10.0),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 16.0, color: riskC),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text('${risk.$1}: ${risk.$2}',
                  style: _t(12.0, color: riskC, weight: FontWeight.w600)),
            ),
          ]),
        ],
        if (hot) ...[
          const SizedBox(height: 10.0),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(children: [
              const Icon(Icons.campaign_rounded, size: 18.0, color: _red),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text('NEWS ≥ 4 รายงานแพทย์ เพื่อ Take protocol sepsis',
                    style: _t(12.5, color: _red, weight: FontWeight.w700)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // ------------------------------------------------------------ ขวา
  /// footer = ปุ่มท้าย panel (null = ยืนยันและส่งผู้ป่วยในหน้าคัดกรอง)
  /// extra = เนื้อหาต่อท้ายเหตุผล (หน้าลงทะเบียน: สรุปข้อมูลที่กรอก)
  /// [cardTop] = ระยะการ์ดจากขอบบนแผง (หน้าสรุปใช้ให้เสมอการ์ดฝั่งซ้าย)
  Widget _triEsiPanel(int? sug, List<String> why, int? level,
      {Widget? footer, Widget? extra, double cardTop = 0.0}) {
    final esi = level == null ? null : _Esi.values[level - 1];
    Widget pick(int l) {
      final e = _Esi.values[l - 1];
      final on = level == l;
      return Expanded(
        child: _Press(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _triPick = l == sug ? null : l);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 44.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: on ? _glossGrad(e.color) : null,
                color: on ? null : _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
                border: l == sug && !on
                    ? Border.all(color: e.color, width: 1.6)
                    : null,
              ),
              child: Text('$l',
                  style: _num(16.0,
                      color: on ? Colors.white : e.color,
                      weight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // การ์ด "ระบบแนะนำ" (ขอบบนเสมอการ์ดสรุปฝั่งซ้าย)
          Expanded(
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                top: cardTop,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    // แบบเดียวกับการ์ดอื่น: ขอบเทา มุม 12 ไม่มีเงา
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFDADCE0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (level == null) ...[
                        const Icon(Icons.speed_rounded, size: 30.0, color: _g5),
                        const SizedBox(height: 4.0),
                      ] else
                        // ป้ายระดับใหญ่ เปลี่ยนแล้วขยายเข้า
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutBack,
                          transitionBuilder: (c, a) => FadeTransition(
                            opacity: a,
                            child: ScaleTransition(
                                scale: Tween(begin: 0.7, end: 1.0).animate(a),
                                alignment: Alignment.centerLeft,
                                child: c),
                          ),
                          child: Row(
                              key: ValueKey(level),
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('ESI $level',
                                    style: _num(26.0,
                                        color: esi!.color,
                                        weight: FontWeight.w800)),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(esi.en,
                                      style: _t(13.0,
                                          color: _ink2,
                                          weight: FontWeight.w600)),
                                ),
                              ]),
                        ),
                      const SizedBox(height: 6.0),
                      Text(
                          _triPick != null
                              ? 'เลือกเอง (ระบบแนะนำ ESI ${sug ?? '-'})'
                              : sug == null
                                  ? (_triAct.isEmpty
                                      ? 'เลือกกิจกรรมที่คาดว่าต้องทำ (ขั้น 3) เพื่อดูระดับแนะนำ'
                                      : 'กรอกข้อมูลตรงกลางเพื่อดูระดับแนะนำ')
                                  : 'ระบบแนะนำจากข้อมูลที่กรอก',
                          style:
                              _t(11.5, color: _ink3, weight: FontWeight.w500)),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final w in why)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Container(
                                            width: 6.0,
                                            height: 6.0,
                                            decoration: BoxDecoration(
                                              color: (sug ?? 5) <= 2
                                                  ? _red
                                                  : _ink3,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(w,
                                              style: _t(13.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w600)),
                                        ),
                                      ]),
                                ),
                              if (extra != null) ...[
                                const SizedBox(height: 10.0),
                                extra,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // สายรัดข้อมือ 3D (เฉพาะสาย) ข้างชื่อระดับ ล้นขึ้นเหนือการ์ดได้
              if (level != null)
                Positioned(
                  top: _bandBox.$1 - 63.0 + cardTop,
                  right: _bandBox.$2,
                  width: _bandBox.$3,
                  height: _bandBox.$4,
                  child: ErEsiGauge3D(level: level, pose: _bandPose),
                ),
              // ปุ่มเปิดตัวปรับสายรัด (debug เท่านั้น) มุมขวาล่างการ์ด
              if (kDebugMode && level != null)
                Positioned(
                  bottom: 4.0,
                  right: 4.0,
                  child: IconButton(
                    tooltip: 'ปรับสายรัด (debug)',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _bandDebug = !_bandDebug),
                    icon: Icon(Icons.tune_rounded,
                        size: 18.0, color: _bandDebug ? _blue : _g5),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 12.0),
          // NEWS ประกอบการตัดสิน (≥ 4 รายงานแพทย์)
          if (_triNews() case (final n, _))
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: n >= 4 ? _red.withValues(alpha: 0.08) : _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                Text('NEWS2',
                    style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                const SizedBox(width: 8.0),
                Text('$n',
                    style: _num(18.0,
                        color: n >= 4 ? _red : _inkTitle,
                        weight: FontWeight.w800)),
                const Spacer(),
                Text(n >= 4 ? 'รายงานแพทย์' : (_triNewsRisk()?.$1 ?? ''),
                    style: _t(12.0,
                        color: n >= 4 || (_triNewsRisk()?.$3 ?? 0) >= 1
                            ? _red
                            : _ink3,
                        weight: FontWeight.w600)),
              ]),
            ),
          Text('เปลี่ยนระดับเอง',
              style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(height: 6.0),
          Row(children: [
            for (var l = 1; l <= 5; l++) ...[
              if (l > 1) const SizedBox(width: 6.0),
              pick(l),
            ],
          ]),
          const SizedBox(height: 12.0),
          if (level != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(children: [
                const Icon(Icons.place_outlined, size: 16.0, color: _ink3),
                const SizedBox(width: 6.0),
                Text(_triZoneOf(level).$1,
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.schedule_rounded, size: 16.0, color: _ink3),
                const SizedBox(width: 4.0),
                Text(_triZoneOf(level).$2,
                    style: _t(12.5,
                        color: level <= 2 ? _red : _inkTitle,
                        weight: FontWeight.w600)),
              ]),
            ),
          footer ??
              _navBtn('ส่งตรวจ', Icons.check_rounded,
                  level == null ? null : () => _triSend(level)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- ภาพประกอบ GCS
/// แถบคะแนน GCS 3–15: ช่วงรุนแรง/ปานกลาง/เล็กน้อย + จุดตำแหน่งคะแนน
class _GcsBarPainter extends CustomPainter {
  _GcsBarPainter(this.sum);
  final int? sum;

  @override
  void paint(Canvas c, Size s) {
    final y = s.height / 2;
    double x(num v) => (v - 3) / 12 * s.width;
    final p = Paint()
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    for (final (a, b, col) in [
      (3, 8, _red.withValues(alpha: 0.35)),
      (9, 12, const Color(0xFFDC8610).withValues(alpha: 0.35)),
      (13, 15, const Color(0xFFB0B5BB)),
    ]) {
      p.color = col;
      c.drawLine(
          Offset(x(a) + 3, y), Offset(x(b) - 3 + (b == 15 ? 0 : 3), y), p);
    }
    if (sum != null) {
      final col = sum! <= 8
          ? _red
          : sum! <= 12
              ? const Color(0xFFDC8610)
              : _inkTitle;
      c.drawCircle(Offset(x(sum!), y), 6.0, Paint()..color = _panel);
      c.drawCircle(Offset(x(sum!), y), 4.5, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(_GcsBarPainter o) => o.sum != sum;
}

/// ภาพของแต่ละตัวเลือก (flat pictogram): E = ตา · V = กล่องคำพูด · M = ท่าร่างกาย
/// พื้นวงกลมอ่อน ลายเส้นหนาปลายมน เติมสี ตัวกระตุ้น (เสียง/เจ็บ) เป็นป้ายมุม
class _GcsPicPainter extends CustomPainter {
  _GcsPicPainter(this.kind, this.i, this.on);
  final String kind;
  final int i;
  final bool on;

  Color get _ink => on ? _blue : const Color(0xFF3C4650);

  @override
  void paint(Canvas c, Size s) {
    // ภาพเต็มการ์ด: วางครึ่งล่าง เว้นมุมบนซ้ายให้ตัวเลข/คำอธิบาย
    // V M: แถบพื้นอ่อนครึ่งล่างแบบเดียวกับผิวของ E · ภาพอยู่ในแถบ
    final band = Rect.fromLTRB(0, s.height * 0.42, s.width, s.height);
    // Vb = ชั้นกล่องคำพูดอย่างเดียว วางทับภาพหน้าจากหุ่น 3D (ไม่ทาพื้น)
    if (kind != 'Vb')
      c.drawRect(
          band,
          Paint()
            ..color = on ? const Color(0xFFD2E3FC) : const Color(0xFFE9EDF1));
    var r = math.min(s.width * 0.4, s.height * 0.26);
    var ctr = Offset(s.width / 2, s.height * 0.72);
    // ชั้นกล่องคำพูด: ภาพหน้าเต็มการ์ดแล้ว ปากอยู่ราวกลางการ์ด
    if (kind == 'Vb') ctr = Offset(s.width / 2, s.height * 0.6);
    if (kind == 'E') {
      // ตา: ระยะใกล้มุม 3/4 ผิวเต็มความกว้างครึ่งล่างของการ์ด ดั้งจมูกด้านซ้าย
      // (ครึ่งบนเป็นพื้นการ์ดเรียบ ให้ตัวเลข/คำอธิบายอ่านง่าย)
      final bg = Rect.fromLTRB(0, s.height * 0.42, s.width, s.height);
      c.save();
      c.clipRect(bg);
      c.drawRect(
          bg,
          Paint()
            ..shader = LinearGradient(colors: [
              const Color(0xFFD9A587),
              const Color(0xFFF0CDB5),
              const Color(0xFFF4D6C2),
            ], stops: const [
              0.0,
              0.35,
              1.0
            ]).createShader(bg));
      if (on) c.drawRect(bg, Paint()..color = _blue.withValues(alpha: 0.10));
      r = math.min(s.width * 0.44, s.height * 0.36);
      ctr = Offset(s.width * 0.56, s.height * 0.76);
    }
    c.save();
    c.translate(ctr.dx, ctr.dy);
    c.scale(r / 30.0); // วาดในกรอบ -30..30
    switch (kind) {
      case 'E':
        _eye(c);
      case 'V' || 'Vb':
        _talk(c);
      default:
        // M ใช้ภาพเรนเดอร์จากหุ่น 3D (assets/images/er_gcs_m*.png) วาดแค่แถบพื้น
        break;
    }
    c.restore();
    if (kind == 'E') c.restore();
  }

  Paint _stroke(double w, [Color? col]) => Paint()
    ..color = col ?? _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _fill(Color col) => Paint()..color = col;

  // ---- E: ตาระยะใกล้มุม 3/4 (หัวตาชิดดั้งจมูกด้านซ้าย หางตาด้านขวา)
  void _eye(Canvas c) {
    const shadow = Color(0x55A0634A);
    // ดั้งจมูก + ปลายจมูก (โปรไฟล์ด้านซ้าย)
    c.drawPath(
        Path()
          ..moveTo(-24, -34)
          ..quadraticBezierTo(-22, -6, -34, 16),
        Paint()
          ..color = shadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round);
    c.drawPath(
        Path()
          ..moveTo(-40, 14)
          ..quadraticBezierTo(-30, 22, -22, 18),
        Paint()
          ..color = shadow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round);
    // คิ้วโค้ง หนาที่หัวคิ้ว
    c.drawPath(
        Path()
          ..moveTo(-14, -20)
          ..quadraticBezierTo(4, -29, 26, -19)
          ..quadraticBezierTo(5, -25, -14, -17)
          ..close(),
        Paint()..color = const Color(0xFF4A3426));
    if (i == 4) {
      // ตาบวมปิด: เปลือกตาบวมนูนช้ำ
      c.drawOval(
          Rect.fromCenter(center: const Offset(5, 0), width: 40, height: 22),
          Paint()..color = const Color(0xFFC07F96));
      c.drawOval(
          Rect.fromCenter(center: const Offset(4, -2), width: 30, height: 13),
          Paint()..color = const Color(0xFFDCA0B3));
      c.drawPath(
          Path()
            ..moveTo(-12, 6)
            ..quadraticBezierTo(5, 11, 22, 5),
          _stroke(2.2, const Color(0xFF7A4A5A)));
      return;
    }
    final open = const [1.0, 0.8, 0.45, 0.0, 0.0][i];
    // รอยพับเปลือกตาบน
    c.drawPath(
        Path()
          ..moveTo(-10, -9)
          ..quadraticBezierTo(6, -17, 22, -8),
        _stroke(1.6, shadow));
    const inner = Offset(-12, 2), outer = Offset(23, -1);
    final h = 10.0 * open;
    final eye = Path()
      ..moveTo(inner.dx, inner.dy)
      ..cubicTo(-6, -h * 1.5, 12, -h * 1.6, outer.dx, outer.dy)
      ..cubicTo(14, h * 1.1, -4, h * 1.2, inner.dx, inner.dy)
      ..close();
    if (open > 0) {
      c.drawPath(eye, Paint()..color = const Color(0xFFF8F3EE));
      c.save();
      c.clipPath(eye);
      // ม่านตาทรงรีตามมุมมอง 3/4
      final ic = const Offset(5, 0);
      final ir = Rect.fromCenter(center: ic, width: 15, height: 18);
      c.drawOval(
          ir,
          Paint()
            ..shader = const RadialGradient(
                    colors: [Color(0xFF9A6B42), Color(0xFF4A2F1C)])
                .createShader(ir));
      c.drawOval(Rect.fromCenter(center: ic, width: 6.5, height: 8),
          Paint()..color = const Color(0xFF0E0806));
      c.drawCircle(const Offset(8, -3), 1.8, Paint()..color = Colors.white);
      // เปลือกตาบนทอดเงา
      c.drawRect(
          Rect.fromLTRB(-14, -16, 26, -h * 0.4),
          Paint()
            ..shader = const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE3AE90), Color(0x00E3AE90)])
                .createShader(Rect.fromLTRB(-14, -16, 26, -h * 0.4 + 0.1)));
      c.restore();
      c.drawPath(eye, _stroke(1.8, const Color(0xFF4A3426)));
    } else {
      // ปิดตา: เส้นโค้งลง + ขนตาด้านหางตา
      c.drawPath(
          Path()
            ..moveTo(inner.dx, inner.dy)
            ..quadraticBezierTo(6, 9, outer.dx, outer.dy),
          _stroke(2.2, const Color(0xFF4A3426)));
      for (final t in [0.35, 0.55, 0.75, 0.92]) {
        final x = inner.dx + (outer.dx - inner.dx) * t;
        final y = 5.5 - 7 * (t - 0.5) * (t - 0.5) * 4 / 4;
        c.drawLine(Offset(x, y), Offset(x + 2.5, y + 4),
            _stroke(1.6, const Color(0xFF4A3426)));
      }
    }
  }

  // ---- V: หน้าด้านข้าง (หันขวา) ระยะใกล้ + กล่องคำพูดข้างปาก
  void _talk(Canvas c) {
    _bubble(c);
  }

  // กล่องคำพูดข้างปาก: ทรงมนเป็นชิ้นเดียวกับหาง เนื้อหาเป็นคำพูดจริงตามระดับ V
  void _bubble(Canvas c) {
    // กรอบกล่อง (พิกัดภาพ -30..30) หางชี้ลงซ้ายไปที่ปาก
    const l = 4.0, t = -32.0, r = 50.0, b = -6.0, rad = 9.0;
    final shape = Path()
      ..moveTo(l + rad, t)
      ..lineTo(r - rad, t)
      ..arcToPoint(const Offset(r, t + rad), radius: const Radius.circular(rad))
      ..lineTo(r, b - rad)
      ..arcToPoint(const Offset(r - rad, b), radius: const Radius.circular(rad))
      ..lineTo(l + 15, b)
      // หางเรียวโค้งต่อจากขอบล่าง
      ..quadraticBezierTo(l + 9, b + 3, l + 1, b + 8)
      ..quadraticBezierTo(l + 5, b + 2, l + 6, b)
      ..lineTo(l + rad, b)
      ..arcToPoint(const Offset(l, b - rad), radius: const Radius.circular(rad))
      ..lineTo(l, t + rad)
      ..arcToPoint(const Offset(l + rad, t), radius: const Radius.circular(rad))
      ..close();
    final mute = i == 4;
    final fill = on ? const Color(0xFFEAF1FF) : Colors.white;
    // เงานุ่มใต้กล่อง
    c.drawPath(
        shape.shift(const Offset(0, 1.8)),
        Paint()
          ..color =
              const Color(0xFF1F2A37).withValues(alpha: mute ? 0.05 : 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6));
    c.drawPath(shape, _fill(mute ? fill.withValues(alpha: 0.75) : fill));
    c.drawPath(
        shape,
        _stroke(
            0.9,
            (on ? _blue : const Color(0xFF9AA4B2))
                .withValues(alpha: mute ? 0.5 : 0.7)));
    final ink = on ? _blue : const Color(0xFF2B3440);
    const ctr = Offset((l + r) / 2, (t + b) / 2);
    void say(String txt, double size, {FontWeight w = FontWeight.w700}) {
      final tp = TextPainter(
          text: TextSpan(
              text: txt,
              style: TextStyle(
                  color: ink, fontSize: size, fontWeight: w, height: 1.0)),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: r - l - 6);
      tp.paint(c, ctr - Offset(tp.width / 2, tp.height / 2));
    }

    switch (i) {
      case 0: // พูดรู้เรื่อง: ประโยคสมบูรณ์
        say('สบายดี', 10.5);
      case 1: // สับสน
        say('?', 17.0, w: FontWeight.w800);
      case 2: // เป็นคำ ๆ ไม่ต่อกัน
        say('…บ้าน…', 10.0);
      case 3: // ส่งเสียงไม่เป็นคำ: คลื่นเสียงโค้งมน
        final p = Path()..moveTo(l + 9, ctr.dy);
        for (var k = 0; k < 6; k++) {
          p.relativeQuadraticBezierTo(2.8, k.isEven ? -7.0 : 7.0, 5.6, 0);
        }
        c.drawPath(p, _stroke(2.2, ink));
      default: // ไม่ออกเสียง: ลำโพงปิดเสียง
        final g = _stroke(1.8, ink.withValues(alpha: 0.5));
        final sp = Path()
          ..moveTo(ctr.dx - 9, ctr.dy - 3)
          ..lineTo(ctr.dx - 5, ctr.dy - 3)
          ..lineTo(ctr.dx, ctr.dy - 8)
          ..lineTo(ctr.dx, ctr.dy + 8)
          ..lineTo(ctr.dx - 5, ctr.dy + 3)
          ..lineTo(ctr.dx - 9, ctr.dy + 3)
          ..close();
        c.drawPath(sp, g);
        c.drawLine(
            Offset(ctr.dx + 4, ctr.dy - 4), Offset(ctr.dx + 11, ctr.dy + 4), g);
        c.drawLine(
            Offset(ctr.dx + 11, ctr.dy - 4), Offset(ctr.dx + 4, ctr.dy + 4), g);
    }
  }

  @override
  bool shouldRepaint(_GcsPicPainter o) =>
      o.kind != kind || o.i != i || o.on != on;
}

/// เกจ ESI แบบ 3D: เอียงมีมุมมอง (perspective) + ความหนาด้านล่าง + เงาพื้น
/// เปิดหรือเปลี่ยนระดับ = เกจพลิกจากแนวตั้งลงมาเอียง (ครั้งเดียว ไม่วนตลอด)
class _EsiGauge3D extends StatefulWidget {
  const _EsiGauge3D({
    required this.level,
    required this.center,
    this.mark,
    this.width = 180.0,
  });

  final int level;
  final int? mark;
  final Widget center;
  final double width;

  @override
  State<_EsiGauge3D> createState() => _EsiGauge3DState();
}

class _EsiGauge3DState extends State<_EsiGauge3D>
    with TickerProviderStateMixin {
  // เปิดครั้งแรก: เกจพลิกลงมาเอียง
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward();
  // เปลี่ยนระดับ: เกจเด้ง (ยุบแล้วขยาย) + เอียงโยกเล็กน้อย
  late final AnimationController _p = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void didUpdateWidget(_EsiGauge3D old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level) _p.forward(from: 0.0);
  }

  @override
  void dispose() {
    _c.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _Esi.values[widget.level - 1].color;
    Widget gauge(Widget center) => _EsiGauge(
        level: widget.level,
        mark: widget.mark,
        width: widget.width,
        center: center);
    // สีความหนา/เงาไล่จากระดับเดิมไประดับใหม่
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: target),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, color, _) =>
          Stack(alignment: Alignment.bottomCenter, children: [
        tilted(color ?? target, gauge),
        // ตัวหนังสือกลางเกจตั้งตรง อ่านง่าย · เปลี่ยนระดับ = ป้ายใหม่ขยายเข้า
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(
                  scale: Tween(begin: 0.6, end: 1.0).animate(a), child: child),
            ),
            child:
                KeyedSubtree(key: ValueKey(widget.level), child: widget.center),
          ),
        ),
      ]),
    );
  }

  Widget tilted(Color color, Widget Function(Widget) gauge) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c, _p]),
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_c.value);
        // เด้งตอนเปลี่ยนระดับ: 0 → 1 → 0 แบบหน่วง
        final bump = math.sin(math.pi * _p.value) * (1.0 - _p.value * 0.4);
        // เอียงหน้าเกจไปด้านหลัง 1.1 → 0.62 เรเดียน (perspective แรง: ล่างใหญ่ หัวแคบ) (+ โยกตอนเปลี่ยนระดับ)
        final tilt = 1.1 - 0.48 * t + 0.12 * bump;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0048)
            ..rotateX(tilt)
            ..scaleByDouble(1.0 + 0.06 * bump, 1.0 + 0.06 * bump, 1.0, 1.0),
          child: child,
        );
      },
      child: Stack(clipBehavior: Clip.none, children: [
        // เงาพื้นนุ่ม ๆ ใต้เกจ (สีตามระดับ)
        Positioned(
          left: widget.width * 0.1,
          right: widget.width * 0.1,
          bottom: -10.0,
          height: 22.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 18.0,
                    spreadRadius: -4.0),
              ],
            ),
          ),
        ),
        // ความหนา: เกจสีเข้มซ้อนเลื่อนลงทีละพิกเซล
        for (var k = 6; k >= 1; k--)
          Transform.translate(
            offset: Offset(0.0, k * 1.6),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Color.lerp(color, Colors.black, 0.35)!
                      .withValues(alpha: 0.85),
                  BlendMode.srcATop),
              child: gauge(const SizedBox.shrink()),
            ),
          ),
        gauge(const SizedBox.shrink()),
      ]),
    );
  }
}
