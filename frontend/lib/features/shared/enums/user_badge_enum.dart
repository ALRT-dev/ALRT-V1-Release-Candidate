enum UserBadge {
  watcher,
  scout,
  guardian;

  /// Returns the title of the user badge.
  String get title {
    return switch (this) {
      UserBadge.watcher => 'Watcher',
      UserBadge.scout => 'Scout',
      UserBadge.guardian => 'Guardian',
    };
  }

  /// Returns the next user badge.
  UserBadge get nextBadge {
    return UserBadge.values[(index + 1).clamp(
      0,
      UserBadge.values.length - 1,
    )];
  }

  /// Returns the required XP points to achieve the user badge.
  int get requiredXpPoints {
    return switch (this) {
      UserBadge.watcher => 0,
      UserBadge.scout => 750,
      UserBadge.guardian => 1500,
    };
  }

  /// The tier [xp] has reached. Derived from the same number the bar
  /// draws, so the tier and the bar can never disagree.
  static UserBadge forXp(final int xp) {
    var badge = UserBadge.watcher;
    for (final candidate in UserBadge.values) {
      if (xp >= candidate.requiredXpPoints) badge = candidate;
    }
    return badge;
  }
}
