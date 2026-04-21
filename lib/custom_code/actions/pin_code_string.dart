// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> pinCodeString(String? numbers) async {
  // ดึงรหัส PIN ปัจจุบันจากตัวแปรสถานะของแอป
  String currentPinCode = FFAppState().pinCode;

  // ถ้า numbers ไม่เป็น null และเมื่อนำมาต่อกันแล้วยังไม่เกิน 6 หลัก
  if (numbers != null && (currentPinCode.length + numbers.length) <= 6) {
    currentPinCode += numbers; // เพิ่มตัวเลขเข้าไปในรหัส PIN
  }

  // อัปเดตรหัส PIN ใหม่กลับไปยังสถานะของแอป
  FFAppState().pinCode = currentPinCode;

  // ส่งค่ารหัส PIN ปัจจุบันกลับ
  return currentPinCode;
}
