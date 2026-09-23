/// ชนิดข้อมูลที่ฉากสามมิติของหน้าภาพรวมใช้ร่วมกับฝั่ง Flutter
library;

/// ตำแหน่งบนจอของจุดยึดแท่นหนึ่งขั้น ฝั่งสามมิติคำนวณส่งกลับมาทุกเฟรมที่ขยับ
class ErFlowStagePos {
  const ErFlowStagePos(this.key, this.dx, this.dy, this.visible);

  /// รหัสขั้น ตรงกับชื่อกลุ่มในไฟล์ฉาก เช่น triage
  final String key;

  /// พิกัดบนจอ หน่วยพิกเซลแบบ logical เท่ากับของ Flutter
  final double dx;
  final double dy;

  final bool visible;
}

/// ค่ากล้องของฉาก isometric ปรับได้เพื่อจูนองศาและระยะซูม
class ErFlowCam {
  const ErFlowCam({
    this.zoom = 13.0,
    this.yaw = 45.0,
    this.pitch = 35.264,
    this.shiftX = 0.0,
    this.shiftY = 0.0,
  });

  /// ความสูงของกรอบภาพเป็นเมตร ค่าน้อยคือซูมเข้า
  final double zoom;

  /// มุมหมุนรอบแกนตั้ง (องศา) 45 คือ isometric มาตรฐาน
  final double yaw;

  /// มุมก้ม (องศา) 35.264 คือ isometric จริงตามนิยาม
  final double pitch;

  /// เลื่อนฉากบนจอ (เมตร)
  final double shiftX;
  final double shiftY;

  String get js => '{zoom:$zoom,yaw:$yaw,pitch:$pitch,'
      'shiftX:$shiftX,shiftY:$shiftY}';
}
