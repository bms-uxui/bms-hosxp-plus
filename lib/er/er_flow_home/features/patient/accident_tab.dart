// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ แท็บอุบัติเหตุ (แพทย์)
// ข้อมูลเหตุการณ์ที่พยาบาลคัดกรองบันทึกตอนรับเข้า ไว้ประกอบการดูแลเคสบาดเจ็บ
// ค่าที่แพทย์บันทึกเองในขั้น "อุบัติเหตุ" ของ workflow แทนที่ค่าจากจุดคัดกรอง

/// ลำดับของแท็บใน _detailTabs (ต่อท้าย ไม่ขยับเลขแท็บเดิม)
const int _accTab = 13;

/// ช่องของฟอร์มอุบัติเหตุ (ชื่อเดียวกับฟอร์ม accident ของจุดคัดกรอง)
const String _accHas = 'มีอุบัติเหตุหรือไม่';
const String _accPlace = 'สถานที่เกิดเหตุ';
const String _accType = 'ประเภทอุบัติเหตุ';
const String _accVehicle = 'ยานพาหนะ / ประเภทผู้บาดเจ็บ';
const String _accSafety = 'หมวกนิรภัย / เข็มขัดนิรภัย';
const String _accSubst = 'แอลกอฮอล์ / สารเสพติด';
const String _accPre = 'การดูแลก่อนมาถึง';

/// ข้อมูลจำลองจากจุดคัดกรอง: HN → (เวลาเกิดเหตุ, ช่องฟอร์ม)
const Map<String, (String, Map<String, String>)> _accSeed = {
  '670123469': (
    '09:10',
    {
      _accHas: 'มี',
      _accPlace: 'บนถนนสายหลัก ถ.มิตรภาพ หน้าตลาดเทศบาล',
      _accType: 'การขนส่ง V20-V29 ผู้ขับขี่รถจักรยานยนต์',
      _accVehicle: 'รถจักรยานยนต์ / ผู้ขับขี่',
      _accSafety: 'สวมหมวกนิรภัย / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ดามขาขวา ใส่ Collar ห้ามเลือดแผลศีรษะ',
    }
  ),
  '670123460': (
    '09:52',
    {
      _accHas: 'มี',
      _accPlace: 'บนถนนสายรอง ซอยวัดกลาง',
      _accType: 'การขนส่ง V20-V29 ผู้ขับขี่รถจักรยานยนต์',
      _accVehicle: 'รถจักรยานยนต์ / ผู้ขับขี่',
      _accSafety: 'ไม่สวมหมวกนิรภัย / -',
      _accSubst: 'ดื่มแอลกอฮอล์ (ได้กลิ่น) / ไม่ใช้',
      _accPre: 'ใส่ Collar ดามแขนซ้าย',
    }
  ),
  '670123458': (
    '09:30',
    {
      _accHas: 'มี',
      _accPlace: 'ที่บ้าน',
      _accType: 'พลัดตกหกล้ม W10 ตกบันได',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ไม่ได้รับการดูแล',
    }
  ),
  '670123466': (
    '08:40',
    {
      _accHas: 'มี',
      _accPlace: 'ที่ทำงาน (ร้านอาหาร)',
      _accType: 'ของมีคม W26 มีด',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'กดห้ามเลือดด้วยผ้าสะอาด',
    }
  ),
  '670123468': (
    '09:15',
    {
      _accHas: 'มี',
      _accPlace: 'ที่บ้าน (ห้องน้ำ)',
      _accType: 'พลัดตกหกล้ม W01 ลื่นล้มบนพื้นระดับเดียวกัน',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ประคบเย็น',
    }
  ),
  '670123474': (
    '08:20',
    {
      _accHas: 'มี',
      _accPlace: 'สนามฟุตบอลโรงเรียน',
      _accType: 'การบาดเจ็บจากกีฬา W03 ปะทะกับผู้อื่น',
      _accVehicle: '- / ผู้บาดเจ็บ',
      _accSafety: '- / -',
      _accSubst: 'ไม่ดื่ม / ไม่ใช้',
      _accPre: 'ประคบเย็น ยกขาสูง',
    }
  ),
};

extension _FeaturesPatientAccidentTabPart on _ErFlowHomeWidgetState {
  /// ข้อมูลอุบัติเหตุของเคสจากจุดคัดกรอง (ไม่มี = null)
  /// ตัวที่สาม = แพทย์บันทึกฟอร์มอุบัติเหตุแล้ว
  (String?, Map<String, String>, bool)? _accOf(String hn) {
    final seed = _accSeed[hn];
    if (seed == null) return null;
    return (seed.$1, seed.$2, _accSaved(hn));
  }

  /// แผงซ้ายของอุบัติเหตุ: มีข้อมูลจากฟอร์ม (กำลังกรอก/บันทึกแล้ว/ร่าง) = หน้าข้อมูลแบบหน้าอื่น
  /// (_clyInfoPage) อัปเดตตามฟอร์มทันที · ยังไม่มี = ข้อมูลจากจุดคัดกรองแบบเดิม
  Widget _accTabBody() => ValueListenableBuilder<int>(
      valueListenable: _accLiveTick,
      builder: (context, _, __) {
        final hn = _caseP().hn;
        final vals = _accLive[hn] ?? _accStore[hn] ?? _accDrafts[hn];
        return vals == null || vals.isEmpty
            ? _accSeedBody()
            : _accRecordPage(vals, live: _accLive.containsKey(hn));
      });

  Widget _accRecordPage(Map<String, String> v, {required bool live}) {
    final hn = _caseP().hn;
    String val(String k) => (v[k] ?? '').trim().isEmpty ? '-' : v[k]!.trim();
    List<(String, String, bool)> rows(Iterable<String> ks) => [
          for (final k in ks) (k, val(k), false),
        ];
    List<String> group(String t) => [
          for (final (g, _, fs) in _accGroups)
            if (g == t)
              for (final (l, _) in fs) l
        ];
    final story = (_accNarratives[hn] ?? '').trim();
    final iss = _accIssTone(v['ISS']);
    final rts = _accRtsTone(v['RTS']);
    final saved = _accSaved(hn);
    // ข้อความยาว: การ์ดแบบเดียวกับการ์ดใน _clyInfoPage แต่เต็มความกว้าง (ไม่มีคอลัมน์ชื่อช่อง)
    Widget textCard(String name, String text) => Container(
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(name,
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 8.0),
            Text(text,
                style: _t(14.0,
                    color: _inkTitle, weight: FontWeight.w500, height: 1.5)),
          ]),
        );
    return _clyInfoPage(
      'อุบัติเหตุ',
      live
          ? 'ข้อมูลที่กำลังบันทึก · อัปเดตตามฟอร์มด้านขวา'
          : saved
              ? 'ข้อมูลอุบัติเหตุที่บันทึกแล้ว'
              : 'ร่างที่ยังไม่บันทึก',
      'triage',
      [
        ('เหตุการณ์', rows([_accWhen, ...group('เหตุการณ์')])),
        ('ข้อมูลการมา', rows([for (final (l, _) in _accArrival) l])),
        (
          'ปัจจัยเสี่ยง',
          [
            for (final k in group('ปัจจัยเสี่ยง'))
              // ดื่ม/ใช้สาร/ไม่สวม/ไม่คาด = ความเสี่ยง (แดง)
              (
                k,
                val(k),
                RegExp(r'ดื่ม|ใช้|ไม่สวม|ไม่คาด').hasMatch(v[k] ?? '') &&
                    !RegExp(r'ไม่ดื่ม|ไม่ใช้').hasMatch(v[k] ?? '')
              ),
          ]
        ),
        (
          'Body Region (AIS)',
          [
            for (final r in _accRegions)
              (_accRegionArt[r]?.$1 ?? r, val(r), (_accAisOf(v[r]) ?? 0) >= 3),
          ]
        ),
        (
          'Trauma Score',
          [
            (
              'ISS',
              iss == null ? '-' : '${v['ISS']} · ${iss.$2}',
              (iss?.$1 ?? 0) >= 4
            ),
            (
              'RTS',
              rts == null ? '-' : '${v['RTS']} · ${rts.$2}',
              (rts?.$1 ?? 0) >= 4
            ),
            for (final k in ['GCS.v', 'BPs', 'RR', 'PS']) (k, val(k), false),
          ]
        ),
        (
          'การดูแลก่อนมาถึง',
          [
            ...rows(group('การดูแลก่อนมาถึง')),
            if (val(_accPreNote) != '-') (_accPreNote, val(_accPreNote), false),
          ]
        ),
        if (val('หมายเหตุ') != '-')
          ('หมายเหตุ', [('', val('หมายเหตุ'), false)]),
      ],
      heroArt: Image.asset('assets/images/er_ov_emergent_fig.png',
          filterQuality: FilterQuality.medium),
      // ไม่ใช่ข้อมูลของผู้บันทึกคัดกรอง: ไม่แสดงบรรทัด "บันทึกโดย" (ยังไม่มีผู้บันทึกจริง)
      by: '-',
      lead: [
        if (story.isNotEmpty) ...[
          textCard('เล่าเหตุการณ์', story),
          const SizedBox(height: 12.0)
        ],
      ],
      extra: [
        if (val('หมายเหตุ') != '-') textCard('หมายเหตุ', val('หมายเหตุ')),
      ],
    );
  }

  Widget _accSeedBody() {
    final p = _caseP();
    final c = erCaseOf(p.hn);
    final acc = _accOf(p.hn);
    if (acc == null || acc.$2[_accHas] == 'ไม่มี') {
      return _accEmpty(acc == null
          ? 'ยังไม่มีข้อมูลอุบัติเหตุของเคสนี้'
          : 'บันทึกไว้ว่าไม่ใช่เคสอุบัติเหตุ');
    }
    final (time, f, byDoctor) = acc;
    final injuries = [
      for (final t in erBodyTargets(c))
        if (t.kind == ErBodyKind.bone || t.kind == ErBodyKind.zone) t.th
    ];
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        // หัว: กลไกการบาดเจ็บ (อาการสำคัญ) + เวลาเกิดเหตุ ห่างจากตอนนี้ + ผู้นำส่ง
        Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(_phaseIconOfAcc, size: 16.0, color: _blue),
                const SizedBox(width: 6.0),
                Text('ข้อมูลอุบัติเหตุ',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                Text(
                    byDoctor
                        ? 'แพทย์บันทึกเพิ่มในขั้นอุบัติเหตุ'
                        : 'บันทึกโดยพยาบาลคัดกรอง',
                    style: _t(10.0, color: _ink3)),
              ]),
              const SizedBox(height: 10.0),
              Text(c.cc,
                  style: _t(13.0,
                      color: _inkTitle, weight: FontWeight.w600, height: 1.45)),
              const SizedBox(height: 10.0),
              Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                if (time != null)
                  _accChip(Icons.schedule_rounded,
                      'เกิดเหตุ $time น. ${_ago(time)}'),
                _accChip(Icons.local_shipping_rounded, c.arrival),
                if (f[_accType] case final t? when t.isNotEmpty)
                  _accChip(Icons.category_rounded, t),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        // ความเสี่ยงที่ต้องระวัง: ไม่สวมอุปกรณ์นิรภัย / แอลกอฮอล์ = แดง (ค่าผิดปกติ)
        _clyCardGrid([
          _accField(Icons.place_rounded, 'สถานที่เกิดเหตุ', f[_accPlace]),
          _accField(Icons.two_wheeler_rounded, 'ยานพาหนะ / ผู้บาดเจ็บ',
              f[_accVehicle]),
          _accField(
              Icons.sports_motorsports_rounded, 'อุปกรณ์นิรภัย', f[_accSafety],
              bad: (f[_accSafety] ?? '').contains('ไม่สวม') ||
                  (f[_accSafety] ?? '').contains('ไม่คาด')),
          _accField(
              Icons.local_bar_rounded, 'แอลกอฮอล์ / สารเสพติด', f[_accSubst],
              bad: (f[_accSubst] ?? '').contains('ดื่มแอลกอฮอล์') ||
                  (f[_accSubst] ?? '').contains('ใช้สาร')),
        ], per: 2, minW: 200.0, equal: false),
        const SizedBox(height: 10.0),
        _clyCardGrid([
          _accField(
              Icons.medical_services_rounded, 'การดูแลก่อนมาถึง', f[_accPre]),
          _accField(Icons.personal_injury_rounded, 'ตำแหน่งที่บาดเจ็บ',
              injuries.isEmpty ? null : injuries.join(' ')),
        ], per: 2, minW: 200.0, equal: false),
        const SizedBox(height: 12.0),
        Align(
          alignment: Alignment.centerLeft,
          child: _accEditBtn(),
        ),
      ],
    );
  }

  IconData get _phaseIconOfAcc => Icons.car_crash_rounded;

  Widget _accChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13.0, color: _ink2),
          const SizedBox(width: 5.0),
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// การ์ดหนึ่งช่อง: ไอคอน + ชื่อช่อง + ค่า · ค่าที่เป็นความเสี่ยงเป็นสีแดง
  Widget _accField(IconData icon, String label, String? value,
          {bool bad = false}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
        decoration: _clyTileDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(icon, size: 14.0, color: bad ? _red : _blue),
              const SizedBox(width: 5.0),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6.0),
            Text(value == null || value.trim().isEmpty ? 'ไม่ระบุ' : value,
                style: _t(12.5,
                    color: bad
                        ? _red
                        : value == null
                            ? _ink3
                            : _inkTitle,
                    weight: FontWeight.w600,
                    height: 1.4)),
          ],
        ),
      );

  /// เปิดฟอร์มบันทึกอุบัติเหตุ
  Widget _accEditBtn() => _Press(
        child: Material(
          color: _panel,
          shape: const StadiumBorder(side: BorderSide(color: _line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: _openAccidentPane,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.edit_note_rounded, size: 16.0, color: _blue),
                const SizedBox(width: 6.0),
                Text('บันทึกในขั้นอุบัติเหตุ',
                    style: _t(11.5, color: _blue, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      );

  Widget _accEmpty(String text) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.car_crash_rounded, size: 40.0, color: _g5),
          const SizedBox(height: 10.0),
          Text(text, style: _t(12.5, color: _ink2, weight: FontWeight.w600)),
          const SizedBox(height: 12.0),
          _accEditBtn(),
        ]),
      );
}

// ------------------------------------------------ แท็บ X-ray
// ภาพรังสีของเคส (X-ray / CT) แบบแกลเลอรีภาพใหญ่ พร้อมผลอ่าน · แตะเพื่อดูเต็มจอ ซูมได้
// แท็บ "ภาพถ่าย" เดิมยังอยู่ (ผู้ใช้เลือกเพิ่มแท็บใหม่ ไม่แทนที่)

/// ลำดับของแท็บใน _detailTabs (ต่อท้าย ไม่ขยับเลขแท็บเดิม)
const int _xrayTab = 14;

extension _FeaturesPatientXrayTabPart on _ErFlowHomeWidgetState {
  Widget _xrayTabBody() {
    final imgs = erCaseOf(_caseP().hn).imaging;
    if (imgs.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.radio_button_checked_rounded,
              size: 40.0, color: _g5),
          const SizedBox(height: 10.0),
          Text('ยังไม่ได้ส่งถ่ายภาพรังสี',
              style: _t(12.5, color: _ink2, weight: FontWeight.w600)),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        Row(children: [
          Text('ภาพรังสี',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(width: 8.0),
          Text('${imgs.length} รายการ', style: _t(10.5, color: _ink3)),
        ]),
        const SizedBox(height: 10.0),
        _clyCardGrid([
          for (var i = 0; i < imgs.length; i++) _xrayCard(imgs, i),
        ], per: 2, minW: 220.0, equal: false),
      ],
    );
  }

  /// การ์ดภาพหนึ่งใบ: ภาพพื้นดำ · ชื่อ · ผลอ่าน (รอผล = สีรอง)
  Widget _xrayCard(List<ErImage> imgs, int i) {
    final img = imgs[i];
    final waiting = img.result.startsWith('รอ');
    return _Press(
      child: GestureDetector(
        onTap: () => _xrayView(imgs, i),
        child: Container(
          decoration: _clyTileDeco(),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 170.0,
                color: Colors.black,
                child: Image.asset(img.asset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: _g4))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(img.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 3.0),
                    Text(img.result,
                        style: _t(11.0,
                            color: waiting ? _ink3 : _ink2,
                            weight: FontWeight.w500,
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ดูภาพเต็มจอ ปัดเลื่อนภาพ · หนีบซูมได้
  void _xrayView(List<ErImage> imgs, int start) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      // Material โปร่ง: IconButton ใน dialog ต้องมี Material ancestor (ไม่งั้นจอแดง)
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          PageView.builder(
            controller: PageController(initialPage: start),
            itemCount: imgs.length,
            itemBuilder: (_, i) => Column(children: [
              Expanded(
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: Center(child: Image.asset(imgs[i].asset)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 28.0),
                child: Text('${imgs[i].name}  ${imgs[i].result}',
                    textAlign: TextAlign.center,
                    style:
                        _t(13.0, color: Colors.white, weight: FontWeight.w600)),
              ),
            ]),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
