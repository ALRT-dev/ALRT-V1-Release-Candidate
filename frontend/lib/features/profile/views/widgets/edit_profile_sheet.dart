import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the "Your photo" sheet from the Me tab (the avatar and the Edit
/// link both land here), as on the prototype "ProfilePhoto" board: photo
/// (groups only, never the map) and display name.
Future<void> showEditProfileSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) => const EditProfileSheet(),
  );
}

/// The display name a Save will send, or null when nothing should be
/// sent: blank input, or the same name the account already has. Pure, so
/// the rule is testable without a widget.
String? displayNameToSave({
  required final String input,
  required final String? current,
}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed == (current ?? '').trim()) return null;
  return trimmed;
}

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  static const _hairline = Color(0xFFE3E6EA);
  static const _danger = Color(0xFFDA1F2D);

  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(providerOfLoggedInUser)?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(providerOfLoggedInUser);
    final photo = ref.watch(
      providerOfProfile.select((s) => s.profilePicture),
    );
    final media = photo ?? user?.processedProfilePicture;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 16.spMin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36.spMin,
                    height: 4.spMin,
                    decoration: BoxDecoration(
                      color: _hairline,
                      borderRadius: BorderRadius.circular(2.spMin),
                    ),
                  ),
                ),
                SizedBox(height: 14.spMin),
                const ProfileSheetTitle(
                  title: 'Your photo',
                  subtitle: 'Shown to the people in your groups only. Never '
                      'on the map, never on a report.',
                ),
                SizedBox(height: 12.spMin),
                Row(
                  children: [
                    _buildAvatar(user: user, media: media),
                    SizedBox(width: 14.spMin),
                    Expanded(
                      child: ProfileButton(
                        key: const Key('edit-profile-photo'),
                        label: 'Choose a photo',
                        kind: ProfileButtonKind.secondary,
                        onPressed: _saving ? null : _showPhotoPicker,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.spMin),
                TextField(
                  key: const Key('edit-profile-name'),
                  controller: _nameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: 60,
                  onSubmitted: (_) => _save(),
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Your name',
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 14.spMin,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(
                        color: _hairline,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(
                        color: _hairline,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(
                        color: AppColors.orange,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.spMin),
                ProfileButton(
                  key: const Key('edit-profile-save'),
                  label: 'Save',
                  busy: _saving,
                  onPressed: _save,
                ),
                if (media != null)
                  ProfileButton(
                    label: 'Remove photo',
                    kind: ProfileButtonKind.ghost,
                    onPressed: _saving
                        ? null
                        : () => ref
                            .read(providerOfProfile.notifier)
                            .deleteProfilePicture(),
                  ),
                ProfileButton(
                  label: 'Close',
                  kind: ProfileButtonKind.ghost,
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 72 px avatar: the photo when there is one, else initials on the brand
  /// gradient. Tapping it opens the same picker as "Choose a photo".
  Widget _buildAvatar({
    required final AppUser? user,
    required final AlrtMedia? media,
  }) {
    final size = 72.spMin;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orange300, AppColors.red200],
        ),
      ),
      child: _buildAvatarContent(media: media, user: user),
    ).onPressed(_saving ? null : _showPhotoPicker);
  }

  Widget _buildAvatarContent({
    required final AlrtMedia? media,
    required final AppUser? user,
  }) {
    if (media != null) {
      switch (media.source) {
        case AlrtMediaSource.file:
          return Image.file(File(media.value), fit: BoxFit.cover);
        case AlrtMediaSource.networkUrl:
          return Image.network(
            media.value,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildInitials(user),
          );
        case AlrtMediaSource.asset:
          return Image.asset(media.value, fit: BoxFit.cover);
      }
    }
    return _buildInitials(user);
  }

  Widget _buildInitials(final AppUser? user) {
    return Center(
      child: Text(
        user?.initials ?? 'U',
        style: TextStyle(
          fontSize: 26.spMin,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  /// The photo picker that used to be the whole "Edit" action: Take photo,
  /// Choose from library, Remove photo. Each one goes through the profile
  /// provider's existing PUT / DELETE profile-picture calls.
  void _showPhotoPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.spMin),
              child: Text(
                'Edit photo',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.black),
              title: Text(
                'Take photo',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppColors.black),
              title: Text(
                'Choose from library',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.gallery);
              },
            ),
            if (ref.read(providerOfLoggedInUser)?.processedProfilePicture !=
                null)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: _danger),
                title: Text(
                  'Remove photo',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(providerOfProfile.notifier).deleteProfilePicture();
                },
              ),
            SizedBox(height: 8.spMin),
          ],
        ),
      ),
    );
  }

  /// PUT /api/user with the current user plus the new name, through the
  /// existing user service; the logged-in-user provider is then refreshed
  /// from the server's answer (keeping the locally picked photo).
  Future<void> _save() async {
    if (_saving) return;
    final current = ref.read(providerOfLoggedInUser);
    final name = displayNameToSave(
      input: _nameController.text,
      current: current?.name,
    );
    if (name == null) {
      if (_nameController.text.trim().isEmpty) {
        context.showErrorToast(message: 'Enter a display name.');
        return;
      }
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    final result = await ref
        .read(providerOfUserService)
        .updateCurrentUser(user: (current ?? const AppUser()).copyWith(name: name));
    if (!mounted) return;
    setState(() => _saving = false);

    result.when(
      (updated) {
        ref.read(providerOfLoggedInUser.notifier).update(
              (user) => updated.copyWith(
                name: updated.name ?? name,
                processedProfilePicture: user?.processedProfilePicture ??
                    updated.processedProfilePicture,
              ),
            );
        context.showSuccessToast(message: 'Profile saved.');
        Navigator.of(context).pop();
      },
      (error) {
        context.showErrorToast(
          message: error.message.isEmpty
              ? 'Could not save your profile. Please try again.'
              : error.message,
        );
      },
    );
  }
}
