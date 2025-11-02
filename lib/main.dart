import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/app/app.dart';
import 'package:palabra/app/bootstrap/bootstrap.dart';

/// Entry point for the Palabra mobile application.
Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(child: PalabraApp()));
}
