import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/er/er_dashboard/widgets/chief_complaints/chief_complaints_widget.dart';
import '/er/er_dashboard/widgets/disposition/disposition_widget.dart';
import '/er/er_dashboard/widgets/illustration_slot/illustration_slot_widget.dart';
import '/er/er_dashboard/widgets/kpi_card/kpi_card_widget.dart' show Solid3DBadge;
import '/er/er_dashboard/widgets/kpi_overview_section/kpi_overview_section_widget.dart';
import '/er/er_dashboard/widgets/length_of_stay/length_of_stay_widget.dart';
import '/er/er_dashboard/widgets/patient_flow/patient_flow_widget.dart';
import '/er/er_dashboard/widgets/triage_classification/triage_classification_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'er_dashboard_model.dart';
export 'er_dashboard_model.dart';

class ERDashboardWidget extends StatefulWidget {
  const ERDashboardWidget({super.key});

  static String routeName = 'ER_Dashboard';
  static String routePath = 'erDashboard';

  @override
  State<ERDashboardWidget> createState() => _ERDashboardWidgetState();
}

class _ERDashboardWidgetState extends State<ERDashboardWidget> {
  late ERDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ERDashboardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  double _pagePad(BuildContext context) {
    return MediaQuery.sizeOf(context).width < kBreakpointMedium ? 12.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final pad = _pagePad(context);
    final isCompact =
        MediaQuery.sizeOf(context).width < kBreakpointMedium;

    final heroHeight = isCompact ? 300.0 : 340.0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.accent2,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: theme.accent2,
              automaticallyImplyLeading: false,
              expandedHeight: heroHeight,
              toolbarHeight: 64.0,
              elevation: 0.0,
              title: wrapWithModel(
                model: _model.appBarUserModel,
                updateCallback: () => safeSetState(() {}),
                child: const AppBarUserWidget(),
              ),
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHero(context, theme, pad, isCompact),
              ),
            ),
          ],
          body: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
            ),
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(pad, pad, pad, 140.0),
                  children: [
                    const KpiOverviewSectionWidget(),
                    SizedBox(height: pad),
                    const TriageClassificationWidget(),
                    SizedBox(height: pad),
                    const PatientFlowWidget(),
                    SizedBox(height: pad),
                    const LengthOfStayWidget(),
                    SizedBox(height: pad),
                    const ChiefComplaintsWidget(),
                    SizedBox(height: pad),
                    const DispositionWidget(),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: wrapWithModel(
                    model: _model.navBarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const NavBarWidget(
                      navbar: 5,
                      hide: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    FlutterFlowTheme theme,
    double pad,
    bool isCompact,
  ) {
    final topInset = MediaQuery.paddingOf(context).top + 64.0 + 8.0;

    return Container(
      color: theme.accent2,
      child: Stack(
        children: [
          Positioned(
            top: topInset - 16.0,
            right: -20.0,
            child: const IllustrationSlot(
              width: 200.0,
              height: 200.0,
              opacity: 0.22,
              borderRadius: 16.0,
              placeholderLabel: 'DECORATIVE',
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              pad + 4.0,
              topInset,
              pad + 4.0,
              24.0,
            ),
            child: isCompact
                ? _buildHeroCompact(context, theme)
                : _buildHeroWide(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWide(BuildContext context, FlutterFlowTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildHeroTextBlock(context, theme)),
        const SizedBox(width: 20.0),
        _buildFeaturedIllustration(120.0),
      ],
    );
  }

  Widget _buildHeroCompact(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildHeroTextBlock(context, theme)),
            const SizedBox(width: 12.0),
            _buildFeaturedIllustration(96.0),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLivePill(context, theme),
            const SizedBox(width: 8.0),
            _buildAlertPill(context, theme, count: 3),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroTextBlock(BuildContext context, FlutterFlowTheme theme) {
    final isCompact =
        MediaQuery.sizeOf(context).width < kBreakpointMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ห้องอุบัติเหตุและฉุกเฉิน',
          style: theme.labelSmall.override(
            fontFamily: theme.labelSmallFamily,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            useGoogleFonts: !theme.labelSmallIsCustom,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'ภาพรวมผู้บริหาร',
          style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.0,
            lineHeight: 1.1,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6.0,
                offset: const Offset(0.0, 2.0),
              ),
            ],
            useGoogleFonts: !theme.headlineMediumIsCustom,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'ข้อมูล ณ วันที่ 16 เมษายน 2568 · อัปเดตทุก 15 นาที',
          style: theme.labelSmall.override(
            fontFamily: theme.labelSmallFamily,
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.2,
            useGoogleFonts: !theme.labelSmallIsCustom,
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(height: 16.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLivePill(context, theme),
              const SizedBox(width: 8.0),
              _buildAlertPill(context, theme, count: 3),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedIllustration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4.0),
      child: IllustrationSlot(
        width: size - 8.0,
        height: size - 8.0,
        shape: BoxShape.circle,
        placeholderLabel: 'HERO',
        placeholderIcon: Icons.local_hospital_outlined,
      ),
    );
  }

  Widget _buildLivePill(BuildContext context, FlutterFlowTheme theme) {
    return Solid3DBadge(
      color: theme.success,
      padding: const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 12.0, 6.0),
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

  Widget _buildAlertPill(
    BuildContext context,
    FlutterFlowTheme theme, {
    required int count,
  }) {
    return Solid3DBadge(
      color: theme.warning,
      padding: const EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 12.0, 6.0),
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
}
