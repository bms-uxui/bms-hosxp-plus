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

  /// tooltip ข้อความเต็มของแต่ละแถวในไทม์ไลน์ (เปิดเองตอนกดค้าง)
  final Map<String, GlobalKey<TooltipState>> _ccPeekKeys = {};
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

  /// รูปของผู้บันทึก (จับคู่ชื่อกับ staff) · ไม่พบ = อักษรย่อบนพื้นกรมท่า
  Widget _ccAvatar(_CcRec r, double size) {
    final first = r.who.split(' ').length > 1 ? r.who.split(' ')[1] : r.who;
    String? face;
    for (final u in erStaff) {
      if (u.name.contains(first)) face = u.face;
    }
    return Tooltip(
      message: '${r.who} · ${r.role} · ${r.time} น.',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          // avatar 3D พื้นโปร่ง: รองพื้นฟ้าอ่อนให้เต็มวง
          color: face == null ? null : const Color(0xFFDCE6F5),
          gradient: face == null ? _glossGrad(_blue) : null,
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: face != null
            // ขยายเน้นใบหน้า-ไหล่ ให้คนเต็มวง
            ? Transform.scale(
                scale: 1.35,
                alignment: const Alignment(0.0, -0.55),
                child: Image.asset(face,
                    width: size, height: size, fit: BoxFit.cover))
            : Text(first.isEmpty ? '?' : first.characters.first,
                style: _t(size * 0.42,
                    color: Colors.white, weight: FontWeight.w700)),
      ),
    );
  }

  /// avatar ของที่มาหลายคนซ้อนกันเล็กน้อย
  Widget _ccAvatars(List<int> src, List<_CcRec> recs, double size) {
    final list = src.where((n) => n >= 1 && n <= recs.length).toList();
    return SizedBox(
      width: list.isEmpty ? size : size + (list.length - 1) * size * 0.6,
      height: size,
      child: Stack(children: [
        for (var i = 0; i < list.length; i++)
          Positioned(
              left: i * size * 0.6, child: _ccAvatar(recs[list[i] - 1], size)),
      ]),
    );
  }

  int _ccMin(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  /// หนึ่งจุดบนไทม์ไลน์อาการ: เวลา (+ห่างจากครั้งก่อน) · เส้นเชื่อม · avatar · ข้อความ
  Widget _ccTimeRow(List<_CcSeg> tl, int i, List<_CcRec> recs) {
    final rec = recs[tl[i].src.first - 1];
    final prev = i > 0 ? recs[tl[i - 1].src.first - 1] : null;
    final gap = prev == null ? null : _ccMin(rec.time) - _ccMin(prev.time);
    final last = i == tl.length - 1;
    // กดค้าง = ดูอาการสำคัญฉบับเต็มที่ผู้บันทึกคนนี้เขียนไว้ (ไม่ใช่สรุปของ AI)
    final peek = _ccPeekKeys.putIfAbsent(
        '${rec.time}|${rec.who}', () => GlobalKey<TooltipState>());
    return Tooltip(
        key: peek,
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(seconds: 6),
        preferBelow: false,
        padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: _inkTitle,
          borderRadius: BorderRadius.circular(12.0),
        ),
        richMessage: TextSpan(children: [
          TextSpan(
              text: '${_clock(rec.time)}  ${rec.role} · ${rec.who}\n',
              style: _t(10.5, color: Colors.white.withValues(alpha: 0.75))),
          TextSpan(
              text: rec.text,
              style: _t(12.5,
                  color: Colors.white, weight: FontWeight.w500, height: 1.5)),
        ]),
        // กดค้าง: ripple ทั้งแถว แล้วเปิดข้อความเต็ม
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                splashColor: _blue.withValues(alpha: 0.10),
                highlightColor: _blue.withValues(alpha: 0.05),
                onTap: () {},
                onLongPress: () {
                  HapticFeedback.selectionClick();
                  peek.currentState?.ensureTooltipVisible();
                },
                child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // เวลาอยู่บนข้อความ (ไม่มีคอลัมน์เวลาซ้ายแล้ว)
                        SizedBox(
                          width: 14.0,
                          child: Column(children: [
                            const SizedBox(height: 5.0),
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: last ? _blue : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _blue, width: 1.5),
                              ),
                            ),
                            if (!last)
                              Expanded(
                                child: Container(
                                    width: 1.5,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    color: _blue.withValues(alpha: 0.25)),
                              ),
                          ]),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ccAvatar(rec, 18.0),
                                  const SizedBox(width: 6.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // เวลาบันทึก + ห่างจากครั้งก่อน อยู่เหนือข้อความ
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Text(_clock(rec.time),
                                                  style: _num(11.0,
                                                      color: _inkTitle,
                                                      weight: FontWeight.w700)),
                                              if (gap != null && gap > 0) ...[
                                                const SizedBox(width: 6.0),
                                                Text('+${_hm(gap)}',
                                                    style:
                                                        _t(9.5, color: _ink3)),
                                              ],
                                            ]),
                                        // AI มักขึ้นต้นด้วยเวลาซ้ำ ("09:22: …") ตัดออก เวลาอยู่บรรทัดบนแล้ว
                                        Text(
                                            tl[i]
                                                .text
                                                .replaceFirst(
                                                    RegExp(
                                                        r'^\s*\d{1,2}[:.]\d{2}\s*(น\.)?\s*[:\-–·]?\s*'),
                                                    '')
                                                .trim(),
                                            style: _t(11.5,
                                                color: _inkTitle,
                                                weight: FontWeight.w500,
                                                height: 1.4)),
                                        Text('${rec.role} · ${rec.who}',
                                            style: _t(9.0, color: _ink3)),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ]),
                ))));
  }

  /// เนื้อหาสรุป AI ในการ์ด CC: หนึ่งบรรทัดต่อหนึ่งช่วง · avatar ที่มาอยู่ซ้าย
  Widget _ccAiView(String hn, List<_CcRec> recs) {
    final r = _ccAi[hn];
    if (r == null) {
      if (!_ccAiBusy.contains(hn) && !_ccAiErr.containsKey(hn)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _ccAiRun(hn, recs));
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: _ccAiErr[hn] != null
            ? Row(children: [
                Expanded(
                    child: Text(_ccAiErr[hn]!, style: _t(11.0, color: _ink3))),
                TextButton(
                    onPressed: () => _ccAiRun(hn, recs),
                    child: Text('ลองใหม่',
                        style:
                            _t(11.0, color: _blue, weight: FontWeight.w700))),
              ])
            : _CcAiSkeleton(
                label: 'AI กำลังวิเคราะห์บันทึก ${recs.length} รายการ',
                style: _t(11.0, color: _blue, weight: FontWeight.w600),
                rows: recs.length.clamp(1, 3)),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // สรุปเป็นประโยคเดียวต่อเนื่อง (ไม่มีกรอบ)
      Text(
          r.sum
              .map((sg) => sg.text.trim())
              .where((t) => t.isNotEmpty)
              .join(' '),
          style:
              _t(12.5, color: _inkTitle, weight: FontWeight.w500, height: 1.5)),
      // อาการตามช่วงเวลาที่บันทึก: เวลา · ห่างจากครั้งก่อน · ผู้บันทึก · สิ่งที่เปลี่ยน
      const SizedBox(height: 8.0),
      Text('อาการตามช่วงเวลา',
          style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
      const SizedBox(height: 4.0),
      for (var i = 0; i < r.time.length; i++) _ccTimeRow(r.time, i, recs),
      // ไม่แสดงการ์ด "ต่างกันระหว่างผู้บันทึก" (ผู้ใช้สั่งเอาออก) · ความต่างดูได้จากไทม์ไลน์ด้านบน
      Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child:
            Text('สรุปโดย AI · ตรวจทานก่อนใช้', style: _t(9.0, color: _ink3)),
      ),
    ]);
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
