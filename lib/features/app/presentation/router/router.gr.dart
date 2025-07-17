// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:mobile/features/app/presentation/pages/splash.dart' as _i2;
import 'package:mobile/features/auth/presentation/pages/login.dart' as _i1;

/// generated route for
/// [_i1.LoginScreen]
class LoginScreen extends _i3.PageRouteInfo<void> {
  const LoginScreen({List<_i3.PageRouteInfo>? children})
    : super(LoginScreen.name, initialChildren: children);

  static const String name = 'LoginScreen';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.LoginScreen();
    },
  );
}

/// generated route for
/// [_i2.Splash]
class Splash extends _i3.PageRouteInfo<void> {
  const Splash({List<_i3.PageRouteInfo>? children})
    : super(Splash.name, initialChildren: children);

  static const String name = 'Splash';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.Splash();
    },
  );
}
