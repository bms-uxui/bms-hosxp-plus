// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ข้อความดิบของฟอร์มหนึ่ง (ยังไม่ตกแต่ง)
String _kbRaw(Map<String, dynamic> f, Map<String, String> got) {
  final b = StringBuffer();
  b.writeln('id: ${f['id']}');
  b.writeln('title: ${f['title']}');
  b.writeln('role: ${f['role']}');
  b.writeln('purpose: ${f['purpose']}');
  b.writeln('source: ${f['source']}');
  b.writeln();
  for (final s in (f['sections'] as List<dynamic>? ?? const [])) {
    b.writeln('== ${s['title']} ==');
    for (final fd in (s['fields'] as List<dynamic>? ?? const [])) {
      final label = fd['label'] as String;
      b.write('  • $label  <${fd['type']}>');
      if (fd['required'] == true) b.write(' *');
      final hint = fd['hint'];
      if (hint is String && hint.isNotEmpty) b.write('  hint: $hint');
      b.writeln();
      final opts = fd['options'];
      if (opts is List && opts.isNotEmpty) {
        b.writeln('      options: ${opts.join(' | ')}');
      }
      final v = got[label];
      if (v != null) b.writeln('      ค่าจากผู้ช่วยเสียง: $v');
    }
    b.writeln();
  }
  return b.toString();
}

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientFormKbTabState on State<ErFlowHomeWidget> {
  /// ฟอร์มที่กำลังดูใน tab ฟอร์ม HOSxP
  String _kbFormId = 'patient_screening';
}

extension _FeaturesPatientFormKbTabPart on _ErFlowHomeWidgetState {
  /// tab ฟอร์ม HOSxP: ข้อมูลดิบจาก er_form_kb.json ยังไม่ตกแต่ง
  /// ซ้าย = รายชื่อฟอร์ม ขวา = section/ช่อง/ตัวเลือก + ค่าที่ผู้ช่วยเสียงจับได้
  List<Widget> _kbOverlays() {
    final kb = ErFormKb.maybe;
    if (kb == null) {
      return [
        const Positioned(
            left: 0.0, top: 0.0, child: Text('กำลังโหลด er_form_kb.json…')),
      ];
    }
    // ค่าที่ AI จับได้จากทุกขั้น รวมเป็นแผนที่ชื่อช่อง → ค่า
    final got = <String, String>{};
    for (final m in _filled) {
      got.addAll(m);
    }
    final form = kb.form(_kbFormId) ?? kb.forms.first;
    return [
      Positioned(
        left: 0.0,
        top: 0.0,
        bottom: 0.0,
        width: 250.0,
        child: Container(
          color: _panel,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text('forms: ${kb.forms.length}', style: _t(10.0, color: _ink3)),
              for (final f in kb.forms)
                InkWell(
                  onTap: () => setState(() => _kbFormId = f['id'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                        '${f['id'] == _kbFormId ? '▶ ' : ''}${f['title']}  [${f['role']}]',
                        style: _t(11.0,
                            color: f['id'] == _kbFormId ? _blue : _ink,
                            weight: f['id'] == _kbFormId
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ),
                ),
            ],
          ),
        ),
      ),
      Positioned(
        left: 258.0,
        right: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: Container(
          color: _panel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: SelectableText(_kbRaw(form, got),
                style: _t(11.0, color: _ink, height: 1.5)),
          ),
        ),
      ),
    ];
  }

  /// แท็บฟอร์ม HOSxP ในการ์ดขวา: เลือกฟอร์ม · เนื้อหาฟอร์ม
  Widget _kbPanel() {
    final kb = ErFormKb.maybe;
    if (kb == null) return _clyEmpty('กำลังโหลดฟอร์ม…');
    final got = <String, String>{};
    for (final m in _filled) {
      got.addAll(m);
    }
    final form = kb.form(_kbFormId) ?? kb.forms.first;
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        Wrap(spacing: 6.0, runSpacing: 6.0, children: [
          for (final f in kb.forms)
            _chip('${f['title']}', f['id'] == form['id'],
                () => setState(() => _kbFormId = f['id'] as String)),
        ]),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12.0),
          child: SelectableText(_kbRaw(form, got),
              style: _t(11.0, color: _ink, height: 1.5)),
        ),
      ],
    );
  }
}
