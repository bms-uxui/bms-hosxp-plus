// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

/// ขนาดตัวอักษรของทั้งโมดูล ER (ตั้งค่าได้ S / M / L / XL) คูณเข้าไปใน _t และ _num
const List<(String, double)> _txtSizes = [
  ('S', 0.9),
  ('M', 1.0),
  ('L', 1.12),
  ('XL', 1.25),
];
double _txtScale = 1.0;
const String _txtKey = 'er_text_size';

/// แสดงการ์ด AI Overview บนภาพรวมผู้ป่วย (ปิดได้ในตั้งค่า) จำในเครื่อง
bool _aovOn = true;
const String _aovPrefKey = 'er_ai_overview';

extension _SidebarSidebarPart on _ErFlowHomeWidgetState {
  /// ชิปผู้ใช้ที่ login อยู่ มุมล่างซ้าย แตะเพื่อสลับบทบาท
  Widget _userChip() {
    final u = ErSession.instance.user;
    if (u == null) return const SizedBox.shrink();
    final nurse = u.role == ErRole.nurse;
    return _Press(
        child: Material(
      color: _panel,
      // flat: ขอบบางแทนเงา
      shape: const StadiumBorder(side: BorderSide(color: _line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ErSession.instance.signOut();
          context.goNamed(ErLoginWidget.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 14.0, backgroundImage: AssetImage(u.face)),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(u.name,
                      style:
                          _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
                  Text('${u.roleLabel} · ${u.shift}',
                      style: _t(8.5, color: nurse ? _blue : _blue)),
                ],
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.swap_horiz_rounded, size: 14.0, color: _ink3),
            ],
          ),
        ),
      ),
    ));
  }

  // ---------------------------------------------------------------- sidebar

  /// แถบซ้ายสุด เป็นรางไอคอนล้วน
  ///
  /// แท็บที่เลือกใช้สีเดียวกับแผงและไม่มีมุมโค้งด้านขวา
  /// จึงดูเชื่อมเป็นชิ้นเดียวกับแผงที่อยู่ติดกัน เหมือนแท็บที่ยื่นออกมา
  /// พื้นรางเป็นสีพื้นหน้า ไม่ใช่สีแผง ความต่างตรงนี้คือสิ่งที่ทำให้อ่านออก
  Widget _sideBar() => Container(
        width: 72.0,
        color: _bg,
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Image.asset('assets/images/app_launcher_icon.png',
                width: 30.0,
                height: 30.0,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.local_hospital, size: 26.0, color: _blue)),
            const SizedBox(height: 14.0),
            _sideTab(Icons.dashboard_rounded, 'ภาพรวม', null),
            for (final ph in _Phase.values)
              _sideTab(_phaseIcon(ph), ph.label, ph),
            const SizedBox(height: 14.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final p
                        in _patients.where((e) => _pinned.contains(e.hn)))
                      _pinPatient(p),
                    _pinAdd(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Tooltip(
              message: 'ตั้งค่า',
              child: _Press(
                child: Material(
                  color: _panel,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openSettings,
                    child: const SizedBox(
                      width: 34.0,
                      height: 34.0,
                      child: Icon(Icons.settings_rounded,
                          size: 19.0, color: _ink2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(_clock('10:24'), style: _num(13.0, weight: FontWeight.w600)),
            // เว้นที่ให้ชิปผู้ใช้ที่ลอยทับมุมล่างซ้าย
            const SizedBox(height: 54.0),
          ],
        ),
      );

  /// อ่านขนาดตัวอักษรที่ตั้งไว้ (เรียกตอนเปิดหน้า พร้อมโหลดหมุด)
  void _loadTextSize(SharedPreferences p) {
    final v = p.getDouble(_txtKey);
    if (v != null && v != _txtScale && mounted) setState(() => _txtScale = v);
    final a = p.getBool(_aovPrefKey);
    if (a != null && a != _aovOn && mounted) setState(() => _aovOn = a);
  }

  void _setAov(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _aovOn = v);
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_aovPrefKey, v))
        .catchError((_) => true);
  }

  void _setTextSize(double v) {
    HapticFeedback.selectionClick();
    setState(() => _txtScale = v);
    SharedPreferences.getInstance()
        .then((p) => p.setDouble(_txtKey, v))
        .catchError((_) => true);
  }

  /// หน้าตั้งค่าแบบเต็มหน้า: เมนูซ้าย (การแสดงผล · Standing order) เนื้อหาขวา
  void _openSettings() {
    var tab = 0;
    var cur = _soDocs.containsKey(_template) ? _template : _soDocs.keys.first;
    final changed = <String>{};
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, a, _, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.0, 0.03), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx, set) {
          Widget menu(int i, IconData icon, String t, String sub) {
            final on = tab == i;
            return GestureDetector(
              onTap: () => set(() => tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                decoration: BoxDecoration(
                  color: on ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(children: [
                  Icon(icon, size: 18.0, color: on ? Colors.white : _ink2),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t,
                            style: _t(13.0,
                                color: on ? Colors.white : _inkTitle,
                                weight: FontWeight.w600)),
                        Text(sub,
                            style: _t(10.5,
                                color: on ? const Color(0xCCFFFFFF) : _ink3,
                                weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          }

          final ai = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 460.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ผู้ช่วย AI',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 4.0),
                  Text('AI ช่วยสรุปและแนะนำ ผู้ใช้ตรวจทานและยืนยันเสมอ',
                      style: _t(12.0, color: _ink3)),
                  const SizedBox(height: 16.0),
                  // เปิด/ปิด AI Overview บนหน้าภาพรวมผู้ป่วย
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 10.0),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 20.0, color: _blue),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Overview',
                                  style: _t(14.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              Text('สรุปเคสด้วย AI บนหน้าภาพรวมผู้ป่วย',
                                  style: _t(12.0, color: _ink3)),
                            ]),
                      ),
                      Switch(
                        value: _aovOn,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _blue,
                        onChanged: (v) => set(() => _setAov(v)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );

          final display = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 460.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('การแสดงผล',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 16.0),
                  Text('ขนาดตัวอักษร',
                      style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(children: [
                      for (final (label, v) in _txtSizes) ...[
                        if (label != _txtSizes.first.$1)
                          const SizedBox(width: 8.0),
                        Expanded(
                          child: _Press(
                            child: GestureDetector(
                              onTap: () => set(() => _setTextSize(v)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 64.0,
                                decoration: BoxDecoration(
                                  gradient: _txtScale == v
                                      ? _glossGrad(_blue)
                                      : _glossWhite,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                      color: _txtScale == v ? _blue : _line),
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // ตัวอย่างขนาดจริง ไม่คูณ scale ปัจจุบัน
                                      Text('ก',
                                          style: TextStyle(
                                              fontFamily: 'GoogleSans',
                                              fontFamilyFallback: const [
                                                'NotoSansThai'
                                              ],
                                              fontSize: 16.0 * v,
                                              height: 1.1,
                                              fontWeight: FontWeight.w600,
                                              color: _txtScale == v
                                                  ? Colors.white
                                                  : _inkTitle)),
                                      Text(label,
                                          style: TextStyle(
                                              fontFamily: 'GoogleSans',
                                              fontFamilyFallback: const [
                                                'NotoSansThai'
                                              ],
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w600,
                                              color: _txtScale == v
                                                  ? Colors.white
                                                  : _ink3)),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12.0),
                  Text('ตัวอย่าง: ผู้ป่วยแน่นหน้าอก 2 ชั่วโมงก่อนมา รพ.',
                      style: _t(12.0, color: _inkTitle)),
                ],
              ),
            ),
          );
          return Material(
            color: _panelSoft,
            child: SafeArea(
              child: Column(children: [
                // แถบบน: ปิด + ชื่อหน้า
                Container(
                  height: 56.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: const BoxDecoration(
                    color: _panel,
                    border: Border(bottom: BorderSide(color: _line)),
                  ),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'ปิด',
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 22.0, color: _inkTitle),
                    ),
                    const SizedBox(width: 4.0),
                    Text('ตั้งค่า',
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ]),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 250.0,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          color: _panel,
                          border: Border(right: BorderSide(color: _line)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // หมวดหมู่ตั้งค่า: ทั่วไป · AI · ทางคลินิก
                              for (final (h, items) in [
                                (
                                  'ทั่วไป',
                                  [
                                    (
                                      0,
                                      Icons.text_fields_rounded,
                                      'การแสดงผล',
                                      'ขนาดตัวอักษร'
                                    ),
                                  ]
                                ),
                                (
                                  'AI',
                                  [
                                    (
                                      2,
                                      Icons.auto_awesome_rounded,
                                      'ผู้ช่วย AI',
                                      'AI Overview'
                                    ),
                                  ]
                                ),
                                (
                                  'ทางคลินิก',
                                  [
                                    (
                                      1,
                                      Icons.account_tree_outlined,
                                      'Standing order',
                                      'จำแนกหมวดแต่ละบรรทัดในใบ'
                                    ),
                                  ]
                                ),
                              ]) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 14.0, 10.0, 6.0),
                                  child: Text(h,
                                      style: _t(11.0,
                                          color: _ink3,
                                          weight: FontWeight.w700)),
                                ),
                                for (final (i, ic, t, sub) in items)
                                  menu(i, ic, t, sub),
                              ],
                            ]),
                      ),
                      Expanded(
                        child: switch (tab) {
                          0 =>
                            Align(alignment: Alignment.topLeft, child: display),
                          2 => Align(alignment: Alignment.topLeft, child: ai),
                          _ => _soStructView(cur, (k) => cur = k, changed, set),
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  /// ไอคอนประจำช่วงงาน
  IconData _phaseIcon(_Phase phase) {
    switch (phase) {
      case _Phase.triage:
        return Icons.fact_check_rounded;
      case _Phase.treatment:
        return Icons.medical_services_rounded;
      case _Phase.after:
        return Icons.logout_rounded;
      case _Phase.observe:
        return Icons.visibility_rounded;
    }
  }

  /// ปุ่มหนึ่งใบในรางไอคอน
  ///
  /// ใบที่เลือกกินเต็มความกว้างราง โค้งเฉพาะด้านซ้าย ขอบขวาชนแผงพอดี
  /// ใบที่ไม่ได้เลือกเป็นสี่เหลี่ยมมุมมนลอยอยู่กลางราง
  Widget _sideTab(IconData icon, String label, _Phase? phase) {
    final active = _open == phase;
    return _Press(
        child: Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: Padding(
        padding: EdgeInsets.fromLTRB(active ? 10.0 : 14.0, 0.0, 0.0, 8.0),
        child: Material(
          color: active ? _pBg : _panel,
          borderRadius: BorderRadius.horizontal(
            left: const Radius.circular(14.0),
            right: Radius.circular(active ? 0.0 : 14.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (_open == phase) return;
              setState(() {
                _open = phase;
                _detail = false;
                _zoom = null;
              });
              _simulateLoad(const Duration(milliseconds: 500));
            },
            child: SizedBox(
              width: active ? 62.0 : 44.0,
              height: 44.0,
              // ใบที่เลือกพื้นเป็นสีหลัก ไอคอนจึงเป็นขาว
              // ใบที่ไม่ได้เลือกพื้นขาว ไอคอนเป็นสีหลัก
              child:
                  Icon(icon, size: 21.0, color: active ? Colors.white : _blue),
            ),
          ),
        ),
      ),
    ));
  }
}
