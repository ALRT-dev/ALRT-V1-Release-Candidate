/// What a spoken sentence asks ALRT to do (ruling 16 Oct 2026, "one mic").
///
/// The mic in the map search bar is Speak to ALRT. It searches, answers
/// questions through Ask ALRT, and does a small fixed set of things. The
/// fixed commands are understood here, on the phone; anything else is a
/// search, or a question when it reads like one.
///
/// Rules baked in:
/// * Anything that saves, sends or checks in asks first ([needsConfirmation]).
/// * SOS is never done by voice ([VoiceCommandKind.sosRefused]).
/// * A hazard description opens Post an ALRT with the words filled in; it is
///   never posted by voice (the person still checks and posts it there).
enum VoiceCommandKind {
  search,
  ask,
  savePlace,
  sendAlert,
  checkIn,
  readAlert,
  nearMe,
  route,
  report,
  sosRefused,
}

class VoiceCommand {
  const VoiceCommand(
    this.kind, {
    required this.heard,
    this.place,
    this.alertWords,
    this.groupWords,
  });

  final VoiceCommandKind kind;

  /// The words as recognised, trimmed.
  final String heard;

  /// savePlace: the place to save. route: the destination. search: the query.
  final String? place;

  /// sendAlert / readAlert: words naming the alert ("the fire", "this").
  final String? alertWords;

  /// sendAlert: words naming the group ("my group", "the Nixon group").
  final String? groupWords;

  /// Saving, sending and checking in change something other people see or
  /// that persists; the person confirms before it happens.
  bool get needsConfirmation =>
      kind == VoiceCommandKind.savePlace ||
      kind == VoiceCommandKind.sendAlert ||
      kind == VoiceCommandKind.checkIn;

  /// Short label shown under the heard words.
  String get label => switch (kind) {
        VoiceCommandKind.search => 'Search',
        VoiceCommandKind.ask => 'A question for Ask ALRT',
        VoiceCommandKind.savePlace => 'Save a place',
        VoiceCommandKind.sendAlert => 'Send an alert to your group',
        VoiceCommandKind.checkIn => 'Check in',
        VoiceCommandKind.readAlert => 'Read an alert aloud',
        VoiceCommandKind.nearMe => 'What is near you',
        VoiceCommandKind.route => 'Check a route',
        VoiceCommandKind.report => 'Post an ALRT',
        VoiceCommandKind.sosRefused => 'SOS (not by voice)',
      };

  /// Title-cases [s] only when the recogniser gave it all in lower case, so
  /// "Perth CBD" stays as heard and "perth cbd" becomes "Perth Cbd".
  static String _cap(final String s) => s != s.toLowerCase()
      ? s
      : s
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');

  /// The words of [m]'s group [g] as they were heard (original casing).
  /// The pattern ran on the lower-cased text, which keeps ASCII lengths, so
  /// the group's offset there is its offset in [heard].
  static String _orig(final String heard, final RegExpMatch m, final int g) {
    final words = m.group(g)!;
    if (heard.length != m.input.length) return words;
    final at = m.input.indexOf(words, m.start);
    if (at < 0) return words;
    return heard.substring(at, at + words.length);
  }

  static String _stripLeading(final String s, final List<String> words) {
    var out = s.trim();
    var changed = true;
    while (changed) {
      changed = false;
      for (final w in words) {
        if (out.startsWith('$w ')) {
          out = out.substring(w.length + 1).trim();
          changed = true;
        }
      }
    }
    return out;
  }

  /// Understands [transcript]. Never throws; unknown phrasing is a search.
  static VoiceCommand parse(final String transcript) {
    final heard = transcript.trim().replaceAll(RegExp(r'[.!]+$'), '');
    final l = heard.toLowerCase();

    if (RegExp(r'\bs\.?o\.?s\b').hasMatch(l)) {
      return VoiceCommand(VoiceCommandKind.sosRefused, heard: heard);
    }

    final save = RegExp(
      r'^(?:please )?(?:save|add|remember|follow) (.+?) (?:as|to) (?:a |my |the )?(?:saved |favourite |favorite )?(?:place|places|location|locations)$',
    ).firstMatch(l);
    if (save != null) {
      final name = _stripLeading(_orig(heard, save, 1), ['my', 'the', 'My', 'The']);
      return VoiceCommand(
        VoiceCommandKind.savePlace,
        heard: heard,
        place: _cap(name),
      );
    }

    final send = RegExp(r'^(?:please )?(?:send|share|forward) (.*?) (?:to|with) (.+)$')
        .firstMatch(l);
    if (send != null &&
        (RegExp(r'\b(group|circle|family|everyone|my people)\b')
                .hasMatch(send.group(2)!) ||
            RegExp(r'\b(alert|warning|this|that|it)\b').hasMatch(send.group(1)!))) {
      final alert = _stripLeading(send.group(1)!, ['this', 'that', 'the']);
      final group = _stripLeading(send.group(2)!, ['my', 'the'])
          .replaceAll(RegExp(r'\b(group|circle|family)\b'), '')
          .trim();
      return VoiceCommand(
        VoiceCommandKind.sendAlert,
        heard: heard,
        alertWords: alert.replaceAll(RegExp(r'^(alert|warning)$'), ''),
        groupWords: group,
      );
    }

    if (RegExp(
      r"^(?:please )?check(?:ed)? ?in\b|\bi'?m (?:okay|ok|fine)\b|\bi am (?:okay|ok|fine)\b|^tell (?:my |the )?(?:group|family|circle) i",
    ).hasMatch(l)) {
      return VoiceCommand(VoiceCommandKind.checkIn, heard: heard);
    }

    final read = RegExp(r'^(?:please )?(?:read|read me|read out|read aloud|tell me about) (.+)$')
        .firstMatch(l);
    if (read != null) {
      return VoiceCommand(
        VoiceCommandKind.readAlert,
        heard: heard,
        alertWords: _stripLeading(read.group(1)!, ['me', 'out', 'the', 'this']),
      );
    }

    if (RegExp(r"near me|around me|nearby|close to me|what'?s happening|anything (?:near|around)")
        .hasMatch(l)) {
      return VoiceCommand(VoiceCommandKind.nearMe, heard: heard);
    }

    final route = RegExp(
      r'^(?:please )?(?:take me to|navigate to|directions to|route to|drive to|get me to|go to|how do i get to) (.+)$',
    ).firstMatch(l);
    if (route != null) {
      return VoiceCommand(
        VoiceCommandKind.route,
        heard: heard,
        place: _cap(_orig(heard, route, 1).replaceAll(RegExp(r'\?$'), '')),
      );
    }

    if (RegExp(r'^(what|how|why|when|where|is|are|should|can|could|do|does|will|which|who)\b')
            .hasMatch(l) ||
        heard.endsWith('?')) {
      return VoiceCommand(VoiceCommandKind.ask, heard: heard);
    }

    if (_soundsLikeReport(l)) {
      return VoiceCommand(VoiceCommandKind.report, heard: heard);
    }

    return VoiceCommand(VoiceCommandKind.search, heard: heard, place: heard);
  }

  /// First-person hazard phrasing and hazard nouns (same heuristic the map
  /// mic used before 16 Oct, so a spoken hazard still opens Post an ALRT).
  static bool _soundsLikeReport(final String lower) {
    final t = ' $lower ';
    const phrases = [
      'report', "there's a", 'there is a', 'i can see', ' i see ',
      'i want to report', 'happening on', 'happening at',
    ];
    const nouns = [
      ' fire ', ' smoke ', ' flood', ' floodwater', ' water rising',
      ' crash ', ' accident ', ' fallen tree', ' tree down',
      ' powerline', ' power line', ' power out', ' gas leak', ' spill ',
      ' storm damage', ' road blocked', ' road closed', ' hazard ',
    ];
    for (final p in phrases) {
      if (t.contains(p)) return true;
    }
    for (final n in nouns) {
      if (t.contains(n)) return true;
    }
    return false;
  }
}
