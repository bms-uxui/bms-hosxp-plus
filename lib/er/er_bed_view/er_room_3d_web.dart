/// ฉากสามมิติฝั่งเว็บ — ใช้ตอนรันใน tablet simulator เท่านั้น
///
/// webview_flutter ไม่มีตัวจริงบนเว็บ และฉากบนมือถือต้องเปิด HttpServer
/// ที่ 127.0.0.1 ซึ่งทำบนเว็บไม่ได้ จึงแทนด้วยภาพนิ่งของห้องที่เรนเดอร์ไว้
/// หน้าเตียงส่วนที่เหลือ (แผงต่าง ๆ แถบล่าง) ทำงานได้ตามปกติ
///
/// ป้ายเตียงจะไม่ขึ้น เพราะตำแหน่งบนจอต้องให้ฝั่งสามมิติคำนวณส่งกลับมา
library;

import 'package:flutter/material.dart';

import 'er_room_types.dart';

class ErRoom3D extends StatelessWidget {
  const ErRoom3D({
    super.key,
    required this.beds,
    required this.selectedCode,
    required this.cam,
    this.onBedTap,
    this.onPositions,
    this.onHotspots,
    this.topView = false,
    this.layer = 'skin',
    this.highlight = const [],
    this.dark = false,
    this.pageBg = 0xFFFFFF,
    this.zoom = 1.0,
    this.zoomTick = 0,
    this.pickMode = false,
    this.onBodyPick,
  });

  final List<ErRoomBed> beds;
  final String selectedCode;
  final ErCam cam;
  final void Function(String code)? onBedTap;
  final void Function(List<ErBedScreenPos> positions)? onPositions;
  final void Function(List<ErBedScreenPos> spots)? onHotspots;
  final bool topView;
  final String layer;
  final List<String> highlight;
  final bool dark;
  final int pageBg;
  final double zoom;
  final int zoomTick;
  final bool pickMode;
  final void Function(String bone)? onBodyPick;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bed/er_room.png', fit: BoxFit.cover),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: const Text(
                  'ฉากสามมิติแสดงเฉพาะบนแท็บเล็ตจริง — นี่คือภาพนิ่งแทน',
                  style: TextStyle(color: Colors.white, fontSize: 11.0),
                ),
              ),
            ),
          ),
        ],
      );
}
