import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/data_core.dart';

class ProfileRepository {
  ProfileRepository({InMemoryStore? store})
    : _store = store ?? InMemoryStore.instance;

  final InMemoryStore _store;

  Future<List<ProfileSummary>> listProfiles() async {
    _store.ensureActiveProfile();
    final summaries = _store.profileSummaries()
      ..sort((a, b) {
        if (a.isActive != b.isActive) {
          return a.isActive ? -1 : 1;
        }
        final aSeen = a.lastSeenAt ?? a.createdAt;
        final bSeen = b.lastSeenAt ?? b.createdAt;
        final seenCompare = bSeen.compareTo(aSeen);
        if (seenCompare != 0) {
          return seenCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });
    return summaries;
  }

  Future<ProfileSummary> activeProfile() async {
    final id = _store.ensureActiveProfile();
    return _store.profileSummary(id);
  }

  Future<ProfileSummary> createProfile(String name) async {
    final id = _store.createProfile(name: name);
    await _store.persist();
    return _store.profileSummary(id);
  }

  Future<void> renameProfile(String profileId, String name) async {
    final meta = _store.profileMeta(profileId);
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      meta.profileName = trimmed;
      meta.lastSeenAt = DateTime.now();
      await _store.persist();
    }
  }

  Future<void> switchProfile(String profileId) async {
    _store.ensureActiveProfile(profileId: profileId);
    await _store.persist();
  }

  Future<void> deleteProfile(String profileId) async {
    _store.deleteProfile(profileId);
    await _store.persist();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  return ProfileRepository(store: store);
});
