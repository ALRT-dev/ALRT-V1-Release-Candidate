/// The lowest app version one platform still supports, from the public
/// GET /api/app/version-policy:
/// `{"ios": {"minVersion": "1.4.0", "minBuild": 52, "storeUrl": "..."},
///   "android": {...}}`. Every field may be null (no minimum set).
class PlatformVersionPolicy {
  const PlatformVersionPolicy({this.minVersion, this.minBuild, this.storeUrl});

  /// Null or malformed input reads as "no minimum".
  factory PlatformVersionPolicy.fromJson(final Object? json) {
    if (json is! Map) return const PlatformVersionPolicy();
    final version = json['minVersion'];
    final build = json['minBuild'];
    final url = json['storeUrl'];
    return PlatformVersionPolicy(
      minVersion: version is String && version.trim().isNotEmpty
          ? version.trim()
          : null,
      minBuild: build is int
          ? build
          : build is num
          ? build.toInt()
          : build is String
          ? int.tryParse(build.trim())
          : null,
      storeUrl: url is String && url.trim().isNotEmpty ? url.trim() : null,
    );
  }

  final String? minVersion;
  final int? minBuild;
  final String? storeUrl;
}

/// The policy for one platform out of the whole response ("ios" or
/// "android"); a missing platform means no minimum.
PlatformVersionPolicy policyForPlatform(
  final Object? json, {
  required final bool isIOS,
}) {
  if (json is! Map) return const PlatformVersionPolicy();
  return PlatformVersionPolicy.fromJson(json[isIOS ? 'ios' : 'android']);
}

/// Parses "x.y.z" (also "x.y", "x", and tolerates a "-beta" or "+45"
/// suffix) into three numbers. Null when it isn't a version at all.
List<int>? parseSemver(final String? version) {
  if (version == null) return null;
  final core = version.trim().split(RegExp(r'[+\-\s]')).first;
  if (core.isEmpty) return null;
  final parts = core.split('.');
  if (parts.length > 3) return null;
  final numbers = <int>[];
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0) return null;
    numbers.add(n);
  }
  while (numbers.length < 3) {
    numbers.add(0);
  }
  return numbers;
}

/// Compares two x.y.z versions: negative when [a] is older than [b], zero
/// when equal, positive when newer. Null when either can't be read.
int? compareSemver(final String a, final String b) {
  final left = parseSemver(a);
  final right = parseSemver(b);
  if (left == null || right == null) return null;
  for (var i = 0; i < 3; i++) {
    final diff = left[i] - right[i];
    if (diff != 0) return diff;
  }
  return 0;
}

/// Whether the installed app ([version], [buildNumber] from
/// package_info_plus) is below [policy]'s minimum. Semantic version first;
/// the build number only decides when the versions are equal (or when the
/// policy names a build and no version). Anything unreadable on either
/// side is never a reason to block the app.
bool isUpdateRequired({
  required final String version,
  required final String buildNumber,
  required final PlatformVersionPolicy policy,
}) {
  final minVersion = policy.minVersion;
  final minBuild = policy.minBuild;
  final build = int.tryParse(buildNumber.trim());

  if (minVersion != null) {
    final cmp = compareSemver(version, minVersion);
    if (cmp == null) return false;
    if (cmp < 0) return true;
    if (cmp > 0) return false;
  }
  if (minBuild != null && build != null) return build < minBuild;
  return false;
}
