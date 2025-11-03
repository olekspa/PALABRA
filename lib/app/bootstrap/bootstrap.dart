import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:palabra/data_core/data_core.dart';

/// Handles one-time bootstrapping before the app widget tree is mounted.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InMemoryStore.instance.ensureVocabularyLoaded(rootBundle);
}
