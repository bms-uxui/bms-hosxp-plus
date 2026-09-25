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

extension _CoreSkeletonPart on _ErFlowHomeWidgetState {
  /// แผงซ้าย: หัวข้อ ตัวเลขใหญ่ 2×2 กราฟ แล้วรายการ
  Widget _panelSkeleton({Key? key}) => SingleChildScrollView(
        key: key,
        padding: const EdgeInsets.fromLTRB(18.0, 10.0, 16.0, 16.0),
        child: _Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(190.0, 22.0),
              _gap(6.0),
              _bone(150.0, 11.0),
              _gap(16.0),
              for (var r = 0; r < 2; r++) ...[
                Row(
                  children: [
                    for (var c = 0; c < 2; c++) ...[
                      if (c == 1) const SizedBox(width: 10.0),
                      Expanded(
                        child: _bone(double.infinity, 78.0, radius: 14.0),
                      ),
                    ],
                  ],
                ),
                _gap(10.0),
              ],
              _bone(150.0, 12.0),
              _gap(10.0),
              _bone(double.infinity, 120.0, radius: 12.0),
              _gap(18.0),
              _bone(120.0, 12.0),
              _gap(10.0),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _bone(64.0, 30.0, radius: 100.0),
                    ),
                ],
              ),
              _gap(12.0),
              // รายการเป็นแถวคั่นเส้น กระดูกจึงเป็นบรรทัด ไม่ใช่กล่องการ์ด
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(14.0, 16.0, radius: 4.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bone(double.infinity, 12.0),
                            _gap(6.0),
                            _bone(120.0, 10.0),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      _bone(42.0, 12.0),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _statCardSkeleton() => _Shimmer(
        child: Container(
          width: 236.0,
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bone(70.0, 11.0),
                    _gap(8.0),
                    _bone(58.0, 30.0),
                    _gap(6.0),
                    _bone(96.0, 10.0),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              _bone(62.0, 62.0, radius: 31.0),
            ],
          ),
        ),
      );

  Widget _patientCardSkeleton() => _Shimmer(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: _line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bone(44.0, 22.0, radius: 8.0),
                  const SizedBox(width: 6.0),
                  _bone(96.0, 22.0, radius: 8.0),
                  const Spacer(),
                  _bone(110.0, 22.0),
                ],
              ),
              _gap(10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _bone(44.0, 44.0, radius: 22.0),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _bone(180.0, 18.0),
                                  _gap(6.0),
                                  _bone(240.0, 11.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _gap(12.0),
                        _bone(120.0, 11.0),
                        _gap(8.0),
                        _bone(double.infinity, 13.0),
                        _gap(6.0),
                        _bone(260.0, 13.0),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    flex: 4,
                    child: _bone(double.infinity, 144.0, radius: 16.0),
                  ),
                ],
              ),
              _gap(12.0),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _bone(96.0, 34.0, radius: 12.0),
                    ),
                  const Spacer(),
                  _bone(150.0, 38.0, radius: 14.0),
                ],
              ),
            ],
          ),
        ),
      );

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
}
