// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

/// แผงซ้ายกาง/ยุบ
///
/// เนื้อหาทั้งสองแบบวางซ้อนกันด้วยความกว้างคงที่ แล้วให้กรอบนอกค่อย ๆ
/// แคบลงพร้อม ClipRect ตัดส่วนเกิน ข้อความจึงไม่ตัดบรรทัดใหม่ทุกเฟรม
/// (ของเดิมสลับลูกทันทีแล้วให้ความกว้างวิ่ง ทำให้กระตุกตอนเปลี่ยน)
/// เนื้อหาเฟดสลับกันสั้นกว่าจังหวะกว้าง ให้รู้สึกว่าแผง "เลื่อน" ไม่ใช่ "กระพริบ"
/// สวิตช์ปิดการ์ดสรุปที่ลอยอยู่ในฉากภาพรวมชั่วคราว
/// เปิดกลับเป็น true เมื่อจะใช้การ์ดกับการซูมอีกครั้ง
const bool _showSceneStats = true;

/// ความกว้างแผงตอนกางกับตอนหุบ
const double _panelW = 336.0;
const double _railW = 40.0;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsLeftPanelState on State<ErFlowHomeWidget> {
  /// แผงข้อมูลซ้ายกางอยู่หรือยุบแล้ว ยุบเพื่อคืนพื้นที่ให้ฉากสามมิติ
  bool _panelOpen = true;
}

extension _TabsLeftPanelPart on _ErFlowHomeWidgetState {
  Widget _leftPanel() {
    const dur = Duration(milliseconds: 320);
    const fade = Duration(milliseconds: 180);
    return AnimatedContainer(
      duration: dur,
      curve: Curves.easeInOutCubic,
      width: _panelOpen ? _panelW : _railW,
      decoration: const BoxDecoration(color: _pBg),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              width: _railW,
              child: IgnorePointer(
                ignoring: _panelOpen,
                child: AnimatedOpacity(
                  opacity: _panelOpen ? 0.0 : 1.0,
                  duration: fade,
                  curve: Curves.easeOut,
                  child: _collapsedPanel(),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              width: _panelW,
              child: IgnorePointer(
                ignoring: !_panelOpen,
                child: AnimatedOpacity(
                  opacity: _panelOpen ? 1.0 : 0.0,
                  duration: fade,
                  curve: Curves.easeOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    // ชิดบนเสมอ ค่าเริ่มต้นของ AnimatedSwitcher จัดกึ่งกลาง
                    // เนื้อหาที่สั้นกว่าจอจึงเคยลอยไปอยู่กลางแผง
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previous,
                        if (current != null) current,
                      ],
                    ),
                    child: _loading
                        ? _panelSkeleton(key: ValueKey('sk-$_open'))
                        : _open == null
                            ? _overviewPanel()
                            : _phasePanel(_open!, key: ValueKey(_open)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ปุ่มยุบแผง เป็นลิ้นชิดขอบขวาของแผงพอดี
  ///
  /// มุมซ้ายมนอย่างเดียว ฝั่งขวาตัดตรงให้ต่อเนื่องกับขอบแผง
  /// ดันออกนอกระยะขอบของเนื้อหา 16 พิกเซลด้วย Transform
  Widget _collapseButton() {
    const r = Radius.circular(10.0);
    // ไม่ใช้ Transform ดันออกนอกกรอบแล้ว ส่วนที่ล้นออกไปกดไม่ติด
    // แถวหัวแผงเว้นขอบขวาเป็น 0 ปุ่มจึงชิดขอบด้วยพื้นที่จริง
    return _Press(
        child: Material(
      color: _pSoft,
      borderRadius: const BorderRadius.only(topLeft: r, bottomLeft: r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _panelOpen = false),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(7.0, 8.0, 6.0, 8.0),
          child: Icon(Icons.keyboard_double_arrow_left_rounded,
              size: 16.0, color: _pInk2),
        ),
      ),
    ));
  }

  /// แผงตอนยุบ เหลือแค่ปุ่มกางกับชื่อหน้าตามแนวตั้ง
  Widget _collapsedPanel() => Column(
        children: [
          const SizedBox(height: 8.0),
          Material(
            color: _pSoft,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _panelOpen = true),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(Icons.keyboard_double_arrow_right_rounded,
                    size: 15.0, color: _pInk2),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(_open == null ? 'ภาพรวมห้องฉุกเฉิน' : _open!.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _pInk2, weight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      );
}
