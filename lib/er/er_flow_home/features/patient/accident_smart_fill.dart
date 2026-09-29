part of '../../er_flow_home_widget.dart';

extension _AccidentSmartFillPart on _ErFlowHomeWidgetState {
  Future<Map<String, String>?> _accReviewFill(
    List<ErFillSuggestion> suggestions,
    Set<int> selected,
    Map<String, String> snapshot,
    Map<String, String> current,
  ) async {
    final selectedIndexes = selected
        .where((i) =>
            i >= 0 && i < suggestions.length && suggestions[i].applicable)
        .toList(growable: false);

    if (selectedIndexes.isEmpty) {
      return Map<String, String>.of(current);
    }

    final direct = <int>{};
    final conflicts = <int>[];

    for (final i in selectedIndexes) {
      final suggestion = suggestions[i];
      final currentValue = current[suggestion.field] ?? '';
      // ช่องว่าง หรือค่าปัจจุบันตรงกับค่าที่ AI พบ สามารถใช้ได้ตรง ๆ
      if (!ErSmartFill.conflicts(suggestion, currentValue)) {
        direct.add(i);
      } else {
        conflicts.add(i);
      }
    }

    var result = ErSmartFill.apply(
      suggestions,
      direct,
      {
        ...snapshot,
        // Reconcile fields cleared or already filled since analysis.
        for (final i in direct)
          suggestions[i].field: current[suggestions[i].field] ?? '',
      },
      current,
    );

    if (conflicts.isEmpty) {
      return result;
    }

    final useNew = <int>{};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(
            'ตรวจทานข้อมูลที่มีอยู่แล้ว',
            style: _t(14, weight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 660,
            height: math.min(480, MediaQuery.sizeOf(ctx).height * 0.6),
            child: ListView(
              children: [
                Text(
                  'พบข้อมูลเดิมในฟอร์ม เลือกเฉพาะรายการที่ต้องการใช้ข้อมูลใหม่',
                  style: _t(11, color: _ink2),
                ),
                const SizedBox(height: 10),
                for (final i in conflicts)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: _clyTileDeco(),
                    child: CheckboxListTile(
                      value: useNew.contains(i),
                      activeColor: _blue,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) => set(() {
                        if (checked == true) {
                          useNew.add(i);
                        } else {
                          useNew.remove(i);
                        }
                      }),
                      title: Text(
                        suggestions[i].field,
                        style: _t(11.5, weight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ข้อมูลเดิม: ${current[suggestions[i].field] ?? ''}',
                              style: _t(11, color: _ink2),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'ข้อมูลใหม่: ${suggestions[i].value}',
                              style: _t(12, color: _blue),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'จากข้อความ: “${suggestions[i].evidence}”',
                              style: _t(10.5, color: _ink3),
                            ),
                            if (suggestions[i].reason.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                suggestions[i].reason,
                                style: _t(10.5, color: _ink2),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              useNew.contains(i)
                                  ? 'ใช้ข้อมูลใหม่'
                                  : 'คงข้อมูลเดิม',
                              style: _t(10.5, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('ยกเลิก', style: _t(11, color: _ink2)),
            ),
            _apptPrimaryBtn(
              Icons.check_rounded,
              'ยืนยัน',
              () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return null;

    // หลังผู้ใช้ Review แล้ว ใช้ค่าปัจจุบันเป็น snapshot ใหม่สำหรับ conflict fields
    final reviewedSnapshot = Map<String, String>.of(current);
    result = ErSmartFill.apply(
      suggestions,
      useNew,
      reviewedSnapshot,
      result,
    );

    return result;
  }
}
