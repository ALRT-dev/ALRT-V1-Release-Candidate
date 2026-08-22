import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/enums/ai_confidence_types.dart';
import 'package:hazard_app/features/shared/converters/date_time_converter.dart';
import 'package:hazard_app/features/shared/enums/category_image_type.dart';
import 'package:hazard_app/features/shared/enums/fire_status_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/category_image_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/models/s3_media_model.dart';

part 'hazard_model.freezed.dart';
part 'hazard_model.g.dart';

@freezed
abstract class Hazard with _$Hazard {
  const Hazard._();

  const factory Hazard({
    /// The id of the hazard.
    final String? id,

    /// The title of the hazard.
    final String? title,

    /// The detailed description of the hazard.
    final String? description,

    /// The severity level of the hazard as per user input or source.
    final HazardSeverity? severity,

    /// The severity band of the hazard.
    final HazardSeverityBand? severityBand,

    /// The latitude of the hazard location.
    final double? latitude,

    /// The longitude of the hazard location.
    final double? longitude,

    /// The human-readable name of the hazard location.
    final String? locationName,

    /// The north-east latitude of the hazard bounding box.
    final double? northeastLat,

    /// The north-east longitude of the hazard bounding box.
    final double? northeastLng,

    /// The south-west latitude of the hazard bounding box.
    final double? southwestLat,

    /// The south-west longitude of the hazard bounding box.
    final double? southwestLng,

    /// The id of the category the hazard belongs to.
    final String? categoryId,

    /// The category the hazard belongs to.
    final HazardCategory? category,

    /// The fire status of the hazard (if applicable).
    ///
    /// If the hazard is not a fire-related hazard, this will be null.
    final FireStatus? fireStatus,

    /// The source details of the hazard.
    final HazardSource? source,

    /// The AI-generated summary of the hazard.
    final String? aiSummary,

    /// The AI-determined confidence level of the hazard.
    final AIConfidence? aiConfidence,

    /// The things users can do to mitigate the hazard.
    final List<String>? callsToAction,

    /// Indicates whether the hazard follows AWS standards.
    final bool? isAwsCompliant,

    /// The user who reported the hazard.
    ///
    /// If source is provided, this may be null.
    final AppUser? reportedBy,

    /// The status of the hazard review.
    final HazardReviewStatus? reviewStatus,

    /// The feedback provided during the review of the hazard.
    final String? reviewFeedback,

    /// The id of the user who reviewed the hazard.
    ///
    /// If AI reviewed the hazard, this will be "ai",
    final String? reviewedById,

    /// The date and time when the hazard was reviewed.
    @DateTimeConverter() final DateTime? reviewedAt,

    /// The vote type (upvote or downvote) by the current user.
    final HazardVoteType? userVoteType,

    /// The total number of upvotes for the hazard.
    @Default(0) final int upvoteCount,

    /// The total number of downvotes for the hazard.
    @Default(0) final int downvoteCount,

    /// The confidence score of the hazard (from 0 to 100) to be used in the sorting order.
    final int? confidenceScore,

    /// The list of media files associated with the hazard.
    @Default(<S3Media>[]) final List<S3Media> medias,

    /// The list of medias that have been processed and are ready for displaying to the UI.
    ///
    /// This field is not included in JSON serialization/deserialization and is generated using [medias].
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<AlrtMedia>[])
    final List<AlrtMedia> processedMedias,

    /// The external link related to the hazard for more information.
    final String? link,

    /// The date and time when the hazard occurred.
    @DateTimeConverter() final DateTime? occurredAt,

    /// The date and time when the hazard was reported.
    @DateTimeConverter() final DateTime? createdAt,

    /// The date and time when the hazard was last updated.
    @DateTimeConverter() final DateTime? updatedAt,

    /// The date and time when the hazard expires.
    @DateTimeConverter() final DateTime? expiresAt,
  }) = _Hazard;

  /// The net vote count (upvotes - downvotes) for the hazard.
  int get voteCount => upvoteCount - downvoteCount;

  /// Indicates whether the hazard was reported by a user.
  bool get isUserReported => reportedBy != null;

  /// The backend source ids publishing GLOBAL HUMANITARIAN events: disasters
  /// rated for international humanitarian response, not Australian agency
  /// warnings. Today that is GDACS, whose scale (Red/Orange/Green) describes
  /// the likelihood of international aid, never personal danger, so it is
  /// carried verbatim and never mapped onto an AWS level word.
  ///
  /// This system may be retired later. Everything that makes the square
  /// exist hangs off this one set and [isGlobalHumanitarian] — empty the set
  /// and the shape stops being produced everywhere at once.
  static const globalHumanitarianSourceIds = {'gdacsGlobal'};

  /// Whether this alert came from a global humanitarian feed (the square).
  bool get isGlobalHumanitarian {
    final id = source?.id;
    return id != null && globalHumanitarianSourceIds.contains(id);
  }

  /// ALRT's own assessment: the shield.
  ///
  /// Driven entirely by the source registry the backend already keeps, so
  /// publishing intel is a matter of giving the source `shape: shield` in
  /// the admin portal, with nothing to change in the app. The shield never
  /// writes a band word and never restates or overrides an official
  /// warning; like every other shape it takes the band hexes.
  bool get isAlrtIntel => source?.shape == HazardSourceShape.shield;

  /// Indicates whether the hazard has expired based on the current date and time.
  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Gets the appropriate BitmapDescriptor for the hazard marker.
  BitmapDescriptor? getMarkerBitmapDescriptor(
    Map<String, BitmapDescriptor> bitmapMap,
  ) {
    if (isUserReported) {
      return bitmapMap['${categoryId}_user'];
    }

    if (fireStatus != null && isAwsCompliant == false) {
      final fireKey = '${categoryId}_fireStatus_${fireStatus!.name}';
      final fireBitmap = bitmapMap[fireKey];
      if (fireBitmap != null) {
        return fireBitmap;
      }
    }

    final severityBandName = severityBand?.name ?? HazardSeverityBand.info.name;
    var severityKey =
        '${categoryId}_$severityBandName${isAwsCompliant == true ? '_aws' : '_non_aws'}';

    return bitmapMap[severityKey];
  }

  /// The color associated with the hazard's severity band.
  Color get color {
    // If the hazard is user-reported, use the user report status color
    if (isUserReported) {
      final reportsStatus = reportedBy!.reportsStatus;
      return reportsStatus.color;
    }

    // If the hazard follows AWS standards, use AWS colors
    if (isAwsCompliant == true) {
      return severityBand?.colorAws ?? HazardSeverityBand.info.colorAws;
    }

    // Otherwise, use non-AWS colors
    return severityBand?.colorNonAws ?? HazardSeverityBand.info.colorNonAws;
  }

  /// The title associated with the hazard's severity.
  String get severityTitle {
    if (isAwsCompliant == true) {
      return severity?.titleAws ?? HazardSeverity.info.titleAws;
    }
    return severity?.titleNonAws ?? HazardSeverity.info.titleNonAws;
  }

  /// The category image type of the hazard based on the severity and AWS compliance.
  CategoryImageType get categoryImageType {
    if (isUserReported) {
      return CategoryImageType.user;
    }

    if (fireStatus != null && isAwsCompliant == false) {
      final firestatus = switch (fireStatus!) {
        FireStatus.active => CategoryImageType.fireActive,
        FireStatus.beingControlled => CategoryImageType.fireBeingControlled,
        FireStatus.underControl => CategoryImageType.fireUnderControl,
        FireStatus.closed => CategoryImageType.fireClosed,
      };
      final hasImage = category?.categoryImageByType(firestatus) != null;
      if (hasImage) {
        return firestatus;
      }
    }

    if (isAwsCompliant == true) {
      return switch (severityBand) {
        HazardSeverityBand.info => CategoryImageType.advice,
        HazardSeverityBand.monitor => CategoryImageType.advice,
        HazardSeverityBand.action => CategoryImageType.watchAndAct,
        HazardSeverityBand.critical => CategoryImageType.emergency,
        _ => CategoryImageType.info,
      };
    }

    return switch (severityBand) {
      HazardSeverityBand.info => CategoryImageType.info,
      HazardSeverityBand.monitor => CategoryImageType.monitor,
      HazardSeverityBand.action => CategoryImageType.action,
      HazardSeverityBand.critical => CategoryImageType.critical,
      _ => CategoryImageType.info,
    };
  }

  /// The category image of the hazard.
  CategoryImage? get categoryImage =>
      category?.categoryImageByType(categoryImageType);

  /// The fallback icon path for the hazard.
  String get fallbackIconPath {
    if (isAwsCompliant == true) {
      return 'assets/images/hazards/aws/other_${severityBand?.name ?? HazardSeverityBand.info.name}.png';
    }
    return 'assets/images/hazards/non_aws/other_${severityBand?.name ?? HazardSeverityBand.info.name}.png';
  }

  factory Hazard.fromJson(Map<String, dynamic> json) => _$HazardFromJson(json);
}
