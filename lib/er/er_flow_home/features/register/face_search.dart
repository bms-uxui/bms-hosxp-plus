// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ค้นหาผู้ป่วยด้วยการสแกนหน้า
// ปุ่มบนหน้าแรก → กล้องหน้า ถ่ายหน้าผู้ป่วย → เทียบกับรูปในระบบ
// ไม่เปิดเคสเองอัตโนมัติ: แสดงผู้ป่วยที่หน้าคล้ายที่สุด ให้ยืนยันชื่อ/HN ก่อนเปิดเสมอ
// (ยังจำลองการจับคู่ใบหน้า ยังไม่ได้ต่อระบบจดจำใบหน้าจริง)

mixin _FeaturesRegisterFaceSearchState on State<ErFlowHomeWidget> {
  /// หน้าต่างสแกนเปิดอยู่
  bool _faceOpen = false;

  /// รูปที่ถ่าย (ไฟล์ชั่วคราวจากกล้อง)
  String? _faceShot;

  /// 0 กำลังเทียบใบหน้า · 1 แสดงผล
  int _faceStage = 0;

  /// ผู้ป่วยที่คล้าย (HN, ความคล้าย 0–1) เรียงมากไปน้อย
  List<(String, double)> _faceHits = const [];
}

extension _FeaturesRegisterFaceSearchPart on _ErFlowHomeWidgetState {
  Future<void> _startFaceScan() async {
    final XFile? shot;
    try {
      shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 900.0,
        imageQuality: 80,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('เปิดกล้องไม่ได้ ตรวจสิทธิ์การใช้กล้อง',
              style: _t(12.0, color: Colors.white))));
      return;
    }
    if (shot == null || !mounted) return;
    final bytes = await shot.readAsBytes();
    // จำลองการจับคู่: สุ่มจากลายนิ้วมือของรูป ได้ผลเดิมทุกครั้งกับรูปเดิม
    var seed = bytes.length;
    for (var i = 0; i < bytes.length; i += 997) {
      seed = (seed * 31 + bytes[i]) & 0x7fffffff;
    }
    final rnd = math.Random(seed);
    final pool = [..._patients]..shuffle(rnd);
    final top = 0.86 + rnd.nextDouble() * 0.1;
    setState(() {
      _faceShot = shot!.path;
      _faceStage = 0;
      _faceHits = [
        for (var i = 0; i < math.min(3, pool.length); i++)
          (
            pool[i].hn,
            i == 0 ? top : top - 0.22 - i * 0.07 - rnd.nextDouble() * 0.05
          ),
      ];
      _faceOpen = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _faceOpen) setState(() => _faceStage = 1);
    });
  }

  void _closeFace() => setState(() => _faceOpen = false);

  void _faceOpenPatient(_P p) {
    setState(() => _faceOpen = false);
    _openPatient(p);
  }

  /// ปุ่มบนหน้าแรก คู่กับปุ่มลงทะเบียน (พื้นกรมท่า = การ์ดกระจก)
  Widget _faceScanButton() => _Press(
        child: GestureDetector(
          onTap: _startFaceScan,
          child: Container(
            height: 40.0,
            decoration: _lpCardDeco,
            foregroundDecoration: const _InnerGloss(12.0, dark: true),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.face_retouching_natural_rounded,
                  size: 18.0, color: _lpInk),
              const SizedBox(width: 6.0),
              Text('สแกนหน้า',
                  style: _t(12.5, color: _lpInk, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  Widget _faceHitRow(_P p, double score, bool best) {
    final c = erCaseOf(p.hn);
    final pct = (score * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      decoration: BoxDecoration(
        color: best ? _blue.withValues(alpha: 0.05) : _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: best ? _blue.withValues(alpha: 0.5) : _line),
      ),
      child: Row(children: [
        ClipOval(
          child: Image.asset(_faceUrl(p.hn),
              width: 44.0, height: 44.0, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
            Text(
                'HN ${p.hn} · ${c.ageText}'
                '${p.bed == null ? '' : ' · เตียง ${p.bed}'} · ${p.stage.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.5, color: _ink3)),
          ]),
        ),
        const SizedBox(width: 8.0),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$pct%',
              style: _num(15.0,
                  color: best ? _blue : _ink2, weight: FontWeight.w700)),
          Text('ความคล้าย', style: _t(9.0, color: _ink3)),
        ]),
        const SizedBox(width: 10.0),
        SizedBox(
          width: 92.0,
          child: _navBtn(
              'เปิด', Icons.arrow_forward_rounded, () => _faceOpenPatient(p),
              primary: best, trailing: true),
        ),
      ]),
    );
  }

  /// หน้าต่างผลสแกน: รูปที่ถ่าย (ซ้าย) · ผู้ป่วยที่คล้าย (ขวา)
  Widget _faceOverlay() {
    final hits = [
      for (final (hn, s) in _faceHits)
        for (final p in _patients)
          if (p.hn == hn) (p, s),
    ];
    final scanning = _faceStage == 0;
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: _closeFace,
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
        ),
      ),
      Center(
        child: Container(
          width: 720.0,
          height: 400.0,
          padding: const EdgeInsets.all(16.0),
          decoration: _clyCardDeco,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // รูปที่ถ่าย + เส้นสแกนวิ่งระหว่างเทียบ
            SizedBox(
              width: 280.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(fit: StackFit.expand, children: [
                  if (_faceShot != null)
                    Image.file(File(_faceShot!), fit: BoxFit.cover)
                  else
                    const ColoredBox(color: _panelSoft),
                  // กรอบใบหน้า
                  Center(
                    child: Container(
                      width: 170.0,
                      height: 210.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90.0),
                        border: Border.all(
                            color: scanning ? Colors.white : _blue4,
                            width: 2.5),
                      ),
                    ),
                  ),
                  if (scanning)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1800),
                      builder: (context, v, _) => Align(
                        alignment: Alignment(0.0, -0.9 + 1.8 * v),
                        child: Container(
                          height: 3.0,
                          margin: const EdgeInsets.symmetric(horizontal: 40.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: _blue4.withValues(alpha: 0.9),
                                  blurRadius: 12.0,
                                  spreadRadius: 2.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                          scanning
                              ? 'กำลังเทียบใบหน้า…'
                              : 'ผู้ป่วยที่หน้าตรงกัน',
                          style: _t(15.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    _topIcon(Icons.close_rounded, false, _closeFace),
                  ]),
                  Text(
                      scanning
                          ? 'เทียบกับรูปผู้ป่วย ${_patients.length} รายในห้องฉุกเฉิน'
                          : 'ตรวจชื่อและ HN กับผู้ป่วยก่อนเปิดทุกครั้ง',
                      style: _t(11.0, color: _ink3)),
                  const SizedBox(height: 14.0),
                  if (scanning)
                    const Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 28.0,
                          height: 28.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: _blue),
                        ),
                      ),
                    )
                  else ...[
                    for (var i = 0; i < hits.length; i++)
                      _faceHitRow(hits[i].$1, hits[i].$2, i == 0),
                    const Spacer(),
                    Row(children: [
                      Expanded(
                        child: _navBtn(
                            'สแกนใหม่', Icons.refresh_rounded, _startFaceScan,
                            primary: false),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: _navBtn('ไม่พบ · ลงทะเบียนใหม่',
                            Icons.person_add_alt_1_rounded, () {
                          _closeFace();
                          _openRegister();
                        }, primary: false),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}
