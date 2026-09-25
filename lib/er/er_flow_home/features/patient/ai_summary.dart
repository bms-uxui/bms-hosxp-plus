// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

List<String> _strList(Object? v) => [
      for (final x in (v is List ? v : const []))
        if (x is String && x.trim().isNotEmpty) x
    ];

Color _sevColor(Object? s) => switch (s) {
      'critical' => _dRed,
      'urgent' => _dAccent,
      _ => _dAccent,
    };

String _sevLabel(Object? s) => switch (s) {
      'critical' => 'วิกฤต',
      'urgent' => 'เร่งด่วน',
      _ => 'คงที่',
    };

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientAiSummaryState on State<ErFlowHomeWidget> {
  /// หน้าสรุปเคสด้วย AI (ทับหน้ารายละเอียด หุ่นเป็นเอกซเรย์พื้นมืด)
  bool _summaryOpen = false;
  bool _summaryBusy = false;
  String? _summaryErr;
  final Map<String, Map<String, dynamic>> _summaryCache = {};
}

extension _FeaturesPatientAiSummaryPart on _ErFlowHomeWidgetState {
  // ------------------------------------------------ หน้าสรุปเคสด้วย AI
  /// เปิดหน้าสรุป: หุ่นเปลี่ยนเป็นเอกซเรย์พื้นมืด แล้วให้ LLM สรุปจากข้อมูลเคสทั้งหมด
  Future<void> _openSummary({bool refresh = false}) async {
    final hn = _caseP().hn;
    setState(() {
      _summaryOpen = true;
      _fabOpen = false;
      _timelineOpen = false;
      _summaryErr = null;
    });
    if (!refresh && _summaryCache.containsKey(hn)) return;
    setState(() => _summaryBusy = true);
    final t0 = DateTime.now();
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': '''
คุณคือแพทย์เวชศาสตร์ฉุกเฉินอาวุโส สรุปเคสผู้ป่วยห้องฉุกเฉินให้ทีมอ่านใน 10 วินาที
ใช้เฉพาะข้อมูลที่ให้มา ห้ามแต่งผลตรวจหรือยาที่ไม่มี ภาษาไทยปนศัพท์แพทย์อังกฤษได้
ทุกช่องเขียนภาษาไทยเป็นหลัก ใช้อังกฤษเฉพาะศัพท์แพทย์/ชื่อยา/ชื่อแล็บ
ตอบ JSON เท่านั้น รูปแบบ:
{"headline":"<สรุป 1 บรรทัดภาษาไทย (ศัพท์แพทย์อังกฤษได้) ไม่เกิน 14 คำ>",
 "severity":"critical|urgent|stable",
 "summary":"<ย่อหน้าเดียว 2-3 ประโยค: ใคร มาด้วยอะไร ตอนนี้เป็นอย่างไร>",
 "problems":[{"title":"<ปัญหา>","organ":"brain|heart|lungs|liver|stomach|kidneys|intestine|bladder","status":"critical|urgent|stable","detail":"<หลักฐานสั้น ๆ เช่น ค่าแล็บ/สัญญาณชีพ>"}],
 "red_flags":["<สิ่งอันตรายที่ต้องจับตา>"],
 "done":["<สิ่งที่ทำไปแล้ว>"],
 "pending":["<ผล/งานที่ค้าง>"],
 "next_actions":[{"text":"<สิ่งที่ควรทำต่อ>","owner":"แพทย์|พยาบาล","urgent":true}],
 "disposition":"<แนวทางจำหน่ายที่เหมาะ พร้อมเหตุผลสั้น>"}
problems ไม่เกิน 4 ข้อ organ ต้องเป็นหนึ่งในรายการที่กำหนด red_flags/pending/done ไม่เกิน 4 ข้อ next_actions ไม่เกิน 4 ข้อ''',
        },
        {'role': 'user', 'content': 'ข้อมูลเคส:\n${_caseContext()}'},
      ], json: true, fast: true, maxTokens: 900, temperature: 0.2);
      debugPrint(
          'ErAi สรุปเคส ${DateTime.now().difference(t0).inMilliseconds} ms');
      final data = ErAi.extractJson(out);
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = data ?? _fallbackSummary();
        if (data == null)
          _summaryErr = 'AI ตอบไม่เป็นรูปแบบ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = _fallbackSummary();
        _summaryErr = 'เชื่อมต่อ AI ไม่ได้ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    }
  }

  /// สรุปสำรองจากข้อมูลเคสตรง ๆ เมื่อ AI ใช้ไม่ได้
  Map<String, dynamic> _fallbackSummary() {
    final c = _case;
    final p = _caseP();
    final organs = _organsOfCase(c);
    return {
      'headline': c.dx.isNotEmpty ? c.dx.first.text : c.cc,
      'severity': (p.esi?.level ?? 3) <= 1
          ? 'critical'
          : ((p.esi?.level ?? 3) <= 2 ? 'urgent' : 'stable'),
      'summary': '${c.sex} ${c.age} ปี ${c.cc}',
      'problems': [
        for (var i = 0; i < c.dx.length && i < 4; i++)
          {
            'title': c.dx[i].text,
            'organ': organs.isEmpty ? 'heart' : organs[i % organs.length],
            'status':
                c.dx[i].level.name == 'normal' ? 'stable' : c.dx[i].level.name,
            'detail': c.dx[i].icd10 ?? '',
          }
      ],
      'red_flags': c.advice,
      'done': [for (final m in c.meds) '${m.name} ${m.time}'],
      'pending': [
        for (final i in c.imaging)
          if (i.result.contains('รอ')) i.name
      ],
      'next_actions': [
        {'text': c.nextStep, 'owner': 'แพทย์', 'urgent': true}
      ],
      'disposition': c.disposition.isEmpty ? c.nextDetail : c.disposition,
    };
  }

  Map<String, dynamic>? get _summary => _summaryCache[_caseP().hn];

  /// อวัยวะที่ให้หุ่นเรืองแสงในหน้าสรุป
  List<String> _summaryOrgans() {
    const ok = {
      'brain',
      'heart',
      'lungs',
      'liver',
      'stomach',
      'kidneys',
      'intestine',
      'bladder'
    };
    final list = [
      for (final pr in (_summary?['problems'] as List? ?? const []))
        if (pr is Map && ok.contains(pr['organ'])) pr['organ'] as String
    ];
    // กระดูกที่หักมาจากตัว map เสมอ (LLM สรุปเฉพาะอวัยวะ)
    final bones = [
      for (final c in _bodyCodesOfCase(_case))
        if (c.startsWith('bone:')) c,
    ];
    return [
      ...(list.isEmpty ? _organsOfCase(_case) : list.toSet().toList()),
      ...bones,
    ];
  }

  Widget _dCard(Widget child, {EdgeInsets? pad, Color? glow}) => Container(
        padding: pad ?? const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: _dPanel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: glow?.withValues(alpha: 0.55) ?? _dLine),
          boxShadow: [
            if (glow != null)
              BoxShadow(
                  color: glow.withValues(alpha: 0.12),
                  blurRadius: 18.0,
                  spreadRadius: 1.0),
          ],
        ),
        child: child,
      );

  Widget _dHead(IconData icon, String text, {Color color = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Icon(icon, size: 13.0, color: color),
          const SizedBox(width: 6.0),
          Text(text, style: _t(10.5, color: color, weight: FontWeight.w700)),
        ]),
      );

  Widget _dBullet(String text, {Color dot = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5.0,
              height: 5.0,
              margin: const EdgeInsets.only(top: 6.0, right: 8.0),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            Expanded(
                child: Text(text, style: _t(10.5, color: _dInk, height: 1.35))),
          ],
        ),
      );

  /// ตัวเลขใหญ่แบบภาพอ้างอิง: ค่าผิดปกติเป็นสีแดงเรืองแสง
  Widget _dMetric(String label, String value, String unit, bool bad,
          {IconData? icon}) =>
      _dCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 12.0, color: bad ? _dRed : _dInk2),
                const SizedBox(width: 5.0),
              ],
              Text(label, style: _t(9.5, color: _dInk2)),
            ]),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(26.0,
                            color: bad ? _dRed : _dInk, weight: FontWeight.w700)
                        .copyWith(shadows: [
                      if (bad)
                        Shadow(
                            color: _dRed.withValues(alpha: 0.6),
                            blurRadius: 14.0),
                    ])),
                const SizedBox(width: 4.0),
                Text(unit, style: _t(9.5, color: _dInk2)),
              ],
            ),
          ],
        ),
        pad: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
        glow: bad ? _dRed : null,
      );

  List<Widget> _summaryOverlays() {
    final c = _case;
    final p = _caseP();
    final s = _summary;
    final sev = s?['severity'];
    bool out(double v, double lo, double hi) => v < lo || v > hi;
    final gcs = int.tryParse(c.gcsScore);
    final left = ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
      children: [
        // ตัวตนผู้ป่วย + ความรุนแรงรวม
        _dCard(
          Row(children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: _sevColor(sev).withValues(alpha: 0.2),
              child: Icon(Icons.person_rounded, color: _sevColor(sev)),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: _t(14.0, color: _dInk, weight: FontWeight.w700)),
                  Text(
                      '${c.sex} ${c.age} ปี · HN ${p.hn} · เตียง ${p.bed ?? '—'}',
                      style: _t(9.5, color: _dInk2)),
                  const SizedBox(height: 4.0),
                  Wrap(spacing: 5.0, runSpacing: 4.0, children: [
                    _dChip(
                        p.esi == null ? 'ยังไม่คัดกรอง' : 'ESI ${p.esi!.level}',
                        p.esi?.hue ?? _dInk2),
                    _dChip('${p.stage.label} · ${_clockWait(p.waitMin)}',
                        _dAccent),
                    if (c.onset != null)
                      _dChip(
                          'เริ่มอาการ ${_clockWait(_minutesSince(c.onset!))}',
                          _dRed),
                  ]),
                ],
              ),
            ),
          ]),
          glow: _sevColor(sev),
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14.0, color: _dAccent),
              const SizedBox(width: 6.0),
              Text('AI สรุปเคส',
                  style: _t(10.5, color: _dAccent, weight: FontWeight.w700)),
              const Spacer(),
              if (s != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: _sevColor(sev).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(_sevLabel(sev),
                      style: _t(9.0,
                          color: _sevColor(sev), weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 8.0),
            if (_summaryBusy || s == null)
              Row(children: [
                const SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: _dAccent)),
                const SizedBox(width: 8.0),
                Text('กำลังอ่านข้อมูลทั้งเคสและสรุป…',
                    style: _t(10.5, color: _dInk2)),
              ])
            else ...[
              Text(s['headline']?.toString() ?? '',
                  style: _t(15.0,
                      color: _dInk, weight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 6.0),
              Text(s['summary']?.toString() ?? '',
                  style: _t(11.0, color: _dInk, height: 1.45)),
              if (_summaryErr != null) ...[
                const SizedBox(height: 6.0),
                Text(_summaryErr!, style: _t(9.0, color: _dAccent)),
              ],
            ],
          ],
        )),
        if (s != null && _strList(s['red_flags']).isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dHead(Icons.warning_amber_rounded, 'ต้องจับตา', color: _dRed),
                for (final f in _strList(s['red_flags']))
                  _dBullet(f, dot: _dRed),
              ],
            ),
            glow: _dRed,
          ),
        ],
        if (c.allergies.isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.block_rounded, 'แพ้ยา / แพ้อาหาร', color: _dRed),
              Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final a in c.allergies) _dChip(a, _dRed),
              ]),
            ],
          )),
        ],
      ],
    );

    final problems = [
      for (final pr in (s?['problems'] as List? ?? const []))
        if (pr is Map) pr
    ];
    final actions = [
      for (final a in (s?['next_actions'] as List? ?? const []))
        if (a is Map) a
    ];
    final right = ListView(
      padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
      children: [
        // ตัวเลขใหญ่: สัญญาณชีพล่าสุด
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.9,
          children: [
            _dMetric(
                'ชีพจร', '${c.hr.last.round()}', 'bpm', out(c.hr.last, 60, 100),
                icon: Icons.favorite_rounded),
            _dMetric('ความดัน', c.bp, 'mmHg', out(c.sbp.last, 90, 140),
                icon: Icons.monitor_heart_rounded),
            _dMetric('SpO₂', '${c.spo2.last.round()}', '%',
                out(c.spo2.last, 94, 100),
                icon: Icons.bubble_chart_rounded),
            _dMetric('GCS', c.gcsScore, '/15', gcs != null && gcs < 15,
                icon: Icons.psychology_rounded),
          ],
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.biotech_rounded, 'ปัญหาหลัก · ตำแหน่งบนร่างกาย'),
            if (problems.isEmpty)
              Text(_summaryBusy ? '…' : 'ไม่มีปัญหาเร่งด่วน',
                  style: _t(10.5, color: _dInk2)),
            for (final pr in problems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(top: 5.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: _sevColor(pr['status']),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _sevColor(pr['status'])
                                  .withValues(alpha: 0.7),
                              blurRadius: 8.0),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pr['title']?.toString() ?? '',
                              style: _t(11.0,
                                  color: _dInk, weight: FontWeight.w700)),
                          if ((pr['detail']?.toString() ?? '').isNotEmpty)
                            Text(pr['detail'].toString(),
                                style: _t(9.5, color: _dInk2, height: 1.3)),
                        ],
                      ),
                    ),
                    Text(_organTh(pr['organ']),
                        style: _t(9.0, color: _dAccent)),
                  ],
                ),
              ),
          ],
        )),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.bolt_rounded, 'ควรทำต่อ', color: _dAccent),
            if (actions.isEmpty)
              Text(_summaryBusy ? '…' : '-', style: _t(10.5, color: _dInk2)),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        a['urgent'] == true
                            ? Icons.priority_high_rounded
                            : Icons.arrow_right_rounded,
                        size: 14.0,
                        color: a['urgent'] == true ? _dRed : _dInk2),
                    const SizedBox(width: 4.0),
                    Expanded(
                        child: Text(a['text']?.toString() ?? '',
                            style: _t(10.5, color: _dInk, height: 1.3))),
                    const SizedBox(width: 6.0),
                    _dChip(a['owner']?.toString() ?? 'แพทย์', _dInk2),
                  ],
                ),
              ),
          ],
        )),
        if (s != null) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.task_alt_rounded, 'ทำไปแล้ว', color: _dAccent),
              for (final d in _strList(s['done'])) _dBullet(d, dot: _dAccent),
              const SizedBox(height: 4.0),
              _dHead(Icons.hourglass_top_rounded, 'รอผล / ค้าง',
                  color: _dAccent),
              if (_strList(s['pending']).isEmpty)
                Text('ไม่มี', style: _t(10.5, color: _dInk2)),
              for (final d in _strList(s['pending']))
                _dBullet(d, dot: _dAccent),
            ],
          )),
        ],
      ],
    );

    return [
      Positioned(left: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: left),
      Positioned(right: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: right),
      // แถบล่างกลาง: แนวทางจำหน่าย + ปุ่ม
      Positioned(
        left: 372.0,
        right: 372.0,
        bottom: 14.0,
        child: _dCard(
          Row(children: [
            const Icon(Icons.logout_rounded, size: 16.0, color: _dAccent),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('แนวทางจำหน่าย', style: _t(9.0, color: _dInk2)),
                  Text(
                      s?['disposition']?.toString() ??
                          (_summaryBusy ? 'กำลังประเมิน…' : '-'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0,
                          color: _dInk, weight: FontWeight.w600, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            _dButton(Icons.copy_rounded, 'คัดลอก', () {
              final sm = _summary;
              if (sm == null) return;
              Clipboard.setData(ClipboardData(
                  text:
                      '${p.name} HN ${p.hn}\n${sm['headline']}\n${sm['summary']}\n'
                      'แผน: ${sm['disposition']}'));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('คัดลอกสรุปแล้ว')));
            }),
            const SizedBox(width: 6.0),
            _dButton(Icons.refresh_rounded, 'สรุปใหม่',
                _summaryBusy ? null : () => _openSummary(refresh: true)),
            const SizedBox(width: 6.0),
            _dButton(Icons.close_rounded, 'ปิด',
                () => setState(() => _summaryOpen = false)),
          ]),
          pad: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
        ),
      ),
    ];
  }

  Widget _dChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child:
            Text(text, style: _t(9.0, color: color, weight: FontWeight.w700)),
      );

  Widget _dButton(IconData icon, String label, VoidCallback? onTap) => _Press(
          child: Material(
        color: _blue.withValues(alpha: onTap == null ? 0.03 : 0.07),
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            child: Row(children: [
              Icon(icon, size: 14.0, color: _dInk),
              const SizedBox(width: 5.0),
              Text(label,
                  style: _t(10.0, color: _dInk, weight: FontWeight.w600)),
            ]),
          ),
        ),
      ));
}
