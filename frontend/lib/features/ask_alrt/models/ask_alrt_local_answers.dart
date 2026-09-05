/// Ask ALRT's on-device answer library: the basics, answered instantly with
/// no network call and no AI.
///
/// Two reasons this exists. Common questions ("how do I send an SOS", "what
/// does the orange triangle mean") have one correct answer written to the
/// product rules, and asking a model to reinvent it each time is slower and
/// less reliable. And when the assistant backend is unreachable, the app
/// should still be able to explain itself rather than shrug.
///
/// Mirrors the backend's zero-AI library so both give the same answers. The
/// wording is deliberate: nothing here promises ALRT contacts emergency
/// services, quotes a price, or states a hazard is safe.
class AskAlrtLocalAnswer {
  const AskAlrtLocalAnswer({
    required this.id,
    required this.triggers,
    required this.keywords,
    required this.answer,
  });

  /// Multi-word phrases; a substring hit is a strong signal.
  final List<String> triggers;

  /// Single words; each overlap adds a little.
  final List<String> keywords;

  final String id;
  final String answer;
}

abstract final class AskAlrtLocalAnswers {
  /// A phrase hit is worth this much; each keyword hit one point.
  static const _triggerWeight = 10;

  /// Below this we do not claim to know the answer.
  static const _minimumScore = 3;

  /// `{emergency}` is replaced with the user's resolved local number, so
  /// nothing here hard-codes 000.
  static const entries = <AskAlrtLocalAnswer>[
    AskAlrtLocalAnswer(
      id: 'what_is_alrt',
      triggers: ['what is alrt', 'what does this app do', 'how does alrt work'],
      keywords: ['about', 'alrt', 'purpose', 'app'],
      answer:
          'ALRT is a real time safety alert app. It shows official and '
          'community hazard alerts near you on a map and in a list, and it '
          'has a Family layer so your circle can share a location snapshot '
          'or reach each other in an emergency.',
    ),
    AskAlrtLocalAnswer(
      id: 'send_sos',
      triggers: ['how do i send an sos', 'send sos', 'start an sos', 'trigger sos'],
      keywords: ['sos', 'emergency', 'help'],
      answer:
          'Open the SOS screen and hold the button for 3 seconds. You get a '
          'confirm screen showing exactly who will be alerted, a countdown, '
          'and an undo after it sends. SOS alerts the people in your circle. '
          'It does not contact emergency services: for that, call {emergency}.',
    ),
    AskAlrtLocalAnswer(
      id: 'shapes',
      triggers: [
        'what do the shapes mean',
        'what does the triangle mean',
        'what does the diamond mean',
        'what does the circle mean',
        'what does the shield mean',
        'what does the square mean',
      ],
      keywords: [
        'shape', 'shapes', 'triangle', 'diamond', 'circle', 'shield',
        'square', 'symbol', 'icon',
      ],
      answer:
          'The shape tells you who issued the alert. Triangle: an AWS '
          'warning, the only source that states a level in words (Advice, '
          'Watch and Act, Emergency Warning). Diamond: an official agency. '
          'Rounded square: a global humanitarian feed, carrying that '
          "source's own scale. Circle: an unverified community report. "
          "Shield: ALRT's own assessment. The full key is on the map under "
          'the layers button.',
    ),
    AskAlrtLocalAnswer(
      id: 'colours',
      triggers: [
        'what do the colours mean',
        'what do the colors mean',
        'what does red mean',
        'what does orange mean',
        'severity levels',
      ],
      keywords: [
        'colour', 'color', 'red', 'orange', 'yellow', 'grey', 'band',
        'severity', 'urgent', 'critical',
      ],
      answer:
          'Colour tells you how urgent an alert is. Grey is Info, awareness '
          'only. Yellow is Monitor. Orange is Action. Red is Critical, the '
          'highest level. Community reports are the exception: their circle '
          'wears the category colour, not an urgency colour.',
    ),
    AskAlrtLocalAnswer(
      id: 'aws_levels',
      triggers: [
        'what is aws',
        'what is watch and act',
        'what is an emergency warning',
        'australian warning system',
      ],
      keywords: ['aws', 'advice', 'watch', 'act', 'warning', 'level'],
      answer:
          'AWS is the Australian Warning System, a three level scale. '
          'Advice: an incident is happening, stay informed. Watch and Act: '
          'conditions are changing, take action to protect yourself. '
          'Emergency Warning: the highest level, act immediately. In ALRT '
          'these are triangles, and they are the only alerts that write '
          'their level in words.',
    ),
    AskAlrtLocalAnswer(
      id: 'community_reports',
      triggers: [
        'can i trust community reports',
        'what is a community report',
        'unverified alert',
      ],
      keywords: ['community', 'report', 'unverified', 'trust', 'confirm'],
      answer:
          'A community report (a circle on the map) is posted by a person '
          'nearby and is unverified. Others can confirm or dispute it. '
          'Treat it as a heads-up, not an official warning, and check '
          'official alerts for the confirmed picture. You can post one '
          'yourself from the ALRT button in the footer.',
    ),
    AskAlrtLocalAnswer(
      id: 'tracking',
      triggers: [
        'do you track me',
        'are you tracking my location',
        'is my location shared',
        'continuous tracking',
      ],
      keywords: ['track', 'tracking', 'location', 'privacy', 'continuous'],
      answer:
          'Location is shared only when someone chooses it—for a one-time '
          'snapshot, an active SOS, or an active journey. Snapshots are '
          'one moment and expire after an hour. SOS live sharing stops '
          'after 4 hours at the latest and the trail is deleted when you '
          'stand down. Live sharing can be stopped at any time.',
    ),
    AskAlrtLocalAnswer(
      id: 'snapshot',
      triggers: [
        'what is a snapshot',
        'location snapshot',
        'how do i share my location',
        'request a location',
      ],
      keywords: ['snapshot', 'share', 'request', 'location'],
      answer:
          'A snapshot is one location, sent on purpose. Someone in your '
          'circle can ask for it, and you choose whether to send it: '
          'declining sends nothing and does not tell them. Snapshots expire '
          'after an hour, and the coordinates are deleted, not hidden.',
    ),
    AskAlrtLocalAnswer(
      id: 'family_groups',
      triggers: [
        'how do i join a group',
        'how do i create a group',
        'invite code',
        'family circle',
        'can i be in more than one group',
      ],
      keywords: ['family', 'group', 'circle', 'join', 'invite', 'code'],
      answer:
          'Joining with an invite code is always free, and you can be in as '
          'many groups as you like. Creating a group you host is the ALRT+ '
          'subscription: 8 seats to split across up to 4 groups you host. '
          'People who join someone else\'s group spend nothing of their own.',
    ),
    AskAlrtLocalAnswer(
      id: 'pricing',
      triggers: ['how much does it cost', 'is it free', 'what is alrt plus'],
      keywords: ['cost', 'price', 'free', 'pay', 'subscription', 'plus'],
      answer:
          'Alerts, the live map and emergency call guidance are always '
          'free. ALRT+ is only needed to host a family group. Current '
          'prices are shown on the ALRT+ screen in the app, straight from '
          'the store.',
    ),
    AskAlrtLocalAnswer(
      id: 'emergency',
      triggers: [
        'call emergency services',
        'do you call the police',
        'do you contact emergency services',
        'what number do i call',
      ],
      keywords: ['emergency', 'police', 'ambulance', 'fire', 'call', 'number'],
      answer:
          'ALRT never contacts emergency services for you. If you are in '
          'danger, call {emergency} now. Every alert carries a call button '
          'so the number is always one tap away.',
    ),
  ];

  /// The best local answer for [question], or null when nothing scores
  /// highly enough. Saying nothing beats answering the wrong question.
  static String? answerFor(
    final String question, {
    required final String emergencyNumber,
  }) {
    final q = question.toLowerCase().trim();
    if (q.isEmpty) return null;

    final words = q.split(RegExp(r'[^a-z0-9]+')).where((w) => w.length > 2);

    AskAlrtLocalAnswer? best;
    var bestScore = 0;
    for (final entry in entries) {
      var score = 0;
      for (final trigger in entry.triggers) {
        if (q.contains(trigger)) score += _triggerWeight;
      }
      for (final word in words) {
        if (entry.keywords.contains(word)) score += 1;
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore < _minimumScore) return null;
    return best.answer.replaceAll('{emergency}', emergencyNumber);
  }
}
