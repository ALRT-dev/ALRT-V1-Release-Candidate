/// Presentation segments for an attributed agency instruction.
class AttributedActionParts {
  const AttributedActionParts(this.attribution, this.lead, this.remainder);
  final String attribution;
  final String lead;
  final String remainder;
}

AttributedActionParts? attributedActionParts(String action) {
  final match = RegExp(r'^.{1,60}? advises:\s*').firstMatch(action);
  if (match == null) return null;
  final attribution = action.substring(0, match.end);
  final directive = action.substring(match.end);
  // Keep conditional wording equally prominent. This is presentation only;
  // never move a directive ahead of its condition or infer an instruction.
  if (RegExp(
    r'\b(if|unless|until|when|only|except|otherwise|provided)\b',
    caseSensitive: false,
  ).hasMatch(directive)) {
    return AttributedActionParts(attribution, '', directive);
  }
  final words = RegExp(r'\S+').allMatches(directive).take(6).toList();
  if (words.isEmpty) return AttributedActionParts(attribution, '', directive);
  var end = words.last.end;
  final punctuation = RegExp(r'[,;:.](?=\s|$)').firstMatch(directive);
  if (punctuation != null && punctuation.end < end) end = punctuation.end;
  // Every segment is a slice of the original, including punctuation,
  // whitespace and newlines. Concatenating them must reproduce the source.
  return AttributedActionParts(
    attribution,
    directive.substring(0, end),
    directive.substring(end),
  );
}
