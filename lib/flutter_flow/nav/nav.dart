import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/supabase/supabase.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => isWeb
                  ? Container()
                  : Container(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      child: Center(
                        child: Image.asset(
                          'assets/images/ChatGPT_Image_18_.._2568_10_55_29.png',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            )
          : LoginWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => isWeb
                      ? Container()
                      : Container(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          child: Center(
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_18_.._2568_10_55_29.png',
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                )
              : LoginWidget(),
          routes: [
            FFRoute(
              name: LoginWidget.routeName,
              path: LoginWidget.routePath,
              builder: (context, params) => LoginWidget(),
            ),
            FFRoute(
              name: PreviewWidgetWidget.routeName,
              path: PreviewWidgetWidget.routePath,
              builder: (context, params) => PreviewWidgetWidget(),
            ),
            FFRoute(
              name: PdpaWidget.routeName,
              path: PdpaWidget.routePath,
              builder: (context, params) => PdpaWidget(),
            ),
            FFRoute(
              name: PinWidget.routeName,
              path: PinWidget.routePath,
              builder: (context, params) => PinWidget(),
            ),
            FFRoute(
              name: MainPageWidget.routeName,
              path: MainPageWidget.routePath,
              builder: (context, params) => MainPageWidget(),
            ),
            FFRoute(
              name: HomepageOPDWidget.routeName,
              path: HomepageOPDWidget.routePath,
              builder: (context, params) => HomepageOPDWidget(),
            ),
            FFRoute(
              name: IPDHomepageWidget.routeName,
              path: IPDHomepageWidget.routePath,
              builder: (context, params) => IPDHomepageWidget(),
            ),
            FFRoute(
              name: ERDashboardWidget.routeName,
              path: ERDashboardWidget.routePath,
              builder: (context, params) => ERDashboardWidget(),
            ),
            FFRoute(
              name: SettingWidget.routeName,
              path: SettingWidget.routePath,
              builder: (context, params) => SettingWidget(),
            ),
            FFRoute(
              name: ExaminationroomOPDWidget.routeName,
              path: ExaminationroomOPDWidget.routePath,
              builder: (context, params) => ExaminationroomOPDWidget(),
            ),
            FFRoute(
              name: PatientListOPDWidget.routeName,
              path: PatientListOPDWidget.routePath,
              builder: (context, params) => PatientListOPDWidget(),
            ),
            FFRoute(
              name: ExaminationroomIPDWidget.routeName,
              path: ExaminationroomIPDWidget.routePath,
              builder: (context, params) => ExaminationroomIPDWidget(),
            ),
            FFRoute(
              name: PatientListIPDWidget.routeName,
              path: PatientListIPDWidget.routePath,
              builder: (context, params) => PatientListIPDWidget(),
            ),
            FFRoute(
              name: PatientInfoIPDWidget.routeName,
              path: PatientInfoIPDWidget.routePath,
              builder: (context, params) => PatientInfoIPDWidget(),
            ),
            FFRoute(
              name: SelectBranchWidget.routeName,
              path: SelectBranchWidget.routePath,
              builder: (context, params) => SelectBranchWidget(),
            ),
            FFRoute(
              name: PDPASettingWidget.routeName,
              path: PDPASettingWidget.routePath,
              builder: (context, params) => PDPASettingWidget(),
            ),
            FFRoute(
              name: AddNursingproblemsWidget.routeName,
              path: AddNursingproblemsWidget.routePath,
              builder: (context, params) => AddNursingproblemsWidget(),
            ),
            FFRoute(
              name: AddTreatmentIPDWidget.routeName,
              path: AddTreatmentIPDWidget.routePath,
              builder: (context, params) => AddTreatmentIPDWidget(),
            ),
            FFRoute(
              name: LabHistoryWidget.routeName,
              path: LabHistoryWidget.routePath,
              builder: (context, params) => LabHistoryWidget(),
            ),
            FFRoute(
              name: ConsultListWidget.routeName,
              path: ConsultListWidget.routePath,
              builder: (context, params) => ConsultListWidget(),
            ),
            FFRoute(
              name: SendConsultWidget.routeName,
              path: SendConsultWidget.routePath,
              builder: (context, params) => SendConsultWidget(),
            ),
            FFRoute(
              name: AddMedicalcertificateWidget.routeName,
              path: AddMedicalcertificateWidget.routePath,
              builder: (context, params) => AddMedicalcertificateWidget(),
            ),
            FFRoute(
              name: MedicalcertificateDetailWidget.routeName,
              path: MedicalcertificateDetailWidget.routePath,
              builder: (context, params) => MedicalcertificateDetailWidget(),
            ),
            FFRoute(
              name: AddAppiontmentWidget.routeName,
              path: AddAppiontmentWidget.routePath,
              builder: (context, params) => AddAppiontmentWidget(),
            ),
            FFRoute(
              name: AppiontmentDetailWidget.routeName,
              path: AppiontmentDetailWidget.routePath,
              builder: (context, params) => AppiontmentDetailWidget(),
            ),
            FFRoute(
              name: NursingProblemsDetailWidget.routeName,
              path: NursingProblemsDetailWidget.routePath,
              builder: (context, params) => NursingProblemsDetailWidget(),
            ),
            FFRoute(
              name: TreatmentIPDDetailWidget.routeName,
              path: TreatmentIPDDetailWidget.routePath,
              builder: (context, params) => TreatmentIPDDetailWidget(),
            ),
            FFRoute(
              name: AddNursingrecordsWidget.routeName,
              path: AddNursingrecordsWidget.routePath,
              builder: (context, params) => AddNursingrecordsWidget(),
            ),
            FFRoute(
              name: NursingrecordsDetailWidget.routeName,
              path: NursingrecordsDetailWidget.routePath,
              builder: (context, params) => NursingrecordsDetailWidget(),
            ),
            FFRoute(
              name: AddLabWidget.routeName,
              path: AddLabWidget.routePath,
              builder: (context, params) => AddLabWidget(),
            ),
            FFRoute(
              name: AddXrayWidget.routeName,
              path: AddXrayWidget.routePath,
              builder: (context, params) => AddXrayWidget(),
            ),
            FFRoute(
              name: ERHomepageWidget.routeName,
              path: ERHomepageWidget.routePath,
              builder: (context, params) => ERHomepageWidget(),
            ),
            FFRoute(
              name: PatientInfoERWidget.routeName,
              path: PatientInfoERWidget.routePath,
              builder: (context, params) => PatientInfoERWidget(),
            ),
            FFRoute(
              name: AddAdmitWidget.routeName,
              path: AddAdmitWidget.routePath,
              builder: (context, params) => AddAdmitWidget(),
            ),
            FFRoute(
              name: AddReferWidget.routeName,
              path: AddReferWidget.routePath,
              builder: (context, params) => AddReferWidget(),
            ),
            FFRoute(
              name: AddScreeningWidget.routeName,
              path: AddScreeningWidget.routePath,
              builder: (context, params) => AddScreeningWidget(),
            ),
            FFRoute(
              name: AddPhysicalExaminationWidget.routeName,
              path: AddPhysicalExaminationWidget.routePath,
              builder: (context, params) => AddPhysicalExaminationWidget(),
            ),
            FFRoute(
              name: AddAccidentWidget.routeName,
              path: AddAccidentWidget.routePath,
              builder: (context, params) => AddAccidentWidget(),
            ),
            FFRoute(
              name: AddAccidentVitalSignsWidget.routeName,
              path: AddAccidentVitalSignsWidget.routePath,
              builder: (context, params) => AddAccidentVitalSignsWidget(),
            ),
            FFRoute(
              name: AddAccidentBasicCareWidget.routeName,
              path: AddAccidentBasicCareWidget.routePath,
              builder: (context, params) => AddAccidentBasicCareWidget(),
            ),
            FFRoute(
              name: AddTreatmentERWidget.routeName,
              path: AddTreatmentERWidget.routePath,
              builder: (context, params) => AddTreatmentERWidget(),
            ),
            FFRoute(
              name: TreatmentERDetailWidget.routeName,
              path: TreatmentERDetailWidget.routePath,
              builder: (context, params) => TreatmentERDetailWidget(),
            ),
            FFRoute(
              name: AddObserveWidget.routeName,
              path: AddObserveWidget.routePath,
              builder: (context, params) => AddObserveWidget(),
            ),
            FFRoute(
              name: AddNursingDiagnosisWidget.routeName,
              path: AddNursingDiagnosisWidget.routePath,
              builder: (context, params) => AddNursingDiagnosisWidget(),
            ),
            FFRoute(
              name: AddDoctorsordersWidget.routeName,
              path: AddDoctorsordersWidget.routePath,
              builder: (context, params) => AddDoctorsordersWidget(),
            ),
            FFRoute(
              name: ERAdmissionEditWidget.routeName,
              path: ERAdmissionEditWidget.routePath,
              builder: (context, params) => ERAdmissionEditWidget(),
            ),
            FFRoute(
              name: AddMedicatinOrderWidget.routeName,
              path: AddMedicatinOrderWidget.routePath,
              builder: (context, params) => AddMedicatinOrderWidget(),
            ),
            FFRoute(
              name: MedicatinOrderDetailWidget.routeName,
              path: MedicatinOrderDetailWidget.routePath,
              builder: (context, params) => MedicatinOrderDetailWidget(),
            ),
            FFRoute(
              name: MedicatinOrderDetail2Widget.routeName,
              path: MedicatinOrderDetail2Widget.routePath,
              builder: (context, params) => MedicatinOrderDetail2Widget(),
            ),
            FFRoute(
              name: OrganDonationpageWidget.routeName,
              path: OrganDonationpageWidget.routePath,
              builder: (context, params) => OrganDonationpageWidget(),
            ),
            FFRoute(
              name: PatientInfoOrganDonationWidget.routeName,
              path: PatientInfoOrganDonationWidget.routePath,
              builder: (context, params) => PatientInfoOrganDonationWidget(),
            ),
            FFRoute(
              name: DonorssignatureWidget.routeName,
              path: DonorssignatureWidget.routePath,
              builder: (context, params) => DonorssignatureWidget(),
            ),
            FFRoute(
              name: PatientInfoOrganDonationDetailWidget.routeName,
              path: PatientInfoOrganDonationDetailWidget.routePath,
              builder: (context, params) =>
                  PatientInfoOrganDonationDetailWidget(),
            ),
            FFRoute(
              name: XrayDetalWidget.routeName,
              path: XrayDetalWidget.routePath,
              builder: (context, params) => XrayDetalWidget(
                data: params.getParam(
                  'data',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: AddVitalsignmonitorWidget.routeName,
              path: AddVitalsignmonitorWidget.routePath,
              builder: (context, params) => AddVitalsignmonitorWidget(),
            ),
            FFRoute(
              name: RegisPatientipdERWidget.routeName,
              path: RegisPatientipdERWidget.routePath,
              builder: (context, params) => RegisPatientipdERWidget(),
            ),
            FFRoute(
              name: SummarizeChartWidget.routeName,
              path: SummarizeChartWidget.routePath,
              builder: (context, params) => SummarizeChartWidget(),
            ),
            FFRoute(
              name: PatientInfoSummarizeChartWidget.routeName,
              path: PatientInfoSummarizeChartWidget.routePath,
              builder: (context, params) => PatientInfoSummarizeChartWidget(),
            ),
            FFRoute(
              name: ERHomepageCopyWidget.routeName,
              path: ERHomepageCopyWidget.routePath,
              builder: (context, params) => ERHomepageCopyWidget(),
            ),
            FFRoute(
              name: AddPhysicalExaminationCopy2Widget.routeName,
              path: AddPhysicalExaminationCopy2Widget.routePath,
              builder: (context, params) => AddPhysicalExaminationCopy2Widget(),
            ),
            FFRoute(
              name: MainPageCopyWidget.routeName,
              path: MainPageCopyWidget.routePath,
              builder: (context, params) => MainPageCopyWidget(),
            ),
            FFRoute(
              name: AddPhysicalExaminationCopyWidget.routeName,
              path: AddPhysicalExaminationCopyWidget.routePath,
              builder: (context, params) => AddPhysicalExaminationCopyWidget(),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
