// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

extension _SidebarSidebarPart on _ErFlowHomeWidgetState {
  /// ชิปผู้ใช้ที่ login อยู่ มุมล่างซ้าย แตะเพื่อสลับบทบาท
  Widget _userChip() {
    final u = ErSession.instance.user;
    if (u == null) return const SizedBox.shrink();
    final nurse = u.role == ErRole.nurse;
    return _Press(
        child: Material(
      color: _panel,
      borderRadius: BorderRadius.circular(999.0),
      elevation: 3.0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
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
            Text(_clock('10:24'), style: _num(13.0, weight: FontWeight.w600)),
            const SizedBox(height: 10.0),
            Container(
              width: 34.0,
              height: 34.0,
              decoration:
                  const BoxDecoration(color: _panel, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 19.0, color: _ink2),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      );

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
