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

/// สัญญาณชีพ: (key, ชื่อ, หน่วย)
const List<(String, String, String)> _triVsFields = [
  ('sbp', 'SBP', 'mmHg'),
  ('dbp', 'DBP', 'mmHg'),
  ('hr', 'ชีพจร', '/min'),
  ('rr', 'หายใจ', '/min'),
  ('spo2', 'SpO₂', '%'),
  ('bt', 'อุณหภูมิ', '°C'),
  ('gcs', 'GCS', '/15'),
  ('wt', 'น้ำหนัก', 'kg'),
  ('ht', 'ส่วนสูง', 'cm'),
];

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
    final src = await showModalBottomSheet<ImageSource>(
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
          'PR',
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
  void _openTriage(_P p) {
    setState(() {
      _triReset(age: erCases[p.hn]?.age);
      _triP = p;
      _regOpen = true;
    });
  }

  void _closeTriage() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _triP = null;
      _regOpen = false;
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

  void _triSend(int level) {
    final p = _triP!;
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
    ErFeedback.confirm();
    _closeTriage();
    setState(() => _open = _Phase.of(_Stage.waitDoctor));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'คัดกรอง ${p.name} เป็น ESI $level แล้ว ส่ง${_triZoneOf(level).$1} ${_triZoneOf(level).$2}',
            style: _t(12.0, color: Colors.white))));
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
    showModalBottomSheet<void>(
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
      if (ee != null && vv != null && mm != null) {
        _triCtl('gcs').text = '${ee + vv + mm}';
      }
    }

    String pupil(String side) {
      final s = _triPupil[side], r = _triPupil['${side}r'];
      if (s == null && r == null) return '-';
      return '${s == null ? '-' : '$s mm'} ${r ?? ''}'.trim();
    }

    final gcsText = e != null && v != null && m != null
        ? 'GCS ${e + v + m} (E$e V$v M$m)'
        : null;
    return _qCard(
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
        Text('การประเมินระดับความรู้สึกตัว (GCS)',
            style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
        const SizedBox(height: 6.0),
        _qGrid(3, [
          _qPick(
              'การลืมตา',
              Icons.visibility_rounded,
              _triE,
              _triEOpts,
              (x) => setState(() {
                    _triE = x;
                    syncGcs();
                  })),
          _qPick(
              'ตอบสนองการพูด',
              Icons.record_voice_over_rounded,
              _triV,
              _triVOpts,
              (x) => setState(() {
                    _triV = x;
                    syncGcs();
                  })),
          _qPick(
              'การเคลื่อนไหว',
              Icons.back_hand_rounded,
              _triM,
              _triMOpts,
              (x) => setState(() {
                    _triM = x;
                    syncGcs();
                  })),
        ]),
        const SizedBox(height: 12.0),
        Text('รูม่านตา (Pupils)',
            style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
        const SizedBox(height: 6.0),
        _qGrid(2, [
          for (final (side, name) in const [('R', 'ขวา'), ('L', 'ซ้าย')]) ...[
            _qPick('ตา$name ขนาด (mm)', Icons.circle_outlined, _triPupil[side],
                _triPupilSizes, (x) => setState(() => _triPupil[side] = x)),
            _qPick(
                'ตา$name ปฏิกิริยาต่อแสง',
                Icons.flare_rounded,
                _triPupil['${side}r'],
                _triPupilReacts,
                (x) => setState(() => _triPupil['${side}r'] = x)),
          ],
        ]),
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
          _ => false,
        };
    // ช่องกรอกตัวเลข (outlined) ใช้ทั้งแถวและกล่องวัดซ้ำ
    Widget vsInput(String k, String unit, bool red) {
      final node = _triFocus.putIfAbsent(k, FocusNode.new);
      return SizedBox(
        width: 180.0,
        height: 48.0,
        child: TextField(
          controller: _triCtl(k),
          focusNode: node,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          style: _num(18.0,
              color: red ? _red : _inkTitle, weight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: '-',
            hintStyle: _t(16.0, color: _g5),
            // หน่วยแสดงตลอด (suffixText ซ่อนตอนช่องว่าง)
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 14.0),
              child: Text(unit,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0.0),
            filled: true,
            fillColor: red ? _red.withValues(alpha: 0.05) : _panel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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

    // ค่าปกติแสดงใต้ชื่อ (ช่วยตัดสินว่าเกินเกณฑ์ไหม)
    String normal(String k) => switch (k) {
          'sbp' => 'ต่ำกว่า 90 = Shock',
          'hr' => band == null ? '' : 'ปกติไม่เกิน ${band.$2.toInt()}',
          'rr' => band == null ? '' : 'ปกติไม่เกิน ${band.$3.toInt()}',
          'spo2' => 'ต่ำกว่า 92 = ผิดปกติ',
          'bt' => 'เกิน 38 = มีไข้',
          'gcs' => 'ไม่เกิน 12 = ซึม',
          _ => '',
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
        constraints: const BoxConstraints(minHeight: 64.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                Text(label,
                    style: _t(14.0,
                        color: red ? _red : _inkTitle,
                        weight: FontWeight.w500)),
                if (hint.isNotEmpty)
                  Text(hint,
                      style: _t(12.0,
                          color: red ? _red : _ink3, weight: FontWeight.w500)),
              ],
            ),
          ),
          vsInput(k, unit, red),
        ]),
      );
    }

    Widget grid(int cols, List<Widget> kids, {double gap = 8.0}) =>
        LayoutBuilder(builder: (context, bc) {
          final w = (bc.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(spacing: gap, runSpacing: gap, children: [
            for (final k in kids) SizedBox(width: w, child: k),
          ]);
        });

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

    // คะแนนปวด 0–10: ≥ 7 = ESI 2 จึงเป็นสีแดง
    Widget painBtn(int i) {
      final on = _triPain == i;
      final hot = i >= 7;
      final tone = hot ? _red : _blue;
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _triPain = on ? null : i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 44.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? tone : _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text('$i',
                style: _num(15.0,
                    color: on
                        ? Colors.white
                        : hot
                            ? _red
                            : _inkTitle,
                    weight: FontWeight.w700)),
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
    final danger = _triDanger();
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

    final now = DateTime.now();
    return [
      _qCard(
        'สัญญาณชีพ',
        sum: _triVsSum(),
        done: _triVal('hr') != null &&
            _triVal('rr') != null &&
            _triVal('sbp') != null,
        count: 'วัดเวลา ${_clock(_qClock(now))}',
        // ทางลัดกรอก V/S: สแกนจอ monitor (OCR) หรือพูดค่าทั้งชุด
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          _triPill(Icons.document_scanner_rounded, 'สแกนจอ', _triVsScan,
              busy: _triOcrBusy, primary: false),
          const SizedBox(width: 8.0),
          _triPill(Icons.mic_rounded, 'กรอกโดยใช้เสียง', _triVsSpeak),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // กลุ่มอายุ (dangerous zone) คำนวณจากอายุผู้ป่วยเอง ไม่ต้องเลือก
          for (var i = 0; i < _triVsFields.length; i++)
            vsBox(_triVsFields[i], last: i == _triVsFields.length - 1),
          // V/S เกินเกณฑ์: วัดซ้ำ ถ้ากลับมาปกติครบจึงไม่ยกเป็น ESI 2
          if (danger.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                    color:
                        _triRecheckOk() ? _line : _red.withValues(alpha: 0.5)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        _triRecheckOk()
                            ? 'วัดซ้ำแล้วกลับมาปกติ ไม่ยกเป็น ESI 2'
                            : 'V/S เกินเกณฑ์ (${danger.join(', ')}) วัดซ้ำ ถ้ายังเกินจะยกเป็น ESI 2',
                        style: _t(12.0,
                            color: _triRecheckOk() ? _ink2 : _red,
                            weight: FontWeight.w700)),
                    const SizedBox(height: 8.0),
                    for (final f in _triVsFields)
                      if (const ['hr', 'rr', 'spo2'].contains(f.$1))
                        vsBox(('${f.$1}2', '${f.$2} วัดซ้ำ', f.$3),
                            last: f.$1 == 'spo2'),
                  ]),
            ),
          ],
        ]),
      ),
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
                      setState(() => _triType.add(kind));
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
          const SizedBox(height: 12.0),
          Row(children: [
            Text('Pain score',
                style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
            const SizedBox(width: 8.0),
            if (_triPain != null)
              Text('$_triPain/10',
                  style: _num(12.0,
                      color: _triPain! >= 7 ? _red : _inkTitle,
                      weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6.0),
          Row(children: [
            for (var i = 0; i <= 10; i++) ...[
              if (i > 0) const SizedBox(width: 6.0),
              Expanded(child: painBtn(i)),
            ],
          ]),
          // ESI v5: ปวด ≥ 7 "พิจารณา" ESI 2 ไม่ใช่ทุกราย
          // ปวดจากกระดูก/กล้ามเนื้อที่ไม่มีปัญหาเส้นเลือด/ประสาท รอได้
          if ((_triPain ?? 0) >= 7) ...[
            const SizedBox(height: 8.0),
            waive('pain',
                'ปวดจากกระดูก/กล้ามเนื้อ ไม่มีปัญหาเส้นเลือด/ประสาท ให้ยาแก้ปวดแล้วรอได้'),
          ],
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
    ];
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
  Widget _triEsiPanel(int? sug, List<String> why, int? level,
      {Widget? footer, Widget? extra}) {
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
          Text('ระดับความเร่งด่วน',
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 10.0),
          // ยังไม่มีข้อมูล = วงว่าง ไม่แสดงเข็ม
          if (level == null)
            Container(
              height: 108.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _qFlat ? _panel : _panelSoft,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.speed_rounded, size: 30.0, color: _g5),
                const SizedBox(height: 4.0),
                Text('รอข้อมูล',
                    style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
              ]),
            )
          else
            Center(
              child: _EsiGauge(
                level: level,
                width: 180.0,
                mark: _triPick != null ? sug : null,
                center: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('ESI $level',
                      style: _num(24.0,
                          color: esi!.color, weight: FontWeight.w800)),
                  Text(esi.en,
                      style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
                ]),
              ),
            ),
          const SizedBox(height: 12.0),
          Text(
              _triPick != null
                  ? 'เลือกเอง (ระบบแนะนำ ESI ${sug ?? '-'})'
                  : sug == null
                      ? (_triAct.isEmpty
                          ? 'เลือกกิจกรรมที่คาดว่าต้องทำ (ขั้น 3) เพื่อดูระดับแนะนำ'
                          : 'กรอกข้อมูลตรงกลางเพื่อดูระดับแนะนำ')
                      : 'ระบบแนะนำจากข้อมูลที่กรอก',
              style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: (sug ?? 5) <= 2 ? _red : _ink3,
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
              _navBtn(
                  level == null
                      ? 'ยืนยัน ESI และส่งต่อ'
                      : 'ยืนยัน ESI $level และส่งต่อ',
                  Icons.check_rounded,
                  level == null ? null : () => _triSend(level)),
        ],
      ),
    );
  }
}
