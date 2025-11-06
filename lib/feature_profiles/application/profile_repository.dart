import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palabra/data_core/data_core.dart';

class ProfileRepository {
  ProfileRepository({InMemoryStore? store, RemoteProfileApi? remote})
    : _store = store ?? InMemoryStore.instance,
      _remote = remote;

  final InMemoryStore _store;
  final RemoteProfileApi? _remote;

  bool get _remoteEnabled => _remote?.isConfigured ?? false;

  Future<List<ProfileSummary>> listProfiles() async {
    if (!_remoteEnabled) {
      return _sortedLocalSummaries();
    }
    try {
      final remoteSummaries = await _remote!.listProfiles();
      _syncLocalSummaries(remoteSummaries);
      final activeId = _store.activeProfileId;
      return remoteSummaries
          .map((summary) => _summaryFromRemote(summary, activeId))
          .toList();
    } catch (error, stack) {
      debugPrint('ProfileRepository listProfiles remote failed: $error');
      debugPrintStack(stackTrace: stack);
      return _sortedLocalSummaries();
    }
  }

  Future<ProfileSummary> activeProfile() async {
    final id = _store.ensureActiveProfile();
    return _store.profileSummary(id);
  }

  Future<ProfileSummary> createProfile(String name) async {
    if (!_remoteEnabled) {
      final id = _store.createProfile(name: name);
      await _store.persist();
      return _store.profileSummary(id);
    }
    final remoteSummary = await _remote!.createProfile(name);
    final meta = UserMeta()
      ..profileName = remoteSummary.displayName
      ..createdAt = DateTime.now()
      ..lastSeenAt = remoteSummary.lastSeenAt ?? DateTime.now()
      ..level = (remoteSummary.level ?? 'a1').toLowerCase()
      ..totalRuns = remoteSummary.totalRuns ?? 0
      ..syncVersion = remoteSummary.version;
    _store.upsertProfile(remoteSummary.id, meta);
    await _store.persist();
    return _store.profileSummary(remoteSummary.id);
  }

  Future<void> renameProfile(String profileId, String name) async {
    final meta = _store.profileMeta(profileId);
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      meta.profileName = trimmed;
      meta.lastSeenAt = DateTime.now();
      await _store.persist();
      await _pushProfile(profileId);
    }
  }

  Future<void> switchProfile(String profileId) async {
    if (_remoteEnabled) {
      await _pullRemoteProfile(profileId);
    }
    _store.ensureActiveProfile(profileId: profileId);
    await _store.persist();
  }

  Future<void> deleteProfile(String profileId) async {
    if (_remoteEnabled) {
      try {
        await _remote!.deleteProfile(profileId);
      } catch (error, stack) {
        debugPrint('ProfileRepository delete remote failed: $error');
        debugPrintStack(stackTrace: stack);
      }
    }
    _store.deleteProfile(profileId);
    await _store.persist();
  }

  Future<void> pushActiveProfile() async {
    final id = _store.ensureActiveProfile();
    await _pushProfile(id);
  }

  List<ProfileSummary> _sortedLocalSummaries() {
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

  void _syncLocalSummaries(List<RemoteProfileSummary> remoteSummaries) {
    for (final summary in remoteSummaries) {
      final meta = _store.profileMeta(summary.id);
      meta.profileName = summary.displayName;
      meta.lastSeenAt = summary.lastSeenAt ?? meta.lastSeenAt ?? DateTime.now();
      meta.totalRuns = summary.totalRuns ?? meta.totalRuns;
      if (summary.level != null && summary.level!.isNotEmpty) {
        meta.level = summary.level!.toLowerCase();
      }
      meta.syncVersion = summary.version;
      _store.upsertProfile(summary.id, meta);
    }
  }

  ProfileSummary _summaryFromRemote(
    RemoteProfileSummary summary,
    String? activeId,
  ) {
    final meta = _store.profileMeta(summary.id);
    return ProfileSummary(
      id: summary.id,
      displayName: summary.displayName,
      createdAt: meta.createdAt,
      lastSeenAt: summary.lastSeenAt ?? meta.lastSeenAt ?? meta.createdAt,
      level: summary.level ?? meta.level,
      totalRuns: summary.totalRuns ?? meta.totalRuns,
      isActive: summary.id == activeId,
    );
  }

  Future<void> _pullRemoteProfile(String profileId) async {
    try {
      final snapshot = await _remote!.fetchProfile(profileId);
      _store.applyProfileSnapshot(profileId, snapshot.toJson());
    } catch (error, stack) {
      debugPrint('ProfileRepository pull remote failed: $error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _pushProfile(String profileId) async {
    if (!_remoteEnabled) {
      return;
    }
    try {
      final snapshotMap = _store.profileSnapshot(profileId);
      final snapshot = RemoteProfileSnapshot.fromJson(snapshotMap);
      final nextVersion = snapshot.version + 1;
      final outgoing = snapshot.copyWith(versionOverride: nextVersion);
      await _remote!.saveProfile(profileId, outgoing);
      _store.updateProfileVersion(profileId, nextVersion);
      await _store.persist();
    } catch (error, stack) {
      debugPrint('ProfileRepository push remote failed: $error');
      debugPrintStack(stackTrace: stack);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final store = ref.watch(inMemoryStoreProvider);
  final remote = ref.watch(remoteProfileApiProvider);
  return ProfileRepository(store: store, remote: remote);
});
