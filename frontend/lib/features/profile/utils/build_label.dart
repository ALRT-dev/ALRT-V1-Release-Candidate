/// The one line that tells a tester which build is on the phone.
///
/// Android's app info shows only the version name ("1.0.5"), which every
/// TEST build shares, so the build number has to be visible in the app
/// itself. "TEST build" marks the dev flavour; the production flavour
/// shows the version alone.
String buildLabel({
  required final String version,
  required final String buildNumber,
  required final String? flavor,
}) {
  final base =
      buildNumber.isEmpty ? 'ALRT $version' : 'ALRT $version ($buildNumber)';
  return flavor == 'dev' ? '$base · TEST build' : base;
}
