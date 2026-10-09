import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/report/views/widgets/create_report_medias_list_item.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/dotted_border_container.dart';
import 'package:hazard_app/others/app_colors.dart';

class CreateReportMediasList extends ConsumerStatefulWidget {
  /// Displays a list of media items (images/videos) associated with a report.
  const CreateReportMediasList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateReportMediasListState();
}

class _CreateReportMediasListState
    extends ConsumerState<CreateReportMediasList> {
  @override
  Widget build(BuildContext context) {
    final medias = ref.watch(
      providerOfCreateReport.select(
        (value) => value.medias,
      ),
    );
    return GridView.builder(
      itemCount: medias.length + 1,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.spMin,
        crossAxisSpacing: 10.spMin,
      ),
      itemBuilder: (context, index) {
        if (index == 0) return _addButtonBuilder();

        final media = medias[index - 1];
        return CreateReportMediasListItem(
          media: media,
        );
      },
    );
  }

  Widget _addButtonBuilder() {
    return DottedBorderContainer(
      borderColor: AppColors.lightGrey,
      borderRadius: 14.spMin,
      strokeWidth: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.spMin),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 30.spMin,
          color: AppColors.grey.withValues(alpha: 0.8),
        ),
      ).onPressed(_pickMedias),
    );
  }

  /// Handles the action of picking multiple media files when the add button is pressed.
  void _pickMedias() async {
    context.unfocusInputs();
    final medias = await showImagePickerBottomSheet(
      context: context,
    );
    if (!mounted) return;
    if (medias != null && medias.isNotEmpty) {
      ref.read(providerOfCreateReport.notifier).addMedias(medias);
    }
  }
}
