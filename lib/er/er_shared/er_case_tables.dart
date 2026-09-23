/// ตารางข้อมูลจำลองรายแท็บของหน้ารายละเอียดผู้ป่วย ER (pure Dart ไม่มี Flutter)
///
/// ต่อยอดจาก `erCases` (er_cases.dart) ด้วยรายละเอียดเพิ่มต่อ HN: คำสั่งยา
/// แล็บครบชุด ภาพถ่ายรังสี คำสั่งแพทย์ ผลตรวจร่างกายรายระบบ
/// ชื่อคอลัมน์อิงฟอร์ม HOSxP Plus (assets/jsons/er_form_kb.json) และหน้า
/// FlutterFlow ใน lib/er/** — ค่าทั้งหมดกำหนดตายตัว (deterministic)
library;

import 'er_cases.dart';

enum ErTab { overview, triage, exam, orders, vitals, meds, labs, imaging }

/// ชื่อแท็บภาษาไทยตามหน้ารายละเอียดผู้ป่วย
String erTabLabel(ErTab t) => switch (t) {
      ErTab.overview => 'ภาพรวม',
      ErTab.triage => 'คัดกรอง',
      ErTab.exam => 'ตรวจร่างกาย',
      ErTab.orders => 'คำสั่งแพทย์',
      ErTab.vitals => 'สัญญาณชีพ',
      ErTab.meds => 'ยา',
      ErTab.labs => 'แล็บ',
      ErTab.imaging => 'ภาพถ่าย',
    };

/// ตารางพื้นฐาน: หัวคอลัมน์ + แถว + เซลล์ที่ผิดปกติ (row, col)
class ErTable {
  const ErTable({
    required this.title,
    required this.columns,
    required this.rows,
    this.alerts = const {},
  });
  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final Set<(int, int)> alerts;
  bool get isEmpty => rows.isEmpty;
  bool isAlert(int row, int col) => alerts.contains((row, col));
}

/// ตารางหลักของแท็บ (แท็บภาพรวมคืนตาราง "ข้อมูลรับบริการ")
ErTable erTableFor(String hn, ErTab tab) => erTablesFor(hn, tab).first;

/// ทุกตารางของแท็บ — ภาพรวมมีหลายตาราง แท็บอื่นมีตารางเดียว
List<ErTable> erTablesFor(String hn, ErTab tab) {
  final c = erCaseOf(hn);
  final x = _extras[c.hn] ?? const _Extra();
  return switch (tab) {
    ErTab.overview => _overview(c, x),
    ErTab.triage => [_triage(c, x)],
    ErTab.exam => [_exam(c, x)],
    ErTab.orders => [_orders(c, x)],
    ErTab.vitals => [_vitals(c, x)],
    ErTab.meds => [_meds(c, x)],
    ErTab.labs => [_labs(c, x)],
    ErTab.imaging => [_imaging(c, x)],
  };
}

// ======================================================================
// บุคลากร
const _d1 = 'พญ. ศิริพร ก.';
const _d2 = 'นพ. ธีรภัทร อ.';
const _n1 = 'พย. วราภรณ์ ส.';
const _n2 = 'พย. ณัฐพร ล.';
const _rad = 'นพ. กิตติพัฒน์ ร. (รังสีแพทย์)';
const _visitDate = '23/09/2569';

String _doctorOf(ErCase c) {
  for (final (name, role) in c.team) {
    if (role.contains('แพทย์')) return name;
  }
  return _d2;
}

String _bedNurseOf(ErCase c) {
  for (final (name, role) in c.team) {
    if (role == 'พยาบาลประจำเตียง') return name;
  }
  return _n2;
}

// ======================================================================
// โมเดลข้อมูลเสริม

class _Rx {
  const _Rx(this.time, this.name, this.dose, this.route, this.freq, this.qty,
      this.unit, this.status,
      {this.given = '-', this.by = '-', this.orderer, this.o2, this.off});
  final String time, name, dose, route, freq, qty, unit, status, given, by;
  final String? orderer;

  /// ถ้าเป็นออกซิเจน: ข้อความที่แสดงในช่อง O₂ ของตารางสัญญาณชีพ
  final String? o2;

  /// เวลาหยุดออกซิเจน
  final String? off;
}

class _Lx {
  const _Lx(this.time, this.panel, this.test, this.result, this.unit, this.ref,
      this.flag, this.status, this.reported);
  final String time, panel, test, result, unit, ref, flag, status, reported;
}

const _rep = 'รายงานผลแล้ว';
const _col = 'เก็บสิ่งส่งตรวจแล้ว';
const _ord = 'สั่งแล้ว';

String _fmt(num v) {
  if (v == v.roundToDouble() && v.abs() >= 1) return v.round().toString();
  return v.toString();
}

/// ผลตัวเลข: คำนวณ Flag H/L/N จากช่วงอ้างอิง
_Lx _n(String time, String panel, String test, num v, String unit, num lo,
    num hi, String reported,
    {String? ref}) {
  final flag = v > hi ? 'H' : (v < lo ? 'L' : 'N');
  return _Lx(time, panel, test, _fmt(v), unit, ref ?? '${_fmt(lo)}–${_fmt(hi)}',
      flag, _rep, reported);
}

/// ผลข้อความ
_Lx _t(String time, String panel, String test, String result, String unit,
        String ref, String flag, String reported) =>
    _Lx(time, panel, test, result, unit, ref, flag, _rep, reported);

/// ยังไม่มีผล
_Lx _p(String time, String panel, String test, String unit, String ref,
        [String status = _col]) =>
    _Lx(time, panel, test, '-', unit, ref, '-', status, '-');

class _Ix {
  const _Ix(this.time, this.study, this.part, this.status, this.result,
      this.reporter, this.reported,
      {this.abn = false});
  final String time, study, part, status, result, reporter, reported;
  final bool abn;
}

class _Ox {
  const _Ox(this.time, this.cat, this.item, this.detail, this.status,
      {this.by});
  final String time, cat, item, detail, status;
  final String? by;
}

typedef _F = (String, String);
_F _ab(String s) => ('ผิดปกติ', s);
_F _ok(String s) => ('ปกติ', s);

class _Ex {
  const _Ex(this.time, this.by, this.f, {this.full = true});
  final String time, by;
  final Map<String, _F> f;

  /// true = ตรวจครบทุกระบบ (ระบบที่ไม่ระบุใช้ค่าปกติตั้งต้น)
  /// false = ตรวจซ้ำเฉพาะระบบที่ระบุ
  final bool full;
}

class _Extra {
  const _Extra({
    this.esi = 0,
    this.bed = '-',
    this.ptype = 'ผู้ป่วยฉุกเฉิน',
    this.pain,
    this.meds = const [],
    this.labs = const [],
    this.imgs = const [],
    this.orders = const [],
    this.exams = const [],
  });

  /// 0 = ยังไม่คัดกรอง
  final int esi;
  final String bed;
  final String ptype;
  final List<int>? pain;
  final List<_Rx> meds;
  final List<_Lx> labs;
  final List<_Ix> imgs;
  final List<_Ox> orders;
  final List<_Ex> exams;
}

// ======================================================================
// ตรวจร่างกาย: ระบบตามฟอร์ม physical_examination

const _peSystems = [
  'GA',
  'HEENT',
  'Heart',
  'Chest',
  'Abdomen',
  'PR',
  'PV',
  'Genitalia',
  'Neurological',
  'Extremities',
];
const _rosSystems = ['Constitutional', 'Eyes', 'ENT/Mouth'];

const Map<String, _F> _peDefault = {
  'GA': ('ปกติ', 'รู้สึกตัวดี ไม่ซีด ไม่เหลือง ไม่หอบเหนื่อย'),
  'HEENT': ('ปกติ', 'not pale, anicteric, no neck stiffness'),
  'Heart': ('ปกติ', 'regular rhythm, normal S1 S2, no murmur'),
  'Chest': ('ปกติ', 'equal breath sound, clear both lungs'),
  'Abdomen': ('ปกติ', 'soft, not tender, normal bowel sound'),
  'PR': ('ไม่ได้ตรวจ', '-'),
  'PV': ('ไม่ได้ตรวจ', '-'),
  'Genitalia': ('ไม่ได้ตรวจ', '-'),
  'Neurological': ('ปกติ', 'no focal neurological deficit'),
  'Extremities': ('ปกติ', 'no edema, capillary refill < 2 sec'),
  'Constitutional': ('ปกติ', 'ไม่มีไข้ ไม่มีน้ำหนักลด'),
  'Eyes': ('ปกติ', 'ไม่มีตามัว ไม่เห็นภาพซ้อน'),
  'ENT/Mouth': ('ปกติ', 'ไม่เจ็บคอ ไม่มีน้ำมูก'),
};

// ======================================================================
// ข้อมูลเสริมราย HN

const _cbc = 'CBC';
const _ele = 'Electrolyte';
const _rft = 'BUN / Cr';
const _coa = 'Coagulation';
const _poc = 'POCT';

final Map<String, _Extra> _extras = {
  // ---------------------------------------------------------- รอคัดกรอง
  '670123456': _Extra(
    ptype: 'ผู้ป่วย Stroke',
    pain: [0],
    labs: [
      _n('10:09', _poc, 'DTX (Capillary blood glucose)', 156, 'mg/dL', 70, 140,
          '10:10'),
    ],
  ),
  '670123457': _Extra(
    ptype: 'ผู้ป่วย Sepsis',
    labs: [
      _n('10:12', _poc, 'DTX (Capillary blood glucose)', 238, 'mg/dL', 70, 140,
          '10:13'),
    ],
  ),
  '670123458': const _Extra(ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)'),
  '670123459': const _Extra(ptype: 'ผู้ป่วยฉุกเฉิน'),
  '670123460': _Extra(
    ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)',
    labs: [
      _n('10:20', _poc, 'DTX (Capillary blood glucose)', 112, 'mg/dL', 70, 140,
          '10:21'),
    ],
  ),

  // ---------------------------------------------------------- รอตรวจ
  '670123461': _Extra(
    esi: 1,
    bed: 'A3',
    ptype: 'ผู้ป่วย STEMI',
    pain: [8, 8, 6],
    meds: const [
      _Rx('10:00', 'O2 Mask with Reservoir', '10 L/min', 'Inhalation',
          'ต่อเนื่อง', '1', 'SET', 'ให้แล้ว',
          given: '10:00', by: _n2, o2: 'Mask c bag 10 L/min'),
      _Rx('10:01', 'Aspirin 300 mg', '300 mg', 'เคี้ยว (PO)',
          'ครั้งเดียว (stat)', '1', 'TAB', 'ให้แล้ว',
          given: '10:02', by: _n1),
      _Rx('10:05', '0.9% NSS 1,000 mL', '20 mL/hr', 'IV', 'KVO', '1', 'BAG',
          'ให้แล้ว',
          given: '10:06', by: _n2),
      _Rx('10:08', 'Isosorbide dinitrate 5 mg', '5 mg', 'SL (อมใต้ลิ้น)',
          'ทุก 5 นาที ไม่เกิน 3 เม็ด', '3', 'TAB', 'ให้แล้ว',
          given: '10:09', by: _n1),
      _Rx('10:16', 'Morphine 10 mg/mL', '3 mg', 'IV', 'prn ทุก 4 ชม. (ปวด > 5)',
          '1', 'AMP', 'จ่ายแล้ว'),
    ],
    labs: [
      _n('10:03', _cbc, 'Hemoglobin (Hb)', 14.6, 'g/dL', 13, 17, '10:20'),
      _n('10:03', _cbc, 'Hematocrit (Hct)', 44, '%', 40, 54, '10:20'),
      _n('10:03', _cbc, 'WBC', 10.2, '×10³/µL', 4.0, 11.0, '10:20'),
      _n('10:03', _cbc, 'Platelet', 248, '×10³/µL', 150, 400, '10:20'),
      _n('10:03', _ele, 'Sodium (Na)', 138, 'mmol/L', 135, 145, '10:22'),
      _n('10:03', _ele, 'Potassium (K)', 4.1, 'mmol/L', 3.5, 5.1, '10:22'),
      _n('10:03', _ele, 'Chloride (Cl)', 102, 'mmol/L', 98, 107, '10:22'),
      _n('10:03', _ele, 'Bicarbonate (HCO₃)', 22, 'mmol/L', 22, 29, '10:22'),
      _n('10:03', _rft, 'BUN', 16, 'mg/dL', 7, 20, '10:22'),
      _n('10:03', _rft, 'Creatinine (Cr)', 1.0, 'mg/dL', 0.6, 1.2, '10:22'),
      _n('10:03', 'Cardiac enzyme', 'Troponin I', 1.8, 'ng/mL', 0, 0.04,
          '10:18',
          ref: '< 0.04'),
      _n('10:03', 'Cardiac enzyme', 'CK-MB', 28.5, 'ng/mL', 0, 5, '10:18',
          ref: '< 5.0'),
      _n('10:03', _poc, 'DTX (Capillary blood glucose)', 168, 'mg/dL', 70, 140,
          '10:04'),
      _p('10:03', _coa, 'PT', 'sec', '10.5–13.5'),
      _p('10:03', _coa, 'INR', '', '0.8–1.2'),
      _p('10:03', _coa, 'aPTT', 'sec', '25–35'),
    ],
    imgs: const [
      _Ix(
          '10:00',
          'ECG 12 lead',
          'หัวใจ',
          'รายงานผลแล้ว',
          'Sinus tachycardia 102/min, ST elevation 2–3 mm V1–V4, reciprocal ST depression II, III, aVF · Anterior wall STEMI',
          _d2,
          '10:03',
          abn: true),
      _Ix(
          '10:04',
          'CXR (Portable AP)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'Normal heart size, no pulmonary congestion, no widened mediastinum',
          _rad,
          '10:19'),
    ],
    orders: const [
      _Ox('10:00', 'หัตถการ', 'Monitor ECG ต่อเนื่อง',
          'ต่อ cardiac monitor + ติด defibrillator pad', 'ดำเนินการแล้ว'),
      _Ox('10:00', 'พยาบาล', 'Oxygen Sat monitor', 'เป้าหมาย SpO₂ ≥ 94%',
          'ดำเนินการแล้ว'),
      _Ox('10:05', 'หัตถการ', 'IV Line (Angiocath #18)', 'แขนซ้าย 2 เส้น',
          'ดำเนินการแล้ว'),
      _Ox('10:05', 'พยาบาล', 'Monitor VS ทุก 15 นาที',
          'รายงานแพทย์ถ้า SBP < 90', 'ดำเนินการแล้ว'),
      _Ox('10:10', 'Consult', 'Consult Cardiologist',
          'STEMI fast track · ขอ Primary PCI', 'รับคำสั่ง'),
      _Ox('10:10', 'หัตถการ', 'เตรียมส่ง Cath Lab',
          'NPO, เตรียมผิวขาหนีบ 2 ข้าง, เซ็นใบยินยอม', 'รอรับคำสั่ง'),
    ],
    exams: [
      _Ex('10:05', _d2, {
        'GA': _ab('รู้สึกตัวดี เหงื่อออก กระสับกระส่ายจากเจ็บแน่นอก'),
        'HEENT': _ok('not pale, JVP not engorged'),
        'Heart': _ok('regular, HR 100, no murmur, no S3 gallop'),
        'Chest': _ok('clear both lungs, no crepitation'),
        'Extremities': _ok('no edema, pulse full 4 extremities'),
        'Constitutional': _ab('เหงื่อแตก คลื่นไส้'),
      }),
    ],
  ),
  '670123462': _Extra(
    esi: 2,
    bed: 'A4',
    ptype: 'ผู้ป่วย Stroke',
    pain: [0, 0, 0],
    meds: const [
      _Rx('09:50', '0.9% NSS 1,000 mL', '80 mL/hr', 'IV', 'ต่อเนื่อง', '1',
          'BAG', 'ให้แล้ว',
          given: '09:52', by: _n2),
    ],
    labs: [
      _n('09:46', _poc, 'DTX (Capillary blood glucose)', 142, 'mg/dL', 70, 140,
          '09:47'),
      _n('09:48', _cbc, 'Hemoglobin (Hb)', 13.1, 'g/dL', 12, 16, '10:02'),
      _n('09:48', _cbc, 'Hematocrit (Hct)', 39.5, '%', 36, 48, '10:02'),
      _n('09:48', _cbc, 'WBC', 8.6, '×10³/µL', 4.0, 11.0, '10:02'),
      _n('09:48', _cbc, 'Platelet', 265, '×10³/µL', 150, 400, '10:02'),
      _n('09:48', _coa, 'PT', 12.4, 'sec', 10.5, 13.5, '10:05'),
      _n('09:48', _coa, 'INR', 1.1, '', 0.8, 1.2, '10:05'),
      _n('09:48', _coa, 'aPTT', 30.2, 'sec', 25, 35, '10:05'),
      _n('09:48', _ele, 'Sodium (Na)', 139, 'mmol/L', 135, 145, '10:08'),
      _n('09:48', _ele, 'Potassium (K)', 3.9, 'mmol/L', 3.5, 5.1, '10:08'),
      _n('09:48', _ele, 'Chloride (Cl)', 103, 'mmol/L', 98, 107, '10:08'),
      _n('09:48', _ele, 'Bicarbonate (HCO₃)', 24, 'mmol/L', 22, 29, '10:08'),
      _n('09:48', _rft, 'BUN', 18, 'mg/dL', 7, 20, '10:08'),
      _n('09:48', _rft, 'Creatinine (Cr)', 0.9, 'mg/dL', 0.6, 1.2, '10:08'),
      _p('09:48', 'Lipid profile', 'Cholesterol / TG / LDL / HDL', 'mg/dL',
          'LDL < 100'),
    ],
    imgs: const [
      _Ix('09:46', 'CT Brain (non-contrast)', 'สมอง', 'ถ่ายภาพแล้ว รออ่านผล',
          'ภาพอยู่ใน PACS · รอแพทย์อ่านเพื่อตัดสิน rt-PA', '-', '-'),
      _Ix(
          '09:50',
          'ECG 12 lead',
          'หัวใจ',
          'รายงานผลแล้ว',
          'Atrial fibrillation, ventricular rate 88/min, no acute ST-T change',
          _d1,
          '09:55',
          abn: true),
      _Ix('09:50', 'CXR (Portable AP)', 'ทรวงอก', 'สั่งแล้ว', '-', '-', '-'),
    ],
    orders: const [
      _Ox('09:46', 'Consult', 'Consult Neuro / Stroke fast track',
          'แจ้ง Stroke team · NIHSS 9 · onset 08:20', 'ดำเนินการแล้ว'),
      _Ox('09:48', 'หัตถการ', 'ใส่ IV Line (large bore)',
          'Angiocath #18 แขนขวา', 'ดำเนินการแล้ว'),
      _Ox('09:50', 'พยาบาล', 'Monitor BP / GCS',
          'ทุก 15 นาที · BP เป้าหมาย < 185/110', 'ดำเนินการแล้ว'),
      _Ox('09:50', 'พยาบาล', 'NPO', 'งดน้ำงดอาหารจนกว่าประเมินการกลืน',
          'ดำเนินการแล้ว'),
    ],
    exams: [
      _Ex('09:50', _d1, {
        'GA': _ab('รู้สึกตัว พูดไม่ชัด สับสนเล็กน้อย'),
        'Heart': _ab('irregularly irregular, HR 88, no murmur'),
        'Neurological': _ab(
            'Lt hemiparesis: แขนซ้าย motor gr 2/5, ขาซ้าย gr 3/5, Lt facial palsy (UMN), dysarthria · NIHSS 9'),
        'Constitutional': _ok('ไม่มีไข้ ไม่ปวดศีรษะ ไม่ชัก'),
      }),
    ],
  ),
  '670123463': _Extra(
    esi: 2,
    bed: 'B1',
    ptype: 'ผู้ป่วย Sepsis',
    pain: [5, 5, 4, 4],
    meds: const [
      _Rx('09:40', '0.9% NSS 1,000 mL', '1,000 mL', 'IV',
          'bolus ใน 30 นาที (30 mL/kg)', '2', 'BAG', 'ให้แล้ว',
          given: '09:40', by: _n1),
      _Rx('09:42', 'Paracetamol 500 mg', '1,000 mg', 'PO', 'ครั้งเดียว (stat)',
          '2', 'TAB', 'ให้แล้ว',
          given: '09:45', by: _n1),
      _Rx('09:42', 'Ondansetron 4 mg/2 mL', '4 mg', 'IV', 'ครั้งเดียว (stat)',
          '1', 'AMP', 'ให้แล้ว',
          given: '09:45', by: _n1),
      _Rx('10:15', 'Ceftriaxone 1 g', '2 g', 'IV drip ใน 30 นาที',
          'วันละ 1 ครั้ง', '2', 'VIAL', 'จ่ายแล้ว'),
    ],
    labs: [
      _n('09:50', _cbc, 'Hemoglobin (Hb)', 12.4, 'g/dL', 12, 16, '10:05'),
      _n('09:50', _cbc, 'Hematocrit (Hct)', 37.2, '%', 36, 48, '10:05'),
      _n('09:50', _cbc, 'WBC', 18.2, '×10³/µL', 4.0, 11.0, '10:05'),
      _n('09:50', _cbc, 'Neutrophil', 89, '%', 40, 75, '10:05'),
      _n('09:50', _cbc, 'Platelet', 168, '×10³/µL', 150, 400, '10:05'),
      _n('09:50', 'Lactate', 'Lactate', 2.8, 'mmol/L', 0.5, 2.0, '09:56'),
      _n('09:50', _ele, 'Sodium (Na)', 136, 'mmol/L', 135, 145, '10:10'),
      _n('09:50', _ele, 'Potassium (K)', 3.6, 'mmol/L', 3.5, 5.1, '10:10'),
      _n('09:50', _ele, 'Chloride (Cl)', 101, 'mmol/L', 98, 107, '10:10'),
      _n('09:50', _ele, 'Bicarbonate (HCO₃)', 19, 'mmol/L', 22, 29, '10:10'),
      _n('09:50', _rft, 'BUN', 24, 'mg/dL', 7, 20, '10:10'),
      _n('09:50', _rft, 'Creatinine (Cr)', 1.3, 'mg/dL', 0.6, 1.2, '10:10'),
      _n('09:50', _poc, 'DTX (Capillary blood glucose)', 128, 'mg/dL', 70, 140,
          '09:51'),
      _t('09:50', 'UA', 'Urine WBC', '> 100', 'cells/HPF', '0–5', 'H', '10:12'),
      _t('09:50', 'UA', 'Urine RBC', '10–20', 'cells/HPF', '0–2', 'H', '10:12'),
      _t('09:50', 'UA', 'Nitrite', 'Positive', '', 'Negative', 'H', '10:12'),
      _t('09:50', 'UA', 'Leukocyte esterase', '3+', '', 'Negative', 'H',
          '10:12'),
      _p('09:50', 'Blood Culture x2 sites', 'Hemoculture ×2', '',
          'No growth (รอ 48–72 ชม.)'),
      _p('09:50', 'UA / UC', 'Urine culture', '', '< 10⁴ CFU/mL'),
    ],
    imgs: const [
      _Ix(
          '09:50',
          'CXR (PA)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'No infiltration, no pleural effusion, normal heart size',
          _rad,
          '10:10'),
      _Ix('10:15', 'Ultrasound KUB', 'ไต ท่อไต กระเพาะปัสสาวะ', 'สั่งแล้ว', '-',
          '-', '-'),
    ],
    orders: const [
      _Ox('09:40', 'พยาบาล', 'Monitor VS ทุก 15 นาที',
          'รายงานแพทย์ถ้า MAP < 65', 'ดำเนินการแล้ว'),
      _Ox('09:50', 'หัตถการ', 'Draw blood + blood culture',
          'H/C ×2 sites ก่อนเริ่มยาฆ่าเชื้อ', 'ดำเนินการแล้ว'),
      _Ox('09:50', 'หัตถการ', 'Foley catheter',
          'เบอร์ 14 · บันทึก urine output ทุก 1 ชม.', 'ดำเนินการแล้ว'),
    ],
    exams: [
      _Ex('09:50', _d2, {
        'GA': _ab('febrile, looks ill, หนาวสั่น'),
        'HEENT': _ab('dry lips, not pale, anicteric'),
        'Heart': _ab('tachycardia 120, regular, no murmur'),
        'Abdomen': _ab(
            'mild suprapubic tenderness, CVA tenderness ขวา (+), no guarding'),
        'Extremities': _ab('cool extremities, capillary refill 3 sec'),
        'Constitutional': _ab('ไข้สูง หนาวสั่น 3 วัน'),
      }),
      _Ex(
          '10:20',
          _d2,
          {
            'GA': _ab('ยังมีไข้ 38.4 รู้สึกตัวดี'),
            'Extremities': _ok('warm, capillary refill < 2 sec หลังให้สารน้ำ'),
          },
          full: false),
    ],
  ),
  '670123464': const _Extra(
    esi: 3,
    bed: 'โซนนั่งรอ',
    ptype: 'ผู้ป่วยฉุกเฉิน',
    pain: [7, 7],
    orders: [
      _Ox('09:30', 'พยาบาล', 'NPO', 'งดน้ำงดอาหารไว้ก่อน เผื่อทำ ultrasound',
          'ดำเนินการแล้ว',
          by: _n2),
    ],
  ),
  '670123465': const _Extra(
    esi: 3,
    bed: 'โซนนั่งรอ',
    ptype: 'ผู้ป่วยฉุกเฉิน',
    meds: [
      _Rx('09:22', 'Oxygen nasal cannula', '3 L/min', 'Inhalation', 'ต่อเนื่อง',
          '1', 'SET', 'ให้แล้ว',
          given: '09:22', by: _n2, o2: 'Cannula 3 L/min', orderer: _d2),
      _Rx('09:40', 'Salbutamol 2.5 mg/2.5 mL (NB)', '2.5 mg', 'พ่น (Nebulizer)',
          'ทุก 20 นาที × 3 ครั้ง', '3', 'NB', 'ให้แล้ว 1/3',
          given: '09:40', by: _n2, orderer: '$_d2 (standing order)'),
    ],
    orders: [
      _Ox('09:40', 'พยาบาล', 'วัด SpO₂ หลังพ่นยาทุกครั้ง',
          'รายงานถ้า SpO₂ < 92%', 'ดำเนินการแล้ว'),
    ],
  ),
  '670123466': const _Extra(
    esi: 4,
    bed: 'ห้องหัตถการ 2',
    ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)',
    pain: [4],
    orders: [
      _Ox('09:08', 'พยาบาล', 'Wound dressing',
          'ล้างแผล NSS ปิด gauze กดห้ามเลือด', 'ดำเนินการแล้ว',
          by: _n2),
    ],
  ),
  '670123467': _Extra(
    esi: 4,
    bed: 'โซนนั่งรอ',
    ptype: 'ผู้ป่วยตรวจโรคทั่วไป',
    meds: const [
      _Rx('09:12', 'Dimenhydrinate 50 mg/mL', '50 mg', 'IM',
          'ครั้งเดียว (stat)', '1', 'AMP', 'ให้แล้ว',
          given: '09:15', by: _n2, orderer: _d2),
    ],
    labs: [
      _n('08:50', _poc, 'DTX (Capillary blood glucose)', 118, 'mg/dL', 70, 140,
          '08:51'),
    ],
    orders: const [
      _Ox('09:15', 'พยาบาล', 'ป้องกันพลัดตกหกล้ม',
          'ยกราวกั้นเตียง ช่วยพยุงเวลาลุก', 'ดำเนินการแล้ว',
          by: _n2),
    ],
  ),
  '670123468': const _Extra(
    esi: 4,
    bed: 'โซนนั่งรอ',
    ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)',
    pain: [8],
    meds: [
      _Rx('09:50', 'Paracetamol 500 mg', '1,000 mg', 'PO', 'ครั้งเดียว (stat)',
          '2', 'TAB', 'ให้แล้ว',
          given: '09:53', by: _n2, orderer: _d2),
    ],
    imgs: [
      _Ix('09:45', 'X-ray แขน/ขา (Wrist ขวา AP/Lat)', 'ข้อมือขวา', 'สั่งแล้ว',
          '-', '-', '-'),
    ],
    orders: [
      _Ox('09:52', 'หัตถการ', 'Splint ชั่วคราว',
          'Short arm slab ชั่วคราว ยกสูง ประคบเย็น', 'ดำเนินการแล้ว',
          by: _n2),
      _Ox('09:52', 'พยาบาล', 'ประเมิน neurovascular ทุก 30 นาที',
          'radial pulse, capillary refill, sensation ปลายนิ้ว', 'ดำเนินการแล้ว',
          by: _n2),
    ],
  ),

  // ---------------------------------------------------------- ตรวจแล้ว
  '670123469': _Extra(
    esi: 1,
    bed: 'A1',
    ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)',
    pain: [8, 7, 7, 7, 7],
    meds: const [
      _Rx('09:40', 'Omeprazole 40 mg', '40 mg', 'IV', 'วันละ 1 ครั้ง', '1',
          'VIAL', 'ให้แล้ว',
          given: '09:42', by: _n1),
      _Rx('09:52', 'Oxygen nasal cannula', '3 L/min', 'Inhalation', 'ต่อเนื่อง',
          '1', 'SET', 'ให้แล้ว',
          given: '09:52', by: _n1, o2: 'Cannula 3 L/min', off: '10:20'),
      _Rx('09:58', 'Ondansetron 4 mg/2 mL', '4 mg', 'IV', 'ครั้งเดียว (stat)',
          '1', 'AMP', 'ให้แล้ว',
          given: '09:58', by: _n1),
      _Rx('10:05', 'Paracetamol 500 mg', '500 mg', 'PO', 'ทุก 6 ชม.', '1',
          'TAB', 'ให้แล้ว',
          given: '10:05', by: _n1),
      _Rx('10:18', '0.9% NSS 1,000 mL', '1,000 mL', 'IV', 'free flow', '1',
          'BAG', 'ให้แล้ว',
          given: '10:18', by: _n1),
      _Rx('10:20', 'O2 Mask with Reservoir', '10 L/min', 'Inhalation',
          'ต่อเนื่อง', '1', 'SET', 'ให้แล้ว',
          given: '10:20', by: _n1, o2: 'Mask c bag 10 L/min'),
      _Rx('10:22', 'Tranexamic acid 250 mg/5 mL', '1 g', 'IV drip ใน 10 นาที',
          'ครั้งเดียว (stat)', '4', 'AMP', 'สั่งแล้ว'),
      _Rx('10:22', 'PRC (Pack red cell)', '1 unit', 'IV', 'ใน 1 ชม. × 2 unit',
          '2', 'UNIT', 'สั่งแล้ว'),
    ],
    labs: [
      _n('09:30', _cbc, 'Hemoglobin (Hb)', 10.2, 'g/dL', 12, 16, '09:48'),
      _n('09:30', _cbc, 'Hematocrit (Hct)', 30.8, '%', 36, 48, '09:48'),
      _n('09:30', _cbc, 'WBC', 14.8, '×10³/µL', 4.0, 11.0, '09:48'),
      _n('09:30', _cbc, 'Platelet', 220, '×10³/µL', 150, 400, '09:48'),
      _n('09:30', _ele, 'Sodium (Na)', 134, 'mmol/L', 135, 145, '09:55'),
      _n('09:30', _ele, 'Potassium (K)', 3.2, 'mmol/L', 3.5, 5.1, '09:55'),
      _n('09:30', _ele, 'Chloride (Cl)', 100, 'mmol/L', 98, 107, '09:55'),
      _n('09:30', _ele, 'Bicarbonate (HCO₃)', 18, 'mmol/L', 22, 29, '09:55'),
      _n('09:30', _rft, 'BUN', 22, 'mg/dL', 7, 20, '09:55'),
      _n('09:30', _rft, 'Creatinine (Cr)', 1.6, 'mg/dL', 0.6, 1.2, '09:55'),
      _n('09:30', 'Lactate / ABG', 'Lactate', 3.4, 'mmol/L', 0.5, 2.0, '09:50'),
      _n('09:30', _coa, 'PT', 13.8, 'sec', 10.5, 13.5, '10:00'),
      _n('09:30', _coa, 'INR', 1.18, '', 0.8, 1.2, '10:00'),
      _n('09:30', _coa, 'aPTT', 32.0, 'sec', 25, 35, '10:00'),
      _n('09:30', 'Amylase', 'Amylase', 62, 'U/L', 28, 100, '10:02'),
      _t('09:30', 'Blood Type & Crossmatch', 'Blood group / Crossmatch',
          'O Rh+ · PRC 2 unit compatible', '', '-', 'N', '10:15'),
      _n('09:25', _poc, 'DTX (Capillary blood glucose)', 124, 'mg/dL', 70, 140,
          '09:26'),
    ],
    imgs: const [
      _Ix(
          '09:30',
          'CXR (PA)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'ปกติ · no rib fracture, no pneumothorax, no hemothorax',
          _rad,
          '09:55'),
      _Ix('09:30', 'CXR (Lat)', 'ทรวงอก', 'รายงานผลแล้ว', 'ปกติ', _rad,
          '09:55'),
      _Ix(
          '09:30',
          'X-ray Femur ขวา AP/Lat',
          'ต้นขาขวา',
          'รายงานผลแล้ว',
          'Transverse fracture mid-shaft Rt femur, displaced with shortening',
          _rad,
          '10:00',
          abn: true),
      _Ix(
          '09:35',
          'FAST Ultrasound',
          'ช่องท้อง / เยื่อหุ้มหัวใจ',
          'รายงานผลแล้ว',
          'Negative FAST · no free fluid, no pericardial effusion',
          _d1,
          '09:40'),
      _Ix('10:22', 'CT Brain (non-contrast)', 'สมอง',
          'นัดตรวจ 10:40 · ห้องรังสี ชั้น 1', 'รอผลอ่าน', '-', '-'),
    ],
    orders: const [
      _Ox('09:25', 'หัตถการ', 'Immobilize C-spine',
          'คง C-collar จนกว่าแพทย์ clear', 'ดำเนินการแล้ว'),
      _Ox('09:28', 'หัตถการ', 'IV Line x2', 'Angiocath #18 แขน 2 ข้าง',
          'ดำเนินการแล้ว'),
      _Ox('09:30', 'พยาบาล', 'Monitor GCS, pupil', 'ทุก 15 นาที',
          'ดำเนินการแล้ว'),
      _Ox('09:40', 'หัตถการ', 'Long leg slab ขาขวา', 'ดามขาขวา ยกสูง',
          'ดำเนินการแล้ว'),
      _Ox('10:20', 'Consult', 'Consult Neurosurgery',
          'Head injury · รอผล CT brain', 'รับคำสั่ง'),
      _Ox('10:20', 'Consult', 'Consult Orthopedic',
          'Closed fracture shaft femur ขวา', 'รับคำสั่ง'),
      _Ox('10:22', 'หัตถการ', 'Foley catheter (ดู blood)',
          'บันทึก urine output ทุก 1 ชม.', 'รอรับคำสั่ง'),
      _Ox('10:22', 'พยาบาล', 'จองเตียง ICU ศัลยกรรม',
          'เผื่อความดันไม่ขึ้นหลังให้เลือด', 'รอรับคำสั่ง'),
    ],
    exams: [
      _Ex('09:30', _d1, {
        'GA': _ab('รู้สึกตัวดี ปวดศีรษะ อาเจียน 2 ครั้ง'),
        'HEENT': _ab(
            'Scalp hematoma ท้ายทอยขวา 4×3 cm, pupils 3 mm RTLBE, no CSF rhinorrhea/otorrhea'),
        'Chest': _ok('no chest wall tenderness, clear both lungs'),
        'Abdomen': _ab('mild tenderness RLQ, no guarding, no rebound'),
        'Neurological':
            _ok('GCS 15, motor gr 5 ทุกแขนขา, no lateralizing sign'),
        'Extremities': _ab(
            'Rt thigh swelling, deformity, shortening · DP/PT pulse palpable, sensation intact'),
      }),
      _Ex(
          '10:20',
          _d1,
          {
            'GA': _ab('ซีดลง เหงื่อออก ตัวเย็น'),
            'Heart': _ab('tachycardia 121, regular'),
            'Neurological': _ok('GCS 15 คงที่, pupils 3 mm RTLBE'),
            'Extremities': _ab('Rt thigh บวมเพิ่ม, capillary refill 3 sec'),
          },
          full: false),
    ],
  ),
  '670123470': _Extra(
    esi: 2,
    bed: 'A2',
    ptype: 'ผู้ป่วย Sepsis',
    meds: const [
      _Rx('08:45', 'Oxygen nasal cannula', '3 L/min', 'Inhalation', 'ต่อเนื่อง',
          '1', 'SET', 'ให้แล้ว',
          given: '08:45', by: _n2, o2: 'Cannula 3 L/min'),
      _Rx('08:50', '0.9% NSS 1,000 mL', '1,500 mL', 'IV', 'bolus ใน 1 ชม.', '2',
          'BAG', 'ให้แล้ว',
          given: '08:50', by: _n2),
      _Rx('09:20', 'Piperacillin/Tazobactam 4.5 g', '4.5 g',
          'IV drip ใน 30 นาที', 'ทุก 8 ชม.', '1', 'VIAL', 'ให้แล้ว',
          given: '09:25', by: _n2),
      _Rx('09:20', 'Azithromycin 500 mg', '500 mg', 'IV drip ใน 1 ชม.',
          'วันละ 1 ครั้ง', '1', 'VIAL', 'ให้แล้ว',
          given: '09:40', by: _n2),
      _Rx('09:20', 'Berodual (Fenoterol/Ipratropium) NB', '1 NB',
          'พ่น (Nebulizer)', 'ทุก 4 ชม.', '1', 'NB', 'ให้แล้ว',
          given: '09:30', by: _n2),
      _Rx('09:20', 'Paracetamol 500 mg', '1,000 mg', 'PO', 'ทุก 6 ชม. prn ไข้',
          '2', 'TAB', 'ให้แล้ว',
          given: '09:30', by: _n2),
      _Rx('09:50', 'Regular insulin (RI)', '6 unit', 'SC',
          'ตาม DTX sliding scale ทุก 4 ชม.', '1', 'VIAL', 'ให้แล้ว',
          given: '09:55', by: _n2),
    ],
    labs: [
      _n('08:50', _cbc, 'Hemoglobin (Hb)', 11.8, 'g/dL', 12, 16, '09:10'),
      _n('08:50', _cbc, 'Hematocrit (Hct)', 35.6, '%', 36, 48, '09:10'),
      _n('08:50', _cbc, 'WBC', 21.4, '×10³/µL', 4.0, 11.0, '09:10'),
      _n('08:50', _cbc, 'Neutrophil', 91, '%', 40, 75, '09:10'),
      _n('08:50', _cbc, 'Platelet', 142, '×10³/µL', 150, 400, '09:10'),
      _n('08:50', 'Lactate', 'Lactate', 4.1, 'mmol/L', 0.5, 2.0, '08:58'),
      _n('08:50', _ele, 'Sodium (Na)', 132, 'mmol/L', 135, 145, '09:15'),
      _n('08:50', _ele, 'Potassium (K)', 4.4, 'mmol/L', 3.5, 5.1, '09:15'),
      _n('08:50', _ele, 'Chloride (Cl)', 97, 'mmol/L', 98, 107, '09:15'),
      _n('08:50', _ele, 'Bicarbonate (HCO₃)', 17, 'mmol/L', 22, 29, '09:15'),
      _n('08:50', _rft, 'BUN', 38, 'mg/dL', 7, 20, '09:15'),
      _n('08:50', _rft, 'Creatinine (Cr)', 1.9, 'mg/dL', 0.6, 1.2, '09:15'),
      _n('08:50', _poc, 'Blood sugar (DTX)', 268, 'mg/dL', 70, 140, '08:51'),
      _n('08:55', 'ABG', 'pH', 7.29, '', 7.35, 7.45, '09:00'),
      _n('08:55', 'ABG', 'pCO₂', 38, 'mmHg', 35, 45, '09:00'),
      _n('08:55', 'ABG', 'pO₂ (O₂ 3 L/min)', 62, 'mmHg', 80, 100, '09:00'),
      _n('08:55', 'ABG', 'HCO₃ (ABG)', 17.8, 'mmol/L', 22, 26, '09:00'),
      _t(
          '08:55',
          'Sputum',
          'Sputum Gram stain',
          'Gram positive diplococci numerous, PMN > 25/LPF',
          '',
          '-',
          'H',
          '09:40'),
      _p('08:50', 'Blood Culture x2 sites', 'Hemoculture ×2', '',
          'No growth (รอ 48–72 ชม.)'),
      _p('08:55', 'Sputum', 'Sputum culture', '', 'Normal flora'),
      _p('11:00', 'Lactate', 'Lactate ซ้ำ (2 ชม.)', 'mmol/L', '0.5–2.0', _ord),
    ],
    imgs: const [
      _Ix('08:50', 'ECG 12 lead', 'หัวใจ', 'รายงานผลแล้ว',
          'Sinus tachycardia 128/min, no ST-T change', _d2, '08:55',
          abn: true),
      _Ix(
          '08:55',
          'CXR (PA)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'Infiltration RLL, no pleural effusion, hyperinflation (COPD)',
          _rad,
          '09:30',
          abn: true),
    ],
    orders: const [
      _Ox('08:50', 'พยาบาล', 'Monitor VS ทุก 15 นาที',
          'รายงานแพทย์ถ้า MAP < 65', 'ดำเนินการแล้ว'),
      _Ox('08:50', 'หัตถการ', 'Draw blood + blood culture', 'H/C ×2 sites',
          'ดำเนินการแล้ว'),
      _Ox('08:55', 'หัตถการ', 'Foley catheter',
          'เบอร์ 14 · urine output ทุก 1 ชม.', 'ดำเนินการแล้ว'),
      _Ox('09:50', 'Consult', 'Consult ID / ICU', 'Septic shock จาก CAP RLL',
          'ดำเนินการแล้ว'),
      _Ox('09:50', 'Admit', 'จองเตียง ICU อายุรกรรม', 'จองแล้ว · รอย้าย',
          'รับคำสั่ง'),
      _Ox('09:50', 'พยาบาล', 'DTX ทุก 4 ชม.',
          'คุมน้ำตาล 140–180 ด้วย RI sliding scale', 'ดำเนินการแล้ว'),
    ],
    exams: [
      _Ex('08:55', _d2, {
        'GA': _ab('dyspnea, ใช้กล้ามเนื้อช่วยหายใจ, พูดได้เป็นคำ ๆ'),
        'HEENT': _ab('dry lips, not pale'),
        'Heart': _ab('tachycardia 128, regular, no murmur'),
        'Chest': _ab(
            'crepitation + bronchial breath sound RLL, mild wheezing both lungs'),
        'Extremities': _ab('cool, capillary refill 3 sec'),
        'Constitutional': _ab('ไข้ 3 วัน อ่อนเพลีย'),
      }),
      _Ex(
          '10:15',
          _d2,
          {
            'Chest': _ab('crepitation RLL คงเดิม, wheezing ลดลง'),
            'Extremities': _ok('warm, capillary refill < 2 sec'),
          },
          full: false),
    ],
  ),
  '670123471': _Extra(
    esi: 2,
    bed: 'A5',
    ptype: 'ผู้ป่วยฉุกเฉิน',
    meds: const [
      _Rx('08:20', 'Oxygen nasal cannula', '2 L/min', 'Inhalation', 'ต่อเนื่อง',
          '1', 'SET', 'ให้แล้ว',
          given: '08:20', by: _n1, o2: 'Cannula 2 L/min'),
      _Rx('08:30', 'Furosemide 20 mg/2 mL', '40 mg', 'IV', 'ครั้งเดียว (stat)',
          '2', 'AMP', 'ให้แล้ว',
          given: '08:30', by: _n1),
      _Rx('08:35', 'Isosorbide dinitrate 5 mg', '5 mg', 'SL (อมใต้ลิ้น)',
          'ครั้งเดียว', '1', 'TAB', 'ให้แล้ว',
          given: '08:36', by: _n1),
      _Rx('09:05', 'Furosemide 20 mg/2 mL', '40 mg', 'IV', 'ทุก 12 ชม.', '2',
          'AMP', 'สั่งแล้ว'),
    ],
    labs: [
      _n('08:25', _cbc, 'Hemoglobin (Hb)', 11.2, 'g/dL', 13, 17, '08:45'),
      _n('08:25', _cbc, 'Hematocrit (Hct)', 34, '%', 40, 54, '08:45'),
      _n('08:25', _cbc, 'WBC', 7.8, '×10³/µL', 4.0, 11.0, '08:45'),
      _n('08:25', _cbc, 'Platelet', 210, '×10³/µL', 150, 400, '08:45'),
      _n('08:25', _ele, 'Sodium (Na)', 133, 'mmol/L', 135, 145, '08:55'),
      _n('08:25', _ele, 'Potassium (K)', 4.8, 'mmol/L', 3.5, 5.1, '08:55'),
      _n('08:25', _ele, 'Chloride (Cl)', 99, 'mmol/L', 98, 107, '08:55'),
      _n('08:25', _ele, 'Bicarbonate (HCO₃)', 23, 'mmol/L', 22, 29, '08:55'),
      _n('08:25', _rft, 'BUN', 36, 'mg/dL', 7, 20, '08:55'),
      _n('08:25', _rft, 'Creatinine (Cr)', 1.8, 'mg/dL', 0.6, 1.2, '08:55'),
      _n('08:25', 'Cardiac enzyme', 'NT-proBNP', 4200, 'pg/mL', 0, 300, '09:10',
          ref: '< 300'),
      _n('08:25', 'Cardiac enzyme', 'Troponin I', 0.03, 'ng/mL', 0, 0.04,
          '09:05',
          ref: '< 0.04'),
      _n('08:22', _poc, 'DTX (Capillary blood glucose)', 132, 'mg/dL', 70, 140,
          '08:23'),
      _p('10:20', _ele, 'Electrolyte ซ้ำ (หลังให้ Furosemide)', 'mmol/L',
          'K 3.5–5.1', _ord),
    ],
    imgs: const [
      _Ix(
          '08:22',
          'ECG 12 lead',
          'หัวใจ',
          'รายงานผลแล้ว',
          'Sinus tachycardia 104/min, LVH with strain, no acute ST elevation',
          _d1,
          '08:25',
          abn: true),
      _Ix(
          '08:25',
          'CXR (PA)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'Cardiomegaly (CTR 0.62), pulmonary congestion, small bilateral pleural effusion',
          _rad,
          '08:55',
          abn: true),
    ],
    orders: const [
      _Ox('08:20', 'พยาบาล', 'จัดท่านอนศีรษะสูง 45°', 'Monitor SpO₂ ต่อเนื่อง',
          'ดำเนินการแล้ว'),
      _Ox('08:30', 'หัตถการ', 'Foley catheter', 'บันทึก I/O ทุก 1 ชม.',
          'ดำเนินการแล้ว'),
      _Ox('08:30', 'พยาบาล', 'จำกัดน้ำ 1,000 mL/วัน', 'งดเค็ม',
          'ดำเนินการแล้ว'),
      _Ox('09:05', 'Admit', 'สั่ง Admit', 'ตึกอายุรกรรมชาย 1 · Dx ADHF',
          'รับคำสั่ง'),
    ],
    exams: [
      _Ex('08:30', _d1, {
        'GA': _ab('orthopnea, พูดเป็นประโยคสั้น ๆ'),
        'HEENT': _ab('JVP engorged 5 cm above sternal angle'),
        'Heart': _ab('S3 gallop, pansystolic murmur gr II at apex'),
        'Chest': _ab('fine crepitation both lower lungs'),
        'Abdomen': _ok('soft, not tender, liver not palpable'),
        'Extremities': _ab('pitting edema 2+ ขา 2 ข้าง'),
        'Constitutional': _ab('น้ำหนักขึ้น 3 กก. ใน 1 สัปดาห์'),
      }),
      _Ex(
          '10:10',
          _d1,
          {
            'GA': _ok('เหนื่อยลดลง นอนหัวสูงได้'),
            'Chest': _ab('crepitation ลดลง เหลือ basal both lungs'),
          },
          full: false),
    ],
  ),
  '670123472': _Extra(
    esi: 3,
    bed: 'B2',
    ptype: 'ผู้ป่วยฉุกเฉิน',
    meds: const [
      _Rx('09:18', 'Oxygen nasal cannula', '2 L/min', 'Inhalation', 'ต่อเนื่อง',
          '1', 'SET', 'ให้แล้ว',
          given: '09:18', by: _n2, o2: 'Cannula 2 L/min', off: '10:00'),
      _Rx('09:20', 'Salbutamol 2.5 mg/2.5 mL (NB)', '2.5 mg', 'พ่น (Nebulizer)',
          'ทุก 30 นาที × 3 ครั้ง', '3', 'NB', 'ให้แล้ว 2/3',
          given: '09:20, 09:50', by: _n2),
      _Rx('09:25', 'Prednisolone 5 mg', '20 mg', 'PO', 'วันละ 1 ครั้ง', '4',
          'TAB', 'ให้แล้ว',
          given: '09:25', by: _n2),
      _Rx('09:25', 'Paracetamol syrup 120 mg/5 mL', '250 mg (10 mL)', 'PO',
          'ทุก 6 ชม. prn ไข้', '1', 'BOT', 'ให้แล้ว',
          given: '09:30', by: _n2),
    ],
    labs: [
      _t('09:22', 'Rapid test', 'Influenza A/B antigen', 'Negative', '',
          'Negative', 'N', '09:50'),
    ],
    imgs: const [
      _Ix(
          '09:25',
          'CXR (PA)',
          'ทรวงอก',
          'รายงานผลแล้ว',
          'Hyperinflation, peribronchial thickening, no infiltration, no pneumothorax',
          _rad,
          '10:00'),
    ],
    orders: const [
      _Ox('09:18', 'พยาบาล', 'Monitor SpO₂ ต่อเนื่อง', 'เป้าหมาย SpO₂ ≥ 95%',
          'ดำเนินการแล้ว'),
      _Ox('10:15', 'พยาบาล', 'สอนผู้ปกครองใช้ MDI + spacer', 'ก่อนจำหน่าย',
          'รอรับคำสั่ง'),
    ],
    exams: [
      _Ex('09:22', _d2, {
        'GA': _ab(
            'mild–moderate respiratory distress, suprasternal retraction, พูดได้เป็นวลี'),
        'HEENT': _ab('injected pharynx, clear rhinorrhea'),
        'Heart': _ab('tachycardia 132, regular, no murmur'),
        'Chest': _ab(
            'expiratory wheezing both lungs, prolonged expiration, subcostal retraction'),
        'Constitutional': _ab('ไข้ 1 วัน'),
        'ENT/Mouth': _ab('ไอ มีน้ำมูก'),
      }),
      _Ex(
          '10:18',
          _d2,
          {
            'GA': _ok('ไม่มี respiratory distress เล่นได้'),
            'Chest': _ab('mild expiratory wheezing both lungs, no retraction'),
          },
          full: false),
    ],
  ),

  // ---------------------------------------------------------- รอออก
  '670123473': _Extra(
    esi: 3,
    bed: 'B3',
    ptype: 'ผู้ป่วยตรวจโรคทั่วไป',
    pain: [8, 4, 2],
    meds: [
      const _Rx('09:12', 'Metoclopramide 10 mg/2 mL', '10 mg', 'IV',
          'ครั้งเดียว (stat)', '1', 'AMP', 'ให้แล้ว',
          given: '09:15', by: _n1),
      const _Rx('09:12', 'Ketorolac 30 mg/mL', '30 mg', 'IV',
          'ครั้งเดียว (stat)', '1', 'AMP', 'ให้แล้ว',
          given: '09:15', by: _n1),
      const _Rx('10:00', 'Paracetamol 500 mg (กลับบ้าน)', '1–2 เม็ด', 'PO',
          'ทุก 6 ชม. เมื่อปวด', '20', 'TAB', 'สั่งแล้ว'),
      const _Rx('10:00', 'Naproxen 250 mg (กลับบ้าน)', '1 เม็ด', 'PO',
          'วันละ 2 ครั้ง หลังอาหาร เมื่อปวด', '10', 'TAB', 'สั่งแล้ว'),
      const _Rx('10:00', 'Domperidone 10 mg (กลับบ้าน)', '1 เม็ด', 'PO',
          'ก่อนอาหาร 3 เวลา เมื่อคลื่นไส้', '10', 'TAB', 'สั่งแล้ว'),
    ],
    orders: [
      const _Ox('09:10', 'พยาบาล', 'จัดห้องมืด เงียบ', 'ลดแสง ลดเสียงกระตุ้น',
          'ดำเนินการแล้ว'),
      const _Ox('10:00', 'จำหน่าย', 'สั่งจำหน่ายกลับบ้าน',
          'นัด OPD อายุรกรรมประสาท 2 สัปดาห์', 'ดำเนินการแล้ว'),
    ],
    exams: [
      _Ex('09:10', _d1, {
        'GA': _ab('ปวดศีรษะ 8/10 หลบแสง'),
        'HEENT': _ok('no neck stiffness, fundi: no papilledema'),
        'Neurological':
            _ok('cranial nerves intact, motor gr 5 ทุกแขนขา, no focal deficit'),
        'Eyes': _ab('photophobia'),
      }),
      _Ex(
          '10:00',
          _d1,
          {
            'GA': _ok('ปวดลดลงเหลือ 2/10 เดินได้ ไม่คลื่นไส้'),
          },
          full: false),
    ],
  ),
  '670123474': _Extra(
    esi: 4,
    bed: 'B4',
    ptype: 'ผู้ป่วยอุบัติเหตุ (Trauma)',
    pain: [5, 3],
    meds: [
      const _Rx('09:35', 'Paracetamol 500 mg', '1,000 mg', 'PO',
          'ครั้งเดียว (stat)', '2', 'TAB', 'ให้แล้ว',
          given: '09:38', by: _n2),
      const _Rx('09:55', 'Elastic bandage 4 นิ้ว', '1 ม้วน', 'ภายนอก', '-', '1',
          'ม้วน', 'ให้แล้ว',
          given: '09:58', by: _n2),
      const _Rx('09:55', 'ไม้ค้ำยัน (Axillary crutches)', '1 คู่', '-', '-',
          '1', 'คู่', 'ให้แล้ว',
          given: '09:58', by: _n2),
      const _Rx('09:55', 'Ibuprofen 400 mg (กลับบ้าน)', '1 เม็ด', 'PO',
          'วันละ 3 ครั้ง หลังอาหาร', '15', 'TAB', 'จ่ายแล้ว'),
      const _Rx('09:55', 'Paracetamol 500 mg (กลับบ้าน)', '1–2 เม็ด', 'PO',
          'ทุก 6 ชม. เมื่อปวด', '10', 'TAB', 'จ่ายแล้ว'),
    ],
    imgs: [
      const _Ix(
          '09:35',
          'X-ray แขน/ขา (Ankle ซ้าย AP/Lat/Mortise)',
          'ข้อเท้าซ้าย',
          'รายงานผลแล้ว',
          'No fracture, soft tissue swelling lateral malleolus',
          _d2,
          '09:45'),
    ],
    orders: [
      const _Ox('09:55', 'หัตถการ', 'Elastic bandage ข้อเท้าซ้าย',
          'พันแบบ figure-of-8', 'ดำเนินการแล้ว'),
      const _Ox('09:55', 'พยาบาล', 'สอนเดินไม้ค้ำยัน',
          'non-weight bearing 3 วัน', 'ดำเนินการแล้ว'),
      const _Ox(
          '09:55',
          'จำหน่าย',
          'สั่งจำหน่ายกลับบ้าน',
          'RICE 48 ชม. · นัดออร์โธปิดิกส์ 1 สัปดาห์ถ้ายังลงน้ำหนักไม่ได้',
          'ดำเนินการแล้ว'),
    ],
    exams: [
      _Ex('09:32', _d2, {
        'Extremities': _ab(
            'Lt ankle swelling lateral malleolus, tender ATFL, ลงน้ำหนักไม่ได้ 4 ก้าว, anterior drawer mildly positive, DP pulse palpable'),
      }),
    ],
  ),
  '670123475': _Extra(
    esi: 2,
    bed: 'B5',
    ptype: 'ผู้ป่วยฉุกเฉิน',
    meds: const [
      _Rx('08:30', '0.9% NSS 1,000 mL', '1,000 mL', 'IV',
          'free flow แล้ว 100 mL/hr', '1', 'BAG', 'ให้แล้ว',
          given: '08:32', by: _n1),
      _Rx('08:40', 'Omeprazole 40 mg', '80 mg', 'IV bolus', 'ครั้งเดียว (stat)',
          '2', 'VIAL', 'ให้แล้ว',
          given: '08:40', by: _n1),
      _Rx('08:40', 'Omeprazole 40 mg + NSS 100 mL', '8 mg/hr', 'IV drip',
          'ต่อเนื่อง 72 ชม.', '5', 'VIAL', 'ให้แล้ว',
          given: '08:45', by: _n1),
      _Rx('09:05', 'PRC (Pack red cell)', '1 unit', 'IV', 'ใน 2 ชม.', '1',
          'UNIT', 'กำลังให้',
          given: '09:30', by: _n1),
    ],
    labs: [
      _n('08:35', _cbc, 'Hemoglobin (Hb)', 7.8, 'g/dL', 12, 16, '08:55'),
      _n('08:35', _cbc, 'Hematocrit (Hct)', 23.6, '%', 36, 48, '08:55'),
      _n('08:35', _cbc, 'WBC', 11.4, '×10³/µL', 4.0, 11.0, '08:55'),
      _n('08:35', _cbc, 'Platelet', 198, '×10³/µL', 150, 400, '08:55'),
      _n('08:35', _rft, 'BUN', 42, 'mg/dL', 7, 20, '09:05'),
      _n('08:35', _rft, 'Creatinine (Cr)', 1.1, 'mg/dL', 0.6, 1.2, '09:05'),
      _n('08:35', _ele, 'Sodium (Na)', 137, 'mmol/L', 135, 145, '09:05'),
      _n('08:35', _ele, 'Potassium (K)', 4.0, 'mmol/L', 3.5, 5.1, '09:05'),
      _n('08:35', _ele, 'Chloride (Cl)', 104, 'mmol/L', 98, 107, '09:05'),
      _n('08:35', _ele, 'Bicarbonate (HCO₃)', 21, 'mmol/L', 22, 29, '09:05'),
      _n('08:35', _coa, 'PT', 12.8, 'sec', 10.5, 13.5, '09:00'),
      _n('08:35', _coa, 'INR', 1.08, '', 0.8, 1.2, '09:00'),
      _n('08:35', _coa, 'aPTT', 31.0, 'sec', 25, 35, '09:00'),
      _n('08:35', 'LFT', 'AST', 28, 'U/L', 0, 40, '09:10'),
      _n('08:35', 'LFT', 'ALT', 22, 'U/L', 0, 40, '09:10'),
      _n('08:35', 'LFT', 'Albumin', 3.4, 'g/dL', 3.5, 5.2, '09:10'),
      _t('08:35', 'Blood Type & Crossmatch', 'Blood group / Crossmatch',
          'AB Rh+ · PRC 2 unit compatible', '', '-', 'N', '09:20'),
      _p('10:30', _cbc, 'Hct ซ้ำ (หลังให้ PRC)', '%', '36–48', _ord),
    ],
    imgs: const [
      _Ix('08:35', 'ECG 12 lead', 'หัวใจ', 'รายงานผลแล้ว',
          'Sinus tachycardia 118/min, no ischemic change', _d1, '08:38',
          abn: true),
      _Ix('08:45', 'CXR (Portable AP)', 'ทรวงอก', 'รายงานผลแล้ว',
          'No free air under diaphragm, normal heart size', _rad, '09:15'),
    ],
    orders: const [
      _Ox('08:30', 'หัตถการ', 'IV Line x2', 'Angiocath #18 แขน 2 ข้าง',
          'ดำเนินการแล้ว'),
      _Ox('08:30', 'พยาบาล', 'NPO · Monitor VS ทุก 15 นาที',
          'งดยา NSAIDs · สังเกตถ่ายดำ/อาเจียนเป็นเลือด', 'ดำเนินการแล้ว'),
      _Ox('08:40', 'หัตถการ', 'NG Tube', 'NG lavage: coffee ground 150 mL',
          'ดำเนินการแล้ว'),
      _Ox('09:00', 'Consult', 'Consult Surgery',
          'ขอ EGD · ไม่มีแพทย์ส่องกล้องในเวร', 'ดำเนินการแล้ว'),
      _Ox('09:10', 'Refer', 'Refer ทางกาย · รพ.ศูนย์',
          'ส่องกล้อง EGD · Glasgow-Blatchford score 13', 'ดำเนินการแล้ว'),
      _Ox('10:00', 'พยาบาล', 'เตรียมเอกสารส่งตัว',
          'แนบผลแล็บ + ECG ไปกับใบ Refer', 'รับคำสั่ง'),
    ],
    exams: [
      _Ex('08:40', _d1, {
        'GA': _ab('pale, อ่อนเพลีย, ตัวเย็น'),
        'HEENT': _ab('markedly pale conjunctivae, anicteric'),
        'Heart': _ab('tachycardia 118, regular, no murmur'),
        'Abdomen': _ab(
            'mild epigastric tenderness, no guarding, no stigmata of chronic liver disease'),
        'PR': _ab('melena on glove, no mass'),
        'Extremities': _ab('cold, capillary refill 3 sec'),
        'Constitutional': _ab('หน้ามืด อ่อนเพลีย 2 วัน'),
      }),
      _Ex(
          '10:00',
          _d1,
          {
            'GA': _ab('ดีขึ้น ยังซีด'),
            'Heart': _ok('HR 98, regular'),
            'Extremities': _ok('warm, capillary refill < 2 sec'),
          },
          full: false),
    ],
  ),
};

// ======================================================================
// ภาพรวม

const _esiLabel = {
  0: 'รอคัดกรอง',
  1: 'ESI 1 · ภาวะวิกฤต',
  2: 'ESI 2 · เร่งด่วน',
  3: 'ESI 3 · เร่งด่วนปานกลาง',
  4: 'ESI 4 · อาการไม่รุนแรงมาก',
  5: 'ESI 5 · ไม่เร่งด่วน',
};

const _icdFallback = {
  'คลื่นไส้ อาเจียน': 'R11',
  'ความดันโลหิตสูง': 'I10',
  'ปวดท้องด้านขวาล่าง': 'R10.3',
  'COPD': 'J44.9',
  'โรคไตเรื้อรังระยะ 3': 'N18.3',
};

/// โรคประจำตัว → (ICD-10, ยาที่ใช้ประจำ)
const _underlyingInfo = {
  'ความดันโลหิตสูง': ('I10', 'Amlodipine 5 mg วันละ 1 ครั้ง'),
  'เบาหวานชนิดที่ 2': ('E11.9', 'Metformin 500 mg วันละ 2 ครั้ง'),
  'ไขมันในเลือดสูง': ('E78.5', 'Simvastatin 20 mg ก่อนนอน'),
  'ไตเรื้อรังระยะ 3': ('N18.3', 'งดยากลุ่ม NSAIDs'),
  'ไตเรื้อรัง': ('N18.9', 'งดยากลุ่ม NSAIDs'),
  'สูบบุหรี่ 20 มวน/วัน': ('F17.2', '-'),
  'หัวใจเต้นผิดจังหวะ AF': (
    'I48.9',
    'Digoxin 0.125 mg วันละ 1 ครั้ง · ไม่ได้ใช้ยาต้านการแข็งตัวของเลือด'
  ),
  'หอบหืด': ('J45.9', 'Budesonide/Formoterol 160/4.5 พ่นวันละ 2 ครั้ง'),
  'กระดูกพรุน': ('M81.9', 'Calcium carbonate 1,000 mg + Vitamin D'),
  'หัวใจล้มเหลว EF 35%': (
    'I50.9',
    'Enalapril 5 mg วันละ 2 ครั้ง, Carvedilol 6.25 mg วันละ 2 ครั้ง, Furosemide 40 mg เช้า'
  ),
  'COPD': ('J44.9', 'Tiotropium 18 mcg สูดวันละ 1 ครั้ง'),
  'ไมเกรน': ('G43.9', 'Paracetamol 500 mg เมื่อปวด'),
  'ข้อเข่าเสื่อม': (
    'M17.9',
    'Naproxen 250 mg วันละ 2 ครั้ง (ซื้อกินเอง) · หยุดยา'
  ),
};

/// สิ่งที่แพ้ → (ประเภท, อาการ, ความรุนแรง)
const _allergyInfo = {
  'Penicillin': ('ยา', 'ผื่นลมพิษ หน้าบวม', 'รุนแรง'),
  'Sulfa': ('ยา', 'ผื่นแดงคันทั้งตัว', 'ปานกลาง'),
  'NSAIDs': ('ยา', 'หอบกำเริบ', 'รุนแรง'),
  'กุ้ง': ('อาหาร', 'ผื่นลมพิษ คัน', 'ปานกลาง'),
  'ปู': ('อาหาร', 'ผื่นลมพิษ คัน', 'ปานกลาง'),
  'ถั่วลิสง': ('อาหาร', 'ปากบวม', 'ปานกลาง'),
};

String _arrivalTime(ErCase c) {
  final ts = [...c.times, ...c.events.map((e) => e.time)]..sort();
  return ts.isEmpty ? '-' : ts.first;
}

(int, int, int)? _evm(String? g) {
  if (g == null) return null;
  final m = RegExp(r'E(\d).*V(\d).*M(\d)').firstMatch(g);
  if (m == null) return null;
  return (
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!)
  );
}

String _gcsShort(String? g) {
  final e = _evm(g);
  if (e == null) return '-';
  final (a, b, d) = e;
  return 'E$a V$b M$d = ${a + b + d}';
}

// ======================================================================
// คัดกรอง: ตามฟอร์ม patient_screening ของ HOSxP ครบทุก section
const _esiChip = {
  1: 'ภาวะวิกฤต',
  2: 'เร่งด่วน',
  3: 'เร่งด่วนปานกลาง',
  4: 'อาการไม่รุนแรงมาก',
  5: 'ไม่เร่งด่วน',
};
const _eOpt = {
  1: 'E1 ไม่ลืมเลย(ไม่มีการตอบสนอง)',
  2: 'E2 ลืมเมื่อเจ็บ',
  3: 'E3 ลืมตาเมื่อถูกเรียก',
  4: 'E4 ลืมตาได้เอง',
};
const _vOpt = {
  1: 'V1 ไม่ออกเสียงเลย',
  2: 'V2 ส่งเสียงไม่เป็นคำ',
  3: 'V3 พูดเป็นคำๆ',
  4: 'V4 พูดคุยได้แต่สับสน',
  5: 'V5 พูดคุยได้แต่ไม่สับสน',
};
const _mOpt = {
  1: 'M1 ไม่เคลื่อนไหว',
  2: 'M2 แขนมี Ab.ext',
  3: 'M3 แขนที่ Ab.flex',
  4: 'M4 ชักแขนขาหนี',
  5: 'M5 ทราบตำแหน่งที่ได้รับบาดเจ็บ',
  6: 'M6 ทำตามคำสั่งได้',
};

String _shiftOf(String hhmm) {
  final h = int.tryParse(hhmm.split(':').first) ?? 9;
  if (h >= 8 && h < 16) return 'เช้า (08:00:00-15:59:59)';
  if (h >= 16) return 'บ่าย (16:00:00-23:59:59)';
  return 'ดึก (00:00:01-07:59:59)';
}

String _bringer(String arrival) {
  if (arrival.contains('BLS')) return 'หน่วยกู้ชีพ ระดับพื้นฐาน (BLS)';
  if (arrival.contains('ALS')) return 'หน่วยกู้ชีพ ระดับสูง (ALS)';
  if (arrival.contains('ILS')) return 'หน่วยกู้ชีพ ระดับกลาง (ILS)';
  if (arrival.contains('ญาติ')) return 'ญาติ';
  if (arrival.contains('ส่งต่อ')) return 'รถพยาบาลโรงพยาบาลต้นทาง';
  return 'มาเอง';
}

/// น้ำหนัก/ส่วนสูงโดยประมาณตามเพศ-อายุ เยื้องตาม HN ให้แต่ละคนไม่ซ้ำกัน
(double, int) _bodySize(ErCase c) {
  final d = int.parse(c.hn.substring(c.hn.length - 2)) % 7;
  if (c.age < 12) return (18.0 + c.age * 2.2 + d, 100 + c.age * 5 + d);
  final male = c.sex.contains('ชาย');
  return male ? (62.0 + d * 2.5, 164 + d * 2) : (50.0 + d * 2.2, 152 + d * 2);
}

ErTable _triage(ErCase c, _Extra x) {
  final t = _arrivalTime(c);
  final triaged = x.esi > 0;
  String v(List<double> s, [int dp = 0]) =>
      s.isEmpty ? '-' : s.first.toStringAsFixed(dp);
  final (wt, ht) = _bodySize(c);
  final evm = _evm(c.gcs);
  final pupil = evm != null && evm.$1 + evm.$2 + evm.$3 < 15
      ? '3 mm · React (ตอบสนองช้า)'
      : '3 mm · React';
  final rows = <List<String>>[
    ['ข้อมูลรับเข้า', 'วันที่เข้าห้องฉุกเฉิน', _visitDate],
    ['ข้อมูลรับเข้า', 'เวลาที่เข้าห้องฉุกเฉิน', t == '-' ? '-' : '$t น.'],
    ['ข้อมูลรับเข้า', 'เวร', t == '-' ? '-' : _shiftOf(t)],
    ['ข้อมูลรับเข้า', 'สภาพผู้ป่วย', c.condition],
    ['ข้อมูลการมา', 'ประเภทการมา', c.arrival],
    [
      'ข้อมูลการมา',
      'มาจากหน่วยบริการ',
      c.arrival.contains('ส่งต่อ') ? 'โรงพยาบาลชุมชน' : '-'
    ],
    ['ข้อมูลการมา', 'ผู้นำส่ง', _bringer(c.arrival)],
    ['ประเภทผู้ป่วย', 'ประเภทผู้ป่วย', triaged ? x.ptype : 'รอประเมิน'],
    ['อาการสำคัญ', 'อาการสำคัญ', c.cc],
    ['Vital Sign', 'น้ำหนัก (kg)', wt.toStringAsFixed(1)],
    ['Vital Sign', 'ส่วนสูง (cm)', '$ht'],
    ['Vital Sign', 'อุณหภูมิ (°C)', v(c.bt, 1)],
    [
      'Vital Sign',
      'ความดัน (mmHg)',
      c.sbp.isEmpty ? '-' : '${v(c.sbp)}/${v(c.dbp)}'
    ],
    ['Vital Sign', 'อัตราการเต้นชีพจร (/min)', v(c.hr)],
    ['Vital Sign', 'อัตราการหายใจ (/min)', v(c.rr)],
    ['Vital Sign', 'ออกซิเจนในเลือด (%)', v(c.spo2)],
    ['Vital Sign', 'ความรู้สึกตัว', c.consciousness],
    [
      'การประเมินระดับความรู้สึกตัว (GCS)',
      'การลืมตา',
      evm == null ? 'ยังไม่ประเมิน' : _eOpt[evm.$1]!
    ],
    [
      'การประเมินระดับความรู้สึกตัว (GCS)',
      'ตอบสนองการพูด',
      evm == null ? 'ยังไม่ประเมิน' : _vOpt[evm.$2]!
    ],
    [
      'การประเมินระดับความรู้สึกตัว (GCS)',
      'การเคลื่อนไหว',
      evm == null ? 'ยังไม่ประเมิน' : _mOpt[evm.$3]!
    ],
    [
      'ระดับความเจ็บปวด',
      'ระดับความเจ็บปวด (0-10)',
      c.painScore == null ? '0' : '${c.painScore}'
    ],
    ['รูม่านตา (Pupils)', 'ด้านซ้าย (L)', evm == null ? '-' : pupil],
    ['รูม่านตา (Pupils)', 'ด้านขวา (R)', evm == null ? '-' : pupil],
    [
      'ระดับความเร่งด่วน (ESI)',
      'ระดับความเร่งด่วน (ESI)',
      triaged ? 'ESI ${x.esi} · ${_esiChip[x.esi]}' : 'รอประเมิน'
    ],
    [
      'ผู้คัดกรอง',
      'พยาบาลคัดกรอง / เวลา',
      triaged || c.times.isNotEmpty ? '$_n2 · $t น.' : '-'
    ],
  ];
  // เซลล์ผิดปกติ (คอลัมน์ค่า = 2)
  final alerts = <(int, int)>{};
  double? num(String s) => double.tryParse(s.split('/').first);
  for (var i = 0; i < rows.length; i++) {
    final label = rows[i][1];
    final n = num(rows[i][2]);
    final bad = switch (label) {
      'อุณหภูมิ (°C)' => n != null && n >= 37.5,
      'ความดัน (mmHg)' => n != null && (n >= 160 || n < 90),
      'อัตราการเต้นชีพจร (/min)' => n != null && (n > 100 || n < 60),
      'อัตราการหายใจ (/min)' => n != null && (n > 22 || n < 10),
      'ออกซิเจนในเลือด (%)' => n != null && n < 94,
      'ระดับความเจ็บปวด (0-10)' => n != null && n >= 7,
      'ความรู้สึกตัว' => rows[i][2] != 'ตื่นดี',
      'ระดับความเร่งด่วน (ESI)' => x.esi == 1 || x.esi == 2,
      _ => false,
    };
    if (bad) alerts.add((i, 2));
  }
  return ErTable(
    title: 'แบบคัดกรอง (Patient Screening)',
    columns: const ['หมวด', 'รายการ', 'ข้อมูล'],
    rows: rows,
    alerts: alerts,
  );
}

List<ErTable> _overview(ErCase c, _Extra x) {
  // ---- ข้อมูลรับบริการ
  final info = <(String, String)>[
    ('HN', c.hn),
    ('เพศ / อายุ', '${c.sex} · ${c.age} ปี'),
    ('หมู่เลือด', c.bloodGroup),
    ('สิทธิการรักษา', c.right),
    ('วันที่-เวลาเข้าห้องฉุกเฉิน', '$_visitDate ${_arrivalTime(c)} น.'),
    ('เวร', 'เช้า (08:00:00-15:59:59)'),
    ('ประเภทการมา', c.arrival),
    ('สภาพผู้ป่วย', c.condition),
    ('ประเภทผู้ป่วย', x.ptype),
    ('อาการสำคัญ', c.cc),
    ('HPI', c.hpi.isEmpty ? '-' : c.hpi),
    ('เวลาเริ่มอาการ', c.onset == null ? '-' : '${c.onset} น.'),
    ('ระดับความเร่งด่วน (ESI)', _esiLabel[x.esi]!),
    ('ความรู้สึกตัว', c.consciousness),
    ('GCS', _gcsShort(c.gcs)),
    ('ระดับความเจ็บปวด', c.painScore == null ? '-' : '${c.painScore}/10'),
    ('เตียง', x.bed),
    ('แพทย์เจ้าของไข้', x.exams.isEmpty ? 'รอแพทย์ตรวจ' : _doctorOf(c)),
    ('พยาบาล', _bedNurseOf(c)),
    (
      'ขั้นตอนถัดไป',
      c.nextDetail.isEmpty ? c.nextStep : '${c.nextStep} · ${c.nextDetail}'
    ),
    (
      'สภาพผู้ป่วยออกจากห้อง ER',
      c.disposition.isEmpty ? 'ยังไม่ตัดสิน' : c.disposition
    ),
  ];
  final infoAlerts = <(int, int)>{};
  for (var i = 0; i < info.length; i++) {
    final k = info[i].$1;
    if (k.startsWith('ระดับความเร่งด่วน') && (x.esi == 1 || x.esi == 2)) {
      infoAlerts.add((i, 1));
    }
    if (k == 'GCS') {
      final e = _evm(c.gcs);
      if (e != null && e.$1 + e.$2 + e.$3 < 15) infoAlerts.add((i, 1));
    }
    if (k == 'ระดับความเจ็บปวด' && (c.painScore ?? 0) >= 7) {
      infoAlerts.add((i, 1));
    }
  }
  final t1 = ErTable(
    title: 'ข้อมูลรับบริการ / คัดกรอง',
    columns: const ['รายการ', 'ข้อมูล'],
    rows: [
      for (final (k, v) in info) [k, v]
    ],
    alerts: infoAlerts,
  );

  // ---- การวินิจฉัย
  final provisional = x.exams.isEmpty;
  final dxRows = <List<String>>[];
  final dxAlerts = <(int, int)>{};
  for (var i = 0; i < c.dx.length; i++) {
    final d = c.dx[i];
    final type = provisional
        ? 'Provisional (คัดกรอง)'
        : i == 0
            ? 'Principal diagnosis'
            : (c.underlying.any((u) => d.text.contains(u) || u.contains(d.text))
                ? 'Comorbidity'
                : 'Other diagnosis');
    final level = switch (d.level) {
      ErLevel.critical => 'วิกฤต',
      ErLevel.urgent => 'เร่งด่วน',
      ErLevel.normal => 'ทั่วไป',
    };
    if (d.level == ErLevel.critical) dxAlerts.add((i, 4));
    dxRows.add([
      '${i + 1}',
      type,
      d.icd10 ?? _icdFallback[d.text] ?? '-',
      d.text,
      level,
    ]);
  }
  final t2 = ErTable(
    title: 'การวินิจฉัย (Diagnosis)',
    columns: const ['ลำดับ', 'ประเภท', 'ICD-10', 'Diagnosis Text', 'ระดับ'],
    rows: dxRows,
    alerts: dxAlerts,
  );

  // ---- แพ้ยา/อาหาร
  final alRows = <List<String>>[];
  final alAlerts = <(int, int)>{};
  for (var i = 0; i < c.allergies.length; i++) {
    final a = c.allergies[i];
    final (type, sym, sev) = _allergyInfo[a] ?? ('ยา', '-', '-');
    alRows.add([a, type, sym, sev, 'ผู้ป่วย/ญาติแจ้ง · บันทึกใน HOSxP']);
    alAlerts.add((i, 0));
  }
  final t3 = ErTable(
    title: 'รายการแพ้ยา / อาหาร',
    columns: const [
      'สิ่งที่แพ้',
      'ประเภท',
      'อาการที่แพ้',
      'ความรุนแรง',
      'แหล่งข้อมูล'
    ],
    rows: alRows,
    alerts: alAlerts,
  );

  // ---- โรคประจำตัว
  final t4 = ErTable(
    title: 'โรคประจำตัว',
    columns: const ['โรคประจำตัว', 'ICD-10', 'ยาที่ใช้ประจำ'],
    rows: [
      for (final u in c.underlying)
        [u, _underlyingInfo[u]?.$1 ?? '-', _underlyingInfo[u]?.$2 ?? '-']
    ],
  );

  // ---- ลำดับเหตุการณ์
  final doc = _doctorOf(c);
  final nurse = _bedNurseOf(c);
  final ev = <(String, String, String, String)>[
    for (final e in c.events)
      (
        e.time,
        e.text,
        e.byDoctor ? 'แพทย์' : 'พยาบาล',
        e.byDoctor ? doc : nurse
      ),
    if (c.lastNote != null)
      (
        c.lastNote!.time,
        'บันทึกทางการพยาบาล: ${c.lastNote!.text}',
        'พยาบาล',
        c.lastNote!.by
      ),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  final t5 = ErTable(
    title: 'ลำดับเหตุการณ์ (Timeline)',
    columns: const ['เวลา', 'เหตุการณ์', 'ประเภท', 'ผู้บันทึก'],
    rows: [
      for (final (t, s, k, b) in ev) [t, s, k, b]
    ],
  );

  return [t1, t2, t3, t4, t5];
}

// ======================================================================
// ตรวจร่างกาย

ErTable _exam(ErCase c, _Extra x) {
  final rows = <List<String>>[];
  final alerts = <(int, int)>{};
  for (var r = 0; r < x.exams.length; r++) {
    final ex = x.exams[r];
    final round = 'รอบ ${r + 1} · ${ex.time}';
    void add(String group, String sys) {
      final f = ex.f[sys] ?? (ex.full ? _peDefault[sys] : null);
      if (f == null) return;
      if (f.$1 == 'ผิดปกติ') {
        alerts.add((rows.length, 3));
        alerts.add((rows.length, 4));
      }
      rows.add([round, group, sys, f.$1, f.$2, ex.by]);
    }

    for (final s in _peSystems) {
      add('ตรวจร่างกาย', s);
    }
    for (final s in _rosSystems) {
      add('Review of System', s);
    }
  }
  return ErTable(
    title: 'ผลตรวจร่างกายรายระบบ (PE / ROS)',
    columns: const [
      'รอบ / เวลา',
      'หมวด',
      'ระบบ',
      'ผลตรวจ',
      'รายละเอียด',
      'ผู้ตรวจ'
    ],
    rows: rows,
    alerts: alerts,
  );
}

// ======================================================================
// สัญญาณชีพ

String _o2At(_Extra x, String time) {
  String? cur;
  for (final m in x.meds) {
    if (m.o2 == null) continue;
    if (m.given == '-' || m.given.compareTo(time) > 0) continue;
    if (m.off != null && m.off!.compareTo(time) <= 0) continue;
    cur = m.o2; // รายการหลังสุดชนะ
  }
  return cur ?? 'Room air';
}

ErTable _vitals(ErCase c, _Extra x) {
  final child = c.age < 12;
  final rows = <List<String>>[];
  final alerts = <(int, int)>{};
  final nurse = _bedNurseOf(c);
  final gcsDefault = _gcsShort(c.gcs);
  for (var i = 0; i < c.times.length; i++) {
    final hr = c.hr[i], sbp = c.sbp[i], dbp = c.dbp[i];
    final spo2 = c.spo2[i], rr = c.rr[i], bt = c.bt[i];
    final pain = x.pain != null && i < x.pain!.length
        ? x.pain![i]
        : (i == c.times.length - 1 ? c.painScore : null);
    final gcs = gcsDefault;
    final r = rows.length;
    if (bt >= 37.5 || bt < 36.0) alerts.add((r, 1));
    if (child ? (hr > 120 || hr < 70) : (hr > 100 || hr < 50)) {
      alerts.add((r, 2));
    }
    if (child ? (rr > 25 || rr < 15) : (rr > 22 || rr < 10)) alerts.add((r, 3));
    if (sbp < 90 || sbp >= 160 || dbp >= 100) alerts.add((r, 4));
    if (spo2 < 94) alerts.add((r, 5));
    if ((pain ?? 0) >= 7) alerts.add((r, 7));
    final e = _evm(c.gcs);
    if (e != null && e.$1 + e.$2 + e.$3 < 15) alerts.add((r, 8));
    rows.add([
      c.times[i],
      bt.toStringAsFixed(1),
      '${hr.round()}',
      '${rr.round()}',
      '${sbp.round()}/${dbp.round()}',
      '${spo2.round()}',
      _o2At(x, c.times[i]),
      pain == null ? '-' : '$pain',
      gcs,
      i == 0 ? _n2 : nurse,
    ]);
  }
  return ErTable(
    title: 'บันทึกค่า Vital Sign',
    columns: const [
      'เวลา',
      'อุณหภูมิ (°C)',
      'ชีพจร (/min)',
      'หายใจ (/min)',
      'ความดัน (mmHg)',
      'SpO₂ (%)',
      'O₂ support',
      'Pain (0–10)',
      'GCS (E/V/M)',
      'ผู้บันทึก',
    ],
    rows: rows,
    alerts: alerts,
  );
}

// ======================================================================
// ยา

ErTable _meds(ErCase c, _Extra x) {
  final doc = _doctorOf(c);
  final list = [...x.meds]..sort((a, b) => a.time.compareTo(b.time));
  final alerts = <(int, int)>{};
  for (var i = 0; i < list.length; i++) {
    if (list[i].status == 'สั่งแล้ว') alerts.add((i, 8));
  }
  return ErTable(
    title: 'Medication Order (สั่งยา/เวชภัณฑ์)',
    columns: const [
      'เวลาสั่ง',
      'รายการยา/เวชภัณฑ์',
      'Dose',
      'Route',
      'ความถี่',
      'จำนวน',
      'หน่วยบรรจุ',
      'ผู้สั่ง',
      'สถานะ',
      'เวลาให้',
      'ผู้ให้',
    ],
    rows: [
      for (final m in list)
        [
          m.time,
          m.name,
          m.dose,
          m.route,
          m.freq,
          m.qty,
          m.unit,
          m.orderer ?? doc,
          m.status,
          m.given,
          m.by,
        ]
    ],
    alerts: alerts,
  );
}

// ======================================================================
// แล็บ

ErTable _labs(ErCase c, _Extra x) {
  final list = [...x.labs]..sort((a, b) => a.time.compareTo(b.time));
  final alerts = <(int, int)>{};
  for (var i = 0; i < list.length; i++) {
    if (list[i].flag == 'H' || list[i].flag == 'L') {
      alerts.add((i, 3));
      alerts.add((i, 6));
    }
  }
  return ErTable(
    title: 'ผลตรวจทางห้องปฏิบัติการ (Lab)',
    columns: const [
      'เวลาสั่ง',
      'กลุ่ม',
      'รายการ Lab',
      'ผลตรวจ',
      'หน่วย',
      'ค่าอ้างอิง',
      'Flag',
      'สถานะ',
      'เวลารายงาน',
    ],
    rows: [
      for (final l in list)
        [
          l.time,
          l.panel,
          l.test,
          l.result,
          l.unit.isEmpty ? '-' : l.unit,
          l.ref,
          l.flag,
          l.status,
          l.reported,
        ]
    ],
    alerts: alerts,
  );
}

// ======================================================================
// ภาพถ่าย

ErTable _imaging(ErCase c, _Extra x) {
  final list = [...x.imgs]..sort((a, b) => a.time.compareTo(b.time));
  final alerts = <(int, int)>{};
  for (var i = 0; i < list.length; i++) {
    if (list[i].abn) alerts.add((i, 4));
  }
  return ErTable(
    title: 'Radiology Report (X-ray / CT / US / ECG)',
    columns: const [
      'เวลาสั่ง',
      'รายการตรวจ',
      'ส่วนที่ตรวจ',
      'สถานะ',
      'ผลอ่าน / Impression',
      'ผู้รายงาน',
      'เวลารายงาน',
    ],
    rows: [
      for (final m in list)
        [m.time, m.study, m.part, m.status, m.result, m.reporter, m.reported]
    ],
    alerts: alerts,
  );
}

// ======================================================================
// คำสั่งแพทย์ — รวมยา แล็บ (ตามกลุ่ม) ภาพถ่าย และคำสั่งอื่น

String _medOrderStatus(String s) => s.startsWith('ให้แล้ว') || s == 'กำลังให้'
    ? 'ดำเนินการแล้ว'
    : s == 'จ่ายแล้ว'
        ? 'รับคำสั่ง'
        : 'รอรับคำสั่ง';

ErTable _orders(ErCase c, _Extra x) {
  final doc = _doctorOf(c);
  final rows = <(String, String, String, String, String, String)>[];

  for (final m in x.meds) {
    rows.add((
      m.time,
      'ยา/เวชภัณฑ์',
      m.name,
      '${m.dose} · ${m.route} · ${m.freq}',
      m.orderer ?? doc,
      _medOrderStatus(m.status),
    ));
  }

  // แล็บรวมเป็นคำสั่งตามกลุ่ม (เวลา + กลุ่ม)
  final groups = <(String, String), List<_Lx>>{};
  for (final l in x.labs) {
    groups.putIfAbsent((l.time, l.panel), () => []).add(l);
  }
  groups.forEach((k, ls) {
    final allRep = ls.every((l) => l.status == _rep);
    final anyCol = ls.any((l) => l.status != _ord);
    final poct = k.$2 == _poc;
    rows.add((
      k.$1,
      'Lab',
      k.$2,
      ls.map((l) => l.test).join(', '),
      poct ? _n2 : doc,
      allRep ? 'ดำเนินการแล้ว' : (anyCol ? 'รับคำสั่ง' : 'รอรับคำสั่ง'),
    ));
  });

  for (final m in x.imgs) {
    rows.add((
      m.time,
      m.study.startsWith('ECG') ? 'ECG' : 'X-ray',
      m.study,
      m.part,
      doc,
      m.status == 'รายงานผลแล้ว'
          ? 'ดำเนินการแล้ว'
          : m.status == 'สั่งแล้ว'
              ? 'รอรับคำสั่ง'
              : 'รับคำสั่ง',
    ));
  }

  for (final o in x.orders) {
    rows.add((o.time, o.cat, o.item, o.detail, o.by ?? doc, o.status));
  }

  rows.sort((a, b) => a.$1.compareTo(b.$1));
  final alerts = <(int, int)>{};
  for (var i = 0; i < rows.length; i++) {
    if (rows[i].$6 == 'รอรับคำสั่ง') alerts.add((i, 5));
  }
  return ErTable(
    title: 'บันทึกคำสั่งแพทย์',
    columns: const [
      'เวลา',
      'ประเภท',
      'รายการ',
      'รายละเอียด',
      'ผู้สั่ง',
      'สถานะ'
    ],
    rows: [
      for (final r in rows) [r.$1, r.$2, r.$3, r.$4, r.$5, r.$6]
    ],
    alerts: alerts,
  );
}
