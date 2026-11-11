// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ สรุป CC หลายผู้บันทึกด้วย AI
// รวมอาการสำคัญที่หลายคนบันทึก เป็นสรุปเดียว · ทุกช่วงข้อความมีเลขอ้างอิงผู้เขียน
// (ใคร · บทบาท · เวลา) · แยกข้อแตกต่างระหว่างผู้บันทึก

typedef _CcRec = ({String who, String role, String time, String text});

/// ช่วงข้อความในสรุป + ลำดับผู้บันทึกที่เป็นที่มา (1-based)
typedef _CcSeg = ({String text, List<int> src});

mixin _FeaturesPatientCcSummaryState on State<ErFlowHomeWidget> {
  /// ผลสรุปต่อ HN: (สรุป, ข้อแตกต่าง)
  final Map<String, ({List<_CcSeg> sum, List<_CcSeg> diff, List<_CcSeg> time})>
      _ccAi = {};
  final Set<String> _ccAiBusy = {};
  final Map<String, String> _ccAiErr = {};
}

extension _FeaturesPatientCcSummaryPart on _ErFlowHomeWidgetState {
  Future<void> _ccAiRun(String hn, List<_CcRec> recs) async {
    if (_ccAiBusy.contains(hn)) return;
    setState(() {
      _ccAiBusy.add(hn);
      _ccAiErr.remove(hn);
    });
    final list = [
      for (var i = 0; i < recs.length; i++)
        '[${i + 1}] ${recs[i].role} เวลา ${recs[i].time}: ${recs[i].text}'
    ].join('\n');
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': '''
คุณช่วยแพทย์ห้องฉุกเฉินรวม "อาการสำคัญ" ที่หลายคนบันทึก
ใช้เฉพาะข้อความที่ให้มา ห้ามเพิ่มข้อมูลใหม่ ภาษาไทยกระชับ
ตอบเป็น JSON เท่านั้น:
{"summary":[{"text":"ข้อความช่วงหนึ่ง","src":[เลขผู้บันทึกที่เป็นที่มา]}],
 "timeline":[{"text":"อาการ ณ เวลาที่บันทึกนั้น เน้นสิ่งที่เปลี่ยนหรือพบใหม่","src":[เลขผู้บันทึกหนึ่งคน]}],
 "diff":[{"text":"จุดที่แต่ละคนบันทึกต่างกัน","src":[เลขที่เกี่ยวข้อง]}]}
- summary = ประโยคเดียวยาวต่อเนื่อง เล่าอาการตามเวลาเกิด แบ่งเป็น 2-5 ช่วงที่ต่อกันแล้วอ่านเป็นประโยคเดียว (ไม่ขึ้นประโยคใหม่) ทุกช่วงต้องมี src
- timeline = หนึ่งรายการต่อผู้บันทึกแต่ละคน เรียงตามเวลาบันทึก บอกว่าช่วงนั้นอาการเป็นอย่างไร
  เทียบกับครั้งก่อน (แย่ลง/ดีขึ้น/พบใหม่/คงเดิม) สั้น 1 ประโยค
- diff = ข้อมูลที่ขัดกันหรือเปลี่ยนไประหว่างผู้บันทึก (เช่น ความปวดเพิ่มขึ้น) ไม่มีให้เป็น []'''
        },
        {'role': 'user', 'content': list},
      ], fast: true, json: true, temperature: 0.1, maxTokens: 500);
      final j = ErAi.extractJson(out);
      List<_CcSeg> segs(Object? v) => [
            for (final e in (v as List?) ?? const [])
              if (e is Map && (e['text'] ?? '').toString().trim().isNotEmpty)
                (
                  text: e['text'].toString().trim(),
                  src: [
                    for (final n in (e['src'] as List?) ?? const [])
                      if (n is num && n >= 1 && n <= recs.length) n.toInt()
                  ],
                ),
          ];
      final sum = segs(j?['summary']);
      if (sum.isEmpty) throw 'empty';
      if (!mounted) return;
      // ไทม์ไลน์ต้องครบทุกผู้บันทึก · ขาดใช้ข้อความที่บันทึกจริงแทน
      final tl = segs(j?['timeline']);
      final time = [
        for (var i = 1; i <= recs.length; i++)
          tl.firstWhere((t) => t.src.contains(i),
              orElse: () => (text: recs[i - 1].text, src: [i])),
      ];
      setState(
          () => _ccAi[hn] = (sum: sum, diff: segs(j?['diff']), time: time));
    } catch (e) {
      if (mounted)
        setState(() => _ccAiErr[hn] = 'สรุปไม่สำเร็จ ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _ccAiBusy.remove(hn));
    }
  }
}

/// skeleton ระหว่าง AI วิเคราะห์อาการสำคัญ: โครงเดียวกับผลลัพธ์ (สรุป + ไทม์ไลน์)
/// แถบไล่สีโทน AI (กรมท่า → คราม → ฟ้า) กวาดผ่าน · ไอคอนประกายกะพริบ
class _CcAiSkeleton extends StatefulWidget {
  const _CcAiSkeleton(
      {required this.label, required this.style, required this.rows});

  final String label;
  final TextStyle style;
  final int rows;

  @override
  State<_CcAiSkeleton> createState() => _CcAiSkeletonState();
}

class _CcAiSkeletonState extends State<_CcAiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(double w, {double h = 10.0}) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: w,
        child: Container(
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(h),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bones = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _bar(1.0),
        const SizedBox(height: 7.0),
        _bar(0.92),
        const SizedBox(height: 7.0),
        _bar(0.64),
        const SizedBox(height: 14.0),
        _bar(0.28, h: 8.0),
        for (var i = 0; i < widget.rows; i++) ...[
          const SizedBox(height: 10.0),
          Row(children: [
            SizedBox(width: 44.0, child: _bar(0.9, h: 9.0)),
            const SizedBox(width: 10.0),
            Container(
              width: 16.0,
              height: 16.0,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _bar(0.95, h: 9.0),
                  const SizedBox(height: 5.0),
                  _bar(0.5, h: 7.0),
                ],
              ),
            ),
          ]),
        ],
      ],
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              // ประกายโทน AI หมุนเบา ๆ + กะพริบ
              Transform.rotate(
                angle: t * 6.2832,
                child: Opacity(
                  opacity: 0.55 + 0.45 * (1 - (2 * t - 1).abs()),
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (r) => const LinearGradient(colors: [
                      _blue,
                      Color(0xFF5B5BD6),
                      Color(0xFF3AA8E0),
                    ]).createShader(r),
                    child: const Icon(Icons.auto_awesome_rounded, size: 16.0),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(child: Text(widget.label, style: widget.style)),
              Text('.' * (1 + (t * 3).floor() % 3), style: widget.style),
            ]),
            const SizedBox(height: 10.0),
            ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment(-2.4 + 4.0 * t, -0.4),
                end: Alignment(-0.4 + 4.0 * t, 0.4),
                colors: const [
                  Color(0xFFE6EAF5),
                  Color(0xFFC9D2F2),
                  Color(0xFFD6D3F7),
                  Color(0xFFCDE9F7),
                  Color(0xFFE6EAF5),
                ],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              ).createShader(rect),
              child: child,
            ),
          ],
        );
      },
      child: bones,
    );
  }
}
