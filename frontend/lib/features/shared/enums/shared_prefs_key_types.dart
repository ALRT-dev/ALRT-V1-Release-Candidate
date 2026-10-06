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
}
