/// ฉากขั้นบันไดฝั่งเว็บ — WebView ทำงานบนเว็บไม่ได้ จึงปล่อยว่าง
library;

import 'package:flutter/material.dart';

import 'er_flow_3d_types.dart';

/// หนึ่งแท่นในฉาก (ชนิดเดียวกับฝั่งมือถือ)
class ErStair {
  const ErStair({
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

class ErStair3D extends StatelessWidget {
  const ErStair3D({
    super.key,
    required this.stairs,
    this.selected,
    this.onTap,
    this.onPositions,
  });

  final List<ErStair> stairs;
  final String? selected;
  final void Function(String key)? onTap;
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
