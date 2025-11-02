import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/app/theme/app_theme.dart';

/// Root widget for the Palabra application.
class PalabraApp extends ConsumerWidget {
  /// Creates a [PalabraApp].
  const PalabraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Palabra',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
