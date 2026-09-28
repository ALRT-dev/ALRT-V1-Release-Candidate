import 'package:hazard_app/features/family/models/family_models.dart';

/// What the sender sees before holding the SOS button (master spec §12):
/// exactly who it goes to, and exactly what location they get.
class SosPreview {
  const SosPreview({required this.names, required this.live});

  /// Names of the people the SOS is addressed to, in the group it is sent
  /// from. The server may still leave out anyone who can't receive it.
  final List<String> names;
  final bool live;

  bool get isEmpty => names.isEmpty;

  /// "Alex, Morgan and Taylor" / "Alex, Morgan, Taylor and 5 others".
  String get recipientsLine {
    if (names.isEmpty) return 'No one yet';
    if (names.length == 1) return names.single;
    if (names.length <= 4) {
      return '${names.sublist(0, names.length - 1).join(', ')} and '
          '${names.last}';
    }
    final rest = names.length - 3;
    return '${names.take(3).join(', ')} and $rest others';
  }

  /// True to what the app sends: with live sharing on, a location that
  /// keeps updating; with it off, the one point taken when it is sent
  /// (when the phone has one), never updated.
  String get locationLine => live
      ? 'Your live location, updating until you end the SOS (up to 4 hours).'
      : 'Where you are when you send it, once. It won\'t update.';
}

SosPreview sosPreview({
  required final List<FamilyMember> others,
  required final FamilySosList? list,
  required final bool live,
}) {
  final chosen = list == null
      ? others
      : others.where((m) => list.memberIds.contains(m.id)).toList();
  return SosPreview(
    names: [for (final m in chosen) m.name],
    live: live,
  );
}
