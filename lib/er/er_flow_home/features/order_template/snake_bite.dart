part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ Standing order: Snake bite
// ถอดจากเอกสาร "Standing order Snake bite รพ.ปากเกร็ด (ต.ค.65)"
// ซ้าย = PROGRESS NOTE (แพทย์ประเมิน) · ขวา = คำสั่งที่เปลี่ยนตามผลประเมิน
// (ORDER FOR ONE DAY → ORDER FOR CONTINUATION → MED → หมายเหตุ)

/// ตัวเลือกหนึ่งข้อใน progress note
class _PnOpt {
  const _PnOpt(this.label, [this.sub = '']);
  final String label;
  final String sub;
}

/// กลุ่มตัวเลือกในหัวข้อเดียวกัน (เช่น Hematotoxin / Neurotoxin)
class _PnGroup {
  const _PnGroup(this.title, this.opts);
  final String title;
  final List<_PnOpt> opts;
}

/// หัวข้อของ progress note = หนึ่งเมนูในแถบซ้าย
class _PnSection {
  const _PnSection(this.id, this.title, this.short, this.icon, this.groups,
      {this.single = false});
  final String id;
  final String title;
  final String short;
  final IconData icon;
  final List<_PnGroup> groups;

  /// เลือกได้ข้อเดียวทั้งหัวข้อ (เช่น Fang mark มี/ไม่มี · ชนิดงู)
  final bool single;
}

/// คำสั่งหนึ่งบรรทัด · rate = มีช่องกรอกอัตรา ml/hr
class _TplLine {
  const _TplLine(this.text, {this.rate = false});
  final String text;
  final bool rate;
}

/// ก้อนคำสั่งตามเอกสาร · part = ส่วนของเอกสาร · sections = หัวข้อซ้ายที่เกี่ยวข้อง
class _TplBlock {
  const _TplBlock(this.id, this.part, this.title, this.lines, this.sections);
  final String id;
  final String part;
  final String title;
  final List<_TplLine> lines;
  final Set<String> sections;
}

/// template ที่เลือกได้ในแต่ละประเภทผู้ป่วยของ Order Set
/// (id, ชื่อ, ที่มา) · id 'inline' = ชุดคำสั่งเดิมที่ติ๊กในหน้า Order Set
const Map<String, List<(String, String, String)>> _orderTemplatesOf = {
  'Sepsis': [
    ('inline', 'Template สำหรับผู้ป่วย Sepsis', 'แนวทางการดูแลตามมาตรฐาน')
  ],
  'งูกัด': [
    ('snake', 'Standing order Snake bite', 'รพ.ปากเกร็ด · ต.ค. 65'),
  ],
};

const List<String> _snakeNeuro = [
  'งูเห่า',
  'งูจงอาง',
  'งูสามเหลี่ยม',
  'งูทับสมิงคลา',
];

const List<_PnSection> _snakeNote = [
  _PnSection(
      'fang',
      'Fang mark',
      'Fang mark',
      Icons.adjust_rounded,
      [
        _PnGroup('', [_PnOpt('มี'), _PnOpt('ไม่มี')]),
      ],
      single: true),
  _PnSection(
      'type',
      'ชนิดงู',
      'ชนิดงู',
      Icons.pest_control_rounded,
      [
        _PnGroup('Hematotoxin', [
          _PnOpt('งูกะปะ'),
          _PnOpt('งูเขียวหางไหม้'),
          _PnOpt('งูแมวเซา'),
        ]),
        _PnGroup('Neurotoxin', [
          _PnOpt('งูเห่า'),
          _PnOpt('งูจงอาง'),
          _PnOpt('งูสามเหลี่ยม'),
          _PnOpt('งูทับสมิงคลา'),
        ]),
        _PnGroup('', [_PnOpt('ไม่ทราบชนิด', 'ใช้คำสั่งกรณี hematotoxin')]),
      ],
      single: true),
  _PnSection('antivenom', 'Indication for antivenom', 'Antivenom',
      Icons.vaccines_rounded, [
    _PnGroup('Hematotoxin', [
      _PnOpt('Systemic bleeding'),
      _PnOpt('WBCT > 20 min'),
      _PnOpt('Platelet < 50,000 หรือ INR > 1.2'),
      _PnOpt('AKI', 'กรณีงูแมวเซา'),
      _PnOpt('Compartment syndrome'),
    ]),
    _PnGroup('Neurotoxin', [
      _PnOpt('กล้ามเนื้ออ่อนแรง',
          'เริ่มตั้งแต่หนังตาตก ไม่ต้องรอให้มี respiratory failure'),
      _PnOpt('สงสัยงูทับสมิงคลาหรืองูสามเหลี่ยม',
          'ให้ antivenom โดยไม่ต้องรอให้มีอาการ'),
    ]),
  ]),
  _PnSection('intubation', 'Indication for intubation', 'Intubation',
      Icons.air_rounded, [
    _PnGroup('', [
      _PnOpt('กลืนลำบาก'),
      _PnOpt('หนังตาตก', 'palpebral fissure < 0.5 cm'),
      _PnOpt('Respiratory failure'),
      _PnOpt('Peak flow < 200'),
    ]),
  ]),
  _PnSection('refer', 'Refer เมื่อ', 'Refer', Icons.local_shipping_rounded, [
    _PnGroup('', [
      _PnOpt('Intubation + need respiratory support'),
      _PnOpt('Compartment syndrome'),
      _PnOpt('Uncontrolled bleeding'),
      _PnOpt('Meet criteria for hemodialysis'),
    ]),
  ]),
];

/// ชื่อส่วนของเอกสารฝั่งคำสั่ง
const Map<String, String> _tplParts = {
  'one': 'ORDER FOR ONE DAY',
  'cont': 'ORDER FOR CONTINUATION',
  'med': 'MED',
  'note': 'หมายเหตุ',
};

/// ผลประเมินที่ใช้ตัดสินคำสั่ง
class _SnakeState {
  _SnakeState(Map<String, Set<String>> a)
      : species = (a['type'] ?? const {}).firstOrNull ?? '',
        crit = a['antivenom'] ?? const {},
        intub = a['intubation'] ?? const {},
        refer = a['refer'] ?? const {};
  final String species;
  final Set<String> crit;
  final Set<String> intub;
  final Set<String> refer;

  bool get neuro => _snakeNeuro.contains(species);

  /// กรณีสงสัย hematotoxin หรือไม่ทราบชนิด (รวมยังไม่ได้ระบุ)
  bool get hemato => !neuro;

  /// เข้าเกณฑ์ให้ antivenom ตามสาขาพิษ
  bool get indicated {
    final hem = _snakeNote[2].groups[0].opts.map((o) => o.label);
    final neu = _snakeNote[2].groups[1].opts.map((o) => o.label);
    if (neuro) {
      return crit.any(neu.contains) ||
          species == 'งูทับสมิงคลา' ||
          species == 'งูสามเหลี่ยม';
    }
    return crit.any(hem.contains);
  }

  /// สาขาคำสั่งตามเอกสาร ('' = ยังประเมินไม่พอจะเลือก)
  String get branch {
    if (species.isEmpty && crit.isEmpty) return '';
    if (neuro) {
      return indicated
          ? '2. สงสัย neurotoxin · ให้ antivenom'
          : '2. สงสัย neurotoxin · เฝ้าระวัง';
    }
    return indicated
        ? '1.1 สงสัย hematotoxin · ให้ antivenom'
        : '1.2 สงสัย hematotoxin · ยังไม่เข้าเกณฑ์ antivenom';
  }

  /// เหตุผลที่ได้สาขานี้ (ชนิดงู + เกณฑ์ที่ติ๊ก) · ใช้ย้อนดูว่าคำสั่งมาจากไหน
  List<String> get reasons => [
        if (species.isNotEmpty) species,
        if (species == 'งูทับสมิงคลา' || species == 'งูสามเหลี่ยม')
          'ให้ได้โดยไม่ต้องรออาการ',
        ...crit,
      ];

  /// ประเมินซ้ำอีกกี่ชั่วโมง: neurotoxin ที่ให้ antivenom ซ้ำได้ทุก 2-6 hr
  /// นอกนั้นตามรอบ WBCT / antivenom hemato ทุก 6 hr
  int get recheckHr => neuro && indicated ? 2 : 6;

  /// ข้อ Refer ที่เข้าเกณฑ์จากหัวข้ออื่น (แนะนำ ให้แพทย์ยืนยัน)
  Set<String> get referHint => {
        if (intub.isNotEmpty) 'Intubation + need respiratory support',
        if (crit.contains('Compartment syndrome')) 'Compartment syndrome',
      };
}

/// ก้อนคำสั่งทั้งหมดตามลำดับเอกสาร โดยใส่ผลประเมินแล้ว (เฉพาะที่ใช้กับเคสนี้)
List<_TplBlock> _snakeBlocks(Map<String, Set<String>> ans) {
  final s = _SnakeState(ans);
  final sp = s.species;
  final out = <_TplBlock>[];
  // เกิด anaphylaxis ระหว่างให้ antivenom: คำสั่งแก้ไขขึ้นก่อนทุกอย่าง
  if ((ans['anaphylaxis'] ?? const {}).isNotEmpty) {
    out.add(const _TplBlock('anaph', 'one', 'Anaphylaxis จาก antivenom', [
      _TplLine('หยุด antivenom'),
      _TplLine('Adrenaline (1:1000) 0.5 ml IM'),
      _TplLine('CPM 10 mg IV'),
    ], {
      'antivenom'
    }));
  }
  if (s.hemato && s.indicated) {
    final av = switch (sp) {
      'งูกะปะ' ||
      'งูเขียวหางไหม้' =>
        'Antivenom งูกะปะ / งูเขียวหางไหม้ 3 vials',
      'งูแมวเซา' => 'Antivenom งูแมวเซา 5 vials',
      _ => 'Antivenom งูรวมระบบ hemato 5 vials',
    };
    out.add(_TplBlock(
        'h11_av', 'one', '1.1 สงสัย hematotoxin · เข้าเกณฑ์ให้ antivenom', [
      _TplLine(av),
      const _TplLine(
          'ผสมใน NSS 100 ml IV drip in 30-60 min · ให้ซ้ำได้ทุก 6 hr'),
    ], const {
      'antivenom'
    }));
    out.add(_TplBlock('h11_lab', 'one', '1.1 การตรวจติดตาม', [
      const _TplLine('CBC OD x 3 day'),
      const _TplLine(
          'PT, PTT, INR q 6 hr x 4 ครั้ง then ถ้า stable ลดเป็น OD จนครบ 3 days'),
      const _TplLine(
          'WBCT q 6 hr x 4 ครั้ง then ถ้า stable ลดเป็น OD จนครบ 3 days'),
      const _TplLine('BUN, Cr, Electrolyte'),
      const _TplLine('0.9% NSS 1000 ml IV drip', rate: true),
      if (sp == 'งูแมวเซา')
        const _TplLine(
            'งูแมวเซา: record urine output q 8 hr + BUN, Cr, Electrolyte OD'),
    ], const {
      'type',
      'antivenom'
    }));
  }
  if (s.hemato && !s.indicated) {
    out.add(const _TplBlock(
        'h12', 'one', '1.2 สงสัย hematotoxin · ไม่เข้าเกณฑ์ให้ antivenom', [
      _TplLine('WBCT q 6 hr x 4 ครั้ง then ถ้า stable ลดเป็น OD จนครบ 3 days'),
      _TplLine('CBC, PT, PTT, INR OD 3 days'),
    ], {
      'type',
      'antivenom'
    }));
  }
  if (s.neuro) {
    out.add(_TplBlock('n_ett', 'one', '2. สงสัย neurotoxin', [
      _TplLine(s.intub.isEmpty
          ? 'On ETT เมื่อมี indication'
          : 'On ETT · indication: ${s.intub.join(', ')}'),
      const _TplLine('CBC, BUN, Cr, Electrolyte'),
      const _TplLine('0.9% NSS 1000 ml IV drip', rate: true),
    ], const {
      'type',
      'intubation'
    }));
    if (s.indicated) {
      out.add(_TplBlock('n_av', 'one', '2. neurotoxin · ให้ antivenom', [
        _TplLine(sp == 'งูทับสมิงคลา'
            ? 'Antivenom งูทับสมิงคลา 5 vials'
            : sp.isEmpty
                ? 'Antivenom งูรวมระบบ neuro 10 vials'
                : 'Antivenom งูเห่า / งูจงอาง / งูสามเหลี่ยม 10 vials'),
        const _TplLine(
            'ผสมใน NSS 100 ml IV drip in 30-60 min · ให้ซ้ำได้ทุก 2-6 hr'),
      ], const {
        'antivenom'
      }));
    }
    out.add(const _TplBlock('n_obs', 'one', '2. การเฝ้าระวังทางระบบประสาท', [
      _TplLine(
          'Observe อาการทางระบบประสาททุก 1 hr อย่างน้อย 6 hr แล้วปรับความถี่ตามความเหมาะสม'),
    ], {
      'intubation',
      'antivenom'
    }));
  }
  if (s.refer.isNotEmpty) {
    out.add(_TplBlock('refer', 'one', 'Refer',
        [_TplLine('Refer · ${s.refer.join(', ')}')], const {'refer'}));
  }
  out.add(const _TplBlock('cont', 'cont', 'การดูแลต่อเนื่อง', [
    _TplLine('NPO'),
    _TplLine('Regular diet / soft diet'),
    _TplLine('Record V/S, I/O'),
    _TplLine('Observe bleeding'),
    _TplLine('Observe neuro sign'),
    _TplLine('Dressing wound OD'),
    _TplLine(
        'Observe clinical of compartment syndrome (ปวด ชา อ่อนแรง ไม่มีชีพจร ซีด ขยับไม่ได้)'),
  ], {
    'fang'
  }));
  out.add(const _TplBlock('med', 'med', 'ยาปฏิชีวนะ', [
    _TplLine('Augmentin 1.2 g IV q 8 hr'),
    _TplLine('Augmentin (1 g) 1 x 2 pc'),
  ], {
    'fang'
  }));
  out.add(const _TplBlock(
      'note_dt',
      'note',
      'วัคซีนบาดทะยัก',
      [_TplLine('พิจารณาฉีด dT 0.5 ml IM หลัง clinical stable แล้ว')],
      {'fang'}));
  if (s.indicated) {
    out.add(const _TplBlock('note_av', 'note', 'การให้ antivenom', [
      _TplLine(
          'Antivenom ไม่ต้องทำ skin test ก่อนให้ · observe clinical anaphylaxis อย่างน้อย 2 hr หลังให้'),
      _TplLine(
          'ถ้ามี anaphylaxis ให้หยุด antivenom + adrenaline (1:1000) 0.5 ml IM + CPM 10 mg IV'),
    ], {
      'antivenom'
    }));
  }
  return out;
}

/// บรรทัดที่ไม่ติ๊กไว้ตั้งแต่แรก (ทางเลือกที่ใช้คู่กันไม่ได้)
bool _snakeDefaultOff(String block, int i, Map<String, Set<String>> ans) {
  final neuro = _SnakeState(ans).neuro;
  if (block == 'cont' && i == 0) return !neuro; // NPO เฉพาะ neurotoxin
  if (block == 'cont' && i == 1)
    return neuro; // อาหารปกติเมื่อไม่ใช่ neurotoxin
  if (block == 'med' && i == 1) return true; // ยากินเป็นทางเลือกของยาฉีด
  return false;
}
