/// Family invite codes as the backend mints them (family.service.ts
/// generateInviteCode): `ALRT-` followed by five characters from an
/// alphabet that leaves out 0/O/1/I/L so a code can be read aloud or off a
/// QR without ambiguity.
///
/// Pure and unit-tested (invite_code_parse_test.dart). Used by the QR
/// scanner to decide whether what it just read is an invite code at all,
/// and by manual entry to normalise what someone typed, so both paths hand
/// the unchanged join flow the same canonical string.
const String inviteCodeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

final RegExp _canonicalInviteCode = RegExp('^ALRT-[$inviteCodeAlphabet]{5}\$');

/// Returns the canonical `ALRT-XXXXX` form of [raw], or null when [raw] is
/// not an invite code.
///
/// Forgiving about what people (and cameras) produce: surrounding
/// whitespace, lower case, a missing `ALRT-` prefix, or a stray space or
/// dash inside the code are all normalised. Anything else - a URL, another
/// app's QR, a code with a character outside the alphabet, the wrong
/// length - is rejected rather than sent to the server.
String? parseInviteCode(final String raw) {
  var value = raw.trim().toUpperCase();
  if (value.isEmpty) return null;

  // Drop any whitespace and dashes people add when reading a code out.
  value = value.replaceAll(RegExp(r'[\s\-]'), '');
  if (value.startsWith('ALRT')) value = value.substring(4);
  if (value.length != 5) return null;

  final canonical = 'ALRT-$value';
  return _canonicalInviteCode.hasMatch(canonical) ? canonical : null;
}
