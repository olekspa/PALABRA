import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/data_core/in_memory_store.dart';
import 'package:palabra/feature_profiles/application/profile_repository.dart';

void main() {
  setUp(() {
    final store = InMemoryStore.instance;
    for (final id in List<String>.from(store.profileIds)) {
      store.deleteProfile(id);
    }
    store.ensureActiveProfile();
  });

  test('creates and switches profiles', () async {
    final repo = ProfileRepository(store: InMemoryStore.instance);
    final summary1 = await repo.createProfile('Alice');
    expect(summary1.displayName, 'Alice');

    final summary2 = await repo.createProfile('Bob');
    expect(summary2.displayName, 'Bob');

    await repo.switchProfile(summary1.id);
    final active = await repo.activeProfile();
    expect(active.id, summary1.id);
  });
}
