/// บริเวณร่างกายสำหรับบันทึกตำแหน่งการตรวจร่างกายในห้องฉุกเฉิน
///
/// รหัสตำแหน่งอ้างอิง FMA (Foundational Model of Anatomy) ผ่านชุดข้อมูล
/// BodyParts3D เพื่อให้ตำแหน่งที่บันทึกเป็นรหัสสากล ไม่ใช่ข้อความไทยที่แต่ละ
/// โรงพยาบาลสะกดต่างกัน และแลกเปลี่ยนกับระบบอื่นได้
///
/// ใช้เฉพาะ region ระดับบนสุดของ BodyParts3D เพราะลำดับชั้นล่างกว่านั้นเป็น
/// กายวิภาค (เช่น กระดูกคอ C1–C7) ไม่ตรงกับวิธีแบ่งของการตรวจร่างกาย
///
/// ที่มาข้อมูล: BodyParts3D, © The Database Center for Life Science
/// licensed under CC Attribution 4.0 International
/// https://dbarchive.biosciencedbc.jp/en/bodyparts3d/
library;

/// ระบบที่ตรวจ ตรงกับช่องใน FFAppState (ga, HEENT, Heart, Chest, …)
enum ErExamSystem {
  ga('GA', 'ลักษณะทั่วไป'),
  constitutional('Constitutional', 'สภาพร่างกายโดยรวม'),
  heent('HEENT', 'ศีรษะ ตา หู จมูก คอ'),
  eyes('Eyes', 'ตา'),
  entMouth('ENTMounth', 'หู คอ จมูก ช่องปาก'),
  chest('Chest', 'ทรวงอกและปอด'),
  heart('Heart', 'หัวใจ'),
  abdomen('Abdomen', 'ช่องท้อง'),
  genitalia('Genitalia', 'อวัยวะเพศ'),
  pr('PR', 'ตรวจทางทวารหนัก'),
  pv('PV', 'ตรวจภายใน'),
  extremities('Extremities', 'แขนขา'),
  neurological('Neurological', 'ระบบประสาท');

  const ErExamSystem(this.stateKey, this.th);

  /// ชื่อช่องใน FFAppState ที่เก็บผลของระบบนี้อยู่ตอนนี้
  final String stateKey;
  final String th;
}

/// ด้านของร่างกายที่ region นั้นอยู่ ใช้เลือกว่าจะวาดบนภาพด้านหน้าหรือด้านหลัง
enum ErBodySide { front, back, both }

class ErBodyRegion {
  const ErBodyRegion({
    required this.id,
    required this.fmaId,
    required this.bpId,
    required this.en,
    required this.th,
    required this.side,
    required this.systems,
  });

  /// รหัสสั้นใช้ในแอป
  final String id;

  /// รหัส FMA เช่น FMA9576 — ใช้บันทึกและแลกเปลี่ยน
  final String fmaId;

  /// รหัส mesh ใน BodyParts3D (null = region ที่ไม่มี mesh แยกให้)
  final String? bpId;

  final String en;
  final String th;
  final ErBodySide side;

  /// ระบบตรวจที่เกี่ยวกับ region นี้ เรียงจากที่พบบ่อยก่อน
  final List<ErExamSystem> systems;
}

/// 14 region ระดับบนสุด เรียงจากศีรษะลงเท้า
const List<ErBodyRegion> erBodyRegions = [
  ErBodyRegion(
    id: 'head',
    fmaId: 'FMA7154',
    bpId: 'BP9488',
    en: 'head',
    th: 'ศีรษะ',
    side: ErBodySide.both,
    systems: [ErExamSystem.heent, ErExamSystem.neurological],
  ),
  ErBodyRegion(
    id: 'face',
    fmaId: 'FMA24728',
    bpId: null,
    en: 'face',
    th: 'ใบหน้า',
    side: ErBodySide.front,
    systems: [ErExamSystem.heent, ErExamSystem.eyes, ErExamSystem.entMouth],
  ),
  ErBodyRegion(
    id: 'neck',
    fmaId: 'FMA7155',
    bpId: 'BP9369',
    en: 'neck',
    th: 'คอ',
    side: ErBodySide.both,
    systems: [ErExamSystem.heent, ErExamSystem.entMouth],
  ),
  ErBodyRegion(
    id: 'chestFront',
    fmaId: 'FMA24816',
    bpId: 'BP9316',
    en: 'anterior chest',
    th: 'ทรวงอกด้านหน้า',
    side: ErBodySide.front,
    systems: [ErExamSystem.chest, ErExamSystem.heart],
  ),
  ErBodyRegion(
    id: 'chestBack',
    fmaId: 'FMA24217',
    bpId: 'BP9346',
    en: 'back of thorax',
    th: 'ทรวงอกด้านหลัง',
    side: ErBodySide.back,
    systems: [ErExamSystem.chest],
  ),
  ErBodyRegion(
    id: 'abdomen',
    fmaId: 'FMA9577',
    bpId: 'BP9533',
    en: 'abdomen',
    th: 'ช่องท้อง',
    side: ErBodySide.front,
    systems: [ErExamSystem.abdomen],
  ),
  ErBodyRegion(
    id: 'pelvis',
    fmaId: 'FMA9578',
    bpId: 'BP9535',
    en: 'pelvis',
    th: 'เชิงกราน',
    side: ErBodySide.both,
    systems: [ErExamSystem.genitalia, ErExamSystem.pr, ErExamSystem.pv],
  ),
  ErBodyRegion(
    id: 'armRight',
    fmaId: 'FMA7185',
    bpId: 'BP9411',
    en: 'right upper limb',
    th: 'แขนขวา',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities, ErExamSystem.neurological],
  ),
  ErBodyRegion(
    id: 'armLeft',
    fmaId: 'FMA7186',
    bpId: 'BP9390',
    en: 'left upper limb',
    th: 'แขนซ้าย',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities, ErExamSystem.neurological],
  ),
  ErBodyRegion(
    id: 'handRight',
    fmaId: 'FMA9713',
    bpId: 'BP9508',
    en: 'right hand',
    th: 'มือขวา',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities],
  ),
  ErBodyRegion(
    id: 'handLeft',
    fmaId: 'FMA9714',
    bpId: 'BP9439',
    en: 'left hand',
    th: 'มือซ้าย',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities],
  ),
  ErBodyRegion(
    id: 'legRight',
    fmaId: 'FMA7187',
    bpId: 'BP9467',
    en: 'right lower limb',
    th: 'ขาขวา',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities, ErExamSystem.neurological],
  ),
  ErBodyRegion(
    id: 'legLeft',
    fmaId: 'FMA7188',
    bpId: 'BP9296',
    en: 'left lower limb',
    th: 'ขาซ้าย',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities, ErExamSystem.neurological],
  ),
  ErBodyRegion(
    id: 'footRight',
    fmaId: 'FMA11343',
    bpId: 'BP9465',
    en: 'right foot',
    th: 'เท้าขวา',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities],
  ),
  ErBodyRegion(
    id: 'footLeft',
    fmaId: 'FMA11344',
    bpId: 'BP9294',
    en: 'left foot',
    th: 'เท้าซ้าย',
    side: ErBodySide.both,
    systems: [ErExamSystem.extremities],
  ),
];

/// ระบบที่ไม่ผูกกับตำแหน่งใดตำแหน่งหนึ่ง — ตรวจทั้งตัว
const List<ErExamSystem> erWholeBodySystems = [
  ErExamSystem.ga,
  ErExamSystem.constitutional,
  ErExamSystem.neurological,
];

ErBodyRegion? erBodyRegionById(String id) {
  for (final r in erBodyRegions) {
    if (r.id == id) return r;
  }
  return null;
}

ErBodyRegion? erBodyRegionByFma(String fmaId) {
  for (final r in erBodyRegions) {
    if (r.fmaId == fmaId) return r;
  }
  return null;
}

/// region ทั้งหมดที่เกี่ยวกับระบบตรวจนั้น — ใช้ไฮไลต์บนภาพร่างกาย
/// เมื่อผู้ใช้เลือกระบบจากรายการแทนการแตะบนภาพ
List<ErBodyRegion> erRegionsForSystem(ErExamSystem system) =>
    erBodyRegions.where((r) => r.systems.contains(system)).toList();
