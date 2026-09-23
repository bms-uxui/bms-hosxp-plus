/// ชนิดข้อมูลที่ใช้ร่วมกันระหว่างฉากสามมิติกับหน้าเตียง
///
/// แยกไว้ต่างหากเพราะฝั่งเว็บกับฝั่งมือถือใช้คนละตัวจริง แต่ใช้ชนิดเดียวกัน
library;

import 'package:flutter/material.dart';

/// เตียงหนึ่งช่องในฉาก พร้อมสีที่จะใช้ไฮไลต์
class ErRoomBed {
  const ErRoomBed({
    required this.code,
    required this.color,
    this.vacant = false,
  });

  final String code;
  final Color color;
  final bool vacant;

  Map<String, dynamic> toJson() => {
        'code': code,
        // three.js รับสีเป็นเลขฐานสิบหก 0xRRGGBB
        'color': color.toARGB32() & 0x00FFFFFF,
        'vacant': vacant,
      };
}

/// ตำแหน่งบนจอของเตียงหนึ่งเตียง ฝั่งเว็บคำนวณให้ทุกครั้งที่กล้องขยับ
/// ใช้วางป้ายเตียงเป็นวิดเจ็ตของ Flutter ทับบนฉาก ตัวหนังสือจึงคมเสมอ
class ErBedScreenPos {
  const ErBedScreenPos(this.code, this.dx, this.dy, this.visible);

  final String code;
  final double dx;
  final double dy;
  final bool visible;
}

/// ค่ากล้องของฉาก ปรับได้ตอนรันเพื่อจูนมุมมอง
///
/// กล้องมองตรงเข้าหาเตียงที่เลือก เตียงข้างเคียงลู่ออกไปสองข้างตามระยะ
/// แบบเดียวกับภาพต้นแบบใน Figma
class ErCam {
  const ErCam({
    this.height = 3.0,
    this.distance = 6.42,
    this.fov = 40.0,
    this.yaw = 0.0,
    this.lookY = -0.45,
    this.tagLift = 0.02,
    this.shiftX = 0.0,
    this.shiftY = 0.0,
    this.bedTurn = 0.0,
    this.screenX = 0.0,
    this.iso = false,
    this.zoom = 4.2,
    this.pitch = 16.0,
  });

  /// ความสูงของกล้องจากพื้น (เมตร)
  final double height;

  /// ระยะห่างจากเตียงที่เลือก (เมตร)
  final double distance;

  /// มุมมองภาพ (องศา)
  final double fov;

  /// มุมเอียงด้านข้าง (องศา) 0 = มองตรงเข้าหาเตียง
  final double yaw;

  /// ความสูงของจุดที่กล้องเล็ง (เมตร)
  final double lookY;

  /// ระยะยกป้ายเตียงเหนือหัวเตียง (เมตร)
  final double tagLift;

  /// เลื่อนกล้องตามแนวนอน (เมตร) ใช้ดันเตียงที่เลือกให้พ้นแผงที่ลอยทับอยู่
  final double shiftX;

  /// เลื่อนฉากขึ้นลง (เมตร)
  final double shiftY;

  /// true = ฉากแบบ isometric (กล้อง orthographic), false = เพอร์สเปกทีฟ
  final bool iso;

  /// ความสูงของกรอบภาพตอนเป็น isometric (เมตร) ค่าน้อย = ซูมเข้า
  final double zoom;

  /// มุมก้มตอนเป็น isometric (องศา)
  final double pitch;

  /// หมุนตัวเตียงเทียบกับกล้อง (องศา) 90 = หัวเตียงหันไปทางแถบเมนู
  final double bedTurn;

  /// เลื่อนภาพทั้งฉากตามแนวนอนบนจอ (พิกเซล) ค่าบวก = เตียงไปอยู่ทางซ้าย
  final double screenX;

  ErCam copyWith({
    double? height,
    double? distance,
    double? fov,
    double? yaw,
    double? lookY,
    double? tagLift,
    double? shiftX,
    double? shiftY,
    bool? iso,
    double? zoom,
    double? pitch,
    double? bedTurn,
    double? screenX,
  }) =>
      ErCam(
        height: height ?? this.height,
        distance: distance ?? this.distance,
        fov: fov ?? this.fov,
        yaw: yaw ?? this.yaw,
        lookY: lookY ?? this.lookY,
        tagLift: tagLift ?? this.tagLift,
        shiftX: shiftX ?? this.shiftX,
        shiftY: shiftY ?? this.shiftY,
        iso: iso ?? this.iso,
        zoom: zoom ?? this.zoom,
        pitch: pitch ?? this.pitch,
        bedTurn: bedTurn ?? this.bedTurn,
        screenX: screenX ?? this.screenX,
      );

  String get js => '{height:$height,distance:$distance,fov:$fov,'
      'yaw:$yaw,lookY:$lookY,tagLift:$tagLift,shiftX:$shiftX,'
      'shiftY:$shiftY,iso:$iso,zoom:$zoom,pitch:$pitch,bedTurn:$bedTurn,'
      'screenX:$screenX}';
}
