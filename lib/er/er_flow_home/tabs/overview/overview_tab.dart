// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ตัวกรองระดับ ESI ของรายชื่อผู้ป่วยหน้าภาพรวม (null = ทั้งหมด)
int? _boardEsi;

/// เลื่อนแถวไทล์ในหัวรายบุคคลไปแล้วแค่ไหน (0–1): ฉากขวาหุบออก ไทล์ใช้เต็มกว้าง
final ValueNotifier<double> _ovTileScroll = ValueNotifier(0.0);

/// รอบรายบุคคลที่แถวไทล์เป็นของ (เปลี่ยนรอบ = ฉากกลับมา)
String _ovTileScrollKey = '';

/// หยุดวนรอบไว้เพราะเลื่อนไทล์อยู่
bool _ovTileHeld = false;

/// ตัวเลื่อนแถวไทล์ในหัวรายบุคคล
/// ไม่จำตำแหน่งเลื่อน (PageStorage): สไลด์ใหม่เริ่มต้นแถวเสมอ ไม่รับระยะเลื่อนของสไลด์ก่อน
final ScrollController _ovTileCtl = ScrollController(keepScrollOffset: false);

/// ความกว้างข้อความหัวรายบุคคล (ป้าย ชื่อ คำอธิบาย) คงที่ตอนฉากหุบ: ข้อความไม่จัดบรรทัดใหม่ระหว่างเลื่อน
double _ovHeadW = 400.0;

/// เมนู "ตัวชี้วัด" ในรางซ้ายเลือกอยู่ (แผงซ้าย = ตัวชี้วัด 8 ตัว · ขวา = ข้อมูลเชิงลึก)
bool _kpiOpen = false;

/// ระดับ ESI ที่แตะเลือกในการ์ดแยกตามระดับความเร่งด่วน (null = ไม่ได้เลือก)
int? _kpiEsiSel;

/// บทอาการที่พามา: กางดูทุกอาการ (ปกติแสดง 5 อันดับแรก)
bool _kpiCcAll = false;

/// ช่องตัวชี้วัด 8 ช่องของแผงซ้าย (รอบ build ล่าสุด) ไว้ preview ในหน้าต่างที่มาและสูตร
List<Widget> _kpiTilesPreview = const [];

/// วิดเจ็ตในแผงภาพรวม: ผู้ใช้เลือก/เรียงเองจากชุดตัวชี้วัด (id, ชื่อ, เต็มแถว) · จำไว้ในเครื่อง
const _ovWidgetAll = <(String, String, bool)>[
  ('queue', 'รอรับบริการ', true),
  ('wait', 'เวลารอ', false),
  ('bed', 'เตียง ER', false),
  ('total', 'ผู้ป่วยวันนี้', true),
  ('d2d', 'Door-to-Doctor', false),
  ('admit', 'Admit', false),
  ('lwbs', 'LWBS', false),
  ('death', 'เสียชีวิต', false),
  ('hour', 'ผู้ป่วยเข้าออกรายชั่วโมง', true),
];
List<String> _ovWidgets = const ['queue', 'wait', 'bed', 'hour'];
bool _ovWidgetsLoaded = false;

/// โหมดจัดวิดเจ็ต: ลากเรียง/เอาออกในแผงได้ทันที + ถาดวิดเจ็ตงอกออกขวาแผง (ลากเข้ามาเพิ่ม)
bool _ovEdit = false;
bool _ovAlertsAll = false; // การ์ดแจ้งเตือนซ้อน: กางเป็นรายการ
String? _ovDrag; // id ที่กำลังลาก
List<String>? _ovLive; // ลำดับระหว่างลาก (ยังไม่บันทึก) · ปล่อยในแผง = บันทึก
double _ovPanelW =
    296.0; // ความกว้างช่องวิดเจ็ตในแผง (ถาดใช้ขนาดเดียวกัน ลากแล้วขนาดไม่เปลี่ยน)
Size _ovDragSize = Size.zero; // ขนาดการ์ดที่ยกอยู่ (หาจุดกึ่งกลางใต้นิ้ว)
(String, Rect)? _ovSettle; // ปล่อยแล้ว: การ์ดร่อนจากจุดปล่อยลงช่อง
bool _ovSettleGo = false;
Timer? _ovScrollT; // เลื่อนแผงอัตโนมัติเมื่อลากชิดขอบบน/ล่าง
double _ovScrollV = 0.0;
(String, Offset)? _ovLastMove;
final _ovGridKey = GlobalKey();
const _ovWidgetsKey = 'er_overview_widgets';

/// เนื้อการ์ดของบทข้อมูลเชิงลึก 5 บท (รอบ build ล่าสุด) ไว้ preview ในหน้าต่างที่มาและสูตร
final List<Widget Function(bool)?> _kpiChPreview = List.filled(5, null);

/// กราฟรายชั่วโมง: ชั่วโมงที่แตะ/ลากเลือก (ดัชนีใน _kpiFlowHours) · null = ไม่เลือก (แสดงป้ายช่วงพีค)
int? _kpiFlowSel;

/// ชั่วโมงที่เลือกล่าสุด (ป้ายจางออกที่ตำแหน่งเดิม) · ตำแหน่งต่อเนื่องระหว่างลาก (null = ไม่ได้ลาก)
int _kpiFlowLast = 0;
final ValueNotifier<double?> _kpiFlowDrag = ValueNotifier(null);

/// ข้อมูลเชิงลึกวันนี้ (ชุดเดียวกับแดชบอร์ด ER: er_dashboard widgets) · ยังไม่ต่อข้อมูลจริง
const _kpiTriage = [12, 48, 134, 89, 29];
const _kpiFlowHours = [0, 2, 4, 6, 8, 10, 12, 14, 16];
const _kpiFlowIn = [6, 4, 3, 9, 20, 27, 31, 28, 23];
const _kpiFlowOut = [4, 3, 2, 6, 16, 23, 28, 26, 21];
const _kpiFlowAdmit = [2, 1, 1, 2, 4, 5, 6, 5, 4];
const _kpiLos = [
  ('คัดกรอง', 8),
  ('รอพบแพทย์', 22),
  ('ตรวจและรักษา', 35),
  ('รอผล Lab', 45),
  ('รอผล X-ray', 25),
  ('รอ Admit', 68),
  ('จำหน่าย', 20),
];
const _kpiCc = [
  ('เจ็บหน้าอก', 410, 42),
  ('หายใจลำบาก', 371, 38),
  ('อุบัติเหตุ บาดเจ็บ', 351, 22),
  ('ปวดท้อง', 301, 18),
  ('ไข้สูง', 278, 11),
  ('ชัก หมดสติ', 200, 55),
  ('ปวดศีรษะ', 171, 9),
  ('แขนขาอ่อนแรง', 131, 60),
  ('อาเจียน', 115, 15),
  ('วิงเวียน เป็นลม', 98, 20),
];
const _kpiDispo = [
  ('กลับบ้าน', 64.0),
  ('Admit', 19.0),
  ('สังเกตอาการ', 10.0),
  ('ส่งต่อ', 4.0),
  ('เสียชีวิต', 3.0),
];

/// สีชุดกราฟตัวชี้วัด: กรมท่าไล่อ่อน (ไม่ใช้สีที่สื่อความเร่งด่วน) · แดงเฉพาะค่าที่ผิดปกติ/คอขวด
const _kpiTones = [
  Color(0xFF001B7C),
  Color(0xFF2B3F96),
  Color(0xFF5A69B4),
  Color(0xFF9AA3D2),
  Color(0xFFC9CEE8),
];

/// กรองเฉพาะผู้ป่วยที่เปิดแฟ้ม fast track (หน้าภาพรวม)
bool _boardFt = false;

/// กลุ่มย่อย Fast track ที่กรอง (id แฟ้ม เช่น stroke) · null = ทุกกลุ่ม
String? _boardFtType;

/// แพทย์: แสดงเฉพาะผู้ป่วยที่ assign ให้ตัวเอง (ค่าเริ่มต้น = เปิด) ER-3819
bool _boardMine = true;

/// ตัวปรับภาพในวงภาพรวม (debug build เท่านั้น · กดค้างวงกลางเพื่อเปิด)
/// _ovTune[ภาพ] = (ขนาดกรอบ, เลื่อน x, เลื่อน y) ทับค่าในโค้ดชั่วคราว จนกว่าจะคัดลอกไปใส่
bool _ovDbg = false;
int _ovDbgCur = 0;
final Map<String, (double, double, double)> _ovTune = {};
double _ovPinch0 = 0.0;

/// ตำแหน่งแผงปรับภาพ (ลากที่หัวแผงเพื่อย้าย)
Offset _ovDbgPos = const Offset(12.0, 58.0);

/// สีย้อมของรอบที่วนอยู่ (ฉากภาพรวม) ให้พื้นหลังบอร์ดใต้รายชื่อไหลสีต่อจากฉาก
final _ovTint = ValueNotifier<Color>(_blue);

/// ตัวเลื่อนรายชื่อหน้าภาพรวม (ใช้ดูดฉากหัวให้กาง/หุบสุดตอนปล่อยนิ้ว)
final _ovScroll = ScrollController();

/// มุมมองรายชื่อหน้าภาพรวม: false = การ์ด · true = ตาราง
bool _boardTable = false;

/// คอลัมน์ที่เรียงในตาราง (ดัชนี _tblCols) · null = ลำดับตั้งต้น (ESI แล้วเวลารอ) · asc = น้อยไปมาก
int? _tblSort;
bool _tblAsc = true;

/// หน้าของตาราง (เกิน 20 คนแบ่งหน้า หน้าละ 20)
int _tblPage = 0;
const int _tblPer = 20;

extension _TabsOverviewOverviewTabPart on _ErFlowHomeWidgetState {
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
      case _Stage.observe:
        return _mono ? _g5 : _blue3;
    }
  }

  // คำอธิบายสีเคยลอยบนฉาก · หน้าภาพรวมใช้กระดานแล้ว (ป้าย ESI บอกระดับในการ์ดเอง)
  Widget _legend() => const SizedBox.shrink();

  /// แผงซ้ายเมนู "ตัวชี้วัด": ตัวชี้วัดสำคัญวันนี้ 8 ตัว ชุดเดียวกับแดชบอร์ด ER (ไอคอนชุดเดียวกัน)
  /// ช่องละแถวเต็มกว้าง: ชื่อ · ค่าใหญ่ + หน่วย · บรรทัดบริบท | ภาพประกอบขวา
  /// ค่าที่เกินเป้า/เกณฑ์ = ป้ายแดงหลังชื่อ · รอรับบริการ/เวลารอ/เตียง คำนวณจากบอร์ด
  /// ที่เหลือโมเดลผู้ป่วยยังไม่มีข้อมูล ใช้ตัวเลขเดียวกับแดชบอร์ด (er_dashboard kpi_overview_section)
  /// ที่มาและสูตรของตัวชี้วัดทุกตัวในหน้าตัวชี้วัด (ปุ่ม i มุมขวาล่าง hero แบบหน้าภาพรวม)
  /// แผงซ้าย 8 ตัว + ข้อมูลเชิงลึก 5 หัวข้อ · แต่ละตัว: คำอธิบาย · สูตร + ตัวอย่างจากตัวเลขวันนี้ · เป้า/เกณฑ์ · ที่มาข้อมูล
  /// ข้อความ/สูตรแผงซ้ายชุดเดียวกับแดชบอร์ด ER (er_dashboard kpi_overview_section)
  Future<void> _kpiInfoAll() {
    final waiting = [
      for (final p in _patients)
        if (p.stage == _Stage.triage || p.stage == _Stage.waitDoctor) p
    ];
    final waitAvg = waiting.isEmpty
        ? 0
        : (waiting.fold<int>(0, (a, p) => a + p.waitMin) / waiting.length)
            .round();
    final waitTriage = waiting.where((p) => p.stage == _Stage.triage).length;
    final todayIn = _kpiTriage.reduce((a, b) => a + b);
    final bedsUsed = _patients.where((p) => p.bed != null).length;
    final bedPct =
        _roomBeds.isEmpty ? 0 : (bedsUsed * 100 / _roomBeds.length).round();
    const target = 280;
    final defs = <(String, String, String, String?, String?, String)>[
      (
        'ผู้ป่วยรอรับบริการ',
        'จำนวนผู้ป่วยที่ลงทะเบียนเข้า ER แล้ว แต่ยังไม่ได้รับการประเมินหรือรักษาครั้งแรก บอกภาระงานของทีมตอนนี้',
        'รอรับบริการ = รอคัดกรอง + รอตรวจ',
        '$waitTriage + ${waiting.length - waitTriage} = ${waiting.length} ราย',
        null,
        'บอร์ดผู้ป่วย ER ตอนนี้ (ผู้ป่วยสถานะรอคัดกรองและรอตรวจ)'
      ),
      (
        'เวลารอเฉลี่ย',
        'ค่าเฉลี่ยเวลาที่ผู้ป่วยรอ ตั้งแต่ลงทะเบียนจนได้รับการประเมินหรือรักษาครั้งแรก ครอบคลุมรอคัดกรอง รอแพทย์ รอผล Lab และรอเตียง',
        'เวลารอเฉลี่ย = Σ เวลารอของผู้ป่วยทุกราย ÷ จำนวนผู้ป่วย',
        waiting.isEmpty
            ? null
            : '(${[
                for (final p in waiting) p.waitMin
              ].join(' + ')}) ÷ ${waiting.length} = $waitAvg นาที',
        'ไม่เกิน 30 นาที',
        'เวลาลงทะเบียนของผู้ป่วยที่ยังรออยู่บนบอร์ด ER นับถึงตอนนี้'
      ),
      (
        'อัตราการใช้เตียง ER',
        'สัดส่วนเตียงที่มีผู้ป่วยอยู่ตอนนี้ เทียบกับจำนวนเตียงทั้งหมดของ ER',
        'Bed Occupancy = (จำนวนเตียงที่มีผู้ป่วย ÷ จำนวนเตียงทั้งหมด) × 100',
        '$bedsUsed ÷ ${_roomBeds.length} × 100 = $bedPct%',
        'ต่ำกว่า 90% (ตั้งแต่ 90% เป็นระดับวิกฤต แจ้งทีมสำรอง)',
        'ผังเตียง ER (เตียงที่มีผู้ป่วยตอนนี้)'
      ),
      (
        'ผู้ป่วยทั้งหมดวันนี้',
        'จำนวนผู้ป่วยทั้งหมดที่ลงทะเบียนเข้า ER ตั้งแต่ 00:00 น. ของวันนี้',
        'ผู้ป่วยวันนี้ = จำนวนผู้ลงทะเบียน ER ตั้งแต่ 00:00 น.',
        '${_kpiTriage.join(' + ')} = $todayIn ราย (แยกตาม ESI 1 ถึง 5)',
        'วันละ $target ราย',
        'ทะเบียนผู้ป่วย ER วันนี้'
      ),
      (
        'Door-to-Doctor',
        'ระยะเวลาตั้งแต่ผู้ป่วยเข้าประตู ER จนพบแพทย์ครั้งแรก ไม่รวมเวลารอผล Lab หรือการตรวจอื่น ๆ',
        'Door-to-Doctor = เวลาที่พบแพทย์ − เวลาเข้าประตู',
        'วันนี้เฉลี่ย 22 นาที เร็วขึ้น 5 นาทีจากเมื่อวาน (27 นาที)',
        null,
        'เวลาลงทะเบียน ER และเวลาที่แพทย์บันทึกตรวจครั้งแรก'
      ),
      (
        'อัตราการ Admit',
        'สัดส่วนผู้ป่วยที่แพทย์ตัดสินใจรับไว้นอนโรงพยาบาล เทียบกับผู้ป่วยทั้งหมดที่เข้า ER',
        'Admit Rate = (จำนวนผู้ถูก Admit ÷ จำนวนผู้ป่วย ER ทั้งหมด) × 100',
        '58 ÷ 312 × 100 = 18.6%',
        'เทียบเดือนก่อน 17.2% (ขีดบนวง)',
        'ผลการจำหน่ายผู้ป่วย ER วันนี้ (Admit)'
      ),
      (
        'ออกก่อนพบแพทย์ (LWBS)',
        'Left Without Being Seen คือผู้ป่วยที่ลงทะเบียนหรือผ่านการคัดกรองแล้ว แต่ออกจาก ER ก่อนพบแพทย์โดยไม่ได้รับการรักษา',
        'LWBS Rate = (จำนวนผู้ออกก่อนพบแพทย์ ÷ จำนวนผู้ลงทะเบียนทั้งหมด) × 100',
        '13 ÷ 312 × 100 = 4.2%',
        'ไม่เกิน 3% (ขีดบนหน้าปัด)',
        'สถานะจำหน่ายออกก่อนพบแพทย์ในทะเบียน ER วันนี้'
      ),
      (
        'ผู้ป่วยเสียชีวิต',
        'จำนวนผู้ป่วยที่เสียชีวิตใน ER วันนี้ เทียบกับค่าเฉลี่ยต่อวันจากข้อมูลย้อนหลัง 30 วัน',
        'นับผู้ป่วยที่จำหน่ายด้วยสถานะเสียชีวิตใน ER ตั้งแต่ 00:00 น.',
        'วันนี้ 2 ราย ค่าเฉลี่ย 30 วัน 1.8 ราย/วัน',
        null,
        'สถานะจำหน่ายเสียชีวิตในทะเบียน ER (วันนี้และย้อนหลัง 30 วัน)'
      ),
    ];
    final losTotal = _kpiLos.fold<int>(0, (a, e) => a + e.$2);
    final insights = <(String, String, String, String?, String?, String)>[
      (
        'กระแสผู้ป่วยรายชั่วโมง',
        'จำนวนผู้ป่วยเข้า ออก และรับเข้านอน ในแต่ละชั่วโมงของวันนี้',
        'ต่อชั่วโมง: เข้า = ผู้ลงทะเบียน ออก = ผู้จำหน่าย รับเข้านอน = ผู้ถูก Admit',
        'เข้าทั้งวัน ${_kpiFlowIn.reduce((a, b) => a + b)} ราย ออก ${_kpiFlowOut.reduce((a, b) => a + b)} ราย รับเข้านอน ${_kpiFlowAdmit.reduce((a, b) => a + b)} ราย',
        null,
        'เวลาลงทะเบียน เวลาจำหน่าย และคำสั่ง Admit ในทะเบียน ER วันนี้'
      ),
      (
        'อาการที่พามา',
        'อาการสำคัญที่พาผู้ป่วยมา ER บ่อยที่สุดเดือนนี้ และสัดส่วนที่ต้องนอนโรงพยาบาล',
        'Admit % ของอาการ = (ผู้ถูก Admit ในอาการนั้น ÷ ผู้ป่วยอาการนั้น) × 100',
        '${_kpiCc.first.$1} ${_kpiCc.first.$2} ราย Admit ${_kpiCc.first.$3}%',
        null,
        'อาการสำคัญ (CC) ที่บันทึกตอนคัดกรอง และผลการจำหน่าย เดือนนี้'
      ),
      (
        'ระดับความเร่งด่วน',
        'สัดส่วนผู้ป่วยวันนี้ในแต่ละระดับ ESI',
        'สัดส่วนระดับ = (ผู้ป่วยระดับนั้น ÷ ผู้ป่วยทั้งหมดวันนี้) × 100',
        'ESI 3: ${_kpiTriage[2]} ÷ $todayIn × 100 = ${(_kpiTriage[2] * 100 / todayIn).toStringAsFixed(1)}%',
        null,
        'ระดับ ESI ที่พยาบาลคัดกรองบันทึก วันนี้'
      ),
      (
        'ระยะเวลาแต่ละขั้นตอน',
        'เวลาเฉลี่ยที่ผู้ป่วยใช้ในแต่ละขั้น ตั้งแต่ลงทะเบียนจนจำหน่าย ขั้นที่นานที่สุดคือคอขวด',
        'เวลาเฉลี่ยของขั้น = Σ (เวลาจบขั้น − เวลาเริ่มขั้น) ÷ จำนวนผู้ป่วย',
        '${_kpiLos.map((e) => e.$2).join(' + ')} = $losTotal นาที (${losTotal ~/ 60} ชม. ${losTotal % 60} นาที)',
        null,
        'เวลาบันทึกสถานะแต่ละขั้นของผู้ป่วย ER วันนี้'
      ),
      (
        'ผลลัพธ์ของผู้ป่วย',
        'ผู้ป่วยที่จำหน่ายวันนี้ไปทางไหนบ้าง',
        'สัดส่วนผลลัพธ์ = (ผู้ป่วยผลลัพธ์นั้น ÷ ผู้ป่วยที่จำหน่ายวันนี้) × 100',
        _kpiDispo.map((e) => '${e.$1} ${e.$2.round()}%').join('  '),
        null,
        'ผลการจำหน่ายผู้ป่วย ER วันนี้'
      ),
    ];
    // อ่านง่าย: รายชื่อซ้าย (เลือกทีละตัว) · ขวาแสดงตัวเดียว สูตรตัวใหญ่ ผลลัพธ์เด่น เป้า/ที่มาแยกกล่อง
    final all = [
      for (final d in defs) ('ตัวชี้วัดวันนี้', d),
      for (final d in insights) ('ข้อมูลเชิงลึก', d),
    ];
    var sel = 0;
    Widget infoBox(IconData ic, String label, String text) => Container(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(ic, size: 16.0, color: _blue),
              const SizedBox(width: 6.0),
              Text(label,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4.0),
            Text(text,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ]),
        );
    // preview แบบมี story: เห็นทั้งจอก่อน (แผงซ้ายทั้ง 8 ช่อง / การ์ดข้อมูลเชิงลึกทั้ง 5 บท)
    // แล้วกล้องซูมเข้าไปโฟกัสช่อง/การ์ดของตัวที่เลือก ตัวอื่นจางลง กรอบเน้นค่อย ๆ ขึ้น
    // ค้างภาพรวม ~0.5 วิ (ภาพในช่องเล่น) แล้วซูม (สเกลแบบ log ให้ความเร็วซูมคงที่)
    Widget preview(int i) {
      final tiles = i < 8;
      late final Size stage;
      late final List<Rect> rects;
      late final List<Widget> kids;
      if (tiles) {
        if (_kpiTilesPreview.length < 8) return const SizedBox.shrink();
        // ผังเดียวกับแผงซ้าย: เต็มกว้าง / คู่ / เต็มกว้าง / คู่ / คู่
        const w = 270.0, hw = 131.0, g = 8.0;
        // เต็มกว้างสูง 100 เท่าวิดเจ็ตหน้าภาพรวม (96 ทำให้ช่องผู้ป่วยวันนี้ล้น 1 px)
        rects = const [
          Rect.fromLTWH(0.0, 0.0, w, 100.0),
          Rect.fromLTWH(0.0, 108.0, hw, 140.0),
          Rect.fromLTWH(hw + g, 108.0, hw, 140.0),
          Rect.fromLTWH(0.0, 256.0, w, 100.0),
          Rect.fromLTWH(0.0, 364.0, hw, 130.0),
          Rect.fromLTWH(hw + g, 364.0, hw, 130.0),
          Rect.fromLTWH(0.0, 502.0, hw, 130.0),
          Rect.fromLTWH(hw + g, 502.0, hw, 130.0),
        ];
        stage = const Size(w, 632.0);
        kids = _kpiTilesPreview;
      } else {
        if (_kpiChPreview.any((b) => b == null)) {
          return const SizedBox.shrink();
        }
        const w = 552.0, h = 340.0, g = 12.0;
        rects = [
          for (var k = 0; k < 5; k++) Rect.fromLTWH(0.0, k * (h + g), w, h)
        ];
        stage = const Size(w, 5 * h + 4 * g);
        kids = [
          for (final b in _kpiChPreview)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: _clyCardDeco,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: 0.0,
                  maxHeight: double.infinity,
                  child: b!(true),
                ),
              ),
            ),
        ];
      }
      final sel = tiles ? i : i - 8;
      final bh = tiles ? 240.0 : 300.0;
      return LayoutBuilder(builder: (context, box) {
        final bw = box.maxWidth;
        final r = rects[sel];
        final s0 = math.min(bw * 0.9 / stage.width, bh * 0.9 / stage.height);
        final s1 = math.min(bw * 0.84 / r.width, bh * 0.84 / r.height);
        final c0 = Offset(stage.width / 2, stage.height / 2);
        return Container(
          height: bh,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tiles ? _lpBg : _bg,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              key: ValueKey('kpi-focus-$i'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1800),
              builder: (context, v, _) {
                final t = Curves.easeInOutCubic
                    .transform(((v - 0.3) / 0.7).clamp(0.0, 1.0));
                final sc =
                    math.exp(math.log(s0) + (math.log(s1) - math.log(s0)) * t);
                final c = Offset.lerp(c0, r.center, t)!;
                final o = Offset(bw / 2, bh / 2) - c * sc;
                return Stack(clipBehavior: Clip.hardEdge, children: [
                  Positioned(
                    left: 0.0,
                    top: 0.0,
                    width: stage.width,
                    height: stage.height,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(o.dx, o.dy, 0.0, 1.0)
                        ..scaleByDouble(sc, sc, 1.0, 1.0),
                      child: Stack(clipBehavior: Clip.none, children: [
                        for (var k = 0; k < kids.length; k++)
                          Positioned.fromRect(
                            rect: rects[k],
                            child: k == sel
                                ? DecoratedBox(
                                    position: DecorationPosition.foreground,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          tiles ? 12.0 : 16.0),
                                      border: Border.all(
                                          color: (tiles ? Colors.white : _blue)
                                              .withValues(alpha: 0.9 * t),
                                          width: 2.0 / sc),
                                    ),
                                    child: kids[k],
                                  )
                                : Opacity(
                                    opacity: 1.0 - 0.75 * t, child: kids[k]),
                          ),
                      ]),
                    ),
                  ),
                ]);
              },
            ),
          ),
        );
      });
    }

    Widget detail(
        int idx, (String, String, String, String?, String?, String) d) {
      final (title, desc, formula, example, target, source) = d;
      final fi = formula.indexOf(' = ');
      // ผลลัพธ์ = ส่วนหลัง " = " ตัวสุดท้ายของตัวอย่าง (เด่นตัวใหญ่) · ไม่มีเครื่องหมาย = ทั้งบรรทัดเป็นค่า
      final ei = example?.lastIndexOf(' = ') ?? -1;
      return SingleChildScrollView(
        key: ValueKey(title),
        padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 24.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title,
              style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 12.0),
          preview(idx),
          const SizedBox(height: 14.0),
          Text(desc,
              style:
                  _t(14.0, color: _ink2, weight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: 18.0),
          Text('สูตรการคำนวณ',
              style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EAF8),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text.rich(
                fi < 0
                    ? TextSpan(text: formula)
                    : TextSpan(children: [
                        TextSpan(
                            text: formula.substring(0, fi),
                            style: const TextStyle(color: _blue)),
                        TextSpan(text: '  =  ', style: TextStyle(color: _ink3)),
                        TextSpan(text: formula.substring(fi + 3)),
                      ]),
                style: _t(16.0,
                    color: _inkTitle, weight: FontWeight.w600, height: 1.45)),
          ),
          if (example != null) ...[
            const SizedBox(height: 18.0),
            Text('ตัวอย่างจากวันนี้',
                style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
            const SizedBox(height: 6.0),
            if (ei < 0)
              Text(example,
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w600))
            else
              Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    Text('${example.substring(0, ei)}  =',
                        style: _num(
                          14.0,
                          color: _ink2,
                          weight: FontWeight.w500,
                        )),
                    Text(example.substring(ei + 3),
                        style:
                            _num(22.0, color: _blue, weight: FontWeight.w700)),
                  ]),
          ],
          const SizedBox(height: 18.0),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (target != null) ...[
              Expanded(child: infoBox(Icons.flag_rounded, 'เป้าหมาย', target)),
              const SizedBox(width: 10.0),
            ],
            Expanded(
                child: infoBox(Icons.storage_rounded, 'ที่มาข้อมูล', source)),
          ]),
        ]),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: SizedBox(
          width: 820.0,
          height: math.min(600.0, MediaQuery.sizeOf(ctx).height * 0.86),
          child: StatefulBuilder(
            builder: (ctx, setD) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 10.0, 10.0),
                    child: Row(children: [
                      const _McGIcon(Icons.info_rounded,
                          size: 36.0, navy: true),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text('ที่มาและสูตรตัวชี้วัด',
                            style: _t(17.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: 'ปิด',
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded,
                            size: 22.0, color: _ink2),
                      ),
                    ]),
                  ),
                  const Divider(height: 1.0, thickness: 1.0, color: _line),
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // รายชื่อ: แตะเลือก · ที่เลือก = pill ฟ้าอ่อน ตัวกรมท่าหนา (Google style)
                          SizedBox(
                            width: 230.0,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 10.0, 10.0, 16.0),
                              children: [
                                for (final (i, (g, d)) in all.indexed) ...[
                                  if (i == 0 || all[i - 1].$1 != g)
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, i == 0 ? 2.0 : 14.0, 10.0, 6.0),
                                      child: Text(g,
                                          style: _t(11.5,
                                              color: _ink3,
                                              weight: FontWeight.w700)),
                                    ),
                                  _Press(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setD(() => sel = i);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 9.0),
                                        decoration: BoxDecoration(
                                          color: i == sel
                                              ? const Color(0xFFE2EAF8)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        child: Text(d.$1,
                                            style: _t(13.5,
                                                color: i == sel ? _blue : _ink2,
                                                weight: i == sel
                                                    ? FontWeight.w700
                                                    : FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const VerticalDivider(
                              width: 1.0, thickness: 1.0, color: _line),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOutCubic,
                                transitionBuilder: (c, a) => FadeTransition(
                                    opacity: a,
                                    child: SlideTransition(
                                        position: Tween(
                                                begin: const Offset(0.0, 0.04),
                                                end: Offset.zero)
                                            .animate(a),
                                        child: c)),
                                layoutBuilder: (cur, prev) => Stack(
                                    alignment: Alignment.topLeft,
                                    children: [...prev, if (cur != null) cur]),
                                child: detail(sel, all[sel].$2),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  /// ช่องตัวชี้วัดทั้ง 8 (id → การ์ด) ใช้ร่วมกัน: แผงตัวชี้วัด + วิดเจ็ตที่ผู้ใช้เลือกในแผงภาพรวม ([_ovWidgetAll])
  Map<String, Widget> _kpiTiles() {
    // ตัวชี้วัดวันนี้ (ชุดเดียวกับแดชบอร์ด ER): รอรับบริการ/เวลารอ นับจากรายชื่อในบอร์ด
    // ที่เหลือโมเดลผู้ป่วยยังไม่มีข้อมูล ใช้ตัวเลขเดียวกับแดชบอร์ด (er_dashboard kpi_overview_section)
    final waiting = [
      for (final p in _patients)
        if (p.stage == _Stage.triage || p.stage == _Stage.waitDoctor) p
    ];
    final waitAvg = waiting.isEmpty
        ? 0
        : (waiting.fold<int>(0, (a, p) => a + p.waitMin) / waiting.length)
            .round();
    final waitTriage = waiting.where((p) => p.stage == _Stage.triage).length;
    // ผู้ป่วยทั้งหมดวันนี้ = ยอดเดียวกับการ์ดแยกตามระดับความเร่งด่วนทางขวา
    final todayIn = _kpiTriage.reduce((a, b) => a + b);
    final bedsUsed = _patients.where((p) => p.bed != null).length;
    final bedPct =
        _roomBeds.isEmpty ? 0 : (bedsUsed * 100 / _roomBeds.length).round();
    // แผงตัวชี้วัดแบบ bento: แต่ละตัวมีภาพแทนความหมายของตัวเลข (ไม่ใช่ไอคอนประดับ)
    // ตอนนี้ = คิวรอ (คนเป็นตัว ๆ) · เวลารอ (หน้าปัดเทียบเป้า) · เตียง (เตียงเป็นช่อง)
    // วันนี้ = ยอดรวม (แถบเทียบเป้า) · Door-to-Doctor (เส้นเวลาเร็วขึ้น) · Admit (วงสัดส่วน) · LWBS (หน้าปัดเทียบเกณฑ์) · เสียชีวิต (เทียบค่าเฉลี่ย)
    // การ์ดขาวบนแผงกรมท่า: ภาพกรมท่า = ปกติ · แดงเฉพาะส่วนที่เกินเป้า/เกณฑ์ · ทุกตัวเลขมีหน่วย · พอดีความสูงแผง (flex)
    // ข้อความน้อย: ชื่อสั้น ไม่มีบรรทัดหมายเหตุ ภาพบอกเป้า/เกณฑ์เอง (ขีดบนหน้าปัด แถบ แท่งเทียบ)
    final over = _red;
    const track = Color(0xFFE6EAF2);
    Widget tag(String s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
          decoration: BoxDecoration(
              color: _red, borderRadius: BorderRadius.circular(100.0)),
          child: Text(s,
              style: _t(10.0, color: Colors.white, weight: FontWeight.w700)),
        );
    Widget head(String label, {String? alert}) => Row(children: [
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
          ),
          if (alert != null) ...[const SizedBox(width: 6.0), tag(alert)],
        ]);
    Widget val(String v, String u, {double size = 24.0}) => Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(v,
                  style: _num(size, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 3.0),
              Text(u, style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
            ]);
    // การ์ดขาว (แบบการ์ดฟีดหน้าภาพรวม) · เกินเป้า/เกณฑ์ ([alert]) = แดงอ่อนฟุ้งจากขอบล่าง + ป้ายอยู่ล่าง
    // gradient ทึบ (ไม่ใช้ blur) ขอบนอกเป็นขาว ไม่ใส่ color คู่ gradient
    Widget card(Widget child, {String? alert}) => Stack(children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  12.0, 10.0, 12.0, alert == null ? 10.0 : 30.0),
              decoration: BoxDecoration(
                color: alert == null ? _panel : null,
                borderRadius: BorderRadius.circular(12.0),
                gradient: alert == null
                    ? null
                    // แสงอยู่แค่แถบล่างรอบป้าย (ไม่ขึ้นไปหลังภาพ ส่วนแดงของภาพไม่จมพื้น)
                    : RadialGradient(
                        center: const Alignment(0.0, 1.55),
                        radius: 0.78,
                        colors: [
                          Color.lerp(_panel, _red, 0.3)!,
                          Color.lerp(_panel, _red, 0.08)!,
                          _panel,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
              ),
              child: child,
            ),
          ),
          if (alert != null)
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 8.0,
              child: Center(child: tag(alert)),
            ),
        ]);
    Widget Function(Widget) hot(String? alert) => (c) => card(c, alert: alert);
    // ภาพเล่นครั้งเดียวตอนเปิดแผง
    Widget grow(Widget Function(double k) b) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, k, _) => b(k),
        );

    // ---- คิวรอ: คนเป็นตัว ๆ แยก 2 กลุ่มมีป้ายกำกับ (รอคัดกรอง = กรมท่าจาง · รอตรวจ = กรมท่า)
    final waitDoc = waiting.length - waitTriage;
    final queue = card(Row(children: [
      Expanded(
        flex: 4,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              head('รอรับบริการ'),
              const SizedBox(height: 4.0),
              val('${waiting.length}', 'ราย', size: 28.0),
            ]),
      ),
      const SizedBox(width: 10.0),
      Expanded(
        flex: 6,
        child: grow((k) => LayoutBuilder(builder: (context, b) {
              final most = math.max(1, math.max(waitTriage, waitDoc));
              final s = math.min(16.0, b.maxWidth / most);
              Widget group(String label, int n, Color c, double from) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$label $n ราย',
                            style: _t(10.5,
                                color: _ink2, weight: FontWeight.w600)),
                        const SizedBox(height: 1.0),
                        Row(children: [
                          for (var i = 0; i < n; i++)
                            Opacity(
                              opacity:
                                  ((k * 1.6 - from) * most - i).clamp(0.0, 1.0),
                              child:
                                  Icon(Icons.person_rounded, size: s, color: c),
                            ),
                        ]),
                      ]);
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    group('รอคัดกรอง', waitTriage,
                        _blue.withValues(alpha: 0.35), 0.0),
                    const SizedBox(height: 4.0),
                    group('รอตรวจ', waitDoc, _blue, 0.3),
                  ]);
            })),
      ),
    ]));

    // ---- ช่องตัวชี้วัด: อ่านแบบเดียวกันทุกช่อง = ตัวเลขใหญ่ + แถบเทียบ (bullet)
    // แถบเติมกรมท่าถึงค่า · ขีดเข้ม = ค่าที่เทียบ (เป้า เกณฑ์ เมื่อวาน เดือนก่อน ค่าเฉลี่ย) มีป้ายใต้ขีด
    // [worse] = ค่าเกินขีดแล้วแย่ (เป้า/เกณฑ์): ส่วนที่เกินเป็นแดง · ขีดอ้างอิงอื่น (เมื่อวาน ฯลฯ) ไม่ระบายแดง
    Widget bulletTile(
            {required String title,
            required String value,
            required String unit,
            String? extra,
            required double v,
            required double mark,
            required double max,
            required String markLabel,
            bool worse = false,
            String? alert}) =>
        hot(alert)(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head(title),
          const SizedBox(height: 2.0),
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                val(value, unit),
                if (extra != null) ...[
                  const SizedBox(width: 6.0),
                  Flexible(
                    child: Text(extra,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
                  ),
                ],
              ]),
          const Spacer(),
          grow((k) => SizedBox(
                height: 30.0,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _KpiBullet(
                      v: v / max * k,
                      mark: mark / max,
                      worse: worse,
                      label: markLabel,
                      track: track,
                      on: _blue,
                      over: over,
                      style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
                ),
              )),
        ]));

    final waitTile = bulletTile(
        title: 'เวลารอ',
        value: '$waitAvg',
        unit: 'นาที',
        v: waitAvg.toDouble(),
        mark: 30.0,
        max: 60.0,
        markLabel: 'เป้า 30 นาที',
        worse: true,
        alert: waitAvg > 30 ? 'เกินเป้า' : null);
    final bedHot = bedPct >= 90;
    final bedTile = bulletTile(
        title: 'เตียง ER',
        value: '$bedPct',
        unit: '%',
        extra: '$bedsUsed/${_roomBeds.length} เตียง',
        v: bedPct.toDouble(),
        mark: 90.0,
        max: 100.0,
        markLabel: 'วิกฤต 90%',
        worse: true,
        alert: bedHot ? 'วิกฤต' : null);
    const target = 280;
    final totalTile = bulletTile(
        title: 'ผู้ป่วยวันนี้',
        value: '$todayIn',
        unit: 'ราย',
        v: todayIn.toDouble(),
        mark: target.toDouble(),
        max: 360.0,
        markLabel: 'เป้า $target ราย');
    final d2dTile = bulletTile(
        title: 'Door-to-Doctor',
        value: '22',
        unit: 'นาที',
        v: 22.0,
        mark: 27.0,
        max: 40.0,
        markLabel: 'เมื่อวาน 27 นาที');
    final admitTile = bulletTile(
        title: 'Admit',
        value: '18.6',
        unit: '%',
        v: 18.6,
        mark: 17.2,
        max: 30.0,
        markLabel: 'เดือนก่อน 17.2%');
    final lwbsTile = bulletTile(
        title: 'LWBS',
        value: '4.2',
        unit: '%',
        v: 4.2,
        mark: 3.0,
        max: 6.0,
        markLabel: 'เกณฑ์ 3%',
        worse: true,
        alert: 'เกินเกณฑ์');
    final deathTile = bulletTile(
        title: 'เสียชีวิต',
        value: '2',
        unit: 'ราย',
        v: 2.0,
        mark: 1.8,
        max: 4.0,
        markLabel: 'เฉลี่ย 1.8 ราย');

    _kpiTilesPreview = [
      queue,
      waitTile,
      bedTile,
      totalTile,
      d2dTile,
      admitTile,
      lwbsTile,
      deathTile
    ];
    return {
      'queue': queue,
      'wait': waitTile,
      'bed': bedTile,
      'total': totalTile,
      'd2d': d2dTile,
      'admit': admitTile,
      'lwbs': lwbsTile,
      'death': deathTile,
    };
  }

  Widget _kpiPanel() {
    final m = _kpiTiles();
    final queue = m['queue']!,
        waitTile = m['wait']!,
        bedTile = m['bed']!,
        totalTile = m['total']!,
        d2dTile = m['d2d']!,
        admitTile = m['admit']!,
        lwbsTile = m['lwbs']!,
        deathTile = m['death']!;
    Widget pair(Widget a, Widget b) =>
        Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: a),
          const SizedBox(width: 8.0),
          Expanded(child: b)
        ]);
    const gap = SizedBox(height: 8.0);
    return Padding(
      key: const ValueKey('kpi-panel'),
      padding: const EdgeInsets.fromLTRB(20.0, 18.0, 0.0, 14.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ตัวชี้วัด',
                  style: _t(19.0, color: _lpInk, weight: FontWeight.w700)),
              Text('ตัวชี้วัดสำคัญของห้องฉุกเฉินวันนี้',
                  style: _t(10.5, color: _lpInk3)),
            ]),
          ),
          _collapseButton(),
        ]),
        const SizedBox(height: 12.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 22, child: _Appear(index: 0, child: queue)),
                  gap,
                  Expanded(
                      flex: 30,
                      child: _Appear(index: 1, child: pair(waitTile, bedTile))),
                  gap,
                  Expanded(
                      flex: 22, child: _Appear(index: 2, child: totalTile)),
                  gap,
                  Expanded(
                      flex: 26,
                      child:
                          _Appear(index: 3, child: pair(d2dTile, admitTile))),
                  gap,
                  Expanded(
                      flex: 28,
                      child:
                          _Appear(index: 4, child: pair(lwbsTile, deathTile))),
                ]),
          ),
        ),
      ]),
    );
  }

  /// ขวาของเมนูตัวชี้วัด: ข้อมูลเชิงลึกวันนี้ เล่าเป็น "เส้นทางผู้ป่วยวันนี้"
  /// หัว = ยอดวันนี้ + ประโยคสรุป + แผนที่เส้นทาง 5 จุด (ฉากในวงชุดเดียวกับ hero หน้าภาพรวม แตะ = ไปบทนั้น)
  /// บท: มาถึง → อาการที่พามา → คัดกรอง → ตรวจรักษา → ผลลัพธ์ · แต่ละบทเปิดด้วยประโยค insight
  /// (คำนวณจากชุดข้อมูล ไม่แต่งเพิ่ม) + คำอธิบายคงที่ · ฉากโผล่จากหลังการ์ด (ภาษาเดียวกับหัวหมวด ESI)
  /// สีเน้น: กรมท่า = ตัวเลขสำคัญ · แดงเฉพาะคอขวด · สี ESI เฉพาะแท่งระดับ
  /// legend กราฟเข้าออกรายชั่วโมง (เส้น + ชื่อ + ยอดทั้งวัน + หน่วย) ใช้ร่วม: บท 1 หน้าตัวชี้วัด + วิดเจ็ตหน้าภาพรวม
  Widget _kpiFlowLegend({double fs = 12.5, double gap = 16.0}) {
    int sum(List<int> l) => l.fold(0, (a, b) => a + b);
    Widget item(Color c, String label, int total, {bool dash = false}) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 18.0,
            height: 10.0,
            child: CustomPaint(painter: _KpiLegendLine(c, dash)),
          ),
          const SizedBox(width: 6.0),
          Text(label, style: _t(fs, color: _ink2, weight: FontWeight.w500)),
          const SizedBox(width: 4.0),
          Text('$total',
              style: _num(fs + 0.5, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(width: 3.0),
          Text('ราย',
              style: _t(fs - 1.0, color: _ink3, weight: FontWeight.w500)),
        ]);
    return Wrap(spacing: gap, runSpacing: 6.0, children: [
      item(_kpiTones[0], 'เข้า', sum(_kpiFlowIn)),
      item(_kpiTones[3], 'ออก', sum(_kpiFlowOut)),
      item(_ink3, 'รับเข้านอน', sum(_kpiFlowAdmit), dash: true),
    ]);
  }

  /// กราฟเข้าออกรายชั่วโมงแบบแตะ/ลากได้ (ชุดเดียวกับหน้าตัวชี้วัด) · ใช้ทั้งบท 1 และวิดเจ็ตหน้าภาพรวม
  Widget _kpiFlowLive({bool peak = true}) =>
      LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        // ป้ายแสดงเฉพาะตอนนิ้วอยู่บนกราฟ: กด/ลาก = แสดงชั่วโมงใต้นิ้ว · ยกนิ้ว = ป้ายจางหายตรงจุดเดิม
        void pressAt(double dx) {
          final i = _KpiFlowChart.hit(dx, w);
          if (i != _kpiFlowSel) HapticFeedback.selectionClick();
          setState(() {
            _kpiFlowSel = i;
            _kpiFlowLast = i;
          });
        }

        void release() {
          final fx = _kpiFlowDrag.value;
          setState(() {
            if (fx != null) _kpiFlowLast = fx.round();
            _kpiFlowSel = null;
          });
          _kpiFlowDrag.value = null;
        }

        void dragStart(double dx) {
          _kpiFlowDrag.value = _KpiFlowChart.hitF(dx, w);
          pressAt(dx);
        }

        void dragTo(double dx) {
          final fx = _KpiFlowChart.hitF(dx, w);
          final prev = _kpiFlowDrag.value;
          if (prev != null && prev.round() != fx.round()) {
            HapticFeedback.selectionClick();
          }
          _kpiFlowDrag.value = fx;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => pressAt(d.localPosition.dx),
          onTapUp: (_) => release(),
          onTapCancel: () {
            if (_kpiFlowDrag.value == null) release();
          },
          onHorizontalDragStart: (d) => dragStart(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => dragTo(d.localPosition.dx),
          onHorizontalDragEnd: (_) => release(),
          onHorizontalDragCancel: release,
          // ป้าย focus: เลื่อนไหลระหว่างชั่วโมง (ตำแหน่ง) + ขยายเด้ง/จางเข้าออก (การมองเห็น)
          child: ValueListenableBuilder<double?>(
            valueListenable: _kpiFlowDrag,
            builder: (context, drag, _) => TweenAnimationBuilder<double>(
              tween:
                  Tween(end: drag ?? (_kpiFlowSel ?? _kpiFlowLast).toDouble()),
              duration: Duration(milliseconds: drag != null ? 70 : 320),
              curve: drag != null ? Curves.linear : Curves.easeOutBack,
              builder: (context, pf, _) => TweenAnimationBuilder<double>(
                tween: Tween(end: _kpiFlowSel == null ? 0.0 : 1.0),
                duration:
                    Duration(milliseconds: _kpiFlowSel == null ? 180 : 360),
                curve: _kpiFlowSel == null ? Curves.easeIn : Curves.easeOutBack,
                builder: (context, ta, _) => CustomPaint(
                  size: Size.infinite,
                  painter: _KpiFlowChart(
                      t: _t,
                      num: _num,
                      peak: peak,
                      sel: _kpiFlowSel,
                      pickF: pf,
                      tipA: ta),
                ),
              ),
            ),
          ),
        );
      });

  Widget _kpiBoard() {
    // ---- ตัวเลขที่ใช้เล่าเรื่อง
    final tTotal = _kpiTriage.reduce((a, b) => a + b);
    int sum(List<int> l) => l.reduce((a, b) => a + b);
    final peak = _kpiFlowIn.reduce(math.max);
    final peakAt = _clock(
        '${_kpiFlowHours[_kpiFlowIn.indexOf(peak)].toString().padLeft(2, '0')}:00');
    final esiMax = _kpiTriage.reduce(math.max);
    final esiTop = _kpiTriage.indexOf(esiMax);
    final esiPct = (esiMax * 100 / tTotal).round();
    final losTotal = _kpiLos.fold<int>(0, (a, e) => a + e.$2);
    final losMax = _kpiLos.map((x) => x.$2).reduce(math.max);
    final bott = _kpiLos.indexWhere((e) => e.$2 == losMax);
    final losText = '${losTotal ~/ 60} ชม. ${losTotal % 60} นาที';
    final ccMax = _kpiCc.map((e) => e.$2).reduce(math.max);
    final home = _kpiDispo.first;

    TextStyle hi([Color c = _blue]) => TextStyle(color: c);
    // ป้ายแนวโน้ม (แบบไทล์แล็บ): เทา · แดงเฉพาะเรื่องที่ต้องแก้
    Widget chip(String text, {IconData? icon, bool alert = false}) {
      final c = alert ? _red : _ink2;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14.0, color: c),
            const SizedBox(width: 3.0),
          ],
          Text(text, style: _t(11.0, color: c, weight: FontWeight.w600)),
        ]),
      );
    }

    const rowLine = Border(top: BorderSide(color: _line, width: 1.0));

    // แตะจุดบนแผนที่เส้นทาง = เลื่อนไปบทนั้น (context ของบทจากรอบ build นี้)
    final chCtx = List<BuildContext?>.filled(5, null);
    void goCh(int i) {
      final c = chCtx[i];
      if (c == null || !c.mounted) return;
      HapticFeedback.selectionClick();
      Scrollable.ensureVisible(c,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic);
    }

    // ---- บท: หมุดเลขบทบนราง + เส้นต่อบทถัดไป · หัว (ชื่อบท insight คำอธิบาย)
    // ภาพตัวละคร (ตัดพื้นหลัง) ยืนหลังการ์ด โผล่พ้นขอบบน ส่วนล่างถูกการ์ดบัง (แบบหัวหมวด ESI หน้าภาพรวม)
    // fig = (ภาพ, สูง, สัดส่วนกว้าง/สูงของไฟล์, ช่วงที่แสดงซ้าย–ขวา 0–1, ส่วนที่จมหลังการ์ด)
    // ขนาดใกล้กันทุกบท: ส่วนคนที่โผล่เหนือการ์ดสูง ~60–74 · ภาพครึ่งตัว (ระยะใกล้) หัวไม่เกิน ~22
    // ครอปได้เฉพาะตรงที่รอยตัดตกอยู่หลังการ์ด (เฟอร์นิเจอร์ช่วงล่าง) · ห้ามรอยตัดตรงลอยเหนือการ์ด
    // body(seen): seen = บทเลื่อนเข้ามาในจอแล้ว (เริ่มเล่นกราฟ/คลี่สายตอนนั้น ไม่เล่นทิ้งไว้นอกจอ)
    Widget chapter(int i, String label, _KpiFig fig, List<InlineSpan> headline,
        String desc, Widget Function(bool seen) body) {
      final last = i == 4;
      _kpiChPreview[i] = body;
      final (art, fh, ar, cl, cr, sink) = fig;
      final full = fh * ar, fw = full * (cr - cl);
      // จัดภาพเต็มให้ช่วง [cl, cr] ตรงช่องที่แสดง
      final ax = fw >= full ? -1.0 : 2.0 * cl * full / (full - fw) - 1.0;
      return Builder(builder: (context) {
        chCtx[i] = context;
        return Stack(clipBehavior: Clip.none, children: [
          if (!last)
            Positioned(
              left: 13.0,
              top: 34.0,
              bottom: 4.0,
              child: Container(
                width: 2.0,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 44.0, bottom: last ? 0.0 : 28.0),
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                right: 28.0,
                // ขอบบนการ์ด ~80 จากหัวบท
                top: 80.0 + sink - fh,
                width: fw,
                height: fh,
                child: IgnorePointer(
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment(ax, 0.0),
                      minWidth: full,
                      maxWidth: full,
                      child: Image.asset(art,
                          fit: BoxFit.fitHeight,
                          height: fh,
                          filterQuality: FilterQuality.medium),
                    ),
                  ),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: math.max(150.0, fw + 40.0), top: 2.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: _t(12.5,
                                color: _blue, weight: FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text.rich(TextSpan(children: headline),
                            style: _t(19.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text(desc, style: _t(12.0, color: _ink3)),
                      ]),
                ),
                const SizedBox(height: 14.0),
                _KpiInView(
                  builder: (context, seen) => Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: _clyCardDeco,
                    child: body(seen),
                  ),
                ),
              ]),
            ]),
          ),
          Positioned(
            left: 0.0,
            top: 2.0,
            child: Container(
              width: 28.0,
              height: 28.0,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: _blue, shape: BoxShape.circle),
              child: Text('${i + 1}',
                  style:
                      _num(13.0, color: Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ]);
      });
    }

    // ---- หัว: hero วนแบบหน้าภาพรวมทุกอย่าง (_OvCycle · พื้นย้อมสี _ovHeroBackdrop · วง 232 _ErStarFrame
    // + วงแหวน ESI _EsiDonutPainter · ฉากในวง + ตัวละครโผล่พ้นวง · ตัวเลข 64 · ตัวบอกรอบ · ปุ่มย้อน/ถัดไป)
    // หน้า: ผู้ป่วยวันนี้ → มาถึง → อาการที่พามา → คัดกรอง → ตรวจรักษา → ผลลัพธ์ · แตะหัวข้อ = ไปบทนั้น
    final esi3 = _Esi.values[esiTop];
    final slides = <({
      String label,
      _KpiSc sc,
      List<(String, String)> big,
      String? line2,
      List<InlineSpan> line,
      Color tint,
      Color numC,
      int? sel,
      int ch,
      bool bar,
    })>[
      (
        label: 'ผู้ป่วยวันนี้',
        sc: _kpiScLobby,
        big: [('$tTotal', 'ราย')],
        line2: null,
        line: [
          const TextSpan(text: 'เพิ่มขึ้น 4.2% จากเมื่อวาน มามากที่สุดช่วง '),
          TextSpan(text: peakAt),
        ],
        tint: _blue,
        numC: _blue,
        sel: null,
        ch: 0,
        bar: true,
      ),
      (
        label: 'มาถึง',
        sc: _kpiScArrive,
        big: [('$peak', 'ราย')],
        line2: 'ช่วง $peakAt',
        line: [
          TextSpan(
              text:
                  'ช่วงที่มามากที่สุดของวัน วันนี้เข้า ${sum(_kpiFlowIn)} ราย ออก ${sum(_kpiFlowOut)} ราย'),
        ],
        tint: _blue,
        numC: _blue,
        sel: null,
        ch: 0,
        bar: false,
      ),
      (
        label: 'อาการที่พามา',
        sc: _kpiScCounter,
        big: [('${_kpiCc.first.$2}', 'ราย')],
        line2: _kpiCc.first.$1,
        line: [
          TextSpan(
              text:
                  'อาการที่พามามากที่สุด ต้องนอนโรงพยาบาล ${_kpiCc.first.$3}%'),
        ],
        tint: _blue,
        numC: _blue,
        sel: null,
        ch: 1,
        bar: false,
      ),
      (
        label: 'คัดกรอง',
        sc: _kpiScWrist,
        big: [('$esiPct', '%')],
        line2: esi3.en,
        line: [
          TextSpan(
              text:
                  'ส่วนใหญ่เป็นผู้ป่วย${esi3.label} $esiMax ราย จาก $tTotal ราย'),
        ],
        tint: esi3.color,
        numC: esi3.level == 3
            ? Color.lerp(esi3.color, Colors.black, 0.25)!
            : esi3.color,
        sel: esiTop + 1,
        ch: 2,
        bar: false,
      ),
      (
        label: 'ตรวจรักษา',
        sc: _kpiScCare,
        big: [('${losTotal ~/ 60}', 'ชม.'), ('${losTotal % 60}', 'นาที')],
        line2: 'อยู่ใน ER เฉลี่ย',
        line: [
          const TextSpan(text: 'ขั้นที่นานที่สุดคือ'),
          TextSpan(
              text: '${_kpiLos[bott].$1} $losMax นาที',
              style: TextStyle(color: _red)),
        ],
        tint: _blue,
        numC: _blue,
        sel: null,
        ch: 3,
        bar: false,
      ),
      (
        label: 'ผลลัพธ์',
        sc: _kpiScHome,
        big: [('${home.$2.round()}', '%')],
        line2: home.$1,
        line: [
          TextSpan(
              text:
                  'Admit ${_kpiDispo[1].$2.round()}% สังเกตอาการ ${_kpiDispo[2].$2.round()}% ส่งต่อ ${_kpiDispo[3].$2.round()}%'),
        ],
        tint: _blue,
        numC: _blue,
        sel: null,
        ch: 4,
        bar: false,
      ),
    ];
    Widget headline(int k) {
      final s = slides[k];
      return GestureDetector(
        key: ValueKey(k),
        behavior: HitTestBehavior.opaque,
        onTap: () => goCh(s.ch),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.label,
                  style: _t(13.0, color: _ink3, weight: FontWeight.w600)),
              Text.rich(
                  TextSpan(children: [
                    for (final (i, (v, u)) in s.big.indexed) ...[
                      TextSpan(text: i == 0 ? v : ' $v'),
                      TextSpan(
                          text: ' $u',
                          style: _t(22.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ],
                  ]),
                  maxLines: 1,
                  style: _num(64.0, color: s.numC, weight: FontWeight.w800)),
              if (s.line2 != null)
                Text(s.line2!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(20.0, color: _inkTitle, weight: FontWeight.w800)),
              const SizedBox(height: 2.0),
              Text.rich(TextSpan(children: s.line),
                  maxLines: 2,
                  style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
              if (s.bar) ...[
                const SizedBox(height: 12.0),
                SizedBox(
                  width: 300.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: SizedBox(
                            height: 14.0,
                            child: Row(children: [
                              for (final (i, n) in _kpiTriage.indexed) ...[
                                if (i > 0) const SizedBox(width: 2.0),
                                Expanded(
                                    flex: n,
                                    child:
                                        Container(color: _Esi.values[i].color)),
                              ],
                            ]),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // แถวเดียวเสมอ (ตัวเลข 3 หลักกว้างกว่าหน้าภาพรวม) · ไม่พอ = ย่อลง
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(children: [
                              for (final (i, n) in _kpiTriage.indexed) ...[
                                if (i > 0) const SizedBox(width: 12.0),
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                        color: _Esi.values[i].color,
                                        borderRadius:
                                            BorderRadius.circular(2.0)),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text('ESI ${i + 1}',
                                      style: _t(11.5,
                                          color: _ink2,
                                          weight: FontWeight.w500)),
                                  const SizedBox(width: 4.0),
                                  // ไม่ใส่หน่วย: แถวคำอธิบายใต้ยอดรวมใหญ่ "312 ราย" (หน่วยเดียวกัน แบบหน้าภาพรวม)
                                  Text('$n',
                                      style: _num(12.5,
                                          color: _inkTitle,
                                          weight: FontWeight.w700)),
                                ]),
                              ],
                            ])),
                      ]),
                ),
              ],
            ]),
      );
    }

    Widget fade(Widget child, {AlignmentGeometry align = Alignment.center}) =>
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          layoutBuilder: (c, prev) => Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              alignment: align,
              children: [...prev, if (c != null) c]),
          child: child,
        );
    final hero = SizedBox(
      // สูงกว่าหน้าภาพรวม 24 + วงต่ำลง 24: เว้นที่ให้หัวตัวละครที่ล้นขอบบนวง
      height: 320.0,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final cx = w - 116.0 - 48.0, cy = 176.0;
        const big = 232.0;
        final headW = math.max(130.0, cx - big / 2 - 34.0);
        return _OvCycle(
          count: slides.length,
          paused: false,
          subsOf: (_) => 1,
          durationOf: (_) => const Duration(seconds: 7),
          builder: (k, _, ctl) {
            final s = slides[k];
            final sc = s.sc;
            final imgS = sc.$3, imgL = cx + sc.$4, imgT = cy + sc.$5;
            // ตัวละครโผล่พ้นวง (offset): ฉากที่มีภาพตัดเต็มตัว (_fig) = ขยายฉาก 1.24 ยึดขอบล่าง
            // ชั้นโผล่ใช้ภาพตัดเต็มตัววางทับตัวละครในฉากพอดี (ไม่มีรอยต่อ) ตัดให้ล้นได้เฉพาะเหนือวง
            // ตรวจรักษา/กลับบ้าน (ภาพตัดจางที่เอว/คอ) = ขยาย 1.28 ยึดขอบล่าง ฝั่งตัวละคร
            // หัวล้นขอบบนวง ส่วนที่จางยังอยู่ในวง (ไม่เห็นรอยต่อ)
            // โถง ER คงเดิม (มุมกำแพงโผล่พ้นวงอยู่แล้ว)
            final fig = _kpiFigIn[sc.$1];
            final pop = identical(sc, _kpiScWrist)
                ? 1.0
                : fig != null
                    ? 1.24
                    : identical(sc, _kpiScLobby)
                        ? 1.0
                        : 1.28;
            final popA = fig != null
                ? Alignment.bottomCenter
                : identical(sc, _kpiScCare)
                    ? const Alignment(-0.3, 1.0)
                    : const Alignment(0.0, 1.0);
            return Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(child: _ovHeroBackdrop(s.tint)),
              // แตะซ้าย 1/3 = ย้อน · ขวา = ถัดไป · กดค้าง = หยุด (แบบหน้าภาพรวม)
              Positioned.fill(
                child: Row(children: [
                  for (final fwd in [false, true])
                    Expanded(
                      flex: fwd ? 2 : 1,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: fwd ? ctl.next : ctl.prev,
                        onLongPressStart: (_) => ctl.hold(true),
                        onLongPressEnd: (_) => ctl.hold(false),
                      ),
                    ),
                ]),
              ),
              // วงกลาง: กรอบขาว + วงแหวน ESI วันนี้ (หน้าคัดกรอง = ชี้ระดับที่มากสุด) · ฉากเปลี่ยนแบบจาง
              Positioned(
                left: cx - big / 2,
                top: cy - big / 2,
                width: big,
                height: big,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => TweenAnimationBuilder<double>(
                    tween: Tween(
                        end: _EsiDonutPainter.midOf(_kpiTriage, s.sel ?? 0)),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeInOutCubic,
                    builder: (context, knob, child) => CustomPaint(
                      painter: const _ErStarFrame(Offset.zero),
                      foregroundPainter: _EsiDonutPainter(
                        counts: _kpiTriage,
                        colors: [for (final e in _Esi.values) e.color],
                        sel: s.sel,
                        t: t,
                        knob: knob,
                      ),
                      child: child,
                    ),
                    child: child,
                  ),
                  child: ClipPath(
                    clipper: const _ErStarClip(Offset.zero),
                    child: ColoredBox(
                      color: const Color(0xFFEEF2F8),
                      child: fade(Stack(
                          key: ValueKey('in${sc.$1}'),
                          clipBehavior: Clip.none,
                          children: [
                            // ภาพข้อมือวาดชั้นเดียวในชั้นโผล่ (ตัดตามวง + ช่องเหนือวง) ไม่ซ้อนสองชั้น
                            if (!identical(sc, _kpiScWrist))
                              Positioned(
                                left: imgL - (cx - big / 2),
                                top: imgT - (cy - big / 2),
                                width: imgS,
                                height: imgS,
                                child: Transform.scale(
                                    scale: pop,
                                    alignment: popA,
                                    child:
                                        Image.asset(sc.$1, fit: BoxFit.cover)),
                              ),
                          ])),
                    ),
                  ),
                ),
              ),
              // ตัวละครโผล่พ้นวง: ภาพตัดเต็มตัว ตัดเป็นวง + ช่องเหนือวง (หัว/ไหล่ล้นขอบบน ขา/ล้อไม่ล้นล่าง)
              Positioned.fill(
                child: IgnorePointer(
                  child: fade(fig == null
                      ? Stack(
                          key: ValueKey('pop${sc.$2}'),
                          clipBehavior: Clip.none,
                          children: [
                              Positioned(
                                left: imgL,
                                top: imgT,
                                width: imgS,
                                height: imgS,
                                child: Transform.scale(
                                    scale: pop,
                                    alignment: popA,
                                    child:
                                        Image.asset(sc.$2, fit: BoxFit.cover)),
                              ),
                            ])
                      : ClipPath(
                          key: ValueKey(fig.$1),
                          clipper: _KpiPopClip(
                              Offset(cx, cy), big / 2, fig.$6, fig.$7,
                              circle: fig.$1 != sc.$1 ||
                                  identical(sc, _kpiScWrist)),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Positioned(
                              left: imgL,
                              top: imgT,
                              width: imgS,
                              height: imgS,
                              child: Transform.scale(
                                scale: pop,
                                alignment: Alignment.bottomCenter,
                                child:
                                    Stack(clipBehavior: Clip.none, children: [
                                  Positioned(
                                    left: fig.$2 * imgS,
                                    top: fig.$3 * imgS,
                                    width: fig.$4 * imgS,
                                    height: fig.$5 * imgS,
                                    child:
                                        Image.asset(fig.$1, fit: BoxFit.fill),
                                  ),
                                ]),
                              ),
                            ),
                          ]),
                        )),
                ),
              ),
              Positioned(
                left: 24.0,
                top: 16.0,
                bottom: 0.0,
                width: headW,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (c, prev) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...prev, if (c != null) c]),
                    transitionBuilder: (c, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0.0, 0.12),
                                    end: Offset.zero)
                                .animate(a),
                            child: c)),
                    child: headline(k),
                  ),
                ),
              ),
              // FYI มุมขวาล่าง (ตำแหน่ง/ทรงเดียวกับหน้าภาพรวม): ที่มาและสูตรของตัวชี้วัดทุกตัวในหน้านี้
              Positioned(
                right: 10.0,
                bottom: 10.0,
                child: Tooltip(
                  message: 'ที่มาและสูตรตัวชี้วัด',
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ctl.hold(true);
                        _kpiInfoAll().whenComplete(() => ctl.hold(false));
                      },
                      child: const SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Icon(Icons.info_outline_rounded,
                            size: 18.0, color: _ink2),
                      ),
                    ),
                  ),
                ),
              ),
              // ตัวบอกรอบ แนวตั้งชิดขวา: รอบปัจจุบัน = ขีดยาว ร่องขาว เติมกรมท่าตามเวลา · แตะ = ไปรอบนั้น
              Positioned(
                right: 10.0,
                top: 0.0,
                bottom: 0.0,
                width: 16.0,
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (var i = 0; i < slides.length; i++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => ctl.go(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 6.0,
                              height: i == k ? 22.0 : 6.0,
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                color: i == k
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.55),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x290B1B3F),
                                      blurRadius: 3.0),
                                ],
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: i == k
                                  ? AnimatedBuilder(
                                      animation: ctl.progress,
                                      builder: (context, _) =>
                                          FractionallySizedBox(
                                        heightFactor:
                                            ctl.progress.value.clamp(0.0, 1.0),
                                        widthFactor: 1.0,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: _blue,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100.0)),
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              // ปุ่มย้อน/ถัดไป มุมขวาบน
              for (final fwd in [false, true])
                Positioned(
                  right: fwd ? 16.0 : 58.0,
                  top: 12.0,
                  child: _Press(
                    child: GestureDetector(
                      onTap: fwd ? ctl.next : ctl.prev,
                      child: Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: _panel.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: _line, width: 0.5),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x140B1B3F), blurRadius: 8.0),
                          ],
                        ),
                        child: Icon(
                            fwd
                                ? Icons.chevron_right_rounded
                                : Icons.chevron_left_rounded,
                            size: 22.0,
                            color: _ink2),
                      ),
                    ),
                  ),
                ),
            ]);
          },
        );
      }),
    );

    // ---- บท 1 มาถึง: กราฟรายชั่วโมง + ป้ายชี้ช่วงพีค
    final ch1 = chapter(
        0,
        'มาถึง',
        (
          'assets/images/er_ov_emergent_fig.png',
          122.0,
          321 / 260,
          0.0,
          1.0,
          48.0
        ),
        [
          const TextSpan(text: 'มามากที่สุดช่วง '),
          TextSpan(text: peakAt, style: hi()),
          TextSpan(text: ' $peak ราย'),
        ],
        'ผู้ป่วยเข้า ออก และรับเข้านอน ตลอด 24 ชั่วโมง',
        (seen) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _kpiFlowLegend(),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 180.0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: seen ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, k, child) =>
                      ClipRect(clipper: _RevealClip(k), child: child),
                  // ท่าเดียวกับกราฟการ์ดสัญญาณชีพหน้าผู้ป่วย (_vsDetailChartBox):
                  // กดค้าง/ลาก = ป้ายชั่วโมงใต้นิ้ว · ยกนิ้ว = ป้ายหาย
                  // ลาก = ป้ายไหลตามนิ้วต่อเนื่อง ผ่านจุดวัด = haptic · ปล่อย = ดีดเข้าจุดใกล้สุด
                  child: _kpiFlowLive(),
                ),
              ),
            ]));

    // ---- บท 2 อาการที่พามา: 5 อันดับแรก + ดูรายการ (ที่เหลือ)
    final ccShow = _kpiCcAll ? _kpiCc : _kpiCc.take(5).toList();
    final ch2 = chapter(
        1,
        'อาการที่พามา',
        (
          'assets/images/er_ov_lessurg_fig.png',
          104.0,
          167 / 260,
          0.0,
          1.0,
          32.0
        ),
        [
          TextSpan(text: _kpiCc.first.$1, style: hi()),
          const TextSpan(text: ' พามามากที่สุด'),
        ],
        'อาการที่พามาบ่อยที่สุดเดือนนี้ และสัดส่วนที่ต้องนอนโรงพยาบาล',
        (seen) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final (i, e) in ccShow.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(border: i == 0 ? null : rowLine),
                  child: Row(children: [
                    SizedBox(
                      width: 22.0,
                      child: Text('${i + 1}',
                          style: _num(12.5,
                              color: i == 0 ? _blue : _ink3,
                              weight: FontWeight.w700)),
                    ),
                    SizedBox(
                      width: 128.0,
                      child: Text(e.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, b) => Stack(children: [
                          Container(
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: _panelSoft,
                                borderRadius: BorderRadius.circular(100.0),
                              )),
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                                begin: 0.0, end: seen ? e.$2 / ccMax : 0.0),
                            duration: Duration(milliseconds: 600 + 60 * i),
                            curve: Curves.easeOutCubic,
                            builder: (context, f, _) => Container(
                                width: b.maxWidth * f,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  color: i == 0 ? _blue : _kpiTones[2],
                                  borderRadius: BorderRadius.circular(100.0),
                                )),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      width: 72.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${e.$2}',
                                style: _num(15.0,
                                    color: _inkTitle, weight: FontWeight.w700)),
                            const SizedBox(width: 3.0),
                            Text('ราย',
                                style: _t(11.5,
                                    color: _ink3, weight: FontWeight.w500)),
                          ]),
                    ),
                    const SizedBox(width: 8.0),
                    SizedBox(
                        width: 86.0,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: chip('Admit ${e.$3}%'))),
                  ]),
                ),
              if (_kpiCc.length > 5) ...[
                const SizedBox(height: 8.0),
                _Press(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _kpiCcAll = !_kpiCcAll);
                    },
                    child: Container(
                      height: 36.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(100.0),
                        border: Border.all(color: const Color(0xFFC4C7CC)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_kpiCcAll ? 'ซ่อนรายการ' : 'ดูรายการ',
                            style: _t(13.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                        const SizedBox(width: 6.0),
                        Icon(
                            _kpiCcAll
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18.0,
                            color: _inkTitle),
                      ]),
                    ),
                  ),
                ),
              ],
            ]));

    // ---- บท 3 คัดกรอง: แท่งระดับ ESI มีตัวละครของระดับยืนบนแท่ง · แตะแท่ง = เลือกระดับ
    final ch3 = chapter(
        2,
        'คัดกรอง',
        // พยาบาลวัดไข้ผู้ป่วย (ภาพหัวหน้าคัดกรอง): เฉพาะช่วงคนสองคน ตัดเก้าอี้/โต๊ะ (อยู่หลังการ์ด) กับป้ายผนังออก
        ('assets/images/er_hero_triage.png', 84.0, 682 / 294, 0.11, 0.67, 12.0),
        [
          const TextSpan(text: 'ส่วนใหญ่เป็นผู้ป่วย'),
          TextSpan(text: _Esi.values[esiTop].label, style: hi()),
          TextSpan(text: ' $esiPct%'),
        ],
        'ผู้ป่วยวันนี้แยกตามระดับ ESI แตะแถวเพื่อดูแต่ละระดับ',
        // แต่ละระดับ = สายรัดข้อมือนอน (ขยาย 1.25 เท่าของป้าย) ยาวตามจำนวน
        // ป้ายชื่อกว้างเท่ากัน ช่วงสายหลังป้ายบอกจำนวน · สัดส่วน + ชื่อไทยต่อท้ายปลายสาย
        // เลื่อนมาเห็น = สายคลี่ม้วนออกทีละเส้น (ท่าเดียวกับป้ายสายรัดหน้าภาพรวม) · แตะแถว = เลือกระดับ
        (seen) => Column(children: [
              for (final (i, n) in _kpiTriage.indexed)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                        () => _kpiEsiSel = _kpiEsiSel == i + 1 ? null : i + 1);
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity:
                        _kpiEsiSel == null || _kpiEsiSel == i + 1 ? 1.0 : 0.35,
                    child: Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0.0 : 12.0),
                      child: LayoutBuilder(builder: (context, b) {
                        const k = 1.25, base = 168.0 * k, tail = 136.0;
                        final w =
                            base + (b.maxWidth - tail - base) * n / esiMax;
                        return Row(children: [
                          SizedBox(
                            width: w,
                            height: 24.0 * k,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: seen ? 1.0 : 0.0),
                                duration:
                                    Duration(milliseconds: 1200 + 160 * i),
                                builder: (context, v, _) => RepaintBoundary(
                                  child: _esiBand(null, _Esi.values[i].color,
                                      esi: _Esi.values[i],
                                      width: w / k,
                                      count: n,
                                      strap: true,
                                      t: v),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Text('${(n * 100 / tTotal).toStringAsFixed(1)}%',
                              style: _num(15.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(_Esi.values[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
            ]));

    // ---- บท 4 ตรวจรักษา: ไทม์ไลน์ต่อขั้น (waterfall) เรียงตามลำดับจริง แต่ละแท่งเริ่มต่อจากขั้นก่อน
    // แกนบน = ชั่วโมงตั้งแต่ลงทะเบียน · แท่งกรมท่าสีเดียว คอขวด = แดง + ป้าย · ท้าย = ธงเวลารวม
    // เลื่อนมาเห็น = แท่งวาดต่อกันทีละขั้น (เวลาเดินจากลงทะเบียนไปจำหน่าย)
    final ch4 = chapter(
        3,
        'ตรวจรักษา',
        ('assets/images/er_login_doctor.png', 86.0, 1.0, 0.0, 1.0, 10.0),
        [
          const TextSpan(text: 'อยู่ใน ER เฉลี่ย '),
          TextSpan(text: losText, style: hi()),
        ],
        'เวลาเฉลี่ยตั้งแต่ลงทะเบียนจนจำหน่าย',
        (seen) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: seen ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 1800),
              curve: Curves.easeInOutCubic,
              builder: (context, v, _) => LayoutBuilder(builder: (context, b) {
                const nameW = 112.0, minW = 92.0, rowH = 36.0, axisH = 26.0;
                final trackW = b.maxWidth - nameW - minW;
                double xOf(num m) => nameW + trackW * m / losTotal;
                final n = _kpiLos.length;
                final ticks = [for (var m = 0; m < losTotal; m += 60) m];
                var acc = 0;
                final rows = <Widget>[];
                for (final (i, e) in _kpiLos.indexed) {
                  final start = acc;
                  acc += e.$2;
                  final bad = i == bott;
                  // ช่วงเวลาของขั้นนี้ในแอนิเมชัน: วาดต่อกันตามลำดับ
                  final k = ((v * n) - i).clamp(0.0, 1.0);
                  rows.add(SizedBox(
                    height: rowH,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        left: 0.0,
                        width: nameW - 8.0,
                        top: 0.0,
                        bottom: 0.0,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(e.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(13.0,
                                  color: bad ? _red : _inkTitle,
                                  weight: FontWeight.w600)),
                        ),
                      ),
                      Positioned(
                        left: xOf(start),
                        width: math.max(6.0, (xOf(acc) - xOf(start)) * k),
                        top: (rowH - 14.0) / 2,
                        height: 14.0,
                        child: Opacity(
                          opacity: k > 0.0 ? 1.0 : 0.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bad ? _red : _kpiTones[1],
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0.0,
                        width: minW,
                        top: 0.0,
                        bottom: 0.0,
                        child: Opacity(
                          opacity: k,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (bad) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 1.0),
                                    decoration: BoxDecoration(
                                      color: _red,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    child: Text('คอขวด',
                                        style: _t(10.0,
                                            color: Colors.white,
                                            weight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 6.0),
                                ],
                                Text('${e.$2}',
                                    style: _num(15.0,
                                        color: bad ? _red : _inkTitle,
                                        weight: FontWeight.w700)),
                                const SizedBox(width: 3.0),
                                Text('นาที',
                                    style: _t(11.5,
                                        color: _ink3, weight: FontWeight.w500)),
                              ]),
                        ),
                      ),
                    ]),
                  ));
                }
                return Stack(clipBehavior: Clip.none, children: [
                  // เส้นแบ่งชั่วโมง (จุดประ) + เส้นจบ (เวลารวม)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _KpiLosGrid(
                          xs: [for (final m in ticks) xOf(m)],
                          end: xOf(losTotal),
                          top: axisH),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: axisH,
                          child: Stack(clipBehavior: Clip.none, children: [
                            for (final m in ticks)
                              Positioned(
                                left: xOf(m) - 30.0,
                                width: 60.0,
                                top: 0.0,
                                child: Text(
                                    m == 0 ? 'ลงทะเบียน' : '${m ~/ 60} ชม.',
                                    textAlign: TextAlign.center,
                                    style: _t(11.0,
                                        color: _ink3, weight: FontWeight.w500)),
                              ),
                            Positioned(
                              left: xOf(losTotal) - 70.0,
                              width: 140.0,
                              top: 0.0,
                              child: Opacity(
                                opacity: ((v - 0.9) * 10).clamp(0.0, 1.0),
                                child: Text('จำหน่าย $losText',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: _t(11.0,
                                        color: _blue, weight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                        ),
                        ...rows,
                      ]),
                ]);
              }),
            ));

    // ---- บท 5 ผลลัพธ์: โดนัท + รายการ
    Color dispoC(int i) => i == 4 ? _ink3 : _kpiTones[i];
    final ch5 = chapter(
        4,
        'ผลลัพธ์',
        // ผู้ป่วยนอนพักที่บ้าน (ภาพใบรับรองแพทย์ให้พัก)
        ('assets/images/er_mc_rest.png', 114.0, 640 / 409, 0.0, 1.0, 30.0),
        [
          TextSpan(text: '${home.$2.round()}%', style: hi()),
          TextSpan(text: ' ได้${home.$1}'),
        ],
        'ผู้ป่วยวันนี้ไปทางไหนบ้าง',
        (seen) => Row(children: [
              SizedBox.square(
                dimension: 132.0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: seen ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, k, _) => CustomPaint(
                    painter: _KpiDonut(
                        [for (final e in _kpiDispo) e.$2],
                        [for (var i = 0; i < _kpiDispo.length; i++) dispoC(i)],
                        k),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${home.$2.round()}%',
                            style: _num(22.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        Text(home.$1,
                            style: _t(11.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: Column(children: [
                  for (final (i, e) in _kpiDispo.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      decoration:
                          BoxDecoration(border: i == 0 ? null : rowLine),
                      child: Row(children: [
                        Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: dispoC(i),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(e.$1,
                              style: _t(13.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                        Text('${e.$2.round()}%',
                            style: _num(15.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                      ]),
                    ),
                ]),
              ),
            ]));

    final parts = [ch1, ch2, ch3, ch4, ch5];
    // hero ชิดขอบเต็มกว้างบนสุด (แบบหน้าภาพรวม) · บทต่อด้านล่างมีขอบซ้ายขวา
    // เลื่อนลง = hero หุบแบบ sliver header ตัวเดียวกับหน้าภาพรวม (_HeroCollapse: เลื่อนช้ากว่า + จางจากขอบบน)
    // ไม่เด้งเกินขอบ (iOS bounce เปิดช่องขาวเหนือ hero)
    return CustomScrollView(
      key: const ValueKey('kpi-board'),
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPersistentHeader(
            delegate: _HeroCollapse(height: 320.0, child: hero)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
          sliver: SliverToBoxAdapter(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in parts.indexed)
                    _Appear(index: i, child: w),
                ]),
          ),
        ),
      ],
    );
  }

  Widget _overviewPanel() {
    final over = _patients.where((p) => p.over).length;
    // นับจากข้อมูลจริง ให้ตรงกับแถบล่างที่นับเตียงที่ใช้
    final vacant =
        _roomBeds.length - _patients.where((p) => p.bed != null).length;
    // ขอบในรับกับมุมโค้งแผง (24): ระยะเดียวกับแผงช่วงงาน (บน 18 · ซ้าย/ขวา 20 · ปุ่มหุบ 14)
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20.0, 18.0, 0.0, 76.0), // ล่างเว้นให้ป้ายผู้ใช้
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.zero, // ปุ่มหุบเป็นลิ้นชิดขอบขวาแผง (มุมแผงเหลี่ยม)
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ภาพรวมห้องฉุกเฉิน',
                          style:
                              _t(19.0, color: _lpInk, weight: FontWeight.w700)),
                      Text('อัปเดทข้อมูลทุก 30 วินาที',
                          style: _t(10.5, color: _lpInk3)),
                    ],
                  ),
                ),
                _collapseButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                // ลงทะเบียนผู้ป่วยใหม่ = งานแรกของห้อง ER วางบนสุดของหน้าแรก
                // ปุ่มหลักของแผง = pill ขาว (ไอคอนในวงฟ้าอ่อน) · สแกนหน้า = ปุ่มกลมเส้นขอบ ไอคอนอย่างเดียว
                Row(children: [
                  Expanded(child: _ovRegisterPill()),
                  const SizedBox(width: 8.0),
                  _ovFaceCircle(),
                ]),
                const SizedBox(height: 14.0),
                // ฟีดการ์ด (ref ฟีดการ์ดขาวมุมโค้ง): ภาพรวมห้อง · เข้าออกรายชั่วโมง · การแจ้งเตือนใบละรายการ
                ..._lpFeed(over, vacant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ฟีดแผงภาพรวม (ref ฟีดการ์ด) ด้วยภาษาของแอป: การ์ดขาวมุม 14 · หัวการ์ด = ไอคอนวง + ชื่อ/คำอธิบาย
  /// วิดเจ็ตที่ผู้ใช้เลือก/เรียงเอง (ช่องตัวชี้วัด + กราฟเข้าออกรายชั่วโมง) + ปุ่มปรับแต่ง · การแจ้งเตือนใบละรายการ
  List<Widget> _lpFeed(int over, int vacant) {
    final alerts = _allAlerts;
    // วิดเจ็ตที่ผู้ใช้เลือก (ชุดเดียวกับแผงตัวชี้วัด) เรียงตามลำดับที่ตั้งไว้ · จำไว้ในเครื่อง
    if (!_ovWidgetsLoaded) {
      _ovWidgetsLoaded = true;
      SharedPreferences.getInstance().then((sp) {
        final l = sp.getStringList(_ovWidgetsKey);
        if (l == null || !mounted) return;
        setState(() => _ovWidgets = [
              for (final id in l)
                if (_ovWidgetAll.any((w) => w.$1 == id)) id
            ]);
      });
    }
    return [
      LayoutBuilder(builder: (c, b) {
        _ovPanelW = b.maxWidth;
        return _ovGrid(b.maxWidth);
      }),
      // ปกติ = ปุ่มรอง "ปรับแต่งวิดเจ็ต" (pill เส้นขอบ) · โหมดจัด = ช่องวางรวมอยู่ใน _ovGrid
      if (!_ovEdit) ...[
        SizedBox(height: _ovWidgets.isEmpty ? 0.0 : 10.0),
        _Press(
          child: GestureDetector(
            onTap: () => setState(() => _ovEdit = true),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: _lpInk.withValues(alpha: 0.35)),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.tune_rounded, size: 18.0, color: _lpInk),
                const SizedBox(width: 6.0),
                Text('ปรับแต่งวิดเจ็ต',
                    style: _t(13.0, color: _lpInk, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ],
      // การแจ้งเตือน = การ์ดซ้อนกัน (ด่วนสุดอยู่บน) แตะกาง/ย่อ
      if (alerts.isNotEmpty) ...[
        const SizedBox(height: 14.0),
        _ovAlertStack(alerts),
      ],
    ];
  }

  /// วิดเจ็ต 'hour': กราฟเข้าออกรายชั่วโมงชุดเดียวกับหน้าตัวชี้วัด (ข้อมูล/ท่าแตะลากเดียวกัน ตัวเลขตรงกันสองหน้า)
  /// ความสูงคงที่ [_ovH] ('hour') · กราฟยืดเต็มที่เหลือ · legend บรรทัดเดียว (ย่อเองถ้าแคบ)
  Widget _ovHourCard() => Container(
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('ผู้ป่วยเข้าออกรายชั่วโมง',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 6.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 320.0,
              child: _kpiFlowLegend(fs: 11.0, gap: 10.0),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _kpiFlowLive(peak: false)),
        ]),
      );

  /// ปุ่มหลักบนสุดแผงภาพรวม: pill ขาวสูง 48 ไอคอนในวง #DBE5FC + ชื่อกรมท่า (เปิดหน้าส่งตรวจและคัดกรอง)
  /// เปิดหน้า "ส่งตรวจและคัดกรองผู้ป่วย" (เลือกวิธีดึงข้อมูล: อ่านบัตร ถ่ายภาพบัตร สแกนหน้า ค้นหา HN)
  Widget _ovRegisterPill() => _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: _openQuickRegister,
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.fromLTRB(6.0, 6.0, 16.0, 6.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x2E000A2E),
                    blurRadius: 12.0,
                    offset: Offset(0.0, 4.0)),
              ],
            ),
            child: Row(children: [
              // ไอคอนแบบเมนูใบรับรองแพทย์ (_McGIcon): วง #DBE5FC + สัญลักษณ์กรมท่าสองโทนแบ่งทแยง
              const _McGIcon(Icons.person_add_alt_1_rounded,
                  size: 36.0, navy: true),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text('ส่งตรวจผู้ป่วยใหม่',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(14.0, color: _blue, weight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      );

  /// ปุ่มรอง: สแกนหน้าค้นหาผู้ป่วย = วงขาว 48 แบบหัว pill หลัก ไอคอนอย่างเดียว (กดค้างเห็นชื่อ)
  Widget _ovFaceCircle() => Tooltip(
        message: 'สแกนหน้า',
        child: Semantics(
          button: true,
          label: 'สแกนหน้า',
          child: _Press(
            radius: 100.0,
            child: GestureDetector(
              onTap: _startFaceScan,
              child: Container(
                width: 48.0,
                height: 48.0,
                // วงขาว + เงาเดียวกับ pill หลัก · ข้างในไอคอนแบบเมนูใบรับรองแพทย์ (หน้าตาเหมือนหัว pill)
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _panel,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x2E000A2E),
                        blurRadius: 12.0,
                        offset: Offset(0.0, 4.0)),
                  ],
                ),
                child: const Center(child: _FaceScanIcon(size: 36.0)),
              ),
            ),
          ),
        ),
      );

  /// แจ้งเตือนหน้าภาพรวม = การ์ดซ้อนกัน (stacked แบบแจ้งเตือนบนมือถือ)
  /// หุบ: ใบบนสุด (ด่วนสุด) เต็ม + ใบถัดไปโผล่ใต้ขอบ 2 ชั้น (แคบลง สีเข้มขึ้นนิด) · แตะกอง = กางออก
  /// กาง: ทุกใบเลื่อนลงเป็นรายการ (เหลื่อมเวลานิด ๆ) · แตะใบ = ไปหน้าผู้ป่วย/รายการใต้กระดิ่ง · "ย่อ" = ซ้อนกลับ
  Widget _ovAlertStack(List<_Alert> alerts) {
    const h = 82.0, gap = 8.0, step = 10.0;
    final n = alerts.length;
    final open = _ovAlertsAll || n == 1;
    final total = open ? n * h + (n - 1) * gap : h + step * math.min(2, n - 1);
    void toggle() {
      HapticFeedback.selectionClick();
      setState(() => _ovAlertsAll = !_ovAlertsAll);
    }

    Widget card(_Alert a, int depth) {
      final p = a.hn == null
          ? null
          : _patients.where((x) => x.hn == a.hn).firstOrNull;
      final front = open || depth == 0;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: !open
            ? toggle
            : a.hn == null
                ? () => setState(() => _alertsOpen = true)
                : () => _alertGo(a),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(12.0, 11.0, 12.0, 10.0),
          decoration: BoxDecoration(
            color: front ? _panel : Color.lerp(_panel, _pBg, 0.16 * depth),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x29000A2E),
                  blurRadius: 10.0,
                  offset: Offset(0.0, 3.0)),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: front ? 1.0 : 0.0,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox.square(
                dimension: 36.0,
                child: p != null
                    ? ClipOval(
                        child: Image.asset(_faceUrl(p.hn),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, st) => const _McGIcon(
                                Icons.person_rounded,
                                size: 36.0,
                                navy: true)))
                    : const _McGIcon(Icons.notifications_rounded,
                        size: 36.0, navy: true),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _t(13.0,
                              color: _inkTitle,
                              weight: FontWeight.w600,
                              height: 1.3)),
                      const Spacer(),
                      Row(children: [
                        _levelBadge(a.level),
                        const SizedBox(width: 6.0),
                        Text(_clock(a.time),
                            style: _num(11.5,
                                color: _ink3, weight: FontWeight.w600)),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(p?.name ?? 'ทั้งห้อง',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.5,
                                  color: _ink3, weight: FontWeight.w500)),
                        ),
                      ]),
                    ]),
              ),
            ]),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // หัวบนพื้นแผง: ชื่อ + จำนวน · กางอยู่ = ปุ่ม "ย่อ" (pill เส้นขอบ)
      SizedBox(
        height: 30.0,
        child: Row(children: [
          const SizedBox(width: 4.0),
          Text('การแจ้งเตือน',
              style: _t(14.0, color: _lpInk, weight: FontWeight.w700)),
          const SizedBox(width: 8.0),
          Text('$n', style: _num(14.0, color: _lpInk, weight: FontWeight.w700)),
          Text(' รายการ', style: _t(11.5, color: _lpInk3)),
          const Spacer(),
          if (_ovAlertsAll && n > 1)
            _Press(
              radius: 100.0,
              child: GestureDetector(
                onTap: toggle,
                child: Container(
                  height: 28.0,
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: _lpInk.withValues(alpha: 0.35)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('ย่อ',
                        style:
                            _t(12.0, color: _lpInk, weight: FontWeight.w600)),
                    const Icon(Icons.keyboard_arrow_up_rounded,
                        size: 18.0, color: _lpInk),
                  ]),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 8.0),
      AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        height: total,
        child: Stack(clipBehavior: Clip.none, children: [
          // วาดจากใบท้ายก่อน ใบแรกอยู่บนสุด · ใบที่ 4 เป็นต้นไปซ่อนอยู่หลังใบที่ 3 ตอนหุบ
          for (var i = n - 1; i >= 0; i--)
            () {
              final depth = math.min(i, 2);
              return AnimatedPositioned(
                key: ValueKey('al-$i'),
                duration: Duration(
                    milliseconds: 360 + (open ? math.min(i, 8) * 24 : 0)),
                curve: Curves.easeOutCubic,
                left: open ? 0.0 : depth * 8.0,
                right: open ? 0.0 : depth * 8.0,
                top: open ? i * (h + gap) : depth * step,
                height: h,
                child: card(alerts[i], depth),
              );
            }(),
        ]),
      ),
    ]);
  }

  bool _ovWide(String id) => _ovWidgetAll.firstWhere((w) => w.$1 == id).$3;
  // ความสูงช่อง: เต็มแถว 100 · ครึ่งแถวคู่ 128 · ครึ่งแถวเดี่ยว 120 (พอป้ายเกินเกณฑ์) · กราฟรายชั่วโมง 200 (กราฟยืดเต็มที่เหลือ)
  double _ovH(String id, {bool pair = false}) => id == 'hour'
      ? 200.0
      : _ovWide(id)
          ? 100.0
          : (pair ? 128.0 : 120.0);

  Widget _ovTile(String id, Map<String, Widget> tiles, double w,
          {bool pair = false}) =>
      id == 'hour'
          ? SizedBox(width: w, child: _ovHourCard())
          : SizedBox(width: w, height: _ovH(id, pair: pair), child: tiles[id]!);

  /// ช่องว่างแทนที่วิดเจ็ตระหว่างลาก (บอกว่าจะไปลงตรงไหน)
  Widget _ovHole(double w, double h, {Color c = Colors.white}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
        ),
      );

  /// การ์ดที่ยกขึ้นตามนิ้ว: ค่อย ๆ ขยาย 1 → 1.05 พร้อมเงาเข้มขึ้น (เหมือนหยิบขึ้นจากแผง)
  Widget _ovLift(Widget tile) => Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, k, child) => Transform.scale(
            scale: 1.0 + 0.05 * k,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.30 * k),
                      blurRadius: 28.0 * k,
                      offset: Offset(0.0, 14.0 * k)),
                ],
              ),
              child: child,
            ),
          ),
          child: tile,
        ),
      );

  void _ovSave() {
    final l = [..._ovWidgets];
    SharedPreferences.getInstance()
        .then((sp) => sp.setStringList(_ovWidgetsKey, l));
  }

  /// ตำแหน่งแต่ละวิดเจ็ตตามลำดับ (ซ้ายบนของกริด): เต็มแถว = 1 แถว · ครึ่งแถวติดกัน = คู่ · ครึ่งเดี่ยว = เต็มแถว
  Map<String, Rect> _ovPack(List<String> order, double w) {
    final half = (w - 8.0) / 2;
    final m = <String, Rect>{};
    var y = 0.0;
    for (var i = 0; i < order.length; i++) {
      final id = order[i];
      final next = i + 1 < order.length ? order[i + 1] : null;
      if (!_ovWide(id) && next != null && !_ovWide(next)) {
        final h = _ovH(id, pair: true);
        m[id] = Rect.fromLTWH(0.0, y, half, h);
        m[next] = Rect.fromLTWH(half + 8.0, y, half, h);
        y += h + 8.0;
        i++;
      } else {
        final h = _ovH(id);
        m[id] = Rect.fromLTWH(0.0, y, w, h);
        y += h + 8.0;
      }
    }
    return m;
  }

  /// ลากอยู่เหนือกริด: หาตำแหน่งแทรกที่ทำให้ช่องของการ์ดใกล้จุดกึ่งกลางการ์ดใต้นิ้วที่สุด
  /// (ลองทุกตำแหน่ง ≤10 แบบ) · ต้องใกล้กว่าเดิมเกิน 18 px จึงย้าย (ไม่กระพือตอนนิ้วอยู่กลางรอยต่อ)
  void _ovMoveAt(String data, Offset feedbackTopLeft) {
    _ovLastMove = (data, feedbackTopLeft);
    final box = _ovGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final w = box.size.width;
    final p =
        box.globalToLocal(feedbackTopLeft) + _ovDragSize.center(Offset.zero);
    final base = [..._ovWidgets]..remove(data);
    var best = 0;
    var bd = double.infinity;
    for (var i = 0; i <= base.length; i++) {
      final r = _ovPack([...base]..insert(i, data), w)[data]!;
      final d = (r.center - p).distance;
      if (d < bd) {
        bd = d;
        best = i;
      }
    }
    final live = _ovLive;
    final cur = live?.indexOf(data) ?? -1;
    if (cur >= 0) {
      final cd = (_ovPack(live!, w)[data]!.center - p).distance;
      if (cur == best || cd - bd < 18.0) {
        _ovAutoScroll(box, feedbackTopLeft);
        return;
      }
    }
    HapticFeedback.selectionClick();
    setState(() => _ovLive = [...base]..insert(best, data));
    _ovAutoScroll(box, feedbackTopLeft);
  }

  /// การ์ดชิดขอบบน/ล่างของแผง = เลื่อนแผงเอง (ยิ่งชิดยิ่งเร็ว) แล้วคำนวณตำแหน่งแทรกใหม่
  void _ovAutoScroll(RenderBox grid, Offset feedbackTopLeft) {
    final sc = Scrollable.maybeOf(_ovGridKey.currentContext!);
    final vb = sc?.context.findRenderObject() as RenderBox?;
    if (sc == null || vb == null) return;
    final top = vb.localToGlobal(Offset.zero).dy;
    final bottom = top + vb.size.height;
    final cy = feedbackTopLeft.dy + _ovDragSize.height / 2;
    const zone = 80.0;
    _ovScrollV = cy < top + zone
        ? -(top + zone - cy) / zone * 14.0
        : cy > bottom - zone - 60.0
            ? (cy - (bottom - zone - 60.0)) / zone * 14.0
            : 0.0;
    if (_ovScrollV == 0.0) {
      _ovScrollT?.cancel();
      _ovScrollT = null;
      return;
    }
    _ovScrollT ??= Timer.periodic(const Duration(milliseconds: 16), (t) {
      final pos = sc.position;
      final to = (pos.pixels + _ovScrollV)
          .clamp(pos.minScrollExtent, pos.maxScrollExtent);
      if (_ovDrag == null || to == pos.pixels) {
        t.cancel();
        _ovScrollT = null;
        return;
      }
      pos.jumpTo(to);
      final m = _ovLastMove;
      if (m != null) _ovMoveAt(m.$1, m.$2);
    });
  }

  void _ovStopScroll() {
    _ovScrollT?.cancel();
    _ovScrollT = null;
  }

  /// ปล่อยในกริด/ยกเลิก: การ์ดร่อนจากจุดที่ปล่อยลงช่องของมัน (เฟรมแรกวางที่จุดปล่อย แล้วค่อยเลื่อน)
  void _ovSettleFrom(String id, Offset feedbackTopLeft) {
    final box = _ovGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _ovSettle = (id, box.globalToLocal(feedbackTopLeft) & _ovDragSize);
    _ovSettleGo = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ovSettleGo = true);
      Timer(const Duration(milliseconds: 320), () {
        if (mounted && _ovSettle?.$1 == id) setState(() => _ovSettle = null);
      });
    });
  }

  void _ovDragDone() {
    _ovStopScroll();
    _ovLastMove = null;
    if (!mounted) return;
    setState(() {
      _ovDrag = null;
      _ovLive = null;
    });
  }

  void _ovRemove(String id) {
    HapticFeedback.selectionClick();
    setState(() => _ovWidgets = [..._ovWidgets]..remove(id));
    _ovSave();
  }

  /// วิดเจ็ตในแผง: วางด้วยตำแหน่งที่คำนวณ (AnimatedPositioned) ลำดับเปลี่ยน = การ์ดอื่นเลื่อนหลบนุ่ม ๆ
  /// ปกติ = แตะไปหน้าตัวชี้วัด · โหมดจัด = ลากทั้งใบ (ยกขึ้น + เงา) ปุ่มเอาออกมุมขวาบน ช่องวางท้ายแผง
  Widget _ovGrid(double w) {
    final tiles = _kpiTiles();
    final order = _ovLive ?? _ovWidgets;
    final rects = _ovPack(order, w);
    final h = order.isEmpty
        ? 0.0
        : rects.values.map((r) => r.bottom).reduce(math.max);
    final st = _ovSettle;
    final ids = [
      for (final id in order)
        if (id != st?.$1) id,
      if (st != null && order.contains(st.$1)) st.$1, // ร่อนลง = อยู่บนสุด
    ];
    final grid = AnimatedContainer(
      key: _ovGridKey,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: h,
      child: Stack(clipBehavior: Clip.none, children: [
        for (final (i, id) in ids.indexed)
          () {
            final settling = st?.$1 == id && !_ovSettleGo;
            final r = settling ? st!.$2 : rects[id]!;
            return AnimatedPositioned(
              key: ValueKey(id),
              duration:
                  settling ? Duration.zero : const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: r.left,
              top: r.top,
              width: r.width,
              height: r.height,
              child: _ovItem(id, tiles, rects[id]!.size, i),
            );
          }(),
      ]),
    );
    if (!_ovEdit) return grid;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onMove: (d) => _ovMoveAt(d.data, d.offset),
      // ลากจากถาดออกไปนอกกริด = เอาช่องตัวอย่างออก · ลากจากแผง = ช่องว่างค้างที่เดิม
      onLeave: (data) {
        _ovStopScroll();
        if (data != null && !_ovWidgets.contains(data)) {
          setState(() => _ovLive = null);
        }
      },
      onAcceptWithDetails: (d) {
        _ovStopScroll();
        final live = _ovLive;
        if (live == null) return;
        setState(() {
          _ovWidgets = live;
          _ovLive = null;
          _ovDrag = null;
          _ovSettleFrom(d.data, d.offset);
        });
        _ovSave();
      },
      builder: (context, cand, _) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        grid,
        SizedBox(height: order.isEmpty ? 0.0 : 10.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 56.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: cand.isEmpty ? 0.0 : 0.08),
            borderRadius: BorderRadius.circular(14.0),
            border:
                Border.all(color: _lpInk.withValues(alpha: 0.45), width: 1.5),
          ),
          child: Text('ลากวิดเจ็ตมาวางที่นี่',
              style: _t(13.0, color: _lpInk2, weight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _ovItem(String id, Map<String, Widget> tiles, Size size, int i) {
    final tile = id == 'hour' ? _ovHourCard() : tiles[id]!;
    if (!_ovEdit) {
      return _Appear(
        index: i,
        child: _Press(
          scale: 0.98,
          child: GestureDetector(
              onTap: () => setState(() => _kpiOpen = true), child: tile),
        ),
      );
    }
    final hole = _ovHole(size.width, size.height);
    return Draggable<String>(
      data: id,
      feedback: _ovLift(SizedBox.fromSize(size: size, child: tile)),
      childWhenDragging: hole,
      onDragStarted: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _ovDrag = id;
          _ovDragSize = size;
          _ovLive = [..._ovWidgets];
          _ovSettle = null;
        });
      },
      onDragCompleted: _ovDragDone,
      // ปล่อยนอกกริด/ถาด = กลับที่เดิม (ร่อนกลับจากจุดที่ปล่อย)
      onDraggableCanceled: (_, at) {
        _ovDragDone();
        if (mounted) setState(() => _ovSettleFrom(id, at));
      },
      child: id == _ovDrag
          ? hole
          : Stack(fit: StackFit.expand, children: [
              tile,
              Positioned(
                top: 6.0,
                right: 6.0,
                child: GestureDetector(
                  onTap: () => _ovRemove(id),
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF5F6878)),
                    child: const Icon(Icons.remove_rounded,
                        size: 18.0, color: Colors.white),
                  ),
                ),
              ),
            ]),
    );
  }

  /// ถาดวิดเจ็ต (โหมดจัด): งอกออกจากขอบขวาแผงซ้าย สีเดียวกับแผง (เหมือนแผงยื่นออกมา)
  /// วิดเจ็ตขนาดจริงเท่าในแผง ลากไปซ้าย = เพิ่ม (ลากแนวตั้ง = เลื่อนถาด) · ลากวิดเจ็ตจากแผงมาวาง = เอาออก
  Widget _ovTray() {
    final w = _ovPanelW, half = (w - 8.0) / 2;
    final tiles = _kpiTiles();
    final rest = [
      for (final d in _ovWidgetAll)
        if (!_ovWidgets.contains(d.$1)) d.$1
    ];
    Widget item(String id, double iw, {bool pair = false}) {
      final tile = _ovTile(id, tiles, iw, pair: pair);
      return Draggable<String>(
        data: id,
        affinity: Axis.horizontal,
        feedback: _ovLift(tile),
        childWhenDragging: _ovHole(iw, _ovH(id, pair: pair)),
        onDragStarted: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _ovDrag = id;
            _ovDragSize = Size(iw, _ovH(id, pair: pair));
            _ovSettle = null;
          });
        },
        onDragCompleted: _ovDragDone,
        onDraggableCanceled: (_, __) => _ovDragDone(),
        child: tile,
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < rest.length; i++) {
      final id = rest[i];
      final next = i + 1 < rest.length ? rest[i + 1] : null;
      if (!_ovWide(id) && next != null && !_ovWide(next)) {
        rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          item(id, half, pair: true),
          const SizedBox(width: 8.0),
          item(next, half, pair: true),
        ]));
        i++;
      } else {
        rows.add(item(id, w));
      }
    }
    return DragTarget<String>(
      // วิดเจ็ตจากแผงลากมาวางบนถาด = เอาออก (ถาดขึ้น "ปล่อยเพื่อเอาออก" · แผงยังเว้นช่องว่างไว้จนปล่อย)
      onWillAcceptWithDetails: (d) => _ovWidgets.contains(d.data),
      onAcceptWithDetails: (d) {
        setState(() {
          _ovWidgets = [..._ovWidgets]..remove(d.data);
          _ovLive = null;
        });
        _ovSave();
      },
      // เมนูลอย: มุมโค้งรอบด้าน สูงตามเนื้อ (ไม่เกินจอ) ห่างแผงซ้าย 12 · เงาใหญ่ให้ลอยเหนือหน้า
      builder: (context, cand, _) => Container(
        width: w + 32.0,
        decoration: BoxDecoration(
          color: _pBg,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
                color: Color(0x40000000),
                blurRadius: 32.0,
                offset: Offset(0.0, 12.0)),
          ],
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('เพิ่มวิดเจ็ต',
                          style:
                              _t(17.0, color: _lpInk, weight: FontWeight.w700)),
                      Text('ลากไปวางในแผงภาพรวม',
                          style: _t(11.0, color: _lpInk3)),
                    ]),
              ),
              Flexible(
                child: Stack(children: [
                  rest.isEmpty
                      ? SizedBox(
                          height: 120.0,
                          child: Center(
                            child: Text('ใส่ครบทุกวิดเจ็ตแล้ว',
                                style: _t(13.0,
                                    color: _lpInk2, weight: FontWeight.w600)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                          physics: const ClampingScrollPhysics(),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8.0),
                          itemBuilder: (_, i) => rows[i],
                        ),
                  // ลากวิดเจ็ตจากแผงมาลอยเหนือถาด = บอกว่าปล่อยแล้วเอาออก
                  if (cand.isNotEmpty)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _pBg,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                              color: _lpInk.withValues(alpha: 0.6), width: 1.5),
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.remove_circle_outline_rounded,
                              size: 32.0, color: _lpInk),
                          const SizedBox(height: 6.0),
                          Text('ปล่อยเพื่อเอาออก',
                              style: _t(14.0,
                                  color: _lpInk, weight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                child: _Press(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _ovEdit = false;
                      _ovLive = null;
                      _ovDrag = null;
                    }),
                    child: Container(
                      height: 44.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(100.0)),
                      child: Text('เสร็จ',
                          style:
                              _t(14.0, color: _blue, weight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  // ---------------------------------------------------------------- กระดานภาพรวม
  /// หน้าภาพรวม (ขวาของแผง KPI): 2 หน้าต่าง
  /// ซ้าย = visualization (placeholder รอออกแบบ) · ขวา = รายชื่อผู้ป่วย 2 คอลัมน์ เรียงตามความเร่งด่วน
  /// chip ระดับ ESI: จุดสีระดับ + ชื่อ + จำนวน · เลือกแล้ว = พื้นสีระดับอ่อน ขอบสี
  /// ปุ่มสลับมุมมองรายชื่อ (segmented ไอคอน): การ์ด | ตาราง
  Widget _boardViewToggle({bool bare = false, List<_P>? mine}) {
    Widget seg(bool table, IconData icon, String tip) {
      final on = _boardTable == table;
      return Tooltip(
        message: tip,
        child: GestureDetector(
          onTap: () => setState(() => _boardTable = table),
          // ที่เลือก = pill กรมท่า ไอคอน + ข้อความกำกับ · ที่ไม่เลือก = ไอคอนอย่างเดียว
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 34.0,
            padding: EdgeInsets.symmetric(horizontal: on ? 14.0 : 11.0),
            decoration: BoxDecoration(
              color: on ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 20.0, color: on ? Colors.white : _ink2),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: on
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(tip,
                            style: _t(14.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      )
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2.0),
      // bare = อยู่ในแท็บหัว folder (ไม่มีพื้น/ขอบของตัวเอง)
      decoration: bare
          ? null
          : BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
      // หัวข้อ "รายชื่อผู้ป่วย" ตัวเล็กบางอยู่เหนือแถวปุ่ม (มุมมอง · ของฉัน · ESI)
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              seg(false, Icons.grid_view_rounded, 'การ์ด'),
              seg(true, Icons.table_rows_rounded, 'ตาราง'),
              // ตัวกรองผู้ป่วยของฉัน (แพทย์) ย้ายจากมุมฉากมาอยู่ในหัวรายชื่อ
              if (mine != null) ...[
                Container(
                    width: 1.0,
                    height: 20.0,
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    color: _line),
                _boardMineToggle(mine),
              ],
              Container(
                  width: 1.0,
                  height: 20.0,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: _line),
              _esiFilterButton(mine ?? const []),
            ]),
          ]),
    );
  }

  /// มุมมองตาราง: แถวละคน · ESI · ชื่อ/HN · เตียง · ประเภท · Fast track KPI · อยู่ใน ER · ช่วงงาน
  /// แตะแถว = เปิดผู้ป่วย
  static const _tblCols = [
    ('ESI', 58.0),
    ('ผู้ป่วย', 0.0),
    ('เตียง', 52.0),
    ('ประเภท', 80.0),
    ('Fast track', 150.0),
    ('อยู่ใน ER', 92.0),
  ];

  /// หัวตาราง (ค้างบนสุดเมื่อเลื่อน ใต้หัวรายชื่อผู้ป่วย) · มุมบนโค้ง ต่อกับตัวตาราง
  /// หัวตาราง (ค้างบนสุดเมื่อเลื่อน ใต้หัวรายชื่อผู้ป่วย) · มุมบนโค้ง ต่อกับตัวตาราง
  /// แตะหัวคอลัมน์ = เรียง (แตะซ้ำ สลับขึ้น/ลง · ครั้งที่สาม = กลับลำดับตั้งต้น)
  Widget _boardTableHead() {
    Widget head(int i) {
      final c = _tblCols[i];
      final on = _tblSort == i;
      final w = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (_tblSort != i) {
              _tblSort = i;
              _tblAsc = true;
            } else if (_tblAsc) {
              _tblAsc = false;
            } else {
              _tblSort = null;
            }
          });
        },
        child: SizedBox(
          height: 38.0,
          child: Row(children: [
            Flexible(
              child: Text(c.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0,
                      color: on ? _blue : _ink2,
                      weight: on ? FontWeight.w700 : FontWeight.w600)),
            ),
            const SizedBox(width: 2.0),
            Icon(
                on
                    ? (_tblAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14.0,
                color: on ? _blue : _ink3),
          ]),
        ),
      );
      return c.$2 == 0.0 ? Expanded(child: w) : SizedBox(width: c.$2, child: w);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        border: Border(
          top: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          left: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          right: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
      ),
      child: Row(children: [for (var i = 0; i < _tblCols.length; i++) head(i)]),
    );
  }

  /// ตัวแบ่งหน้าตาราง: "1–20 จาก 22" · ก่อนหน้า · เลขหน้า · ถัดไป
  Widget _tblPager(int pages, int total) {
    Widget btn(IconData ic, bool on, VoidCallback f) => _Press(
          child: GestureDetector(
            onTap: on ? f : null,
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: _panel,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Icon(ic, size: 20.0, color: on ? _inkTitle : _ink3),
            ),
          ),
        );
    final from = _tblPage * _tblPer + 1;
    final to = math.min(total, from + _tblPer - 1);
    return Row(children: [
      Text('$from–$to จาก $total ราย',
          style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
      const Spacer(),
      btn(Icons.chevron_left_rounded, _tblPage > 0,
          () => setState(() => _tblPage--)),
      const SizedBox(width: 6.0),
      for (var i = 0; i < pages; i++) ...[
        GestureDetector(
          onTap: () => setState(() => _tblPage = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == _tblPage ? _blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text('${i + 1}',
                style: _num(13.0,
                    color: i == _tblPage ? Colors.white : _ink2,
                    weight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 4.0),
      ],
      const SizedBox(width: 2.0),
      btn(Icons.chevron_right_rounded, _tblPage < pages - 1,
          () => setState(() => _tblPage++)),
    ]);
  }

  /// แถวตารางไล่เข้า: เหลื่อมเวลาตามลำดับ (สูงสุด 12 แถวแรก ที่เหลือขึ้นพร้อมแถวที่ 12)
  Widget _tblRise(int i, Key key, Widget child) {
    final d = math.min(i, 12);
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + 30 * d),
      builder: (context, v, c) {
        final t = Curves.easeOutCubic
            .transform(Interval((30 * d) / (380 + 30 * d), 1.0).transform(v));
        return Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0.0, 8.0 * (1 - t)), child: c),
        );
      },
      child: child,
    );
  }

  /// เรียงรายชื่อตามคอลัมน์ที่เลือก (ค่าว่างไปท้ายเสมอ)
  List<_P> _tblSorted(List<_P> list) {
    final k = _tblSort;
    if (k == null) return list;
    // Fast track: เกินเป้ามากสุดก่อน (ค่า + = นาทีที่เกิน, - = นาทีที่เหลือ)
    num? ft(_P p) {
      final b = _ftKpiBrief(p.hn).firstOrNull;
      if (b == null || b.$3 == _ink3) return null;
      final n =
          int.tryParse(RegExp(r'(\d+) นาที').firstMatch(b.$2)?.group(1) ?? '');
      if (n == null) return null;
      return b.$2.startsWith('เกิน') ? n : -n;
    }

    Comparable? key(_P p) => switch (k) {
          0 => p.esi?.level as Comparable?,
          1 => p.name as Comparable?,
          2 => p.bed as Comparable?,
          3 => p.type?.label as Comparable?,
          4 => ft(p) as Comparable?,
          _ => p.waitMin as Comparable?,
        };
    final out = [...list];
    out.sort((a, b) {
      final x = key(a), y = key(b);
      if (x == null && y == null) return 0;
      if (x == null) return 1;
      if (y == null) return -1;
      final r = Comparable.compare(x, y);
      return _tblAsc ? r : -r;
    });
    return out;
  }

  Widget _boardTableView(List<_P> list) {
    const cols = _tblCols;
    Widget cell(int i, Widget w) => cols[i].$2 == 0.0
        ? Expanded(child: w)
        : SizedBox(width: cols[i].$2, child: w);
    String hm(int m) => m >= 60 ? '${m ~/ 60} ชม. ${m % 60} นาที' : '$m นาที';
    // ตัวตาราง (หัวแยกไปเป็น sliver ค้าง): มุมล่างโค้ง ไม่มีขอบบน (ต่อจากหัว)
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        border: Border(
          left: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          right: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
          bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                textAlign: TextAlign.center,
                style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
          ),
        for (final (i, p) in list.indexed) ...[
          if (i > 0)
            const Divider(
                height: 1.0, thickness: 0.5, color: Color(0xFFE8EAED)),
          // เปิดตาราง/เปลี่ยนการเรียง: แถวไล่เข้าบนลงล่าง (จาง + เลื่อนขึ้นจากล่างเล็กน้อย)
          _tblRise(
              i,
              ValueKey('tr-$_tblSort-$_tblAsc-$_tblPage-${p.hn}'),
              InkWell(
                onTap: () => _openPatient(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(children: [
                    cell(
                        0,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: p.esi == null
                              ? Text('-', style: _t(13.0, color: _ink3))
                              // สายรัดข้อมือชิ้นเดียวกับการ์ด ป้ายพิมพ์เลขระดับ
                              : SizedBox(
                                  height: 22.0,
                                  child: FittedBox(
                                      child: _esiBand(p, p.esi!.color,
                                          label: '${p.esi!.level}')),
                                ),
                        )),
                    cell(
                        1,
                        Row(children: [
                          ClipOval(
                            child: Image.asset(_faceUrl(p.hn),
                                width: 30.0, height: 30.0, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(14.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w600)),
                                  Text('HN ${p.hn}',
                                      style: _num(11.5,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                                ]),
                          ),
                        ])),
                    cell(
                        2,
                        Text(p.bed ?? '-',
                            style: _num(13.0,
                                color: _inkTitle, weight: FontWeight.w600))),
                    cell(
                        3,
                        Text(p.type?.label ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500))),
                    cell(4, Builder(builder: (_) {
                      final k = _ftKpiBrief(p.hn).firstOrNull;
                      if (k == null || k.$3 == _ink3) {
                        return Text(_ftOf(p.hn).isEmpty ? '-' : 'รอเริ่มนับ',
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500));
                      }
                      return Row(children: [
                        const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CustomPaint(painter: _StopwatchArt(1.0))),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(k.$2.split(' (').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(12.5,
                                  color: k.$3, weight: FontWeight.w700)),
                        ),
                      ]);
                    })),
                    cell(
                        5,
                        Text(hm(p.waitMin),
                            style: _t(13.0,
                                color: p.over ? _red : _inkTitle,
                                weight: FontWeight.w600))),
                  ]),
                ),
              )),
        ],
      ]),
    );
  }

  /// ตัวกรอง Fast track = ป้ายแฟ้มชิ้นเดียวกับในการ์ดผังเตียง (_ftBadge แดงทึบ นาฬิกา 3D)
  /// แบบเดียวกับชิป ESI (สายรัดข้อมือ): เลือก = ยกลอย + เงาแดง · ระหว่างกรอง ESI อื่น = จาง
  /// ตัวกรอง "ผู้ป่วยของฉัน" ใช้เฉพาะบทบาทแพทย์
  bool get _mineOn => _boardMine && ErSession.instance.role == ErRole.doctor;

  /// ผู้ป่วยที่ assign ให้แพทย์ที่ login (ทีมเคสมีชื่อแพทย์คนนี้ เทียบชื่อต้น)
  bool _isMine(_P p) {
    final me = ErSession.instance.user;
    if (me == null) return true;
    final parts = me.name.split(' ');
    final first = parts.length > 1 ? parts[1] : me.name;
    return erCaseOf(p.hn)
        .team
        .any((m) => m.$2.contains('แพทย์') && m.$1.contains(first));
  }

  /// ช่วงปกติของสัญญาณชีพ (ชื่อ, ค่า, ต่ำสุด, สูงสุด, ขั้นต่ำที่นับว่าเปลี่ยน)
  List<(String, List<double>, double, double, double)> _ovVitalRanges(
          ErCase c) =>
      [
        ('HR', c.hr, 60.0, 100.0, 2.0),
        ('SBP', c.sbp, 90.0, 140.0, 4.0),
        ('RR', c.rr, 12.0, 20.0, 1.0),
        ('SpO₂', c.spo2, 95.0, 100.0, 0.5),
        ('BT', c.bt, 36.0, 37.5, 0.2),
      ];

  /// คำอธิบายแนวโน้มเป็นประโยค: อะไรเปลี่ยนไปทางไหน ในช่วงเวลาเท่าไร + ความหมายทางคลินิกคร่าว ๆ
  /// เช่น "ชีพจรเร็วขึ้นและความดันลดลงใน 22 นาที เข้าเกณฑ์เฝ้าระวังภาวะช็อก"
  String _ovTrendStory(
      int kind, ErCase c, List<(String, double, double, double, double)> ch,
      {List<(String, double, double, double, double)> minor = const []}) {
    if (ch.isEmpty) {
      return kind == 6 ? 'สัญญาณชีพแย่ลง' : 'สัญญาณชีพดีขึ้น';
    }
    String word(String lb, double a, double b, double lo, double hi) {
      final up = b > a;
      final inRange = b >= lo && b <= hi;
      return switch (lb) {
        'HR' =>
          up ? 'ชีพจรเร็วขึ้น' : (inRange ? 'ชีพจรกลับสู่ปกติ' : 'ชีพจรช้าลง'),
        'SBP' => up
            ? (inRange ? 'ความดันกลับสู่ปกติ' : 'ความดันสูงขึ้น')
            : (inRange ? 'ความดันลดลงสู่ปกติ' : 'ความดันลดลง'),
        'RR' => up
            ? 'หายใจเร็วขึ้น'
            : (inRange ? 'การหายใจกลับสู่ปกติ' : 'หายใจช้าลง'),
        'SpO₂' => up ? 'ออกซิเจนในเลือดดีขึ้น' : 'ออกซิเจนในเลือดลดลง',
        'BT' => up ? 'ไข้สูงขึ้น' : (inRange ? 'ไข้ลดลง' : 'อุณหภูมิต่ำลง'),
        _ => lb,
      };
    }

    final parts = [
      for (final x in ch.take(3)) word(x.$1, x.$2, x.$3, x.$4, x.$5)
    ];
    final joined = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(' ')} และ${parts.last}';
    // ช่วงเวลา: จากรอบที่เทียบถึงรอบล่าสุด
    String span = '';
    if (c.times.length >= 2) {
      int m(String t) {
        final q = t.split(':');
        return int.parse(q[0]) * 60 + int.parse(q[1]);
      }

      try {
        final d = m(c.times.last) - m(c.times[math.max(0, c.times.length - 3)]);
        if (d > 0) span = ' ใน $d นาที';
      } catch (_) {}
    }
    // ความหมายทางคลินิก (กติกาง่าย ๆ ตามค่าล่าสุด)
    double? last(String lb) {
      for (final x in ch) {
        if (x.$1 == lb) return x.$3;
      }
      return null;
    }

    final hr = last('HR') ?? (c.hr.isEmpty ? null : c.hr.last);
    final sbp = last('SBP') ?? (c.sbp.isEmpty ? null : c.sbp.last);
    final spo2 = last('SpO₂') ?? (c.spo2.isEmpty ? null : c.spo2.last);
    String hint = '';
    if (kind == 6) {
      if (hr != null && sbp != null && hr > 100 && sbp < 100) {
        hint = ' เข้าเกณฑ์เฝ้าระวังภาวะช็อก';
      } else if (spo2 != null && spo2 < 94) {
        hint = ' ควรประเมินการหายใจ';
      } else {
        hint = ' ควรประเมินซ้ำ';
      }
    } else {
      final allNormal = ch.every((x) => x.$3 >= x.$4 && x.$3 <= x.$5);
      hint = allNormal ? ' อยู่ในช่วงปกติแล้ว' : ' ตอบสนองต่อการรักษา';
    }
    // ค่าที่สวนทาง (ส่วนน้อย): ต่อท้ายด้วย "แต่…"
    final but = minor.isEmpty
        ? ''
        : ' แต่${[
            for (final x in minor.take(2)) word(x.$1, x.$2, x.$3, x.$4, x.$5)
          ].join(' ')}';
    return '$joined$span$but$hint';
  }

  String _ovUnit(String lb) => switch (lb) {
        'HR' => 'bpm',
        'SBP' => 'mmHg',
        'RR' => '/min',
        'SpO₂' => '%',
        'BT' => '°C',
        _ => '',
      };

  /// ระยะที่ค่าออกนอกช่วงปกติ (อยู่ในช่วง = 0)
  double _ovOut(double v, double lo, double hi) =>
      v < lo ? lo - v : (v > hi ? v - hi : 0.0);

  /// แนวโน้มอาการจากสัญญาณชีพ 3 รอบล่าสุด (รอบเก่าสุดในช่วง เทียบรอบล่าสุด): + ดีขึ้น · − แย่ลง · 0 คงที่/ไม่พอ
  /// แต่ละค่า (HR SBP RR SpO₂ BT) เทียบระยะห่างจากค่ากลางปกติ รอบล่าสุดกับรอบก่อน
  int _ovTrend(_P p) {
    final c = erCaseOf(p.hn);
    var better = 0, worse = 0;
    for (final (_, v, lo, hi, tol) in _ovVitalRanges(c)) {
      if (v.length < 2) continue;
      final d0 = _ovOut(v[math.max(0, v.length - 3)], lo, hi),
          d1 = _ovOut(v.last, lo, hi);
      // เข้า/ออกช่วงผิดปกติ นับเสมอ · ผิดปกติอยู่แล้ว = ต้องเปลี่ยนเกินขั้นต่ำ
      if (d1 < d0 - tol || (d1 == 0 && d0 > 0)) better++;
      if (d1 > d0 + tol || (d0 == 0 && d1 > 0)) worse++;
    }
    return worse > better ? -1 : (better > worse ? 1 : 0);
  }

  /// FYI: เกณฑ์ที่ hero ใช้เลือกผู้ป่วยแต่ละแบบ (อ่านจากโค้ดจริง: _ovTrend · _ovVitalRanges · _ovDueOf)
  Future<void> _ovTrendInfo() {
    Widget sec(IconData ic, Color c, String title, List<String> lines) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(ic, size: 18.0, color: c),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 4.0),
                    for (final l in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(l,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500)),
                      ),
                  ]),
            ),
          ]),
        );
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('แนวโน้มในภาพรวมคำนวณอย่างไร',
                      style:
                          _t(18.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 4.0),
                  Text(
                      'ระบบเลือกผู้ป่วยขึ้นแต่ละแบบด้วยเกณฑ์นี้ เป็นการช่วยเตือน ไม่ใช่การวินิจฉัย',
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                  const SizedBox(height: 18.0),
                  sec(Icons.trending_down_rounded, _red, 'แนวโน้มแย่ลง', [
                    'เทียบสัญญาณชีพรอบล่าสุดกับรอบที่วัดก่อนหน้า 2 รอบ (ดู 3 รอบล่าสุด)',
                    'ดู 5 ค่าเทียบช่วงปกติ: HR 60–100, SBP 90–140, RR 12–20, SpO₂ 95–100, BT 36.0–37.5',
                    'นับว่าแย่ลงเมื่อค่าออกนอกช่วงปกติ หรือห่างจากช่วงปกติมากขึ้นเกินขั้นต่ำ (HR 2, SBP 4, RR 1, SpO₂ 0.5, BT 0.2)',
                    'ค่าที่แย่ลงมากกว่าค่าที่ดีขึ้น = แนวโน้มแย่ลง',
                  ]),
                  sec(Icons.trending_up_rounded, _green, 'แนวโน้มดีขึ้น', [
                    'ใช้ 3 รอบล่าสุดและช่วงปกติเดียวกัน',
                    'นับว่าดีขึ้นเมื่อค่ากลับเข้าช่วงปกติ หรือเข้าใกล้ช่วงปกติเกินขั้นต่ำ',
                    'ค่าที่ดีขึ้นมากกว่าค่าที่แย่ลง = แนวโน้มดีขึ้น',
                  ]),
                  sec(Icons.schedule_rounded, _blue, 'ถึงเวลาดูแล', [
                    'งานจากคำสั่งแพทย์และ Fast track ที่ตั้งเวลาไว้ และเวลาถึงแล้วแต่ยังไม่บันทึกว่าทำ',
                    'คนที่มีงานค้างมากสุดขึ้นก่อน',
                  ]),
                  sec(Icons.format_list_numbered_rounded, _ink2,
                      'ลำดับที่แสดง', [
                    'แต่ละแบบแสดงไม่เกิน 3 คน แนวโน้มเรียงตาม ESI ด่วนก่อน',
                    'ค่าที่แย่ลงและดีขึ้นเท่ากัน หรือมีสัญญาณชีพไม่ถึง 2 รอบ จะไม่ขึ้นในแนวโน้ม',
                  ]),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('เข้าใจแล้ว',
                          style:
                              _t(14.0, color: _blue, weight: FontWeight.w700)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  /// headline รายบุคคล: ชื่อ → ข้อความ (ชนิดแจ้ง + เตียง/ESI) → ค่า → ปุ่มดูเคส · ตัวบอกรอบใต้สุด
  Widget _ovWhoHeadline(int kind, _P p, String label, Color col,
      List<int> steps, List<(int, _P)> people, int cur, Color tint) {
    final c = erCaseOf(p.hn);
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    // ค่า: แย่ลง/ดีขึ้น = ค่าที่เปลี่ยน (ก่อน → ล่าสุด) · ถึงเวลา = งานที่เลยเวลา
    final vals = <(String, String)>[];
    // แถวรายละเอียด: (ชื่อ, ค่าทุกรอบสำหรับกราฟเล็ก, ก่อน → ล่าสุด, ช่วงปกติ)
    // ไทล์: (ชื่อ, ค่าทุกรอบ, ก่อน, ล่าสุด, ต่ำ, สูง)
    final tiles =
        <(String, List<double>, double, double, double, double, Color)>[];
    // งานที่เลยเวลา: (เวลา, ชื่องาน, เลยกี่นาที)
    final trows = <(String, String, int)>[];
    String meta = '';
    String msg = 'มีงานถึงเวลาแล้ว';
    // คนเดียวมีได้ทั้งแนวโน้ม (6/7) และงานถึงเวลา: ไทล์สัญญาณชีพ + การ์ดงานในแถวเดียวกัน
    if (kind == 8 || _ovDueOf(p) > 0) {
      final now = DateTime.now();
      final hm =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final t = _ovCareTasks(p.hn)
          .where((t) =>
              !_isDone(t.title, p.hn) &&
              RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
              t.time.compareTo(hm) <= 0)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      if (kind == 8 && t.isNotEmpty) msg = t.first.title;
      if (t.isNotEmpty) {
        final p0 = t.first.time.split(':');
        final due = DateTime(
            now.year, now.month, now.day, int.parse(p0[0]), int.parse(p0[1]));
        vals.add(('ถึงเวลา', _clock(t.first.time)));
        vals.add(('เลยมา', '${now.difference(due).inMinutes} นาที'));
        if (t.length > 1) vals.add(('งานค้าง', '${t.length} งาน'));
        for (final x in t.take(3)) {
          final q = x.time.split(':');
          final d = DateTime(
              now.year, now.month, now.day, int.parse(q[0]), int.parse(q[1]));
          trows.add((x.time, x.title, now.difference(d).inMinutes));
        }
        // ไม่มีบรรทัดสรุปใต้ bento (จำนวนงาน/ผู้สั่งอยู่ในกองการ์ดและช่องขวาแล้ว)
      }
    }
    if (kind != 8) {
      msg = kind == 6 ? 'สัญญาณชีพแย่ลง' : 'สัญญาณชีพดีขึ้น';
      // ทุกค่าที่เปลี่ยน (คนหนึ่งอาจมีทั้งดีขึ้นและแย่ลง) · สีตามทิศของค่านั้น · ทิศส่วนมากขึ้นก่อน
      final same =
          <(String, List<double>, double, double, double, double, Color)>[];
      final other =
          <(String, List<double>, double, double, double, double, Color)>[];
      for (final (lb, v, lo, hi, tol) in _ovVitalRanges(c)) {
        if (v.length < 2) continue;
        final a = v[math.max(0, v.length - 3)], b = v.last;
        final d0 = _ovOut(a, lo, hi), d1 = _ovOut(b, lo, hi);
        final worse = d1 > d0 + tol || (d0 == 0 && d1 > 0);
        final better = d1 < d0 - tol || (d1 == 0 && d0 > 0);
        if (!worse && !better) continue;
        final series = v.length > 6 ? v.sublist(v.length - 6) : v;
        final t = (lb, series, a, b, lo, hi, worse ? _red : _green);
        ((kind == 6) == worse ? same : other).add(t);
        if ((kind == 6) == worse) vals.add((lb, '${f(a)} → ${f(b)}'));
      }
      tiles.addAll(same);
      tiles.addAll(other);
      final minor = [for (final t in other) (t.$1, t.$3, t.$4, t.$5, t.$6)];
      msg = _ovTrendStory(
          kind, c, [for (final t in same) (t.$1, t.$3, t.$4, t.$5, t.$6)],
          minor: minor);
      final n = c.hr.length;
      final last = c.times.isEmpty ? null : c.times.last;
      meta = [
        'วัด $n รอบ',
        if (last != null) 'ล่าสุด ${_clock(last)}',
      ].join('  ');
    }
    // ข้างป้ายแนวโน้ม: HN อย่างเดียว
    final where = 'HN ${p.hn}';
    // รอบใหม่: แถวไทล์เริ่มต้นที่เดิม = ฉากขวากลับมา
    if (_ovTileScrollKey != '$kind-${p.hn}') {
      _ovTileScrollKey = '$kind-${p.hn}';
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ovTileScroll.value = 0.0);
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชนิดแจ้งเตือน (สีตามชนิด) + ที่อยู่ผู้ป่วย
          // ข้อความหัวกว้างคงที่ (_ovHeadW): ฉากหุบตอนเลื่อนไทล์แล้วข้อความไม่จัดบรรทัดใหม่
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _ovHeadW),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(label,
                      style: _t(12.0, color: col, weight: FontWeight.w700)),
                ),
                // มีงานถึงเวลาด้วย (รอบแนวโน้ม): ป้ายที่สองต่อท้าย
                if (kind != 8 && trows.isNotEmpty) ...[
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text('ถึงเวลาดูแล',
                        style: _t(12.0, color: _blue, weight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(where,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
                ),
              ])),
          const SizedBox(height: 6.0),
          // ชื่อ + ปุ่มดูเคสชิดขวาของชื่อ (ไม่บังไทล์)
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _ovHeadW),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                // รูปหน้าผู้ป่วย + ป้าย ESI / สายฟ้า fast track (ชิ้นเดียวกับรายชื่อ)
                SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: FittedBox(child: _rowAvatar(p)),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(22.0,
                          color: _inkTitle,
                          weight: FontWeight.w800,
                          height: 1.2)),
                ),
                // ปุ่มดูเคสหลังชื่อทุกรอบ (ถึงเวลาดูแลด้วย)
                ...[
                  const SizedBox(width: 10.0),
                  _Press(
                    child: GestureDetector(
                      onTap: () => _openPatient(p),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12.0, 5.0, 8.0, 5.0),
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('ดูเคส',
                              style: _t(12.5,
                                  color: Colors.white,
                                  weight: FontWeight.w600)),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16.0, color: Colors.white),
                        ]),
                      ),
                    ),
                  ),
                ],
              ])),
          // ข้อความใต้ชื่อ (ถึงเวลาดูแลอย่างเดียวไม่มี: การ์ดงานด้านล่างบอกครบแล้ว)
          if (tiles.isNotEmpty || trows.isEmpty) ...[
            const SizedBox(height: 2.0),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _ovHeadW),
              child: Text(msg,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.0,
                      color: _ink2, weight: FontWeight.w500, height: 1.5)),
            ),
          ],
          const SizedBox(height: 6.0),
          // รายละเอียด: แนวโน้ม = ไทล์ต่อค่า (ค่าล่าสุดใหญ่ · ต่างจากเดิม · กราฟทุกรอบบนแถบช่วงปกติ)
          // ถึงเวลาดูแล = รายการงานที่เลยเวลา
          if (tiles.isNotEmpty) ...[
            // ล้นความกว้าง = เลื่อนแนวนอนได้ · ขยายพื้นที่เลื่อนเข้าไปในระยะขอบซ้าย 24
            // (เลื่อนแล้วไทล์ล้นออกซ้ายได้) ฟุ้งจางทั้งสองขอบ
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Flexible(
                child: Transform.translate(
                  offset: const Offset(-24.0, 0.0),
                  // ขอบขวาจาง (ยังมีต่อ) เฉพาะตอนฉากกาง · เลื่อนแล้ว (ไทล์ทับหน้าฉาก) = ไม่จาง ไทล์เลื่อนพ้นขอบแผงตรง ๆ
                  child: ValueListenableBuilder<double>(
                    valueListenable: _ovTileScroll,
                    builder: (context, t, child) => ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => LinearGradient(
                        colors: const [
                          Color(0x00FFFFFF),
                          Colors.white,
                          Colors.white,
                          Color(0x00FFFFFF)
                        ],
                        stops: [0.0, 20.0 / r.width, 0.84 + 0.16 * t, 1.0],
                      ).createShader(r),
                      child: child,
                    ),
                    // เลื่อนดูไทล์ = ฉากขวาหุบตามระยะเลื่อน (120 = หุบสุด)
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (n) {
                        if (n.depth == 0 && n.metrics.axis == Axis.horizontal) {
                          _ovTileScroll.value =
                              (n.metrics.pixels / 120.0).clamp(0.0, 1.0);
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _ovTileCtl,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                            left: 24.0, right: 40.0, bottom: 10.0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          // งานที่ถึงเวลา (เร่งกว่า) ขึ้นก่อนไทล์สัญญาณชีพ · การ์ดเดียวกับกองการ์ดงาน
                          for (final r in trows) ...[
                            SizedBox(
                                width: 230.0,
                                height: 128.0,
                                child: _ovTaskCard(p.hn, r)),
                            const SizedBox(width: 8.0),
                          ],
                          for (final (i, (lb, series, a, b, lo, hi, _))
                              in tiles.indexed) ...[
                            if (i > 0) const SizedBox(width: 8.0),
                            // ไทล์แบบตารางสัญญาณชีพหน้าผู้ป่วย: หัว bento (ชื่อ + เหรียญเตือน · การเปลี่ยนแปลงมุมขวาบน · ค่าล่าสุด)
                            // + ภาพประกอบ ghost ใต้ป้าย + กราฟแบบรายละเอียด (กะทัดรัด)
                            () {
                              final bad = b < lo || b > hi;
                              final v = ErVital(
                                icon: Icons.monitor_heart_outlined,
                                label: lb,
                                unit: _ovUnit(lb),
                                series: series,
                                color: bad ? _red : _inkTitle,
                                display: f(b),
                              );
                              final n = series.length;
                              return Container(
                                width: 180.0,
                                height: 128.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: _panel,
                                  gradient: bad
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                              Color(0xFFFFF6F5),
                                              Colors.white
                                            ],
                                          stops: [
                                              0.0,
                                              0.5
                                            ])
                                      : null,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                      color: const Color(0xFFDADCE0),
                                      width: 0.5),
                                ),
                                child: Stack(children: [
                                  Positioned(
                                    right: -12.0,
                                    top: 26.0,
                                    width: 44.0,
                                    height: 44.0,
                                    child: IgnorePointer(
                                        child: _vsArtImg(v, 0.15)),
                                  ),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // หัวเตี้ย (ที่ในไทล์จำกัด): ชื่อ + เหรียญ · ป้ายการเปลี่ยนแปลง / ค่าล่าสุด
                                        // ตัวอักษร/เหรียญ/ป้ายชุดเดียวกับหัว bento หน้าผู้ป่วย
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12.0, 8.0, 8.0, 0.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Text(lb,
                                                      style: _t(13.5,
                                                          color: _inkTitle,
                                                          weight:
                                                              FontWeight.w600)),
                                                  if (bad) ...[
                                                    const SizedBox(width: 6.0),
                                                    SizedBox.square(
                                                        dimension: 16.0,
                                                        child: FittedBox(
                                                            child: _vsBadCoin)),
                                                  ],
                                                  const Spacer(),
                                                  if (n > 1)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0,
                                                          vertical: 2.0),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFF1F2F4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      // เทียบกับค่าตั้งต้นของช่วงที่ข้อความการ์ดพูดถึง (เช่น 30 นาที)
                                                      child: _vsDeltaChip(
                                                          a, b, _ink2),
                                                    ),
                                                ]),
                                                const SizedBox(height: 2.0),
                                                Text.rich(TextSpan(children: [
                                                  TextSpan(
                                                      text: f(b),
                                                      style: _num(19.0,
                                                          color: bad
                                                              ? _vsHot
                                                              : _inkTitle,
                                                          weight:
                                                              FontWeight.w700)),
                                                  TextSpan(
                                                      text: ' ${_ovUnit(lb)}',
                                                      style: _t(11.0,
                                                          color: _ink3)),
                                                ])),
                                              ]),
                                        ),
                                        // กราฟแบบรายละเอียดหน้าผู้ป่วย (กะทัดรัด): แกนจุด + ขีดช่วงปกติ · ค่าทุกจุด · เวลารอบแรก/ล่าสุด
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                6.0, 0.0, 8.0, 4.0),
                                            child: CustomPaint(
                                              size: Size.infinite,
                                              painter: _VsDetailChart(
                                                compact: true,
                                                values: series,
                                                labels: [
                                                  for (final x in series) f(x)
                                                ],
                                                // เวลาของรอบท้าย ๆ ตามจำนวนค่า (เวลาไม่พอ = ว่าง)
                                                times: [
                                                  for (var i = 0; i < n; i++)
                                                    c.times.length - n + i >= 0
                                                        ? _clock(c.times[
                                                            c.times.length -
                                                                n +
                                                                i])
                                                        : ''
                                                ],
                                                lo: lo,
                                                hi: hi,
                                                openTop: lb.startsWith('SpO'),
                                                unit: _ovUnit(lb),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ]),
                              );
                            }(),
                          ],
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
          // งานที่เลยเวลา: การ์ดเรียงแนวนอนแบบไทล์สัญญาณชีพ (เวลา · งาน · เลยกี่นาที)
          if (trows.isNotEmpty && tiles.isEmpty)
            // bento: การ์ดงานหลักซ้อนเป็นกอง (หลายงาน = พลิกใบหน้าทบไปหลังกองทีละใบ)
            // ช่องขวา 2 ช่อง = ข้อมูลของใบที่อยู่หน้ากอง (เปลี่ยนตามใบที่พลิกขึ้นมา)
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 440.0, maxHeight: 140.0),
              child: _OvTaskStack(
                key: ValueKey('stack-${p.hn}'),
                cards: [for (final r in trows) _ovTaskCard(p.hn, r)],
                infos: [
                  for (final r in trows) _ovTaskInfo(p.hn, r).take(2).toList()
                ],
              ),
            ),
          // เวลาวัดล่าสุด (ปุ่มดูเคสอยู่ข้างชื่อ)
          // เวลาวัดล่าสุดอยู่ใน footer ของไทล์แล้ว
          if (meta.isNotEmpty && tiles.isEmpty) ...[
            const SizedBox(height: 2.0),
            Text(meta, style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
          ],
        ]);
  }

  /// รายละเอียดรายบุคคล: แย่ลง/ดีขึ้น = ค่าที่เปลี่ยน (ก่อน → ล่าสุด) · ถึงเวลา = งานแรกที่เลยเวลา
  String _ovWhoDetail(int kind, _P p) {
    if (kind == 8) {
      final now = DateTime.now();
      final hm =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final t = _ovCareTasks(p.hn)
          .where((t) =>
              !_isDone(t.title, p.hn) &&
              RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
              t.time.compareTo(hm) <= 0)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      if (t.isEmpty) return '';
      final more = t.length > 1 ? ' และอีก ${t.length - 1} งาน' : '';
      return '${t.first.title} ถึงเวลา ${_clock(t.first.time)}$more';
    }
    final c = erCaseOf(p.hn);
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    final out = <String>[];
    for (final (label, v, lo, hi, tol) in _ovVitalRanges(c)) {
      if (v.length < 2) continue;
      final a = v[math.max(0, v.length - 3)], b = v.last;
      final d0 = _ovOut(a, lo, hi), d1 = _ovOut(b, lo, hi);
      final hit = kind == 6
          ? d1 > d0 + tol || (d0 == 0 && d1 > 0)
          : d1 < d0 - tol || (d1 == 0 && d0 > 0);
      if (hit) out.add('$label ${f(a)} → ${f(b)}');
    }
    return out.take(3).join('  ');
  }

  /// ประเภทงานที่เลยเวลาของผู้ป่วย: (ภาพ 3D, นาทีที่เลยมากสุด, จำนวนงาน, งานที่เลยนานสุด)
  /// เรียงเลยนานก่อน สูงสุด 3 ประเภท
  List<(String, int, int, String)> _ovDueKinds(_P p) {
    final now = DateTime.now();
    final m = now.hour * 60 + now.minute;
    final by = <String, (int, int, String)>{};
    for (final t in _ovCareTasks(p.hn)) {
      if (_isDone(t.title, p.hn) ||
          !RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time)) {
        continue;
      }
      final d = m -
          (int.parse(t.time.substring(0, 2)) * 60 +
              int.parse(t.time.substring(3)));
      if (d <= 0) continue;
      final k = _ovTaskImg(t.title);
      final o = by[k];
      by[k] = o == null
          ? (d, 1, t.title)
          : (d > o.$1 ? d : o.$1, o.$2 + 1, d > o.$1 ? t.title : o.$3);
    }
    final out = [
      for (final e in by.entries) (e.key, e.value.$1, e.value.$2, e.value.$3)
    ]..sort((a, b) => b.$2 - a.$2);
    return out.take(3).toList();
  }

  /// ภาพ 3D ตามประเภทงาน (ชุดเดียวกับไอคอนหมวดในแฟ้มคำสั่ง)
  String _ovTaskImg(String title) {
    final n = title.toLowerCase();
    bool has(String re) => RegExp(re).hasMatch(n);
    if (has(r'x-?ray|cxr|\bct\b|film|mri|ultrasound|\bu/s\b')) {
      return 'assets/images/er_os_xray.png';
    }
    if (has(
        r'cbc|bun|\bcr\b|e.?lyte|electrolyte|dtx|lab|\bua\b|culture|lactate|lft|\binr\b|trop|glucose|hemoculture')) {
      return 'assets/images/er_os_lab.png';
    }
    if (has(r'\bmg\b|\bml\b|nss|acetar|ringer|\biv\b|load|tab|inj|ยา')) {
      return 'assets/images/er_os_med.png';
    }
    if (has(r'ekg|foley|ng tube|เย็บ|ทำแผล|ใส่|ดาม')) {
      return 'assets/images/er_os_proc_cap.png';
    }
    return 'assets/images/er_os_other.png';
  }

  static const _ovCardDeco = BoxDecoration(
    color: _panel,
    borderRadius: BorderRadius.all(Radius.circular(14.0)),
    boxShadow: [
      BoxShadow(
          color: Color(0x0F0B1B3F), blurRadius: 10.0, offset: Offset(0, 2)),
    ],
  );

  Widget _ovLateChip(int late) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(late < 1 ? 'ถึงเวลาแล้ว' : 'เลย $late นาที',
            style: _num(11.5, color: _red, weight: FontWeight.w700)),
      );

  /// การ์ดงานหลัก: ชื่องาน + ไอคอน · timeline รอบ · ชิปเลยเวลา + รอบที่
  Widget _ovTaskCard(String hn, (String, String, int) r) {
    final (tm, title, late) = r;
    final (d, n) = _ovRounds(hn, title);
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
      decoration: _ovCardDeco,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 8.0),
            Image.asset(_ovTaskImg(title), width: 26.0, height: 26.0),
          ]),
        ),
        _ovRoundTrack(hn, title, tm),
        const SizedBox(height: 2.0),
        Row(children: [
          _ovLateChip(late),
          const Spacer(),
          if (n > 1)
            Text('รอบ ${d + 1}/$n',
                style: _num(11.0, color: _ink3, weight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  /// ช่องข้อมูลเล็กของ bento: ไอคอนในเหรียญ · ป้ายเทา · ค่าตัวหนา
  Widget _ovInfoTile(IconData icon, String label, String value) => Container(
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
        decoration: _ovCardDeco,
        child: Row(children: [
          SizedBox(
            width: 30.0,
            height: 30.0,
            child: FittedBox(child: _SoStatusCoin.field(icon)),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                  const SizedBox(height: 1.0),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
                ]),
          ),
        ]),
      );

  /// ข้อมูลงานหลักสำหรับช่อง bento: รอบถัดไป · ทำล่าสุด · ผู้สั่ง (เท่าที่มี ตามลำดับ)
  List<Widget> _ovTaskInfo(String hn, (String, String, int) r) {
    final (tm, title, _) = r;
    final (d, n) = _ovRounds(hn, title);
    final m = RegExp(r'ทุก\s*(\d+)\s*(นาที|ชม)').firstMatch(title);
    final step =
        m == null ? 0 : int.parse(m.group(1)!) * (m.group(2) == 'ชม' ? 60 : 1);
    final out = <Widget>[];
    if (step > 0) {
      if (d + 1 < n) {
        final v = (int.parse(tm.substring(0, 2)) * 60 +
                int.parse(tm.substring(3)) +
                step) %
            (24 * 60);
        final hm =
            '${(v ~/ 60).toString().padLeft(2, '0')}:${(v % 60).toString().padLeft(2, '0')}';
        out.add(_ovInfoTile(Icons.schedule_rounded, 'รอบถัดไป', _clock(hm)));
      } else {
        out.add(_ovInfoTile(Icons.flag_rounded, 'รอบนี้', 'รอบสุดท้าย'));
      }
    }
    for (final ro in _repeatOrders[hn] ?? const <_RepeatOrder>[]) {
      if (ro.task.title == title && ro.done.isNotEmpty) {
        final (who, at) = ro.done.last;
        out.add(_ovInfoTile(
            Icons.check_circle_rounded, 'ทำล่าสุด ${_clock(at)}', who));
      }
    }
    for (final t in _ovCareTasks(hn)) {
      if (t.title == title) {
        out.add(_ovInfoTile(Icons.person_rounded, 'ผู้สั่ง', t.by));
        break;
      }
    }
    return out;
  }

  /// (ทำแล้วกี่รอบ, ทั้งหมดกี่รอบ) ของงาน · ×N ในชื่อ = จำนวนรอบ · รอบที่ทำแล้วจากคำสั่งซ้ำ
  (int, int) _ovRounds(String hn, String title) {
    final n =
        int.tryParse(RegExp(r'×\s*(\d+)').firstMatch(title)?.group(1) ?? '') ??
            1;
    var d = 0;
    for (final r in _repeatOrders[hn] ?? const <_RepeatOrder>[]) {
      if (r.task.title == title) d = r.done.length;
    }
    return (d.clamp(0, n), n);
  }

  /// timeline รอบของงาน (แบบตารางยา Apple Health): จุดต่อรอบบนเส้นเวลา + เวลาใต้จุด
  /// ทำแล้ว = จุดกรมท่ามีเครื่องหมายถูก · รอบที่เลย = จุดแดงมีวงฟุ้ง · ถัดไป = วงเทา
  /// [due] = เวลาของรอบที่ถึงแล้ว (HH:mm) · ช่วงห่างจาก "ทุก N นาที/ชม." ในชื่องาน
  Widget _ovRoundTrack(String hn, String title, String due) {
    final (d, n) = _ovRounds(hn, title);
    final m = RegExp(r'ทุก\s*(\d+)\s*(นาที|ชม)').firstMatch(title);
    final step =
        m == null ? 0 : int.parse(m.group(1)!) * (m.group(2) == 'ชม' ? 60 : 1);
    final dm =
        int.parse(due.substring(0, 2)) * 60 + int.parse(due.substring(3));
    String at(int i) {
      final v = (dm + (i - d) * step) % (24 * 60);
      return '${(v ~/ 60).toString().padLeft(2, '0')}:${(v % 60).toString().padLeft(2, '0')}';
    }

    // รอบเดียว / ไม่รู้ช่วงห่าง: แสดงแค่จุดเดียว (เวลาที่ถึง)
    final count = step == 0 ? 1 : n;
    final cur = step == 0 ? 0 : d;
    return TweenAnimationBuilder<double>(
      // เส้นวิ่งถึงรอบปัจจุบันครั้งเดียวตอนปรากฏ (ไม่วน)
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        double xOf(int i) =>
            count == 1 ? 11.0 : 11.0 + (w - 22.0) * i / (count - 1);
        final reach = xOf(cur) * t;
        return SizedBox(
          height: 39.0,
          child: Stack(clipBehavior: Clip.none, children: [
            // ราง + ช่วงที่ผ่านมาแล้ว (กรมท่าไล่ไปแดงที่รอบที่เลย) · งานครั้งเดียวไม่มีราง
            if (count > 1)
              Positioned(
                left: 11.0,
                right: 11.0,
                top: 10.0,
                height: 2.0,
                child: const ColoredBox(color: _line),
              ),
            if (cur > 0)
              Positioned(
                left: 11.0,
                width: math.max(0.0, reach - 11.0),
                top: 10.0,
                height: 2.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_blue, _red]),
                  ),
                ),
              ),
            for (var i = 0; i < count; i++) ...[
              // จุดรอบ = เหรียญสถานะ 2.5D ชุดเดียวกับแฟ้มคำสั่ง (ทำแล้ว · เลยเวลา · ถัดไป)
              Positioned(
                left: xOf(i) - 11.0,
                top: 0.0,
                width: 22.0,
                height: 22.0,
                child: Opacity(
                  opacity: i <= cur && xOf(i) > reach + 0.5 ? 0.0 : 1.0,
                  child: FittedBox(
                    child: i < cur
                        ? const _SoStatusCoin.done()
                        : i == cur
                            ? const _SoStatusCoin.abnormal()
                            : const _SoStatusCoin.wait(),
                  ),
                ),
              ),
              Positioned(
                // ปลายซ้าย/ขวาชิดขอบ (ไม่ล้นการ์ด) · ตรงกลางจัดกึ่งกลางจุด
                left: count == 1
                    ? 30.0
                    : i == 0
                        ? xOf(i) - 11.0
                        : i == count - 1
                            ? xOf(i) + 11.0 - 48.0
                            : xOf(i) - 24.0,
                width: count == 1 ? 140.0 : 48.0,
                top: count == 1 ? 3.0 : 25.0,
                child: Text(count == 1 ? 'ถึงเวลา ${at(i)} น.' : at(i),
                    textAlign: count == 1
                        ? TextAlign.left
                        : i == 0
                            ? TextAlign.left
                            : i == count - 1
                                ? TextAlign.right
                                : TextAlign.center,
                    style: _num(10.5,
                        color: i == cur ? _red : _ink3,
                        weight: i == cur ? FontWeight.w700 : FontWeight.w500)),
              ),
            ],
          ]),
        );
      }),
    );
  }

  /// งานที่พยาบาลต้องลงมือเองข้างเตียง (หัตถการ ยา อื่น ๆ) · ไม่รวมสั่ง Lab/X-ray
  /// (ส่งทางคอมแล้วรอผล ไม่ใช่งานค้างที่ต้องทำ)
  /// คำสั่งชุดตัวอย่างกลาง (_soHistory) ใช้ร่วมทุกคน = ไม่ใช่งานจริงของคนนั้น ไม่นับ
  /// (ไม่งั้นทุกคนขึ้น "0.9% NSS load" / "On oxygen" เหมือนกันหมด) · นับเฉพาะคำสั่งที่บันทึกของคนนั้น
  List<_Task> _ovCareTasks(String hn) {
    final shared = {
      if ((_soSaved[hn] ?? const []).isEmpty)
        for (final r in _soHistory)
          for (final it in r.items) it.$1
    };
    return [
      for (final t in _tasksOfHn(hn))
        if (!shared.contains(t.title) &&
            switch (_ovTaskImg(t.title)) {
              'assets/images/er_os_lab.png' ||
              'assets/images/er_os_xray.png' =>
                false,
              _ => true,
            })
          t
    ];
  }

  /// งานที่ถึงเวลาแล้วยังไม่ได้ทำของผู้ป่วย (เวลาสั่ง ≤ ตอนนี้)
  int _ovDueOf(_P p) {
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return _ovCareTasks(p.hn)
        .where((t) =>
            !_isDone(t.title, p.hn) &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(t.time) &&
            t.time.compareTo(hm) <= 0)
        .length;
  }

  /// ภาพรวมห้องฉุกเฉินแบบฉากเต็มพื้นที่ (ref GUNKUL hero):
  /// พื้น = ภาพห้อง ER เบลอเต็ม section ย้อมสีตามรอบที่วน (ภาพรวม = น้ำเงิน · ESI = สีระดับ)
  /// กลาง = วงแก้ว + donut ESI + ภาพเตียง (เตียงล้นพ้นวงออกมา) · ซ้าย = ตัวเลขใหญ่ของรอบนั้น
  /// ขวา = แถบแก้ว ESI 5 ระดับ (แตะ = กรอง หยุดวน) · วนอัตโนมัติ ภาพรวม → ESI ที่มีผู้ป่วย
  Widget _ovCircles(List<_P> all) {
    final n = {
      for (final e in _Esi.values) e: all.where((p) => p.esi == e).length
    };
    // แจ้งเตือนไม่อยู่ในรอบวนแล้ว (แสดงเป็นการ์ดซ้อนใต้ headline แทน) · โค้ดรอบแจ้งเตือน (-1) เก็บไว้
    final hot = _allAlerts.where((a) => a.level == _Level.critical).toList();
    // รอบเพิ่ม: 6 = แนวโน้มแย่ลง · 7 = แนวโน้มดีขึ้น · 8 = ถึงเวลาดูแล (มีผู้ป่วยถึงแสดง)
    final worse = [
      for (final p in all)
        if (_ovTrend(p) < 0) p
    ];
    final better = [
      for (final p in all)
        if (_ovTrend(p) > 0) p
    ];
    // seed งานของทุกคนก่อนคัด: งานที่ทำแล้วเก็บตามชื่องาน (ข้ามผู้ป่วย) และ seed ทีละคนตอนเรียกครั้งแรก
    // ไม่ seed ก่อน = คัดคนเข้ารอบตอนงานยังค้าง แล้ว headline ว่างเมื่อคนถัดไป seed ชื่องานซ้ำ
    for (final p in all) {
      _ovCareTasks(p.hn);
    }
    final due = [
      for (final p in all)
        if (_ovDueOf(p) > 0) p
    ];
    // แต่ละกลุ่มวนไม่เกิน 3 คน: แย่ลง/ดีขึ้น เรียงตาม ESI (ด่วนก่อน) · ถึงเวลา = มีงานค้างมากสุดก่อน
    int esiOf(_P p) => p.esi?.level ?? 9;
    // รายบุคคล: หนึ่งรอบต่อผู้ป่วยหนึ่งคน (รหัสรอบ 100 + ลำดับ) · (ชนิด 6/7/8, ผู้ป่วย)
    final people = [
      for (final p in ([...worse]..sort((a, b) => esiOf(a) - esiOf(b))).take(3))
        (6, p),
      for (final p
          in ([...better]..sort((a, b) => esiOf(a) - esiOf(b))).take(3))
        (7, p),
    ];
    // ถึงเวลาดูแล: คนที่อยู่ในรอบแนวโน้มแล้ว = งานแสดงในรอบเดิม (ไม่แยกรอบซ้ำ)
    // มีแนวโน้มแต่ไม่ติด 3 อันดับ = รอบแนวโน้มของคนนั้น (แสดงทั้งคู่) · ไม่มีแนวโน้ม = รอบถึงเวลา
    final shown = {for (final e in people) e.$2.hn};
    for (final p in ([...due]..sort((a, b) => _ovDueOf(b) != _ovDueOf(a)
            ? _ovDueOf(b) - _ovDueOf(a)
            : esiOf(a) - esiOf(b)))
        .take(3)) {
      if (shown.contains(p.hn)) continue;
      final t = _ovTrend(p);
      people.add((
        t < 0
            ? 6
            : t > 0
                ? 7
                : 8,
        p
      ));
    }
    final steps = [
      // story แรก = ภาพรวม แล้วไล่ ESI ที่มีผู้ป่วยทีละระดับในตัว (sub) · ต่อด้วยรายบุคคล
      0,
      for (var i = 0; i < people.length; i++) 100 + i,
    ];
    final manual = _ovDbg || _boardEsi != null || _boardFt;
    final levels = [
      for (final e in _Esi.values)
        if ((n[e] ?? 0) > 0) e.level,
    ];
    return _OvCycle(
        key: const ValueKey('ov-cycle-sub'),
        count: steps.length,
        paused: manual,
        // story ภาพรวม: ภาพรวม 1 จังหวะ + ESI ละ 1 จังหวะ (2.6 วิต่อจังหวะ) · story อื่น 7 วิ
        // ไม่ไล่ ESI ทีละระดับแล้ว: ทุก story จังหวะเดียว
        subsOf: (k) => 1,
        durationOf: (k) => const Duration(seconds: 7),
        builder: (k, sub, ctl) => LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              final cur = _ovDbg
                  ? _ovDbgCur
                  : manual
                      ? (_boardEsi ?? 0)
                      : steps[k % steps.length] == 0 && sub > 0
                          ? levels[(sub - 1).clamp(0, levels.length - 1)]
                          : steps[k % steps.length];
              final ce = cur <= 0 || cur > 5 ? null : _Esi.values[cur - 1];
              final who = cur >= 100 && cur - 100 < people.length
                  ? people[cur - 100]
                  : null;
              final alertStep = cur == -1;
              // รอบสถานะผู้ป่วย: (หัวข้อ, ชื่อ, คำอธิบาย, สี)
              final spec = switch (who?.$1) {
                6 => (
                    'แนวโน้มแย่ลง',
                    'Deteriorating',
                    'สัญญาณชีพรอบล่าสุดห่างจากค่าปกติมากขึ้น',
                    _red
                  ),
                7 => (
                    'แนวโน้มดีขึ้น',
                    'Improving',
                    'สัญญาณชีพรอบล่าสุดเข้าใกล้ค่าปกติ',
                    _green
                  ),
                8 => (
                    'ถึงเวลาดูแล',
                    'Care due',
                    'มีงานที่ถึงเวลาแล้วยังไม่ได้ทำ',
                    _blue
                  ),
                _ => null,
              };
              final whoP = who?.$2;
              // ฉากในวงของรอบสถานะ: ยืมฉากเดิม (แย่ลง = ดูแลบนเตียง · ดีขึ้น = นั่งรอสบาย · ถึงเวลา = พยาบาลเข็น)
              final scCur =
                  switch (who?.$1) { 6 => 1, 7 => 5, 8 => 3, _ => cur };
              // ฉากพื้นสว่างแบบแอป (ขาว → _bg) ตัวเลขกรมท่า เส้น _line
              // แสงฟุ้ง immersive ตามรอบ: ภาพรวม = กรมท่า · ESI = สีระดับ (เปลี่ยนสีแบบจางข้าม)
              final tint = alertStep ? _red : (spec?.$4 ?? ce?.color ?? _blue);
              if (_ovTint.value != tint) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _ovTint.value = tint);
              }
              // ฉากกลางชิดขวา (เหลือที่ซ้ายให้ headline)
              final cx = w - 116.0 - 48.0, cy = 152.0;
              // วงกลาง: รูปเว้นขอบ 14 (ชิดเส้นวง) · เดิมเว้น 34
              const big = 232.0, inner = big;
              // ฉากในวงต่อรอบ: ESI 5 = นั่งเล่นมือถือรอ (Figma 577:91) · ESI 4 = นั่งรอหน้าเคาน์เตอร์ (577:95) · ESI 3 = รถเข็นผู้ป่วย (577:103) · ESI 2 = ทีมเข็นเปล (569:81) · ESI 1 = พยาบาลดูแลผู้ป่วยบนเตียง (577:100) · อื่น ๆ = เตียง ER (564:26)
              // (ภาพเต็ม, ภาพตัดพื้นหลัง, ขนาดกรอบ, เลื่อน x/y จากจุดกลาง, เงาพื้น: กลาง x / กว้าง / y ตามสัดส่วนกรอบ)
              final sc = who?.$1 == 7
                  ? (
                      // อาการดีขึ้น: ผู้ป่วยนั่งพักบนเตียงยิ้ม (Figma 566:75)
                      img: 'assets/images/er_ov_better.jpg',
                      pop: 'assets/images/er_ov_better_pop.png',
                      // กรอบเดียวกับฉากแนวโน้มแย่ลง (er_ov_resus) = ขนาดเท่ากัน เปลี่ยนภาพไม่กระโดด
                      size: 256.0,
                      dx: -125.0,
                      dy: -134.0,
                      shX: 0.0,
                      shW: 0.0,
                      shY: 0.0,
                    )
                  : who?.$1 == 8
                      ? (
                          // ถึงเวลาดูแล: พยาบาลบันทึกงานข้างเตียงผู้ป่วย (Figma 682:454)
                          // ทั้งภาพในวง ล้นออกเฉพาะหัวกับไหล่พยาบาล (ภาพตัดช่วงบน ขอบขาวสติกเกอร์
                          // จางลงช่วงอก ตัวไล่จางช่วงเอวซึ่งอยู่ในวงแล้ว) · ผู้ป่วยบนเตียงอยู่ในวงขวา
                          img: 'assets/images/er_ov_care.jpg',
                          pop: 'assets/images/er_ov_care_pop.png',
                          size: 260.0,
                          dx: -136.0,
                          dy: -84.0,
                          shX: 0.0,
                          shW: 0.0,
                          shY: 0.0,
                        )
                      : scCur == 5
                          ? (
                              // นั่งเล่นมือถือรอ (Figma 577:91): ทั้งภาพในวง ล้นออกเฉพาะหัว
                              img: 'assets/images/er_ov_nonurg.jpg',
                              pop: 'assets/images/er_ov_nonurg_pop.png',
                              size: 340.0,
                              dx: -135.0,
                              dy: -185.0,
                              shX: 0.0,
                              shW: 0.0,
                              shY: 0.0,
                            )
                          : scCur == 4
                              ? (
                                  // นั่งรอหน้าเคาน์เตอร์ (Figma 577:95): ทั้งภาพในวง ล้นออกเฉพาะหัว
                                  img: 'assets/images/er_ov_lessurg.jpg',
                                  pop: 'assets/images/er_ov_lessurg_pop.png',
                                  size: 361.0,
                                  dx: -178.0,
                                  dy: -186.0,
                                  shX: 0.0,
                                  shW: 0.0,
                                  shY: 0.0,
                                )
                              : scCur == 3
                                  ? (
                                      // พยาบาลเข็นรถเข็นผู้ป่วยเข้าห้องฉุกเฉิน (Figma 577:103): ล้นออกเฉพาะหัวพยาบาล
                                      img: 'assets/images/er_ov_urgent.jpg',
                                      pop: 'assets/images/er_ov_urgent_pop.png',
                                      size: 300.0,
                                      dx: -124.0,
                                      dy: -165.0,
                                      shX: 0.0,
                                      shW: 0.0,
                                      shY: 0.0,
                                    )
                                  : scCur == 2
                                      ? (
                                          // ทีมเข็นเปลลงจากรถพยาบาล (Figma 569:81): ทั้งภาพในวง ล้นออกเฉพาะหัวบุรุษพยาบาล
                                          img:
                                              'assets/images/er_ov_emergent.jpg',
                                          pop:
                                              'assets/images/er_ov_emergent_pop.png',
                                          size: 367.0,
                                          dx: -157.0,
                                          dy: -208.0,
                                          shX: 0.17,
                                          shW: 0.0,
                                          shY: 0.9,
                                        )
                                      : scCur == 1
                                          ? (
                                              // พยาบาลดูแลผู้ป่วยบนเตียง (Figma 577:100): ล้นออกเฉพาะหัวพยาบาลและหัวผู้ป่วย
                                              img:
                                                  'assets/images/er_ov_resus.jpg',
                                              pop:
                                                  'assets/images/er_ov_resus_pop.png',
                                              size: 256.0,
                                              dx: -125.0,
                                              dy: -134.0,
                                              shX: 0.0,
                                              shW: 0.0,
                                              shY: 0.0,
                                            )
                                          : (
                                              // ภาพรวม: โถงห้องฉุกเฉิน (Figma 646:111) เต็มวง ไม่มีภาพตัดล้น
                                              img:
                                                  'assets/images/er_ov_lobby.jpg',
                                              // มุมบนซ้ายของกำแพงป้าย ER โผล่พ้นขอบซ้ายบนของวง (ป้าย + คนอยู่ในวงครบ)
                                              pop:
                                                  'assets/images/er_ov_lobby_pop.png',
                                              size: 400.0,
                                              // มุมกำแพง (146, 113 ของภาพ 640) อยู่นอกขอบวง 40 px ตามแนวทแยง
                                              dx: -193.05,
                                              dy: -168.18,
                                              shX: 0.0,
                                              shW: 0.0,
                                              shY: 0.0,
                                            );
              final tune = _ovTune[sc.img] ?? (sc.size, sc.dx, sc.dy);
              final imgS = tune.$1, imgL = cx + tune.$2, imgT = cy + tune.$3;
              void setTune(double size, double dx, double dy) =>
                  setState(() => _ovTune[sc.img] = (
                        size.clamp(100.0, 420.0).roundToDouble(),
                        dx.roundToDouble(),
                        dy.roundToDouble()
                      ));
              // ความกว้างหัวซ้ายตอนฉากกาง (รายบุคคล: จบก่อนลูกศรที่ทะลุออกซ้ายของรูปทรง)
              final headBase =
                  math.max(130.0, cx - big / 2 - (whoP != null ? 40.0 : 34.0));
              _ovHeadW = headBase;
              return Stack(clipBehavior: Clip.none, children: [
                // ---- ฉากหลัง (immersive แต่โทนแอป): ภาพห้องเบลอ + ม่านขาว (ขอบทึบกว่า กลางเห็นห้อง)
                // ไล่ลงล่างจางหาพื้นบอร์ด (ขาว → _bg) ต่อเนื่องกับรายชื่อ
                Positioned.fill(
                  child: _ovHeroBackdrop(tint),
                ),
                // ---- ควบคุมเอง (แบบ IG story): แตะซ้าย 1/3 = ย้อน · ขวา = ถัดไป · กดค้าง = หยุด
                // อยู่ใต้ชั้นเนื้อหา (ปุ่ม/ชิปยังกดได้ตามปกติ)
                if (!manual)
                  Positioned.fill(
                    child: Row(children: [
                      for (final fwd in [false, true])
                        Expanded(
                          flex: fwd ? 2 : 1,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: fwd ? ctl.next : ctl.prev,
                            onLongPressStart: (_) => ctl.hold(true),
                            onLongPressEnd: (_) => ctl.hold(false),
                            // ปัด = อ่านที่ _OvCycleState (Listener) ทั้งพื้นที่ hero
                          ),
                        ),
                    ]),
                  ),
                // ---- ฉากขวา (วง + ภาพ + ลูกศร) ชิ้นเดียว อยู่ใต้หัวซ้าย: เลื่อนไทล์ในหัวรายบุคคล =
                // แถวไทล์ขยายกว้างทับหน้าฉาก ฉากถอยไปอยู่หลังไทล์ (ย่อนิด เลื่อนขวาลงเล็กน้อย) ตามระยะเลื่อน
                // ระหว่างไทล์ทับหยุดวนรอบ (กำลังอ่านไทล์) · เลื่อนกลับต้นแถว = ฉากกลับที่เดิม วนต่อ
                Positioned.fill(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _ovTileScroll,
                    builder: (context, t0, child) {
                      final t = whoP == null ? 0.0 : t0;
                      // หยุด/วนต่อเฉพาะตอนเปลี่ยนสถานะ (ไม่ทับการกดค้างหยุดของผู้ใช้)
                      if ((t > 0.0) != _ovTileHeld) {
                        _ovTileHeld = t > 0.0;
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => ctl.hold(_ovTileHeld));
                      }
                      if (t <= 0.0) return child!;
                      final e = Curves.easeInOutCubic.transform(t);
                      final sc = 1.0 - 0.08 * e;
                      final c = Offset(cx + 36.0 * e, cy + 10.0 * e);
                      // ถอยไปหลังไทล์ = กลายเป็น ghost: สีจางลงเกือบเทา + โปร่ง (ไม่แย่งสายตาจากไทล์)
                      final k = 1.0 - 0.85 * e;
                      const r = 0.2126, g = 0.7152, b = 0.0722;
                      return IgnorePointer(
                        child: Opacity(
                          opacity: 1.0 - 0.78 * e,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix([
                              r + (1 - r) * k, g - g * k, b - b * k, 0, 0, //
                              r - r * k, g + (1 - g) * k, b - b * k, 0, 0,
                              r - r * k, g - g * k, b + (1 - b) * k, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                            child: Transform(
                              transform: Matrix4.identity()
                                ..translateByDouble(c.dx, c.dy, 0.0, 1.0)
                                ..scaleByDouble(sc, sc, 1.0, 1.0)
                                ..translateByDouble(-cx, -cy, 0.0, 1.0),
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(clipBehavior: Clip.none, children: [
                      // ---- กลาง: วงแก้ว + donut + ภาพเตียงในวง (แตะ = ล้างตัวกรอง) · ภาพรวมไม่มีวง
                      Positioned(
                        left: cx - big / 2,
                        top: cy - big / 2,
                        width: big,
                        height: big,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _boardEsi = null;
                            _boardFt = false;
                          }),
                          // debug: กดค้าง = เปิด/ปิดตัวปรับภาพ · ระหว่างเปิด ลาก = เลื่อน บีบ = ย่อขยาย
                          onLongPress: kDebugMode
                              ? () => setState(() {
                                    _ovDbg = !_ovDbg;
                                    _ovDbgCur = cur;
                                  })
                              : null,
                          onScaleStart: _ovDbg ? (_) => _ovPinch0 = imgS : null,
                          onScaleUpdate: _ovDbg
                              ? (d) => setTune(
                                  d.pointerCount > 1
                                      ? _ovPinch0 * d.scale
                                      : imgS,
                                  tune.$2 + d.focalPointDelta.dx,
                                  tune.$3 + d.focalPointDelta.dy)
                              : null,
                          // รอบภาพรวม/ESI = วงกลม donut · รอบรายบุคคล = morph เป็น Star of Life (Figma 638:23)
                          // น้ำหนักรูป (ดาว, นาฬิกา): ภาพรวม/ESI = วงกลม · แย่ลง/ดีขึ้น = ดาว · ถึงเวลาดูแล = นาฬิกาจับเวลา
                          child: TweenAnimationBuilder<Offset>(
                            tween: Tween(
                                end: Offset(
                                    whoP != null && who!.$1 != 8 ? 1.0 : 0.0,
                                    whoP != null && who!.$1 == 8 ? 1.0 : 0.0)),
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeInOutCubic,
                            builder: (context, morph, _) => CustomPaint(
                              painter: _ErStarFrame(morph),
                              // รูปทรงดาว/นาฬิกา: กรอบ เส้นขอบ และรูป ใช้กรอบเดียวกัน (ชิดกันเต็มพื้นที่)
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  // หัวชี้วิ่งไปกลางช่องของระดับที่วนถึง (ภาพรวม = จุดบนสุด)
                                  builder: (context, t, child) =>
                                      TweenAnimationBuilder<double>(
                                    tween: Tween(
                                        end: _EsiDonutPainter.midOf([
                                      for (final e in _Esi.values) n[e] ?? 0
                                    ], cur > 5 ? 0 : cur)),
                                    duration: const Duration(milliseconds: 650),
                                    curve: Curves.easeInOutCubic,
                                    builder: (context, knob, child) =>
                                        CustomPaint(
                                      foregroundPainter: _EsiDonutPainter(
                                        // ภาพรวม: สัดส่วนอยู่ในพิซซ่าแล้ว วงนอกเหลือรางเปล่า
                                        counts: [
                                          for (final e in _Esi.values) n[e] ?? 0
                                        ],
                                        colors: [
                                          for (final e in _Esi.values) e.color
                                        ],
                                        sel: cur <= 0 || cur > 5 ? null : cur,
                                        t: t,
                                        knob: knob,
                                        morph: morph,
                                        solid: spec?.$4,
                                      ),
                                      child: child,
                                    ),
                                    child: child,
                                  ),
                                  // รูปทรงดาว/นาฬิกา: ขยายพื้นที่รูปเกือบเต็มกรอบ (วงกลมเว้น 24 แบบเดิม)
                                  child: Padding(
                                    padding: EdgeInsets.zero,
                                    // ภาพห้อง ER (Figma 564:26) ตัดในวง · ตำแหน่งเดียวกับชั้นเตียงที่ล้นออก
                                    child: ClipPath(
                                      clipper: _ErStarClip(morph, slices: null),
                                      child: ColoredBox(
                                        color: const Color(0xFFEEF2F8),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          layoutBuilder: (c, prev) => Stack(
                                              clipBehavior: Clip.none,
                                              fit: StackFit.expand,
                                              children: [
                                                ...prev,
                                                if (c != null) c
                                              ]),
                                          // รอบแจ้งเตือน: กระดิ่งแกว่ง บนพื้นแดงอ่อน · รอบอื่น = ภาพฉาก
                                          child: alertStep
                                              ? Container(
                                                  key: const ValueKey(
                                                      'alert-bell'),
                                                  color:
                                                      const Color(0xFFFCE8E6),
                                                  alignment: Alignment.center,
                                                  child: _OvBell(
                                                      label: Text(
                                                          '${hot.length}',
                                                          style: _num(17.0,
                                                              color: _red,
                                                              weight: FontWeight
                                                                  .w800))),
                                                )
                                              : Stack(
                                                  key: ValueKey(sc.img),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                      // พื้นที่รูปกว้างขึ้นตามรูปทรง: ชดเชยตำแหน่ง + ขยายภาพให้เต็มแขนดาว/ตัวนาฬิกา
                                                      Positioned(
                                                        left: imgL -
                                                            (cx -
                                                                (inner +
                                                                        0.0 *
                                                                            (morph.dx + morph.dy).clamp(0.0,
                                                                                1.0)) /
                                                                    2),
                                                        top: imgT -
                                                            (cy -
                                                                (inner +
                                                                        0.0 *
                                                                            (morph.dx + morph.dy).clamp(0.0,
                                                                                1.0)) /
                                                                    2),
                                                        width: imgS,
                                                        height: imgS,
                                                        child: Transform.scale(
                                                          scale: 1.0 +
                                                              0.18 *
                                                                  (morph.dx +
                                                                          morph
                                                                              .dy)
                                                                      .clamp(
                                                                          0.0,
                                                                          1.0),
                                                          child: Image.asset(
                                                              sc.img,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                    ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // วงแหวนเวลา (รอบถึงเวลาดูแล): อยู่ใต้ตัวแบบที่ล้นวง (หัวพยาบาลทับวงแหวน ไม่โดนเส้นพาด)
                      // บนขอบตัวกลมของนาฬิกา (กลาง 0.56 · รัศมี 0.42 ของกรอบ) · กวาดครั้งเดียวต่อคน
                      if (who?.$1 == 8)
                        if (_ovDueKinds(whoP!) case final kinds
                            when kinds.isNotEmpty)
                          Positioned(
                            left: cx - big * 0.42 - 8.0,
                            top: cy - big / 2 + big * 0.56 - big * 0.42 - 8.0,
                            width: big * 0.84 + 16.0,
                            height: big * 0.84 + 16.0,
                            child: IgnorePointer(
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey('ring-${whoP.hn}'),
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, t, _) => CustomPaint(
                                  painter: _LateRingPainter(
                                      frac: (kinds.first.$2 / 60.0)
                                              .clamp(0.04, 1.0) *
                                          t),
                                ),
                              ),
                            ),
                          ),
                      // เงาพื้น + ตัวแบบตัดพื้นหลังล้นพ้นวงออกมา (เปลี่ยนฉากแบบจางข้าม)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            layoutBuilder: (c, prev) => Stack(
                                clipBehavior: Clip.none,
                                fit: StackFit.expand,
                                children: [...prev, if (c != null) c]),
                            // ตัวแบบล้นพ้นวง/รูปทรงออกมาทุกรอบ (ยกเว้นรอบแจ้งเตือน และภาพที่ไม่มีภาพตัด)
                            child: alertStep || sc.pop.isEmpty
                                ? const SizedBox.shrink(
                                    key: ValueKey('alert-nopop'))
                                : Stack(
                                    key: ValueKey(sc.pop),
                                    clipBehavior: Clip.none,
                                    children: [
                                        if (sc.shW > 0)
                                          Positioned(
                                            left: imgL +
                                                imgS * sc.shX -
                                                sc.shW / 2,
                                            top: imgT + imgS * sc.shY,
                                            width: sc.shW,
                                            height: 18.0,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.elliptical(
                                                        sc.shW / 2, 9.0)),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Color(0x1F0B1B3F),
                                                      blurRadius: 14.0,
                                                      spreadRadius: -2.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          left: imgL,
                                          top: imgT,
                                          width: imgS,
                                          height: imgS,
                                          // ขยายเท่ารูปในรูปทรง (ดาว/นาฬิกา) ให้ตัวแบบซ้อนตรงกัน
                                          child: Transform.scale(
                                              scale: whoP != null ? 1.18 : 1.0,
                                              child: Image.asset(sc.pop,
                                                  fit: BoxFit.cover)),
                                        ),
                                      ]),
                          ),
                        ),
                      ),
                      // อาการแย่ลง: ลูกศรพุ่งออกจากแขนซ้ายของดาว ผ่านหน้ารูป แล้วทะลุเลยขอบขวาออกไป
                      if (who?.$1 == 6)
                        Positioned(
                          left: cx - big / 2 + 10.0,
                          top: cy - big / 2 + 74.0,
                          width: big + 30.0,
                          height: big + 30.0,
                          // ส่วนในดาวถูกตัดตามรูปดาว (เป็นเนื้อเดียวกับรูป) · ส่วนที่พ้นขอบซ้ายล่างโผล่ทะลุออกมา
                          child: IgnorePointer(
                              child: ClipPath(
                                  clipper: const _TrendClip(
                                      Rect.fromLTWH(-10.0, -74.0, big, big)),
                                  // key ต่อคน: เปลี่ยนคนในกลุ่มเดียวกัน = เล่นท่าปรากฏใหม่
                                  child: _TrendDownMark(
                                      key: ValueKey('trend-${whoP!.hn}')))),
                        ),
                      // แนวโน้มดีขึ้น: ลูกศรเขียวพุ่งขึ้นซ้าย หางในดาว หัวทะลุมุมซ้ายบน (ฝั่งเดียวกับลูกศรแย่ลง)
                      if (who?.$1 == 7)
                        Positioned(
                          left: cx - big / 2 + 2.0,
                          top: cy - big / 2 + 30.0,
                          width: big + 30.0,
                          height: big + 30.0,
                          child: IgnorePointer(
                              child: ClipPath(
                                  clipper: const _TrendClip(
                                      Rect.fromLTWH(-2.0, -30.0, big, big),
                                      up: true),
                                  child: _TrendDownMark(
                                      key: ValueKey('trend-up-${whoP!.hn}'),
                                      up: true))),
                        ),
                      // ถึงเวลาดูแล: ภาพ 3D ประเภทงานที่เลยเวลา ในนาฬิกามุมขวาล่าง สลับทีละชิ้น
                      // อยู่บนวงแหวน (ไม่มีเส้นวงพาดทับของ) · ส่วนที่ล้นพ้นวงค่อย ๆ จางหาย
                      if (who?.$1 == 8)
                        if (_ovDueKinds(whoP!) case final kinds
                            when kinds.isNotEmpty)
                          Positioned(
                            left: cx - big / 2,
                            top: cy - big / 2,
                            width: big,
                            height: big,
                            child: IgnorePointer(
                                child: _CareDueObject(
                                    key: ValueKey(
                                        'care-${whoP.hn}-${kinds.map((k) => k.$1).join()}'),
                                    items: [for (final k in kinds) k.$1])),
                          ),
                      // ถึงเวลาดูแล: เหรียญกระดิ่ง (แจ้งเตือนพยาบาลแล้ว) ที่มุมล่างซ้ายของภาพหมวดงาน
                      // ตำแหน่งตามที่วางภาพใน _CareDueObject (กลางนาฬิกา 0.56 · รัศมี 0.42 · มุม 0.2π · ภาพ 86)
                      if (who?.$1 == 8)
                        if (_ovDueKinds(whoP!) case final kinds
                            when kinds.isNotEmpty)
                          Positioned(
                            left: cx - big / 2 + 132.0,
                            top: cy - big / 2 + 182.0,
                            width: 34.0,
                            height: 34.0,
                            child: IgnorePointer(
                              child:
                                  _OvNotify(key: ValueKey('notify-${whoP.hn}')),
                            ),
                          ),
                    ]),
                  ),
                ),
                // ---- ซ้าย: ตัวเลขใหญ่ของรอบนั้น
                // ฉากขวาหุบ (เลื่อนไทล์) = กว้างขึ้นจนเกือบเต็ม เว้นตัวบอกรอบขวา
                ValueListenableBuilder<double>(
                  valueListenable: _ovTileScroll,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (c, prev) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...prev, if (c != null) c]),
                      transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                              position: Tween(
                                      begin: const Offset(0.0, 0.12),
                                      end: Offset.zero)
                                  .animate(a),
                              child: c)),
                      // รอบแจ้งเตือน: แตะ headline = เปิดแผงแจ้งเตือน
                      child: whoP != null
                          ? KeyedSubtree(
                              key: ValueKey(cur),
                              child: _ovWhoHeadline(who!.$1, whoP, spec!.$1,
                                  spec.$4, steps, people, cur, tint))
                          : GestureDetector(
                              key: ValueKey(cur),
                              behavior: HitTestBehavior.opaque,
                              onTap: alertStep
                                  ? () => setState(() => _alertsOpen = true)
                                  : null,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        alertStep
                                            ? 'แจ้งเตือนวิกฤต'
                                            : spec != null
                                                ? spec.$1
                                                : ce == null
                                                    ? 'ผู้ป่วยในห้องฉุกเฉิน'
                                                    : 'ESI ${ce.level}',
                                        style: _t(13.0,
                                            color: _ink3,
                                            weight: FontWeight.w600)),
                                    Text.rich(
                                        TextSpan(children: [
                                          TextSpan(
                                              text: whoP != null
                                                  ? whoP.name
                                                  : '${alertStep ? hot.length : ce == null ? all.length : n[ce]}'),
                                          // ภาพรวม/ESI: หน่วย "ราย" ต่อท้ายตัวเลข
                                          if (whoP == null && !alertStep)
                                            TextSpan(
                                                text: ' ราย',
                                                style: _t(22.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w700)),
                                        ]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        // สีเดียวกับระดับ (ภาพรวม = กรมท่า) · ESI 3 ส้มเข้มขึ้นให้อ่านออกบนพื้นอ่อน (แบบ _esiBand)
                                        style: whoP != null
                                            ? _t(26.0,
                                                color: spec!.$4,
                                                weight: FontWeight.w800,
                                                height: 1.2)
                                            : _num(64.0,
                                                color: alertStep
                                                    ? _red
                                                    : spec != null
                                                        ? spec.$4
                                                        : ce == null
                                                            ? _blue
                                                            : ce.level == 3
                                                                ? Color.lerp(
                                                                    ce.color,
                                                                    Colors
                                                                        .black,
                                                                    0.25)!
                                                                : ce.color,
                                                weight: FontWeight.w800)),
                                    // ภาพรวม: ไม่มีบรรทัดชื่อ (ตัวเลข + ราย อ่านจบในตัว)
                                    if (!(ce == null &&
                                        whoP == null &&
                                        !alertStep))
                                      Text(
                                          alertStep
                                              ? 'รายการต้องดู'
                                              : whoP != null
                                                  ? [
                                                      if (whoP.bed != null)
                                                        'เตียง ${whoP.bed}',
                                                      if (whoP.esi != null)
                                                        'ESI ${whoP.esi!.level}',
                                                    ].join('  ')
                                                  : ce == null
                                                      ? ''
                                                      : ce.en,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: _t(20.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w800)),
                                    const SizedBox(height: 2.0),
                                    Text(
                                        maxLines: 2,
                                        alertStep
                                            ? 'ล่าสุด ${hot.first.time} น. ${hot.first.title}'
                                            : whoP != null
                                                ? _ovWhoDetail(who!.$1, whoP)
                                                : ce == null
                                                    ? 'เมื่อ ${_clock('${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}')}'
                                                    : '${(100 * (n[ce] ?? 0) / math.max(1, all.length)).round()}% ของผู้ป่วยในห้อง',
                                        style: _t(12.5,
                                            color: _ink2,
                                            weight: FontWeight.w500)),
                                    // ภาพรวม: แถบสัดส่วนแบ่งช่องตาม ESI (กว้างตามจำนวน) + ป้ายใต้แถบ · แตะช่อง = กรองระดับนั้น
                                    if (!alertStep &&
                                        whoP == null &&
                                        ce == null) ...[
                                      const SizedBox(height: 12.0),
                                      SizedBox(
                                        width: 300.0,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: SizedBox(
                                                  height: 14.0,
                                                  child: Row(children: [
                                                    for (final (i, e) in [
                                                      for (final e
                                                          in _Esi.values)
                                                        if ((n[e] ?? 0) > 0) e
                                                    ].indexed) ...[
                                                      if (i > 0)
                                                        const SizedBox(
                                                            width: 2.0),
                                                      Expanded(
                                                        flex: n[e]!,
                                                        child: GestureDetector(
                                                          onTap: () => setState(
                                                              () => _boardEsi =
                                                                  e.level),
                                                          child: Container(
                                                              color: e.color),
                                                        ),
                                                      ),
                                                    ],
                                                  ]),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Wrap(
                                                  spacing: 12.0,
                                                  runSpacing: 4.0,
                                                  children: [
                                                    for (final e in _Esi.values)
                                                      if ((n[e] ?? 0) > 0)
                                                        Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 8.0,
                                                                height: 8.0,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        e.color,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            2.0)),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4.0),
                                                              Text(
                                                                  'ESI ${e.level}',
                                                                  style: _t(
                                                                      11.5,
                                                                      color:
                                                                          _ink2,
                                                                      weight: FontWeight
                                                                          .w500)),
                                                              const SizedBox(
                                                                  width: 4.0),
                                                              Text('${n[e]}',
                                                                  style: _num(
                                                                      12.5,
                                                                      color:
                                                                          _inkTitle,
                                                                      weight: FontWeight
                                                                          .w700)),
                                                            ]),
                                                  ]),
                                            ]),
                                      ),
                                    ],
                                  ])),
                    ),
                  ),
                  builder: (context, t0, child) {
                    final t =
                        whoP == null ? 0.0 : Curves.easeOutCubic.transform(t0);
                    // ข้อความคงความกว้าง (_ovHeadW) · เฉพาะแถวไทล์ที่กว้างขึ้นตามฉากที่หุบ
                    final base = headBase;
                    return Positioned(
                      left: 24.0,
                      // กึ่งกลางแนวตั้งของฉาก (เว้นล่างให้ตัวบอกรอบ) ทุกรอบ
                      top: 16.0,
                      bottom: 0.0,
                      width: base + (w - 24.0 - base) * t,
                      child: child!,
                    );
                  },
                ),
                // ตัวบอกรอบ + ปุ่มอธิบาย อยู่เหนือแถวไทล์ (ไทล์เลื่อนพ้นขอบขวาลอดใต้)
                // ---- FYI มุมขวาล่าง: อธิบายว่าแนวโน้มแต่ละแบบคำนวณจากอะไร
                Positioned(
                  right: 10.0,
                  bottom: 10.0,
                  child: Tooltip(
                    message: 'แนวโน้มคำนวณอย่างไร',
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ctl.hold(true);
                          _ovTrendInfo().whenComplete(() => ctl.hold(false));
                        },
                        child: const SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: Icon(Icons.info_outline_rounded,
                              size: 18.0, color: _ink2),
                        ),
                      ),
                    ),
                  ),
                ),
                // ---- ตัวบอกรอบ (indicator) แนวตั้ง ชิดขวา กึ่งกลางแนวตั้ง · รอบปัจจุบัน = ขีดยาวสีตามรอบ · แตะ = ไปรอบนั้น
                Positioned(
                  right: 10.0,
                  top: 0.0,
                  bottom: 0.0,
                  width: 16.0,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      for (var i = 0; i < steps.length; i++) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => ctl.go(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Center(
                              // รอบปัจจุบัน = ขีดยาว เติมสีตามเวลาที่เหลือก่อนไปรอบถัดไป (บนลงล่าง)
                              // หยุดวน (กดค้าง/เลื่อนไทล์/กรองเอง) = การเติมหยุดตาม
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 6.0,
                                height: i == k % steps.length ? 22.0 : 6.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  // ขีดปัจจุบัน = ร่องขาว เติมกรมท่า (เห็นชัดทุกสีพื้น)
                                  color: i == k % steps.length
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.55),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x290B1B3F),
                                        blurRadius: 3.0),
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                alignment: Alignment.topCenter,
                                child: i == k % steps.length
                                    ? AnimatedBuilder(
                                        animation: ctl.progress,
                                        builder: (context, _) =>
                                            FractionallySizedBox(
                                          heightFactor: manual
                                              ? 1.0
                                              : ctl.progress.value
                                                  .clamp(0.0, 1.0),
                                          widthFactor: 1.0,
                                          child: const DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: _blue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100.0)),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
                // สายรัดข้อมือ ESI ย้ายไปอยู่หัวส่วนรายชื่อผู้ป่วย (_esiFilterBar)
                // ---- ปุ่มควบคุมย้อน/ถัดไป: มุมขวาบน (คู่กัน) · ชั้นบนสุด ไม่ถูกวงกลางทับ
                if (!manual)
                  for (final fwd in [false, true])
                    Positioned(
                      right: fwd ? 16.0 : 58.0,
                      top: 12.0,
                      child: _Press(
                        child: GestureDetector(
                          onTap: fwd ? ctl.next : ctl.prev,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: _panel.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: _line, width: 0.5),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x140B1B3F), blurRadius: 8.0),
                              ],
                            ),
                            child: Icon(
                                fwd
                                    ? Icons.chevron_right_rounded
                                    : Icons.chevron_left_rounded,
                                size: 22.0,
                                color: _ink2),
                          ),
                        ),
                      ),
                    ),
                // แผงปรับภาพอยู่ชั้นบนสุด (ไม่ถูกสายรัดข้อมือทับ)
                if (_ovDbg)
                  // จำกัดให้อยู่ในฉาก: ส่วนที่พ้นขอบฉากแตะ/ลากไม่ได้ (hit test ไม่ถึง)
                  // เก็บค่าที่ clamp กลับ ลากครั้งต่อไปเริ่มจากตำแหน่งที่เห็นจริง
                  Positioned(
                    left: (_ovDbgPos = Offset(
                            _ovDbgPos.dx.clamp(0.0, math.max(0.0, w - 270.0)),
                            _ovDbgPos.dy.clamp(
                                0.0, math.max(0.0, box.maxHeight - 186.0))))
                        .dx,
                    top: _ovDbgPos.dy,
                    width: 270.0,
                    child: _ovDbgPanel(sc.img, tune, setTune),
                  ),
              ]);
            }));
  }

  /// แผงปรับภาพ (debug): เลือกฉาก · slider ขนาด/เลื่อน · คัดลอกค่าไปวางในโค้ด · รีเซ็ต
  Widget _ovDbgPanel(String img, (double, double, double) tune,
      void Function(double, double, double) set) {
    Widget slider(String label, double v, double min, double max,
            void Function(double) on) =>
        Row(children: [
          SizedBox(
              width: 40.0,
              child: Text(label,
                  style: _t(11.5,
                      color: const Color(0xB3FFFFFF),
                      weight: FontWeight.w600))),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                  trackHeight: 2.0,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Color(0x40FFFFFF),
                  thumbColor: Colors.white),
              child: Slider(
                  value: v.clamp(min, max), min: min, max: max, onChanged: on),
            ),
          ),
          SizedBox(
              width: 40.0,
              child: Text(v.toStringAsFixed(0),
                  textAlign: TextAlign.right,
                  style: _num(12.0,
                      color: Colors.white, weight: FontWeight.w700))),
        ]);
    Widget btn(String label, VoidCallback on) => GestureDetector(
          onTap: on,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(8.0)),
            child: Text(label,
                style: _t(11.5, color: Colors.white, weight: FontWeight.w600)),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: const Color(0xE60B1220),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // หัวแผง = ที่จับลาก (ย้ายแผงไปที่อื่นได้ ไม่บังภาพ)
        Row(children: [
          Expanded(
            // Listener อ่านการขยับนิ้วทุกทิศ · GestureDetector ลากเปล่าไว้ชนะรายการเลื่อน (scroll ไม่แย่ง)
            child: Listener(
              // เริ่มลากจากตำแหน่งที่แสดงจริง (หลัง clamp) ไม่สะสมค่าที่ล้นขอบ
              onPointerMove: (e) => setState(() => _ovDbgPos = Offset(
                  math.max(0.0, _ovDbgPos.dx + e.delta.dx),
                  math.max(0.0, _ovDbgPos.dy + e.delta.dy))),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (_) {},
                onHorizontalDragUpdate: (_) {},
                child: Row(children: [
                  const Icon(Icons.drag_indicator_rounded,
                      size: 16.0, color: Color(0x99FFFFFF)),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text('ปรับภาพ ${img.split('/').last}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ]),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _ovDbg = false),
            child: const Icon(Icons.close_rounded,
                size: 18.0, color: Colors.white),
          ),
        ]),
        const SizedBox(height: 6.0),
        // ฉาก: รวม + ESI 1–5
        Row(children: [
          for (var i = 0; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: GestureDetector(
                onTap: () => setState(() => _ovDbgCur = i),
                child: Container(
                  width: i == 0 ? 40.0 : 28.0,
                  height: 24.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        _ovDbgCur == i ? Colors.white : const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(i == 0 ? 'รวม' : '$i',
                      style: _t(11.5,
                          color: _ovDbgCur == i ? _inkTitle : Colors.white,
                          weight: FontWeight.w700)),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 4.0),
        slider('size', tune.$1, 100.0, 420.0, (v) => set(v, tune.$2, tune.$3)),
        slider('x', tune.$2, -260.0, 120.0, (v) => set(tune.$1, v, tune.$3)),
        slider('y', tune.$3, -280.0, 80.0, (v) => set(tune.$1, tune.$2, v)),
        Text('ลากในวง = เลื่อนภาพ บีบสองนิ้ว = ย่อขยาย',
            style: _t(10.5,
                color: const Color(0x99FFFFFF), weight: FontWeight.w500)),
        const SizedBox(height: 6.0),
        Row(children: [
          btn('คัดลอกค่า', () {
            Clipboard.setData(ClipboardData(
                text:
                    'size: ${tune.$1}, dx: ${tune.$2}, dy: ${tune.$3}, // $img'));
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                content: Text(
                    'คัดลอกแล้ว size ${tune.$1.toStringAsFixed(0)} x ${tune.$2.toStringAsFixed(0)} y ${tune.$3.toStringAsFixed(0)}')));
          }),
          const SizedBox(width: 6.0),
          btn('รีเซ็ต', () => setState(() => _ovTune.remove(img))),
        ]),
      ]),
    );
  }

  /// สวิตช์ ผู้ป่วยของฉัน | ทั้งหมด (แพทย์เท่านั้น) มุมซ้ายบนของฉาก
  /// การ์ดขาวลอยเงานุ่ม: หัวเล็ก "ผู้ป่วยที่แสดง" · แท็บใหญ่ (รูปแพทย์ + ของฉัน n | ทั้งหมด n)
  /// FYI ใต้แท็บ: ที่มาของ "ของฉัน" = แพทย์เวรที่พยาบาลคัดกรองเลือกตอนส่งตรวจ
  /// สวิตช์ ผู้ป่วยของฉัน | ทั้งหมด แบบกะทัดรัด: pill เดียว แตะสลับ
  /// [รูปแพทย์/ไอคอนกลุ่มคน] ข้อความโหมด + จำนวน + ไอคอนสลับ (บอกว่าแตะได้)
  /// ที่มาของ "ของฉัน" อยู่ใน tooltip (กดค้าง)
  Widget _boardMineToggle(List<_P> all) {
    final me = ErSession.instance.user;
    if (ErSession.instance.role != ErRole.doctor || me == null) {
      return const SizedBox.shrink();
    }
    final mine = _boardMine;
    final n = mine ? all.where(_isMine).length : all.length;
    return Tooltip(
      message: mine
          ? 'ผู้ป่วยของฉัน = พยาบาลคัดกรองเลือกคุณเป็นแพทย์เวรตอนส่งตรวจ'
          : 'ผู้ป่วยทั้งหมดในห้องฉุกเฉิน',
      child: _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _boardMine = !_boardMine);
          },
          // ภาษาเดียวกับปุ่มสลับมุมมองข้าง ๆ: สูง 34 ตัว 14 · ของฉัน = พื้นกรมท่าจาง (tonal)
          // ไม่ใช้กรมท่าทึบซ้ำกับปุ่มมุมมองที่เลือกอยู่ · ทั้งหมด = ไอคอน + ข้อความเทา
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 34.0,
            padding: EdgeInsets.fromLTRB(mine ? 4.0 : 10.0, 0.0, 12.0, 0.0),
            decoration: BoxDecoration(
              color: mine ? _blue.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              mine
                  ? CircleAvatar(
                      radius: 13.0, backgroundImage: AssetImage(me.face))
                  : const Icon(Icons.groups_rounded, size: 20.0, color: _ink2),
              const SizedBox(width: 6.0),
              Text(mine ? 'ของฉัน' : 'ทั้งหมด',
                  style: _t(14.0,
                      color: mine ? _blue : _ink2, weight: FontWeight.w600)),
              const SizedBox(width: 6.0),
              Text('$n',
                  style: _num(14.0,
                      color: mine ? _blue : _ink3, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }

  /// bottom sheet เลือกค่าตัวกรอง: หัวข้อ + แถวตัวเลือก (ซ้าย = widget ป้าย · ขวา = จำนวน + ติ๊กตัวที่เลือก)
  Future<void> _ovPickSheet<T>(String title, List<(T, Widget, int?)> opts,
      T current, void Function(T) onPick) {
    return _placedSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 520.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD5D8DD),
                        borderRadius: BorderRadius.circular(100.0)),
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(title,
                    style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(height: 8.0),
                for (final (v, label, n) in opts)
                  InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(ctx);
                      onPick(v);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: _line, width: 0.5))),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft, child: label)),
                        if (n != null)
                          Text('$n คน',
                              style: _num(14.0,
                                  color: _ink2, weight: FontWeight.w600)),
                        const SizedBox(width: 12.0),
                        SizedBox(
                          width: 22.0,
                          child: v == current
                              ? const Icon(Icons.check_rounded,
                                  size: 22.0, color: _blue)
                              : null,
                        ),
                      ]),
                    ),
                  ),
              ]),
        ),
      ),
    );
  }

  /// ตัวกรอง ESI ปุ่มเดียวในหัวรายชื่อ: ยังไม่กรอง = ไอคอน + "ESI" · กรองอยู่ = สายรัดข้อมือของระดับนั้น
  /// แตะ = เมนูสายรัดข้อมือ 5 ระดับ + ทุกระดับ
  Widget _esiFilterButton(List<_P> all) {
    final cur = _boardEsi == null ? null : _Esi.values[_boardEsi! - 1];
    return GestureDetector(
      onTap: () => _ovPickSheet<int>(
          'กรองระดับ ESI',
          [
            (
              0,
              Text('ทุกระดับ',
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
              all.length
            ),
            for (final e in _Esi.values)
              (
                e.level,
                SizedBox(
                  height: 28.0,
                  child: FittedBox(
                      child: _esiBand(null, e.color, esi: e, width: 124.0)),
                ),
                all.where((p) => p.esi == e).length
              ),
          ],
          _boardEsi ?? 0,
          (v) => setState(() => _boardEsi = v == 0 ? null : v)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 34.0,
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 0.0),
        decoration: BoxDecoration(
          color:
              cur == null ? Colors.transparent : _blue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (cur == null) ...[
            const _EsiLevelIcon(),
            const SizedBox(width: 6.0),
            Text('ESI', style: _t(14.0, color: _ink2, weight: FontWeight.w600)),
          ] else
            SizedBox(
              height: 22.0,
              child: FittedBox(
                  child: _esiBand(null, cur.color, esi: cur, width: 124.0)),
            ),
          const SizedBox(width: 2.0),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18.0, color: _ink3),
        ]),
      ),
    );
  }

  /// ชิปกลุ่มย่อย Fast track (แฟ้มที่มีผู้ป่วย) งอกออกทางขวาของปุ่ม Fast track
  /// ยืดความกว้าง + จาง เลื่อนเข้าจากขวา · เลือก = พื้นแดง ตัวขาว
  Widget _ftTypeChips(List<_P> all, double maxW) {
    final ftAll = all.where((p) => _ftOf(p.hn).isNotEmpty).toList();
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: !_boardFt
          ? const SizedBox(height: 34.0)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                      offset: Offset(-24.0 * (1 - v), 0.0), child: child)),
              // ปุ่มเดียวเลือกประเภท Fast track (เมนู) แทนชิปทุกประเภท
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: GestureDetector(
                  onTap: () => _ovPickSheet<String>(
                      'ประเภท Fast track',
                      [
                        (
                          '',
                          Text('ทุกประเภท',
                              style: _t(15.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                          ftAll.length
                        ),
                        for (final t in erFastTracks)
                          if (ftAll.any((p) => _ftOf(p.hn).containsKey(t.id)))
                            (
                              t.id,
                              _ftBadge(t.name),
                              ftAll
                                  .where((p) => _ftOf(p.hn).containsKey(t.id))
                                  .length
                            ),
                      ],
                      _boardFtType ?? '',
                      (id) => setState(
                          () => _boardFtType = id.isEmpty ? null : id)),
                  child: Container(
                    height: 34.0,
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
                    decoration: BoxDecoration(
                      color: _boardFtType != null
                          ? _ftRed
                          : const Color(0xFFFCE8E6),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                          _boardFtType == null
                              ? 'ทุกประเภท'
                              : (erFastTrackById(_boardFtType!)?.name ??
                                  _boardFtType!),
                          style: _t(13.0,
                              color:
                                  _boardFtType != null ? Colors.white : _ftRed,
                              weight: FontWeight.w600)),
                      const SizedBox(width: 2.0),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: _boardFtType != null ? Colors.white : _ftRed),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _boardFtChip(int n) {
    final on = _boardFt;
    final dim = _boardEsi != null && !on;
    return _Press(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _boardFt = !_boardFt;
            _boardFtType = null;
          });
          // เปิด Fast track: หุบ hero ให้รายชื่อขึ้นมาเต็ม (ยังไม่หุบเท่านั้น)
          if (_boardFt && _ovScroll.hasClients && _ovScroll.offset < 296.0) {
            _ovScroll.animateTo(296.0,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic);
          }
        },
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: dim ? 0.4 : 1.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              offset: Offset.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  // เลือกแล้ว: ไม่ลอย ไม่มีเงาแดงฟุ้ง (แบน ตาม design rules)
                ),
                // ป้ายแดง + นาฬิกา 3D ใหญ่ล้นขอบบน/ซ้าย (ท่า idle สายฟ้าหมุนเป็นรอบ ๆ แบบ hero)
                child: SizedBox(
                  height: 34.0,
                  child: Stack(clipBehavior: Clip.none, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 34.0,
                      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 14.0, 0.0),
                      alignment: Alignment.center,
                      // ยังไม่เลือก = ไม่มีพื้น ตัวแดง · เลือกแล้ว = แดงทึบ ตัวขาว
                      decoration: BoxDecoration(
                        color: on ? _ftRed : Colors.transparent,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('Fast track',
                          style: _t(14.0,
                              color: on ? Colors.white : _ftRed,
                              weight: FontWeight.w700)),
                    ),
                    // นาฬิกากึ่งกลางแนวตั้งของปุ่ม (สูง 34)
                    const Positioned(
                      left: 2.0,
                      top: 2.0,
                      width: 28.0,
                      height: 30.0,
                      child:
                          IgnorePointer(child: _StopwatchHero(boltScale: 1.3)),
                    ),
                  ]),
                ),
              ),
            )),
      ),
    );
  }

  /// section ของกลุ่ม ESI (ref แอปประกัน): หัวข้อใหญ่ + คำอธิบาย ซ้าย · ภาพประกอบระดับโผล่ขวา
  /// มีแสงสีระดับฟุ้งหลังภาพ · ใต้หัว = แผงโค้งพื้นสีระดับอ่อน ครอบการ์ดผู้ป่วย
  /// แถบล่างของแผง = สรุปของกลุ่ม (จำนวน + เกินเกณฑ์) · cards(cw) = การ์ดตามความกว้างที่เหลือในแผง
  Widget _esiSection(
      _Esi? e, List<_P> ps, List<Widget> Function(double cw) cards) {
    final col = e?.color ?? _ink3;
    // ภาพประกอบ: ตัวแบบตัดพื้นหลังชุดเดียวกับฉากภาพรวม มุมขวาบน ซ่อนปลายล่างไว้หลังแผง
    final fig = switch (e?.level) {
      1 => 'assets/images/er_ov_resus_fig.png',
      2 => 'assets/images/er_ov_emergent_fig.png',
      3 => 'assets/images/er_ov_urgent_fig.png',
      4 => 'assets/images/er_ov_lessurg_fig.png',
      5 => 'assets/images/er_ov_nonurg_fig.png',
      _ => null,
    };
    final sub = switch (e?.level) {
      1 => 'ต้องช่วยชีวิตทันที ทีมพร้อมข้างเตียง',
      2 => 'เสี่ยงสูง ต้องพบแพทย์ภายใน 10 นาที',
      3 => 'ต้องใช้ทรัพยากรหลายอย่าง เฝ้าสัญญาณชีพ',
      4 => 'ต้องใช้ทรัพยากรอย่างเดียว รอได้',
      5 => 'ไม่ต้องใช้ทรัพยากร ตรวจรักษาเบื้องต้น',
      _ => 'รอพยาบาลคัดกรองระดับความเร่งด่วน',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, right: 10.0),
      child: Stack(clipBehavior: Clip.none, children: [
        // ภาพประกอบอยู่หลังแผง (แบบ ref): ส่วนล่างถูกแผงบัง ดูเหมือนโผล่จากหลังแผง
        if (fig != null)
          Positioned(
            right: 34.0,
            top: 0.0,
            height: 96.0,
            child: IgnorePointer(
              child: Image.asset(fig, fit: BoxFit.contain),
            ),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ---- หัว: ข้อความซ้าย · ภาพวงกลมโผล่ขวา ทับขอบบนของแผง
          SizedBox(
            // หัวกระชับ (ชื่อ + คำอธิบาย) · ภาพประกอบสูง 96 โผล่ 60 ซ่อนหลังแผง 36 ยอดเสมอหัวข้อ
            height: 60.0,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 4.0,
                top: 0.0,
                right: 16.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // หัวข้อ = สายรัดข้อมือระดับ (ชิ้นเดียวกับการ์ดผู้ป่วย) ขนาดหัวข้อ · ยังไม่คัดกรอง = ข้อความ
                      e == null
                          ? Text('ยังไม่คัดกรอง',
                              style: _t(20.0,
                                  color: _inkTitle, weight: FontWeight.w700))
                          : Row(children: [
                              // คลี่ม้วนสายรัดตอนปรากฏ (ท่าเดียวกับการ์ดผู้ป่วย) · จำนวนอยู่บนสาย
                              SizedBox(
                                height: 24.0,
                                child: FittedBox(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.2, end: 1.0),
                                    duration:
                                        const Duration(milliseconds: 1100),
                                    builder: (context, v, _) => RepaintBoundary(
                                        child: _esiBand(null, col,
                                            esi: e, count: ps.length, t: v)),
                                  ),
                                ),
                              ),
                            ]),
                      const SizedBox(height: 4.0),
                      Text(sub,
                          maxLines: 2,
                          style:
                              _t(13.0, color: _ink2, weight: FontWeight.w500)),
                    ]),
              ),
            ]),
          ),
          // ---- แผง: พื้นสีระดับอ่อน มุมโค้ง · การ์ด 2 ใบต่อแถว · แถบสรุปล่าง
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // การ์ดผู้ป่วยแถวเดียว เลื่อนแนวนอน (เห็นพร้อมกัน ~2.2 ใบ บอกว่าเลื่อนต่อได้)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 10.0),
                    child: LayoutBuilder(
                      builder: (context, b) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cards(
                                (b.maxWidth / (ps.length > 2 ? 2.2 : 2) - 10.0)
                                    .floorToDouble())),
                      ),
                    ),
                  ),
                ]),
          ),
        ]),
      ]),
    );
  }

  /// ฉากหลังของภาพรวมด้านบน (สีระดับ + แสงส่องข้าง + ม่านขาว) · ใช้ทั้งในฉากและใต้มุมโค้งแผงรายชื่อ
  Widget _ovHeroBackdrop(Color tint) => IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(r),
          child: Stack(fit: StackFit.expand, children: [
            // ---- แสงสีของระดับ (immersive): พื้นอ่อนสีระดับทั้งฉาก + แสงส่องจากด้านข้าง
            // จางข้ามสีตอนเปลี่ยนรอบ · ภาพรวม = กรมท่า
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              color: Color.lerp(_panel, tint, 0.14),
            ),
            // แสงสีระดับส่องเข้ามาจากขอบซ้าย/ขวา (กลางฉากสว่าง ไม่มีแสงหลังวง)
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-1.15, 0.0),
                  radius: 0.95,
                  colors: [
                    tint.withValues(alpha: 0.38),
                    tint.withValues(alpha: 0.12),
                    tint.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.15, 0.0),
                  radius: 0.95,
                  colors: [
                    tint.withValues(alpha: 0.6),
                    tint.withValues(alpha: 0.22),
                    tint.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // ม่านขาวหลัง headline (ฟุ้งเป็นวง ไม่เป็นแถบ) ตัวเลข/ชื่อระดับไม่กลืนกับแสงสี
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.78, -0.05),
                  radius: 0.55,
                  colors: [
                    _panel.withValues(alpha: 0.85),
                    _panel.withValues(alpha: 0.5),
                    _panel.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _panel.withValues(alpha: 0.35),
                    _panel.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ]),
        ),
      );

  /// พื้นบอร์ดภาพรวม: _bg + สีย้อมของรอบที่วนอยู่ (เต็มแถวหน้า อยู่ใต้แผงรายชื่อด้วย)
  /// [corner] = เติมฉากหลังภาพรวมใต้มุมโค้งขวาบนของแผงรายชื่อ (สีต่อเนื่องกับขอบซ้ายของฉาก)
  /// เลื่อน/หุบ/จางตามภาพรวมด้านบนจริง (สูตรเดียวกับ [_HeroCollapse])
  /// เมนูตัวชี้วัด (ขวา = ข้อมูลเชิงลึก) ไม่มี hero: พื้นกลาง ขาวไล่ลงเป็น _bg ไม่มีสีย้อม/ฉากใต้มุมแผง
  Widget _ovBoardBg({bool corner = false}) => Container(
        color: _bg,
        child: Stack(children: [
          if (corner && !_kpiOpen)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              left: 108.0 + (_panelOpen ? _panelW : _railW) - 24.0,
              width: 48.0,
              top: 0.0,
              height: 296.0,
              child: AnimatedBuilder(
                animation: Listenable.merge([_ovScroll, _ovTint]),
                builder: (context, _) {
                  final o = _ovScroll.hasClients ? _ovScroll.offset : 0.0;
                  final shrink = o.clamp(0.0, 296.0);
                  final p = Curves.easeOut.transform(shrink / 296.0);
                  final w = MediaQuery.sizeOf(context).width -
                      108.0 -
                      (_panelOpen ? _panelW : _railW) +
                      24.0;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 296.0 - shrink,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.bottomCenter,
                          minHeight: 296.0,
                          maxHeight: 296.0,
                          child: Opacity(
                            opacity: 1.0 - (p * 1.8).clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0.0, shrink * 0.45),
                              // ฉากหลังวางตรงตำแหน่งจริง (เริ่มที่ขอบขวาแผง = x 24 ในช่องนี้) ขนาดเท่าฉากจริง
                              // ส่วนใต้มุม (x 0–24) = ภาพสะท้อนของขอบซ้ายฉาก สีต่อกันพอดี ไม่มีรอยต่อ
                              child: Stack(clipBehavior: Clip.none, children: [
                                Positioned(
                                  left: 24.0,
                                  top: 0.0,
                                  bottom: 0.0,
                                  width: w - 24.0,
                                  child: _ovHeroBackdrop(_ovTint.value),
                                ),
                                Positioned(
                                  left: 24.0 - (w - 24.0),
                                  top: 0.0,
                                  bottom: 0.0,
                                  width: w - 24.0,
                                  child: Transform.flip(
                                      flipX: true,
                                      child: _ovHeroBackdrop(_ovTint.value)),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // พื้นบอร์ด: สีย้อมของรอบที่วนอยู่ ไหลต่อจากฉากลงใต้หัวรายชื่อแล้วจางหาย (อยู่ใต้รายการ ไม่ทับเนื้อหา)
          Positioned(
            left: 0.0,
            right: 0.0,
            top: 0.0,
            height: 560.0,
            child: IgnorePointer(
              child: ValueListenableBuilder<Color>(
                valueListenable: _ovTint,
                builder: (context, tint, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _kpiOpen
                          ? [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.0),
                            ]
                          : [
                              tint.withValues(alpha: 0.16),
                              tint.withValues(alpha: 0.1),
                              tint.withValues(alpha: 0.04),
                              tint.withValues(alpha: 0.0),
                            ],
                      stops: const [0.0, 0.4, 0.62, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // มุมซ้ายของแผงรายชื่อ (ต่อกับแถบเมนู): พื้นสีเดียวกับแถบเมนู ไม่ใช่สีย้อมบอร์ด
          // (เดิมเห็นสีย้อมแทรกตรงมุมเว้าของแท็บที่เลือก)
          if (corner)
            const Positioned(
              left: 0.0,
              width: 108.0 + 24.0,
              top: 0.0,
              bottom: 0.0,
              child: ColoredBox(color: _bg),
            ),
        ]),
      );

  Widget _overviewBoard() {
    final all = [..._patients]..sort((a, b) {
        final e = (a.esi?.level ?? 9).compareTo(b.esi?.level ?? 9);
        return e != 0 ? e : b.waitMin.compareTo(a.waitMin);
      });
    final list = [
      for (final p in all)
        if ((_boardEsi == null || p.esi?.level == _boardEsi) &&
            (!_boardFt || _ftOf(p.hn).isNotEmpty) &&
            (!_boardFt ||
                _boardFtType == null ||
                _ftOf(p.hn).containsKey(_boardFtType)) &&
            (!_mineOn || _isMine(p)))
          p
    ];
    // เลื่อนรายชื่อขึ้น = visualize เลื่อนพ้นจอไป (แบบ SliverAppBar) · หัวข้อ + chip ค้างบนสุด
    final cardH = 206.0 + (_txtScale - 1.0) * 60.0;
    // ไม่มี padding ข้าง: ฉาก 3D เต็มความกว้างเป็นพื้นหลังของ section · ส่วนอื่นเว้น 16 เอง
    // ฉาก 3D ห้องฉุกเฉิน (three.js) = พื้นหลังของ section ขวา ไม่มีการ์ดครอบ ค้างอยู่กับที่
    // รายชื่อผู้ป่วยเลื่อนขึ้นมาทับขอบล่างของฉากเล็กน้อย (Flutter วาดทับ platform view ได้)
    // พื้นบอร์ด (_bg + สีย้อม) วาดแยกใน [_ovBoardBg] ใต้ทั้งแถวหน้า: ต่อเข้าใต้มุมโค้งแผงรายชื่อ
    return Container(
      child: Stack(children: [
        // ไม่เด้งเกินขอบบน (ดึงลงแล้วไม่เห็นพื้นว่างเหนือภาพรวม)
        // ปล่อยนิ้วกลางทางระหว่างฉากหุบ: ดูดเข้าเต็ม/หุบสุด (snap) ไม่ค้างครึ่ง ๆ
        Positioned.fill(
            child: NotificationListener<ScrollEndNotification>(
                onNotification: (n) {
                  final m = n.metrics;
                  if (n.depth == 0 && m.axis == Axis.vertical) {
                    // รายชื่อสั้น (เช่น กรอง Fast track) เลื่อนได้ไม่ถึงความสูงฉาก: ดูดเข้าสุดเท่าที่เลื่อนได้จริง
                    // เดิมดูดไป 296 ที่เลื่อนไม่ถึง = เลื่อนวนไม่จบ รายการไม่รับแตะ (กดอะไรไม่ได้)
                    final h = math.min(296.0, m.maxScrollExtent);
                    final o = m.pixels;
                    if (o > 0.5 && o < h - 0.5) {
                      final to = o < h * 0.4 ? 0.0 : h;
                      Future.microtask(() => _ovScroll.animateTo(to,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic));
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                    controller: _ovScroll,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      // พื้นที่โปร่งเหนือรายชื่อ: เห็นฉากด้านหลัง · หัวรายชื่อเริ่มที่ 306 ทับฐานแท่นเล็กน้อย
                      // ภาพรวมแบบวงกลมซ้อน (แทนฉาก 3D): อยู่ในรายการเลื่อน แตะวงได้ เลื่อนพ้นไปพร้อมรายชื่อ
                      // สวิตช์ของฉัน/ทั้งหมด + กระดิ่ง อยู่ในส่วนนี้ เลื่อนพ้นไปด้วย (ค้างเฉพาะ header)
                      // ฉากภาพรวมหุบแบบ sliver header ตอนเลื่อนลง: เลื่อนช้ากว่า (parallax) ย่อ + จางหาย
                      SliverPersistentHeader(
                          delegate: _HeroCollapse(
                              height: 296.0,
                              child: Stack(children: [
                                Positioned.fill(child: _ovCircles(all)),
                                // กระดิ่งแจ้งเตือนย้ายไปแท็บหัวขวา ข้างปุ่ม Fast track
                              ]))),
                      // ---- หัวข้อ + chip ระดับ ESI: ค้างบนสุดเมื่อเลื่อน
                      // ซ้าย 16 · ขวาไม่เว้น: แถวชิปเลื่อนล้นถึงขอบขวาของแผง (เว้นปลายใน scroll แทน)
                      SliverPadding(
                        padding: EdgeInsets.zero,
                        sliver: SliverPersistentHeader(
                          pinned: true,
                          delegate: _BoardHeader(
                            height: 60.0,
                            card: 1,
                            bg: _ovBoardBg(),
                            // หัว folder: แท็บขาว (หัวข้อ + สลับมุมมอง) ซ้ายบน ต่อเนื้อเดียวกับตัวการ์ดใหญ่
                            // ขวา: ตัวกรองลอยบนพื้นหน้า เหนือขอบบนของตัว folder
                            child: LayoutBuilder(builder: (context, hb) {
                              // ชิปกลุ่มย่อยกว้างได้ไม่เกินช่องว่างระหว่างแท็บซ้าย (~268) กับปุ่ม Fast track + ขอบ (~168)
                              final ftMaxW = hb.maxWidth - 268.0 - 168.0;
                              return Stack(children: [
                                Positioned(
                                  left: 10.0,
                                  top: 4.0,
                                  bottom: 0.0,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              6.0, 6.0, 0.0, 0.0),
                                          alignment: Alignment.topCenter,
                                          decoration: const BoxDecoration(
                                            color: _panel,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20.0)),
                                          ),
                                          child: _boardViewToggle(
                                              bare: true, mine: all),
                                        ),
                                        // มุมเว้า (fillet) ต่อแท็บกับขอบบนตัว folder
                                        const SizedBox(
                                            width: 20.0,
                                            child: CustomPaint(
                                                painter: _FolderFillet(
                                                    bodyTop: 42.0))),
                                      ]),
                                ),
                                // แท็บหัว folder ฝั่งขวา (กลับด้าน): มุมเว้าซ้าย + แท็บขาว ใส่ตัวกรอง Fast track
                                Positioned(
                                  right: 10.0,
                                  top: 4.0,
                                  bottom: 0.0,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(
                                            width: 20.0,
                                            child: CustomPaint(
                                                painter: _FolderFillet(
                                                    bodyTop: 42.0,
                                                    left: true))),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 5.0, 8.0, 0.0),
                                          alignment: Alignment.topCenter,
                                          decoration: const BoxDecoration(
                                            color: _panel,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20.0)),
                                          ),
                                          // เปิด Fast track: ชิปกลุ่มย่อยงอกออกทางขวาของปุ่ม (แท็บยืดไปทางซ้าย)
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _boardFtChip(all
                                                    .where((p) =>
                                                        _ftOf(p.hn).isNotEmpty)
                                                    .length),
                                                _ftTypeChips(all, ftMaxW),
                                              ]),
                                        ),
                                      ]),
                                ),
                              ]);
                            }),
                          ),
                        ),
                      ),
                      // ---- โหมดตาราง: หัวตารางค้างบนสุด (ต่อใต้หัวรายชื่อผู้ป่วย)
                      if (_boardTable)
                        SliverPadding(
                          padding: EdgeInsets.zero,
                          sliver: SliverPersistentHeader(
                            pinned: true,
                            delegate: _BoardHeader(
                                height: 38.0,
                                card: 2,
                                pad: const EdgeInsets.symmetric(
                                    horizontal: 22.0),
                                child: _boardTableHead()),
                          ),
                        ),
                      // ---- การ์ดผู้ป่วย 2 ใบต่อแถว เต็มความกว้าง
                      // การ์ดมีระยะขวา 10 ในตัว: เว้นขวา 6 ให้ขอบขวารวม 16 เท่าซ้าย
                      // การ์ดขาวใบใหญ่ช่วงล่าง (ต่อจากหัวรายชื่อ) มุมล่างโค้ง
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 24.0),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(12.0, 0.0, 2.0, 0.0),
                            decoration: const BoxDecoration(
                              color: _panel,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(24.0)),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ตัวกรองระดับ ESI (ย้ายจากฉากภาพรวม) บนสุดของส่วนรายชื่อ

                                  LayoutBuilder(builder: (context, box) {
                                    final alertHn = _footAlertHn;
                                    if (_boardTable) {
                                      // การ์ดเว้นขวา 6 · ตารางเว้นขวา 16 เท่าหัวตาราง
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, bottom: 40.0),
                                        child: Builder(builder: (_) {
                                          final sorted = _tblSorted(list);
                                          final pages =
                                              (sorted.length / _tblPer).ceil();
                                          if (_tblPage >= pages)
                                            _tblPage = math.max(0, pages - 1);
                                          final page = sorted
                                              .skip(_tblPage * _tblPer)
                                              .take(_tblPer)
                                              .toList();
                                          return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                _boardTableView(page),
                                                if (pages > 1) ...[
                                                  const SizedBox(height: 12.0),
                                                  _tblPager(
                                                      pages, sorted.length),
                                                ],
                                              ]);
                                        }),
                                      );
                                    }
                                    return Padding(
                                      // เลื่อนสุดแล้วการ์ดแถวสุดท้ายเห็นครบ พ้นมุมโค้งของจอ
                                      padding:
                                          const EdgeInsets.only(bottom: 40.0),
                                      // แตกเป็น section ตาม ESI (_esiSection) · ไม่มีระดับ = ยังไม่คัดกรอง (ท้ายสุด)
                                      child: Builder(builder: (_) {
                                        final groups = <(_Esi?, List<_P>)>[
                                          for (final e in [
                                            ..._Esi.values,
                                            null
                                          ])
                                            (
                                              e,
                                              [
                                                for (final p in list)
                                                  if (p.esi == e) p
                                              ]
                                            ),
                                        ]
                                            .where((g) => g.$2.isNotEmpty)
                                            .toList();
                                        var order = 0;
                                        // เปลี่ยนตัวกรอง = key ใหม่ → section/การ์ดเล่นท่าปรากฏใหม่ (เลื่อนขึ้น + จาง ไล่ทีละ section)
                                        return Column(
                                            key: ValueKey(
                                                'sec|$_boardEsi|$_boardFt|$_boardFtType|$_boardMine|$_boardTable'),
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (final (e, ps) in groups) ...[
                                                if (e != groups.first.$1)
                                                  const SizedBox(height: 16.0),
                                                _SectionIn(
                                                  index: groups.indexWhere(
                                                      (g) => g.$1 == e),
                                                  child: _esiSection(
                                                      e,
                                                      ps,
                                                      (cw) => [
                                                            for (final p in ps)
                                                              SizedBox(
                                                                height: cardH,
                                                                // แบ่งหมวดตาม ESI อยู่แล้ว (หัวกลุ่ม) = ไม่มีป้าย ESI ในการ์ด
                                                                child: _footCard(
                                                                    p,
                                                                    alertHn:
                                                                        alertHn,
                                                                    order:
                                                                        order++,
                                                                    width: cw,
                                                                    esiTag:
                                                                        false),
                                                              ),
                                                          ]),
                                                ),
                                              ],
                                            ]);
                                      }),
                                    );
                                  }),
                                ]),
                          ),
                        ),
                      ),
                    ]))),
      ]),
    );
  }
}

/// หัวรายชื่อที่ค้างบนสุดตอนเลื่อน (ความสูงคงที่)
class _BoardHeader extends SliverPersistentHeaderDelegate {
  _BoardHeader(
      {required this.height,
      required this.child,
      this.pad = EdgeInsets.zero,
      this.card = 0,
      this.bg});
  final double height;
  final Widget child;

  /// พื้นบอร์ด (สีย้อมเดียวกับพื้นหลัง) ใช้ทาหัวที่ค้างบนสุด · null = สีพื้นเรียบ
  final Widget? bg;

  /// การ์ดขาวใบใหญ่ครอบรายชื่อ: 0 = ไม่มี · 1 = ต้นการ์ด (มุมบนโค้ง) · 2 = ช่วงกลาง (ไม่โค้ง)
  final int card;

  /// ระยะของเนื้อหาข้างใน (ฝ้าเบลอเต็มความกว้าง ไม่โดนตัดที่ขอบเนื้อหา)
  final EdgeInsets pad;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  // อยู่เหนือฉาก = โปร่ง · ค้างบนสุดแล้วมีเนื้อหาลอดใต้ = ฝ้าเบลอฟุ้ง ๆ (ไม่ทาสีทึบ)
  Widget build(BuildContext context, double shrink, bool overlaps) {
    final frost = overlaps || shrink > 0;
    return ClipRect(
      child: Stack(fit: StackFit.expand, children: [
        // หัว folder ค้างบนสุด: พื้นทึบสีหน้า (ไม่ให้การ์ดลอดใต้ช่องว่างข้างแท็บ)
        if (frost && card == 1)
          Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              height: 46.0,
              // ค้างที่ขอบบนบอร์ดพอดี: วางพื้นบอร์ดชิดบน สีย้อมตรงกับข้างหลัง (ไม่เป็นแถบขาว)
              child: bg == null
                  ? const ColoredBox(color: _bg)
                  : ClipRect(
                      child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 560.0,
                          maxHeight: 560.0,
                          child: bg))),
        if (frost && card != 1)
          // ขอบล่างฟุ้งจางลง (ไม่เป็นเส้นตรงแข็ง)
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.7, 1.0],
            ).createShader(r),
            child: ErFrost(tint: _bg.withValues(alpha: 0.6)),
          ),
        if (card > 0)
          Padding(
            // card 1 = ตัว folder เริ่มที่ y 46 (แท็บหัวอยู่ซ้ายบน) มุมขวาบนโค้ง
            padding:
                EdgeInsets.fromLTRB(10.0, card == 1 ? 46.0 : 0.0, 10.0, 0.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panel,
                // card 1: มุมบนทั้งสองถูกแท็บซ้าย/ขวาคลุม = ไม่โค้ง
              ),
            ),
          ),
        Padding(padding: pad, child: child),
      ]),
    );
  }

  @override
  bool shouldRebuild(_BoardHeader o) => true;
}

/// donut สัดส่วนผู้ป่วยตาม ESI แบบเส้นเดียวไล่สีต่อเนื่อง (sweep gradient) เรียบ ไม่มีแสงฟุ้ง
/// สีเปลี่ยนนุ่ม ๆ ที่รอยต่อระดับ · หัวชี้ (knob) = มุมกลางช่องของระดับที่วนถึง วาดเป็นจุดขาวขอบสีระดับ
/// sel = ระดับที่วนถึง/กรอง (ช่วงนั้นหนาขึ้น) · t = กวาดเข้าตอนเปิด (0..1) · knob = มุม (rad, 0 = บนสุด)
class _EsiDonutPainter extends CustomPainter {
  const _EsiDonutPainter(
      {required this.counts,
      required this.colors,
      this.sel,
      this.t = 1.0,
      this.knob = 0.0,
      this.morph = Offset.zero,
      this.solid});
  final List<int> counts;

  /// น้ำหนักรูป (ดาว, นาฬิกา) · (0, 0) = วงกลม
  final Offset morph;

  /// รอบรายบุคคล: เส้นสีเดียวตลอดรอบ ไม่แบ่งช่อง ESI ไม่มีหัวชี้
  final Color? solid;
  final List<Color> colors;
  final int? sel;
  final double t;
  final double knob;

  /// มุมกลางช่องของระดับ (rad จากบนสุด ตามเข็ม) · 0 = ภาพรวม/ไม่มีผู้ป่วย
  static double midOf(List<int> counts, int level) {
    final total = counts.fold<int>(0, (a, b) => a + b);
    if (level <= 0 || total == 0) return 0.0;
    var acc = 0;
    for (var i = 0; i < level - 1; i++) {
      acc += counts[i];
    }
    return (acc + counts[level - 1] / 2) / total * math.pi * 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ไม่มีเส้นวง/หัวชี้แล้ว (ผู้ใช้ขอเอาออก) · สัดส่วน ESI ดูที่ชิปใต้หัวข้อ
    return;
    final total = counts.fold<int>(0, (a, b) => a + b);
    // เส้นวงบาง (รูปเต็มวงขึ้น)
    const w = 3.0;
    // เส้นรอบ Star of Life (แทนวงกลม) · ตำแหน่งตามสัดส่วนความยาวเส้น เริ่มกลางแขนบน ตามเข็ม
    // วงกลม = เส้นทับขอบรูปพอดี (รูปเว้น 4 ในกรอบนี้) · ดาว/นาฬิกา = เส้นตรงขอบรูปพอดี
    final mm = (morph.dx + morph.dy).clamp(0.0, 1.0);
    final star =
        _ovShapePath((Offset.zero & size).deflate(4.0 * (1.0 - mm)), morph);
    final m = star.computeMetrics().first;
    final len = m.length;
    // จุดเริ่ม = จุดบนเส้นที่ใกล้กลางขอบบนที่สุด
    var o0 = 0.0, best = double.infinity;
    final topMid = Offset(size.width / 2, 10.0);
    for (var d = 0.0; d < len; d += len / 400) {
      final p = m.getTangentForOffset(d)!.position;
      final e = (p - topMid).distanceSquared;
      if (e < best) {
        best = e;
        o0 = d;
      }
    }
    Path seg(double a, double b) {
      // a, b = สัดส่วน 0..1 ของรอบ (ห่อรอบได้)
      final s0 = (o0 + a * len) % len;
      final s1 = s0 + (b - a) * len;
      if (s1 <= len) return m.extractPath(s0, s1);
      return m.extractPath(s0, len)
        ..addPath(m.extractPath(0.0, s1 - len), Offset.zero);
    }

    Offset at(double f) =>
        m.getTangentForOffset((o0 + f * len) % len)!.position;
    // ราง
    canvas.drawPath(
        star,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    // รายบุคคล (ดาว/นาฬิกา): ไม่มีเส้นขอบ เหลือแต่รูปทรง
    if (solid != null) return;
    if (total == 0) return;
    // ช่วงของแต่ละระดับตามสัดส่วนผู้ป่วย (สีระดับ) · วาดทีละช่วงตามความคืบหน้า t
    var acc = 0.0;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      final a = acc / total, b = (acc + counts[i]) / total;
      acc += counts[i];
      final e = math.min(b, t);
      if (e <= a) continue;
      canvas.drawPath(
          seg(a, e),
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = sel == i + 1 && t >= 1.0 ? w + 3.0 : w
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
    // หัวชี้: จุดขาว ขอบสีตามตำแหน่ง
    if (t >= 1.0) {
      final p = at(knob / (math.pi * 2));
      final kc = sel != null ? colors[sel! - 1] : _blue;
      canvas.drawCircle(p, 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(
          p,
          6.5,
          Paint()
            ..color = kc
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(_EsiDonutPainter o) =>
      o.t != t ||
      o.sel != sel ||
      o.knob != knob ||
      o.morph != morph ||
      o.solid != solid ||
      o.counts.join() != counts.join();
}

/// ตัวนับรอบวนอัตโนมัติของภาพรวม (ค้างรอบละ 5 วินาที) · paused = ค้างไว้ (ผู้ใช้กรองเอง)
class _OvCycle extends StatefulWidget {
  const _OvCycle(
      {super.key,
      required this.count,
      required this.paused,
      required this.builder,
      required this.subsOf,
      required this.durationOf});
  final int count;
  final bool paused;
  final Widget Function(int k, int sub, _OvCycleState c) builder;

  /// จังหวะย่อยใน story (เช่น ภาพรวมไล่ ESI) และความยาวของแต่ละ story
  final int Function(int k) subsOf;
  final Duration Function(int k) durationOf;
  @override
  State<_OvCycle> createState() => _OvCycleState();
}

/// ตัววนรอบแบบ IG story: รอบละ 5 วิ (progress = แถบบนสุด) · แตะซ้าย/ขวา = ย้อน/ถัดไป ·
/// แตะแถบ = กระโดด · กดค้าง = หยุดชั่วคราว ปล่อย = เดินต่อ · paused (กรองเอง) = ไม่วน
class _OvCycleState extends State<_OvCycle>
    with SingleTickerProviderStateMixin {
  int _k = 0;
  int _sub = 0;
  late final AnimationController progress =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..addListener(() {
          final n = widget.subsOf(_k);
          final s = (progress.value * n).floor().clamp(0, n - 1);
          if (s != _sub && mounted) setState(() => _sub = s);
        })
        ..addStatusListener((st) {
          if (st == AnimationStatus.completed && mounted) {
            setState(() {
              _k = (_k + 1) % math.max(1, widget.count);
              _sub = 0;
            });
            _start();
          }
        });

  void _start() {
    progress.duration = widget.durationOf(_k);
    progress.forward(from: 0.0);
  }

  void _arm() {
    if (widget.paused || (widget.count < 2 && widget.subsOf(_k) < 2)) {
      progress.stop();
      return;
    }
    _start();
  }

  /// ไปรอบ i (วนรอบ) แล้วนับ 5 วิใหม่
  void go(int i) {
    if (widget.count == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _k = (i % widget.count + widget.count) % widget.count;
      _sub = 0;
    });
    if (!widget.paused) _start();
  }

  /// ถัดไป: มีจังหวะย่อยเหลือ = ไปจังหวะถัดไป · ครบ = story ถัดไป
  void next() {
    final n = widget.subsOf(_k);
    if (_sub < n - 1) {
      HapticFeedback.selectionClick();
      final to = (_sub + 1) / n;
      setState(() => _sub += 1);
      if (!widget.paused) progress.forward(from: to);
      return;
    }
    go(_k + 1);
  }

  /// ย้อน: อยู่ในจังหวะย่อย (ไล่ ESI) = ถอยทีละจังหวะ · จังหวะแรก = story ก่อนหน้า
  void prev() {
    final n = widget.subsOf(_k);
    if (_sub > 0 && n > 1) {
      HapticFeedback.selectionClick();
      final to = (_sub - 1) / n;
      setState(() => _sub -= 1);
      if (!widget.paused) progress.forward(from: to);
      return;
    }
    go(_k - 1);
  }

  /// กดค้าง = หยุด · ปล่อย = เดินต่อจากจุดเดิม
  /// หยุดจากข้างนอก (เลื่อนไทล์ในหัวรายบุคคล): ตัวจับเวลาหลังแตะไม่เดินต่อเองจนกว่าจะปล่อย
  bool _held = false;

  void hold(bool on) {
    _held = on;
    if (widget.paused) return;
    on ? progress.stop() : progress.forward();
  }

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(_OvCycle old) {
    super.didUpdateWidget(old);
    if (old.paused && !widget.paused) {
      // กลับจากกรองเอง: เริ่มที่ภาพรวมใหม่ นับ 5 วิเต็ม
      _k = 0;
      _arm();
    } else if (!old.paused && widget.paused) {
      progress.stop();
    } else if (old.count != widget.count) {
      if (_k >= widget.count) _k = 0;
      _arm();
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    progress.dispose();
    super.dispose();
  }

  @override

  /// ผู้ใช้กำลังแตะ/เลื่อนในฉาก: หยุดวน · ไม่แตะครบ 6 วิ ค่อยเดินต่อจากจุดเดิม
  Timer? _idle;
  void touch() {
    if (widget.paused) return;
    progress.stop();
    _idle?.cancel();
    _idle = Timer(const Duration(seconds: 6), () {
      if (mounted && !widget.paused && !_held) progress.forward();
    });
  }

  // ปัดซ้าย/ขวา: อ่านจาก Listener (ได้ทุก pointer แม้ปุ่ม/การ์ด/รายการเลื่อนข้างในชนะ gesture ไปแล้ว)
  Offset? _down;
  DateTime _downAt = DateTime.now();
  // นิ้วนี้ลากตัวเลื่อนแนวนอนข้างใน (การ์ด V/S รายเตียง แถวชิป) ไปแล้ว = ไม่เปลี่ยนหน้า
  bool _inner = false;

  void _swipeEnd(Offset up) {
    final d0 = _down;
    _down = null;
    if (d0 == null || widget.paused || _inner) return;
    final d = up - d0;
    final ms = DateTime.now().difference(_downAt).inMilliseconds;
    // แนวนอนชัด (> 1.5 เท่าแนวตั้ง) · ไกลพอ หรือเร็วพอ
    if (d.dx.abs() < d.dy.abs() * 1.5) return;
    if (d.dx.abs() < 60.0 && !(d.dx.abs() > 30.0 && ms < 250)) return;
    d.dx < 0 ? next() : prev();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          _down = e.position;
          _downAt = DateTime.now();
          _inner = false;
          touch();
        },
        onPointerMove: (_) => touch(),
        onPointerUp: (e) {
          _swipeEnd(e.position);
          touch();
        },
        onPointerCancel: (e) => _swipeEnd(e.position),
        // ตัวเลื่อนแนวนอนข้างในเริ่มลากด้วยนิ้ว (มี dragDetails · เลื่อนเองไม่นับ)
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.horizontal && n.dragDetails != null) {
              _inner = true;
            }
            return false;
          },
          child: widget.builder(_k, widget.paused ? 0 : _sub, this),
        ),
      );
}

/// กระดิ่งแจ้งเตือนในวงภาพรวม: แกว่งเป็นช่วง ๆ (สั่น 3 ครั้งแล้วพัก) + ป้ายจำนวนแดง
class _OvBell extends StatefulWidget {
  const _OvBell({required this.label});
  final Widget label;
  @override
  State<_OvBell> createState() => _OvBellState();
}

class _OvBellState extends State<_OvBell> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          // 0..0.45 = แกว่งลดแรงลง · ที่เหลือพัก
          final v = _c.value;
          final a = v < 0.45
              ? math.sin(v / 0.45 * math.pi * 6) * 0.28 * (1 - v / 0.45)
              : 0.0;
          return Transform.rotate(
              angle: a, alignment: const Alignment(0.0, -0.8), child: child);
        },
        child: Stack(clipBehavior: Clip.none, children: [
          Icon(Icons.notifications_rounded, size: 96.0, color: _red),
          Positioned(
            right: -2.0,
            top: 4.0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 34.0),
              height: 34.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(17.0),
                border: Border.all(color: _red, width: 2.5),
              ),
              child: widget.label,
            ),
          ),
        ]),
      );
}

/// มุมเว้าระหว่างแท็บหัว folder กับขอบบนตัว folder (ขาว ลบวงกลมมุมขวาบน)
class _FolderFillet extends CustomPainter {
  const _FolderFillet({required this.bodyTop, this.left = false});
  final double bodyTop;

  /// left = มุมเว้าอยู่ซ้ายของแท็บ (แท็บฝั่งขวา) วงกลมที่ลบอยู่มุมซ้ายบน
  final bool left;
  @override
  void paint(Canvas canvas, Size size) {
    const r = 20.0;
    final sq = Path()..addRect(Rect.fromLTWH(0.0, bodyTop - r, r, r));
    final hole = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(left ? 0.0 : r, bodyTop - r), radius: r));
    canvas.drawPath(Path.combine(PathOperation.difference, sq, hole),
        Paint()..color = _panel);
  }

  @override
  bool shouldRepaint(_FolderFillet o) => o.bodyTop != bodyTop || o.left != left;
}

/// ฉากหัวหน้าภาพรวมที่หุบตอนเลื่อน: เนื้อหาสูงเต็มคงที่ แล้วเลื่อนขึ้นครึ่งเดียวของระยะหด
/// (parallax) ย่อเล็กน้อยจากด้านบน และจางหายก่อนหุบสุด
class _HeroCollapse extends SliverPersistentHeaderDelegate {
  _HeroCollapse({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => 0.0;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrink, bool overlaps) {
    final p = Curves.easeOut.transform((shrink / height).clamp(0.0, 1.0));
    // ลื่น: เนื้อหาวาดครั้งเดียว (RepaintBoundary) แล้วแค่เลื่อน (ไม่ย่อ ไม่ใช้ Opacity = ไม่ saveLayer)
    // จางด้วยม่านสีพื้นทับด้านบน (ถูกกว่า) ไล่จากบนลงล่างให้ขอบบนหายก่อน
    // ยังไม่เลื่อน = ไม่ตัดขอบ (ลูกศร/ตัวแบบล้นลงไปทับช่องว่างหัวรายชื่อได้) · เลื่อนแล้วค่อยตัด
    return ClipRect(
      clipBehavior: shrink > 0.5 ? Clip.hardEdge : Clip.none,
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: height,
        maxHeight: height,
        // จางเนื้อหาเอง (mask) ไม่ใช่ม่านสีพื้นทับ: พื้นบอร์ดมีสีย้อม ม่าน _bg เห็นเป็นแผ่นเทาไม่เนียน
        // โครงเดียวตลอด (ไม่สลับ widget = เนื้อหาไม่ถูกสร้างใหม่ตอนเริ่มเลื่อน) · ขอบบนหายก่อน ขอบล่างตามมา
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // ขอบล่างแตะหัวรายชื่อตลอด: ต้องจางหมดก่อนครึ่งทาง ไม่งั้นเห็นรอยตัดแข็งที่หัว
              Colors.black.withValues(alpha: 1.0 - (p * 3.0).clamp(0.0, 1.0)),
              Colors.black.withValues(alpha: 1.0 - (p * 1.8).clamp(0.0, 1.0)),
            ],
          ).createShader(r),
          child: Transform.translate(
            offset: Offset(0.0, shrink * 0.45),
            child: RepaintBoundary(child: child),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_HeroCollapse o) => true;
}

/// ท่าปรากฏของ section รายชื่อ (หลังเปลี่ยนตัวกรอง): เลื่อนขึ้น 16 + จางเข้า ไล่ลำดับ 70ms ต่อ section
class _SectionIn extends StatefulWidget {
  const _SectionIn({required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  State<_SectionIn> createState() => _SectionInState();
}

class _SectionInState extends State<_SectionIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 70 * widget.index.clamp(0, 6)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.0, 0.06), end: Offset.zero)
              .animate(_a),
          child: widget.child,
        ),
      );
}

/// เครื่องหมาย Star of Life (ER department · Figma 638:23) ในกรอบ r · เริ่มที่มุมบนซ้ายของแขนบน
Path _erStarPath(Rect r) {
  double x(double v) => r.left + v * r.width;
  double y(double v) => r.top + v * r.height;
  return Path()
    ..moveTo(x(0.38590), y(0.00425))
    ..cubicTo(
        x(0.40647), y(0.00360), x(0.42844), y(0.00430), x(0.44916), y(0.00433))
    ..cubicTo(
        x(0.50439), y(0.00441), x(0.55967), y(0.00399), x(0.61489), y(0.00458))
    ..cubicTo(
        x(0.61772), y(0.00438), x(0.63323), y(0.00696), x(0.63404), y(0.00865))
    ..cubicTo(
        x(0.64051), y(0.02214), x(0.63821), y(0.07841), x(0.63821), y(0.08944))
    ..lineTo(x(0.63815), y(0.20261))
    ..cubicTo(
        x(0.63807), y(0.22277), x(0.63735), y(0.24610), x(0.63902), y(0.26591))
    ..cubicTo(
        x(0.65083), y(0.26080), x(0.67691), y(0.24464), x(0.68975), y(0.23735))
    ..lineTo(x(0.79913), y(0.17520))
    ..cubicTo(
        x(0.81382), y(0.16689), x(0.85675), y(0.13894), x(0.86768), y(0.14265))
    ..cubicTo(
        x(0.87846), y(0.14630), x(0.91688), y(0.21853), x(0.92370), y(0.23008))
    ..lineTo(x(0.96573), y(0.30159))
    ..cubicTo(
        x(0.97596), y(0.31886), x(0.99236), y(0.34400), x(0.99831), y(0.36199))
    ..cubicTo(
        x(0.99693), y(0.36685), x(0.99504), y(0.37191), x(0.99101), y(0.37513))
    ..cubicTo(
        x(0.97982), y(0.38405), x(0.96498), y(0.39128), x(0.95248), y(0.39855))
    ..lineTo(x(0.83794), y(0.46369))
    ..cubicTo(
        x(0.82438), y(0.47133), x(0.78614), y(0.49154), x(0.77632), y(0.50073))
    ..cubicTo(
        x(0.78373), y(0.50679), x(0.81525), y(0.52378), x(0.82554), y(0.52954))
    ..lineTo(x(0.93180), y(0.59023))
    ..cubicTo(
        x(0.94978), y(0.60050), x(0.96837), y(0.60993), x(0.98577), y(0.62104))
    ..cubicTo(
        x(0.99560), y(0.62732), x(1.00138), y(0.63348), x(0.99600), y(0.64516))
    ..cubicTo(
        x(0.98876), y(0.66086), x(0.97968), y(0.67557), x(0.97094), y(0.69049))
    ..lineTo(x(0.92758), y(0.76429))
    ..cubicTo(
        x(0.91749), y(0.78147), x(0.90753), y(0.79873), x(0.89772), y(0.81607))
    ..cubicTo(
        x(0.89018), y(0.82926), x(0.87554), y(0.86496), x(0.85708), y(0.85680))
    ..cubicTo(
        x(0.84121), y(0.84979), x(0.82605), y(0.83994), x(0.81088), y(0.83144))
    ..lineTo(x(0.70178), y(0.76948))
    ..cubicTo(
        x(0.68642), y(0.76059), x(0.65388), y(0.74052), x(0.63914), y(0.73426))
    ..cubicTo(
        x(0.63704), y(0.74846), x(0.63787), y(0.77403), x(0.63788), y(0.78897))
    ..lineTo(x(0.63795), y(0.90700))
    ..cubicTo(
        x(0.63798), y(0.92240), x(0.64009), y(0.98067), x(0.63348), y(0.99187))
    ..cubicTo(
        x(0.62833), y(0.99573), x(0.62113), y(0.99505), x(0.61466), y(0.99510))
    ..lineTo(x(0.46128), y(0.99463))
    ..cubicTo(
        x(0.43567), y(0.99463), x(0.40994), y(0.99536), x(0.38451), y(0.99513))
    ..cubicTo(
        x(0.37100), y(0.99499), x(0.36872), y(0.98892), x(0.36790), y(0.97702))
    ..cubicTo(
        x(0.36650), y(0.95665), x(0.36699), y(0.93464), x(0.36694), y(0.91427))
    ..lineTo(x(0.36692), y(0.79630))
    ..cubicTo(
        x(0.36696), y(0.78140), x(0.36780), y(0.74857), x(0.36564), y(0.73525))
    ..cubicTo(
        x(0.35260), y(0.73925), x(0.32162), y(0.75846), x(0.30818), y(0.76624))
    ..lineTo(x(0.20995), y(0.82244))
    ..cubicTo(
        x(0.19134), y(0.83315), x(0.17259), y(0.84365), x(0.15385), y(0.85453))
    ..cubicTo(
        x(0.13280), y(0.86676), x(0.12639), y(0.84783), x(0.11676), y(0.83254))
    ..cubicTo(
        x(0.11080), y(0.82307), x(0.10536), y(0.81240), x(0.09971), y(0.80256))
    ..lineTo(x(0.06484), y(0.74292))
    ..lineTo(x(0.03067), y(0.68471))
    ..cubicTo(
        x(0.02395), y(0.67327), x(-0.00323), y(0.63622), x(0.01159), y(0.62580))
    ..cubicTo(
        x(0.02883), y(0.61368), x(0.05006), y(0.60244), x(0.06864), y(0.59190))
    ..lineTo(x(0.19150), y(0.52199))
    ..cubicTo(
        x(0.19669), y(0.51902), x(0.22469), y(0.50413), x(0.22751), y(0.50148))
    ..cubicTo(
        x(0.22336), y(0.49055), x(0.04508), y(0.39896), x(0.01585), y(0.37727))
    ..cubicTo(
        x(0.01300), y(0.37516), x(0.01037), y(0.37285), x(0.00874), y(0.36966))
    ..cubicTo(
        x(0.00679), y(0.36584), x(0.00635), y(0.36093), x(0.00780), y(0.35688))
    ..cubicTo(
        x(0.01211), y(0.34477), x(0.02039), y(0.33309), x(0.02683), y(0.32193))
    ..lineTo(x(0.06746), y(0.25243))
    ..lineTo(x(0.10814), y(0.18295))
    ..cubicTo(
        x(0.11628), y(0.16904), x(0.12933), y(0.13385), x(0.14958), y(0.14410))
    ..cubicTo(
        x(0.16874), y(0.15380), x(0.18761), y(0.16530), x(0.20628), y(0.17608))
    ..cubicTo(
        x(0.24581), y(0.19907), x(0.28557), y(0.22166), x(0.32557), y(0.24385))
    ..cubicTo(
        x(0.33803), y(0.25072), x(0.35277), y(0.26092), x(0.36576), y(0.26555))
    ..cubicTo(
        x(0.36715), y(0.24302), x(0.36674), y(0.21709), x(0.36677), y(0.19430))
    ..lineTo(x(0.36674), y(0.08507))
    ..cubicTo(
        x(0.36673), y(0.06221), x(0.36629), y(0.03911), x(0.36753), y(0.01631))
    ..cubicTo(
        x(0.36808), y(0.00621), x(0.37819), y(0.00501), x(0.38590), y(0.00425))
    ..close();
}

/// พื้นกรอบรูปดาว: ขาว + เส้นขอบบาง (แทน BoxShape.circle)
class _ErStarFrame extends CustomPainter {
  const _ErStarFrame(this.morph);
  final Offset morph;
  @override
  void paint(Canvas canvas, Size size) {
    final p = _ovShapePath(Offset.zero & size, morph);
    canvas.drawPath(p, Paint()..color = _panel);
    // ขอบขาวแบบสติกเกอร์รอบรูป ระยะเท่ากันทุกรูปทรง (วงกลม ดาว นาฬิกา)
    canvas.drawPath(
        p,
        Paint()
          ..color = _panel
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(
        p,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(_ErStarFrame o) => o.morph != morph;
}

/// ตัดภาพฉากในวงเป็นรูปดาว
class _ErStarClip extends CustomClipper<Path> {
  const _ErStarClip(this.morph, {this.slices});
  final Offset morph;

  /// ภาพรวม: ตัดภาพเป็นชิ้นพิซซ่าตามจำนวนผู้ป่วยแต่ละ ESI (เริ่มบนสุด ตามเข็ม เว้นร่องระหว่างชิ้น)
  final List<int>? slices;
  @override
  Path getClip(Size size) {
    final r = Offset.zero & size;
    final total = slices?.fold<int>(0, (a, b) => a + b) ?? 0;
    if (slices == null || total == 0 || morph.distance > 0.01) {
      return _ovShapePath(r, morph);
    }
    final c = r.center;
    final rad = size.shortestSide / 2;
    const gap = 0.045; // ครึ่งร่องระหว่างชิ้น (rad)
    final path = Path();
    var acc = 0;
    final nz = slices!.where((x) => x > 0).length;
    for (final k in slices!) {
      if (k == 0) continue;
      final a0 = -math.pi / 2 + acc / total * math.pi * 2;
      final sw = k / total * math.pi * 2;
      acc += k;
      if (nz == 1) return Path()..addOval(r);
      // ชิ้นขยับออกจากกลางเล็กน้อย = เห็นร่องชัดแบบพิซซ่าที่ตัดแล้ว
      final mid = a0 + sw / 2;
      final off = Offset(math.cos(mid), math.sin(mid)) * 3.0;
      path.addPath(
          Path()
            ..moveTo(c.dx, c.dy)
            ..arcTo(Rect.fromCircle(center: c, radius: rad), a0 + gap,
                math.max(0.0, sw - gap * 2), false)
            ..close(),
          off);
    }
    return path;
  }

  @override
  bool shouldReclip(_ErStarClip o) =>
      o.morph != morph || o.slices?.join() != slices?.join();
}

/// รูปกรอบกลางหน้าภาพรวม: ผสมวงกลม / Star of Life / นาฬิกาจับเวลา ตามน้ำหนัก w (ดาว, นาฬิกา)
/// แต่ละรูปสุ่มจุดเท่ากันตามความยาวเส้น เริ่มจุดใกล้กลางขอบบน วนตามเข็ม แล้วผสมทีละจุด
Path _ovShapePath(Rect r, Offset w) {
  const eps = 0.001;
  if (w.dx < eps && w.dy < eps) return Path()..addOval(r);
  if (w.dx > 1 - eps && w.dy < eps) return _erStarPath(r);
  if (w.dy > 1 - eps && w.dx < eps) return _erClockPath(r);
  const n = 240;
  final circle = [
    for (var i = 0; i <= n; i++)
      r.center +
          Offset(math.cos(-math.pi / 2 + i / n * math.pi * 2) * r.width / 2,
              math.sin(-math.pi / 2 + i / n * math.pi * 2) * r.height / 2)
  ];
  final star = w.dx > eps ? _ovSample(_erStarPath(r), r, n) : circle;
  final clock = w.dy > eps ? _ovSample(_erClockPath(r), r, n) : circle;
  final wc = (1.0 - w.dx - w.dy).clamp(0.0, 1.0);
  final path = Path();
  for (var i = 0; i <= n; i++) {
    final p = circle[i] * wc + star[i] * w.dx + clock[i] * w.dy;
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path..close();
}

/// สุ่ม n+1 จุดตามความยาวเส้นรอบนอก เริ่มจุดใกล้กลางขอบบน ทิศตามเข็ม (บนจอ)
List<Offset> _ovSample(Path shape, Rect r, int n) {
  final m = shape.computeMetrics().first;
  final len = m.length;
  var o0 = 0.0, best = double.infinity;
  final topMid = Offset(r.center.dx, r.top);
  for (var d = 0.0; d < len; d += len / 300) {
    final e = (m.getTangentForOffset(d)!.position - topMid).distanceSquared;
    if (e < best) {
      best = e;
      o0 = d;
    }
  }
  var pts = [
    for (var i = 0; i <= n; i++)
      m.getTangentForOffset((o0 + i / n * len) % len)!.position
  ];
  // ทิศ: shoelace บวก = ตามเข็มบนจอ (แกน y ลง) · ไม่ใช่ = กลับทิศ (คงจุดเริ่ม)
  var area = 0.0;
  for (var i = 0; i < n; i++) {
    area += pts[i].dx * pts[i + 1].dy - pts[i + 1].dx * pts[i].dy;
  }
  if (area < 0) pts = [pts.first, ...pts.sublist(1).reversed];
  return pts;
}

/// นาฬิกาจับเวลา (ถึงเวลาดูแล): ตัวกลม + ก้านและปุ่มบน + ปุ่มข้างเฉียงขวา · รวมเป็นเส้นรอบนอกเดียว
Path _erClockPath(Rect r) {
  final s = r.shortestSide;
  final c = Offset(r.center.dx, r.top + s * 0.56);
  final rad = s * 0.42;
  var p = Path()..addOval(Rect.fromCircle(center: c, radius: rad));
  Path rrect(Rect b, double rr) =>
      Path()..addRRect(RRect.fromRectAndRadius(b, Radius.circular(rr)));
  // ก้าน + ปุ่มกดบน
  p = Path.combine(
      PathOperation.union,
      p,
      rrect(
          Rect.fromCenter(
              center: Offset(c.dx, c.dy - rad - s * 0.04),
              width: s * 0.09,
              height: s * 0.12),
          s * 0.02));
  p = Path.combine(
      PathOperation.union,
      p,
      rrect(
          Rect.fromCenter(
              center: Offset(c.dx, c.dy - rad - s * 0.10),
              width: s * 0.24,
              height: s * 0.07),
          s * 0.035));
  // ปุ่มข้าง เฉียง 45° ขวาบน
  final side = rrect(
      Rect.fromCenter(center: Offset.zero, width: s * 0.10, height: s * 0.07),
      s * 0.02);
  final a = -math.pi / 4;
  final at = c + Offset(math.cos(a), math.sin(a)) * (rad + s * 0.02);
  final m4 = Matrix4.identity()
    ..translate(at.dx, at.dy)
    ..rotateZ(a + math.pi / 2);
  p = Path.combine(PathOperation.union, p, side.transform(m4.storage));
  return p;
}

/// ลูกศรกราฟดิ่งลง 3D (จากไฟล์ SVG ที่ผู้ใช้ให้มา 265×338): ชิ้นสันเข้ม + หน้าแดง
/// ท่าทาง: เผยจากหัวลงหาง (clip ไล่ตามแนวเฉียง) แล้วลอยขึ้นลง + เอียง perspective เล็กน้อย
/// กองการ์ดงานค้าง: ใบหน้าพลิกขึ้น (หมุนรอบขอบบน) แล้วไปทบหลังกอง ใบถัดไปเลื่อนขึ้นมาแทน
/// ช่องขวา (infos) ของใบหน้า จางข้ามตามใบ · งานเดียว = การ์ดนิ่ง ไม่มีกอง
class _OvTaskStack extends StatefulWidget {
  const _OvTaskStack({super.key, required this.cards, required this.infos});
  final List<Widget> cards;
  final List<List<Widget>> infos;
  @override
  State<_OvTaskStack> createState() => _OvTaskStackState();
}

class _OvTaskStackState extends State<_OvTaskStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 620))
    ..addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted) {
        setState(() => _i = (_i + 1) % widget.cards.length);
        _c.value = 0.0;
      }
    });
  Timer? _tick;
  int _i = 0;

  int get _n => widget.cards.length;

  @override
  void initState() {
    super.initState();
    // story หนึ่งเรื่อง 7 วิ: แบ่งให้ทุกใบได้ขึ้นหน้า (อย่างน้อย 2 วิต่อใบ)
    if (_n > 1) {
      final per = math.max(2000, 6400 ~/ _n);
      _tick = Timer.periodic(Duration(milliseconds: per), (_) {
        if (mounted && !_c.isAnimating) _c.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const peek = 6.0;
    final layers = math.min(_n, 3);
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        flex: 3,
        child: Padding(
          padding: EdgeInsets.only(bottom: peek * (layers - 1)),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = Curves.easeInOutCubic.transform(_c.value);
              // ชั้น k (0 = หน้า): หลังเลื่อนลงนิดและหดนิด · ระหว่างพลิก ทุกชั้นเลื่อนขึ้นหนึ่งขั้น
              Widget layer(int k) {
                final pos = (k - t).clamp(0.0, 2.0);
                return Transform.translate(
                  offset: Offset(0.0, peek * pos),
                  child: Transform.scale(
                    scale: 1.0 - 0.04 * pos,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: k >= 2 ? (0.55 + 0.45 * t) : 1.0,
                      child: widget.cards[(_i + k) % _n],
                    ),
                  ),
                );
              }

              // ใบหน้าพลิกขึ้นรอบขอบบน (หมุนแกน X) จางออกครึ่งหลัง แล้วไปอยู่หลังกอง
              final front = Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(t * math.pi / 2)
                  ..translateByDouble(0.0, -t * 10.0, 0.0, 1.0),
                child: Opacity(
                  opacity: (1.0 - (t - 0.35) / 0.65).clamp(0.0, 1.0),
                  child: widget.cards[_i % _n],
                ),
              );
              return Stack(clipBehavior: Clip.none, children: [
                for (var k = layers - 1; k >= 1; k--)
                  Positioned.fill(child: layer(k)),
                Positioned.fill(child: _n > 1 ? front : layer(0)),
              ]);
            },
          ),
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        flex: 2,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.0, 0.08), end: Offset.zero)
                  .animate(a),
              child: c,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_i),
            child: Column(children: [
              for (final (k, w) in widget.infos[_i % _n].indexed) ...[
                if (k > 0) const SizedBox(height: 8.0),
                Expanded(child: w),
              ],
              if (widget.infos[_i % _n].length < 2) const Spacer(),
            ]),
          ),
        ),
      ),
    ]);
  }
}

/// เหรียญกระดิ่งแจ้งเตือน (ระบบแจ้งพยาบาลแล้ว): ตกลงมาพร้อมจาง ครั้งเดียว แล้วกระดิ่งส่ายสั้น ๆ ครั้งเดียว
class _OvNotify extends StatefulWidget {
  const _OvNotify({super.key});
  @override
  State<_OvNotify> createState() => _OvNotifyState();
}

class _OvNotifyState extends State<_OvNotify>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    // หลังภาพหมวดงานลอยขึ้นมาแล้ว (ภาพเริ่ม 750 ms)
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        // หันหน้าเหรียญไปทางซ้าย (เข้าหารูปประกอบ)
        child: const FittedBox(
            child: _SoStatusCoin.field(Icons.notifications_active_rounded,
                tilt: -0.55)),
        builder: (context, child) {
          final v = _c.value;
          final k = Curves.easeOutBack.transform((v / 0.4).clamp(0.0, 1.0));
          // ส่ายหลังลงที่ (0.4–0.85) แล้วหยุด
          final w = ((v - 0.4) / 0.45).clamp(0.0, 1.0);
          return Opacity(
            opacity: (v / 0.2).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0.0, (1.0 - k) * -14.0),
              child: Transform.rotate(
                angle: math.sin(w * math.pi * 4) * 0.3 * (1.0 - w),
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
          );
        },
      );
}

/// วงแหวนเวลา: รางขาวโปร่งเต็มวง + ส่วนที่เลยเวลาเป็นแดง เริ่มบนสุดตามเข็ม
class _LateRingPainter extends CustomPainter {
  const _LateRingPainter({required this.frac});
  final double frac;
  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(6.0);
    const sw = 8.0;
    // รางขาวโปร่ง (เป็นขอบแก้วของวง ไม่แข่งกับภาพ)
    canvas.drawArc(
        r,
        0.0,
        math.pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..color = const Color(0xB3FFFFFF));
    if (frac <= 0.0) return;
    final sweep = math.pi * 2 * frac;
    // เส้นที่เลย: ไล่จากแดงอ่อน → แดงเข้มที่ปลาย (แบบวงกิจกรรม Apple Watch)
    canvas.drawArc(
        r,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0.0,
            endAngle: math.max(sweep, 0.01),
            colors: [_red.withValues(alpha: 0.35), _red],
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(r));
    // หัวเข็มที่ปลาย: จุดขาวขอบแดง (บอก "ตอนนี้")
    final a = -math.pi / 2 + sweep;
    final c = r.center + Offset(math.cos(a), math.sin(a)) * (r.width / 2);
    canvas.drawCircle(
        c,
        7.5,
        Paint()
          ..color = const Color(0x330B1B3F)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
    canvas.drawCircle(c, 6.5, Paint()..color = Colors.white);
    canvas.drawCircle(c, 3.5, Paint()..color = _red);
  }

  @override
  bool shouldRepaint(_LateRingPainter o) => o.frac != frac;
}

/// หลายประเภท = ขึ้นสลับทีละชิ้น (เลยนานสุดก่อน): เลื่อนออกจากหลังนาฬิกา ค้าง แล้วหลบกลับ
class _CareDueObject extends StatefulWidget {
  const _CareDueObject({super.key, required this.items});

  /// ภาพ 3D ประเภทงาน เรียงเลยนานก่อน
  final List<String> items;
  @override
  State<_CareDueObject> createState() => _CareDueObjectState();
}

class _CareDueObjectState extends State<_CareDueObject>
    with SingleTickerProviderStateMixin {
  // หนึ่งรอบต่อชิ้น: ออก 0–0.2 · ค้าง · หลบกลับ 0.85–1 (ชิ้นเดียว = ออกแล้วค้าง)
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200));
  Timer? _wait;
  int _i = 0;

  bool get _multi => widget.items.length > 1;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((st) {
      if (st == AnimationStatus.completed && _multi && mounted) {
        setState(() => _i = (_i + 1) % widget.items.length);
        _c.forward(from: 0.0);
      }
    });
    _wait = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        final s = size.shortestSide;
        // ตัวกลมกลาง 0.56s รัศมี 0.42s ตาม _erClockPath
        // ของวางในนาฬิกามุมขวาล่าง (เป็นส่วนหนึ่งของฉาก) · ส่วนบนล้นพ้นขอบออกไปแบบหัวพยาบาล
        final cc = Offset(size.width / 2, s * 0.56);
        final rad = s * 0.42;
        // ขนาดพอเห็นเป็นของ ไม่บังผู้ป่วยบนเตียงกลางวง · วางชิดขอบล่างขวา
        const a = math.pi * 0.20, sz = 86.0;
        final dir = Offset(math.cos(a), math.sin(a));
        final home = cc + dir * (rad - sz * 0.22);
        final img = widget.items[_i % widget.items.length];
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = _c.value;
            // gentle (design rule): ease นุ่ม ไม่เด้ง · เข้า 0–0.22 · ออก 0.84–1
            final inP =
                Curves.easeOutCubic.transform((v / 0.22).clamp(0.0, 1.0));
            final outP = !_multi
                ? 0.0
                : Curves.easeInOutCubic
                    .transform(((v - 0.84) / 0.16).clamp(0.0, 1.0));
            final k = inP * (1 - outP);
            // เข้า: ลอยขึ้นสั้น ๆ พร้อมจางเข้า · ออก: จางออกพร้อมจมลงนิด
            final c = home + Offset(0.0, (1 - k) * sz * 0.22);
            final op = k;
            Widget obj({bool fade = false}) => Positioned(
                  left: c.dx - sz / 2,
                  top: c.dy - sz * 0.58,
                  width: sz,
                  height: sz * 1.16,
                  child: Opacity(
                    opacity: op,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: fade
                          // ส่วนที่ล้นพ้นขอบ: จางลงช่วงกลางตัว (แบบภาพตัดหัวพยาบาล) ไม่เห็นรอยตัด
                          ? ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (r) => const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Color(0x00FFFFFF)
                                    ],
                                    stops: [0.0, 0.42, 0.62],
                                  ).createShader(r),
                              child: Image.asset(img, fit: BoxFit.contain))
                          : Image.asset(img, fit: BoxFit.contain),
                    ),
                  ),
                );
            return Stack(clipBehavior: Clip.none, children: [
              // ตัดขอบแบบนุ่ม (feather) ตามวงนาฬิกา: ในวงเห็นเต็ม ค่อย ๆ จางผ่านแนววงแหวน
              // (เดิมตัดแข็งที่ขอบวง + ส่วนนอกจางแยกชิ้น = เห็นรอยต่อ)
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => RadialGradient(
                    center: Alignment(cc.dx / size.width * 2 - 1,
                        cc.dy / size.height * 2 - 1),
                    radius: (rad + 34.0) / size.shortestSide,
                    colors: const [
                      Colors.white,
                      Colors.white,
                      Color(0x00FFFFFF)
                    ],
                    // เต็มถึงขอบนอกวงแหวน แล้วจางยาว ๆ ข้างนอก (ไม่มีขอบแข็ง)
                    stops: [0.0, (rad + 4.0) / (rad + 34.0), 1.0],
                  ).createShader(r),
                  child: Stack(clipBehavior: Clip.none, children: [obj()]),
                ),
              ),
            ]);
          },
        );
      });
}

class _TrendDownMark extends StatefulWidget {
  const _TrendDownMark({super.key, this.up = false});

  /// true = แนวโน้มดีขึ้น (เขียว พุ่งขึ้นขวา)
  final bool up;
  @override
  State<_TrendDownMark> createState() => _TrendDownMarkState();
}

class _TrendDownMarkState extends State<_TrendDownMark>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat();
  Timer? _wait;

  /// เริ่มหลังรูปทรง morph เป็นดาวเสร็จ (650 ms) + เว้นจังหวะนิด
  @override
  void initState() {
    super.initState();
    _wait = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _in.forward();
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_in, _loop]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_in.value);
          final ph = _loop.value * math.pi * 2;
          // วาดจากหางที่แขนซ้ายไปถึงหัวที่ทะลุขอบขวา แล้วลอยขึ้นลงเบา ๆ
          return Transform.translate(
            offset: Offset(0.0, math.sin(ph) * 3.0),
            child: CustomPaint(painter: _TrendDownPainter(t, up: widget.up)),
          );
        },
      );
}

class _TrendDownPainter extends CustomPainter {
  const _TrendDownPainter(this.t, {this.up = false, this.tone});
  final double t;
  final bool up;

  /// สี (หน้า, สัน) แทนค่าเริ่ม (แย่ลง = แดง · ดีขึ้น = เขียว) เช่น ลูกศรในการ์ดสัญญาณชีพ
  final (Color, Color)? tone;

  @override
  void paint(Canvas canvas, Size size) {
    // ลูกศรริบบอน 2.5D แบบ ref: ไกล (ต้นทาง) แคบ → ใกล้ (หัว) กว้าง = perspective
    // หน้าแดงอ่อนสว่าง · สันหนาด้านล่างขวาสีเข้ม (หนาตามระยะใกล้) · หัวใหญ่กว่าตัว
    final s = size.shortestSide;
    Offset q(double x, double y) =>
        Offset((size.width - s) / 2 + x * s, (size.height - s) / 2 + y * s);
    // ซิกแซกลงซ้าย: ท่อนยาว · ท่อนสั้นหักกลับ · ท่อนยาวถึงหัว
    // กลับซ้าย-ขวา: หางที่แขนขวาของดาว หัวพุ่งลงซ้ายทะลุขอบซ้าย
    // แย่ลง: ขวาบน → ซ้ายล่าง · ดีขึ้น: ซ้ายล่าง → ขวาบน (ซิกแซกแบบกราฟขึ้น)
    final pts = up
        // หางอยู่ในแขนล่างของดาว (ไม่ตัดผ่านร่องระหว่างแขน) · หัวออกซ้ายบน
        ? [q(0.80, 0.64), q(0.52, 0.48), q(0.40, 0.60), q(0.14, 0.36)]
        : [q(0.78, 0.20), q(0.56, 0.42), q(0.44, 0.32), q(0.16, 0.58)];
    final face =
        tone?.$1 ?? (up ? const Color(0xFF5FD68C) : const Color(0xFFFF7A7A));
    final side =
        tone?.$2 ?? (up ? const Color(0xFF1E8E3E) : const Color(0xFFC0182E));
    final lens = [
      for (var i = 0; i < pts.length - 1; i++) (pts[i + 1] - pts[i]).distance
    ];
    final total = lens.fold<double>(0, (a, b) => a + b);
    // ความกว้างครึ่งหนึ่ง/ความหนาตามระยะทาง (0 = ต้น · 1 = หัว)
    double halfAt(double u) => s * (0.035 + 0.035 * u);
    // หันอีกทาง: เห็นสันหนาด้านบน (กล้องมองจากใต้ลูกศร)
    Offset extAt(double u) => Offset(s * 0.012, s * 0.035) * (0.5 + 0.8 * u);
    final upto = total * Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    var acc = 0.0;
    var end = pts.first;
    var dir = const Offset(0, 1);
    var uEnd = 0.0;
    final faces = <Path>[], sides = <Path>[];
    for (var i = 0; i < pts.length - 1; i++) {
      if (acc >= upto) break;
      final a0 = pts[i], b0 = pts[i + 1];
      final d = (b0 - a0) / lens[i];
      final f = math.min(1.0, (upto - acc) / lens[i]);
      final b1 = a0 + d * lens[i] * f;
      final u0 = acc / total, u1 = (acc + lens[i] * f) / total;
      acc += lens[i];
      final n = Offset(-d.dy, d.dx);
      // ยืดต้นท่อนย้อนนิดให้ข้อพับต่อเนื่อง
      final a1 = i == 0 ? a0 : a0 - d * halfAt(u0);
      final quad = [
        a1 + n * halfAt(u0),
        b1 + n * halfAt(u1),
        b1 - n * halfAt(u1),
        a1 - n * halfAt(u0),
      ];
      faces.add(Path()..addPolygon(quad, true));
      sides.add(Path()
        ..addPolygon([
          quad[0] + extAt(u0),
          quad[1] + extAt(u1),
          quad[2] + extAt(u1),
          quad[3] + extAt(u0),
        ], true));
      end = b1;
      dir = d;
      uEnd = u1;
    }
    // หัวลูกศร: กว้าง 2.4 เท่าตัว ยาวพุ่งต่อทิศท่อนสุดท้าย
    final hk = ((t - 0.7) / 0.3).clamp(0.0, 1.0);
    if (hk > 0) {
      final n = Offset(-dir.dy, dir.dx);
      final hw = halfAt(1.0) * 2.1 * hk;
      final tip = end + dir * s * 0.13 * hk;
      final head = [end + n * hw, tip, end - n * hw];
      faces.add(Path()..addPolygon(head, true));
      sides.add(
          Path()..addPolygon([for (final p in head) p + extAt(1.0)], true));
    }
    // รวมทุกท่อน + หัวเป็นรูปเดียว (ไม่มีรอยต่อ) · สันใช้รูปรวมของสันทุกท่อน
    Path union(List<Path> ps) => ps.isEmpty
        ? Path()
        : ps
            .skip(1)
            .fold(ps.first, (a, b) => Path.combine(PathOperation.union, a, b));
    final faceAll = union(faces);
    final sideAll = union(sides);
    // ผนังเชื่อมหน้า→สัน: รูปรวมของหน้าเลื่อนทีละนิดจนถึงสัน (ทึบต่อเนื่อง)
    const steps = 10;
    for (var k = steps; k >= 1; k--) {
      final f = k / steps;
      canvas.drawPath(faceAll.shift(extAt(0.8) * f), Paint()..color = side);
    }
    canvas.drawPath(sideAll, Paint()..color = side);
    canvas.drawPath(faceAll, Paint()..color = face);
    canvas.drawPath(
        faceAll,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeJoin = StrokeJoin.round);
    if (uEnd < 0) return;
  }

  @override
  bool shouldRepaint(_TrendDownPainter o) => o.t != t;
}

/// ไอคอนปุ่มเลือกระดับ ESI (Figma 642:77): พีระมิดแถบสี 4 ชั้น + วงกรองฟ้ามุมขวาล่าง
/// ปรากฏ: แถบเลื่อนเข้าจากซ้ายทีละชั้น (ล่างขึ้นบน) แล้ววงกรองเด้งขึ้น
class _EsiLevelIcon extends StatefulWidget {
  const _EsiLevelIcon();
  @override
  State<_EsiLevelIcon> createState() => _EsiLevelIconState();
}

class _EsiLevelIconState extends State<_EsiLevelIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28.0,
        height: 23.0,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _EsiLevelPainter(_c.value)),
        ),
      );
}

class _EsiLevelPainter extends CustomPainter {
  const _EsiLevelPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // พิกัดจาก Figma (กรอบ 512) เฉพาะส่วนภาพ x 104–425 · y 134–393
    const ox = 104.0, oy = 134.0, bw = 321.0, bh = 259.0;
    final k = math.min(size.width / bw, size.height / bh);
    Offset p(double x, double y) => Offset((x - ox) * k, (y - oy) * k);
    // แถบพีระมิด: (x, y, กว้าง, สูง, สี) ล่าง → บน · ข้างเฉียงเข้าด้านบน
    const bars = [
      (104.7, 306.0, 176.6, 50.7, Color(0xFFE64A45)),
      (131.8, 248.1, 180.7, 47.6, Color(0xFFFA8231)),
      (157.5, 190.4, 145.3, 47.5, Color(0xFFFBBC2C)),
      (182.2, 134.4, 96.1, 45.1, Color(0xFF34A853)),
    ];
    for (var i = 0; i < bars.length; i++) {
      final (x, y, w, h, col) = bars[i];
      final a =
          Curves.easeOutCubic.transform(((t - i * 0.12) / 0.5).clamp(0.0, 1.0));
      if (a <= 0) continue;
      const slant = 13.0;
      final r = 8.0 * k;
      final dx = -18.0 * (1.0 - a) * k * 3;
      final path = Path()
        ..moveTo(p(x + slant, y).dx + r + dx, p(x, y).dy)
        ..lineTo(p(x + w - slant, y).dx - r + dx, p(x, y).dy)
        ..quadraticBezierTo(p(x + w - slant, y).dx + dx, p(x, y).dy,
            p(x + w - slant, y).dx + dx + r * 0.3, p(x, y).dy + r)
        ..lineTo(p(x + w, y + h).dx + dx, p(x, y + h).dy - r)
        ..quadraticBezierTo(p(x + w, y + h).dx + dx, p(x, y + h).dy,
            p(x + w, y + h).dx + dx - r, p(x, y + h).dy)
        ..lineTo(p(x, y + h).dx + dx + r, p(x, y + h).dy)
        ..quadraticBezierTo(p(x, y + h).dx + dx, p(x, y + h).dy,
            p(x, y + h).dx + dx + r * 0.3, p(x, y + h).dy - r)
        ..lineTo(p(x + slant, y).dx + dx - r * 0.3, p(x, y).dy + r)
        ..quadraticBezierTo(p(x + slant, y).dx + dx, p(x, y).dy,
            p(x + slant, y).dx + dx + r, p(x, y).dy)
        ..close();
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: a));
    }
    // วงกรอง: ขอบขาวคั่น + พื้นฟ้าอ่อน + กรวยฟ้า · เด้งขึ้นหลังแถบ
    final b = Curves.easeOutBack.transform(((t - 0.45) / 0.55).clamp(0.0, 1.0));
    if (b > 0) {
      final c = p(282.7 + 70.9, 251.1 + 70.9);
      final rad = 70.9 * k * b;
      canvas.drawCircle(c, rad + 9.0 * k, Paint()..color = Colors.white);
      canvas.drawCircle(c, rad, Paint()..color = const Color(0xFFD3E3FD));
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(b);
      final f = Path()
        ..moveTo(-41.0 * k, -34.0 * k)
        ..lineTo(41.0 * k, -34.0 * k)
        ..lineTo(9.0 * k, 4.0 * k)
        ..lineTo(9.0 * k, 44.0 * k)
        ..lineTo(-9.0 * k, 34.0 * k)
        ..lineTo(-9.0 * k, 4.0 * k)
        ..close();
      canvas.drawPath(
          f,
          Paint()
            ..color = const Color(0xFF4285F4)
            ..strokeJoin = StrokeJoin.round);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EsiLevelPainter o) => o.t != t;
}

/// พื้นที่ที่ลูกศรมองเห็น: ภายในดาว ∪ ด้านซ้ายล่างนอกดาว (ให้หัวลูกศรโผล่ทะลุกรอบ)
/// star = กรอบดาวในพิกัดของกล่องลูกศร
class _TrendClip extends CustomClipper<Path> {
  const _TrendClip(this.star, {this.up = false});
  final Rect star;

  /// true = เปิดมุมขวาบนนอกดาว (ลูกศรขึ้น) · false = มุมซ้ายล่าง
  final bool up;
  @override
  Path getClip(Size size) => Path.combine(
      PathOperation.union,
      _erStarPath(star),
      Path()
        ..addRect(up
            // เปิดทั้งฝั่งซ้ายของดาว: หัวลูกศรทะลุออกได้เต็มรูป ไม่ถูกขอบแขนตัด
            ? Rect.fromLTRB(-400.0, -400.0, star.center.dx - star.width * 0.08,
                size.height + 400.0)
            : Rect.fromLTRB(-400.0, star.center.dy + star.height * 0.12,
                star.center.dx - star.width * 0.12, size.height + 400.0)));
  @override
  bool shouldReclip(_TrendClip o) => o.star != star || o.up != up;
}

/// เส้นตัวอย่างในคำอธิบายกราฟ (ทึบ / ประ)
class _KpiLegendLine extends CustomPainter {
  _KpiLegendLine(this.c, this.dash);
  final Color c;
  final bool dash;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = c
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dash) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), p);
      return;
    }
    for (var x = 0.0; x < size.width; x += 6.0) {
      canvas.drawLine(
          Offset(x, y), Offset(math.min(x + 3.0, size.width), y), p);
    }
  }

  @override
  bool shouldRepaint(_KpiLegendLine old) => old.c != c || old.dash != dash;
}

/// กราฟกระแสผู้ป่วยรายชั่วโมง: แกนแบบกราฟสัญญาณชีพ (เส้นประจุดที่เลขกลม ตัวเลขเทา)
/// เข้า = กรมท่าทึบ + พื้นจาง · ออก = กรมท่าอ่อน · รับเข้านอน = เส้นประเทา · เส้นตอนนี้ที่จุดล่าสุด
class _KpiFlowChart extends CustomPainter {
  _KpiFlowChart(
      {required this.t,
      required this.num,
      this.peak = false,
      this.sel,
      this.pickF,
      this.tipA = 0.0});

  /// [peak] = ป้ายกรมท่าชี้จุดที่ผู้ป่วยเข้ามากที่สุด (ซ่อนเมื่อเลือกชั่วโมง)
  final bool peak;

  /// ชั่วโมงที่เลือก (ซ่อนป้ายพีค) · [pickF] ตำแหน่งป้ายต่อเนื่อง · [tipA] การมองเห็นป้าย 0–1
  final int? sel;
  final double? pickF;
  final double tipA;

  static const _axisW = 30.0, _padL = 10.0, _padR = 18.0;

  /// ดัชนีชั่วโมงที่ใกล้ตำแหน่ง [dx] ที่สุด (กว้างกราฟ [w])
  static int hit(double dx, double w) {
    final n = _kpiFlowHours.length;
    final f = (dx - _axisW - _padL) / (w - _axisW - _padL - _padR) * (n - 1);
    return f.round().clamp(0, n - 1);
  }

  /// ตำแหน่งต่อเนื่อง (ดัชนีมีเศษ) ระหว่างลาก
  static double hitF(double dx, double w) {
    final n = _kpiFlowHours.length;
    final f = (dx - _axisW - _padL) / (w - _axisW - _padL - _padR) * (n - 1);
    return f.clamp(0.0, n - 1.0);
  }

  final TextStyle Function(double,
      {Color color, FontWeight weight, double? height}) t;
  final TextStyle Function(double, {Color color, FontWeight weight}) num;

  TextPainter _tp(String s, TextStyle st) => TextPainter(
      text: TextSpan(text: s, style: st), textDirection: TextDirection.ltr)
    ..layout();

  @override
  void paint(Canvas canvas, Size size) {
    const axisW = _axisW, top = 22.0, bottom = 24.0, padL = _padL, padR = _padR;
    final n = _kpiFlowHours.length;
    final all = [..._kpiFlowIn, ..._kpiFlowOut, ..._kpiFlowAdmit];
    final vMax = ((all.reduce(math.max) / 10).ceil() * 10).toDouble();
    final base = size.height - bottom;
    double yOf(int v) => top + (base - top) * (1 - v / vMax);
    double xOf(int i) =>
        axisW + padL + (size.width - axisW - padL - padR) * i / (n - 1);
    final dot = Paint()..color = _ink3.withValues(alpha: 0.45);
    for (var v = 0.0; v <= vMax; v += 10.0) {
      final y = yOf(v.round());
      for (var x = axisW; x < size.width; x += 7.0) {
        canvas.drawCircle(Offset(x, y), 0.8, dot);
      }
      final tp = _tp(
          v.round().toString(), t(11.0, color: _ink3, weight: FontWeight.w500));
      tp.paint(canvas, Offset(axisW - 8.0 - tp.width, y - tp.height / 2));
    }
    // หน่วยของแกนตั้ง (ตัวเลขบนกราฟมีหน่วยเสมอ)
    _tp('ราย', t(10.5, color: _ink3, weight: FontWeight.w500))
        .paint(canvas, const Offset(0.0, 0.0));
    Path line(List<int> d) {
      final p = Path()..moveTo(xOf(0), yOf(d[0]));
      for (var i = 1; i < n; i++) {
        final x0 = xOf(i - 1), x1 = xOf(i), mx = (x0 + x1) / 2;
        p.cubicTo(mx, yOf(d[i - 1]), mx, yOf(d[i]), x1, yOf(d[i]));
      }
      return p;
    }

    // พื้นจางใต้เส้นเข้า
    final inLine = line(_kpiFlowIn);
    final area = Path.from(inLine)
      ..lineTo(xOf(n - 1), base)
      ..lineTo(xOf(0), base)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _kpiTones[0].withValues(alpha: 0.16),
              _kpiTones[0].withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTRB(0.0, top, size.width, base)));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line(_kpiFlowOut), stroke..color = _kpiTones[3]);
    // รับเข้านอน: เส้นประ
    final ad = line(_kpiFlowAdmit);
    for (final m in ad.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9.0) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5.0, m.length)),
            stroke..color = _ink3);
      }
    }
    canvas.drawPath(inLine, stroke..color = _kpiTones[0]);
    for (var i = 0; i < n; i++) {
      if (tipA > 0.3 && pickF != null && pickF!.round() == i) continue;
      for (final (d, c) in [
        (_kpiFlowIn, _kpiTones[0]),
        (_kpiFlowOut, _kpiTones[3]),
      ]) {
        canvas.drawCircle(
            Offset(xOf(i), yOf(d[i])), 4.0, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(xOf(i), yOf(d[i])), 2.6, Paint()..color = c);
      }
    }
    if (peak && sel == null) {
      final pv = _kpiFlowIn.reduce(math.max);
      final pi = _kpiFlowIn.indexOf(pv);
      final pc = Offset(xOf(pi), yOf(pv));
      canvas.drawCircle(pc, 7.0, Paint()..color = Colors.white);
      canvas.drawCircle(pc, 5.0, Paint()..color = _kpiTones[0]);
      final lab = _tp('มากสุด $pv ราย',
          t(11.0, color: Colors.white, weight: FontWeight.w700));
      final r = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(pc.dx, pc.dy - 22.0),
              width: lab.width + 16.0,
              height: lab.height + 6.0),
          const Radius.circular(100.0));
      canvas.drawRRect(r, Paint()..color = _kpiTones[0]);
      canvas.drawPath(
          Path()
            ..moveTo(pc.dx - 4.0, r.bottom - 0.5)
            ..lineTo(pc.dx + 4.0, r.bottom - 0.5)
            ..lineTo(pc.dx, r.bottom + 4.0)
            ..close(),
          Paint()..color = _kpiTones[0]);
      lab.paint(canvas, Offset(pc.dx - lab.width / 2, r.top + 3.0));
    }
    // เส้นตอนนี้ (จุดล่าสุด)
    final xn = xOf(n - 1);
    for (var y = top - 8.0; y < base; y += 6.0) {
      canvas.drawLine(
          Offset(xn, y),
          Offset(xn, math.min(y + 3.0, base)),
          Paint()
            ..color = _kpiTones[1]
            ..strokeWidth = 1.2);
    }
    final now = _tp(
        'ตอนนี้ ${_clock('${_kpiFlowHours.last.toString().padLeft(2, '0')}:00')}',
        t(11.0, color: _kpiTones[1], weight: FontWeight.w700));
    now.paint(canvas,
        Offset(math.min(xn - now.width / 2, size.width - now.width), 0.0));
    if (pickF != null && tipA > 0.01) _tip(canvas, size, xOf, yOf, top, base);
    // เวลาใต้แกน: กราฟแคบ (วิดเจ็ตหน้าภาพรวม) = เว้นป้ายให้ไม่ชนกัน · ป้ายสุดท้าย (ตอนนี้) แสดงเสมอ
    final every = n < 2 ? 1 : math.max(1, (36.0 / (xOf(1) - xOf(0))).ceil());
    for (var i = 0; i < n; i++) {
      if (i != n - 1 && (i % every != 0 || xOf(n - 1) - xOf(i) < 36.0)) {
        continue;
      }
      final tp = _tp(
          '${_kpiFlowHours[i].toString().padLeft(2, '0')} น.',
          t(10.5,
              color: i == n - 1 ? _ink2 : _ink3,
              weight: i == n - 1 ? FontWeight.w600 : FontWeight.w500));
      tp.paint(
          canvas,
          Offset(
              (xOf(i) - tp.width / 2)
                  .clamp(axisW, size.width - tp.width)
                  .toDouble(),
              base + 8.0));
    }
  }

  @override

  /// ป้าย focus แบบการ์ดสัญญาณชีพ (_VsDetailChart._tip): แถบไฮไลต์ · เส้นนำจางลงฐาน · จุดมีวง
  /// ป้าย pill เหนือจุดสูงสุด หางชี้ลง ขยายจากปลายหาง: เวลา · จุดสีเข้า/ออก/รับเข้านอน + ค่า
  void _tip(Canvas canvas, Size size, double Function(int) xOf,
      double Function(int) yOf, double top, double base) {
    final n = _kpiFlowHours.length;
    final f = pickF!.clamp(0.0, n - 1.0);
    final i0 = f.floor(), i1 = math.min(i0 + 1, n - 1), tt = f - i0;
    final i = f.round();
    final o = tipA.clamp(0.0, 1.0);
    final x = xOf(i0) + (xOf(i1) - xOf(i0)) * tt;
    double yAt(List<int> d) => yOf(d[i0]) + (yOf(d[i1]) - yOf(d[i0])) * tt;
    final rows = [
      (_kpiFlowIn, _kpiTones[0]),
      (_kpiFlowOut, _kpiTones[3]),
      (_kpiFlowAdmit, _ink3),
    ];
    final ys = [for (final (d, _) in rows) yAt(d)];
    final yTop = ys.reduce(math.min);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(x - 16.0, top - 6.0, x + 16.0, base),
            const Radius.circular(10.0)),
        Paint()..color = _blue.withValues(alpha: 0.05 * o));
    canvas.drawLine(
        Offset(x, yTop),
        Offset(x, base),
        Paint()
          ..strokeWidth = 1.2
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _blue.withValues(alpha: 0.5 * o),
              _blue.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTRB(x - 1.0, yTop, x + 1.0, base)));
    for (final (r, (_, c)) in rows.indexed) {
      final y = ys[r];
      canvas.drawCircle(Offset(x, y), 13.0 * o,
          Paint()..color = c.withValues(alpha: 0.12 * o));
      canvas.drawCircle(Offset(x, y), 7.0,
          Paint()..color = Colors.white.withValues(alpha: o));
      canvas.drawCircle(
          Offset(x, y), 4.4, Paint()..color = c.withValues(alpha: o));
    }
    // ป้ายบรรทัดเดียว: เวลา + (จุดสี ค่า หน่วย) ×3 · วางบนเส้นฐานตัวอักษรเดียวกัน · ค่าตัวเลขมีหน่วยเสมอ
    final tTime = _tp(
        _clock('${_kpiFlowHours[i].toString().padLeft(2, '0')}:00'),
        t(11.0, color: _ink3.withValues(alpha: o), weight: FontWeight.w500));
    final tv = [
      for (final (d, _) in rows)
        _tp(
            '${d[i]}',
            num(15.0,
                color: _inkTitle.withValues(alpha: o), weight: FontWeight.w700))
    ];
    final tu = _tp('ราย',
        t(11.0, color: _ink3.withValues(alpha: o), weight: FontWeight.w500));
    const dot = 8.0, dotGap = 4.0, itemGap = 10.0, unitGap = 3.0;
    var bw = 12.0 + tTime.width;
    for (final p in tv) {
      bw += itemGap + dot + dotGap + p.width + unitGap + tu.width;
    }
    bw += 12.0;
    final bh = tv.first.height + 10.0;
    const arrow = 6.0, gap = 8.0;
    final bx = (x - bw / 2).clamp(0.0, size.width - bw).toDouble();
    final by = math.max(-14.0, yTop - gap - arrow - bh);
    final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh), Radius.circular(bh / 2));
    final ax = x.clamp(bx + bh / 2, bx + bw - bh / 2).toDouble();
    final tail = Path()
      ..moveTo(ax - 6.0, by + bh - 0.5)
      ..lineTo(ax, by + bh + arrow)
      ..lineTo(ax + 6.0, by + bh - 0.5)
      ..close();
    final shape = Path.combine(PathOperation.union, Path()..addRRect(rr), tail);
    final pivot = Offset(ax, by + bh + arrow);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    final k = 0.86 + 0.14 * tipA;
    canvas.scale(k, k);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawShadow(
        shape, const Color(0xFF0B1B3F).withValues(alpha: 0.5 * o), 4.0, false);
    canvas.drawPath(shape, Paint()..color = Colors.white.withValues(alpha: o));
    canvas.drawPath(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0xFFDADCE0).withValues(alpha: o));
    final baseY = by + 5.0 + tv.first.height * 0.78;
    var cx = bx + 12.0;
    tTime.paint(canvas, Offset(cx, baseY - tTime.height * 0.78));
    cx += tTime.width;
    for (final (r, p) in tv.indexed) {
      cx += itemGap;
      canvas.drawCircle(Offset(cx + dot / 2, by + bh / 2), dot / 2,
          Paint()..color = rows[r].$2.withValues(alpha: o));
      cx += dot + dotGap;
      p.paint(canvas, Offset(cx, by + 5.0));
      cx += p.width + unitGap;
      tu.paint(canvas, Offset(cx, baseY - tu.height * 0.78));
      cx += tu.width;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KpiFlowChart old) =>
      old.sel != sel || old.pickF != pickF || old.tipA != tipA;
}

/// แถบเทียบ (bullet) ช่องตัวชี้วัด: ร่องเทา · เติมกรมท่าถึง [v] (0–1) · ขีดเข้มที่ [mark] + ป้าย [label] ใต้ขีด
/// [worse] = เกินขีดแล้วแย่: ส่วนเกินขีดเป็น [over] (แดง)
class _KpiBullet extends CustomPainter {
  const _KpiBullet(
      {required this.v,
      required this.mark,
      required this.worse,
      required this.label,
      required this.track,
      required this.on,
      required this.over,
      required this.style});
  final double v, mark;
  final bool worse;
  final String label;
  final Color track, on, over;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    const h = 10.0, y = 2.0;
    RRect bar(double a, double b) => RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * a, y, size.width * b, y + h),
        const Radius.circular(5.0));
    canvas.drawRRect(bar(0.0, 1.0), Paint()..color = track);
    final vv = v.clamp(0.0, 1.0), m = mark.clamp(0.0, 1.0);
    if (vv > 0) {
      final cut = worse ? math.min(vv, m) : vv;
      canvas.drawRRect(bar(0.0, cut), Paint()..color = on);
      if (worse && vv > m) {
        // ส่วนเกิน: ต่อจากขีด ปลายมน (ฝั่งขีดตรง)
        canvas.drawRRect(
            RRect.fromRectAndCorners(
                Rect.fromLTRB(size.width * m, y, size.width * vv, y + h),
                topRight: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0)),
            Paint()..color = over);
      }
    }
    final x = size.width * m;
    canvas.drawLine(
        Offset(x, y - 4.0),
        Offset(x, y + h + 4.0),
        Paint()
          ..color = _inkTitle
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round);
    final tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(
        canvas,
        Offset(
            (x - tp.width / 2).clamp(0.0, size.width - tp.width), y + h + 5.0));
  }

  @override
  bool shouldRepaint(_KpiBullet o) =>
      o.v != v || o.mark != mark || o.worse != worse || o.label != label;
}

/// ภาพตัดเต็มตัว (ชุดหัวหมวด ESI) ของฉากในวง: (ไฟล์, ซ้าย, บน, กว้าง, สูง เป็นสัดส่วนของภาพฉาก,
/// ช่องโผล่ซ้าย, ขวา เป็นเท่าของรัศมีจากกลางวง) · ช่องโผล่ครอบเฉพาะหัวตัวละครหลัก
/// ตัวรอง (เช่น พยาบาลชุดเขียวขอบขวา) อยู่ในวง ถูกขอบวงตัดตามโค้ง ไม่มีรอยตัดตรง
/// วัดตำแหน่งด้วย template matching ให้ทับตัวละครในฉากพอดี (2026-11-24)
const _kpiFigIn =
    <String, (String, double, double, double, double, double, double)>{
  'assets/images/er_ov_emergent.jpg': (
    'assets/images/er_ov_emergent_fig.png',
    0.0563,
    0.3344,
    0.7219,
    0.5844,
    -1.4,
    0.2
  ),
  'assets/images/er_ov_urgent.jpg': (
    'assets/images/er_ov_urgent_fig.png',
    0.1000,
    0.2469,
    0.5656,
    0.6875,
    -1.4,
    0.15
  ),
  'assets/images/er_kpi_wrist.png': (
    'assets/images/er_kpi_wrist.png',
    0.0,
    0.0,
    1.0,
    1.0,
    -0.85,
    0.85
  ),
  'assets/images/er_ov_lessurg.jpg': (
    'assets/images/er_ov_lessurg_fig.png',
    0.2906,
    0.2687,
    0.4188,
    0.6500,
    -0.6,
    0.4
  ),
};

/// ขอบเขตที่ตัวละครล้นได้: วง (ศูนย์กลาง [c] รัศมี [r]) + ช่องเหนือเส้นกลางวง ช่วง x = c.dx + [a..b] × r
/// [circle] = false: เฉพาะช่องเหนือวง (ภาพในวงมีตัวละครครบแล้ว ส่วนล่างให้ขอบวงตัดตามโค้ง)
class _KpiPopClip extends CustomClipper<Path> {
  const _KpiPopClip(this.c, this.r, this.a, this.b, {this.circle = true});
  final Offset c;
  final double r, a, b;
  final bool circle;

  @override
  Path getClip(Size size) {
    final win = Path()
      ..addRect(
          Rect.fromLTRB(c.dx + a * r, -400.0, c.dx + b * r, c.dy - r * 0.2));
    return circle
        ? Path.combine(PathOperation.union,
            Path()..addOval(Rect.fromCircle(center: c, radius: r)), win)
        : win;
  }

  @override
  bool shouldReclip(_KpiPopClip o) =>
      o.c != c || o.r != r || o.a != a || o.b != b || o.circle != circle;
}

/// ภาพตัวละครหัวบท: (ไฟล์, สูง, สัดส่วนกว้าง/สูงของไฟล์, ช่วงที่แสดงซ้าย, ขวา 0–1, ส่วนที่จมหลังการ์ด)
typedef _KpiFig = (String, double, double, double, double, double);

/// ฉากในวงแบบ hero หน้าภาพรวม: (ภาพเต็ม, ภาพตัดที่โผล่พ้นวง, ขนาด, เลื่อน x, y) ในกรอบวง 232
typedef _KpiSc = (String, String, double, double, double);
const _KpiSc _kpiScLobby = (
  'assets/images/er_ov_lobby.jpg',
  'assets/images/er_ov_lobby_pop.png',
  400.0,
  -193.05,
  -168.18
);
const _KpiSc _kpiScArrive = (
  'assets/images/er_ov_emergent.jpg',
  'assets/images/er_ov_emergent_pop.png',
  367.0,
  -157.0,
  -208.0
);
const _KpiSc _kpiScCounter = (
  'assets/images/er_ov_lessurg.jpg',
  'assets/images/er_ov_lessurg_pop.png',
  361.0,
  -178.0,
  -186.0
);

/// คัดกรอง: แขนหุ่น 3D (er_patient_figure.glb) มือผ่อนคลาย ยกขึ้นจากกลางล่าง ใส่สายรัด ESI ทรงเดียวกับ ErEsiGauge3D
/// สายบางสัดส่วนจริง · แป๊กขาว 2 เม็ด + ป้ายขาว "ESI 3 / Urgent" แปะด้านหน้าข้อมือ · เรนเดอร์ Blender พื้นโปร่ง
/// มือ/ข้อมือผิวปกติ (ขอบคมเหนือวง) → แขนท่อนล่างไล่เป็นผิวอ่อนแล้วจางหายในวง · สายรัดสีเต็ม เป็นจุดเด่น
/// (มือซีดบนพื้นพีชเหนือวงดูฟุ้ง จึงจางเฉพาะช่วงล่างแบบภาพตัดหน้าภาพรวม)
/// กล้องมองหลังมือ (ไม่เห็นฝ่ามือ/ข้อนิ้วที่หุ่น low-poly ทำได้ไม่สมจริง)
/// ภาพเดียวใช้ทั้งในวงและชั้นโผล่ (มือล้นขอบบนวง แขนถูกวงตัดด้านล่าง) · ซูมให้สายอยู่ครึ่งล่างวง ป้ายอ่านออก
const _KpiSc _kpiScWrist = (
  'assets/images/er_kpi_wrist.png',
  'assets/images/er_kpi_wrist.png',
  395.0,
  -207.0,
  -214.0
);

const _KpiSc _kpiScCare = (
  'assets/images/er_ov_care.jpg',
  'assets/images/er_ov_care_pop.png',
  260.0,
  -136.0,
  -84.0
);
const _KpiSc _kpiScHome = (
  'assets/images/er_ov_better.jpg',
  'assets/images/er_ov_better_pop.png',
  256.0,
  -125.0,
  -134.0
);

/// เล่นครั้งเดียวเมื่อเลื่อนมาเห็น: [builder] ได้ seen = true ตอนขอบบนของตัวเองเข้ามาในจอ (82% ของความสูงจอ)
class _KpiInView extends StatefulWidget {
  const _KpiInView({required this.builder});
  final Widget Function(BuildContext context, bool seen) builder;

  @override
  State<_KpiInView> createState() => _KpiInViewState();
}

class _KpiInViewState extends State<_KpiInView> {
  bool _seen = false;
  ScrollPosition? _pos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = Scrollable.maybeOf(context)?.position;
    if (p != _pos) {
      _pos?.removeListener(_check);
      _pos = p;
      _pos?.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_seen || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * 0.82) {
      _pos?.removeListener(_check);
      setState(() => _seen = true);
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _seen);
}

/// เส้นแบ่งชั่วโมงของไทม์ไลน์ตรวจรักษา: จุดประแนวตั้งที่ [xs] · เส้นจบ (เวลารวม) กรมท่าที่ [end]
class _KpiLosGrid extends CustomPainter {
  const _KpiLosGrid({required this.xs, required this.end, required this.top});
  final List<double> xs;
  final double end, top;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = _ink3.withValues(alpha: 0.4);
    for (final x in xs) {
      for (var y = top; y < size.height; y += 6.0) {
        canvas.drawCircle(Offset(x, y), 0.8, dot);
      }
    }
    final line = Paint()
      ..color = _blue.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    for (var y = top; y < size.height; y += 6.0) {
      canvas.drawLine(
          Offset(end, y), Offset(end, math.min(y + 3.0, size.height)), line);
    }
  }

  @override
  bool shouldRepaint(_KpiLosGrid o) =>
      o.end != end || o.top != top || o.xs.join() != xs.join();
}

/// โดนัทผลลัพธ์ของผู้ป่วย: วาดตามเข็มนาฬิกาจากบนสุด [k] = ความคืบหน้าการวาด (0–1)
class _KpiDonut extends CustomPainter {
  _KpiDonut(this.values, this.colors, this.k);
  final List<double> values;
  final List<Color> colors;
  final double k;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0.0, (a, b) => a + b);
    const sw = 22.0;
    final r = Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.shortestSide / 2 - sw / 2);
    var a = -math.pi / 2;
    final sweepAll = 2 * math.pi * k;
    for (var i = 0; i < values.length; i++) {
      final s = 2 * math.pi * values[i] / total;
      final drawn = math.min(s, math.max(0.0, -math.pi / 2 + sweepAll - a));
      if (drawn > 0.0) {
        canvas.drawArc(
            r,
            a + 0.02,
            math.max(0.0, drawn - 0.04),
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = sw
              ..color = colors[i]);
      }
      a += s;
    }
  }

  @override
  bool shouldRepaint(_KpiDonut old) => old.k != k;
}

/// ไอคอนสแกนหน้าแบบเมนูใบรับรองแพทย์ (เหมือน [_McGIcon] navy): วง #DBE5FC · ไม่รองขาว (ตา/ยิ้มโปร่งเห็นสีวง)
/// สัญลักษณ์ไล่สองโทนแบ่งทแยง (ซ้ายบน 5A69B4 · ขวาล่าง 2B3F96) · ชุด Material ไม่มีรูปสแกนหน้า จึงวาดเอง
class _FaceScanIcon extends StatelessWidget {
  const _FaceScanIcon({this.size = 40.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    final k = size / 40.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFDBE5FC)),
      child: Stack(alignment: Alignment.center, children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5A69B4),
              Color(0xFF5A69B4),
              Color(0xFF2B3F96),
              Color(0xFF2B3F96)
            ],
            stops: [0.0, 0.5, 0.5, 1.0],
          ).createShader(r),
          child: CustomPaint(
              size: Size.square(24.0 * k),
              painter: const _FaceScanGlyph(Colors.white)),
        ),
      ]),
    );
  }
}

/// สัญลักษณ์สแกนหน้า: มุมกรอบสแกน 4 มุม + หน้ากลมทึบ เจาะตา/ยิ้มโปร่ง (สีมาจาก ShaderMask ของ [_FaceScanIcon])
class _FaceScanGlyph extends CustomPainter {
  const _FaceScanGlyph(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24.0);
    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // มุมกรอบ: แขนยาว 5.5 มุมโค้ง 3
    const a = 2.3, b = 21.7, arm = 5.5, r = 3.0;
    for (final (x, y, sx, sy) in const [
      (a, a, 1.0, 1.0),
      (b, a, -1.0, 1.0),
      (a, b, 1.0, -1.0),
      (b, b, -1.0, -1.0),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(x, y + sy * arm)
            ..lineTo(x, y + sy * r)
            ..quadraticBezierTo(x, y, x + sx * r, y)
            ..lineTo(x + sx * arm, y),
          corner);
    }
    // หน้าทึบ + เจาะตา/ยิ้ม
    const c = Offset(12.0, 12.0);
    canvas.saveLayer(Rect.fromCircle(center: c, radius: 7.5), Paint());
    canvas.drawCircle(c, 6.6, Paint()..color = color);
    final cut = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(const Offset(9.6, 10.6), 1.15, cut);
    canvas.drawCircle(const Offset(14.4, 10.6), 1.15, cut);
    canvas.drawPath(
        Path()
          ..moveTo(9.2, 13.6)
          ..quadraticBezierTo(12.0, 16.4, 14.8, 13.6),
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FaceScanGlyph old) => old.color != color;
}
