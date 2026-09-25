/// หน้า login จำลองของโมดูล ER: เลือกบทบาท (แพทย์ / พยาบาล) แล้วเลือกคน
///
/// ใช้เดโม workflow ตามบทบาทเท่านั้น ไม่ผูกกับ Provider ID / PIN ของระบบจริง
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../er_flow_home/er_flow_home_widget.dart';
import '../er_shared/er_session.dart';

const Color _bg = Color(0xFFEDEDED);
const Color _panel = Color(0xFFFFFFFF);
const Color _line = Color(0xFFE3E6EA);
const Color _ink = Color(0xFF202124);
const Color _ink3 = Color(0xFF6B7178);
const Color _blue = Color(0xFF001B7C);
const Color _teal = Color(0xFF00796B);

TextStyle _t(double size,
        {Color color = _ink, FontWeight weight = FontWeight.w400}) =>
    TextStyle(
        fontFamily: 'IBMPlexSansThaiLooped',
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.3);

class ErLoginWidget extends StatefulWidget {
  const ErLoginWidget({super.key});

  static const String routeName = 'Er_Login';
  static const String routePath = 'erLogin';

  @override
  State<ErLoginWidget> createState() => _ErLoginWidgetState();
}

class _ErLoginWidgetState extends State<ErLoginWidget> {
  ErRole _role = ErRole.doctor;

  void _enter(ErUser u) {
    ErSession.instance.signIn(u);
    context.goNamed(ErFlowHomeWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final people = erStaff.where((u) => u.role == _role).toList();
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(12.0)),
                      child: const Icon(Icons.local_hospital_rounded,
                          color: Colors.white, size: 26.0),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOSxP Plus · ห้องฉุกเฉิน',
                            style: _t(18.0, weight: FontWeight.w700)),
                        Text(
                            'เข้าใช้งานจำลอง เลือกบทบาทเพื่อดู workflow ของแต่ละหน้าที่',
                            style: _t(11.5, color: _ink3)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22.0),
                Row(
                  children: [
                    _roleCard(
                        ErRole.doctor,
                        Icons.medical_services_rounded,
                        'แพทย์ ER',
                        'ทบทวนเคส · HPI · ตรวจร่างกาย · วินิจฉัย/สั่งการรักษา · จำหน่าย',
                        _blue),
                    const SizedBox(width: 14.0),
                    _roleCard(
                        ErRole.nurse,
                        Icons.health_and_safety_rounded,
                        'พยาบาล ER',
                        'สัญญาณชีพ · AIS · รับคำสั่งแพทย์ · สังเกตอาการ · การพยาบาล',
                        _teal),
                    const SizedBox(width: 14.0),
                    _roleCard(
                        ErRole.triage,
                        Icons.how_to_reg_rounded,
                        'พยาบาลคัดกรอง',
                        'รับเข้า · อาการสำคัญ · สัญญาณชีพ · GCS · อุบัติเหตุ · ESI',
                        const Color(0xFFB26A00)),
                  ],
                ),
                const SizedBox(height: 18.0),
                Text('เลือกเจ้าหน้าที่ (เวรเช้า)',
                    style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
                const SizedBox(height: 8.0),
                for (final u in people)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: _panel,
                      borderRadius: BorderRadius.circular(14.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _enter(u),
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 10.0, 14.0, 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: _line)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 22.0,
                                  backgroundImage: AssetImage(u.face)),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.name,
                                        style:
                                            _t(13.0, weight: FontWeight.w700)),
                                    Text('${u.position} · ${u.shift}',
                                        style: _t(10.5, color: _ink3)),
                                  ],
                                ),
                              ),
                              Text('เข้าใช้งาน',
                                  style: _t(11.0,
                                      color: _blue, weight: FontWeight.w700)),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 16.0, color: _blue),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 6.0),
                Text('* หน้าจำลองสำหรับออกแบบ ไม่ใช้ Provider ID / PIN จริง',
                    style: _t(10.0, color: _ink3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
      ErRole r, IconData icon, String title, String desc, Color color) {
    final on = _role == r;
    return Expanded(
      child: Material(
        color: on ? color : _panel,
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _role = r),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                    color: on ? color : _line, width: on ? 2.0 : 1.0)),
            child: Row(
              children: [
                Icon(icon, size: 30.0, color: on ? Colors.white : color),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: _t(15.0,
                              color: on ? Colors.white : _ink,
                              weight: FontWeight.w700)),
                      const SizedBox(height: 2.0),
                      Text(desc,
                          style: _t(10.5, color: on ? Colors.white70 : _ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
