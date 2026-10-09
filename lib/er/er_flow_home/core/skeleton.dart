// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

// ------------------------------------------------- skeleton
/// กล่องเทาแทนที่เนื้อหาระหว่างโหลด ใช้คู่กับ _Shimmer
const Color _boneColor = Color(0xFFE4E7EB);

Widget _bone(double w, double h, {double radius = 8.0}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: _boneColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

Widget _gap(double h) => SizedBox(height: h);

/// กระดูกบนพื้นกรมท่า (แผงซ้าย): ขาวโปร่ง
const Color _boneDark = Color(0x24FFFFFF);

Widget _boneD(double w, double h, {double radius = 8.0}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: _boneDark,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

/// shimmer บนพื้นเข้ม: แสงขาวจางวิ่งผ่านกระดูกขาวโปร่ง (_Shimmer เดิมเป็นเทาสำหรับพื้นขาว)
class _ShimmerDark extends StatefulWidget {
  const _ShimmerDark({required this.child});

  final Widget child;

  @override
  State<_ShimmerDark> createState() => _ShimmerDarkState();
}

class _ShimmerDarkState extends State<_ShimmerDark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(-2.6 + 4.0 * t, -0.3),
              end: Alignment(-0.6 + 4.0 * t, 0.3),
              colors: const [
                Color(0x24FFFFFF),
                Color(0x47FFFFFF),
                Color(0x24FFFFFF),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect),
            child: child,
          );
        },
        child: widget.child,
      );
}

extension _CoreSkeletonPart on _ErFlowHomeWidgetState {
  /// แผงซ้าย (พื้นกรมท่า): โครงตามแผงที่กำลังจะเปิด
  /// ภาพรวม = หัวข้อ ปุ่ม 2 อัน ตัวเลข 2×2 กราฟ การ์ดผู้ป่วยล่าสุด
  /// ช่วงงาน = หัวข้อ ตัวเลขใหญ่ ชิปตัวกรอง แถวรายชื่อคั่นเส้น
  Widget _panelSkeleton({Key? key}) => SingleChildScrollView(
        key: key,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18.0, 8.0, 16.0, 16.0),
        child: _ShimmerDark(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _boneD(_open == null ? 200.0 : 120.0, 22.0),
              _gap(6.0),
              _boneD(150.0, 11.0),
              _gap(14.0),
              if (_open == null || _open == _Phase.triage) ...[
                Row(children: [
                  Expanded(
                      flex: 3,
                      child: _boneD(double.infinity, 40.0, radius: 100.0)),
                  const SizedBox(width: 8.0),
                  Expanded(
                      flex: 2,
                      child: _boneD(double.infinity, 40.0, radius: 100.0)),
                ]),
                _gap(14.0),
              ],
              if (_open == null) ...[
                for (var r = 0; r < 2; r++) ...[
                  Row(children: [
                    for (var c = 0; c < 2; c++) ...[
                      if (c == 1) const SizedBox(width: 10.0),
                      Expanded(
                          child: _boneD(double.infinity, 82.0, radius: 14.0)),
                    ],
                  ]),
                  _gap(10.0),
                ],
                _boneD(double.infinity, 150.0, radius: 14.0),
                _gap(20.0),
                _boneD(130.0, 13.0),
                _gap(12.0),
                for (var i = 0; i < 2; i++) ...[
                  _boneD(double.infinity, 120.0, radius: 16.0),
                  _gap(10.0),
                ],
              ] else ...[
                Row(children: [
                  _boneD(46.0, 36.0),
                  const SizedBox(width: 8.0),
                  _boneD(80.0, 13.0),
                ]),
                _gap(14.0),
                // ชิปกว้างตามสัดส่วน ไม่ล้นแผงแคบ
                Row(children: [
                  for (final (k, f) in const [3, 3, 4].indexed) ...[
                    if (k > 0) const SizedBox(width: 8.0),
                    Expanded(flex: f, child: _boneD(double.infinity, 32.0)),
                  ],
                ]),
                _gap(12.0),
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) Container(height: 1.0, color: _boneDark),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 14.0, 10.0, 14.0),
                    child: Row(children: [
                      _boneD(38.0, 38.0, radius: 19.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _boneD(140.0, 13.0),
                            _gap(7.0),
                            _boneD(100.0, 10.0),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _boneD(44.0, 10.0),
                          _gap(6.0),
                          _boneD(64.0, 13.0),
                        ],
                      ),
                    ]),
                  ),
                ],
              ],
            ],
          ),
        ),
      );

  /// การ์ดสรุปช่วงงานบนฉากภาพรวม: ชื่อขั้น + จำนวน แล้วแถบสัดส่วน ESI
  Widget _statCardSkeleton() => _Shimmer(
        child: Container(
          width: 186.0,
          padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _bone(64.0, 12.0),
                const Spacer(),
                _bone(36.0, 22.0),
              ]),
              _gap(12.0),
              _bone(double.infinity, 18.0, radius: 4.0),
            ],
          ),
        ),
      );

  /// การ์ดผู้ป่วยบนฉากเตียง: แถบหัวกรมท่า (หัวข้อ stepper สถานะ) + ตัวการ์ดขาว
  /// (ป้าย ESI/แพ้ยา ชื่อ HN อาการสำคัญ ปุ่ม และกรอบคำสั่งแพทย์ด้านขวา)
  Widget _patientCardSkeleton() => Stack(children: [
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          height: 96.0,
          child: Container(
            decoration: const BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 0.0),
            alignment: Alignment.topLeft,
            child: _ShimmerDark(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _boneD(140.0, 13.0),
                  _gap(6.0),
                  _boneD(170.0, 10.0),
                ]),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i > 0) _boneD(52.0, 2.5, radius: 2.0),
                        _boneD(34.0, 34.0, radius: 17.0),
                      ],
                    ],
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _boneD(70.0, 10.0),
                  _gap(6.0),
                  _boneD(80.0, 13.0),
                ]),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 62.0),
          child: Container(
            height: 270.0,
            padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: _Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _bone(116.0, 24.0, radius: 4.0),
                    const SizedBox(width: 6.0),
                    _bone(86.0, 24.0),
                    const SizedBox(width: 6.0),
                    _bone(150.0, 24.0),
                  ]),
                  _gap(14.0),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                _bone(44.0, 44.0, radius: 22.0),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _bone(170.0, 16.0),
                                    _gap(6.0),
                                    _bone(100.0, 11.0),
                                  ],
                                ),
                              ]),
                              _gap(14.0),
                              _bone(70.0, 10.0),
                              _gap(8.0),
                              _bone(double.infinity, 13.0),
                              _gap(6.0),
                              _bone(double.infinity, 13.0),
                              _gap(6.0),
                              _bone(220.0, 13.0),
                              const Spacer(),
                              Row(children: [
                                _bone(96.0, 40.0, radius: 100.0),
                                const SizedBox(width: 8.0),
                                _bone(116.0, 40.0, radius: 100.0),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: _line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _bone(90.0, 14.0),
                                _gap(6.0),
                                _bone(150.0, 10.0),
                                _gap(10.0),
                                // 2 แถว: กรอบสูงจำกัด (3 แถวล้นล่าง)
                                for (var i = 0; i < 2; i++) ...[
                                  _bone(double.infinity, 44.0, radius: 12.0),
                                  _gap(6.0),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);

  Widget _detailChartsSkeleton() => SizedBox(
        width: 250.0,
        child: _Shimmer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
            children: [
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _bone(double.infinity, 118.0, radius: 14.0),
                ),
            ],
          ),
        ),
      );

  Widget _detailFieldsSkeleton() => Container(
        width: 272.0,
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
        child: _Shimmer(
          child: Column(
            children: [
              Expanded(
                  child: _bone(double.infinity, double.infinity, radius: 16.0)),
              _gap(10.0),
              _bone(double.infinity, 150.0, radius: 16.0),
              _gap(10.0),
              _bone(double.infinity, 64.0, radius: 14.0),
            ],
          ),
        ),
      );

  Widget _detailTimelineSkeleton() => Container(
        width: 210.0,
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
        child: _Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(70.0, 14.0),
              _gap(12.0),
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(30.0, 30.0, radius: 15.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bone(56.0, 10.0),
                            _gap(6.0),
                            _bone(double.infinity, 12.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  /// หน้ารายละเอียดผู้ป่วย แผงเนื้อหา: แถบ AI ภาพรวม · หัวข้อสัญญาณชีพ · การ์ด V/S
  /// (ใหญ่ 1 + เล็ก 4) · การ์ดอาการสำคัญ / คำสั่งแพทย์คู่กัน
  Widget _clyBodySkeleton() => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
        child: _Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(double.infinity, 92.0, radius: 20.0),
              _gap(20.0),
              Row(children: [
                _bone(110.0, 18.0),
                const Spacer(),
                _bone(90.0, 12.0),
              ]),
              _gap(14.0),
              Row(children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: 12.0),
                  Expanded(child: _bone(double.infinity, 26.0, radius: 6.0)),
                ],
              ]),
              _gap(16.0),
              SizedBox(
                height: 214.0,
                child: Row(children: [
                  Expanded(
                      flex: 5,
                      child: _bone(double.infinity, double.infinity,
                          radius: 16.0)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 8,
                    child: Column(children: [
                      for (var r = 0; r < 2; r++) ...[
                        if (r > 0) _gap(10.0),
                        Expanded(
                          child: Row(children: [
                            for (var c = 0; c < 2; c++) ...[
                              if (c > 0) const SizedBox(width: 10.0),
                              Expanded(
                                  child: _bone(double.infinity, double.infinity,
                                      radius: 16.0)),
                            ],
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ]),
              ),
              _gap(20.0),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 12.0),
                  Expanded(child: _bone(double.infinity, 220.0, radius: 16.0)),
                ],
              ]),
            ],
          ),
        ),
      );
}
