import 'package:flutter_riverpod/legacy.dart';

/// Provider to manage the current index of the hazard medias carousel.
final providerOfHazardMediasCarouselIndex = StateProvider.family<int, String>(
  (ref, id) => 0,
);
