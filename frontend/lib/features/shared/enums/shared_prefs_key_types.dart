enum SharedPrefsKey {
  /// The key for storing the authentication method used to login.
  authMethod,

  /// The key for the access token.
  accessToken,

  /// The key for the refresh token.
  refreshToken,

  /// The key for storing whether the video is muted.
  isVideoMuted,

  /// Millis timestamp of the last "Maybe later" on the notification priming
  /// screen — used to snooze the re-ask.
  notificationPrimingSnoozedAt,

  /// Millis timestamp of the last in-app review ask, so we never nag.
  reviewLastAskedAt,

  /// The API base URL the running flavour resolved at start-up, kept so
  /// the background notification-action isolate (which has no Riverpod
  /// and no loaded .env) can reach the same backend.
  apiBaseUrl,

  /// Check-in request ids already answered from a notification action, so
  /// a second tap on the same request (phone or watch) sends nothing.
  wearableAnsweredRequestIds,
}
