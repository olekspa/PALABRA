// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RemoteProfileSummary {
  RemoteProfileSummary({
    required this.id,
    required this.displayName,
    required this.version,
    this.lastSeenAt,
    this.level,
    this.totalRuns,
  });

  factory RemoteProfileSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return RemoteProfileSummary(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Player',
      version: json['version'] as int? ?? 0,
      lastSeenAt: parseTimestamp(json['lastSeenAt']),
      level: json['level'] as String?,
      totalRuns: json['totalRuns'] as int?,
    );
  }

  final String id;
  final String displayName;
  final int version;
  final DateTime? lastSeenAt;
  final String? level;
  final int? totalRuns;
}

class RemoteProfileSnapshot {
  RemoteProfileSnapshot({
    required this.meta,
    required this.userStates,
    required this.runLogs,
    required this.attemptLogs,
    required this.version,
  });

  factory RemoteProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return RemoteProfileSnapshot(
      meta: Map<String, dynamic>.from(
        (json['meta'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
      userStates: Map<String, dynamic>.from(
        (json['userStates'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      runLogs: (json['runLogs'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          <Map<String, dynamic>>[],
      attemptLogs: (json['attemptLogs'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          <Map<String, dynamic>>[],
      version: json['version'] as int? ?? 0,
    );
  }

  final Map<String, dynamic> meta;
  final Map<String, dynamic> userStates;
  final List<Map<String, dynamic>> runLogs;
  final List<Map<String, dynamic>> attemptLogs;
  final int version;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'meta': meta,
      'userStates': userStates,
      'runLogs': runLogs,
      'attemptLogs': attemptLogs,
      'version': version,
    };
  }

  RemoteProfileSnapshot copyWith({int? versionOverride}) {
    return RemoteProfileSnapshot(
      meta: Map<String, dynamic>.from(meta),
      userStates: Map<String, dynamic>.from(userStates),
      runLogs: runLogs.map((e) => Map<String, dynamic>.from(e)).toList(),
      attemptLogs: attemptLogs
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      version: versionOverride ?? version,
    );
  }
}

class RemoteProfileApi {
  RemoteProfileApi({
    required String baseUrl,
    required String apiKey,
    http.Client? client,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _apiKey = apiKey,
       _client = client ?? http.Client();

  final String _baseUrl;
  final String _apiKey;
  final http.Client _client;

  bool get isConfigured => _baseUrl.isNotEmpty && _apiKey.isNotEmpty;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    'X-Palabra-Key': _apiKey,
  };

  Future<List<RemoteProfileSummary>> listProfiles() async {
    final response = await _client.get(
      _uri('/profiles'),
      headers: _headers,
    );
    _ensureSuccess(response);
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => RemoteProfileSummary.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }
    return <RemoteProfileSummary>[];
  }

  Future<RemoteProfileSummary> createProfile(String displayName) async {
    final response = await _client.post(
      _uri('/profiles'),
      headers: _headers,
      body: json.encode(<String, dynamic>{'displayName': displayName}),
    );
    _ensureSuccess(response);
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return RemoteProfileSummary.fromJson(decoded);
  }

  Future<RemoteProfileSnapshot> fetchProfile(String profileId) async {
    final response = await _client.get(
      _uri('/profiles/$profileId'),
      headers: _headers,
    );
    _ensureSuccess(response);
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return RemoteProfileSnapshot.fromJson(decoded);
  }

  Future<void> saveProfile(
    String profileId,
    RemoteProfileSnapshot snapshot,
  ) async {
    final response = await _client.put(
      _uri('/profiles/$profileId'),
      headers: _headers,
      body: json.encode(snapshot.toJson()),
    );
    _ensureSuccess(response);
  }

  Future<void> deleteProfile(String profileId) async {
    final response = await _client.delete(
      _uri('/profiles/$profileId'),
      headers: _headers,
    );
    _ensureSuccess(response);
  }

  void dispose() {
    _client.close();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    if (kDebugMode) {
      debugPrint(
        'RemoteProfileApi error ${response.statusCode}: ${response.body}',
      );
    }
    throw HttpException(response.statusCode, response.body);
  }
}

class HttpException implements Exception {
  HttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HttpException($statusCode): $body';
}
