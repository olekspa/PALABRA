/// Runtime configuration helpers sourced from `--dart-define` flags.
class AppConfig {
  const AppConfig._();

  /// Base URL for the optional remote profile API (e.g. `https://host/api`).
  static const String profileApiBaseUrl = String.fromEnvironment(
    'PALABRA_PROFILE_API_BASE',
  );

  /// Shared secret or token for authenticating with the remote profile API.
  static const String profileApiKey = String.fromEnvironment(
    'PALABRA_PROFILE_API_KEY',
  );

  /// Whether remote profile sync should be enabled.
  static bool get profileSyncEnabled =>
      profileApiBaseUrl.isNotEmpty && profileApiKey.isNotEmpty;
}
