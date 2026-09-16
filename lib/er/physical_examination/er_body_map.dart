/// แผนที่ร่างกายสำหรับบันทึกผลตรวจร่างกายในห้องฉุกเฉิน
///
/// ภาพเป็นเงาร่างกายที่ตัดเป็นชั้นตาม region แต่ละชั้นซ้อนกันพอดีพิกเซล
/// จึงระบายสีทีละส่วนได้โดยไม่ต้องวาด path เอง
///
/// ที่มาข้อมูล: BodyParts3D, © The Database Center for Life Science
/// licensed under CC Attribution 4.0 International
/// https://dbarchive.biosciencedbc.jp/en/bodyparts3d/
library;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'er_body_region.dart';
import 'er_body_region_rects.dart';

/// ผลตรวจของ region หนึ่ง ใช้เลือกสีที่ระบาย
enum ErBodyFinding {
  /// ยังไม่ได้ตรวจ
  pending,

  /// ตรวจแล้วปกติ
  normal,

  /// ตรวจแล้วผิดปกติ
  abnormal,
}

/// ด้านที่กำลังแสดง
enum ErBodyView { front, back }

const Map<ErBodyView, String> _viewKey = {
  ErBodyView.front: 'front',
  ErBodyView.back: 'back',
};

class ErBodyMap extends StatelessWidget {
  const ErBodyMap({
    super.key,
    required this.view,
    this.findings = const {},
    this.selectedRegionId,
    this.onRegionTap,
  });

  final ErBodyView view;

  /// ผลตรวจรายส่วน คีย์คือ [ErBodyRegion.id] ส่วนที่ไม่มีในนี้ถือว่ายังไม่ตรวจ
  final Map<String, ErBodyFinding> findings;

  /// ส่วนที่กำลังเลือกอยู่ วาดเส้นขอบเน้น
  final String? selectedRegionId;

  final void Function(ErBodyRegion region)? onRegionTap;

  Map<String, Rect> get _rects =>
      erBodyRegionRects[_viewKey[view]!] ?? const {};

  Color _fill(BuildContext context, String id) {
    final theme = FlutterFlowTheme.of(context);
    switch (findings[id] ?? ErBodyFinding.pending) {
      case ErBodyFinding.normal:
        return const Color(0xFF37E974);
      case ErBodyFinding.abnormal:
        return theme.error;
      case ErBodyFinding.pending:
        return theme.alternate;
    }
  }

  /// หา region จากจุดที่แตะ เลือกกรอบที่เล็กที่สุดที่ครอบจุดนั้น
  /// เพื่อให้มือชนะแขน และเท้าชนะขา เวลากรอบซ้อนกัน
  ErBodyRegion? _hit(Offset unit) {
    String? best;
    double bestArea = double.infinity;
    _rects.forEach((id, r) {
      if (!r.contains(unit)) return;
      final area = r.width * r.height;
      if (area < bestArea) {
        bestArea = area;
        best = id;
      }
    });
    return best == null ? null : erBodyRegionById(best!);
  }

  @override
  Widget build(BuildContext context) {
    final viewKey = _viewKey[view]!;
    final ids = _rects.keys.toList();
    return AspectRatio(
      aspectRatio: erBodyImageSize.width / erBodyImageSize.height,
      child: LayoutBuilder(
        builder: (context, box) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final unit = Offset(
              details.localPosition.dx / box.maxWidth,
              details.localPosition.dy / box.maxHeight,
            );
            final region = _hit(unit);
            if (region != null) onRegionTap?.call(region);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (final id in ids)
                Image.asset(
                  'assets/images/body/${viewKey}_$id.png',
                  fit: BoxFit.contain,
                  color: _fill(context, id),
                  colorBlendMode: BlendMode.srcIn,
                  filterQuality: FilterQuality.medium,
                ),
              // เส้นขอบเน้นส่วนที่เลือก วาดทับด้วยภาพเดิมสีเข้มกว่า
              if (selectedRegionId != null &&
                  _rects.containsKey(selectedRegionId))
                Image.asset(
                  'assets/images/body/${viewKey}_$selectedRegionId.png',
                  fit: BoxFit.contain,
                  color: FlutterFlowTheme.of(context).primary,
                  colorBlendMode: BlendMode.srcIn,
                  filterQuality: FilterQuality.medium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่มสลับด้านหน้า/ด้านหลัง
class ErBodyViewToggle extends StatelessWidget {
  const ErBodyViewToggle({
    super.key,
    required this.view,
    required this.onChanged,
  });

  final ErBodyView view;
  final ValueChanged<ErBodyView> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget item(ErBodyView v, String label) {
      final on = v == view;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => onChanged(v),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: on ? theme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.bodySmall.override(
                fontWeight: FontWeight.w500,
                color: on ? Colors.white : theme.secondaryText,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          item(ErBodyView.front, 'ด้านหน้า'),
          item(ErBodyView.back, 'ด้านหลัง'),
        ],
      ),
    );
  }
}
