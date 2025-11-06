import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/application/profile_service.dart';

class ProfileController
    extends StateNotifier<AsyncValue<List<ProfileSummary>>> {
  ProfileController({required ProfileService service})
    : _service = service,
      super(const AsyncLoading<List<ProfileSummary>>()) {
    _loadProfiles();
  }

  final ProfileService _service;

  Future<List<ProfileSummary>> refresh() => _loadProfiles();

  Future<List<ProfileSummary>> _loadProfiles() async {
    final previous = state;
    state = const AsyncLoading<List<ProfileSummary>>().copyWithPrevious(
      previous,
    );
    try {
      final profiles = await _service.listProfiles();
      state = AsyncData<List<ProfileSummary>>(profiles);
      return profiles;
    } catch (error, stack) {
      state = AsyncError<List<ProfileSummary>>(
        error,
        stack,
      ).copyWithPrevious(previous);
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<ProfileSummary> create(String name) async {
    final summary = await _service.createProfile(name);
    await _loadProfiles();
    return summary;
  }

  Future<ProfileSummary> select(String id) async {
    await _service.switchProfile(id);
    final profiles = await _loadProfiles();
    return profiles.firstWhere((profile) => profile.id == id);
  }

  Future<void> rename({required String id, required String name}) async {
    await _service.renameProfile(id, name);
    await _loadProfiles();
  }

  Future<void> delete(String id) async {
    await _service.deleteProfile(id);
    await _loadProfiles();
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<List<ProfileSummary>>>(
      (ref) {
        final service = ref.watch(profileServiceProvider);
        return ProfileController(service: service);
      },
    );
