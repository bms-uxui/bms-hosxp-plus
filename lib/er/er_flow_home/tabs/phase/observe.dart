// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

extension _TabsPhaseObservePart on _ErFlowHomeWidgetState {
  /// การ์ดข้อมูลผู้ป่วยลอยล่างฉาก ชุดเดียวกับหน้าผังเตียง
  ///
  /// หัวการ์ดบอกเตียงกับระดับความเร่งด่วน ตัวการ์ดบอกชื่อ HN และสรุปอาการ
  /// ท้ายการ์ดเป็นปุ่มลัดไปงานที่ทำต่อจากตรงนี้

  /// บันทึกกิจกรรมพยาบาลของผู้ป่วย (ใหม่ → เก่า) ถ้าไม่มีบันทึกใช้เหตุการณ์ของพยาบาล
  List<ErNote> _nurseNotesOf(_P p) {
    final c = erCaseOf(p.hn);
    if (c.nurseNotes.isNotEmpty) return c.nurseNotes;
    return [
      if (c.lastNote != null) c.lastNote!,
      for (final e in c.events)
        if (!e.byDoctor && e.time != c.lastNote?.time)
          ErNote(e.time, 'พยาบาล', e.text),
    ];
  }

  /// ไทม์ไลน์กิจกรรมพยาบาล: เวลา · ผู้บันทึก · ข้อความอิสระ เลื่อนดูย้อนหลังได้
  Widget _nurseActivity(_P p) {
    final notes = _nurseNotesOf(p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, size: 15.0, color: _blue),
          const SizedBox(width: 5.0),
          Text('กิจกรรมพยาบาล',
              style: _t(11.0, color: _blueHue, weight: FontWeight.w700)),
          const SizedBox(width: 6.0),
          Text('${notes.length} บันทึก', style: _t(9.5, color: _ink3)),
          const Spacer(),
          if (notes.isNotEmpty)
            Text('ล่าสุด ${notes.first.time} น.', style: _t(9.5, color: _ink3)),
        ]),
        const SizedBox(height: 6.0),
        if (notes.isEmpty)
          Text('ยังไม่มีบันทึกทางการพยาบาล', style: _t(11.0, color: _ink3))
        else
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final n = notes[i];
                final last = i == notes.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 40.0,
                        child: Text(n.time,
                            style: _num(10.5,
                                color: i == 0 ? _inkTitle : _ink3,
                                weight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 14.0,
                        child: Column(children: [
                          const SizedBox(height: 4.0),
                          Container(
                            width: 7.0,
                            height: 7.0,
                            decoration: BoxDecoration(
                              color: i == 0 ? _blue : _g5,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!last)
                            Expanded(
                                child: Container(width: 1.0, color: _line)),
                        ]),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.text,
                                  style: _t(11.5,
                                      color: i == 0 ? _inkTitle : _ink,
                                      height: 1.4)),
                              Text(n.by, style: _t(9.5, color: _ink3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
