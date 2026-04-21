import '/er/er_dashboard/widgets/kpi_card/kpi_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'kpi_overview_section_model.dart';
export 'kpi_overview_section_model.dart';

class KpiOverviewSectionWidget extends StatefulWidget {
  const KpiOverviewSectionWidget({
    super.key,
    this.sectionNumber = '1',
    this.showHeader = true,
    this.showLiveBadges = true,
  });

  final String sectionNumber;
  final bool showHeader;
  final bool showLiveBadges;

  @override
  State<KpiOverviewSectionWidget> createState() =>
      _KpiOverviewSectionWidgetState();
}

class _KpiOverviewSectionWidgetState extends State<KpiOverviewSectionWidget> {
  late KpiOverviewSectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KpiOverviewSectionModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  double _gap(BuildContext context) {
    return MediaQuery.sizeOf(context).width < kBreakpointMedium ? 12.0 : 16.0;
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kBreakpointMedium) return 1;
    if (w < kBreakpointLarge) return 2;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final pad = _gap(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E83E6).withValues(alpha: 0.14),
            blurRadius: 32.0,
            offset: const Offset(0.0, 18.0),
            spreadRadius: -6.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.70),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.72),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(pad + 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showHeader) _buildHeader(context),
                      if (widget.showHeader) SizedBox(height: pad),
                      _buildGrid(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bool isCompact =
        MediaQuery.sizeOf(context).width < kBreakpointMedium;

    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary, theme.secondary],
              begin: const AlignmentDirectional(0.56, -1.0),
              end: const AlignmentDirectional(-0.56, 1.0),
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.sectionNumber,
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              color: theme.secondaryBackground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ตัวชี้วัดสำคัญวันนี้',
                style: theme.titleMedium.override(
                  fontFamily: theme.titleMediumFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleMediumIsCustom,
                ),
              ),
              Text(
                'KEY METRICS · สรุปภาพรวม ER แบบเรียลไทม์ — อัปเดตทุก 15 นาที',
                style: theme.labelSmall.override(
                  fontFamily: theme.labelSmallFamily,
                  letterSpacing: 0.8,
                  useGoogleFonts: !theme.labelSmallIsCustom,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!widget.showLiveBadges) return titleBlock;

    final badges = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _livePill(context),
        const SizedBox(width: 8.0),
        _alertPill(context, count: 3),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 12.0),
          badges,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        badges,
      ],
    );
  }

  Widget _livePill(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Solid3DBadge(
      color: theme.success,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.7),
                  blurRadius: 4.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            'Live',
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertPill(BuildContext context, {required int count}) {
    final theme = FlutterFlowTheme.of(context);
    return Solid3DBadge(
      color: theme.warning,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.white,
            size: 12.0,
          ),
          const SizedBox(width: 6.0),
          Text(
            'แจ้งเตือน $count รายการ',
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final gap = _gap(context);
    final kpis = <Widget>[
      const KpiCardWidget(
        title: 'ผู้ป่วยรอรับบริการ',
        value: '47',
        unit: 'คน',
        subtitle: '↑ เพิ่มขึ้น 8 คน ใน 1 ชม.',
        status: KpiStatus.neutral,
        illustrationPath: 'assets/images/ChatGPT_Image_24_.._2568_14_20_19.png',
        infoDescription:
            'จำนวนผู้ป่วยที่ลงทะเบียนเข้า ER แล้วแต่ยังไม่ได้รับการประเมินหรือรักษาครั้งแรก · ตัวเลขนี้บอกภาระงานปัจจุบันของทีม',
      ),
      const KpiCardWidget(
        title: 'เวลารอเฉลี่ย',
        value: '38',
        unit: 'นาที',
        subtitle: '↑ ช้ากว่าเป้าหมาย (≤30 นาที)',
        status: KpiStatus.warning,
        illustrationPath: 'assets/images/ChatGPT_Image_27_.._2568_16_20_42.png',
        infoDescription:
            'ค่าเฉลี่ยของเวลาที่ผู้ป่วยทุกรายรอตั้งแต่ลงทะเบียนจนได้รับการประเมินหรือรักษาครั้งแรก · ครอบคลุมรอ Triage, รอแพทย์, รอผล Lab, รอเตียง',
        infoFormula: 'เวลารอเฉลี่ย = Σ เวลารอของผู้ป่วยทุกราย ÷ จำนวนผู้ป่วย',
        infoExample: '(20 + 30 + 45 + 25 + 70) ÷ 5 = 38 นาที',
      ),
      const KpiCardWidget(
        title: 'Door-to-Doctor',
        value: '22',
        unit: 'นาที',
        subtitle: '↓ เร็วขึ้น 5 นาที — ทำได้ดี',
        status: KpiStatus.good,
        illustrationPath: 'assets/images/ChatGPT_Image_24_.._2568_14_27_57.png',
        infoDescription:
            'ระยะเวลาตั้งแต่ผู้ป่วยเข้าประตู ER จนพบแพทย์ครั้งแรก · ไม่รวมเวลารอผล Lab หรือการตรวจอื่นๆ',
        infoFormula: 'Door-to-Doctor = เวลาที่พบแพทย์ − เวลาเข้าประตู',
      ),
      const KpiCardWidget(
        title: 'ผู้ป่วยทั้งหมดวันนี้',
        value: '312',
        unit: 'คน',
        subtitle: 'เป้าหมายวันละ 280 คน',
        status: KpiStatus.neutral,
        illustrationPath: 'assets/images/ChatGPT_Image_4_.._2568_08_58_08.png',
        infoDescription:
            'จำนวนผู้ป่วยทั้งหมดที่ลงทะเบียนเข้า ER ตั้งแต่ 00:00 น. ของวันนี้ · เทียบกับค่าเป้าหมายเฉลี่ย 280 คน/วัน',
      ),
      const KpiCardWidget(
        title: 'อัตราการ Admit',
        value: '18.6',
        unit: '%',
        subtitle: 'เดือนก่อน 17.2% — ใกล้เคียงกัน',
        status: KpiStatus.neutral,
        illustrationPath: 'assets/images/ChatGPT_Image_7_.._2568_17_57_10.png',
        infoDescription:
            'อัตราส่วนของผู้ป่วยที่แพทย์ตัดสินใจรับไว้นอนโรงพยาบาล (Admit) เทียบกับผู้ป่วยทั้งหมดที่เข้า ER',
        infoFormula:
            'Admit Rate = (จำนวนผู้ถูก Admit ÷ จำนวนผู้ป่วย ER ทั้งหมด) × 100',
        infoExample: '58 ÷ 312 × 100 = 18.6%',
      ),
      const KpiCardWidget(
        title: 'ออกก่อนพบแพทย์ (LWBS)',
        value: '4.2',
        unit: '%',
        subtitle: '↑ เกินเกณฑ์ (≤3%) ควรตรวจสอบ',
        status: KpiStatus.critical,
        illustrationPath: 'assets/images/ChatGPT_Image_2_.._2568_13_41_16.png',
        infoDescription:
            'Left Without Being Seen · ผู้ป่วยที่ลงทะเบียนหรือผ่าน Triage แล้วแต่ตัดสินใจออกจาก ER ก่อนพบแพทย์ โดยไม่ได้รับการรักษา · เกณฑ์มาตรฐาน ≤ 3%',
        infoFormula:
            'LWBS Rate = (จำนวนผู้ออกก่อนพบแพทย์ ÷ จำนวนผู้ลงทะเบียนทั้งหมด) × 100',
        infoExample: '13 ÷ 312 × 100 = 4.2%',
      ),
      const KpiCardWidget(
        title: 'อัตราการใช้เตียง ER',
        value: '91',
        unit: '%',
        subtitle: 'ระดับวิกฤต (≥90%) — แจ้งทีมสำรอง',
        status: KpiStatus.critical,
        illustrationPath: 'assets/images/ChatGPT_Image_30_.._2568_13_54_54.png',
        infoDescription:
            'อัตราการครองเตียงของผู้ป่วย ณ ช่วงเวลาใดเวลาหนึ่ง เทียบกับจำนวนเตียงทั้งหมดที่ ER มีอยู่ · เกณฑ์วิกฤต ≥ 90%',
        infoFormula:
            'Bed Occupancy = (จำนวนเตียงที่มีผู้ป่วย ÷ จำนวนเตียงทั้งหมด) × 100',
        infoExample: '27 ÷ 30 × 100 = 90%',
      ),
      const KpiCardWidget(
        title: 'ผู้ป่วยเสียชีวิต',
        value: '2',
        unit: 'คน',
        subtitle: 'เฉลี่ยต่อวัน 1.8 คน',
        status: KpiStatus.neutral,
        illustrationPath: 'assets/images/ChatGPT_Image_5_.._2568_14_58_59.png',
        infoDescription:
            'จำนวนผู้ป่วยที่เสียชีวิตใน ER วันนี้ · เทียบกับค่าเฉลี่ย 1.8 คน/วัน จากข้อมูลย้อนหลัง 30 วัน',
      ),
    ];

    return MasonryGridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount(context),
      ),
      crossAxisSpacing: gap,
      mainAxisSpacing: gap,
      itemCount: kpis.length,
      itemBuilder: (context, index) => kpis[index],
    );
  }
}
