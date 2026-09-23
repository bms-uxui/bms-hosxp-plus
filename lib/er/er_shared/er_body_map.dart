/// ผูกอาการสำคัญของเคสเข้ากับตำแหน่งบนร่างกาย (อวัยวะ + กระดูก)
///
/// อ่านจากข้อความจริงของเคส (อาการสำคัญ วินิจฉัย ผลภาพถ่าย) ด้วยกฎคำสำคัญ
/// ไม่ผูกกับ HN ใด ๆ — เคสใหม่ที่พิมพ์อาการเข้ามาก็ map ได้เอง
///
/// ผลลัพธ์ใช้ร่วมกันสองที่:
///   * หุ่นสามมิติ: รหัส `heart`, `lungs`, … (ชั้นอวัยวะ) และ `bone:femur_r`, … (ข้อต่อจริงของ rig)
///   * การ์ดหุ่นเงาสองมิติ ในหน้าภาพรวม
library;

import 'er_cases.dart';

enum ErBodyKind { organ, bone, zone }

class ErBodyTarget {
  const ErBodyTarget(this.kind, this.id, this.th, this.hit);

  final ErBodyKind kind;

  /// organ: brain/heart/lungs/stomach/liver/kidneys/intestine/bladder
  /// bone: <ส่วน>_<l|r> เช่น femur_r หรือส่วนกลางตัว เช่น pelvis, cspine
  final String id;

  /// ชื่อไทยสำหรับแสดงผล
  final String th;

  /// คำในข้อความเคสที่ทำให้ map มาที่นี่ (ไว้โชว์เหตุผล/ดีบัก)
  final String hit;

  /// รหัสที่ส่งให้ฉากสามมิติ
  String get code => switch (kind) {
        ErBodyKind.bone => 'bone:$id',
        ErBodyKind.zone => 'zone:$id',
        ErBodyKind.organ => id,
      };

  /// ส่วนกระดูกโดยไม่มีข้าง เช่น femur_r → femur
  String get part => id.replaceAll(RegExp(r'_(l|r)$'), '');

  /// ข้าง: 'l' / 'r' / null (กลางตัว)
  String? get side {
    final m = RegExp(r'_(l|r)$').firstMatch(id);
    return m?.group(1);
  }
}

/// กฎกระดูก เรียงจากเจาะจงไปกว้าง (ข้อมือก่อนมือ ข้อเท้าก่อนเท้า)
/// sided = ต้องระบุข้าง ถ้าข้อความไม่บอกข้าง จะใช้ข้างที่พบในข้อความทั้งก้อน หรือขวา
const List<(String part, String th, bool sided, List<String> words)>
    _boneRules = [
  ('skull', 'กะโหลกศีรษะ', false, ['กะโหลก', 'skull', 'ศีรษะแตก']),
  (
    'cspine',
    'กระดูกสันหลังส่วนคอ',
    false,
    ['กระดูกคอ', 'ต้นคอ', 'c-spine', 'cervical', 'c-collar']
  ),
  ('clavicle', 'กระดูกไหปลาร้า', true, ['ไหปลาร้า', 'clavicle']),
  ('ribs', 'กระดูกซี่โครง', true, ['ซี่โครง', 'rib fracture', 'ribs']),
  ('tspine', 'กระดูกสันหลังส่วนอก', false, ['t-spine', 'thoracic spine']),
  (
    'lspine',
    'กระดูกสันหลังส่วนเอว',
    false,
    ['หลังส่วนล่าง', 'กระดูกสันหลัง', 'l-spine', 'lumbar']
  ),
  ('pelvis', 'กระดูกเชิงกราน', false, ['เชิงกราน', 'pelvis', 'pelvic']),
  ('humerus', 'กระดูกต้นแขน', true, ['ต้นแขน', 'humerus', 'ไหล่หลุด']),
  (
    'forearm',
    'กระดูกปลายแขน/ข้อมือ',
    true,
    ['ข้อมือ', 'ปลายแขน', 'radius', 'ulna', 'colles']
  ),
  ('hand', 'มือ', true, ['ฝ่ามือ', 'นิ้วมือ', 'หลังมือ', 'metacarpal']),
  (
    'femur',
    'กระดูกต้นขา',
    true,
    ['ต้นขา', 'femur', 'femoral', 'คอกระดูกสะโพก', 'สะโพก']
  ),
  ('knee', 'ข้อเข่า', true, ['ข้อเข่า', 'เข่า', 'patella', 'knee']),
  ('tibia', 'กระดูกหน้าแข้ง', true, ['หน้าแข้ง', 'แข้ง', 'tibia', 'fibula']),
  ('ankle', 'ข้อเท้า', true, ['ข้อเท้า', 'ankle', 'malleol']),
  ('foot', 'เท้า', true, ['ฝ่าเท้า', 'หลังเท้า', 'metatarsal', 'เท้า']),
];

/// กฎอวัยวะ: เฉพาะคำที่ระบุอวัยวะหรือโรคของอวัยวะนั้นชัดเจน
/// (อาการกว้าง ๆ เช่น ปวดท้อง คลื่นไส้ ไปเป็นโซน heatmap แทน)
const List<(String id, String th, List<String> words)> _organRules = [
  (
    'brain',
    'สมอง',
    [
      'สมอง',
      'stroke',
      'ischemic',
      'infarct',
      'intracranial',
      'cva',
      'tia',
      'migraine',
      'ไมเกรน',
      'bppv',
      'ประสาทหูชั้นใน'
    ]
  ),
  (
    'heart',
    'หัวใจ',
    [
      'หัวใจ',
      'stemi',
      'nstemi',
      'heart failure',
      'acute coronary',
      'acs',
      'myocard',
      'arrhythmia',
      'af with'
    ]
  ),
  (
    'lungs',
    'ปอด',
    [
      'ปอด',
      'pneumonia',
      'asthma',
      'copd',
      'หอบหืด',
      'pneumothorax',
      'bronch',
      'pulmonary'
    ]
  ),
  (
    'stomach',
    'กระเพาะอาหาร',
    ['กระเพาะอาหาร', 'gi bleed', 'gastritis', 'peptic', 'upper gi']
  ),
  (
    'liver',
    'ตับ/ถุงน้ำดี',
    ['ตับ', 'cholecystitis', 'ถุงน้ำดี', 'hepatitis', 'biliary', 'ดีซ่าน']
  ),
  (
    'kidneys',
    'ไต',
    ['ไต', 'pyelonephritis', 'renal', 'aki', 'ckd', 'นิ่วในไต']
  ),
  (
    'intestine',
    'ลำไส้',
    ['ลำไส้', 'appendicitis', 'ไส้ติ่ง', 'colitis', 'bowel', 'enteritis']
  ),
  ('bladder', 'กระเพาะปัสสาวะ', ['กระเพาะปัสสาวะ', 'cystitis']),
  ('pancreas', 'ตับอ่อน', ['ตับอ่อน', 'pancrea']),
  ('esophagus', 'หลอดอาหาร', ['หลอดอาหาร', 'esophag', 'oesophag']),
  ('trachea', 'หลอดลมใหญ่', ['หลอดลมใหญ่', 'trachea', 'airway obstruction']),
];

/// โซนของอาการที่ไม่ได้ระบุอวัยวะ/กระดูก แสดงเป็น heatmap บนผิว
/// รหัสต้องตรงกับภาพฐาน assets/images/bodymap/zone_<id>.png และโซนในฉาก 3D
const List<(String id, String th, List<String> words)> _zoneRules = [
  ('ruq', 'ท้องขวาบน', ['ขวาบน']),
  ('luq', 'ท้องซ้ายบน', ['ซ้ายบน']),
  ('rlq', 'ท้องขวาล่าง', ['ขวาล่าง']),
  ('llq', 'ท้องซ้ายล่าง', ['ซ้ายล่าง']),
  ('epigastric', 'ลิ้นปี่', ['ลิ้นปี่', 'จุกแน่นท้อง', 'คลื่นไส้', 'อาเจียน']),
  ('suprapubic', 'ท้องน้อย', ['ท้องน้อย', 'แสบขัด', 'ปัสสาวะขุ่น', 'ปัสสาวะ']),
  ('flank_r', 'สีข้างขวา', ['เอวขวา', 'สีข้างขวา']),
  ('flank_l', 'สีข้างซ้าย', ['เอวซ้าย', 'สีข้างซ้าย']),
  ('lowback', 'หลังส่วนล่าง', ['ปวดหลัง', 'ปวดเอว']),
  ('abdomen', 'ช่องท้อง', ['ปวดท้อง', 'ท้องเสีย', 'ท้องอืด', 'ถ่ายดำ']),
  (
    'chest',
    'หน้าอก',
    [
      'เจ็บหน้าอก',
      'แน่นหน้าอก',
      'ใจสั่น',
      'หอบ',
      'หายใจลำบาก',
      'หายใจ',
      'ไอ',
      'วี้ด',
      'เหนื่อย'
    ]
  ),
  ('throat', 'คอ', ['เจ็บคอ', 'กลืนลำบาก', 'คอบวม']),
  (
    'head',
    'ศีรษะ',
    [
      'ปวดศีรษะ',
      'ปวดหัว',
      'เวียนศีรษะ',
      'ศีรษะ',
      'พูดไม่ชัด',
      'ปากเบี้ยว',
      'ชัก',
      'ซึม',
      'หมดสติ',
      'สับสน'
    ]
  ),
];

/// โซนย่อยของท้อง: ถ้าพบแล้วไม่ต้องแสดงโซนท้องรวม
const Set<String> _abdoQuadrants = {'ruq', 'luq', 'rlq', 'llq', 'epigastric'};

const List<String> _rightWords = ['ขวา', 'right', ' rt', '(r)'];
const List<String> _leftWords = ['ซ้าย', 'left', ' lt', '(l)'];

/// ข้อความที่ใช้ map: อาการสำคัญ + วินิจฉัย + ผลภาพถ่าย
/// (ไม่ใช้ HPI เพราะมักมีประโยคปฏิเสธยาว ๆ เช่น "ไม่ปวดศีรษะ ไม่แน่นหน้าอก")
String erBodyText(ErCase c) => [
      c.cc,
      for (final d in c.dx) d.text,
      for (final i in c.imaging) i.result,
    ].join(' · ').toLowerCase();

/// คำนี้อยู่หลัง "ไม่" หรือ "no" ติด ๆ = ประโยคปฏิเสธ ไม่นับ
bool _negated(String text, int at) {
  final from = (at - 4).clamp(0, text.length);
  final before = text.substring(from, at);
  return before.contains('ไม่') || before.endsWith('no ');
}

final RegExp _latin = RegExp(r'[a-z]');

/// คำอังกฤษต้องขึ้นต้นคำจริง (cystitis ไม่นับใน cholecystitis)
bool _wordStart(String text, int at, String w) {
  if (at == 0 || !_latin.hasMatch(w[0])) return true;
  return !_latin.hasMatch(text[at - 1]);
}

/// คำสั้นที่เป็นส่วนหน้าของคำอื่น (ตับ ↔ ตับอ่อน) ไม่นับ
const Map<String, List<String>> _longerWords = {
  'ตับ': ['ตับอ่อน'],
  'ไต': ['ไตร'],
};
bool _longer(String text, int at, String w) =>
    (_longerWords[w] ?? const []).any((l) => text.startsWith(l, at));

int _findWord(String text, String w) {
  var i = text.indexOf(w);
  while (i >= 0) {
    if (!_negated(text, i) && _wordStart(text, i, w) && !_longer(text, i, w)) {
      return i;
    }
    i = text.indexOf(w, i + w.length);
  }
  return -1;
}

/// ข้างของคำที่เจอ ดูจากคำที่อยู่ใกล้ที่สุดในวลีเดียวกัน (ก่อนเครื่องหมาย · , )
String? _sideNear(String text, int at, int len) {
  var s = at, e = at + len;
  while (s > 0 && !'·,;'.contains(text[s - 1])) {
    s--;
  }
  while (e < text.length && !'·,;'.contains(text[e])) {
    e++;
  }
  final phrase = text.substring(s, e);
  final pos = at - s;
  int best = 1 << 30;
  String? side;
  void scan(List<String> words, String sd) {
    for (final w in words) {
      var i = phrase.indexOf(w);
      while (i >= 0) {
        final d = (i - pos).abs();
        if (d < best) {
          best = d;
          side = sd;
        }
        i = phrase.indexOf(w, i + w.length);
      }
    }
  }

  scan(_rightWords, 'r');
  scan(_leftWords, 'l');
  return side;
}

/// ข้างที่ข้อความทั้งก้อนพูดถึง (ถ้าพูดข้างเดียว)
String? _sideAny(String text) {
  final r = _rightWords.any(text.contains);
  final l = _leftWords.any(text.contains);
  if (r == l) return null;
  return r ? 'r' : 'l';
}

/// ตำแหน่งบนร่างกายทั้งหมดของเคสนี้ เรียงตามลำดับที่พบในข้อความ
/// (อาการสำคัญมาก่อนวินิจฉัย สิ่งที่ผู้ป่วยบ่นก่อนจึงเป็นตำแหน่งหลัก)
List<ErBodyTarget> erBodyTargets(ErCase c) {
  final text = erBodyText(c);
  final found = <(int, ErBodyTarget)>[];
  final taken =
      <(int, int)>[]; // ช่วงข้อความที่ถูกใช้แล้ว กันคำซ้อน เช่น ข้อมือ/มือ

  bool overlaps(int a, int b) => taken.any((t) => a < t.$2 && b > t.$1);

  for (final (part, th, sided, words) in _boneRules) {
    for (final w in words) {
      var i = _findWord(text, w);
      while (i >= 0) {
        if (!overlaps(i, i + w.length)) {
          taken.add((i, i + w.length));
          final near = sided ? _sideNear(text, i, w.length) : null;
          // ไม่ระบุข้างแต่เคยเจอส่วนนี้แล้ว = คำซ้ำของตำแหน่งเดิม ไม่ใช่อีกข้าง
          final dup =
              sided && near == null && found.any((f) => f.$2.part == part);
          final side = sided ? (near ?? _sideAny(text) ?? 'r') : null;
          final id = side == null ? part : '${part}_$side';
          if (!dup && !found.any((f) => f.$2.id == id)) {
            final sideTh = side == null ? '' : (side == 'r' ? 'ขวา' : 'ซ้าย');
            found.add((
              i,
              ErBodyTarget(ErBodyKind.bone, id, '$th$sideTh', w),
            ));
          }
        }
        final n = text.indexOf(w, i + w.length);
        i = n < 0 ? -1 : (_negated(text, n) ? -1 : n);
      }
    }
  }
  final bones = [...found]..sort((a, b) => a.$1.compareTo(b.$1));

  final organs = <(int, ErBodyTarget)>[];
  for (final (id, th, words) in _organRules) {
    var first = -1;
    String hit = '';
    for (final w in words) {
      final i = _findWord(text, w);
      if (i >= 0 && !overlaps(i, i + w.length) && (first < 0 || i < first)) {
        first = i;
        hit = w;
      }
    }
    if (first >= 0) {
      organs.add((first, ErBodyTarget(ErBodyKind.organ, id, th, hit)));
    }
  }
  for (final o in organs) {
    final h = o.$2.hit;
    final i = o.$1;
    taken.add((i, i + h.length));
  }

  final zones = <(int, ErBodyTarget)>[];
  for (final (id, th, words) in _zoneRules) {
    var first = -1;
    String hit = '';
    for (final w in words) {
      final i = _findWord(text, w);
      if (i >= 0 && !overlaps(i, i + w.length) && (first < 0 || i < first)) {
        first = i;
        hit = w;
      }
    }
    if (first >= 0) {
      taken.add((first, first + hit.length));
      zones.add((first, ErBodyTarget(ErBodyKind.zone, id, th, hit)));
    }
  }
  if (zones.any((z) => _abdoQuadrants.contains(z.$2.id))) {
    zones.removeWhere((z) => z.$2.id == 'abdomen');
  }
  // โซนที่มีอวัยวะระบุชัดอยู่แล้ว ไม่ต้องซ้อน heatmap (อวัยวะโชว์ผ่านเอกซเรย์แทน)
  const organZones = {
    'brain': {'head'},
    'heart': {'chest'},
    'lungs': {'chest'},
    'stomach': {'epigastric', 'abdomen'},
    'liver': {'ruq', 'epigastric'},
    'intestine': {'abdomen'},
    'kidneys': {'flank_r', 'flank_l'},
    'bladder': {'suprapubic'},
    'pancreas': {'epigastric'},
    'esophagus': {'chest', 'epigastric'},
    'trachea': {'throat'},
  };
  final covered = {
    for (final o in organs) ...?organZones[o.$2.id],
  };
  zones.removeWhere((z) => covered.contains(z.$2.id));

  // ตำแหน่งหลัก: กระดูก > อวัยวะ > โซน แล้วตามลำดับในข้อความ
  int rank(ErBodyKind k) => switch (k) {
        ErBodyKind.bone => 0,
        ErBodyKind.organ => 1,
        ErBodyKind.zone => 2,
      };
  final all = [...bones, ...organs, ...zones]..sort((a, b) {
      final r = rank(a.$2.kind).compareTo(rank(b.$2.kind));
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
  return [for (final t in all) t.$2];
}

/// รหัสส่งให้ฉากสามมิติ (อวัยวะ + กระดูก) จำกัดจำนวนไม่ให้รก
List<String> erBodyCodes(ErCase c, {int max = 6}) =>
    [for (final t in erBodyTargets(c).take(max)) t.code];

/// ตำแหน่งหลักของเคส (อันแรก) ถ้าไม่พบอะไรเลย = null
ErBodyTarget? erBodyPrimary(ErCase c) {
  final t = erBodyTargets(c);
  return t.isEmpty ? null : t.first;
}

/// จุดหมุดบนหุ่นสามมิติ (mark_*) ที่ตรงกับอวัยวะนี้
/// กระดูกไม่ใช้หมุด เพราะหุ่นวาดแท่งแดงตามแนวกระดูกข้างที่ถูกต้องอยู่แล้ว
String? erSpotOf(ErBodyTarget t) {
  if (t.kind != ErBodyKind.organ) return null;
  return switch (t.id) {
    'brain' => 'head',
    'lungs' => 'chest',
    'heart' => 'heart',
    'stomach' || 'liver' => 'abdomen',
    _ => 'belly',
  };
}

/// หมุดที่ควรแสดงสำหรับเคสนี้
Set<String> erSpotsOf(ErCase c) => {
      for (final t in erBodyTargets(c))
        if (erSpotOf(t) != null) erSpotOf(t)!,
    };

/// รัศมีของโซน heatmap (มม. ในพิกัด BodyParts3D) ใช้กับภาพการ์ด 2D
const Map<String, double> erZoneRadiusMm = {
  'head': 110,
  'throat': 55,
  'chest': 150,
  'epigastric': 80,
  'ruq': 75,
  'luq': 75,
  'abdomen': 130,
  'rlq': 72,
  'llq': 72,
  'suprapubic': 70,
  'flank_r': 70,
  'flank_l': 70,
  'lowback': 110,
};
