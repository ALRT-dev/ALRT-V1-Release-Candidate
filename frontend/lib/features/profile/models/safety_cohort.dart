import 'dart:ui';

/// The nine For You cohorts (For You Cohort Layer v2.1).
///
/// Coarse categories only — no free text, no diagnoses; `medical` stays
/// deliberately broad. Each cohort's tint is its permanent identity and never
/// varies by line, card or hazard. Ticked cohorts are stored ON DEVICE ONLY
/// and never leave the phone.
enum SafetyCohort {
  older('older', 'Older adult', Color(0xFFEAF1E4), Color(0xFF4A6B35)),
  kids('kids', 'Children in my care', Color(0xFFFFF0E0), Color(0xFFB05A10)),
  mobility(
    'mobility',
    'Mobility or disability needs',
    Color(0xFFE4EEF5),
    Color(0xFF2E5E80),
  ),
  medical('medical', 'Medical condition', Color(0xFFF3ECFB), Color(0xFF6B3FA0)),
  deaf('deaf', 'Deaf or hard of hearing', Color(0xFFFDF2DC), Color(0xFF9A6B15)),
  vision('vision', 'Vision impairment', Color(0xFFE2F2EF), Color(0xFF1F6E60)),
  visitor('visitor', 'Visiting Australia', Color(0xFFFFE9F1), Color(0xFFA83A66)),
  worker('worker', 'Essential worker', Color(0xFFE9EDF6), Color(0xFF3D5382)),
  pets('pets', 'Pets or livestock', Color(0xFFEFE7DE), Color(0xFF7A5A3A));

  const SafetyCohort(this.id, this.label, this.tintBg, this.tintInk);

  /// Stable id used as the on-device storage key and content-row key.
  final String id;

  /// The user-facing chip label.
  final String label;

  /// The cohort's permanent background tint.
  final Color tintBg;

  /// The cohort's permanent ink (text) colour.
  final Color tintInk;
}
