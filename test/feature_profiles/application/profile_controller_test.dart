import 'package:flutter_test/flutter_test.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/application/profile_controller.dart';
import 'package:palabra/feature_profiles/application/profile_service.dart';
import 'package:palabra/feature_profiles/application/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late InMemoryStore store;
  late ProfileController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    store = InMemoryStore.instance;
    for (final id in List<String>.from(store.profileIds)) {
      store.deleteProfile(id);
    }
    store.ensureActiveProfile();
    store.userMeta = UserMeta();

    final repo = ProfileRepository(store: store);
    final service = ProfileService(repo);
    controller = ProfileController(service: service);
    addTearDown(controller.dispose);
  });

  test('initial load contains default profile', () async {
    final profiles = await controller.refresh();
    expect(profiles, isNotEmpty);
    expect(controller.state.hasValue, isTrue);
  });

  test('create, rename, select, and delete profile flow', () async {
    final initialProfiles = await controller.refresh();
    final initialCount = initialProfiles.length;

    final created = await controller.create('Alice');
    expect(created.displayName, 'Alice');
    expect(controller.state.value!.length, initialCount + 1);

    await controller.rename(id: created.id, name: 'Alicia');
    final renamed = controller.state.value!.firstWhere(
      (profile) => profile.id == created.id,
    );
    expect(renamed.displayName, 'Alicia');

    final selected = await controller.select(created.id);
    expect(selected.isActive, isTrue);

    await controller.delete(created.id);
    expect(
      controller.state.value!.any((profile) => profile.id == created.id),
      isFalse,
    );
  });
}
