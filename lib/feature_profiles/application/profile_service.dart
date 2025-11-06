import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/application/profile_repository.dart';

final activeProfileIdProvider = StateProvider<String?>((ref) => null);

final profileListProvider = FutureProvider.autoDispose<List<ProfileSummary>>((
  ref,
) async {
  final repo = ref.watch(profileRepositoryProvider);
  final summaries = await repo.listProfiles();
  ProfileSummary? active;
  for (final summary in summaries) {
    if (summary.isActive) {
      active = summary;
      break;
    }
  }
  active ??= summaries.isNotEmpty ? summaries.first : null;
  if (active != null) {
    ref.read(activeProfileIdProvider.notifier).state = active.id;
  }
  return summaries;
});

final activeProfileProvider = FutureProvider.autoDispose<ProfileSummary>((
  ref,
) async {
  final repo = ref.watch(profileRepositoryProvider);
  final summary = await repo.activeProfile();
  ref.read(activeProfileIdProvider.notifier).state = summary.id;
  return summary;
});

class ProfileService {
  ProfileService(this._repo);

  final ProfileRepository _repo;

  Future<List<ProfileSummary>> listProfiles() => _repo.listProfiles();

  Future<ProfileSummary> createProfile(String name) async {
    final summary = await _repo.createProfile(name);
    await _repo.switchProfile(summary.id);
    return summary;
  }

  Future<void> renameProfile(String profileId, String name) {
    return _repo.renameProfile(profileId, name);
  }

  Future<void> switchProfile(String profileId) async {
    await _repo.switchProfile(profileId);
  }

  Future<void> deleteProfile(String profileId) async {
    await _repo.deleteProfile(profileId);
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileService(repo);
});
