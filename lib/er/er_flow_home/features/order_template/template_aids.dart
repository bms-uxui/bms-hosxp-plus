// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ตัวช่วยของ template order
// แถบสาขาคำสั่ง + เหตุผล · ผล lab ช่วยติ๊กเกณฑ์ · กฎความปลอดภัย antivenom
// · รอบประเมิน (คอลัมน์ Date) · หน้าสรุปแบบกระดาษเดิม

extension _FeaturesOrderTemplateTemplateAidsPart on _ErFlowHomeWidgetState {
  /// แถบบนแผงคำสั่ง: ได้คำสั่งสาขาไหน เพราะอะไร · เตือนเข้าเกณฑ์ Refer
  Widget _tplBranchCard() {
    final st = _SnakeState(_tplAns);
    final refer = st.referHint.difference(st.refer);
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 10.0),
      decoration: BoxDecoration(
        gradient: st.branch.isEmpty ? null : _glossGrad(_blue),
        color: st.branch.isEmpty ? _panelSoft : null,
        borderRadius: BorderRadius.circular(12.0),
        border: st.branch.isEmpty ? Border.all(color: _line) : null,
      ),
      foregroundDecoration:
          st.branch.isEmpty ? null : const _InnerGloss(12.0, dark: true),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.alt_route_rounded,
              size: 16.0, color: st.branch.isEmpty ? _ink3 : Colors.white),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
                st.branch.isEmpty
                    ? 'ยังไม่ได้เลือกสาขาคำสั่ง · ประเมินชนิดงูและเกณฑ์ antivenom ก่อน'
                    : st.branch,
                style: _t(12.0,
                    color: st.branch.isEmpty ? _ink3 : Colors.white,
                    weight: FontWeight.w700)),
          ),
        ]),
        if (st.reasons.isNotEmpty) ...[
          const SizedBox(height: 6.0),
          Wrap(spacing: 5.0, runSpacing: 5.0, children: [
            Text('เพราะ', style: _t(9.5, color: Colors.white)),
            for (final r in st.reasons)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(r,
                    style:
                        _t(9.5, color: Colors.white, weight: FontWeight.w600)),
              ),
          ]),
        ],
        if (refer.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          _Press(
            child: GestureDetector(
              onTap: () => setState(
                  () => _tplSec = _tplNote.indexWhere((s) => s.id == 'refer')),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(children: [
                  const Icon(Icons.local_shipping_rounded,
                      size: 14.0, color: _red),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text('เข้าเกณฑ์ Refer: ${refer.join(', ')}',
                        style: _t(10.5, color: _red, weight: FontWeight.w700)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16.0, color: _red),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  /// กฎความปลอดภัยใต้คำสั่ง antivenom (จากหมายเหตุของเอกสาร) + ปุ่ม anaphylaxis
  Widget _tplAvSafety() {
    final on = (_tplAns['anaphylaxis'] ?? const {}).isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(left: 25.0, top: 2.0, bottom: 4.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(9.0),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.shield_outlined, size: 14.0, color: _blue),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
                'ไม่ต้องทำ skin test ก่อนให้ · เฝ้าดู anaphylaxis อย่างน้อย 2 ชม. หลังให้',
                style: _t(10.5, color: _ink, weight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 7.0),
        _Press(
          child: GestureDetector(
            onTap: () => setState(() {
              HapticFeedback.mediumImpact();
              _tplAns['anaphylaxis'] = on ? <String>{} : {'1'};
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
              decoration: BoxDecoration(
                color: on ? _red : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: _red),
              ),
              child: Row(children: [
                Icon(on ? Icons.check_rounded : Icons.bolt_rounded,
                    size: 15.0, color: on ? Colors.white : _red),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                      on
                          ? 'สั่งแก้ anaphylaxis แล้ว · แตะเพื่อยกเลิก'
                          : 'เกิด anaphylaxis → หยุด AV + Adrenaline 0.5 ml IM + CPM 10 mg IV',
                      style: _t(10.5,
                          color: on ? Colors.white : _red,
                          weight: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  /// ผล lab เข้าเกณฑ์แต่ยังไม่ได้ติ๊ก: แนะนำ + ปุ่มติ๊กทั้งหมด
  List<Widget> _tplLabSuggest(List<_PnGroup> groups) {
    final set = _tplAns.putIfAbsent('antivenom', () => <String>{});
    final sug = [
      for (final g in groups)
        for (final o in g.opts)
          if ((_tplLabHint(o.label)?.$2 ?? false) && !set.contains(o.label))
            o.label
    ];
    if (sug.isEmpty) return const [];
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(children: [
          const Icon(Icons.science_rounded, size: 15.0, color: _blue),
          const SizedBox(width: 7.0),
          Expanded(
            child: Text('ผล lab เข้าเกณฑ์ ${sug.length} ข้อ: ${sug.join(', ')}',
                style: _t(10.5, color: _ink, weight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => setState(() => set.addAll(sug)),
            child: Text('ติ๊กตามผล lab',
                style: _t(10.5, color: _blue, weight: FontWeight.w700)),
          ),
        ]),
      ),
    ];
  }

  /// รอบประเมิน: รอบที่เท่าไร · เวลาประเมินซ้ำ (เลยกำหนด = แดง)
  Widget _tplRoundLine() {
    final due = _tplDue;
    final n = _tplRounds.length + 1;
    if (due == null) {
      return Text('รอบที่ 1 · ${_hhmm(DateTime.now())} น.',
          style: _t(10.0, color: _ink3, weight: FontWeight.w600));
    }
    final left = due.difference(DateTime.now());
    final late = left.isNegative;
    final h = left.inMinutes.abs() ~/ 60;
    final m = left.inMinutes.abs() % 60;
    return Text(
        'รอบที่ $n · ประเมินซ้ำ ${_hhmm(due)} น. '
        '(${late ? 'เลยมา' : 'อีก'} ${h > 0 ? '$h ชม. ' : ''}$m นาที)',
        style: _t(10.0, color: late ? _red : _blue, weight: FontWeight.w700));
  }

  /// สลับมุมมองหน้าสรุป: กระดาษ / รายการ
  Widget _tplViewToggle() => Row(mainAxisSize: MainAxisSize.min, children: [
        _chip('กระดาษ', _tplPaper, () => setState(() => _tplPaper = true)),
        const SizedBox(width: 4.0),
        _chip('รายการ', !_tplPaper, () => setState(() => _tplPaper = false)),
      ]);

  /// หน้าสรุปแบบเอกสารเดิม 3 คอลัมน์ ติ๊กตามที่ประเมิน/สั่ง · ใช้ตรวจทานก่อนบันทึก
  Widget _tplPaperView() {
    final blocks = _tplBlocks;
    final doctor = ErSession.instance.user?.name ?? 'แพทย์';
    Widget box(bool on) => Container(
          width: 11.0,
          height: 11.0,
          margin: const EdgeInsets.only(top: 2.0, right: 5.0),
          decoration: BoxDecoration(
            color: on ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(2.5),
            border: Border.all(color: on ? _blue : _g5, width: 1.2),
          ),
          child: on
              ? const Icon(Icons.check_rounded, size: 9.0, color: Colors.white)
              : null,
        );
    Widget row(bool on, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            box(on),
            Expanded(
              child: Text(text,
                  style: _t(9.5,
                      color: on ? _inkTitle : _ink3,
                      weight: on ? FontWeight.w600 : FontWeight.w500,
                      height: 1.3)),
            ),
          ]),
        );
    Widget title(String t) => Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 3.0),
          child: Text(t, style: _t(9.5, color: _ink2, weight: FontWeight.w700)),
        );
    Widget col(String h, List<Widget> kids) => Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Text(h,
                    textAlign: TextAlign.center,
                    style: _t(10.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              const Divider(height: 10.0, color: _line),
              ...kids,
            ]),
          ),
        );
    List<Widget> orders(Set<String> parts) {
      final out = <Widget>[];
      String? part;
      for (final b in blocks.where((b) => parts.contains(b.part))) {
        if (parts.length > 1 && b.part != part) {
          part = b.part;
          out.add(Padding(
            padding: EdgeInsets.only(top: out.isEmpty ? 0.0 : 8.0),
            child: Text(_tplParts[part]!,
                style: _t(9.5, color: _inkTitle, weight: FontWeight.w700)),
          ));
        }
        out.add(title(b.title));
        for (var i = 0; i < b.lines.length; i++) {
          final rate = _tplRate['${b.id}|$i']?.text ?? '';
          out.add(row(
              _tplLineOn(b, i),
              b.lines[i].rate
                  ? '${b.lines[i].text} ${rate.isEmpty ? '......' : rate} ml/hr'
                  : b.lines[i].text));
        }
      }
      return out;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _g5),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10.0, offset: Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
          child: Column(children: [
            Text('Standing order Snake bite รพ.ปากเกร็ด (ต.ค.65)',
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text(
                'Date ${_fmtDateTime(DateTime.now())} · รอบที่ ${_tplRounds.length + 1} · $doctor',
                style: _t(9.5, color: _ink2, weight: FontWeight.w600)),
          ]),
        ),
        const Divider(height: 1.0, color: _g5),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            col('PROGRESS NOTE', [
              for (final s in _tplNote) ...[
                title(s.title),
                for (final g in s.groups) ...[
                  if (g.title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text('• ${g.title}',
                          style:
                              _t(9.0, color: _ink3, weight: FontWeight.w600)),
                    ),
                  for (final o in g.opts)
                    row((_tplAns[s.id] ?? const {}).contains(o.label), o.label),
                ],
              ],
            ]),
            const VerticalDivider(width: 1.0, color: _g5),
            col('ORDER FOR ONE DAY', orders({'one'})),
            const VerticalDivider(width: 1.0, color: _g5),
            col('ORDER FOR CONTINUATION', orders({'cont', 'med', 'note'})),
          ]),
        ),
      ]),
    );
  }
}
