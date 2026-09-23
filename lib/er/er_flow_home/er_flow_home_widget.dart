/// หน้าแรกของโมดูล ER — ภาพรวมกระแสงานทั้งห้องเป็นแท่น isometric สี่ขั้น
///
/// อ่านได้ในแวบเดียวว่าตอนนี้คนค้างอยู่ขั้นไหนกี่คน และขั้นไหนเป็นคอขวด
/// แตะที่แท่นเพื่อกางรายชื่อของขั้นนั้นโดยไม่ต้องออกจากหน้า
///
/// ข้อมูลในไฟล์นี้ยังเป็นข้อมูลจำลองทั้งหมด รอต่อกับฐานข้อมูลจริงของ HOSxP
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../er_bed_view/er_room_3d.dart';
import '../er_shared/er_ai.dart';
import '../er_login/er_login_widget.dart';
import '../er_shared/er_aura.dart';
import '../er_shared/er_body_map.dart';
import 'er_detail_tables.dart';
import '../er_shared/er_cases.dart';
import '../er_shared/er_session.dart';
import '../er_shared/er_form_kb.dart';
import '../er_shared/er_genui.dart';
import '../er_shared/er_master.dart';
import '../er_shared/er_pe_templates.dart';
import '../er_shared/er_vitals.dart';

// ---------------------------------------------------------------- ชุดสี
// ชุดเดียวกับ er-registry design language ที่ใช้ทั้งโมดูล
const Color _bg = Color(0xFFEDEDED);

// โทนของหน้าสรุปเคส AI (โทนสว่างเดียวกับทั้งแอป)
const Color _dPanel = Color(0xF2FFFFFF);
const Color _dLine = Color(0xFFE3E6EA);
const Color _dInk = Color(0xFF202124);
const Color _dInk2 = Color(0xFF6B7178);
const Color _dRed = Color(0xFFD93025);
const Color _dAmber = Color(0xFFE8A33D);
const Color _dGreen = Color(0xFF34A853);
const Color _dAccent = Color(0xFF001B7C);
const Color _panel = Color(0xFFFFFFFF);
const Color _panelSoft = Color(0xFFF1F3F4);
const Color _line = Color(0xFFE3E6EA);
const Color _ink = Color(0xFF202124);

/// สีหัวข้อ = primaryText ของธีมแอป เข้มกว่าตัวอักษรทั่วไปหนึ่งขั้น
const Color _inkTitle = Color(0xFF14181B);

/// โทนสีภายในแผงซ้าย พื้นเป็นสีหลัก ตัวอักษรกลับเป็นขาว
/// แยกชุดจากโทนบนพื้นขาวของทั้งหน้า เพื่อไม่ให้สับสนว่าตัวไหนใช้ที่ไหน
const Color _pBg = _blue;
const Color _pInk = Color(0xFFFFFFFF);
const Color _pInk2 = Color(0xE6FFFFFF);
const Color _pInk3 = Color(0xBDFFFFFF);
const Color _pLine = Color(0x2EFFFFFF);
const Color _pSoft = Color(0x1FFFFFFF);

/// ดันสีเน้นให้สว่างพอจะอ่านออกบนพื้นสีหลัก
/// สี ESI กับสีระดับแจ้งเตือนเดิมเข้มเกินไปเมื่ออยู่บนน้ำเงินเข้ม
Color _onDark(Color c) => Color.lerp(c, Colors.white, 0.42)!;

/// สัดส่วนตำแหน่งการ์ดของแต่ละช่วงงานบนฉาก อิงผังใน Figma
/// ใช้เป็นจุดยึดตอนซูมเข้าไปดูมุมนั้นด้วย การ์ดกับมุมที่ขยายจึงตรงกัน
/// ความจุที่รับไหวกับอัตราเข้า-ออกต่อชั่วโมงของแต่ละช่วงงาน
/// ยังเป็นค่าจำลอง รอต่อกับสถิติจริงของห้อง
/// ใช้ชี้คอขวด: เข้ามากกว่าออก = คนกำลังกอง
const Map<_Phase, ({int cap, int inRate, int outRate})> _phaseFlow = {
  _Phase.triage: (cap: 8, inRate: 9, outRate: 7),
  _Phase.treatment: (cap: 10, inRate: 7, outRate: 4),
  _Phase.after: (cap: 6, inRate: 4, outRate: 5),
};

/// ไล่ลงขวาตามขั้นบันไดในภาพ การ์ดจึงเดินคู่ไปกับลำดับงาน
/// ไม่ใช่กระจายสามมุมแบบเดิมที่ไม่สัมพันธ์กับฉาก
const Map<_Phase, Offset> _spots = {
  _Phase.triage: Offset(0.13, 0.30),
  _Phase.treatment: Offset(0.36, 0.56),
  _Phase.after: Offset(0.66, 0.72),
};
const Color _ink2 = Color(0xFF474C52);
const Color _ink3 = Color(0xFF6B7178);

/// สัดส่วนสีทั้งหน้าเป็นกฎ 60-30-10
/// 60 = พื้นและแผง (_bg _panel _panelSoft _line)
/// 30 = โครงสร้างและตัวรอง (_ink _ink2 _ink3 และ _blue ที่เป็นสีรอง)
/// 10 = สีเน้น (_red _amber และสี ESI) ใช้เฉพาะจุดที่ต้องการให้สะดุดตา
/// สีเน้นจะโผล่เฉพาะตอนผิดปกติ สถานะปกติใช้สีตัวอักษรธรรมดา
const bool _mono = false;

/// สีหลักของระบบ — น้ำเงินเข้ม ใช้เป็นสีรองในกฎ 60-30-10
/// (ส่วน 30) ไม่ใช่สีเน้น สีเน้นยังเป็นแดง/เหลืองกับสี ESI
const Color _blueHue = Color(0xFF001B7C);

/// ไล่เฉดจากสีหลัก ใช้กับของที่ต้องแยกลำดับกันในตระกูลสีเดียว
const Color _blue2 = Color(0xFF2B3F96);
const Color _blue3 = Color(0xFF5A69B4);
const Color _blue4 = Color(0xFF9AA3D2);
const Color _redHue = Color(0xFFD93025);
const Color _amberHue = Color(0xFFE8A33D);
const Color _greenHue = Color(0xFF34A853);

/// ระดับเทาที่ใช้แทนสีเน้นระหว่างโหมดยังไม่ลงสี เรียงจากเข้มไปอ่อน
const Color _g1 = Color(0xFF202124);
const Color _g2 = Color(0xFF3C4043);
const Color _g3 = Color(0xFF5F6368);
const Color _g4 = Color(0xFF80868B);
const Color _g5 = Color(0xFF9AA0A6);

const Color _blue = _mono ? _g2 : _blueHue;
const Color _red = _mono ? _g1 : _redHue;
const Color _amber = _mono ? _g4 : _amberHue;

/// ระดับความเร่งด่วน ใช้ชุดสีเดียวกับวิดเจ็ต ESI ที่มีอยู่ในโค้ดเบส
enum _Esi {
  one(1, 'กู้ชีพ', Color(0xFFBE1E2D), _g1),
  two(2, 'ฉุกเฉิน', Color(0xFFAF1EBE), _g2),
  three(3, 'เร่งด่วน', Color(0xFFDC8610), _g3),
  four(4, 'กึ่งเร่งด่วน', Color(0xFF006838), _g4),
  five(5, 'ไม่เร่งด่วน', Color(0xFF465054), _g5);

  const _Esi(this.level, this.label, this.hue, this.grey);

  final int level;
  final String label;

  /// สีจริงของระดับ ใช้เมื่อเลิกโหมดยังไม่ลงสี
  final Color hue;

  /// ระดับเทาแทนสีจริง ยังไล่เข้มอ่อนตามความเร่งด่วนอยู่
  final Color grey;

  Color get color => _mono ? grey : hue;
}

/// ตัวกรองรายชื่อผู้ป่วยในแผงซ้ายตอนเลือกช่วงงาน
/// วิธีเรียงการ์ดในแถบล่างของหน้าภาพรวม
enum _FootSort {
  esi('ความเร่งด่วน'),
  wait('เวลารอ'),
  bed('รหัสเตียง');

  const _FootSort(this.label);
  final String label;
}

enum _ListFilter {
  all('ทั้งหมด'),
  onBed('บนเตียง'),
  noBed('ยังไม่ได้เตียง'),
  over('เกินเกณฑ์');

  const _ListFilter(this.label);

  final String label;
}

/// ชนิดผู้ป่วยตามทางด่วนเฉพาะโรค (fast track)
/// ใช้สีเฉพาะตัวเพราะแต่ละทางด่วนมีทีมและนาฬิกาจับเวลาของตัวเอง
enum _Ptype {
  stroke('Stroke', Color(0xFF7B1FA2)),
  trauma('Trauma', Color(0xFFC62828)),
  stemi('STEMI', Color(0xFFAD1457)),
  sepsis('Sepsis', Color(0xFFEF6C00));

  const _Ptype(this.label, this.color);

  final String label;
  final Color color;
}

/// ระดับความสำคัญของการแจ้งเตือน กำหนดสีจุดท้ายการ์ด
enum _Level {
  critical('วิกฤต', _redHue, _g1),
  urgent('เร่งด่วน', Color(0xFFF97316), _g2),
  watch('เฝ้าระวัง', _amberHue, _g4),
  normal('ปกติ', _greenHue, _g5);

  const _Level(this.label, this.hue, this.grey);

  final String label;
  final Color hue;
  final Color grey;

  Color get color => _mono ? grey : hue;
}

/// การแจ้งเตือนหนึ่งรายการ — เหตุการณ์ที่เพิ่งเกิด ไม่ใช่สถานะสะสม
class _Alert {
  const _Alert(this.time, this.title, this.detail, this.level);

  final String time;
  final String title;
  final String detail;
  final _Level level;
}

/// ข้อมูลจำลอง รอต่อกับคิวเหตุการณ์จริงของ HOSxP
const List<_Alert> _alerts = [
  _Alert('10:22', 'ESI 1 ยังไม่ได้พบแพทย์เกิน 5 นาที',
      'นายกิตติพงษ์ รัตน์ · เตียง A3 · รอตรวจ', _Level.critical),
  _Alert('10:19', 'ผู้ป่วยรอตรวจเกินเกณฑ์ 7 ราย', 'ขั้นรอตรวจเป็นคอขวดของกะนี้',
      _Level.critical),
  _Alert('10:18', 'เตียงสังเกตอาการเหลือ 2 จาก 10',
      'รอเตียง 5 ราย · คาดเต็มใน 20 นาที', _Level.urgent),
  _Alert('10:12', 'ผู้ป่วยค้างขั้นตรวจแล้วเกิน 2 ชม.',
      'นายปรีชา ดำรงค์ · เตียง A5 · รอเตียงวอร์ด', _Level.urgent),
  _Alert('10:08', 'คิวคัดกรองเกิน 10 นาที 2 ราย',
      'นายสมชาย แสงชัย · นางอารยา ธนกิจ', _Level.urgent),
  _Alert('10:05', 'ผลแล็บค้างเกิน 60 นาที',
      'นางอรสา ลิ้มเจริญ · เตียง A2 · รอผลเพาะเชื้อ', _Level.watch),
  _Alert('09:58', 'รอรถส่งต่อเกิน 45 นาที',
      'นางวารุณี เพ็ญศรี · เตียง B5 · ขั้นรอออก', _Level.watch),
  _Alert('09:47', 'ผลภาพสมองออกแล้ว',
      'นางสุดา กมลรัตน์ · เตียง A4 · รอแพทย์อ่านผล', _Level.watch),
  _Alert('09:54', 'ส่งต่อผู้ป่วยไปวอร์ดอายุรกรรมสำเร็จ',
      'นายปรีชา ดำรงค์ · ย้ายออกจากเตียง A5', _Level.normal),
  _Alert('09:41', 'คัดกรองครบทุกรายในคิวเช้า',
      'คัดกรอง 18 ราย · เฉลี่ย 6 นาทีต่อราย', _Level.normal),
  _Alert('09:30', 'รับเวรกะเช้าเรียบร้อย', 'พยาบาล 6 คน · แพทย์เวร 2 คน',
      _Level.normal),
  _Alert('09:12', 'จำหน่ายผู้ป่วยกลับบ้าน 3 ราย', 'เตียง B1 · B3 · B4 ว่างแล้ว',
      _Level.normal),
];

/// สี่ขั้นของกระแสงานใน ER ตรงกับแท็บใน e_r_homepage_copy
/// เพิ่ม "รอออก" เพราะคนกลุ่มนี้ยังครองเตียงอยู่ ต้องนับเป็นภาระงาน
enum _Stage {
  triage('รอคัดกรอง', 'Waiting for triage', 'triage'),
  waitDoctor('รอตรวจ', 'Waiting for doctor', 'wait_doctor'),
  treatment('ตรวจแล้ว', 'In treatment', 'treatment'),
  discharge('รอออก', 'Waiting for discharge', 'discharge');

  const _Stage(this.label, this.en, this.asset);

  final String label;
  final String en;
  final String asset;

  String get image => 'assets/images/flow/stage_$asset.png';

  /// รหัสที่ใช้คุยกับฝั่งสามมิติ ตรงกับชื่อปีกใน er_ward.glb
  String get key => switch (this) {
        _Stage.triage => 'zone_triage',
        _Stage.waitDoctor => 'zone_waitdoctor',
        _Stage.treatment => 'zone_treatment',
        _Stage.discharge => 'zone_discharge',
      };
}

/// ช่วงงานที่ใช้เป็นแท็บฝั่งขวา ตามแบบ Figma node 96-1345
///
/// หนึ่งช่วงครอบได้หลายขั้น — "ตรวจรักษา" กินทั้งรอตรวจและตรวจแล้ว
/// เพราะในสายตาคนทำงานมันคือช่วงเดียวกัน ต่างกันแค่แพทย์มาถึงหรือยัง
enum _Phase {
  triage('คัดกรอง', [_Stage.triage]),
  treatment('ตรวจรักษา', [_Stage.waitDoctor, _Stage.treatment]),
  after('หลังการตรวจ', [_Stage.discharge]);

  const _Phase(this.label, this.stages);

  final String label;
  final List<_Stage> stages;

  /// คีย์ห้องในฉากสามมิติ คั่นด้วยจุลภาคเมื่อครอบหลายห้อง
  String get keys => stages.map((s) => s.key).join(',');

  static _Phase of(_Stage stage) =>
      _Phase.values.firstWhere((p) => p.stages.contains(stage));
}

/// เกณฑ์เวลาของแต่ละขั้น (นาที) เกินแล้วถือว่าค้างผิดปกติ
/// ขั้นรอตรวจใช้เกณฑ์ตามระดับความเร่งด่วน ที่เหลือใช้ค่าเดียวทั้งขั้น
int _limitFor(_Stage stage, _Esi? esi) {
  switch (stage) {
    case _Stage.triage:
      return 10;
    case _Stage.waitDoctor:
      return const {1: 0, 2: 10, 3: 30, 4: 60, 5: 120}[esi?.level ?? 3] ?? 30;
    case _Stage.treatment:
      return 120;
    case _Stage.discharge:
      return 45;
  }
}

/// รูปหน้าจำลองสำหรับผู้ป่วยที่ปักหมุด ชุดเดียวกับหน้าผังเตียง
const List<String> _facePhotos = [
  'photo-1500648767791-00dcc994a43e',
  'photo-1544005313-94ddf0286df2',
  'photo-1528892952291-009c663ce843',
  'photo-1633332755192-727a05c4013d',
  'photo-1573497019940-1c28c88b4f3e',
  'photo-1521119989659-a83eee488004',
];

/// รูปหน้าประจำ HN
///
/// เดิมดึงจาก Unsplash ตรง ๆ แต่เครือข่ายในโรงพยาบาลบล็อกปลายทาง
/// รูปจึงหายทั้งหน้า ย้ายมาเก็บเป็นไฟล์ในแอปแทน ได้ภาพชุดเดิมและไม่พึ่งเน็ต
String _faceUrl(String hn) {
  final i = hn.hashCode.abs() % _facePhotos.length;
  return 'assets/images/faces/face$i.jpg';
}

/// เวลานาฬิกาแบบไทย ลงท้ายด้วย "น." เสมอ เช่น 10:22 น.
String _clock(String hhmm) => '$hhmm น.';

String _hm(int minutes) => minutes < 60
    ? '$minutes นาที'
    : '${minutes ~/ 60} ชม. ${(minutes % 60).toString().padLeft(2, '0')} น.';

/// ผู้ป่วยหนึ่งคนที่อยู่ในห้องตอนนี้
class _P {
  const _P(this.hn, this.name, this.stage, this.waitMin,
      {this.esi, this.bed, this.note = '', this.type});

  final String hn;
  final String name;
  final _Stage stage;

  /// เวลาที่ค้างอยู่ในขั้นนี้ หน่วยนาที
  final int waitMin;

  /// คนที่ยังไม่ถูกคัดกรองจะยังไม่มีระดับความเร่งด่วน
  final _Esi? esi;

  /// เตียงที่ครองอยู่ ถ้าไม่มีคือยังไม่ได้เตียง
  final String? bed;

  /// ข้อความสั้น ๆ บอกว่าค้างเพราะอะไร
  final String note;

  /// ทางด่วนเฉพาะโรคที่ผู้ป่วยรายนี้เข้าเกณฑ์ ถ้าไม่มีคือเคสทั่วไป
  final _Ptype? type;

  bool get over => waitMin > _limitFor(stage, esi);
}

/// รหัสเตียงในห้อง ชุดเดียวกับหน้าผังเตียง
const List<String> _roomBeds = [
  'A1',
  'A2',
  'A3',
  'A4',
  'A5',
  'B1',
  'B2',
  'B3',
  'B4',
  'B5',
];

/// รายชื่อผู้ป่วยจำลอง — ยังไม่ได้ต่อกับฐานข้อมูลจริง
const List<_P> _patients = [
  // รอคัดกรอง ยังไม่มี ESI จัดลำดับด้วยเวลารออย่างเดียว
  _P('670123456', 'นายสมชาย แสงชัย', _Stage.triage, 14,
      note: 'เดินมาเอง', type: _Ptype.stroke),
  _P('670123457', 'นางอารยา ธนกิจ', _Stage.triage, 11, note: 'ญาตินำส่ง'),
  _P('670123458', 'นายบริรักษ์ คงทน', _Stage.triage, 8, note: 'นั่งรถเข็น'),
  _P('670123459', 'นางสาวณัฐมน พงศ์ดี', _Stage.triage, 5, note: 'เดินมาเอง'),
  _P('670123460', 'นายวีระชัย ลาภมี', _Stage.triage, 3,
      note: 'ส่งตัวโดย BLS', type: _Ptype.trauma),

  // รอตรวจ บางคนได้เตียง บางคนนั่งรอ
  _P('670123461', 'นายกิตติพงษ์ รัตน์', _Stage.waitDoctor, 22,
      esi: _Esi.one, bed: 'A3', note: 'รอแพทย์เวรกู้ชีพ', type: _Ptype.stemi),
  _P('670123462', 'นางสุดา กมลรัตน์', _Stage.waitDoctor, 34,
      esi: _Esi.two, bed: 'A4', note: 'รอผลภาพสมอง', type: _Ptype.stroke),
  _P('670123463', 'นางสาวจุฑามาศ ไชย', _Stage.waitDoctor, 45,
      esi: _Esi.two, bed: 'B1', type: _Ptype.sepsis),
  _P('670123464', 'นายนิติพนธ์ สุขสม', _Stage.waitDoctor, 52, esi: _Esi.three),
  _P('670123465', 'นางลลิตา ภู่ทอง', _Stage.waitDoctor, 65, esi: _Esi.three),
  _P('670123466', 'นายอนันต์ มีทรัพย์', _Stage.waitDoctor, 78, esi: _Esi.four),
  _P('670123467', 'นางกัญญารัตน์ ทองดี', _Stage.waitDoctor, 96, esi: _Esi.four),
  _P('670123468', 'นายวัชระ นาคสุข', _Stage.waitDoctor, 41,
      esi: _Esi.four, note: 'ข้อมือขวาผิดรูป'),

  // ตรวจแล้ว ครองเตียงระหว่างรอผลหรือรอตัดสินใจ
  _P('670123469', 'นางสาวสุภาพร ว่องไว', _Stage.treatment, 80,
      esi: _Esi.one, bed: 'A1', note: 'รอผล CT ด่วน', type: _Ptype.trauma),
  _P('670123470', 'นางอรสา ลิ้มเจริญ', _Stage.treatment, 105,
      esi: _Esi.two, bed: 'A2', note: 'รอผลเพาะเชื้อ', type: _Ptype.sepsis),
  _P('670123471', 'นายปรีชา ดำรงค์', _Stage.treatment, 155,
      esi: _Esi.two, bed: 'A5', note: 'รอเตียงวอร์ดอายุรกรรม'),
  _P('670123472', 'นางพิมพ์ชนก ศรีวิไล', _Stage.treatment, 62,
      esi: _Esi.three, bed: 'B2', note: 'พ่นยาแล้วสองรอบ'),

  // รอออก ปลายทางตัดสินแล้วแต่ยังไม่ได้ออกจริง
  _P('670123473', 'นางพรทิพย์ ก้องเกียรติ', _Stage.discharge, 15,
      esi: _Esi.three, bed: 'B3', note: 'รอใบสั่งยา'),
  _P('670123474', 'นายจิระ สินสมบูรณ์', _Stage.discharge, 28,
      esi: _Esi.four, bed: 'B4', note: 'รอญาติมารับ'),
  _P('670123475', 'นางวารุณี เพ็ญศรี', _Stage.discharge, 58,
      esi: _Esi.two, bed: 'B5', note: 'รอรถส่งต่อ'),
];

class ErFlowHomeWidget extends StatefulWidget {
  const ErFlowHomeWidget({super.key});

  static const String routeName = 'Er_Flow_Home';
  static const String routePath = 'erFlowHome';

  @override
  State<ErFlowHomeWidget> createState() => _ErFlowHomeWidgetState();
}

class _ErFlowHomeWidgetState extends State<ErFlowHomeWidget> {
  /// ช่วงงานที่กางรายชื่ออยู่ ถ้าเป็น null คือดูภาพรวมทั้งห้อง
  _Phase? _open;

  /// ตัวกรองการแจ้งเตือนในแผงซ้าย null = ทุกระดับ
  _Level? _filter;

  /// แผงข้อมูลซ้ายกางอยู่หรือยุบแล้ว ยุบเพื่อคืนพื้นที่ให้ฉากสามมิติ
  bool _panelOpen = true;

  /// ตัวกรองรายชื่อผู้ป่วยตอนเลือกช่วงงาน
  _ListFilter _listFilter = _ListFilter.all;

  /// HN ของผู้ป่วยที่ปักหมุดไว้ที่แถบขวา
  final Set<String> _pinned = {'670123461', '670123471'};

  /// ผู้ป่วยที่เปิดดูล่าสุด (ใหม่สุดก่อน) ตั้งต้นด้วยเคสที่แพทย์เวรเพิ่งดูในกะนี้
  final List<String> _recentHn = [
    '670123469',
    '670123468',
    '670123460',
    '670123461',
    '670123470',
    '670123474',
  ];

  /// HN ของผู้ป่วยที่เลือกอยู่ในฉากสามมิติ null = ใช้คนแรกของช่วงงาน
  String? _sceneHn;

  /// โหมดข้อมูลผู้ป่วย: กล้องเลื่อนไปมองเตียงจากบน แผงซ้ายเป็นกราฟ
  /// ฝั่งขวามีรายการข้อมูลกับเส้นเวลา (Figma node 58-697)
  bool _detail = false;

  /// แท็บที่เลือกในแถบบนของหน้ารายละเอียด (ยังเป็นภาพนิ่ง ยกเว้น "ภาพรวม")
  int _detailTab = 0;

  /// ช่วงงานที่กำลังซูมดูอยู่ในหน้าภาพรวม null = ยังไม่ได้ซูม
  /// ต่างจาก _open ตรงที่ยังอยู่หน้าภาพรวม ฉากเดิม แค่ขยายเข้าไปดูมุมนั้น
  _Phase? _zoom;

  /// การ์ดแจ้งเตือนด้านขวา เปิดจากปุ่มกระดิ่งมุมขวาบน
  bool _alertsOpen = false;

  /// เวลาของใบวิกฤตที่ปัดทิ้งไปแล้ว ไม่ต้องเด้งเป็น toast ซ้ำ
  final Set<String> _toastGone = {};

  /// ลิ้นชักเส้นเวลาในหน้ารายละเอียด เปิดจากปุ่มบนแถบบน
  bool _timelineOpen = false;

  /// เมนูปุ่มลัดมุมขวาล่างของหน้ารายละเอียด กดปุ่มหลักเพื่อกาง
  bool _fabOpen = false;

  /// แท็บภาพรวม/ตรวจร่างกาย/คำสั่งแพทย์: true = ดูเป็นตาราง
  bool _tableView = false;

  /// Generative UI ของผู้ช่วย: บล็อกล่าสุดที่ผู้ช่วยส่งมา + ขั้นที่ส่ง
  List<ErUiBlock> _agentUi = const [];
  int _agentUiStep = -1;
  int _agentUiGen = 0;

  /// การ์ดที่กำลังนำเสนอในสำรับเหนือวงล้อ
  int _uiIdx = 0;

  /// หน้าที่เปิดอยู่ของ flipbook ฟอร์ม (ทีละช่อง)
  int _formAt = 0;

  /// ขั้นที่เด้งไปหน้าสรุปยืนยันแล้ว (ครบทุกช่อง) กันเด้งซ้ำ
  int _reviewShown = -1;
  bool _formFwd = true;

  /// รายการในชุดคำสั่งแนะนำที่แพทย์ติ๊กไว้ ('ช่อง|รายการ')
  final Set<String> _orderPick = {};

  /// รายการใน checklist ของผู้ช่วยที่ติ๊กแล้ว
  final Set<String> _uiTicks = {};

  /// การ์ดข้างวงโค้งตอนพูด: false = checklist · true = การ์ดฟอร์มจริง (generative UI)
  bool _guideForm = false;

  /// รอบสัญญาณชีพที่เลือกในกราฟแท่ง (key = ชื่อค่า) ไม่มี = รอบล่าสุด
  final Map<String, int> _vsPick = {};

  // ---- แท็บของแพทย์
  /// แท็บตรวจร่างกาย: 0 = ทบทวนระบบ (ROS) · 1 = ตรวจร่างกาย (PE)
  int _examMode = 1;

  String _template = 'Sepsis';
  final Set<String> _orderPicked = {
    'Piperacillin + Tazobactam 4.5 g',
    '0.9% NSS 1,000 mL',
    'Blood culture ×2',
    'CBC',
    'BUN / Cr',
    'Lactate',
    'Chest X-ray',
    'Oxygen cannula 3 L/min',
  };
  int _followTab = 0;

  // ---- โหมดพูดเพื่อบันทึก (Figma 186:68)
  bool _speechOpen = false;
  int _speechStep = 0;
  final Set<int> _speechDone = {};
  bool _recording = false;
  int _recSec = 0;
  int _tick = 0;
  Timer? _recTimer;
  List<double> _wave = List.filled(28, 0.15);

  /// ระดับเสียงพื้นหลังของห้อง (dBFS) ใช้แยกเสียงพูดออกจากเสียงรอบข้าง
  double _dbFloor = -45.0;

  // ---- ผู้ช่วย AI ในโหมดพูด: หุ่นยนต์ + ไมค์จริง + LLM/ASR/TTS ของ BMS Cloud
  final ErAuraController _robot = ErAuraController();
  final GlobalKey _auraKey = GlobalKey();
  final AudioRecorder _rec = AudioRecorder();

  /// ค่าที่ AI จับได้ของแต่ละขั้น ชื่อช่อง → ข้อความ
  final List<Map<String, String>> _filled =
      List.generate(6, (_) => <String, String>{});

  /// ข้อความที่ถอดเสียงได้ของแต่ละขั้น (สะสม)
  final List<String> _transcripts = List.filled(6, '');

  /// ขั้นของโหมดพูดตามบทบาทที่ login (แพทย์ / พยาบาล)
  /// แต่ละบทบาทกรอกเฉพาะฟอร์ม HOSxP ของตัวเอง (role ใน er_form_kb.json)
  List<(IconData, String)> get _steps => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorSteps,
        ErRole.nurse => _nurseSteps,
        ErRole.triage => _triageSteps,
      };
  List<List<(String, String)>> get _forms => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorForm,
        ErRole.nurse => _nurseForm,
        ErRole.triage => _triageForm,
      };
  List<String> get _asks => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorAsk,
        ErRole.nurse => _nurseAsk,
        ErRole.triage => _triageAsk,
      };

  /// ประโยคล่าสุดที่หุ่นพูด
  String _agentSay = '';

  /// สถานะงานเบื้องหลัง เช่น กำลังถอดเสียง / กำลังคิด (ว่าง = ไม่มี)
  String _agentStatus = '';
  bool _agentBusy = false;

  /// กันคำตอบเก่ามาทับหลังปิดหรือเปลี่ยนขั้น
  int _agentGen = 0;

  /// ตัวเลือกที่ผู้ช่วยสร้างให้กด (generative UI): ช่อง + รายการตัวเลือก
  (String, List<String>)? _agentChoices;

  /// หน้าสรุปเคสด้วย AI (ทับหน้ารายละเอียด หุ่นเป็นเอกซเรย์พื้นมืด)
  bool _summaryOpen = false;
  bool _summaryBusy = false;
  String? _summaryErr;
  final Map<String, Map<String, dynamic>> _summaryCache = {};

  /// โหมดเงียบ: ไม่อ่านออกเสียง แสดงข้อความ + สั่น (ใช้ใน ER ที่เสียงรบกวน)
  bool _silent = false;

  /// ช่องที่เพิ่งลงในรอบล่าสุด ไว้ "ยกเลิกอันล่าสุด"
  List<(int, String, String?)> _lastFilled = const [];

  /// ประวัติการคุยทั้งหมด (ผู้ใช้ / ผู้ช่วย) ใช้ทั้งโชว์และส่งให้ LLM จำบริบท
  final List<_ChatTurn> _chatLog = [];
  bool _chatOpen = false;
  final ScrollController _chatScroll = ScrollController();

  void _logTurn(bool user, String text) {
    if (text.trim().isEmpty) return;
    _chatLog.add(_ChatTurn(user, text.trim(), _speechStep, DateTime.now()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
      }
    });
  }

  /// บทสนทนาล่าสุดในรูปแบบข้อความของ LLM (จำกัดจำนวนกันบริบทยาว)
  List<Map<String, String>> _historyMessages({int max = 12}) => [
        for (final t
            in _chatLog.skip(_chatLog.length > max ? _chatLog.length - max : 0))
          {'role': t.user ? 'user' : 'assistant', 'content': t.text},
      ];

  /// ตรวจจับเสียงพูดตอนอัด: ได้ยินเสียงพูดแล้วหรือยัง
  bool _heard = false;

  /// คำทบทวนเคส (ขั้น 1) เตรียมไว้ล่วงหน้าตั้งแต่เปิดหน้าคนไข้: JSON + คลิปเสียงทีละประโยค
  Map<String, dynamic>? _reviewJson;
  List<Uint8List>? _reviewClips;
  Future<void>? _reviewJob;

  /// ชั้นกายวิภาคที่กำลังดูในหน้ารายละเอียด skin | bone | organ | vessel
  String _layer = 'skin';

  /// จุดอาการที่กำลังเพ่ง แตะที่จุดเพื่อสลับ null = ยังไม่ได้เลือก
  String? _focusSpot;

  /// ตำแหน่งการ์ดสรุปในฉาก ลากย้ายได้อิสระ เริ่มจากค่าตั้งต้นใน _spots
  /// เก็บเป็นสัดส่วนของกรอบฉาก ย่อ/ขยายหน้าต่างแล้วการ์ดยังอยู่จุดเดิม
  final Map<_Phase, Offset> _cardAt = {..._spots};

  /// จุดยึดของการซูมล่าสุด ค้างไว้แม้ซูมออกแล้ว
  ///
  /// ถ้าสลับจุดยึดกลับไปกลางจอพร้อมกับที่สเกลเริ่มลด ภาพจะกระตุกทันทีที่กด
  /// เพราะจุดยึดเปลี่ยนแบบไม่มีอนิเมชัน สเกล 1.0 จะยึดตรงไหนก็ได้ผลเหมือนกัน
  /// จึงปล่อยให้ค้างที่มุมเดิมจนกว่าจะซูมมุมใหม่
  Alignment _zoomAt = Alignment.center;

  /// ตำแหน่งบนจอของจุดสำคัญบนตัวหุ่น (จากฉากสามมิติ) ไว้วางเครื่องหมายอาการ
  List<ErBedScreenPos> _hotspots = const [];

  /// แถบล่างของหน้าภาพรวม ชุดเดียวกับหน้าผังเตียง: ค้นหา + การ์ดเตียง
  final ScrollController _footScroll = ScrollController();
  final String _footQuery = '';
  _FootSort _footSort = _FootSort.esi;

  /// กำลังโหลดข้อมูลของหน้า/ช่วงงานที่เลือกอยู่ → โชว์ skeleton แทนเนื้อหา
  /// ยังไม่มี API จริง จึงจำลองหน่วงเวลา: เปิดหน้าครั้งแรก 900ms สลับช่วงงาน 500ms
  bool _loading = true;
  int _loadSeq = 0;

  void _simulateLoad(Duration d) {
    final seq = ++_loadSeq;
    setState(() => _loading = true);
    Future.delayed(d, () {
      if (!mounted || seq != _loadSeq) return;
      setState(() => _loading = false);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _simulateLoad(const Duration(milliseconds: 900));
    ErFormKb.load();
    _loadPeTemplates();
    ErMaster.load().then((_) {
      if (mounted) setState(() {});
    });
    ErSession.instance.addListener(_onSession);
    // ยังไม่ได้เลือกบทบาท → ไปหน้า login จำลองก่อน
    if (!ErSession.instance.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.goNamed(ErLoginWidget.routeName);
      });
    }
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  /// ชิปผู้ใช้ที่ login อยู่ มุมล่างซ้าย แตะเพื่อสลับบทบาท
  Widget _userChip() {
    final u = ErSession.instance.user;
    if (u == null) return const SizedBox.shrink();
    final nurse = u.role == ErRole.nurse;
    return Material(
      color: _panel,
      borderRadius: BorderRadius.circular(999.0),
      elevation: 3.0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ErSession.instance.signOut();
          context.goNamed(ErLoginWidget.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 14.0, backgroundImage: AssetImage(u.face)),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(u.name,
                      style:
                          _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
                  Text('${u.roleLabel} · ${u.shift}',
                      style: _t(8.5, color: nurse ? _greenHue : _blue)),
                ],
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.swap_horiz_rounded, size: 14.0, color: _ink3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _footScroll.dispose();
    _chatScroll.dispose();
    _recTimer?.cancel();
    _rec.dispose();
    ErSession.instance.removeListener(_onSession);
    super.dispose();
  }

  List<_P> _of(_Stage s) {
    final list = _patients.where((p) => p.stage == s).toList();
    // เรียงตามความเสี่ยง ระดับความเร่งด่วนก่อน แล้วค่อยเวลารอ
    // ขั้นรอคัดกรองไม่มีระดับ จึงเรียงด้วยเวลารออย่างเดียว
    list.sort((a, b) {
      final ea = a.esi?.level ?? 9;
      final eb = b.esi?.level ?? 9;
      if (ea != eb) return ea.compareTo(eb);
      return b.waitMin.compareTo(a.waitMin);
    });
    return list;
  }

  /// ฟอนต์มาจากไฟล์ที่ฝังในแอป ไม่ได้โหลดจากเน็ต จอในห้องฉุกเฉินจึงไม่พังตอนเน็ตหลุด
  TextStyle _t(double size,
          {Color color = _ink,
          FontWeight weight = FontWeight.w400,
          double? height}) =>
      TextStyle(
          fontFamily: 'NotoSansThai',
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height);

  TextStyle _num(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: 'NotoSansThai',
          fontSize: size,
          color: color,
          fontWeight: weight);

  void _go(String routeName) {
    try {
      context.pushNamed(routeName);
    } catch (e) {
      debugPrint('เปิดเส้นทาง $routeName ไม่ได้: $e');
    }
  }

  // ---------------------------------------------------------------- sidebar

  /// แถบซ้ายสุด เป็นรางไอคอนล้วน
  ///
  /// แท็บที่เลือกใช้สีเดียวกับแผงและไม่มีมุมโค้งด้านขวา
  /// จึงดูเชื่อมเป็นชิ้นเดียวกับแผงที่อยู่ติดกัน เหมือนแท็บที่ยื่นออกมา
  /// พื้นรางเป็นสีพื้นหน้า ไม่ใช่สีแผง ความต่างตรงนี้คือสิ่งที่ทำให้อ่านออก
  Widget _sideBar() => Container(
        width: 72.0,
        color: _bg,
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Image.asset('assets/images/app_launcher_icon.png',
                width: 30.0,
                height: 30.0,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.local_hospital, size: 26.0, color: _blue)),
            const SizedBox(height: 14.0),
            _sideTab(Icons.dashboard_rounded, 'ภาพรวม', null),
            for (final ph in _Phase.values)
              _sideTab(_phaseIcon(ph), ph.label, ph),
            const SizedBox(height: 14.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final p
                        in _patients.where((e) => _pinned.contains(e.hn)))
                      _pinPatient(p),
                    _pinAdd(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(_clock('10:24'), style: _num(13.0, weight: FontWeight.w600)),
            const SizedBox(height: 10.0),
            Container(
              width: 34.0,
              height: 34.0,
              decoration:
                  const BoxDecoration(color: _panel, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 19.0, color: _ink2),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      );

  /// ไอคอนประจำช่วงงาน
  IconData _phaseIcon(_Phase phase) {
    switch (phase) {
      case _Phase.triage:
        return Icons.fact_check_rounded;
      case _Phase.treatment:
        return Icons.medical_services_rounded;
      case _Phase.after:
        return Icons.logout_rounded;
    }
  }

  /// ปุ่มหนึ่งใบในรางไอคอน
  ///
  /// ใบที่เลือกกินเต็มความกว้างราง โค้งเฉพาะด้านซ้าย ขอบขวาชนแผงพอดี
  /// ใบที่ไม่ได้เลือกเป็นสี่เหลี่ยมมุมมนลอยอยู่กลางราง
  Widget _sideTab(IconData icon, String label, _Phase? phase) {
    final active = _open == phase;
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: Padding(
        padding: EdgeInsets.fromLTRB(active ? 10.0 : 14.0, 0.0, 0.0, 8.0),
        child: Material(
          color: active ? _pBg : _panel,
          borderRadius: BorderRadius.horizontal(
            left: const Radius.circular(14.0),
            right: Radius.circular(active ? 0.0 : 14.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (_open == phase) return;
              setState(() {
                _open = phase;
                _detail = false;
                _zoom = null;
              });
              _simulateLoad(const Duration(milliseconds: 500));
            },
            child: SizedBox(
              width: active ? 62.0 : 44.0,
              height: 44.0,
              // ใบที่เลือกพื้นเป็นสีหลัก ไอคอนจึงเป็นขาว
              // ใบที่ไม่ได้เลือกพื้นขาว ไอคอนเป็นสีหลัก
              child:
                  Icon(icon, size: 21.0, color: active ? Colors.white : _blue),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- หัวหน้า
  /// สีประจำขั้น ใช้ทั้งกับแท่นในฉากและป้ายบนจอ
  Color _stageColor(_Stage stage) {
    switch (stage) {
      // ไล่เข้มอ่อนในสีรองสีเดียว ไม่ใช่สี่สีแข่งกับสีเน้น
      case _Stage.triage:
        return _mono ? _g2 : _blue;
      case _Stage.waitDoctor:
        return _mono ? _g3 : _blue2;
      case _Stage.treatment:
        return _mono ? _g4 : _blue3;
      case _Stage.discharge:
        return _mono ? _g5 : _blue4;
    }
  }

  /// ตัวเลขใหญ่หนึ่งช่องในแผงซ้าย เป็นการ์ดมีเส้นขอบ
  /// หน่วยต่อท้ายด้วยขนาดเล็กกว่า ตัวเลขจะได้ไม่ต้องแบกความหมายเอง
  Widget _bigStat(String label, String value,
          {String? unit, Color color = _pInk}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
        decoration: BoxDecoration(
          color: _pSoft,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _pLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: _t(11.0, color: _pInk3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(24.0, color: color, weight: FontWeight.w700)),
                if (unit != null) ...[
                  const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(11.0, color: _pInk3)),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

  // ------------------------------------------------------------ แจ้งเตือน
  /// ชิปกรองระดับการแจ้งเตือน กดซ้ำที่ตัวเดิมเพื่อกลับไปดูทั้งหมด
  Widget _filterChip(String label, _Level? level) {
    final active = _filter == level;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Material(
        // อยู่บนพื้นการ์ดขาว ตัวที่เลือกจึงต้องเป็นพื้นทึบตัวอักษรขาว
        // "ทั้งหมด" ไม่มีสีประจำระดับ ใช้สีหลักแทน
        color: active ? (level?.color ?? _blue) : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _filter = active ? null : level),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(label,
                style: _t(10.5,
                    color: active ? Colors.white : _ink2,
                    weight: active ? FontWeight.w600 : FontWeight.w400)),
          ),
        ),
      ),
    );
  }

  /// ป้ายทางด่วนเฉพาะโรค — ตัวอักษรบนพื้นจางสีเดียวกัน
  /// onDark = อยู่บนแผงสีหลัก ต้องดันสีให้สว่างพอ
  Widget _typeBadge(_Ptype t, {bool onDark = false, double size = 9.0}) {
    final c = onDark ? _onDark(t.color) : t.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.7, vertical: 1.0),
      decoration: BoxDecoration(
        color: c.withValues(alpha: onDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child:
          Text(t.label, style: _num(size, color: c, weight: FontWeight.w700)),
    );
  }

  /// ป้ายระดับการแจ้งเตือน ทุกระดับหน้าตาเดียวกัน
  /// พื้นจางสีประจำระดับ + จุดสีทึบ + คำกำกับ ต่างกันแค่สี
  Widget _levelBadge(_Level level) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.5),
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.0,
              height: 6.0,
              decoration:
                  BoxDecoration(color: level.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5.0),
            Text(level.label,
                style: _t(9.5, color: level.color, weight: FontWeight.w600)),
          ],
        ),
      );

  /// แถวการแจ้งเตือนหนึ่งรายการ
  ///
  /// คั่นด้วยเส้นชุดเดียวกับรายชื่อผู้ป่วย ไม่ใช่การ์ดแยกใบ
  /// สองคอลัมน์: ป้ายระดับกับเรื่อง · เวลา
  /// ป้ายระดับวางบรรทัดบนของคอลัมน์ข้อความ ไม่ลงพื้นสีทั้งแถว
  /// ทุกระดับใช้ป้ายทรงเดียวกัน ต่างกันที่สีเท่านั้น
  Widget _alertRow(_Alert a) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ป้ายระดับอยู่คอลัมน์เดียวกับข้อความ วางนำหน้าหัวเรื่องในบรรทัดแรก
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ป้ายระดับอยู่บรรทัดบนของคอลัมน์เดียวกับหัวเรื่อง
                  _levelBadge(a.level),
                  const SizedBox(height: 4.0),
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: _ink, weight: FontWeight.w600, height: 1.25)),
                  const SizedBox(height: 2.0),
                  Text(a.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.5, color: _ink2)),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // คอลัมน์ 3 เวลาที่เกิดเหตุ ชิดขวาให้ตรงคอลัมน์เวลาของรายชื่อผู้ป่วย
            Text(_clock(a.time),
                style: _num(11.0, color: _ink3, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// การ์ดแจ้งเตือนลอยใต้ปุ่มกระดิ่ง
  ///
  /// ย้ายออกจากแผงซ้ายเพราะเป็นของที่ดูเป็นครั้ง ไม่ใช่ของที่ต้องเห็นตลอด
  /// เป็นการ์ดลอย ไม่ใช่แผงที่กินความกว้าง ฉากจึงไม่ต้องหุบทุกครั้งที่เปิดดู
  Widget _alertCardOverlay() {
    final list = _filter == null
        ? _alerts
        : _alerts.where((a) => a.level == _filter).toList();
    return Container(
      width: 352.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 10.0, 8.0),
            child: Row(
              children: [
                Text('การแจ้งเตือน',
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(width: 8.0),
                Text('${list.length} รายการ', style: _t(10.5, color: _ink3)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _alertsOpen = false),
                  icon: const Icon(Icons.close_rounded, size: 20.0),
                  color: _ink2,
                  tooltip: 'ปิด',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              runSpacing: 6.0,
              children: [
                _filterChip('ทั้งหมด', null),
                for (final l in _Level.values) _filterChip(l.label, l),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          Flexible(
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text('ไม่มีการแจ้งเตือนในระดับนี้',
                          style: _t(11.0, color: _ink3)),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                    children: [for (final a in list) _alertRow(a)],
                  ),
          ),
        ],
      ),
    );
  }

  /// toast ของใบระดับวิกฤต เด้งค้างไว้ข้างขวาจนกว่าจะปิดหรือกดดู
  ///
  /// ใบวิกฤตรอให้คนเปิดกระดิ่งไม่ได้ ต้องสะดุดตาเองโดยไม่บังฉากทั้งจอ
  /// ปิดการ์ดแจ้งเตือนอยู่ถึงจะเด้ง เปิดอยู่แล้วก็เห็นในรายการแล้ว
  Widget _alertToasts() {
    final hot = _alerts
        .where(
            (a) => a.level == _Level.critical && !_toastGone.contains(a.time))
        .toList();
    if (hot.isEmpty || _alertsOpen) return const SizedBox.shrink();
    // ซ้อนเป็นตั้งเหมือนกระดาษวางทับกัน ใบหน้าสุดอ่านได้เต็ม
    // ใบที่เหลือโผล่แค่ขอบล่าง พอบอกว่ายังมีอีกโดยไม่กินพื้นที่ฉาก
    final behind = (hot.length - 1).clamp(0, 2);
    return SizedBox(
      width: 266.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          for (var i = behind; i >= 1; i--)
            Positioned(
              left: i * 9.0,
              right: i * 9.0,
              bottom: -i * 7.0,
              child: Container(
                height: 30.0,
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: _red.withValues(alpha: 0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.10),
                      blurRadius: 14.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          _toastCard(hot.first, more: hot.length - 1),
        ],
      ),
    );
  }

  /// การ์ด toast หนึ่งใบ — สองบรรทัด ป้ายระดับกับเวลาอยู่บน เรื่องอยู่ล่าง
  ///
  /// วางเรียงแนวนอนแล้วการ์ดยาวเกินไป กินฉากทั้งแถบ
  /// รายละเอียดอื่นอยู่ในรายการแจ้งเตือน แตะที่การ์ดเพื่อเปิด
  Widget _toastCard(_Alert a, {int more = 0}) => Material(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() {
            _alertsOpen = true;
            _filter = _Level.critical;
          }),
          child: Container(
            width: 266.0,
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 6.0, 11.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: _red.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: _red.withValues(alpha: 0.16),
                  blurRadius: 20.0,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _levelBadge(a.level),
                    const SizedBox(width: 8.0),
                    Text(_clock(a.time),
                        style:
                            _num(10.0, color: _ink3, weight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _toastGone.add(a.time)),
                      icon: const Icon(Icons.close_rounded, size: 15.0),
                      color: _ink3,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6.0),
                      tooltip: 'ปิด',
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: _ink, weight: FontWeight.w600, height: 1.25)),
                ),
              ],
            ),
          ),
        ),
      );

  /// ปุ่มกระดิ่งมุมขวาบน ตัวเลขคือจำนวนใบระดับวิกฤตที่ยังค้าง
  Widget _alertBell() {
    final hot = _alerts.where((a) => a.level == _Level.critical).length;
    return Material(
      color: _panel,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: () => setState(() => _alertsOpen = !_alertsOpen),
        child: SizedBox(
          width: 42.0,
          height: 42.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                  _alertsOpen
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  size: 22.0,
                  color: _blue),
              if (hot > 0)
                Positioned(
                  right: 8.0,
                  top: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: _panel, width: 1.5),
                    ),
                    child: Text('$hot',
                        style: _num(8.5,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ระดับความเร่งด่วน', style: _t(10.0, color: _ink3)),
          const SizedBox(height: 6.0),
          for (final e in _Esi.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text('${e.level} ${e.label}', style: _t(10.0, color: _ink2)),
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: _ink3,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const SizedBox(width: 6.0),
              Text('ยังไม่คัดกรอง', style: _t(10.0, color: _ink2)),
            ],
          ),
        ],
      );

  /// แผงซ้ายกาง/ยุบ
  ///
  /// เนื้อหาทั้งสองแบบวางซ้อนกันด้วยความกว้างคงที่ แล้วให้กรอบนอกค่อย ๆ
  /// แคบลงพร้อม ClipRect ตัดส่วนเกิน ข้อความจึงไม่ตัดบรรทัดใหม่ทุกเฟรม
  /// (ของเดิมสลับลูกทันทีแล้วให้ความกว้างวิ่ง ทำให้กระตุกตอนเปลี่ยน)
  /// เนื้อหาเฟดสลับกันสั้นกว่าจังหวะกว้าง ให้รู้สึกว่าแผง "เลื่อน" ไม่ใช่ "กระพริบ"
  /// สวิตช์ปิดการ์ดสรุปที่ลอยอยู่ในฉากภาพรวมชั่วคราว
  /// เปิดกลับเป็น true เมื่อจะใช้การ์ดกับการซูมอีกครั้ง
  static const bool _showSceneStats = true;

  /// ความกว้างแผงตอนกางกับตอนหุบ
  static const double _panelW = 336.0;
  static const double _railW = 40.0;

  Widget _leftPanel() {
    const dur = Duration(milliseconds: 320);
    const fade = Duration(milliseconds: 180);
    return AnimatedContainer(
      duration: dur,
      curve: Curves.easeInOutCubic,
      width: _panelOpen ? _panelW : _railW,
      decoration: const BoxDecoration(color: _pBg),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              width: _railW,
              child: IgnorePointer(
                ignoring: _panelOpen,
                child: AnimatedOpacity(
                  opacity: _panelOpen ? 0.0 : 1.0,
                  duration: fade,
                  curve: Curves.easeOut,
                  child: _collapsedPanel(),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              width: _panelW,
              child: IgnorePointer(
                ignoring: !_panelOpen,
                child: AnimatedOpacity(
                  opacity: _panelOpen ? 1.0 : 0.0,
                  duration: fade,
                  curve: Curves.easeOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    // ชิดบนเสมอ ค่าเริ่มต้นของ AnimatedSwitcher จัดกึ่งกลาง
                    // เนื้อหาที่สั้นกว่าจอจึงเคยลอยไปอยู่กลางแผง
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previous,
                        if (current != null) current,
                      ],
                    ),
                    child: _loading
                        ? _panelSkeleton(key: ValueKey('sk-$_open'))
                        : _open == null
                            ? _overviewPanel()
                            : _phasePanel(_open!, key: ValueKey(_open)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ปุ่มยุบแผง เป็นลิ้นชิดขอบขวาของแผงพอดี
  ///
  /// มุมซ้ายมนอย่างเดียว ฝั่งขวาตัดตรงให้ต่อเนื่องกับขอบแผง
  /// ดันออกนอกระยะขอบของเนื้อหา 16 พิกเซลด้วย Transform
  Widget _collapseButton() {
    const r = Radius.circular(10.0);
    // ไม่ใช้ Transform ดันออกนอกกรอบแล้ว ส่วนที่ล้นออกไปกดไม่ติด
    // แถวหัวแผงเว้นขอบขวาเป็น 0 ปุ่มจึงชิดขอบด้วยพื้นที่จริง
    return Material(
      color: _pSoft,
      borderRadius: const BorderRadius.only(topLeft: r, bottomLeft: r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _panelOpen = false),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(7.0, 8.0, 6.0, 8.0),
          child: Icon(Icons.keyboard_double_arrow_left_rounded,
              size: 16.0, color: _pInk2),
        ),
      ),
    );
  }

  /// แผงตอนยุบ เหลือแค่ปุ่มกางกับชื่อหน้าตามแนวตั้ง
  Widget _collapsedPanel() => Column(
        children: [
          const SizedBox(height: 8.0),
          Material(
            color: _pSoft,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _panelOpen = true),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(Icons.keyboard_double_arrow_right_rounded,
                    size: 15.0, color: _pInk2),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(_open == null ? 'ภาพรวมห้องฉุกเฉิน' : _open!.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _pInk2, weight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      );

  Widget _overviewPanel() {
    final over = _patients.where((p) => p.over).length;
    // นับจากข้อมูลจริง ให้ตรงกับแถบล่างที่นับเตียงที่ใช้
    final vacant =
        _roomBeds.length - _patients.where((p) => p.bed != null).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 0.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ภาพรวมห้องฉุกเฉิน',
                        style: _t(19.0, color: _pInk, weight: FontWeight.w700)),
                    Text('อัปเดทข้อมูลทุก 30 วินาที',
                        style: _t(10.5, color: _pInk3)),
                  ],
                ),
              ),
              _collapseButton(),
            ],
          ),
          // เนื้อหาที่เหลือกลับมามีขอบขวา 16 เหมือนเดิม
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat(
                          'ผู้ป่วยในห้องตอนนี้', '${_patients.length}',
                          unit: 'ราย'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('ค้างเกินเกณฑ์', '$over',
                          unit: 'ราย', color: over > 0 ? _onDark(_red) : _pInk),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat('เวลาเฉลี่ยใน ER', '2:18', unit: 'ชม.'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('เตียงว่าง', '$vacant',
                          unit: 'จาก ${_roomBeds.length} เตียง',
                          color: vacant == 0 ? _onDark(_amber) : _pInk),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                _HourChart(t: _t, num: _num),
                _recentSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------- แผงซ้ายโหมดช่วงงาน
  /// คนในช่วงงานนี้ เรียงตามความเสี่ยง ระดับความเร่งด่วนก่อน แล้วเวลารอ
  List<_P> _ofPhase(_Phase phase) {
    final list = [for (final st in phase.stages) ..._of(st)];
    list.sort((a, b) {
      final ea = a.esi?.level ?? 9;
      final eb = b.esi?.level ?? 9;
      if (ea != eb) return ea.compareTo(eb);
      return b.waitMin.compareTo(a.waitMin);
    });
    return list;
  }

  List<_P> _filtered(List<_P> people) => switch (_listFilter) {
        _ListFilter.all => people,
        _ListFilter.onBed => people.where((p) => p.bed != null).toList(),
        _ListFilter.noBed => people.where((p) => p.bed == null).toList(),
        _ListFilter.over => people.where((p) => p.over).toList(),
      };

  Widget _listChip(_ListFilter f) {
    final active = _listFilter == f;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Material(
        color: active ? Colors.white : _pSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _listFilter = f),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(f.label,
                style: _t(10.5,
                    color: active ? _pBg : _pInk2,
                    weight: active ? FontWeight.w600 : FontWeight.w400)),
          ),
        ),
      ),
    );
  }

  Widget _phasePanel(_Phase phase, {Key? key}) {
    final people = _ofPhase(phase);
    final shown = _filtered(people);
    final over = people.where((p) => p.over).length;
    final noBed = people.where((p) => p.bed == null).length;
    final avg = people.isEmpty
        ? 0
        : (people.map((p) => p.waitMin).reduce((a, b) => a + b) / people.length)
            .round();
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 0.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase.label,
                        style: _t(19.0, color: _pInk, weight: FontWeight.w700)),
                    Text('อัปเดทข้อมูลทุก 30 วินาที',
                        style: _t(10.5, color: _pInk3)),
                  ],
                ),
              ),
              _collapseButton(),
            ],
          ),
          // เนื้อหาที่เหลือกลับมามีขอบขวา 16 เหมือนเดิม
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat('อยู่ในช่วงนี้', '${people.length}',
                          unit: 'ราย'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('ค้างเกินเกณฑ์', '$over',
                          unit: 'ราย', color: over > 0 ? _onDark(_red) : _pInk),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat('เวลารอเฉลี่ย', _hm(avg)),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('ยังไม่ได้เตียง', '$noBed',
                          unit: 'ราย',
                          color: noBed > 0 ? _onDark(_amber) : _pInk),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Text('รายชื่อผู้ป่วย',
                        style:
                            _t(11.0, color: _pInk2, weight: FontWeight.w600)),
                    const Spacer(),
                    Text('${shown.length} ราย', style: _t(10.0, color: _pInk3)),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(children: [
                  for (final f in _ListFilter.values) _listChip(f)
                ]),
                const SizedBox(height: 8.0),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                        style: _t(10.5, color: _pInk3)),
                  )
                else
                  for (final p in shown) _personRow(p),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------- รายการปักหมุดในแถบซ้าย
  /// ผู้ป่วยที่ปักหมุด แตะแล้วกระโดดไปช่วงงานที่เขาอยู่
  ///
  /// แสดงรูปโปรไฟล์จริง วงแหวนรอบรูปบอกระดับความเร่งด่วน
  /// แดงหนาเมื่อค้างเกินเกณฑ์ ป้ายมุมล่างบอกรหัสเตียง
  Widget _pinPatient(_P p) {
    final ring = p.over ? _red : (p.esi?.color ?? _ink3);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openPatient(p),
          child: Tooltip(
            message: '${p.name} · ${p.bed ?? 'ยังไม่ได้เตียง'}',
            child: SizedBox(
              width: 52.0,
              height: 56.0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 46.0,
                    height: 46.0,
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: ring, width: p.over ? 2.0 : 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _faceUrl(p.hn),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Container(
                          color: ring.withValues(alpha: 0.12),
                          alignment: Alignment.center,
                          child: Icon(Icons.person_rounded,
                              size: 20.0, color: ring),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: ring,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(p.bed ?? '—',
                          style: _num(9.5,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ช่องเปล่าท้ายรายการ สำหรับปักหมุดผู้ป่วยเพิ่ม
  Widget _pinAdd() => Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _go('ERHomepageCopy'),
          child: Container(
            width: 46.0,
            height: 46.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _line, width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, size: 18.0, color: _ink3),
          ),
        ),
      );

  /// ฉากอาคารแผนกสามมิติ สี่ปีกคือสี่ขั้นของกระแสงาน โถงกลางคือที่นั่งรอ
  /// ไอคอนกับตัวเลขเป็นวิดเจ็ตของ Flutter ที่ลอยตามตำแหน่งปีกซึ่งฝั่งสามมิติ
  /// คำนวณส่งกลับมา ข้อความไทยจึงคมเท่าส่วนอื่นของหน้า
  // ------------------------------------------------- แถบรายชื่อเร่งด่วน
  /// ผู้ป่วยทั้งห้องเรียงตามความเร่งด่วน กรองด้วยคำค้นในแถบล่าง
  ///
  /// เรียงระดับ ESI ก่อน (ยังไม่คัดกรองไปท้าย) แล้วค่อยเวลารอมาก→น้อย
  List<_P> get _footFiltered {
    final q = _footQuery.trim().toLowerCase();
    final list = _patients.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.hn.contains(q) ||
          (p.bed ?? '').toLowerCase().contains(q) ||
          p.note.toLowerCase().contains(q) ||
          (p.esi?.label ?? 'ยังไม่คัดกรอง').contains(q) ||
          p.stage.label.contains(q);
    }).toList();
    list.sort((a, b) {
      switch (_footSort) {
        case _FootSort.esi:
          final ea = a.esi?.level ?? 9;
          final eb = b.esi?.level ?? 9;
          if (ea != eb) return ea.compareTo(eb);
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.wait:
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.bed:
          // มีเตียงมาก่อน เรียงรหัสเตียง แล้วคนไม่มีเตียงตามเวลารอ
          if (a.bed != null && b.bed != null) return a.bed!.compareTo(b.bed!);
          if (a.bed != null) return -1;
          if (b.bed != null) return 1;
          return b.waitMin.compareTo(a.waitMin);
      }
    });
    return list;
  }

  /// ตัวเลือกวิธีเรียงในแถบล่าง กดแล้วมีเมนูให้เลือก
  Widget _footSortPill() => PopupMenuButton<_FootSort>(
        tooltip: 'เรียงตาม',
        position: PopupMenuPosition.over,
        color: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: _line),
        ),
        onSelected: (v) => setState(() => _footSort = v),
        itemBuilder: (context) => [
          for (final o in _FootSort.values)
            PopupMenuItem(
              value: o,
              height: 38.0,
              child: Row(
                children: [
                  Icon(
                    o == _footSort
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16.0,
                    color: o == _footSort ? _blue : _ink3,
                  ),
                  const SizedBox(width: 8.0),
                  Text(o.label, style: _t(12.0)),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: _line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เรียงตาม ', style: _t(12.0, color: _ink2)),
              Text(_footSort.label, style: _t(12.0, weight: FontWeight.w600)),
              const SizedBox(width: 4.0),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 17.0, color: _ink2),
            ],
          ),
        ),
      );

  /// สถานะเตียงแบบย่อ มุมขวาของแถบล่าง: เตียงที่ใช้ + จำนวนแต่ละระดับ

  /// การ์ดผู้ป่วยหนึ่งใบในแถบล่าง โครงเดียวกับการ์ดเตียงของหน้าผังเตียง
  ///
  /// ป้ายมุมซ้ายบนคือรหัสเตียง (ยังไม่ได้เตียง = ขีด) รูปเตียงจางเมื่อไม่มีเตียง
  /// รูปผู้ป่วยวงกลมในการ์ดแถบล่าง วงแหวนเป็นสี ESI
  Widget _footAvatar(_P p) {
    final color = p.esi?.color ?? _ink3;
    return Container(
      width: 46.0,
      height: 46.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _panelSoft,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2.0),
      ),
      child: ClipOval(
        child: Image.asset(
          _faceUrl(p.hn),
          width: 46.0,
          height: 46.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: _panelSoft,
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, size: 20.0, color: _ink3),
          ),
        ),
      ),
    );
  }

  Widget _footCard(_P p) {
    final color = p.esi?.color ?? _ink3;
    final on = p.hn == _sceneHn;
    return Container(
      width: 148.0,
      margin: const EdgeInsets.only(right: 10.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: on ? color : _line, width: on ? 2.0 : 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            _sceneHn = p.hn;
            _open = _Phase.of(p.stage);
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Text(p.bed ?? '—',
                          style: _num(12.0,
                              color: Colors.white, weight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text(_hm(p.waitMin),
                        style: _num(10.5,
                            color: p.over ? _red : _ink3,
                            weight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6.0),
                _footAvatar(p),
                const SizedBox(height: 6.0),
                Text(p.name,
                    style: _t(12.5, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (p.type != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: _typeBadge(p.type!),
                  )
                else
                  Text(p.note.isEmpty ? p.stage.label : p.note,
                      style: _t(11.0, color: _ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// แถบล่างของหน้าภาพรวม ยกมาจากหน้าผังเตียง
  /// แถวบน: ตัวเรียง ช่องค้นหา สถานะเตียง · แถวล่าง: การ์ดผู้ป่วยเลื่อนแนวนอน
  /// ปุ่มเลื่อนแถวการ์ดผู้ป่วยในแถบล่าง ทีละราวสามใบ
  Widget _footScrollButton(IconData icon, int dir) => Material(
        color: _panelSoft,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!_footScroll.hasClients) return;
            final to = (_footScroll.offset + dir * 474.0)
                .clamp(0.0, _footScroll.position.maxScrollExtent);
            _footScroll.animateTo(to,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic);
          },
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: Icon(icon, size: 20.0, color: _ink2),
          ),
        ),
      );

  Widget _urgentStrip() {
    final list = _footFiltered;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _footSortPill(),
              const SizedBox(width: 10.0),
              Text('${list.length} ราย', style: _t(11.0, color: _ink2)),
              const Spacer(),
              // ปุ่มเลื่อนแถวการ์ด อยู่ขวาสุดของแถบ
              _footScrollButton(Icons.chevron_left_rounded, -1),
              const SizedBox(width: 6.0),
              _footScrollButton(Icons.chevron_right_rounded, 1),
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            // Noto Sans Thai สูงกว่าฟอนต์ที่หน้าผังเตียงจูนไว้ เผื่ออีก 6px
            height: 144.0,
            child: _loading
                ? _Shimmer(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: _bone(148.0, 128.0, radius: 14.0),
                          ),
                      ],
                    ),
                  )
                : list.isEmpty
                    ? Center(
                        child: Text('ไม่มีผู้ป่วยในเงื่อนไขนี้',
                            style: _t(12.0, color: _ink3)),
                      )
                    : ListView.builder(
                        controller: _footScroll,
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, i) => _footCard(list[i]),
                      ),
          ),
        ],
      ),
    );
  }

  /// ภาพฉากกระแสงาน ER สามขั้น พร้อมการ์ดสรุปลอยข้างแต่ละขั้น
  ///
  /// ใช้ภาพเรนเดอร์จากแบบ (Figma node 148-2597) แทนฉากสามมิติที่รันจริง
  /// ตำแหน่งการ์ดวางเป็นสัดส่วนของกรอบ ตามผังใน Figma node 96-1343
  /// ภาพฉากกระแสงาน ER สามขั้น พร้อมการ์ดสรุปลอยข้างแต่ละขั้น
  ///
  /// ตำแหน่งการ์ดวางเป็นสัดส่วนของกรอบ ตามผังใน Figma node 96-1343
  Widget _stairScene() => LayoutBuilder(
        builder: (context, c) {
          final zoomed = _zoom != null && _open == null;
          Widget card(_Phase ph) => Positioned(
                left: _cardAt[ph]!.dx * c.maxWidth,
                top: _cardAt[ph]!.dy * c.maxHeight,
                // ใบที่ไม่ได้ซูมจางหายไป เหลือใบเดียวคู่กับมุมที่ขยาย
                child: AnimatedOpacity(
                  opacity: zoomed && _zoom != ph ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubic,
                  child: IgnorePointer(
                    ignoring: zoomed && _zoom != ph,
                    // ลากการ์ดไปวางตรงไหนก็ได้ในฉาก เก็บเป็นสัดส่วนของกรอบ
                    child: GestureDetector(
                      onPanUpdate: (d) => setState(() {
                        final cur = _cardAt[ph]!;
                        _cardAt[ph] = Offset(
                          (cur.dx + d.delta.dx / c.maxWidth).clamp(0.0, 0.92),
                          (cur.dy + d.delta.dy / c.maxHeight).clamp(0.0, 0.86),
                        );
                      }),
                      child:
                          _loading ? _statCardSkeleton() : _sceneStatCard(ph),
                    ),
                  ),
                ),
              );
          return Stack(
            children: [
              // หน้าภาพรวม: พื้นหลังฉากเป็นขาว ขอบซ้ายไล่จางจากพื้นแอปเข้าหาขาว
              if (_open == null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white,
                            Colors.white,
                          ],
                          stops: const [0.0, 0.22, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              // ซูมเข้าไปที่มุมของช่วงงานที่เลือก จุดยึดคือตำแหน่งการ์ดใบนั้น
              Positioned.fill(
                child: ClipRect(
                  child: AnimatedScale(
                    scale: zoomed ? 1.75 : 1.0,
                    alignment: _zoomAt,
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeInOutCubic,
                    child: _sceneFor(_open),
                  ),
                ),
              ),
              // แตะที่ฉากตอนซูมอยู่เพื่อถอยกลับ
              if (zoomed)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _zoom = null),
                  ),
                ),
              // ระหว่างโหลด คลุมฉากด้วยแผ่น skeleton แล้วค่อยเฟดออก
              // (ฉากยัง mount อยู่ข้างล่าง วิดีโอ/WebView จึงไม่โหลดซ้ำ)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _loading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    child: Container(
                      color: _bg,
                      padding:
                          const EdgeInsets.fromLTRB(24.0, 34.0, 24.0, 30.0),
                      child: _Shimmer(
                        child: Center(
                          child: _open == null
                              ? _bone(c.maxWidth * 0.46, c.maxHeight * 0.78,
                                  radius: 28.0)
                              : _bone(c.maxWidth * 0.86, c.maxHeight * 0.55,
                                  radius: 24.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // โหมดภาพรวมโชว์ครบสามใบ เลือกช่วงงานแล้วเหลือใบเดียว
              // ปิดการ์ดในฉากไว้ก่อนระหว่างจัดองค์ประกอบฉากใหม่
              if (_open == null && _showSceneStats) ...[
                // (กลุ่มการ์ดของโหมดภาพรวม)
                card(_Phase.triage),
                card(_Phase.treatment),
                card(_Phase.after),
                // แผงสรุปของช่วงงานที่ซูมอยู่ เลื่อนขึ้นมาจากขอบล่าง
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: 14.0,
                  child: IgnorePointer(
                    ignoring: !zoomed,
                    child: AnimatedSlide(
                      offset: zoomed ? Offset.zero : const Offset(0, 0.25),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeInOutCubic,
                      child: AnimatedOpacity(
                        opacity: zoomed ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: _zoomPanel(_zoom ?? _Phase.triage),
                      ),
                    ),
                  ),
                ),
              ],
              if (_open != null) ...[
                Positioned(
                  left: 16.0,
                  top: 66.0,
                  child:
                      _loading ? _statCardSkeleton() : _sceneStatCard(_open!),
                ),
                // ปุ่มเลื่อนดูเตียงก่อนหน้า/ถัดไป กึ่งกลางแนวตั้งของฉาก
                if (!_loading) ...[
                  Positioned(
                    left: 16.0,
                    top: c.maxHeight * 0.40,
                    child: _stepButton(Icons.chevron_left_rounded, -1),
                  ),
                  Positioned(
                    right: 16.0,
                    top: c.maxHeight * 0.40,
                    child: _stepButton(Icons.chevron_right_rounded, 1),
                  ),
                ],
                // การ์ดผู้ป่วยลอยล่างฉาก ต้องวางหลัง WebView ใน Stack
                // ไม่งั้นมุมมองฝั่งระบบจะทับจนมองไม่เห็น
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: 14.0,
                  child: _loading
                      ? _patientCardSkeleton()
                      : _scenePatientCard(_open!),
                ),
              ],
            ],
          );
        },
      );

  /// แผงสรุปของช่วงงานที่ซูมดูอยู่ในหน้าภาพรวม
  ///
  /// ตอบคำถามที่การ์ดเล็กตอบไม่ได้ — ช้าตรงไหน ใครยังไม่ได้เตียง
  /// คนกองอยู่ที่ขั้นย่อยไหน และแบ่งตามความเร่งด่วนอย่างไร
  Widget _zoomPanel(_Phase phase) {
    final people = _ofPhase(phase);
    final over = people.where((p) => p.over).length;
    final noBed = people.where((p) => p.bed == null).length;
    final avg = people.isEmpty
        ? 0
        : (people.map((p) => p.waitMin).reduce((a, b) => a + b) / people.length)
            .round();
    final worst = people.isEmpty
        ? 0
        : people.map((p) => p.waitMin).reduce((a, b) => a > b ? a : b);
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                    color: _stageColor(phase.stages.first),
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 7.0),
              Text(phase.label,
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 8.0),
              Text('${people.length} ราย', style: _t(11.0, color: _ink3)),
              const Spacer(),
              _zoomAction('เปิดช่วงงานนี้', () {
                setState(() {
                  _zoom = null;
                  _open = phase;
                  _detail = false;
                });
                _simulateLoad(const Duration(milliseconds: 500));
              }),
              const SizedBox(width: 8.0),
              _zoomAction('ถอยกลับ', () => setState(() => _zoom = null),
                  primary: false),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _zoomStat('เกินเกณฑ์', '$over', 'ราย',
                  color: over > 0 ? _red : _ink),
              _zoomStat('ยังไม่ได้เตียง', '$noBed', 'ราย',
                  color: noBed > 0 ? _amber : _ink),
              _zoomStat('รอเฉลี่ย', _hm(avg), null),
              _zoomStat('รอนานสุด', _hm(worst), null,
                  color: worst > 0 && over > 0 ? _red : _ink),
              // คนกองอยู่ขั้นย่อยไหนของช่วงงานนี้
              SizedBox(
                width: 170.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('แยกตามขั้น', style: _t(9.5, color: _ink3)),
                    const SizedBox(height: 4.0),
                    for (final st in phase.stages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(st.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(10.0, color: _ink2)),
                            ),
                            Text('${_of(st).length}',
                                style: _num(10.5,
                                    color: _ink, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 12.0),
              // แถบสัดส่วนความเร่งด่วน อ่านง่ายกว่าโดนัทเล็ก ๆ ในการ์ด
              SizedBox(
                width: 190.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ความเร่งด่วน', style: _t(9.5, color: _ink3)),
                    const SizedBox(height: 5.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: SizedBox(
                        height: 10.0,
                        child: Row(
                          children: [
                            for (final e in _Esi.values)
                              if (counts[e]! > 0)
                                Expanded(
                                  flex: counts[e]!,
                                  child: ColoredBox(color: e.color),
                                ),
                            if (none > 0)
                              Expanded(
                                flex: none,
                                child: const ColoredBox(color: _ink3),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 2.0,
                      children: [
                        for (final e in _Esi.values)
                          if (counts[e]! > 0)
                            _zoomKey('${e.level}', counts[e]!, e.color),
                        if (none > 0) _zoomKey('—', none, _ink3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ตัวเลขหนึ่งช่องในแผงซูม
  Widget _zoomStat(String label, String value, String? unit,
          {Color color = _ink}) =>
      Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: _t(9.5, color: _ink3)),
            const SizedBox(height: 3.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(17.0, color: color, weight: FontWeight.w700)),
                if (unit != null) ...[
                  const SizedBox(width: 3.0),
                  Text(unit, style: _t(9.5, color: _ink3)),
                ],
              ],
            ),
          ],
        ),
      );

  /// คำอธิบายสีหนึ่งตัวใต้แถบสัดส่วน
  Widget _zoomKey(String label, int count, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4.0),
          Text('$label · $count',
              style: _num(9.5, color: _ink2, weight: FontWeight.w600)),
        ],
      );

  /// ปุ่มเล็กในหัวแผงซูม
  Widget _zoomAction(String label, VoidCallback onTap, {bool primary = true}) =>
      Material(
        color: primary ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(label,
                style: _t(10.5,
                    color: primary ? Colors.white : _ink2,
                    weight: FontWeight.w600)),
          ),
        ),
      );

  /// ฉากสามมิติที่ใช้ในแต่ละโหมด
  ///
  /// ภาพรวม = ฉากทั้งแผนกจากโมเดล Meshy (ย่อจาก 22.9 MB เหลือ 1.3 MB)
  /// เลือกช่วงงานแล้ว = ฉากเตียงชุดเดียวกับหน้าผังเตียง เห็นว่าใครอยู่เตียงไหน
  Widget _sceneFor(_Phase? phase) {
    if (phase == null) {
      // ภาพฉากกระแสงานจาก Figma (175:2979) เป็น PNG พื้นโปร่ง
      // จึงไม่มีปัญหาสีพื้นไม่ตรงกับพื้นแอปเหมือนตอนใช้วิดีโอ
      // เว้นขอบบนให้พ้นปุ่มกระดิ่ง ฉากจึงจัดกลางในพื้นที่ที่มองเห็นจริง
      // กว้าง 88% ของฝั่งขวา จัดกลาง — ใหญ่กว่าแบบ contain ล้วน
      // ส่วนที่ล้นบน-ล่างถูก ClipRect ของฉากตัด
      return Padding(
        // ขอบบนมากกว่าล่าง = ฉากอยู่ต่ำลงจากกึ่งกลางเล็กน้อย
        padding: const EdgeInsets.only(top: 66.0),
        child: Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.88,
            child: OverflowBox(
              alignment: Alignment.center,
              maxHeight: double.infinity,
              child: Image.asset(
                'assets/images/flow/er_flow_scene.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      );
    }
    final people = _ofPhase(phase);
    // เตียงในฉากมีคงที่ตามห้อง คนที่ยังไม่ได้เตียงจึงไม่ปรากฏในฉากนี้
    final byBed = {
      for (final p in people)
        if (p.bed != null) p.bed!: p,
    };
    final beds = [
      for (final code in _roomBeds)
        ErRoomBed(
          code: code,
          color: byBed[code]?.esi?.color ?? _ink3,
          vacant: !byBed.containsKey(code),
        ),
    ];
    final sel = _sceneSelected(phase);
    return ErRoom3D(
      // GlobalObjectKey ให้ WebView ตัวเดิมย้ายไปอยู่หน้ารายละเอียดได้
      // กล้องจึงเลื่อนต่อเนื่อง ไม่ต้องโหลดฉากใหม่
      key: GlobalObjectKey(phase),
      beds: beds,
      selectedCode: sel.bed ?? _roomBeds.first,
      cam: const ErCam(),
      onBedTap: (code) {
        final hit = byBed[code];
        if (hit != null) setState(() => _sceneHn = hit.hn);
      },
      topView: _detail,
      layer: _detail ? _layer : 'skin',
      highlight: _detail
          ? (_summaryOpen ? _summaryOrgans() : _highlightOrgans())
          : const [],
      onHotspots: (list) {
        if (!mounted || !_detail) return;
        setState(() => _hotspots = list);
      },
      // ช่องตำแหน่งบาดแผลเปิดอยู่: แตะบนหุ่นเพื่อระบุตำแหน่ง
      pickMode: _detail && _woundField != null,
      onBodyPick: _onBodyPick,
    );
  }

  /// ช่องตำแหน่งแผลที่ flipbook เปิดอยู่ตอนนี้ (null = ไม่ได้อยู่ที่ช่องนั้น)
  String? get _woundField {
    if (!_speechOpen) return null;
    final seq = _uiSeq;
    if (seq.isEmpty) return null;
    final b = seq[_uiIdx.clamp(0, seq.length - 1)];
    if (b.type != ErUiType.form) return null;
    final fields = _formFields(b);
    if (fields.isEmpty) return null;
    final f = fields[_formAt.clamp(0, fields.length - 1)];
    return f.contains('ตำแหน่ง') && f.contains('แผล') ? f : null;
  }

  /// ชื่อส่วนของร่างกายจากกระดูก rig (.L/.R = ซ้าย/ขวาของผู้ป่วย)
  static const Map<String, String> _boneTh = {
    'Head': 'ศีรษะ',
    'Neck': 'คอ',
    'Chest': 'หน้าอก',
    'Belly': 'ท้อง',
    'Pelvis': 'สะโพก/ท้องน้อย',
    'Collar': 'ไหล่',
    'UpperArm': 'ต้นแขน',
    'Forearm': 'แขนท่อนล่าง',
    'Palm': 'มือ',
    'Hip': 'ต้นขา',
    'Shin': 'ขาท่อนล่าง',
    'Foot': 'เท้า',
    'Toes': 'นิ้วเท้า',
  };

  /// แตะบนหุ่นตอนกรอกตำแหน่งแผล: เติมชื่อส่วนของร่างกายต่อท้ายช่อง (แตะหลายจุดได้)
  void _onBodyPick(String bone) {
    final f = _woundField;
    if (f == null) return;
    final part = bone.split('.');
    final th = _boneTh[part.first] ?? part.first;
    final side = part.length > 1 ? (part[1] == 'R' ? 'ขวา' : 'ซ้าย') : '';
    final where = side.isEmpty ? th : '$th$side';
    setState(() {
      final old = _filled[_speechStep][f];
      _lastFilled = [(_speechStep, f, old)];
      _filled[_speechStep][f] = old == null || old.isEmpty
          ? where
          : (old.contains(where) ? old : '$old, $where');
    });
    HapticFeedback.selectionClick();
  }

  /// เลื่อนคนที่ฉากเล็งอยู่ไปคนก่อนหน้า/ถัดไปในช่วงงานนี้ (วนรอบ)
  ///
  /// ไล่ตามรหัสเตียง A1→A2→… ให้ตรงกับที่กล้องกวาดไปทางซ้าย/ขวาในห้อง
  /// คนที่ยังไม่ได้เตียงต่อท้าย
  void _stepPatient(int dir) {
    final people = _ofPhase(_open!);
    if (people.isEmpty) return;
    final withBed = people.where((p) => p.bed != null).toList()
      ..sort((a, b) => a.bed!.compareTo(b.bed!));
    final ordered = [...withBed, ...people.where((p) => p.bed == null)];
    final cur = _sceneSelected(_open!);
    var i = ordered.indexWhere((p) => p.hn == cur.hn);
    if (i < 0) i = 0;
    i = (i + dir + ordered.length) % ordered.length;
    setState(() => _sceneHn = ordered[i].hn);
  }

  /// ปุ่มกลมลอยข้างฉาก ซ้าย/ขวา
  Widget _stepButton(IconData icon, int dir) => Material(
        color: _panel.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 3.0,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        child: InkWell(
          onTap: () => _stepPatient(dir),
          child: SizedBox(
            width: 44.0,
            height: 44.0,
            child: Icon(icon, size: 26.0, color: _ink),
          ),
        ),
      );

  /// ผู้ป่วยที่ฉากกำลังเล็งอยู่ในช่วงงานนี้
  ///
  /// ยึดคนที่แตะเลือกไว้ก่อน ถ้าคนนั้นไม่ได้อยู่ช่วงงานนี้แล้วให้ถอยไปคนแรก
  /// ช่วงคัดกรองยังไม่มีใครได้เตียง จึงเลือกจากลำดับรายชื่อแทน
  _P _sceneSelected(_Phase phase) {
    final people = _ofPhase(phase);
    if (people.isEmpty) return _patients.first;
    return people.firstWhere((p) => p.hn == _sceneHn,
        orElse: () => people.firstWhere((p) => p.bed != null,
            orElse: () => people.first));
  }

  // ------------------------------------------------- โหมดข้อมูลผู้ป่วย
  /// หน้ารายละเอียดผู้ป่วย (Figma node 58-697) โครงใหม่ทั้งหน้า
  ///
  /// บน: แถบแท็บ + ป้ายชื่อผู้ป่วย (แตะเพื่อกลับ)
  /// ล่าง: กราฟ | ฉากมองจากบน + จุดอาการ | ข้อมูลผู้ป่วย | เส้นเวลา + ปุ่มลัด
  Widget _detailPage() => Column(
        children: [
          _detailTopBar(),
          Expanded(
            child: Stack(
              children: [
                // ฉากสามมิติเป็นพื้นหลังเต็มพื้นที่ ทุกแผงลอยทับอยู่ข้างบน
                Positioned.fill(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _sceneFor(_open)),
                      // แท็บภาพรวม: พื้นขาว ฉากจางหายไปทางซ้ายใต้คอลัมน์กราฟ/ปัญหา
                      if (_detailTab == 0 && !_tableView && !_summaryOpen)
                        Positioned(
                          left: 0.0,
                          top: 0.0,
                          bottom: 0.0,
                          width: 560.0,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.92),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // วงกลมเพ่งบริเวณอาการ วาดไว้ใต้จุดทั้งหมด
                      if (!_loading)
                        for (final h in _hotspots)
                          if (h.visible && h.code == _focusSpot)
                            Positioned(
                              left: h.dx - 132.0,
                              top: h.dy - 132.0,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  size: const Size(264.0, 264.0),
                                  painter: _FocusRing(color: _amber),
                                ),
                              ),
                            ),
                      // แท็บตรวจร่างกายวาดจุดเองในเส้นชี้ ไม่ต้องซ้ำ
                      // แสดงเฉพาะหมุดที่ผูกกับอาการสำคัญ/วินิจฉัยของเคสนี้
                      // หมุดเดิมเลิกใช้ในหน้านี้: อวัยวะ/กระดูกเห็นผ่านหน้าต่างเอกซเรย์
                      // อาการไม่ระบุตำแหน่งเป็น heatmap บนผิวในฉาก 3D แล้ว
                      if (false)
                        for (final h in _hotspots)
                          if (h.visible && erSpotsOf(_case).contains(h.code))
                            Positioned(
                              left: h.dx - 15.0,
                              top: h.dy - 15.0,
                              child: _hotspotMark(h.code),
                            ),
                    ],
                  ),
                ),
                ..._detailOverlays(),

                // คำใบ้ท่าทาง บอกว่าลากหมุนได้ หุบสองนิ้วซูมได้
                if (!_loading)
                  // ปุ่มลัดอยู่มุมขวาล่าง กดปุ่มหลักก่อนถึงกางเมนู
                  // ไม่ต้องกินพื้นที่ตลอดเวลาเหมือนเรียงค้างไว้ห้าปุ่ม
                  if (!_speechOpen)
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: _fabOpen
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (ErSession.instance.isNurse) ...[
                                        _fabItem(
                                            Icons.playlist_add_check_rounded,
                                            'รับคำสั่งแพทย์',
                                            onTap: () => setState(() {
                                                  _detailTab = 3;
                                                  _fabOpen = false;
                                                })),
                                        _fabItem(Icons.monitor_heart_rounded,
                                            'บันทึกสัญญาณชีพ',
                                            onTap: () => _openSpeech(step: 1)),
                                      ],
                                      _fabItem(Icons.auto_awesome_rounded,
                                          'สรุปเคส AI',
                                          onTap: () => _openSummary()),
                                      _fabItem(
                                          Icons.mic_rounded, 'พูดเพื่อบันทึก',
                                          onTap: () => _openSpeech(step: 0)),
                                      if (!ErSession.instance.isNurse) ...[
                                        _fabItem(
                                            Icons.accessibility_new_rounded,
                                            'ตรวจร่างกาย',
                                            onTap: () => setState(() {
                                                  _detailTab = 2;
                                                  _fabOpen = false;
                                                })),
                                        _fabItem(Icons.assignment_rounded,
                                            'คำสั่งแพทย์',
                                            onTap: () => setState(() {
                                                  _detailTab = 3;
                                                  _fabOpen = false;
                                                })),
                                      ],
                                      _fabItem(
                                          Icons.task_alt_rounded, 'ยืนยัน'),
                                      const SizedBox(height: 4.0),
                                    ],
                                  )
                                : const SizedBox(width: 0.0, height: 0.0),
                          ),
                          _fabMain(),
                        ],
                      ),
                    ),
                // แตะพื้นที่ว่างเพื่อปิดลิ้นชักเส้นเวลา
                if (_timelineOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _timelineOpen = false),
                    ),
                  ),
                // เส้นเวลาเป็นลิ้นชักเลื่อนเข้ามาจากขอบขวา
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: IgnorePointer(
                    ignoring: !_timelineOpen,
                    child: AnimatedSlide(
                      offset:
                          _timelineOpen ? Offset.zero : const Offset(1.0, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: _loading
                          ? _detailTimelineSkeleton()
                          : _detailTimeline(),
                    ),
                  ),
                ),
                // aura (WebView เล่นเสียง) เตรียมไว้ตั้งแต่เปิดหน้าคนไข้
                // ซ่อนด้วย opacity ให้ WebView โหลดค้างไว้ ตอนเปิดโหมดพูดจะได้พูดทันที
                if (!_speechOpen) _auraWarm(),
                // โหมดพูดเพื่อบันทึก ทับทุกอย่างรวมถึงปุ่มลัด
                // แผงผู้ช่วยข้างวงล้อ: เฉพาะสิ่งที่ต้องลงมือทำ (ข้อมูลที่หน้าแสดงอยู่แล้วไม่ซ้ำ)
                if (_speechOpen) _speechBlur(),
                if (_speechOpen) _speechOverlay(),
                if (_speechOpen && !_loading) _agentDock(),
                // ลิ้นชักประวัติการคุยกับผู้ช่วย เลื่อนจากซ้าย ทับแถบพูดได้
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  width: 400.0,
                  child: IgnorePointer(
                    ignoring: !_chatOpen,
                    child: AnimatedSlide(
                      offset: _chatOpen ? Offset.zero : const Offset(-1.0, 0.0),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      child: _chatPanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  static const List<String> _detailTabs = [
    'ภาพรวม',
    'คัดกรอง',
    'ตรวจร่างกาย',
    'คำสั่งแพทย์',
    'สัญญาณชีพ',
    'ยา',
    'แล็บ',
    'ภาพถ่าย',
    'ฟอร์ม HOSxP',
  ];

  // ------------------------------------------- แผงบริบทระหว่างใช้โหมดพูด
  /// ตอนพูด แผงข้าง ๆ เปลี่ยนตามขั้น: ซ้าย = สิ่งที่ต้องเห็นตลอด (V/S แพ้ยา)
  /// กลางซ้าย/ขวา = ข้อมูลที่ขั้นนั้นต้องใช้ตัดสินใจ วางไว้เหนือแถบพูด
  List<Widget> _speechContextOverlays() {
    const h = 372.0;
    final (a, b) = _ctxBlocks();
    return [
      Positioned(
        left: 0.0,
        top: 0.0,
        height: h,
        width: 250.0,
        child: _ctxPanel(_ctxAlways()),
      ),
      Positioned(
        left: 256.0,
        top: 0.0,
        height: h,
        width: 300.0,
        child: _ctxPanel(a),
      ),
      Positioned(
        right: 0.0,
        top: 0.0,
        height: h,
        width: 300.0,
        child: _ctxPanel(b),
      ),
    ];
  }

  Widget _ctxPanel(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 4.0),
        children: children,
      );

  /// แผงซ้าย: V/S ย่อ + แพ้ยา + เตือนยาชนแพ้
  List<Widget> _ctxAlways() {
    final c = _case;
    final v = _caseVitals();
    return [
      _detailBlock('สัญญาณชีพ · ${c.times.last} น.', [
        for (final x in v)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Icon(x.icon, size: 12.0, color: x.line),
                const SizedBox(width: 6.0),
                SizedBox(
                    width: 40.0,
                    child: Text(x.label,
                        style:
                            _t(10.0, color: _ink2, weight: FontWeight.w600))),
                Text(x.display ?? _fmtNum(x.series.last),
                    style: _num(12.0, color: x.line, weight: FontWeight.w700)),
                const SizedBox(width: 4.0),
                Text(x.unit, style: _t(8.5, color: _ink3)),
                const Spacer(),
                if (x.series.length > 1)
                  Icon(
                      x.series.last > x.series.first
                          ? Icons.north_east_rounded
                          : (x.series.last < x.series.first
                              ? Icons.south_east_rounded
                              : Icons.east_rounded),
                      size: 12.0,
                      color: _ink3),
              ],
            ),
          ),
        if (c.gcs != null)
          Text('GCS ${c.gcsScore} · ${c.consciousness}',
              style: _t(9.5, color: _ink3)),
      ]),
      _detailBlock('แพ้ยา / แพ้อาหาร', [
        if (c.allergies.isEmpty)
          Text('ไม่มีประวัติแพ้', style: _t(10.5, color: _ink3)),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            for (final a in c.allergies)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(a,
                    style: _t(10.5, color: _red, weight: FontWeight.w600)),
              ),
          ],
        ),
        if (_allergyWarn != null) ...[
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 14.0, color: Colors.white),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(_allergyWarn!,
                      style: _t(9.5,
                          color: Colors.white, weight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ]),
    ];
  }

  static String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  Widget _ctxLine(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 84.0, child: Text(label, style: _t(9.5, color: _ink3))),
            Expanded(
              child: Text(value,
                  style: _t(10.5, color: color ?? _ink, height: 1.3)),
            ),
          ],
        ),
      );

  List<Widget> _ctxCcBlock() {
    final c = _case;
    return [
      _detailBlock('จากจุดคัดกรอง', [
        _ctxLine('อาการสำคัญ', c.cc, color: _inkTitle),
        _ctxLine('การมา', '${c.arrival} · ${c.condition}'),
        if (c.onset != null)
          _ctxLine('เริ่มอาการ',
              '${c.onset} (${_clockWait(_minutesSince(c.onset!))} ที่แล้ว)',
              color: _redHue),
        if (c.painScore != null) _ctxLine('ความปวด', '${c.painScore}/10'),
        if (c.gcs != null) _ctxLine('GCS', c.gcs!),
      ]),
    ];
  }

  List<Widget> _ctxNoteBlock() {
    final c = _case;
    return [
      _detailBlock('บันทึกพยาบาลล่าสุด', [
        if (c.lastNote == null)
          Text('ยังไม่มีบันทึก', style: _t(10.5, color: _ink3)),
        if (c.lastNote != null) ...[
          Text('${c.lastNote!.time} น. · ${c.lastNote!.by}',
              style: _t(9.5, color: _ink3)),
          const SizedBox(height: 3.0),
          Text(c.lastNote!.text, style: _t(10.5, color: _ink, height: 1.35)),
        ],
      ]),
      _detailBlock('เหตุการณ์ล่าสุด', [
        for (final e in c.events.take(4))
          _ctxLine(e.time, e.text, color: e.byDoctor ? _blueHue : _ink),
      ]),
    ];
  }

  List<Widget> _ctxHistoryBlock() {
    final c = _case;
    return [
      _detailBlock('ประวัติเดิม', [
        _ctxLine('โรคประจำตัว',
            c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', ')),
        _ctxLine('HPI (คัดกรอง)', c.hpi.isEmpty ? '-' : c.hpi),
        _ctxLine('สิทธิ', c.right),
      ]),
    ];
  }

  List<Widget> _ctxLabBlock() {
    final c = _case;
    final abn = c.labs.where((l) => l.abnormal).toList();
    return [
      _detailBlock('แล็บผิดปกติ · ${c.times.last} น.', [
        if (c.labs.isEmpty)
          Text('ยังไม่มีผลแล็บ', style: _t(10.5, color: _ink3)),
        if (c.labs.isNotEmpty && abn.isEmpty)
          Text('ทุกค่าอยู่ในเกณฑ์', style: _t(10.5, color: _greenHue)),
        for (final l in abn) _labRow(_labTuple(l)),
      ]),
      _detailBlock('ภาพถ่าย', [
        if (c.imaging.isEmpty)
          Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(10.5, color: _ink3)),
        for (final i in c.imaging)
          _ctxLine(i.name, i.result,
              color: i.result.contains('รอ') ? _amberHue : _ink),
      ]),
    ];
  }

  List<Widget> _ctxMedBlock() {
    final c = _case;
    return [
      _detailBlock('ยาที่ให้แล้ว (กันสั่งซ้ำ)', [
        if (c.meds.isEmpty)
          Text('ยังไม่ได้ให้ยา', style: _t(10.5, color: _ink3)),
        for (final m in c.meds) _ctxLine(m.time, '${m.name} · ${m.route}'),
      ]),
      _detailBlock('Template คำสั่งแพทย์', [
        Text(_kbType(_caseP().type),
            style: _t(10.5, color: _blueHue, weight: FontWeight.w700)),
        Text('ตัวเลือกยา/Lab/X-ray/หัตถการ ของ template นี้พร้อมให้พูดสั่ง',
            style: _t(9.5, color: _ink3)),
      ]),
    ];
  }

  List<Widget> _ctxPeBlock() {
    final prev = _peRounds.last;
    final abn = [
      for (final s in _peSystems)
        if (prev.of(s.key).$1 == _Finding.abnormal) (s.th, prev.of(s.key).$2)
    ];
    return [
      _detailBlock('ตรวจร่างกายรอบก่อน · ${prev.time}', [
        if (abn.isEmpty)
          Text('ไม่มีระบบผิดปกติ', style: _t(10.5, color: _ink3)),
        for (final (th, note) in abn) _ctxLine(th, note, color: _redHue),
        const SizedBox(height: 4.0),
        Text('พูด "ที่เหลือปกติหมด" เพื่อปิดทุกระบบที่ไม่ได้พูดถึง',
            style: _t(9.0, color: _ink3)),
      ]),
    ];
  }

  List<Widget> _ctxDispositionBlock() {
    final c = _case;
    final p = _caseP();
    final pending = c.imaging.where((i) => i.result.contains('รอ')).toList();
    return [
      _detailBlock('ก่อนออกจาก ER', [
        _ctxLine('อยู่ในขั้น', '${p.stage.label} · ${_clockWait(p.waitMin)}'),
        _ctxLine('ผลค้าง',
            pending.isEmpty ? 'ไม่มี' : pending.map((i) => i.name).join(', '),
            color: pending.isEmpty ? _greenHue : _amberHue),
        _ctxLine('แผนที่วางไว้', '${c.nextStep} ${c.nextDetail}'),
        if (c.disposition.isNotEmpty)
          _ctxLine('สั่งแล้ว', c.disposition, color: _blueHue),
      ]),
      _detailBlock('Checklist', [
        for (final t in const [
          'ผลตรวจทั้งหมดอ่านแล้ว',
          'ใบสั่งยา / ใบนัด',
          'คำแนะนำผู้ป่วยและญาติ',
          'สรุปค่าบริการ',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(children: [
              const Icon(Icons.radio_button_unchecked_rounded,
                  size: 13.0, color: _g5),
              const SizedBox(width: 6.0),
              Text(t, style: _t(10.0, color: _ink)),
            ]),
          ),
      ]),
    ];
  }

  List<Widget> _ctxAccidentBlock() {
    final c = _case;
    return [
      _detailBlock('ข้อมูลเหตุ', [
        _ctxLine('การมา', '${c.arrival} · ${c.condition}'),
        _ctxLine('เล่าเหตุ', c.hpi.isEmpty ? c.cc : c.hpi),
        if (c.painScore != null) _ctxLine('ความปวด', '${c.painScore}/10'),
      ]),
      _detailBlock('ภาพแผล', [
        Text('แตะจุดบนหุ่นหรือพูด "ถ่ายภาพแผล" เพื่อเปิดกล้อง',
            style: _t(9.5, color: _ink3)),
      ]),
    ];
  }

  /// เลือกบล็อกซ้าย/ขวาตามบทบาทและขั้น
  (List<Widget>, List<Widget>) _ctxBlocks() {
    final st = _speechStep;
    if (ErSession.instance.isNurse) {
      return switch (st) {
        0 => (_ctxCcBlock(), _ctxNoteBlock()),
        1 => (_ctxCcBlock(), _ctxHistoryBlock()),
        2 => (_ctxAccidentBlock(), _ctxNoteBlock()),
        3 => (_ctxMedBlock(), _ctxLabBlock()),
        4 => (_ctxNoteBlock(), _ctxHistoryBlock()),
        _ => (_ctxDispositionBlock(), _ctxLabBlock()),
      };
    }
    return switch (st) {
      0 => (_ctxCcBlock(), _ctxNoteBlock()),
      1 => (_ctxNoteBlock(), _ctxHistoryBlock()),
      2 => (_ctxPeBlock(), _ctxLabBlock()),
      3 => (_ctxAccidentBlock(), _ctxLabBlock()),
      4 => (_ctxLabBlock(), _ctxMedBlock()),
      _ => (_ctxDispositionBlock(), _ctxLabBlock()),
    };
  }

  /// แตะค่าใน checklist เพื่อแก้ด้วยมือ (ASR ฟังผิด) ไม่ต้องพูดใหม่
  Future<void> _editField(String label, {String? title}) async {
    final ctrl = TextEditingController(text: _filled[_speechStep][label] ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? label, style: _t(13.0, weight: FontWeight.w700)),
        content: SizedBox(
          width: 560.0,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 4,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
            style: _t(12.5, height: 1.45),
            decoration: const InputDecoration(
                hintText: 'พิมพ์ข้อความ (ยาวได้หลายประโยค)',
                border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: Text('ล้างค่า', style: _t(11.0, color: _red))),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text('บันทึก', style: _t(11.0, color: Colors.white))),
        ],
      ),
    );
    if (v == null || !mounted) return;
    setState(() {
      if (v.isEmpty) {
        _filled[_speechStep].remove(label);
      } else {
        _filled[_speechStep][label] = v;
      }
      _allergyWarn = _allergyConflict();
    });
  }

  // ------------------------------------------------ หน้าสรุปเคสด้วย AI
  /// เปิดหน้าสรุป: หุ่นเปลี่ยนเป็นเอกซเรย์พื้นมืด แล้วให้ LLM สรุปจากข้อมูลเคสทั้งหมด
  Future<void> _openSummary({bool refresh = false}) async {
    final hn = _caseP().hn;
    setState(() {
      _summaryOpen = true;
      _fabOpen = false;
      _timelineOpen = false;
      _summaryErr = null;
    });
    if (!refresh && _summaryCache.containsKey(hn)) return;
    setState(() => _summaryBusy = true);
    final t0 = DateTime.now();
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': '''
คุณคือแพทย์เวชศาสตร์ฉุกเฉินอาวุโส สรุปเคสผู้ป่วยห้องฉุกเฉินให้ทีมอ่านใน 10 วินาที
ใช้เฉพาะข้อมูลที่ให้มา ห้ามแต่งผลตรวจหรือยาที่ไม่มี ภาษาไทยปนศัพท์แพทย์อังกฤษได้
ทุกช่องเขียนภาษาไทยเป็นหลัก ใช้อังกฤษเฉพาะศัพท์แพทย์/ชื่อยา/ชื่อแล็บ
ตอบ JSON เท่านั้น รูปแบบ:
{"headline":"<สรุป 1 บรรทัดภาษาไทย (ศัพท์แพทย์อังกฤษได้) ไม่เกิน 14 คำ>",
 "severity":"critical|urgent|stable",
 "summary":"<ย่อหน้าเดียว 2-3 ประโยค: ใคร มาด้วยอะไร ตอนนี้เป็นอย่างไร>",
 "problems":[{"title":"<ปัญหา>","organ":"brain|heart|lungs|liver|stomach|kidneys|intestine|bladder","status":"critical|urgent|stable","detail":"<หลักฐานสั้น ๆ เช่น ค่าแล็บ/สัญญาณชีพ>"}],
 "red_flags":["<สิ่งอันตรายที่ต้องจับตา>"],
 "done":["<สิ่งที่ทำไปแล้ว>"],
 "pending":["<ผล/งานที่ค้าง>"],
 "next_actions":[{"text":"<สิ่งที่ควรทำต่อ>","owner":"แพทย์|พยาบาล","urgent":true}],
 "disposition":"<แนวทางจำหน่ายที่เหมาะ พร้อมเหตุผลสั้น>"}
problems ไม่เกิน 4 ข้อ organ ต้องเป็นหนึ่งในรายการที่กำหนด red_flags/pending/done ไม่เกิน 4 ข้อ next_actions ไม่เกิน 4 ข้อ''',
        },
        {'role': 'user', 'content': 'ข้อมูลเคส:\n${_caseContext()}'},
      ], json: true, fast: true, maxTokens: 900, temperature: 0.2);
      debugPrint(
          'ErAi สรุปเคส ${DateTime.now().difference(t0).inMilliseconds} ms');
      final data = ErAi.extractJson(out);
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = data ?? _fallbackSummary();
        if (data == null)
          _summaryErr = 'AI ตอบไม่เป็นรูปแบบ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = _fallbackSummary();
        _summaryErr = 'เชื่อมต่อ AI ไม่ได้ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    }
  }

  /// สรุปสำรองจากข้อมูลเคสตรง ๆ เมื่อ AI ใช้ไม่ได้
  Map<String, dynamic> _fallbackSummary() {
    final c = _case;
    final p = _caseP();
    final organs = _organsOfCase(c);
    return {
      'headline': c.dx.isNotEmpty ? c.dx.first.text : c.cc,
      'severity': (p.esi?.level ?? 3) <= 1
          ? 'critical'
          : ((p.esi?.level ?? 3) <= 2 ? 'urgent' : 'stable'),
      'summary': '${c.sex} ${c.age} ปี ${c.cc}',
      'problems': [
        for (var i = 0; i < c.dx.length && i < 4; i++)
          {
            'title': c.dx[i].text,
            'organ': organs.isEmpty ? 'heart' : organs[i % organs.length],
            'status':
                c.dx[i].level.name == 'normal' ? 'stable' : c.dx[i].level.name,
            'detail': c.dx[i].icd10 ?? '',
          }
      ],
      'red_flags': c.advice,
      'done': [for (final m in c.meds) '${m.name} ${m.time}'],
      'pending': [
        for (final i in c.imaging)
          if (i.result.contains('รอ')) i.name
      ],
      'next_actions': [
        {'text': c.nextStep, 'owner': 'แพทย์', 'urgent': true}
      ],
      'disposition': c.disposition.isEmpty ? c.nextDetail : c.disposition,
    };
  }

  Map<String, dynamic>? get _summary => _summaryCache[_caseP().hn];

  /// อวัยวะที่ให้หุ่นเรืองแสงในหน้าสรุป
  List<String> _summaryOrgans() {
    const ok = {
      'brain',
      'heart',
      'lungs',
      'liver',
      'stomach',
      'kidneys',
      'intestine',
      'bladder'
    };
    final list = [
      for (final pr in (_summary?['problems'] as List? ?? const []))
        if (pr is Map && ok.contains(pr['organ'])) pr['organ'] as String
    ];
    // กระดูกที่หักมาจากตัว map เสมอ (LLM สรุปเฉพาะอวัยวะ)
    final bones = [
      for (final c in _bodyCodesOfCase(_case))
        if (c.startsWith('bone:')) c,
    ];
    return [
      ...(list.isEmpty ? _organsOfCase(_case) : list.toSet().toList()),
      ...bones,
    ];
  }

  static List<String> _strList(Object? v) => [
        for (final x in (v is List ? v : const []))
          if (x is String && x.trim().isNotEmpty) x
      ];

  static Color _sevColor(Object? s) => switch (s) {
        'critical' => _dRed,
        'urgent' => _dAmber,
        _ => _dGreen,
      };

  static String _sevLabel(Object? s) => switch (s) {
        'critical' => 'วิกฤต',
        'urgent' => 'เร่งด่วน',
        _ => 'คงที่',
      };

  Widget _dCard(Widget child, {EdgeInsets? pad, Color? glow}) => Container(
        padding: pad ?? const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: _dPanel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: glow?.withValues(alpha: 0.55) ?? _dLine),
          boxShadow: [
            if (glow != null)
              BoxShadow(
                  color: glow.withValues(alpha: 0.12),
                  blurRadius: 18.0,
                  spreadRadius: 1.0),
          ],
        ),
        child: child,
      );

  Widget _dHead(IconData icon, String text, {Color color = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Icon(icon, size: 13.0, color: color),
          const SizedBox(width: 6.0),
          Text(text, style: _t(10.5, color: color, weight: FontWeight.w700)),
        ]),
      );

  Widget _dBullet(String text, {Color dot = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5.0,
              height: 5.0,
              margin: const EdgeInsets.only(top: 6.0, right: 8.0),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            Expanded(
                child: Text(text, style: _t(10.5, color: _dInk, height: 1.35))),
          ],
        ),
      );

  /// ตัวเลขใหญ่แบบภาพอ้างอิง: ค่าผิดปกติเป็นสีแดงเรืองแสง
  Widget _dMetric(String label, String value, String unit, bool bad,
          {IconData? icon}) =>
      _dCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 12.0, color: bad ? _dRed : _dInk2),
                const SizedBox(width: 5.0),
              ],
              Text(label, style: _t(9.5, color: _dInk2)),
            ]),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(26.0,
                            color: bad ? _dRed : _dInk, weight: FontWeight.w700)
                        .copyWith(shadows: [
                      if (bad)
                        Shadow(
                            color: _dRed.withValues(alpha: 0.6),
                            blurRadius: 14.0),
                    ])),
                const SizedBox(width: 4.0),
                Text(unit, style: _t(9.5, color: _dInk2)),
              ],
            ),
          ],
        ),
        pad: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
        glow: bad ? _dRed : null,
      );

  List<Widget> _summaryOverlays() {
    final c = _case;
    final p = _caseP();
    final s = _summary;
    final sev = s?['severity'];
    bool out(double v, double lo, double hi) => v < lo || v > hi;
    final gcs = int.tryParse(c.gcsScore);
    final left = ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
      children: [
        // ตัวตนผู้ป่วย + ความรุนแรงรวม
        _dCard(
          Row(children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: _sevColor(sev).withValues(alpha: 0.2),
              child: Icon(Icons.person_rounded, color: _sevColor(sev)),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: _t(14.0, color: _dInk, weight: FontWeight.w700)),
                  Text(
                      '${c.sex} ${c.age} ปี · HN ${p.hn} · เตียง ${p.bed ?? '—'}',
                      style: _t(9.5, color: _dInk2)),
                  const SizedBox(height: 4.0),
                  Wrap(spacing: 5.0, runSpacing: 4.0, children: [
                    _dChip(
                        p.esi == null ? 'ยังไม่คัดกรอง' : 'ESI ${p.esi!.level}',
                        p.esi?.hue ?? _dInk2),
                    _dChip('${p.stage.label} · ${_clockWait(p.waitMin)}',
                        _dAccent),
                    if (c.onset != null)
                      _dChip(
                          'เริ่มอาการ ${_clockWait(_minutesSince(c.onset!))}',
                          _dRed),
                  ]),
                ],
              ),
            ),
          ]),
          glow: _sevColor(sev),
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14.0, color: _dAccent),
              const SizedBox(width: 6.0),
              Text('AI สรุปเคส',
                  style: _t(10.5, color: _dAccent, weight: FontWeight.w700)),
              const Spacer(),
              if (s != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: _sevColor(sev).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(_sevLabel(sev),
                      style: _t(9.0,
                          color: _sevColor(sev), weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 8.0),
            if (_summaryBusy || s == null)
              Row(children: [
                const SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: _dAccent)),
                const SizedBox(width: 8.0),
                Text('กำลังอ่านข้อมูลทั้งเคสและสรุป…',
                    style: _t(10.5, color: _dInk2)),
              ])
            else ...[
              Text(s['headline']?.toString() ?? '',
                  style: _t(15.0,
                      color: _dInk, weight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 6.0),
              Text(s['summary']?.toString() ?? '',
                  style: _t(11.0, color: _dInk, height: 1.45)),
              if (_summaryErr != null) ...[
                const SizedBox(height: 6.0),
                Text(_summaryErr!, style: _t(9.0, color: _dAmber)),
              ],
            ],
          ],
        )),
        if (s != null && _strList(s['red_flags']).isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dHead(Icons.warning_amber_rounded, 'ต้องจับตา', color: _dRed),
                for (final f in _strList(s['red_flags']))
                  _dBullet(f, dot: _dRed),
              ],
            ),
            glow: _dRed,
          ),
        ],
        if (c.allergies.isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.block_rounded, 'แพ้ยา / แพ้อาหาร', color: _dRed),
              Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final a in c.allergies) _dChip(a, _dRed),
              ]),
            ],
          )),
        ],
      ],
    );

    final problems = [
      for (final pr in (s?['problems'] as List? ?? const []))
        if (pr is Map) pr
    ];
    final actions = [
      for (final a in (s?['next_actions'] as List? ?? const []))
        if (a is Map) a
    ];
    final right = ListView(
      padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
      children: [
        // ตัวเลขใหญ่: สัญญาณชีพล่าสุด
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.9,
          children: [
            _dMetric(
                'ชีพจร', '${c.hr.last.round()}', 'bpm', out(c.hr.last, 60, 100),
                icon: Icons.favorite_rounded),
            _dMetric('ความดัน', c.bp, 'mmHg', out(c.sbp.last, 90, 140),
                icon: Icons.monitor_heart_rounded),
            _dMetric('SpO₂', '${c.spo2.last.round()}', '%',
                out(c.spo2.last, 94, 100),
                icon: Icons.bubble_chart_rounded),
            _dMetric('GCS', c.gcsScore, '/15', gcs != null && gcs < 15,
                icon: Icons.psychology_rounded),
          ],
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.biotech_rounded, 'ปัญหาหลัก · ตำแหน่งบนร่างกาย'),
            if (problems.isEmpty)
              Text(_summaryBusy ? '…' : 'ไม่มีปัญหาเร่งด่วน',
                  style: _t(10.5, color: _dInk2)),
            for (final pr in problems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(top: 5.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: _sevColor(pr['status']),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _sevColor(pr['status'])
                                  .withValues(alpha: 0.7),
                              blurRadius: 8.0),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pr['title']?.toString() ?? '',
                              style: _t(11.0,
                                  color: _dInk, weight: FontWeight.w700)),
                          if ((pr['detail']?.toString() ?? '').isNotEmpty)
                            Text(pr['detail'].toString(),
                                style: _t(9.5, color: _dInk2, height: 1.3)),
                        ],
                      ),
                    ),
                    Text(_organTh(pr['organ']),
                        style: _t(9.0, color: _dAccent)),
                  ],
                ),
              ),
          ],
        )),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.bolt_rounded, 'ควรทำต่อ', color: _dAccent),
            if (actions.isEmpty)
              Text(_summaryBusy ? '…' : '-', style: _t(10.5, color: _dInk2)),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        a['urgent'] == true
                            ? Icons.priority_high_rounded
                            : Icons.arrow_right_rounded,
                        size: 14.0,
                        color: a['urgent'] == true ? _dRed : _dInk2),
                    const SizedBox(width: 4.0),
                    Expanded(
                        child: Text(a['text']?.toString() ?? '',
                            style: _t(10.5, color: _dInk, height: 1.3))),
                    const SizedBox(width: 6.0),
                    _dChip(a['owner']?.toString() ?? 'แพทย์', _dInk2),
                  ],
                ),
              ),
          ],
        )),
        if (s != null) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.task_alt_rounded, 'ทำไปแล้ว', color: _dGreen),
              for (final d in _strList(s['done'])) _dBullet(d, dot: _dGreen),
              const SizedBox(height: 4.0),
              _dHead(Icons.hourglass_top_rounded, 'รอผล / ค้าง',
                  color: _dAmber),
              if (_strList(s['pending']).isEmpty)
                Text('ไม่มี', style: _t(10.5, color: _dInk2)),
              for (final d in _strList(s['pending'])) _dBullet(d, dot: _dAmber),
            ],
          )),
        ],
      ],
    );

    return [
      Positioned(left: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: left),
      Positioned(right: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: right),
      // แถบล่างกลาง: แนวทางจำหน่าย + ปุ่ม
      Positioned(
        left: 372.0,
        right: 372.0,
        bottom: 14.0,
        child: _dCard(
          Row(children: [
            const Icon(Icons.logout_rounded, size: 16.0, color: _dAccent),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('แนวทางจำหน่าย', style: _t(9.0, color: _dInk2)),
                  Text(
                      s?['disposition']?.toString() ??
                          (_summaryBusy ? 'กำลังประเมิน…' : '-'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0,
                          color: _dInk, weight: FontWeight.w600, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            _dButton(Icons.copy_rounded, 'คัดลอก', () {
              final sm = _summary;
              if (sm == null) return;
              Clipboard.setData(ClipboardData(
                  text:
                      '${p.name} HN ${p.hn}\n${sm['headline']}\n${sm['summary']}\n'
                      'แผน: ${sm['disposition']}'));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('คัดลอกสรุปแล้ว')));
            }),
            const SizedBox(width: 6.0),
            _dButton(Icons.refresh_rounded, 'สรุปใหม่',
                _summaryBusy ? null : () => _openSummary(refresh: true)),
            const SizedBox(width: 6.0),
            _dButton(Icons.close_rounded, 'ปิด',
                () => setState(() => _summaryOpen = false)),
          ]),
          pad: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
        ),
      ),
    ];
  }

  Widget _dChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child:
            Text(text, style: _t(9.0, color: color, weight: FontWeight.w700)),
      );

  Widget _dButton(IconData icon, String label, VoidCallback? onTap) => Material(
        color: _blue.withValues(alpha: onTap == null ? 0.03 : 0.07),
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            child: Row(children: [
              Icon(icon, size: 14.0, color: _dInk),
              const SizedBox(width: 5.0),
              Text(label,
                  style: _t(10.0, color: _dInk, weight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  static String _organTh(Object? o) => switch (o) {
        'brain' => 'สมอง',
        'heart' => 'หัวใจ',
        'lungs' => 'ปอด',
        'liver' => 'ตับ',
        'stomach' => 'กระเพาะ',
        'kidneys' => 'ไต',
        'intestine' => 'ลำไส้',
        'bladder' => 'กระเพาะปัสสาวะ',
        _ => '',
      };

  /// ฟอร์มที่กำลังดูใน tab ฟอร์ม HOSxP
  String _kbFormId = 'patient_screening';

  /// tab ฟอร์ม HOSxP: ข้อมูลดิบจาก er_form_kb.json ยังไม่ตกแต่ง
  /// ซ้าย = รายชื่อฟอร์ม ขวา = section/ช่อง/ตัวเลือก + ค่าที่ผู้ช่วยเสียงจับได้
  List<Widget> _kbOverlays() {
    final kb = ErFormKb.maybe;
    if (kb == null) {
      return [
        const Positioned(
            left: 0.0, top: 0.0, child: Text('กำลังโหลด er_form_kb.json…')),
      ];
    }
    // ค่าที่ AI จับได้จากทุกขั้น รวมเป็นแผนที่ชื่อช่อง → ค่า
    final got = <String, String>{};
    for (final m in _filled) {
      got.addAll(m);
    }
    final form = kb.form(_kbFormId) ?? kb.forms.first;
    return [
      Positioned(
        left: 0.0,
        top: 0.0,
        bottom: 0.0,
        width: 250.0,
        child: Container(
          color: _panel,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text('forms: ${kb.forms.length}', style: _t(10.0, color: _ink3)),
              for (final f in kb.forms)
                InkWell(
                  onTap: () => setState(() => _kbFormId = f['id'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                        '${f['id'] == _kbFormId ? '▶ ' : ''}${f['title']}  [${f['role']}]',
                        style: _t(11.0,
                            color: f['id'] == _kbFormId ? _blue : _ink,
                            weight: f['id'] == _kbFormId
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ),
                ),
            ],
          ),
        ),
      ),
      Positioned(
        left: 258.0,
        right: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: Container(
          color: _panel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: SelectableText(_kbRaw(form, got),
                style: _t(11.0, color: _ink, height: 1.5)),
          ),
        ),
      ),
    ];
  }

  /// ข้อความดิบของฟอร์มหนึ่ง (ยังไม่ตกแต่ง)
  static String _kbRaw(Map<String, dynamic> f, Map<String, String> got) {
    final b = StringBuffer();
    b.writeln('id: ${f['id']}');
    b.writeln('title: ${f['title']}');
    b.writeln('role: ${f['role']}');
    b.writeln('purpose: ${f['purpose']}');
    b.writeln('source: ${f['source']}');
    b.writeln();
    for (final s in (f['sections'] as List<dynamic>? ?? const [])) {
      b.writeln('== ${s['title']} ==');
      for (final fd in (s['fields'] as List<dynamic>? ?? const [])) {
        final label = fd['label'] as String;
        b.write('  • $label  <${fd['type']}>');
        if (fd['required'] == true) b.write(' *');
        final hint = fd['hint'];
        if (hint is String && hint.isNotEmpty) b.write('  hint: $hint');
        b.writeln();
        final opts = fd['options'];
        if (opts is List && opts.isNotEmpty) {
          b.writeln('      options: ${opts.join(' | ')}');
        }
        final v = got[label];
        if (v != null) b.writeln('      ค่าจากผู้ช่วยเสียง: $v');
      }
      b.writeln();
    }
    return b.toString();
  }

  /// แถบบนของหน้ารายละเอียด
  ///
  /// ตามผัง 58:697 — ซ้ายสุดคือย้อนกลับ ตามด้วยแท็บ ขวาสุดคือบันทึก
  /// ชื่อผู้ป่วยอยู่กับแท็บ ไม่ต้องทำเป็นปุ่มย้อนกลับซ้อนอีกอันเหมือนเดิม
  /// แท็บแบบขีดเส้นใต้ ตามแบบที่ผู้ใช้ส่งมา — ไม่มีพื้นหลัง มีแค่เส้นใต้ตัวที่เลือก
  Widget _detailTabItem(int i) {
    final on = i == _detailTab;
    return InkWell(
      onTap: () => setState(() => _detailTab = i),
      child: Container(
        height: 55.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        alignment: Alignment.center,
        // เส้นใต้แท็บที่เลือก วาดเป็นขอบล่างของแท็บเอง จึงชิดขอบแถบพอดี
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(color: on ? _blue : Colors.transparent, width: 3.0),
          ),
        ),
        child: Text(
          _detailTabs[i],
          style: _t(12.0,
              color: on ? _inkTitle : _ink3,
              weight: on ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }

  /// ป้ายคนไข้บนแถบบน: ชื่อ อายุ HN เตียง + ชิป ESI + ขั้นงานปัจจุบันใน ER
  Widget _patientHeader(_P p) {
    final c = erCaseOf(p.hn);
    final esi = p.esi;
    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
                Text(
                    '${c.sex} · ${c.age} ปี · HN ${p.hn} · เตียง ${p.bed ?? '—'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5, color: _ink3)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: esi == null ? _g5 : esi.hue,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(
              esi == null ? 'ยังไม่คัดกรอง' : 'ESI ${esi.level} · ${esi.label}',
              style: _t(9.5, color: Colors.white, weight: FontWeight.w700)),
        ),
        if (c.onset != null) ...[
          const SizedBox(width: 6.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: _redHue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: _redHue.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 11.0, color: _redHue),
                const SizedBox(width: 4.0),
                Text(
                    'เริ่ม ${c.onset} · ${_clockShort(_minutesSince(c.onset!))}',
                    style: _t(9.5, color: _redHue, weight: FontWeight.w700)),
              ],
            ),
          ),
        ],
        const SizedBox(width: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: _blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.route_rounded, size: 11.0, color: _blue),
              const SizedBox(width: 4.0),
              Text('${p.stage.label} · ${_clockShort(p.waitMin)}',
                  style: _t(9.5, color: _blueHue, weight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  static String _clockWait(int m) =>
      m >= 60 ? '${m ~/ 60} ชม. ${m % 60} น.' : '$m นาที';

  /// แบบสั้นสำหรับชิปบนแถบบน
  static String _clockShort(int m) => m >= 60
      ? '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')} ชม.'
      : '$m น.';

  /// นาฬิกาจำลองของฉาก (ข้อมูล mock อิงเวลานี้)
  static const String _simNow = '10:25';
  static int _minutesSince(String hhmm) {
    int toMin(String t) {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    return (toMin(_simNow) - toMin(hhmm)).clamp(0, 24 * 60);
  }

  Widget _detailTopBar() {
    final p = _sceneSelected(_open!);
    return Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Material(
            color: _panelSoft,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() {
                _detail = false;
                _timelineOpen = false;
              }),
              child: const SizedBox(
                width: 34.0,
                height: 34.0,
                child: Icon(Icons.arrow_back_rounded, size: 19.0, color: _ink),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          for (var i = 0; i < _detailTabs.length; i++) _detailTabItem(i),
          const SizedBox(width: 6.0),
          Expanded(
            child: _patientHeader(p),
          ),
          // เปิดหน้าสรุปเคสด้วย AI
          Material(
            color: _summaryOpen ? _blue : _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _summaryOpen
                  ? setState(() => _summaryOpen = false)
                  : _openSummary(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 15.0, color: _summaryOpen ? Colors.white : _blue),
                  const SizedBox(width: 5.0),
                  Text('สรุปเคส AI',
                      style: _t(11.0,
                          color: _summaryOpen ? Colors.white : _blueHue,
                          weight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // เปิด/ปิดลิ้นชักเส้นเวลา
          Material(
            color: _timelineOpen ? _blue : _panelSoft,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _timelineOpen = !_timelineOpen),
              child: SizedBox(
                width: 34.0,
                height: 34.0,
                child: Icon(Icons.history_rounded,
                    size: 19.0, color: _timelineOpen ? Colors.white : _ink),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Material(
            color: _blue,
            borderRadius: BorderRadius.circular(100.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 16.0, color: Colors.white),
                    const SizedBox(width: 7.0),
                    Text('บันทึก',
                        style: _t(12.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// คอลัมน์ซ้าย: กราฟแท่งสัญญาณชีพทีละค่า + ช่องเพิ่ม
  Widget _detailCharts() => SizedBox(
        width: 250.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
          children: [
            Column(
              children: [
                for (final v in _caseVitals().take(4)) _vitalBarsCard(v),
              ],
            ),
            _dashedAdd('เพิ่มกราฟ'),
          ],
        ),
      );

  // ------------------------------------------- คอลัมน์ 2 ปัญหา ยา แพ้ยา
  /// รายการที่พยาบาลต้องเห็นก่อนแตะตัวผู้ป่วย — วินิจฉัย แพ้ยา ยาที่ให้ไปแล้ว
  Widget _detailProblems() => SizedBox(
        width: 216.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
          children: [
            _detailBlock('ปัญหา / วินิจฉัย', [
              if (_case.dx.isEmpty)
                Text('ยังไม่มีการวินิจฉัย', style: _t(10.5, color: _ink3)),
              for (final d in _case.dx)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.only(top: 4.0, right: 7.0),
                        decoration: BoxDecoration(
                            color: _levelColor(d.level),
                            shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Text(d.text,
                            style: _t(11.0, color: _ink, height: 1.25)),
                      ),
                    ],
                  ),
                ),
            ]),
            _detailBlock('แพ้ยา / แพ้อาหาร', [
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: [
                  if (_case.allergies.isEmpty)
                    Text('ไม่มีประวัติแพ้', style: _t(10.5, color: _ink3)),
                  for (final a in _case.allergies)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(a,
                          style:
                              _t(10.5, color: _red, weight: FontWeight.w600)),
                    ),
                ],
              ),
            ]),
            _detailBlock('ยาที่ให้แล้ว', [
              if (_case.meds.isEmpty)
                Text('ยังไม่ได้ให้ยา', style: _t(10.5, color: _ink3)),
              for (final m in _case.meds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(11.0, weight: FontWeight.w600)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(m.route,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(9.5, color: _ink2)),
                          ),
                          Text(m.time, style: _num(9.5, color: _ink3)),
                        ],
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      );

  // ------------------------------------------ คอลัมน์ 3 ผลตรวจล่าสุด
  /// ค่าแล็บพร้อมแถบช่วงปกติ อ่านออกทันทีว่าค่าไหนหลุดช่วง
  Widget _detailLabs() => SizedBox(
        width: 264.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 12.0),
          children: [
            _detailBlock('ผลแล็บล่าสุด · ${_case.times.last} น.', [
              if (_case.labs.isEmpty)
                Text('ยังไม่มีผลแล็บ', style: _t(10.5, color: _ink3)),
              if (_case.labs.isNotEmpty) ...[
                _labHead(),
                for (final l in _case.labs) _labRow(_labTuple(l)),
              ],
            ]),
            _detailBlock('ภาพถ่ายทางรังสี', [
              if (_case.imaging.isEmpty)
                Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(10.5, color: _ink3)),
              Row(
                children: [
                  for (final img in _case.imaging)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                height: 62.0,
                                color: Colors.black,
                                child: Image.asset(img.asset,
                                    fit: BoxFit.cover, width: double.infinity),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(img.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(9.5, weight: FontWeight.w600)),
                            Text(img.result,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(8.5, color: _ink2)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ]),
          ],
        ),
      );

  /// หัวคอลัมน์ของตารางแล็บ
  Widget _labHead() => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          children: [
            Expanded(child: Text('รายการ', style: _t(8.5, color: _ink3))),
            Text('ค่า / ปกติ', style: _t(8.5, color: _ink3)),
          ],
        ),
      );

  /// ค่าแล็บหนึ่งบรรทัด — ชื่อ แถบจุดบอกว่าอยู่ตรงไหนของช่วง และค่า/ค่าปกติ
  ///
  /// แถบเป็นจุดถี่ ๆ ไม่ใช่แท่งทึบ อ่านระดับได้เป็นขั้น ๆ ตามผัง 181:3803
  /// ขีดคั่นคือเพดานปกติ จุดที่เลยขีดไปคือส่วนที่ผิดปกติ
  Widget _labRow((String, double, double, double) l) {
    final (name, value, lo, hi) = l;
    final bad = value < lo || value > hi;
    final tone = bad ? _red : _blue;
    const dots = 16;
    final scale = hi * 1.45;
    final filled = ((value / scale) * dots).round().clamp(0, dots);
    final markAt = ((hi / scale) * dots).round().clamp(1, dots - 1);
    // ค่าผิดปกติ: ตัวเลขแดงหนา + ป้าย H/L แบบรายงานแล็บ ไม่ลงสีทั้งแถว
    return Padding(
      padding: const EdgeInsets.only(bottom: 9.0),
      child: Row(
        children: [
          SizedBox(
            width: 58.0,
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.5, color: _ink, weight: FontWeight.w700)),
          ),
          Expanded(
            child: Container(
              height: 12.0,
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < dots; i++) ...[
                    if (i == markAt)
                      Container(
                        width: 1.2,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        color: _ink3,
                      ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 3.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: i < filled
                                ? tone
                                : _ink3.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            width: 70.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_numText(value),
                    style: _num(12.0,
                        color: bad ? _red : _ink,
                        weight: bad ? FontWeight.w800 : FontWeight.w600)),
                Text(' | ', style: _t(9.5, color: _ink3)),
                Text(_numText(hi), style: _num(9.5, color: _ink3)),
              ],
            ),
          ),
          SizedBox(
            width: 22.0,
            child: bad
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(value > hi ? 'H' : 'L',
                          style: _t(9.0,
                              color: Colors.white, weight: FontWeight.w800)),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  static String _numText(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  // ------------------------------------------- คอลัมน์ 4 สรุปและทีม
  /// การ์ดหัวสีหลักคือสิ่งที่จะเกิดต่อไป ใต้ลงมาเป็นทีมดูแล บันทึก และคำแนะนำ
  Widget _detailSide() {
    final p = _sceneSelected(_open!);
    return SizedBox(
      width: 236.0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ขั้นถัดไป',
                    style: _t(10.5, color: _pInk3, weight: FontWeight.w600)),
                const SizedBox(height: 6.0),
                Text(_case.nextStep.isEmpty ? 'รอแพทย์' : _case.nextStep,
                    style: _t(15.0, color: _pInk, weight: FontWeight.w700)),
                const SizedBox(height: 2.0),
                Text(_case.nextDetail, style: _t(10.5, color: _pInk2)),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    _sideKpi('เตียง', p.bed ?? '—'),
                    const SizedBox(width: 14.0),
                    _sideKpi('ESI', '${p.esi?.level ?? '—'}'),
                    const SizedBox(width: 14.0),
                    _sideKpi('รอแล้ว', _hm(p.waitMin)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          _detailBlock('ทีมผู้ดูแล', [
            for (var i = 0; i < _case.team.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset('assets/images/faces/face$i.jpg',
                          width: 26.0, height: 26.0, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_case.team[i].$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10.5, weight: FontWeight.w600)),
                          Text(_case.team[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(9.0, color: _ink2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ]),
          _detailBlock('บันทึกล่าสุด', [
            if (_case.lastNote == null)
              Text('ยังไม่มีบันทึก', style: _t(10.5, color: _ink3)),
            if (_case.lastNote != null) ...[
              Text('${_case.lastNote!.time} น. · ${_case.lastNote!.by}',
                  style: _t(9.5, color: _ink3)),
              const SizedBox(height: 3.0),
              Text(_case.lastNote!.text,
                  style: _t(10.5, color: _ink, height: 1.35)),
            ],
          ]),
          _detailBlock('คำแนะนำของระบบ', [
            if (_case.advice.isEmpty)
              Text('ไม่มีคำแนะนำเพิ่มเติม', style: _t(10.5, color: _ink3)),
            for (final a in _case.advice)
              Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child:
                          Text(a, style: _t(10.0, color: _ink2, height: 1.3)),
                    ),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _sideKpi(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: _t(9.0, color: _pInk3)),
          Text(value, style: _num(12.5, color: _pInk, weight: FontWeight.w700)),
        ],
      );

  /// กล่องหัวข้อหนึ่งบล็อกในคอลัมน์ของหน้ารายละเอียด
  Widget _detailBlock(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }

  /// เครื่องหมายอาการบนตัวหุ่น: วงแดงมีวงจางล้อมรอบ
  /// จุดอาการบนตัวหุ่น แตะเพื่อเพ่งบริเวณนั้น แตะซ้ำเพื่อเลิกเพ่ง
  Widget _hotspotMark(String key) {
    final on = _focusSpot == key;
    return GestureDetector(
      onTap: () => setState(() => _focusSpot = on ? null : key),
      child: Container(
        width: 30.0,
        height: 30.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (on ? _amber : _red).withValues(alpha: on ? 0.28 : 0.18),
        ),
        child: Container(
          width: on ? 13.0 : 11.0,
          height: on ? 13.0 : 11.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? _amber : _red,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
        ),
      ),
    );
  }

  /// การ์ดกราฟแท่งของสัญญาณชีพหนึ่งค่า แท่งสุดท้ายคือค่าล่าสุด
  /// ค่าของแท่งที่ i (ความดันแสดงเป็น ตัวบน/ตัวล่าง)
  String _vsValue(ErVital v, int i) {
    final c = _case;
    if (v.unit == 'mmHg' && i < c.sbp.length && i < c.dbp.length) {
      return '${c.sbp[i].round()}/${c.dbp[i].round()}';
    }
    final x = v.series[i];
    return x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
  }

  /// กราฟแท่งสัญญาณชีพ: ทุกแท่งมีค่ากำกับ แตะหรือลากนิ้วบนกราฟเพื่อเลือกรอบ
  /// หัวการ์ดแสดงค่า + เวลาของรอบที่เลือก (ตั้งต้น = รอบล่าสุด)
  Widget _vitalBarsCard(ErVital v) {
    final lo = v.series.reduce((a, b) => a < b ? a : b);
    final hi = v.series.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;
    final n = v.series.length;
    final pick = (_vsPick[v.label] ?? n - 1).clamp(0, n - 1);
    final picked = pick != n - 1;
    final time = pick < _case.times.length ? _case.times[pick] : '';
    void choose(double dx, double w) {
      final idx = (dx / w * n).floor().clamp(0, n - 1);
      if (idx != _vsPick[v.label]) setState(() => _vsPick[v.label] = idx);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: picked ? v.line : _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(v.icon, size: 14.0, color: v.line),
              const SizedBox(width: 6.0),
              Text(v.label,
                  style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
              const Spacer(),
              if (picked) ...[
                Text('$time น.', style: _num(9.0, color: _ink3)),
                const SizedBox(width: 5.0),
              ],
              Text(
                  picked ? _vsValue(v, pick) : (v.display ?? _vsValue(v, pick)),
                  style: _num(14.0, color: v.color, weight: FontWeight.w700)),
              const SizedBox(width: 3.0),
              Text(v.unit, style: _t(9.5, color: _ink3)),
            ],
          ),
          const SizedBox(height: 6.0),
          SizedBox(
            height: 84.0,
            child: LayoutBuilder(builder: (context, box) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => choose(d.localPosition.dx, box.maxWidth),
                onHorizontalDragUpdate: (d) =>
                    choose(d.localPosition.dx, box.maxWidth),
                onDoubleTap: () => setState(() => _vsPick.remove(v.label)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(_vsValue(v, i),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: _num(n > 4 ? 7.5 : 8.5,
                                    color: i == pick ? v.color : _ink3,
                                    weight: i == pick
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                            const SizedBox(height: 2.0),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              height: 10.0 + (v.series[i] - lo) / span * 34.0,
                              decoration: BoxDecoration(
                                color: i == pick
                                    ? v.line
                                    : v.line.withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(i < _case.times.length ? _case.times[i] : '',
                                style: _num(8.0,
                                    color: i == pick ? _ink2 : _ink3)),
                          ],
                        ),
                      ),
                      if (i < n - 1) const SizedBox(width: 6.0),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// ช่องเส้นประ "+ เพิ่ม" ตามโครงใน Figma
  Widget _dashedAdd(String label) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () {},
          child: Container(
            height: 64.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: _line, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_box_outlined, size: 18.0, color: _ink3),
                const SizedBox(height: 2.0),
                Text(label, style: _t(10.0, color: _ink3)),
              ],
            ),
          ),
        ),
      );

  /// ปุ่มหลักของเมนูลัด หมุนเป็นกากบาทเมื่อกางเมนูอยู่
  // ================================================== แท็บของแพทย์
  // สามหน้าจอของแพทย์ (Figma 165:2618 ทบทวนระบบ · 165:2615 ตรวจร่างกาย
  // · 169:2801 คำสั่งแพทย์) ยุบมาอยู่ในหน้ารายละเอียดเดียวกัน
  // ใช้ภาษาเดียวกับหน้านี้: การ์ดขาว ขอบ _line มุม 14 ตัวอักษร Sarabun
  // หุ่นสามมิติยังเป็นพื้นหลังเสมอ แผงทั้งหมดลอยทับ

  /// แผงที่ลอยทับฉากตามแท็บที่เลือก
  /// แท็บ → ตารางข้อมูล (แท็บฟอร์ม HOSxP ไม่มีตาราง)
  static const List<ErTab?> _tabTables = [
    ErTab.overview,
    ErTab.triage,
    ErTab.exam,
    ErTab.orders,
    ErTab.vitals,
    ErTab.meds,
    ErTab.labs,
    ErTab.imaging,
    null,
  ];

  /// แท็บที่มีหน้าตาแบบภาพอยู่แล้ว สลับเป็นตารางได้ · แท็บอื่นเป็นตารางอย่างเดียว
  // 0 ภาพรวม · 1 คัดกรอง · 2 ตรวจร่างกาย · 3 คำสั่งแพทย์ · 4 สัญญาณชีพ
  // 5 ยา · 6 แล็บ · 7 ภาพถ่าย · 8 ฟอร์ม HOSxP
  bool get _tableOnly =>
      _detailTab == 1 || (_detailTab >= 4 && _detailTab <= 7);

  /// แท็บที่มีทั้งหน้าตาแบบภาพและตาราง
  bool get _hasToggle => const {0, 3}.contains(_detailTab);

  List<Widget> _tableOverlays() {
    final tab = _tabTables[_detailTab]!;
    return [
      Positioned(
        left: 16.0,
        top: _tableOnly ? 14.0 : 58.0,
        bottom: 16.0,
        child: LayoutBuilder(builder: (context, c) {
          return SizedBox(
            width: math.min(820.0, MediaQuery.of(context).size.width * 0.64),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: ErDetailTable(hn: _caseP().hn, tab: tab),
            ),
          );
        }),
      ),
    ];
  }

  /// ปุ่มสลับ ภาพ | ตาราง ของแท็บภาพรวม ตรวจร่างกาย คำสั่งแพทย์
  Widget _viewToggle() => Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: _line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (i, label, icon) in [
            (0, 'ภาพ', Icons.view_quilt_rounded),
            (1, 'ตาราง', Icons.table_rows_rounded),
          ])
            Material(
              color: (_tableView ? 1 : 0) == i ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => _tableView = i == 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: Row(children: [
                    Icon(icon,
                        size: 14.0,
                        color:
                            (_tableView ? 1 : 0) == i ? Colors.white : _ink3),
                    const SizedBox(width: 4.0),
                    Text(label,
                        style: _t(10.5,
                            color: (_tableView ? 1 : 0) == i
                                ? Colors.white
                                : _ink2,
                            weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
        ]),
      );

  List<Widget> _detailOverlays() {
    final list = _detailOverlaysInner();
    // ปุ่มสลับวางกลางบนของพื้นที่ฉาก เฉพาะแท็บที่มีทั้งภาพและตาราง
    if (!_summaryOpen && !_speechOpen && _hasToggle) {
      return [
        ...list,
        Positioned(
          top: 12.0,
          left: 0.0,
          right: 0.0,
          child: Center(child: _viewToggle()),
        ),
      ];
    }
    return list;
  }

  List<Widget> _detailOverlaysInner() {
    if (_summaryOpen) return _summaryOverlays();
    // โหมดพูดคงหน้าจอของแท็บเดิมไว้ (ไม่สลับเป็นแผงบริบท) orbit ลอยทับด้านล่าง
    if (_tableOnly || (_hasToggle && _tableView)) return _tableOverlays();
    if (_detailTab == 2) return _examOverlays();
    if (_detailTab == 8) return _kbOverlays();
    if (_detailTab == 3) {
      return [
        Positioned(left: 0.0, top: 0.0, bottom: 0.0, child: _orderLeft()),
        Positioned(right: 0.0, top: 0.0, bottom: 0.0, child: _orderRight()),
      ];
    }
    return [
      Positioned(
        left: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: _loading ? _detailChartsSkeleton() : _detailCharts(),
      ),
      if (!_loading)
        Positioned(
            left: 250.0, top: 0.0, bottom: 0.0, child: _detailProblems()),
      if (!_loading)
        Positioned(right: 236.0, top: 0.0, bottom: 0.0, child: _detailLabs()),
      Positioned(
        right: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: _loading ? _detailFieldsSkeleton() : _detailSide(),
      ),
    ];
  }

  // ---------------------------------------------- ตรวจร่างกาย: log ตามเวลา
  // แท็บนี้เป็นประวัติการตรวจทุกครั้งเรียงตามเวลา (ซ้าย → ขวา = เก่า → ใหม่)
  // แถว = ระบบ · คอลัมน์ = ครั้งที่ตรวจ · คอลัมน์สุดท้าย = ครั้งนี้ (บันทึกต่อ)
  // แพทย์เปิดดูแล้วเทียบกับครั้งก่อน ๆ ได้ทันที แล้วพูดบันทึกครั้งใหม่ต่อจากตรงนี้

  List<_ExamRound> get _rounds => _examMode == 0 ? _rosRounds : _peRounds;

  /// การเปลี่ยนแปลงของระบบ key ในครั้งที่ i เทียบกับครั้งก่อนหน้า
  _Change _changeAt(List<_ExamRound> rs, int i, String key) {
    if (i == 0) return _Change.none;
    final now = rs[i].of(key).$1;
    final prev = rs[i - 1].of(key).$1;
    if (now == _Finding.abnormal && prev != _Finding.abnormal) {
      return _Change.newAbn;
    }
    if (now != _Finding.abnormal && prev == _Finding.abnormal) {
      return _Change.better;
    }
    if (now == _Finding.abnormal &&
        prev == _Finding.abnormal &&
        rs[i].of(key).$2 != rs[i - 1].of(key).$2) {
      return _Change.worse;
    }
    return _Change.same;
  }

  /// ระบบใน log → ชื่อช่องในฟอร์มตรวจร่างกายของโหมดพูด (คอลัมน์ "ครั้งนี้")
  static const Map<String, String> _peField = {
    'pe_ga': 'GA',
    'pe_heent': 'HEENT',
    'pe_heart': 'Heart',
    'pe_chest': 'Chest',
    'pe_abd': 'Abdomen',
    'pe_ext': 'Extremities',
    'pe_neuro': 'Neurological',
  };

  /// ขั้นตรวจร่างกายในโหมดพูดของแพทย์
  static const int _peStep = 2;

  List<Widget> _examOverlays() => [
        Positioned.fill(
          child: ColoredBox(
            color: _bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: _examLog(),
            ),
          ),
        ),
      ];

  Widget _examLog() {
    final rs = _rounds;
    final systems = _examMode == 0 ? _rosSystems : _peSystems;
    final last = rs.length - 1;
    final abn = [
      for (final s in systems)
        if (rs[last].of(s.key).$1 == _Finding.abnormal) s
    ];
    final fresh = [
      for (final s in systems)
        if (_changeAt(rs, last, s.key) == _Change.newAbn) s
    ];
    final moved = [
      for (final s in systems)
        if (_changeAt(rs, last, s.key) == _Change.worse) s
    ];
    final better = [
      for (final s in systems)
        if (_changeAt(rs, last, s.key) == _Change.better) s
    ];
    final doctor = !ErSession.instance.isNurse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // หัว: ชื่อ · สลับ PE/ROS · บันทึกครั้งใหม่
        Row(children: [
          Text('ประวัติการตรวจ',
              style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(width: 12.0),
          SizedBox(
            width: 300.0,
            child: _segmented(const ['ทบทวนระบบ (ROS)', 'ตรวจร่างกาย (PE)'],
                _examMode, (i) => setState(() => _examMode = i)),
          ),
          const Spacer(),
          if (doctor && _examMode == 1) ...[
            _uiButton(
                'Template การตรวจ', Icons.bookmarks_rounded, _openPeTemplates,
                primary: false),
            const SizedBox(width: 8.0),
            _uiButton('บันทึกครั้งใหม่ด้วยเสียง', Icons.mic_rounded,
                () => _openSpeech(step: _peStep)),
          ],
        ]),
        const SizedBox(height: 10.0),
        // สรุปครั้งล่าสุดเทียบครั้งก่อน อ่านจบในบรรทัดเดียว
        Wrap(spacing: 8.0, runSpacing: 6.0, children: [
          _logPill(Icons.schedule_rounded,
              'ล่าสุด ${rs[last].time} น. · ${rs[last].by}', _ink2, _panel),
          _logPill(Icons.error_outline_rounded, 'ผิดปกติ ${abn.length} ระบบ',
              abn.isEmpty ? _ink2 : _red, _panel),
          if (fresh.isNotEmpty)
            _logPill(
                Icons.fiber_new_rounded,
                'พบใหม่: ${fresh.map((s) => s.th).join(', ')}',
                _red,
                _red.withValues(alpha: 0.08)),
          if (moved.isNotEmpty)
            _logPill(
                Icons.swap_vert_rounded,
                'ค่าเปลี่ยน: ${moved.map((s) => s.th).join(', ')}',
                _amber,
                _amber.withValues(alpha: 0.08)),
          if (better.isNotEmpty)
            _logPill(
                Icons.trending_up_rounded,
                'ดีขึ้น: ${better.map((s) => s.th).join(', ')}',
                _greenHue,
                _greenHue.withValues(alpha: 0.08)),
        ]),
        const SizedBox(height: 12.0),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: _line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              _logHeader(rs),
              const Divider(height: 1.0, color: _line),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: systems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1.0, color: _line),
                  itemBuilder: (_, r) => _logRow(rs, systems[r]),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  static const double _logSysW = 196.0;

  /// หัวคอลัมน์ = เส้นเวลา: จุดของแต่ละครั้งต่อกันด้วยเส้น ครั้งล่าสุดเน้น
  Widget _logHeader(List<_ExamRound> rs) {
    final last = rs.length - 1;
    Widget node(bool on, {bool dashed = false}) => Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dashed ? _panel : (on ? _blue : _panel),
            border: Border.all(
                color: dashed ? _g5 : (on ? _blue : _ink3), width: 2.0),
            boxShadow: on
                ? [
                    BoxShadow(
                        color: _blue.withValues(alpha: 0.25), spreadRadius: 3.0)
                  ]
                : null,
          ),
        );
    Widget line(bool show) => Expanded(
        child:
            Container(height: 2.0, color: show ? _line : Colors.transparent));
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 10.0),
      child: Row(children: [
        SizedBox(
          width: _logSysW,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('ระบบ',
                style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
          ),
        ),
        for (var i = 0; i < rs.length; i++)
          Expanded(
            child: Column(children: [
              Row(children: [line(i > 0), node(i == last), line(true)]),
              const SizedBox(height: 6.0),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${rs[i].time} น.',
                    style: _num(14.0,
                        color: i == last ? _blueHue : _inkTitle,
                        weight: FontWeight.w700)),
                if (i == last) ...[
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text('ล่าสุด',
                        style: _t(9.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ],
              ]),
              Text(
                  _examMode == 0 && i < _rosMeta.length
                      ? '${_rosMeta[i].$1} · ${rs[i].by}'
                      : 'ครั้งที่ ${i + 1} · ${rs[i].by}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(10.0, color: _ink3)),
            ]),
          ),
        // ครั้งนี้: บันทึกต่อจากครั้งล่าสุด
        Expanded(
          child: Column(children: [
            Row(children: [line(true), node(false, dashed: true), line(false)]),
            const SizedBox(height: 6.0),
            Text('ครั้งนี้',
                style: _t(14.0, color: _ink2, weight: FontWeight.w700)),
            Text(ErSession.instance.user?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.0, color: _ink3)),
          ]),
        ),
      ]),
    );
  }

  Widget _logRow(List<_ExamRound> rs, _System s) {
    final draftLabel = _examMode == 1 ? _peField[s.key] : null;
    final draft = draftLabel == null
        ? null
        : (_peStep < _filled.length ? _filled[_peStep][draftLabel] : null);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _logSysW,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 10.0),
              child: Row(children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Icon(s.icon, size: 16.0, color: _blue),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.th,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(12.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      Text(s.en,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(9.5, color: _ink3)),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          for (var i = 0; i < rs.length; i++)
            Expanded(
                child: _logCell(rs[i].of(s.key), _changeAt(rs, i, s.key),
                    latest: i == rs.length - 1)),
          Expanded(child: _logDraftCell(draftLabel, draft)),
        ],
      ),
    );
  }

  /// ช่องผลหนึ่งครั้ง: สถานะ + บันทึกย่อ + การเปลี่ยนแปลงเทียบครั้งก่อน
  Widget _logCell((_Finding, String) f, _Change ch, {required bool latest}) {
    final (st, note) = f;
    final (label, col) = switch (st) {
      _Finding.abnormal => ('ผิดปกติ', _red),
      _Finding.normal => ('ปกติ', _greenHue),
      _Finding.notDone => ('ไม่ได้ตรวจ', _ink3),
      _Finding.none => ('—', _ink3),
    };
    final change = switch (ch) {
      _Change.newAbn => ('พบใหม่', _red, Icons.fiber_new_rounded),
      _Change.worse => ('เปลี่ยน', _amber, Icons.swap_vert_rounded),
      _Change.better => ('ดีขึ้น', _greenHue, Icons.trending_up_rounded),
      _ => null,
    };
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      decoration: BoxDecoration(
        color: st == _Finding.abnormal
            ? _red.withValues(alpha: latest ? 0.08 : 0.04)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border:
            latest ? Border.all(color: _blue.withValues(alpha: 0.25)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(color: col, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5.0),
            Text(label, style: _t(10.5, color: col, weight: FontWeight.w700)),
            const Spacer(),
            if (change != null)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(change.$3, size: 12.0, color: change.$2),
                const SizedBox(width: 2.0),
                Text(change.$1,
                    style: _t(9.5, color: change.$2, weight: FontWeight.w700)),
              ]),
          ]),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 3.0),
            Text(note,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _t(11.0, color: _ink, height: 1.35)),
          ],
        ],
      ),
    );
  }

  /// ช่อง "ครั้งนี้": ค่าที่บันทึกในโหมดพูดแล้ว หรือปุ่มบันทึกต่อ
  Widget _logDraftCell(String? label, String? value) {
    final canRecord = label != null && !ErSession.instance.isNurse;
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: value != null ? _greenHue : _line),
        color: value != null ? _greenHue.withValues(alpha: 0.05) : _panelSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canRecord ? () => _openSpeech(step: _peStep) : null,
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
            child: value != null
                ? Text(value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _inkTitle, weight: FontWeight.w600))
                : Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(canRecord ? Icons.mic_none_rounded : Icons.remove,
                          size: 14.0, color: _ink3),
                      if (canRecord) ...[
                        const SizedBox(width: 4.0),
                        Text('บันทึกต่อ', style: _t(10.5, color: _ink3)),
                      ],
                    ]),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _logPill(IconData icon, String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: _line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13.0, color: fg),
          const SizedBox(width: 5.0),
          Text(text, style: _t(11.0, color: fg, weight: FontWeight.w600)),
        ]),
      );

  // ---------------------------------------------- ทบทวนอาการตามระบบ (ROS)
  // ข้อมูลครบตามหน้าจอ 165:2618 · ผังตาม wireframe 195:343
  // ซ้าย: หัวข้อ + ขั้นตอน + ค่าผิดปกติ/ความเร่งด่วน · กลาง: หุ่นไฮไลต์ระบบ Positive
  // ขวา: บันทึกการตรวจ (Audit Trail) + สรุป Positive/AI · ล่าง: การ์ดระบบ 3 สถานะ

  /// อวัยวะที่ให้หุ่นเรืองแสง ตามอาการ/ผลตรวจที่ผิดปกติ
  ///
  /// แท็บตรวจร่างกาย: ถ้าเลือกป้ายอยู่ เน้นเฉพาะระบบนั้น ไม่งั้นเน้นทุกระบบ
  /// ที่ผิดปกติในครั้งที่กำลังดู · แท็บอื่น: เน้นตามปัญหา/วินิจฉัยของผู้ป่วย
  List<String> _highlightOrgans() {
    // หน้าอื่น: อวัยวะ + กระดูกที่ map จากอาการสำคัญ/วินิจฉัยของผู้ป่วยรายนี้
    return _bodyCodesOfCase(_case);
  }

  /// เดาอวัยวะจากคำในวินิจฉัยและอาการสำคัญ (คำไทย/อังกฤษที่พบบ่อยใน ER)
  static List<String> _organsOfCase(ErCase c) {
    // ใช้ตัว map กลาง (er_body_map.dart) เอาเฉพาะอวัยวะ
    final out = [
      for (final t in erBodyTargets(c))
        if (t.kind == ErBodyKind.organ) t.id,
    ];
    return out.isEmpty ? const ['heart'] : out.take(3).toList();
  }

  /// ตำแหน่งบนร่างกายของเคส (อวัยวะ + กระดูก) ส่งให้หุ่นสามมิติ
  static List<String> _bodyCodesOfCase(ErCase c) => erBodyCodes(c);

  Widget _miniAction(IconData icon, String label, VoidCallback onTap) =>
      Material(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(8.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13.0, color: _blue),
                const SizedBox(width: 5.0),
                Text(label,
                    style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  /// สลับสองทางแบบเต็มความกว้าง ตัวที่เลือกเป็นสีหลัก
  Widget _segmented(List<String> items, int index, ValueChanged<int> onPick) =>
      Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Material(
                  color: i == index ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onPick(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Center(
                        child: Text(items[i],
                            style: _t(10.5,
                                color: i == index ? Colors.white : _ink2,
                                weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _countBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text(text,
            style: _t(9.5, color: Colors.white, weight: FontWeight.w700)),
      );

  // ---------------------------------------------- คำสั่งแพทย์ (Order set)

  /// คอลัมน์ซ้าย: เลือกชุดคำสั่ง แล้วติ๊กรายการ
  Widget _orderLeft() => SizedBox(
        width: 400.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: _line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('เลือก Order Set',
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      const Spacer(),
                      _orderKey('ยังไม่รับ', _g5),
                      _orderKey('รับแล้ว', _blue),
                      _orderKey('ทำแล้ว', _greenHue),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 32.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 15.0, color: _ink3),
                        const SizedBox(width: 6.0),
                        Text('ค้นหา Template', style: _t(10.5, color: _ink3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: [
                      for (final t in _templates)
                        _chip(t, t == _template,
                            () => setState(() => _template = t)),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_rounded,
                            size: 15.0, color: _blue),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Template สำหรับผู้ป่วย $_template',
                                  style: _t(10.5,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              Text('แนวทางการดูแลตามมาตรฐาน',
                                  style: _t(9.5, color: _ink3)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded,
                            size: 16.0, color: _blue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (final g in _orderGroups) _orderGroupCard(g),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Material(
                color: _blue,
                borderRadius: BorderRadius.circular(12.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_rounded,
                            size: 15.0, color: Colors.white),
                        const SizedBox(width: 7.0),
                        Text(
                            'บันทึกคำสั่งแพทย์ · เลือกแล้ว ${_orderPicked.length} รายการ',
                            style: _t(11.5,
                                color: Colors.white, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _orderKey(String label, Color color) => Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4.0),
            Text(label, style: _t(9.0, color: _ink3)),
          ],
        ),
      );

  Widget _chip(String label, bool on, VoidCallback onTap) => Material(
        color: on ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
            child: Text(label,
                style: _t(10.0,
                    color: on ? Colors.white : _ink2, weight: FontWeight.w600)),
          ),
        ),
      );

  /// กลุ่มคำสั่งหนึ่งหมวด (ยา / เลือด / แล็บ / X-ray / หัตถการ)
  Widget _orderGroupCard(_OrderGroup g) {
    final picked = g.items.where((i) => _orderPicked.contains(i.name)).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 6.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(g.icon, size: 14.0, color: g.color),
              const SizedBox(width: 6.0),
              Text(g.title,
                  style: _t(11.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 6.0),
              Text('($picked/${g.items.length})',
                  style: _num(10.0, color: _ink3)),
              const Spacer(),
              InkWell(
                onTap: () => setState(() {
                  for (final i in g.items) {
                    _orderPicked.add(i.name);
                  }
                }),
                child: Text('เลือกทั้งหมด',
                    style: _t(9.5, color: _blue, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          for (var i = 0; i < g.items.length; i++) ...[
            _orderRow(g.items[i]),
            if (i < g.items.length - 1)
              const Divider(height: 1.0, thickness: 1.0, color: _line),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(_OrderItem it) {
    final on = _orderPicked.contains(it.name);
    return InkWell(
      onTap: () => setState(() {
        if (on) {
          _orderPicked.remove(it.name);
        } else {
          _orderPicked.add(it.name);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16.0,
              height: 16.0,
              margin: const EdgeInsets.only(top: 1.0, right: 8.0),
              decoration: BoxDecoration(
                color: on ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: on ? _blue : _g5, width: 1.5),
              ),
              child: on
                  ? const Icon(Icons.check_rounded,
                      size: 12.0, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.name,
                      style:
                          _t(10.5, color: _inkTitle, weight: FontWeight.w600)),
                  Text(it.detail, style: _t(9.5, color: _ink3)),
                ],
              ),
            ),
            const SizedBox(width: 6.0),
            _orderStatus(it.status, it.time),
          ],
        ),
      ),
    );
  }

  Widget _orderStatus(_OrderStatus s, String time) {
    final (label, color) = switch (s) {
      _OrderStatus.pending => ('ยังไม่รับ', _g4),
      _OrderStatus.accepted => ('รับแล้ว', _blue),
      _OrderStatus.working => ('กำลังทำ', _amberHue),
      _OrderStatus.done => ('ทำแล้ว', _greenHue),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(label,
              style: _t(9.0, color: color, weight: FontWeight.w700)),
        ),
        if (time.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(_clock(time), style: _num(8.5, color: _ink3)),
          ),
      ],
    );
  }

  /// คอลัมน์ขวา: งานที่ต้องติดตาม (พยาบาลรอรับ / แพทย์ตรวจซ้ำ)
  Widget _orderRight() {
    final tasks = _followTab == 0
        ? _followTasks.where((t) => !t.doctor).toList()
        : _followTasks.where((t) => t.doctor).toList();
    final nNurse = _followTasks.where((t) => !t.doctor).length;
    final nDoc = _followTasks.where((t) => t.doctor).length;
    return SizedBox(
      width: 330.0,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist_rounded,
                        size: 15.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Text('งานที่ต้องติดตาม',
                        style: _t(13.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8.0),
                _segmented(
                  ['พยาบาลรอรับ $nNurse', 'แพทย์ตรวจซ้ำ $nDoc'],
                  _followTab,
                  (i) => setState(() => _followTab = i),
                ),
              ],
            ),
          ),
          for (final t in tasks) _followCard(t),
        ],
      ),
    );
  }

  Widget _followCard(_Task t) => Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.fromLTRB(10.0, 9.0, 10.0, 9.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border:
              Border.all(color: t.urgent ? _red.withValues(alpha: 0.5) : _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(t.icon, size: 15.0, color: t.color),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: _t(11.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                      Text('สั่งเมื่อ ${_clock(t.time)} · ${t.detail}',
                          style: _t(9.5, color: _ink3)),
                    ],
                  ),
                ),
                if (t.urgent) _countBadge('ด่วน', _red),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 13.0, color: t.urgent ? _red : _ink3),
                const SizedBox(width: 4.0),
                Text('รอมาแล้ว ${_hm(t.waitMin)}',
                    style: _num(10.0,
                        color: t.urgent ? _red : _ink2,
                        weight: FontWeight.w600)),
                const Spacer(),
                Material(
                  color: t.doctor ? _panelSoft : _blue,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Text(t.doctor ? 'เปิดตรวจซ้ำ' : 'รับงาน',
                          style: _t(10.0,
                              color: t.doctor ? _blue : Colors.white,
                              weight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ---------------------------------------------- โหมดพูดเพื่อบันทึก
  // ตามแบบ 186:68 — แถบโค้งครึ่งวงกลมด้านล่าง ไมค์ใหญ่ตรงกลาง
  // ขั้นตอนเรียงเป็นวงกลมบนแถบโค้ง (แบบอ้างอิง: มาตรวัดที่ติ๊กขั้นที่ผ่านแล้ว)
  // เขียวมีเครื่องหมายถูก = ทำแล้ว · ขอบน้ำเงิน = ขั้นปัจจุบัน · ขาว = ยังไม่ถึง

  /// HN ของคนไข้ที่ข้อมูลการพูดปัจจุบันเป็นของ
  String? _speechHn;

  void _openSpeech({int step = 0}) {
    if (_speechHn != _caseP().hn) {
      _resetSpeechCase();
      _speechHn = _caseP().hn;
    }
    setState(() {
      _speechOpen = true;
      _speechStep = step;
      _fabOpen = false;
      _summaryOpen = false;
    });
    _agentGreet();
  }

  /// กันเริ่ม/หยุดซ้อนกัน (ปุ่มไมค์ + เปิดฟังเองหลังผู้ช่วยพูด + ตรวจจับเงียบ)
  bool _recBusy = false;

  /// หยุดอัด: send = ส่งไปถอดเสียง · false = ทิ้งคลิป (เปลี่ยนขั้น/ปิดโหมดพูด)
  /// ปุ่มเปลี่ยนสถานะทันที ไม่รอเครื่องอัดปิดเสร็จ
  Future<void> _stopRecord({bool send = true}) async {
    if (!_recording) return;
    _recTimer?.cancel();
    if (mounted) setState(() => _recording = false);
    String? path;
    try {
      path = await _rec.stop();
    } catch (_) {}
    if (!mounted) return;
    if (send && path != null) {
      _processClip(path);
    } else {
      _robot.setMood(ErAuraMood.idle);
    }
  }

  /// นิ้วยังกดปุ่มไมค์อยู่ (กดค้างเพื่อพูด)
  bool _holding = false;
  DateTime _holdAt = DateTime(0);

  void _holdDown() {
    if (_agentBusy) return;
    HapticFeedback.mediumImpact();
    _robot.stop();
    _holding = true;
    _holdAt = DateTime.now();
    _startRecord();
  }

  /// ปล่อยนิ้ว: สั้นกว่า 0.4 วิ หรือไม่ได้ยินเสียงพูด = ยกเลิก ไม่ส่ง
  void _holdUp() {
    if (!_holding) return;
    _holding = false;
    final short = DateTime.now().difference(_holdAt).inMilliseconds < 400;
    if (!_recording) return; // ยังเปิดไมค์ไม่ทัน _startRecord จะปิดเอง
    if (short || !_heard) {
      _stopRecord(send: false);
      setState(() => _agentStatus = short
          ? 'กดค้างไว้ขณะพูด แล้วปล่อยเมื่อพูดจบ'
          : 'ไม่ได้ยินเสียงพูด ลองใหม่อีกครั้ง');
    } else {
      _stopRecord();
    }
  }

  /// เริ่มฟังจากไมค์จริง ขณะกดปุ่มค้าง (ปล่อยนิ้ว = ส่ง)
  Future<void> _startRecord() async {
    if (_recBusy || _recording || _agentBusy || !_speechOpen) return;
    _recBusy = true;
    try {
      if (!await _rec.hasPermission()) {
        if (!mounted) return;
        setState(() => _agentStatus = 'ไม่ได้รับสิทธิ์ใช้ไมโครโฟน');
        return;
      }
      // เครื่องอัดค้างจากรอบก่อน (เช่น เปลี่ยนขั้นกลางคัน) ปิดก่อนเริ่มใหม่
      if (await _rec.isRecording()) await _rec.stop();
      _robot.stop();
      _robot.setMood(ErAuraMood.listening);
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/er_clip_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      if (!mounted) return;
      // ปล่อยนิ้วก่อนไมค์พร้อม = ยกเลิก
      if (!_holding) {
        await _rec.stop();
        return;
      }
      setState(() {
        _recording = true;
        _recSec = 0;
        _tick = 0;
        _heard = false;
        _dbFloor = -45.0;
        _agentStatus = '';
      });
    } finally {
      _recBusy = false;
    }
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(milliseconds: 120), (t) async {
      if (!mounted || !_recording) return;
      // ความดังจริงจากไมค์ (dBFS) แปลงเป็น 0..1 ให้คลื่นบนการ์ด
      double amp = 0.15;
      double db = -60.0;
      try {
        final a = await _rec.getAmplitude();
        db = a.current;
        amp = ((db + 50.0) / 50.0).clamp(0.08, 1.0);
      } catch (_) {}
      if (!mounted || !_recording) return;
      // ตรวจจับพูด/เงียบเทียบกับเสียงพื้นหลังของห้อง (ห้อง ER ไม่เคยเงียบจริง)
      // พื้นหลัง = ค่าต่ำที่ค่อย ๆ ขยับขึ้น · พูด = ดังกว่าพื้นหลัง 12 dB
      // ได้ยินเสียงพูดแล้วค่อยส่งตอนปล่อยนิ้ว · กดค้างนานสุด 60 วิ
      _dbFloor = db < _dbFloor ? db : _dbFloor + (db - _dbFloor) * 0.01;
      if (db > _dbFloor + 12.0) {
        _heard = true;
      }
      if (_recSec >= 60) {
        _holding = false;
        _heard ? _stopRecord() : _stopRecord(send: false);
        return;
      }
      setState(() {
        _tick += 1;
        if (_tick % 8 == 0) _recSec += 1;
        _wave = [..._wave.skip(1), amp];
      });
      // กดค้างเพื่อพูด: ปล่อยนิ้วเมื่อไรค่อยส่ง (ไม่ตัดเองตอนเงียบ)
    });
  }

  /// ถอดเสียงคลิปแล้วส่งข้อความให้ผู้ช่วยตีความลงฟอร์ม
  Future<void> _processClip(String path) async {
    final gen = ++_agentGen;
    setState(() {
      _agentBusy = true;
      _agentStatus = 'กำลังถอดเสียง…';
      _agentChoices = null;
    });
    _robot.setMood(ErAuraMood.thinking);
    try {
      final bytes = await File(path).readAsBytes();
      final t0 = DateTime.now();
      final text = await ErAi.transcribe(bytes);
      debugPrint(
          'ErAi ถอดเสียง ${DateTime.now().difference(t0).inMilliseconds} ms '
          '(${bytes.length} ไบต์): "$text"');
      if (!mounted || gen != _agentGen) return;
      if (text.isEmpty) {
        setState(() {
          _agentBusy = false;
          _agentStatus = 'ไม่ได้ยินเสียง ลองพูดอีกครั้ง';
        });
        _robot.setMood(ErAuraMood.idle);
        return;
      }
      setState(() {
        final old = _transcripts[_speechStep];
        _transcripts[_speechStep] = old.isEmpty ? text : '$old $text';
        _logTurn(true, text);
      });
      await _agentTurn(text, gen);
    } catch (e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ถอดเสียงไม่สำเร็จ: ${_shortErr(e)}';
      });
      _robot.setMood(ErAuraMood.idle);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  static String _shortErr(Object e) {
    final t = e.toString();
    return t.length > 60 ? '${t.substring(0, 60)}…' : t;
  }

  /// เตรียมคำทบทวนเคสไว้ก่อน ตอนกดเปิดโหมดพูดจะได้พูดทันทีไม่ต้องรอ LLM+TTS
  void _prefetchReview() {
    // คนไข้คนใหม่: ล้างของคนก่อน (รวมคำทบทวนที่เตรียมไว้) แล้วเตรียมใหม่
    if (_speechHn != _caseP().hn) {
      _resetSpeechCase();
      _speechHn = _caseP().hn;
    }
    if (_reviewJson != null || _reviewJob != null) return;
    _reviewJob = () async {
      try {
        await ErFormKb.load();
        final out = await ErAi.chat([
          {'role': 'system', 'content': _agentSystem(0)},
          {'role': 'user', 'content': _greetPrompt(0)},
        ], fast: true, json: true, maxTokens: 900, temperature: 0.3);
        final data = ErAi.extractJson(out);
        if (data == null) return;
        final reply =
            _brief(_femaleVoice((data['reply'] as String?)?.trim() ?? ''));
        data['reply'] = reply;
        final clips = <Uint8List>[];
        for (final part in _sentences(reply)) {
          clips.add(await ErAi.speak(part));
        }
        if (!mounted) return;
        _reviewJson = data;
        _reviewClips = clips;
        debugPrint('ErAi เตรียมคำทบทวนเคสแล้ว ${clips.length} ประโยค');
      } catch (e) {
        debugPrint('ErAi เตรียมคำทบทวนไม่สำเร็จ: $e');
      } finally {
        _reviewJob = null;
      }
    }();
  }

  String _greetPrompt(int step) {
    final items = _forms[step];
    final missing = [
      for (final (label, _) in items)
        if (!_filled[step].containsKey(label)) label
    ];
    final (_, stepName) = _steps[step];
    return step == 0
        ? 'เริ่มขั้น "$stepName" ช่องที่ยังว่าง: ${missing.join(', ')}. '
            'ระบบมีข้อมูลจากจุดคัดกรองแล้วและแสดงบนจออยู่ ให้ reply สั้นมาก '
            'ไม่เกิน 15 คำ: อาการสำคัญ 1 วลี + แพ้ยาถ้ามี แล้วถาม "ถูกไหมคะ" '
            'ห้ามอ่านสัญญาณชีพหรือแล็บ ห้ามเกริ่น '
            'และเติมช่องที่ตอบได้จากข้อมูลนั้นลง fields เลย '
            'ช่องที่ไม่มีข้อมูลให้เว้น ใส่ choices ["ถูกต้อง","ขอแก้ไข"] ตอบเป็น JSON'
        : 'เริ่มขั้น "$stepName" ช่องที่ยังว่าง: ${missing.join(', ')}. '
            'reply ไม่เกิน 10 คำ บอกแค่ให้พูดอะไรก่อน ห้ามเกริ่นหรือทักทาย '
            '(เช่น "บอกอาการปัจจุบันได้เลยค่ะ") '
            'fields ให้ว่าง ถ้าช่องแรกที่ถามมีคำตอบเป็นตัวเลือกจำกัด '
            'ให้ใส่ choices ด้วย ตอบเป็น JSON';
  }

  /// เก็บบล็อก UI จากคำตอบผู้ช่วย (เรียกใน setState)
  void _takeUi(Map<String, dynamic> data, int step) {
    final ui = erParseUi(data['ui']);
    if (ui.isEmpty) return;
    _agentUi = ui;
    _agentUiStep = step;
    _agentUiGen++;
    _uiIdx = 0;
    _formAt = 0;
  }

  /// รับ JSON ทักทาย: เติมช่อง ตั้งตัวเลือก คืนข้อความที่จะพูด
  String _applyGreet(Map<String, dynamic> data) {
    final fields = (data['fields'] as Map<String, dynamic>?) ?? const {};
    setState(() {
      _useHpiTemplate(data, _speechStep);
      _usePeTemplate(data, _speechStep);
      for (final label in _acceptLabels(_speechStep)) {
        final v = fields[label];
        if (v is String && v.trim().isNotEmpty) {
          _filled[_speechStep][label] = v.trim();
        }
      }
      _agentChoices = _parseChoices(data);
      _takeUi(data, _speechStep);
    });
    final (_, stepName) = _steps[_speechStep];
    final reply = _femaleVoice((data['reply'] as String?)?.trim() ?? '');
    return reply.isEmpty
        ? 'สวัสดีค่ะคุณหมอ เริ่มขั้น$stepNameได้เลยค่ะ'
        : reply;
  }

  /// หุ่นทักทายเมื่อเปิดโหมดพูดหรือขึ้นขั้นใหม่ บอกว่ายังขาดช่องไหน
  Future<void> _agentGreet() async {
    final gen = ++_agentGen;
    // ขั้นทบทวนเคส: ถ้าเตรียมไว้แล้วพูดได้ทันที
    if (_speechStep == 0 && _filled[0].isEmpty) {
      if (_reviewJson == null && _reviewJob != null) {
        setState(() {
          _agentBusy = true;
          _agentStatus = 'กำลังเตรียมผู้ช่วย…';
        });
        _robot.setMood(ErAuraMood.thinking);
        await _reviewJob;
        if (!mounted || gen != _agentGen) return;
      }
      final json = _reviewJson;
      final clips = _reviewClips;
      if (json != null && clips != null) {
        final text = _applyGreet(json);
        setState(() {
          _logTurn(false, text);
          _agentSay = text;
          _agentStatus = '';
          _agentBusy = false;
        });
        _robot.onSpeechEnd = () {
          if (!mounted) return;
          _robot.setMood(ErAuraMood.idle);
        };
        if (_silent) {
          HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 1400));
          if (!mounted || gen != _agentGen) return;
          _robot.onSpeechEnd?.call();
          return;
        }
        for (final c in clips) {
          await _robot.speak(c);
        }
        _robot.flush();
        return;
      }
    }
    setState(() {
      _agentBusy = true;
      _agentStatus = 'กำลังเตรียมผู้ช่วย…';
    });
    _robot.setMood(ErAuraMood.thinking);
    try {
      final out = await ErAi.chat([
        {'role': 'system', 'content': _agentSystem(_speechStep)},
        ..._historyMessages(max: 8),
        {'role': 'user', 'content': _greetPrompt(_speechStep)},
      ], fast: true, json: true, maxTokens: 800, temperature: 0.4);
      if (!mounted || gen != _agentGen) return;
      final data = ErAi.extractJson(out) ?? const {};
      final text = _applyGreet(data);
      await _agentSpeak(text, gen);
    } catch (e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ผู้ช่วยไม่ตอบ: ${_shortErr(e)}';
      });
      _robot.setMood(ErAuraMood.idle);
    }
  }

  /// รอบสนทนา: ข้อความที่หมอพูด → LLM แยกลงช่องฟอร์ม + ประโยคตอบกลับ → TTS
  Future<void> _agentTurn(String userText, int gen) async {
    setState(() => _agentStatus = 'กำลังตีความ…');
    final step = _speechStep;
    final known = _filled[step];
    final t0 = DateTime.now();
    // ส่งบทสนทนาก่อนหน้าไปด้วย ผู้ช่วยจะได้จำสิ่งที่คุยกันแล้ว ไม่ถามซ้ำ
    final history = _historyMessages();
    if (history.isNotEmpty && !history.last['content']!.contains(userText)) {
      history.removeLast();
    }
    if (history.isNotEmpty) history.removeLast();
    final out = await ErAi.chat([
      {'role': 'system', 'content': _agentSystem(step)},
      ...history,
      {
        'role': 'user',
        'content': 'ค่าที่บันทึกไว้แล้ว: ${jsonEncode(known)}\n'
            'พูดว่า: "$userText"\n'
            'ตอบเป็น JSON ตามรูปแบบที่กำหนด',
      },
    ], json: true, fast: true, maxTokens: 900);
    debugPrint('ErAi LLM ${DateTime.now().difference(t0).inMilliseconds} ms');
    if (!mounted || gen != _agentGen) return;
    final data = ErAi.extractJson(out) ?? const {};
    final intent = (data['intent'] as String?) ?? 'fill';
    final reply = (data['reply'] as String?)?.trim() ?? '';

    // คำสั่งควบคุม: ข้าม / ย้อน / ยกเลิกล่าสุด / อ่านทวน — ไม่ลงฟอร์ม
    if (intent == 'command') {
      final cmd = (data['command'] as String?) ?? '';
      switch (cmd) {
        case 'skip':
        case 'next':
          _agentGen++;
          _confirmStep();
          return;
        case 'back':
          if (_speechStep > 0) {
            _agentGen++;
            setState(() => _speechStep -= 1);
            _agentGreet();
            return;
          }
        case 'undo':
          setState(() {
            for (final (st, label, prev) in _lastFilled) {
              if (prev == null) {
                _filled[st].remove(label);
              } else {
                _filled[st][label] = prev;
              }
            }
            _lastFilled = const [];
          });
          await _agentSpeak('ยกเลิกรายการล่าสุดแล้วค่ะ', gen);
          return;
        case 'read':
          final k = _filled[step];
          final text = k.isEmpty
              ? 'ขั้นนี้ยังไม่มีข้อมูลค่ะ'
              : [for (final e in k.entries) '${e.key} ${e.value}'].join(', ');
          await _agentSpeak('ที่บันทึกไว้คือ $text', gen);
          return;
      }
    }

    // คำถามกลับ ("Cr เท่าไร" "แพ้อะไร"): ตอบจากข้อมูลเคส ไม่ลงฟอร์ม
    if (intent == 'question') {
      setState(() {
        _agentChoices = null;
        _takeUi(data, step);
      });
      await _agentSpeak(
          reply.isEmpty ? 'ไม่พบข้อมูลนั้นในระบบค่ะ' : reply, gen);
      return;
    }

    final fields = (data['fields'] as Map<String, dynamic>?) ?? const {};
    final changed = <(int, String, String?)>[];
    setState(() {
      _useHpiTemplate(data, step);
      _usePeTemplate(data, step);
      for (final label in _acceptLabels(step)) {
        final v = fields[label];
        if (v is String && v.trim().isNotEmpty) {
          changed.add((step, label, known[label]));
          known[label] = v.trim();
        }
      }
      if (changed.isNotEmpty) _lastFilled = changed;
      if (step == _speechStep) _autoIcd9();
      _agentChoices = _parseChoices(data);
      _takeUi(data, step);
      // เตือนยาที่ชนกับประวัติแพ้ทันที (เช็คจากข้อความที่ลงในช่องยา)
      _allergyWarn = _allergyConflict();
    });
    var say = reply.isEmpty ? 'รับทราบค่ะ มีอะไรเพิ่มอีกไหมคะ' : reply;
    if (_allergyWarn != null && !say.contains('แพ้')) {
      say = 'ระวังค่ะ ${_allergyWarn!} $say';
    }
    await _agentSpeak(say, gen);
  }

  /// ยาที่ลงช่องคำสั่ง/ยา ตรงกับประวัติแพ้ของผู้ป่วยหรือไม่ (เทียบชื่อแบบหยาบ)
  String? _allergyWarn;
  String? _allergyConflict() {
    final meds = [
      for (final m in _filled)
        for (final e in m.entries)
          if (e.key.contains('ยา') || e.key.contains('การรักษา')) e.value
    ].join(' ').toLowerCase();
    if (meds.isEmpty) return null;
    const alias = {
      'penicillin': [
        'penicillin',
        'amoxicillin',
        'ampicillin',
        'เพนิซิลลิน',
        'อะม็อกซี',
        'pip/tazo',
        'piperacillin',
        'augmentin'
      ],
      'sulfa': ['sulfa', 'co-trimoxazole', 'bactrim', 'ซัลฟา'],
      'nsaids': [
        'nsaid',
        'ibuprofen',
        'ketorolac',
        'diclofenac',
        'naproxen',
        'ไอบูโพรเฟน'
      ],
    };
    for (final a in _case.allergies) {
      final key = a.toLowerCase();
      final hits = alias.entries
          .where((e) => key.contains(e.key) || e.value.any(key.contains))
          .expand((e) => e.value)
          .toList()
        ..add(key);
      final hit = hits.firstWhere(meds.contains, orElse: () => '');
      if (hit.isNotEmpty) return 'ผู้ป่วยแพ้ $a แต่มีการสั่ง $hit';
    }
    return null;
  }

  /// อ่าน choices จากคำตอบผู้ช่วย ต้องเป็นช่องที่มีในฟอร์มขั้นนี้และมี 2 ตัวเลือกขึ้นไป
  (String, List<String>)? _parseChoices(Map<String, dynamic> data) {
    final c = data['choices'];
    if (c is! Map) return null;
    final field = c['field'];
    final opts = c['options'];
    if (field is! String || opts is! List) return null;
    final labels = [for (final (l, _) in _forms[_speechStep]) l];
    // field ว่าง = ปุ่มยืนยัน/โต้ตอบทั่วไป ไม่ผูกกับช่องใด
    if (field.isNotEmpty && !labels.contains(field)) return null;
    final list = [
      for (final o in opts)
        if (o is String && o.trim().isNotEmpty) o.trim()
    ].take(6).toList();
    return list.length < 2 ? null : (field, list);
  }

  /// หมอกดตัวเลือกที่ผู้ช่วยสร้างให้ → ลงช่องทันที แล้วให้ผู้ช่วยถามข้อถัดไป
  void _pickChoice(String field, String option) {
    if (_agentBusy || _recording) return;
    _robot.stop();
    setState(() {
      if (field.isNotEmpty) _filled[_speechStep][field] = option;
      _agentChoices = null;
      _logTurn(true, field.isEmpty ? option : '$field: $option');
      _agentBusy = true;
      _agentStatus = field.isEmpty ? 'เลือก "$option"' : 'บันทึก $field แล้ว';
    });
    _robot.setMood(ErAuraMood.thinking);
    final gen = ++_agentGen;
    _agentTurn(
            field.isEmpty
                ? '(กดเลือก) $option'
                : '(กดเลือกจากตัวเลือก) $field = $option',
            gen)
        .catchError((e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ผู้ช่วยไม่ตอบ: ${_shortErr(e)}';
      });
      _robot.setMood(ErAuraMood.idle);
    });
  }

  /// กันหลุด: แปลงคำลงท้ายผู้ชายเป็นผู้หญิง ก่อนแสดงและอ่านออกเสียง
  static String _femaleVoice(String t) => t
      .replaceAll(RegExp(r'นะครับ'), 'นะคะ')
      .replaceAll(RegExp(r'ไหมครับ|มั้ยครับ'), 'ไหมคะ')
      .replaceAll(RegExp(r'หรือครับ|เหรอครับ'), 'หรือคะ')
      .replaceAll(RegExp(r'อะไรครับ'), 'อะไรคะ')
      .replaceAll(RegExp(r'ครับ'), 'ค่ะ')
      .replaceAll(RegExp(r'(^|\s)ผม(\s|$)'), r'$1น้องช่วย$2');

  /// ให้หุ่นพูดข้อความนี้: แยกเป็นประโยค สังเคราะห์ทีละประโยคแล้วส่งเข้าคิว
  /// ประโยคแรกสั้น ๆ มาถึงใน ~1 วิ หุ่นเริ่มพูดทันที ระหว่างนั้นประโยคถัดไปค่อยตามมา
  Future<void> _agentSpeak(String raw, int gen) async {
    final text = _brief(_femaleVoice(raw));
    setState(() {
      _logTurn(false, text);
      _agentSay = text;
      _agentStatus = '';
      _agentBusy = false;
    });
    _robot.onSpeechEnd = () {
      if (!mounted) return;
      _robot.setMood(ErAuraMood.idle);
      // กดค้างเพื่อพูด: ไม่เปิดไมค์เอง กันเสียงรอบห้องเข้าระบบ
    };
    if (_silent) {
      // โหมดเงียบ: สั่นเตือน แสดงข้อความ แล้วเปิดไมค์หลังให้เวลาอ่านสั้น ๆ
      HapticFeedback.mediumImpact();
      _robot.setMood(ErAuraMood.talking);
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted || gen != _agentGen) return;
      _robot.onSpeechEnd?.call();
      return;
    }
    final t0 = DateTime.now();
    var first = true;
    for (final part in _sentences(text)) {
      try {
        final mp3 = await ErAi.speak(part);
        if (!mounted || gen != _agentGen) return;
        if (first) {
          debugPrint(
              'ErAi TTS ประโยคแรก ${DateTime.now().difference(t0).inMilliseconds} ms');
          first = false;
        }
        await _robot.speak(mp3);
      } catch (e) {
        debugPrint('ErAi TTS ล้มเหลว: $e');
        if (!mounted || gen != _agentGen) return;
        setState(() => _agentStatus = 'เสียงไม่มา แต่อ่านคำตอบได้จากการ์ด');
      }
    }
    if (!mounted || gen != _agentGen) return;
    _robot.flush();
  }

  /// กันผู้ช่วยพูดยาว: เก็บแค่ 2 ประโยคแรก (ข้อมูลอื่นอยู่บนจอแล้ว)
  static String _brief(String text) {
    final parts = _sentences(text);
    return parts.length <= 2 ? text : parts.take(2).join(' ');
  }

  /// แบ่งข้อความไทยเป็นประโยคสั้น ๆ ตามคำลงท้าย/เครื่องหมาย รวมท่อนสั้นเกินเข้าด้วยกัน
  static List<String> _sentences(String text) {
    final raw = text
        .replaceAllMapped(RegExp(r'(ค่ะ|คะ|ครับ|นะคะ|นะครับ|[.!?])\s+'),
            (m) => '${m.group(1)}\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final out = <String>[];
    for (final r in raw) {
      if (out.isNotEmpty && out.last.length < 18) {
        out[out.length - 1] = '${out.last} $r';
      } else {
        out.add(r);
      }
    }
    return out.isEmpty ? [text] : out;
  }

  /// ชื่อประเภทผู้ป่วยตามตัวเลือกจริงในหน้าคัดกรองของ HOSxP
  static String _kbType(_Ptype? t) => switch (t) {
        _Ptype.trauma => 'ผู้ป่วยอุบัติเหตุ (Trauma)',
        _Ptype.sepsis => 'ผู้ป่วย Sepsis',
        _Ptype.stroke => 'ผู้ป่วย Stroke',
        _Ptype.stemi => 'ผู้ป่วย STEMI',
        _ => 'ผู้ป่วยฉุกเฉิน',
      };

  /// ข้อมูลเคสปัจจุบันจากจุดคัดกรอง/แฟ้ม (จำลอง) ให้ผู้ช่วยทบทวนได้โดยไม่ต้องถามซ้ำ
  /// ยังไม่ส่งชื่อ-HN ออกไป ส่งเฉพาะข้อมูลทางคลินิก
  /// ผู้ป่วยที่กำลังดูอยู่ (หน้ารายละเอียด) หรือคนแรกของช่วงงาน
  _P _caseP() => _sceneSelected(_open ?? _Phase.treatment);

  /// เคสจำลองของผู้ป่วยที่กำลังดู
  ErCase get _case => erCaseOf(_caseP().hn);

  static Color _levelColor(ErLevel l) => switch (l) {
        ErLevel.critical => _redHue,
        ErLevel.urgent => _amberHue,
        ErLevel.normal => _greenHue,
      };

  static (String, double, double, double) _labTuple(ErLab l) =>
      (l.name, l.value, l.lo, l.hi);

  /// แปลงสัญญาณชีพของเคสเป็นการ์ดกราฟ สีแดงเมื่อค่าล่าสุดผิดปกติ
  List<ErVital> _caseVitals() => _vitalsFor(_case);

  static List<ErVital> _vitalsFor(ErCase c) {
    Color tone(double v, double lo, double hi) =>
        (v < lo || v > hi) ? _red : _ink;
    return [
      ErVital(
          icon: Icons.favorite_rounded,
          label: 'HR',
          unit: 'bpm',
          series: c.hr,
          color: tone(c.hr.last, 60, 100)),
      ErVital(
          icon: Icons.monitor_heart_rounded,
          label: 'BP',
          unit: 'mmHg',
          series: c.sbp,
          color: tone(c.sbp.last, 90, 140),
          display: c.bp),
      ErVital(
          icon: Icons.bubble_chart_rounded,
          label: 'SpO₂',
          unit: '%',
          series: c.spo2,
          color: tone(c.spo2.last, 94, 100)),
      ErVital(
          icon: Icons.air_rounded,
          label: 'RR',
          unit: '/min',
          series: c.rr,
          color: tone(c.rr.last, 12, 20)),
      ErVital(
          icon: Icons.thermostat_rounded,
          label: 'BT',
          unit: '°C',
          series: c.bt,
          color: tone(c.bt.last, 36.0, 37.5)),
    ];
  }

  String _caseContext() {
    final p = _caseP();
    final c = _case;
    final esi = p.esi == null
        ? 'ยังไม่คัดกรอง'
        : 'ESI ${p.esi!.level} (${p.esi!.label})';
    String list(List<String> l) => l.isEmpty ? 'ไม่มี' : l.join(', ');
    return [
      'ผู้ป่วย${c.sex} อายุ ${c.age} ปี เตียง ${p.bed ?? 'ยังไม่มีเตียง'} ขั้นงาน: ${p.stage.label} '
          'ระดับ $esi ประเภทผู้ป่วย: ${_kbType(p.type)} สถานะ: ${p.note}',
      'ประเภทการมา: ${c.arrival} สภาพผู้ป่วย: ${c.condition} สิทธิ: ${c.right}',
      'อาการสำคัญจากจุดคัดกรอง: ${c.cc}',
      if (c.hpi.isNotEmpty) 'HPI: ${c.hpi}',
      if (c.painScore != null) 'ระดับความเจ็บปวด: ${c.painScore}/10',
      if (c.gcs != null)
        'GCS: ${c.gcs} (รวม ${c.gcsScore}) ความรู้สึกตัว: ${c.consciousness}',
      'ปัญหา/วินิจฉัยที่บันทึกแล้ว: ${list([
            for (final d in c.dx)
              d.icd10 == null ? d.text : '${d.text} (${d.icd10})'
          ])}',
      'ประวัติแพ้: ${list(c.allergies)}',
      'โรคประจำตัว: ${list(c.underlying)}',
      'ยาที่ให้แล้ว: ${list([
            for (final m in c.meds) '${m.name} (${m.route} ${m.time})'
          ])}',
      'แล็บ: ${list([
            for (final l in c.labs)
              '${l.name} ${l.value}${l.abnormal ? ' ผิดปกติ' : ''}'
          ])}',
      'ภาพถ่าย: ${list([for (final i in c.imaging) '${i.name}: ${i.result}'])}',
      'สัญญาณชีพล่าสุด (${c.times.last}): HR ${c.hr.last.round()} BP ${c.bp} SpO2 ${c.spo2.last.round()}% '
          'RR ${c.rr.last.round()} BT ${c.bt.last}',
      if (c.lastNote != null)
        'บันทึกพยาบาลล่าสุด ${c.lastNote!.time} ${c.lastNote!.by}: ${c.lastNote!.text}',
      'ขั้นถัดไปที่วางแผนไว้: ${c.nextStep} ${c.nextDetail}',
      if (c.disposition.isNotEmpty)
        'สภาพผู้ป่วยออกจากห้อง ER ที่สั่งแล้ว: ${c.disposition}',
    ].join('\n');
  }

  /// ส่วนของฟอร์ม HOSxP ที่เกี่ยวกับขั้นนี้ (จาก er_form_kb.json)
  String _kbForStep(int step) {
    final kb = ErFormKb.maybe;
    if (kb == null) return '(ยังโหลดฐานความรู้ไม่เสร็จ)';
    final p = _caseP();
    final template = switch (p.type) {
      _Ptype.trauma => 'template_trauma',
      _Ptype.sepsis => 'template_sepsis',
      _Ptype.stroke => 'template_stroke',
      _Ptype.stemi => 'template_stemi',
      _ => 'template_general_emergency',
    };
    if (ErSession.instance.isTriage) {
      return switch (step) {
        0 => kb.describe('patient_screening', sections: const [
            'ข้อมูลรับเข้า',
            'ข้อมูลการมา',
            'ประเภทผู้ป่วย',
          ]),
        1 => kb.describe('patient_screening',
            sections: const ['อาการสำคัญ', 'ระดับความเจ็บปวด']),
        2 => kb.describe('patient_screening', sections: const ['Vital Sign']),
        3 => kb.describe('patient_screening', sections: const [
            'การประเมินระดับความรู้สึกตัว (GCS)',
            'รูม่านตา (Pupils)',
          ]),
        4 => kb.describe('accident') + kb.describe('add_accident_basic_care'),
        _ => kb.describe('patient_screening',
            sections: const ['ระดับความเร่งด่วน (ESI)']),
      };
    }
    if (ErSession.instance.isNurse) {
      return switch (step) {
        0 => kb.describe('add_vitalsignmonitor'),
        1 => kb.describe('add_accident_vital_signs'),
        2 => kb.describe('nursing_activities'),
        3 => kb.describe('observe'),
        4 => kb.describe('add_nursing_diagnosis'),
        _ => kb.describe('e_r_admission_edit'),
      };
    }
    return switch (step) {
      // แพทย์ทบทวนข้อมูลที่จุดคัดกรองบันทึกไว้ (ยืนยัน ไม่กรอกแทน)
      0 => kb.describe('patient_screening', sections: const [
          'ประเภทผู้ป่วย',
          'อาการสำคัญ',
          'ระดับความเร่งด่วน (ESI)',
          'การประเมินระดับความรู้สึกตัว (GCS)',
          'ระดับความเจ็บปวด',
        ]),
      1 => kb.describe('physical_examination',
          sections: const ['HPI', 'ข้อมูลการซักประวัติและการตรวจรักษา']),
      2 => kb.describe('physical_examination',
          sections: const ['ตรวจร่างกาย', 'Review of System']),
      3 => kb.describe('treatment'),
      4 => kb.describe('diagnosis') +
          kb.describe('add_doctorsorders') +
          kb.describe(template) +
          kb.describe('add_medicatin_order',
              sections: const ['Medication', 'ฉลากช่วย']) +
          kb.describe('treatment'),
      _ => kb.describe('e_r_admission_edit') +
          kb.describe('add_admit') +
          kb.describe('add_refer'),
    };
  }

  /// ฐานความรู้ของผู้ช่วย: ฟอร์มที่ต้องกรอกในขั้นนี้และกติกาการตอบ
  String _agentSystem(int step) {
    final (_, stepName) = _steps[step];
    final form = [
      for (final (label, hint) in _forms[step])
        '- "$label"${hint.isEmpty ? '' : ' (ตัวอย่าง: $hint)'}',
      for (final l in _detailLabels(step))
        '- "$l" (ข้อความอิสระ ยาวได้หลายประโยค ใส่รายละเอียดผลตรวจตามที่แพทย์พูดครบถ้วน ไม่ย่อ)',
      if (_isHpiStep(step)) _hpiTemplatePrompt(),
      if (_isPeStep(step)) _peTemplatePrompt(),
      if (_forms[step].any((f) => f.$1 == _icd9Label)) _icd9Prompt(),
    ].join('\n');
    final outline = [
      for (var i = 0; i < _steps.length; i++) '${i + 1}. ${_steps[i].$2}'
    ].join(' → ');
    return '''
คุณคือ "น้องช่วย" ผู้ช่วยห้องฉุกเฉิน เป็นผู้หญิง กำลังคุยกับ${ErSession.instance.isNurse ? '${ErSession.instance.isTriage ? 'พยาบาลจุดคัดกรอง' : 'พยาบาลห้องฉุกเฉิน'} เรียกว่า "คุณพยาบาล"' : 'แพทย์ เรียกว่า "คุณหมอ"'} เพื่อเก็บข้อมูลลงเวชระเบียนผ่านเสียง
ใช้ภาษาผู้หญิงสุภาพเสมอ: ลงท้ายประโยคบอกเล่าด้วย "ค่ะ" ประโยคคำถามด้วย "คะ" เรียกตัวเองว่า "น้องช่วย"
ห้ามใช้ "ครับ" หรือ "ผม" เด็ดขาด
ขั้นตอนทั้งหมด: $outline
ตอนนี้อยู่ขั้น "$stepName" ฟอร์มขั้นนี้มีช่องดังนี้ (ชื่อช่องต้องใช้ตรงตามนี้เป๊ะ):
$form

ข้อมูลเคสปัจจุบันที่มีอยู่แล้วในระบบ (จากจุดคัดกรองและแฟ้ม):
${_caseContext()}

ฟอร์มจริงใน HOSxP Plus ที่ขั้นนี้ต้องบันทึก (ชื่อช่อง ประเภท และตัวเลือกที่ระบบมีจริง):
${_kbForStep(step)}

แนวทางขั้นนี้: ${_asks[step]}

หน้าที่:
1. ผู้ใช้มักพูดเป็น narrative ก้อนเดียวปนอังกฤษ (เช่น "หญิงห้าสิบสี่ ซ้อนมอไซค์ล้ม ใส่หมวก LOC ไม่มี อาเจียนสองครั้ง ปวดหัวเจ็ดเต็มสิบ underlying HT")
   ต้องแตกทุกข้อมูลในประโยคลง "หลายช่อง" พร้อมกันในรอบเดียว ห้ามแต่งข้อมูลที่ไม่ได้พูด
2. ถ้าบอกว่าปกติ/ไม่มี ให้บันทึกได้ เช่น "ปกติ" "ไม่มี" "ไม่แพ้ยา"
   ถ้าพูดว่า "ที่เหลือปกติหมด" / "อื่น ๆ ปกติ" ให้ใส่ "ปกติ" ทุกช่องที่ยังว่างของขั้นนี้
2.1 ถามกลับเฉพาะช่องที่ "ยังว่างและสำคัญต่อการตัดสินใจ" (เช่น LOC, ยาละลายลิ่มเลือด, GCS, แพ้ยา)
   ช่องเสริมที่ว่างให้ปล่อยได้ ไม่ต้องไล่ถามครบทุกช่อง
2.2 intent: ถ้าผู้ใช้สั่งควบคุม ("ข้าม" "ขั้นต่อไป" "ย้อนกลับ" "ยกเลิกอันล่าสุด" "อ่านที่บันทึกให้ฟัง")
   ให้ตอบ {"intent":"command","command":"skip|next|back|undo|read","reply":"..."} ไม่ต้องมี fields
   ถ้าผู้ใช้ "ถาม" ข้อมูลเคส ("Cr เท่าไร" "แพ้อะไรบ้าง" "ให้ยาอะไรไปแล้ว" "รอ CT นานแค่ไหน")
   ให้ตอบจากข้อมูลเคสด้านบนใน reply สั้น ๆ พร้อม {"intent":"question"} ไม่ลงฟอร์ม
   กรณีอื่นใช้ {"intent":"fill"}
3. ตอบสั้นแบบวิทยุสื่อสารในห้องฉุกเฉิน ไม่เกิน 12 คำ ไม่เกิน 2 ประโยค ไม่ทวนสิ่งที่รับได้
   ห้ามเกริ่น ("น้องช่วยพร้อม…" "ได้เลยค่ะ คุณหมอ…") ข้อมูลอยู่บนจอแล้ว ไม่ต้องอ่านซ้ำ
   แค่ "รับทราบ" แล้วถามช่องถัดไป 1 ช่อง ถ้าครบแล้วพูดว่า "ครบแล้ว กดยืนยันได้"
   ประโยคแรกต้องสั้นมาก (ไม่เกิน 6 คำ) เพราะจะถูกอ่านออกเสียงก่อน
4. คำตอบจะถูกอ่านออกเสียงด้วย TTS ภาษาไทย จึงเลี่ยงตัวย่อและอักษรอังกฤษ
   ใช้คำอ่านไทยแทน เช่น หัวใจ ปอด ท้อง ระบบประสาท ไม่ต้องใส่หัวข้อหรืออีโมจิ

รูปแบบ JSON ที่ต้องตอบ (เมื่อถูกขอให้ตอบ JSON):
{"intent": "fill|command|question",
 "command": "<เฉพาะ intent=command>",
 "fields": {"<ชื่อช่อง>": "<ค่าที่ได้>"},
 "reply": "<ประโยคตอบกลับ>",
 "complete": <true|false>,
 "choices": {"field": "<ชื่อช่องที่กำลังถาม>", "options": ["<ตัวเลือก>", ...]},
 "ui": [<บล็อก UI ตามแค็ตตาล็อกด้านล่าง>]}
ใส่เฉพาะช่องที่ได้ข้อมูลใหม่หรือแก้ไขใน fields
choices = ปุ่มให้แพทย์กดเลือกแทนการพูด ใส่เมื่อช่องที่กำลังถามมีคำตอบเป็นชุดจำกัด
ถ้าฟอร์ม HOSxP ด้านบนมีตัวเลือกของช่องนั้นอยู่แล้ว ต้องใช้ข้อความตัวเลือกตรงตามนั้น
และค่าที่ใส่ใน fields ต้องเป็นหนึ่งในตัวเลือกจริง (เช่น GCS ใช้ "E4 ลืมตาได้เอง")
2-6 ตัวเลือกสั้น ๆ เช่น ระดับความรุนแรง → ["ESI 1","ESI 2","ESI 3","ESI 4","ESI 5"],
ผลตรวจ → ["ปกติ","ผิดปกติ"], ประวัติแพ้ยา → ["ไม่แพ้ยา","แพ้ยา (ระบุ)"],
ระยะเวลา → ["ไม่กี่ชั่วโมง","1-2 วัน","3-7 วัน","มากกว่า 1 สัปดาห์"]
ถ้าคำตอบเป็นข้อความอิสระ ให้ละ choices

$erUiCatalogPrompt
เป้าหมาย: พาแพทย์ไปจนจบเคสโดยไม่ต้องสลับหน้าจอ ทุกรอบให้ ui แสดงสิ่งที่ต้องใช้ตัดสินใจตอนนั้น
เช่น ถามค่าแล็บ → labs · ถึงขั้นสั่งการรักษา → order_set จาก template ตามประเภทผู้ป่วย + alert ถ้าแพ้ยา
เคส fast track → timer · เจอค่าวิกฤต → alert · ครบขั้นแล้ว → next_step''';
  }

  void _confirmStep() {
    _uiIdx = 0;
    _formAt = 0;
    _orderPick.clear();
    _uiTicks.clear();
    _stopRecord(send: false);
    _robot.stop();
    setState(() {
      _speechDone.add(_speechStep);
      if (_speechStep < _steps.length - 1) _speechStep += 1;
    });
    _agentGreet();
  }

  void _closeSpeech() {
    _agentGen++;
    _robot.stop();
    _stopRecord(send: false);
    setState(() {
      _speechOpen = false;
      _agentBusy = false;
      _agentStatus = '';
      _agentChoices = null;
    });
  }

  /// aura ตอนยังไม่เปิดโหมดพูด: วางตำแหน่งเดียวกับในแถบ ใช้ GlobalKey เดิม
  /// พอเปิดโหมดพูด widget ย้ายไปอยู่ในแถบโดยไม่สร้าง WebView ใหม่
  /// ขนาดวงล้อ (สัมพันธ์กับความกว้างจอ) ใช้ร่วมกันระหว่างแถบพูดกับ aura ที่เตรียมไว้
  static const double _orbitK = 1.12;

  /// ม่านเบลอครึ่งล่างของจอตอนเปิดโหมดพูด: บนใส ไล่เบลอลงล่าง
  /// อยู่ใต้วงล้อ แผงผู้ช่วย และสารบัญ (ใช้ ShaderMask แนวตั้ง ไม่เจาะรู
  /// เพราะ ClipPath+BackdropFilter บน WebView 3D ทำให้ Impeller วาดหน้าหาย)
  Widget _speechBlur() => Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: IgnorePointer(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0xFF000000), Color(0xFF000000)],
              stops: [0.0, 0.45, 1.0],
            ).createShader(r),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: _bg.withValues(alpha: 0.45)),
            ),
          ),
        ),
      );

  /// ความกว้างมุมขวาล่างที่วงล้อใช้ (แผ่นเบลอ ปุ่มปิด แผงผู้ช่วยวางชิดซ้ายของมัน)
  double _orbitZoneW(double w) {
    final k = w / 1366.0 * 0.5;
    return 64.0 + 332.0 * k * _orbitK + 44.0 * k + 40.0 * k + 40.0;
  }

  static const double _micK = 74.0;

  Widget _auraWarm() => Positioned.fill(
        child: LayoutBuilder(
          builder: (context, c) {
            final k = c.maxWidth / 1366.0 * 0.5;
            final rArc = 332.0 * k * _orbitK;
            final rMic = _micK * k;
            final band = 88.0 * k;
            final h = rArc + band / 2 + 44.0;
            final cx = c.maxWidth - 64.0;
            final cy = c.maxHeight - 22.0;
            final micX = cx - rArc * 0.36;
            final micY = cy - rArc * 0.36;
            return Stack(
              children: [
                Positioned(
                  left: micX - rMic * 2.6,
                  top: micY - rMic * 2.6,
                  width: rMic * 5.2,
                  height: (rMic * 5.2).clamp(0.0, h),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.0,
                      child: ErAiAura(key: _auraKey, controller: _robot),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

  /// แถบลอยด้านล่าง เบลอเฉพาะพื้นที่ของเครื่องมือ ไม่ทับทั้งหน้า
  /// หน้าด้านบนยังอ่านและแตะได้ตามปกติ
  Widget _speechOverlay() => Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: LayoutBuilder(
          builder: (context, c) {
            // สัดส่วนอิงแบบกว้าง 1366 แล้วย่อลงครึ่งหนึ่ง ให้เป็นแถบเตี้ย ๆ
            // การ์ดข้อความย้ายไปอยู่ข้างวงโค้ง ไม่ซ้อนด้านบน แถบจึงไม่สูง
            final k = c.maxWidth / 1366.0 * 0.5;
            // วงล้อกะทัดรัดที่มุมขวาล่าง (คำตอบ/การ์ดย้ายไปกลางล่างแล้ว ไม่ต้องเผื่อด้านบน)
            final rArc = 332.0 * k * _orbitK;
            final rNode = 40.0 * k;
            final rMic = _micK * k;
            final band = 88.0 * k;
            const guideH = 0.0;
            final h = rArc + band / 2 + 58.0;
            // orbit เป็นควอเตอร์อาร์คที่มุมขวาล่าง ศูนย์กลางชิดขอบขวา
            final cx = c.maxWidth - 64.0;
            final cy = h - 22.0;
            const angles = [176.0, 159.0, 142.0, 125.0, 108.0, 91.0];
            // ไมค์อยู่ในอาร์ค เยื้องทแยงจากศูนย์กลาง
            final micX = cx - rArc * 0.36;
            final micY = cy - rArc * 0.36;
            return SizedBox(
              height: h,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ArcTrack(
                            center: Offset(cx, cy),
                            radius: rArc,
                            width: band,
                            color: _g5.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < _steps.length; i++)
                      Positioned(
                        left: cx +
                            rArc * math.cos(angles[i] * math.pi / 180) -
                            rNode,
                        top: cy -
                            rArc * math.sin(angles[i] * math.pi / 180) -
                            rNode,
                        child: _speechNode(i, rNode),
                      ),
                    // aura ของผู้ช่วย AI อยู่รอบปุ่มไมค์ ใต้ปุ่ม เต้นตามเสียงและสถานะ
                    Positioned(
                      left: micX - rMic * 2.6,
                      top: micY - rMic * 2.6,
                      width: rMic * 5.2,
                      height: rMic * 5.2,
                      child: IgnorePointer(
                          child: ErAiAura(key: _auraKey, controller: _robot)),
                    ),
                    // คลื่นเสียงรอบไมค์ ตามความดังจริงจากไมค์ (เฉพาะตอนกำลังฟัง)
                    if (_recording)
                      Positioned(
                        left: micX - rMic - 26.0,
                        top: micY - rMic - 26.0,
                        width: rMic * 2 + 52.0,
                        height: rMic * 2 + 52.0,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _MicWave(
                                levels: _wave, inner: rMic + 4.0, color: _red),
                          ),
                        ),
                      ),
                    // สถานะไมค์ใต้ปุ่ม: ฟังอยู่ / ประมวลผล / ผู้ช่วยพูด / รอแตะ
                    Positioned(
                      left: micX - 70.0,
                      width: 140.0,
                      top: micY + rMic + 8.0,
                      child: IgnorePointer(child: Center(child: _micStatus())),
                    ),
                    Positioned(
                      left: micX - rMic,
                      top: micY - rMic,
                      child: Material(
                        color: _recording ? _red : (_agentBusy ? _g5 : _blue),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        elevation: 8.0,
                        shadowColor: _blue.withValues(alpha: 0.45),
                        child: Listener(
                          onPointerDown: (_) => _holdDown(),
                          onPointerUp: (_) => _holdUp(),
                          onPointerCancel: (_) => _holdUp(),
                          child: SizedBox(
                            width: rMic * 2,
                            height: rMic * 2,
                            child: Icon(
                                _recording
                                    ? Icons.graphic_eq_rounded
                                    : (_agentBusy
                                        ? Icons.more_horiz_rounded
                                        : Icons.mic_rounded),
                                size: 44.0 * k,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: guideH + 6.0,
                      right: 12.0,
                      child: Material(
                        color: _panel,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        elevation: 2.0,
                        child: InkWell(
                          onTap: _closeSpeech,
                          child: const SizedBox(
                            width: 36.0,
                            height: 36.0,
                            child: Icon(Icons.close_rounded,
                                size: 19.0, color: _ink),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  /// ป้ายสถานะไมค์: บอกชัดว่าตอนนี้ไมค์ฟังอยู่ไหม
  Widget _micStatus() {
    final talking = _robot.mood == ErAuraMood.talking;
    final (text, col, live) = _recording
        ? (
            'ปล่อยเพื่อส่ง ${_recSec ~/ 60}:${(_recSec % 60).toString().padLeft(2, '0')}',
            _red,
            true
          )
        : _agentBusy
            ? ('กำลังประมวลผล…', _ink2, false)
            : talking
                ? ('น้องช่วยกำลังพูด', _blue, false)
                : ('กดค้างเพื่อพูด', _ink3, false);
    // ระดับเสียงล่าสุด: ไม่มีเสียงเข้า = จุดจาง ให้รู้ว่าไมค์ยังไม่ได้ยิน
    final lvl = _wave.isEmpty ? 0.0 : _wave.last;
    final heard = live && lvl > 0.25;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: live ? _red.withValues(alpha: 0.4) : _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x140B1B3F), blurRadius: 8.0, offset: Offset(0, 2)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (live) ...[
          // มิเตอร์ 5 แท่งจากค่าความดังล่าสุด
          for (final v in _wave.skip(_wave.length - 5))
            Container(
              width: 2.5,
              height: 3.0 + v * 11.0,
              margin: const EdgeInsets.symmetric(horizontal: 0.8),
              decoration: BoxDecoration(
                color: heard ? _red : _red.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          const SizedBox(width: 5.0),
        ] else
          Container(
            width: 6.0,
            height: 6.0,
            margin: const EdgeInsets.only(right: 5.0),
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
        Text(text, style: _num(10.0, color: col, weight: FontWeight.w700)),
      ]),
    );
  }

  /// หมุดขั้นตอนบนแถบโค้ง
  Widget _speechNode(int i, double r) {
    final done = _speechDone.contains(i);
    final cur = i == _speechStep;
    final (icon, label) = _steps[i];
    return SizedBox(
      width: r * 2,
      height: r * 2 + 30.0,
      child: Column(
        children: [
          Material(
            color: done ? _greenHue : _panel,
            shape: CircleBorder(
              side: BorderSide(
                  color: cur ? _blue : (done ? _greenHue : _line),
                  width: cur ? 3.0 : 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: cur ? 4.0 : 1.0,
            child: InkWell(
              onTap: () {
                if (i == _speechStep) return;
                _robot.stop();
                _stopRecord(send: false);
                setState(() => _speechStep = i);
                _agentGreet();
              },
              child: SizedBox(
                width: r * 2,
                height: r * 2,
                child: Icon(done ? Icons.check_rounded : icon,
                    size: r * 0.9, color: done ? Colors.white : _blue),
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          // มุมขวาล่างพื้นที่น้อย โชว์ชื่อเฉพาะขั้นที่เลือกอยู่ ที่เหลือใช้ไอคอน
          if (cur)
            Text('${i + 1}. $label',
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: _t(8.5, color: _inkTitle, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// การ์ดไกด์ของโหมดพูด: รายการช่องที่ฟอร์มขั้นนี้ต้องการ
  /// ติ๊กให้เมื่อผู้ช่วย AI จับค่าจากคำพูดได้แล้ว พร้อมโชว์ค่าที่ได้
  /// ปุ่มสลับ checklist ↔ การ์ดฟอร์ม
  Widget _guideModeToggle() => Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (form, icon, tip) in const [
            (false, Icons.checklist_rounded, 'Checklist'),
            (true, Icons.dashboard_customize_rounded, 'การ์ดฟอร์ม'),
          ])
            Tooltip(
              message: tip,
              child: InkWell(
                onTap: () => setState(() => _guideForm = form),
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: _guideForm == form ? _panel : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(icon,
                      size: 13.0, color: _guideForm == form ? _blue : _ink3),
                ),
              ),
            ),
        ]),
      );

  /// ตัวเลือกของช่อง: master data (ผูกด้วยชื่อช่อง) → ตัวเลือกในฟอร์ม KB → คำใบ้ "A / B"
  /// ช่องในโหมดพูดที่รวมหลายช่องของฟอร์มจริงไว้ด้วยกัน → ตาราง master ของแต่ละช่องย่อย
  /// (ชื่อช่องในโหมดพูดไม่ตรงกับ used_by ของ master จึงต้องจับคู่ด้วย id ตาราง)
  static const Map<String, List<String>> _fieldTables = {
    'GCS (E / V / M)': ['gcs_eye', 'gcs_verbal', 'gcs_motor'],
    'การลืมตา / ตอบสนองการพูด / การเคลื่อนไหว': [
      'gcs_eye',
      'gcs_verbal',
      'gcs_motor'
    ],
    'ยานพาหนะ / ประเภทผู้บาดเจ็บ': [
      'accident_vehicle_type',
      'accident_person_type'
    ],
    'หมวกนิรภัย / เข็มขัดนิรภัย': [
      'accident_helmet_type',
      'accident_belt_type'
    ],
    'แอลกอฮอล์ / สารเสพติด': ['accident_alcohol_type', 'accident_drug_type'],
    'การดูแลก่อนมาถึง': [
      'accident_airway_type',
      'accident_bleed_type',
      'accident_fluid_type',
      'accident_splint_type',
      'accident_cspine_type',
    ],
    'ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป': ['er_ipd_ward', 'er_refer_hospital'],
    'รับคำสั่ง ยา/เวชภัณฑ์': ['er_order_receive_action'],
    'รับคำสั่ง Lab': ['er_order_receive_action'],
    'รับคำสั่ง X-ray': ['er_order_receive_action'],
    'รับคำสั่ง หัตถการ': ['er_order_receive_action'],
    'ยืนยันแพทย์ผู้บันทึก': ['er_doctor'],
    'หัตถการที่ทำ': ['er_procedure'],
    'รหัสหัตถการ ICD-9-CM': ['er_icd9cm'],
    'ปฏิกิริยารูม่านตา ซ้าย / ขวา': [
      'er_pupil_reaction|ด้านซ้าย (L)',
      'er_pupil_reaction|ด้านขวา (R)'
    ],
    'สถานที่สังเกตอาการ': ['er_observe_place'],
    'ห้อง / เตียง': ['er_room', 'er_bed'],
    'ห้อง / โซนห้องฉุกเฉิน': ['er_room'],
    'ยืนยันพยาบาลผู้บันทึก': ['er_staff'],
  };

  /// กลุ่มตัวเลือกจาก master ของช่องที่รวมหลายช่องย่อย: (ชื่อช่องย่อย, ตัวเลือก)
  List<(String, List<String>)> _fieldGroups(String label) {
    final m = ErMaster.maybe;
    final ids = _fieldTables[label];
    if (m == null || ids == null) return const [];
    return [
      // "id|ชื่อ" = ใช้ตารางเดียวกันซ้ำ (เช่น รูม่านตาซ้าย/ขวา) ด้วยชื่อกลุ่มของตัวเอง
      for (final ref in ids)
        if (m.table(ref.split('|').first) case final t?)
          (
            ref.contains('|') ? ref.split('|').last : t.nameTh,
            [for (final it in t.activeItems) it.name]
          ),
    ];
  }

  List<String> _fieldOptions(String label, String hint) {
    if (hint == '0–10') return [for (var i = 0; i <= 10; i++) '$i'];
    final g = _fieldGroups(label);
    if (g.length == 1) return g.first.$2;
    final m = ErMaster.maybe;
    if (m != null) {
      for (final t in m.tables) {
        if (t.usedBy.any((u) => u.field == label) || t.nameTh == label) {
          return [for (final it in t.activeItems) it.name];
        }
      }
    }
    final kb = ErFormKb.maybe;
    if (kb != null) {
      for (final f in kb.forms) {
        final o = kb.options(f['id'] as String, label);
        if (o.isNotEmpty) return o;
      }
    }
    if (hint.contains(' / ') && !hint.contains('…')) {
      final parts = hint.split(' / ').map((e) => e.trim()).toList();
      if (parts.every((e) => e.length <= 14)) return parts;
    }
    return const [];
  }

  /// หน่วยของช่องตัวเลข (ว่าง = ไม่ใช่ช่องตัวเลข)
  static String _fieldUnit(String hint) =>
      const {'mmHg', '/min', '%', '°C'}.contains(hint) ? hint : '';

  /// การ์ดฟอร์มจริงของขั้นนี้ แต่ละช่องวาดตามชนิด: ชิปตัวเลือก / ช่องตัวเลข / ช่องข้อความ
  /// ค่าที่ผู้ช่วยกรอกจากเสียงไฮไลต์อยู่ในช่องจริง แตะเพื่อเลือก/แก้เองได้
  /// ฟอร์มแบบ flipbook: ทีละช่อง การ์ดหน้าใหญ่ การ์ดถัดไปซ้อนอยู่ด้านหลัง
  /// เลือกตัวเลือกแล้วพลิกไปช่องถัดไปเอง ปัด/กดย้อน-ถัดไปได้
  /// ช่องของบล็อกฟอร์มที่มีจริงในฟอร์มขั้นนี้
  /// ช่องของขั้นที่ต้องกรอก: ขั้นตรวจร่างกายที่เลือก template แล้ว
  /// เหลือเฉพาะระบบในขอบเขตของ template (แพทย์เฉพาะทางไม่ได้ตรวจทุกระบบ)
  List<String> _stepLabels(int st) => [
        for (final (l, _) in _forms[st])
          if (!_isPeStep(st) ||
              _peScope == null ||
              !_peHasDetail(l) ||
              _peScope!.contains(l))
            l
      ];

  /// ช่องนี้ครบหรือยัง: ผลตรวจ "ผิดปกติ" ต้องมีรายละเอียดเสมอ
  bool _fieldDone(int st, String l) {
    final v = _filled[st][l];
    if (v == null) return false;
    return !_needsDetail(st, l);
  }

  bool _needsDetail(int st, String l) =>
      _isPeStep(st) &&
      _filled[st][l] == 'ผิดปกติ' &&
      (_filled[st]['$l - รายละเอียด'] ?? '').trim().isEmpty;

  List<String> _formFields(ErUiBlock b) {
    final have = {..._stepLabels(_speechStep)};
    return [
      for (final f in b.strs('fields'))
        if (have.contains(f)) f
    ];
  }

  /// พลิก flipbook ไป d หน้า (ใช้ทั้งปุ่มบนหัวแผง แถบ stepper และการปัด)
  void _formGo(int d, int n) {
    final at = _formAt.clamp(0, n - 1);
    final to = (at + d).clamp(0, n - 1);
    if (to != at) {
      setState(() {
        _formFwd = d > 0;
        _formAt = to;
      });
    }
  }

  /// สารบัญของฟอร์ม: ทุกช่องพร้อมสถานะ แตะเพื่อพลิกไปช่องนั้น
  Widget _formToc(List<String> fields) {
    final done = _speechDone.contains(_speechStep);
    final n = fields.length;
    final at = _formAt.clamp(0, n - 1);
    final ok = fields.where((f) => _fieldDone(_speechStep, f) || done).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x140B1B3F), blurRadius: 20.0, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 6.0),
            child: Row(children: [
              Expanded(
                child: Text('สารบัญ',
                    style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
              ),
              Text('$ok/$n',
                  style: _num(10.5,
                      color: ok == n ? _greenHue : _ink3,
                      weight: FontWeight.w700)),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(children: [
                for (var i = 0; i < n; i++)
                  _tocRow(i + 1, fields[i],
                      ok: _fieldDone(_speechStep, fields[i]) || done,
                      on: i == at,
                      onTap: () => _formGo(i - at, n)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tocRow(int no, String label,
          {required bool ok, required bool on, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: on ? _blue.withValues(alpha: 0.07) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18.0,
              height: 18.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ok ? _greenHue : (on ? _blue : _panel),
                border: Border.all(
                    color: ok ? _greenHue : (on ? _blue : _line), width: 1.5),
              ),
              child: ok
                  ? const Icon(Icons.check_rounded,
                      size: 12.0, color: Colors.white)
                  : Text('$no',
                      style: _num(9.0,
                          color: on ? Colors.white : _ink3,
                          weight: FontWeight.w700)),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0,
                          color: on ? _blueHue : (ok ? _ink2 : _ink),
                          weight: on ? FontWeight.w700 : FontWeight.w500)),
                  if (_termOf(label) case final sub?)
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(9.0, color: _ink3)),
                ],
              ),
            ),
          ]),
        ),
      );

  /// คำอธิบายใต้ชื่อช่องที่เป็นคำย่อ/ศัพท์เฉพาะ กันผู้ใช้ลืมความหมาย
  static const Map<String, String> _terms = {
    'HPI': 'ประวัติเจ็บป่วยปัจจุบัน',
    'GA': 'ลักษณะทั่วไป',
    'HEENT': 'ศีรษะ ตา หู จมูก คอ',
    'Heart': 'หัวใจ',
    'Chest': 'ทรวงอก ปอด',
    'Chest / Lung': 'ทรวงอก ปอด',
    'Abdomen': 'ช่องท้อง',
    'PR': 'ตรวจทางทวารหนัก',
    'PV': 'ตรวจภายใน',
    'Genitalia': 'อวัยวะเพศ',
    'Neurological': 'ระบบประสาท',
    'Extremities': 'แขนขา',
    'Constitutional': 'อาการทั่วไป',
    'Eyes': 'ตา',
    'ENT/Mouth': 'หู คอ จมูก ปาก',
    'GCS (E / V / M)': 'ระดับความรู้สึกตัว',
    'ระดับความเร่งด่วน (ESI)': 'ระดับ 1–5',
    'Diagnosis ICD-10': 'รหัสโรค',
    'ตำแหน่ง ชนิด ขนาดแผล': 'แตะบนหุ่น 3D เพื่อระบุตำแหน่ง',
    'บันทึกการตรวจแบบละเอียด': 'ผลตรวจเพิ่มเติม ยาวได้หลายประโยค',
    'HEAD/NECK': 'ศีรษะและคอ',
    'FACE': 'ใบหน้า',
    'THORAX': 'ทรวงอก',
    'ABDOMEN/PELVIC CONTENTS': 'ช่องท้องและอวัยวะในอุ้งเชิงกราน',
    'EXTREMITIES/PELVIC GIRDLE': 'แขนขาและกระดูกเชิงกราน',
    'EXTERNAL': 'ผิวหนัง แผลภายนอก',
    'หัตถการที่ทำ': 'บันทึกการทำหัตถการ',
    'รหัสหัตถการ ICD-9-CM': 'รหัสหัตถการ',
  };

  String? _termOf(String label) => _terms[label];

  // ------------------------------------------------ HPI template + ช่องข้อความอิสระ

  /// ส่วนเสริมใต้ช่องกรอกใน flipbook: HPI มีแถบ template · ผลตรวจมีช่องรายละเอียด
  Widget _fieldWithExtras(String label, Widget field) {
    if (label == _icd9Label) {
      final sug = _icd9Suggest();
      if (sug.isEmpty) return field;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [field, const SizedBox(height: 8.0), _icd9Bar(sug)],
      );
    }
    final hpi = _isHpiStep(_speechStep) && label == 'HPI';
    final detail = _isPeStep(_speechStep) && _peHasDetail(label);
    if (!hpi && !detail) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        const SizedBox(height: 8.0),
        hpi ? _hpiTemplateBar() : _detailBox(label),
      ],
    );
  }

  // ------------------------------------------------ template ตรวจร่างกาย
  List<ErPeTemplate> _peTemplates = erPeBuiltIns;

  String get _uid => ErSession.instance.user?.id ?? 'guest';

  Future<void> _loadPeTemplates() async {
    final list = await ErPeTemplates.load(_uid);
    if (mounted) setState(() => _peTemplates = list);
  }

  /// วาง template ลงฟอร์มตรวจร่างกาย (แทนค่าช่องที่ template มี)
  void _applyPeTemplate(ErPeTemplate t, {int? step}) {
    final st = step ?? _speechStep;
    final ok = {..._acceptLabels(st)};
    _lastFilled = [
      for (final e in t.values.entries)
        if (ok.contains(e.key)) (st, e.key, _filled[st][e.key])
    ];
    for (final e in t.values.entries) {
      if (ok.contains(e.key)) _filled[st][e.key] = e.value;
    }
    // ระบบนอก template = แพทย์ท่านนี้ไม่ได้ตรวจ บันทึกเป็น "ไม่ได้ตรวจ" และไม่ต้องกรอก
    final scope = {
      for (final k in t.values.keys)
        if (!k.contains(' - ')) k
    };
    for (final (l, _) in _forms[st]) {
      if (_peHasDetail(l) && !scope.contains(l)) _filled[st][l] = 'ไม่ได้ตรวจ';
    }
    _peScope = scope;
  }

  /// ระบบที่ template ที่เลือกครอบคลุม (null = ไม่ใช้ template ตรวจทุกระบบ)
  Set<String>? _peScope;

  /// ระบบที่ template ตรวจร่างกายเก็บได้ (ตามฟอร์มตรวจร่างกายของแพทย์)
  List<String> get _peTplSystems => [
        for (final (l, _) in _doctorForm[_peStep])
          if (_peHasDetail(l)) l
      ];

  /// หน้าต่างจัดการ template ตรวจร่างกาย (แยกจาก flow บันทึก)
  /// ซ้าย: รายการ template · ขวา: ตัวแก้ไข เลือกระบบที่ตรวจ ผล และรายละเอียด
  Future<void> _openPeTemplates() async {
    final systems = _peTplSystems;
    var sel = _peTemplates.isEmpty ? null : _peTemplates.first;
    var name = TextEditingController(text: sel?.name ?? '');
    var draft = <String, String>{...?sel?.values};
    final notes = <String, TextEditingController>{};
    TextEditingController noteOf(String l) =>
        notes.putIfAbsent(l, () => TextEditingController());
    void load(ErPeTemplate? t) {
      sel = t;
      name = TextEditingController(text: t?.name ?? '');
      draft = {...?t?.values};
      for (final l in systems) {
        noteOf(l).text = draft['$l - รายละเอียด'] ?? '';
      }
    }

    load(sel);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final readOnly = sel?.builtIn ?? false;
        Future<void> save() async {
          final n = name.text.trim();
          if (n.isEmpty) return;
          final values = <String, String>{
            for (final l in systems)
              if (draft[l] != null) l: draft[l]!,
            for (final l in systems)
              if (draft[l] != null && noteOf(l).text.trim().isNotEmpty)
                '$l - รายละเอียด': noteOf(l).text.trim(),
          };
          if (values.isEmpty) return;
          final list = await ErPeTemplates.add(_uid, ErPeTemplate(n, values));
          if (!mounted) return;
          setState(() => _peTemplates = list);
          set(() => load(list.firstWhere((t) => t.name == n)));
        }

        Future<void> remove() async {
          final t = sel;
          if (t == null || t.builtIn) return;
          final list = await ErPeTemplates.remove(_uid, t.name);
          if (!mounted) return;
          setState(() => _peTemplates = list);
          set(() => load(list.isEmpty ? null : list.first));
        }

        // ตั้งต้นจากผลตรวจที่กำลังบันทึก (ถ้ามี) ไม่งั้นจากครั้งล่าสุดในประวัติ
        void fromLatest() {
          final cur = _peStep < _filled.length ? _filled[_peStep] : const {};
          set(() {
            sel = null;
            name = TextEditingController();
            draft = {};
            for (final l in systems) {
              if (cur[l] != null) draft[l] = cur[l]!;
              noteOf(l).text = cur['$l - รายละเอียด'] ?? '';
            }
            if (draft.isEmpty) {
              final last = _peRounds.last;
              for (final sy in _peSystems) {
                final l = _peField[sy.key];
                if (l == null) continue;
                final (f, note) = last.of(sy.key);
                if (f == _Finding.none) continue;
                draft[l] = switch (f) {
                  _Finding.abnormal => 'ผิดปกติ',
                  _Finding.notDone => 'ไม่ได้ตรวจ',
                  _ => 'ปกติ',
                };
                noteOf(l).text = note;
              }
            }
          });
        }

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          clipBehavior: Clip.antiAlias,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // รายการ template
            Container(
              width: 260.0,
              color: _panelSoft,
              padding: const EdgeInsets.fromLTRB(14.0, 18.0, 14.0, 14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Template การตรวจร่างกาย',
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 2.0),
                    Text('ชุดระบบที่ตรวจบ่อย เรียกใช้ตอนบันทึกด้วยเสียง',
                        style: _t(10.0, color: _ink3)),
                    const SizedBox(height: 12.0),
                    _uiButton(
                        'สร้างจากผลตรวจล่าสุด', Icons.add_rounded, fromLatest),
                    const SizedBox(height: 12.0),
                    Expanded(
                      child: ListView(children: [
                        for (final t in _peTemplates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Material(
                              color: t == sel ? _panel : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                onTap: () => set(() => load(t)),
                                borderRadius: BorderRadius.circular(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Row(children: [
                                    Icon(
                                        t.builtIn
                                            ? Icons.bookmark_border_rounded
                                            : Icons.bookmark_rounded,
                                        size: 16.0,
                                        color: t.builtIn ? _ink3 : _blue),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(t.name,
                                                style: _t(12.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w600)),
                                            Text(
                                                '${t.systems} ระบบ${t.builtIn ? ' · ของระบบ' : ''}',
                                                style: _t(9.5, color: _ink3)),
                                          ]),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ]),
            ),
            // ตัวแก้ไข
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 14.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: name,
                            readOnly: readOnly,
                            style: _t(15.0, weight: FontWeight.w700),
                            decoration: InputDecoration(
                              hintText: 'ชื่อ template เช่น ตรวจเด็กไข้',
                              helperText: readOnly
                                  ? 'template ของระบบ แก้ไม่ได้ · เปลี่ยนชื่อแล้วบันทึกเป็นของตัวเองได้'
                                  : null,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: readOnly ? null : (_) => set(() {}),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ]),
                      const SizedBox(height: 10.0),
                      Text(
                          'เลือกระบบที่สาขานี้ตรวจ ระบบที่ "ไม่รวม" จะบันทึกเป็นไม่ได้ตรวจและไม่ต้องกรอก',
                          style: _t(10.5, color: _ink3)),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: ListView.separated(
                          itemCount: systems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1.0, color: _line),
                          itemBuilder: (_, i) {
                            final l = systems[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(children: [
                                SizedBox(
                                  width: 130.0,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l,
                                            style: _t(12.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w700)),
                                        if (_termOf(l) case final sub?)
                                          Text(sub,
                                              style: _t(9.5, color: _ink3)),
                                      ]),
                                ),
                                for (final o in const [
                                  'ไม่รวม',
                                  'ปกติ',
                                  'ผิดปกติ',
                                  'ไม่ได้ตรวจ'
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: _optChip(
                                        o,
                                        (draft[l] ?? 'ไม่รวม') == o,
                                        false,
                                        () => set(() => o == 'ไม่รวม'
                                            ? draft.remove(l)
                                            : draft[l] = o),
                                        size: 10.5),
                                  ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: TextField(
                                    controller: noteOf(l),
                                    enabled: draft[l] != null,
                                    minLines: 1,
                                    maxLines: 4,
                                    style: _t(11.5),
                                    decoration: const InputDecoration(
                                      hintText: 'รายละเอียดตั้งต้น',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(children: [
                        if (sel != null && !readOnly)
                          _uiButton('ลบ', Icons.delete_outline_rounded, remove,
                              primary: false),
                        const Spacer(),
                        Text(
                            '${systems.where((l) => draft[l] != null).length} ระบบ',
                            style: _t(11.0, color: _ink3)),
                        const SizedBox(width: 10.0),
                        _uiButton('บันทึก template', Icons.check_rounded, save),
                      ]),
                    ]),
              ),
            ),
          ]),
        );
      }),
    );
  }

  /// template ที่ใช้ล่าสุดในขั้นตรวจร่างกาย (แสดงบนปุ่มเลือก)
  String? _peTplUsed;

  /// หน้าแรกของ workflow ตรวจร่างกาย: เลือก template แล้วไปกรอกต่อ
  /// เรียบที่สุด: รายการชื่อ + จำนวนระบบ · ข้าม · จัดการ (ลิงก์เล็ก)
  Widget _pePickCard() {
    void next() => setState(() {
          _formFwd = true;
          _uiIdx = _uiSeq.indexWhere((x) => x.type == ErUiType.form);
          _formAt = 0;
        });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(children: [
              for (final t in _peTemplates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Material(
                    color: _peTplUsed == t.name
                        ? _blue.withValues(alpha: 0.07)
                        : _panelSoft,
                    borderRadius: BorderRadius.circular(12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _applyPeTemplate(t);
                          _peTplUsed = t.name;
                        });
                        next();
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 12.0),
                        child: Row(children: [
                          Expanded(
                            child: Text(t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(13.0,
                                    color: _inkTitle, weight: FontWeight.w600)),
                          ),
                          Text('${t.systems} ระบบ',
                              style: _t(10.5, color: _ink3)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        Row(children: [
          TextButton(
            onPressed: _openPeTemplates,
            child: Text('จัดการ template',
                style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _peTplUsed = null;
                _peScope = null;
              });
              next();
            },
            child: Text('ข้าม · กรอกเอง',
                style: _t(11.5, color: _blueHue, weight: FontWeight.w700)),
          ),
        ]),
      ],
    );
  }

  /// ผู้ช่วยสั่งใช้ template ด้วยเสียง: {"pe_template":"<ชื่อ>"}
  void _usePeTemplate(Map<String, dynamic> data, int step) {
    final n = data['pe_template'];
    if (n is! String || !_isPeStep(step)) return;
    final t = _peTemplates.where((x) => x.name == n.trim()).firstOrNull;
    if (t != null) {
      _applyPeTemplate(t, step: step);
      _peTplUsed = t.name;
    }
  }

  String _peTemplatePrompt() => '''
template ตรวจร่างกายของแพทย์คนนี้: ${_peTemplates.map((t) => '"${t.name}"').join(', ')}
ถ้าแพทย์พูดว่า "ใช้ template ..." หรือ "ตรวจเหมือน ..." ให้ใส่ "pe_template":"<ชื่อตรงตามรายการ>" ใน JSON
ระบบจะเติมผลตาม template ให้ แล้วเติม fields เฉพาะส่วนที่แพทย์บอกว่าต่างจาก template''';

  static const String _icd9Label = 'รหัสหัตถการ ICD-9-CM';
  static const String _procLabel = 'หัตถการที่ทำ';

  /// ICD-9-CM ที่แนะนำจากหัตถการที่เลือก (ผูกรหัสไว้ใน master er_procedure.icd9cm)
  /// คืน (รหัส, ชื่อตาม master er_icd9cm) ไม่เดารหัสเอง
  List<(String, String)> _icd9Suggest() {
    final m = ErMaster.maybe;
    final proc = _filled[_speechStep][_procLabel];
    if (m == null || proc == null || proc.isEmpty) return const [];
    final icd = {
      for (final it
          in m.table('er_icd9cm')?.activeItems ?? const <ErMasterItem>[])
        it.code: it.name
    };
    return [
      for (final it
          in m.table('er_procedure')?.activeItems ?? const <ErMasterItem>[])
        if (proc.contains(it.name) && icd[it.extra['icd9cm']] != null)
          ('${it.extra['icd9cm']}', icd[it.extra['icd9cm']]!),
    ];
  }

  Widget _icd9Bar(List<(String, String)> sug) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 12.0, color: _blue),
            const SizedBox(width: 4.0),
            Text('แนะนำจากหัตถการที่ทำ',
                style: _t(9.5, color: _blueHue, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4.0),
          Wrap(spacing: 5.0, runSpacing: 5.0, children: [
            for (final (code, name) in sug)
              _optChip('$code · $name',
                  _filled[_speechStep][_icd9Label] == name, false, () {
                setState(() {
                  _lastFilled = [
                    (_speechStep, _icd9Label, _filled[_speechStep][_icd9Label])
                  ];
                  _filled[_speechStep][_icd9Label] = name;
                });
              }, size: 10.5),
          ]),
        ],
      );

  /// เลือกหัตถการแล้ว ICD-9-CM ยังว่าง: เติมรหัสที่ผูกไว้ให้เลย (แก้ได้)
  void _autoIcd9() {
    if (_filled[_speechStep].containsKey(_icd9Label)) return;
    final sug = _icd9Suggest();
    if (sug.isNotEmpty) _filled[_speechStep][_icd9Label] = sug.first.$2;
  }

  bool _isHpiStep(int step) =>
      ErSession.instance.role == ErRole.doctor && step == 1;
  bool _isPeStep(int step) =>
      ErSession.instance.role == ErRole.doctor && step == 2;

  /// ช่องรายละเอียดแบบข้อความอิสระของผลตรวจแต่ละระบบ (ตามฟอร์ม HOSxP "<ระบบ> - รายละเอียด")
  List<String> _detailLabels(int step) => _isPeStep(step)
      ? [
          for (final (l, _) in _forms[step])
            if (_peHasDetail(l)) '$l - รายละเอียด'
        ]
      : const [];

  /// ช่องบันทึกอิสระท้ายฟอร์มตรวจร่างกาย (ช่อง "บันทึกการตรวจร่างกาย" ของ HOSxP)
  static const String _peNoteLabel = 'บันทึกการตรวจแบบละเอียด';

  static bool _peHasDetail(String label) => label != _peNoteLabel;

  /// ชื่อช่องที่ผู้ช่วยเติมได้ในขั้นนี้ (ช่องในฟอร์ม + ช่องรายละเอียด)
  List<String> _acceptLabels(int step) =>
      [for (final (l, _) in _forms[step]) l, ..._detailLabels(step)];

  /// template ที่เหมาะกับเคสนี้ (ตามประเภทผู้ป่วย/อาการสำคัญ)
  String get _hpiSuggest {
    final cc = _case.cc;
    return switch (_caseP().type) {
      _Ptype.trauma => 'trauma',
      _Ptype.stemi => 'chest_pain',
      _Ptype.stroke => 'stroke',
      _Ptype.sepsis => 'fever',
      _ => cc.contains('ปวดท้อง')
          ? 'abd_pain'
          : (cc.contains('เจ็บหน้าอก') || cc.contains('แน่นหน้าอก'))
              ? 'chest_pain'
              : (cc.contains('หอบ') || cc.contains('เหนื่อย'))
                  ? 'dyspnea'
                  : 'general',
    };
  }

  /// ให้ผู้ช่วยเสนอ ICD-9-CM จากหัตถการ โดยใช้คู่รหัสใน master เท่านั้น
  String _icd9Prompt() {
    final m = ErMaster.maybe;
    if (m == null) return '';
    final icd = {
      for (final it
          in m.table('er_icd9cm')?.activeItems ?? const <ErMasterItem>[])
        it.code: it.name
    };
    final pairs = [
      for (final it
          in m.table('er_procedure')?.activeItems ?? const <ErMasterItem>[])
        if (icd[it.extra['icd9cm']] != null)
          '- ${it.name} → ${icd[it.extra['icd9cm']]}'
    ].join('\n');
    return '''
เมื่อรู้หัตถการที่ทำ ให้เสนอ "$_icd9Label" ทันทีโดยใส่ชื่อรหัสตามคู่นี้เท่านั้น (ห้ามแต่งรหัสเอง) แล้วถามแพทย์ยืนยัน:
$pairs''';
  }

  String _hpiTemplatePrompt() => '''
template HPI ที่ระบบมี (แนะนำสำหรับเคสนี้: "$_hpiSuggest"):
${[for (final t in _hpiTemplates) '- ${t.$1} (${t.$2}): ${t.$3}'].join('\n')}
การใช้ template: เลือก template ที่ตรงเคสแล้วใส่ "hpi_template":"<id>" ใน JSON ระบบจะวางข้อความ template ลงช่อง HPI ให้
เมื่อแพทย์เล่าประวัติ ให้เติมข้อความใน [ ] ของ template ด้วยสิ่งที่แพทย์พูด แล้วส่ง HPI ทั้งย่อหน้าใน fields
ส่วนที่แพทย์ยังไม่ได้พูดให้คง [ ] ไว้ แล้วถามต่อทีละ 1-2 ข้อ ห้ามเดาข้อมูล''';

  /// ผู้ช่วยเรียกใช้ template: {"hpi_template":"trauma"} → วางลงช่อง HPI ถ้ายังว่าง
  void _useHpiTemplate(Map<String, dynamic> data, int step) {
    final id = data['hpi_template'];
    if (id is! String || !_isHpiStep(step)) return;
    final t = _hpiTemplates.where((x) => x.$1 == id.trim()).firstOrNull;
    if (t == null) return;
    final cur = _filled[step]['HPI'];
    if (cur == null || cur.trim().isEmpty) _filled[step]['HPI'] = t.$3;
  }

  /// แถบเลือก template ใต้ช่อง HPI (แตะเพื่อวาง/แทนที่)
  Widget _hpiTemplateBar() {
    final sug = _hpiSuggest;
    final list = [
      ..._hpiTemplates.where((t) => t.$1 == sug),
      ..._hpiTemplates.where((t) => t.$1 != sug),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Template', style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
        const SizedBox(height: 4.0),
        SizedBox(
          height: 28.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5.0),
            itemBuilder: (_, i) {
              final t = list[i];
              final rec = t.$1 == sug;
              return InkWell(
                onTap: () => setState(() {
                  _lastFilled = [
                    (_speechStep, 'HPI', _filled[_speechStep]['HPI'])
                  ];
                  _filled[_speechStep]['HPI'] = t.$3;
                }),
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rec ? _blue.withValues(alpha: 0.08) : _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: rec ? _blue : _line),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (rec) ...[
                      const Icon(Icons.auto_awesome_rounded,
                          size: 11.0, color: _blue),
                      const SizedBox(width: 3.0),
                    ],
                    Text(t.$2,
                        style: _t(10.5,
                            color: rec ? _blueHue : _ink2,
                            weight: rec ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ช่องรายละเอียดอิสระใต้ผลตรวจของแต่ละระบบ (พิมพ์/พูดยาว ๆ ได้)
  Widget _detailBox(String label) {
    final key = '$label - รายละเอียด';
    final v = _filled[_speechStep][key];
    final must = _needsDetail(_speechStep, label);
    return InkWell(
      onTap: () => _editField(key),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: must
                  ? _red
                  : (v != null ? _greenHue.withValues(alpha: 0.5) : _line),
              width: must ? 1.5 : 1.0),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(must ? Icons.error_rounded : Icons.notes_rounded,
              size: 15.0, color: must ? _red : _ink3),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
                must
                    ? 'ผิดปกติ · ต้องระบุรายละเอียด'
                    : (v ?? 'รายละเอียด (พิมพ์หรือพูดได้ยาว ๆ)'),
                style: _t(11.5,
                    color: v != null ? _inkTitle : _ink3,
                    height: 1.4,
                    weight: v != null ? FontWeight.w500 : FontWeight.w400)),
          ),
        ]),
      ),
    );
  }

  /// หน้าสรุปก่อนบันทึก: ทุกช่องของขั้นพร้อมค่า แตะแถวเพื่อกลับไปแก้ช่องนั้น
  /// ครบแล้วจึงกดยืนยันได้ ยังไม่ครบปุ่มจะพาไปช่องแรกที่ขาด
  Widget _reviewCard(ErUiBlock b) {
    final labels = _stepLabels(_speechStep);
    final known = _filled[_speechStep];
    final missing = [
      for (final l in labels)
        if (!_fieldDone(_speechStep, l)) l
    ];
    final seq = _uiSeq;
    final formIdx = seq.indexWhere((x) => x.type == ErUiType.form);
    void editAt(String l) {
      if (formIdx < 0) return;
      final i = _formFields(seq[formIdx]).indexOf(l);
      setState(() {
        _formFwd = false;
        _uiIdx = formIdx;
        _formAt = i < 0 ? 0 : i;
      });
    }

    final action = b.str('action', 'confirm_step');
    final done = missing.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Icon(done ? Icons.fact_check_rounded : Icons.pending_actions_rounded,
              size: 18.0, color: done ? _greenHue : _amber),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text('สรุปก่อนบันทึก · ${_steps[_speechStep].$2}',
                style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text(
              done ? 'ครบ ${labels.length} ช่อง' : 'ขาด ${missing.length} ช่อง',
              style: _t(10.5,
                  color: done ? _greenHue : _amber, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8.0),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _line),
            ),
            child: SingleChildScrollView(
              child: Column(children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) const Divider(height: 1.0, color: _line),
                  InkWell(
                    onTap: () => editAt(labels[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140.0,
                              child: Text(labels[i],
                                  style: _t(11.0,
                                      color: _ink2, weight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Text(
                                  _needsDetail(_speechStep, labels[i])
                                      ? 'ผิดปกติ · ต้องระบุรายละเอียด'
                                      : [
                                          known[labels[i]] ?? 'ยังไม่ได้กรอก',
                                          if ((known['${labels[i]} - รายละเอียด'] ??
                                                  '')
                                              .isNotEmpty)
                                            known['${labels[i]} - รายละเอียด']!,
                                        ].join(' · '),
                                  style: _t(11.5,
                                      color: _fieldDone(_speechStep, labels[i])
                                          ? _inkTitle
                                          : _amber,
                                      weight: FontWeight.w600)),
                            ),
                            const Icon(Icons.edit_rounded,
                                size: 13.0, color: _g5),
                          ]),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Row(children: [
          _uiButton('แก้ไข', Icons.edit_note_rounded,
              () => editAt(done ? labels.first : missing.first),
              primary: false),
          const Spacer(),
          if (done)
            _uiButton(b.str('title', 'ยืนยันบันทึก'), Icons.check_rounded, () {
              if (action == 'summary') {
                _closeSpeech();
                _openSummary();
              } else {
                _confirmStep();
              }
            })
          else
            _uiButton('ไปกรอกช่องที่ขาด', Icons.arrow_forward_rounded,
                () => editAt(missing.first)),
        ]),
      ],
    );
  }

  /// ความสูงคงที่ของการ์ดช่องกรอกใน flipbook
  static const double _flipH = 156.0;

  Widget _formFlip(
      ErUiBlock b, List<String> fields, Map<String, String> items) {
    final known = _filled[_speechStep];
    final n = fields.length;
    final at = _formAt.clamp(0, n - 1);
    void go(int d) => _formGo(d, n);

    final f = fields[at];
    final front = Container(
      key: ValueKey('flip_${_speechStep}_$f'),
      // สูงเท่ากันทุกช่อง ไม่ว่าจะเป็นช่องพิมพ์หรือตัวเลือกหลายแถว
      height: _flipH,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 14.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
            color: _fieldDone(_speechStep, f)
                ? _greenHue.withValues(alpha: 0.5)
                : _line),
      ),
      // แถวเดียว: ซ้ายชื่อช่อง ขวาช่องกรอก
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 116.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f,
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                if (_termOf(f) case final sub?)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.0, color: _ink3, height: 1.3)),
                  ),
                if (_fieldDone(_speechStep, f))
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 12.0, color: _greenHue),
                      const SizedBox(width: 3.0),
                      Text('บันทึกแล้ว',
                          style: _t(9.5,
                              color: _greenHue, weight: FontWeight.w600)),
                    ]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          // ช่องกรอกตัวจริง (ขนาดใหญ่) ใช้ร่วมกับโหมด checklist
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: _fieldWithExtras(
                    f,
                    _guideFieldCard(f, items[f]!, known[f], true,
                        big: true,
                        onPick: () => Future.delayed(
                                const Duration(milliseconds: 380), () {
                              // ผิดปกติ = รอกรอกรายละเอียดก่อน ไม่พลิกหน้าเอง
                              if (_isPeStep(_speechStep) &&
                                  _filled[_speechStep][f] == 'ผิดปกติ') return;
                              if (mounted && _formAt == at) go(1);
                            }))),
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200) go(1);
            if (v > 200) go(-1);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // การ์ดหน้าถัดไปซ้อนด้านหลัง (เห็นขอบล่าง) บอกว่ายังมีต่อ
              for (var k = math.min(2, n - 1 - at); k >= 1; k--)
                Positioned(
                  left: 10.0 * k,
                  right: 10.0 * k,
                  top: 0.0,
                  bottom: -5.0 * k,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: _line),
                    ),
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (cur, prev) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...prev, if (cur != null) cur]),
                transitionBuilder: (child, anim) {
                  final incoming = child.key == front.key;
                  final sign = (_formFwd ? 1.0 : -1.0) * (incoming ? 1 : -1);
                  return AnimatedBuilder(
                    animation: anim,
                    child: child,
                    builder: (_, ch) => Opacity(
                      opacity: anim.value.clamp(0.0, 1.0),
                      child: Transform(
                        alignment: _formFwd
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(sign * (1 - anim.value) * math.pi / 2.2),
                        child: ch,
                      ),
                    ),
                  );
                },
                child: front,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _guideFormBody(List<(String, String)> items, Map<String, String> known,
      bool Function(int) has) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          _guideFieldCard(items[i].$1, items[i].$2, known[items[i].$1], has(i)),
      ],
    );
  }

  /// สีและไอคอนตามความหมายของตัวเลือก (ปกติ = เขียว ผิดปกติ = แดง ไม่ได้ตรวจ = เทา)
  (Color, IconData?) _choiceTone(String o) => switch (o) {
        'ปกติ' || 'ไม่มี' || 'สวม' || 'คาด' || 'ไม่ดื่ม' || 'ไม่ใช้' => (
            _greenHue,
            Icons.check_circle_rounded
          ),
        'ผิดปกติ' || 'มี' => (_red, Icons.error_rounded),
        'ไม่ได้ตรวจ' || 'ไม่ทราบ' || 'ข้าม' => (
            _ink3,
            Icons.remove_circle_rounded
          ),
        _ => (_blue, null),
      };

  /// ปุ่มตัวเลือกใหญ่ เต็มช่อง สูง 44 (เป้ากดใหญ่ ใช้มือเดียวได้)
  Widget _bigChoice(String o, bool on, VoidCallback onTap) {
    final (col, icon) = _choiceTone(o);
    return Material(
      color: on ? col : _panel,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: 44.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: on ? col : col.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 16.0, color: on ? Colors.white : col),
              const SizedBox(width: 5.0),
            ],
            Flexible(
              child: Text(o,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.0,
                      color: on ? Colors.white : col, weight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }

  /// ชิปตัวเลือก: size = ขนาดตัวอักษรกำหนดเอง (ใช้ในช่องย่อยที่พื้นที่แคบ)
  Widget _optChip(String o, bool on, bool big, VoidCallback onTap,
          {double? size}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)
              : EdgeInsets.symmetric(
                  horizontal: size == null ? 8.0 : 10.0,
                  vertical: size == null ? 3.0 : 4.0),
          decoration: BoxDecoration(
            color: on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: on ? _blue : _line),
          ),
          child: Text(o,
              style: _t(size ?? (big ? 11.5 : 9.0),
                  color: on ? Colors.white : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w500)),
        ),
      );

  /// เลือกจากรายการ master ยาว ๆ (ICD-10 ยา Lab ตึก ...) มีช่องค้นหา
  /// เลือกช่องทั้งช่องจากรายการยาว แล้วบันทึกลงฟอร์ม
  Future<void> _pickFromList(String label, List<String> opts,
      {VoidCallback? onPick}) async {
    final picked =
        await _listSheet(label, opts, current: _filled[_speechStep][label]);
    if (picked == null || !mounted) return;
    setState(() {
      _lastFilled = [(_speechStep, label, _filled[_speechStep][label])];
      _filled[_speechStep][label] = picked;
      if (label == _procLabel) _autoIcd9();
      _allergyWarn = _allergyConflict();
    });
    onPick?.call();
  }

  Future<String?> _listSheet(String label, List<String> opts,
      {String? current}) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) {
        var q = '';
        return StatefulBuilder(builder: (ctx, set) {
          final list = [
            for (final o in opts)
              if (q.isEmpty || o.toLowerCase().contains(q.toLowerCase())) o
          ];
          return SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.7,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Row(children: [
                  Expanded(
                    child: Text(label,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  Text('${opts.length} รายการ', style: _t(11.0, color: _ink3)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onChanged: (v) => set(() => q = v.trim()),
                  style: _t(13.0),
                  decoration: InputDecoration(
                    hintText: 'ค้นหา',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20.0),
                    isDense: true,
                    filled: true,
                    fillColor: _panelSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 16.0),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1.0, color: _line),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(list[i], style: _t(12.5, color: _ink)),
                    trailing: current == list[i]
                        ? const Icon(Icons.check_rounded, color: _blue)
                        : null,
                    onTap: () => Navigator.pop(ctx, list[i]),
                  ),
                ),
              ),
            ]),
          );
        });
      },
    );
    return picked;
  }

  Widget _guideFieldCard(String label, String hint, String? value, bool done,
      {bool big = false, VoidCallback? onPick}) {
    final opts = _fieldOptions(label, hint);
    final unit = _fieldUnit(hint);
    // ตัวเลือกที่ตรงกับค่า: ตรงทั้งคำก่อน แล้วค่อยคำที่อยู่ในค่า (ยาวสุดชนะ)
    String? sel;
    if (value != null && opts.isNotEmpty) {
      sel = opts.contains(value)
          ? value
          : (opts.where((o) => value.contains(o)).toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .firstOrNull;
    }
    Widget field;
    final groups = _fieldGroups(label);
    if (groups.length > 1) {
      // หลายช่องย่อย: ค่ารวมเป็น "ตัวเลือก · ตัวเลือก" ตามลำดับกลุ่ม
      String? pickOf(List<String> o) {
        if (value == null) return null;
        final hit = o.where((x) => value.contains(x)).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        return hit.firstOrNull;
      }

      // ค่าเก็บตามตำแหน่งกลุ่ม "a · b" (กลุ่มที่ยังไม่เลือก = "-")
      // กลุ่มที่ตัวเลือกซ้ำกัน (รูม่านตาซ้าย/ขวา) จึงแยกกันได้
      final parts = value?.split(' · ');
      final cur = [
        for (var gi = 0; gi < groups.length; gi++)
          parts != null && parts.length == groups.length
              ? (groups[gi].$2.contains(parts[gi]) ? parts[gi] : null)
              : pickOf(groups[gi].$2)
      ];
      void setGroup(int gi, String o) {
        final next = [...cur]..[gi] = o;
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = next.map((x) => x ?? '-').join(' · ');
        });
        // ครบทุกกลุ่มแล้วค่อยพลิกไปช่องถัดไป
        if (next.every((x) => x != null)) onPick?.call();
      }

      // ช่องย่อยละก้อน: ชื่อเล็กด้านบน · ตัวเลือกไม่เกิน 4 เป็นชิป มากกว่านั้นเป็นปุ่มเลือกจากรายการ
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var gi = 0; gi < groups.length; gi++)
            Padding(
              padding: EdgeInsets.only(top: gi == 0 ? 0 : (big ? 8.0 : 5.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(groups[gi].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(big ? 9.5 : 8.5,
                          color: _ink3, weight: FontWeight.w600)),
                  const SizedBox(height: 3.0),
                  groups[gi].$2.length <= 4
                      ? Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            for (final o in groups[gi].$2)
                              _optChip(
                                  o, o == cur[gi], false, () => setGroup(gi, o),
                                  size: big ? 11.0 : 9.0),
                          ],
                        )
                      : InkWell(
                          onTap: () async {
                            final o = await _listSheet(
                                groups[gi].$1, groups[gi].$2,
                                current: cur[gi]);
                            if (o != null && mounted) setGroup(gi, o);
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 7.0),
                            decoration: BoxDecoration(
                              color: _panelSoft,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                  color: cur[gi] != null
                                      ? _greenHue.withValues(alpha: 0.5)
                                      : _line),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Text(cur[gi] ?? 'เลือก…',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(big ? 12.0 : 9.5,
                                        color:
                                            cur[gi] != null ? _inkTitle : _ink3,
                                        weight: cur[gi] != null
                                            ? FontWeight.w600
                                            : FontWeight.w400)),
                              ),
                              const Icon(Icons.expand_more_rounded,
                                  size: 16.0, color: _ink3),
                            ]),
                          ),
                        ),
                ],
              ),
            ),
        ],
      );
    } else if (big && opts.length >= 2 && opts.length <= 4) {
      // ตัวเลือกน้อย (ปกติ/ผิดปกติ/ไม่ได้ตรวจ, มี/ไม่มี ...): ปุ่มใหญ่กว้างเท่ากัน กดง่าย
      field = Row(children: [
        for (var i = 0; i < opts.length; i++) ...[
          if (i > 0) const SizedBox(width: 6.0),
          Expanded(
              child: _bigChoice(opts[i], opts[i] == sel, () {
            setState(() {
              _lastFilled = [(_speechStep, label, value)];
              _filled[_speechStep][label] = opts[i];
            });
            // ผิดปกติ: บังคับระบุรายละเอียดทันที
            if (_needsDetail(_speechStep, label)) {
              _editField('$label - รายละเอียด',
                  title: '$label ผิดปกติ · ระบุรายละเอียด');
              return;
            }
            onPick?.call();
          })),
        ],
      ]);
    } else if (opts.isNotEmpty && opts.length <= 8) {
      field = Wrap(
        spacing: big ? 7.0 : 4.0,
        runSpacing: big ? 7.0 : 4.0,
        children: [
          for (final o in opts)
            InkWell(
              onTap: () {
                setState(() {
                  _lastFilled = [(_speechStep, label, value)];
                  _filled[_speechStep][label] = o;
                });
                onPick?.call();
              },
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                padding: big
                    ? const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 7.0)
                    : const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: o == sel ? _blue : _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: o == sel ? _blue : _line),
                ),
                child: Text(o,
                    style: _t(big ? 12.5 : 9.0,
                        color: o == sel ? Colors.white : _ink2,
                        weight: o == sel ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
        ],
      );
    } else {
      // ช่องพิมพ์ (หรือ dropdown ที่ตัวเลือกยาว แสดงเป็นช่องเลือก)
      final dropdown = opts.length > 8;
      field = InkWell(
        onTap: () => dropdown
            ? _pickFromList(label, opts, onPick: onPick)
            : _editField(label),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0)
              : const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(big ? 12.0 : 8.0),
            border: Border.all(
                color:
                    value != null ? _greenHue.withValues(alpha: 0.5) : _line),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                  value ??
                      (hint.isEmpty
                          ? (dropdown ? 'เลือก…' : 'พิมพ์หรือพูด…')
                          : hint),
                  maxLines: unit.isEmpty ? (big ? 8 : 3) : 1,
                  overflow: TextOverflow.ellipsis,
                  style: unit.isEmpty
                      ? _t(big ? 13.5 : 10.0,
                          color: value != null ? _inkTitle : _ink3,
                          weight:
                              value != null ? FontWeight.w600 : FontWeight.w400)
                      : _num(big ? 20.0 : 12.0,
                          color: value != null ? _inkTitle : _ink3,
                          weight: FontWeight.w700)),
            ),
            if (unit.isNotEmpty)
              Text(unit, style: _t(big ? 12.0 : 9.0, color: _ink3)),
            if (dropdown)
              const Icon(Icons.expand_more_rounded, size: 15.0, color: _ink3),
          ]),
        ),
      );
    }
    // flipbook มีหัวการ์ดของตัวเอง ใช้เฉพาะช่องกรอก
    if (big) return field;
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: _lastFilled.any((f) => f.$2 == label)
                ? _greenHue
                : (done ? _line : _blue.withValues(alpha: 0.35))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(label,
                  style: _t(9.5, color: _ink2, weight: FontWeight.w700)),
            ),
            Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 13.0,
                color: done ? _greenHue : _g5),
          ]),
          const SizedBox(height: 5.0),
          field,
        ],
      ),
    );
  }

  // ================================================ Generative UI ของผู้ช่วย
  // ผู้ช่วยตอบเป็นบล็อก UI (er_genui.dart) วาดในแผงขวาระหว่างโหมดพูด
  // แพทย์เห็นข้อมูลที่ต้องใช้ + ลงมือได้ในที่เดียว ไม่ต้องสลับแท็บ
  // แต่ละขั้นมีบล็อกตั้งต้น (_guideUi) เสมอ ผู้ช่วยเสริม/แทนที่ได้ตามบทสนทนา

  /// บล็อกตั้งต้นของขั้น: พาแพทย์ไปตามเส้นทางเคสแม้ผู้ช่วยยังไม่ตอบ UI มา
  List<ErUiBlock> _guideUi(int step) {
    final c = _case;
    final p = _caseP();
    final out = <ErUiBlock>[];
    ErUiBlock b(String type, Map<String, dynamic> d) => erParseUi([
          {'type': type, ...d}
        ]).map((x) => ErUiBlock(x.type, x.data, source: 'guide')).first;
    final allergy = c.allergies.isEmpty
        ? null
        : b('alert', {
            'level': 'critical',
            'title': 'แพ้ยา / แพ้อาหาร',
            'text': c.allergies.join(' · '),
          });
    final fast = switch (p.type) {
      _Ptype.stroke => ('Door-to-needle (rtPA)', 60),
      _Ptype.stemi => ('Door-to-balloon (PCI)', 90),
      _Ptype.sepsis => ('Sepsis bundle 1 ชม.', 60),
      _Ptype.trauma => ('Golden hour', 60),
      _ => null,
    };
    final arrive = c.times.isEmpty ? null : c.times.first;
    ErUiBlock? timer() => fast == null || arrive == null
        ? null
        : b('timer', {
            'label': fast.$1,
            'since': c.onset ?? arrive,
            'target_min': fast.$2
          });

    if (ErSession.instance.isNurse) {
      if (step == 1)
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
      if (allergy != null) out.add(allergy);
      return _withReview(out, step, b);
    }
    switch (step) {
      case 0:
        out.add(b('brief', {
          'title':
              '${c.sex} ${c.age} ปี · ${p.esi == null ? 'รอคัดกรอง' : 'ESI ${p.esi!.level}'}',
          'points': [
            c.cc,
            if (c.underlying.isNotEmpty)
              'โรคประจำตัว: ${c.underlying.join(', ')}',
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.first.text}',
          ],
        }));
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
        if (allergy != null) out.add(allergy);
        final t = timer();
        if (t != null) out.add(t);
      case 1:
      case 2:
      case 3:
        if (step == 2) {
          // หน้าแรกของตรวจร่างกาย: เลือก template ก่อน
          out.add(b('brief', {'title': 'เลือก template', 'pe_pick': true}));
          out.add(b('vitals', {
            'keys': ['hr', 'bp', 'spo2', 'gcs']
          }));
        }
      case 4:
        final abn = [
          for (final l in c.labs)
            if (l.abnormal) l.name
        ];
        if (abn.isNotEmpty) out.add(b('labs', {'names': abn.take(4).toList()}));
        if (allergy != null) out.add(allergy);
        final tpl = switch (p.type) {
          _Ptype.stroke => 'template_stroke',
          _Ptype.stemi => 'template_stemi',
          _Ptype.sepsis => 'template_sepsis',
          _Ptype.trauma => 'template_trauma',
          _ => 'template_general_emergency',
        };
        final kb = ErFormKb.maybe;
        if (kb != null) {
          out.add(b('order_set', {
            'title': 'ชุดคำสั่งแนะนำ · ${p.type?.label ?? 'ทั่วไป'}',
            'groups': [
              for (final f in const ['ยา/เวชภัณฑ์', 'Lab', 'X-ray', 'หัตถการ'])
                if (kb.options(tpl, f).isNotEmpty)
                  {
                    'field': f,
                    'items': kb
                        .options(tpl, f)
                        .where((o) => o != 'อื่นๆ')
                        .take(5)
                        .toList(),
                  },
            ],
          }));
        }
        final t = timer();
        if (t != null) out.add(t);
      default:
        out.add(b('brief', {
          'title': 'สรุปก่อนจำหน่าย',
          'points': [
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.map((d) => d.text).join(', ')}',
            'ขั้นถัดไป: ${c.nextStep}${c.nextDetail.isEmpty ? '' : ' · ${c.nextDetail}'}',
            if (c.disposition.isNotEmpty) 'Disposition: ${c.disposition}',
          ],
        }));
    }
    return _withReview(out, step, b);
  }

  /// ท้ายทุกขั้นของทุกบทบาท: ฟอร์มครบทุกช่อง + หน้าสรุปก่อนยืนยันบันทึก
  List<ErUiBlock> _withReview(List<ErUiBlock> out, int step,
      ErUiBlock Function(String, Map<String, dynamic>) b) {
    final last = step >= _steps.length - 1;
    return [
      ...out,
      b('form', {
        'title': _steps[step].$2,
        'fields': [for (final (l, _) in _forms[step]) l],
      }),
      b('next_step', {
        'review': true,
        'title': last ? 'ยืนยันและจบเคส' : 'ยืนยันบันทึก',
        'action': last ? 'summary' : 'confirm_step',
      }),
    ];
  }

  /// บล็อกที่แสดงอยู่ตอนนี้: ของผู้ช่วย (รอบล่าสุดของขั้นนี้) + บล็อกตั้งต้น
  /// ฟอร์มกับหน้าสรุปยืนยันใช้ของขั้นเสมอ (ผู้ช่วยส่งมาแทนไม่ได้)
  List<ErUiBlock> get _uiNow => erMergeUi([
        if (_agentUiStep == _speechStep)
          for (final b in _agentUi)
            if (b.type != ErUiType.form && b.type != ErUiType.nextStep) b
      ], _guideUi(_speechStep));

  /// ลำดับการนำเสนอการ์ด: ภาพรวม → อันตราย → ข้อมูลประกอบ → สิ่งที่ต้องทำ → ไปต่อ
  static const Map<ErUiType, int> _uiOrder = {
    ErUiType.brief: 0,
    ErUiType.alert: 1,
    ErUiType.timer: 2,
    ErUiType.vitals: 3,
    ErUiType.labs: 4,
    ErUiType.imaging: 5,
    ErUiType.checklist: 6,
    ErUiType.form: 7,
    ErUiType.orderSet: 8,
    ErUiType.nextStep: 9,
  };

  List<ErUiBlock> get _uiSeq {
    // ข้อมูลที่หน้ารายละเอียดแสดงอยู่แล้ว (สัญญาณชีพ แล็บ แพ้ยา ...) ไม่แสดงซ้ำ
    // ตัดตามชนิดข้อมูล ไม่ขึ้นกับแท็บ แผงผู้ช่วยจึงเหมือนเดิมทุกแท็บ
    final list = [
      for (final b in _uiNow)
        if (_spotOf(b) == null) b
    ];
    int rank(ErUiBlock b) =>
        (b.type == ErUiType.alert && b.str('level') == 'critical')
            ? -1
            : _uiOrder[b.type]!;
    // stable sort
    final idx = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : idx[a]!.compareTo(idx[b]!);
    });
    return list;
  }

  void _uiGo(int d, int n) {
    final to = (_uiIdx + d).clamp(0, n - 1);
    if (to != _uiIdx) setState(() => _uiIdx = to);
  }

  /// ข้อมูลชนิดนี้หน้ารายละเอียดแสดงอยู่แล้ว (คืนชื่อแผง) — null = ต้องแสดงเป็นการ์ด
  String? _spotOf(ErUiBlock b) {
    switch (b.type) {
      case ErUiType.vitals:
        return 'vitals';
      case ErUiType.labs:
        return 'labs';
      case ErUiType.imaging:
        return 'imaging';
      case ErUiType.brief:
        return b.data['pe_pick'] == true ? null : 'dx';
      case ErUiType.alert:
        final t = '${b.str('title')} ${b.str('text')}'.toLowerCase();
        return (t.contains('แพ้') || t.contains('allerg')) ? 'allergy' : null;
      default:
        return null;
    }
  }

  /// แผงผู้ช่วยข้างวงล้อ: ข้อความ → ลำดับสิ่งที่ชี้ → คำอธิบาย หรือการ์ดที่ต้องลงมือทำ
  /// หน้าตาเดียวกับแผงในหน้า (ขาว ขอบบาง มุม 14) ไม่ใช่การ์ดชนิดใหม่
  Widget _agentDock() => Positioned.fill(
        child: LayoutBuilder(builder: (context, c) {
          final seq = _uiSeq;
          final n = seq.length;
          final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
          final cur = n == 0 ? null : seq[at];
          // กรอกครบทุกช่องของขั้น: พาไปหน้าสรุปยืนยันเอง (ครั้งเดียวต่อการครบ)
          final complete =
              _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
          if (complete && _reviewShown != _speechStep && n > 0) {
            _reviewShown = _speechStep;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _uiIdx = _uiSeq.length - 1);
            });
          } else if (!complete && _reviewShown == _speechStep) {
            _reviewShown = -1;
          }
          final right = _orbitZoneW(c.maxWidth) - 28.0;
          final w = math.min(cur?.type == ErUiType.form ? 440.0 : 380.0,
              c.maxWidth - right - 24.0);
          final busy = _agentStatus.isNotEmpty;
          final say = busy
              ? _agentStatus
              : (_agentSay.isEmpty ? 'น้องช่วยพร้อมค่ะ' : _agentSay);
          final tocFields =
              cur?.type == ErUiType.form ? _formFields(cur!) : const <String>[];
          return Stack(children: [
            // สารบัญ (ซ้าย) + แผงผู้ช่วย ขอบบนตรงกัน ฐานวางบนแถวเดียวกัน
            Positioned(
              right: right,
              bottom: 16.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tocFields.length > 1) ...[
                    SizedBox(
                      width: 196.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: math.min(360.0, c.maxHeight * 0.55)),
                        child: _formToc(tocFields),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                  ],
                  SizedBox(
                    width: w,
                    child: Container(
                      padding:
                          const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: _line),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x1A0B1B3F),
                              blurRadius: 24.0,
                              offset: Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ผู้ช่วย: ขั้นที่อยู่ + ข้อความ ในก้อนเดียว
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26.0,
                                height: 26.0,
                                margin: const EdgeInsets.only(top: 2.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [
                                    Color(0xFF3B5BDB),
                                    Color(0xFF001B7C)
                                  ]),
                                ),
                                child: Icon(
                                    _agentBusy
                                        ? Icons.more_horiz_rounded
                                        : Icons.auto_awesome_rounded,
                                    size: 14.0,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'ขั้น ${_speechStep + 1}/${_steps.length} · ${_steps[_speechStep].$2}',
                                        style: _t(10.0,
                                            color: _ink3,
                                            weight: FontWeight.w600)),
                                    const SizedBox(height: 2.0),
                                    Text(say,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: _t(13.0,
                                            color: busy ? _ink3 : _inkTitle,
                                            weight: FontWeight.w600,
                                            height: 1.4)),
                                  ],
                                ),
                              ),
                              // ตัวควบคุมเดียว เดินต่อเนื่องทุกหน้า:
                              // การ์ดทั่วไป = 1 หน้า · ฟอร์ม = 1 หน้าต่อช่อง
                              if (_pageCount(seq) > 1) ...[
                                const SizedBox(width: 6.0),
                                Builder(builder: (_) {
                                  final total = _pageCount(seq);
                                  final p = _pageAt(seq);
                                  return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _dockArrow(
                                            Icons.chevron_left_rounded,
                                            p > 0
                                                ? () => _pageGo(seq, p - 1)
                                                : null),
                                        Text('${p + 1}/$total',
                                            style: _num(11.0,
                                                color: _ink2,
                                                weight: FontWeight.w700)),
                                        _dockArrow(
                                            Icons.chevron_right_rounded,
                                            p < total - 1
                                                ? () => _pageGo(seq, p + 1)
                                                : null),
                                      ]);
                                }),
                              ],
                            ],
                          ),
                          if (_agentChoices != null &&
                              !_agentBusy &&
                              cur?.data['pe_pick'] != true)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(36.0, 10.0, 0, 0),
                              child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: [
                                    for (final o in _agentChoices!.$2)
                                      InkWell(
                                        onTap: () =>
                                            _pickChoice(_agentChoices!.$1, o),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 5.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            border: Border.all(color: _line),
                                          ),
                                          child: Text(o,
                                              style: _t(11.0,
                                                  color: _blueHue,
                                                  weight: FontWeight.w600)),
                                        ),
                                      ),
                                  ]),
                            ),
                          if (cur != null) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(height: 1.0, color: _line),
                            ),
                            GestureDetector(
                              onHorizontalDragEnd:
                                  n < 2 || cur.type == ErUiType.form
                                      ? null
                                      : (d) {
                                          final v = d.primaryVelocity ?? 0;
                                          if (v < -200) _uiGo(1, n);
                                          if (v > 200) _uiGo(-1, n);
                                        },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                layoutBuilder: (a, b) => Stack(
                                    alignment: Alignment.topLeft,
                                    children: [...b, if (a != null) a]),
                                child: KeyedSubtree(
                                  key: ValueKey(
                                      '${_speechStep}_${at}_${cur.key}_$_agentUiGen'),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            math.min(320.0, c.maxHeight * 0.5)),
                                    child: _uiBlock(cur),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        }),
      );

  /// จำนวนหน้าของขั้นนี้: การ์ดทั่วไป 1 หน้า ฟอร์ม 1 หน้าต่อช่อง
  int _pagesOf(ErUiBlock b) =>
      b.type == ErUiType.form ? math.max(1, _formFields(b).length) : 1;

  int _pageCount(List<ErUiBlock> seq) => seq.fold(0, (a, b) => a + _pagesOf(b));

  /// หน้าปัจจุบัน (นับรวมทุกการ์ด)
  int _pageAt(List<ErUiBlock> seq) {
    if (seq.isEmpty) return 0;
    final at = _uiIdx.clamp(0, seq.length - 1);
    var p = 0;
    for (var i = 0; i < at; i++) {
      p += _pagesOf(seq[i]);
    }
    return p +
        (seq[at].type == ErUiType.form
            ? _formAt.clamp(0, _pagesOf(seq[at]) - 1)
            : 0);
  }

  /// ไปหน้าที่ p: หาการ์ดที่หน้านั้นอยู่ แล้วตั้งช่องของฟอร์มถ้าเป็นฟอร์ม
  void _pageGo(List<ErUiBlock> seq, int p) {
    final cur = _pageAt(seq);
    var rest = p;
    for (var i = 0; i < seq.length; i++) {
      final n = _pagesOf(seq[i]);
      if (rest < n) {
        setState(() {
          _formFwd = p > cur;
          _uiIdx = i;
          _formAt = seq[i].type == ErUiType.form ? rest : 0;
        });
        return;
      }
      rest -= n;
    }
  }

  Widget _dockArrow(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 26.0,
          height: 26.0,
          child: Icon(icon, size: 18.0, color: onTap == null ? _g5 : _blue),
        ),
      );

  /// เนื้อการ์ดในแผ่นล่าง: หัวข้อ + เนื้อหาเลื่อนได้ (แผ่นเป็นพื้นให้ ไม่มีกรอบซ้อน)
  Widget _uiCard(ErUiBlock b,
      {required IconData icon,
      required String title,
      Color? accent,
      Widget? trailing,
      required Widget child}) {
    final a = accent ?? _blue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 26.0,
            height: 26.0,
            decoration: BoxDecoration(
              color: a.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, size: 15.0, color: a),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
          ),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 8.0),
        Flexible(child: SingleChildScrollView(child: child)),
      ],
    );
  }

  Widget _uiBlock(ErUiBlock b) {
    final c = _case;
    switch (b.type) {
      case ErUiType.brief when b.data['pe_pick'] == true:
        return _pePickCard();
      case ErUiType.brief:
        return _uiCard(b,
            icon: Icons.person_search_rounded,
            title: b.str('title', 'สรุปเคส'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final pt in b.strs('points'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5.0,
                          height: 5.0,
                          margin: const EdgeInsets.only(top: 5.0, right: 7.0),
                          decoration: const BoxDecoration(
                              color: _blue, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(pt,
                              style: _t(10.5, color: _ink, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ));
      case ErUiType.vitals:
        final all = {for (final v in _caseVitals()) v.label: v};
        const names = {
          'hr': 'HR',
          'bp': 'BP',
          'spo2': 'SpO₂',
          'rr': 'RR',
          'bt': 'BT',
        };
        final keys = b.strs('keys').isEmpty
            ? const ['hr', 'bp', 'spo2', 'rr']
            : b.strs('keys');
        final tiles = <Widget>[
          for (final k in keys)
            if (names[k] != null && all[names[k]] != null)
              _uiMetric(
                  all[names[k]]!.label,
                  _vsValue(all[names[k]]!, all[names[k]]!.series.length - 1),
                  all[names[k]]!.unit,
                  all[names[k]]!.color != _ink && all[names[k]]!.color != _ink2
                      ? all[names[k]]!.color
                      : _inkTitle,
                  all[names[k]]!.series)
            else if (k == 'gcs' && c.gcs != null)
              _uiMetric(
                  'GCS',
                  c.gcsScore,
                  '/15',
                  (int.tryParse(c.gcsScore) ?? 15) < 15 ? _red : _inkTitle,
                  const []),
        ];
        return _uiCard(b,
            icon: Icons.monitor_heart_rounded,
            title: b.str('title',
                'สัญญาณชีพล่าสุด · ${c.times.isEmpty ? '' : '${c.times.last} น.'}'),
            accent: _red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                  childAspectRatio: 2.3,
                  children: tiles,
                ),
                if (b.str('note').isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(b.str('note'), style: _t(10.0, color: _ink2)),
                ],
              ],
            ));
      case ErUiType.labs:
        final want = b.strs('names').map((e) => e.toLowerCase()).toList();
        final labs = [
          for (final l in c.labs)
            if (want.isEmpty ||
                want.any((w) =>
                    l.name.toLowerCase().contains(w) ||
                    w.contains(l.name.toLowerCase())))
              l
        ];
        return _uiCard(b,
            icon: Icons.science_rounded,
            title: b.str('title', 'ผลแล็บที่ต้องดู'),
            accent: const Color(0xFF1565C0),
            child: labs.isEmpty
                ? Text('ยังไม่มีผลแล็บ', style: _t(10.0, color: _ink3))
                : Column(children: [
                    for (final l in labs) _labRow(_labTuple(l)),
                    if (b.str('note').isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text(b.str('note'), style: _t(10.0, color: _ink2)),
                      ),
                  ]));
      case ErUiType.imaging:
        final want = b.strs('names').map((e) => e.toLowerCase()).toList();
        final imgs = [
          for (final i in c.imaging)
            if (want.isEmpty ||
                want.any((w) =>
                    i.name.toLowerCase().contains(w) ||
                    w.contains(i.name.toLowerCase())))
              i
        ];
        return _uiCard(b,
            icon: Icons.image_search_rounded,
            title: b.str('title', 'ภาพถ่ายทางรังสี'),
            accent: const Color(0xFF00897B),
            child: imgs.isEmpty
                ? Text('ยังไม่มีภาพ', style: _t(10.0, color: _ink3))
                : Row(children: [
                    for (final i in imgs.take(3))
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(i.asset,
                                    height: 64.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, e, s) => Container(
                                        height: 64.0, color: _panelSoft)),
                              ),
                              const SizedBox(height: 3.0),
                              Text(i.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.5, weight: FontWeight.w700)),
                              Text(i.result,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.0, color: _ink3)),
                            ],
                          ),
                        ),
                      ),
                  ]));
      case ErUiType.alert:
        final lv = b.str('level', 'warn');
        final col = lv == 'critical' ? _red : (lv == 'info' ? _blue : _amber);
        return Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
          decoration: BoxDecoration(
            color: Color.alphaBlend(col.withValues(alpha: 0.07), _panel),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: col.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    lv == 'info'
                        ? Icons.info_rounded
                        : Icons.warning_amber_rounded,
                    size: 22.0,
                    color: col),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.str('title', 'แจ้งเตือน'),
                        style: _t(14.5, color: col, weight: FontWeight.w700)),
                    if (b.str('text').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(b.str('text'),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.5, color: _ink, height: 1.4)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case ErUiType.form:
        final items = {for (final (l, h) in _forms[_speechStep]) l: h};
        final fields = _formFields(b);
        if (fields.isEmpty) return const SizedBox.shrink();
        return _formFlip(b, fields, items);
      case ErUiType.orderSet:
        final groups = b.maps('groups');
        return _uiCard(b,
            icon: Icons.playlist_add_check_rounded,
            title: b.str('title', 'ชุดคำสั่งแนะนำ'),
            accent: const Color(0xFF7B1FA2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final g in groups) ...[
                  Text('${g['field'] ?? ''}',
                      style: _t(9.5, color: _ink3, weight: FontWeight.w700)),
                  const SizedBox(height: 3.0),
                  Wrap(spacing: 5.0, runSpacing: 5.0, children: [
                    for (final it in (g['items'] as List? ?? const []))
                      if (it is String) _uiOrderChip('${g['field']}', it),
                  ]),
                  const SizedBox(height: 7.0),
                ],
                Row(children: [
                  Text('${_orderPick.length} รายการที่เลือก',
                      style: _t(9.5, color: _ink3)),
                  const Spacer(),
                  _uiButton(
                      _orderPick.isEmpty ? 'เลือกทั้งหมด' : 'ยืนยันคำสั่ง',
                      _orderPick.isEmpty
                          ? Icons.done_all_rounded
                          : Icons.check_rounded, () {
                    if (_orderPick.isEmpty) {
                      setState(() {
                        for (final g in groups) {
                          for (final it in (g['items'] as List? ?? const [])) {
                            if (it is String)
                              _orderPick.add('${g['field']}|$it');
                          }
                        }
                      });
                    } else {
                      _commitOrders();
                    }
                  }, primary: _orderPick.isNotEmpty),
                ]),
              ],
            ));
      case ErUiType.checklist:
        return _uiCard(b,
            icon: Icons.fact_check_rounded,
            title: b.str('title', 'ขั้นตอนมาตรฐาน'),
            accent: _greenHue,
            child: Column(children: [
              for (final it in b.strs('items'))
                InkWell(
                  onTap: () => setState(() => _uiTicks.contains(it)
                      ? _uiTicks.remove(it)
                      : _uiTicks.add(it)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(children: [
                      Icon(
                          _uiTicks.contains(it)
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 16.0,
                          color: _uiTicks.contains(it) ? _greenHue : _g5),
                      const SizedBox(width: 7.0),
                      Expanded(
                        child: Text(it,
                            style: _t(10.5,
                                color: _uiTicks.contains(it) ? _ink3 : _ink)),
                      ),
                    ]),
                  ),
                ),
            ]));
      case ErUiType.timer:
        final since = b.str('since', c.times.isEmpty ? _simNow : c.times.first);
        final target = (b.data['target_min'] as num?)?.toInt() ?? 60;
        final used = RegExp(r'^\d{1,2}:\d{2}$').hasMatch(since)
            ? _minutesSince(since)
            : 0;
        final left = target - used;
        final frac = (used / target).clamp(0.0, 1.0);
        final col = left <= 0 ? _red : (frac > 0.66 ? _amber : _greenHue);
        return _uiCard(b,
            icon: Icons.timer_rounded,
            title: b.str('label', 'เวลาเป้าหมาย'),
            accent: col,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(left <= 0 ? 'เกิน ${-left}' : '$left',
                        style: _num(22.0, color: col, weight: FontWeight.w700)),
                    const SizedBox(width: 4.0),
                    Text('นาที ${left <= 0 ? 'จากเป้า' : 'ที่เหลือ'}',
                        style: _t(10.0, color: _ink3)),
                    const Spacer(),
                    Text('เริ่ม $since น. · เป้า $target น.',
                        style: _t(9.0, color: _ink3)),
                  ],
                ),
                const SizedBox(height: 6.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6.0,
                    backgroundColor: _panelSoft,
                    valueColor: AlwaysStoppedAnimation(col),
                  ),
                ),
              ],
            ));
      case ErUiType.nextStep:
        if (b.data['review'] == true) return _reviewCard(b);
        final action = b.str('action', 'confirm_step');
        return Center(
          heightFactor: 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: _greenHue.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 22.0, color: _greenHue),
              ),
              const SizedBox(height: 10.0),
              Text(b.str('title', 'ไปขั้นต่อไป'),
                  textAlign: TextAlign.center,
                  style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              if (b.str('detail').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(b.str('detail'),
                      textAlign: TextAlign.center,
                      style: _t(12.0, color: _ink3)),
                ),
              const SizedBox(height: 14.0),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(100.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (action == 'summary') {
                      _closeSpeech();
                      _openSummary();
                    } else {
                      _confirmStep();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22.0, vertical: 10.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(action == 'summary' ? 'สร้างสรุปเคส' : 'ไปขั้นต่อไป',
                          style: _t(13.0,
                              color: Colors.white, weight: FontWeight.w700)),
                      const SizedBox(width: 6.0),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 18.0, color: Colors.white),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _uiMetric(String label, String value, String unit, Color color,
          List<double> series) =>
      Container(
        padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 4.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _t(8.5, color: _ink3, weight: FontWeight.w600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _num(15.0, color: color, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 2.0),
                Text(unit, style: _t(8.0, color: _ink3)),
              ],
            ),
            if (series.length > 1)
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _Spark(series, color),
                ),
              ),
          ],
        ),
      );

  Widget _uiOrderChip(String field, String item) {
    final key = '$field|$item';
    final on = _orderPick.contains(key);
    final conflict = _allergyHit(item);
    return InkWell(
      onTap: () =>
          setState(() => on ? _orderPick.remove(key) : _orderPick.add(key)),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF7B1FA2).withValues(alpha: 0.10) : _panel,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
              color: conflict ? _red : (on ? const Color(0xFF7B1FA2) : _line)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              on
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 13.0,
              color: on ? const Color(0xFF7B1FA2) : _g5),
          const SizedBox(width: 4.0),
          Text(item,
              style: _t(9.5,
                  color: conflict ? _red : _ink,
                  weight: on ? FontWeight.w700 : FontWeight.w500)),
          if (conflict) ...[
            const SizedBox(width: 3.0),
            const Icon(Icons.warning_amber_rounded, size: 12.0, color: _red),
          ],
        ]),
      ),
    );
  }

  /// รายการคำสั่งนี้ชนกับประวัติแพ้ของผู้ป่วยไหม (ใช้กติกาเดียวกับ _allergyConflict)
  bool _allergyHit(String item) {
    final s = item.toLowerCase();
    for (final a in _case.allergies) {
      final k = a.toLowerCase();
      if (s.contains(k)) return true;
      if (k.contains('penicillin') &&
          ['amoxicillin', 'ampicillin', 'piperacillin', 'augmentin']
              .any(s.contains)) {
        return true;
      }
      if (k.contains('sulfa') && s.contains('co-trimoxazole')) return true;
      if (k.contains('nsaid') &&
          ['ibuprofen', 'ketorolac', 'diclofenac'].any(s.contains)) {
        return true;
      }
    }
    return false;
  }

  /// ลงคำสั่งที่ติ๊กเข้าช่องของขั้นนี้ แล้วให้ผู้ช่วยรับทราบต่อ
  void _commitOrders() {
    final byField = <String, List<String>>{};
    for (final k in _orderPick) {
      final i = k.indexOf('|');
      byField.putIfAbsent(k.substring(0, i), () => []).add(k.substring(i + 1));
    }
    final labels = {for (final (l, _) in _forms[_speechStep]) l};
    final changed = <(int, String, String?)>[];
    setState(() {
      for (final e in byField.entries) {
        if (!labels.contains(e.key)) continue;
        changed.add((_speechStep, e.key, _filled[_speechStep][e.key]));
        _filled[_speechStep][e.key] = e.value.join(', ');
      }
      if (changed.isNotEmpty) _lastFilled = changed;
      _allergyWarn = _allergyConflict();
      _orderPick.clear();
      _uiIdx += 1; // สั่งแล้วเลื่อนไปการ์ดถัดไปของลำดับ
    });
    final gen = ++_agentGen;
    _agentTurn(
        '(ยืนยันชุดคำสั่ง) ${byField.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join(' · ')}',
        gen);
  }

  Widget _uiButton(String label, IconData icon, VoidCallback onTap,
          {bool primary = true}) =>
      Material(
        color: primary ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13.0, color: primary ? Colors.white : _blue),
              const SizedBox(width: 4.0),
              Text(label,
                  style: _t(10.0,
                      color: primary ? Colors.white : _blueHue,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  Widget _speechGuide(double maxH) {
    final items = _forms[_speechStep];
    final allDone = _speechDone.contains(_speechStep);
    final known = _filled[_speechStep];
    bool has(int i) => allDone || known.containsKey(items[i].$1);
    final got = [
      for (var i = 0; i < items.length; i++)
        if (has(i)) i
    ].length;
    final nextIdx = [
      for (var i = 0; i < items.length; i++)
        if (!has(i)) i
    ];
    return Container(
      width: 300.0,
      constraints: BoxConstraints(maxHeight: maxH),
      padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 9.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14.0,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, size: 14.0, color: _blue),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text('ต้องพูดให้ครบ · ${_steps[_speechStep].$2}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text('$got/${items.length}',
                  style: _num(10.0,
                      color: got == items.length ? _greenHue : _ink3,
                      weight: FontWeight.w700)),
              const SizedBox(width: 6.0),
              _guideModeToggle(),
            ],
          ),
          const SizedBox(height: 6.0),
          Flexible(
            child: SingleChildScrollView(
              child: _guideForm
                  ? _guideFormBody(items, known, has)
                  : Column(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  has(i)
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 14.0,
                                  color: has(i) ? _greenHue : _g5,
                                ),
                                const SizedBox(width: 7.0),
                                Expanded(
                                  child: Text(items[i].$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(10.0,
                                          color: has(i) ? _ink3 : _inkTitle,
                                          weight: has(i)
                                              ? FontWeight.w400
                                              : FontWeight.w600)),
                                ),
                                const SizedBox(width: 6.0),
                                InkWell(
                                  onTap: () => _editField(items[i].$1),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 110.0),
                                    child: Text(
                                        known[items[i].$1] ?? items[i].$2,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        style: _t(8.5,
                                            color:
                                                known.containsKey(items[i].$1)
                                                    ? _greenHue
                                                    : _ink3,
                                            weight:
                                                known.containsKey(items[i].$1)
                                                    ? FontWeight.w600
                                                    : FontWeight.w400)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (nextIdx.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('ถัดไป: ${items[nextIdx.first].$1}',
                  style: _t(9.5, color: _blue, weight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  /// แผงประวัติการคุย: ฟองข้อความสลับผู้ใช้/ผู้ช่วย พร้อมเวลาและขั้นที่คุย
  Widget _chatPanel() => Container(
        decoration: BoxDecoration(
          color: _panel,
          border: Border(right: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16.0,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 6.0, 4.0),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined, size: 14.0, color: _blue),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                        'ประวัติการคุยกับผู้ช่วย · ${_chatLog.length} ข้อความ',
                        style: _t(10.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  InkWell(
                    onTap: () => setState(() => _chatOpen = false),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child:
                          Icon(Icons.close_rounded, size: 16.0, color: _ink3),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, color: _line),
            Expanded(
              child: _chatLog.isEmpty
                  ? Center(
                      child: Text('ยังไม่มีบทสนทนา',
                          style: _t(10.5, color: _ink3)))
                  : ListView.builder(
                      controller: _chatScroll,
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                      itemCount: _chatLog.length,
                      itemBuilder: (context, i) {
                        final t = _chatLog[i];
                        final hh = t.at.hour.toString().padLeft(2, '0');
                        final mm = t.at.minute.toString().padLeft(2, '0');
                        final stepName = _steps[t.step].$2;
                        return Align(
                          alignment: t.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420.0),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6.0),
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 6.0, 10.0, 6.0),
                              decoration: BoxDecoration(
                                color: t.user
                                    ? _blue
                                    : _blue.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  topRight: const Radius.circular(12.0),
                                  bottomLeft:
                                      Radius.circular(t.user ? 12.0 : 3.0),
                                  bottomRight:
                                      Radius.circular(t.user ? 3.0 : 12.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.text,
                                      style: _t(10.5,
                                          color: t.user ? Colors.white : _ink,
                                          height: 1.35)),
                                  const SizedBox(height: 2.0),
                                  Text(
                                      '${t.user ? (ErSession.instance.user?.name ?? 'ผู้ใช้') : 'น้องช่วย'} · $hh:$mm · $stepName',
                                      style: _t(8.0,
                                          color:
                                              t.user ? Colors.white70 : _ink3)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );

  /// กล่องกลางเหนือวงโค้ง: ประโยคที่ผู้ช่วยพูด + ปุ่มตัวเลือกให้กด
  Widget _agentBubble() {
    final busy = _agentStatus.isNotEmpty;
    final text = busy
        ? _agentStatus
        : (_agentSay.isEmpty ? 'ผู้ช่วยพร้อมค่ะ' : _agentSay);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: _line),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14.0,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                    _agentBusy
                        ? Icons.hourglass_top_rounded
                        : Icons.auto_awesome_rounded,
                    size: 14.0,
                    color: busy ? _ink3 : _blue),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: _t(11.0,
                          color: busy ? _ink3 : _blueHue,
                          weight: FontWeight.w600,
                          height: 1.3)),
                ),
              ],
            ),
          ),
          if (_agentChoices != null && !_agentBusy) ...[
            const SizedBox(height: 6.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                for (final o in _agentChoices!.$2)
                  Material(
                    color: _panel,
                    borderRadius: BorderRadius.circular(999.0),
                    clipBehavior: Clip.antiAlias,
                    elevation: 2.0,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    child: InkWell(
                      onTap: () => _pickChoice(_agentChoices!.$1, o),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999.0),
                          border:
                              Border.all(color: _blue.withValues(alpha: 0.45)),
                        ),
                        child: Text(o,
                            style: _t(10.5,
                                color: _blueHue, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// การ์ดกลาง: สถานะฟัง คลื่นเสียง เวลา ข้อความร่าง และปุ่มยืนยัน
  Widget _speechCard() {
    final (_, label) = _steps[_speechStep];
    final mm = (_recSec ~/ 60).toString().padLeft(2, '0');
    final ss = (_recSec % 60).toString().padLeft(2, '0');
    final transcript = _transcripts[_speechStep];
    return Container(
      width: 290.0,
      padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 9.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14.0,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                    color: _recording ? _red : _g5, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                    '${_recording ? 'กำลังฟัง' : 'ขั้น'} ${_speechStep + 1}/${_steps.length} · $label',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text('$mm:$ss',
                  style: _num(11.0, color: _ink2, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6.0),
          SizedBox(
            height: 18.0,
            child: Row(
              children: [
                for (var i = 0; i < 28; i++) ...[
                  Expanded(
                    child: Align(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 3.0,
                        height: 3.0 + 15.0 * (_recording ? _wave[i] : 0.15),
                        decoration: BoxDecoration(
                          color: _recording ? _blue : _g5,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1.5),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              transcript.isEmpty
                  ? (_recording
                      ? 'พูดได้เลย หยุดพูดแล้วระบบส่งให้เอง'
                      : 'แตะไมค์แล้วพูดได้เลย')
                  : transcript,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _t(10.0,
                  color: transcript.isEmpty ? _ink3 : _ink, height: 1.35),
            ),
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              _miniAction(
                  _silent ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  _silent ? 'เงียบ' : 'เสียง', () {
                setState(() => _silent = !_silent);
                if (_silent) _robot.stop();
              }),
              const SizedBox(width: 6.0),
              _miniAction(
                  Icons.forum_outlined,
                  'ประวัติการคุย${_chatLog.isEmpty ? '' : ' (${_chatLog.length})'}',
                  () => setState(() => _chatOpen = !_chatOpen)),
              const Spacer(),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(8.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _confirmStep,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded,
                            size: 12.0, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text('ยืนยัน',
                            style: _t(9.5,
                                color: Colors.white, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fabMain() => Material(
        color: _blue,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        shadowColor: _blue.withValues(alpha: 0.4),
        child: InkWell(
          onTap: () => setState(() => _fabOpen = !_fabOpen),
          child: SizedBox(
            width: 52.0,
            height: 52.0,
            child: AnimatedRotation(
              turns: _fabOpen ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              // หมุนบวก 45 องศาได้กากบาทพอดี ไม่ต้องสลับไอคอน
              child: const Icon(Icons.add_rounded,
                  size: 26.0, color: Colors.white),
            ),
          ),
        ),
      );

  /// รายการหนึ่งอันในเมนูลัด มีป้ายชื่อกำกับ ไม่ต้องเดาความหมายของไอคอน
  Widget _fabItem(IconData icon, String label, {VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: _line),
              ),
              child: Text(label,
                  style: _t(10.5, color: _ink, weight: FontWeight.w600)),
            ),
            const SizedBox(width: 8.0),
            Material(
              color: _panel,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 2.0,
              child: InkWell(
                onTap: onTap ?? () => setState(() => _fabOpen = false),
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(icon, size: 18.0, color: _blue),
                ),
              ),
            ),
          ],
        ),
      );

  /// ลิ้นชักเส้นเวลาเหตุการณ์ เลื่อนเข้ามาจากขอบขวา
  Widget _detailTimeline() => Container(
        width: 268.0,
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
        decoration: BoxDecoration(
          color: _panel,
          border: const Border(left: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24.0,
              offset: const Offset(-6, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('ประวัติการบันทึก',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _timelineOpen = false),
                  icon: const Icon(Icons.close_rounded, size: 18.0),
                  color: _ink2,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'ปิด',
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < _case.events.length; i++)
                    _timelineRow(
                        _Ev(_case.events[i].time, _case.events[i].text,
                            byDoctor: _case.events[i].byDoctor),
                        last: i == _case.events.length - 1),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _timelineRow(_Ev e, {bool last = false}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      e.byDoctor ? _blue.withValues(alpha: 0.15) : _panelSoft,
                ),
                child: Icon(
                    e.byDoctor
                        ? Icons.medical_services_rounded
                        : Icons.vaccines_rounded,
                    size: 14.0,
                    color: e.byDoctor ? _blue : _ink2),
              ),
              if (!last) Container(width: 1.5, height: 30.0, color: _line),
            ],
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clock(e.time), style: _num(9.5, color: _ink3)),
                  Text(e.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.5, weight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      );

  // ------------------------------------------------- skeleton
  /// กล่องเทาแทนที่เนื้อหาระหว่างโหลด ใช้คู่กับ _Shimmer
  static const Color _boneColor = Color(0xFFE4E7EB);

  static Widget _bone(double w, double h, {double radius = 8.0}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _boneColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static Widget _gap(double h) => SizedBox(height: h);

  /// แผงซ้าย: หัวข้อ ตัวเลขใหญ่ 2×2 กราฟ แล้วรายการ
  Widget _panelSkeleton({Key? key}) => SingleChildScrollView(
        key: key,
        padding: const EdgeInsets.fromLTRB(18.0, 10.0, 16.0, 16.0),
        child: _Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(190.0, 22.0),
              _gap(6.0),
              _bone(150.0, 11.0),
              _gap(16.0),
              for (var r = 0; r < 2; r++) ...[
                Row(
                  children: [
                    for (var c = 0; c < 2; c++) ...[
                      if (c == 1) const SizedBox(width: 10.0),
                      Expanded(
                        child: _bone(double.infinity, 78.0, radius: 14.0),
                      ),
                    ],
                  ],
                ),
                _gap(10.0),
              ],
              _bone(150.0, 12.0),
              _gap(10.0),
              _bone(double.infinity, 120.0, radius: 12.0),
              _gap(18.0),
              _bone(120.0, 12.0),
              _gap(10.0),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _bone(64.0, 30.0, radius: 100.0),
                    ),
                ],
              ),
              _gap(12.0),
              // รายการเป็นแถวคั่นเส้น กระดูกจึงเป็นบรรทัด ไม่ใช่กล่องการ์ด
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(14.0, 16.0, radius: 4.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bone(double.infinity, 12.0),
                            _gap(6.0),
                            _bone(120.0, 10.0),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      _bone(42.0, 12.0),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _statCardSkeleton() => _Shimmer(
        child: Container(
          width: 236.0,
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bone(70.0, 11.0),
                    _gap(8.0),
                    _bone(58.0, 30.0),
                    _gap(6.0),
                    _bone(96.0, 10.0),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              _bone(62.0, 62.0, radius: 31.0),
            ],
          ),
        ),
      );

  Widget _patientCardSkeleton() => _Shimmer(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: _line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bone(44.0, 22.0, radius: 8.0),
                  const SizedBox(width: 6.0),
                  _bone(96.0, 22.0, radius: 8.0),
                  const Spacer(),
                  _bone(110.0, 22.0),
                ],
              ),
              _gap(10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _bone(44.0, 44.0, radius: 22.0),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _bone(180.0, 18.0),
                                  _gap(6.0),
                                  _bone(240.0, 11.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _gap(12.0),
                        _bone(120.0, 11.0),
                        _gap(8.0),
                        _bone(double.infinity, 13.0),
                        _gap(6.0),
                        _bone(260.0, 13.0),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    flex: 4,
                    child: _bone(double.infinity, 144.0, radius: 16.0),
                  ),
                ],
              ),
              _gap(12.0),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _bone(96.0, 34.0, radius: 12.0),
                    ),
                  const Spacer(),
                  _bone(150.0, 38.0, radius: 14.0),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _detailChartsSkeleton() => SizedBox(
        width: 250.0,
        child: _Shimmer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
            children: [
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _bone(double.infinity, 118.0, radius: 14.0),
                ),
            ],
          ),
        ),
      );

  Widget _detailFieldsSkeleton() => Container(
        width: 272.0,
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        child: _Shimmer(
          child: Column(
            children: [
              Expanded(
                  child: _bone(double.infinity, double.infinity, radius: 16.0)),
              _gap(10.0),
              _bone(double.infinity, 150.0, radius: 16.0),
              _gap(10.0),
              _bone(double.infinity, 64.0, radius: 14.0),
            ],
          ),
        ),
      );

  Widget _detailTimelineSkeleton() => Container(
        width: 210.0,
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
        child: _Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(70.0, 14.0),
              _gap(12.0),
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(30.0, 30.0, radius: 15.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bone(56.0, 10.0),
                            _gap(6.0),
                            _bone(double.infinity, 12.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  /// การ์ดข้อมูลผู้ป่วยลอยล่างฉาก ชุดเดียวกับหน้าผังเตียง
  ///
  /// หัวการ์ดบอกเตียงกับระดับความเร่งด่วน ตัวการ์ดบอกชื่อ HN และสรุปอาการ
  /// ท้ายการ์ดเป็นปุ่มลัดไปงานที่ทำต่อจากตรงนี้
  Widget _scenePatientCard(_Phase phase) {
    final p = _sceneSelected(phase);
    final color = p.esi?.color ?? _ink3;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(p.bed ?? 'ยังไม่ได้เตียง',
                    style: _num(11.0, color: color, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 6.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                    p.esi == null
                        ? 'ยังไม่คัดกรอง'
                        : 'ESI ${p.esi!.level} · ${p.esi!.label}',
                    style:
                        _t(10.5, color: Colors.white, weight: FontWeight.w600)),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('เวลาอยู่ในขั้น${phase.label}',
                      style: _t(10.0, color: _ink3)),
                  Text(_hm(p.waitMin),
                      style: _num(16.0,
                          weight: FontWeight.w600,
                          color: p.over ? _red : _ink)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _scenePatientIdentity(p, color),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 13.0, color: _blue),
                        const SizedBox(width: 5.0),
                        Text('สรุปโดยระบบ',
                            style: _t(10.5,
                                color: Colors.white, weight: FontWeight.w600)),
                        const SizedBox(width: 6.0),
                        Text('ตรวจทานก่อนใช้ตัดสินใจ',
                            style: _t(9.5, color: _ink3)),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      p.over
                          ? 'ค้างในขั้น${p.stage.label}นาน ${_hm(p.waitMin)} '
                              'เกินเกณฑ์ที่กำหนด ควรเร่งจัดการก่อนรายอื่น'
                          : 'อยู่ในขั้น${p.stage.label} ${_hm(p.waitMin)} '
                              'ยังอยู่ในเกณฑ์',
                      style: _t(12.5, height: 1.45, color: _ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14.0),
              // กราฟสัญญาณชีพชุดเดียวกับหน้าผังเตียง
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('สัญญาณชีพ', style: _t(10.5, color: _ink3)),
                          const Spacer(),
                          Text('วัดซ้ำทุก 15 นาที',
                              style: _t(9.5, color: _ink3)),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      // กราฟแตะดูค่าได้ ใช้ fl_chart ตัวเดียวกับที่อื่นในแอป
                      SizedBox(
                        height: 104.0,
                        child: ErVitalsLineChart(
                            gridColor: _line,
                            mutedColor: _ink3,
                            vitals: _vitalsFor(erCaseOf(p.hn)).take(4).toList(),
                            timeLabels: erCaseOf(p.hn).times),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              _sceneCardAction(Icons.person_search_rounded, 'ข้อมูลผู้ป่วย',
                  onTap: () {
                setState(() {
                  _detail = true;
                  _touchRecent(p.hn);
                });
                _prefetchReview();
                _simulateLoad(const Duration(milliseconds: 600));
              }),
              _sceneCardAction(Icons.assignment_rounded, 'สั่งการรักษา'),
              _sceneCardAction(Icons.science_rounded, 'ผลตรวจ'),
              _sceneCardAction(Icons.edit_note_rounded, 'บันทึก'),
              const Spacer(),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(14.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call_rounded,
                            size: 16.0, color: Colors.white),
                        const SizedBox(width: 8.0),
                        Text('ขอความช่วยเหลือ',
                            style: _t(13.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// แถวรูป ชื่อ และ HN ของผู้ป่วยในการ์ด
  Widget _scenePatientIdentity(_P p, Color color) => Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                _faceUrl(p.hn),
                fit: BoxFit.cover,
                errorBuilder: (c, e, st) => Container(
                  color: color.withValues(alpha: 0.12),
                  alignment: Alignment.center,
                  child: Icon(Icons.person_rounded, size: 22.0, color: color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: _t(17.0, weight: FontWeight.w600)),
                const SizedBox(height: 2.0),
                Text('HN ${p.hn}  |  ${p.stage.label}  |  ${p.note}',
                    style: _t(11.5, color: _ink2)),
              ],
            ),
          ),
        ],
      );

  /// ปุ่มลัดในการ์ดผู้ป่วย
  Widget _sceneCardAction(IconData icon, String label, {VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Material(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () {},
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14.0, color: _ink2),
                  const SizedBox(width: 6.0),
                  Text(label,
                      style: _t(11.0, color: _ink, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      );

  /// การ์ดสรุปหนึ่งขั้นที่ลอยอยู่บนฉาก
  ///
  /// เล่าเรื่องคอขวด ไม่ใช่แค่จำนวนคน
  /// แถบ bullet = คนค้างจริงเทียบความจุที่ขั้นนี้รับไหว (ขีดคือเส้นความจุ)
  /// บรรทัดอัตรา = เข้า/ออกต่อชั่วโมง ต่างกันเท่าไรคือกองเพิ่มหรือระบายออก
  /// แถบล่างสุด = สัดส่วนความเร่งด่วน แทนโดนัทที่กินพื้นที่กว่า
  Widget _sceneStatCard(_Phase phase) {
    final people = _ofPhase(phase);
    final over = people.where((p) => p.over).length;
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    final on = _open == phase || _zoom == phase;
    final flow = _phaseFlow[phase]!;
    final net = flow.inRate - flow.outRate;
    final full = people.length >= flow.cap;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.0),
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      child: InkWell(
        onTap: () => setState(() {
          if (_open != null) {
            _open = on ? null : phase;
          } else {
            _zoom = _zoom == phase ? null : phase;
            if (_zoom != null) {
              _zoomAt = Alignment(
                  _cardAt[_zoom]!.dx * 2 - 1, _cardAt[_zoom]!.dy * 2 - 1);
            }
          }
        }),
        child: Container(
          width: 192.0,
          padding: const EdgeInsets.fromLTRB(11.0, 9.0, 11.0, 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13.0),
            border: Border.all(
                color: on ? _stageColor(phase.stages.first) : _line,
                width: on ? 1.5 : 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(phase.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.0, color: _ink2)),
                  ),
                  // ป้ายคอขวดขึ้นเฉพาะขั้นที่คนเข้ามากกว่าออก
                  if (net > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('คอขวด',
                          style: _t(8.5, color: _red, weight: FontWeight.w700)),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${people.length}',
                      style: _num(20.0,
                          color: full ? _red : _ink, weight: FontWeight.w700)),
                  const SizedBox(width: 3.0),
                  Text('/ ${flow.cap} ที่รับไหว', style: _t(9.0, color: _ink3)),
                  const Spacer(),
                  if (over > 0)
                    Text('เกินเกณฑ์ $over',
                        style: _t(9.0, color: _red, weight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 5.0),
              // segmented chart — หนึ่งช่องคือหนึ่งที่ที่ขั้นนี้รับได้
              // ช่องที่มีคนไล่สีตามความเร่งด่วน ช่องว่างเป็นเทา
              // ล้นความจุจะมีช่องแดงต่อท้าย เห็นทันทีว่าเกินไปกี่ราย
              Builder(builder: (context) {
                final segs = _segColors(counts, none, flow.cap);
                return Row(
                  children: [
                    for (var i = 0; i < segs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2.0),
                      Expanded(
                        child: Container(
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: segs[i],
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  _flowRate(Icons.south_rounded, flow.inRate, _ink2),
                  const SizedBox(width: 10.0),
                  _flowRate(Icons.north_rounded, flow.outRate, _ink2),
                  const Spacer(),
                  Text(
                      net == 0
                          ? 'คงที่'
                          : (net > 0 ? 'กอง +$net/ชม.' : 'ระบาย $net/ชม.'),
                      style: _t(9.0,
                          color: net > 0 ? _red : _ink3,
                          weight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// สีของแต่ละช่องใน segmented chart
  ///
  /// เรียงคนตามความเร่งด่วนก่อน แล้วค่อยเติมช่องว่าง
  /// ถ้าคนเกินความจุ ช่องส่วนเกินเป็นแดงต่อท้าย
  List<Color> _segColors(Map<_Esi, int> counts, int none, int cap) {
    final filled = <Color>[
      for (final e in _Esi.values) ...List.filled(counts[e] ?? 0, e.color),
      ...List.filled(none, _ink3),
    ];
    if (filled.length >= cap) {
      return [
        ...filled.take(cap),
        ...List.filled(filled.length - cap, _red),
      ];
    }
    return [...filled, ...List.filled(cap - filled.length, _panelSoft)];
  }

  /// อัตราเข้า/ออกต่อชั่วโมงหนึ่งตัว
  Widget _flowRate(IconData icon, int value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.0, color: color),
          const SizedBox(width: 2.0),
          Text('$value/ชม.',
              style: _num(9.5, color: color, weight: FontWeight.w600)),
        ],
      );

  // ---------------------------------------------------------------- รายชื่อ
  /// เข้าหน้ารายละเอียดของผู้ป่วยคนนี้ทันที (จากหมุดข้างแถบหรือรายชื่อในแผง)
  /// ล้างข้อมูลการพูดของคนไข้คนก่อน (ฟอร์ม ข้อความ ประวัติคุย การ์ดผู้ช่วย)
  void _resetSpeechCase() {
    _peTplUsed = null;
    _peScope = null;
    for (final m in _filled) {
      m.clear();
    }
    for (var i = 0; i < _transcripts.length; i++) {
      _transcripts[i] = '';
    }
    _speechDone.clear();
    _speechStep = 0;
    _chatLog.clear();
    _reviewJson = null;
    _reviewClips = null;
    _reviewJob = null;
    _agentUi = const [];
    _agentUiStep = -1;
    _uiIdx = 0;
    _formAt = 0;
    _orderPick.clear();
    _uiTicks.clear();
    _lastFilled = const [];
    _allergyWarn = null;
    _agentChoices = null;
  }

  void _openPatient(_P p) {
    if (_speechOpen) _closeSpeech();
    _vsPick.clear();
    _touchRecent(p.hn);
    setState(() {
      _open = _Phase.of(p.stage);
      _sceneHn = p.hn;
      _zoom = null;
      _fabOpen = false;
      _summaryOpen = false;
      _timelineOpen = false;
      _detail = true;
    });
    _prefetchReview();
    _simulateLoad(const Duration(milliseconds: 600));
  }

  /// รูปผู้ป่วยในรายชื่อแผงซ้าย: วงสี ESI และป้ายเลขระดับที่มุมล่าง
  /// ยังไม่คัดกรอง = วงเทา ป้าย "?"
  Widget _rowAvatar(_P p) {
    final esi = p.esi;
    final ring = esi == null ? _pInk3 : _onDark(esi.color);
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2.0),
            ),
            child: ClipOval(
              child: Image.asset(
                _faceUrl(p.hn),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: _panelSoft,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded,
                      size: 18.0, color: _ink3),
                ),
              ),
            ),
          ),
          Positioned(
            right: -2.0,
            bottom: -2.0,
            child: Tooltip(
              message: esi == null
                  ? 'ยังไม่คัดกรอง'
                  : 'ESI ${esi.level} · ${esi.label}',
              child: Container(
                width: 18.0,
                height: 18.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esi == null ? _g5 : esi.hue,
                  border: Border.all(color: _blue, width: 1.5),
                ),
                child: Text(esi == null ? '?' : '${esi.level}',
                    style: _num(10.0,
                        color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------- ผู้ป่วยที่ดูล่าสุด
  // การ์ดตาม Figma 195-681: ชื่อ เตียง/ขั้นงาน ค่าเด่นหนึ่งค่า
  // + หุ่นเงาครอปเฉพาะส่วน ไฮไลต์อวัยวะของอาการสำคัญ

  void _touchRecent(String hn) {
    _recentHn.remove(hn);
    _recentHn.insert(0, hn);
    if (_recentHn.length > 8) _recentHn.removeLast();
  }

  /// ค่าเด่นของการ์ด ตามตำแหน่งหลักที่ map ได้: (ไอคอน, ป้าย, ค่า, หน่วย, ผิดปกติ)
  /// กระดูก → ระดับความปวด · อวัยวะ → ค่าที่เกี่ยวกับอวัยวะนั้น
  (IconData, String, String, String, bool) _mapMetric(
      ErCase c, ErBodyTarget? t) {
    double? last(List<double> v) => v.isEmpty ? null : v.last;
    final organ = t == null || t.kind == ErBodyKind.bone ? '' : t.id;
    switch (organ) {
      case 'heart':
        final hr = last(c.hr);
        if (hr != null) {
          return (
            Icons.favorite_rounded,
            'ชีพจร',
            '${hr.round()}',
            'bpm',
            hr > 100 || hr < 60
          );
        }
      case 'lungs':
        final s = last(c.spo2);
        if (s != null) {
          return (Icons.air_rounded, 'SpO₂', '${s.round()}', '%', s < 94);
        }
      case 'brain':
        final g = int.tryParse(c.gcsScore);
        if (g != null) {
          return (Icons.psychology_rounded, 'GCS', '$g', '/15', g < 15);
        }
      case 'kidneys':
        for (final l in c.labs) {
          if (l.name == 'Cr') {
            return (
              Icons.science_rounded,
              'Creatinine',
              l.value.toStringAsFixed(1),
              'mg/dL',
              l.abnormal
            );
          }
        }
    }
    if (c.painScore != null) {
      return (
        Icons.sentiment_dissatisfied_rounded,
        'ระดับความปวด',
        '${c.painScore}',
        '/10',
        c.painScore! >= 7
      );
    }
    final sbp = last(c.sbp);
    return (
      Icons.monitor_heart_rounded,
      'ความดัน',
      c.bp,
      'mmHg',
      sbp != null && (sbp >= 160 || sbp < 90)
    );
  }

  Widget _recentSection() {
    final people = [
      for (final hn in _recentHn)
        for (final p in _patients)
          if (p.hn == hn) p,
    ];
    if (people.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Row(children: [
          Text('ผู้ป่วยที่ดูล่าสุด',
              style: _t(12.5, color: _pInk, weight: FontWeight.w700)),
          const Spacer(),
          Text('${people.length} ราย', style: _t(10.0, color: _pInk3)),
        ]),
        const SizedBox(height: 8.0),
        for (final p in people)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _recentCard(p),
          ),
      ],
    );
  }

  Widget _recentCard(_P p) {
    final c = erCaseOf(p.hn);
    final target = erBodyPrimary(c);
    final m = _mapMetric(c, target);
    return Material(
      color: _panel,
      borderRadius: BorderRadius.circular(14.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openPatient(p),
        child: SizedBox(
          height: 108.0,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // หุ่น 3D กว้างสองเท่าของพื้นที่เดิม ล้นไปใต้ข้อความได้ โดนตัดแค่ขอบการ์ด
              Positioned(
                right: -46.0,
                top: 0.0,
                bottom: 0.0,
                width: 216.0,
                child: Tooltip(
                  message: 'อาการสำคัญ: ${c.cc}'
                      '${target == null ? '' : ' · ${target.th}'}',
                  child: SizedBox(
                    height: 108.0,
                    child: ClipRect(child: _bodyMapThumb(target)),
                  ),
                ),
              ),
              // ไล่ขาวจากซ้าย ให้ข้อความอ่านง่ายเหนือหุ่น
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _panel,
                          _panel.withValues(alpha: 0.85),
                          _panel.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.38, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                width: 170.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _rowAvatarLight(p),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(11.5,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              Text(
                                  '${p.bed ?? 'ยังไม่ได้เตียง'} · ${p.stage.label}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.0, color: _ink3)),
                            ],
                          ),
                        ),
                      ]),
                      const Spacer(),
                      Row(children: [
                        Icon(m.$1, size: 11.0, color: _ink3),
                        const SizedBox(width: 4.0),
                        Text(m.$2, style: _t(9.0, color: _ink3)),
                      ]),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(m.$3,
                              style: _num(22.0,
                                  color: m.$5 ? _red : _inkTitle,
                                  weight: FontWeight.w700)),
                          const SizedBox(width: 3.0),
                          Text(m.$4, style: _t(9.5, color: _ink3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ภาพหุ่น 3D จาก BodyParts3D (เรนเดอร์ไว้ใน assets/images/bodymap)
  /// อวัยวะ/กระดูก = ภาพที่ชิ้นนั้นเป็นสีแดง
  /// โซนอาการไม่ระบุตำแหน่ง = ภาพฐานกึ่งกลางที่โซน + heatmap วาดทับ
  Widget _bodyMapThumb(ErBodyTarget? t) {
    if (t == null) {
      return Center(
        child: Text('ไม่ระบุตำแหน่ง',
            textAlign: TextAlign.center, style: _t(9.0, color: _ink3)),
      );
    }
    final file = switch (t.kind) {
      ErBodyKind.organ => t.id,
      ErBodyKind.bone => 'bone_${t.id}',
      ErBodyKind.zone => 'zone_${t.id}',
    };
    final img = Image.asset('assets/images/bodymap/$file.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const SizedBox.shrink());
    if (t.kind != ErBodyKind.zone) return img;
    return LayoutBuilder(builder: (context, c) {
      // ภาพฐานสูง 560 มม. จริง รัศมีโซนจึงแปลงเป็นพิกเซลตามสัดส่วนนี้
      final r = (erZoneRadiusMm[t.id] ?? 90.0) / 560.0 * c.maxHeight;
      return Stack(fit: StackFit.expand, children: [
        img,
        Center(
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0xD9E1190F),
                Color(0xB3EE501C),
                Color(0x61FAB432),
                Color(0x00FCDC5A),
              ], stops: [
                0.0,
                0.3,
                0.62,
                1.0
              ]),
            ),
          ),
        ),
      ]);
    });
  }

  /// รูปผู้ป่วยบนพื้นขาว วงสี ESI (แบบเดียวกับรายชื่อแต่คนละพื้น)
  Widget _rowAvatarLight(_P p) {
    final ring = p.esi?.hue ?? _g5;
    return Container(
      width: 30.0,
      height: 30.0,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          _faceUrl(p.hn),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: _panelSoft,
            child: const Icon(Icons.person_rounded, size: 16.0, color: _ink3),
          ),
        ),
      ),
    );
  }

  /// แถวรายชื่อผู้ป่วยในแผงซ้าย
  ///
  /// คั่นด้วยเส้น ไม่ใช่การ์ดแยกใบ — ภาษาเดียวกับหน้าแก้ไขเวลาเข้า-ออกงาน
  /// ตาไล่ลงมาทีละคอลัมน์ได้รวดเดียว ไม่ต้องข้ามขอบการ์ดทุกแถว
  /// แถวที่เกินเกณฑ์ไม่ลงพื้นสีและไม่มีแถบซ้าย บอกด้วยตัวเลขเวลาสีแดงอย่างเดียว
  Widget _personRow(_P p) {
    final limit = _limitFor(p.stage, p.esi);
    return InkWell(
      onTap: () => _openPatient(p),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _pLine)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // คอลัมน์ 1 รูปผู้ป่วย วงสีตามระดับความเร่งด่วน + ป้ายเลข ESI
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: _rowAvatar(p),
              ),
              // คอลัมน์ 2 ชื่อ · HN และอาการ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(13.0,
                                  color: _pInk, weight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8.0),
                        if (p.bed != null) ...[
                          const Icon(Icons.bed_rounded,
                              size: 13.0, color: _pInk3),
                          const SizedBox(width: 3.0),
                          Text(p.bed!,
                              style: _num(11.5,
                                  color: _pInk2, weight: FontWeight.w600)),
                        ] else
                          Text('ยังไม่ได้เตียง',
                              style: _t(10.5, color: _pInk3)),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                        p.note.isEmpty
                            ? 'HN ${p.hn}'
                            : 'HN ${p.hn} · ${p.note}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.5, color: _pInk2)),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              // คอลัมน์ 3 เวลารอเทียบเกณฑ์
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_hm(p.waitMin),
                      style: _num(13.5,
                          color: p.over ? _onDark(_red) : _pInk,
                          weight: FontWeight.w600)),
                  const SizedBox(height: 2.0),
                  Text(
                      limit == 0
                          ? 'ต้องพบแพทย์ทันที'
                          : (p.over
                              ? 'เกินเกณฑ์ $limit น.'
                              : 'เกณฑ์ $limit น.'),
                      style: _t(9.5, color: p.over ? _onDark(_red) : _pInk3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // คีย์บอร์ดไม่ดันหน้า (dialog/bottom sheet จัดการพื้นที่เอง) กันแผงผู้ช่วยล้น
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      // หน้ารายละเอียดผู้ป่วยเป็นโครงใหม่ทั้งหน้า ไม่มีแถบซ้าย/แผงเดิม
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(
            child: _detail && _open != null
                ? _detailPage()
                : Row(
                    children: [
                      _sideBar(),
                      _leftPanel(),
                      // ฝั่งขวาเป็นฉากสามมิติเต็มพื้นที่ ชิปด้านบนเปลี่ยนทั้งฉากและแผงซ้าย
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(child: _stairScene()),
                                  // กดที่ว่างรอบ ๆ เพื่อปิดการ์ดแจ้งเตือน
                                  if (_alertsOpen)
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            setState(() => _alertsOpen = false),
                                      ),
                                    ),
                                  Positioned(
                                      right: 16.0,
                                      top: 12.0,
                                      child: _alertBell()),
                                  Positioned(
                                    right: 16.0,
                                    top: 62.0,
                                    child: _alertToasts(),
                                  ),
                                  // การ์ดแจ้งเตือนลอยทับฉาก ไม่กินความกว้างของหน้า
                                  Positioned(
                                    right: 16.0,
                                    top: 62.0,
                                    bottom: 16.0,
                                    child: IgnorePointer(
                                      ignoring: !_alertsOpen,
                                      child: AnimatedSlide(
                                        offset: _alertsOpen
                                            ? Offset.zero
                                            : const Offset(0.06, -0.04),
                                        duration:
                                            const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                        child: AnimatedOpacity(
                                          opacity: _alertsOpen ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 220),
                                          child: _alertCardOverlay(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // คำอธิบายสีมีเฉพาะโหมดภาพรวม เลือกช่วงงานแล้ว
                                  // การ์ดผู้ป่วยกินพื้นที่ตรงนั้นแทน
                                  // ตอนซูมก็ซ่อน แผงสรุปมีคำอธิบายสีของตัวเองแล้ว
                                  if (_open == null)
                                    Positioned(
                                      left: 20.0,
                                      bottom: 12.0,
                                      child: IgnorePointer(
                                        ignoring: _zoom != null,
                                        child: AnimatedOpacity(
                                          opacity: _zoom == null ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 420),
                                          curve: Curves.easeInOutCubic,
                                          child: _legend(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // แถบผู้ป่วยเร่งด่วนมีเฉพาะโหมดภาพรวม
                            // เลือกช่วงงานแล้วรายชื่ออยู่ในแผงซ้ายกับการ์ดในฉากอยู่แล้ว
                            if (_open == null) _urgentStrip(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(left: 12.0, bottom: 10.0, child: _userChip()),
        ]),
      ),
    );
  }
}

/// กราฟผู้ป่วยเข้าออกรายชั่วโมง — แตะหรือลากนิ้วเพื่อดูค่ารายชั่วโมง
///
/// อ่านง่ายขึ้นด้วยเส้นกริด ป้ายชั่วโมงใต้แกน และคำอธิบายสีด้านบน
/// ค่าที่เลือกขึ้นเป็นตัวเลขจริงตรงหัวกราฟ ไม่ต้องเดาความสูงของแท่ง
class _HourChart extends StatefulWidget {
  const _HourChart({required this.t, required this.num});

  final TextStyle Function(double,
      {Color color, FontWeight weight, double? height}) t;
  final TextStyle Function(double, {Color color, FontWeight weight}) num;

  @override
  State<_HourChart> createState() => _HourChartState();
}

class _HourChartState extends State<_HourChart> {
  /// ชั่วโมงที่เลือกอยู่ null = ยังไม่ได้เลือก แสดงยอดรวมทั้งวันแทน
  int? _sel;

  void _pick(Offset local, double width) {
    final i = (local.dx / (width / _HourBars.hours)).floor();
    final c = i.clamp(0, _HourBars.hours - 1);
    if (c != _sel) setState(() => _sel = c);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final n = widget.num;
    final i = _sel;
    final totalIn = _HourBars.inflow.reduce((a, b) => a + b).round();
    final totalOut = _HourBars.outflow.reduce((a, b) => a + b).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ผู้ป่วยเข้าออกรายชั่วโมง',
                style: t(11.0, color: _pInk2, weight: FontWeight.w600)),
            const Spacer(),
            if (i == null)
              Text('24 ชม.', style: t(10.0, color: _pInk3))
            else
              Material(
                color: _pSoft,
                borderRadius: BorderRadius.circular(100.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _sel = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${i.toString().padLeft(2, '0')}:00–'
                            '${i.toString().padLeft(2, '0')}:59 น.',
                            style: n(10.0,
                                color: _pInk2, weight: FontWeight.w600)),
                        const SizedBox(width: 4.0),
                        const Icon(Icons.close_rounded,
                            size: 11.0, color: _pInk3),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            _key(Colors.white, 'เข้า',
                i == null ? totalIn : _HourBars.inflow[i].round(), t, n),
            const SizedBox(width: 12.0),
            _key(_pInk3, 'ออก',
                i == null ? totalOut : _HourBars.outflow[i].round(), t, n),
            const Spacer(),
            Text(i == null ? 'รวมทั้งวัน' : 'ชั่วโมงที่เลือก',
                style: t(9.5, color: _pInk3)),
          ],
        ),
        const SizedBox(height: 6.0),
        LayoutBuilder(
          builder: (context, c) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _pick(d.localPosition, c.maxWidth),
            onHorizontalDragUpdate: (d) => _pick(d.localPosition, c.maxWidth),
            child: SizedBox(
              height: 86.0,
              child: CustomPaint(
                painter: _HourBars(selected: _sel),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _key(
          Color color,
          String label,
          int value,
          TextStyle Function(double,
                  {Color color, FontWeight weight, double? height})
              t,
          TextStyle Function(double, {Color color, FontWeight weight}) n) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2.0)),
          ),
          const SizedBox(width: 5.0),
          Text(label, style: t(10.0, color: _pInk2)),
          const SizedBox(width: 4.0),
          Text('$value', style: n(12.0, color: _pInk, weight: FontWeight.w700)),
        ],
      );
}

/// ตัวกราฟ — ยังเป็นข้อมูลจำลอง
class _HourBars extends CustomPainter {
  const _HourBars({this.selected});

  /// ชั่วโมงที่เลือก ใช้เน้นแท่งและลากเส้นนำสายตา
  final int? selected;

  static const int hours = 24;

  static const List<double> inflow = [
    2, 1, 1, 2, 3, 5, 6, 8, 9, 7, 6, 5, //
    4, 6, 7, 9, 11, 10, 8, 6, 5, 4, 3, 2,
  ];
  static const List<double> outflow = [
    1, 1, 2, 1, 2, 3, 4, 5, 7, 8, 7, 6, //
    5, 4, 5, 6, 7, 9, 9, 7, 6, 5, 4, 3,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 14.0;
    final plot = size.height - labelH;
    final hi = inflow.reduce((a, b) => a > b ? a : b);

    // เส้นกริดแนวนอนสามเส้น พร้อมตัวเลขกำกับ อ่านความสูงได้โดยไม่ต้องเดา
    final grid = Paint()..color = _pLine;
    for (var g = 1; g <= 3; g++) {
      final v = hi * g / 3;
      final y = plot - (v / hi) * plot * 0.88;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 0.6), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: v.round().toString(),
          style: const TextStyle(
              fontFamily: 'NotoSansThai', fontSize: 8.0, color: _pInk3),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width, y - tp.height - 1.0));
    }

    final slot = size.width / hours;
    final w = slot * 0.32;

    // แถบไฮไลต์ของชั่วโมงที่เลือก วาดก่อนแท่งเพื่อให้อยู่ด้านหลัง
    if (selected != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slot * selected!, 0, slot, plot),
          const Radius.circular(4.0),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.10),
      );
    }

    for (var i = 0; i < hours; i++) {
      final x = slot * i + slot / 2;
      final dim = selected != null && selected != i;
      final hIn = (inflow[i] / hi) * plot * 0.88;
      final hOut = (outflow[i] / hi) * plot * 0.88;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - w - 0.8, plot - hIn, w, hIn),
          const Radius.circular(2.0),
        ),
        Paint()..color = Colors.white.withValues(alpha: dim ? 0.30 : 0.95),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 0.8, plot - hOut, w, hOut),
          const Radius.circular(2.0),
        ),
        Paint()..color = _pInk3.withValues(alpha: dim ? 0.18 : 0.5),
      );
    }

    // เส้นฐานเข้มกว่ากริด ให้เห็นขอบล่างของกราฟชัด
    canvas.drawRect(
        Rect.fromLTWH(0, plot - 0.9, size.width, 0.9), Paint()..color = _pInk3);

    // ป้ายชั่วโมงทุกหกชั่วโมง พอให้จับเวลาได้โดยไม่รก
    for (var i = 0; i < hours; i += 6) {
      final on = selected == i;
      final tp = TextPainter(
        text: TextSpan(
          text: '${i.toString().padLeft(2, '0')} น.',
          style: TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 8.5,
              color: on ? Colors.white : _pInk3,
              fontWeight: on ? FontWeight.w700 : FontWeight.w400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(slot * i, plot + 3.0));
    }

    // ป้ายชั่วโมงที่เลือก ถ้าไม่ตรงกับป้ายประจำหกชั่วโมง
    if (selected != null && selected! % 6 != 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${selected!.toString().padLeft(2, '0')} น.',
          style: const TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 8.5,
              color: Colors.white,
              fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (slot * selected! + slot / 2 - tp.width / 2)
          .clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, plot + 3.0));
    }
  }

  @override
  bool shouldRepaint(covariant _HourBars old) => old.selected != selected;
}

/// รายการเหตุการณ์ในเส้นเวลาของผู้ป่วย (ข้อมูลจำลอง)
/// ข้อความหนึ่งรายการในประวัติการคุยกับผู้ช่วย
class _ChatTurn {
  const _ChatTurn(this.user, this.text, this.step, this.at);
  final bool user;
  final String text;
  final int step;
  final DateTime at;
}

class _Ev {
  const _Ev(this.time, this.text, {this.byDoctor = false});
  final String time;
  final String text;
  final bool byDoctor;
}

// ------------------------------------------------ ข้อมูลจำลองของแพทย์
enum _Finding { none, normal, abnormal, notDone }

class _System {
  const _System(this.key, this.icon, this.th, this.en, this.note, this.spot);
  final String key;
  final IconData icon;
  final String th;
  final String en;
  final String note;
  final String spot; // จุดบนหุ่นที่เกี่ยวข้อง
}

/// ทบทวนอาการตามระบบ (ROS) — ตามหน้าจอ 165:2618
const List<_System> _rosSystems = [
  _System('ros_const', Icons.person_rounded, 'อาการทั่วไป', 'Constitutional',
      'ไม่มีไข้ ไม่อ่อนเพลีย', 'belly'),
  _System('ros_eyes', Icons.visibility_rounded, 'ตาและการมองเห็น', 'Eyes',
      'ไม่ตามัว ไม่ปวดตา', 'head'),
  _System('ros_ent', Icons.hearing_rounded, 'หู จมูก คอ ช่องปาก', 'ENT-Mouth',
      'ไม่เจ็บคอ ไม่มีน้ำมูก', 'neck'),
  _System('ros_cv', Icons.favorite_rounded, 'หัวใจและหลอดเลือด',
      'Cardiovascular', 'ใจสั่น ไม่มีเจ็บหน้าอก', 'heart'),
  _System('ros_resp', Icons.air_rounded, 'ระบบทางเดินหายใจ', 'Respiratory',
      'ไอมีเสมหะ หอบเหนื่อย 2 วัน', 'chest'),
  _System('ros_gi', Icons.restaurant_rounded, 'ระบบทางเดินอาหาร',
      'Gastrointestinal', 'ไม่คลื่นไส้ ไม่ปวดท้อง', 'abdomen'),
  _System('ros_heme', Icons.water_drop_rounded, 'เลือดและต่อมน้ำเหลือง',
      'Hemato-Lymphatic', '', 'arm'),
  _System('ros_msk', Icons.accessibility_new_rounded, 'กล้ามเนื้อและกระดูก',
      'Musculoskeletal', 'ปวดเข่าขวาเวลาเดิน', 'knee'),
];

/// ตรวจร่างกาย (PE) — ตามหน้าจอ 165:2615
const List<_System> _peSystems = [
  _System('pe_ga', Icons.person_rounded, 'GA', 'General Appearance',
      'รู้สึกตัวดี', 'neck'),
  _System('pe_heent', Icons.visibility_rounded, 'HEENT', 'Head, Eye, ENT',
      'ไม่ซีด ไม่เหลือง', 'head'),
  _System('pe_heart', Icons.favorite_rounded, 'Heart', 'Cardiovascular',
      'Tachycardia 124/min', 'heart'),
  _System('pe_chest', Icons.air_rounded, 'Chest / Lung', 'Respiratory',
      'Wheezing RLL', 'chest'),
  _System('pe_abd', Icons.restaurant_rounded, 'Abdomen', 'Abdomen',
      'ท้องนุ่ม กดเจ็บบริเวณลิ้นปี่เล็กน้อย ไม่พบ guarding', 'abdomen'),
  _System('pe_ext', Icons.accessibility_new_rounded, 'Extremities',
      'Musculoskeletal', 'No edema', 'ankle'),
  _System('pe_neuro', Icons.psychology_rounded, 'Neurological', 'Neurological',
      'GCS E4V4M5', 'head'),
];

/// ทิศทางการเปลี่ยนแปลงระหว่างครั้ง
enum _Change { none, same, newAbn, worse, better }

/// ผลตรวจหนึ่งครั้ง: เวลา ผู้บันทึก และผลของแต่ละระบบ (ผล, บันทึกย่อ)
class _ExamRound {
  const _ExamRound(this.time, this.by, this.findings);
  final String time;
  final String by;
  final Map<String, (_Finding, String)> findings;
  (_Finding, String) of(String key) => findings[key] ?? (_Finding.none, '');
}

/// ทบทวนระบบ 3 Record เก่า → ใหม่ (ตามหน้าจอ 165:2618)
const List<_ExamRound> _rosRounds = [
  _ExamRound('22:10', 'นพ.ธนกร สุขใจ', {
    'ros_const': (_Finding.abnormal, 'ไข้ต่ำ ๆ อ่อนเพลีย 1 วัน'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.abnormal, 'เจ็บคอเล็กน้อย'),
    'ros_cv': (_Finding.normal, 'ไม่ใจสั่น ไม่เจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอแห้ง ไม่หอบ'),
    'ros_gi': (_Finding.normal, 'ไม่คลื่นไส้ ไม่ปวดท้อง'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.normal, 'ไม่ปวดกล้ามเนื้อหรือข้อ'),
  }),
  _ExamRound('13:40', 'พญ.สุภาวดี พรชัย', {
    'ros_const': (_Finding.normal, 'ไม่มีไข้ ไม่อ่อนเพลีย'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.normal, 'ไม่เจ็บคอ'),
    'ros_cv': (_Finding.normal, 'ไม่ใจสั่น ไม่เจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอมีเสมหะ หอบเหนื่อย'),
    'ros_gi': (_Finding.abnormal, 'คลื่นไส้ ไม่อาเจียน'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.abnormal, 'ปวดเข่าขวาเวลาเดิน'),
  }),
  _ExamRound('14:23', 'นพ.กิตติศักดิ์ วัฒนา', {
    'ros_const': (_Finding.normal, 'ไม่มีไข้ ไม่อ่อนเพลีย'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.normal, 'ไม่เจ็บคอ ไม่มีน้ำมูก'),
    'ros_cv': (_Finding.abnormal, 'ใจสั่น ไม่มีเจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอมีเสมหะ หอบเหนื่อย 2 วัน'),
    'ros_gi': (_Finding.normal, 'ไม่คลื่นไส้ ไม่ปวดท้อง'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.abnormal, 'ปวดเข่าขวาเวลาเดิน'),
  }),
];

/// ข้อมูลประกอบของแต่ละ Record ROS: (วันที่, ผู้บันทึก, เป็นของผู้ใช้ที่เข้าระบบ)
/// Record ล่าสุดเป็นของผู้ใช้ปัจจุบัน แก้ได้ · ของคนอื่นดูอย่างเดียว
const List<(String, String, bool)> _rosMeta = [
  ('18 ก.ย. 2569', 'นพ.ธนกร สุขใจ', false),
  ('วันนี้', 'พญ.สุภาวดี พรชัย', false),
  ('วันนี้', 'นพ.กิตติศักดิ์ วัฒนา', true),
];

/// ตรวจร่างกาย 3 ครั้ง — ครั้งล่าสุดคือค่าที่แสดงตั้งต้น
const List<_ExamRound> _peRounds = [
  _ExamRound('09:35', 'นพ.กิตติศักดิ์', {
    'pe_ga': (_Finding.abnormal, 'ซึมเล็กน้อย ตอบคำถามช้า'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 132/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing both lungs'),
    'pe_abd': (_Finding.normal, 'ท้องนุ่ม กดไม่เจ็บ'),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E3V4M5'),
  }),
  _ExamRound('11:40', 'พญ.ศิริพร', {
    'pe_ga': (_Finding.normal, 'รู้สึกตัวดี'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 128/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing RLL'),
    'pe_abd': (_Finding.normal, 'ท้องนุ่ม กดไม่เจ็บ'),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E4V4M5'),
  }),
  _ExamRound('14:25', 'นพ.กิตติศักดิ์', {
    'pe_ga': (_Finding.normal, 'รู้สึกตัวดี'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 124/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing RLL'),
    'pe_abd': (
      _Finding.abnormal,
      'ท้องนุ่ม กดเจ็บบริเวณลิ้นปี่เล็กน้อย ไม่พบ guarding'
    ),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E4V4M5'),
  }),
];

enum _OrderStatus { pending, accepted, working, done }

class _OrderItem {
  const _OrderItem(this.name, this.detail, this.status, this.time);
  final String name;
  final String detail;
  final _OrderStatus status;
  final String time;
}

class _OrderGroup {
  const _OrderGroup(this.title, this.icon, this.color, this.items);
  final String title;
  final IconData icon;
  final Color color;
  final List<_OrderItem> items;
}

const List<String> _templates = [
  'ใช้บ่อย',
  'Sepsis',
  'Chest Pain',
  'Stroke',
  'Trauma'
];

/// ชุดคำสั่งของ Sepsis — ตามหน้าจอ 169:2801
const List<_OrderGroup> _orderGroups = [
  _OrderGroup('ยา / เวชภัณฑ์', Icons.medication_rounded, Color(0xFF7B1FA2), [
    _OrderItem('Piperacillin + Tazobactam 4.5 g',
        'IV ทุก 8 ชม. · หลังเจาะ culture', _OrderStatus.done, '10:40'),
    _OrderItem('Ceftriaxone 1 g', 'IV วันละครั้ง · ยังไม่แพ้ยา',
        _OrderStatus.pending, ''),
    _OrderItem('0.9% NSS 1,000 mL', 'IV drip 30 mL/kg ใน 3 ชม.',
        _OrderStatus.working, '10:34'),
  ]),
  _OrderGroup('เลือด', Icons.water_drop_rounded, _redHue, [
    _OrderItem('Blood culture ×2', 'aerobic + anaerobic ก่อนให้ยาปฏิชีวนะ',
        _OrderStatus.working, '10:32'),
  ]),
  _OrderGroup('แล็บ', Icons.science_rounded, _blueHue, [
    _OrderItem('CBC', 'complete blood count', _OrderStatus.done, '10:48'),
    _OrderItem('BUN / Cr', 'serum', _OrderStatus.accepted, '10:35'),
    _OrderItem(
        'Lactate', 'ซ้ำที่ 2 ชม. ถ้า > 2', _OrderStatus.accepted, '10:35'),
  ]),
  _OrderGroup(
      'ภาพถ่าย', Icons.radio_button_checked_rounded, Color(0xFF00897B), [
    _OrderItem('Chest X-ray', 'CXR AP/Portable', _OrderStatus.done, '10:50'),
  ]),
  _OrderGroup('หัตถการ', Icons.healing_rounded, _amberHue, [
    _OrderItem('Oxygen cannula 3 L/min', 'เป้าหมาย SpO₂ > 94%',
        _OrderStatus.working, '10:34'),
    _OrderItem(
        'On ET tube', 'เตรียมพร้อมถ้าหายใจล้มเหลว', _OrderStatus.pending, ''),
  ]),
];

class _Task {
  const _Task(
      this.title, this.detail, this.icon, this.color, this.time, this.waitMin,
      {this.urgent = false, this.doctor = false});
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final String time;
  final int waitMin;
  final bool urgent;
  final bool doctor;
}

const List<_Task> _followTasks = [
  _Task('เก็บ Blood culture ×2', 'พยาบาลรอรับ', Icons.water_drop_rounded,
      _redHue, '10:32', 6,
      urgent: true),
  _Task('ให้ Piperacillin + Tazobactam', 'รอผล culture',
      Icons.medication_rounded, Color(0xFF7B1FA2), '10:34', 6),
  _Task('ให้ออกซิเจน 3 L/min', 'กำลังติดตาม SpO₂', Icons.air_rounded,
      Color(0xFF00897B), '10:34', 4),
  _Task('ประเมินซ้ำหลังให้ยา 15 นาที', 'เหลือ 4 นาที', Icons.timer_rounded,
      _amberHue, '10:45', 11,
      urgent: true, doctor: true),
  _Task('ทบทวนผล CBC / Lactate', 'Lactate 4.1', Icons.science_rounded, _redHue,
      '10:48', 3,
      doctor: true),
  _Task('ประเมินการหายใจซ้ำ', 'หลังให้การรักษา 1 ชม.',
      Icons.person_search_rounded, _blueHue, '11:30', 0,
      doctor: true),
];

/// ขั้นตอนของโหมดพูด เรียงตามลำดับที่แพทย์ทำงานจริง
/// ขั้นของโหมดพูด ตาม workflow แพทย์ ER (Figma 130-5: Single-View → HPI →
/// Systemic Review → Wound → Diagnosis & Orders → Disposition)
const List<(IconData, String)> _doctorSteps = [
  (Icons.visibility_outlined, 'ทบทวนเคส'),
  (Icons.history_edu_rounded, 'ประวัติ HPI'),
  (Icons.accessibility_new_rounded, 'ตรวจร่างกาย'),
  (Icons.healing_rounded, 'บาดแผล/หัตถการ'),
  (Icons.assignment_rounded, 'วินิจฉัย/สั่ง'),
  (Icons.logout_rounded, 'จำหน่าย'),
];

/// ช่องของฟอร์มที่แต่ละขั้นของโหมดพูดต้องกรอก (ชื่อช่อง, ตัวอย่างสั้น)
///
/// แพทย์กรอกเฉพาะฟอร์ม role = doctor ใน er_form_kb.json
/// (physical_examination · treatment · diagnosis · คำสั่งแพทย์ · admit/refer)
/// ข้อมูลคัดกรอง/อุบัติเหตุ พยาบาลคัดกรองเป็นคนบันทึก แพทย์แค่ทบทวนและยืนยัน
const List<List<(String, String)>> _doctorForm = [
  [
    ('ยืนยันข้อมูลคัดกรอง', 'ถูกต้อง / ขอแก้ไข'),
    ('ยืนยันประวัติแพ้ยา', 'ถูกต้อง / ขอแก้ไข'),
  ],
  [
    ('HPI', 'ประวัติอาการปัจจุบัน'),
    ('ข้อบ่งชี้กรณีฉุกเฉิน', 'รักษาด่วน / ผ่าตัดด่วน'),
  ],
  [
    ('GA', 'ปกติ / ผิดปกติ'),
    ('HEENT', 'ปกติ / ผิดปกติ'),
    ('Heart', 'ปกติ / ผิดปกติ'),
    ('Chest', 'ปกติ / ผิดปกติ'),
    ('Abdomen', 'ปกติ / ผิดปกติ'),
    ('PR', 'ปกติ / ไม่ได้ตรวจ'),
    ('PV', 'ปกติ / ไม่ได้ตรวจ'),
    ('Genitalia', 'ปกติ / ไม่ได้ตรวจ'),
    ('Neurological', 'GCS pupils'),
    ('Extremities', 'ปกติ / ผิดปกติ'),
    ('บันทึกการตรวจแบบละเอียด', 'บันทึกผลตรวจเพิ่มเติม (ข้อความยาวได้)'),
  ],
  [
    ('ตำแหน่ง ชนิด ขนาดแผล', 'ฉีกขาด 3 ซม.'),
    ('หัตถการที่ทำ', 'ทำแผล / เย็บแผล'),
    ('รหัสหัตถการ ICD-9-CM', ''),
    ('ถ่ายภาพแผล', 'ถ่าย / ข้าม'),
  ],
  [
    ('Diagnosis ICD-10', 'S06.0'),
    ('Diagnosis Text', ''),
    ('Template คำสั่งแพทย์', 'ตามประเภทผู้ป่วย'),
    ('ยา/เวชภัณฑ์', 'จาก template'),
    ('Lab', 'CBC Coag'),
    ('X-ray', 'CT Brain'),
    ('หัตถการ', 'IV Line'),
  ],
  [
    ('สภาพผู้ป่วยออกจากห้อง ER', 'Admit / Refer / Observe'),
    ('ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป', ''),
    ('อาการสำคัญ (ใบ Admit/Refer)', ''),
    ('ยืนยันแพทย์ผู้บันทึก', ''),
  ],
];

/// แนวทางว่าผู้ช่วยควรถามอะไรในแต่ละขั้น (ใส่ใน system prompt)
const List<String> _doctorAsk = [
  'ข้อมูลคัดกรองพยาบาลบันทึกแล้วและแสดงบนจอ ให้แพทย์ยืนยันว่าถูกต้องหรือขอแก้ไข '
      'และยืนยันประวัติแพ้ยา ห้ามถามข้อมูลคัดกรองใหม่',
  'ซักประวัติอาการปัจจุบันแบบ OLDCARTS ต่อยอดจากอาการสำคัญ (เริ่มเมื่อไร ระยะเวลา '
      'อาการร่วม ถ้าเป็น Trauma ถามกลไกการบาดเจ็บและการหมดสติ) ถามทีละ 1-2 ข้อ '
      'แล้วเรียบเรียงทั้งหมดลงช่อง HPI ช่องเดียว',
  'ให้แพทย์บอกผลตรวจร่างกายทีละระบบ ระบบที่ไม่ได้พูดถึงห้ามเดา '
      'ถ้าแพทย์บอก "ปกติหมด" ให้ใส่ปกติทุกช่องที่เหลือ Neuro ต้องได้ GCS '
      'ระบบที่ผิดปกติต้องได้รายละเอียดเสมอ ถ้ายังไม่มีให้ถามก่อนไปต่อ',
  'ถ้าไม่มีแผลให้ใส่ "ไม่มีบาดแผล" ในช่องแรก ช่องอื่นเป็น "-" แล้วบอกว่าข้ามขั้นนี้ได้ '
      'ถ้ามีแผลให้แตะบนหุ่น 3D เพื่อระบุตำแหน่ง บอกชนิดและขนาด '
      'แล้วถามหัตถการที่ทำ (ทำแผล เย็บแผล ...) ใช้ตัวเลือกจริง',
  'สรุปวินิจฉัยจากข้อมูลทั้งหมดและเสนอรหัส ICD-10 ให้แพทย์ยืนยัน '
      'เสนอชุดส่งตรวจและการรักษาที่เหมาะกับวินิจฉัยเป็นตัวเลือกให้กด '
      'ห้ามสั่งยาที่ผู้ป่วยแพ้',
  'ให้แพทย์เลือกสถานะจำหน่ายเป็นตัวเลือกจริงของระบบ '
      'ถ้า Admit/Refer ให้เลือกตึกหรือสถานพยาบาลและอาการสำคัญ แล้วสรุปเคสสั้น ๆ ก่อนยืนยัน',
];

/// template HPI ของแพทย์ ER: (id, ชื่อ, ข้อความที่มีช่อง [ ] ให้เติม)
/// ผู้ช่วยเลือกใช้ได้ด้วย "hpi_template" และเติม [ ] จากคำบอกเล่าของแพทย์
const List<(String, String, String)> _hpiTemplates = [
  (
    'trauma',
    'อุบัติเหตุ',
    'ผู้ป่วย[เพศ/อายุ] ประสบอุบัติเหตุ[กลไก เช่น รถจักรยานยนต์ล้มเอง/ชน] '
        'เมื่อ[เวลา] ก่อนมา รพ. [ระยะเวลา] ขณะเกิดเหตุ[ผู้ขับขี่/ผู้โดยสาร] '
        'หมดสติ[มี/ไม่มี] จำเหตุการณ์ได้[ได้/ไม่ได้] ปวด[ตำแหน่ง] '
        'อาเจียน[มี/ไม่มี] ชัก[มี/ไม่มี] เลือดออก[ตำแหน่ง] '
        'ได้รับการดูแลก่อนมาถึง[ใส่เฝือก/ห้ามเลือด/C-collar]'
  ),
  (
    'chest_pain',
    'เจ็บหน้าอก',
    'เจ็บแน่นหน้าอก[ตำแหน่ง] ลักษณะ[แน่น/บีบ/แสบ] เริ่มเมื่อ[เวลา] นาน[ระยะเวลา] '
        'ร้าวไป[แขน/กราม/หลัง] เป็นขณะ[พัก/ออกแรง] อาการร่วม[เหงื่อแตก/ใจสั่น/หอบ/คลื่นไส้] '
        'ความรุนแรง[0-10] ประวัติ[HT/DM/DLP/สูบบุหรี่/โรคหัวใจ] ยาที่ทานอยู่[ ]'
  ),
  (
    'stroke',
    'Stroke',
    'แขนขาอ่อนแรงซีก[ซ้าย/ขวา] ปากเบี้ยว[มี/ไม่มี] พูดไม่ชัด[มี/ไม่มี] '
        'Last seen normal[เวลา] พบอาการเมื่อ[เวลา] ปวดศีรษะ[มี/ไม่มี] ชัก[มี/ไม่มี] '
        'ประวัติ[HT/DM/AF/stroke เดิม] ยาต้านเกล็ดเลือด/ต้านการแข็งตัวของเลือด[ ]'
  ),
  (
    'fever',
    'ไข้/ติดเชื้อ',
    'ไข้[ระยะเวลา] หนาวสั่น[มี/ไม่มี] อาการร่วม[ไอ/เสมหะ/ปัสสาวะแสบขัด/ปวดท้อง/ถ่ายเหลว] '
        'ซึมลง[มี/ไม่มี] รับประทานได้[ปกติ/น้อยลง] ปัสสาวะ[ปกติ/ออกน้อย] '
        'ประวัติ[โรคประจำตัว/ภูมิคุ้มกันต่ำ] ได้ยามาก่อน[ ]'
  ),
  (
    'abd_pain',
    'ปวดท้อง',
    'ปวดท้อง[ตำแหน่ง] ลักษณะ[บิด/แน่น/แสบ] เริ่มเมื่อ[เวลา] นาน[ระยะเวลา] '
        'ร้าวไป[ตำแหน่ง] คลื่นไส้อาเจียน[มี/ไม่มี] ถ่ายเหลว[มี/ไม่มี] ไข้[มี/ไม่มี] '
        'ถ่ายเป็นเลือด/ดำ[มี/ไม่มี] ประจำเดือนครั้งสุดท้าย[ ] ความรุนแรง[0-10]'
  ),
  (
    'dyspnea',
    'หอบเหนื่อย',
    'หอบเหนื่อย[ระยะเวลา] เป็นมากขึ้นขณะ[พัก/ออกแรง/นอนราบ] ไอ[แห้ง/มีเสมหะ] '
        'ไข้[มี/ไม่มี] เจ็บหน้าอก[มี/ไม่มี] ขาบวม[มี/ไม่มี] '
        'ประวัติ[หอบหืด/COPD/หัวใจล้มเหลว] ใช้ยาพ่น[ ]'
  ),
  (
    'general',
    'ทั่วไป (OLDCARTS)',
    'อาการ[ ] เริ่มเมื่อ[เวลา] ตำแหน่ง[ ] ระยะเวลา[ ] ลักษณะ[ ] '
        'ปัจจัยที่ทำให้ดีขึ้น/แย่ลง[ ] ร้าวไป[ ] ความรุนแรง[0-10] อาการร่วม[ ] '
        'การรักษาก่อนมา[ ]'
  ),
];

/// พยาบาลห้องฉุกเฉิน: ฟอร์ม role = nurse ที่ทำระหว่างผู้ป่วยอยู่ใน ER
/// (add_vitalsignmonitor · AIS · nursing_activities · observe · nursing diagnosis)
const List<(IconData, String)> _nurseSteps = [
  (Icons.monitor_heart_rounded, 'สัญญาณชีพ'),
  (Icons.personal_injury_rounded, 'ความรุนแรง AIS'),
  (Icons.playlist_add_check_rounded, 'รับคำสั่งแพทย์'),
  (Icons.visibility_rounded, 'สังเกตอาการ'),
  (Icons.volunteer_activism_rounded, 'การพยาบาล'),
  (Icons.logout_rounded, 'ออกจาก ER'),
];

const List<List<(String, String)>> _nurseForm = [
  [
    ('ความดัน', 'mmHg'),
    ('อัตราการเต้นชีพจร', '/min'),
    ('อัตราการเต้นของหัวใจ', '/min'),
    ('ออกซิเจนในเลือด', '%'),
    ('อุณหภูมิ', '°C'),
  ],
  [
    ('HEAD/NECK', ''),
    ('FACE', ''),
    ('THORAX', ''),
    ('ABDOMEN/PELVIC CONTENTS', ''),
    ('EXTREMITIES/PELVIC GIRDLE', ''),
    ('EXTERNAL', ''),
  ],
  [
    ('รับคำสั่ง ยา/เวชภัณฑ์', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง Lab', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง X-ray', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง หัตถการ', 'รับคำสั่ง / ยกเลิก'),
    ('ดำเนินการแล้ว / ใช้เวลา', 'นาที'),
  ],
  [
    ('สถานที่สังเกตอาการ', ''),
    ('ห้อง / เตียง', ''),
    ('อาการที่สังเกตได้', ''),
  ],
  [
    ('ข้อวินิจฉัยทางการพยาบาล', ''),
    ('กิจกรรมพยาบาล', ''),
    ('ประเมินผล', ''),
  ],
  [
    ('สภาพผู้ป่วยออกจากห้อง ER', 'Admit / Refer / กลับบ้าน'),
    ('วันที่-เวลาออกจากห้อง ER', ''),
    ('ส่งต่อข้อมูลให้วอร์ด / รพ.ปลายทาง', ''),
    ('ยืนยันพยาบาลผู้บันทึก', ''),
  ],
];

const List<String> _nurseAsk = [
  'ให้พยาบาลอ่านค่าสัญญาณชีพรอบนี้ทีละค่า รับตัวเลขตามที่พูดห้ามปัดเอง '
      'ถ้าค่าผิดปกติมากหรือแย่ลงจากรอบก่อนให้เตือนสั้น ๆ',
  'เฉพาะเคสอุบัติเหตุ ให้ประเมินความรุนแรง AIS ทีละส่วนของร่างกายเป็นตัวเลือกจริง '
      'ถ้าไม่ใช่อุบัติเหตุให้บอกว่าข้ามขั้นนี้ได้',
  'ทวนคำสั่งแพทย์ที่รอรับทีละกลุ่ม (ยา Lab X-ray หัตถการ) ให้กดรับหรือยกเลิก '
      'บันทึกเวลาที่ใช้เมื่อดำเนินการเสร็จ',
  'บันทึกสถานที่ ห้อง เตียงที่สังเกตอาการ และอาการที่สังเกตได้',
  'เสนอข้อวินิจฉัยทางการพยาบาลที่สอดคล้องกับอาการให้ยืนยัน '
      'แล้วเลือกกิจกรรมพยาบาลและประเมินผล ใช้ตัวเลือกจริง',
  'ให้เลือกสภาพผู้ป่วยออกจากห้อง ER เป็นตัวเลือก บันทึกเวลาออก '
      'และสรุปสิ่งที่ต้องส่งต่อให้วอร์ดหรือ รพ.ปลายทาง',
];

/// พยาบาลจุดคัดกรอง: ฟอร์ม patient_screening + accident + การดูแลก่อนมาถึง
/// (ข้อมูลเหตุการณ์อย่างหมวกนิรภัย/แอลกอฮอล์ ได้จากผู้ป่วย ญาติ หรือผู้นำส่งตอนรับเข้า)
const List<(IconData, String)> _triageSteps = [
  (Icons.how_to_reg_rounded, 'รับเข้า'),
  (Icons.record_voice_over_rounded, 'อาการสำคัญ'),
  (Icons.monitor_heart_rounded, 'สัญญาณชีพ'),
  (Icons.psychology_alt_rounded, 'GCS/รูม่านตา'),
  (Icons.car_crash_rounded, 'อุบัติเหตุ'),
  (Icons.priority_high_rounded, 'ระดับ ESI'),
];

const List<List<(String, String)>> _triageForm = [
  [
    ('ประเภทการมา', 'มาเอง / BLS / ALS'),
    ('สภาพผู้ป่วย', 'เดินมา / เปลนอน'),
    ('ผู้นำส่ง', ''),
    ('ประเภทผู้ป่วย', 'Trauma / Sepsis / …'),
  ],
  [
    ('อาการสำคัญ', ''),
    ('ระดับความเจ็บปวด', '0–10'),
  ],
  [
    ('ความดัน', 'mmHg'),
    ('อัตราการเต้นชีพจร', '/min'),
    ('อัตราการหายใจ', '/min'),
    ('ออกซิเจนในเลือด', '%'),
    ('อุณหภูมิ', '°C'),
    ('ความรู้สึกตัว', 'ตื่นดี / ซึม'),
  ],
  [
    ('การลืมตา / ตอบสนองการพูด / การเคลื่อนไหว', 'E4 V5 M6'),
    ('ปฏิกิริยารูม่านตา ซ้าย / ขวา', ''),
  ],
  [
    ('มีอุบัติเหตุหรือไม่', 'มี / ไม่มี'),
    ('สถานที่เกิดเหตุ', 'บนถนนสายรอง'),
    ('ประเภทอุบัติเหตุ', 'การขนส่ง V01-V89'),
    ('ยานพาหนะ / ประเภทผู้บาดเจ็บ', ''),
    ('หมวกนิรภัย / เข็มขัดนิรภัย', ''),
    ('แอลกอฮอล์ / สารเสพติด', ''),
    ('การดูแลก่อนมาถึง', ''),
  ],
  [
    ('ระดับความเร่งด่วน (ESI)', 'ภาวะวิกฤต…'),
    ('ห้อง / โซนห้องฉุกเฉิน', ''),
  ],
];

const List<String> _triageAsk = [
  'เก็บข้อมูลแรกรับ ถามประเภทการมา สภาพผู้ป่วย ผู้นำส่ง '
      'แล้วให้เลือกประเภทผู้ป่วยเป็นตัวเลือกจริงของระบบ',
  'บันทึกอาการสำคัญตามคำบอกเล่าของผู้ป่วยหรือญาติ และระดับความเจ็บปวด 0-10',
  'ให้พยาบาลอ่านค่าสัญญาณชีพทีละค่า รับตัวเลขตามที่พูดห้ามปัดเอง '
      'ถ้าค่าผิดปกติมากให้เตือนสั้น ๆ',
  'ประเมิน GCS แยก E V M และปฏิกิริยารูม่านตาซ้ายขวา ใช้ตัวเลือกจริงของระบบ',
  'ถ้าไม่ใช่อุบัติเหตุให้ใส่ "ไม่มี" ช่องแรกและข้ามขั้น ถ้ามีให้ถามจากผู้ป่วย ญาติ '
      'หรือผู้นำส่ง: สถานที่ ประเภท ยานพาหนะ อุปกรณ์นิรภัย แอลกอฮอล์ และการดูแลก่อนมาถึง',
  'เสนอระดับ ESI จากอาการและสัญญาณชีพให้ยืนยัน แล้วเลือกโซนห้องฉุกเฉิน',
];

/// แถบโค้งครึ่งวงกลมของโหมดพูด
class _ArcTrack extends CustomPainter {
  const _ArcTrack({
    required this.center,
    required this.radius,
    required this.width,
    required this.color,
  });
  final Offset center;
  final double radius;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi, false, p);
  }

  @override
  bool shouldRepaint(_ArcTrack old) =>
      old.center != center || old.radius != radius || old.color != color;
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-2.6 + 4.0 * t, -0.3),
            end: Alignment(-0.6 + 4.0 * t, 0.3),
            colors: const [
              Color(0xFFE4E7EB),
              Color(0xFFF7F8FA),
              Color(0xFFE4E7EB),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// วงกลมเพ่งบริเวณอาการ ตามแบบในผัง — วงนอกบาง วงในไล่สี และเส้นรัศมี
class _FocusRing extends CustomPainter {
  const _FocusRing({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // ไล่สีจางจากกลางออกขอบ บอกความรุนแรงโดยไม่บังตัวหุ่น
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.34),
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = color.withValues(alpha: 0.75);
    canvas.drawCircle(c, r, line);
    canvas.drawCircle(
        c,
        r * 0.66,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.55));
    canvas.drawCircle(
        c,
        r * 0.34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.45));

    // เส้นรัศมีสี่ทิศ ช่วยให้อ่านออกว่าเป็นวงเพ่ง ไม่ใช่รอยเปื้อน
    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r * 0.34),
        c + Offset(math.cos(a), math.sin(a)) * r,
        Paint()
          ..strokeWidth = 1.0
          ..color = color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusRing old) => old.color != color;
}

/// เส้นแนวโน้มเล็ก ๆ ในช่องค่าสัญญาณชีพของ Generative UI
class _Spark extends CustomPainter {
  _Spark(this.series, this.color);
  final List<double> series;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2 || size.height <= 0) return;
    final lo = series.reduce(math.min), hi = series.reduce(math.max);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = i / (series.length - 1) * size.width;
      final y = size.height - (series[i] - lo) / span * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_Spark old) => old.series != series || old.color != color;
}

/// คลื่นเสียงรอบปุ่มไมค์: แท่งรัศมีรอบวง ยาวตามความดังจริงช่วงล่าสุด
class _MicWave extends CustomPainter {
  _MicWave({required this.levels, required this.inner, required this.color});

  final List<double> levels;
  final double inner;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;
    final c = size.center(Offset.zero);
    const n = 40;
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (var i = 0; i < n; i++) {
      // วนค่าความดังรอบวงแบบสมมาตร ค่าล่าสุดอยู่ด้านบน
      final k = (i < n / 2 ? i : n - i) * (levels.length - 1) ~/ (n / 2);
      final v = levels[levels.length - 1 - k.clamp(0, levels.length - 1)];
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      final d = Offset(math.cos(a), math.sin(a));
      final len = 2.0 + v * 22.0;
      p.color = color.withValues(alpha: 0.25 + v * 0.6);
      canvas.drawLine(c + d * inner, c + d * (inner + len), p);
    }
  }

  @override
  bool shouldRepaint(_MicWave old) => true;
}
