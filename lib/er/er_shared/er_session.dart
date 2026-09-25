/// ผู้ใช้จำลองของโมดูล ER (หน้า login จำลอง เลือกบทบาทแพทย์/พยาบาล ER/พยาบาลคัดกรอง)
///
/// ไม่เกี่ยวกับ login จริงของ HOSxP (Provider ID + PIN) — ใช้เพื่อเดโม workflow
/// ตามบทบาทเท่านั้น
library;

import 'package:flutter/foundation.dart';

/// บทบาทตามฟอร์ม HOSxP ที่แต่ละคนรับผิดชอบ
/// doctor = ฟอร์มแพทย์ · nurse = พยาบาลห้องฉุกเฉิน · triage = พยาบาลจุดคัดกรอง
enum ErRole { doctor, nurse, triage }

class ErUser {
  const ErUser({
    required this.id,
    required this.name,
    required this.role,
    required this.position,
    required this.shift,
    required this.face,
  });

  final String id;
  final String name;
  final ErRole role;
  final String position;
  final String shift;

  /// ไฟล์รูปหน้าใน assets/images/faces
  final String face;

  String get roleLabel => switch (role) {
        ErRole.doctor => 'แพทย์',
        ErRole.nurse => 'พยาบาล ER',
        ErRole.triage => 'พยาบาลคัดกรอง',
      };
}

/// รายชื่อเจ้าหน้าที่จำลองของกะนี้
const List<ErUser> erStaff = [
  ErUser(
    id: 'D001',
    name: 'พญ. ศิริพร กิตติวงศ์',
    role: ErRole.doctor,
    position: 'แพทย์เวชศาสตร์ฉุกเฉิน · แพทย์เวร',
    shift: 'เวรเช้า 08:00–16:00',
    face: 'assets/images/faces/face1.jpg',
  ),
  ErUser(
    id: 'D002',
    name: 'นพ. ธีรภัทร อมรเลิศ',
    role: ErRole.doctor,
    position: 'แพทย์เวชศาสตร์ฉุกเฉิน',
    shift: 'เวรเช้า 08:00–16:00',
    face: 'assets/images/faces/face2.jpg',
  ),
  ErUser(
    id: 'N001',
    name: 'พย. วราภรณ์ สุขใจ',
    role: ErRole.nurse,
    position: 'พยาบาลวิชาชีพ · หัวหน้าเวร',
    shift: 'เวรเช้า 08:00–16:00',
    face: 'assets/images/faces/face3.jpg',
  ),
  ErUser(
    id: 'N002',
    name: 'พย. ณัฐพร แซ่ลิ้ม',
    role: ErRole.triage,
    position: 'พยาบาลวิชาชีพ · จุดคัดกรอง',
    shift: 'เวรเช้า 08:00–16:00',
    face: 'assets/images/faces/face4.jpg',
  ),
];

/// สถานะผู้ใช้ปัจจุบัน ฟังการเปลี่ยนแปลงได้ (เปลี่ยนคนแล้วหน้าอัปเดตเอง)
class ErSession extends ChangeNotifier {
  ErSession._();
  static final ErSession instance = ErSession._();

  ErUser? _user;
  ErUser? get user => _user;
  ErRole get role => _user?.role ?? ErRole.doctor;

  /// พยาบาลทั้งสองบทบาท (ใช้กับคำเรียก/ข้อมูลประกอบที่เหมือนกัน)
  bool get isNurse => role != ErRole.doctor;

  /// พยาบาลจุดคัดกรอง (ขั้นของโหมดพูดแยกจากพยาบาล ER)
  bool get isTriage => role == ErRole.triage;
  bool get signedIn => _user != null;

  void signIn(ErUser u) {
    _user = u;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
