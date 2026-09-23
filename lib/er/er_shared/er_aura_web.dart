/// หุ่นยนต์ผู้ช่วยฝั่งเว็บ — แทนด้วยไอคอนนิ่ง ใช้ตอนรันใน tablet simulator
library;

import 'package:flutter/material.dart';

import 'er_aura_types.dart';

class ErAiAura extends StatelessWidget {
  const ErAiAura({super.key, required this.controller});

  final ErAuraController controller;

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(Icons.smart_toy_outlined,
            size: 64.0, color: Color(0xFF9AA0A6)),
      );
}
