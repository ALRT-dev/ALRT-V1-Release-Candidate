import 'package:hazard_app/features/learn/models/guide_models.dart';

/// The three phases of a guide: Before / During / After.
enum GuidePhase {
  before,
  during,
  after;

  String get label {
    switch (this) {
      case GuidePhase.before:
        return 'Before';
      case GuidePhase.during:
        return 'During';
      case GuidePhase.after:
        return 'After';
    }
  }

  /// Returns the steps of [sections] belonging to this phase.
  List<GuideStep> stepsOf(final GuideSections sections) {
    switch (this) {
      case GuidePhase.before:
        return sections.before;
      case GuidePhase.during:
        return sections.during;
      case GuidePhase.after:
        return sections.after;
    }
  }
}
