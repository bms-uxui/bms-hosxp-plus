/// ฉากสามมิติฝั่งเว็บ — ใช้ตอนรันใน tablet simulator
///
/// WebView กับ HttpServer ทำงานบนเว็บไม่ได้ จึงปล่อยว่างไว้
/// ป้ายต่าง ๆ ฝั่ง Flutter จะไม่ขึ้นเพราะไม่มีตำแหน่งส่งกลับมา
library;

import 'package:flutter/material.dart';

import 'er_flow_3d_types.dart';

class ErFlow3D extends StatelessWidget {
  const ErFlow3D({
    super.key,
    required this.stages,
    required this.cam,
    this.model = 'assets/models/er_flow.glb',
    this.highlight,
    this.onStageTap,
    this.onPositions,
  });

  final List<String> stages;
  final ErFlowCam cam;
  final String model;
  final String? highlight;
  final void Function(String key)? onStageTap;
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFF8F9FA),
        child: Center(
          child: Text('ฉากสามมิติแสดงเฉพาะบนแท็บเล็ตจริง',
              style: TextStyle(fontSize: 12.0, color: Color(0xFF9AA0A6))),
        ),
      );
}
