// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> removeLastPinCodeDigit() async {
  // ดึงรหัส PIN ปัจจุบันจากสถานะของแอป
  String currentPinString = FFAppState().pinCode;

  // แสดงผลรหัส PIN ก่อนแก้ไข (สำหรับ debug)
  print("Current Pin String before modification: $currentPinString");

  // ถ้ามีรหัสอยู่ ให้ลบตัวสุดท้ายออก
  if (currentPinString.isNotEmpty) {
    currentPinString =
        currentPinString.substring(0, currentPinString.length - 1);
  }

  // อัปเดตรหัส PIN ที่ถูกลบแล้วกลับไปยังสถานะของแอป
  FFAppState().pinCode = currentPinString;

  // แสดงผลรหัส PIN หลังแก้ไข (สำหรับ debug)
  print("Current Pin String after modification: $currentPinString");

  // ส่งค่ารหัส PIN ปัจจุบันกลับ
  return currentPinString;
}
