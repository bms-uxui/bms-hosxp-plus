// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _SidebarPinnedState on State<ErFlowHomeWidget> {
  /// HN ของผู้ป่วยที่ปักหมุดไว้ที่แถบขวา
  final Set<String> _pinned = {'670123461', '670123471'};
}

extension _SidebarPinnedPart on _ErFlowHomeWidgetState {
  String get _pinKey => 'er_pinned_$_uid';

  Future<void> _loadPins() async {
    try {
      final p = await SharedPreferences.getInstance();
      _loadTextSize(p);
      final l = p.getStringList(_pinKey);
      if (l != null && mounted) {
        setState(() => _pinned
          ..clear()
          ..addAll(l));
      }
    } catch (_) {}
  }
}
