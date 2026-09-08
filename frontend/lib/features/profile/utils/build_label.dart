/// The one line that tells a tester which build is on the phone.
///
/// Android's app info shows only the version name ("1.0.5"), which every
/// TEST build shares, so the build number, the commit it was built from
/// and the billing mode have to be visible in the app itself. The commit
/// and billing mode arrive as --dart-define values from the build
/// workflow (ALRT_BUILD_COMMIT, ALRT_BILLING_MODE); a local build without
/// them shows only what it knows.
String buildLabel({
  required final String version,
  required final String buildNumber,
  required final String? flavor,
  final String commit = '',
  final String billingMode = '',
}) {
  final parts = <String>[
    buildNumber.isEmpty ? 'ALRT $version' : 'ALRT $version ($buildNumber)',
    if (flavor == 'dev') 'TEST build',
    if (commit.isNotEmpty) commit,
    if (billingMode.isNotEmpty) billingMode,
  ];
  return parts.join(' · ');
}

/// What the workflow passed in, if anything.
const kBuildCommit = String.fromEnvironment('ALRT_BUILD_COMMIT');
const kBuildBillingMode = String.fromEnvironment('ALRT_BILLING_MODE');

/// Human wording for the billing mode: what the workflow declared, else
/// what the running app can tell from its own configuration.
String billingModeLabel({
  required final bool testUnlocked,
  required final bool hasStoreKey,
}) {
  if (kBuildBillingMode == 'bypass' || testUnlocked) return 'billing bypass';
  if (kBuildBillingMode == 'test_store') return 'RevenueCat Test Store';
  return hasStoreKey ? 'store billing' : 'no billing key';
}
