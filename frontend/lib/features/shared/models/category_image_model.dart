import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/enums/category_image_type.dart';

part 'category_image_model.freezed.dart';
part 'category_image_model.g.dart';

@freezed
abstract class CategoryImage with _$CategoryImage {
  const CategoryImage._();

  const factory CategoryImage({
    required final String id,
    required final String categoryId,
    required final CategoryImageType imageType,
    @JsonKey(name: 'presignedUrl') required final String url,
    required final String s3Key,
    final int? width,
    final int? height,
    final int? fileSizeBytes,
  }) = _CategoryImage;

  factory CategoryImage.fromJson(Map<String, dynamic> json) =>
      _$CategoryImageFromJson(json);
}
