import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/feature_finish/presentation/finish_screen.dart';
import 'package:palabra/feature_gate/presentation/gate_screen.dart';
import 'package:palabra/feature_prerun/presentation/prerun_screen.dart';
import 'package:palabra/feature_run/presentation/run_screen.dart';

/// Declarative identifiers for app navigation targets.
enum AppRoute {
  /// Landing gate route.
  gate('/gate'),

  /// Pre-run configuration route.
  preRun('/mm/prerun'),

  /// Active run route.
  run('/mm/run'),

  /// Run completion summary route.
  finish('/mm/finish');

  const AppRoute(this.path);

  /// Path used by [GoRouter].
  final String path;
}

/// Global router provider shared across the app using Riverpod.
final goRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoute.gate.path,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.gate.path,
        name: AppRoute.gate.name,
        builder: (BuildContext context, GoRouterState state) {
          return const GateScreen();
        },
      ),
      GoRoute(
        path: AppRoute.preRun.path,
        name: AppRoute.preRun.name,
        builder: (BuildContext context, GoRouterState state) {
          return const PreRunScreen();
        },
      ),
      GoRoute(
        path: AppRoute.run.path,
        name: AppRoute.run.name,
        builder: (BuildContext context, GoRouterState state) {
          return const RunScreen();
        },
      ),
      GoRoute(
        path: AppRoute.finish.path,
        name: AppRoute.finish.name,
        builder: (BuildContext context, GoRouterState state) {
          return const FinishScreen();
        },
      ),
    ],
  );
});
