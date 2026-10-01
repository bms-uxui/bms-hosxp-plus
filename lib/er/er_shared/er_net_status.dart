import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// toast กลางบนจอ บอกว่าเน็ตหลุด ค้างไว้จนกว่าจะต่อกลับ
/// ต่อกลับแล้วเปลี่ยนเป็น "เชื่อมต่อแล้ว" สีเขียว 2 วินาทีแล้วหายไป
/// ครอบทั้งแอปใน MaterialApp.builder จึงเห็นทุกหน้า
class ErNetStatus extends StatefulWidget {
  const ErNetStatus({super.key, required this.child});

  final Widget child;

  @override
  State<ErNetStatus> createState() => _ErNetStatusState();
}

enum _Net { online, offline, back }

class _ErNetStatusState extends State<ErNetStatus> {
  _Net _net = _Net.online;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    final c = Connectivity();
    c.checkConnectivity().then(_apply).catchError((_) {});
    _sub = c.onConnectivityChanged.listen(_apply, onError: (_) {});
  }

  void _apply(List<ConnectivityResult> r) {
    if (!mounted) return;
    final off = r.isEmpty || r.every((e) => e == ConnectivityResult.none);
    if (off) {
      _hide?.cancel();
      setState(() => _net = _Net.offline);
    } else if (_net == _Net.offline) {
      setState(() => _net = _Net.back);
      _hide?.cancel();
      _hide = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _net = _Net.online);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hide?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final show = _net != _Net.online;
    return Stack(children: [
      widget.child,
      Positioned(
        top: top + 12.0,
        left: 0.0,
        right: 0.0,
        child: IgnorePointer(
          ignoring: !show,
          child: Center(
            child: AnimatedSlide(
              offset: show ? Offset.zero : const Offset(0.0, -2.0),
              duration: const Duration(milliseconds: 380),
              curve: show ? Curves.easeOutBack : Curves.easeInCubic,
              child: AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 240),
                child: _pill(_net == _Net.back),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _pill(bool back) {
    const ink = Color(0xFF14181B);
    const green = Color(0xFF1E9E5A);
    const red = Color(0xFFE5484D);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 18.0, 8.0),
      decoration: BoxDecoration(
        color: back ? green : ink,
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'NotoSansThai',
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: back ? Colors.white.withValues(alpha: 0.22) : red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              back ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              size: 17.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10.0),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: back
                ? const Text('เชื่อมต่ออินเทอร์เน็ตแล้ว',
                    style:
                        TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ขาดการเชื่อมต่ออินเทอร์เน็ต',
                          style: TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.w600)),
                      Text('กำลังรอเชื่อมต่อใหม่',
                          style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
          ),
          if (!back) ...[
            const SizedBox(width: 14.0),
            SizedBox(
              width: 14.0,
              height: 14.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
