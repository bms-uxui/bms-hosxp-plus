// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ คัดลอกแบบแท็บเล็ต
// ไม่ต้องลากเลือกข้อความทีละตัว: กดค้างที่ก้อนข้อมูล = คัดลอกทั้งก้อนทันที
// ก้อนที่คัดลอกได้มีปุ่มคัดลอกเล็กที่มุม

extension _FeaturesPatientCopyToolsPart on _ErFlowHomeWidgetState {
  /// คัดลอกข้อความ + สั่นเบา ๆ · notify = แจ้ง snackbar "คัดลอกสำเร็จ" สั้น ๆ
  void _copyText(String label, String text, {bool notify = false}) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    if (notify) {
      final m = ScaffoldMessenger.of(context);
      m.hideCurrentSnackBar();
      m.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 360.0,
        duration: const Duration(seconds: 2),
        backgroundColor: _inkTitle,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, size: 16.0, color: _green),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text('คัดลอก$labelสำเร็จ',
                style: _t(12.0, color: Colors.white, weight: FontWeight.w600)),
          ),
        ]),
      ));
    }
  }

  /// ปุ่มคัดลอกเล็ก (เป้ากดใหญ่พอสำหรับนิ้ว)
  Widget _copyBtn(String label, String Function() text) => _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _copyText(label, text()),
          child: Container(
            height: 26.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              gradient: _glossWhite,
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: _line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.copy_rounded, size: 13.0, color: _ink2),
              const SizedBox(width: 4.0),
              Text('คัดลอก',
                  style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  /// ก้อนข้อมูลที่กดค้างแล้วคัดลอกทั้งก้อน
  Widget _copyable(String label, String text, Widget child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _copyText(label, text),
        child: child,
      );

  /// ข้อความผล Lab หนึ่งรายการ (ชื่อ ค่า ธง)
  String _labCopy(ErLab l) {
    final flag = l.isNumeric
        ? (l.value > l.hi ? ' (H)' : (l.value < l.lo ? ' (L)' : ''))
        : (l.abnormal ? ' (ผิดปกติ)' : '');
    return '${l.name} ${l.resultText}$flag';
  }
}
