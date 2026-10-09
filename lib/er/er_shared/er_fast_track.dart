/// Master data ของ ER fast track: กลุ่มโรค เกณฑ์เปิด จุดเวลาที่ต้องบันทึก และ KPI
///
/// ที่มาและลิงก์เอกสารครบ: หน้าแฟ้ม ER Fast Track (artifact) · ตรวจกับต้นฉบับ 9 ต.ค. 2569
/// ที่มา (ดู docs/knowledge.md ข้อ 54):
/// - แนวทางปัจจุบัน: AHA/ASA (Stroke), AHA/ESC (STEMI), Surviving Sepsis Campaign
///   Hour-1 bundle (Sepsis), ATLS/CRASH-2 (Trauma)
/// - ACTEP 2014 fast track (พญ.พรทิพา ตันติบัณฑิต รพ.ขอนแก่น): เกณฑ์เปิด Stroke,
///   door-to-OR ของ Trauma, ชุด Head injury
/// - ช่องเวลาในแท็บ "การรับเข้าห้องฉุกเฉิน" ของ HOSxP (hosxp = รหัสช่องเดิม)
///
/// เป้าเวลาเป็นค่าตั้งต้น รพ. ปรับเองได้ (ยังไม่มีหน้าตั้งค่า) · ข้อมูลยังไม่ผ่านทีมคลินิกยืนยัน
library;

/// จุดเวลาหนึ่งจุดที่ต้องบันทึก
class ErFtItem {
  const ErFtItem(this.id, this.label,
      {this.when, this.hosxp, this.auto = false});

  /// รหัสภายใน (ใช้ใน KPI) ไม่ซ้ำภายในกลุ่ม
  final String id;
  final String label;

  /// null = บังคับทุกเคสในกลุ่มนี้ · มีค่า = ทำเมื่อเข้าเงื่อนไขนี้ (เลือก "ไม่ได้ทำ" ได้)
  final String? when;

  /// ชื่อช่องเดิมในแท็บ "การรับเข้าห้องฉุกเฉิน" ของ HOSxP (null = HOSxP ยังไม่มี)
  final String? hosxp;

  /// true = ได้จากข้อมูลอื่นอยู่แล้ว (เช่น เวลามาถึง ER จากการลงทะเบียน) ไม่ต้องกรอก
  final bool auto;
}

/// ตัวชี้วัด: เวลาจาก [from] ถึง [to] (รหัส item ในกลุ่มเดียวกัน หรือ 'door')
class ErFtKpi {
  const ErFtKpi(this.label, this.from, this.to,
      {this.maxMin, this.before = false, this.source = 'แนวทางปัจจุบัน'});

  /// ชื่อ KPI เช่น Door-to-CT
  final String label;
  final String from;
  final String to;

  /// เป้าไม่เกินกี่นาที (null = ติดตามอย่างเดียว ไม่มีเป้า)
  final int? maxMin;

  /// true = เกณฑ์ลำดับ: [from] ต้องเกิดก่อน [to] (เช่น เก็บ culture ก่อนให้ยา)
  final bool before;
  final String source;
}

/// กลุ่ม fast track หนึ่งโรค
class ErFastTrack {
  const ErFastTrack({
    required this.id,
    required this.name,
    required this.criteria,
    required this.items,
    required this.kpis,
  });

  final String id;
  final String name;

  /// เกณฑ์เปิด fast track (ข้อความแสดงให้ผู้ใช้)
  final List<String> criteria;
  final List<ErFtItem> items;
  final List<ErFtKpi> kpis;

  /// KPI ที่ปลายทางคือ item นี้ (ไว้บอกเป้าใต้ชื่อ item)
  ErFtKpi? kpiTo(String itemId) {
    for (final k in kpis) {
      if (k.to == itemId && k.maxMin != null) return k;
    }
    return null;
  }
}

/// จุดตั้งต้นร่วมทุกกลุ่ม: เวลามาถึง ER (จากการลงทะเบียน)
const ErFtItem erFtDoor =
    ErFtItem('door', 'เวลามาถึง ER', auto: true, hosxp: 'เวลามาถึง');

const List<ErFastTrack> erFastTracks = [
  ErFastTrack(
    id: 'stroke',
    name: 'Stroke',
    criteria: [
      'แขนขาอ่อนแรงซีกเดียว เกิดทันที',
      'พูดไม่ชัด พูดไม่ได้ หรือฟังไม่เข้าใจ เกิดทันที',
      'เวียนศีรษะ เดินเซ เกิดทันที',
      'มองเห็นภาพซ้อน หรือตามัวข้างเดียว เกิดทันที',
      'เริ่มอาการไม่เกิน 4.5 ชม.',
    ],
    items: [
      ErFtItem('onset', 'เวลาเริ่มอาการ (Last known well)'),
      ErFtItem('assess', 'เวลาประเมินแรกรับ'),
      ErFtItem('md', 'เวลาแพทย์ประเมิน'),
      ErFtItem('ct', 'เวลาเริ่ม CT/MRI สมอง', hosxp: 'เวลาเริ่ม CT/MRI สมอง'),
      ErFtItem('ctread', 'เวลาอ่านผล CT'),
      ErFtItem('lab', 'เวลาส่ง Lab'),
      ErFtItem('rtpa', 'ให้ยาละลายลิ่มเลือด (rt-PA)',
          when: 'ให้ยา', hosxp: 'ได้รับ ยาละลายลิ่มเลือด'),
      ErFtItem('groin', 'เริ่มใส่อุปกรณ์ลากลิ่มเลือด (EVT)', when: 'ทำ EVT'),
      ErFtItem('out', 'ส่งต่อออก', when: 'ส่งต่อ'),
    ],
    kpis: [
      ErFtKpi('Door-to-assessment', 'door', 'assess',
          maxMin: 5, source: 'ACTEP 2014'),
      ErFtKpi('Door-to-physician', 'door', 'md',
          maxMin: 10, source: 'NINDS / AHA Target: Stroke'),
      // Target: Stroke ขั้นสูงใช้ ≤ 20
      ErFtKpi('Door-to-CT', 'door', 'ct',
          maxMin: 25, source: 'NINDS / AHA/ASA 2019'),
      // Target: Stroke ขั้นสูงใช้ ≤ 35
      ErFtKpi('Door-to-CT read', 'door', 'ctread', maxMin: 45, source: 'NINDS'),
      ErFtKpi('Door-to-lab', 'door', 'lab', maxMin: 30, source: 'ACTEP 2014'),
      // สธ. ปีงบ 2569 วัดสัดส่วนที่ทำได้ ≥ ร้อยละ 60
      ErFtKpi('Door-to-needle', 'door', 'rtpa',
          maxMin: 60, source: 'AHA Target: Stroke / Health KPI สธ.'),
      ErFtKpi('Onset-to-needle', 'onset', 'rtpa',
          maxMin: 270, source: 'AHA/ASA 2019'),
      // ส่งต่อมาจาก รพ.อื่น ≤ 60
      ErFtKpi('Door-to-device', 'door', 'groin',
          maxMin: 90, source: 'AHA Target: Stroke'),
      ErFtKpi('Door-in-door-out', 'door', 'out',
          maxMin: 120, source: 'Brain Attack Coalition'),
    ],
  ),
  ErFastTrack(
    id: 'stemi',
    name: 'STEMI',
    criteria: [
      'เจ็บแน่นหน้าอก หรืออาการเทียบเท่า',
      'ECG 12 lead มี ST elevation หรือ LBBB ใหม่',
    ],
    items: [
      ErFtItem('onset', 'เวลาเริ่มเจ็บหน้าอก'),
      ErFtItem('fmc', 'เวลาพบบุคลากรครั้งแรก (FMC)', when: 'มาด้วยรถพยาบาล'),
      ErFtItem('ecg', 'เวลาทำ ECG 12 lead', hosxp: 'เวลาทำ ECG 12 lead'),
      ErFtItem('dx', 'เวลาวินิจฉัย STEMI (อ่าน ECG)'),
      ErFtItem('lytic', 'ให้ยาละลายลิ่มเลือด',
          when: 'ให้ยา', hosxp: 'ได้รับ ยาละลายลิ่มเลือด'),
      ErFtItem('cath', 'เวลาเรียก Cath lab', when: 'ทำ PCI'),
      ErFtItem('balloon', 'ทำบอลลูน (Primary PCI)',
          when: 'ทำ PCI', hosxp: 'ทำบอลลูน (STEMI)'),
      ErFtItem('out', 'ส่งต่อออก', when: 'ส่งต่อ'),
    ],
    kpis: [
      ErFtKpi('Symptom-to-door', 'onset', 'door'),
      ErFtKpi('Door-to-ECG', 'door', 'ecg',
          maxMin: 10, source: 'ESC 2023 / ACCF/AHA 2013'),
      ErFtKpi('Door-to-needle', 'door', 'lytic',
          maxMin: 30, source: 'ACCF/AHA 2013'),
      // สธ. นับจากวินิจฉัยด้วย ECG (ESC ใช้ < 10)
      ErFtKpi('Diagnosis-to-needle', 'dx', 'lytic',
          maxMin: 30, source: 'Health KPI สธ.'),
      ErFtKpi('Door-to-cath lab', 'door', 'cath',
          maxMin: 60, source: 'ACTEP 2014'),
      ErFtKpi('Door-to-balloon', 'door', 'balloon',
          maxMin: 90, source: 'ACCF/AHA 2013'),
      ErFtKpi('Diagnosis-to-PCI', 'dx', 'balloon',
          maxMin: 120, source: 'Health KPI สธ.'),
      // ส่งต่อ ≤ 120
      ErFtKpi('FMC-to-device', 'fmc', 'balloon',
          maxMin: 90, source: 'ACCF/AHA 2013'),
      ErFtKpi('Door-in-door-out', 'door', 'out',
          maxMin: 30, source: 'ESC 2023'),
    ],
  ),
  ErFastTrack(
    id: 'sepsis',
    name: 'Sepsis',
    criteria: [
      'สงสัยติดเชื้อ',
      // SSC 2021/2026: ไม่ใช้ qSOFA เป็นเครื่องมือคัดกรองเดี่ยว
      'คัดกรองด้วย NEWS/NEWS2, MEWS หรือ SIRS',
      'ความดันต่ำ หรือ Lactate ≥ 2 mmol/L',
    ],
    items: [
      // SSC 2018: time zero = เวลาคัดกรองที่ ER
      ErFtItem('zero', 'เวลาวินิจฉัย Sepsis (time zero)',
          hosxp: 'เวลาวินิจฉัย Sepsis'),
      ErFtItem('lactate', 'เวลาเจาะ Lactate'),
      ErFtItem('culture', 'เวลาเก็บ Blood culture'),
      ErFtItem('atb', 'ให้ยา Antibiotics', hosxp: 'ได้รับยา Antibiotics'),
      ErFtItem('fluid', 'เริ่มให้สารน้ำ 30 ml/kg',
          when: 'ความดันต่ำ หรือ Lactate ≥ 4'),
      ErFtItem('vaso', 'เริ่มยากระตุ้นความดัน', when: 'MAP < 65 ระหว่างหรือหลังให้สารน้ำ'),
      ErFtItem('lactate2', 'เจาะ Lactate ซ้ำ', when: 'Lactate ครั้งแรก > 2'),
    ],
    kpis: [
      ErFtKpi('Time-to-lactate', 'zero', 'lactate',
          maxMin: 60, source: 'SSC 2018'),
      ErFtKpi('Culture ก่อน ATB', 'culture', 'atb',
          before: true, source: 'SSC 2018 / Health KPI สธ.'),
      // septic shock หรือ probable/definite sepsis · สงสัยแต่ไม่มี shock ≤ 180
      ErFtKpi('Time-to-antibiotics', 'zero', 'atb',
          maxMin: 60, source: 'SSC 2026 / Health KPI สธ.'),
      // สธ. ให้ครบ 30 ml/kg ในชั่วโมงแรก
      ErFtKpi('Time-to-fluid', 'zero', 'fluid',
          maxMin: 60, source: 'SSC 2018 / Health KPI สธ.'),
      ErFtKpi('Time-to-vasopressor', 'zero', 'vaso',
          maxMin: 60, source: 'SSC 2018'),
      ErFtKpi('Repeat lactate', 'lactate', 'lactate2',
          maxMin: 240, source: 'SSC 2018'),
    ],
  ),
  ErFastTrack(
    id: 'trauma',
    name: 'Trauma',
    criteria: [
      'บาดเจ็บรุนแรงเข้าเกณฑ์ trauma activation',
      'สัญญาณชีพผิดปกติ หรือ GCS ≤ 13',
      'กลไกการบาดเจ็บรุนแรง',
    ],
    items: [
      ErFtItem('injury', 'เวลาเกิดเหตุ'),
      ErFtItem('team', 'เวลาเรียกทีม Trauma'),
      ErFtItem('fast', 'เวลาทำ FAST', when: 'ทำ FAST'),
      ErFtItem('txa', 'ให้ Tranexamic acid', when: 'มีเลือดออก'),
      ErFtItem('blood', 'เริ่มให้เลือด', when: 'ให้เลือด'),
      ErFtItem('ct', 'เวลาเริ่ม CT', when: 'ทำ CT'),
      ErFtItem('or', 'เข้าห้องผ่าตัด', when: 'ผ่าตัด'),
      ErFtItem('out', 'ส่งต่อออก', when: 'ส่งต่อ'),
    ],
    kpis: [
      ErFtKpi('Injury-to-door', 'injury', 'door'),
      ErFtKpi('Door-to-FAST', 'door', 'fast'),
      ErFtKpi('Injury-to-TXA', 'injury', 'txa', maxMin: 180, source: 'CRASH-2'),
      ErFtKpi('Door-to-CT', 'door', 'ct'),
      ErFtKpi('Door-to-OR', 'door', 'or', maxMin: 30, source: 'ACTEP 2014'),
      ErFtKpi('Door-in-door-out', 'door', 'out'),
    ],
  ),
  ErFastTrack(
    id: 'head',
    name: 'Head injury',
    criteria: [
      'บาดเจ็บที่ศีรษะ',
      'GCS ≤ 13 หรือ ซึมลง ชัก อาเจียนซ้ำ',
    ],
    items: [
      ErFtItem('ct', 'เวลาเริ่ม CT สมอง'),
      ErFtItem('lab', 'เวลาส่ง Lab'),
      ErFtItem('op', 'เข้าห้องผ่าตัด', when: 'ผ่าตัด'),
      ErFtItem('leave', 'ออกจาก ER'),
    ],
    kpis: [
      ErFtKpi('Door-to-CT', 'door', 'ct', maxMin: 120, source: 'ACTEP 2014'),
      ErFtKpi('Door-to-lab', 'door', 'lab', maxMin: 60, source: 'ACTEP 2014'),
      ErFtKpi('Door-to-operation', 'door', 'op',
          maxMin: 240, source: 'ACTEP 2014'),
      ErFtKpi('เวลาอยู่ ER', 'door', 'leave', maxMin: 60, source: 'ACTEP 2014'),
    ],
  ),
];

ErFastTrack? erFastTrackById(String id) {
  for (final t in erFastTracks) {
    if (t.id == id) return t;
  }
  return null;
}

/// จำแนก fast track ของเคสจากประเภทผู้ป่วย + อาการสำคัญ
/// [type] = ป้ายประเภทผู้ป่วยจากการคัดกรอง (Stroke STEMI Sepsis Trauma) · [cc] = อาการสำคัญ
/// เคสหนึ่งเข้าได้หลายกลุ่ม (เช่น อุบัติเหตุศีรษะกระแทก = Trauma + Head injury)
List<ErFastTrack> erFastTracksFor({String? type, String cc = ''}) {
  bool has(List<String> words) => words.any(cc.contains);
  final ids = <String>{
    if (type == 'Stroke' ||
        has([
          'อ่อนแรงซีก',
          'แขนขาอ่อนแรง',
          'ปากเบี้ยว',
          'พูดไม่ชัด',
          'หน้าเบี้ยว'
        ]))
      'stroke',
    if (type == 'STEMI' || has(['เจ็บแน่นหน้าอก', 'เจ็บหน้าอก', 'แน่นหน้าอก']))
      'stemi',
    if (type == 'Sepsis' || has(['ติดเชื้อในกระแสเลือด', 'septic'])) 'sepsis',
    if (type == 'Trauma') 'trauma',
    if (has(['ศีรษะกระแทก', 'หัวกระแทก', 'ศีรษะฟาด', 'บาดเจ็บที่ศีรษะ']))
      'head',
  };
  return [
    for (final t in erFastTracks)
      if (ids.contains(t.id)) t
  ];
}
