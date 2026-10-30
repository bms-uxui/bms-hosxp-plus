/// แค็ตตาล็อกใบสั่ง Lab แบบ HOSxP ใช้ร่วมกันระหว่างหน้าสั่ง Lab และหน้าดูผล Lab
///
/// โครงสร้างเดียวกันทั้งสองฝั่ง: แบบฟอร์ม → ใบสั่ง → รายการ (ชุดตรวจ/profile มีผลย่อย) → ผล
/// หน้าสั่งติ๊กรายการในใบ · ผลแต่ละตัว (`ErLab.at`) บอกว่ามาจากใบไหน ชุดไหน ชื่อผลตาม HOSxP
/// ค่าจำลอง (ลำดับและชื่อตามแบบฟอร์ม THOSxPLabOrderEntryForm) รอดึง lab_form จาก HOSxP
library;

/// ที่มาของผล Lab: ใบสั่ง · ชุดตรวจ (ว่าง = สั่งเป็นรายการเดี่ยว) · ชื่อผลตาม HOSxP
typedef ErLabAt = ({String sheet, String profile, String item});

/// ยังไม่ระบุที่มา (ผลเก่า/คำนวณ) หน้าดูผลจัดไว้ใน "อื่น ๆ"
const ErLabAt erLabNone = (sheet: '', profile: '', item: '');

const erSheetBio = 'ใบสั่ง LAB Biochemistry';
const erSheetHema = 'ใบสั่ง LAB Hematology';
const erSheetBank = 'ใบสั่ง LAB Blood bank';
const erSheetUrine = 'ใบสั่ง LAB Urine';

/// ผลตรวจข้างเตียง (DTX) รายงานผลเอง ไม่ผ่านห้อง Lab ไม่มีสถานะปกติ/ผิดปกติ
const erSheetSelf = 'ใบสั่ง Lab รายงานผลเอง';

const erLabCbc = [
  'WBC',
  'RBC',
  'Hemoglobin',
  'Hematocrit',
  'MCV',
  'MCH',
  'MCHC',
  'RDW',
  'Plt.count',
  'Estimated Platelet',
  'Neutrophils',
  'Lymphocytes',
  'Monocytes',
  'Eosinophils',
  'Basophils',
];

const erLabUa = [
  'Color',
  'Sp.gr',
  'pH',
  'Protein',
  'Glucose',
  'Ketone',
  'Blood',
  'WBC',
  'RBC',
];

/// แบบฟอร์ม → [(ใบสั่ง, [(รายการ, ผลย่อยของชุดตรวจ)])] · มีผลย่อย = ชุดตรวจ (profile)
const Map<String, List<(String, List<(String, List<String>)>)>> erLabForms = {
  // ลำดับและชื่อตามรายการแบบฟอร์มของ HOSxP (THOSxPLabOrderEntryForm)
  'ใบสั่ง Lab รวม Test Standing Order': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('Glucose(Strip)', []),
        ('BUN', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Lipid profile', ['Cholesterol', 'TG', 'HDL', 'LDL']),
        ('LFT', ['AST', 'ALT', 'ALP', 'Bilirubin', 'Albumin']),
        ('Electrolyte', ['Sodium', 'Potassium', 'Chloride', 'Bicarbonate']),
      ]
    ),
    (
      'ใบสั่ง LAB Hematology',
      [
        ('CBC', erLabCbc),
        ('PT-INR (POCT)', []),
        ('VCT', []),
        ('Microfilaria', []),
      ]
    ),
  ],
  'Checkup': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('FBS', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Lipid profile', ['Cholesterol', 'TG', 'HDL', 'LDL']),
        ('LFT', ['AST', 'ALT', 'ALP', 'Bilirubin', 'Albumin']),
      ]
    ),
    ('ใบสั่ง LAB Hematology', [('CBC', erLabCbc)]),
    ('ใบสั่ง LAB Urine', [('UA', erLabUa)]),
  ],
  'Test er ppl xe': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('Glucose(Strip)', []),
        ('BUN', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Electrolyte', ['Sodium', 'Potassium', 'Chloride', 'Bicarbonate']),
        ('Troponin-T', []),
        ('Lactate', []),
      ]
    ),
    (
      'ใบสั่ง LAB Hematology',
      [
        ('CBC', erLabCbc),
        ('PT-INR (POCT)', []),
      ]
    ),
    ('ใบสั่ง LAB Blood bank', [('Type & Crossmatch', [])]),
  ],
  'Test v3': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('BUN', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Electrolyte', ['Sodium', 'Potassium', 'Chloride', 'Bicarbonate']),
      ]
    ),
    ('ใบสั่ง LAB Hematology', [('CBC', erLabCbc)]),
  ],
  'ใบสั่ง LAB ANC': [
    (
      'ใบสั่ง LAB ANC',
      [
        ('CBC', erLabCbc),
        ('Blood group', []),
        ('HIV', []),
        ('HBsAg', []),
        ('VDRL', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Biochemistry': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('Glucose(Strip)', []),
        ('Glucose', []),
        ('FBS', []),
        ('HbA1C', []),
        ('BUN', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Lipid profile', ['Cholesterol', 'TG', 'HDL', 'LDL']),
        ('LFT', ['AST', 'ALT', 'ALP', 'Bilirubin', 'Albumin']),
        ('Electrolyte', ['Sodium', 'Potassium', 'Chloride', 'Bicarbonate']),
        ('Troponin-T', []),
        ('Troponin I', []),
        ('CK-MB', []),
        ('NT-proBNP', []),
        ('Lactate', []),
        ('Ketone', []),
        ('Amylase', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Blood bank': [
    (
      'ใบสั่ง LAB Blood bank',
      [
        ('Blood group', []),
        ('Type & Crossmatch', []),
        ('Antibody screening', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Hematology': [
    (
      'ใบสั่ง LAB Hematology',
      [
        ('CBC', erLabCbc),
        ('PT-INR (POCT)', []),
        ('Coagulogram', ['PT', 'aPTT', 'INR']),
        ('Peripheral blood smear', []),
        ('VCT', []),
        ('Microfilaria', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Urine': [
    (
      'ใบสั่ง LAB Urine',
      [
        ('UA', erLabUa),
        ('Urine pregnancy test', []),
      ]
    ),
  ],
  'ใบสั่ง Lab รายงานผลเอง': [
    (erSheetSelf, [('DTX', [])]),
  ],
  'ใบสั่ง LAB Microbiology': [
    (
      'ใบสั่ง LAB Microbiology',
      [
        ('Hemoculture x2', []),
        ('Sputum Gram stain', []),
        ('Sputum culture', []),
        ('Urine culture', []),
        ('Pus Gram stain', []),
        ('Pus C/S', []),
      ]
    ),
  ],
  // ชุดรวมที่ รพ. ตั้งไว้สำหรับ sepsis (เจาะพร้อมกันครั้งเดียว ออกหลายใบ)
  'ใบสั่ง Lab Sepsis': [
    (
      'ใบสั่ง LAB Biochemistry',
      [
        ('Glucose(Strip)', []),
        ('BUN', []),
        ('Creatinine+eGFR', ['Creatinine', 'eGFR(CKD-EPI)']),
        ('Electrolyte', ['Sodium', 'Potassium', 'Chloride', 'Bicarbonate']),
        ('LFT', ['AST', 'ALT', 'ALP', 'Bilirubin', 'Albumin']),
        ('Lactate', []),
      ]
    ),
    (
      'ใบสั่ง LAB Hematology',
      [
        ('CBC', erLabCbc),
        ('Coagulogram', ['PT', 'aPTT', 'INR']),
      ]
    ),
    ('ใบสั่ง LAB Urine', [('UA', erLabUa)]),
    (
      'ใบสั่ง LAB Microbiology',
      [
        ('Hemoculture x2', []),
        ('Sputum Gram stain', []),
        ('Sputum culture', []),
        ('Urine culture', []),
        ('Pus Gram stain', []),
        ('Pus C/S', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Microscopy': [
    (
      'ใบสั่ง LAB Microscopy',
      [
        ('Stool exam', ['WBC', 'RBC', 'Color', 'Parasite', 'Character']),
        ('Stool occult blood', []),
      ]
    ),
  ],
  'ใบสั่ง LAB Cytology': [
    (
      'ใบสั่ง LAB Cytology',
      [
        ('Pap smear', []),
        ('Fluid cytology', []),
      ]
    ),
  ],
};

/// ที่มาของผลที่ใช้บ่อยในเคสจำลอง (ชื่อย่อในเคส → ใบ/ชุด/ชื่อผลตาม HOSxP)
const ErLabAt erLabWbc = (sheet: erSheetHema, profile: 'CBC', item: 'WBC');
const ErLabAt erLabHb =
    (sheet: erSheetHema, profile: 'CBC', item: 'Hemoglobin');
const ErLabAt erLabPlt =
    (sheet: erSheetHema, profile: 'CBC', item: 'Plt.count');
const ErLabAt erLabInr =
    (sheet: erSheetHema, profile: '', item: 'PT-INR (POCT)');
const ErLabAt erLabPbs =
    (sheet: erSheetHema, profile: '', item: 'Peripheral blood smear');
const ErLabAt erLabBun = (sheet: erSheetBio, profile: '', item: 'BUN');
const ErLabAt erLabCr =
    (sheet: erSheetBio, profile: 'Creatinine+eGFR', item: 'Creatinine');
const ErLabAt erLabEgfr =
    (sheet: erSheetBio, profile: 'Creatinine+eGFR', item: 'eGFR(CKD-EPI)');
const ErLabAt erLabNa =
    (sheet: erSheetBio, profile: 'Electrolyte', item: 'Sodium');
const ErLabAt erLabK =
    (sheet: erSheetBio, profile: 'Electrolyte', item: 'Potassium');
const ErLabAt erLabHco3 =
    (sheet: erSheetBio, profile: 'Electrolyte', item: 'Bicarbonate');
const ErLabAt erLabDtx = (sheet: erSheetSelf, profile: '', item: 'DTX');
const ErLabAt erLabGlu = (sheet: erSheetBio, profile: '', item: 'Glucose');
const ErLabAt erLabLactate = (sheet: erSheetBio, profile: '', item: 'Lactate');
const ErLabAt erLabTropI = (sheet: erSheetBio, profile: '', item: 'Troponin I');
const ErLabAt erLabBnp = (sheet: erSheetBio, profile: '', item: 'NT-proBNP');
const ErLabAt erLabKetone = (sheet: erSheetBio, profile: '', item: 'Ketone');
const ErLabAt erLabBloodGroup =
    (sheet: erSheetBank, profile: '', item: 'Blood group');
const erSheetMicroscopy = 'ใบสั่ง LAB Microscopy';
const ErLabAt erLabStoolWbc =
    (sheet: erSheetMicroscopy, profile: 'Stool exam', item: 'WBC');
const ErLabAt erLabStoolRbc =
    (sheet: erSheetMicroscopy, profile: 'Stool exam', item: 'RBC');
const ErLabAt erLabStoolColor =
    (sheet: erSheetMicroscopy, profile: 'Stool exam', item: 'Color');
const ErLabAt erLabStoolParasite =
    (sheet: erSheetMicroscopy, profile: 'Stool exam', item: 'Parasite');
const ErLabAt erLabStoolChar =
    (sheet: erSheetMicroscopy, profile: 'Stool exam', item: 'Character');
const ErLabAt erLabUaBlood =
    (sheet: erSheetUrine, profile: 'UA', item: 'Blood');

/// ที่มานี้สั่งได้จริงในแค็ตตาล็อกไหม (ใบมีรายการนี้ · ชุดตรวจมีผลนี้)
bool erLabAtValid(ErLabAt a) {
  if (a.sheet.isEmpty) return true;
  for (final sheets in erLabForms.values) {
    for (final (sheet, tests) in sheets) {
      if (sheet != a.sheet) continue;
      for (final (name, results) in tests) {
        if (a.profile.isEmpty
            ? name == a.item
            : name == a.profile && results.contains(a.item)) {
          return true;
        }
      }
    }
  }
  return false;
}

/// ค่าอ้างอิงต่อผล (ชื่อผลตาม HOSxP): หน่วย ช่วงปกติ ค่าจำลองเมื่อเคสไม่มีผลตัวนั้น
/// ผลแบบข้อความ: normal = ค่าปกติที่แสดง (เช่น Adequate, Negative) และใช้เป็นค่าจำลอง
/// show = ผลข้อความจำลอง (ว่าง = เท่าค่าปกติ) · ต่างจากค่าปกติ = ผิดปกติ
/// ผลข้อความมีหน่วยได้ เช่น 2-3 cell/HPF (แบบหน้าผล Microscopy ของ HOSxP)
typedef ErLabRef = ({
  String unit,
  double lo,
  double hi,
  double mock,
  String normal,
  String show,
});

ErLabRef _n(String unit, double lo, double hi, double mock) =>
    (unit: unit, lo: lo, hi: hi, mock: mock, normal: '', show: '');
ErLabRef _txt(String normal, {String unit = '', String show = ''}) =>
    (unit: unit, lo: 0, hi: 0, mock: 0, normal: normal, show: show);

/// สั่งชุดตรวจได้ผลทุกตัวในชุด (CBC 13 ผล, Electrolyte 4 ผล) ตัวที่เคสจำลองไม่มีเติมจากตารางนี้
final Map<String, ErLabRef> erLabRefs = {
  // CBC
  'WBC': _n('×10³/µL', 4.5, 10.0, 8.8),
  'RBC': _n('×10⁶/µL', 4.5, 6.3, 4.8),
  'Hemoglobin': _n('g/dL', 12.0, 16.0, 13.4),
  'Hematocrit': _n('%', 37, 47, 40),
  'MCV': _n('fl', 80, 100, 86),
  'MCH': _n('pg', 26, 34, 29),
  'MCHC': _n('g/dL', 31, 37, 33),
  'Plt.count': _n('×10³/µL', 140, 400, 257),
  'Estimated Platelet': _txt('Adequate'),
  'Neutrophils': _n('%', 40, 70, 58),
  'Lymphocytes': _n('%', 20, 50, 32),
  'Monocytes': _n('%', 2, 10, 6),
  'Eosinophils': _n('%', 1, 5, 3),
  'Basophils': _n('%', 0, 1, 0.5),
  'RDW': _n('%', 11.5, 14.5, 13.2),
  // Biochemistry
  'BUN': _n('mg/dL', 5, 20, 12),
  'Creatinine': _n('mg/dL', 0.6, 1.2, 0.9),
  'eGFR(CKD-EPI)': _n('mL/min/1.73m²', 60, 200, 90),
  'Sodium': _n('mmol/L', 135, 145, 139),
  'Potassium': _n('mmol/L', 3.5, 5.1, 4.0),
  'Chloride': _n('mmol/L', 98, 108, 102),
  'Bicarbonate': _n('mmol/L', 22, 30, 25),
  'Glucose': _n('mg/dL', 70, 140, 98),
  'Lactate': _n('mmol/L', 0.5, 2.0, 1.1),
  'Troponin I': _n('ng/mL', 0, 0.04, 0.01),
  'NT-proBNP': _n('pg/mL', 0, 300, 80),
  'Ketone': _txt('Negative'),
  'DTX': _n('mg/dL', 70, 140, 110),
  // Hematology อื่น
  'PT-INR (POCT)': _n('', 0.8, 1.2, 1.0),
  'PT': _n('sec', 10, 13, 11.8),
  'aPTT': _n('sec', 25, 35, 29),
  'INR': _n('', 0.8, 1.2, 1.0),
  // UA
  'Color': _txt('Yellow'),
  'Sp.gr': _n('', 1.005, 1.030, 1.015),
  'pH': _n('', 5, 8, 6),
  'Protein': _txt('Negative'),
  'Blood': _txt('Negative'),
  // ชื่อผลซ้ำกับชุดอื่น: ใช้คีย์ "ชุด|ผล" (ค้นก่อนชื่อผลอย่างเดียว)
  'UA|Glucose': _txt('Negative'),
  'UA|Ketone': _txt('Negative'),
  'UA|WBC': _txt('0-1'),
  'UA|RBC': _txt('0-1'),
  // Stool exam (ใบ Microscopy): ผลเป็นข้อความ/ช่วง ค่าปกติเป็นข้อความ
  'Stool exam|WBC': _txt('0-1', unit: 'cell/HPF', show: '2-3'),
  'Stool exam|RBC': _txt('0-1', unit: 'cell/HPF', show: '3-5'),
  'Stool exam|Color': _txt('Yellow', show: 'Brown'),
  'Stool exam|Parasite': _txt('Not found'),
  'Stool exam|Character': _txt('Soft'),
  'Stool occult blood': _txt('Negative'),
};

/// หมายเหตุของผล (คอลัมน์หมายเหตุในหน้าผล HOSxP) · ค่าจำลอง
const Map<String, String> erLabNotes = {
  'Stool exam|Color': 'สีน้ำตาลเข้ม',
  'Estimated Platelet': 'ประเมินจากสไลด์',
  'eGFR(CKD-EPI)': 'คำนวณจาก Creatinine อายุ เพศ',
};

/// ค่าอ้างอิงของผล (ชุดตรวจ + ชื่อผล) · ไม่มี = null
ErLabRef? erLabRefOf(ErLabAt a) =>
    erLabRefs['${a.profile}|${a.item}'] ?? erLabRefs[a.item];

/// สิ่งส่งตรวจของรายการ (ข้อมูลการสั่งแบบ HOSxP) · ค่าจำลอง
String erLabSpecimen(String sheet, String test) {
  if (sheet == erSheetSelf) return 'Capillary blood';
  if (sheet == erSheetUrine) return 'Urine 10 ml.';
  if (sheet == erSheetBank) return 'Clotted blood 6 ml.';
  if (sheet.contains('Microscopy') || test.startsWith('Stool')) {
    return 'Stool';
  }
  if (sheet.contains('Microbiology') || test.contains('culture')) {
    return 'Sterile container';
  }
  if (test == 'Coagulogram' || test.startsWith('PT')) {
    return 'Sodium citrate 2.7 ml.';
  }
  if (sheet == erSheetHema || test == 'HbA1C' || test == 'CBC') {
    return 'EDTA 3 ml.';
  }
  return 'Lithium Heparin 3 ml.';
}

/// ค่าบริการต่อรายการ (บาท) · ค่าจำลอง ไม่มีในตาราง = 100
const Map<String, double> erLabPrice = {
  'CBC': 90,
  'BUN': 50,
  'Creatinine+eGFR': 60,
  'Electrolyte': 180,
  'Lipid profile': 200,
  'LFT': 250,
  'Glucose': 40,
  'Glucose(Strip)': 40,
  'DTX': 40,
  'FBS': 40,
  'HbA1C': 150,
  'Lactate': 150,
  'Troponin I': 350,
  'NT-proBNP': 800,
  'Ketone': 60,
  'PT-INR (POCT)': 120,
  'Coagulogram': 250,
  'Peripheral blood smear': 60,
  'Blood group': 80,
  'UA': 60,
  'VCT': 150,
};
