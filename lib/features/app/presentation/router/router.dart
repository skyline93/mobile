import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/app/presentation/router/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // AutoRoute(page: Splash.page, path: '/splash', initial: true),
    AutoRoute(page: LoginScreen.page, path: '/login', initial: true),
  ];
}

final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});
