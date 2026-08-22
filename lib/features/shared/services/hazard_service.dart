import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/category_image_type.dart';
import 'package:hazard_app/features/shared/enums/fire_status_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/category_image_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/get_hazards_with_subscription_id_reponse.dart';
import 'package:hazard_app/features/shared/models/view_hazard_response_model.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/repositories/hazard_repository.dart';
import 'package:hazard_app/features/shared/services/cache_manager_service.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/shared/utils/hazard_util.dart';

/// Limits concurrent async tasks to prevent network/socket saturation.
class _ConcurrencyPool {
  _ConcurrencyPool(this.maxConcurrent);
  final int maxConcurrent;
  int _active = 0;
  final _waiting = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= maxConcurrent) {
      final completer = Completer<void>();
      _waiting.add(completer);
      await completer.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_waiting.isNotEmpty) {
        _waiting.removeAt(0).complete();
      }
    }
  }
}

class HazardService {
  HazardService(final Ref ref) : _ref = ref;

  /// No auth interceptors — presigned image URLs must not receive API headers.
  static final Dio _markerImageDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
      validateStatus: (final status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  static final _downloadPool = _ConcurrencyPool(30);

  final Ref _ref;
  HazardRepository get _hazardRepository =>
      _ref.read(providerOfHazardRepository);
  MediaService get _mediaService => _ref.read(providerOfMediaService);
  CacheManagerService get _cacheManagerService =>
      _ref.read(providerOfCacheManagerService);

  /// Caches in-flight URL downloads so the same image is fetched only once.
  final _urlBytesCache = <String, Future<Uint8List?>>{};

  /// Caches asset-based fallback bitmaps to avoid redundant disk I/O.
  final _assetBitmapCache = <String, Future<BitmapDescriptor>>{};

  /// Caches network BitmapDescriptors by s3Key+size to deduplicate identical images.
  final _bitmapByS3KeyCache = <String, Future<BitmapDescriptor?>>{};

  /// Fetches the list of hazards from the server.
  Future<Either<List<Hazard>, AppError>> getHazards({
    required final HazardSearchParams searchParams,
    final CancelToken? cancelToken,
  }) async {
    final result = await _hazardRepository.getHazards(
      searchParams: searchParams,
      cancelToken: cancelToken,
    );

    final success = await result.whenSuccess(
      populateHazardsWithRequiredData,
    );

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Fetches all hazards from the server by making multiple parallel requests.
  Future<Either<List<Hazard>, AppError>> getAllHazards({
    final int numberOfParallelRequests = 10,
    required final HazardSearchParams searchParams,
    final bool allowEmptyCategoryIds = false,
    final bool allowAllSourceFiltersFalse = false,
    final CancelToken? cancelToken,
  }) async {
    // If no category IDs are provided, return an empty list immediately.
    if (searchParams.categoryIds.isEmpty && !allowEmptyCategoryIds) {
      return Success(<Hazard>[]);
    }

    // If all hazard source filters are false, return an empty list immediately.
    if (!searchParams.awsEmergency &&
        !searchParams.awsWatchAndAct &&
        !searchParams.awsAdvice &&
        !searchParams.officialNonAws &&
        !searchParams.userReported &&
        !allowAllSourceFiltersFalse) {
      return Success(<Hazard>[]);
    }

    final allHazards = <Hazard>[];
    final pageSize = searchParams.pageSize;
    int currentPage = searchParams.page;
    bool hasMoreData = true;

    while (hasMoreData) {
      final batchFutures = <Future<Either<List<Hazard>, AppError>>>[];

      // Create parallel requests for the current batch of pages
      for (int i = 0; i < numberOfParallelRequests; i++) {
        final pageSearchParams = searchParams.copyWith(
          page: currentPage + i,
        );

        batchFutures.add(
          getHazards(
            searchParams: pageSearchParams,
            cancelToken: cancelToken,
          ),
        );
      }

      // Wait for this batch to complete
      final batchResults = await Future.wait(batchFutures);

      // Process batch results
      bool hasDataInThisBatch = false;
      for (final result in batchResults) {
        final error = result.when(
          (hazards) {
            if (hazards.isNotEmpty) {
              allHazards.addAll(hazards);
              hasDataInThisBatch = true;

              // If this page has fewer items than page size, it's the last page
              if (hazards.length < pageSize) {
                hasMoreData = false;
              }
            }
            return null; // Success case
          },
          (error) => error, // Return error
        );

        // If any request fails, return the error
        if (error != null) {
          return Failure(error);
        }
      }

      // If no data was found in any of the parallel requests, we're done
      if (!hasDataInThisBatch) {
        hasMoreData = false;
      }

      // Move to the next batch of pages
      currentPage += numberOfParallelRequests;
    }

    // Return the combined list of all hazards
    return Success(
      HazardUtil.sortHazards(
        allHazards,
        searchParams.sortSettings,
      ),
    );
  }

  /// Fetches hazards along with subscription ID from the server.
  Future<Either<GetHazardsWithSubscriptionIdResponse, AppError>>
  getHazardsWithSubscriptionId({
    required final HazardSearchParams searchParams,
  }) async {
    final result = await _hazardRepository.getGetHazardsWithSubscriptionId(
      searchParams: searchParams,
    );

    final success = await result.whenSuccess((response) async {
      final populatedHazards = await populateHazardsWithRequiredData(
        response.hazards,
      );
      return response.copyWith(
        hazards: populatedHazards,
      );
    });

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Fetches the list of hazard categories from the server including parent and sub-categories.
  Future<Either<List<HazardCategory>, AppError>> getAllHazardCategories() {
    return _hazardRepository.getAllHazardCategories();
  }

  /// Fetches the list of parent hazard categories from the server.
  Future<Either<List<HazardCategory>, AppError>>
  getAllParentHazardCategories() {
    return _hazardRepository.getAllParentHazardCategories();
  }

  /// Fetches the list of sub hazard categories from the server.
  Future<Either<List<HazardCategory>, AppError>> getAllSubHazardCategories() {
    return _hazardRepository.getAllSubHazardCategories();
  }

  /// Creates a new hazard report on the server.
  Future<Either<Hazard, AppError>> createHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
  }) async {
    final result = await _hazardRepository.createHazardReport(
      hazard: hazard,
      mediaFiles: mediaFiles,
    );

    final success = await result.whenSuccess(
      populateHazardWithRequiredData,
    );

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Updates an existing hazard report on the server.
  ///
  /// The [hazard] must have a valid [id] to identify which report to update.
  ///
  /// The [removedMediaIds] is a list of media IDs that should be removed from the hazard report.
  Future<Either<Hazard, AppError>> updateHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
    final List<String>? removedMediaIds,
  }) async {
    if (hazard.id == null) {
      return Failure(
        AppError(
          message: 'Hazard ID is required for updating a hazard report.',
        ),
      );
    }

    final result = await _hazardRepository.updateHazardReport(
      hazard: hazard,
      mediaFiles: mediaFiles,
      removedMediaIds: removedMediaIds,
    );

    final success = await result.whenSuccess(
      populateHazardWithRequiredData,
    );

    return result.copyWith(
      success: (_) => success,
    );
  }

  /// Deletes a hazard report from the server.
  Future<Either<void, AppError>> deleteHazard({
    required final String hazardId,
  }) {
    return _hazardRepository.deleteHazard(
      hazardId: hazardId,
    );
  }

  /// Votes on a hazard report.
  Future<Either<void, AppError>> voteHazard({
    required final String hazardId,
    required final HazardVoteType voteType,
  }) {
    return _hazardRepository.voteHazard(
      hazardId: hazardId,
      voteType: voteType,
    );
  }

  /// Views a hazard report.
  Future<Either<ViewHazardResponse, AppError>> viewHazard({
    required final String hazardId,
  }) {
    return _hazardRepository.viewHazard(
      hazardId: hazardId,
    );
  }

  /// Populates a hazard with any required data before processing.
  Future<Hazard> populateHazardWithRequiredData(final Hazard hazard) async {
    return hazard.copyWith(
      processedMedias: await _mediaService.convertS3MediaToAlrtMedia(
        s3Medias: hazard.medias,
      ),
    );
  }

  /// Populates a list of hazards with any required data before processing.
  Future<List<Hazard>> populateHazardsWithRequiredData(
    final List<Hazard> hazards,
  ) async {
    final futures = hazards.map(populateHazardWithRequiredData).toList();
    return Future.wait(futures);
  }

  /// Finds the first image matching [imageType] walking up the parent chain.
  CategoryImage? _findFirstImageInChain(
    final HazardCategory category,
    final CategoryImageType imageType,
  ) {
    for (HazardCategory? node = category; node != null; node = node.parent) {
      final slot = node.images?.firstWhereOrNull(
        (final image) => image.imageType == imageType,
      );
      if (slot != null && slot.url.isNotEmpty) {
        return slot;
      }
    }
    return null;
  }

  /// Generates marker bitmaps for all hazard categories and severities.
  ///
  /// Uses a three-phase approach to minimize async overhead:
  /// 1. Resolve all image chains synchronously
  /// 2. Batch-download unique images + pre-load fallback assets
  /// 3. Build bitmap map with minimal async
  Future<Either<Map<String, BitmapDescriptor>, AppError>>
  generateHazardMarkerBitmaps() async {
    _urlBytesCache.clear();
    _assetBitmapCache.clear();
    _bitmapByS3KeyCache.clear();

    final stopwatch = Stopwatch()..start();
    final categoriesResult = await getAllSubHazardCategories();
    if (categoriesResult.isFailure) {
      return Failure(categoriesResult.failure);
    }

    final categories = List<HazardCategory>.from(categoriesResult.success);
    final severityBands = HazardSeverityBand.values;
    final categoriesById = _hazardCategoriesById(categories);

    categories.add(HazardCategory(id: 'other'));

    final scheduledKeys = <String>{};
    const defaultSize = Size(40, 40);

    final parentCategoryIds = categories
        .map((cat) => cat.parentId)
        .where((parentId) => parentId != null)
        .cast<String>()
        .toSet()
        .toList();

    // Pre-compute linked categories once
    final linked = <String, HazardCategory>{};
    for (final category in categories) {
      linked[category.id] = _categoryWithLinkedParents(
        category,
        categoriesById,
      );
    }
    for (final parentId in parentCategoryIds) {
      linked.putIfAbsent(
        parentId,
        () => _categoryWithLinkedParents(
          categoriesById[parentId] ?? HazardCategory(id: parentId),
          categoriesById,
        ),
      );
    }

    // ── Phase 1: Resolve all bitmap entries synchronously ──
    // Network entries: (bitmapKey, slot, netSize, fallbackSeverity, fallbackIsAws, fallbackSize)
    final networkEntries =
        <(String, CategoryImage, Size, HazardSeverityBand, bool, Size)>[];
    // Asset-only entries: (bitmapKey, severity, isAws, size)
    final assetEntries = <(String, HazardSeverityBand, bool, Size)>[];
    // Fire status entries (nullable, no fallback): (bitmapKey, slot, size)
    final fireEntries = <(String, CategoryImage, Size)>[];

    void resolveHazard(
      final String key,
      final HazardCategory cat,
      final HazardSeverityBand severity,
      final bool isAws,
    ) {
      if (!scheduledKeys.add(key)) return;
      final imageType = _categoryImageTypeForSeverityBand(
        severity,
        isAwsCompliant: isAws,
      );
      final slot = _findFirstImageInChain(cat, imageType);
      if (slot != null) {
        networkEntries.add((
          key,
          slot,
          _markerLogicalSizeForCategoryImage(slot, defaultSize),
          severity,
          isAws,
          _markerLogicalSizeFromCategoryChainForType(
            cat,
            imageType,
            defaultSize,
          ),
        ));
      } else {
        assetEntries.add((
          key,
          severity,
          isAws,
          _markerLogicalSizeFromCategoryChainForType(
            cat,
            imageType,
            defaultSize,
          ),
        ));
      }
    }

    void resolveUser(final String key, final HazardCategory cat) {
      if (!scheduledKeys.add(key)) return;
      final slot = _findFirstImageInChain(cat, CategoryImageType.user);
      if (slot != null) {
        networkEntries.add((
          key,
          slot,
          _markerLogicalSizeForCategoryImage(slot, defaultSize),
          HazardSeverityBand.info,
          false,
          _markerLogicalSizeFromCategoryChainForType(
            cat,
            CategoryImageType.user,
            defaultSize,
          ),
        ));
      } else {
        assetEntries.add((
          key,
          HazardSeverityBand.info,
          false,
          _markerLogicalSizeFromCategoryChainForType(
            cat,
            CategoryImageType.user,
            defaultSize,
          ),
        ));
      }
    }

    void resolveFireStatus(
      final String key,
      final HazardCategory cat,
      final FireStatus status,
    ) {
      if (!scheduledKeys.add(key)) return;
      final imageType = _categoryImageTypeForFireStatus(status);
      final slot = _findFirstImageInChain(cat, imageType);
      if (slot != null) {
        fireEntries.add((
          key,
          slot,
          _markerLogicalSizeForCategoryImage(slot, defaultSize),
        ));
      }
    }

    for (final category in categories) {
      final cat = linked[category.id]!;
      for (final severity in severityBands) {
        resolveHazard(
          '${category.id}_${severity.name}_aws',
          cat,
          severity,
          true,
        );
        resolveHazard(
          '${category.id}_${severity.name}_non_aws',
          cat,
          severity,
          false,
        );
      }
      final userKey = category.parentId != null
          ? '${category.parentId}_user'
          : '${category.id}_user';
      resolveUser(userKey, cat);
      for (final fireStatus in FireStatus.values) {
        resolveFireStatus(
          '${category.id}_fireStatus_${fireStatus.name}',
          cat,
          fireStatus,
        );
      }
    }

    for (final parentId in parentCategoryIds) {
      final cat = linked[parentId]!;
      for (final severity in severityBands) {
        resolveHazard('${parentId}_${severity.name}_aws', cat, severity, true);
        resolveHazard(
          '${parentId}_${severity.name}_non_aws',
          cat,
          severity,
          false,
        );
      }
      for (final fireStatus in FireStatus.values) {
        resolveFireStatus(
          '${parentId}_fireStatus_${fireStatus.name}',
          cat,
          fireStatus,
        );
      }
    }

    // ── Phase 2: Batch-download unique images + pre-load fallback assets ──
    final uniqueDownloads = <String, String>{}; // s3Key → url
    for (final (_, slot, _, _, _, _) in networkEntries) {
      uniqueDownloads.putIfAbsent(slot.s3Key, () => slot.url);
    }
    for (final (_, slot, _) in fireEntries) {
      uniqueDownloads.putIfAbsent(slot.s3Key, () => slot.url);
    }

    // Collect unique asset fallbacks (including fallbacks for network entries
    // in case a download fails).
    final assetFutures = <String, Future<BitmapDescriptor>>{};
    void ensureAsset(HazardSeverityBand sev, bool isAws, Size size) {
      final k = '${isAws}_${sev.name}_${size.width}_${size.height}';
      assetFutures.putIfAbsent(
        k,
        () => _bitmapDescriptorOtherSeverity(
          severityBand: sev,
          isAwsCompliant: isAws,
          size: size,
        ),
      );
    }

    for (final (_, sev, isAws, size) in assetEntries) {
      ensureAsset(sev, isAws, size);
    }
    for (final (_, _, _, fallbackSev, fallbackAws, fallbackSize)
        in networkEntries) {
      ensureAsset(fallbackSev, fallbackAws, fallbackSize);
    }

    // Run all downloads and asset loads concurrently
    await Future.wait(<Future<void>>[
      ...uniqueDownloads.entries.map(
        (e) => _downloadImageBytes(e.value, cacheKey: e.key),
      ),
      ...assetFutures.values,
    ]);

    // Resolve cached results into sync maps
    final downloadedBytes = <String, Uint8List>{};
    for (final s3Key in uniqueDownloads.keys) {
      final bytes = await _urlBytesCache[s3Key]!;
      if (bytes != null) {
        downloadedBytes[s3Key] = bytes;
      }
    }
    final resolvedAssets = <String, BitmapDescriptor>{};
    for (final entry in assetFutures.entries) {
      resolvedAssets[entry.key] = await entry.value;
    }

    // ── Phase 2.5: Render downloaded images via Flutter widgets ─────────
    // BitmapDescriptor.bytes() relies on the native platform decoder which
    // silently fails for some images, producing invisible-but-tappable
    // markers.  Rendering through a Flutter widget + toBitmapDescriptor()
    // uses Skia on the Dart side, completely bypassing the native decoder.
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final renderedDescriptors = <String, BitmapDescriptor?>{};
    final renderFutures = <Future<void>>[];

    void scheduleRender(String s3Key, Size logicalSize) {
      final rk = '$s3Key|${logicalSize.width}|${logicalSize.height}';
      if (renderedDescriptors.containsKey(rk)) return;
      renderedDescriptors[rk] = null; // placeholder
      final raw = downloadedBytes[s3Key];
      if (raw == null) return;
      renderFutures.add(() async {
        try {
          final imageSize = Size(
            (logicalSize.width * dpr).ceilToDouble(),
            (logicalSize.height * dpr).ceilToDouble(),
          );
          final descriptor = await Image.memory(
            raw,
            width: logicalSize.width,
            height: logicalSize.height,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ).toBitmapDescriptor(
            logicalSize: logicalSize,
            imageSize: imageSize,
          );
          renderedDescriptors[rk] = descriptor;
        } catch (_) {}
      }());
    }

    for (final (_, slot, size, _, _, _) in networkEntries) {
      scheduleRender(slot.s3Key, size);
    }
    for (final (_, slot, size) in fireEntries) {
      scheduleRender(slot.s3Key, size);
    }
    await Future.wait(renderFutures);

    // ── Phase 3: Build bitmap map (fully sync) ──
    final bitmapMap = <String, BitmapDescriptor>{};

    BitmapDescriptor? networkBitmap(CategoryImage slot, Size size) {
      final cacheKey = '${slot.s3Key}|${size.width}|${size.height}';
      return renderedDescriptors[cacheKey];
    }

    for (final (key, slot, size, fallbackSev, fallbackAws, fallbackSize)
        in networkEntries) {
      final bitmap = networkBitmap(slot, size);
      final assetKey =
          '${fallbackAws}_${fallbackSev.name}_${fallbackSize.width}_${fallbackSize.height}';
      bitmapMap[key] = bitmap ?? resolvedAssets[assetKey]!;
    }

    for (final (key, sev, isAws, size) in assetEntries) {
      final assetKey = '${isAws}_${sev.name}_${size.width}_${size.height}';
      bitmapMap[key] = resolvedAssets[assetKey]!;
    }

    for (final (key, slot, size) in fireEntries) {
      final bitmap = networkBitmap(slot, size);
      if (bitmap != null) {
        bitmapMap[key] = bitmap;
      }
    }

    _urlBytesCache.clear();
    _bitmapByS3KeyCache.clear();
    stopwatch.stop();
    return Success(bitmapMap);
  }

  /// Gets a BitmapDescriptor for the given hazard category and severity.
  Future<BitmapDescriptor> getBitmapDescriptorForHazard({
    required final HazardCategory category,
    required final HazardSeverityBand severityBand,
    final bool isAwsCompliant = false,
    final Size size = const Size(40, 40),
  }) async {
    final imageType = _categoryImageTypeForSeverityBand(
      severityBand,
      isAwsCompliant: isAwsCompliant,
    );
    return _bitmapDescriptorFromCategoryImageChain(
      category: category,
      imageType: imageType,
      severityBandForOtherFallback: severityBand,
      isAwsCompliantForOtherFallback: isAwsCompliant,
      size: size,
    );
  }

  /// User-report marker: own [CategoryImageType.user], then parent chain, then [other_info].
  Future<BitmapDescriptor> getBitmapDescriptorForCategoryUserMarker({
    required final HazardCategory category,
    final Size size = const Size(40, 40),
  }) async {
    return _bitmapDescriptorFromCategoryImageChain(
      category: category,
      imageType: CategoryImageType.user,
      severityBandForOtherFallback: HazardSeverityBand.info,
      isAwsCompliantForOtherFallback: false,
      size: size,
    );
  }

  /// Resolves a [CategoryImage] slot to a [BitmapDescriptor], cached by s3Key+size.
  Future<BitmapDescriptor?> _bitmapForCategoryImage(
    final CategoryImage slot,
    final Size defaultSize,
  ) {
    final url = slot.url;
    if (url.isEmpty) return Future.value(null);
    final logicalSize = _markerLogicalSizeForCategoryImage(slot, defaultSize);
    final cacheKey = '${slot.s3Key}|${logicalSize.width}|${logicalSize.height}';
    return _bitmapByS3KeyCache.putIfAbsent(
      cacheKey,
      () async {
        final bytes = await _downloadImageBytes(url, cacheKey: slot.s3Key);
        if (bytes == null) return null;
        return BitmapDescriptor.bytes(
          bytes,
          width: logicalSize.width,
          height: logicalSize.height,
        );
      },
    );
  }

  /// Category → parent chain via network only; null if nothing loaded.
  Future<BitmapDescriptor?> _bitmapDescriptorFromNetworkChainOnly({
    required final HazardCategory category,
    required final CategoryImageType imageType,
    required final Size size,
  }) async {
    try {
      for (HazardCategory? node = category; node != null; node = node.parent) {
        final slot = node.images?.firstWhereOrNull(
          (final image) => image.imageType == imageType,
        );
        if (slot != null && slot.url.isNotEmpty) {
          final bitmap = await _bitmapForCategoryImage(slot, size);
          if (bitmap != null) {
            return bitmap;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Uses this category's image for [imageType], then each ancestor's own image, then `other_*`.
  Future<BitmapDescriptor> _bitmapDescriptorFromCategoryImageChain({
    required final HazardCategory category,
    required final CategoryImageType imageType,
    required final HazardSeverityBand severityBandForOtherFallback,
    required final bool isAwsCompliantForOtherFallback,
    required final Size size,
  }) async {
    final fromNet = await _bitmapDescriptorFromNetworkChainOnly(
      category: category,
      imageType: imageType,
      size: size,
    );
    if (fromNet != null) {
      return fromNet;
    }
    final assetSize = _markerLogicalSizeFromCategoryChainForType(
      category,
      imageType,
      size,
    );
    return _bitmapDescriptorOtherSeverity(
      severityBand: severityBandForOtherFallback,
      isAwsCompliant: isAwsCompliantForOtherFallback,
      size: assetSize,
    );
  }

  /// Uses [image] width/height when both are set and positive; otherwise [defaultSize].
  Size _markerLogicalSizeForCategoryImage(
    final CategoryImage image,
    final Size defaultSize,
  ) {
    final w = image.width;
    final h = image.height;
    if (w != null && h != null && w > 0 && h > 0) {
      return Size(w.toDouble(), h.toDouble());
    }
    return defaultSize;
  }

  /// First matching [imageType] in category → parent chain with valid width/height, else [defaultSize].
  Size _markerLogicalSizeFromCategoryChainForType(
    final HazardCategory category,
    final CategoryImageType imageType,
    final Size defaultSize,
  ) {
    for (HazardCategory? node = category; node != null; node = node.parent) {
      final slot = node.images?.firstWhereOrNull(
        (final image) => image.imageType == imageType,
      );
      if (slot == null) {
        continue;
      }
      final w = slot.width;
      final h = slot.height;
      if (w != null && h != null && w > 0 && h > 0) {
        return Size(w.toDouble(), h.toDouble());
      }
    }
    return defaultSize;
  }

  Future<Uint8List?> _downloadImageBytes(
    final String url, {
    final String? cacheKey,
  }) {
    final key = cacheKey ?? url;
    return _urlBytesCache.putIfAbsent(
      key,
      () async {
        // Check disk cache first (fast local lookup)
        try {
          final cacheResult = await _cacheManagerService.getSingleFileFromCache(
            key: key,
          );
          final file = cacheResult.when((f) => f, (_) => null);
          if (file != null) {
            return file.readAsBytes();
          }
        } catch (_) {}

        // Cache miss — download from network
        return _downloadPool.run(() async {
          try {
            final response = await _markerImageDio.get<List<int>>(
              url,
              options: Options(responseType: ResponseType.bytes),
            );
            final data = response.data;
            if (data == null || data.isEmpty) return null;
            final bytes = data is Uint8List ? data : Uint8List.fromList(data);

            // Fire-and-forget: cache for next app launch
            _cacheManagerService.getSingleFile(
              url: url,
              key: key,
              fileExtension: 'png',
            );

            return bytes;
          } catch (e) {
            return null;
          }
        });
      },
    );
  }

  Future<BitmapDescriptor?> getBitmapDescriptorFromUrl({
    required final String url,
    required final Size logicalSize,
  }) async {
    final bytes = await _downloadImageBytes(url);
    if (bytes == null) return null;
    try {
      final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final imageSize = Size(
        (logicalSize.width * dpr).ceilToDouble(),
        (logicalSize.height * dpr).ceilToDouble(),
      );
      return await Image.memory(
        bytes,
        width: logicalSize.width,
        height: logicalSize.height,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ).toBitmapDescriptor(
        logicalSize: logicalSize,
        imageSize: imageSize,
      );
    } catch (_) {}
    return null;
  }

  Map<String, HazardCategory> _hazardCategoriesById(
    final List<HazardCategory> categories,
  ) {
    final map = <String, HazardCategory>{};
    for (final c in categories) {
      map[c.id] = c;
      var walk = c.parent;
      while (walk != null) {
        map[walk.id] = walk;
        walk = walk.parent;
      }
    }
    return map;
  }

  HazardCategory _categoryWithLinkedParents(
    final HazardCategory category,
    final Map<String, HazardCategory> byId,
  ) {
    if (category.parent != null || category.parentId == null) {
      return category;
    }
    final parent = byId[category.parentId!];
    if (parent == null) {
      return category;
    }
    return category.copyWith(
      parent: _categoryWithLinkedParents(parent, byId),
    );
  }

  CategoryImageType _categoryImageTypeForFireStatus(final FireStatus status) {
    return switch (status) {
      FireStatus.active => CategoryImageType.fireActive,
      FireStatus.beingControlled => CategoryImageType.fireBeingControlled,
      FireStatus.underControl => CategoryImageType.fireUnderControl,
      FireStatus.closed => CategoryImageType.fireClosed,
    };
  }

  CategoryImageType _categoryImageTypeForSeverityBand(
    final HazardSeverityBand band, {
    required final bool isAwsCompliant,
  }) {
    if (isAwsCompliant) {
      return switch (band) {
        HazardSeverityBand.info => CategoryImageType.advice,
        HazardSeverityBand.monitor => CategoryImageType.advice,
        HazardSeverityBand.action => CategoryImageType.watchAndAct,
        HazardSeverityBand.critical => CategoryImageType.emergency,
      };
    }
    return switch (band) {
      HazardSeverityBand.info => CategoryImageType.info,
      HazardSeverityBand.monitor => CategoryImageType.monitor,
      HazardSeverityBand.action => CategoryImageType.action,
      HazardSeverityBand.critical => CategoryImageType.critical,
    };
  }

  /// Local fallback markers: only the generic `other_*` assets are kept on disk.
  Future<BitmapDescriptor> _bitmapDescriptorOtherSeverity({
    required final HazardSeverityBand severityBand,
    required final bool isAwsCompliant,
    required final Size size,
  }) {
    final cacheKey =
        '${isAwsCompliant}_${severityBand.name}_${size.width}_${size.height}';
    return _assetBitmapCache.putIfAbsent(
      cacheKey,
      () async {
        try {
          final assetPath =
              'assets/images/hazards/${isAwsCompliant ? 'aws/' : 'non_aws/'}other_${severityBand.name}.png';
          final dpr =
              ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
          final imageSize = Size(
            (size.width * dpr).ceilToDouble(),
            (size.height * dpr).ceilToDouble(),
          );
          return await Image.asset(
            assetPath,
            width: size.width,
            height: size.height,
            fit: BoxFit.contain,
          ).toBitmapDescriptor(
            logicalSize: size,
            imageSize: imageSize,
          );
        } catch (e) {
          return BitmapDescriptor.defaultMarker;
        }
      },
    );
  }
}
