// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowWorkflowBlocksState on State<ErFlowHomeWidget> {
  /// รายการในชุดคำสั่งแนะนำที่แพทย์ติ๊กไว้ ('ช่อง|รายการ')
  final Set<String> _orderPick = {};

  /// รายการใน checklist ของผู้ช่วยที่ติ๊กแล้ว
  final Set<String> _uiTicks = {};
}

extension _FeaturesWorkflowWorkflowBlocksPart on _ErFlowHomeWidgetState {
  Widget _uiBlock(ErUiBlock b) {
    final c = _case;
    switch (b.type) {
      case ErUiType.brief when b.data['intro'] == true:
        return _stepIntro();
      case ErUiType.brief when b.data['order_pick'] == true:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _orderLeftItems(),
        );
      case ErUiType.brief when b.data['pe_pick'] == true:
        return _pePickCard();
      case ErUiType.brief when b.data['hpi_pick'] == true:
        return _hpiPickCard();
      case ErUiType.brief when b.data['esi_ai'] == true:
        return _esiAiCard();
      case ErUiType.brief:
        return _uiCard(b,
            icon: Icons.person_search_rounded,
            title: b.str('title', 'สรุปเคส'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final pt in b.strs('points'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5.0,
                          height: 5.0,
                          margin: const EdgeInsets.only(top: 5.0, right: 7.0),
                          decoration: const BoxDecoration(
                              color: _blue, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(pt,
                              style: _t(10.5, color: _ink, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ));
      case ErUiType.vitals:
        final all = {for (final v in _caseVitals()) v.label: v};
        const names = {
          'hr': 'HR',
          'bp': 'BP',
          'spo2': 'SpO₂',
          'rr': 'RR',
          'bt': 'BT',
        };
        final keys = b.strs('keys').isEmpty
            ? const ['hr', 'bp', 'spo2', 'rr']
            : b.strs('keys');
        final tiles = <Widget>[
          for (final k in keys)
            if (names[k] != null && all[names[k]] != null)
              _uiMetric(
                  all[names[k]]!.label,
                  _vsValue(all[names[k]]!, all[names[k]]!.series.length - 1),
                  all[names[k]]!.unit,
                  all[names[k]]!.color != _ink && all[names[k]]!.color != _ink2
                      ? all[names[k]]!.color
                      : _inkTitle,
                  all[names[k]]!.series)
            else if (k == 'gcs' && c.gcs != null)
              _uiMetric(
                  'GCS',
                  c.gcsScore,
                  '/15',
                  (int.tryParse(c.gcsScore) ?? 15) < 15 ? _red : _inkTitle,
                  const []),
        ];
        return _uiCard(b,
            icon: Icons.monitor_heart_rounded,
            title: b.str('title',
                'สัญญาณชีพล่าสุด · ${c.times.isEmpty ? '' : '${c.times.last} น.'}'),
            accent: _red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                  childAspectRatio: 2.3,
                  children: tiles,
                ),
                if (b.str('note').isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(b.str('note'), style: _t(10.0, color: _ink2)),
                ],
              ],
            ));
      case ErUiType.labs:
        final want = b.strs('names').map((e) => e.toLowerCase()).toList();
        final labs = [
          for (final l in c.labs)
            if (want.isEmpty ||
                want.any((w) =>
                    l.name.toLowerCase().contains(w) ||
                    w.contains(l.name.toLowerCase())))
              l
        ];
        return _uiCard(b,
            icon: Icons.science_rounded,
            title: b.str('title', 'ผลแล็บที่ต้องดู'),
            accent: _blue,
            child: labs.isEmpty
                ? Text('ยังไม่มีผลแล็บ', style: _t(10.0, color: _ink3))
                : Column(children: [
                    for (final l in labs)
                      if (l.isNumeric) _labRow(_labTuple(l)),
                    if (b.str('note').isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text(b.str('note'), style: _t(10.0, color: _ink2)),
                      ),
                  ]));
      case ErUiType.imaging:
        final want = b.strs('names').map((e) => e.toLowerCase()).toList();
        final imgs = [
          for (final i in c.imaging)
            if (want.isEmpty ||
                want.any((w) =>
                    i.name.toLowerCase().contains(w) ||
                    w.contains(i.name.toLowerCase())))
              i
        ];
        return _uiCard(b,
            icon: Icons.image_search_rounded,
            title: b.str('title', 'ภาพถ่ายทางรังสี'),
            accent: _blue,
            child: imgs.isEmpty
                ? Text('ยังไม่มีภาพ', style: _t(10.0, color: _ink3))
                : Row(children: [
                    for (final i in imgs.take(3))
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(i.asset,
                                    height: 64.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, e, s) => Container(
                                        height: 64.0, color: _panelSoft)),
                              ),
                              const SizedBox(height: 3.0),
                              Text(i.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.5, weight: FontWeight.w700)),
                              Text(i.result,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.0, color: _ink3)),
                            ],
                          ),
                        ),
                      ),
                  ]));
      case ErUiType.alert:
        final lv = b.str('level', 'warn');
        final col = lv == 'critical' ? _red : (lv == 'info' ? _blue : _blue);
        return Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
          decoration: BoxDecoration(
            color: Color.alphaBlend(col.withValues(alpha: 0.07), _panel),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: col.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    lv == 'info'
                        ? Icons.info_rounded
                        : Icons.warning_amber_rounded,
                    size: 22.0,
                    color: col),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.str('title', 'แจ้งเตือน'),
                        style: _t(14.5, color: col, weight: FontWeight.w700)),
                    if (b.str('text').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(b.str('text'),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.5, color: _ink, height: 1.4)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case ErUiType.form:
        final items = {for (final (l, h) in _forms[_speechStep]) l: h};
        final fields = _formFields(b);
        if (fields.isEmpty) return const SizedBox.shrink();
        if (_formAllAtOnce) return _formAll(fields, items);
        return _formFlip(b, fields, items);
      case ErUiType.orderSet:
        final groups = b.maps('groups');
        return _uiCard(b,
            icon: Icons.playlist_add_check_rounded,
            title: b.str('title', 'ชุดคำสั่งแนะนำ'),
            accent: _blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final g in groups) ...[
                  Text('${g['field'] ?? ''}',
                      style: _t(9.5, color: _ink3, weight: FontWeight.w700)),
                  const SizedBox(height: 3.0),
                  Wrap(spacing: 5.0, runSpacing: 5.0, children: [
                    for (final it in (g['items'] as List? ?? const []))
                      if (it is String) _uiOrderChip('${g['field']}', it),
                  ]),
                  const SizedBox(height: 7.0),
                ],
                Row(children: [
                  Text('${_orderPick.length} รายการที่เลือก',
                      style: _t(9.5, color: _ink3)),
                  const Spacer(),
                  _uiButton(
                      _orderPick.isEmpty ? 'เลือกทั้งหมด' : 'ยืนยันคำสั่ง',
                      _orderPick.isEmpty
                          ? Icons.done_all_rounded
                          : Icons.check_rounded, () {
                    if (_orderPick.isEmpty) {
                      setState(() {
                        for (final g in groups) {
                          for (final it in (g['items'] as List? ?? const [])) {
                            if (it is String)
                              _orderPick.add('${g['field']}|$it');
                          }
                        }
                      });
                    } else {
                      _commitOrders();
                    }
                  }, primary: _orderPick.isNotEmpty),
                ]),
              ],
            ));
      case ErUiType.checklist:
        return _uiCard(b,
            icon: Icons.fact_check_rounded,
            title: b.str('title', 'ขั้นตอนมาตรฐาน'),
            accent: _blue,
            child: Column(children: [
              for (final it in b.strs('items'))
                InkWell(
                  onTap: () => setState(() => _uiTicks.contains(it)
                      ? _uiTicks.remove(it)
                      : _uiTicks.add(it)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(children: [
                      Icon(
                          _uiTicks.contains(it)
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 16.0,
                          color: _uiTicks.contains(it) ? _blue : _g5),
                      const SizedBox(width: 7.0),
                      Expanded(
                        child: Text(it,
                            style: _t(10.5,
                                color: _uiTicks.contains(it) ? _ink3 : _ink)),
                      ),
                    ]),
                  ),
                ),
            ]));
      case ErUiType.timer:
        final since = b.str('since', c.times.isEmpty ? _simNow : c.times.first);
        final target = (b.data['target_min'] as num?)?.toInt() ?? 60;
        final used = RegExp(r'^\d{1,2}:\d{2}$').hasMatch(since)
            ? _minutesSince(since)
            : 0;
        final left = target - used;
        final frac = (used / target).clamp(0.0, 1.0);
        final col = left <= 0 ? _red : (frac > 0.66 ? _blue : _blue);
        return _uiCard(b,
            icon: Icons.timer_rounded,
            title: b.str('label', 'เวลาเป้าหมาย'),
            accent: col,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(left <= 0 ? 'เกิน ${-left}' : '$left',
                        style: _num(22.0, color: col, weight: FontWeight.w700)),
                    const SizedBox(width: 4.0),
                    Text('นาที ${left <= 0 ? 'จากเป้า' : 'ที่เหลือ'}',
                        style: _t(10.0, color: _ink3)),
                    const Spacer(),
                    Text('เริ่ม $since น. · เป้า $target น.',
                        style: _t(9.0, color: _ink3)),
                  ],
                ),
                const SizedBox(height: 6.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6.0,
                    backgroundColor: _panelSoft,
                    valueColor: AlwaysStoppedAnimation(col),
                  ),
                ),
              ],
            ));
      case ErUiType.nextStep:
        if (b.data['review'] == true) return _reviewCard(b);
        final action = b.str('action', 'confirm_step');
        return Center(
          heightFactor: 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check_rounded, size: 22.0, color: _blue),
              ),
              const SizedBox(height: 10.0),
              Text(b.str('title', 'ไปขั้นต่อไป'),
                  textAlign: TextAlign.center,
                  style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              if (b.str('detail').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(b.str('detail'),
                      textAlign: TextAlign.center,
                      style: _t(12.0, color: _ink3)),
                ),
              const SizedBox(height: 14.0),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(100.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (action == 'summary') {
                      _closeSpeech();
                      _openSummary();
                    } else {
                      _confirmStep();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22.0, vertical: 10.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(action == 'summary' ? 'สร้างสรุปเคส' : 'ไปขั้นต่อไป',
                          style: _t(13.0,
                              color: Colors.white, weight: FontWeight.w700)),
                      const SizedBox(width: 6.0),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 18.0, color: Colors.white),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _uiMetric(String label, String value, String unit, Color color,
          List<double> series) =>
      Container(
        padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 4.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _t(8.5, color: _ink3, weight: FontWeight.w600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _num(15.0, color: color, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 2.0),
                Text(unit, style: _t(8.0, color: _ink3)),
              ],
            ),
            if (series.length > 1)
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _Spark(series, color),
                ),
              ),
          ],
        ),
      );

  Widget _uiOrderChip(String field, String item) {
    final key = '$field|$item';
    final on = _orderPick.contains(key);
    final conflict = _allergyHit(item);
    return _Press(
        child: InkWell(
      onTap: () =>
          setState(() => on ? _orderPick.remove(key) : _orderPick.add(key)),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: on ? _blue.withValues(alpha: 0.10) : _panel,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: conflict ? _red : (on ? _blue : _line)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              on
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 13.0,
              color: on ? _blue : _g5),
          const SizedBox(width: 4.0),
          Text(item,
              style: _t(9.5,
                  color: conflict ? _red : _ink,
                  weight: on ? FontWeight.w700 : FontWeight.w500)),
          if (conflict) ...[
            const SizedBox(width: 3.0),
            const Icon(Icons.warning_amber_rounded, size: 12.0, color: _red),
          ],
        ]),
      ),
    ));
  }

  /// รายการคำสั่งนี้ชนกับประวัติแพ้ของผู้ป่วยไหม (ใช้กติกาเดียวกับ _allergyConflict)
  bool _allergyHit(String item) {
    final s = item.toLowerCase();
    for (final a in _case.allergies) {
      final k = a.toLowerCase();
      if (s.contains(k)) return true;
      if (k.contains('penicillin') &&
          ['amoxicillin', 'ampicillin', 'piperacillin', 'augmentin']
              .any(s.contains)) {
        return true;
      }
      if (k.contains('sulfa') && s.contains('co-trimoxazole')) return true;
      if (k.contains('nsaid') &&
          ['ibuprofen', 'ketorolac', 'diclofenac'].any(s.contains)) {
        return true;
      }
    }
    return false;
  }

  /// ลงคำสั่งที่ติ๊กเข้าช่องของขั้นนี้ แล้วให้ผู้ช่วยรับทราบต่อ
  void _commitOrders() {
    final byField = <String, List<String>>{};
    for (final k in _orderPick) {
      final i = k.indexOf('|');
      byField.putIfAbsent(k.substring(0, i), () => []).add(k.substring(i + 1));
    }
    final labels = {for (final (l, _) in _forms[_speechStep]) l};
    final changed = <(int, String, String?)>[];
    setState(() {
      for (final e in byField.entries) {
        if (!labels.contains(e.key)) continue;
        changed.add((_speechStep, e.key, _filled[_speechStep][e.key]));
        _filled[_speechStep][e.key] = e.value.join(', ');
      }
      if (changed.isNotEmpty) _lastFilled = changed;
      _allergyWarn = _allergyConflict();
      _orderPick.clear();
      _uiIdx += 1; // สั่งแล้วเลื่อนไปการ์ดถัดไปของลำดับ
    });
    final gen = ++_agentGen;
    _agentTurn(
        '(ยืนยันชุดคำสั่ง) ${byField.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join(' · ')}',
        gen);
  }

  Widget _uiButton(String label, IconData icon, VoidCallback onTap,
          {bool primary = true}) =>
      _Press(
          child: Material(
        color: primary ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13.0, color: primary ? Colors.white : _blue),
              const SizedBox(width: 4.0),
              Text(label,
                  style: _t(10.0,
                      color: primary ? Colors.white : _blueHue,
                      weight: FontWeight.w700)),
            ]),
          ),
        ),
      ));

  /// ทุกช่องของฟอร์มในหน้าเดียว (เลื่อนดูได้) · ชื่อช่อง + ช่องกรอกแบบเดียวกับหน้าละช่อง
  Widget _formAll(List<String> fields, Map<String, String> items) {
    final known = _filled[_speechStep];
    return SizedBox(
      height: _flipFill ?? 420.0,
      child: ListView.separated(
        key: PageStorageKey('form-all-$_speechStep'),
        padding: const EdgeInsets.only(bottom: 12.0),
        itemCount: fields.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14.0),
        itemBuilder: (_, i) {
          final f = fields[i];
          final done = _fieldDone(_speechStep, f);
          return Container(
            padding: const EdgeInsets.all(4.0),
            color: _glow.contains(f) ? _blue.withValues(alpha: 0.06) : null,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Text('${i + 1}. $f',
                        style: _t(12.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const Spacer(),
                    if (done)
                      const Icon(Icons.check_circle_rounded,
                          size: 15.0, color: _green),
                  ]),
                  const SizedBox(height: 6.0),
                  _fieldWithExtras(
                      f,
                      _guideFieldCard(f, items[f] ?? '', known[f], true,
                          big: true)),
                ]),
          );
        },
      ),
    );
  }
}
