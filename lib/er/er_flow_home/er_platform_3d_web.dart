/// ฉากแท่นสามมิติฝั่งเว็บ — WebView กับ HttpServer ใช้บนเว็บไม่ได้
///
/// จึงวาดเป็นภาพนิ่งแบบเรียบ ๆ แทน ให้ตัวจำลองแท็บเล็ตยังเปิดหน้านี้ได้
library;

import 'package:flutter/material.dart';

import 'er_flow_3d_types.dart';

class ErPlatform {
  const ErPlatform({
    required this.key,
    required this.color,
    required this.value,
    this.alert = false,
  });

  final String key;
  final Color color;
  final int value;
  final bool alert;
}

class ErPlatform3D extends StatelessWidget {
  const ErPlatform3D({
    super.key,
    required this.platforms,
    required this.cam,
    this.highlight,
    this.onStageTap,
    this.onPositions,
  });

  final List<ErPlatform> platforms;
  final ErFlowCam cam;
  final String? highlight;
  final void Function(String key)? onStageTap;
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFF8F9FA),
        child: Center(
          child: Text(
            'ฉากสามมิติแสดงบนแท็บเล็ตเท่านั้น',
            style: TextStyle(
                fontFamily: 'IBMPlexSansThaiLooped',
                fontSize: 12.0,
                color: Color(0xFF9AA0A6)),
          ),
        ),
      );
}
